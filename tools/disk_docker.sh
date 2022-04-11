#!/bin/bash

bash tools/disk_generic.sh disk_root

dd if=/dev/zero of=/tmp/foxos.img bs=512 count=93750

echo 'echo "o\ny\nn\n1\n\n\n0700\nw\ny\n" | gdisk /tmp/foxos.img' | sh

export PREFIX="/usr/local/foxos-x86_64_elf_gcc"

if [ "$1" != "" ]; then
	export PROG_PREFIX=$1
else
	export PROG_PREFIX="foxos-"
fi

dev_mount=`kpartx -a -v /tmp/foxos.img | egrep -o 'loop[0-9]+'`

echo Mounted disk as /dev/${dev_mount}

mkfs.vfat -F 32 /dev/mapper/${dev_mount}p1

mcopy -s -i /dev/mapper/${dev_mount}p1 disk_root/* ::

kpartx -a -d /dev/${dev_mount}
losetup -d /dev/${dev_mount}

cd tmp/limine/
make limine-deploy
cd ../../
./tmp/limine/limine-deploy /tmp/foxos.img

dd if=/dev/zero of=/tmp/foxos2.img bs=512 count=93750
mkfs.vfat -F 32 /tmp/foxos2.img

echo Copying image files...
mv /tmp/foxos.img ./
mv /tmp/foxos2.img ./
