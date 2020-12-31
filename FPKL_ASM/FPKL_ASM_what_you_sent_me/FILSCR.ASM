; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	filscr.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [003A]	; Linker - Pass two marker


	PUBLIC		_filscr			; Located at 1:0000h Type = 1

_text	SEGMENT
	assume	cs: _text


_filscr:
	push	bp
	mov	bp,sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	es
	mov	ah,0Fh
	int	10h
	cmp	al,03h
	jnbe	$L1
	mov	ax,0B800h
	mov	es,ax
	mov	cx,07D0h
	jmp	short $L2
$L1:	cmp	al,06h
	jnbe	$L3
	mov	ax,0B800h
	mov	es,ax
	mov	cx,2000h
	jmp	short $L2
$L3:	cmp	al,07h
	jnbe	$L4
	mov	ax,0B000h
	mov	es,ax
	mov	cx,07D0h
	jmp	short $L2
$L4:	cmp	al,0Eh
	jc	$L5
	mov	ax,0A000h
	mov	es,ax
	mov	cx,9C40h
	mov	dx,03CEh
	mov	al,03h
	out	dx,al
	mov	dx,03CFh
	mov	al,00h
	out	dx,al
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	mov	ax,000Fh
	out	dx,al
$L2:	mov	al,[bp+006h]
	mov	ah,[bp+008h]
	mov	di,0000h
	cld
	repz	stosw
$L5:	pop	es
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	mov	sp,bp
	pop	bp
	retf

_text	ENDS
	END
