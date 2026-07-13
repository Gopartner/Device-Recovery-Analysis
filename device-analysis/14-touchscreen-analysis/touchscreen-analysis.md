# Touchscreen Analysis

## Input Devices

### 1. GPIO Keys (Power/Volume)

| Property | Value |
|----------|-------|
| Name | gpio-keys |
| Bus | 0019 (GPIO) |
| Event Node | event0 |
| Type | Keyboard |
| Keys | Power, Volume Up/Down |

### 2. Touchscreen

| Property | Value |
|----------|-------|
| Name | chipone-tddi-modules |
| Bus | 001c (SPI) |
| Event Node | event2 |
| Type | Touchscreen |
| Protocol | BTN_TOUCH, ABS_MT_POSITION |
| Driver | Chipone TDDI (ICNL9911C) |

### 3. JiioV Keys (Virtual)

| Property | Value |
|----------|-------|
| Name | jiiov-keys |
| Bus | 0000 (Virtual) |
| Event Node | event3 |
| Type | Special Keys |

### 4. Headset Jack

| Property | Value |
|----------|-------|
| Name | sprdphone-sc2730 Headset Jack |
| Event Node | event4 |
| Type | Switch |

### 5. Headset Keyboard

| Property | Value |
|----------|-------|
| Name | sprdphone-sc2730 Headset Keyboard |
| Event Node | event5 |
| Type | Keyboard |

---

**Status:** ☑ PASS
