; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	inter.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [0067]	; Linker - Pass two marker


	PUBLIC		_inter			; Located at 1:0000h Type = 1
	PUBLIC		_interb			; Located at 1:0052h Type = 1
	PUBLIC		_interlb		; Located at 1:00A4h Type = 1
	PUBLIC		_interl			; Located at 1:0108h Type = 1
	PUBLIC		_interlib		; Located at 1:016Ch Type = 1

_text	SEGMENT
	assume	cs: _text


_inter:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+006h]
	dec	cx
	mov	dx,[bp+008h]
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0000h
	mov	bx,0000h
$L4:	mov	ax,[bx+si]
	mov	bl,al
	sub	al,ah
	pushf
	jg	$L1
	neg	al
$L1:	mul	byte ptr [bp-004h]
	mov	al,ah
	popf
	jl	$L2
	neg	al
$L2:	add	al,bl
	stosb
	add	[bp-004h],dx
	jnc	$L3
	add	word ptr [bp-002h],+001h
$L3:	mov	bx,[bp-003h]
	loop	$L4
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_interb:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+006h]
	dec	cx
	mov	dx,[bp+008h]
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0000h
	mov	bx,0000h
$L8:	mov	ax,[bx+si]
	mov	bl,al
	sub	al,ah
	pushf
	jnbe	$L5
	neg	al
$L5:	mul	byte ptr [bp-004h]
	mov	al,ah
	popf
	jc	$L6
	neg	al
$L6:	add	al,bl
	stosb
	add	[bp-004h],dx
	jnc	$L7
	add	word ptr [bp-002h],+001h
$L7:	mov	bx,[bp-003h]
	loop	$L8
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_interlb:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ch]
	les	di,dword ptr [bp+010h]
	mov	cx,[bp+006h]
	dec	cx
	mov	dx,[bp+008h]
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0000h
	mov	bx,0000h
$L13:	mov	ax,si
	add	ax,bx
	cmp	ax,-001h
	jc	$L9
	mov	si,0000h
$L9:	mov	ax,[bx+si]
	mov	bl,al
	sub	al,ah
	pushf
	jnbe	$L10
	neg	al
$L10:	mul	byte ptr [bp-003h]
	mov	al,ah
	popf
	jc	$L11
	neg	al
$L11:	add	al,bl
	stosb
	add	[bp-004h],dx
	jnc	$L12
	add	word ptr [bp-002h],+001h
$L12:	mov	ax,[bp+00Ah]
	add	[bp-002h],ax
	mov	bx,[bp-002h]
	loop	$L13
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_interl:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ch]
	les	di,dword ptr [bp+010h]
	mov	cx,[bp+006h]
	dec	cx
	mov	dx,[bp+008h]
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0000h
	mov	bx,0000h
$L18:	mov	ax,si
	add	ax,bx
	cmp	ax,-001h
	jc	$L14
	mov	si,0000h
$L14:	mov	ax,[bx+si]
	mov	bl,al
	sub	al,ah
	pushf
	jg	$L15
	neg	al
$L15:	mul	byte ptr [bp-003h]
	mov	al,ah
	popf
	jl	$L16
	neg	al
$L16:	add	al,bl
	stosb
	add	[bp-004h],dx
	jnc	$L17
	add	word ptr [bp-002h],+001h
$L17:	mov	ax,[bp+00Ah]
	add	[bp-002h],ax
	mov	bx,[bp-002h]
	loop	$L18
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_interlib:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ch]
	les	di,dword ptr [bp+010h]
	mov	cx,[bp+006h]
	dec	cx
	mov	dx,[bp+008h]
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0000h
	mov	bx,0000h
$L23:	mov	ax,si
	add	ax,bx
	cmp	ax,-001h
	jc	$L19
	mov	si,0000h
$L19:	mov	ax,[bx+si]
	mov	bl,al
	sub	al,ah
	pushf
	jnbe	$L20
	neg	al
$L20:	mul	byte ptr [bp-003h]
	mov	al,ah
	popf
	jc	$L21
	neg	al
$L21:	add	al,bl
	stosb
	add	[bp-004h],dx
	jnc	$L22
	add	word ptr [bp-002h],+001h
$L22:	mov	ax,[bp+00Ah]
	add	[bp-002h],ax
	mov	bx,[bp-002h]
	loop	$L23
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf

_text	ENDS
	END
