; David Joffe
; 1999/03/11
; pcx 320x200x256 load and display
.model tiny
;.stack 64d
.code
.8086
  org 100h
start:

; The first byte of the code is later used to load data from the file
pcxbuffer:

  ; read commandline parameter
  mov di, 80h
  mov bl, [di]
  xor bh, bh
  mov byte ptr ds:[bx+di+1], 0 ; null-terminate filename
;nextbyte:  ; assume user types only one space between "pcx" and filename
  inc di
  inc di
;  cmp byte ptr ds:[di], 32
;  jz nextbyte
  mov dx, di

  ; open pcx file (ds:dx already points to filename)
  mov ax, 3D00h
  int 21h

  ; file open error checking
;  jc quit                      ; close enough?
  mov bx, ax                   ; use bx throughout for filehandle


  ; set 320x200x256 graphics mode (can this kill bx?)
  mov ax, 13h
  int 10h  


  ; ds=cs, model is tiny (can't we use filename for buffer?)
  ; FIXME: This seems to be work, can we assume ds=cs?
;  push cs
;  pop ds


  ;=== LOAD PCX HEADER ================================================
  ; move file pointer past pcx header (bx=filehandle)
  mov cx, 128                  ; skip 128 bytes of header
skipheader:
  call LoadByte
  loop skipheader


; set file pointer position
;  mov ax, 4200h
;  xor cx, cx
;  mov dx, 128d
;  int 21h

  ; set es:di -> screen
p286
  push 0A000h
  pop es
p8086
;  xor di, di                   ; es:di -> A000:0000
  ; implement donovan's trick
;  mov di, 0FF7Bh
  xor di, di


  ;=== LOAD PCX DATA ==================================================
loading:
  call LoadByte                ; read a byte from the file
                               ; note: ah gets cleared by int21 in LoadByte
  push ax                      ; push loaded byte

  xor ch, ch                   ; set high-order byte of count to 0

  and al, 0C0h
  cmp al, 0C0h
  je rle

  pop ax                       ; pop loaded byte
  mov cl, 1
  jnz pastthis                 ; smaller than "jmp"
;  jmp pastthis
rle:
  ; store count in cx
  pop cx                       ; pop loaded byte
  and cl, 03Fh

  ; read pixel value from file
  call LoadByte

pastthis:

  rep stosb

  ; check if we've loaded 320x200 pixels
  cmp di, 320d * 200d
;  jnae loading
  jne loading


  ; cx = 0 here

  ;=== LOAD PALETTE ===================================================
  ; read 256 * 3 pixel values from file, using es:di to store data
  mov cx, (256d * 3) + 1        ; +1 because of extra byte before palette
paletteload:
  call LoadByte
p286
  shr al, 2                    ; divide by 4
p8086
  stosb
  loop paletteload

  ; close file (bx=filehandle)
  mov ah, 3Eh
  int 21h

  ; set palette
; dx should be = 100h at this point
  mov dx, 64001d                ; es:dx -> palette data
  mov ch, 1                    ; set cx=256 (FIXME can we assume cx=0 here?)
  mov ax, 1012h                ; set palette
  xor bx, bx                   ; block 0
  int 10h

  ; wait for key (FIXME: can we rely on ah=10h here?)
;  mov ah, 10h
  int 16h
  
  ; set textmode
  mov ax, 3
  int 10h

  ;=== QUIT ===========================================================
quit:
  ; DOS terminate process
  mov ah, 4Ch
  int 21h

  ;=== LOAD BYTE FROM PCX FILE ========================================
LoadByte PROC near
  push cx
  mov ah, 3Fh
  mov cx, 1
  mov dx, offset pcxbuffer
;  xor dx, dx                   ; we can assume dx=0, points to cs:0
  int 21h
  pop cx
;  mov al, byte ptr [offset 0]
  mov al, byte ptr [offset pcxbuffer]
  ret
LoadByte ENDP

end start
