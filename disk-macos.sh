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

dev_mount=`hdiutil attach -nomount -noverify foxos.img | egrep -o '/dev/disk[0-9]+' | head -1`

echo "Mounted disk as ${dev_mount}"

$PREFIX'/bin/'$PROG_PREFIX'mkfs.vfat' -F 32 ${dev_mount}s1

mmd -i ${dev_mount}s1 ::/EFI
mmd -i ${dev_mount}s1 ::/EFI/BOOT
mmd -i ${dev_mount}s1 ::/EFI/FOXOS
mmd -i ${dev_mount}s1 ::/EFI/FOXOS/RES
mmd -i ${dev_mount}s1 ::/EFI/FOXOS/MODULES
mmd -i ${dev_mount}s1 ::/BIN

mcopy -i ${dev_mount}s1 tmp/limine/limine.sys ::
mcopy -i ${dev_mount}s1 tmp/limine/BOOTX64.EFI ::/EFI/BOOT
mcopy -i ${dev_mount}s1 limine.cfg ::
mcopy -i ${dev_mount}s1 startup.nsh ::
mcopy -i ${dev_mount}p1 dn.fox ::

mcopy -i ${dev_mount}s1 FoxOS-kernel/bin/*.elf ::/EFI/FOXOS
mcopy -i ${dev_mount}s1 FoxOS-kernel/bin/*.o ::/EFI/FOXOS/MODULES

mcopy -i ${dev_mount}s1 FoxOS-programs/bin/* ::/BIN

mcopy -i ${dev_mount}s1 resources/* ::/EFI/FOXOS/RES

hdiutil detach ${dev_mount}

cd tmp/limine/
make limine-install
cd ../../
./tmp/limine/limine-install foxos.img

dd if=/dev/zero of=foxos2.img bs=512 count=93750
mkfs.vfat -F 32 foxos2.img