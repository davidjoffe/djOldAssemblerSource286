# djOldAssemblerSource286
Some of my old source code from 1990s. Uploading on the off chance someone finds this useful.

**djgame.asm:**
Seemingly a prior attempt to initially write Dave Gnukem in 80286 assembly language in 1994, 16-bit EGA - sometime in 1995 I more sensibly started again in C++). This was using Turbo Assembler.

(Note: While writing a game entirely in assembly language may **sound** like a lot of fun (and one learns a lot), it's actually a bad idea from both a portability perspective, and a "useful use of your time" persective" - of course languages like C/C++ not only provide better portability, but in many cases the optimizing compiler will generate fast enough code for most parts of your game - just optimize the parts that need optimizing.) I don't advise anyone to *actually* write a game in this way, in 1994 I started on it presumably for fun, and just put this up here for interest, also as some actual 'retro code' from the 90s.)

Managed to get this 1994 code assembling and running in DOSbox and it's indeed an early forerunner of what later became Dave Gnukem (started the C++ version the following year)

![2022-11-22 00_24_42-1994_asm_dosbox2](https://user-images.githubusercontent.com/7451578/203170701-5c9c5518-bacc-427d-be40-e75dc2993b9e.png)

![2022-11-22 00_23_32_1994_asm_dosbox](https://user-images.githubusercontent.com/7451578/203170704-055da090-f0da-4f41-8ac7-d2641586798d.png)


**pcxload:**
Tiny PCX loader and viewer in .asm from 1999. 16-bit x86 (80268 DOS with VGA).
Builds to a .com DOS binary just 128 bytes in size that loads and displays a 320x200x256color pcx file specified on command line in VGA mode. Works in DOSBox.
It's not meant to be resilient code; I don't recall the exact point but I think there was some or other challenge to try load and display a pcx in as few bytes of code as one could manage, even if it cuts a few corners.
