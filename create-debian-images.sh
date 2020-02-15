#!/bin/bash

# update system
sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y autoremove

# install packages
xargs sudo apt-get -y install < install_packages.list

# mkdir develop
cd && mkdir -p ~/develop

# check out repo
cd && cd develop
git clone --depth 1 https://github.com/rockchip-linux/repo

# mkdir
mkdir linux && cd $_

# init repo for rk3399
../repo/repo init --repo-url=https://github.com/rockchip-linux/repo -u https://github.com/rockchip-linux/manifests -b master -m rk3399_linux_release.xml

# checkout all repo
../repo/repo sync --current-branch --jobs=20

# create all images
./build.sh all

# create 
./mkfirmware.sh buildroot

# install rktool for 64 bit
cd && cd develop
git clone https://github.com/rockchip-android/RKTools.git

# save old version
mv ~/develop/linux/tools/linux/Linux_Pack_Firmware/rockdev/afptool ~/develop/linux/tools/linux/Linux_Pack_Firmware/rockdev/afptool_not64Bit
mv ~/develop/linux/tools/linux/Linux_Pack_Firmware/rockdev/rkImageMaker ~/develop/linux/tools/linux/Linux_Pack_Firmware/rockdev/rkImageMaker_not64Bit

# create link

ln -s ~/develop/RKTools/linux/Linux_Pack_Firmware/rockdev/afptool ~/develop/linux/tools/linux/Linux_Pack_Firmware/rockdev/afptool
ln -s ~/develop/RKTools/linux/Linux_Pack_Firmware/rockdev/rkImageMaker ~/develop/linux/tools/linux/Linux_Pack_Firmware/rockdev/rkImageMaker

# create update.img
~/develop/linux/./build.sh updateimg

echo "finish "
echo "you can flash the image to sbc with the command"
echo "sudo ~/develop/linux/rkflash.sh update ~/develop/linux/rockdev/update.img"


# build debian rootfs

cd ~/develop/linux/rootfs

# install packages
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -y -f

# make base debian image
RELEASE=stretch TARGET=desktop ARCH=arm64 ./mk-base-debian.sh


# Building the rk-debian rootfs:
RELEASE=stretch ARCH=arm64 ./mk-rootfs.sh

# Creating the ext4 image(linaro-rootfs.img):
./mk-image.sh


