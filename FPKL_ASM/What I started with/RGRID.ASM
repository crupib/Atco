; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	rgrid.C
; [000C]	.286p
	.287
	; Large Memory Model
; [0014]	; CodeView Enabled
RGRID_TEXT	SEGMENT	WORD PUBLIC 'CODE'
RGRID_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [0118]	; Linker - Pass two marker

	EXTRN		__aFftol:NEAR
	EXTRN		_pntplt:NEAR
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
	PUBLIC		_rgrid			; Located at 1:0000h Type = 1

RGRID_TEXT	SEGMENT
	assume	cs: RGRID_TEXT


_rgrid:	enter	00014h,000h
	push	di
	push	si
	mov	ax,[bp+008h]
	sub	ax,[bp+006h]
	mov	[bp-014h],ax
	dw	FIDRQQ - 02065h
	inc	si
	in	al,dx
	dw	FIDRQQ - 02165h
	jbe	$L1
	dw	FIDRQQ - 02665h
	pop	si
	clc
	dw	FIWRQQ - 06470h
	mov	ax,[bp+00Eh]
	db	02Bh
$L1:	inc	si
	or	al,89h
	inc	si
	in	al,dx
	dw	FIDRQQ - 02065h
	inc	si
	in	al,dx
	dw	FIDRQQ - 02165h
	jbe	$L2
	dw	FIDRQQ - 02665h
	pop	si
	db	0F2h
	dw	FIWRQQ - 06470h
	mov	ax,[bp+006h]
	mov	[bp-004h],ax
	jmp	near ptr $L3
$L6	db	0FFh
$L2:	inc	si
	cld
$L3:	mov	ax,[bp-004h]
	cmp	[bp+008h],ax
	jnl	$L4
	jmp	near ptr $L5
$L4:	push	[bp+014h]
	push	[bp+00Ch]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	push	[bp+014h]
	push	[bp+00Eh]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L6
$L5:	mov	ax,[bp+00Ch]
	mov	[bp-00Ah],ax
	jmp	near ptr $L7
$L10:	inc	word ptr [bp-00Ah]
$L7:	mov	ax,[bp-00Ah]
	cmp	[bp+00Eh],ax
	jnl	$L8
	db	0E9h
$L13:
	db	025h
	db	000h
$L8:	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp+006h]
	call	far ptr _pntplt
	add	sp,+006h
	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp+008h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L10
$L9	dw	FIDRQQ - 02065h
	inc	si
	db	00Ch
	dw	FIDRQQ - 02765h
	inc	si
	repnz	call	0000h:0000h
	mov	[bp-00Ah],ax
	jmp	near ptr $L11
$L24	dw	FIDRQQ - 02065h
	inc	si
	db	0F6h
	dw	FIDRQQ - 02765h
	inc	si
	repnz	call	0000h:0000h
	mov	[bp-00Ah],ax

$L11	dw	FIDRQQ - 02065h
	inc	si
	push	cs
	dw	FIDRQQ - 02165h
	db	066h
	db	0F6h
	dw	FIDRQQ - 02765h
	db	066h
	db	0F2h
	dw	FIDRQQ - 02765h
	push	ss
	dw	DGROUP:$S12
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L13
	jnc	$L14
	jmp	near ptr $L15
$L14:	mov	ax,[bp+006h]
	inc	ax
	mov	[bp-004h],ax
	jmp	near ptr $L16
$L19:	inc	word ptr [bp-004h]
$L16:	mov	ax,[bp+006h]
	add	ax,0004h
	cmp	ax,[bp-004h]
	jg	$L17
	jmp	near ptr $L18
$L17:	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L19
$L18:	mov	ax,[bp+008h]
	dec	ax
	mov	[bp-004h],ax
	jmp	near ptr $L20
$L23	db	0FFh
$L26:	dec	si
	cld
$L20:	mov	ax,[bp+008h]
	sub	ax,0004h
	cmp	ax,[bp-004h]
	jl	$L21
	jmp	near ptr $L22
$L21:	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L23
$L22:	jmp	$L24
$L15	dw	FIDRQQ - 02065h
	inc	si
	push	es
	dw	FIDRQQ - 02765h
	inc	si
	clc
	call	far ptr __aFftol
	mov	[bp-004h],ax
	jmp	near ptr $L25
$L37	dw	FIDRQQ - 02065h
	inc	si
	cld
	dw	FIDRQQ - 02765h
	inc	si
	clc
	call	far ptr __aFftol
	mov	[bp-004h],ax
$L25	dw	FIDRQQ - 02065h
	inc	si
	db	008h
	dw	FIDRQQ - 02165h
	cld
	dw	FIDRQQ - 02765h
	clc
	dw	FIDRQQ - 02765h
	push	ss
	dw	DGROUP:$S12
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L26
	jnc	$L27
	jmp	near ptr $L28
$L27:	mov	ax,[bp+00Ch]
	inc	ax
	mov	[bp-00Ah],ax
	jmp	near ptr $L29
$L32:	inc	word ptr [bp-00Ah]
$L29:	mov	ax,[bp+00Ch]
	add	ax,0004h
	cmp	ax,[bp-00Ah]
	jg	$L30
	jmp	near ptr $L31
$L30:	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L32
$L31:	mov	ax,[bp+00Eh]
	dec	ax
	mov	[bp-00Ah],ax
	jmp	near ptr $L33
$L36:	dec	word ptr [bp-00Ah]
$L33:	mov	ax,[bp+00Eh]
	sub	ax,0004h
	cmp	ax,[bp-00Ah]
	jl	$L34
	jmp	near ptr $L35
$L34:	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L36
$L35:	jmp	$L37
$L28:	cmp	word ptr [bp+012h],+000h
	jng	$L38
	jmp	near ptr $L39
$L38:	jmp	$L40
$L39:	cmp	word ptr [bp+012h],+005h
	jg	$L41
	jmp	near ptr $L42
$L41:	mov	word ptr [bp+012h],0005h
$L42:	dw	FIDRQQ - 02665h
	inc	si
	clc
	dw	FIDRQQ - 02165h
	jbe	$L42 + 0001Ah
	call	far ptr __aFftol
	mov	[bp-012h],ax
	dw	FIDRQQ - 02665h
	inc	si
	db	0F2h
	dw	FIDRQQ - 02165h
	jbe	$L43
	call	far ptr __aFftol
	mov	[bp-002h],ax
	cmp	word ptr [bp-012h],+001h
	jl	$L44
	jmp	near ptr $L45
$L44:
	db	0C7h
$L43:	inc	si
	out	dx,al
	add	[bx+si],ax
$L45:	cmp	word ptr [bp-002h],+001h
	jl	$L46
	jmp	near ptr $L47
$L46:	mov	word ptr [bp-002h],0001h
$L47	dw	FIDRQQ - 02065h
	inc	si
	db	00Ch
	dw	FIDRQQ - 02765h
	inc	si
	repnz	call	0000h:0000h
	mov	[bp-00Ah],ax
	jmp	near ptr $L48
$L58	dw	FIDRQQ - 02065h
	inc	si
	db	0F6h
	dw	FIDRQQ - 02765h
	inc	si
	repnz	call	0000h:0000h
	mov	[bp-00Ah],ax
$L48	dw	FIDRQQ - 02065h
	inc	si
	push	cs
	dw	FIDRQQ - 02165h
	db	066h
	db	0F6h
	dw	FIDRQQ - 02765h
	db	066h
	db	0F2h
	dw	FIDRQQ - 02765h
	push	ss
	dw	DGROUP:$S12
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L42 + 00015h
	jnc	$L49
	jmp	near ptr $L50
$L49:	mov	ax,[bp+006h]
	mov	[bp-004h],ax
	jmp	near ptr $L51
$L57:	mov	ax,[bp-012h]
	add	[bp-004h],ax
$L51:	mov	ax,[bp-004h]
	cmp	[bp+008h],ax
	jnl	$L52
	jmp	near ptr $L53
$L52:	mov	ax,[bp-004h]
	cmp	[bp+006h],ax
	db	075h
$L60:	add	bp,cx
	db	01Dh
	db	000h
$L54:	mov	ax,[bp+008h]
	sub	ax,[bp-004h]
	dec	ax
	jnz	$L56
	jmp	near ptr $L55
$L56:	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
$L55:	jmp	near ptr $L57
$L53:	jmp	near ptr $L58
$L50	dw	FIDRQQ - 02065h
	inc	si
	push	es
	dw	FIDRQQ - 02765h
	inc	si
	clc
	call	far ptr __aFftol
	mov	[bp-004h],ax
	jmp	near ptr $L59
$L69	dw	FIDRQQ - 02065h
	inc	si
	cld
	dw	FIDRQQ - 02765h
	inc	si
	clc
	call	far ptr __aFftol
	mov	[bp-004h],ax
$L59	dw	FIDRQQ - 02065h
	inc	si
	db	008h
	dw	FIDRQQ - 02165h
	cld
	dw	FIDRQQ - 02765h
	clc
	dw	FIDRQQ - 02765h
	push	ss
	dw	DGROUP:$S12
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L60
	jnc	$L61
	jmp	near ptr $L40
$L61:	mov	ax,[bp+00Ch]
	mov	[bp-00Ah],ax
	jmp	near ptr $L62
$L68:	mov	ax,[bp-002h]
	add	[bp-00Ah],ax
$L62:	mov	ax,[bp-00Ah]
	cmp	[bp+00Eh],ax
	jnl	$L63
	jmp	near ptr $L64
$L63:	mov	ax,[bp-00Ah]
	cmp	[bp+00Ch],ax
	jnz	$L65
	jmp	near ptr $L66
$L65:	mov	ax,[bp-00Ah]
	cmp	[bp+00Eh],ax
	jnz	$L67
	jmp	near ptr $L66
$L67:	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
$L66:	jmp	near ptr $L68
$L64:	jmp	near ptr $L69
$L40:	pop	si
	pop	di
	leave
	retf

RGRID_TEXT	ENDS
CONST	SEGMENT

$S12	db	000h
	db	000h
	db	080h
	db	0BFh

CONST	ENDS
	END
