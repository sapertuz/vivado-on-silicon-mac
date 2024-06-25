#!/bin/bash

# echo with color
function f_echo {
	echo -e "\e[1m\e[33m$1\e[0m"
}

# Check for previous installation
if [ -d "/home/user/Xilinx/" ]
	then
		f_echo "Previous installation found. To continue, please remove the Xilinx directory."
		exit 1
fi

if [ -d "/home/user/installer/" ]
	then
		f_echo "Installer was previously extracted. Removing the extracted directory."
		rm -rf /home/user/installer
fi

# Check if the Web Installer is present
numberOfInstallers=0

for f in /home/user/*.bin; do
	((numberOfInstallers++))
done

if [[ $numberOfInstallers -eq 1 ]]
	then
		f_echo "Found Installer"
	else
		f_echo "Installer file was not found or there are multiple installer files!"
		f_echo "Make sure to download the Linux Self Extracting Web Installer and place it in this directory."
		exit 1
fi

cd /home/user

VIVADO_VERSION=0
md5sumString=$(md5sum -b /home/user/*.bin | awk '{print $1}')

# checking version
if [[ ($md5sumString == "e47ad71388b27a6e2339ee82c3c8765f") || ($md5sumString == "b8c785d03b754766538d6cde1277c4f0") ]]; then
    VIVADO_VERSION=2023
elif [[ $md5sumString == "9bf473b6be0b8531e70fd3d5c0fe4817" ]]; then
    VIVADO_VERSION=2022
else
    VIVADO_VERSION=-1
    f_echo "ERROR: None of the files is a valid vivado version md5sum: $md5sumString"
    exit 1
fi

f_echo "Vivado Version: $VIVADO_VERSION"

# Extract installer
f_echo "Extracting installer"
mkdir /temp
cp /home/user/*.bin /temp
chmod +x /temp/*.bin
/temp/*.bin --target /temp --noexec
cp -r /temp /home/user/installer
rm -rf /temp

# Get AuthToken by repeating the following command until it succeeds
f_echo "Log into your Xilinx account to download the necessary files."
while ! /home/user/installer/xsetup -b AuthTokenGen
do
	f_echo "Your account information seems to be wrong. Please try logging in again."
	sleep 1
done

# Run installer
f_echo "You successfully logged into your account. The installation will begin now."
f_echo "If a window pops up, simply close it to finish the installation."
/home/user/installer/xsetup -c "/home/user/install_config_$VIVADO_VERSION.txt" -b Install -a XilinxEULA,3rdPartyEULA
