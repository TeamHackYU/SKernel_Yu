#!/bin/bash

# Base by cybojenix <anthonydking@gmail.com>
# Updated by Caio Oliveira aka Caio99BR <caiooliveirafarias0@gmail.com>
# credits to Rashed for the base of zip making
# credits to the internet for filling in else where

# You need to download https://github.com/TeamHackYU/aarch64-toolchains
# Clone in the same folder as the kernel

# Function Start
devicechoice() {
echo ""
export target="yu5010"
export targetname="Yuphoria"
echo "Script says: This Kernel is For $targetname ($target)"; sleep .5
export defconfig=skernel_lettuce64_defconfig
make $defconfig &> /dev/null
}

mainprocess() {
devicechoice
echo ""
echo "Caio99BR says: Checking if you have TeamHackYU Prebuilt Toolchains"; sleep 2
if [ -d ../aarch64-toolchains ]; then
echo "Script says: Only have 4.9 toolchain"; sleep .5
#echo "Script says: Choose the toolchain"; sleep .5
#echo "Google GCC - 1) 4.9"; sleep .5
toolchainchoice
else
echo "Caio99BR says: You don't have TeamHackYU Prebuilt Toolchains"; sleep .5
echo ""
echo "Script says: Please specify a location"; sleep 1
echo "Script says: and the prefix of the chosen toolchain at the end"; sleep 1
echo "Caio99BR says: GCC 4.6 ex. ../arm-eabi-4.6/bin/arm-eabi-"; sleep 2
toolchainplace
fi
echo "$CROSS_COMPILE"; sleep .5
}

toolchainchoice() {
#read -p "Choice: " -n 1 -s toolchain
#case "$toolchain" in
#	1 ) export CROSS_COMPILE="../aarch64-toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-";;
#	* ) echo "$toolchain - This option is not valid"; sleep 2; toolchainchoice;;
#esac
export CROSS_COMPILE="../aarch64-toolchains/aarch64-linux-android-4.9/bin/aarch64-linux-android-"
}

toolchainplace() {
read -p "Place: " -s CROSS_COMPILE
}

kernelclean() {
echo "Cleaning..."
make clean mrproper &> /dev/null
}

removelastzip() {
rm -rf zip-creator/*.zip
rm -rf zip-creator/tools/Image
}

resume() {
echo "Continuing...";
}

continuing() {
echo -ne
}

preloop() {
echo "Just wait"
loop
}

loop() {
LEND=$(date +"%s")
LBUILDTIME=$(($LEND - $START))
echo -ne "\r\033[K"
echo -ne "\033[32mElapsed Time: $(($LBUILDTIME / 60)) minutes and $(($LBUILDTIME % 60)) seconds.\033[0m"
sleep 1
echo -ne "\r\033[K"
looping
}

looping() {
if [ -f zip-creator/*.zip ]; then
continuing
else
loop
fi
}

ziperror() {
echo "Script says: The build failed so a zip won't be created"
}

buildprocess() {
echo "Building..."
sleep 1
echo
make
if [ -f arch/arm64/boot/Image ]; then
cp arch/arm64/boot/Image zip-creator/tools/Image
zipfile="$custom_kernel-$version-$target.zip"
cd zip-creator
zip -r $zipfile * -x *kernel/.gitignore*
cd ..
fi
}

# End - Function

# Start

clear

scriptrev=2

location=.
custom_kernel=SKernel
version=prebeta2

cd $location
export ARCH=arm64
export subarm=arm64

echo ""
echo "Caio99BR says: This is an open source script, feel free to use and share it."; sleep .5
echo "Caio99BR says: Kernel Build Script Revision $scriptrev."; sleep .5

removelastzip

echo ""
echo "Script says: Choose."
read -p "Script says: Any key for Restart Building Process or N for Continue: " -n 1 -s clean
case $clean in
	n) resume; devicechoice;;
	N) resume; devicechoice;;
	*) kernelclean; mainprocess;;
esac

echo ""
echo -e "Script says: Now, building the $custom_kernel for $target $version Edition!"; sleep .5

echo ""
echo "Script says: You want to see the details of kernel build?"
read -p "Script says: Enter any key for Yes or N for No: " -n 1 -t 10 -s clean
START=$(date +"%s")
case $clean in
	n) buildprocess &> /dev/null | preloop;;
	N) buildprocess &> /dev/null | preloop;;
	*) buildprocess;;
esac

if [ -f zip-creator/$zipfile ]; then
echo -e "\033[36mPackage Complete: zip-creator/$zipfile"
else
ziperror
fi

END=$(date +"%s")
BUILDTIME=$(($END - $START))
echo -e "\033[32mBuild Time: $(($BUILDTIME / 60)) minutes and $(($BUILDTIME % 60)) seconds.\033[0m"

# End
