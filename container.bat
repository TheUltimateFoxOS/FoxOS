@echo off

docker run -it --rm -v /dev:/dev --privileged -v %CD%:/root/FoxOS ghcr.io/theultimatefoxos/foxos-toolchain:latest