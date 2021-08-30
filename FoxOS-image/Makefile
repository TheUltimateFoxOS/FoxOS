OBJDIR = lib
BUILDDIR = bin

OUTPUT = foxos-image.elf

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CPPSRC = $(call rwildcard,./,*.cpp)
OBJS = $(patsubst %.cpp, $(OBJDIR)/%_$(OUTPUT).o, $(CPPSRC))


CFLAGS = -g -Iinclude -DDEBUG
LDFLAGS = 

CC = g++
LD = g++

$(OUTPUT): $(OBJS)
	@mkdir -p $(BUILDDIR)
	@echo LD $^
	@$(LD) $(LDFLAGS) -o $(BUILDDIR)/$@ $^

debug: $(OUTPUT)
	@echo gdb $(BUILDDIR)/$(OUTPUT)
	@gdb $(BUILDDIR)/$(OUTPUT) -ex "set arg foxos.img disk.json" -ex "break main" -ex "run" -ex "tui enable"

run: $(OUTPUT)
	dd if=/dev/zero of=foxos.img bs=512 count=93750

	echo 'echo "o\ny\nn\n1\n\n\n0700\nw\ny\n" | gdisk foxos.img' | sh
	
	@echo ./$(BUILDDIR)/$(OUTPUT)
	@./$(BUILDDIR)/$(OUTPUT) foxos.img disk.json

$(OBJDIR)/%_$(OUTPUT).o: %.cpp
	@echo "CC $^ -> $@"
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) -c -o $@ $^

.PHONY: build