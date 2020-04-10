# BOOT

This is just a NES bootable cartridge. The compiled file is `boot.nes`.

To compile, the cc65 suite should be installed, then just `make`.

The cartridge is assembled with assemble.c, to just put together the memory
banks. The character memory bank is hardcoded as `chr.bin`, it just contains the
numbers and letters from the super mario bros dump.

## What to expect

The cartridge should be bootable in a NES emulator (I use mesen). It should
display a blue screen with the word NINTENDO, and it should beep once. A number
below the word just shows the state of the gamepad for the 1st player.
