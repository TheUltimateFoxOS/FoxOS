#include <gpt.h>


#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <file_list_node.h>

using namespace gpt;

bool gpt::read_gpt(FILE* fp) {
	gpt_header* header = (gpt_header*) malloc(sizeof(gpt_header));
	fseek(fp, 512, SEEK_SET);
	fread(header, sizeof(gpt_header), 1, fp);

	if (memcmp(header->signature, "EFI PART", 8) != 0) {
		free(header);
		return false;
	} else {
		gpt_partition_entry* entries = (gpt_partition_entry*) malloc(header->partition_entries_size * header->partition_entries_count);
		fseek(fp, header->partition_entries_startting_lba * 512, SEEK_SET);
		fread(entries, header->partition_entries_size, header->partition_entries_count, fp);

		for (int i = 0; i < header->partition_entries_count; i++) {
			if (entries[i].type_guid.data1 == 0) {
				continue;
			}
			
			printf("Partition guid: %x, index: %d, partition start lba: %d\n", entries[i].type_guid.data3, i, entries[i].first_lba);


			file_list.add({
				.fp = fp,
				.id = 0,
				.offset = (int) entries[i].first_lba * 512,
				.size = (int) (entries[i].last_lba - entries[i].first_lba -1)
			});
		}
		

		free(entries);
		free(header);
		return true;
	}
}