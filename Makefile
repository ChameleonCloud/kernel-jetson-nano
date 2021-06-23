VENDOR_DIR=$(CURDIR)/vendor
SRC_DIR=$(CURDIR)/src
TOOLS_DIR=$(CURDIR)/tools

L4T_URL=https://developer.nvidia.com/embedded/l4t/r32_release_v5.1/r32_release_v5.1/sources/t210/public_sources.tbz2
KERNEL_SRC_DIR=$(SRC_DIR)/kernel/kernel-4.9

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


$(KERNEL_SRC_DIR)/Makefile: |src/Linux_for_Tegra/source/public/kernel_src.tbz2
	mkdir -p $(SRC_DIR)
	tar -C $(SRC_DIR) -xjf src/Linux_for_Tegra/source/public/kernel_src.tbz2


.PHONY: l4t_src
l4t_src: $(KERNEL_SRC_DIR)/Makefile

.PHONY: sources
sources: linaro_src l4t_src


export CROSS_COMPILE=$(TOOLS_DIR)/$(LINARO_VER)/bin/aarch64-linux-gnu-
export LOCALVERSION=-tegra

TEGRA_KERNEL_OUT=$(CURDIR)/build
OUTPUT_DIR=output

tegra_defconfig:
	mkdir -p $(TEGRA_KERNEL_OUT)
	make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) tegra_defconfig
	cp $(TEGRA_KERNEL_OUT)/.config tegra_defconfig

menuconfig:
	make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) menuconfig

$(OUTPUT_DIR)/Image:
	make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) -j16

.PHONY: image
image: $(OUTPUT_DIR)/Image


.PHONY: modules
modules: $(OUTPUT_DIR)/modules
