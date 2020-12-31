; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	xferc.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [0044]	; Linker - Pass two marker


	PUBLIC		_xferci			; Located at 1:0000h Type = 1
	PUBLIC		_xferco			; Located at 1:0024h Type = 1

_text	SEGMENT
	assume	cs: _text


_xferci:
	push	bp
	mov	bp,sp
	push	cx
	push	di
	push	si
	push	ds
	push	es
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
	mov	cx,[bp+00Eh]
	mov	dx,[bp+010h]
	dec	dx
	cld
$L1:	movsb
	add	si,dx
	loop	$L1
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	cx
	mov	sp,bp
	pop	bp
	retf
_xferco:
	push	bp
	mov	bp,sp
	push	cx
	push	di
	push	si
	push	ds
	push	es
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
	mov	cx,[bp+00Eh]
	mov	dx,[bp+010h]
	dec	dx
	cld
$L2:	movsb
	add	di,dx
	loop	$L2
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	cx
	mov	sp,bp
	pop	bp
	retf

_text	ENDS
	END
