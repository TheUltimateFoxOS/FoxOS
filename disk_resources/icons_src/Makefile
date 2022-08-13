rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

INP = $(call rwildcard,./,*.png)

OUT = $(patsubst %.png, %.bmp, $(INP))

all: $(OUT)

%.bmp: %.png
	@echo "CONV $^"
	@convert $^ -depth 24 BMP3:$@