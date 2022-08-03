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
	@git clone https://github.com/limine-bootloader/limine.git --branch=v3.0-branch-binary ./tmp/limine
	@git -C ./tmp/limine checkout 9761d387a73a1d8ba517421ad3c7c6e6cda49626

./tmp/ovmf:
	@echo "Downloading OVMF!"
	@mkdir -p ./tmp/ovmf
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_CODE-pure-efi.fd -o ./tmp/ovmf/OVMF_CODE-pure-efi.fd
	@curl -L https://github.com/TheUltimateFoxOS/FoxOS/releases/download/ovmf/OVMF_VARS-pure-efi.fd -o ./tmp/ovmf/OVMF_VARS-pure-efi.fd

./tmp/saf:
	@echo "Downloading saf"
	@mkdir -p ./tmp/saf
	@git clone https://github.com/chocabloc/saf.git --depth=1 ./tmp/saf

img: all ./tmp/limine ./tmp/saf
	sh tools/disk_linux.sh $(FOX_GCC_PATH)

mac-img: all ./tmp/limine ./tmp/saf
	sh tools/disk_macos.sh $(FOX_GCC_PATH)

docker-img: all ./tmp/limine ./tmp/saf
	sh tools/disk_docker.sh $(FOX_GCC_PATH)

no-gpt-img: all ./tmp/limine ./tmp/saf
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
	rm -rf disk_root/
	rm foxos.img foxos.vmdk foxos.vdi foxos.qcow2

	rm FoxOS-programs/limine_install/include/limine-hdd.h

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

example_images:
	curl https://cdn.discordapp.com/attachments/805055812376330241/959117829704142858/unknown.png -L -o ./tmp/rickroll.png
	curl https://cdn.discordapp.com/attachments/805055812376330241/959117830010322964/unknown.png -L -o ./tmp/trollface.png
	curl https://cdn.discordapp.com/attachments/805055812376330241/959117830345855036/unknown.png -L -o ./tmp/buttercat.png
	curl https://cdn.discordapp.com/attachments/805055812376330241/959117830723346472/foxuwu.jpg -L -o ./tmp/fox.jpg
	curl https://cdn.discordapp.com/attachments/805055812376330241/959125477635809400/nagatoro.png -L -o ./tmp/nagatoro.png

	python3 tools/img2fpic.py ./tmp/rickroll.png ./disk_resources/examples/rickroll.fpic
	python3 tools/img2fpic.py ./tmp/trollface.png ./disk_resources/examples/trollface.fpic
	python3 tools/img2fpic.py ./tmp/buttercat.png ./disk_resources/examples/buttercat.fpic
	python3 tools/img2fpic.py ./tmp/fox.jpg ./disk_resources/examples/fox.fpic
	python3 tools/img2fpic.py ./tmp/nagatoro.png ./disk_resources/examples/nagatoro.fpic

	curl https://cdn.discordapp.com/attachments/805055812376330241/959476065829519380/test3.bmp -L -o ./disk_resources/examples/furry.bmp

example_music:
	curl https://cdn.discordapp.com/attachments/805055812376330241/959832841359880223/erika.txt -L -o ./tmp/erika.txt
	curl https://cdn.discordapp.com/attachments/805055812376330241/959832841548611615/katyusha.txt -L -o ./tmp/katyusha.txt
	curl https://cdn.discordapp.com/attachments/805055812376330241/959832841737363517/rickroll.txt -L -o ./tmp/rickroll.txt
	curl https://cdn.discordapp.com/attachments/805055812376330241/959852424330375193/amogus.txt -L -o ./tmp/amogus.txt
	curl https://cdn.discordapp.com/attachments/805055812376330241/959852424523288646/shinzou_wo_sasageyo.txt -L -o ./tmp/shinzou_wo_sasageyo.txt
	curl https://cdn.discordapp.com/attachments/805055812376330241/959852424779149452/this_game.txt -L -o ./tmp/this_game.txt
	curl https://cdn.discordapp.com/attachments/805055812376330241/959852424997249114/westerwald.txt -L -o ./tmp/westerwald.txt

	deno run -A tools/cord_parse.js ./tmp/erika.txt ./disk_resources/examples/erika.fm
	deno run -A tools/cord_parse.js ./tmp/katyusha.txt ./disk_resources/examples/katyusha.fm
	deno run -A tools/cord_parse.js ./tmp/rickroll.txt ./disk_resources/examples/rickroll.fm
	deno run -A tools/cord_parse.js ./tmp/amogus.txt ./disk_resources/examples/amogus.fm
	deno run -A tools/cord_parse.js ./tmp/shinzou_wo_sasageyo.txt ./disk_resources/examples/shinzou_wo_sasageyo.fm
	deno run -A tools/cord_parse.js ./tmp/this_game.txt ./disk_resources/examples/this_game.fm
	deno run -A tools/cord_parse.js ./tmp/westerwald.txt ./disk_resources/examples/westerwald.fm

examples:
	make example_images
	make example_music

build_headers:
	mkdir -p ./tmp/headers
	cp -r FoxOS-programs/libc/include/ ./tmp/headers/libc/
	cp -r FoxOS-programs/libfoxos/include/ ./tmp/headers/libfoxos/
	cp -r FoxOS-kernel/core/include/ ./tmp/headers/kernel/

sdk: all build_headers ./tmp/saf ./tmp/limine
	mkdir -p ./tmp/sdk
	cp -r ./tmp/headers ./tmp/sdk/
	bash tools/disk_generic.sh ./tmp/sdk/disk

	mkdir -p ./tmp/sdk/bin
	cp -r ./tmp/saf/saf-make ./tmp/sdk/bin/saf-make

	mkdir -p ./tmp/sdk/lib
	cp -r ./FoxOS-programs/bin/libc.a ./tmp/sdk/lib/
	cp -r ./FoxOS-programs/bin/libc.a.o ./tmp/sdk/lib/
	cp -r ./FoxOS-programs/bin/libfoxos.a ./tmp/sdk/lib/
	cp -r ./FoxOS-programs/bin/libfoxos.a.o ./tmp/sdk/lib/

	cp -r sdk/* ./tmp/sdk/

install_sdk: sdk
	sudo mkdir -p /opt/foxos_sdk
	sudo cp -r ./tmp/sdk/* /opt/foxos_sdk/