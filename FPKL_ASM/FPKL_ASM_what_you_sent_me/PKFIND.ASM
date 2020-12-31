; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	pkfind.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [0044]	; Linker - Pass two marker


	PUBLIC		_pkfind			; Located at 1:0000h Type = 1
	PUBLIC		_pkamp			; Located at 1:005Ah Type = 1

_text	SEGMENT
	assume	cs: _text


_pkfind:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
	lds	si,dword ptr [bp+006h]
	les	bx,dword ptr [bp+00Ah]
	mov	dx,es:[bx]
	add	si,dx
	les	bx,dword ptr [bp+00Eh]
	mov	cx,es:[bx]
	mov	ah,[si]
	cmp	ah,00h
	jnl	$L1
	neg	ah
$L1:	mov	dx,si
$L5:	lodsb
	cmp	al,00h
	jnl	$L2
	cmp	al,80h
	jnz	$L3
	add	al,01h
$L3:	neg	al
$L2:	cmp	al,ah
	jbe	$L4
	xchg	al,ah
	mov	dx,si
$L4:	loop	$L5
	xchg	al,ah
	cbw
	les	bx,dword ptr [bp+012h]
	mov	es:[bx],ax
	les	bx,dword ptr [bp+006h]
	sub	dx,bx
	sub	dx,+001h
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],dx
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_pkamp:	push	bp
	mov	bp,sp
	push	si
	push	ds
	cld
	lds	si,dword ptr [bp+006h]
	mov	cx,[bp+00Ah]
	mov	ax,0000h
$L9:	lodsb
	sub	al,80h
	cmp	al,00h
	jnl	$L6
	cmp	al,80h
	jnz	$L7
	add	al,01h
$L7:	neg	al
$L6:	cmp	al,ah
	jbe	$L8
	xchg	al,ah
$L8:	loop	$L9
	xchg	al,ah
	shl	al,1
	sub	ah,ah
	pop	ds
	pop	si
	mov	sp,bp
	pop	bp
	retf

_text	ENDS
	END
