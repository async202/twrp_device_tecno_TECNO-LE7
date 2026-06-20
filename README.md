# TWRP device tree for TECNO Pova 2 (LE7|LE7n)

**Current status:** Buildable and working (haven't tested much). Can decrypt A12+ /data

❗You **MUST** use [Universal Boot Repartitioner](https://github.com/tecno-mt6768/Universal-Boot-Repartitioner-GPT-Backup) to flash this recovery, otherwise you're out of luck.
(Please note that artemscine's TWRP doesn't have zip binary pre-bundled(to pack backup of your previous GPT) and also cannot flash boot.img included in the zip. After resizing, DO NOT reboot into system!!! Instead, reboot to bootloader and flash this recovery.)

Downloads can be found at [here](https://github.com/async202/Action-Recovery-Builder/releases).

Based off [isus203's OnmiRom device tree sample](https://github.com/isus203/twrp_device_tecno_TECNO-LE7)

```
#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
```
