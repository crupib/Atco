; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fp_emsad.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [003F]	; Linker - Pass two marker


	PUBLIC		_fp_emsadd		; Located at 1:0000h Type = 1

_text	SEGMENT
	assume	cs: _text


_fp_emsadd:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	cld
	mov	bx,[bp+007h]
	mov	cx,0006h
	sar	bx,cl
	mov	dx,[bp+00Ah]
	mov	ax,0000h
	mov	ax,4400h
	int	67h
	mov	ax,4401h
	inc	bx
	int	67h
	test	ah,ah
	mov	al,00h
	mov	ax,[bp+006h]
	and	ax,3FFFh
	mov	dx,[bp+00Ch]
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf

_text	ENDS
	END
