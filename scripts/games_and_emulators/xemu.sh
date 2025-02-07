#!/bin/bash

clear -x
echo "Xemu script started!"

# Install dependencies
sudo apt install -y build-essential libsdl2-dev libepoxy-dev libpixman-1-dev libgtk-3-dev libssl-dev libsamplerate0-dev libpcap-dev ninja-build python3 gcc g++ || error "Could not install dependencies"

# Clone and build
git clone https://github.com/mborgerson/xemu.git -j$(nproc) #not including all submodules on this, the folder is over 2 GB if I do -cobalt
cd xemu
git pull --recurse-submodules -j$(nproc) || error "Could Not Pull Latest Source Code"

if grep -q bionic /etc/os-release; then
  ppa_name="ubuntu-toolchain-r/test" && ppa_installer
  #ppa_name="ubuntu-toolchain-r/ppa" && ppa_installer
  sudo apt install python3.8 gcc-11 g++-11 -y #GCC 9 (the 20.04 default) also works, I'm just using 11 to future-proof -cobalt
  sed -i -e 's/python3 /python3.8 /g' build.sh #this is hacky, yes, but hey, it works
  CFLAGS=-mcpu=native CXXFLAGS=-mcpu=native CC=gcc-11 CXX=g++-11 ./build.sh || error "Compilation failed"
else
  #./build.sh
  CFLAGS=-mcpu=native CXXFLAGS=-mcpu=native ./build.sh || error "Compilation failed" #I don't think CXXFLAGS actually gets used, but I'm leaving it there in case the build script ever takes it into account
fi


# Run
#./dist/xemu
### needs desktop files!
