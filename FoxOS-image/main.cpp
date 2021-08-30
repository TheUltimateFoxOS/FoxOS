#include <iostream>
#include <file_list_node.h>

#include <ff.h>
#include <gpt.h>

#include <json.hpp>

list<file_list_node> file_list = list<file_list_node>(10);


int main(int argc, char *argv[]) {
	if (argc < 3) {
		std::cout << "Usage: " << argv[0] << " <file_name> <json_config>" << std::endl;
		return 1;
	}

	FILE* file = fopen(argv[1], "r+");
	if (file == NULL) {
		std::cout << "File not found" << std::endl;
		return 1;
	}

	if (!gpt::read_gpt(file)) {
		std::cout << "GPT not found" << std::endl;
		return 1;
	}

	FILE* config = fopen(argv[2], "r");
	if (config == NULL) {
		std::cout << "Config file not found" << std::endl;
		return 1;
	}

	BYTE work[1000];
	
	MKFS_PARM param;
	param.fmt = FS_FAT32;

	FRESULT fr = f_mkfs("", &param, work, sizeof work);
	if (fr != FR_OK) {
		std::cout << "Failed to format disk" << std::endl;
		return 1;
	}

	FATFS fatfs;
	fr = f_mount(&fatfs, "", 1);

	nlohmann::json json_config;
	fseek(config, 0, SEEK_END);
	long fsize = ftell(config);
	fseek(config, 0, SEEK_SET);
	char* buffer = new char[fsize];
	fread(buffer, 1, fsize, config);
	json_config = nlohmann::json::parse(buffer);

	for (auto& it : json_config["files"]) {
		std::string file = it["file"].get<std::string>();
		std::string file_on_disk = it["file_on_disk"].get<std::string>();

		std::cout << "Adding file: " << file << " to " << file_on_disk << std::endl;

		FILE* f = fopen(file.c_str(), "r");
		if (f == NULL) {
			std::cout << "File not found" << std::endl;
			return 1;
		}
		fseek(f, 0, SEEK_END);
		long file_fsize = ftell(f);
		fseek(f, 0, SEEK_SET);
		char* file_buffer = new char[file_fsize];
		fread(file_buffer, 1, file_fsize, f);
		fclose(f);

		char* file_on_disk_cstr = new char[file_on_disk.length() + 1];
		strcpy(file_on_disk_cstr, file_on_disk.c_str());

		for (int i = 0; i < file_on_disk.length(); i++) {
			if (file_on_disk_cstr[i] == '/') {
				if (i == 0) {
				} else {
					FATDIR dir;
					file_on_disk_cstr[i] = '\0';
			
					fr = f_opendir(&dir, file_on_disk_cstr);
					if (fr != FR_OK) {
						std::cout << "Creating directory: " << file_on_disk_cstr << std::endl;

						fr = f_mkdir(file_on_disk_cstr);
						if (fr != FR_OK) {
							std::cout << "Failed to create directory" << std::endl;
							return 1;
						}
					} else {
						f_closedir(&dir);
					}

					file_on_disk_cstr[i] = '/';
				}
			}
		}

		FIL fp;
		UINT br;
		fr = f_open(&fp, file_on_disk.c_str(), FA_WRITE | FA_CREATE_ALWAYS);
		if (fr != FR_OK) {
			std::cout << "Failed to open file" << std::endl;
			return 1;
		}

		fr = f_write(&fp, file_buffer, file_fsize, &br);
		if (fr != FR_OK) {
			std::cout << "Failed to write file" << std::endl;
			return 1;
		}

		fr = f_close(&fp);
		if (fr != FR_OK) {
			std::cout << "Failed to close file" << std::endl;
			return 1;
		}
		delete[] file_buffer;
	}

	fflush(file);
	fclose(file);

	/*FATFS fs;
	FIL fp;
	UINT btr, br;
	FRESULT fr;

	BYTE work[1000];
	fr = f_mkfs("", 0, work, sizeof work);
	if (fr != FR_OK) {
		std::cout << "Failed to create filesystem err: " << fr << std::endl;
		return 1;
	}

	f_mount(&fs, "", 1);
	f_open(&fp, "/us/bin/hello.txt", FA_CREATE_NEW | FA_WRITE);
	f_write(&fp, "Hello, World!\r\n", 15, &btr);
	f_close(&fp);
	f_unmount("");*/
}