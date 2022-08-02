SDK_ROOT = /opt/foxos_sdk
DISK = .sdk/foxos.img

QEMUFLAGS_RAW = -machine q35 -smp 1 -m 1G -cpu qemu64 -drive if=pflash,format=raw,unit=0,file=".sdk/ovmf/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file=".sdk/ovmf/OVMF_VARS-pure-efi.fd" -serial stdio -soundhw pcspk -netdev user,id=u1,hostfwd=tcp::9999-:9999 -device rtl8139,netdev=u1 -object filter-dump,id=f1,netdev=u1,file=.sdk/dump.dat
QEMUFLAGS = $(QEMUFLAGS_RAW) -drive file=$(DISK)

image:
	rm -rf .sdk/disk
	mkdir -p .sdk/disk
	cp -r $(SDK_ROOT)/disk/* .sdk/disk

	cp -rv $(FOLDER) .sdk/disk/

	dd if=/dev/zero of=$(DISK) bs=512 count=193750 status=progress
	mkfs.vfat -F 32 $(DISK)
	mcopy -s -i $(DISK) .sdk/disk/* ::

./.sdk/ovmf:
	@echo "Downloading OVMF!"
	@mkdir -p ./.sdk/ovmf
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_CODE-pure-efi.fd -o ./.sdk/ovmf/OVMF_CODE-pure-efi.fd
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_VARS-pure-efi.fd -o ./.sdk/ovmf/OVMF_VARS-pure-efi.fd


run: ./.sdk/ovmf
	qemu-system-x86_64 $(QEMUFLAGS)