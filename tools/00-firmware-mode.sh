#!/bin/bash
# TWRP Porting Tool - Firmware Mode
# Untuk device tanpa root - gunakan firmware/ROM files

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/../work"

echo "============================================"
echo "  TWRP Porting Tool - FIRMWARE MODE"
echo "  Untuk device tanpa root"
echo "============================================"
echo ""
echo "Pilih sumber firmware:"
echo ""
echo "  [1] OTA ZIP      - Punya file OTA update"
echo "  [2] payload.bin  - Punya payload.bin langsung"
echo "  [3] Boot Images  - Punya boot.img, vendor_boot.img"
echo "  [4] Stock ROM    - Punya firmware extract"
echo ""
read -p "Pilihan [1-4]: " SOURCE

case $SOURCE in
    1)
        echo ""
        echo "Masukkan path file OTA ZIP:"
        read -p "> " OTA_PATH
        
        if [ ! -f "$OTA_PATH" ]; then
            echo "[ERROR] File tidak ditemukan!"
            exit 1
        fi
        
        echo ""
        echo "[1/3] Extract payload.bin dari OTA..."
        mkdir -p "$WORK_DIR/ota"
        
        # Try to extract payload.bin
        unzip -o "$OTA_PATH" payload.bin -d "$WORK_DIR/ota/" 2>/dev/null || {
            echo "[ERROR] Gagal extract payload.bin dari OTA"
            echo "        Pastikan file OTA valid"
            exit 1
        }
        
        echo "[2/3] Extract images dari payload.bin..."
        cd "$WORK_DIR/ota"
        
        # Use payload-dumper if available
        if command -v payload-dumper &> /dev/null; then
            payload-dumper payload.bin
        elif command -v payload_dumper &> /dev/null; then
            python3 payload_dumper.py payload.bin
        else
            echo "[ERROR] payload-dumper tidak ditemukan!"
            echo "        Install: pipx install android-payload-dumper"
            exit 1
        fi
        
        # Move extracted images
        mkdir -p "$WORK_DIR/images"
        mv output/*.img "$WORK_DIR/images/" 2>/dev/null || true
        
        echo "[3/3] Selesai!"
        ;;
        
    2)
        echo ""
        echo "Masukkan path file payload.bin:"
        read -p "> " PAYLOAD_PATH
        
        if [ ! -f "$PAYLOAD_PATH" ]; then
            echo "[ERROR] File tidak ditemukan!"
            exit 1
        fi
        
        echo ""
        echo "[1/2] Extract images dari payload.bin..."
        mkdir -p "$WORK_DIR/images"
        cd "$WORK_DIR"
        
        # Use payload-dumper
        if command -v payload-dumper &> /dev/null; then
            payload-dumper "$PAYLOAD_PATH"
        elif command -v payload_dumper &> /dev/null; then
            python3 payload_dumper.py "$PAYLOAD_PATH"
        else
            echo "[ERROR] payload-dumper tidak ditemukan!"
            exit 1
        fi
        
        echo "[2/2] Selesai!"
        ;;
        
    3)
        echo ""
        echo "Masukkan path folder berisi boot images:"
        read -p "> " IMG_PATH
        
        if [ ! -d "$IMG_PATH" ]; then
            echo "[ERROR] Folder tidak ditemukan!"
            exit 1
        fi
        
        echo ""
        echo "Copying boot images..."
        mkdir -p "$WORK_DIR/images"
        
        # Copy available images
        for img in boot.img vendor_boot.img init_boot.img vbmeta.img dtbo.img; do
            if [ -f "$IMG_PATH/$img" ]; then
                cp "$IMG_PATH/$img" "$WORK_DIR/images/"
                echo "  [OK] $img"
            fi
        done
        ;;
        
    4)
        echo ""
        echo "Masukkan path folder firmware/ROM:"
        read -p "> " FIRMWARE_PATH
        
        if [ ! -d "$FIRMWARE_PATH" ]; then
            echo "[ERROR] Folder tidak ditemukan!"
            exit 1
        fi
        
        echo ""
        echo "Searching for boot images in firmware..."
        mkdir -p "$WORK_DIR/images"
        
        # Find and copy boot images
        find "$FIRMWARE_PATH" -name "boot.img" -exec cp {} "$WORK_DIR/images/" \;
        find "$FIRMWARE_PATH" -name "vendor_boot.img" -exec cp {} "$WORK_DIR/images/" \;
        find "$FIRMWARE_PATH" -name "init_boot.img" -exec cp {} "$WORK_DIR/images/" \;
        find "$FIRMWARE_PATH" -name "vbmeta.img" -exec cp {} "$WORK_DIR/images/" \;
        find "$FIRMWARE_PATH" -name "dtbo.img" -exec cp {} "$WORK_DIR/images/" \;
        ;;
        
    *)
        echo "[ERROR] Pilihan tidak valid!"
        exit 1
        ;;
esac

echo ""
echo "============================================"
echo "  FIRMWARE READY!"
echo "============================================"
echo ""
echo "Images tersedia:"
ls -lh "$WORK_DIR/images/"
echo ""
echo "Langkah selanjutnya:"
echo "  [1] Jalankan 01-unpack.sh untuk bongkar images"
echo "  [2] Jalankan 02-analyze.sh untuk analisis"
echo "  [3] Jalankan 05-auto-config.sh untuk generate config"
echo ""
