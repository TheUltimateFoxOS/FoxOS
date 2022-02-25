#pragma once

typedef struct keymap_t {
	char layout_normal[0xff];
	char layout_shift[0xff];
	char layout_alt[0xff];
} keymap_t;