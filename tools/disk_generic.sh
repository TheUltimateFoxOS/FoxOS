#!/bin/bash

function build_disk_structure {
	echo "Creating disk structure in $1..."

	mkdir -p $1/{FOXCFG,RES,BOOT,BOOT/MODULES,EFI,BIN,EFI/BOOT}

	cp disk_resources/limine.cfg $1/
	cp disk_resources/startup.nsh $1/
	cp LICENSE $1/
	cp disk_resources/dn.fox $1/FOXCFG
	cp disk_resources/cfg.fox $1/FOXCFG
	cp disk_resources/start.fox $1/FOXCFG

	cp FoxOS-kernel/bin/*.elf $1/BOOT/
	cp FoxOS-kernel/bin/*.o $1/BOOT/MODULES/

	cp FoxOS-programs/bin/* $1/BIN/
	cp disk_resources/resources/* $1/RES/

	cp tmp/limine/limine.sys $1
	cp tmp/limine/BOOTX64.EFI $1/EFI/BOOT

	echo "Done."
}

mkdir -p $1
build_disk_structure $1