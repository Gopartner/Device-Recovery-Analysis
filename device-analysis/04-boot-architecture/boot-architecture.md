# Boot Architecture Analysis

## Boot Image Header (boot.img)

| Field | Value |
|-------|-------|
| Header Version | 4 |
| Kernel Size | 49,789,440 bytes (47.5 MB) |
| Ramdisk Size | 360,844 bytes (352 KB) |
| Page Size | 4096 |
| Kernel Format | raw |
| Ramdisk Format | lz4_legacy |
| AVB | Enabled |

## Vendor Boot Header (vendor_boot.img)

| Field | Value |
|-------|-------|
| Header Version | 4 |
| Ramdisk Size | 36,141,099 bytes (34.5 MB) |
| DTB Size | 134,831 bytes (132 KB) |
| Bootconfig Size | 57 bytes |
| Page Size | 4096 |
| Ramdisk Type | platform |
| Ramdisk Format | lz4_legacy |
| CMDLINE | console=ttyS1,115200n8 bootconfig bootconfig |

## Init Boot Header (init_boot.img)

| Field | Value |
|-------|-------|
| Header Version | 4 |
| Kernel Size | 0 (no kernel) |
| Ramdisk Size | 2,316,185 bytes (2.2 MB) |
| Page Size | 4096 |
| Ramdisk Format | lz4_legacy |

## Bootconfig

```
androidboot.hardware=ums9230_hulk
androidboot.dtbo_idx=0
```

## Extracted Files

### boot/

| File | Size | Keterangan |
|------|------|------------|
| kernel | 47.5 MB | Kernel Linux (Unisoc) |
| ramdisk.cpio | 2.9 MB | Init ramdisk |
| dtb | 132 KB | Device Tree Blob |
| bootconfig | 57 B | Boot configuration |

### vendor_boot/

| File | Size | Keterangan |
|------|------|------------|
| ramdisk.cpio | 73 MB | Vendor ramdisk (lengkap) |
| fstab.ums9230_hulk | 1.2 KB | **KRITIS** - File system table |
| init.recovery.common.rc | 8.6 KB | Init recovery script |

### init_boot/

| File | Size | Keterangan |
|------|------|------------|
| ramdisk.cpio | 2.9 MB | Init ramdisk stage 2 |

## Fstab Analysis (ums9230_hulk)

| Partition | Mount Point | FS Type | Options |
|-----------|-------------|---------|---------|
| system | /system | erofs | ro,avb=vbmeta_system,logical,first_stage_mount,slotselect |
| system_ext | /system_ext | erofs | ro,avb=vbmeta_system,logical,first_stage_mount,slotselect |
| vendor | /vendor | erofs | ro,avb=vbmeta_vendor,logical,first_stage_mount,slotselect |
| odm | /odm | erofs | ro,avb=vbmeta_odm,logical,first_stage_mount,slotselect |
| product | /product | erofs | ro,avb=vbmeta_product,logical,first_stage_mount,slotselect |
| vendor_dlkm | /vendor_dlkm | erofs | ro,avb=vbmeta_system_ext,logical,first_stage_mount,slotselect |
| system_dlkm | /system_dlkm | erofs | ro,avb=vbmeta_system_ext,logical,first_stage_mount,slotselect |
| metadata | /metadata | f2fs | nodev,noatime,nosuid,formattable,first_stage_mount,check |

## Key Findings for TWRP Porting

1. **Kernel:** Raw format (no compression) - 47.5 MB
2. **Ramdisk:** lz4_legacy compression
3. **AVB:** Enabled - Need to disable for TWRP
4. **Dynamic Partitions:** YES - Need to handle dm-*
5. **Fstab:** Available - Use as reference for TWRP fstab
6. **Recovery:** A/B device - No separate recovery partition

---

**Status:** ☑ PASS
