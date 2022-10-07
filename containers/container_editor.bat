@echo off

docker run -it --rm -v /dev:/dev --privileged -v %CD%:/root/FoxOS glowman554/foxos-editor:latest-amd64
