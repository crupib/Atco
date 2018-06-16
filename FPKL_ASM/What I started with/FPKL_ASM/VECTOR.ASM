; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	vector.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
VECTOR_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
VECTOR_TEXT	ENDS
DGROUP	GROUP	_DATA
; [00F0]	; Linker - Pass two marker


	PUBLIC		_xlate			; Located at 3:0000h Type = 1
	PUBLIC		_vectav			; Located at 3:0024h Type = 1
	PUBLIC		_compsl			; Located at 3:004Ch Type = 1
	PUBLIC		_compsc			; Located at 3:007Bh Type = 1
	PUBLIC		_compslt		; Located at 3:00ACh Type = 1
	PUBLIC		_compsct		; Located at 3:00E4h Type = 1
	PUBLIC		_avb3			; Located at 3:0137h Type = 1
	PUBLIC		_vavb3			; Located at 3:0179h Type = 1
	PUBLIC		_difb3			; Located at 3:01B1h Type = 1
	PUBLIC		_vdifb3			; Located at 3:01EEh Type = 1
	PUBLIC		_edge			; Located at 3:0229h Type = 1
	PUBLIC		_salb			; Located at 3:0283h Type = 1
	PUBLIC		_invert			; Located at 3:02B1h Type = 1

VECTOR_TEXT	SEGMENT
	assume	cs: VECTOR_TEXT


_xlate:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	push	fs
	lfs	si,dword ptr [bp+006h]
	les	di,dword ptr [bp+00Ah]
	lds	bx,dword ptr [bp+00Eh]
	mov	cx,[bp+012h]
$L1:	lods	byte ptr fs:[si]
	xlat
	stosb
	loop	$L1
	pop	fs
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vectav:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	lds	bx,dword ptr [bp+00Ch]
	lds	si,dword ptr [bp+008h]
	les	di,dword ptr [bp+010h]
	mov	cx,[bp+006h]
	mov	dh,00h
	mov	ah,00h
$L2:	lodsb
	mov	dl,[bx]
	add	ax,dx
	shr	ax,1
	stosb
	inc	bx
	loop	$L2
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_compsl:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Ah]
	mov	dx,[bp+006h]
	mov	bx,[bp+008h]
$L5:	mov	ah,00h
	mov	cx,bx
$L4:	lodsb
	cmp	al,ah
	jbe	$L3
	mov	ah,al
$L3:	loop	$L4
	mov	al,ah
	stosb
	dec	dx
	cmp	dx,+000h
	jnbe	$L5
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_compsc:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+006h]
	mov	ax,[bp+008h]
	cmp	ah,00h
	jnz	$L6
	shr	cx,1
	cld
	repz	movsw
	jmp	short $L7
$L6:	lodsb
	cmp	al,es:[di]
	jbe	$L8
	stosb
	loop	$L6
$L8:	inc	di
	loop	$L6
$L7:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_compslt:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Ah]
	mov	dx,[bp+006h]
	mov	bp,[bp+008h]
$L11:	mov	ah,00h
	mov	cx,bp
$L10:	lodsb
	cmp	al,ah
	jbe	$L9
	mov	ah,al
	mov	bl,[si+1FFFh]
$L9:	loop	$L10
	mov	al,ah
	stosb
	mov	es:[di+1FFFh],bl
	dec	dx
	cmp	dx,+000h
	jnbe	$L11
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_compsct:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+006h]
	mov	ax,[bp+008h]
	cmp	ah,00h
	jnz	$L12
	shr	cx,1
	cld
	repz	movsw
	lds	si,dword ptr [bp+00Ah]
	add	si,2000h
	les	di,dword ptr [bp+00Eh]
	add	di,2000h
	mov	cx,[bp+006h]
	mov	ax,[bp+008h]
	shr	cx,1
	cld
	repz	movsw
	jmp	short $L13
$L12:	lodsb
	cmp	al,es:[di]
	jbe	$L14
	stosb
	mov	bl,[si+1FFFh]
	mov	es:[di+1FFFh],bl
	loop	$L12
$L14:	inc	di
	loop	$L12
$L13:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_avb3:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	bx,[bp+010h]
	lds	si,dword ptr [bp+008h]
	mov	al,[si]
	inc	si
	les	di,dword ptr [bp+00Ch]
	mov	es:[di],al
	inc	di
	mov	cx,[bp+006h]
	sub	cx,+002h
$L15:	neg	bx
	mov	dl,[bx+si]
	xor	dh,dh
	neg	bx
	mov	al,[bx+si]
	xor	ah,ah
	add	dx,ax
	sar	dx,1
	lodsb
	xor	ah,ah
	add	ax,dx
	sar	ax,1
	stosb
	loop	$L15
	mov	bl,[si]
	mov	es:[di],bl
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vavb3:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	cx,[bp+006h]
	lds	bx,dword ptr [bp+008h]
	lds	si,dword ptr [bp+00Ch]
	les	di,dword ptr [bp+014h]
	lds	bp,dword ptr [bp+010h]
	sub	dx,dx
	sub	ax,ax
$L16:	mov	al,[bx]
	sub	ah,ah
	mov	dl,ds:[bp]
	sub	dh,dh
	add	dx,ax
	sar	dx,1
	lodsb
	add	ax,dx
	sar	ax,1
	stosb
	inc	bx
	inc	bp
	loop	$L16
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_difb3:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+008h]
	mov	al,[si]
	inc	si
	les	di,dword ptr [bp+00Ch]
	mov	es:[di],al
	inc	di
	mov	cx,[bp+006h]
	sub	cx,+002h
$L18:	mov	dl,[si+001h]
	xor	dh,dh
	mov	bl,[si-001h]
	xor	bh,bh
	sub	bx,dx
	sar	bx,1
	lodsb
	add	al,bl
	jnc	$L17
	mov	al,0FFh
$L17:	stosb
	loop	$L18
	mov	bl,[si]
	mov	es:[di],bl
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vdifb3:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
	mov	cx,[bp+006h]
	lds	bx,dword ptr [bp+008h]
	lds	si,dword ptr [bp+00Ch]
	les	di,dword ptr [bp+014h]
	lds	bp,dword ptr [bp+010h]
	sub	dx,dx
	sub	ax,ax
$L20:	mov	al,[bx]
	cbw
	mov	dx,ax
	mov	al,ds:[bp]
	cbw
	sub	dx,ax
	sar	dx,1
	lodsb
	add	al,dl
	jnc	$L19
	mov	al,0FFh
$L19:	stosb
	inc	bx
	inc	bp
	loop	$L20
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_edge:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
	mov	cx,[bp+006h]
	lds	bx,dword ptr [bp+008h]
	lds	si,dword ptr [bp+00Ch]
	les	di,dword ptr [bp+014h]
	lds	bp,dword ptr [bp+010h]
	sub	dx,dx
	sub	ax,ax
$L24:	mov	dl,[bx]
	xor	dh,dh
	mov	al,ds:[bp]
	xor	ah,ah
	sub	dx,ax
	jnl	$L21
	neg	dx
$L21:	push	dx
	mov	dl,[si-001h]
	xor	dh,dh
	mov	al,[si+001h]
	xor	ah,ah
	sub	ax,dx
	jnl	$L22
	neg	ax
$L22:	pop	dx
	add	dx,ax
	shr	dx,1
	lodsb
	add	al,dl
	jc	$L23
	stosb
	inc	bx
	inc	bp
	loop	$L24
	jmp	short $L25
$L23:	mov	al,0FFh
	stosb
	inc	bx
	inc	bp
	loop	$L24
$L25:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_salb:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
	mov	cx,[bp+006h]
	mov	dx,[bp+008h]
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Ah]
$L27:	lodsb
	sub	ah,ah
	xchg	cx,dx
	shl	ax,cl
	xchg	cx,dx
	cmp	ax,00FFh
	jng	$L26
	mov	ax,00FFh
$L26:	stosb
	loop	$L27
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_invert:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
	mov	cx,[bp+006h]
	lds	si,dword ptr [bp+008h]
	les	di,dword ptr [bp+008h]
$L28:	lodsb
	mov	ah,0FFh
	sub	ah,al
	mov	al,ah
	stosb
	loop	$L28
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

VECTOR_TEXT	ENDS
	END
