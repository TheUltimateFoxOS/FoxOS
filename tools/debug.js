import { exec } from 'https://deno.land/x/exec/mod.ts';

function to_bool(str) {
	if(str == "y" || str == "yes") {
    		return true;
	} else if(str == "n" || str == "no") {
		return false;
	}
	return false;
}

var command = ' screen -S gdb gdb -ex "target remote localhost:1234" -ex "break _start_limine" -ex "break _start_stivale2" -ex "continue"'

if(to_bool(prompt("Debug assembly? "))) {
    command += '-ex "layout asm"';
} else {
    command += '-ex "layout src"';
}

if(to_bool(prompt("Show regs? "))) {
    command += '-ex "layout regs"'
}

command += " ./FoxOS-kernel/bin/foxkrnl.elf"

if(to_bool(prompt("Boot vm? "))) {

	if(to_bool(prompt("Boot bios? "))) {
		await exec("make run-dbg-bios");
	} else {
		await exec("make run-dbg");
	}

}

exec(command);
