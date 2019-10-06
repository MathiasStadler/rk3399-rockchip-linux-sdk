#!/bin/bash

# update system
sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove

# install packages
xargs sudo apt-get -y install < install_packages.list

# mkdir develop
cd && mkdir ~/develop

# check out repo
cd && cd develop
git clone https://github.com/rockchip-linux/repo

# mkdir
mkdir linux && cd $_

# init repo for rk3399
../repo/repo init --repo-url=https://github.com/rockchip-linux/repo -u https://github.com/rockchip-linux/manifests -b master -m rk3399_linux_release.xml

# checkout all repo
../repo/repo -c -jobs=20 sync

# create all images
./build.sh all

# create 
./mkfirmware.sh buildroot



