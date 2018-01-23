; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fir.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
FIR_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
FIR_TEXT	ENDS
DGROUP	GROUP	_DATA
; [006A]	; Linker - Pass two marker


	PUBLIC		_fir			; Located at 3:0000h Type = 1

_DATA	SEGMENT

$S3	db	000h
	db	001h
	db	002h
	db	003h
	db	004h
	db	005h
	db	006h
	db	007h
	db	008h
	db	009h
	db	00Ah
	db	00Bh
	db	00Ch
	db	00Dh
	db	00Eh
	db	00Fh
	db	010h
	db	011h
	db	012h
	db	013h
	db	014h
	db	015h
	db	016h
	db	017h
	db	018h
	db	019h
	db	01Ah
	db	01Bh
	db	01Ch
	db	01Dh
	db	01Eh
	db	01Fh
	db	' !"#$'
	db	'%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]'
	db	'^_`abcdefghijklmnopqrstuvwxyz{|}~'
	db	07Fh
	db	07Fh
	db	07Fh
	db	'~}|{zyxwvutsrqponmlkjihgfedcba`_^]\[ZYXWVUTSRQPONMLKJIHGFE'
	db	'DCBA@?>=<;:9876543210/.-,+*)(''&%$'
	db	'#"! '
	db	01Fh
	db	01Eh
	db	01Dh
	db	01Ch
	db	01Bh
	db	01Ah
	db	019h
	db	018h
	db	017h
	db	016h
	db	015h
	db	014h
	db	013h
	db	012h
	db	011h
	db	010h
	db	00Fh
	db	00Eh
	db	00Dh
	db	00Ch
	db	00Bh
	db	00Ah
	db	009h
	db	008h
	db	007h
	db	006h
	db	005h
	db	004h
	db	003h
	db	002h
	db	001h

_DATA	ENDS
FIR_TEXT	SEGMENT
	assume	cs: FIR_TEXT


_fir:	push	bp
	mov	bp,sp
	add	sp,-00Ah
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	push	edx
	push	es
	push	fs
	push	gs
	push	si
	push	di
	mov	fs,word ptr [bp+00Ch]
	mov	es,word ptr [bp+014h]
	mov	gs,word ptr [bp+008h]
	mov	cx,[bp+016h]
	mov	ax,[bp+00Eh]
	xor	bx,bx
	shr	cx,1
	mov	[bp-00Ah],cx
	mov	word ptr [bp-002h],0000h
$L9:	mov	dword ptr [bp-006h],00000000h
	mov	di,[bp+012h]
	mov	cx,[bp-00Ah]
	neg	cx
$L4:	mov	si,cx
	add	si,[bp-002h]
	cmp	si,+000h
	jl	$L1
	cmp	si,[bp+00Eh]
	jnl	$L1
	add	si,[bp+006h]
	mov	bl,gs:[si]
	mov	al,bl
	cmp	word ptr [bp+010h],+000h
	jz	$L2
	assume	ds: DGROUP
	mov	al,[bx+$S3]
$L2:	xor	ah,ah
	imul	word ptr es:[di]
	add	[bp-006h],ax
	adc	[bp-004h],dx
$L1:	add	di,+002h
	inc	cx
	cmp	cx,[bp-00Ah]
	jl	$L4
	mov	ax,[bp-006h]
	mov	dx,[bp-004h]
	idiv	word ptr [bp+018h]
	cmp	word ptr [bp+010h],+000h
	jz	$L5
	cmp	ax,+000h
	jnl	$L6
	mov	ax,0000h
	jmp	short $L7
$L6:	cmp	ax,00FFh
	jng	$L7
	mov	ax,00FFh
	jmp	short $L7
$L5:	cmp	ax,-080h
	jnl	$L8
	mov	ax,0FF80h
	jmp	short $L7
$L8:	cmp	ax,+07Fh
	jng	$L7
	mov	ax,007Fh
$L7:	mov	di,[bp+00Ah]
	mov	fs:[di],al
	inc	di
	mov	[bp+00Ah],di
	mov	cx,[bp-002h]
	inc	cx
	mov	[bp-002h],cx
	cmp	cx,[bp+00Eh]
	jl	$L9
	pop	di
	pop	si
	pop	gs
	pop	fs
	pop	es
	pop	edx
	pop	ds
	mov	sp,bp
	pop	bp
	retf

FIR_TEXT	ENDS
	END
