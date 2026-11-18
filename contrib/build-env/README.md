# ONIE Docker build environment (Debian 13)

From the ONIE fork's repository root, with Docker installed and available to
your user:

```sh
make ONIE_MACHINE=bkhd_g30w ONIE_MACHINEROOT=bkhd build
make ONIE_MACHINE=accton_as5812_54x ONIE_MACHINEROOT=accton build
make ONIE_MACHINE=accton_as7326_56x ONIE_MACHINEROOT=accton build
```

`make build` defaults to G30W. For a platform directly under `machine/`, use
`make ONIE_MACHINE=kvm_x86_64 ONIE_MACHINEROOT= build`. Set `JOBS` to override
the detected number of parallel jobs.

The default container name is `onie-builder` and its image is
`onie-builder:2026.08`. Set `BUILDER_NAME` to a distinct name for each
additional checkout, for example `make BUILDER_NAME=onie-builder-test build`.
Use the same name for that checkout's download, build, and cleanup commands.
The first build with the new name creates a fresh container cache.

The tool image installs the build dependencies once. A persistent container
is created with the checkout mounted **read-only** at
`/src`. Before each build, `rsync` updates a separate writable `/build/onie`
 tree in that container, including Git metadata for ONIE release tags;
 `/build/onie/build` and other generated files are excluded from synchronization
 and remain cached. ONIE compilation runs as the
non-root `build` user (required by crosstool-NG). After each operation, the
container stops. Completed images are copied to the host's `targets/<machine>`.

`make download` prepares downloads without building images, `make clean`
clears upstream build files in the existing container, and `make distclean`
deletes the persistent container, tool image, and exported host images without
first rebuilding the tool image. Modifying the Dockerfile recreates the
container and invalidates its build cache.

For Debian 13 compatibility, GRUB is upgraded to 2.14, with narrowly scoped
source fixes rather than warning downgrades. Regenerating GRUB now requires
`autoconf-archive`. The existing m4 1.4.18 SIGSTKSZ fix under
`patches/crosstool-NG/local/m4/1.4.18/` is retained. These also apply to native
builds. See the [GRUB migration audit](../../patches/grub/2.14/README.md) and
[validation report](GRUB-2.14-validation.md) for results and remaining blockers.
The g30w hardware configuration has not been validated on a device.
