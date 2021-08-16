dd if=/dev/zero of=foxos.img bs=512 count=93750

echo "o\ny\nn\n1\n\n\n0700\nw\ny\n" | gdisk foxos.img

disk_mount_path=$(losetup -Pf --show foxos.img)

echo Mounted disk as $disk_mount_path

mkfs.vfat -F 32 $disk_mount_path'p1'

mmd -i $disk_mount_path'p1' ::/EFI
mmd -i $disk_mount_path'p1' ::/EFI/BOOT
mmd -i $disk_mount_path'p1' ::/EFI/FOXOS

mcopy -i $disk_mount_path'p1' ./tmp/limine/limine.sys ::
mcopy -i $disk_mount_path'p1' ./tmp/limine/BOOTX64.EFI ::/EFI/BOOT
mcopy -i $disk_mount_path'p1' limine.cfg ::
mcopy -i $disk_mount_path'p1' startup.nsh ::
mcopy -i $disk_mount_path'p1' FoxOS-kernel/bin/foxkrnl.elf ::/EFI/FOXOS

mmd -i $disk_mount_path'p1' ::/BIN
mcopy -i $disk_mount_path'p1' FoxOS-programs/bin/test.elf ::/BIN

losetup -d $disk_mount_path

./tmp/limine/limine-install-linux-x86_64 foxos.img