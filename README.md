# Open Network Install Environment

ONIE is a small operating system, pre-installed on bare
metal network switches, that provides an environment for automated
provisioning.

Read the [ONIE Documentation](https://opencomputeproject.github.io/onie) for more info.

## Building ONIE

The recommended way to set up an ONIE build environment is to use a Docker image, as described
in the ONIE Documentation under [Preparing An ONIE Build Environment](https://opencomputeproject.github.io/onie/developers/building.html#preparing-an-onie-build-environment).

This fork provides a Debian 13 Docker builder. From the repository root, run the command for your machine.

```sh
make ONIE_MACHINE=bkhd_g30w ONIE_MACHINEROOT=bkhd build
make ONIE_MACHINE=accton_as5812_54x ONIE_MACHINEROOT=accton build
make ONIE_MACHINE=accton_as7326_56x ONIE_MACHINEROOT=accton build
```

The first build creates a persistent, non-root container and synchronizes
the checkout read-only into it. ONIE downloads and compilation stay in the
container. Finished images are copied to `targets/<machine>/`. The container
stops after each build. `make clean` clears ONIE build files in the container.
`make distclean` removes the container, its image, and exported images.
See [the Docker build environment guide](contrib/build-env/README.md) for details. For native ONIE builds,
the original `build-config/Makefile` remains available.

## Mailing List and Collaboration

Join the conversation -- send questions, comments and ideas to OCP-ONIE@OCP-All.groups.io.

Subscribe to the list: [https://ocp-all.groups.io/g/OCP-ONIE](https://ocp-all.groups.io/g/OCP-ONIE).

Browse the archives: [https://ocp-all.groups.io/g/OCP-ONIE/topics](https://ocp-all.groups.io/g/OCP-ONIE/topics).
