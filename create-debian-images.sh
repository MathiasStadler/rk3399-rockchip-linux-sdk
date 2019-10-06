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
../repo/repo -c -jobs=20 sync

# create all images
./build.sh all

# create 
./mkfirmware.sh buildroot



