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
	$PREFIX'/bin/'$PROG_PREFIX'losetup' m
else
	losetup /dev/loop9 foxos.img
fi

echo Mounted disk as /dev/loop9

mkfs.vfat -F 32 /dev/loop9p1

mmd -i /dev/loop9p1 ::/EFI
mmd -i /dev/loop9p1 ::/EFI/BOOT
mmd -i /dev/loop9p1 ::/EFI/FOXOS

mcopy -i /dev/loop9p1 ./tmp/limine/limine.sys ::
mcopy -i /dev/loop9p1 ./tmp/limine/BOOTX64.EFI ::/EFI/BOOT
mcopy -i /dev/loop9p1 limine.cfg ::
mcopy -i /dev/loop9p1 startup.nsh ::
mcopy -i /dev/loop9p1 FoxOS-kernel/bin/foxkrnl.elf ::/EFI/FOXOS

mmd -i /dev/loop9p1 ::/BIN
mcopy -i /dev/loop9p1 FoxOS-programs/bin/test.elf ::/BIN

if [ -f $PREFIX'/bin/'$PROG_PREFIX'losetup' ]; then
	$PREFIX'/bin/'$PROG_PREFIX'losetup' u
else
	losetup -d /dev/loop9
fi

./tmp/limine/limine-install-linux-x86_64 foxos.img
