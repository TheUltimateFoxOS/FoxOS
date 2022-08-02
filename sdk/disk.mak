image:
	rm -rf .sdk/disk
	mkdir -p .sdk/disk
	cp -r $(SDK_ROOT)/disk/* .sdk/disk

	cp -rv $(FOLDER) .sdk/disk/

	dd if=/dev/zero of=$(DISK) bs=512 count=193750 status=progress
	mkfs.vfat -F 32 $(DISK)
	mcopy -s -i $(DISK) .sdk/disk/* ::
