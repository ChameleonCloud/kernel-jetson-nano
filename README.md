# nvidia-kernel-build

This repo can be used to build the kernel and modules for the Nvidia Jetson Nano.

This is needed in order to add kernel modules that CHI@Edge needs, as nvidia does not include them by default.

## Usage

`make sources` will download and extract needed source files

`make tegra_defconfig` will generate the default nvidia kernel config

`make menuconfig` will allow manual modification of the .config file

`make image` will build the kenrel image file
`make modules` will build all kernel modules


## Installation

WARNING, these will seriously modify your system. Only run on a jetson nano that is not in active use.

```
# Save old modules for safety
mv /lib/modules/4.9.201-tegra/ /lib/modules/4.9.201-tegra.backup/

# Install new modules
tar -C / -xjf kernel_supplements.tbz2 && sync

# Save old kernel for safety
mv /boot/Image /boot/Image.backup

# Copy new kernel to boot
cp Image /boot/  && sync && reboot



```
