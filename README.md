# Device Recovery Analysis

> **Tujuan:** Mengumpulkan seluruh informasi teknis perangkat Android sebagai dasar pembuatan custom recovery (TWRP).

---

## Sumber Analisis

| Metode | Keterangan |
|--------|------------|
| **A** | Perangkat Android via ADB (Tanpa Root) |
| **B** | Perangkat Android yang sudah Root |
| **C** | Firmware resmi (Offline) |

---

## Tools yang Dibutuhkan

### Platform Tools (Wajib)

| Tool | Keterangan | Link |
|------|------------|------|
| **ADB** | Android Debug Bridge - komunikasi PC ke perangkat | [Download](https://developer.android.com/tools/releases/platform-tools) |
| **Fastboot** | Flashing dan bootloader interface | Bundling dengan Platform Tools |

### Firmware Analysis Tools

| Tool | Keterangan | Link |
|------|------------|------|
| **magiskboot** | Unpack/pack boot image, vendor_boot, dll | Bundling dengan [Magisk](https://github.com/topjohnwu/Magisk/releases) |
| **unpack_bootimg** | Unpack boot image (AOSP) | [AOSP Build Tools](https://android.googlesource.com/platform/system/tools/+) |
| **avbtool** | Analisis Android Verified Boot (vbmeta) | Bundling dengan AOSP |
| **lpunpack** | Unpack super.img (dynamic partition) | Bundling dengan AOSP |
| **lpdump** | Dump info dynamic partition | Bundling dengan AOSP |
| **dtc** | Device Tree Compiler | [GitHub](https://github.com/dgibson/dtc) |
| **extract-dtb** | Ekstrak device tree dari kernel | [GitHub](https://github.com/pbatard/extract-dtb) |

### Partition & Image Tools

| Tool | Keterangan | Link |
|------|------------|------|
| **dd** | Dump/partisi image dari block device (via ADB shell) | Built-in Linux/Android |
| **simg2img** | Konversi sparse image ke raw image | [Android Tools](https://android.googlesource.com/platform/system/core/+/refs/heads/main/libsparse/) |
| **img2simg** | Konversi raw image ke sparse image | Bundling dengan simg2img |
| **imgdump** | Dump dan analisis boot.img header | [GitHub](https://github.com/nickcano/imgdump) |
| **sbootimg** | Unpack Samsung boot.img format | [GitHub](https://github.com/nickcano/sbootimg) |
| **mkbootimg** | Buat/pack boot.img dari komponen | [AOSP](https://android.googlesource.com/platform/system/tools/mkbootimg/) |
| **unpackelf** | Unpack ELF boot image (Qualcomm) | Bundling dengan TWRP source |
| **mke2fs / tune2fs** | Buat dan manage ext4 filesystem image | Built-in Linux |
| **f2fs-tools** | Tool untuk f2fs filesystem image | [GitHub](https://github.com/ArtifexSoftware/ArtifexSoftware-f2fs-tools) |
| **Android Image Kitchen** | Tool all-in-one unpack/repack kernel + ramdisk | [GitHub](https://github.com/osm0sis/Android-Image-Kitchen) |

### Payload Dumper (Ekstrak dari OTA)

Tool untuk mengekstrak partition images dari `payload.bin` di dalam OTA firmware.

| Tool | Bahasa | Instalasi | Link |
|------|--------|-----------|------|
| **android-payload-dumper** | Python | `pipx install android-payload-dumper` | [GitHub](https://github.com/nickcano/payload-dumper) |
| **payload-dumper-go** | Go | Download binary | [GitHub](https://github.com/ssut/payload-dumper-go) |
| **payload-dumper-rust** | Rust | Download binary | [GitHub](https://github.com/rhythmcache/payload-dumper-rust) |
| **payload_dumper** (legacy) | Python | `pip install protobuf` | [GitHub](https://github.com/vm03/payload_dumper) |

#### Dependensi

| Tool | Dependensi |
|------|------------|
| **android-payload-dumper** | Python 3.9+, httpx, protobuf, rich |
| **payload-dumper-go** | xz (liblzma) |
| **payload-dumper-rust** | Tidak ada (static binary) |
| **payload_dumper (legacy)** | Python 3.6+, protobuf |

#### Contoh Penggunaan

```bash
# Android Payload Dumper (Python)
payload-dumper payload.bin
payload-dumper firmware_ota.zip
payload-dumper -p boot,vendor_boot payload.bin

# Payload Dumper Go
payload-dumper-go payload.bin
payload-dumper-go -p boot payload.bin

# Legacy Python
python payload_dumper.py payload.bin
```

### Perangkat Android

| Kebutuhan | Keterangan |
|-----------|------------|
| **USB Debugging** | Aktif di Developer Options |
| **Root Access** | Magisk / KernelSU (untuk analisis lanjutan) |
| **USB Cable** | Koneksi stabil ke PC |

### System Requirements

| OS | Keterangan |
|----|------------|
| **Linux** | Direkomendasikan (Ubuntu/Debian) |
| **Windows** | DIDukung dengan WSL atau native |
| **macOS** | DIDukung |

---

## Daftar Isi

1. [Device Identification](#1-device-identification)
2. [Partition Analysis](#2-partition-analysis)
3. [Mount Analysis](#3-mount-analysis)
4. [Boot Architecture](#4-boot-architecture)
5. [Dump Boot Image](#5-dump-boot-image-root)
6. [Recovery Analysis](#6-recovery-analysis)
7. [Vendor Boot Analysis](#7-vendor-boot-analysis)
8. [Device Tree Analysis](#8-device-tree-analysis)
9. [Encryption Analysis](#9-encryption-analysis)
10. [AVB Analysis](#10-avb-analysis)
11. [Dynamic Partition](#11-dynamic-partition)
12. [Slot A/B](#12-slot-ab)
13. [Display Analysis](#13-display-analysis)
14. [Touchscreen Analysis](#14-touchscreen-analysis)
15. [USB Analysis](#15-usb-analysis)
16. [Kernel Log](#16-kernel-log)
17. [Firmware Analysis (Offline)](#17-firmware-analysis-offline)

---

## 1. Device Identification

**Tujuan:** Mengidentifikasi perangkat dan lingkungan sistem.

### Tanpa Root

```bash
adb shell getprop
```

Atau informasi yang lebih spesifik:

```bash
adb shell getprop ro.product.brand
adb shell getprop ro.product.model
adb shell getprop ro.product.device
adb shell getprop ro.build.fingerprint
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell getprop ro.boot.slot_suffix
adb shell getprop ro.boot.hardware
```

### Kernel

```bash
adb shell uname -a
adb shell cat /proc/version
```

### CPU

```bash
adb shell cat /proc/cpuinfo
```

### Memori

```bash
adb shell cat /proc/meminfo
```

### Output yang Didokumentasikan

| Field | Nilai |
|-------|-------|
| Brand | |
| Model | |
| Codename | |
| SoC | |
| Android Version | |
| SDK | |
| Kernel Version | |
| Slot A/B | |
| Build Fingerprint | |

---

## 2. Partition Analysis

### Tanpa Root

```bash
adb shell cat /proc/partitions
adb shell ls -l /dev/block/by-name
```

### Root

```bash
adb shell su
ls -l /dev/block/by-name
```

### Output

| Field | Nilai |
|-------|-------|
| Nama Partisi | |
| Ukuran | |
| Block Device | |
| Logical / Physical | |

---

## 3. Mount Analysis

### Tanpa Root

```bash
adb shell mount
```

Atau

```bash
adb shell cat /proc/mounts
```

### Root

```bash
adb shell su
cat /proc/mounts
```

### Output

| Field | Nilai |
|-------|-------|
| Filesystem | |
| Mount Point | |
| Mount Option | |

---

## 4. Boot Architecture

### Boot Header

Jika memiliki boot.img:

```bash
unpack_bootimg --boot_img boot.img
```

Atau

```bash
magiskboot unpack boot.img
```

### Output

| Field | Nilai |
|-------|-------|
| Header Version | |
| Kernel Size | |
| Ramdisk Size | |
| Page Size | |
| DTB | |

---

## 5. Dump Boot Image (Root)

```bash
adb shell su
dd if=/dev/block/by-name/boot of=/sdcard/boot.img
```

```bash
dd if=/dev/block/by-name/vendor_boot of=/sdcard/vendor_boot.img
```

```bash
dd if=/dev/block/by-name/init_boot of=/sdcard/init_boot.img
```

```bash
dd if=/dev/block/by-name/vbmeta of=/sdcard/vbmeta.img
```

```bash
dd if=/dev/block/by-name/dtbo of=/sdcard/dtbo.img
```

---

## 6. Recovery Analysis

Jika recovery partition ada:

```bash
dd if=/dev/block/by-name/recovery of=/sdcard/recovery.img
magiskboot unpack recovery.img
```

### Analisis

- kernel
- ramdisk
- recovery binary
- init.rc

---

## 7. Vendor Boot Analysis

```bash
magiskboot unpack vendor_boot.img
```

Atau

```bash
unpack_bootimg --boot_img vendor_boot.img
```

### Yang Perlu Dicari

- fstab
- init.recovery.rc
- vendor ramdisk

---

## 8. Device Tree Analysis

```bash
extract-dtb kernel
```

Atau

```bash
dtc -I dtb -O dts xxx.dtb
```

### Output

| Field | Nilai |
|-------|-------|
| Panel | |
| GPIO | |
| Touch | |
| USB | |
| Battery | |

---

## 9. Encryption Analysis

### Tanpa Root

```bash
adb shell getprop | grep crypto
```

### Root

```bash
adb shell su
ls /metadata
cat /vendor/etc/fstab*
```

### Output

| Field | Nilai |
|-------|-------|
| FDE / FBE | |
| Metadata Partition | |

---

## 10. AVB Analysis

Jika ada vbmeta:

```bash
avbtool info_image --image vbmeta.img
```

### Output

| Field | Nilai |
|-------|-------|
| AVB Version | |
| Verification | |
| Rollback Index | |

---

## 11. Dynamic Partition

Jika memiliki super.img:

```bash
lpunpack super.img output/
```

Atau

```bash
lpdump super.img
```

### Output

| Partisi | Keterangan |
|---------|------------|
| system | |
| vendor | |
| product | |
| odm | |

---

## 12. Slot A/B

### Tanpa Root

```bash
adb shell getprop ro.boot.slot_suffix
```

### Fastboot

```bash
fastboot getvar current-slot
```

### Output

| Field | Nilai |
|-------|-------|
| Slot A/B | |
| Current Slot | |
| Boot Control HAL | |

---

## 13. Display Analysis

### Root

```bash
adb shell su
dumpsys display
```

Atau

```bash
wm size
wm density
```

### Output

| Field | Nilai |
|-------|-------|
| Resolution | |
| Density | |
| Orientation | |

---

## 14. Touchscreen Analysis

### Root

```bash
adb shell su
getevent -pl
```

Atau

```bash
cat /proc/bus/input/devices
```

### Output

| Field | Nilai |
|-------|-------|
| Driver | |
| Event Node | |
| Multitouch | |

---

## 15. USB Analysis

```bash
adb devices
adb shell getprop sys.usb.config
```

### Output

| Field | Nilai |
|-------|-------|
| ADB | |
| MTP | |
| FastbootD | |

---

## 16. Kernel Log

### Root

```bash
adb shell su
dmesg
```

Atau

```bash
cat /proc/kmsg
```

---

## 17. Firmware Analysis (Offline)

Jika menggunakan firmware resmi, ekstrak file berikut:

- `boot.img`
- `vendor_boot.img`
- `init_boot.img`
- `vbmeta.img`
- `dtbo.img`
- `super.img`

### Tools yang Digunakan

| Tool | Keterangan |
|------|------------|
| `magiskboot` | Unpack boot/vendor_boot |
| `unpack_bootimg` | Unpack boot image |
| `lpunpack` | Unpack dynamic partition |
| `avbtool` | Analisis AVB |
| `dtc` | Device Tree Compiler |
| `extract-dtb` | Ekstrak Device Tree |

---

## TWRP Porting Tool

Script workflow otomatis untuk porting TWRP:

| Script | Fungsi |
|--------|--------|
| `twrp-tool.sh` | Main menu - jalankan ini |
| `01-unpack.sh` | Bongkar boot images dari perangkat |
| `02-analyze.sh` | Analisis semua komponen |
| `03-patch.sh` | Patch untuk TWRP |
| `04-repack.sh` | Gabungkan jadi TWRP boot image |

**Cara pakai:**
```bash
cd tools
bash twrp-tool.sh
# Pilih [5] Full Workflow
```

Lihat [tools/README.md](tools/README.md) untuk dokumentasi lengkap.

---

## Hasil Akhir

Setelah seluruh langkah selesai, Anda akan memiliki dokumentasi lengkap yang mencakup:

- Identitas perangkat
- Arsitektur boot
- Layout partisi
- Struktur `boot.img` dan `vendor_boot.img`
- `fstab`
- Device Tree (DTB/DTBO)
- Konfigurasi kernel
- Mekanisme enkripsi
- AVB
- Dynamic Partitions
- Skema slot A/B
- Informasi layar dan touchscreen
- Dukungan USB/FastbootD

Dokumentasi ini menjadi **fondasi** untuk tahap berikutnya: menyusun **device tree TWRP**, mengonfigurasi `BoardConfig.mk`, `recovery.fstab`, memilih kernel yang sesuai, dan melakukan proses build serta debugging TWRP.

---

## Referensi

- [TeamWin Recovery Project](https://twrp.me/)
- [Magisk Documentation](https://topjohnwu.github.io/Magisk/)
- [Android Open Source Project](https://source.android.com/)
