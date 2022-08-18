echo Welcome to the limine installer help script.

echo Available disks:
ls dev:

echo Please input the disk you want to install limine on (you only need to input the number):
read disk

lminst dev:disk_$disk
if --val1 $? --val2 0 --cmp == --not --cmd "echo Installation failed. Please try again."