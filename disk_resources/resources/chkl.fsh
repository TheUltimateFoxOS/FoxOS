echo Welcome to the change keyboard layout script.

echo Please input the new keyboard layout:
read layout

foxdb $ROOT_FS/FOXCFG/sys.fdb remove keyboard_layout
foxdb $ROOT_FS/FOXCFG/sys.fdb new_str keyboard_layout $layout