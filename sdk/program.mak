OBJDIR = ./lib
BUILDDIR = ./bin

SDK_ROOT = /opt/foxos_sdk

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CSRC = $(call rwildcard,./,*.c)
CPPSRC = $(call rwildcard,./,*.cpp)

OBJS = $(patsubst %.c, $(OBJDIR)/%_$(PROGRAM_NAME).o, $(CSRC)) $(C_OBJS)
OBJS += $(patsubst %.cpp, $(OBJDIR)/%_$(PROGRAM_NAME).o, $(CPPSRC)) $(CPP_OBJS)

TOOLCHAIN_BASE = /usr/local/foxos-x86_64_elf_gcc

CFLAGS = -O2 -mno-red-zone -ffreestanding -fno-stack-protector -fpic -g -I$(SDK_ROOT)/headers/libc -I$(SDK_ROOT)/headers/libfoxos -I$(SDK_ROOT)/headers/libtinf -Iinclude  -fdata-sections -ffunction-sections
CPPFLAGS = -fno-use-cxa-atexit -fno-rtti $(CFLAGS) -fno-exceptions
LDFLAGS = -pic $(SDK_ROOT)/lib/libc.a.o $(SDK_ROOT)/lib/libfoxos.a.o $(SDK_ROOT)/lib/libtinf.a.o --gc-sections

CFLAGS += $(USER_CFLAGS)
CPPFLAGS += $(USER_CPPFLAGS)

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

program: $(OBJS)
	@mkdir -p $(BUILDDIR)
	@echo LD $^
	@$(LD) $(LDFLAGS) -o $(BUILDDIR)/$(PROGRAM_NAME) $^

$(OBJDIR)/%_$(PROGRAM_NAME).o: %.c
	@echo "CC $^ -> $@"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c -o $@ $^

$(OBJDIR)/%_$(PROGRAM_NAME).o: %.cpp
	@echo "CC $^ -> $@"
	@mkdir -p $(@D)
	@$(CC) $(CPPFLAGS) -c -o $@ $^

DISK = .sdk/foxos.img

QEMUFLAGS_RAW = -machine q35 -smp 1 -m 1G -cpu qemu64 -drive if=pflash,format=raw,unit=0,file=".sdk/ovmf/OVMF_CODE-pure-efi.fd",readonly=on -drive if=pflash,format=raw,unit=1,file=".sdk/ovmf/OVMF_VARS-pure-efi.fd" -serial stdio -soundhw pcspk -netdev user,id=u1,hostfwd=tcp::9999-:9999 -device rtl8139,netdev=u1 -object filter-dump,id=f1,netdev=u1,file=.sdk/dump.dat
QEMUFLAGS = $(QEMUFLAGS_RAW) -drive file=$(DISK)

image: program
	rm -rf .sdk/disk
	mkdir -p .sdk/disk
	cp -r $(SDK_ROOT)/disk/* .sdk/disk

	cp $(BUILDDIR)/$(PROGRAM_NAME) .sdk/disk/BIN

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