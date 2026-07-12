# Device-Recovery-Analysis
Tujuan: Mengumpulkan seluruh informasi teknis perangkat sebagai dasar pembuatan custom recovery (TWRP).
Bisa. Saya justru menyarankan dokumentasi dibuat seperti **playbook** atau **checklist** yang dapat dijalankan langkah demi langkah. Dengan begitu, setiap analisis menghasilkan output yang konsisten.

Berikut contoh struktur untuk **Tahap 1 – Device Recovery Analysis**.

---

Mengumpulkan seluruh informasi teknis perangkat sebagai dasar pembuatan custom recovery (TWRP).

## Sumber Analisis

* Metode A: Perangkat Android (ADB)
* Metode B: Perangkat Android yang sudah root
* Metode C: Firmware resmi (offline)

---

# 1. Device Identification

## Tujuan

Mengidentifikasi perangkat dan lingkungan sistem.

### Tanpa Root

```bash
adb shell getprop
```

atau informasi yang lebih spesifik:

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

### Output yang didokumentasikan

* Brand
* Model
* Codename
* SoC
* Android Version
* SDK
* Kernel Version
* Slot A/B
* Build Fingerprint

---

# 2. Partition Analysis

## Tanpa Root

```bash
adb shell cat /proc/partitions
```

```bash
adb shell ls -l /dev/block/by-name
```

(jika diizinkan)

### Root

```bash
adb shell
su

ls -l /dev/block/by-name
```

### Output

* Nama partisi
* Ukuran
* Block device
* Logical / Physical

---

# 3. Mount Analysis

### Tanpa Root

```bash
adb shell mount
```

atau

```bash
adb shell cat /proc/mounts
```

### Root

```bash
adb shell
su

cat /proc/mounts
```

Output:

* Filesystem
* Mount Point
* Mount Option

---

# 4. Boot Architecture

## Boot Header

Jika memiliki boot.img

```bash
unpack_bootimg --boot_img boot.img
```

atau

```bash
magiskboot unpack boot.img
```

Output:

* Header Version
* Kernel Size
* Ramdisk Size
* Page Size
* DTB

---

# 5. Dump Boot Image (Root)

```bash
adb shell
su

dd if=/dev/block/by-name/boot of=/sdcard/boot.img
```

vendor_boot

```bash
dd if=/dev/block/by-name/vendor_boot of=/sdcard/vendor_boot.img
```

init_boot

```bash
dd if=/dev/block/by-name/init_boot of=/sdcard/init_boot.img
```

vbmeta

```bash
dd if=/dev/block/by-name/vbmeta of=/sdcard/vbmeta.img
```

dtbo

```bash
dd if=/dev/block/by-name/dtbo of=/sdcard/dtbo.img
```

---

# 6. Recovery Analysis

Jika recovery partition ada

```bash
dd if=/dev/block/by-name/recovery of=/sdcard/recovery.img
```

Ekstrak

```bash
magiskboot unpack recovery.img
```

Analisis:

* kernel
* ramdisk
* recovery binary
* init.rc

---

# 7. Vendor Boot Analysis

```bash
magiskboot unpack vendor_boot.img
```

atau

```bash
unpack_bootimg --boot_img vendor_boot.img
```

Cari:

```
fstab
init.recovery.rc
vendor ramdisk
```

---

# 8. Device Tree Analysis

Ekstrak DTB

```bash
extract-dtb kernel
```

atau

```bash
dtc -I dtb -O dts xxx.dtb
```

Output:

* Panel
* GPIO
* Touch
* USB
* Battery

---

# 9. Encryption Analysis

### Tanpa Root

```bash
adb shell getprop | grep crypto
```

### Root

```bash
adb shell
su

ls /metadata
```

```bash
cat /vendor/etc/fstab*
```

Output:

* FDE
* FBE
* Metadata Partition

---

# 10. AVB Analysis

Jika ada vbmeta

```bash
avbtool info_image --image vbmeta.img
```

Output:

* AVB Version
* Verification
* Rollback Index

---

# 11. Dynamic Partition

Jika memiliki super.img

```bash
lpunpack super.img output/
```

atau

```bash
lpdump super.img
```

Output

* system
* vendor
* product
* odm

---

# 12. Slot A/B

Tanpa Root

```bash
adb shell getprop ro.boot.slot_suffix
```

Fastboot

```bash
fastboot getvar current-slot
```

Output

```
Slot A/B

Current Slot

Boot Control HAL
```

---

# 13. Display Analysis

Root

```bash
adb shell
su

dumpsys display
```

atau

```bash
wm size

wm density
```

Output

```
Resolution

Density

Orientation
```

---

# 14. Touchscreen Analysis

Root

```bash
adb shell
su

getevent -pl
```

atau

```bash
cat /proc/bus/input/devices
```

Output

```
Driver

Event Node

Multitouch
```

---

# 15. USB Analysis

ADB

```bash
adb devices
```

USB Config

```bash
adb shell getprop sys.usb.config
```

Output

```
ADB

MTP

FastbootD
```

---

# 16. Kernel Log

Root

```bash
adb shell
su

dmesg
```

atau

```bash
cat /proc/kmsg
```

Output

Semua log kernel yang berguna untuk debugging.

---

# 17. Firmware Analysis (Offline)

Jika menggunakan firmware resmi:

Ekstrak:

```
boot.img

vendor_boot.img

init_boot.img

vbmeta.img

dtbo.img

super.img
```

Kemudian analisis menggunakan:

* `magiskboot`
* `unpack_bootimg`
* `lpunpack`
* `avbtool`
* `dtc`
* `extract-dtb`

---

## Hasil Akhir

Setelah seluruh langkah selesai, Anda akan memiliki dokumentasi lengkap yang mencakup:

* Identitas perangkat
* Arsitektur boot
* Layout partisi
* Struktur `boot.img`
* Struktur `vendor_boot.img`
* `fstab`
* Device Tree (DTB/DTBO)
* Konfigurasi kernel
* Mekanisme enkripsi
* AVB
* Dynamic Partitions
* Skema slot A/B
* Informasi layar dan touchscreen
* Dukungan USB/FastbootD

Dokumentasi ini menjadi **fondasi** untuk tahap berikutnya, yaitu menyusun **device tree TWRP**, mengonfigurasi `BoardConfig.mk`, `recovery.fstab`, memilih kernel yang sesuai, dan melakukan proses build serta debugging TWRP.
---
Menurut saya itu pilihan yang tepat. Saya bahkan akan memecahnya menjadi beberapa **playbook** yang saling berkaitan, bukan satu dokumen besar. Dengan begitu, setiap playbook memiliki tujuan, input, output, dan checklist yang jelas.

Saya menyarankan struktur seperti berikut.

```text
Android Recovery Research
│
├── Playbook-00-Prerequisites.md
├── Playbook-01-Device-Identification.md
├── Playbook-02-Boot-Architecture.md
├── Playbook-03-Partition-Analysis.md
├── Playbook-04-Boot-Image-Analysis.md
├── Playbook-05-Recovery-Analysis.md
├── Playbook-06-Kernel-Analysis.md
├── Playbook-07-Device-Tree-Analysis.md
├── Playbook-08-Filesystem-Mount.md
├── Playbook-09-Encryption.md
├── Playbook-10-Display-Touch.md
├── Playbook-11-AVB.md
├── Playbook-12-Dynamic-Partition.md
├── Playbook-13-Build-Preparation.md
└── Checklist.md
```

Ini lebih mirip dokumentasi internal tim Android daripada sekadar catatan.

---

# Contoh Format Playbook

Semua playbook memiliki format yang sama.

```markdown
# Playbook XX - Nama

## Tujuan

## Prasyarat

## Sumber Data

## Tools

## Langkah

## Perintah

## Output yang Dikumpulkan

## Cara Verifikasi

## Catatan

## Kesimpulan
```

Jadi nanti semua playbook konsisten.

---

# Contoh Nyata

## Playbook-01-Device-Identification.md

# Tujuan

Mengidentifikasi spesifikasi dasar perangkat.

---

## Prasyarat

* USB Debugging aktif
* ADB terpasang

---

## Tools

* adb

---

## Langkah 1

Pastikan perangkat terhubung.

```bash
adb devices
```

Checklist

```
☐ Device terdeteksi
```

---

## Langkah 2

Ambil informasi build.

```bash
adb shell getprop
```

atau

```bash
adb shell getprop ro.product.model
adb shell getprop ro.product.device
adb shell getprop ro.build.version.release
adb shell getprop ro.build.version.sdk
adb shell getprop ro.build.fingerprint
```

Checklist

```
☐ Model

☐ Codename

☐ Android Version

☐ SDK

☐ Fingerprint
```

---

## Langkah 3

Kernel.

```bash
adb shell uname -a
```

Checklist

```
☐ Kernel Version

☐ Architecture
```

---

## Output

```yaml
Brand:

Model:

Codename:

Android:

SDK:

Kernel:

Architecture:
```

---

## Verifikasi

Semua informasi berhasil diperoleh.

```
☐ PASS

☐ FAIL
```

---

# Playbook berikutnya

Misalnya

Playbook-03-Partition-Analysis.md

Setiap langkah memiliki checklist.

```
☐ Dump daftar partisi

☐ Identifikasi boot

☐ Identifikasi vendor_boot

☐ Identifikasi init_boot

☐ Identifikasi vbmeta

☐ Identifikasi dtbo

☐ Identifikasi super

☐ Identifikasi userdata
```

Perintahnya misalnya

```bash
adb shell cat /proc/partitions
```

Root

```bash
adb shell

su

ls -l /dev/block/by-name
```

Output

```yaml
boot:

vendor_boot:

init_boot:

vbmeta:

super:

userdata:
```

---

# Checklist Besar

Di akhir ada satu file khusus.

## Device Recovery Checklist

### Device

```
☐ Model

☐ Codename

☐ Android

☐ Kernel
```

### Boot

```
☐ Boot Header

☐ Kernel

☐ Ramdisk

☐ Cmdline

☐ DTB
```

### Partition

```
☐ boot

☐ vendor_boot

☐ init_boot

☐ vbmeta

☐ dtbo

☐ super

☐ userdata
```

### Recovery

```
☐ Recovery Partition

☐ Recovery-as-Boot

☐ FastbootD
```

### Security

```
☐ AVB

☐ Encryption

☐ Metadata
```

### Hardware

```
☐ Display

☐ Touch

☐ USB

☐ Battery
```

### Build Preparation

```
☐ BoardConfig

☐ recovery.fstab

☐ kernel

☐ DTB

☐ vendor_boot

☐ blobs
```

---

## Yang saya rekomendasikan

Kalau tujuan Anda adalah **membuat panduan lengkap pembuatan TWRP dari nol**, saya akan menyusunnya seperti dokumentasi engineering yang berurutan, misalnya sekitar **15–20 playbook**. Setiap playbook fokus pada satu topik, berisi:

* tujuan analisis,
* prasyarat,
* perintah untuk **HP non-root**,
* perintah untuk **HP root**,
* perintah untuk **analisis firmware offline**,
* contoh output,
* cara memverifikasi hasil,
* serta hubungan hasil analisis tersebut dengan proses build TWRP.

Dengan format seperti itu, playbook tidak hanya menjadi checklist, tetapi juga dapat diikuti berulang kali untuk perangkat apa pun. Ini akan sangat mendekati workflow yang digunakan maintainer TWRP dan recovery Android di komunitas open source.
