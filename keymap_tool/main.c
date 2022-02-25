#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <keyboard_layout.h>
#include <ps2_layout.h>

typedef char (*layout_func)(uint8_t key, bool l_alt, bool r_alt, bool l_ctrl, bool r_ctrl, bool l_shift, bool r_shift, bool caps_lock);

keymap_t from_layout_func(layout_func func) {
	keymap_t keymap;
	for (uint8_t i = 0; i < 0xff; i++) {
		keymap.layout_normal[i] = func(i, false, false, false, false, false, false, false);
	}

	for (uint8_t i = 0; i < 0xff; i++) {
		keymap.layout_alt[i] = func(i, true, false, false, false, false, false, false);
	}

	for (uint8_t i = 0; i < 0xff; i++) {
		keymap.layout_shift[i] = func(i, false, false, false, false, true, false, false);
	}

	return keymap;
}

keymap_t from_file(char* path) {
	FILE* f = fopen(path, "r");
	if (f == NULL) {
		printf("Error: Could not open file %s (you are working on a new empty keymap now)\n", path);
		keymap_t keymap;
		memset(&keymap, 0, sizeof(keymap));
		return keymap;
	}

	keymap_t keymap;
	if (fread(&keymap, sizeof(keymap_t), 1, f) != 1) {
		printf("Error: Could not read keymap from file %s\n", path);
		abort();
	}

	fclose(f);

	return keymap;
}

void save_file(char* path, keymap_t keymap) {
	FILE* f = fopen(path, "w");
	if (f == NULL) {
		printf("Error: Could not open file %s\n", path);
		abort();
	}

	if (fwrite(&keymap, sizeof(keymap_t), 1, f) != 1) {
		printf("Error: Could not write keymap to file %s\n", path);
		abort();
	}

	fclose(f);
}

int parse_number(char* input) {
	bool hex = false;
	bool bin = false;
	bool dec = false;

	int start_offset = 0;

	if (input[0] == '0') {
		if (input[1] == 'x') {
			hex = true;
			start_offset = 2;
		} else if (input[1] == 'b') {
			bin = true;
			start_offset = 2;
		} else {
			dec = true;
		}
	} else {
		dec = true;
	}

	int number_system_base = 0;

	if (hex) {
		number_system_base = 16;
	} else if (bin) {
		number_system_base = 2;
	} else {
		number_system_base = 10;
	}

	int _number = 0;
	int idx = start_offset;

	while (input[idx] != '\0') {
		if (input[idx] >= '0' && input[idx] <= '9') {
			_number = _number * number_system_base + (input[idx] - '0');
		} else if (input[idx] >= 'a' && input[idx] <= 'f') {
			_number = _number * number_system_base + (input[idx] - 'a' + 10);
		} else if (input[idx] >= 'A' && input[idx] <= 'F') {
			_number = _number * number_system_base + (input[idx] - 'A' + 10);
		} else {
			break;
		}

		idx++;
	}

	return _number;
}

int main(int argc, char* argv[]) {
	bool normal_mode = false;
	bool alt_mode = false;
	bool shift_mode = false;
	bool convert_mode = false;

	char* file = NULL;

	int idx = 1;
	while (idx < argc) {
		if (strcmp(argv[idx], "-n") == 0) {
			normal_mode = true;
		} else if (strcmp(argv[idx], "-s") == 0) {
			shift_mode = true;
		} else if (strcmp(argv[idx], "-a") == 0) {
			alt_mode = true;
		} else if (strcmp(argv[idx], "-c") == 0) {
			convert_mode = true;
		} else if (strcmp(argv[idx], "-h") == 0) {
			printf("Usage: %s [-n] [-s] [-a] [-c] <file>\n", argv[0]);
			exit(0);
		} else {
			file = argv[idx];
		}

		idx++;
	}

	if (convert_mode) {
		save_file("de.fmp", from_layout_func(keymap_de));
		save_file("fr.fmp", from_layout_func(keymap_fr));
		save_file("us.fmp", from_layout_func(keymap_us));
		return 0;
	}

	if (!normal_mode && !alt_mode && !shift_mode) {
		printf("Error: No mode specified\n");
		abort();
	}

	if (file == NULL) {
		printf("Error: No file specified\n");
		abort();
	}

	keymap_t keymap = from_file(file);

	while (true) {
		char input[512] = { 0 };
		printf("%s", "index of char to edit or exit or list > ");
		fgets(input, sizeof(input), stdin);

		if (strcmp(input, "exit\n") == 0) {
			break;
		}

		if (strcmp(input, "list\n") == 0) {
			for (int i = 0; i < 0xff; i++) {
				if (normal_mode) {
					printf("%d: %c (%d)\n", i, keymap.layout_normal[i], keymap.layout_normal[i]);
				}
				if (shift_mode) {
					printf("%d: %c (%d)\n", i, keymap.layout_shift[i], keymap.layout_shift[i]);
				}
				if (alt_mode) {
					printf("%d: %c (%d)\n", i, keymap.layout_alt[i], keymap.layout_alt[i]);
				}
			}
			continue;
		}

		int index = parse_number(input);
		if (index < 0 || index >= 0xff) {
			printf("Error: Index out of bounds\n");
			continue;
		}

		printf("%s", "new char > ");
		fgets(input, sizeof(input), stdin);

		if (input[0] == '\\' && input[1] == 'd') {
			input[0] = parse_number(input + 2);
		}

		printf("set %d to %c\n", index, input[0]);

		if (normal_mode) {
			keymap.layout_normal[index] = input[0];
		} else if (alt_mode) {
			keymap.layout_shift[index] = input[0];
		} else if (shift_mode) {
			keymap.layout_shift[index] = input[0];
		}
	}


	save_file(file, keymap);

	printf("Successfully wrote keymap to file %s\n", file);
}