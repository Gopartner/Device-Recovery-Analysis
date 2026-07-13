#!/bin/bash
# TWRP Porting Tool - Main Script
# Workflow lengkap untuk porting TWRP

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo "  TWRP PORTING TOOL"
echo "  Device: Realme RMX3760 (RE58C2)"
echo "  SoC: Unisoc UMS9230"
echo "============================================"
echo ""
echo "Pilih langkah yang ingin dijalankan:"
echo ""
echo "  [1] Unpack    - Bongkar boot images dari perangkat"
echo "  [2] Analyze   - Analisis semua komponen"
echo "  [3] Patch     - Patch untuk TWRP"
echo "  [4] Repack    - Gabungkan jadi TWRP boot image"
echo "  [5] Full      - Jalankan semua langkah"
echo "  [6] Status    - Cek status perangkat"
echo "  [7] Clean     - Bersihkan work directory"
echo "  [0] Exit"
echo ""
read -p "Pilihan [0-7]: " CHOICE

case $CHOICE in
    1)
        bash "$SCRIPT_DIR/01-unpack.sh"
        ;;
    2)
        bash "$SCRIPT_DIR/02-analyze.sh"
        ;;
    3)
        bash "$SCRIPT_DIR/03-patch.sh"
        ;;
    4)
        bash "$SCRIPT_DIR/04-repack.sh"
        ;;
    5)
        echo ""
        echo "Menjalankan FULL WORKFLOW..."
        echo ""
        bash "$SCRIPT_DIR/01-unpack.sh"
        echo ""
        bash "$SCRIPT_DIR/02-analyze.sh"
        echo ""
        bash "$SCRIPT_DIR/03-patch.sh"
        echo ""
        bash "$SCRIPT_DIR/04-repack.sh"
        ;;
    6)
        echo ""
        echo "Device Status:"
        echo "--------------"
        adb devices
        echo ""
        if adb devices | grep -q "device$"; then
            echo "Brand: $(adb shell getprop ro.product.brand | tr -d '\r')"
            echo "Model: $(adb shell getprop ro.product.model | tr -d '\r')"
            echo "Device: $(adb shell getprop ro.product.device | tr -d '\r')"
            echo "Android: $(adb shell getprop ro.build.version.release | tr -d '\r')"
            echo "Root: $(adb shell su -c 'whoami' 2>/dev/null | tr -d '\r')"
        else
            echo "Tidak ada perangkat terhubung!"
        fi
        ;;
    7)
        echo ""
        echo "Bersihkan work directory..."
        rm -rf "$SCRIPT_DIR/../work"
        echo "[OK] Work directory dibersihkan"
        ;;
    0|*)
        echo "Exit."
        exit 0
        ;;
esac
