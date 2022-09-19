echo Welcome to the change keyboard debug script.

echo Please input the new keyboard debug value (true/false):
read debug

foxdb $ROOT_FS/FOXCFG/sys.fdb remove keyboard_debug
foxdb $ROOT_FS/FOXCFG/sys.fdb new_bool keyboard_debug $debug