#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
	setuid(0);
	setgid(0);

	if (argc != 3) {
		printf("Usage: %s <m/u> <id>\n", argv[0]);
		return 1;
	}

	if (argv[1][1] != 0) {
		printf("Usage: %s <m/u> <id>\n", argv[0]);
		return 1;
	}

	char buffer[256];

	switch (argv[1][0]) {
		case 'm':
			sprintf(buffer, "losetup /dev/loop%s foxos.img -P", argv[2]);
			system(buffer);
			sprintf(buffer, "chown $USER:$USER /dev/loop%s", argv[2]);
			system(buffer);
			sprintf(buffer, "chown $USER:$USER /dev/loop%sp1", argv[2]);
			system(buffer);
			break;
		case 'u':
			sprintf(buffer, "losetup -d /dev/loop%s", argv[2]);
			system(buffer);
			sprintf(buffer, "chown root:root /dev/loop%s", argv[2]);
			system(buffer);
			break;
		default:
			printf("Usage: %s <m/u> <id>\n", argv[0]);
			return 1;
	}
}
