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

dev_mount=`hdiutil attach -nomount -noverify foxos.img | egrep -o '/dev/disk[0-9]+' | head -1`

echo "Mounted disk as ${dev_mount}"

$PREFIX'/bin/'$PROG_PREFIX'mkfs.vfat' -F 32 ${dev_mount}s1

mcopy -s -i ${dev_mount}s1 disk_root/* ::

hdiutil detach ${dev_mount}

cd tmp/limine/
make limine-deploy
cd ../../
./tmp/limine/limine-deploy foxos.img

dd if=/dev/zero of=foxos2.img bs=512 count=93750
$PREFIX'/bin/'$PROG_PREFIX'mkfs.vfat' -F 32 foxos2.img