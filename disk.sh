#!/bin/bash

dd if=/dev/zero of=foxos.img bs=512 count=93750

echo 'echo "o\ny\nn\n1\n\n\n0700\nw\ny\n" | gdisk foxos.img' | sh

if [ "$1" != "" ]; then
	export PREFIX=$1
else
	export PREFIX="/usr/local/foxos-x86_64_elf_gcc"
fi

if [ "$2" != "" ]; then
	export PROG_PREFIX=$2
else
	export PROG_PREFIX="foxos-"
fi

if [ -f $PREFIX'/bin/'$PROG_PREFIX'losetup' ]; then
	dev_mount=`$PREFIX'/bin/'$PROG_PREFIX'losetup' f | egrep -o '[0-9]+'`
else
	dev_mount=`losetup -f | egrep -o '[0-9]+'`
fi

if [ -f $PREFIX'/bin/'$PROG_PREFIX'losetup' ]; then
	$PREFIX'/bin/'$PROG_PREFIX'losetup' m ${dev_mount}
else
	losetup /dev/loop${dev_mount} foxos.img -P
fi

echo Mounted disk as /dev/loop${dev_mount}

mkfs.vfat -F 32 /dev/loop${dev_mount}p1

mmd -i /dev/loop${dev_mount}p1 ::/EFI
mmd -i /dev/loop${dev_mount}p1 ::/EFI/BOOT
mmd -i /dev/loop${dev_mount}p1 ::/EFI/FOXOS

mcopy -i /dev/loop${dev_mount}p1 ./tmp/limine/limine.sys ::
mcopy -i /dev/loop${dev_mount}p1 ./tmp/limine/BOOTX64.EFI ::/EFI/BOOT
mcopy -i /dev/loop${dev_mount}p1 limine.cfg ::
mcopy -i /dev/loop${dev_mount}p1 startup.nsh ::
mcopy -i /dev/loop${dev_mount}p1 FoxOS-kernel/bin/* ::/EFI/FOXOS

mmd -i /dev/loop${dev_mount}p1 ::/BIN
mcopy -i /dev/loop${dev_mount}p1 FoxOS-programs/bin/* ::/BIN

if [ -f $PREFIX'/bin/'$PROG_PREFIX'losetup' ]; then
	$PREFIX'/bin/'$PROG_PREFIX'losetup' u ${dev_mount}
else
	losetup -d /dev/loop${dev_mount}
fi

cd tmp/limine/
make limine-install
cd ../../
./tmp/limine/limine-install foxos.img
