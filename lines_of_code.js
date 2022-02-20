var num_lines = 0;

async function read_directory(dir) {
	for await (const dirEntry of Deno.readDir(dir)) {
		if (dirEntry.isDirectory) {
			await read_directory(dir + dirEntry.name + "/");
		} else {
			
			if (dirEntry.name.endsWith(".c") || dirEntry.name.endsWith(".cpp") || dirEntry.name.endsWith(".h")) {
				const file = Deno.readTextFileSync(dir + dirEntry.name);
				const lines = file.split("\n");
				num_lines += lines.length;
			}
		}
	}
}

read_directory("./").then(() => {
	console.log(`There are ${num_lines} lines of code in this project.`);
});