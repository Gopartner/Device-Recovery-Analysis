#!/bin/bash
# TWRP Porting Tool - Repack Script
# Gabungkan komponen jadi TWRP boot image

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/../work"
EXTRACTED="${WORK_DIR}/extracted"
PATCHED="${WORK_DIR}/patched"
OUTPUT="${WORK_DIR}/output"

echo "============================================"
echo "  TWRP Porting Tool - REPACK"
echo "============================================"
echo ""

# Create output directory
mkdir -p "$OUTPUT"

# Check ADB
if ! command -v adb &> /dev/null; then
    echo "[ERROR] ADB tidak ditemukan!"
    exit 1
fi

# Get root
ROOT=$(adb shell su -c "whoami" 2>/dev/null | tr -d '\r')
if [ "$ROOT" != "root" ]; then
    echo "[ERROR] Root access tidak tersedia!"
    exit 1
fi
echo "[OK] Root access tersedia"

# Setup magiskboot
echo ""
echo "[1/3] Setup magiskboot..."
adb shell "su -c 'mkdir -p /data/local/tmp/twrp_pack'"
adb shell "su -c 'cp /data/adb/magisk/magiskboot /data/local/tmp/twrp_pack/magiskboot'"
adb shell "su -c 'chmod 755 /data/local/tmp/twrp_pack/magiskboot'"
echo "    [OK] magiskboot siap"

# Repack boot.img
echo ""
echo "[2/3] Repack boot.img..."
BOOT_DIR="$PATCHED/boot"
if [ -d "$BOOT_DIR" ]; then
    # Prepare files for repack
    adb push "$BOOT_DIR/kernel" //data/local/tmp/twrp_pack/ 2>/dev/null || \
        adb push "$EXTRACTED/boot/kernel" //data/local/tmp/twrp_pack/
    adb push "$BOOT_DIR/ramdisk.cpio" //data/local/tmp/twrp_pack/ 2>/dev/null || \
        adb push "$EXTRACTED/boot/ramdisk.cpio" //data/local/tmp/twrp_pack/
    adb push "$BOOT_DIR/dtb" //data/local/tmp/twrp_pack/ 2>/dev/null || true
    adb push "$BOOT_DIR/header" //data/local/tmp/twrp_pack/ 2>/dev/null || true
    
    # Repack
    adb shell "su -c 'cd /data/local/tmp/twrp_pack && ./magiskboot repack /data/local/tmp/boot.img /data/local/tmp/twrp_boot.img'"
    
    # Pull result
    adb pull //data/local/tmp/twrp_boot.img "$OUTPUT/twrp_boot.img" 2>/dev/null
    echo "    [OK] twrp_boot.img dibuat"
else
    echo "    [SKIP] Boot directory tidak ditemukan"
fi

# Repack vendor_boot.img
echo ""
echo "[3/3] Repack vendor_boot.img..."
VR_DIR="$PATCHED/vendor_boot"
if [ -d "$VR_DIR" ]; then
    # Create vendor_ramdisk directory
    mkdir -p /tmp/vendor_ramdisk
    cp "$EXTRACTED/vendor_boot/vendor_ramdisk.cpio" /tmp/vendor_ramdisk/ 2>/dev/null || true
    
    # Push vendor ramdisk
    adb push /tmp/vendor_ramdisk/ramdisk.cpio //data/local/tmp/twrp_pack/vendor_ramdisk/ 2>/dev/null || true
    adb push "$VR_DIR/dtb" //data/local/tmp/twrp_pack/ 2>/dev/null || \
        adb push "$EXTRACTED/vendor_boot/dtb" //data/local/tmp/twrp_pack/
    adb push "$VR_DIR/bootconfig" //data/local/tmp/twrp_pack/ 2>/dev/null || \
        adb push "$EXTRACTED/vendor_boot/bootconfig" //data/local/tmp/twrp_pack/
    adb push "$VR_DIR/header" //data/local/tmp/twrp_pack/ 2>/dev/null || \
        adb push "$EXTRACTED/vendor_boot/header" //data/local/tmp/twrp_pack/
    
    # Repack
    adb shell "su -c 'cd /data/local/tmp/twrp_pack && ./magiskboot repack /data/local/tmp/vendor_boot.img /data/local/tmp/twrp_vendor_boot.img'"
    
    # Pull result
    adb pull //data/local/tmp/twrp_vendor_boot.img "$OUTPUT/twrp_vendor_boot.img" 2>/dev/null
    echo "    [OK] twrp_vendor_boot.img dibuat"
else
    echo "    [SKIP] Vendor boot directory tidak ditemukan"
fi

# Cleanup
echo ""
echo "Cleaning up..."
adb shell "su -c 'rm -rf /data/local/tmp/twrp_pack'"
rm -rf /tmp/vendor_ramdisk

echo ""
echo "============================================"
echo "  REPACK SELESAI!"
echo "============================================"
echo ""
echo "Output files:"
ls -lh "$OUTPUT/"
echo ""
echo "Untuk flash ke perangkat:"
echo "  adb reboot bootloader"
echo "  fastboot flash boot $OUTPUT/twrp_boot.img"
echo "  fastboot flash vendor_boot $OUTPUT/twrp_vendor_boot.img"
echo "  fastboot reboot recovery"
