# David Joffe old assembler source
Some of my old assembler source code from the 1990s (286). Uploading on the off chance someone finds this useful.

By: [David Joffe](https://djoffe.com/)

**[djgame.asm](https://github.com/davidjoffe/djOldAssemblerSource286/blob/main/djgame.asm):**

I found this old assembler code of mine amongst my old backups, and (after getting it working again in DOSbox in a 2022 attempt - see below), it indeed seems to be a prior attempt of mine to initially write [Dave Gnukem](https://github.com/davidjoffe/dave_gnukem) in 80286 assembly language in 1994, 16-bit EGA video - sometime in 1995 I (slightly more sensibly) started again in C++). This was using Turbo Assembler. Platform: DOS, or DOSbox.

(Note: While writing a game **entirely** in assembly language may **sound** like a lot of fun (and one learns a lot), it's actually not the best idea from both a (1) portability perspective, and (2) a "useful use of your time" persective" - of course languages like C/C++ not only provide better portability, but in many cases the optimizing compiler will generate fast enough code for most parts of your game - just optimize the parts that need optimizing.) I don't advise anyone to *actually* write a game in this way, in 1994 I started on it presumably for fun, and just put this up here for interest, also as some actual 'retro code' from the 90s.)

### Works in DOSbox!

(2022 update) I managed to get this 1994 code of mine assembling and running in DOSbox, using the same old Turbo Assembler, and it worked :) (screenshots below), and it's indeed an early forerunner of what later became [Dave Gnukem](https://github.com/davidjoffe/dave_gnukem) (I started the C++ version the following year in 1995)

2022 screenshots of djgame.asm assembled and running in DOSbox:  
![2022-11-22 00_24_42-1994_asm_dosbox2](https://user-images.githubusercontent.com/7451578/203170701-5c9c5518-bacc-427d-be40-e75dc2993b9e.png)

![2022-11-22 00_23_32_1994_asm_dosbox](https://user-images.githubusercontent.com/7451578/203170704-055da090-f0da-4f41-8ac7-d2641586798d.png)


**(pcxload)[https://github.com/davidjoffe/djOldAssemblerSource286/tree/main/pcxload]:**

Tiny PCX loader and viewer in .asm from 1999. 16-bit x86 (80268 DOS with VGA).
Builds to a .com DOS binary just 128 bytes in size that loads and displays a 320x200x256color pcx file specified on command line in VGA mode. Works in DOSBox.
It's not meant to be resilient code; I don't recall the exact point but I think there was some or other challenge to try load and display a pcx in as few bytes of code as one could manage, even if it cuts a few corners.
