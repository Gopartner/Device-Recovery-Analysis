#!/bin/bash
# TWRP Porting Tool - Unpack Script
# Bongkar semua boot images dari perangkat

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/../work"
OUTPUT_DIR="${WORK_DIR}/extracted"

echo "============================================"
echo "  TWRP Porting Tool - UNPACK"
echo "============================================"
echo ""

# Check ADB
if ! command -v adb &> /dev/null; then
    echo "[ERROR] ADB tidak ditemukan!"
    exit 1
fi

# Check device
DEVICE=$(adb devices | grep -w "device" | head -1 | awk '{print $1}')
if [ -z "$DEVICE" ]; then
    echo "[ERROR] Tidak ada perangkat terhubung!"
    exit 1
fi
echo "[OK] Perangkat: $DEVICE"

# Get root
ROOT=$(adb shell su -c "whoami" 2>/dev/null | tr -d '\r')
if [ "$ROOT" != "root" ]; then
    echo "[ERROR] Root access tidak tersedia!"
    exit 1
fi
echo "[OK] Root access: $ROOT"
echo ""

# Create work directory
mkdir -p "$OUTPUT_DIR"/{boot,vendor_boot,init_boot,vbmeta,dtbo}
mkdir -p "$WORK_DIR"/images

echo "[1/5] Dumping boot images dari perangkat..."
adb shell su -c "dd if=/dev/block/by-name/boot_a of=/data/local/tmp/boot.img" 2>/dev/null
adb shell su -c "dd if=/dev/block/by-name/vendor_boot_a of=/data/local/tmp/vendor_boot.img" 2>/dev/null
adb shell su -c "dd if=/dev/block/by-name/init_boot_a of=/data/local/tmp/init_boot.img" 2>/dev/null
adb shell su -c "dd if=/dev/block/by-name/vbmeta_a of=/data/local/tmp/vbmeta.img" 2>/dev/null
adb shell su -c "dd if=/dev/block/by-name/dtbo_a of=/data/local/tmp/dtbo.img" 2>/dev/null
echo "    [OK] Semua gambar berhasil di-dump"

echo ""
echo "[2/5] Pull images ke PC..."
adb pull //data/local/tmp/boot.img "$WORK_DIR/images/" 2>/dev/null
adb pull //data/local/tmp/vendor_boot.img "$WORK_DIR/images/" 2>/dev/null
adb pull //data/local/tmp/init_boot.img "$WORK_DIR/images/" 2>/dev/null
adb pull //data/local/tmp/vbmeta.img "$WORK_DIR/images/" 2>/dev/null
adb pull //data/local/tmp/dtbo.img "$WORK_DIR/images/" 2>/dev/null
echo "    [OK] Semua gambar berhasil di-pull"

echo ""
echo "[3/5] Setup magiskboot di perangkat..."
adb shell "su -c 'mkdir -p /data/local/tmp/twrp_tools'"
adb push "${SCRIPT_DIR}/bin/magiskboot" //data/local/tmp/twrp_tools/ 2>/dev/null || \
    adb shell "su -c 'cp /data/adb/magisk/magiskboot /data/local/tmp/twrp_tools/magiskboot'"
adb shell "su -c 'chmod 755 /data/local/tmp/twrp_tools/magiskboot'"
echo "    [OK] magiskboot siap"

echo ""
echo "[4/5] Unpack boot.img..."
adb shell "su -c 'cd /data/local/tmp/twrp_tools && ./magiskboot unpack /data/local/tmp/boot.img'"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/kernel $OUTPUT_DIR/boot/'"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/ramdisk.cpio $OUTPUT_DIR/boot/'"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/dtb $OUTPUT_DIR/boot/' 2>/dev/null || true"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/header $OUTPUT_DIR/boot/' 2>/dev/null || true"
echo "    [OK] boot.img terbongkar"

echo ""
echo "[5/5] Unpack vendor_boot.img..."
adb shell "su -c 'cd /data/local/tmp/twrp_tools && ./magiskboot unpack /data/local/tmp/vendor_boot.img'"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/vendor_ramdisk/ramdisk.cpio $OUTPUT_DIR/vendor_boot/vendor_ramdisk.cpio' 2>/dev/null || true"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/dtb $OUTPUT_DIR/vendor_boot/' 2>/dev/null || true"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/bootconfig $OUTPUT_DIR/vendor_boot/' 2>/dev/null || true"
adb shell "su -c 'cp /data/local/tmp/twrp_tools/header $OUTPUT_DIR/vendor_boot/' 2>/dev/null || true"
echo "    [OK] vendor_boot.img terbongkar"

# Extract ramdisk
echo ""
echo "     Extracting boot ramdisk..."
mkdir -p "$OUTPUT_DIR/boot/ramdisk"
cd "$OUTPUT_DIR/boot/ramdisk"
adb shell "su -c 'cat /data/local/tmp/twrp_tools/ramdisk.cpio'" | cpio -idm 2>/dev/null || true

echo "     Extracting vendor ramdisk..."
mkdir -p "$OUTPUT_DIR/vendor_boot/ramdisk"
cd "$OUTPUT_DIR/vendor_boot/ramdisk"
adb shell "su -c 'cat /data/local/tmp/twrp_tools/vendor_ramdisk/ramdisk.cpio'" | cpio -idm 2>/dev/null || true

# Cleanup device
echo ""
echo "Cleaning up perangkat..."
adb shell "su -c 'rm -rf /data/local/tmp/twrp_tools /data/local/tmp/*.img'"

echo ""
echo "============================================"
echo "  UNPACK SELESAI!"
echo "============================================"
echo ""
echo "Output: $OUTPUT_DIR"
echo ""
ls -la "$OUTPUT_DIR"/boot/
echo ""
ls -la "$OUTPUT_DIR"/vendor_boot/
