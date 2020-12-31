; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	dsplaf.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [0058]	; Linker - Pass two marker


	PUBLIC		_dsplaf			; Located at 1:0000h Type = 1
	PUBLIC		_dspla2			; Located at 1:0076h Type = 1
	PUBLIC		setvid			; Located at 1:00D8h Type = 1
	PUBLIC		chesc			; Located at 1:00EDh Type = 1

_text	SEGMENT
	assume	cs: _text


_dsplaf:
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
	call	setvid
	mov	dh,[bp+00Ah]
	mov	dl,[bp+00Ch]
	mov	ch,[bp+00Eh]
	mov	si,0000h
$L3:	mov	bl,dh
	mov	al,50h
	mul	bl
	mov	bh,00h
	mov	bl,dl
	add	ax,bx
	shl	ax,1
	mov	di,ax
$L7:	lds	bx,dword ptr [bp+006h]
	mov	al,[bx+si]
	cmp	al,00h
	jz	$L1
	cmp	al,0Ah
	jnz	$L2
	mov	dl,00h
	inc	dh
	inc	si
	jmp	short $L3
$L2:	cmp	al,1Bh
	jnz	$L4
	call	chesc
	jc	$L5
	add	si,+001h
	jmp	short $L6
$L5:	add	si,+002h
	jmp	short $L6
$L4:	cmp	al,20h
	jc	$L6
	mov	es:[di],al
	mov	es:[di+001h],ch
	inc	dl
	add	di,+002h
$L6:	inc	si
	jmp	short $L7
$L1:	mov	bh,00h
	dec	dl
	mov	ah,02h
	int	10h
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	pop	bp
	retf
_dspla2:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	call	near ptr setvid
	mov	cl,[bp+00Ah]
	mov	dh,[bp+00Ch]
	mov	dl,[bp+00Eh]
	mov	ch,[bp+010h]
	mov	si,0000h
$L10:	mov	bl,dh
	mov	al,50h
	mul	bl
	mov	bh,00h
	mov	bl,dl
	add	ax,bx
	shl	ax,1
	mov	di,ax
$L11:	lds	bx,dword ptr [bp+006h]
	mov	al,[bx+si]
	cmp	al,00h
	jz	$L8
	cmp	al,0Ah
	jz	$L8
	jmp	short $L9
	mov	dl,00h
	inc	dh
	inc	si
	jmp	short $L10
$L9:	mov	es:[di],al
	mov	es:[di+001h],ch
	inc	si
	inc	dl
	add	di,+002h
	mov	ax,si
	cmp	al,cl
	jnc	$L8
	jmp	short $L11
$L8:	mov	bh,00h
	dec	dl
	mov	ah,02h
	int	10h
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
setvid:	mov	ah,0Fh
	int	10h
	cmp	al,07h
	jz	$L12
	mov	ax,0B800h
	mov	es,ax
	jmp	short $L13
$L12:	mov	ax,0B000h
	mov	es,ax
$L13:	ret
chesc:	push	ax
	push	bx
	push	cx
	push	si
	push	ds
	push	es
	jmp	short $L14
$S16:	js	$L15
	sub	ax,4133h
	inc	bx
	dec	cx
	dec	dx
	dec	si
	push	cx
	push	dx
	push	bp
	push	di
	insb
	das
	db	069h
$L14:	clc
	add	si,+001h
	mov	al,[bx+si]
	mov	cx,0010h
	mov	bx,0000h
$L18:	cmp	al,byte ptr cs:[bx+$S16]
	jz	$L17
	inc	bx
	loop	$L18
	clc
	jmp	short $L19
$L17:	stc
$L19:	pop	es
	pop	ds
	pop	si
	pop	cx
	pop	bx
	pop	ax
	ret

	db	65 dup(?)
$L15	=	$ + 01221h
	ORG	00126h

_text	ENDS
	END
