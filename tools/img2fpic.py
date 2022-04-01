import sys
import os
import struct
from PIL import Image

"""
binary structure

uint64_t magic
uint64_t width
uint64_t height
uint32_t[] data (in rgba format)
"""

if __name__ == "__main__":
	if len(sys.argv) != 3:
		print("Usage: %s [image name] [image out]" % (sys.argv[0],))
		sys.exit(-1)

	im = Image.open(sys.argv[1])
	pix = im.load()

	f = open(sys.argv[2], "wb")

	width = im.size[0]
	height = im.size[1]

	f.write(struct.pack("<QQQ", 0xc0ffebabe, width, height))

	for y in range(height):
		for x in range(width):
			try:
				r, g, b = pix[x, y]
				a = 255
				f.write(struct.pack("<BBBB", b, g, r, a))
			except ValueError:
				r, g, b, a = pix[x, y]
				f.write(struct.pack("<BBBB", b, g, r, a))

	f.close()