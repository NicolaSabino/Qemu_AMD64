#!/bin/bash
set -ex

# resources
# https://medium.com/@kiki.tokamuro/creating-initramfs-5cca9b524b5a
# https://lyngvaer.no/log/create-linux-initramfs
# https://linuxconfig.org/introduction-to-the-linux-kernel-log-levels
# http://lists.busybox.net/pipermail/busybox/2010-July/072895.html

function build_kernel {
    tar xvf download/linux-6.3.8.tar.xz
    pushd linux-6.3.8
    make x86_64_defconfig
    make -j$(nproc)
    popd
}

function create_initramfs {
    rm -rf initramfs
    mkdir -p initramfs/{bin,dev,etc,home,mnt,proc,sys,usr,tmp}
    cp download/busybox initramfs/bin/busybox
    initramfs/bin/busybox --install initramfs/bin
    echo Setup init file
    init_script_setup
    pushd initramfs
    find . | cpio -ov --format=newc | gzip -9 > ../initramfz
    popd
}

function init_script_setup {
cat >>initramfs/init << EOF
#!/bin/busybox sh

mount -t devtmpfs  devtmpfs  /dev
mount -t proc      proc      /proc
mount -t sysfs     sysfs     /sys
mount -t tmpfs     tmpfs     /tmp

cat << "END"

    Hello World :)
    Boot in $(cut -d' ' -f1 /proc/uptime) seconds

END

setsid cttyhack sh
EOF
sudo chmod +x initramfs/init
}

function download_data {
    sudo apt-get -y install qemu-system-x86
    mkdir -p download 
    pushd download
    rm -rf *
    wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.3.8.tar.xz
    wget https://www.busybox.net/downloads/binaries/1.26.2-defconfig-multiarch/busybox-x86_64 -O busybox
    chmod +x busybox
    popd
}

function run_qemu {
    qemu-system-x86_64 \
        -kernel linux-6.3.8/arch/x86_64/boot/bzImage\
        -initrd initramfz \
        -append "loglevel=3 console=ttyS0 init=/init" \
        -m 2G \
        -serial stdio \
        -display none
}

# call each fucntion one by one
download_data
build_kernel
create_initramfs
run_qemu




