; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	xfer.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [0040]	; Linker - Pass two marker


	PUBLIC		_xfer			; Located at 1:0000h Type = 1
	PUBLIC		_vxfer			; Located at 1:001Fh Type = 1

_text	SEGMENT
	assume	cs: _text


_xfer:	push	bp
	mov	bp,sp
	push	cx
	push	di
	push	si
	push	ds
	push	es
	cld
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
	mov	cx,[bp+00Eh]
	shr	cx,1
	repz	movsw
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	cx
	mov	sp,bp
	pop	bp
	retf
_vxfer:	push	bp
	mov	bp,sp
	push	cx
	push	di
	push	si
	push	ds
	push	es
	cld
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
	mov	cx,[bp+00Eh]
	repz	movsb
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
