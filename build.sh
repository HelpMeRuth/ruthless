#!/bin/bash

### Prema Chand Alugu (premaca@gmail.com)
### Shivam Desai (shivamdesaixda@gmail.com)
### A custom build script to build zImage,DTB & wlan module (Anykernel2 method)

set -e

## Copy this script inside the kernel directory
KERNEL_DIR=$PWD
KERNEL_TOOLCHAIN=/home/ruthger/android/arm-eabi-5.x/bin/arm-eabi-
KERNEL_DEFCONFIG=osprey_defconfig
DTBTOOL=$KERNEL_DIR/Dtbtool/
JOBS=2
ANY_KERNEL2_DIR=$KERNEL_DIR/Anykernel2/
VERSION=3
echo "**** Setting Build Number ****"
NUMBER=$(cat number)
INCREMENT=$(expr $NUMBER + 1)
sed -i s/$NUMBER/$INCREMENT/g $KERNEL_DIR/number
FINAL_KERNEL_ZIP=Ruthless-build$INCREMENT-R$VERSION.zip

# The MAIN Part
echo "**** Setting Toolchain ****"
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
rm -rf $ANY_KERNEL2_DIR/*.zip

echo "**** Copying zImage ****"
cp $KERNEL_DIR/arch/arm/boot/zImage $ANY_KERNEL2_DIR/
echo "**** Copying dtb ****"
cp $KERNEL_DIR/arch/arm/boot/dtb $ANY_KERNEL2_DIR/
echo "**** Copying modules ****"
cp $KERNEL_DIR/drivers/staging/prima/wlan.ko $ANY_KERNEL2_DIR/modules/

echo "**** Time to zip up! ****"
cd $ANY_KERNEL2_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP
cp $KERNEL_DIR/Anykernel2/$FINAL_KERNEL_ZIP /home/$USER/Builds/$FINAL_KERNEL_ZIP

echo "**** Good Bye!! ****"
cd $KERNEL_DIR
