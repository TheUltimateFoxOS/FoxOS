#!/bin/sh
git pull

cd FoxOS-kernel
git pull

cd ../FoxOS-programs
git pull

cd libc
git pull

cd ../libfoxos
git pull

cd ../libtinf
git pull

cd ../libcfg
git pull

cd ../libfoxdb
git pull