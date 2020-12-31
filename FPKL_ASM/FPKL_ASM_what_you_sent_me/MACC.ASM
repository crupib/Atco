; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	macc.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
dgroup	GROUP	_data
; [0058]	; Linker - Pass two marker


	PUBLIC		_mac			; Located at 2:0000h Type = 1

_text	SEGMENT
	assume	cs: _text


_mac:	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg _data
	mov	ds,ax
	cld
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0000h
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L1:	lodsb
	cbw
	mov	bx,es:[di]
	imul	bx
	add	[bp-004h],ax
	adc	[bp-002h],dx
	add	di,+002h
	loop	$L1
	mov	ax,[bp-003h]
	shl	ax,1
	mov	al,ah
	cmp	al,80h
	jnz	$L2
	inc	al
$L2:	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf

_text	ENDS
	END
