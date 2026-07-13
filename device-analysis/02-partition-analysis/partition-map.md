# Partition Analysis

## Storage Info

| Device | Type | Size |
|--------|------|------|
| mmcblk0 | eMMC | 244,285,440 blocks (~233 GB) |
| mmcblk1 | eMMC | 15,558,144 blocks (~14.8 GB) |
| zram0 | Swap | 5,576,408 kB (~5.3 GB) |

## Partition Map

### Boot & Recovery

| Partition | Block Device | Size (blocks) | Size (MB) |
|-----------|--------------|---------------|-----------|
| boot_a | mmcblk0p36 | 65,536 | 64 MB |
| boot_b | mmcblk0p37 | 65,536 | 64 MB |
| vendor_boot_a | mmcblk0p38 | 102,400 | 100 MB |
| vendor_boot_b | mmcblk0p39 | 102,400 | 100 MB |
| init_boot_a | mmcblk0p40 | 8,192 | 8 MB |
| init_boot_b | mmcblk0p41 | 8,192 | 8 MB |

### Super (Dynamic Partitions)

| Partition | Block Device | Size (blocks) | Size (MB) |
|-----------|--------------|---------------|-----------|
| super | mmcblk0p47 | 8,192,000 | 8,000 MB |

### Device Tree

| Partition | Block Device | Size (blocks) | Size (MB) |
|-----------|--------------|---------------|-----------|
| dtb_a | mmcblk0p42 | 8,192 | 8 MB |
| dtb_b | mmcblk0p43 | 8,192 | 8 MB |
| dtbo_a | mmcblk0p44 | 8,192 | 8 MB |
| dtbo_b | mmcblk0p45 | 8,192 | 8 MB |

### AVB Meta

| Partition | Block Device | Size (blocks) |
|-----------|--------------|---------------|
| vbmeta_a | mmcblk0p51 | 1,024 |
| vbmeta_b | mmcblk0p52 | 1,024 |
| vbmeta_system_a | mmcblk0p57 | 1,024 |
| vbmeta_system_b | mmcblk0p58 | 1,024 |
| vbmeta_vendor_a | mmcblk0p59 | 1,024 |
| vbmeta_vendor_b | mmcblk0p60 | 1,024 |
| vbmeta_product_a | mmcblk0p63 | 1,024 |
| vbmeta_product_b | mmcblk0p64 | 1,024 |
| vbmeta_odm_a | mmcblk0p65 | 1,024 |
| vbmeta_odm_b | mmcblk0p66 | 1,024 |
| vbmeta_system_ext_a | mmcblk0p61 | 1,024 |
| vbmeta_system_ext_b | mmcblk0p62 | 1,024 |
| avbmeta_rs_a | mmcblk0p67 | 1,024 |
| avbmeta_rs_b | mmcblk0p68 | 1,024 |

### Modem & DSP

| Partition | Block Device | Size (blocks) | Size (MB) |
|-----------|--------------|---------------|-----------|
| l_modem_a | mmcblk0p20 | 25,600 | 25 MB |
| l_modem_b | mmcblk0p21 | 25,600 | 25 MB |
| l_gdsp_a | mmcblk0p24 | 10,240 | 10 MB |
| l_gdsp_b | mmcblk0p25 | 10,240 | 10 MB |
| l_ldsp_a | mmcblk0p26 | 20,480 | 20 MB |
| l_ldsp_b | mmcblk0p27 | 20,480 | 20 MB |
| l_agdsp_a | mmcblk0p28 | 6,144 | 6 MB |
| l_agdsp_b | mmcblk0p29 | 6,144 | 6 MB |

### Bootloader (Unisoc)

| Partition | Block Device | Size (blocks) |
|-----------|--------------|---------------|
| sml_a | mmcblk0p6 | 1,024 |
| sml_b | mmcblk0p7 | 1,024 |
| uboot_a | mmcblk0p8 | 3,072 |
| uboot_b | mmcblk0p9 | 3,072 |
| trustos_a | mmcblk0p4 | 6,144 |
| trustos_b | mmcblk0p5 | 6,144 |
| hypervsior_a | mmcblk0p34 | 10,240 |
| hypervsior_b | mmcblk0p35 | 10,240 |
| teecfg_a | mmcblk0p32 | 1,024 |
| teecfg_b | mmcblk0p33 | 1,024 |
| pm_sys_a | mmcblk0p30 | 1,024 |
| pm_sys_b | mmcblk0p31 | 1,024 |

### Data & Others

| Partition | Block Device | Size (blocks) | Size (MB) |
|-----------|--------------|---------------|-----------|
| userdata | mmcblk0p77 | 232,975,360 | ~222 GB |
| cache | mmcblk0p48 | 65,536 | 64 MB |
| metadata | mmcblk0p55 | 65,536 | 64 MB |
| misc | mmcblk0p3 | 1,024 | 1 MB |
| persist | mmcblk0p19 | 2,048 | 2 MB |
| prodnv | mmcblk0p1 | 65,536 | 64 MB |
| logo | mmcblk0p11 | 8,192 | 8 MB |
| fbootlogo | mmcblk0p12 | 8,192 | 8 MB |
| my_preload | mmcblk0p46 | 1,843,200 | 1,800 MB |
| opporeserve | mmcblk0p50 | 65,536 | 64 MB |
| oplusreserve1 | mmcblk0p74 | 8,192 | 8 MB |
| oplusreserve3 | mmcblk0p75 | 65,536 | 64 MB |
| oplusreserve5 | mmcblk0p76 | 32,768 | 32 MB |

## Key Findings

- **Storage:** eMMC (233 GB)
- **Dynamic Partitions:** YES (super partition)
- **A/B Slot:** YES
- **Vendor Boot:** YES (separate partition)
- **Init Boot:** YES (separate partition)
- **Recovery Partition:** TIDAK ADA (A/B device)

---

**Status:** ☑ PASS
