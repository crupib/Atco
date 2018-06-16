; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	four1.C
; [000C]	.286p
	.287
	; Large Memory Model
; [0014]	; CodeView Enabled
FOUR1_TEXT	SEGMENT	WORD PUBLIC 'CODE'
FOUR1_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [010B]	; Linker - Pass two marker

	EXTRN		_sin:NEAR
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
	PUBLIC		_four1			; Located at 1:0000h Type = 1

FOUR1_TEXT	SEGMENT
	assume	cs: FOUR1_TEXT


_four1:	enter	0002Eh,000h
	push	di
	push	si
	mov	ax,[bp+00Ah]
	shl	ax,1
	mov	[bp-028h],ax
	mov	word ptr [bp-020h],0001h
	mov	word ptr [bp-01Eh],0001h
	jmp	near ptr $L1
$L10:	add	word ptr [bp-01Eh],+002h
$L1:	mov	ax,[bp-01Eh]
	cmp	[bp-028h],ax
	jg	$L2
	jmp	$L3
$L2:	mov	ax,[bp-01Eh]
	cmp	[bp-020h],ax
	jg	$L4
	jmp	$L5
$L4:	mov	bx,[bp-020h]
	shl	bx,02h
	les	si,dword ptr [bp+006h]
	mov	ax,es:[bx+si]
	mov	dx,es:[bx+si+002h]
	mov	[bp-014h],ax
	mov	[bp-012h],dx
	mov	bx,[bp-01Eh]
	shl	bx,02h
	les	si,dword ptr [bp+006h]
	mov	ax,es:[bx+si]
	mov	dx,es:[bx+si+002h]
	mov	bx,[bp-020h]
	shl	bx,02h
	les	si,dword ptr [bp+006h]
	mov	es:[bx+si],ax
	mov	es:[bx+si+002h],dx
	mov	bx,[bp-01Eh]
	shl	bx,02h
	les	si,dword ptr [bp+006h]
	mov	ax,[bp-014h]
	mov	dx,[bp-012h]
	mov	es:[bx+si],ax
	mov	es:[bx+si+002h],dx
	mov	si,[bp-020h]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+si+004h]
	mov	dx,es:[bx+si+006h]
	mov	[bp-014h],ax
	mov	[bp-012h],dx
	mov	si,[bp-01Eh]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+si+004h]
	mov	dx,es:[bx+si+006h]
	mov	si,[bp-020h]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	mov	es:[bx+si+004h],ax
	mov	es:[bx+si+006h],dx
	mov	ax,[bp-014h]
	mov	dx,[bp-012h]
	mov	si,[bp-01Eh]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	mov	es:[bx+si+004h],ax
	mov	es:[bx+si+006h],dx
$L5:	mov	ax,[bp-028h]
	sar	ax,1
	mov	[bp-026h],ax
$L9:	cmp	word ptr [bp-026h],+002h
	jnl	$L6
	jmp	near ptr $L7
$L6:	mov	ax,[bp-026h]
	cmp	[bp-020h],ax
	jg	$L8
	jmp	near ptr $L7
$L8:	mov	ax,[bp-026h]
	sub	[bp-020h],ax
	sar	word ptr [bp-026h],1
	jmp	near ptr $L9
$L7:	mov	ax,[bp-026h]
	add	[bp-020h],ax
	jmp	$L10
$L3:	mov	word ptr [bp-00Ah],0002h

$L33:	mov	ax,[bp-028h]
	cmp	[bp-00Ah],ax
	jl	$L11
	jmp	$L12
$L11:	mov	ax,[bp-00Ah]
	shl	ax,1
	mov	[bp-00Ch],ax
	mov	ax,[bp-00Ah]
	imul	word ptr [bp+00Ch]
	mov	[bp-02Eh],ax
	dw	FIDRQQ - 02065h
	inc	si
	db	0D2h
	dw	FIDRQQ - 02365h
	db	03Eh
	dw	DGROUP:$S13
	dw	FIDRQQ - 02665h
	pop	si
	db	0F0h
	dw	FIWRQQ - 06470h
	dw	FIDRQQ - 02665h
	inc	si
	db	0F0h
	dw	FIDRQQ - 02365h
	push	cs
	dw	DGROUP:$S14
	sub	sp,+008h
	mov	bx,sp
	dw	FIDRQQ - 02265h
	pop	ds
	dw	FIWRQQ - 06470h
	call	far ptr _sin
	add	sp,+008h
	mov	es,dx
	mov	bx,ax
	dw	FIERQQ + 0269Bh
	fld	qword ptr [bx]
	dw	FIDRQQ - 02665h
	pop	si
	db	0DCh
	dw	FIWRQQ - 06470h
	dw	FIDRQQ - 02665h
	inc	si
	db	0DCh
	dw	FIDRQQ - 02765h
	dec	si
	db	0DCh
	dw	FIDRQQ - 02365h
	push	cs
	dw	DGROUP:$S15
	dw	FIDRQQ - 02665h
	pop	si
	db	0E4h
	dw	FIWRQQ - 06470h
	dw	FIDRQQ - 02665h
	inc	si
	lock	sub	sp,+008h
	mov	bx,sp
	dw	FIDRQQ - 02265h
	pop	ds
	dw	FIWRQQ - 06470h
	call	far ptr _sin
	add	sp,+008h
	mov	es,dx
	mov	bx,ax
	dw	FIERQQ + 0269Bh
	fld	qword ptr [bx]
	dw	FIDRQQ - 02665h
	pop	si
	clc
	dw	FIWRQQ - 06470h
	assume	ds: DGROUP
	mov	ax,$S16
	mov	dx,$S17
	mov	[bp-018h],ax
	mov	[bp-016h],dx
	mov	ax,$S18
	mov	dx,$S19
	mov	[bp-004h],ax
	mov	[bp-002h],dx
	mov	word ptr [bp-026h],0001h
	jmp	near ptr $L20
$L32:	add	word ptr [bp-026h],+002h
$L20:	mov	ax,[bp-00Ah]
	db	039h
$L27:	inc	si
	fidivr	dword ptr [si+003h]
	jmp	$L22
$L21:	mov	ax,[bp-026h]
	mov	[bp-01Eh],ax
	jmp	near ptr $L23
$L31:	mov	ax,[bp-00Ch]
	add	[bp-01Eh],ax
$L23:	mov	ax,[bp-01Eh]
	cmp	[bp-028h],ax
	jnl	$L24
	jmp	$L25
$L24:	mov	ax,[bp-00Ah]
	add	ax,[bp-01Eh]
	mov	[bp-020h],ax
	mov	bx,[bp-020h]
$L29:	shl	bx,02h
	les	si,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si]
	dw	FIDRQQ - 02765h
	dec	si
	call	$L26
	loopnz	$L27
	out	002h,al
	les	bx,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si+004h]
	dw	FIDRQQ - 02765h
	dec	si
	cld
	dw	FIDRQQ - 02165h
	db	0E9h
	dw	FIDRQQ - 02665h
	pop	si
	in	al,dx
	dw	FIWRQQ - 06470h
	mov	si,[bp-020h]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si+004h]
	dw	FIDRQQ - 02765h
	dec	si
	call	$L28
	loopnz	$L29
	jcxz	$L30
	les	si,dword ptr [bp+006h]
$L30	=	$ - 00001h
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si]
	dw	FIDRQQ - 02765h
	dec	si
	cld
	dw	FIDRQQ - 02165h
	db	0C1h
	dw	FIDRQQ - 02665h
	pop	si
	db	0D4h
	dw	FIWRQQ - 06470h
	mov	bx,[bp-01Eh]
	shl	bx,02h
	les	si,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si]
	dw	FIDRQQ - 02765h
	in	al,dx
	mov	bx,[bp-020h]
	shl	bx,02h
	les	si,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fstp	dword ptr [bx+si]
	dw	FIWRQQ - 06470h
	mov	si,[bp-01Eh]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fld	dword ptr [bx+si+004h]
	dw	FIDRQQ - 02765h
	db	066h
	db	0D4h
	mov	si,[bp-020h]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fstp	dword ptr [bx+si+004h]
	dw	FIWRQQ - 06470h
	mov	bx,[bp-01Eh]
	shl	bx,02h
	les	si,dword ptr [bp+006h]
	dw	FIDRQQ - 02665h
	inc	si
	in	al,dx
	dw	FIERQQ + 0269Bh
	fadd	dword ptr [bx+si]
	dw	FIERQQ + 0269Bh
	fstp	dword ptr [bx+si]
	dw	FIWRQQ - 06470h
	dw	FIDRQQ - 02665h
	inc	si
	db	0D4h
	mov	si,[bp-01Eh]
	shl	si,02h
	les	bx,dword ptr [bp+006h]
	dw	FIERQQ + 0269Bh
	fadd	dword ptr [bx+si+004h]
	dw	FIERQQ + 0269Bh
	fstp	dword ptr [bx+si+004h]
	dw	FIWRQQ - 06470h
	jmp	$L31
$L25	dw	FIDRQQ - 02665h
	inc	si
	db	0E8h
	dw	FIDRQQ - 02665h
	push	si
	db	0DCh
	dw	FIWRQQ - 06470h
	dw	FIDRQQ - 02765h
	dec	si
	db	0E4h
	dw	FIDRQQ - 02665h
	inc	si
	cld
	dw	FIDRQQ - 02765h
	dec	si
	clc
	dw	FIDRQQ - 02165h
	db	0E9h
	dw	FIDRQQ - 02765h
	inc	si
	db	0E8h
	dw	FIDRQQ - 02665h
	pop	si
	db	0E8h
	dw	FIWRQQ - 06470h
	dw	FIDRQQ - 02665h
	db	0E8h
	dw	FIDRQQ - 02765h
	inc	si
	db	0E4h
	dw	FIDRQQ - 02765h
	dec	si
	cld
	dw	FIDRQQ - 02665h
	inc	si
	clc
	dw	FIDRQQ - 02765h
	dec	si
	db	0DCh
	dw	FIDRQQ - 02165h
	db	0C1h
	dw	FIDRQQ - 02665h
	pop	si
	cld
	dw	FIWRQQ - 06470h
	jmp	$L32
$L22:	mov	ax,[bp-00Ch]
	mov	[bp-00Ah],ax
	jmp	$L33
$L12:	pop	si
	pop	di
	leave
	retf

	db	23983 dup(?)
$L28	=	$ + 01221h	db	6099 dup(?)
$L26	=	$ + 01221h	ORG	00302h

FOUR1_TEXT	ENDS
CONST	SEGMENT

$S13	db	01Ch
	db	'-DT'
	db	0FBh
	db	021h
	db	019h
	db	040h
$S14	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	0E0h
	db	03Fh
$S15	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	0C0h
$S16	dw	00000h
$S17	dw	03F80h
$S18	dw	00000h
$S19	dw	00000h

CONST	ENDS
	END
