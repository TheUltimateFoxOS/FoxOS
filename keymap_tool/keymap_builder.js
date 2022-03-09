const keymap_names = ["normal", "shift", "alt"];

// --- Main ---

async function main() {
    if (Deno.args[0] == null || Deno.args[1] == null) { //Check if the arguments are valid
        printUsage();
        Deno.exit(1);
    }
    
    const file_exists = await exists(Deno.args[1]); //Check if the file exists, if so read it
    if (!file_exists) {
        console.log("File does not exist: " + Deno.args[1]);
        Deno.exit(1);
    }
    const file_contents = await Deno.readFile(Deno.args[1]);

    if (Deno.args[0] == "-c") { //Convert JSON to keymap
        const file_json = await getJson(new TextDecoder().decode(file_contents));
        const data = jsonToKeymap(file_json);

        await Deno.writeFile("keymap.fmp", data);

    } else if (Deno.args[0] == "-r") { //Convert keymap to JSON
        const keymap_data = keymapToJson(file_contents);
        const json = JSON.stringify(keymap_data, null, '\t');
    
        await Deno.writeTextFile("keymap.json", json);

    } else {
        printUsage();
        Deno.exit(1);
    }
}

// --- Utility functions ---

function printUsage() {
    console.log("Usage:\n - deno run keymap_builder.js -c <keymap_file_json>\n - deno run keymap_builder.js -r <keymap_file>");
}

async function exists(path) {
    try {
        await Deno.stat(path);
        return true;
    } catch (error) {
        if (error instanceof Deno.errors.NotFound) {
            return false;
        } else {
            throw error;
        }
    }
}

async function getJson(path) {
    try {
        return JSON.parse(path);
    } catch (error) {
        console.log("Unable to read JSON: " + error.message);
        Deno.exit(1);
    }
}

function jsonToKeymap(contents) {
    var out = new Uint8Array(0xFF * keymap_names.length);
    var offset = 0; //The offset of the current keymap in the file

    for (var i = 0; i < keymap_names.length; i++) { //Loop through the keymaps
        const keymap = keymap_names[i];

        for (var key_id = 0; key_id < 0xFF; key_id++) { //Loop through the keys
            const key = "0x" + key_id.toString(16);

            if (contents[keymap].hasOwnProperty(key)) { //If the key doesn't exist, we skip it
				if (contents[keymap][key].length == 1) {
                	out[key_id + offset] = contents[keymap][key].charCodeAt(0);
				} else if (contents[keymap][key].startsWith("@")) {
					out[key_id + offset] = parseInt(contents[keymap][key].substring(1), 10);
				} else {
					console.log("Invalid keymap: " + key);
					Deno.exit(1);
				}
            }
        }

        offset += 0xFF; //Move to the next keymap
    }

    return out;
}

function keymapToJson(contents) {    
    var out = {};
    var offset = 0; //The offset of the current keymap in the file

    for (var i = 0; i < keymap_names.length; i++) { //Loop through the keymaps
        const keymap = keymap_names[i];

        out[keymap] = {};
        for (var key_id = 0; key_id < 0xFF; key_id++) { //Loop through the keys
            var num = contents[key_id + offset];

            if (num != 0) { //Only add the key if it is not 0
                out[keymap]["0x" + key_id.toString(16)] = String.fromCharCode(num);
            }
        }

        offset += 0xFF; //Move to the next keymap
    }

    return out;
}

//Run the program
main();
