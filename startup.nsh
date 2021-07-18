@echo -off
mode 80 25

cls
if exist .\efi\boot\BOOTX64.EFI then
 .\efi\boot\BOOTX64.EFI
 goto END
endif


if exist fs0:\efi\boot\BOOTX64.EFI then
 fs0:
 echo Found bootloader on fs0:
 efi\boot\BOOTX64.EFI
 goto END
endif

if exist fs1:\efi\boot\BOOTX64.EFI then
 fs1:
 echo Found bootloader on fs1:
 efi\boot\BOOTX64.EFI
 goto END
endif

if exist fs2:\efi\boot\BOOTX64.EFI then
 fs2:
 echo Found bootloader on fs2:
 efi\boot\BOOTX64.EFI
 goto END
endif

if exist fs3:\efi\boot\BOOTX64.EFI then
 fs3:
 echo Found bootloader on fs3:
 efi\boot\BOOTX64.EFI
 goto END
endif

if exist fs4:\efi\boot\BOOTX64.EFI then
 fs4:
 echo Found bootloader on fs4:
 efi\boot\BOOTX64.EFI
 goto END
endif

if exist fs5:\efi\boot\BOOTX64.EFI then
 fs5:
 echo Found bootloader on fs5:
 efi\boot\BOOTX64.EFI
 goto END
endif

if exist fs6:\efi\boot\BOOTX64.EFI then
 fs6:
 echo Found bootloader on fs6:
 efi\boot\BOOTX64.EFI
 goto END
endif

if exist fs7:\efi\boot\BOOTX64.EFI then
 fs7:
 echo Found bootloader on fs7:
 efi\boot\BOOTX64.EFI
 goto END
endif

 echo "Unable to find bootloader".
 
:END