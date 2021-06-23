VENDOR_DIR=vendor
SRC_DIR=src
TOOLS_DIR=tools

L4T_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v5.1/r32_release_v5.1/sources/t210/public_sources.tbz2
L4T_KERNEL_DIR=$(SRC_DIR)/kernel/kernel-4.9

LINARO_URL=https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
LINARO_VER=gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu

$(LINARO_VER).tar.xz:
	wget $(LINARO_URL) -O $(LINARO_VER).tar.xz

$(TOOLS_DIR)/$(LINARO_VER)/gcc-linaro-7.3.1-2018.05-linux-manifest.txt: |$(LINARO_VER).tar.xz
	mkdir -p $(TOOLS_DIR)
	tar -C $(TOOLS_DIR) -xf $(LINARO_VER).tar.xz

.PHONY: linaro_src
linaro_src: $(TOOLS_DIR)/$(LINARO_VER)/gcc-linaro-7.3.1-2018.05-linux-manifest.txt

public_sources.tbz2:
	wget $(L4T_URL) -O public_sources.tbz2

src/Linux_for_Tegra/source/public/kernel_src.tbz2: |public_sources.tbz2
	mkdir -p $(SRC_DIR)
	tar -C $(SRC_DIR) -xjf public_sources.tbz2


$(L4T_KERNEL_DIR)/Makefile: |src/Linux_for_Tegra/source/public/kernel_src.tbz2
	mkdir -p $(SRC_DIR)
	tar -C $(SRC_DIR) -xjf src/Linux_for_Tegra/source/public/kernel_src.tbz2


.PHONY: l4t_src
l4t_src: $(L4T_KERNEL_DIR)/Makefile

.PHONY: sources
sources: linaro_src l4t_src


CROSS_COMPILE=$(TOOLS_DIR)/$(LINARO_VER)/bin/aarch64-linux-gnu-
LOCALVERSION=-tegra
