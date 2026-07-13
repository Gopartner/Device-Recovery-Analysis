# TWRP Porting Tool

Script workflow untuk porting TWRP ke perangkat Android.

## Struktur

```
tools/
├── twrp-tool.sh        # Main script (jalankan ini)
├── 00-firmware-mode.sh  # Mode offline (tanpa root)
├── 01-unpack.sh        # Bongkar boot images
├── 02-analyze.sh       # Analisis komponen
├── 03-patch.sh         # Patch untuk TWRP
├── 04-repack.sh        # Gabungkan jadi TWRP
├── 05-auto-config.sh   # Generate config otomatis
└── README.md           # Dokumentasi ini
```

## Mode Penggunaan

### Mode A: Device Mode (Root)

Perangkat terhubung via USB dengan root access:

```bash
bash twrp-tool.sh
# Pilih [A] Device Mode
# Pilih [6] Full
```

### Mode B: Firmware Mode (Tanpa Root)

Gunakan firmware/ROM yang sudah didownload:

```bash
bash twrp-tool.sh
# Pilih [B] Firmware Mode
# Pilih sumber firmware:
#   [1] OTA ZIP
#   [2] payload.bin
#   [3] Boot Images (boot.img, vendor_boot.img)
#   [4] Stock ROM folder
```

## Prasyarat

### Device Mode
1. **ADB** - Android Debug Bridge
2. **Root Access** - Magisk atau KernelSU
3. **Git Bash** / **WSL** - Untuk menjalankan script

### Firmware Mode
1. **Firmware/ROM** - OTA, payload.bin, atau boot images
2. **payload-dumper** - Untuk extract dari OTA/payload
   ```bash
   pipx install android-payload-dumper
   ```
3. **Git Bash** / **WSL**

## Cara Penggunaan

### Full Workflow (Recommended)

```bash
cd tools
bash twrp-tool.sh
# Pilih [6] Full
```

### Langkah Manual

```bash
# 1. Unpack boot images
bash 01-unpack.sh

# 2. Analisis komponen
bash 02-analyze.sh

# 3. Patch untuk TWRP
bash 03-patch.sh

# 4. Repack jadi TWRP
bash 04-repack.sh

# 5. Generate config files
bash 05-auto-config.sh
```

## Output

```
work/
├── images/              # Original boot images
├── extracted/           # Hasil bongkar
│   ├── boot/
│   ├── vendor_boot/
│   └── init_boot/
├── patched/             # Hasil patch
│   ├── boot/
│   └── vendor_boot/
├── output/              # TWRP boot images
│   ├── twrp_boot.img
│   └── twrp_vendor_boot.img
├── config/              # Auto-generated configs
│   ├── BoardConfig.mk
│   ├── device.mk
│   ├── recovery.fstab
│   └── device_tree/
└── analysis-report.md   # Hasil analisis
```

## Auto Config Generator

Script `05-auto-config.sh` akan generate:

| File | Keterangan |
|------|------------|
| `BoardConfig.mk` | Hardware config untuk build |
| `device.mk` | Device tree definition |
| `recovery.fstab` | File system table |
| `device_tree/` | Struktur device tree lengkap |

## Flash ke Perangkat

```bash
# Masuk fastboot
adb reboot bootloader

# Flash TWRP
fastboot flash boot work/output/twrp_boot.img
fastboot flash vendor_boot work/output/twrp_vendor_boot.img

# Reboot ke recovery
fastboot reboot recovery
```

## Build TWRP

Setelah generate config:

```bash
# Setup Android build environment
source build/envsetup.sh
lunch <device>_twrp-eng

# Build
mka recoveryimage

# Output
out/target/product/<device>/recovery.img
```

## Catatan

- Script ini menggunakan magiskboot dari perangkat
- Pastikan USB Debugging aktif
- Pastikan root access tersedia
- Backup data sebelum flash!
- Review generated configs sebelum build
