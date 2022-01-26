
pcx.asm - Some old 1999 assembler source of mine.
Tiny PCX loader and viewer in .asm.
Builds to a .com binary just a tiny 128 bytes(!) in size that loads and
displays a 320x200x256color pcx file specified on command line in VGA mode.
16-bit x86 (80268 DOS with VGA)

I build using Turbo Assembler v3.1, not sure if other versions may work.

To build you should first set your path to include the path to tasm.exe, e.g.:
set path=%path%;c:\path\to\tasm
Then use 'make' .bat helper. It generates pcx.com (a binary extension
that used to be quite common in the DOS days)

Pass the name of the pcx file as parameter, e.g.:
pcx test.pcx

Works in DOSBox.

I can't recall the point of this, but I vaguely recall it may have stemmed
from some kind of challenge to make the smallest program you could that
achieves this task or some-such. It's not meant to be resilient code.

Likely it can be done in less than 128 bytes, if someone feels like a
challenge.

H/T to Donovan Hutchence who evidently offered some tip at line 66.

 - David 2022
