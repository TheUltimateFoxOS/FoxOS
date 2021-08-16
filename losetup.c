#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[]) {
	setuid(0);
	setgid(0);

	if (argc != 2) {
		printf("Usage: %s <m/u>\n", argv[0]);
		return 1;
	}

	if (argv[1][1] != 0) {
		printf("Usage: %s <m/u>\n", argv[0]);
		return 1;
	}

	switch (argv[1][0]) {
		case 'm':
			system("losetup /dev/loop9 foxos.img -P");
			system("chown $USER:$USER /dev/loop9");
			system("chown $USER:$USER /dev/loop9p1");
			break;
		case 'u':
			system("losetup -d /dev/loop9");
			system("chown root:root /dev/loop9");
			break;
		
		default:
			return 1;
	}
}