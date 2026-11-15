# BKHD g30w x86_64 appliance
#
#  Copyright (C) 2026 CXNOS contributors
#
#  SPDX-License-Identifier:     GPL-2.0
#
# Intel Atom J6412 (Elkhart Lake), DDR4, 4x Intel I226, HDMI + DP,
# 1x NVMe, 1x SATA, 1x COM serial console, 4G and 5G module slots.
# No switch ASIC and no I2C syseeprom on this board.

ONIE_ARCH ?= x86_64

VENDOR_REV ?= 0

# Translate hardware revision to ONIE hardware revision
ifeq ($(VENDOR_REV),0)
  MACHINE_REV = 0
else
  $(warning Unknown VENDOR_REV '$(VENDOR_REV)' for MACHINE '$(MACHINE)')
  $(error Unknown VENDOR_REV)
endif

# No switch ASIC on this platform.
SWITCH_ASIC_VENDOR = none

# Vendor ID -- Open Compute Project IANA enterprise number.
VENDOR_ID = 42623

# Skip i2ctools and onie-syseeprom; the board has no I2C EEPROM.
I2CTOOLS_ENABLE = no

# Do not rewrite the factory Ethernet MAC addresses.
SKIP_ETHMGMT_MACS = yes

# Enable UEFI support; GRUB BIOS and UEFI targets come from arch/x86_64.make.
UEFI_ENABLE = yes

# No firmware update images for this board yet.
FIRMWARE_UPDATE_ENABLE = no

# Secure Boot stays off for initial bring-up.  Enable it together with
# machine key material once the firmware enrollment process is defined.
SECURE_BOOT_ENABLE = no

# Local firmware display and USB keyboard, for installations without a
# serial cable. Applies to both recovery GRUB and the installed ONIE.
SERIAL_CONSOLE_ENABLE = no
# Override the earlier "quiet" loglevel and select the local VT console.
EXTRA_CMDLINE_LINUX += console=tty0 loglevel=7
