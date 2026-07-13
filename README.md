# TWRP Porting Toolkit

> **Universal toolkit untuk porting TWRP ke semua perangkat Android 9+**

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%209+-green.svg)](https://developer.android.com)
[![TWRP](https://img.shields.io/badge/TWRP-3.7+-red.svg)](https://twrp.me)

---

## Features

- **Device Analysis** - Analisis lengkap semua komponen perangkat
- **Boot Image Tools** - Unpack, analyze, repack boot images
- **Auto Config Generator** - Generate BoardConfig.mk, device.mk, fstab otomatis
- **Two Mode** - Device Mode (root) & Firmware Mode (tanpa root)
- **Universal** - Support semua SoC: Qualcomm, MediaTek, Unisoc

---

## Quick Start

### Mode A: Device Mode (Root)

```bash
# Jalankan tool
bash tools/twrp-tool.sh

# Pilih [A] Device Mode
# Pilih [6] Full Workflow
```

### Mode B: Firmware Mode (Tanpa Root)

```bash
# Jalankan tool
bash tools/twrp-tool.sh

# Pilih [B] Firmware Mode
# Pilih sumber: OTA ZIP / payload.bin / Boot Images
```

---

## Tools

| Script | Fungsi |
|--------|--------|
| `twrp-tool.sh` | Main menu |
| `00-firmware-mode.sh` | Mode offline (tanpa root) |
| `01-unpack.sh` | Bongkar boot images |
| `02-analyze.sh` | Analisis komponen |
| `03-patch.sh` | Patch untuk TWRP |
| `04-repack.sh` | Gabungkan jadi TWRP |
| `05-auto-config.sh` | Generate config files |

Lihat [tools/README.md](tools/README.md) untuk dokumentasi lengkap.

---

## Output

```
work/
├── images/              # Original boot images
├── extracted/           # Hasil bongkar
│   ├── boot/
│   ├── vendor_boot/
│   └── init_boot/
├── patched/             # Hasil patch
├── output/              # TWRP boot images
│   ├── twrp_boot.img
│   └── twrp_vendor_boot.img
├── config/              # Auto-generated configs
│   ├── BoardConfig.mk
│   ├── device.mk
│   ├── recovery.fstab
│   └── device_tree/
└── analysis-report.md
```

---

## Requirements

### Device Mode

- ADB (Android Debug Bridge)
- Root Access (Magisk/KernelSU)
- USB Debugging aktif

### Firmware Mode

- Firmware/ROM file
- payload-dumper (`pipx install android-payload-dumper`)

### System

| OS | Status |
|----|--------|
| Linux | Recommended |
| Windows | Supported (Git Bash/WSL) |
| macOS | Supported |

---

## Workflow

```
┌─────────────────────────────────────────────────────────┐
│                    TWRP PORTING                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐             │
│  │ Unpack  │───▶│ Analyze │───▶│  Patch  │             │
│  └─────────┘    └─────────┘    └─────────┘             │
│       │                              │                  │
│       ▼                              ▼                  │
│  ┌─────────┐                   ┌─────────┐             │
│  │ Firmware│                   │ Repack  │             │
│  │  Mode   │                   └─────────┘             │
│  └─────────┘                        │                  │
│                                     ▼                  │
│                              ┌─────────┐               │
│                              │  Auto   │               │
│                              │ Config  │               │
│                              └─────────┘               │
│                                     │                  │
│                                     ▼                  │
│                              ┌─────────┐               │
│                              │  Build  │               │
│                              │  TWRP   │               │
│                              └─────────┘               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## What You Need

| Kebutuhan | Device Mode | Firmware Mode |
|-----------|-------------|---------------|
| Perangkat Android | ✅ Wajib | ❌ Tidak perlu |
| Root Access | ✅ Wajib | ❌ Tidak perlu |
| Firmware/ROM | ❌ Otomatis dump | ✅ Wajib |
| PC/Laptop | ✅ Wajib | ✅ Wajib |
| USB Cable | ✅ Wajib | ❌ Tidak perlu |

---

## Documentation

- [Analysis Guide](device-analysis/) - Panduan analisis perangkat
- [Tools Documentation](tools/) - Dokumentasi lengkap tools
- [Example: Realme RMX3760](device-analysis/SUMMARY.md) - Contoh hasil analisis

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [TeamWin Recovery Project](https://twrp.me/) - TWRP Official
- [Magisk](https://github.com/topjohnwu/Magisk) - Boot image tools
- [Android Open Source Project](https://source.android.com/) - Android source
