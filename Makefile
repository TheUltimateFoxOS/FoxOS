QEMUFLAGS = -machine q35 -smp 4 -drive file=foxos.img -m 1G -cpu qemu64 -drive if=pflash,format=raw,unit=0,file="ovmf/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file="ovmf/OVMF_VARS-pure-efi.fd" -serial stdio -soundhw pcspk -netdev user,id=u1,hostfwd=tcp::9999-:9999 -device pcnet,netdev=u1 -object filter-dump,id=f1,netdev=u1,file=dump.dat
QEMUFLAGS_BIOS = -machine q35 -smp 4 -drive file=foxos.img -m 1G -cpu qemu64 -serial stdio -soundhw pcspk -netdev user,id=u1,hostfwd=tcp::9999-:9999 -device e1000,netdev=u1 -object filter-dump,id=f1,netdev=u1,file=dump.dat

FOX_GCC_PATH=/usr/local/foxos-x86_64_elf_gcc

all:
	@make -C FoxOS-kernel setup -i TOOLCHAIN_BASE=$(FOX_GCC_PATH)
	make -C FoxOS-kernel TOOLCHAIN_BASE=$(FOX_GCC_PATH)
	@make -C FoxOS-programs setup -i TOOLCHAIN_BASE=$(FOX_GCC_PATH)
	make -C FoxOS-programs TOOLCHAIN_BASE=$(FOX_GCC_PATH)

./tmp/limine:
	@echo "Downloading latest limine release!"
	@mkdir -p ./tmp/limine
	@git clone https://github.com/limine-bootloader/limine.git --branch=latest-binary ./tmp/limine

img: all ./tmp/limine
	sh disk.sh $(FOX_GCC_PATH)

mac-img: all ./tmp/limine
	sh mac-disk.sh $(FOX_GCC_PATH)

vmdk: img
	qemu-img convert foxos.img -O vmdk foxos.vmdk

vdi: img
	qemu-img convert foxos.img -O vdi foxos.vdi

qcow2: img
	qemu-img convert foxos.img -O qcow2 foxos.qcow2

run: img
	qemu-system-x86_64 $(QEMUFLAGS)

run-dbg: img
	screen -dmS qemu qemu-system-x86_64 $(QEMUFLAGS) -s -S

run-vnc: img
	qemu-system-x86_64 $(QEMUFLAGS) -vnc :1

run-bios: img
	qemu-system-x86_64 $(QEMUFLAGS_BIOS)

run-dbg-bios: img
	screen -dmS qemu qemu-system-x86_64 $(QEMUFLAGS_BIOS) -s -S

run-vnc-bios: img
	qemu-system-x86_64 $(QEMUFLAGS_BIOS) -vnc :1

screenshot:
	echo "(make run-vnc  &>/dev/null & disown; sleep 45; vncsnapshot localhost:1 foxos.jpg; killall qemu-system-x86_64)" | bash

screenshot-bios:
	echo "(make run-vnc-bios  &>/dev/null & disown; sleep 45; vncsnapshot localhost:1 foxos.jpg; killall qemu-system-x86_64)" | bash

clean:
	make -C FoxOS-kernel clean
	make -C FoxOS-programs clean
	rm foxos.img foxos.vmdk foxos.vdi foxos.qcow2
	rm -rf tmp/

debug:
	deno run --allow-run debug.js

usb: all ./tmp/limine
	@read -p "Enter path to usb >> " usb_path; \
	mkdir -p $$usb_path/EFI/BOOT; \
	mkdir -p $$usb_path/EFI/FOXOS; \
	mkdir -p $$usb_path/BIN; \
	cp ./tmp/limine/BOOTX64.EFI $$usb_path/EFI/BOOT/BOOTX64.EFI; \
	cp FoxOS-kernel/bin/* $$usb_path/EFI/FOXOS/.; \
	cp limine.cfg $$usb_path/limine.cfg; \
	cp startup.nsh $$usb_path/startup.nsh; \
	cp FoxOS-programs/bin/test.elf $$usb_path/BIN/.;

losetup:
	gcc -xc -o losetup.elf losetup.c
	chmod u+s losetup.elf
	chmod g+s losetup.elf

	mv losetup.elf $(FOX_GCC_PATH)/bin/foxos-losetup -v

FOXOS_VM_NAME = foxos-runner

vbox-setup:
	vboxmanage createvm --name $(FOXOS_VM_NAME)
	vboxmanage registervm /home/$(USER)/VirtualBox\ VMs/$(FOXOS_VM_NAME)/$(FOXOS_VM_NAME).vbox

	vboxmanage modifyvm $(FOXOS_VM_NAME) --longmode on --ioapic on --nic1 nat --nictype1 Am79C973 --memory 1024 --uart1 0x3f8 4 --uartmode1 file /tmp/vbox.log --nictrace1 on --nictracefile1 /tmp/vbox.pcap

	vboxmanage storagectl $(FOXOS_VM_NAME) --name "IDE Controller" --add ide --controller PIIX4

	vboxmanage storageattach $(FOXOS_VM_NAME) --storagectl "IDE Controller" --port 1 --device 0 --type hdd --medium `pwd`/foxos.qcow2

run-vbox: qcow2
	vboxmanage startvm --putenv VBOX_GUI_DBG_ENABLED=true $(FOXOS_VM_NAME)
	watch -n 0.1 tail /tmp/vbox.log -n $(shell echo $(shell tput lines) - 1 | bc)
