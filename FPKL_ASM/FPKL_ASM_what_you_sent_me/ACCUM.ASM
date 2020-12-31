; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	accum.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [00DC]	; Linker - Pass two marker


	PUBLIC		_laccum			; Located at 2:0000h Type = 1
	PUBLIC		_ldivid			; Located at 2:006Ch Type = 1
	PUBLIC		_sdivid			; Located at 2:00A8h Type = 1
	PUBLIC		_macc			; Located at 2:00DAh Type = 1
	PUBLIC		_accumx			; Located at 2:011Ah Type = 1
	PUBLIC		_shiftx			; Located at 2:016Dh Type = 1
	PUBLIC		_shiftc			; Located at 2:0195h Type = 1
	PUBLIC		_twocmp			; Located at 2:01BDh Type = 1
	PUBLIC		_cvtbin			; Located at 2:01D9h Type = 1
	PUBLIC		_ishift			; Located at 2:01F5h Type = 1
	PUBLIC		_accum			; Located at 2:0228h Type = 1
	PUBLIC		_shift			; Located at 2:027Bh Type = 1
	PUBLIC		_shiftb			; Located at 2:02A3h Type = 1

_text	SEGMENT
	assume	cs: _text


_laccum:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	cx,[bp+012h]
	les	di,dword ptr [bp+00Ch]
	lds	si,dword ptr [bp+008h]
	cmp	byte ptr [bp+006h],00h
	jnbe	$L1
	cmp	byte ptr [bp+010h],00h
	jnz	$L2
$L3:	lodsb
	sub	ah,ah
	stosw
	sub	ax,ax
	stosw
	loop	$L3
	jmp	short $L4
$L2:	lodsb
	cbw
	stosw
	cwd
	mov	ax,dx
	stosw
	loop	$L2
	jmp	short $L4
$L1:	sub	ax,ax
	cmp	byte ptr [bp+010h],00h
	jnz	$L5
$L7:	lodsb
	add	es:[di],ax
	jc	$L6
	add	di,+004h
	loop	$L7
	jmp	short $L4
$L6:	inc	word ptr es:[di+002h]
	add	di,+004h
	loop	$L7
	jmp	short $L4
$L5:	lodsb
	cbw
	cwd
	add	es:[di],ax
	adc	es:[di+002h],dx
	add	di,+004h
	loop	$L5
$L4:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_ldivid:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	cx,[bp+012h]
	mov	bx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
	cmp	byte ptr [bp+010h],00h
	jnz	$L8
$L9:	lodsw
	mov	dx,[si]
	add	si,+002h
	div	bx
	stosb
	loop	$L9
	jmp	short $L10
$L8:	lodsw
	mov	dx,[si]
	add	si,+002h
	idiv	bx
	stosb
	loop	$L8
$L10:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_sdivid:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	cx,[bp+012h]
	mov	bx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
	cmp	byte ptr [bp+010h],00h
	jnz	$L11
$L12:	lodsw
	div	bl
	stosb
	loop	$L12
	jmp	short $L13
$L11:	lodsw
	idiv	bl
	stosb
	loop	$L11
$L13:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_macc:	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	cld
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0000h
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L14:	lodsb
	cbw
	mov	bx,es:[di]
	imul	bx
	add	[bp-004h],ax
	adc	[bp-002h],dx
	add	di,+002h
	loop	$L14
	mov	ax,[bp-002h]
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_accumx:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	cx,[bp+012h]
	les	di,dword ptr [bp+00Ch]
	lds	si,dword ptr [bp+008h]
	cmp	byte ptr [bp+006h],00h
	jnbe	$L15
	cmp	byte ptr [bp+010h],00h
	jnz	$L16
$L17:	lodsb
	sub	ah,ah
	stosw
	loop	$L17
	jmp	short $L18
$L16:	lodsb
	cbw
	stosw
	loop	$L16
	jmp	short $L18
$L15:	cmp	byte ptr [bp+010h],00h
	jnz	$L19
$L20:	lodsb
	sub	ah,ah
	mov	bx,es:[di]
	add	ax,bx
	stosw
	loop	$L20
	jmp	short $L18
$L19:	lodsb
	cbw
	mov	bx,es:[di]
	add	ax,bx
	stosw
	loop	$L19
$L18:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_shiftx:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,[bp+010h]
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L21:	lodsw
	sar	ax,cl
	stosb
	dec	dx
	cmp	dx,+000h
	jnbe	$L21
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_shiftc:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,[bp+010h]
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L22:	lodsb
	sar	al,cl
	stosb
	dec	dx
	cmp	dx,+000h
	jnbe	$L22
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_twocmp:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L23:	lodsb
	sub	al,80h
	stosb
	loop	$L23
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_cvtbin:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L24:	lodsb
	add	al,80h
	stosb
	loop	$L24
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_ishift:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	dx,[bp+010h]
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L27:	lodsw
	sar	ax,cl
	cmp	ax,+07Fh
	jng	$L25
	mov	al,7Fh
	jmp	short $L26
$L25:	cmp	ax,-07Fh
	jnl	$L26
	mov	al,81h
$L26:	stosb
	dec	dx
	cmp	dx,+000h
	jnbe	$L27
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_accum:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	cx,[bp+012h]
	les	di,dword ptr [bp+00Ch]
	lds	si,dword ptr [bp+008h]
	cmp	byte ptr [bp+006h],00h
	jnbe	$L28
	cmp	byte ptr [bp+010h],00h
	jnz	$L29
$L30:	lodsb
	sub	ah,ah
	stosw
	loop	$L30
	jmp	short $L31
$L29:	lodsb
	cbw
	stosw
	loop	$L29
	jmp	short $L31
$L28:	cmp	byte ptr [bp+010h],00h
	jnz	$L32
$L33:	lodsb
	sub	ah,ah
	mov	bx,es:[di]
	add	ax,bx
	stosw
	loop	$L33
	jmp	short $L31
$L32:	lodsb
	cbw
	mov	bx,es:[di]
	add	ax,bx
	stosw
	loop	$L32
$L31:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_shift:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,[bp+010h]
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L34:	lodsw
	sar	ax,cl
	stosb
	dec	dx
	cmp	dx,+000h
	jnbe	$L34
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_shiftb:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,[bp+010h]
	mov	cx,[bp+00Eh]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L35:	lodsb
	shr	al,cl
	stosb
	dec	dx
	cmp	dx,+000h
	jnbe	$L35
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

_text	ENDS
	END
