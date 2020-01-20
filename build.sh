export KBUILD_BUILD_USER="ZyCromerZ"
export KBUILD_BUILD_HOST="Laptop"
export CROSS_COMPILE=~/gcc9/bin/aarch64-linux-gnu-
# export CROSS_COMPILE=~/aarch64-maestro-linux-android-27122019-9.2.1/bin/aarch64-maestro-linux-gnu-
# export CROSS_COMPILE=~/aarch64-elf-gcc-9.2.0/bin/aarch64-elf-
# export CROSS_COMPILE=~/aarch64-maestro-linux-android-170719-9.1/bin/aarch64-maestro-linux-gnu-
# export CROSS_COMPILE=~/aarch64-maestro-linux-android-27122019-10.0.0/bin/aarch64-maestro-linux-gnu-
# export CROSS_COMPILE=~/clang-dev-10.0/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=~/toolchain-32/bin/arm-linux-androideabi-
# export CROSS_COMPILE_ARM32=~/arm-maestro-linux-gnueabi-27122019-10.0.0/bin/arm-maestro-linux-gnueabi-
# export CROSS_COMPILE_ARM32=~/clang-dev-10.0/bin/arm-linux-gnueabi-
KERNEL_DIR=~/android/x01bd_kernel
GetCore=$(nproc --all)
BUILDER_LOG=~/android/builder
if [ ! -d "$BUILDER_LOG" ]; then
    # Control will enter here if $DIRECTORY doesn't exist.
    mkdir $BUILDER_LOG
else
    rm -rf $BUILDER_LOG/*
fi
build(){
    KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    if [ ! -z "$1" ];then
        build_Loga=$BUILDER_LOG/$1.$KERNEL_NAME.buildA.txt
        build_Logb=$BUILDER_LOG/$1.$KERNEL_NAME.buildB.txt
    else
        build_Loga=$BUILDER_LOG/$KERNEL_NAME.buildA.txt
        build_Logb=$BUILDER_LOG/$KERNEL_NAME.buildB.txt
    fi
    sleep 2
    make O=out ARCH=arm64 SUBARCH=arm64 X01BD_defconfig 2>&1 >"$build_Loga"
    make -j$(($GetCore+1)) O=out \
                        ARCH=arm64 \
                        SUBARCH=arm64 \
                        CC=/home/zycromerz/clang-dev-10.0/bin/clang \
                        CLANG_TRIPLE=aarch64-linux-gnu- 2>&1 >"$build_Logb"
                                        
}
buildDTC(){
    KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    if [ ! -z "$1" ];then
        build_Loga=$BUILDER_LOG/$1.$KERNEL_NAME.buildA.txt
        build_Logb=$BUILDER_LOG/$1.$KERNEL_NAME.buildB.txt
    else
        build_Loga=$BUILDER_LOG/$KERNEL_NAME.buildA.txt
        build_Logb=$BUILDER_LOG/$KERNEL_NAME.buildB.txt
    fi
    sleep 2
    make O=out ARCH=arm64 SUBARCH=arm64 X01BD_defconfig 2>&1 >"$build_Loga"
    make -j$(($GetCore+1)) O=out \
                        ARCH=arm64 \
                        SUBARCH=arm64 \
                        CC=/home/zycromerz/dragontc/DragonTC-daily-10.0/bin/clang \
                        CLANG_TRIPLE=aarch64-linux-gnu- 2>&1 >"$build_Logb"
                                        
}
buildClangGoogle(){
    KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    build_Loga=$BUILDER_LOG/$KERNEL_NAME.clangGoogle.buildA.txt
    build_Logb=$BUILDER_LOG/$KERNEL_NAME.clangGoogle.buildB.txt
    sleep 2
    make O=out ARCH=arm64 SUBARCH=arm64 X01BD_defconfig 2>&1 >"$build_Loga"
    make -j$(($GetCore+1)) O=out \
                        ARCH=arm64 \
                        SUBARCH=arm64 \
                        CC=/home/zycromerz/clang-google/clang-r370808/bin/clang \
                        CLANG_TRIPLE=aarch64-linux-gnu- 2>&1 >"$build_Logb"
                                        
}
buildNoClang(){
    KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    if [ ! -z "$1" ];then
        build_Loga=$BUILDER_LOG/$1.$KERNEL_NAME.buildA.txt
        build_Logb=$BUILDER_LOG/$1.$KERNEL_NAME.buildB.txt
    else
        build_Loga=$BUILDER_LOG/$KERNEL_NAME.buildA.txt
        build_Logb=$BUILDER_LOG/$KERNEL_NAME.buildB.txt
    fi
    sleep 2
    make O=out ARCH=arm64 SUBARCH=arm64 X01BD_defconfig 2>&1 >"$build_Loga"
    make -j$(($GetCore+1)) O=out \
                        ARCH=arm64 \
                        SUBARCH=arm64 2>&1 >"$build_Logb"
                                        
}
clean(){
    # KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    echo "clean previous kernel files . . ."
    if [ ! -z "$1" ];then
        clean_Loga=$BUILDER_LOG/$1.cleanA.txt
        clean_Logb=$BUILDER_LOG/$1.cleanB.txt
    else
        clean_Loga=$BUILDER_LOG/cleanA.txt
        clean_Logb=$BUILDER_LOG/cleanB.txt
    fi
    make -j$(($GetCore+1)) O=out clean mrproper 2>&1  >"$clean_Loga"
    make -j$(($GetCore+1)) clean mrproper 2>&1  >"$clean_Logb"
    rm -rf out

    echo "clean previous kernel files, done ."
}
makeFlashable(){
    GetLastCommit=$(git show | grep "commit " | awk '{if($1=="commit") print $2;exit}' | cut -c 1-12)
    KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
    ZIP_DIR=~/android/AnyKernel3
    SPECTRUM_DIR=~/android/spectrum
    ZIP_KERNEL_VERSION="4.4.$(cat "$KERNEL_DIR/Makefile" | grep "SUBLEVEL =" | sed 's/SUBLEVEL = *//g')"
    KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    ZIP_NAME="[$(date +"%m%d" )]$KERNEL_NAME-$(echo $ZIP_KERNEL_VERSION)-$(echo $GetLastCommit).zip"
    if [ -e $KERN_IMG ];then
        cp $KERN_IMG $ZIP_DIR
        if [[ "$KERNEL_NAME" == *"VVVIP"* ]];then
            cp -af $SPECTRUM_DIR/vvvip.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"VVIP"* ]];then
            cp -af $SPECTRUM_DIR/vvip.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"VIPN"* ]];then
            cp -af $SPECTRUM_DIR/vipn.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"VIPL"* ]];then
            cp -af $SPECTRUM_DIR/vipl.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"VIP"* ]];then
            cp -af $SPECTRUM_DIR/vip.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"iLoC"* ]];then
            cp -af $SPECTRUM_DIR/iLoC.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"Niqua-X"* ]];then
            cp -af $SPECTRUM_DIR/iLoC.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"Santuy"* ]];then
            cp -af $SPECTRUM_DIR/santuy.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"DeathFlower"* ]];then
            cp -af $SPECTRUM_DIR/private-3.0.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"MiuiXDC-N"* ]];then
            cp -af $SPECTRUM_DIR/vipn.rc $ZIP_DIR/init.spectrum.rc
        elif [[ "$KERNEL_NAME" == *"SAR-N"* ]];then
            cp -af $SPECTRUM_DIR/vipn.rc $ZIP_DIR/init.spectrum.rc
        else 
            if [ -e $ZIP_DIR/init.spectrum.rc ];then
                rm $ZIP_DIR/init.spectrum.rc
            fi
        fi
        if [ -e $ZIP_DIR/init.spectrum.rc ];then
            cp -af $ZIP_DIR/anykernel-real.sh $ZIP_DIR/anykernel.sh
        fi
        cd $ZIP_DIR
        if [ ! -z "$1" ];then
            KernelOutput=~/kernel_output/$1.$ZIP_NAME
        else
            KernelOutput=~/kernel_output/$ZIP_NAME
        fi
        sed -i "s/kernel.string=.*/kernel.string=$KERNEL_NAME-$GetLastCommit by ZyCromerZ/g" anykernel.sh
        if [ -e init.spectrum.rc ];then
            sed -i "s/setprop persist.spectrum.kernel.*/setprop persist.spectrum.kernel $KERNEL_NAME/g" init.spectrum.rc
        fi
        echo "creating flashable zip file . . ."
        zip -r "$KernelOutput" ./ -x /.git/* ./anykernel-real.sh ./.gitignore ./LICENSE ./README.md  >/dev/null 2>&1
        sleep 1
        echo "done,your file now at $KernelOutput"
        cd $KERNEL_DIR
    else
        echo "kernel img not found"
        exit
    fi
}
buildPlusChangeBranch(){
    git checkout $1
    # git reset --hard 
    KERNEL_NAME=$(cat "./arch/arm64/configs/X01BD_defconfig" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
    GetLastCommit=$(git show | grep "commit " | awk '{if($1=="commit") print $2;exit}' | cut -c 1-12)
    echo "building $KERNEL_NAME-$GetLastCommit . . ."
    echo "please wait. . ."
    if [ ! -z "$3" ];then
        if [ "$3" == "DTC" ];then
            buildDTC "$2"
        else
            buildNoClang "$2"
        fi
    else
        build "$2"
    fi
    if [ ! -z "$2" ];then
        makeFlashable $2
    else
        makeFlashable
    fi
    echo "--- --- --- --- --- ---"
}
cd $KERNEL_DIR

# clean number clean

# buildPlusChangeBranch "branch" "another description" "builder"

echo "done . . . :D"
