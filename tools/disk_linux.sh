#!/bin/bash

bash tools/disk_generic.sh disk_root

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

mcopy -s -i /dev/loop${dev_mount}p1 disk_root/* ::

if [ -f $PREFIX'/bin/'$PROG_PREFIX'losetup' ]; then
	$PREFIX'/bin/'$PROG_PREFIX'losetup' u ${dev_mount}
else
	losetup -d /dev/loop${dev_mount}
fi

cd tmp/limine/
make limine-deploy
cd ../../
./tmp/limine/limine-deploy foxos.img


dd if=/dev/zero of=foxos2.img bs=512 count=93750
mkfs.vfat -F 32 foxos2.img