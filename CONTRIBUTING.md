# Contributing to FoxOS

When contributing to FoxOS, make sure that the changes you wish to make are in line with the project direction. If you are not sure about this, open an issue first, so we can discuss it.

For your first pull request, start with something small to get familiar with the project and its development processes.

## Language

FoxOS code needs to be commented in english and variable names need to be in snake_case or camelCase. Variables and functions should have self explanatory names in english. Indentation should be with tabs only.

## Coding Style

We prefer to use the following coding style:

```c++
int fat32_seek(vfs_mount*, file_t* file, long int offset, int whence) {
	FRESULT res;
	switch (whence) {
		case SEEK_SET:
			{
				res = f_lseek((FIL*)file->data, offset);
			}
			break;

		case SEEK_CUR:
			{
				res = f_lseek((FIL*)file->data, f_tell((FIL*)file->data) + offset);
			}
			break;

		case SEEK_END:
			{
				res = f_lseek((FIL*)file->data, f_size((FIL*)file->data) + offset);
			}
			break;

		default:
			return -1;
	}

	if (res != FR_OK) {
		return -1;
	}

	return 0;
}
```

## Documentation

We require you to write a good description of a function you write. This is especially important for functions witch are not internal to a class. Documentation strings need to be placed in the `docs.txt` file.

### Documentation in c++

The documentation header for c++ is `#<filepath (/ replaced with _)>:<function name>: doc string`  
Example:

```c++
void crash() {
	if(crashc == 100) {
		*((uint32_t*) 0xff00ff00ff00) = 0;
	} else {
		crashc++;
		crash();
	}
}
```

In docs.txt:

```txt
#core_main.cpp:crash: Test function to crash the kernel it is recursive to test the stack tracing.
```

The documentation for a function in a class or namespace is a bit different. The documentation header for c++ code in a class or namespace is `#<filepath (/ replaced with _)>:<class/namespace>::<function name>: doc string`
Example:

```c++
bool e1000Driver::detect_eeprom() {
	uint32_t val = 0;
	write_command(REG_EEPROM, 0x1);

	for(int i = 0; i < 1000 && !this->eerprom_exists; i++) {
		if(read_command(REG_EEPROM) & 0x10) {
			this->eerprom_exists = true;
		}
	}
	return this->eerprom_exists;
}
```

In docs.txt:

```txt
#devices_e1000_e1000.cpp:e1000_driver::detect_eeprom: Detects the eeprom of the e1000
```

### Documentation in assembly

In assembly you also need to supply a c/c++ function signature using the `;#<function name>-signature: <c/c++ function signature>`  
Example:

```asm
;# load_gdt-signature: extern "C" void load_gdt(gdt_descriptor_t* gdt_descriptor);

load_gdt:
	lgdt [rdi]
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	pop rdi
	mov rax, 0x08
	push rax
	push rdi

	retfq
```

Writing the doc strings works the same way as in a c++ file.

In docs.txt:

```txt
#core_gdt.asm:load_gdt: Loads the GDT
```

## Copyrights and licenses

FoxOS and all of it contents are licensed under the [MIT license](https://mit-license.org/). All the code is open source and you can use it as you wish. If you contribute to FoxOS, it will be licensed under the [MIT license](https://mit-license.org/).
