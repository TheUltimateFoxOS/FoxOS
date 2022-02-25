OBJDIR = lib
BUILDDIR = bin

OUTPUT = keymap_tool.elf

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CPPSRC = $(call rwildcard,./,*.c)
OBJS = $(patsubst %.c, $(OBJDIR)/%_$(OUTPUT).o, $(CPPSRC))


CFLAGS = -Iinclude
LDFLAGS =

CC = gcc
ASM = nasm
LD = gcc

$(OUTPUT): $(OBJS)
	@echo LD $^
	@$(LD) $(LDFLAGS) -o $(BUILDDIR)/$@ $^

run: $(OUTPUT)
	@echo "Running $(BUILDDIR)/$(OUTPUT)"
	@$(BUILDDIR)/$(OUTPUT) $(ARGS)

$(OBJDIR)/%_$(OUTPUT).o: %.c
	@echo "CC $^ -> $@"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c -o $@ $^

.PHONY: build
