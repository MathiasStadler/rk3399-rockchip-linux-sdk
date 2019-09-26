# rk3399-rockchip-linux-sdk

missing walkthrough to prepare a debian 10 (buster) image for a [Rockchip RK3399 Sapphire board](https://store.vamrs.com/products/rockchip-rk3399-sapphire-board) demo board

## motivation only for my mind :-)

## source

[Rockchip linux user guide](http://opensource.rock-chips.com/wiki_Linux_user_guide)

## prepare Environment

- used vagrant box ubuntu/xenial64
- with 100 G space
- on ThinkCentre M92/M92p SFF Desktop i5/24GB
- host os ubuntu 16.04.04 with vagrant and virtualbox

## setup vagrant

```bash
# used the Vagrantfile from this repo
vagrant up
```

## update vagrant vm

```bash
#!/bin/bash
sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove
lsb_release -a
# output 27.09.2019
# No LSB modules are available
# Distributor ID:	Ubuntu
# Description:	Ubuntu 16.04.6 LTS
# Release:	16.04
# Codename:	xenial

```

## prepare folder

```bash
mkdir develop && $_
```

## install necessary packages for building the project

```bash
xargs sudo apt-get -y install < install_packages.lst
```

## install repo

```bash
cd && cd develop
git clone https://github.com/rockchip-linux/repo
mkdir linux
cd linux
```

## checkout repo from rockchip for rk3399

```bash
cd && cd develop && cd linux
../repo/repo init --repo-url=https://github.com/rockchip-linux/repo -u https://github.com/rockchip-linux/manifests -b master -m rk3399_linux_release.xml
../repo/repo sync
```

## build all images and collect

- hint: this command create buildroot rootfs

```bash
cd && cd develop && cd linux
./build.sh all
# collect images
./mkfirmware.sh buildroot
```

## build debian strech destop rootfs

```bash
cd && cd develop
git clone https://github.com/rockchip-linux/rk-rootfs-build.git
cd rk-rootfs-build
RELEASE=stretch TARGET=desktop ARCH=arm64 ./mk-base-debian.sh
RELEASE=stretch ARCH=arm64 ./mk-rootfs.sh
./mk-image.sh

```


## modify parameter.txt

- the parameter.txt define the partition size
echo $(( 0x00200000 * 512 / 1024 / 1024 ))M

## flash all image to sbc

- start your sbc in [rkusb mode](http://wiki.t-firefly.com/en/ROC-RK3399-PC/upgrade_firmware_emmc.html)

- remove all cable
- insert usb-c cable from your source computer
- Press and hold the RECOVERY button
- power on the sdc
- after 3 second released the recovery button
- check is the sbc is connected via usb

```bash
lsusb
> 
```

- HINT: if you not see the usb device inside your vagrant vm check the usb filter settings

```bash
cd && cd develop && cd linux
./rkflash
```



sudo apt-get install debootrap
   29  sudo apt-get install debootstrap
   30  sudo apt-get install linaro-image-tools
   31  sudo apt-get install live-build
   32  sudo apt-get install python-linaro-image-tools

