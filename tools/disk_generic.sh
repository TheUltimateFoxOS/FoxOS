#!/bin/bash

function build_disk_structure {
	echo "Creating disk structure in $1..."

	rm -rf $1

	mkdir -p $1/{FOXCFG,RES,BOOT,BOOT/MODULES,EFI,BIN,EFI/BOOT,EXAMPLES}

	cp disk_resources/limine.cfg $1/
	cp disk_resources/startup.nsh $1/
	cp LICENSE $1/
	cp disk_resources/dn.fox $1/FOXCFG
	cp disk_resources/init.cfg $1/FOXCFG
	cp disk_resources/start.fox $1/FOXCFG

	mkdir -p $1/FOXCFG/foxde

	cp disk_resources/foxde-bg.bmp $1/FOXCFG/foxde/bg.bmp -v
	cp disk_resources/foxde.cfg $1/FOXCFG/foxde/config.cfg -v
	cp disk_resources/icons_src/*.bmp $1/FOXCFG/foxde/. -v

	cp FoxOS-kernel/bin/*.elf $1/BOOT/
	cp FoxOS-kernel/bin/*.o $1/BOOT/MODULES/

	cp FoxOS-programs/bin/* $1/BIN/
	cp disk_resources/resources/* $1/RES/
	cp disk_resources/examples/* $1/EXAMPLES/

	cp tmp/limine/limine.sys $1
	cp tmp/limine/BOOTX64.EFI $1/EFI/BOOT

	(
		cd tmp/saf
		make
	)

	./tmp/saf/saf-make $1 initrd_full.saf
	./tmp/saf/saf-make $1/BOOT/MODULES initrd.saf

	mv initrd_full.saf $1/BOOT/
	mv initrd.saf $1/BOOT/

	echo "Done."
}

mkdir -p $1
build_disk_structure $1