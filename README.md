# FoxOS

[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FTheUltimateFoxOS%2FFoxOS&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Discord](https://img.shields.io/discord/810910573864550410.svg?color=%237289da&label=discord)](https://discord.gg/qfYBHFWDcK)
[![Automatic Release](https://github.com/TheUltimateFoxOS/FoxOS/actions/workflows/release.yml/badge.svg)](https://github.com/TheUltimateFoxOS/FoxOS/actions/workflows/release.yml)

Our goal is to develop an operation system that focuses on the terminal, performance and reliability. We hope to provide you with a functional, performant and stable OS. And we do that together, everyone can help!

![screenshot](https://github.com/TheUltimateFoxOS/FoxOS/releases/download/latest/foxos.jpg)

## Building

Before you build the project, you need to clone the submodules. To do so, run `git submodule update --init --recursive`.  

To build this OS, you need one of these:

* A 64bit Ubuntu or Debian based OS that you can install the following pachages on: `sudo apt install graphicsmagick-imagemagick-compat mtools lbzip2 curl bison flex gcc g++ unzip dosfstools automake build-essential nasm qemu-utils gdisk git`. We recommend you run `toolchain.sh` to build binaries that will be compatible with FoxOS.
* WSL (Windows Subsystem for Linx) with Ubuntu installed and the same tings as above.
* Our Docker image. You can run it like this: `docker run -it --rm -v /dev:/dev --privileged ghcr.io/theultimatefoxos/foxos-toolchain:latest`. An easy way to have this setup would be to open a command line or terminal window at a directory on your host machine with FoxOS cloned and run this: `docker run -it --rm -v /dev:/dev --privileged -v $PWD:/root/FoxOS ghcr.io/theultimatefoxos/foxos-toolchain:latest` to mount it at `/root/FoxOS`.
* An Intel Mac. You need to make sure to have these commands: `curl`, `zip`/`unzip`, `make`, `brew`, and `gcc`. First run: `brew install mtools`, `brew install gdisk`, and then run `toolchain_mac.sh`.
  
Then simply run one of the following:

* `make`: build the project.
* `make img`: package the `.img` file.
* `make mac-img`: package the `.img` file on an Intel Mac.
* `make docker-img`: package the `.img` file in Docker.
* `make run`: To build and run FoxOS. (Will not work on Mac)

The following alias command can be used to make your life easier: `alias mkfox="make USER_CFLAGS=\"-DDEBUG -DMEMORY_TRACKING -DBOOTINFO -fsanitize=undefined -DUBSAN_SUPRES_TYPE_MISSMATCH\""`

## Other make commands

* `make usb`: build a bootable USB. **The USB must be formatted with FAT32!**
* `make losetup`: build a script to be able to run `losetup` without root permissions.
* `make clean`: clear all the built files.
* `make debug`: build and debug using [deno](https://deno.land/).
* `make run-dbg`: start a screen for QEMU so you can debug using `gdb`.
* `make vmdk`: build a `.vmdk` file.
* `make vdi`: build a `.vdi` file.
* `make qcow2`: build a `.qcow2` file.
* `make vbox-setup` setup a virtualbox vm (only works on linux)

## Contributing

Feel free to fix a bug, implement a feature or any other change you thing would be good. If you want to contact us, join our [Discord](https://discord.gg/qfYBHFWDcK), we are there to help with any question you may have. Or you can [create an issue](https://github.com/TheUltimateFoxOS/FoxOS/issues/new/choose).  
If you dont know what to implement you can take a look at our [todo list](https://github.com/TheUltimateFoxOS/FoxOS/projects/1).

## Running

To run this OS, you can either use a VM or a bootable USB. See the building section for more info on how to build them.  
How to start:

* **QEMU**: Use `make run` to build and launch QEMU with the correct configuration.
* **VirtalBox**: Use `make qcow2` to build a `.qcow2` image file and create a VM to which you add this `.qcow2`. Then you need to enable EFI under "System" in your VM's config. Then run it!
If you want to add documentation to booting on different software, feel free to do so.

## Our Discord

Here is the link to our [Discord](https://discord.gg/qfYBHFWDcK).
