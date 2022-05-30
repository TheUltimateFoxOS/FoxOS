#!/bin/bash

bash tools/disk_generic.sh disk_root

tmp_dir=`mktemp -d`
dd if=/dev/zero of=${tmp_dir}/foxos.img bs=512 count=193750

echo "echo \"o\ny\nn\n1\n\n\n0700\nw\ny\n\" | gdisk ${tmp_dir}/foxos.img" | sh

dev_mount=`kpartx -a -v ${tmp_dir}/foxos.img | egrep -o 'loop[0-9]+'`

echo Mounted disk as /dev/${dev_mount}

mkfs.vfat -F 32 /dev/mapper/${dev_mount}p1

mcopy -s -i /dev/mapper/${dev_mount}p1 disk_root/* ::

kpartx -a -d /dev/${dev_mount}
losetup -d /dev/${dev_mount}

cd tmp/limine/
make limine-deploy
cd ../../
./tmp/limine/limine-deploy ${tmp_dir}/foxos.img

dd if=/dev/zero of=${tmp_dir}/foxos2.img bs=512 count=93750
mkfs.vfat -F 32 ${tmp_dir}/foxos2.img

echo Copying image files...
mv ${tmp_dir}/foxos.img ./
mv ${tmp_dir}/foxos2.img ./
rm -rf ${tmp_dir}
