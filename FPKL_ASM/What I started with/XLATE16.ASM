; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	xlate16.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
_text	SEGMENT	WORD PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_DATA
; [0074]	; Linker - Pass two marker


	PUBLIC		_xlate16		; Located at 3:0000h Type = 1

_text	SEGMENT
	assume	cs: _text


_xlate16:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	push	gs
	les	si,dword ptr [bp+006h]
	lds	di,dword ptr [bp+00Ah]
	lgs	dx,dword ptr [bp+00Eh]
	mov	cx,[bp+012h]
	mov	ax,0000h
$L1:	lodsw
	mov	bx,dx
	add	bx,ax
	mov	al,gs:[bx]
	stosb
	loop	$L1
	pop	gs
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

_text	ENDS
	END
