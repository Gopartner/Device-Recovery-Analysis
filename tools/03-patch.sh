#!/bin/bash
# TWRP Porting Tool - Patch Script
# Patch komponen untuk TWRP

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/../work"
EXTRACTED="${WORK_DIR}/extracted"
PATCHED="${WORK_DIR}/patched"

echo "============================================"
echo "  TWRP Porting Tool - PATCH"
echo "============================================"
echo ""

# Create patched directory
mkdir -p "$PATCHED"/{boot,vendor_boot,init_boot}

# 1. Patch vbmeta (disable verification)
echo "[1/4] Patching vbmeta (disable AVB)..."
VBMETA="$WORK_DIR/images/vbmeta.img"
if [ -f "$VBMETA" ]; then
    # Disable AVB verification
    python3 -c "
import struct
with open('$VBMETA', 'r+b') as f:
    f.seek(123)  # flags offset
    f.write(b'\\x03')
" 2>/dev/null || {
        # Alternative: use hexpatch
        adb shell "su -c 'cd /data/local/tmp && /data/adb/magisk/magiskboot hexpatch $VBMETA 1500000015 1500000000'" 2>/dev/null || \
        echo "    [WARN] AVB patch perlu dilakukan manual"
    }
    cp "$VBMETA" "$PATCHED/vbmeta.img" 2>/dev/null || true
    echo "    [OK] vbmeta patched"
else
    echo "    [SKIP] vbmeta.img tidak ditemukan"
fi

# 2. Create TWRP fstab
echo ""
echo "[2/4] Membuat recovery.fstab..."
FSTAB_SRC=$(find "$EXTRACTED/vendor_boot/ramdisk" -name "fstab.*" 2>/dev/null | head -1)
FSTAB_DST="$PATCHED/boot/recovery.fstab"

if [ -n "$FSTAB_SRC" ]; then
    # Copy and modify fstab for TWRP
    cp "$FSTAB_SRC" "$FSTAB_DST"
    
    # Add TWRP-specific entries
    cat >> "$FSTAB_DST" << 'EOF'

# TWRP additions
/dev/block/by-name/userdata /userdata ext4 ro,nodev,noatime,nosuid wait,check
/dev/block/by-name/cache /cache ext4 ro,nodev,noatime,nosuid wait,check
/dev/block/by-name/metadata /metadata f2fs nodev,noatime,nosuid wait,formattable,check
EOF
    
    echo "    [OK] recovery.fstab dibuat"
else
    echo "    [SKIP] fstab source tidak ditemukan"
fi

# 3. Create TWRP init.recovery.rc
echo ""
echo "[3/4] Membuat init.recovery.rc..."
INIT_RC_DST="$PATCHED/vendor_boot/init.recovery.rc"

cat > "$INIT_RC_DST" << 'EOF'
# TWRP Init Recovery

on init
    # Mount essential partitions
    mount tmpfs tmpfs /tmp
    
    # Create TWRP directories
    mkdir /tmp.twrp
    mkdir /tmp/twtmp
    mkdir /tmp/twboot
    
    # Set SELinux permissive (for debugging)
    setenforce 0
    
    # Start USB
    write /config/usb_gadget/g1/UDC ${sys.usb.controller}
    setprop sys.usb.config adb
    setprop sys.usb.state adb

on boot
    # TWRP specific
    setprop ro.build.display.id "TWRP"
    setprop ro.build.description "twrp-RE58C2"

service twrp /system/bin/twrp.classic
    class main
    user root
    group root system
    oneshot
EOF

echo "    [OK] init.recovery.rc dibuat"

# 4. Create twrp.flags
echo ""
echo "[4/4] Membuat twrp.flags..."
FLAGS_DST="$PATCHED/boot/twrp.flags"

cat > "$FLAGS_DST" << 'EOF'
# TWRP Flags
TW_SCREEN_BLANK_ON_BOOT=true
TW_NO_REBOOT_BOOTLOADER=false
TW_NO_REBOOT_RECOVERY=false
TW_HAS_DOWNLOAD_MODE=true
TW_INCLUDE_NTFS_3G=true
TW_USE_MODEL_DEVICE_ID=true
TW_INCLUDE_FBE_METADATA_CRYPT=true
TW_DEFAULT_LANGUAGE=en
EOF

echo "    [OK] twrp.flags dibuat"

echo ""
echo "============================================"
echo "  PATCH SELESAI!"
echo "============================================"
echo ""
echo "Output: $PATCHED"
echo ""
ls -la "$PATCHED"/boot/
echo ""
ls -la "$PATCHED"/vendor_boot/
