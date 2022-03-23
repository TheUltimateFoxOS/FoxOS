#include <elf/kernel_module.h>

#include <utils/log.h>

void init() {
	debugf("Hello from the example module!\n");
}

define_module("example_module", init, null_ptr_func, null_ptr_func);