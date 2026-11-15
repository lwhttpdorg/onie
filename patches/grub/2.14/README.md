# GRUB 2.14 migration audit

## Source authentication

Stable upstream release: 2.14 (2026-01-14), downloaded over HTTPS from GNU.
The detached signature was verified with the GNU project keyring using gpgv:
Daniel Kiper, fingerprint BE5C23209ACDDACEB20DB0A28C8189F1988C2166.
SHA-256: bc8d3c73535b8838d8c8e2654d73edc4e6ae8c8acdb45d5df5dc9a1547446d43.
The normal ONIE downloader still checks the committed SHA-1; no validation is disabled.

## Compatibility decisions

* Keep ONIE's Secure Boot state command and its existing return convention
  (1 = enabled, 0 = disabled), using the upstream EFI Secure Boot state API.
  Do not disable GPG, shim or kernel verification.
* Replace the downstream linuxefi module with upstream's unified linux module
  in both EFI image generators. Existing ONIE menu entries already use linux/initrd.
  The upstream loader supports the legacy shim protocol and Linux 5.4 fallback.
* Port DHCPv6, IPv6 PXE, HTTP Boot device paths and firmware DNS support;
  retain upstream DHCP bounds checks, client UUID properties and VLAN handling.
  Update GUID types, EFI calling conventions and the 64-bit datetime API.
* Keep the device-map utility with its safe-allocation fix and EFI platform fallback.
* The old udevadm-disable patch was not in the old series. It is unnecessary:
  upstream Linux hostdisk queries /sys/dev/block directly, without udevadm.
* Prefer text-section placement during linker probing. Binutils 2.44 accepts
  --image-base for ELF but places headers before text, breaking BIOS load addresses.
* GRUB 2.14 still needs a BSD metadata allocation error-contract fix for GCC 14.
  No warning suppression is added; all five previous local array-bounds
  warning downgrades are removed.
* autoconf-archive is a required new regeneration dependency. It was installed
  into the existing container without rebuilding it; the Docker dependency list
  is updated for reproducibility. A later image rebuild replaces the container,
  so export/cache build artifacts before intentionally rebuilding the image.

## Numbered patch order

The four-digit prefix follows the authoritative series application order.
Patch contents are unchanged by numbering; the 2.04 directory remains intact.

1. [0001-core-in-fs.patch](0001-core-in-fs.patch)
2. [0002-restore-mkdevicemap.patch](0002-restore-mkdevicemap.patch)
3. [0003-deviceiter-overflow.patch](0003-deviceiter-overflow.patch)
4. [0004-install-efi-fallback.patch](0004-install-efi-fallback.patch)
5. [0005-is_sb_enabled_command.patch](0005-is_sb_enabled_command.patch)
6. [0006-bsd-explicit-allocation-error.patch](0006-bsd-explicit-allocation-error.patch)
7. [0007-bootp-new-net_bootp6-command.patch](0007-bootp-new-net_bootp6-command.patch)
8. [0008-efinet-uefi-ipv6-pxe-support.patch](0008-efinet-uefi-ipv6-pxe-support.patch)
9. [0009-bootp-process-dhcpack-http-boot.patch](0009-bootp-process-dhcpack-http-boot.patch)
10. [0010-efinet-set-network-from-uefi-devpath.patch](0010-efinet-set-network-from-uefi-devpath.patch)
11. [0011-efinet-set-dns-from-uefi-proto.patch](0011-efinet-set-dns-from-uefi-proto.patch)
12. [0012-net-use-upstream-hexdigit.patch](0012-net-use-upstream-hexdigit.patch)
13. [0013-dhcpv6-time64-api.patch](0013-dhcpv6-time64-api.patch)
14. [0014-elf-text-address.patch](0014-elf-text-address.patch)
15. [0015-bootp-alloc.patch](0015-bootp-alloc.patch)

## Old series disposition (all 99 entries)

“Upstream” below refers to the signed 2.14 source, not to patch dry-run success.
ChangeLog line numbers refer to the unmodified release tarball. Distribution
policy patches are deliberately not rebased: ONIE builds its own boot menus,
images and signing flow rather than Debian/Ubuntu package integration.
This is not a claim of boot testing on non-g30w platforms.

| Old patch | Disposition / evidence |
|---|---|
| [olpc-prefix-hack.patch](../2.04/olpc-prefix-hack.patch) | Old distribution/platform policy outside g30w BIOS/UEFI; not claimed validated on OLPC/PowerPC/Xen. |
| [core-in-fs.patch](../2.04/core-in-fs.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [dpkg-version-comparison.patch](../2.04/dpkg-version-comparison.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [grub-legacy-0-based-partitions.patch](../2.04/grub-legacy-0-based-partitions.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [disable-floppies.patch](../2.04/disable-floppies.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [grub.cfg-400.patch](../2.04/grub.cfg-400.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [gfxpayload-keep-default.patch](../2.04/gfxpayload-keep-default.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [install-stage2-confusion.patch](../2.04/install-stage2-confusion.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [mkrescue-efi-modules.patch](../2.04/mkrescue-efi-modules.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [mkconfig-loopback.patch](../2.04/mkconfig-loopback.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [restore-mkdevicemap.patch](../2.04/restore-mkdevicemap.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [gettext-quiet.patch](../2.04/gettext-quiet.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [install-efi-fallback.patch](../2.04/install-efi-fallback.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [mkconfig-ubuntu-recovery.patch](../2.04/mkconfig-ubuntu-recovery.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [install-locale-langpack.patch](../2.04/install-locale-langpack.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [mkconfig-nonexistent-loopback.patch](../2.04/mkconfig-nonexistent-loopback.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [no-insmod-on-sb.patch](../2.04/no-insmod-on-sb.patch) | Superseded by upstream shim verification and lockdown modules, not the obsolete shim interface. |
| [default-grub-d.patch](../2.04/default-grub-d.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [blacklist-1440x900x32.patch](../2.04/blacklist-1440x900x32.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [uefi-firmware-setup.patch](../2.04/uefi-firmware-setup.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [mkconfig-ubuntu-distributor.patch](../2.04/mkconfig-ubuntu-distributor.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [linuxefi.patch](../2.04/linuxefi.patch) | Replaced by upstream unified EFI linux loader; both image module lists migrated. |
| [mkconfig-signed-kernel.patch](../2.04/mkconfig-signed-kernel.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [install-signed.patch](../2.04/install-signed.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [sleep-shift.patch](../2.04/sleep-shift.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [wubi-no-windows.patch](../2.04/wubi-no-windows.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [maybe-quiet.patch](../2.04/maybe-quiet.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [install-efi-adjust-distributor.patch](../2.04/install-efi-adjust-distributor.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [quick-boot.patch](../2.04/quick-boot.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [quick-boot-lvm.patch](../2.04/quick-boot-lvm.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [gfxpayload-dynamic.patch](../2.04/gfxpayload-dynamic.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [vt-handoff.patch](../2.04/vt-handoff.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [probe-fusionio.patch](../2.04/probe-fusionio.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [ignore-grub_func_test-failures.patch](../2.04/ignore-grub_func_test-failures.patch) | Not carried: never downgrade or ignore test failures. |
| [mkconfig-recovery-title.patch](../2.04/mkconfig-recovery-title.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [install-powerpc-machtypes.patch](../2.04/install-powerpc-machtypes.patch) | Old distribution/platform policy outside g30w BIOS/UEFI; not claimed validated on OLPC/PowerPC/Xen. |
| [ieee1275-clear-reset.patch](../2.04/ieee1275-clear-reset.patch) | Old distribution/platform policy outside g30w BIOS/UEFI; not claimed validated on OLPC/PowerPC/Xen. |
| [ppc64el-disable-vsx.patch](../2.04/ppc64el-disable-vsx.patch) | Old distribution/platform policy outside g30w BIOS/UEFI; not claimed validated on OLPC/PowerPC/Xen. |
| [grub-install-pvxen-paths.patch](../2.04/grub-install-pvxen-paths.patch) | Old distribution/platform policy outside g30w BIOS/UEFI; not claimed validated on OLPC/PowerPC/Xen. |
| [insmod-xzio-and-lzopio-on-xen.patch](../2.04/insmod-xzio-and-lzopio-on-xen.patch) | Old distribution/platform policy outside g30w BIOS/UEFI; not claimed validated on OLPC/PowerPC/Xen. |
| [grub-install-extra-removable.patch](../2.04/grub-install-extra-removable.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [mkconfig-other-inits.patch](../2.04/mkconfig-other-inits.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [zpool-full-device-name.patch](../2.04/zpool-full-device-name.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [net-read-bracketed-ipv6-addr.patch](../2.04/net-read-bracketed-ipv6-addr.patch) | Upstream ChangeLog:10268 and net/net.c bracket/port parsing. |
| [bootp-new-net_bootp6-command.patch](../2.04/bootp-new-net_bootp6-command.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [efinet-uefi-ipv6-pxe-support.patch](../2.04/efinet-uefi-ipv6-pxe-support.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [bootp-process-dhcpack-http-boot.patch](../2.04/bootp-process-dhcpack-http-boot.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [efinet-set-network-from-uefi-devpath.patch](../2.04/efinet-set-network-from-uefi-devpath.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [efinet-set-dns-from-uefi-proto.patch](../2.04/efinet-set-dns-from-uefi-proto.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [fix-lockdown.patch](../2.04/fix-lockdown.patch) | Upstream lockdown infrastructure replaces the old downstream hook. |
| [skip-grub_cmd_set_date.patch](../2.04/skip-grub_cmd_set_date.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [bash-completion-drop-have-checks.patch](../2.04/bash-completion-drop-have-checks.patch) | Superseded by current upstream implementation; not needed by ONIE menu/image generation. |
| [at_keyboard-module-init.patch](../2.04/at_keyboard-module-init.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [uefi-secure-boot-cryptomount.patch](../2.04/uefi-secure-boot-cryptomount.patch) | Debian grub-install Secure Boot packaging policy; ONIE uses its own prebuilt/signed EFI images. |
| [vsnprintf-upper-case-hex.patch](../2.04/vsnprintf-upper-case-hex.patch) | Superseded by current upstream implementation; not needed by ONIE menu/image generation. |
| [efi-variable-storage-minimise-writes.patch](../2.04/efi-variable-storage-minimise-writes.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [no-devicetree-if-secure-boot.patch](../2.04/no-devicetree-if-secure-boot.patch) | Old downstream secure-boot hook is obsolete; upstream devicetree uses lockdown policy. |
| [grub-install-removable-shim.patch](../2.04/grub-install-removable-shim.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [sparc64-fix-bios-boot-partition-support.patch](../2.04/sparc64-fix-bios-boot-partition-support.patch) | Upstream ChangeLog:22777; use upstream implementation. |
| [verifiers-blocklist-fallout.patch](../2.04/verifiers-blocklist-fallout.patch) | Upstream ChangeLog:22853; use upstream implementation. |
| [btrfs-raid1c34.patch](../2.04/btrfs-raid1c34.patch) | Upstream ChangeLog:22538; use upstream implementation. |
| [dejavu-font-path.patch](../2.04/dejavu-font-path.patch) | Debian/Ubuntu packaging, generated-menu, UI or desktop policy; ONIE supplies its own menus/install/image flow. Not an ONIE-specific patch. |
| [xen-ignore-xenpolicy-and-config.patch](../2.04/xen-ignore-xenpolicy-and-config.patch) | Upstream ChangeLog:20981; use upstream implementation. |
| [xen-support-xsm.patch](../2.04/xen-support-xsm.patch) | Upstream ChangeLog:20969; use upstream implementation. |
| [xen-no-xsm-policy-in-non-xsm-options.patch](../2.04/xen-no-xsm-policy-in-non-xsm-options.patch) | Old distribution/platform policy outside g30w BIOS/UEFI; not claimed validated on OLPC/PowerPC/Xen. |
| [CVE-2020-10713.patch](../2.04/CVE-2020-10713.patch) | Upstream ChangeLog:20900; original security change is included (later upstream refinements retained). |
| [safe-alloc-1.patch](../2.04/safe-alloc-1.patch) | Upstream ChangeLog:20883; original security change is included (later upstream refinements retained). |
| [safe-alloc-2.patch](../2.04/safe-alloc-2.patch) | Upstream ChangeLog:18236; original security change is included (later upstream refinements retained). |
| [safe-alloc-3.patch](../2.04/safe-alloc-3.patch) | Upstream ChangeLog:20852; original security change is included (later upstream refinements retained). |
| [safe-alloc-4.patch](../2.04/safe-alloc-4.patch) | Upstream ChangeLog:20825; original security change is included (later upstream refinements retained). |
| [iso9660-realloc-leak.patch](../2.04/iso9660-realloc-leak.patch) | Upstream ChangeLog:20820; original security change is included (later upstream refinements retained). |
| [font-name-leak.patch](../2.04/font-name-leak.patch) | Upstream ChangeLog:20809; original security change is included (later upstream refinements retained). |
| [gfxmenu-load-image-double-free.patch](../2.04/gfxmenu-load-image-double-free.patch) | Upstream ChangeLog:20799; original security change is included (later upstream refinements retained). |
| [xnu-double-free.patch](../2.04/xnu-double-free.patch) | Upstream ChangeLog:20787; original security change is included (later upstream refinements retained). |
| [lzma-overflow.patch](../2.04/lzma-overflow.patch) | Upstream ChangeLog:3072; original security change is included (later upstream refinements retained). |
| [term-overflow.patch](../2.04/term-overflow.patch) | Upstream ChangeLog:20727; original security change is included (later upstream refinements retained). |
| [udf-leak.patch](../2.04/udf-leak.patch) | Upstream ChangeLog:20719; original security change is included (later upstream refinements retained). |
| [multiboot2-leak.patch](../2.04/multiboot2-leak.patch) | Upstream ChangeLog:20712; original security change is included (later upstream refinements retained). |
| [tftp-no-priority-queue.patch](../2.04/tftp-no-priority-queue.patch) | Upstream ChangeLog:20383; original security change is included (later upstream refinements retained). |
| [relocator-chunk-addr-overflow.patch](../2.04/relocator-chunk-addr-overflow.patch) | Upstream ChangeLog:20673; original security change is included (later upstream refinements retained). |
| [relocator-chunk-align-underflow.patch](../2.04/relocator-chunk-align-underflow.patch) | Upstream ChangeLog:20656; original security change is included (later upstream refinements retained). |
| [script-remove-unused-fields.patch](../2.04/script-remove-unused-fields.patch) | Upstream ChangeLog:20651; original security change is included (later upstream refinements retained). |
| [script-use-after-free.patch](../2.04/script-use-after-free.patch) | Upstream ChangeLog:20631; original security change is included (later upstream refinements retained). |
| [relocator-chunk-align-fix-top.patch](../2.04/relocator-chunk-align-fix-top.patch) | Upstream ChangeLog:20611; original security change is included (later upstream refinements retained). |
| [hfsplus-overflow.patch](../2.04/hfsplus-overflow.patch) | Upstream ChangeLog:20600; original security change is included (later upstream refinements retained). |
| [lvm-overflow.patch](../2.04/lvm-overflow.patch) | Upstream ChangeLog:7250; original security change is included (later upstream refinements retained). |
| [emu-free-null.patch](../2.04/emu-free-null.patch) | Upstream ChangeLog:20579; original security change is included (later upstream refinements retained). |
| [efi-malformed-device-path.patch](../2.04/efi-malformed-device-path.patch) | Upstream ChangeLog:20562; original security change is included (later upstream refinements retained). |
| [efi-malformed-device-path-2.patch](../2.04/efi-malformed-device-path-2.patch) | Upstream loader/efi/chainloader.c copy_file_path returns explicit allocation errors and propagates them. |
| [safe-alloc-5.patch](../2.04/safe-alloc-5.patch) | Upstream include/grub/safemath.h provides compiler builtins plus older-compiler fallbacks. |
| [efi-halt-reboot-use-after-free.patch](../2.04/efi-halt-reboot-use-after-free.patch) | Upstream ChangeLog:20511; original security change is included (later upstream refinements retained). |
| [linux-loader-overflow.patch](../2.04/linux-loader-overflow.patch) | Upstream loader/linux.c uses grub_calloc for initrd components. |
| [linux-initrd-overflow.patch](../2.04/linux-initrd-overflow.patch) | Upstream ChangeLog:20496; original security change is included (later upstream refinements retained). |
| [bootp-alloc.patch](../2.04/bootp-alloc.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [unix-config-overflow.patch](../2.04/unix-config-overflow.patch) | Specific to dropped Debian default-grub.d extension; upstream config loader uses xcalloc. |
| [deviceiter-overflow.patch](../2.04/deviceiter-overflow.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [is_sb_enabled_command.patch](../2.04/is_sb_enabled_command.patch) | Retained / ported in the 2.14 series (with current API adaptations where required). |
| [mdraid1x-linux-gcc-10.patch](../2.04/mdraid1x-linux-gcc-10.patch) | Upstream ChangeLog:21483; no duplicate backport. |
| [zfs-gcc-10.patch](../2.04/zfs-gcc-10.patch) | Upstream ChangeLog:21433; no duplicate backport. |

## Validation scope

Validation results and remaining blockers are recorded in the repository build
validation report. Compilation is not a substitute for real BIOS/UEFI boot,
Secure Boot signature rejection, or IPv6/HTTP network-boot tests.
