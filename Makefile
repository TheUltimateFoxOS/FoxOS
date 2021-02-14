all:
	make -C FoxOS-bootloader
	make -C FoxOS-bootloader bootloader
	make -C FoxOS-kernel setup -i
	make -C FoxOS-kernel

img: all
	dd if=/dev/zero of=foxos.img bs=512 count=93750
	mformat -i foxos.img -f 1440 ::
	mmd -i foxos.img ::/EFI
	mmd -i foxos.img ::/EFI/BOOT
	mcopy -i foxos.img FoxOS-bootloader/x86_64/bootloader/main.efi ::/EFI/BOOT
	mcopy -i foxos.img startup.nsh ::
	mcopy -i foxos.img FoxOS-kernel/bin/foxkrnl.elf ::
	#mcopy -i foxos.img $(BUILDDIR)/zap-light16.psf ::
	
run: img
	qemu-system-x86_64 -drive file=foxos.img -m 256M -cpu qemu64 -drive if=pflash,format=raw,unit=0,file="ovmf/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file="ovmf/OVMF_VARS-pure-efi.fd" -net none

clean:
	make -C FoxOS-kernel clean
	make -C FoxOS-bootloader clean
	rm foxos.img
