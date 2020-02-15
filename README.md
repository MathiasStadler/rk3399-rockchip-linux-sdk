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
# Distributor ID:Ubuntu
# Description:Ubuntu 16.04.6 LTS
# Release:16.04
# Codename:xenial

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
../repo/repo sync --current-branch --jobs=8
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

## flash all image to sbc rkusb mode

- start your sbc in [rkusb mode](http://wiki.t-firefly.com/en/ROC-RK3399-PC/upgrade_firmware_emmc.html)

- remove all cable
- insert usb-c cable from your source computer
- Press and hold the RECOVERY button
- power on the sbc
- after 3 second released the recovery button
- check is the sbc is connected via usb on host and Vagrant VM

```bash
lsusb
>Bus 003 Device 004: ID 2207:330c
```

| HINT: if you **NOT** see the usb device inside your
| vagrant virtualbox vm but on your host system check
| the usb filter settings of virtualbox!!

## config udev on host and vagrant vm

```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2207", MODE="0666", GROUP="plugdev"' |sudo tee /etc/udev/rules.d/51-android.roles
```

- unplug the usb cable and enter in the rkusb mode again for activate the rule
- follow error raise if you have NOT config udev

```txt
Loading loader...
Support Type:RK330C     Loader ver:1.19 Loader Time:
Creating Comm Object failed!
```

## flash the board

- the image was prepare with command ./mkfirmware.sh buildroot

```bash
cd && cd develop && cd linux
sudo ./rkflash.sh
```

## missing config.ini file

- follow error means

```txt
flash all images as default
Not found config.ini
```

The tool upgrade_tool create a config.ini in ~/.config/upgrade_tool/config.ini and this file is missing or corrupt :-)

sudo apt-get install debootrap
sudo apt-get install debootstrap
sudo apt-get install linaro-image-tools
sudo apt-get install live-build
sudo apt-get install python-linaro-image-tools

## temperature zone of rk3399 sapphire

```bash
# freq and temp
cat /sys/devices/system/cpu/cpufreq/policy?/cpuinfo_cur_freq /sys/devices/virtual/thermal/thermal_zone?/temp
```

## sshd Could not load host key: /etc/oad host key: /etc/ssh/ssh_host

reason: ssh host key missing => generate it

```bash
/usr/bin/ssh-keygen -A
```

## stress test for sbc

```bash
sudo apt-get install stress
# run stress
stress -c 5 -m 5 -i 5  -t 10
```

## sources

```txt
https://forum.frank-mankel.org/topic/292/rockpro64-rp64-gpio/2
```

## build boot image

- from here https://wiki.radxa.com/Rock/Booting_Linux

git clone https://github.com/neo-technologies/rockchip-mkbootimg.git
   cd rockchip-mkbootimg
   make
   sudo make install
   cd ..

## pack/unpack resources.img

http://rockchip.wikidot.com/create-image

http://lexra.pixnet.net/blog/post/345687467

```bash
git clone --depth 1  https://github.com/linux-rockchip/u-boot-rockchip.git
# enter folder
cd tools/resource
# comment CFLAGS
sed -i '/CFLAGS/s/^/#/g' Makefile
# compile tool
make
# unpack img default to ./out
./resource_tool --verbose --unpack --image=/root/develop/linux/kernel/resource.img
# list files
ls -l ./out
```

```txt
processing option: updateimg
Make update.img
start to make update.img...
Android Firmware Package Tool v1.62
------ PACKAGE ------
Add file: ./package-file
Add file: ./Image/MiniLoaderAll.bin
Add file: ./Image/parameter.txt
Add file: ./Image/trust.img
Add file: ./Image/uboot.img
Add file: ./Image/misc.img
Add file: ./Image/boot.img
Add file: ./Image/recovery.img
Add file: ./Image/rootfs.img
Add file: ./Image/oem.img
Add file: ./Image/userdata.img
Add CRC...
```

http://www.shincbm.com/linux/rk3399/arm64/2019/01/25/rk3399-linux-compile-native.html

## Find the files existing in one directory but not in the other

```bash
diff -r dir1 dir2 | grep dir1 | awk '{print $4}' > difference1.txt

 diff -r linux/kernel/scripts/ linux-mainline-kernel/scripts/ |grep linux/kernel/scripts/ | awk  '{print $4}'

```

## copy files but not overwrite

```bash
cp -vrn linux/kernel/scripts/* linux-mainline-kernel/scripts/
```

```bash
sudo apt-get install lib32z1
```


```bash
/root/develop/linux/rkbin/tools/upgrade_tool
```
rk3399_loader_v1.08.106.bin

```txt
1. Force the device into Maskrom Mode.
2. Run:
/root/develop/linux/rkbin/tools/upgrade_tool db           /root/develop/linux/u-boot/rk3399_loader_v1.22.119.bin
/root/develop/linux/rkbin/tools/upgrade_tool wl 0x0       out/system.img
/root/develop/linux/rkbin/tools/upgrade_tool rd           # reset device to boot
```

## rkdeveloptool

- upload / download bin and images to sbc

- downlaod / install

```bash
cd
cd develop
git clone https://github.com/rockchip-linux/rkdeveloptool.git
cd rkdeveloptool/
autoreconf -i
./configure
make
make install
rkdeveloptool  -v

```

## used rkdeveloptool

rkdeveloptool db /root/develop/linux/u-boot/rk3399_loader_v1.22.119.bin
# download from Armbian.com
rkdeveloptool wl 0x0 /vagrant_data/Armbian_5.98_Firefly-rk3399_Debian_buster_dev_5.3.0-rc4.img
# reset sbc
rkdeveloptool rd


## kitchen sink

```bash
/root/develop/linux/rkbin/tools/upgrade_tool wl 0x0 /vagrant_data/update.img_save
```




## uboot for rk3399-evb

```txt
https://github.com/u-boot/u-boot/tree/master/board/rockchip/evb_rk3399
```



setenv fdtfile rockchip/rk3399-sapphire.dtb
saveenv
run bootcmd_mmc0
