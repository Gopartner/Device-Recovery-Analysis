# Mount Analysis

## Root Filesystem

| Filesystem | Mount Point | Type | Options |
|------------|-------------|------|---------|
| /dev/block/dm-14 | / | erofs | ro,seclabel,relatime |
| /dev/block/mmcblk0p55 | /metadata | f2fs | rw,lazytime,seclabel,noatime |

## Super Partitions (Dynamic)

| Device | Mount Point | Type |
|--------|-------------|------|
| /dev/block/dm-15 | /system_ext | erofs |
| /dev/block/dm-16 | /vendor | erofs |
| /dev/block/dm-17 | /odm | erofs |
| /dev/block/dm-18 | /product | erofs |
| /dev/block/dm-19 | /vendor_dlkm | erofs |
| /dev/block/dm-20 | /system_dlkm | erofs |

## Key Findings

- **Root FS:** erofs (read-only)
- **Metadata:** f2fs (writable)
- **Dynamic Partitions:** Mounted via device-mapper (dm-*)
- **Magisk:** Active (mounted at /debug_ramdisk)

---

**Status:** ☑ PASS
