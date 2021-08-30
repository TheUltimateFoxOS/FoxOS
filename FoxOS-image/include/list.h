#pragma once

#include <stdlib.h>
#include <string.h>

template <typename T>
class list {
	public:

		struct node {
			T data;
			bool taken = false;
		};

		list(int initial_length) {
			length = initial_length;
			data = (node*) calloc(length, sizeof(node));
		};

		~list() {
			free(data);
		}

		template <typename Y>
		node* find(bool (*f)(Y, node*), Y arg) {
			for (size_t i = 0; i < length; i++) {
				if (data[i].taken) {
					if (f(arg, &data[i])) {
						return &data[i];
					}
				}
			}
			
			return nullptr;
		}

		void foreach(void (*f)(node*)) {
			for (size_t i = 0; i < length; i++) {
				if (data[i].taken) {
					f(&data[i]);
				}
			}
		}

		void remove(node* n) {
			for (size_t i = 0; i < length; i++) {
				if (&data[i] == n) {
					memset(&data[i], 0, sizeof(node));
				}
			}
		}

		node* add(T d) {
		retry:
			for (size_t i = 0; i < length; i++) {
				if (!data[i].taken) {
					data[i].data = d;
					data[i].taken = true;
					return &data[i];
				}
			}

			data = (node*) realloc(data, sizeof(node) * (length + 1));
			length++;
			goto retry;
		}
	
	private:
		int length;
		node* data;
};