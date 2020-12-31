; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	findth.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [003A]	; Linker - Pass two marker


	PUBLIC		_findth			; Located at 1:0000h Type = 1

_text	SEGMENT
	assume	cs: _text


_findth:
	push	bp
	mov	bp,sp
	push	si
	push	ds
	cld
	mov	cx,[bp+00Ch]
	mov	dx,[bp+00Ah]
	lds	si,dword ptr [bp+006h]
	add	si,dx
	mov	ah,[bp+00Eh]
	cmp	ah,00h
	jng	$L1
$L3:	lodsb
	cmp	al,ah
	jnl	$L2
	loop	$L3
	mov	ax,0FFFFh
	jmp	short $L4
$L1:	lodsb
	cmp	al,ah
	jng	$L2
	loop	$L1
	mov	ax,0FFFFh
	jmp	short $L4
$L2:	mov	ax,dx
	sub	ax,cx
	add	ax,[bp+00Ch]
$L4:	pop	ds
	pop	si
	pop	bp
	retf

_text	ENDS
	END
