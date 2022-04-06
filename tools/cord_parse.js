if (Deno.args.length != 2) {
	console.log("Usage: chord_parse <in> <out>");
	Deno.exit(1);
}

var file = Deno.readTextFileSync(Deno.args[0]);

var notes = [];

// note must contain length of note (in ms) and the octave of the note and the note itself

var last_note = 0;

file.split("\n\n").forEach(function(section) {
	var octaves = [];

	section.split("\n").forEach(function(octave) {
		if (octave.endsWith("|")) {
			octave = octave.substring(0, octave.length - 1);
		}

		var num_octave = octave.split("|")[0];

		octaves.push({
			num_octave: num_octave,
			notes: octave.split("|")[1].split("")
		});
	});

	for (let i = 0; i < octaves[0].notes.length; i++) {
		for (let j = 0; j < octaves.length; j++) {
			if (octaves[j].notes[i] != "-") {
				var obj = {
					length: 0,
					octave: octaves[j].num_octave,
					note: octaves[j].notes[i]
				};

				if (notes.length != 0) {
					notes[notes.length - 1] = {
						...notes[notes.length - 1],
						length: (last_note - 100 == 0) ? 50 : last_note - 100
					};
				}

				notes.push(obj);
				last_note = 0;
				break;
			}
		}
		last_note += 100;
	}
});

notes[notes.length - 1] = {
	...notes[notes.length - 1],
	length: 100
};

/*
binary structure:
struct note_t {
	uint16_t length_ms;
	uint16_t note;
}

struct foxm_t {
	uint16_t magic; // 0xf0f0baba
	note_t notes[];
}
*/

var array = new Uint16Array(2 + (notes.length * 2));

array[1] = 0xf0f0;
array[0] = 0xbaba;

function note_to_int(note) {
	switch (note) {
		case "c": return 0;
		case "C": return 1;
		case "d": return 2;
		case "D": return 3;
		case "e": return 4;
		case "f": return 5;
		case "F": return 6;
		case "g": return 7;
		case "G": return 8;
		case "a": return 9;
		case "A": return 10;
		case "b": return 11;
		default: throw new Error("Invalid note " + note);
	}
}

notes.forEach(function(note, index) {
	array[2 + index * 2] = note.length;
	array[2 + index * 2 + 1] = ((parseInt(note.octave) << 4) | note_to_int(note.note));
});

console.log("Parsed " + notes.length + " notes");

Deno.writeFileSync(Deno.args[1], new Uint8Array(array.buffer));