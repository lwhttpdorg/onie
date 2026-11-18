#-------------------------------------------------------------------------------
#
#  Copyright (C) 2020 Alex Doyle <adoyle@nvidia.com>
#  Copyright (C) 2013,2014,2016,2017 Curt Brune <curt@cumulusnetworks.com>
#  Copyright (C) 2014 david_yang <david_yang@accton.com>
#  Copyright (C) 2015 Carlos Cardenas <carlos@cumulusnetworks.com>
#  Copyright (C) 2016 Pankaj Bansal <pankajbansal3073@gmail.com>
#
#  SPDX-License-Identifier:     GPL-2.0
#
#-------------------------------------------------------------------------------
#
# makefile fragment that defines the download of the kernel version
#

#-------------------------------------------------------------------------------
# Need the Linux kernel downloaded before building xtools

LINUX_VERSION		?= 5.4
LINUX_MAJOR_VERSION	= $(firstword $(subst ., ,$(LINUX_VERSION)))
LINUX_MINOR_VERSION	?= 86
LINUX_RELEASE		?= $(LINUX_VERSION).$(LINUX_MINOR_VERSION)
LINUX_TARBALL		?= linux-$(LINUX_RELEASE).tar.xz
export LINUX_TARBALL
export LINUX_RELEASE
KERNEL_ORG_DOWNLOAD = https://cdn.kernel.org/pub/linux/kernel
LINUX_TARBALL_URLS	+= $(KERNEL_ORG_DOWNLOAD)/v$(LINUX_MAJOR_VERSION).x $(ONIE_MIRROR)

KERNEL_DOWNLOAD_STAMP	= $(DOWNLOADDIR)/kernel-$(LINUX_RELEASE)-download

PHONY += kernel-download kernel-download-clean

DOWNLOAD += $(KERNEL_DOWNLOAD_STAMP)
kernel-download: $(KERNEL_DOWNLOAD_STAMP)
$(KERNEL_DOWNLOAD_STAMP): $(PROJECT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) echo "==== Getting Linux ===="
	$(Q) $(SCRIPTDIR)/fetch-package $(DOWNLOADDIR) $(UPSTREAMDIR) \
		$(LINUX_TARBALL) $(LINUX_TARBALL_URLS)
	$(Q) touch $@

DOWNLOAD_CLEAN += kernel-download-clean
kernel-download-clean:
	$(Q) rm -f $(KERNEL_DOWNLOAD_STAMP) $(DOWNLOADDIR)/$(LINUX_TARBALL)

# Toolchain headers normally track the runtime kernel. Machines may pin them
# independently without teaching old crosstool-NG about a new kernel series.
XTOOLS_LINUX_VERSION ?= $(LINUX_VERSION)
XTOOLS_LINUX_MINOR_VERSION ?= $(LINUX_MINOR_VERSION)
XTOOLS_LINUX_RELEASE ?= $(LINUX_RELEASE)
XTOOLS_LINUX_TARBALL = linux-$(XTOOLS_LINUX_RELEASE).tar.xz
XTOOLS_KERNEL_DOWNLOAD_STAMP = $(KERNEL_DOWNLOAD_STAMP)
ifneq ($(XTOOLS_LINUX_RELEASE),$(LINUX_RELEASE))
XTOOLS_KERNEL_DOWNLOAD_STAMP = $(DOWNLOADDIR)/kernel-$(XTOOLS_LINUX_RELEASE)-download
DOWNLOAD += $(XTOOLS_KERNEL_DOWNLOAD_STAMP)
$(XTOOLS_KERNEL_DOWNLOAD_STAMP): $(PROJECT_STAMP)
	$(Q) rm -f $@ && eval $(PROFILE_STAMP)
	$(Q) $(SCRIPTDIR)/fetch-package $(DOWNLOADDIR) $(UPSTREAMDIR) \
		$(XTOOLS_LINUX_TARBALL) \
		$(KERNEL_ORG_DOWNLOAD)/v$(firstword $(subst ., ,$(XTOOLS_LINUX_VERSION))).x $(ONIE_MIRROR)
	$(Q) touch $@
endif

#-------------------------------------------------------------------------------
#
# Local Variables:
# mode: makefile-gmake
# End:
