; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	bfplt.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [0087]	; Linker - Pass two marker

	EXTRN		_nucol:WORD
	EXTRN		_vm:ABS
	EXTRN		_vidseg:WORD
	EXTRN		_video:WORD
	PUBLIC		_bfplt			; Located at 2:0000h Type = 1
	PUBLIC		_fgplt			; Located at 2:0106h Type = 1

_data	SEGMENT

$S6	dw	00008h
$S1	dw	01500h

$S5	dw	1 dup(?)
$S4	dw	1 dup(?)
$S2	dw	00000h
$S7	dw	00000h
$S8	dw	00000h
$S16	db	000h
$S17	db	000h
$S20	dw	00000h

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_bfplt:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	al,[bp+00Eh]
	mov	ah,[bp+010h]
	assume	ds: DGROUP
	mov	$S1,ax
	cmp	word ptr $S2,+000h
	jnz	$L3
	push	bp
	mov	bh,06h
	mov	al,30h
	mov	ah,11h
	int	10h
	mov	$S4,bp
	mov	word ptr $S2,es
	pop	bp
$L3:	mov	dx,[bp+00Ah]
	mov	bx,[bp+00Ch]
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,dx
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	mov	$S5,bx
	mov	word ptr $S6,0010h
	mov	word ptr $S7,0000h
	mov	word ptr $S8,0000h
$L14:	les	bx,dword ptr [bp+006h]
	add	bx,$S7
	mov	al,es:[bx]
	cmp	al,00h
	jnz	$L9
	jmp	$L10
$L9:	mov	ah,00h
	mov	bx,$S6
	mul	bl
	mov	bx,$S4
	add	bx,ax
	add	bx,$S6
	dec	bx
	push	ds
	mov	cx,$S6
	push	bp
	mov	bp,_nucol
	mov	di,$S5
	add	di,$S8
	mov	es,word ptr _vidseg
	mov	si,bx
	mov	bx,$S1
	mov	ds,word ptr $S2
	std
	mov	dx,03CEh
	mov	ax,0003h
	out	dx,ax
	mov	ax,0005h
	out	dx,ax
	mov	ax,0FF08h
	out	dx,ax
	mov	dx,03C4h
	mov	ax,0FF02h
	out	dx,ax
	push	cx
	push	di
	mov	al,00h
$L11:	mov	es:[di],al
	sub	di,bp
	loop	$L11
	pop	di
	pop	cx
	mov	dx,03C4h
	mov	al,02h
	mov	ah,bl
	out	dx,ax
	push	cx
	push	si
	push	di
$L12:	lodsb
	mov	es:[di],al
	sub	di,bp
	loop	$L12
	pop	di
	pop	si
	pop	cx
	mov	dx,03CEh
	mov	ax,1003h
	out	dx,ax
	mov	dx,03C4h
	mov	al,02h
	mov	ah,bh
	out	dx,ax
$L13:	lodsb
	not	al
	mov	ah,es:[di]
	mov	es:[di],al
	sub	di,bp
	loop	$L13
	pop	bp
	pop	ds
	inc	word ptr $S7
	inc	word ptr $S8
	jmp	$L14
$L10:	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_fgplt:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	cmp	word ptr $S2,+000h
	jnz	$L15
	push	bp
	mov	bh,06h
	mov	al,30h
	mov	ah,11h
	int	10h
	mov	$S4,bp
	mov	word ptr $S2,es
	pop	bp
$L15:	mov	dx,[bp+00Ah]
	mov	bx,[bp+00Ch]
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,dx
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	mov	$S5,bx
	shl	ax,cl
	sub	dx,ax
	mov	$S16,dl
	mov	ax,0008h
	sub	ax,dx
	mov	$S17,al
	mov	word ptr $S6,0010h
	mov	word ptr $S7,0000h
	mov	dx,03C4h
	mov	ax,0FF02h
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0003h
	out	dx,ax
	mov	ax,0005h
	out	dx,ax
	mov	ax,0F01h
	out	dx,ax
	mov	al,00h
	mov	ah,[bp+00Eh]
	and	ah,0Fh
	out	dx,ax
	inc	dx
	std
$L23:	les	bx,dword ptr [bp+006h]
	add	bx,$S7
	mov	al,es:[bx]
	cmp	al,00h
	jnz	$L18
	jmp	short $L19
$L18:	mov	ah,00h
	mov	bx,$S6
	mul	bl
	mov	bx,$S4
	add	bx,ax
	add	bx,$S6
	dec	bx
	mov	$S20,bx
	push	bp
	mov	bp,_nucol
	mov	di,$S5
	mov	es,word ptr _vidseg
	mov	si,bx
	dec	dx
	mov	al,08h
	out	dx,al
	inc	dx
	mov	bx,$S6
	mov	cl,$S16
	push	ds
	mov	ds,word ptr $S2
$L21:	lodsb
	shr	al,cl
	out	dx,al
	mov	ah,es:[di]
	mov	es:[di],ah
	sub	di,bp
	dec	bx
	jnz	$L21
	pop	ds
	inc	word ptr $S5
	mov	di,$S5
	mov	si,$S20
	mov	bx,$S6
	mov	cl,$S17
	push	ds
	mov	ds,word ptr $S2
$L22:	lodsb
	shl	al,cl
	out	dx,al
	mov	ah,es:[di]
	mov	es:[di],ah
	sub	di,bp
	dec	bx
	jnz	$L22
	pop	ds
	pop	bp
	inc	word ptr $S7
	jmp	$L23
$L19:	mov	dx,03CEh
	mov	ax,0001h
	out	dx,ax
	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

_text	ENDS
	END
