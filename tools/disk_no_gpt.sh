#!/bin/bash

bash tools/disk_generic.sh disk_root

dd if=/dev/zero of=/root/foxos.img bs=512 count=193750 status=progress

mkfs.vfat -F 32 /root/foxos.img

mcopy -s -i /root/foxos.img disk_root/* ::

dd if=/dev/zero of=/root/foxos2.img bs=512 count=93750 status=progress
mkfs.vfat -F 32 /root/foxos2.img

echo Copying image files...
mv /root/foxos.img ./
mv /root/foxos2.img ./
