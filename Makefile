QEMUFLAGS_RAW = -machine q35 -smp 4 -m 1G -cpu qemu64 -drive if=pflash,format=raw,unit=0,file="tmp/ovmf/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file="tmp/ovmf/OVMF_VARS-pure-efi.fd" -serial stdio -soundhw pcspk -netdev user,id=u1,hostfwd=tcp::9999-:9999 -device rtl8139,netdev=u1 -object filter-dump,id=f1,netdev=u1,file=dump.dat
QEMUFLAGS = $(QEMUFLAGS_RAW) -drive file=foxos.img -drive file=foxos2.img

QEMUFLAGS_BIOS_RAW = -machine q35 -smp 4 -m 1G -cpu qemu64 -serial stdio -soundhw pcspk -netdev user,id=u1,hostfwd=tcp::9999-:9999 -device rtl8139,netdev=u1 -object filter-dump,id=f1,netdev=u1,file=dump.dat
QEMUFLAGS_BIOS = $(QEMUFLAGS_BIOS_RAW) -drive file=foxos.img -drive file=foxos2.img

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

./tmp/ovmf:
	@echo "Downloading OVMF!"
	@mkdir -p ./tmp/ovmf
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_CODE-pure-efi.fd -o ./tmp/ovmf/OVMF_CODE-pure-efi.fd
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_VARS-pure-efi.fd -o ./tmp/ovmf/OVMF_VARS-pure-efi.fd

img: all ./tmp/limine
	sh tools/disk_linux.sh $(FOX_GCC_PATH)

mac-img: all ./tmp/limine
	sh tools/disk_macos.sh $(FOX_GCC_PATH)

docker-img: all ./tmp/limine
	sh tools/disk_docker.sh $(FOX_GCC_PATH)

no-gpt-img: all ./tmp/limine
	sh tools/disk_no_gpt.sh $(FOX_GCC_PATH)

vmdk: img
	qemu-img convert foxos.img -O vmdk foxos.vmdk

vdi: img
	qemu-img convert foxos.img -O vdi foxos.vdi

qcow2: img
	qemu-img convert foxos.img -O qcow2 foxos.qcow2

run: img ./tmp/ovmf
	qemu-system-x86_64 $(QEMUFLAGS)

run-dbg: img ./tmp/ovmf
	screen -dmS qemu qemu-system-x86_64 $(QEMUFLAGS) -s -S

run-vnc: img ./tmp/ovmf
	qemu-system-x86_64 $(QEMUFLAGS) -vnc :1

run-bios: img
	qemu-system-x86_64 $(QEMUFLAGS_BIOS)

run-dbg-bios: img
	screen -dmS qemu qemu-system-x86_64 $(QEMUFLAGS_BIOS) -s -S

run-vnc-bios: img
	qemu-system-x86_64 $(QEMUFLAGS_BIOS) -vnc :1

run-foxos2: ./tmp/ovmf
	qemu-system-x86_64 $(QEMUFLAGS_RAW) -drive file=foxos2.img

screenshot:
	echo "(make run-vnc  &>/dev/null & disown; sleep 45; vncsnapshot localhost:1 foxos.jpg; killall qemu-system-x86_64)" | bash

screenshot-bios:
	echo "(make run-vnc-bios  &>/dev/null & disown; sleep 45; vncsnapshot localhost:1 foxos.jpg; killall qemu-system-x86_64)" | bash

clean:
	make -C FoxOS-kernel clean
	make -C FoxOS-programs clean
	rm -rf tmp/ disk_root/
	rm foxos.img foxos.vmdk foxos.vdi foxos.qcow2

debug:
	deno run --allow-run tools/debug.js

usb: all ./tmp/limine
	@read -p "Enter path to usb >> " usb_path; \
	bash tools/disk_generic.sh $$usb_path

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
