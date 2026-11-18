#!/usr/bin/env python3
"""Non-building checks; pass the extracted official Linux 6.18.64 source tree.

Only reads Kconfig, runs merge_config.sh -m in a temporary directory, and
evaluates isolated make fragments with a no-recipe target. Does not run
Kconfig compiler probes, olddefconfig, a compiler, or the project Makefile.
This is not a replacement for Kconfig dependency resolution or hardware tests.
"""

import pathlib
import re
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[4]
SOURCE = pathlib.Path(sys.argv[1]).resolve()
version = (SOURCE / "Makefile").read_text()
for key, value in (("VERSION", "6"), ("PATCHLEVEL", "18"), ("SUBLEVEL", "64")):
    assert re.search(r"^" + key + r"\s*=\s*" + value + r"\s*$", version, re.M)
BASE = ROOT / "build-config/conf/kernel/6.18.64/linux.x86_64.config"
FRAGMENT = pathlib.Path(__file__).with_name("config")


def entries(path):
    result = {}
    for line in path.read_text().splitlines():
        match = re.fullmatch(r"CONFIG_(\w+)=(.*)|# CONFIG_(\w+) is not set", line)
        if match:
            name = match[1] or match[3]
            assert name not in result, (path, "duplicate", name)
            result[name] = match[2] if match[1] else "n"
    return result


symbols = set()
for path in SOURCE.rglob("Kconfig*"):
    if path.is_file():
        symbols.update(
            re.findall(
                r"^\s*(?:menuconfig|config)\s+(\w+)",
                path.read_text(errors="replace"),
                re.MULTILINE,
            )
        )
for path in (BASE, FRAGMENT):
    values = entries(path)
    assert values.keys() <= symbols, (path, values.keys() - symbols)
    assert not any("ALPHA_SUPPORT" in name for name in values)
    print(path.relative_to(ROOT), len(values), "known unique symbols")

with tempfile.TemporaryDirectory(prefix="onie-g30w-config-") as directory:
    subprocess.run(
        [
            "sh",
            str(SOURCE / "scripts/kconfig/merge_config.sh"),
            "-m",
            "-r",
            "-O",
            directory,
            str(BASE),
            str(FRAGMENT),
        ],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    )
    merged = entries(pathlib.Path(directory) / ".config")
    for name in (
        "64BIT",
        "PCI",
        "ACPI",
        "DRM",
        "DRM_I915",
        "DRM_SIMPLEDRM",
        "SYSFB_SIMPLEFB",
        "DRM_FBDEV_EMULATION",
        "DRM_CLIENT_DEFAULT_FBDEV",
        "VT_CONSOLE",
        "FRAMEBUFFER_CONSOLE",
        "IGC",
        "ETHTOOL_NETLINK",
        "PTP_1588_CLOCK",
        "BLK_DEV_NVME",
        "SATA_AHCI",
        "USB_HID",
        "USB_XHCI_HCD",
        "USB_XHCI_PCI",
        "BLK_DEV_INITRD",
        "RD_GZIP",
        "DEVTMPFS",
        "EXT4_FS",
        "VFAT_FS",
    ):
        assert merged[name] == "y", (name, merged.get(name))
    assert merged["DRM_I915_FORCE_PROBE"] == '""'
    print("merge-only: boot/display/network/storage/keyboard requests PASS")

# Never include the top-level makefile (which has parse-time side effects).
for machine, runtime in (
    ("bkhd/bkhd_g30w", "6.18.64"),
    ("accton/accton_as5812_54x", "6.18.64"),
    ("accton/accton_as7326_56x", "6.18.64"),
    ("accton/accton_as5812_54t", "5.4.86"),
):
    harness = f""".DEFAULT_GOAL := inspect
DOWNLOADDIR := /unused/download
PROJECT_STAMP := /unused/project
BUILDDIR := /unused/build
MBUILDDIR := /unused/machine
STAMPDIR := /unused/stamp
IMAGEDIR := /unused/images
MAKE_CLEAN := 1
GCC_VERSION := 8.3.0
XTOOLS_LIBC := uClibc-ng
XTOOLS_LIBC_VERSION := 1.0.38
include machine/{machine}/machine.make
include build-config/make/kernel-download.make
include build-config/make/xtools.make
include build-config/make/kernel.make
$(info RESULT=$(LINUX_RELEASE)|$(LINUX_TARBALL)|$(XTOOLS_LINUX_RELEASE)|$(XTOOLS_VERSION)|$(XTOOLS_KERNEL_DOWNLOAD_STAMP)|$(CT_LINUX_V)|$(KERNEL_OLDDEFCONFIG))
.PHONY: inspect
inspect: ;
"""
    output = subprocess.check_output(
        ["make", "--no-print-directory", "-rR", "-f", "-", "inspect"],
        input=harness,
        text=True,
        cwd=ROOT,
    )
    result = next(
        line[7:] for line in output.splitlines() if line.startswith("RESULT=")
    )
    series = runtime.rsplit(".", 1)[0].replace(".", "_")
    expected = (
        f"{runtime}|linux-{runtime}.tar.xz|{runtime}|"
        f"x86_64-g8.3.0-lnx{runtime}-uClibc-ng-1.0.38|"
        f"/unused/download/kernel-{runtime}-download|{series}|"
        + ("yes" if runtime == "6.18.64" else "")
    )
    assert result == expected, (result, expected)
    print(machine, result, "PASS")

print("PASS: static checks only; Kconfig dependency resolution/build/boot NOT tested")
