# djOldAssemblerSource286
Some of my old source code from 1990s. Uploading on the off chance someone finds this useful.

djgame.asm:
Seemingly a prior attempt to initially write Dave Gnukem in 80286 assembly language in 1994, 16-bit EGA - sometime in 1995 I more sensibly started again in C++). This was using Turbo Assembler.

pcxload:
Tiny PCX loader and viewer in .asm from 1999. 16-bit x86 (80268 DOS with VGA).
Builds to a .com DOS binary just 128 bytes in size that loads and displays a 320x200x256color pcx file specified on command line in VGA mode. Works in DOSBox.
It's not meant to be resilient code; I don't recall the exact point but I think there was some or other challenge to try load and display a pcx in as few bytes of code as one could manage, even if it cuts a few corners.
