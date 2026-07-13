#!/bin/bash
# TWRP Porting Tool - Analyze Script
# Analisis otomatis semua komponen boot

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="${SCRIPT_DIR}/../work"
EXTRACTED="${WORK_DIR}/extracted"
REPORT="${WORK_DIR}/analysis-report.md"

echo "============================================"
echo "  TWRP Porting Tool - ANALYZE"
echo "============================================"
echo ""

# Check if extracted exists
if [ ! -d "$EXTRACTED" ]; then
    echo "[ERROR] Folder extracted tidak ditemukan!"
    echo "        Jalankan 01-unpack.sh terlebih dahulu"
    exit 1
fi

# Start report
cat > "$REPORT" << 'EOF'
# TWRP Porting Analysis Report

## Generated: $(date)

---

EOF

# 1. Analyze Device Info
echo "[1/7] Analyzing device info..."
cat >> "$REPORT" << EOF
## 1. Device Information

EOF

if command -v adb &> /dev/null; then
    DEVICE=$(adb devices | grep -w "device" | head -1 | awk '{print $1}')
    if [ -n "$DEVICE" ]; then
        BRAND=$(adb shell getprop ro.product.brand 2>/dev/null | tr -d '\r')
        MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
        DEVICE_NAME=$(adb shell getprop ro.product.device 2>/dev/null | tr -d '\r')
        ANDROID=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
        SDK=$(adb shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r')
        HARDWARE=$(adb shell getprop ro.boot.hardware 2>/dev/null | tr -d '\r')
        SLOT=$(adb shell getprop ro.boot.slot_suffix 2>/dev/null | tr -d '\r')

        cat >> "$REPORT" << EOF
| Field | Value |
|-------|-------|
| Brand | $BRAND |
| Model | $MODEL |
| Device | $DEVICE_NAME |
| Android | $ANDROID |
| SDK | $SDK |
| Hardware | $HARDWARE |
| Slot | $SLOT |

EOF
    fi
fi

# 2. Analyze Boot Image
echo "[2/7] Analyzing boot.img..."
cat >> "$REPORT" << 'EOF'
## 2. Boot Image Analysis

EOF

if [ -f "$EXTRACTED/boot/kernel" ]; then
    KERNEL_SIZE=$(stat -f%z "$EXTRACTED/boot/kernel" 2>/dev/null || stat -c%s "$EXTRACTED/boot/kernel" 2>/dev/null)
    KERNEL_TYPE=$(file "$EXTRACTED/boot/kernel" 2>/dev/null | cut -d: -f2)
    cat >> "$REPORT" << EOF
| Component | Size | Type |
|-----------|------|------|
| kernel | $KERNEL_SIZE bytes | $KERNEL_TYPE |
EOF
fi

if [ -f "$EXTRACTED/boot/ramdisk.cpio" ]; then
    RAMDISK_SIZE=$(stat -f%z "$EXTRACTED/boot/ramdisk.cpio" 2>/dev/null || stat -c%s "$EXTRACTED/boot/ramdisk.cpio" 2>/dev/null)
    cat >> "$REPORT" << EOF
| ramdisk | $RAMDISK_SIZE bytes | cpio |
EOF
fi

if [ -f "$EXTRACTED/boot/dtb" ]; then
    DTB_SIZE=$(stat -f%z "$EXTRACTED/boot/dtb" 2>/dev/null || stat -c%s "$EXTRACTED/boot/dtb" 2>/dev/null)
    cat >> "$REPORT" << EOF
| dtb | $DTB_SIZE bytes | dtb |
EOF
fi

echo "" >> "$REPORT"

# 3. Analyze Vendor Boot
echo "[3/7] Analyzing vendor_boot.img..."
cat >> "$REPORT" << 'EOF'
## 3. Vendor Boot Analysis

EOF

if [ -f "$EXTRACTED/vendor_boot/vendor_ramdisk.cpio" ]; then
    VR_SIZE=$(stat -f%z "$EXTRACTED/vendor_boot/vendor_ramdisk.cpio" 2>/dev/null || stat -c%s "$EXTRACTED/vendor_boot/vendor_ramdisk.cpio" 2>/dev/null)
    cat >> "$REPORT" << EOF
| Component | Size |
|-----------|------|
| vendor_ramdisk | $VR_SIZE bytes |
EOF
fi

if [ -f "$EXTRACTED/vendor_boot/bootconfig" ]; then
    cat >> "$REPORT" << EOF

### Bootconfig

\`\`\`
$(cat "$EXTRACTED/vendor_boot/bootconfig")
\`\`\`
EOF
fi

echo "" >> "$REPORT"

# 4. Analyze Fstab
echo "[4/7] Analyzing fstab..."
cat >> "$REPORT" << 'EOF'
## 4. Fstab Analysis

EOF

FSTAB=$(find "$EXTRACTED/vendor_boot/ramdisk" -name "fstab.*" 2>/dev/null | head -1)
if [ -n "$FSTAB" ]; then
    cat >> "$REPORT" << EOF
**Source:** \`$FSTAB\`

\`\`\`
$(cat "$FSTAB")
\`\`\`
EOF
else
    echo "No fstab found in vendor ramdisk" >> "$REPORT"
fi

echo "" >> "$REPORT"

# 5. Analyze Init Recovery
echo "[5/7] Analyzing init.recovery.rc..."
cat >> "$REPORT" << 'EOF'
## 5. Init Recovery Analysis

EOF

INIT_RC=$(find "$EXTRACTED/vendor_boot/ramdisk" -name "init.recovery*" 2>/dev/null | head -1)
if [ -n "$INIT_RC" ]; then
    cat >> "$REPORT" << EOF
**Source:** \`$INIT_RC\`

\`\`\`
$(head -50 "$INIT_RC")
\`\`\`
EOF
else
    echo "No init.recovery.rc found" >> "$REPORT"
fi

echo "" >> "$REPORT"

# 6. Analyze SELinux
echo "[6/7] Analyzing SELinux contexts..."
cat >> "$REPORT" << 'EOF'
## 6. SELinux Contexts

EOF

for ctx in file_contexts property_contexts service_contexts; do
    CTX_FILE=$(find "$EXTRACTED/vendor_boot/ramdisk" -name "*$ctx" 2>/dev/null | head -1)
    if [ -n "$CTX_FILE" ]; then
        cat >> "$REPORT" << EOF
### $ctx
\`\`\`
$(head -20 "$CTX_FILE")
\`\`\`
EOF
    fi
done

echo "" >> "$REPORT"

# 7. Summary
echo "[7/7] Generating summary..."
cat >> "$REPORT" << 'EOF'
## 7. Summary & TWRP Porting Notes

### Key Components Found

- [ ] Kernel (raw format)
- [ ] Ramdisk (lz4_legacy compressed)
- [ ] Vendor Ramdisk
- [ ] DTB (Device Tree Blob)
- [ ] Bootconfig
- [ ] Fstab
- [ ] Init Recovery RC
- [ ] SELinux Contexts

### TWRP Porting Checklist

1. **Kernel:** Use as-is for TWRP kernel
2. **Ramdisk:** Need to modify init for TWRP
3. **Fstab:** Use as reference for TWRP fstab
4. **DTB:** May need to patch for display/touch
5. **SELinux:** Need to set permissive for TWRP
6. **AVB:** Need to disable verification

### Next Steps

1. Create TWRP device tree
2. Configure BoardConfig.mk
3. Create recovery.fstab
4. Build TWRP
5. Test and debug

---

EOF

echo "============================================"
echo "  ANALYSIS SELESAI!"
echo "============================================"
echo ""
echo "Report: $REPORT"
echo ""
cat "$REPORT"
