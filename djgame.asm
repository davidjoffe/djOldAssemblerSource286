;*******************************
; ÚÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ DJ - GAME ³  David Joffe
; ÀÄÄÄÄÄÄÄÄÄÄÄÙ '94/02/22 - ?
;*******************************
dosseg
.model compact
.stack 512h
;///////// Initialize all data: ////////////////////////
.data
;### segment 1: game ###################################
segment seg1     ;should contain all game-PLAYING data
 f_graf db 'ega16x16.001',0,'$'
 fh_graf dw 0
 f_man db 'djg-man.dat',0,'$'
 fh_man dw 0
 f_codes db 'djg-code.dat',0,'$'
 fh_codes dw 0
 file_error db 'Error with file: $'
 scenario dw 1
 des dw 0
 v320 dw 320
 v32 dw 32
 v10240 dw 10240
 v128 dw 128
 v640 dw 640
 v512 dw 512
 v352 dw 352
 codes db 256 dup(0)
 graf db 32768 dup(0)
 man db 2048 dup(0)
 i dw 0
 j dw 0
 x dw 0
 y dw 0
 xo dw 0
 yo dw 0
 sx dw 0
 sy dw 0
 lev dw 0
 BufferAtTop db 128 dup(1)
 clev db 10240 dup(0)
 mc dw 0
 mx dw 50 dup(0)
 my dw 50 dup(0)
 o8 dw 0
 xd dw 0
 yd dw 0
 status dw 0
 screenbuffer db 14080 dup(0)
 videoseg dw 0A000h
 jump db 1,1,1,1,0,0    ;(6 long)
 jumpflag dw 0
 jumpcount dw 0
ends seg1
;### segment 2: menu ###################################
segment seg2              ;MenuData
;array for title screen as well.
 f_font db 'DJG.FNT',0,'$'
 fh_font dw 0
 f_screen db 'DJG-SCR.DAT',0,'$'
 fh_screen dw 0
 f_fontg db 'DJG8X8.DAT',0,'$'
 fh_fontg dw 0
 fontg db 8192 dup(0)
 screen db 1000 dup(0)
 des2 dw 0
 i2 dw 0
 j2 dw 0
 c320 dw 320
 c32 dw 32
 k dw 0
 l dw 0
 font db 2048 dup(0)
 color db 0
 col dw 0
 row dw 0
 waitmsg db '=Please wait a moment='
 menuy dw 0
 menuc dw 0
 menu db 'ÉÍÍÍÍÍÍÍ MENU: ÍÍÍÍÍÍÍÍ»'
      db 'º   Start new game     º'
      db 'º   Restore saved game º'
      db 'º   Load level file    º'
      db 'º   Instructions       º'
      db 'º   Game setup         º'
      db 'º   High scores        º'
      db 'º   Credit             º'
      db 'º   Quit to DOS        º'
      db 'ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼'
 curgraf DB 60,126,255,255,255,255,126,60,0,0,0,0,0,0,0,0
	 DB 0,0,6,9,9,6,0,0,60,126,255,255,255,255,126,60
	 DB 60,126,255,255,255,255,126,60,0,0,0,0,0,0,0,0
	 DB 0,0,24,36,36,24,0,0,60,126,255,255,255,255,126,60
	 DB 60,126,255,255,255,255,126,60,0,0,0,0,0,0,0,0
	 DB 0,0,96,144,144,96,0,0,60,126,255,255,255,255,126,60
	 DB 60,126,255,255,255,255,126,60,0,0,0,0,0,0,0,0
	 DB 0,0,129,64,64,129,0,0,60,126,255,255,255,255,126,60
 blockchar db 219
ends    seg2
;### segment 3: levels #################################
segment seg3              ;entire level (6 parts)
 f_lev db 'floddlev.001',0,'$'
 fh_lev dw 0
 levels db 61440 dup(0)
ends    seg3
;### segment 4: sound ##################################
 ;segment seg4
 ;
 ;ends    seg4
;#######################################################
;////////////////////////////////////////////////////////////
assume  ds:seg1
;=============== MACRO DEFINITIONS =====================
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
KEYWAIT macro
	mov ah,10h
	int 16h
	endm
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
OF      macro OFptr,OFhandle
local   OFPastError
	mov ax,seg OFptr
	mov ds,ax
	mov dx,offset OFptr
	mov ax,3D02h
	int 21h
	jnc OFPastError
	jmp FileError
OFPastError:
	mov OFhandle,ax
	endm
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
RF      macro RFfh,RFcount,RFptr
local   RFPastError
	mov bx,RFfh
	mov cx,RFcount
	mov ax,seg RFptr
	mov ds,ax
	mov dx,offset RFptr
	mov ah,3Fh
	int 21h
	jnc RFPastError
	jmp FileError
RFPastError:
	endm
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CF      macro CFfh
local   CFPastError
	mov bx,CFfh
	mov ah,3Eh
	int 21h
	jnc CFPastError
	jmp FileError
CFPastError:
	endm
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TM      macro TMcol,TMrow,TMcolor,TMptr,TMcount
	mov ax,seg TMptr
	mov ds,ax
	assume ds:seg2
	mov col,TMcol
	mov row,TMrow
	mov color,TMcolor
	mov si,offset TMptr
	mov cx,TMcount
	call tipe
	assume ds:seg1
	endm
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.code
	assume ds:seg1
	jmp StartOfCode
;================ PROCEDURE DECLARATIONS:  =============
;-------------------------------------------------------
;-------------------------------------------------------
;-------------------------------------------------------
jumpupdate proc near
	assume ds:seg1
	cmp jumpflag,0
	jz PastJumpUpDate
	mov si,offset jump
	add si,jumpcount
	inc jumpcount
	cmp jumpcount,6
	jne PastFlattenJump
	mov jumpflag,0
	mov jumpcount,0
PastFlattenJump:
	mov al,[si]
	cmp al,0
	jz PastJumpUpDate
	dec y
	dec yo

PastJumpUpdate:
	ret
jumpupdate endp
;-------------------------------------------------------
herofall proc near
	assume ds:seg1
	cmp jumpflag,0
	jnz PastFallCheck
	mov si,offset clev
	mov ax,y
	inc ax
	mul v128
	add ax,x
	add si,ax
	lodsb
	xor ah,ah
	mov si,offset codes
	add si,ax
	lodsb
	cmp al,0
	jnz PastFallCheck
	inc y
	inc yo
PastFallCheck:
	ret
herofall endp
;---------------------------------------------------------
ndraw   proc near
	mov ax,seg1
	mov es,ax
	mov ax,yo
	mul v128
	add ax,xo
	mov si,offset clev
	add si,ax

	mov i,0
nNexI:  mov j,0
nNexJ:
	xor ah,ah
	lodsb
	mul v128
	push si
	mov si,offset graf
	add si,ax

	mov ax,i
	mul v352
	add ax,j
	add ax,j
	mov di,offset screenbuffer
	add di,ax

	mov bl,8
nDrawPlaneLoop:
	MOV CX,16
nDrawll:
	movsw
	add di,20
	loop nDrawll
	add di,3168
	SHR bl,1
	JNZ nDrawPlaneLoop

	pop si
	inc j
	cmp j,10
	jbe nNexJ

	add si,117

	inc i
	cmp i,9
	jbe nNexI

;        call drawman

	mov es,videoseg
	mov si,offset screenbuffer
	mov dx,3c4h
	mov al,2
	out dx,al


	mov al,8
	mov dx,3c5h
	out dx,al
	
	mov di,642
	mov cx,160
drawscreenll8:
	push cx
	mov cx,11
	rep movsw
	add di,18
	pop cx
	loop drawscreenll8

	mov al,4
	mov dx,3c5h
	out dx,al
	
	mov di,642
	mov cx,160
drawscreenll4:
	push cx
	mov cx,11
	rep movsw
	add di,18
	pop cx
	loop drawscreenll4

	mov al,2
	mov dx,3c5h
	out dx,al
	
	mov di,642
	mov cx,160
drawscreenll2:
	push cx
	mov cx,11
	rep movsw
	add di,18
	pop cx
	loop drawscreenll2

	mov al,1
	mov dx,3c5h
	out dx,al
	
	mov di,642
	mov cx,160
drawscreenll1:
	push cx
	mov cx,11
	rep movsw
	add di,18
	pop cx
	loop drawscreenll1

	call drawman

	ret
ndraw   endp
;---------------------------------------------------------
drawman proc near
	mov ax,status
	mul v512
	mov si,offset man
	add si,ax

	mov dx,3c4h
	mov al,2
	out dx,al

	mov bl,8
drawmanplaneloop:
	mov al,bl
	mov dx,3c5h
	out dx,al

	mov di,3851
	mov cx,32
drawmanll:
	movsw
	movsw
	add di,36
	loop drawmanll

	shr bl,1
	jnz drawmanplaneloop
	
	ret
drawman endp
;---------------------------------------------------------
draw1   proc near
	mov ax,yo
	mul v128
	add ax,xo
	mov si,offset clev
	add si,ax

	MOV DX,3C4H
	MOV AL,2
	OUT DX,AL

	mov i,0
NexI1:  mov j,0
NexJ1:
	xor ah,ah
	lodsb
	mul v128
	push si
	mov si,offset graf
	add si,ax
	mov ax,i
	mul v640
	add ax,j
	add ax,j
	add ax,643
	mov des,ax

	mov bl,8
Draw1PlaneLoop:
	MOV AL,bl
	MOV DX,3C5h
	OUT DX,AL
	MOV CX,16
	mov di,des
Draw1ll:
	movsw
	add di,38
	loop Draw1ll
	SHR bl,1
	JNZ Draw1PlaneLoop

	pop si
	inc j
	cmp j,9
	jbe NexJ1

	add si,118

	inc i
	cmp i,9
	jbe NexI1

	call drawman

	ret
draw1   endp
;---------------------------------------------------------
draw0   proc near
	mov ax,yo
	mul v128
	add ax,xo
	mov si,offset clev
	add si,ax

	MOV DX,3C4H
	MOV AL,2
	OUT DX,AL

	mov i,0
NexI:   mov j,0
NexJ:
	xor ah,ah
	lodsb
	mul v128
	push si
	mov si,offset graf
	add si,ax
	mov ax,i
	mul v640
	add ax,j
	add ax,j
	add ax,642
	mov des,ax

	MOV bl,8
Draw0PlaneLoop:
	MOV AL,bl
	MOV DX,3C5H
	OUT DX,AL
	MOV CX,16
	mov di,des
Draw0ll:
	movsw
	add di,38
	loop Draw0ll
	SHR bl,1
	JNZ Draw0PlaneLoop

	pop si
	inc j
	cmp j,10
	jbe NexJ

	add si,117

	inc i
	cmp i,9
	jbe NexI

	call drawman
	ret
draw0   endp
;---------------------------------------------------------
draw3   proc near
	mov ax,yo
	mul v128
	add ax,xo
	mov si,offset clev
	add si,ax

	MOV DX,3C4H
	MOV AL,2
	OUT DX,AL

	mov i,0
	mov des,642

NexI3:  mov j,0

NexJ3:  xor ah,ah
	lodsb
	mul v128
	push si
	mov si,offset graf
	add si,ax

	MOV bl,8
Draw3PlaneLoop:
	MOV AL,bl
	MOV DX,3C5H
	OUT DX,AL
	MOV CX,16
	mov di,des
Draw3ll:
	movsw
	add di,38
	loop Draw3ll
	SHR bl,1
	JNZ Draw3PlaneLoop

	pop si
	inc des
	inc des
	inc j
	cmp j,10
	jbe NexJ3

	add si,117
	add des,618

	inc i
	cmp i,9
	jbe NexI3

	call drawman

	ret
draw3   endp
;---------------------------------------------------------
G8      proc near
	assume ds:seg2
	MOV bl,8
	MOV DX,3C4H
	MOV AL,2
	OUT DX,AL
G8PlaneLoop:
	MOV AL,bl
	MOV DX,3C5H
	OUT DX,AL

	mov di,des2
	MOV CX,8
G8l:    movsb
	add di,39
	loop G8l

	SHR bl,1
	JNZ G8PlaneLoop
	
	ret
G8      endp
;---------------------------------------------------------
menuCB  proc near
	assume ds:seg2
	mov ax,seg blockchar
	mov ds,ax
	mov col,9
	mov ax,8
	add ax,menuy
	mov row,ax
	mov color,0
	mov si,offset blockchar
	mov cx,1
	call tipe
	assume ds:seg1
	ret
menuCB  endp
;---------------------------------------------------------
menuCD  proc near
	assume ds:seg2
	mov ax,seg curgraf
	mov ds,ax
	mov ax,menuy
	mul c320
	mov des2,2569
	add des2,ax
	mov ax,0A000h
	mov es,ax
	mov ax,menuc
	mul c32
	mov si,offset curgraf
	add si,ax
	
	MOV bl,8
	MOV DX,3C4H
	MOV AL,2
	OUT DX,AL
PlaneLoopM:
	MOV AL,bl
	MOV DX,3C5H
	OUT DX,AL

	mov di,des2
	mov cx,8
lld:    movsb
	add di,39
	loop lld

	SHR bl,1
	JNZ PlaneLoopM

;        MOV DX,3C4H
;        MOV AL,2
;        OUT DX,AL
;        INC DX
	MOV AL,0FH
	OUT DX,AL
	assume ds:seg1
	ret
menuCD  endp
;---------------------------------------------------------
tipe    proc near
	assume ds:seg2
	MOV DX,03CEh
	XOR AL,AL
	OUT DX,AL
	INC DX
	MOV AL,color
	OUT DX,AL
	DEC DX
	MOV AL,1
	OUT DX,AL
	INC DX
	MOV AL,0Fh
	OUT DX,AL
	MOV DX,03C4h
	MOV AL,2
	OUT DX,AL
	INC DX
	MOV AL,0Fh
	OUT DX,al

	MOV DX,0A000h
	MOV ES,DX

	mov ax,row
	mul c320
	add ax,col
	mov des2,ax

tipeCXloop:
	xor ah,ah
	lodsb
	shl ax,1
	shl ax,1
	shl ax,1

	push si

	mov si,offset font
	add si,ax
	mov di,des2

	push cx
	mov cx,8
ll:
	MOV DX,03CEh
	MOV AL,08h
	OUT DX,AL
	lodsb
	dec si
	INC DX
	OUT DX,AL

	MOV AH,ES:[DI]
	MOV ES:[DI],AL
	inc si
	add di,40
	loop ll
	pop cx

	pop si
	inc des2

	loop tipeCXloop

	MOV DX,03CEh   ; set the mask in EGA control registers
	MOV AL,08h
	OUT DX,AL
	INC DX
	mov al,0ffh
	OUT DX,AL

	DEC DX       ; Disable SET/RESET function
	MOV AL,1
	OUT DX,AL
	INC DX
	XOR AX,AX
	OUT DX,AL
	assume ds:seg1
	ret
tipe    endp
;---------------------------------------------------------
delay   proc near
	mov cx,15000
dLoop:  loop dLoop

;        mov cx,1
;delayloop1:
;        push cx
;        mov cx,35000
;delayloop2:
;        loop delayloop2
;        pop cx
;        loop delayloop1
	ret
delay   endp
;---------------------------------------------------------
;ðððððððððððððððð START OF GAME CODE: ðððððððððððððððððððð
StartOfCode:
	cld
	assume ds:seg1
	OF f_graf,fh_graf
	RF fh_graf,32768,graf
	CF fh_graf
	OF f_man,fh_man
	RF fh_man,2048,man
	CF fh_man
	assume ds:seg2
	OF f_font,fh_font
	RF fh_font,2048,font
	CF fh_font
	OF f_screen,fh_screen
	RF fh_screen,1000,screen
	CF fh_screen
	OF f_fontg,fh_fontg
	RF fh_fontg,8192,fontg
	CF fh_fontg
	assume ds:seg1
	OF f_codes,fh_codes
	RF fh_codes,256,codes
	CF fh_codes

	mov ax,13               ;EGA 320x200
	int 10h


; * Load title screen here

;******* Write menu to screen *********** (incorporate into graf file!)
	assume ds:seg2
	mov ax,seg col
	mov ds,ax
	mov col,7
	mov row,7
	mov color,15
	mov si,offset menu
MenuWriteLoop:
	mov cx,24
	call tipe
	assume ds:seg2
	inc row
	cmp row,17
	jb MenuWriteLoop

;^^^^^^^^^^^^^^^^^^^ MENULOOP: ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
MenuLoop:
	mov ah,11h
	int 16h

    ;    mov al,0adh
    ;    out 64h,al
    ;    xor ax,ax
    ;    in ax,60h
    ;    push ax
    ;    mov al,0aeh
    ;    out 64h,al
    ;    pop ax
    ;    cmp ax,0
    ;    jz PastKeyCheck

	cmp ah,1
	jne pastterminate
	jmp terminate
pastterminate:

	cmp ah,1ch
	je menuselect

	cmp ah,48h
	jne PastDecmenuy
	cmp menuy,0
	jz PastDecmenuy
	call menuCB
	dec menuy
	jmp PastMenuC0
PastDecmenuy:

	cmp ah,50h
	jne PastIncmenuy
	cmp menuy,7
	je PastIncmenuy
	call menuCB
	inc menuy
	Jmp PastMenuC0
PastIncmenuy:

PastKeyCheck:
	;call delay
	inc menuc
	cmp menuc,4
	jb PastMenuC0
	mov menuc,0
PastMenuC0:
	call menuCD
	call delay
	jmp MenuLoop
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
menuselect:
	cmp menuy,0
	jnz past0
	jmp startgame
past0:
	cmp menuy,0
	jnz past1
	jmp startgame
past1:
	cmp menuy,0
	jnz past2
	jmp startgame
past2:
	cmp menuy,0
	jnz past3
	jmp startgame
past3:
	cmp menuy,0
	jnz past4
	jmp startgame
past4:
	cmp menuy,0
	jnz past5
	jmp startgame
past5:
	cmp menuy,0
	jnz past6
	jmp startgame
past6:

startgame:
	assume ds:seg2
;[][][][][ Draw the border of the playing arena ]
	mov ax,0A000h
	mov es,ax
	mov ax,seg screen
	mov ds,ax
	mov si,offset screen
	mov i2,0
DSCi2:  mov j2,0
DSCj2:  mov ax,i2
	mul c320
	add ax,j2
	mov des2,ax
	xor ah,ah
	lodsb
	mul c32
	push si
	mov si,offset fontg
	add si,ax
	call G8
	pop si
	inc j2
	cmp j2,40
	jb DSCj2
	inc i2
	cmp i2,25
	jb DSCi2

	KEYWAIT

	assume ds:seg3
	OF f_lev,fh_lev
	RF fh_lev,61440,levels
	CF fh_lev

	;mov ax,seg1
	;mov ds,ax
	  
	TM 2,5,11,waitmsg,22

;[][][][][ Interpret the level and load into seg1:clev ]
	assume ds:seg1
	mov ax,seg1
	mov ds,ax
	mov di,offset clev
	mov ax,lev
	mul v10240
	assume ds:seg3
	mov si,offset levels
	add si,ax
;        mov si,ax
	assume ds:seg1
	mov ax,seg clev
	mov es,ax
	mov cx,10240

	mov i,0
NextI:  mov j,0
NextJ:
	xor ah,ah
	mov ax,seg levels
	mov ds,ax
	lodsb
	push ax
	dec si
	movsb
	mov ax,seg1
	mov ds,ax
	pop ax
	cmp al,127
	jne PastME
	 ;dec si
	 ;mov es:[si],word ptr 0
	 ;inc si

	 mov ax,j
	 mov x,ax
	 sub ax,5
	 mov xo,ax

	 mov ax,i
	 mov y,ax
	 sub ax,6
	 mov yo,ax
PastME:
	inc j
	cmp j,127
	jbe NextJ

	inc i
	cmp i,79
	jbe NextI

;[][][][][ initialize ES and DS for playing part of game: ]
	mov ax,0a000h
	mov es,ax
	mov ax,seg1
	mov ds,ax

	call draw0
;[********][********][********][********][********]
;<><><><><><><><><><MAINLOOP: ><><><><><><><><><><><>
MainLoop:
	call delay
	call herofall
	call jumpupdate

	cmp o8,0
	jnz PastDraw02
	call ndraw      ;call draw3
	jmp PastThis00
PastDraw02:
	call draw1      ;call draw3

PastThis00:

	mov ax,1100h
	int 16h
	jz MainLoop
	mov ax,1000h
	int 16h

PastKeyCheck2:

	cmp ah,01h
	jne PML1
	jmp terminate
PML1:   ;cmp ah,48h
	;jne PML2
	;jmp moveup
PML2:   ;cmp ah,50h
	;jne PML3
	;jmp movedown
PML3:   cmp ah,4Bh
	jne PML4
	jmp moveleft
PML4:   cmp ah,4Dh
	jne PML5
	jmp moveright
PML5:   cmp ah,39h
	jne PML6
	jmp jumpup
PML6:

PastThis6:
DrawML:
	cmp o8,0
	jnz PastDraw0
	call ndraw      ;call draw3
	jmp MainLoop
PastDraw0:
	call draw1      ;call draw3
	jmp MainLoop
;[********][********][********][********][********][********]
jumpup:
	cmp jumpflag,0
	jnz Pastjumpup
	mov jumpflag,1
Pastjumpup:
	jmp MainLoop

;movedown:
;        cmp o8,1
;        jne downnext
;        mov ax,y
;        inc ax
;        mul v128
;        add ax,x
;        dec ax
;        mov si,offset clev
;        add si,ax
;        xor ah,ah
;        mov al,[si]
;        mov si,offset codes
;        add si,ax
;        mov al,[si]
;        cmp al,1
;        jne PMLdown1
;        jmp MainLoop
;PMLdown1:
;downnext:
;        mov ax,y
;        inc ax
;        mul v128
;        add ax,x
;        mov si,offset clev
;        add si,ax
;        xor ah,ah
;        mov al,[si]
;        mov si,offset codes
;        add si,ax
;        mov al,[si]
;        cmp al,1
;        jne PMLdown2
;        jmp MainLoop
;PMLdown2:
;        inc yo
;        inc y
;        jmp DrawML
;moveup:
;        cmp o8,1
;        jne upnext
;        mov ax,y
;        dec ax
;        dec ax
;        mul v128
;        add ax,x
;        dec ax
;        mov si,offset clev
;        add si,ax
;        xor ah,ah
;        mov al,[si]
;        mov si,offset codes
;        add si,ax
;        mov al,[si]
;        cmp al,1
;        jne PMLup1
;        jmp MainLoop
;PMLup1:
;upnext:
;        mov ax,y
;        dec ax
;        dec ax
;        mul v128
;        add ax,x
;        mov si,offset clev
;        add si,ax
;        xor ah,ah
;        mov al,[si]
;        mov si,offset codes
;        add si,ax
;        mov al,[si]
;        cmp al,1
;        jne PMLup2
;        jmp MainLoop
;PMLup2:
;        dec yo
;        dec y
;        jmp DrawML
moveleft:
	mov ax,y
	mul v128
	add ax,x
	dec ax
	mov si,offset clev
	add si,ax
	xor ah,ah
	mov al,[si]
	mov si,offset codes
	add si,ax
	mov al,[si]
	cmp al,1
	jne PMLleft
	jmp MainLoop
PMLleft:
	mov ax,o8
	sub xo,ax
	sub x,ax
	xor o8,1
	mov status,2
	jmp DrawML
moveright:
	cmp o8,1
	jz PMLright
	mov ax,y
	mul v128
	add ax,x
	inc ax
	mov si,offset clev
	add si,ax
	xor ah,ah
	mov al,ds:[si]
	mov si,offset codes
	add si,ax
	mov al,ds:[si]
	cmp al,1
	jne PMLright
	jmp MainLoop
PMLright:
	xor o8,1
	mov ax,o8
	add xo,ax
	add x,ax
	mov status,0
	jmp DrawML






;>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Basically this is the end of the prog:
FileError:
	push dx
	mov dx,offset file_error
	mov ah,9
	int 21h
	pop dx
	int 21h
	jmp Goodbye
terminate:
;       [[[restore EGA plane mask before exitting: ] ] ]
	MOV DX,3C4H
	MOV AL,2
	OUT DX,AL
	INC DX
	MOV AL,0FH
	OUT DX,AL

	mov ax,3
	int 10h

	mov bx,0800h
	mov cx,256
	mov dx,0
	mov bp,offset font
	mov ax,seg font
	mov es,ax
	mov ax,1110h
	int 10h
Goodbye:
	mov ax,4c00h
	int 21h
end
