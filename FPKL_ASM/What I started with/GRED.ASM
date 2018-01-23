; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	gred.C
; [000B]	.286p
	.287
	; Large Memory Model
; [0013]	; CodeView Enabled
GRED_TEXT	SEGMENT	WORD PUBLIC 'CODE'
GRED_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [010A]	; Linker - Pass two marker

	EXTRN		_blnkln:NEAR
	EXTRN		_vgawrite:NEAR
	EXTRN		_getxsize:NEAR
	EXTRN		_strlen:NEAR
	EXTRN		_getkey:NEAR
	EXTRN		_vgaread:NEAR
	EXTRN		_funct:NEAR
	EXTRN		_chrplt:NEAR
	PUBLIC		_gred			; Located at 1:0000h Type = 1
	PUBLIC		_gbox			; Located at 1:03ADh Type = 1

GRED_TEXT	SEGMENT
	assume	cs: GRED_TEXT


_gred:	enter	00054h,000h
	push	di
	push	si
	mov	word ptr [bp-02Ch],000Dh
	mov	word ptr [bp-032h],0008h
	mov	word ptr [bp-050h],4B00h
	mov	word ptr [bp-02Ah],4D00h
	mov	word ptr [bp-044h],7300h
	mov	word ptr [bp-022h],7400h
	mov	word ptr [bp-020h],4900h
	mov	word ptr [bp-054h],5100h
	mov	word ptr [bp-040h],4700h
	mov	word ptr [bp-038h],4F00h
	mov	word ptr [bp-030h],5200h
	mov	word ptr [bp-02Eh],5300h
	mov	word ptr [bp-036h],4800h
	mov	word ptr [bp-028h],5000h
	mov	word ptr [bp-04Ah],001Bh
	cmp	word ptr [bp+016h],+020h
	jl	$L1
	jmp	near ptr $L2
$L1:	add	word ptr [bp+016h],+020h
$L2:	cmp	word ptr [bp+016h],+040h
	jl	$L3
	jmp	near ptr $L4
$L3:	add	word ptr [bp+016h],+020h
$L4:	cmp	word ptr [bp+018h],+020h
	jl	$L5
	jmp	near ptr $L6
$L5:	add	word ptr [bp+018h],+020h
$L6:	cmp	word ptr [bp+018h],+040h
	jl	$L7
	jmp	near ptr $L8
$L7:	add	word ptr [bp+018h],+020h
$L8:	mov	ax,[bp+018h]
	add	ax,0010h
	mov	[bp-04Eh],ax
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _strlen
	add	sp,+004h
	cmp	ax,0050h
	jnl	$L9
	jmp	near ptr $L10
$L9:	mov	ax,0050h
	jmp	near ptr $L11
$L10:	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _strlen
	add	sp,+004h
$L11:	mov	[bp-052h],ax
	mov	ax,[bp-052h]
	shl	ax,03h
	mov	[bp-006h],ax
	push	[bp+00Eh]
	push	[bp+00Ch]
	call	far ptr _strlen
	add	sp,+004h
	cmp	ax,0050h
	jnl	$L12
	jmp	near ptr $L13
$L12:	mov	ax,0050h
	jmp	near ptr $L14
$L13:	push	[bp+00Eh]
	push	[bp+00Ch]
	call	far ptr _strlen
	add	sp,+004h
$L14:	mov	[bp-01Ch],ax
	mov	ax,[bp-01Ch]
	shl	ax,03h
	mov	[bp-01Eh],ax
	mov	ax,[bp-052h]
	add	ax,[bp+010h]
	add	ax,0003h
	mov	[bp-026h],ax
	cmp	word ptr [bp+012h],+000h
	jl	$L15
	jmp	near ptr $L16
$L15:	call	far ptr _getxsize
	mov	[bp+012h],ax
	mov	ax,[bp+012h]
	sub	ax,[bp-026h]
	dec	ax
	shl	ax,02h
	mov	[bp+012h],ax
$L16:	mov	ax,[bp+012h]
	add	ax,0010h
	mov	[bp-03Eh],ax
	mov	ax,[bp+014h]
	add	ax,0010h
	mov	[bp-048h],ax
	mov	ax,[bp-006h]
	add	ax,[bp-03Eh]
	add	ax,0008h
	mov	[bp-024h],ax
	mov	word ptr [bp-03Ah],0000h
	push	0EA60h
	push	13ECh
	mov	ax,[bp+014h]
	add	ax,0032h
	push	ax
	push	+000h
	call	far ptr _vgaread
	add	sp,+008h
	mov	word ptr [bp-03Ch],0000h
	jmp	near ptr $L17
$L20:	inc	word ptr [bp-03Ch]
$L17:	cmp	word ptr [bp-03Ch],+010h
	jl	$L18
	jmp	near ptr $L19
$L18:	push	[bp-026h]
	mov	ax,[bp-03Ch]
	add	ax,[bp-048h]
	push	ax
	mov	ax,[bp-03Eh]
	sub	ax,0008h
	push	ax
	call	far ptr _blnkln
	add	sp,+006h
	jmp	near ptr $L20
$L19:	push	+000h
	call	far ptr _funct
	add	sp,+002h
	push	[bp+016h]
	push	+003h
	push	[bp-026h]
	push	[bp+014h]
	push	[bp+012h]
	call	far ptr _gbox
	add	sp,+00Ah
	push	[bp+016h]
	push	[bp-048h]
	push	[bp-03Eh]
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _chrplt
	add	sp,+00Ah
	mov	word ptr [bp-03Ch],0000h
	jmp	near ptr $L21
$L30:	inc	word ptr [bp-03Ch]
$L21:	mov	ax,[bp+010h]
	cmp	[bp-03Ch],ax
	jl	$L22
	jmp	near ptr $L23
$L22:	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp-03Ch]
	cmp	byte ptr es:[bx+si],00h
	jz	$L24
	jmp	near ptr $L25
$L24:	mov	ax,[bp-03Ch]
	mov	[bp-042h],ax
	jmp	near ptr $L26
$L29:	inc	word ptr [bp-042h]
$L26:	mov	ax,[bp+010h]
	cmp	[bp-042h],ax
	jl	$L27
	jmp	near ptr $L28
$L27:	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp-042h]
	mov	byte ptr es:[bx+si],20h
	jmp	near ptr $L29
$L28:	jmp	near ptr $L23
$L25:	jmp	near ptr $L30
$L23:	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp+010h]
	mov	byte ptr es:[bx+si],00h
	push	[bp-04Eh]
	push	[bp-048h]
	push	[bp-024h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	call	far ptr _chrplt
	add	sp,+00Ah
$L55:	call	far ptr _getkey
	mov	[bp-034h],ax
	cmp	word ptr [bp-034h],+020h
	jnl	$L31
	jmp	near ptr $L32
$L31:	cmp	word ptr [bp-034h],00FFh
	jng	$L33
	jmp	near ptr $L32
$L33:	mov	ax,[bp+010h]
	cmp	[bp-03Ah],ax
	jl	$L34
	jmp	near ptr $L35
$L34:	mov	al,[bp-034h]
	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp-03Ah]
	mov	es:[bx+si],al
	jmp	near ptr $L36
$L35:	mov	al,[bp-034h]
	mov	bx,[bp-03Ah]
	les	si,dword ptr [bp+00Ch]
	mov	es:[bx+si-001h],al
$L36:	inc	word ptr [bp-03Ah]
	mov	ax,[bp+010h]
	cmp	[bp-03Ah],ax
	jg	$L37
	jmp	near ptr $L38
$L37:	mov	ax,[bp+010h]
	mov	[bp-03Ah],ax
$L38:	jmp	$L39
$L32:	cmp	word ptr [bp-034h],+020h
	jl	$L40
	jmp	near ptr $L41
$L40:	mov	ax,[bp-034h]
	cmp	[bp-032h],ax
	jnz	$L42
	jmp	near ptr $L41
$L42:	jmp	$L43
	jmp	near ptr $L39
$L41:	mov	ax,[bp-034h]
	cmp	[bp-032h],ax
	jz	$L44
	jmp	near ptr $L45
$L44:	dec	word ptr [bp-03Ah]
	cmp	word ptr [bp-03Ah],+000h
	jl	$L46
	jmp	near ptr $L47
$L46:	mov	word ptr [bp-03Ah],0000h
	jmp	near ptr $L48
$L47:	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp-03Ah]
	mov	byte ptr es:[bx+si],20h
$L48:	jmp	near ptr $L39
$L45:	mov	ax,[bp-034h]
	cmp	[bp-02Ah],ax
	jz	$L49
	jmp	near ptr $L50
$L49:	inc	word ptr [bp-03Ah]
	mov	ax,[bp+010h]
	dec	ax
	cmp	ax,[bp-03Ah]
	jl	$L51
	jmp	near ptr $L52
$L51:	mov	ax,[bp+010h]
	dec	ax
	mov	[bp-03Ah],ax
$L52:	jmp	near ptr $L39
$L50:	mov	ax,[bp-034h]
	cmp	[bp-050h],ax
	jz	$L53
	jmp	near ptr $L39
$L53:	dec	word ptr [bp-03Ah]
	cmp	word ptr [bp-03Ah],+000h
	jl	$L54
	jmp	near ptr $L39
$L54:	mov	word ptr [bp-03Ah],0000h
$L39:	push	[bp-04Eh]
	push	[bp-048h]
	push	[bp-024h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	call	far ptr _chrplt
	add	sp,+00Ah
	jmp	$L55
$L43:	mov	ax,[bp+010h]
	dec	ax
	mov	[bp-03Ch],ax
	jmp	near ptr $L56
$L63:	dec	word ptr [bp-03Ch]
$L56:	cmp	word ptr [bp-03Ch],+000h
	jnl	$L57
	jmp	near ptr $L58
$L57:	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp-03Ch]
	cmp	byte ptr es:[bx+si],00h
	jnz	$L59
	jmp	near ptr $L60
$L59:	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp-03Ch]
	cmp	byte ptr es:[bx+si],20h
	jnz	$L61
	jmp	near ptr $L60
$L61:	jmp	near ptr $L58
	jmp	near ptr $L62
$L60:	les	bx,dword ptr [bp+00Ch]
	mov	si,[bp-03Ch]
	mov	byte ptr es:[bx+si],00h
$L62:	jmp	near ptr $L63
$L58:	push	[bp+018h]
	push	[bp-048h]
	push	[bp-024h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	call	far ptr _chrplt
	add	sp,+00Ah
	push	0EA60h
	push	13ECh
	mov	ax,[bp+014h]
	add	ax,0032h
	push	ax
	push	+000h
	call	far ptr _vgawrite
	add	sp,+008h
	mov	ax,[bp-034h]
	jmp	near ptr $L64
$L64:	pop	si
	pop	di
	leave
	retf
_gbox:	enter	0000Ch,000h

	push	di
	push	si
	mov	word ptr [bp-008h],0010h
	cmp	word ptr [bp+00Eh],+040h
	jl	$L65
	jmp	near ptr $L66
$L65:	mov	word ptr [bp-008h],000Eh
	jmp	near ptr $L67
$L66:	mov	word ptr [bp-008h],0010h
$L67:	mov	ax,[bp+00Ah]
	shl	ax,03h
	mov	[bp-00Ah],ax
	mov	ax,[bp+00Ch]
	dec	ax
	imul	word ptr [bp-008h]
	mov	[bp-00Ch],ax
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L68
$L73:	inc	word ptr [bp-006h]
$L68:	mov	ax,[bp+00Ah]
	cmp	[bp-006h],ax
	jl	$L69
	jmp	near ptr $L70
$L69:	push	[bp+00Eh]
	push	[bp+008h]
	mov	ax,[bp-006h]
	shl	ax,03h
	add	ax,[bp+006h]
	push	ax
	push	ds
	push	offset DGROUP:$S71
	call	far ptr _chrplt
	add	sp,+00Ah
	push	[bp+00Eh]
	mov	ax,[bp-00Ch]
	add	ax,[bp+008h]
	push	ax
	mov	ax,[bp-006h]
	shl	ax,03h
	add	ax,[bp+006h]
	push	ax
	push	ds
	push	offset DGROUP:$S72
	call	far ptr _chrplt
	add	sp,+00Ah
	jmp	near ptr $L73
$L70:	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L74
$L79:	inc	word ptr [bp-006h]
$L74:	mov	ax,[bp+00Ch]
	cmp	[bp-006h],ax
	jl	$L75
	jmp	near ptr $L76
$L75:	push	[bp+00Eh]
	mov	ax,[bp-006h]
	imul	word ptr [bp-008h]
	add	ax,[bp+008h]
	push	ax
	push	[bp+006h]
	push	ds
	push	offset DGROUP:$S77
	call	far ptr _chrplt
	add	sp,+00Ah
	push	[bp+00Eh]
	mov	ax,[bp-006h]
	imul	word ptr [bp-008h]
	add	ax,[bp+008h]
	push	ax
	mov	ax,[bp-00Ah]
	add	ax,[bp+006h]
	push	ax
	push	ds
	push	offset DGROUP:$S78
	call	far ptr _chrplt
	add	sp,+00Ah
	jmp	near ptr $L79
$L76:	push	[bp+00Eh]
	mov	ax,[bp-00Ch]
	add	ax,[bp+008h]
	push	ax
	push	[bp+006h]
	push	ds
	push	offset DGROUP:$S80
	call	far ptr _chrplt
	add	sp,+00Ah
	push	[bp+00Eh]
	mov	ax,[bp-00Ch]
	add	ax,[bp+008h]
	push	ax
	mov	ax,[bp-00Ah]
	add	ax,[bp+006h]
	push	ax
	push	ds
	push	offset DGROUP:$S81
	call	far ptr _chrplt
	add	sp,+00Ah
	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	push	ds
	push	offset DGROUP:$S82
	call	far ptr _chrplt
	add	sp,+00Ah
	push	[bp+00Eh]
	push	[bp+008h]
	mov	ax,[bp-00Ah]
	add	ax,[bp+006h]
	push	ax
	push	ds
	push	offset DGROUP:$S83
	call	far ptr _chrplt
	add	sp,+00Ah
	pop	si
	pop	di
	leave
	retf

GRED_TEXT	ENDS
_DATA	SEGMENT

$S71	db	0CDh
	db	000h
$S72	db	0CDh
	db	000h
$S77	db	0BAh
	db	000h
$S78	db	0BAh
	db	000h
$S80	db	0C9h
	db	000h
$S81	db	0BBh
	db	000h
$S82	db	0C8h
	db	000h
$S83	db	0BCh
	db	000h

_DATA	ENDS
	END
