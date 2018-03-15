; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	lcplt.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [0099]	; Linker - Pass two marker

	EXTRN		_nucol:WORD
	EXTRN		_vm:ABS
	EXTRN		_vidseg:WORD
	EXTRN		_video:WORD
	PUBLIC		_lcplt			; Located at 2:0000h Type = 1
	PUBLIC		plbig			; Located at 2:00D6h Type = 1
	PUBLIC		_mcplt			; Located at 2:00FEh Type = 1
	PUBLIC		pmbig			; Located at 2:01CAh Type = 1

_data	SEGMENT

$S5	dw	00008h

$S4	dw	1 dup(?)
$S3	dw	1 dup(?)
$S1	dw	00000h
$S6	dw	00000h
$S7	dw	00000h

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_lcplt:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,03CEh
	mov	ax,0003h
	out	dx,ax
	mov	ax,0005h
	out	dx,ax
	mov	ax,0FF08h
	out	dx,ax
	mov	dx,03C4h
	mov	al,02h
	mov	ah,[bp+00Eh]
	out	dx,ax
	assume	ds: DGROUP
	cmp	word ptr $S1,+000h
	jnz	$L2
	push	bp
	mov	bh,06h
	mov	al,30h
	mov	ah,11h
	int	10h
	mov	$S3,bp
	mov	word ptr $S1,es
	pop	bp
$L2:	mov	dx,[bp+00Ah]
	mov	bx,[bp+00Ch]
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,dx
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	mov	$S4,bx
	mov	word ptr $S5,0010h
	mov	word ptr $S6,0000h
	mov	word ptr $S7,0000h
$L11:	les	bx,dword ptr [bp+006h]
	add	bx,$S6
	mov	al,es:[bx]
	cmp	al,00h
	jnz	$L8
	jmp	short $L9
$L8:	mov	ah,00h
	mov	bx,$S5
	mul	bl
	mov	bx,$S3
	add	bx,ax
	add	bx,$S5
	dec	bx
	push	ds
	mov	cx,$S5
	push	bp
	mov	bp,_nucol
	mov	di,$S4
	add	di,$S7
	mov	es,word ptr _vidseg
	mov	si,bx
	mov	ds,word ptr $S1
	std
	sub	bx,bx
$L10:	lodsb
	push	di
	call	near ptr plbig
	call	near ptr plbig
	call	near ptr plbig
	call	near ptr plbig
	pop	di
	sub	di,bp
	sub	di,bp
	sub	di,bp
	sub	di,bp
	loop	$L10
	pop	bp
	pop	ds
	inc	word ptr $S6
	add	word ptr $S7,+004h
	jmp	short $L11
$L9:	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
plbig:	push	di
	rol	al,1
	rol	al,1
	mov	bl,al
	and	bl,03h
	mov	ah,byte ptr cs:[bx+$S12]
	mov	es:[di],ah
	sub	di,bp
	mov	es:[di],ah
	sub	di,bp
	mov	es:[di],ah
	sub	di,bp
	mov	es:[di],ah
	pop	di
	inc	di
	ret
$S12:	add	[bx],cl
	db	0F0h
	db	0FFh
_mcplt:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,03CEh
	mov	ax,0003h
	out	dx,ax
	mov	ax,0005h
	out	dx,ax
	mov	ax,0FF08h
	out	dx,ax
	mov	dx,03C4h
	mov	al,02h
	mov	ah,[bp+00Eh]
	out	dx,ax
	cmp	word ptr $S1,+000h
	jnz	$L13
	push	bp
	mov	bh,06h
	mov	al,30h
	mov	ah,11h
	int	10h
	mov	$S3,bp
	mov	word ptr $S1,es
	pop	bp
$L13:	mov	dx,[bp+00Ah]
	mov	bx,[bp+00Ch]
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,dx
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	mov	$S4,bx
	mov	word ptr $S5,0010h
	mov	word ptr $S6,0000h
	mov	word ptr $S7,0000h
$L17:	les	bx,dword ptr [bp+006h]
	add	bx,$S6
	mov	al,es:[bx]
	cmp	al,00h
	jnz	$L14
	jmp	short $L15
$L14:	mov	ah,00h
	mov	bx,$S5
	mul	bl
	mov	bx,$S3
	add	bx,ax
	add	bx,$S5
	dec	bx
	push	ds
	mov	cx,$S5
	push	bp
	mov	bp,_nucol
	mov	di,$S4
	add	di,$S7
	mov	es,word ptr _vidseg
	mov	si,bx
	mov	ds,word ptr $S1
	std
	sub	bx,bx
$L16:	lodsb
	push	di
	call	near ptr pmbig
	call	near ptr pmbig
	pop	di
	sub	di,bp
	sub	di,bp
	loop	$L16
	pop	bp
	pop	ds
	inc	word ptr $S6
	add	word ptr $S7,+002h
	jmp	short $L17
$L15:	cld
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
pmbig:	push	di
	rol	al,1
	rol	al,1
	rol	al,1
	rol	al,1
	mov	bl,al
	and	bl,0Fh
	mov	ah,byte ptr cs:[bx+$S18]
	mov	es:[di],ah
	sub	di,bp
	mov	es:[di],ah
	pop	di
	inc	di
	ret
$S18:	add	[bp+di],al
	or	al,0Fh
	xor	[bp+di],dh
	cmp	al,3Fh
	rol	bl,0CCh
	iret
		lock
	repz	cld
	db	0FFh

_text	ENDS
	END
