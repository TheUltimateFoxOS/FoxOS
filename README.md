# FoxOS
[![HitCount](http://hits.dwyl.com/TheUltimateFoxOS/FoxOS.svg)](http://hits.dwyl.com/TheUltimateFoxOS/FoxOS)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Discord](https://img.shields.io/discord/810910573864550410.svg?color=%237289da&label=discord)](https://discord.gg/qfYBHFWDcK)
[![Automatic Release](https://github.com/TheUltimateFoxOS/FoxOS/actions/workflows/release.yml/badge.svg)](https://github.com/TheUltimateFoxOS/FoxOS/actions/workflows/release.yml)

Our goal is to develop an operation system that focuses on the terminal, performence and reliability. We hope to provide you with a functionnal, performant and stable OS. And we do that together, everyone can help!

## Building
To build this os, you will need a 64bit Ubuntu or Debian based os that you can install the following pachages on: `sudo apt-get install mtools build-essential nasm`<br>
Then simply run one of the following:<br>
`make` to build the files<br>
`make img` to build a .img (this also runs the default make)<br>
`make usb` to build a bootable USB. The USB must be formatted with FAT32 (this also runs the default make)<br>

## Contributing
Feel free to fix a bug, implement a feature or any other change you thing would be good. If you want to contact us, join our Discord, we are there to help with any question.

## Running
To run this OS, you can either use a VM or a bootable USB. See the building section for more info on how to build them.<br>
To run this OS in QEMU, you can run `make run` to build and launch QEMU with the correct configuration.<br>
To run this OS in VirtalBox, you will need to create an optical drive (`.iso`, `.viso`, ...). Then you need to enable EFI under "System" in your VM's config. Then run it!
If you want to add documentation to booting on different software, feel free to do so.

## Our Discord
Here is the link to our Discord: https://discord.gg/qfYBHFWDcK
