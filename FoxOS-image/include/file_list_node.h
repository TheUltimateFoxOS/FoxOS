#pragma once

#include <stdio.h>
#include <list.h>


struct file_list_node {
	FILE* fp;
	int id;
	int offset;
	int size;
};

extern list<file_list_node> file_list;