#!/bin/bash

dd if=/dev/zero of=/root/foxos.img bs=512 count=93750

echo 'echo "o\ny\nn\n1\n\n\n0700\nw\ny\n" | gdisk /root/foxos.img' | sh

export PREFIX="/usr/local/foxos-x86_64_elf_gcc"

if [ "$1" != "" ]; then
	export PROG_PREFIX=$1
else
	export PROG_PREFIX="foxos-"
fi

dev_mount=`kpartx -a -v /root/foxos.img | egrep -o 'loop[0-9]+'`

echo Mounted disk as /dev/${dev_mount}

mkfs.vfat -F 32 /dev/mapper/${dev_mount}p1

mmd -i /dev/mapper/${dev_mount}p1 ::/EFI
mmd -i /dev/mapper/${dev_mount}p1 ::/EFI/BOOT
mmd -i /dev/mapper/${dev_mount}p1 ::/EFI/FOXOS
mmd -i /dev/mapper/${dev_mount}p1 ::/EFI/FOXOS/RES
mmd -i /dev/mapper/${dev_mount}p1 ::/EFI/FOXOS/MODULES
mmd -i /dev/mapper/${dev_mount}p1 ::/BIN

mcopy -i /dev/mapper/${dev_mount}p1 tmp/limine/limine.sys ::
mcopy -i /dev/mapper/${dev_mount}p1 tmp/limine/BOOTX64.EFI ::/EFI/BOOT
mcopy -i /dev/mapper/${dev_mount}p1 limine.cfg ::
mcopy -i /dev/mapper/${dev_mount}p1 startup.nsh ::
mcopy -i /dev/mapper/${dev_mount}p1 LICENSE ::
mcopy -i /dev/mapper/${dev_mount}p1 dn.fox ::
mcopy -i /dev/mapper/${dev_mount}p1 cfg.fox ::
mcopy -i /dev/mapper/${dev_mount}p1 start.fox ::

mcopy -i /dev/mapper/${dev_mount}p1 FoxOS-kernel/bin/*.elf ::/EFI/FOXOS
mcopy -i /dev/mapper/${dev_mount}p1 FoxOS-kernel/bin/*.o ::/EFI/FOXOS/MODULES

mcopy -i /dev/mapper/${dev_mount}p1 FoxOS-programs/bin/* ::/BIN

mcopy -i /dev/mapper/${dev_mount}p1 resources/* ::/EFI/FOXOS/RES

kpartx -a -d /dev/${dev_mount}
losetup -d /dev/${dev_mount}

cd tmp/limine/
make limine-install
cd ../../
./tmp/limine/limine-install /root/foxos.img

dd if=/dev/zero of=/root/foxos2.img bs=512 count=93750
mkfs.vfat -F 32 /root/foxos2.img

mv /root/foxos.img ./
mv /root/foxos2.img ./