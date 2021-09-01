#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>

bool check_args(int argc, char **argv) {
	if (argc == 3) {

		if (strlen(argv[2]) > 8) {
			printf("Usage: %s <m/u/f> <id>\n", argv[0]);
			printf("id must be 8 characters or less\n");
			return false;
		}
		return true;
	} else {
		printf("Usage: %s <m/u/f> <id>\n", argv[0]);
		return false;
	}

}

int main(int argc, char *argv[]) {
	setuid(0);
	setgid(0);

	if (argc < 2 || argc > 3) {
		printf("Usage: %s <m/u/f> <id?>\n", argv[0]);
		return 1;
	}

	if (argv[1][1] != 0) {
		printf("Usage: %s <m/u/f> <id>\n", argv[0]);
		return 1;
	}

	char buffer[256];

	switch (argv[1][0]) {
		case 'm':
			if (!check_args(argc, argv)) {
				return 1;
			}
			sprintf(buffer, "losetup /dev/loop%s foxos.img -P", argv[2]);
			system(buffer);
			sprintf(buffer, "chown $USER:$USER /dev/loop%s", argv[2]);
			system(buffer);
			sprintf(buffer, "chown $USER:$USER /dev/loop%sp1", argv[2]);
			system(buffer);
			break;
		case 'u':
			if (!check_args(argc, argv)) {
				return 1;
			}
			sprintf(buffer, "losetup -d /dev/loop%s", argv[2]);
			system(buffer);
			sprintf(buffer, "chown root:root /dev/loop%s", argv[2]);
			system(buffer);
			break;
		case 'f':
			system("losetup -f");
			break;
		default:
			printf("Usage: %s <m/u/f> <id>\n", argv[0]);
			return 1;
	}
}
