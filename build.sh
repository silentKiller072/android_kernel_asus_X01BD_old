#!/usr/bin/env bash
# Copyright (C) 2019 ZyCromerZ
export KBUILD_BUILD_USER="ZyCromerZ"
export KBUILD_BUILD_HOST="BreakerZ"
export CROSS_COMPILE=~/toolchain_latest/bin/aarch64-linux-android-
export CROSS_COMPILE_ARM32=~/toochain-32/bin/arm-linux-androideabi-
KERNEL_DIR=$PWD
GetCore=$(nproc --all)
build(){
    make O=out ARCH=arm64 SUBARCH=arm64 X01BD_defconfig
    make -j$(($GetCore+1)) O=out \
                        ARCH=arm64 \
                        SUBARCH=arm64 \
                        CC=~/clang-10.0.1/bin/clang \
                        CLANG_TRIPLE=aarch64-linux-gnu- 
                        
                        
}
clean(){
    make -j$(($GetCore+1)) O=out clean mrproper
    rm -rf out
}
makeFlashable(){
    KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
    ZIP_DIR=~/android/AnyKernel3
    ZIP_KERNEL_VERSION="4.4.$(cat "$KERNEL_DIR/Makefile" | grep "SUBLEVEL =" | sed 's/SUBLEVEL = *//g')"
    KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    ZIP_NAME="[$(date +"%m%d" )]$KERNEL_NAME-$(echo $ZIP_KERNEL_VERSION).zip"
	cp $KERN_IMG $ZIP_DIR
    cd $ZIP_DIR
    KernelOutput=~/kernel_output/$ZIP_NAME
    sed -i "s/kernel.string=.*/kernel.string=$KERNEL_NAME by ZyCromerZ/g" anykernel.sh
    zip -r $KernelOutput ./ -x /.git/*
    sleep 1
    echo "done,your file now at $KernelOutput"
    cd $KERNEL_DIR
}
Choice(){
    clear
    echo "1 > clean "
    echo "2 > build "
    echo "3 > makezip "
    echo "4 > clean > build > makezip"
    echo "5 > build > makezip"
    echo "press anykey to quit . . ."
    read GetInput

    if [ "$GetInput" == "1" ];then
        clean
        echo "done . . "
        echo -n "press any key to continue"
        read -n 1
        Choice
    elif [ "$GetInput" == "2" ];then
        build
        echo "done . . "
        echo -n "press any key to continue"
        read -n 1
        Choice
    elif [ "$GetInput" == "3" ];then
        makeFlashable
        echo "done . . "
        read -n 1
        Choice
    elif [ "$GetInput" == "4" ];then
        clean
        build
        makeFlashable
        echo "done . . "
        echo -n "press any key to continue"
        read -n 1
        Choice
    elif [ "$GetInput" == "5" ];then
        build
        makeFlashable
        echo "done . . "
        echo -n "press any key to continue"
        read -n 1
        Choice
    else
        echo "bye . . ."
    fi;
}
Choice