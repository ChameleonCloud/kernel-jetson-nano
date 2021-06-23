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


UPSTREAM_KERNEL_URL=http://ftp.br.debian.org/debian/pool/main/l/linux/linux-headers-4.9.0-13-arm64_4.9.228-1_arm64.deb
UPSTREAM_KERNEL_DEB=linux-headers-4.9.0-13-arm64_4.9.228-1_arm64.deb

$(UPSTREAM_KERNEL_DEB):
	wget $(UPSTREAM_KERNEL_URL) -O $(UPSTREAM_KERNEL_DEB)

data.tar.xz: $(UPSTREAM_KERNEL_DEB)
	ar x $(UPSTREAM_KERNEL_DEB) data.tar.xz

upstream.config: data.tar.xz
	tar --strip-components=4 -xf data.tar.xz "./usr/src/linux-headers-4.9.0-13-arm64/.config"
	mv .config upstream.config

.PHONY: sources
sources: linaro_src l4t_src


export CROSS_COMPILE=$(TOOLS_DIR)/$(LINARO_VER)/bin/aarch64-linux-gnu-
export LOCALVERSION=-tegra

TEGRA_KERNEL_OUT=$(CURDIR)/build
OUTPUT_DIR=$(CURDIR)/output

tegra.config:
	mkdir -p $(TEGRA_KERNEL_OUT)
	make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) tegra_defconfig
	cp $(TEGRA_KERNEL_OUT)/.config tegra.config

menuconfig: load-cc-config
	make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) menuconfig

.PHONY: load-cc-config
load-cc-config:
	cp cc_tegra.config $(TEGRA_KERNEL_OUT)/.config

$(OUTPUT_DIR)/Image: load-cc-config
	mkdir -p $(OUTPUT_DIR)
	make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) -j12
	cp $(TEGRA_KERNEL_OUT)/arch/arm64/boot/Image $(OUTPUT_DIR)/Image

.PHONY: clean
clean:
	rm -rf output/*
	# make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) clean

.PHONY: image
image: $(OUTPUT_DIR)/Image

$(OUTPUT_DIR)/Modules: load-cc-config
	mkdir -p $(OUTPUT_DIR)
	make -C $(KERNEL_SRC_DIR) ARCH=arm64 O=$(TEGRA_KERNEL_OUT) -j8 modules_install \
    	INSTALL_MOD_PATH=$(OUTPUT_DIR)/Modules

$(OUTPUT_DIR)/kernel_supplements.tbz2: $(OUTPUT_DIR)/Modules
	tar -C $(OUTPUT_DIR)/Modules \
		--owner root --group root \
		-cjf $(OUTPUT_DIR)/kernel_supplements.tbz2 \
    	lib/modules

.PHONY: modules
modules: $(OUTPUT_DIR)/kernel_supplements.tbz2

.PHONY: all
all: image modules
