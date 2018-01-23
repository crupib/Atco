; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	power.C
; [000C]	.286p
	.287
	; Large Memory Model
; [0014]	; CodeView Enabled
POWER_TEXT	SEGMENT	WORD PUBLIC 'CODE'
POWER_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [0114]	; Linker - Pass two marker

	EXTRN		_sqrt:NEAR
	EXTRN		_four1:NEAR
	EXTRN		FIWRQQ:ABS
	EXTRN		FIDRQQ:ABS
	EXTRN		FIERQQ:ABS
	EXTRN		FISRQQ:ABS
	EXTRN		FJSRQQ:ABS
	EXTRN		FIARQQ:ABS
	EXTRN		FJARQQ:ABS
	EXTRN		FICRQQ:ABS
	EXTRN		FJCRQQ:ABS
	EXTRN		__fltused:ABS
	PUBLIC		_power			; Located at 1:0000h Type = 1

POWER_TEXT	SEGMENT
	assume	cs: POWER_TEXT


_power:	enter	00014h,000h
	push	di
	push	si
	mov	ax,[bp+010h]
	sar	ax,1
	mov	[bp-008h],ax
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L1
$L6:	inc	word ptr [bp-006h]

$L1:	mov	ax,[bp+010h]
	shl	ax,1
	cmp	ax,[bp-006h]
	jg	$L2
	jmp	near ptr $L3
$L2:	mov	bx,[bp-006h]
	shl	bx,02h
	les	si,dword ptr [bp+00Ch]
	assume	ds: DGROUP
	mov	ax,$S4
	mov	dx,$S5
	mov	es:[bx+si],ax
	mov	es:[bx+si+002h],dx
	jmp	near ptr $L6
$L3:	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L7
$L10:	inc	word ptr [bp-006h]
$L7:	mov	ax,[bp+00Ah]
	cmp	[bp-006h],ax
	jl	$L8
	jmp	near ptr $L9
$L8:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-006h]
	mov	al,es:[bx+si]
	cbw
	mov	[bp-00Ch],ax
	dw	FIDRQQ - 02065h
	inc	si
	hlt
	mov	bx,[bp-006h]
	shl	bx,03h
	les	si,dword ptr [bp+00Ch]
	dw	FIERQQ + 0269Bh
	fstp	dword ptr [bx+si]
	dw	FIWRQQ - 06470h
	jmp	near ptr $L10
$L9:	push	+001h
	push	[bp+010h]
	mov	ax,[bp+00Ch]
	mov	dx,[bp+00Eh]
	sub	ax,0004h
	push	dx
	push	ax
	call	far ptr _four1
	add	sp,+008h
	mov	ax,0000h
	mov	[bp-006h],ax
	mov	[bp-00Ah],ax
	jmp	near ptr $L11
$L14:	inc	word ptr [bp-006h]
$L11:	mov	ax,[bp-008h]
	cmp	[bp-006h],ax
	jl	$L12
	jmp	near ptr $L13
$L12:	add	word ptr [bp-00Ah],+002h
	mov	ax,[bp-00Ah]
	inc	ax
	mov	[bp-004h],ax
	mov	bx,[bp-004h]
	shl	bx,02h
	les	si,dword ptr [bp+00Ch]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si]
	dw	FIDRQQ - 02665h
	push	si
	db	0F0h
	dw	FIDRQQ - 02765h
	dec	si
	lock	mov	bx,[bp-00Ah]
	shl	bx,02h
	les	si,dword ptr [bp+00Ch]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si]
	dw	FIDRQQ - 02665h
	push	si
	in	al,dx
	dw	FIDRQQ - 02765h
	dec	si
	in	al,dx
	dw	FIDRQQ - 02165h
	rol	[bp+di+08ECh],8Bh
	db	0DCh
	dw	FIDRQQ - 02265h
	pop	ds
	dw	FIWRQQ - 06470h
$L20:	call	far ptr _sqrt
	add	sp,+008h
	mov	es,dx
	mov	bx,ax
	dw	FIERQQ + 0269Bh
	fld	qword ptr [bx]
	mov	bx,[bp-006h]
	shl	bx,02h
	les	si,dword ptr [bp+00Ch]
	dw	FIERQQ + 0269Bh
	fstp	dword ptr [bx+si]
	dw	FIWRQQ - 06470h
	jmp	near ptr $L14
$L13:	mov	word ptr [bp-006h],0000h
	les	bx,dword ptr [bp+00Ch]
	mov	ax,es:[bx]
	mov	dx,es:[bx+002h]
$L25	=	$ - 00001h
	mov	$S15,ax
	mov	$S16,dx
	jmp	near ptr $L17
$L23:	inc	word ptr [bp-006h]
$L17:	mov	ax,[bp-008h]
	cmp	[bp-006h],ax
	jl	$L18
	jmp	near ptr $L19
$L18:	mov	bx,[bp-006h]
	shl	bx,02h
	les	si,dword ptr [bp+00Ch]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si]
	dw	FIDRQQ - 02765h
	push	ss
	dw	DGROUP:$S15
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L20
	jnbe	$L21
	jmp	near ptr $L22
$L21:	mov	bx,[bp-006h]
	shl	bx,02h
	les	si,dword ptr [bp+00Ch]
	mov	ax,es:[bx+si]
	mov	dx,es:[bx+si+002h]
	mov	$S15,ax
	mov	$S16,dx
$L22:	jmp	near ptr $L23

$L19	dw	FIDRQQ - 02665h
	push	es
	dw	DGROUP:$S15
	dw	FIDRQQ - 02365h
	push	ss
	dw	DGROUP:$S24
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L25
	jz	$L26
	jmp	near ptr $L27
$L26:	mov	ax,$S28
	mov	dx,$S29
	mov	$S15,ax
	mov	$S16,dx

$L27	dw	FIDRQQ - 02265h
	push	es
	dw	DGROUP:$S30
	dw	FIDRQQ - 02765h
	db	036h
	dw	DGROUP:$S15
	dw	FIDRQQ - 02665h
	push	ds
	dw	DGROUP:$S31
	dw	FIWRQQ - 06470h
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L32
$L35:	inc	word ptr [bp-006h]
$L32:	mov	ax,[bp-008h]
	cmp	[bp-006h],ax
	jl	$L33
	jmp	near ptr $L34
$L33:	mov	bx,[bp-006h]
	shl	bx,02h
	les	si,dword ptr [bp+00Ch]
	dw	FIDRQQ - 02665h
	push	es
	dw	DGROUP:$S31
	dw	FIERQQ + 0269Bh
	fmul	dword ptr [bx+si]
	dw	FIERQQ + 0269Bh
	fstp	dword ptr [bx+si]
	dw	FIWRQQ - 06470h
	jmp	near ptr $L35
$L34:	pop	si
	pop	di
	leave
	retf

POWER_TEXT	ENDS
CONST	SEGMENT

$S4	dw	00000h
$S5	dw	00000h

$S24	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
$S28	dw	00000h
$S29	dw	03F80h

$S30	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	0E0h
	db	06Fh
	db	040h

CONST	ENDS
_BSS	SEGMENT

$S31	dd	1 dup(?)
$S15	dw	1 dup(?)
$S16	dw	1 dup(?)

_BSS	ENDS
	END
