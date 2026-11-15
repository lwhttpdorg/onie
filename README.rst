********************************
Open Network Install Environment
********************************

ONIE is a small operating system, pre-installed on bare
metal network switches, that provides an environment for automated
provisioning.

Read the `ONIE Documentation <https://opencomputeproject.github.io/onie>`_ for more info.

********************************
Building ONIE
********************************

The recommended way to set up an ONIE build environment is to use a Docker image, as described
in the ONIE Documentation under `Preparing An ONIE Build Environment <https://opencomputeproject.github.io/onie/developers/building.html#preparing-an-onie-build-environment>`_.

This fork provides a Debian 13 Docker builder. From the repository root::

    make MODEL=g30w build
    make MODEL=as7326-56x build

The first command builds a persistent, non-root container and synchronizes
the checkout read-only into it. ONIE downloads and compilation stay in the
container; finished images are copied to ``targets/<machine>/``. The container
stops after each build. ``make clean`` clears ONIE build files in the container;
``make distclean`` removes the container, its image, and exported images.
See ``contrib/build-env/README.md`` for details. For native ONIE builds,
the original ``build-config/Makefile`` remains available.

******************************
Mailing List and Collaboration
******************************

Join the conversation -- send questions, comments and ideas to OCP-ONIE@OCP-All.groups.io.

Subscribe to the list: `https://ocp-all.groups.io/g/OCP-ONIE <https://ocp-all.groups.io/g/OCP-ONIE>`_.

Browse the archives: `https://ocp-all.groups.io/g/OCP-ONIE/topics <https://ocp-all.groups.io/g/OCP-ONIE/topics>`_.
