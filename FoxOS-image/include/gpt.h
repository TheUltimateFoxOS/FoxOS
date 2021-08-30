#include <stdint.h>
#include <stdio.h>

namespace gpt {
	struct gpt_guid {
		uint32_t data1;
		uint16_t data2;
		uint16_t data3;
		uint64_t data4;
	} __attribute__((packed));

	struct gpt_header {
		char signature[8];
		uint8_t revision[4];
		uint32_t header_size;
		uint32_t crc32;
		uint32_t reserved;
		uint64_t current_lba;
		uint64_t backup_lba;
		uint64_t first_usable_lba;
		uint64_t last_usable_lba;
		gpt_guid guid;
		uint64_t partition_entries_startting_lba;
		uint32_t partition_entries_count;
		uint32_t partition_entries_size;
		uint32_t partition_entry_array_crc32;
	} __attribute__((packed));

	struct gpt_partition_entry {
		gpt_guid type_guid;
		gpt_guid partition_guid;
		uint64_t first_lba;
		uint64_t last_lba;
		uint16_t partition_name[36];
	} __attribute__((packed));

	bool read_gpt(FILE* fp);
}