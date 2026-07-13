# TWRP Porting Tool

Script workflow untuk porting TWRP ke perangkat Android.

## Struktur

```
tools/
├── twrp-tool.sh        # Main script (jalankan ini)
├── 01-unpack.sh        # Bongkar boot images
├── 02-analyze.sh       # Analisis komponen
├── 03-patch.sh         # Patch untuk TWRP
├── 04-repack.sh        # Gabungkan jadi TWRP
└── README.md           # Dokumentasi ini
```

## Prasyarat

1. **ADB** - Android Debug Bridge
2. **Root Access** - Magisk atau KernelSU
3. **Git Bash** / **WSL** - Untuk menjalankan script

## Cara Penggunaan

### Full Workflow

```bash
cd tools
bash twrp-tool.sh
# Pilih [5] Full
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
└── analysis-report.md   # Hasil analisis
```

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

## Catatan

- Script ini menggunakan magiskboot dari perangkat
- Pastikan USB Debugging aktif
- Pastikan root access tersedia
- Backup data sebelum flash!
