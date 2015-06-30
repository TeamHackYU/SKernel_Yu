#!/bin/bash
# Base by cybojenix <anthonydking@gmail.com>
# ReWriten by Caio Oliveira aka Caio99BR <caiooliveirafarias0@gmail.com>
# 64 Bits Arch commands by Suhail aka Skyinfo <sh.skyinfo@gmail.com>
# Rashed for the base of zip making
# And the internet for filling in else where

# You need to download https://github.com/TeamHackYU/aarch64-toolchains
# Clone in the same folder as the kernel

# Clean - Start

cleanzip() {
rm -rf zip-creator/*.zip
rm -rf zip-creator/Image
cleanzipcheck="Done"
zippackagecheck=""
adbcopycheck=""
}

cleankernel() {
make clean mrproper &> /dev/null
cleankernelcheck="Done"
buildprocesscheck=""
target=""
targetname=""
maindevicecheck=""
}

# Clean - End

# Main Process - Start

maindevice() {
target="Yu5010"
targetname="Yuphoria"
echo "Script says: This Kernel is only for $targetname ($target)"
make skernel_lettuce64_defconfig &> /dev/null
maindevicecheck="On"
}

maintoolchain() {
if [ -d ../aarch64-toolchains ]; then
	export CROSS_COMPILE="../aarch64-toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
else
	echo ""
	echo "Caio99BR says: You don't have TeamHackYU Prebuilt Toolchains"
	echo ""
	echo "Script says: Please specify a location"
	echo "Script says: and the prefix of the chosen toolchain at the end"
	echo "Caio99BR says: GCC 4.6 ex. ../arm-eabi-4.6/bin/arm-eabi-"
	read -p "Place: " CROSS_COMPILE
fi
}

# Main Process - End

# Build Process - Start

buildprocess() {
START=$(date +"%s")
make
END=$(date +"%s")
BUILDTIME=$(($END - $START))
if [ -f arch/$ARCH/boot/Image ]; then
	buildprocesscheck="Done"
	cleankernelcheck=""
else
	buildprocesscheck="Something is wrong, contact Dev!"
fi
}

zippackage() {
cp arch/$ARCH/boot/Image zip-creator/Image

zipfile="$customkernel-$target-$serie-$version.zip"

cd zip-creator
zip -r $zipfile * -x */.gitignore* &> /dev/null
cd ..

zippackagecheck="Done"
cleanzipcheck=""
}

# Build Process - End

# ADB - Start

adbcopy() {
echo "Script says: You want to copy to Internal or External Card?"
echo "i) For Internal"
echo "e) For External"
read -p "Choice: " -n 1 -s adbcoping
case "$adbcoping" in
	i ) echo "Coping to Internal Card..."; adb shell rm -rf /storage/sdcard0/$zipfile; adb push zip-creator/$zipfile /storage/sdcard0/$zipfile &> /dev/null; adbcopycheck="Done";;
	e ) echo "Coping to External Card..."; adb shell rm -rf /storage/sdcard1/$zipfile; adb push zip-creator/$zipfile /storage/sdcard1/$zipfile &> /dev/null; adbcopycheck="Done";;
	* ) echo "$adbcoping - This option is not valid"; sleep 2;;
esac
}

# ADB - End

# Menu - Start

customkernel=SKernel
export ARCH=arm64
export subarm=$ARCH
version=0.1

buildsh() {
kernelversion=`cat Makefile | grep VERSION | cut -c 11- | head -1`
kernelpatchlevel=`cat Makefile | grep PATCHLEVEL | cut -c 14- | head -1`
kernelsublevel=`cat Makefile | grep SUBLEVEL | cut -c 12- | head -1`
kernelname=`cat Makefile | grep NAME | cut -c 8- | head -1`
clear
echo "Caio99BR says: This is an open source script, feel free to use, edit and share it."
echo "Caio99BR says: Simple $customkernel Build Script."
echo "Caio99BR says: Linux Kernel $kernelversion.$kernelpatchlevel.$kernelsublevel - $kernelname"
echo
echo "Clean:"
echo "1) Last Zip Package ($cleanzipcheck)"
echo "2) Kernel ($cleankernelcheck)"
echo
echo "Main Process:"
echo "3) Device Choice ($target$serie$variant)"
echo "4) Toolchain Choice ($CROSS_COMPILE)"
echo
echo "Build Process:"
if ! [ "$maindevicecheck" == "" ]; then
	if ! [ "$CROSS_COMPILE" == "" ]; then
		echo "5) Build Kernel ($buildprocesscheck)"
	else
		echo "Use "4" first."
	fi
else
	echo "Use "3" first."
fi
if [ -f arch/arm/boot/Image ]; then
	echo "6) Build Zip Package ($zippackagecheck)"
fi
if [ -f zip-creator/*.zip ]; then
	echo
	echo "7) Copy to device - Via Adb ($adbcopycheck)"
fi
if [ "$adbcopycheck" == "Done" ]; then
	echo
	echo "8) Reboot device to recovery"
fi
echo
if ! [ "$BUILDTIME" == "" ]; then
	echo -e "\033[32mBuild Time: $(($BUILDTIME / 60)) minutes and $(($BUILDTIME % 60)) seconds.\033[0m"
	echo
fi
echo "q) Quit"
read -n 1 -p "Choice: " -s x
case $x in
	1) echo "$x - Cleaning Zips..."; cleanzip; buildsh;;
	2) echo "$x - Cleaning Kernel..."; cleankernel; buildsh;;
	3) echo "$x - Device choice"; maindevice; buildsh;;
	4) echo "$x - Toolchain choice"; maintoolchain; buildsh;;
	5) if [ -f .config ]; then
		echo "$x - Building Kernel..."; buildprocess; buildsh
	fi;;
	6) if [ -f arch/$ARCH/boot/Image ]; then
		echo "$x - Ziping Kernel..."; zippackage; buildsh
	fi;;
	7) if [ -f zip-creator/*.zip ]; then
		echo "$x - Coping Kernel..."; adbcopy; buildsh
	fi;;
	8) if [ "$adbcopycheck" == "Done" ]; then
		echo "$x - Rebooting $targetname ($target)..."; adb reboot recovery; buildsh
	fi;;
	q) echo "Ok, Bye!"; zippackagecheck="";;
	*) echo "$x - This option is not valid"; sleep 2; buildsh;;
esac
}

# Menu - End

# The core of script is here!

if ! [ -e build.sh ]; then
	echo
	echo "Ensure you run this file from the SAME folder as where it was,"
	echo "otherwise the script will have problems running the commands."
	echo "After you 'cd' to the correct folder, start the build script"
	echo "with the ./build.sh command, NOT with any other command!"
	echo; sleep 3
else
	if [ -f zip-creator/*.zip ]; then
		cleanzipcheck=""
	else
		cleanzipcheck="Done"
	fi

	if [ -f .config ]; then
		cleankernelcheck=""
	else
		cleankernelcheck="Done"
	fi

	if [ -f arch/$ARCH/boot/Image ]; then
		buildprocesscheck="Done"
	else
		buildprocesscheck=""
	fi

	buildsh
fi
