#!/bin/bash

bash tools/disk_generic.sh disk_root

dd if=/dev/zero of=foxos.img bs=512 count=93750

mkfs.vfat -F 32 foxos.img

mcopy -s -i foxos.img disk_root/* ::

dd if=/dev/zero of=foxos2.img bs=512 count=93750
mkfs.vfat -F 32 foxos2.img