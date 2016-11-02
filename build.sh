#!/bin/bash

### Prema Chand Alugu (premaca@gmail.com)
### Shivam Desai (shivamdesaixda@gmail.com)
### HelpMeRuth (jukeboxruthger1@gmail.com)
### A custom build script to build zImage,DTB & wlan module (Anykernel2 method)
### Made universal for everyone. Make sure you run with sudo or su

set -e

KERNEL_DIR=$PWD
TOOLCHAINDIR=../Toolchain
## Place your toolchain in ../Toolchain dir.
if [ ! -d $TOOLCHAINDIR ]
then
echo "**** Making /Toolchain directory ****"
echo "**** Place your toolchain in it! ****"
echo "##STOPPED COMPILING"
mkdir $TOOLCHAINDIR
## Map has been made by root, so give permission to user.
chmod 777 $TOOLCHAINDIR
exit
else
echo "**** /Toolchain present ****"
echo " "
fi
TC=$(ls ../Toolchain/)
KERNEL_TOOLCHAIN=$TOOLCHAINDIR/$TC/bin/arm-eabi-
KERNEL_DEFCONFIG=osprey_defconfig
DTBTOOL=$KERNEL_DIR/Dtbtool/
BUILDS=../Builds
JOBS=2
ANY_KERNEL2_DIR=$KERNEL_DIR/Anykernel2/
VERSION=4

# The MAIN Part
echo "**** Toolchain set to $TC ****"
echo " "
export CROSS_COMPILE=$KERNEL_TOOLCHAIN
export ARCH=arm
echo "**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****"
make $KERNEL_DEFCONFIG
make CONFIG_NO_ERROR_ON_MISMATCH=y CONFIG_DEBUG_SECTION_MISMATCH=y -j$JOBS

# Time for dtb
echo "**** Generating DT.IMG ****"
$DTBTOOL/dtbToolCM -2 -o $KERNEL_DIR/arch/arm/boot/dtb -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/

echo "**** Verify zImage,dtb & wlan ****"
ls $KERNEL_DIR/arch/arm/boot/zImage
ls $KERNEL_DIR/arch/arm/boot/dtb
ls $KERNEL_DIR/drivers/staging/prima/wlan.ko

#Anykernel 2 time!!
echo "**** Verifying Anyernel2 Directory ****"
ls $ANY_KERNEL2_DIR
echo "**** Removing leftovers ****"
rm -rf $ANY_KERNEL2_DIR/dtb
rm -rf $ANY_KERNEL2_DIR/zImage
rm -rf $ANY_KERNEL2_DIR/modules/wlan.ko
### just get rid of every zip, who wants a zip in a zip?
rm -rf $ANY_KERNEL2_DIR/*.zip

echo "**** Copying zImage ****"
cp $KERNEL_DIR/arch/arm/boot/zImage $ANY_KERNEL2_DIR/
echo "**** Copying dtb ****"
cp $KERNEL_DIR/arch/arm/boot/dtb $ANY_KERNEL2_DIR/
echo "**** Copying modules ****"
cp $KERNEL_DIR/drivers/staging/prima/wlan.ko $ANY_KERNEL2_DIR/modules/

## Set build number
echo "**** Setting Build Number ****"
NUMBER=$(cat number)
INCREMENT=$(expr $NUMBER + 1)
sed -i s/$NUMBER/$INCREMENT/g $KERNEL_DIR/number
FINAL_KERNEL_ZIP=Ruthless-build$INCREMENT-R$VERSION.zip

## Make sure we have a map for output zip
if [ ! -d "$BUILDS" ]
then
echo "**** Making /Builds directory ****"
  mkdir $BUILDS
## Map has been made by root, so give permission to user.
chmod 777 $BUILDS
else
echo "**** Build directory is present ****"
fi

echo "**** Time to zip up! ****"
cd $ANY_KERNEL2_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cd ..
cd ..
echo $FINAL_KERNEL_ZIP
cp $KERNEL_DIR/Anykernel2/$FINAL_KERNEL_ZIP Builds/$FINAL_KERNEL_ZIP

echo "**** Good Bye!! ****"
cd $KERNEL_DIR
