OBJDIR = ./lib
BUILDDIR = ./bin

SDK_ROOT = /opt/foxos_sdk

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CPPSRC = $(call rwildcard,./,*.cpp)
CSRC = $(call rwildcard,./,*.c)
ASMSRC = $(call rwildcard,./,*.asm)
OBJS = $(patsubst %.cpp, $(OBJDIR)/$(MODULE_NAME)/%.o, $(CPPSRC))
OBJS += $(patsubst %.c, $(OBJDIR)/$(MODULE_NAME)/%.o, $(CSRC))
OBJS += $(patsubst %.asm, $(OBJDIR)/$(MODULE_NAME)/%_asm.o, $(ASMSRC))

TOOLCHAIN_BASE = /usr/local/foxos-x86_64_elf_gcc

ifeq (,$(wildcard $(TOOLCHAIN_BASE)/bin/foxos-gcc))
	CC = gcc
else
	CC = $(TOOLCHAIN_BASE)/bin/foxos-gcc
endif

ifeq (,$(wildcard $(TOOLCHAIN_BASE)/bin/foxos-nasm))
	ASM = nasm
else
	ASM = $(TOOLCHAIN_BASE)/bin/foxos-nasm
endif

ifeq (,$(wildcard $(TOOLCHAIN_BASE)/bin/foxos-gcc))
	LD = ld
else
	LD = $(TOOLCHAIN_BASE)/bin/foxos-ld
endif

LDFLAGS = -r
CFLAGS = -I$(SDK_ROOT)/headers/kernel -mcmodel=large -ffreestanding -fshort-wchar -mno-red-zone -Iinclude -fno-exceptions -fno-exceptions -fno-stack-protector -mno-sse -mno-sse2 -mno-3dnow -mno-80387 -g
CPPFLAGS = -fno-use-cxa-atexit -fno-rtti $(CFLAGS)
ASMFLAGS = -f elf64

CFLAGS += $(USER_CFLAGS)
ASMFLAGS += $(USER_ASMFLAGS)

module: $(OBJS)
	@mkdir -p $(BUILDDIR)
	@echo LD $^
	@$(LD) $(LDFLAGS) -o $(BUILDDIR)/$(MODULE_NAME) $^

	@echo "\n\nCompiled using asm: $(ASM), cc: $(CC), ld: $(LD)\n\n"

$(OBJDIR)/$(MODULE_NAME)/%.o: %.cpp
	@echo "CPP $^ -> $@"
	@mkdir -p $(@D)
	@$(CC) $(CPPFLAGS) -c -o $@ $^

$(OBJDIR)/$(MODULE_NAME)/%.o: %.c
	@echo "CC $^ -> $@"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c -o $@ $^

$(OBJDIR)/$(MODULE_NAME)/%_asm.o: %.asm
	@echo "ASM $^ -> $@"
	@mkdir -p $(@D)
	@$(ASM) $(ASMFLAGS) -o $@ $^

DISK = .sdk/foxos.img

QEMUFLAGS_RAW = -machine q35 -smp 1 -m 1G -cpu qemu64 -drive if=pflash,format=raw,unit=0,file=".sdk/ovmf/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file=".sdk/ovmf/OVMF_VARS-pure-efi.fd" -serial stdio -soundhw pcspk -netdev user,id=u1,hostfwd=tcp::9999-:9999 -device rtl8139,netdev=u1 -object filter-dump,id=f1,netdev=u1,file=.sdk/dump.dat
QEMUFLAGS = $(QEMUFLAGS_RAW) -drive file=$(DISK)

image: module
	rm -rf .sdk/disk
	mkdir -p .sdk/disk
	cp -r $(SDK_ROOT)/disk/* .sdk/disk

	cp $(BUILDDIR)/$(MODULE_NAME) .sdk/disk/BOOT/MODULES

	$(SDK_ROOT)/bin/saf-make .sdk/disk/BOOT/MODULES .sdk/disk/BOOT/initrd.saf

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