#!/bin/bash
set -e -x

KERNEL_LINK=https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.3.8.tar.xz
KERNEL_FILE=zImage.tar.xz
KERNEL_DIR=zImage
LINUX_DIR=$KERNEL_DIR/linux-6.3.8
FS_LINK=http://dl-cdn.alpinelinux.org/alpine/v3.14/releases/x86_64/alpine-minirootfs-3.14.2-x86_64.tar.gz
FS_FILE=sysroot.tar.gz
FS_DIR=sysroot

ALPINE_LINUX_LINK=https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/x86_64/alpine-standard-3.18.2-x86_64.iso

sudo apt-get -y install \
    qemu-system-x86 \
    git \
    fakeroot \
    build-essential \
    ncurses-dev \
    xz-utils \
    libssl-dev \
    bc \
    flex \
    libelf-dev \
    debootstrap

# kernel
if [ ! -f $KERNEL_FILE ]; then
    wget $KERNEL_LINK -O zImage.tar.xz
fi

# extract kernel if folder does not exists
if [ ! -d $KERNEL_DIR ]; then
    mkdir $KERNEL_DIR
    tar -xvf zImage.tar.xz -C $KERNEL_DIR
fi

# build kernel
pushd $LINUX_DIR > /dev/null
make defconfig
make -j`nproc`
popd > /dev/null

find . -name bzImage

# extract alpine filesystem if folder does not exists
# if [ ! -d $FS_DIR ]; then
#     mkdir $FS_DIR
#     tar -xzvf sysroot.tar.gz -C $FS_DIR
# fi

# alpine file sysem
# if [ ! -f $FS_FILE ]; then  
#     wget $FS_LINK -O sysroot.tar.gz
# fi


# execute qemu
# qemu-system-x86_64 \
#     -kernel $KERNEL_FILE \
#     -hda $FS_FILE \
#     -append "console=ttyS0" \
#     -nographic -m 512M





