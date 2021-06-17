# FoxOS
[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FTheUltimateFoxOS%2FFoxOS&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Discord](https://img.shields.io/discord/810910573864550410.svg?color=%237289da&label=discord)](https://discord.gg/qfYBHFWDcK)
[![Automatic Release](https://github.com/TheUltimateFoxOS/FoxOS/actions/workflows/release.yml/badge.svg)](https://github.com/TheUltimateFoxOS/FoxOS/actions/workflows/release.yml)

Our goal is to develop an operation system that focuses on the terminal, performence and reliability. We hope to provide you with a functionnal, performant and stable OS. And we do that together, everyone can help!

## Building
Before you build the project, you need to clone the submodules. To do so, run `git submodule update --init --recursive`.<br>
To build this OS, you will need a 64bit Ubuntu or Debian based os that you can install the following pachages on: `mtools`, `build-essential` and `nasm`. Install them like this: `sudo apt install mtools build-essential nasm`.<br>
Then simply run one of the following:<br>
* `make`: build the project.
* `make img`: package the `.img` file.
* `make usb`: build a bootable USB. **The USB must be formatted with FAT32!** You will also need `zip` installed on your building machine. To install, simply run `sudo apt install zip`.

## Other make commands
* `make clean`: clear all the built files.
* `make debug`: build and debug using [https://deno.land/](deno).
* `make run-dbg`: start a screen for QEMU so you can debug using gdb.

## Contributing
Feel free to fix a bug, implement a feature or any other change you thing would be good. If you want to contact us, join our [https://discord.gg/qfYBHFWDcK](Discord), we are there to help with any question you may have. Or you can [https://github.com/TheUltimateFoxOS/FoxOS/issues/new/choose](create an issue).

## Running
To run this OS, you can either use a VM or a bootable USB. See the building section for more info on how to build them.<br>
How to start:<br>
* **QEMU**: Use make `make run` to build and launch QEMU with the correct configuration.
* **VirtalBox**: You will need to create an optical drive (`.iso`, `.viso`, ...) from the `.img` file. Then you need to enable EFI under "System" in your VM's config. Then run it!
If you want to add documentation to booting on different software, feel free to do so.

## Our Discord
Here is the link to our [https://discord.gg/qfYBHFWDcK](Discord).
