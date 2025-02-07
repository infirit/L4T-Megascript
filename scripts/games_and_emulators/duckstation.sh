cd ~
sudo apt install cmake libsdl2-dev libxrandr-dev pkg-config qtbase5-dev qtbase5-private-dev qtbase5-dev-tools qttools5-dev libevdev-dev git libcurl4-gnutls-dev libgbm-dev libdrm-dev ninja-build -y || error "Could not install dependencies"

git clone https://github.com/stenzek/duckstation
cd duckstation
git pull || error "Could Not Pull Latest Source Code"
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -GNinja ..
#cmake -DCMAKE_BUILD_TYPE=Release ..
ninja || error "Compilation failed"
#make -j$(nproc)
