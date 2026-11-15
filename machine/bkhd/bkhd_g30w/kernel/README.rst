g30w: Linux 6.18.63 migration
===========================

Scope
-----

Only bkhd_g30w selects runtime Linux 6.18.63. The shared default and
accton_as7326_56x remain at 5.4.86. No existing 5.4 configuration or patch
was changed. No build, container build, installation or flashing was performed.

Source provenance
-----------------

Downloaded on 2026-11-15 from:

* https://www.kernel.org/pub/linux/kernel/v6.x/linux-6.18.63.tar.xz
* https://www.kernel.org/pub/linux/kernel/v6.x/sha256sums.asc

The archive matched the SHA256 entry in the official HTTPS checksum list:

  81764a545072d160748beff4d9de2e7d95aa9f16e8261110288f067a2cc61d71

SHA1 computed locally from that verified archive (for ONIE fetch-package):

  8f2d4e74265d98b03465221d2ee2fc5b7de010d8

Both checksum files are in upstream/. The verified archive is cached locally
in build/download/linux-6.18.63.tar.xz (ignored by Git). The extracted source
Makefile also reports VERSION=6, PATCHLEVEL=18, SUBLEVEL=63. The signature on
the checksum list was NOT independently verified with a trusted OpenPGP key.

Toolchain and build rules
------------------------

The verified source's scripts/min-tool-version.sh and
Documentation/process/changes.rst require GCC >= 8.1 and binutils >= 2.30
on x86. Existing GCC 8.3.0 and binutils 2.32 meet those minimum versions.
This is not evidence of a successful build with that toolchain.

Keep crosstool-NG 1.24 / uClibc-ng 1.0.38 and Linux 5.4.86 userspace headers.
The XTOOLS_LINUX_* overrides separate header download, CT_LINUX_VERSION and
toolchain identity from the runtime kernel. g30w can reuse the existing
5.4.86-header toolchain; other machines retain their old defaults/identity.
Old headers do not prevent building a newer kernel, which uses its own
internal headers. This does not enable new userspace APIs in old libc.

Runtime version naming remains LINUX_VERSION=6.18 plus
LINUX_MINOR_VERSION=63, yielding linux-6.18.63.tar.xz and the v6.x URL.
kernel.make resolves conf/kernel/6.18.63 relative to build-config/ and
patches/kernel/6.18.63 relative to the repository. The common series contains
comments only. Upstream subcmd no longer retries realloc on the old pointer,
so the 5.4 subcmd patch was deliberately NOT carried forward.

g30w alone opts into olddefconfig before the normal kernel build, using the
same ARCH, CROSS_COMPILE and compiler PATH as the build. This happens only
when the user builds: the migration did not execute it. Its purpose is to
resolve new defaults, selected symbols and compiler capabilities without
interactive prompts. The initial merge remains merge_config.sh -m.

Configuration policy
--------------------

The new base is a configuration seed, NOT a compiler-generated .config.
It migrates supported user-visible options from the 5.4.86 ONIE base;
obsolete names, hidden selected capabilities and compiler probe results
were removed. Keep size optimization, disable host-native CPU tuning, retain
retpoline policy, and disable WERROR, Rust, debug info/BTF and module
compression for this installer. New hidden symbols/defaults are left to
the real target Kconfig evaluation. Full dependency resolution remains
unverified until the user's build.

CXNOS common.config and x86_64_defconfig were consulted for hardware intent,
not copied wholesale. The machine fragment requests built-in:

* i915 for J6412 / Elkhart Lake HDMI/DP, without ALPHA_SUPPORT or force-probe.
  The verified i915 PCI table contains the EHL IDs and native ehl_info.
* simpledrm + SYSFB_SIMPLEFB for the firmware-initialized early display,
  DRM fbdev emulation, default fbdev client and framebuffer VT console.
  Do not select EFIDRM simultaneously: its dependency excludes SIMPLEFB.
  Legacy efifb is also left off; simpledrm relies on a usable firmware buffer.
* igc for I226, including ETHTOOL_NETLINK and built-in PTP dependencies.
  Upstream igc explicitly contains I226 LM/V/IT and other device IDs.
* NVMe, retained SATA/AHCI, xHCI and USB HID keyboard support.

Firmware caveat: no linux-firmware blobs were added. For display version 11,
the source requests i915/icl_dmc_ver1_09.bin; absent DMC firmware disables
runtime display power management according to the upstream error path.
GuC/HuC acceleration/firmware behavior and actual display bring-up still
require hardware testing. Basic KMS is the goal, not a claim of validated
GPU acceleration, power management or HDMI audio.

Non-building validation
-----------------------

From the repository root, run the pure static checker against an extracted,
verified official source tree::

  python3 machine/bkhd/bkhd_g30w/kernel/check-config.py /path/to/linux-6.18.63

It checks source version, symbol existence/duplicates, merge-only built-in
requests, and isolated Make fragment evaluation for g30w and
accton_as7326_56x. It never includes the project top-level Makefile, never
runs olddefconfig or compiler probes, and never builds anything. Symbol
existence and textual merging do NOT prove satisfiable Kconfig dependencies.

Also verified both archive checksums and git diff --check. Still untested:
cross-compiler configuration resolution, kernel/toolchain compilation,
image size and packaging, boot, i915 framebuffer handoff/HDMI/DP, all four
I226 ports, NVMe/SATA discovery, USB keyboard and firmware/power management.
Do not treat the migration as a tested release image.
