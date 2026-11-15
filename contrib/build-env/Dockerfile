# SPDX-License-Identifier: GPL-2.0
# Native x86_64 ONIE build environment (Debian 9 is EOL).
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf autoconf-archive automake autopoint bc bison build-essential bsdextrautils ca-certificates \
    cpio curl device-tree-compiler dosfstools fakeroot file flex gawk git \
    gettext gperf help2man libefivar-dev libelf-dev libexpat1-dev libncurses-dev libnss3-dev \
    libnss3-tools libpopt-dev libssl-dev libtool libtool-bin mtools \
    patch pkg-config python3 python3-dev python3-sphinx rsync rst2pdf \
    sbsigntool stgit sudo texinfo u-boot-tools unzip util-linux \
    uuid-dev uuid-runtime wget xorriso xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build/onie
RUN useradd --create-home --shell /bin/bash build \
    && mkdir -p /build/onie \
    && chown -R build:build /build
USER build
RUN git config --global user.name onie-build \
    && git config --global user.email build@onie.invalid
CMD ["sleep", "infinity"]
