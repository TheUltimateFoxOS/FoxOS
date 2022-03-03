function build_keymap {
	echo "Building $1..."
	deno run -A keymap_tool/keymap_builder.js -c keymap_tool/$1.json
	mv keymap.fmp disk_resources/resources/$1.fmp
}

build_keymap de
build_keymap fr
build_keymap us