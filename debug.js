import { exec } from 'https://deno.land/x/exec/mod.ts';

function to_bool(str) {
	if(str == "y" || str == "yes") {
    		return true;
	} else if(str == "n" || str == "no") {
		return false;
	}
	return false;
}

var command = ' screen -S gdb gdb -ex "target remote localhost:1234" -ex "break _start" -ex "continue"'

if(to_bool(prompt("Debug assembly? "))) {
    command += '-ex "layout asm"';
} else {
    command += '-ex "layout src"';
}

if(to_bool(prompt("Show regs? "))) {
    command += '-ex "layout regs"'
}

command += " ./FoxOS-kernel/bin/foxkrnl.elf"

await exec("make run-dbg");
exec(command);
