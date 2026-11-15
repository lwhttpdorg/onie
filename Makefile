.NOTPARALLEL:

# Local Docker build shortcuts; the upstream build-config/Makefile remains the
# authoritative ONIE build system.
MODEL ?= g30w
ifeq ($(MODEL),g30w)
ONIE_MACHINE ?= bkhd_g30w
ONIE_MACHINEROOT ?= bkhd
else ifeq ($(MODEL),as7326-56x)
ONIE_MACHINE ?= accton_as7326_56x
ONIE_MACHINEROOT ?= accton
else
$(error Unsupported MODEL '$(MODEL)': use g30w or as7326-56x)
endif

JOBS ?= $(shell nproc)
# Build verbosity: 0 = quiet (default), 1 = verbose.  Forwarded into the
# container build so sub-makes (grub, kernel, ...) honor it via MAKEFLAGS.
V ?= 0
export V
# Optional alternative ONIE package mirror (same flat layout as
# http://mirror.opencompute.org/onie).  Empty = use the build-config
# default.  Example: make ONIE_MIRROR=https://my.server/onie build
ONIE_MIRROR ?=
export ONIE_MIRROR
DOCKER ?= docker
PROJECT_ID := $(shell pwd -P | sha256sum | cut -c1-12)
BUILDER_IMAGE := onie-builder-$(PROJECT_ID):2026.08
BUILDER := $(CURDIR)/contrib/build-env/build.sh
export DOCKER

.PHONY: all docker-image download build clean distclean
all: build

docker-image:
	$(DOCKER) build -t "$(BUILDER_IMAGE)" -f contrib/build-env/Dockerfile contrib/build-env

download build: docker-image
	@$(BUILDER) $@ "$(ONIE_MACHINE)" "$(ONIE_MACHINEROOT)" "$(JOBS)"

clean:
	@$(BUILDER) clean "$(ONIE_MACHINE)" "$(ONIE_MACHINEROOT)" "$(JOBS)"

distclean:
	@$(BUILDER) distclean
