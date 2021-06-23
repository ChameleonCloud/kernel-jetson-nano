# nvidia-kernel-build

This repo can be used to build the kernel and modules for the Nvidia Jetson Nano.

This is needed in order to add kernel modules that CHI@Edge needs, as nvidia does not include them by default.

## Usage

`make sources` will download and extract needed source files

`make tegra_defconfig` will generate the default nvidia kernel config

`make menuconfig` will allow manual modification of the .config file

`make image` will build the kenrel image file
`make modules` will build all kernel modules
