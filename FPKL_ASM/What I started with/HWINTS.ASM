; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	hwints.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
null	SEGMENT	PARA PUBLIC USE16 'begdata'
null	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [008B]	; Linker - Pass two marker


	PUBLIC		_in_port_60		; Located at 3:0000h Type = 1
	PUBLIC		_enaint			; Located at 3:0005h Type = 1
	PUBLIC		_disint			; Located at 3:004Ah Type = 1
	PUBLIC		_setint			; Located at 3:0085h Type = 1

_data	SEGMENT

$S6	dw	00000h
$S9	dw	00000h
$S10	dw	00000h
	db	067h
	db	00Ch
	db	070h
	db	000h
$S8	db	000h

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_in_port_60:
	mov	ah,00h
	in	al,60h
	retf
_enaint:
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	mov	cl,[bp+006h]
	cmp	cl,0Fh
	jnbe	$L1
	sub	cl,08h
	mov	ah,0FEh
	rol	ah,cl
	in	al,21h
	and	al,ah
	out	021h,al
	mov	al,20h
	out	020h,al
	jmp	short $L2
$L1:	cmp	cl,77h
	jnbe	$L2
	sub	cl,70h
	mov	ah,0FEh
	rol	ah,cl
	in	al,0A1h
	and	al,ah
	out	0A1h,al
	mov	al,20h
	out	0A0h,al
	in	al,21h
	and	al,0FBh
	out	021h,al
	mov	al,20h
	out	020h,al
$L2:	sti
	pop	cx
	pop	ax
	pop	bp
	retf
_disint:
	push	bp
	mov	bp,sp
	push	ax
	push	cx
	mov	cl,[bp+006h]
	cmp	cl,0Fh
	jnbe	$L3
	sub	cl,08h
	mov	ah,01h
	rol	ah,cl
	in	al,21h
	or	al,ah
	out	021h,al
	mov	al,20h
	out	020h,al
	jmp	short $L4
$L3:	cmp	cl,77h
	jnbe	$L4
	sub	cl,70h
	mov	ah,01h
	rol	ah,cl
	in	al,0A1h
	or	al,ah
	out	0A1h,al
	mov	al,20h
	out	0A0h,al
$L4:	sti
	pop	cx
	pop	ax
	pop	bp
	retf
_setint:
	push	bp
	mov	bp,sp
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg _data
	mov	ds,ax
	mov	al,[bp+006h]
	cmp	al,00h
	jz	$L5
	assume	ds: _data
	cmp	word ptr $S6,+001h
	jz	$L7
	mov	word ptr $S6,0001h
	mov	al,[bp+008h]
	mov	$S8,al
	mov	ah,35h
	int	21h
	mov	$S9,bx
	mov	word ptr $S10,es
	push	ds
	mov	al,[bp+008h]
	mov	ah,25h
	lds	dx,dword ptr [bp+00Ah]
	int	21h
	pop	ds
	jmp	short $L7
$L5:	cmp	word ptr $S6,+000h
	jz	$L7
	mov	word ptr $S6,0000h
	mov	al,[bp+008h]
	mov	ah,25h
	mov	dx,$S9
	mov	cx,$S10
	mov	ds,cx
	int	21h
$L7:	pop	es
	pop	ds
	pop	si
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
