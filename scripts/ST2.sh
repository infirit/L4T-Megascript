clear
echo "SuperTux2 script started!"
echo "Downloading the files and installing needed dependencies..."
sleep 3
cd /home/$USER
git clone --recursive https://github.com/SuperTux/supertux
sudo apt install build-essential libsdl2-2.0-0 libsdl2-dev libsdl2-image-2.0-0 libsdl2-image-dev curl libcurl4 libcurl4-openssl-dev libvorbis-dev libogg-dev cmake extra-cmake-modules libopenal-dev libglew-dev libboost-dev libboost-all-dev -y
svn export https://github.com/cobalt2727/L4T-Megascript/trunk/assets/ST2
cd /home/$USER/supertux/data/images/engine/menu
rm logo_dev.png
mv logo.png logo_dev.png
cd /home/$USER/supertux
mkdir build && cd build
echo
echo "Compiling the game..."
sleep 1
echo
cmake .. -DCMAKE_BUILD_TYPE=RELEASE
make -j$(nproc)
echo
echo "Game compiled!"
sleep 1
echo "Installing game...."
sudo make install
echo "Erasing temporary build files to save space..."
sleep 2
echo
cd /home/$USER/.local/share && mkdir supertux2
cd /home/$USER/ST2
mv config -t /home/$USER/.local/share/supertux2
cd /home/$USER
sudo rm -r supertux
rm -r ST2
echo
echo "Game installed!"
echo
echo
echo "[NOTE] Remember NOT to move the SuperTux2 folder or any file inside it or the game will stop working."
echo "If the game icon doesn't appear inmediately, restart the system."
echo "This message will close in 10 seconds."
sleep 10
echo
echo "Sending you back to the main menu..."
sleep 1

