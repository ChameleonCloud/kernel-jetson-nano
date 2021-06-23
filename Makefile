VENDOR_DIR=vendor
SRC_DIR=src
TOOLS_DIR=tools

LINARO_URL=https://releases.linaro.org/components/toolchain/binaries/7.3-2018.05/aarch64-linux-gnu/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu.tar.xz
LINARO_VER=gcc-linaro-7.3.1-2018.05-x86_64_aarch64-linux-gnu

CROSS_COMPILE=$(TOOLS_DIR)/$(LINARO_VER)/bin/aarch64-linux-gnu-
LOCALVERSION=-tegra

$(LINARO_VER).tar.xz:
	wget $(LINARO_URL) -O $(LINARO_VER).tar.xz

tools/$(LINARO_VER): $(LINARO_VER).tar.xz
	mkdir -p $(TOOLS_DIR)
	tar -C $(TOOLS_DIR) -xf $(LINARO_VER).tar.xz
