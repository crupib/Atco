; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	grid.C
; [000B]	.286p
	.287
	; Large Memory Model
; [0013]	; CodeView Enabled
GRID_TEXT	SEGMENT	WORD PUBLIC 'CODE'
GRID_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [00B7]	; Linker - Pass two marker

	EXTRN		_pntplt:NEAR
	PUBLIC		_grid			; Located at 1:0000h Type = 1

GRID_TEXT	SEGMENT
	assume	cs: GRID_TEXT


_grid:	enter	0000Eh,000h
	push	di
	push	si
	mov	ax,[bp+00Ah]
	imul	word ptr [bp+008h]
	add	ax,[bp+006h]
	mov	[bp-008h],ax
	mov	ax,[bp+010h]
	imul	word ptr [bp+00Eh]
	add	ax,[bp+00Ch]
	dec	ax
	mov	[bp-00Ah],ax
	mov	ax,[bp+006h]
	mov	[bp-004h],ax
	jmp	near ptr $L1
$L4:	inc	word ptr [bp-004h]
$L1:	mov	ax,[bp-004h]
	cmp	[bp-008h],ax
	jnl	$L2
	jmp	near ptr $L3
$L2:	push	[bp+014h]
	push	[bp+00Ch]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	push	[bp+014h]
	push	[bp-00Ah]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L4
$L3:	mov	ax,[bp+00Ch]
	mov	[bp-006h],ax
	jmp	near ptr $L5
$L8:	inc	word ptr [bp-006h]
$L5:	mov	ax,[bp-006h]
	cmp	[bp-00Ah],ax
	jnl	$L6
	jmp	near ptr $L7
$L6:	push	[bp+014h]
	push	[bp-006h]
	push	[bp+006h]
	call	far ptr _pntplt
	add	sp,+006h
	push	[bp+014h]
	push	[bp-006h]
	push	[bp-008h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L8
$L7:	mov	ax,[bp+00Eh]
	add	ax,[bp+00Ch]
	mov	[bp-006h],ax
	jmp	near ptr $L9
$L20:	mov	ax,[bp+00Eh]
	add	[bp-006h],ax
$L9:	mov	ax,[bp-00Ah]
	sub	ax,[bp+00Eh]
	inc	ax
	cmp	ax,[bp-006h]
	jnl	$L10
	jmp	near ptr $L11
$L10:	mov	ax,[bp+006h]
	inc	ax
	mov	[bp-004h],ax
	jmp	near ptr $L12
$L15:	inc	word ptr [bp-004h]
$L12:	mov	ax,[bp+006h]
	add	ax,0004h
	cmp	ax,[bp-004h]
	jg	$L13
	jmp	near ptr $L14
$L13:	push	[bp+014h]
	push	[bp-006h]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L15
$L14:	mov	ax,[bp-008h]
	dec	ax
	mov	[bp-004h],ax
	jmp	near ptr $L16
$L19:	dec	word ptr [bp-004h]
$L16:	mov	ax,[bp-008h]
	sub	ax,0004h
	cmp	ax,[bp-004h]
	jl	$L17
	jmp	near ptr $L18
$L17:	push	[bp+014h]
	push	[bp-006h]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L19
$L18:	jmp	near ptr $L20
$L11:	mov	ax,[bp+008h]
	add	ax,[bp+006h]
	mov	[bp-004h],ax
	jmp	near ptr $L21
$L32:	mov	ax,[bp+008h]
	add	[bp-004h],ax
$L21:	mov	ax,[bp-008h]
	sub	ax,[bp+008h]
	inc	ax
	cmp	ax,[bp-004h]
	jnl	$L22
	jmp	near ptr $L23
$L22:	mov	ax,[bp+00Ch]
	inc	ax
	mov	[bp-006h],ax
	jmp	near ptr $L24
$L27:	inc	word ptr [bp-006h]
$L24:	mov	ax,[bp+00Ch]
	add	ax,0004h
	cmp	ax,[bp-006h]
	jg	$L25
	jmp	near ptr $L26
$L25:	push	[bp+014h]
	push	[bp-006h]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L27
$L26:	mov	ax,[bp-00Ah]
	dec	ax
	mov	[bp-006h],ax
	jmp	near ptr $L28
$L31:	dec	word ptr [bp-006h]
$L28:	mov	ax,[bp-00Ah]
	sub	ax,0004h
	cmp	ax,[bp-006h]
	jl	$L29
	jmp	near ptr $L30
$L29:	push	[bp+014h]
	push	[bp-006h]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
	jmp	near ptr $L31
$L30:	jmp	near ptr $L32
$L23:	cmp	word ptr [bp+012h],+000h
	jng	$L33
	jmp	near ptr $L34
$L33:	jmp	$L35
$L34:	cmp	word ptr [bp+012h],+005h
	jg	$L36
	jmp	near ptr $L37
$L36:	mov	word ptr [bp+012h],0005h
$L37:	mov	cl,[bp+012h]
	mov	ax,[bp+008h]
	sar	ax,cl
	mov	[bp-00Eh],ax
	mov	cl,[bp+012h]
	mov	ax,[bp+00Eh]
	sar	ax,cl
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],+001h
	jl	$L38
	jmp	near ptr $L39
$L38:	mov	word ptr [bp-002h],0001h
$L39:	mov	ax,[bp+00Eh]
	add	ax,[bp+00Ch]
	mov	[bp-006h],ax
	jmp	near ptr $L40
$L50:	mov	ax,[bp+00Eh]
	add	[bp-006h],ax
$L40:	mov	ax,[bp-00Ah]
	sub	ax,[bp+00Eh]
	inc	ax
	cmp	ax,[bp-006h]
	jnl	$L41
	jmp	near ptr $L42
$L41:	mov	ax,[bp+006h]
	mov	[bp-004h],ax
	jmp	near ptr $L43
$L49:	mov	ax,[bp-00Eh]
	add	[bp-004h],ax
$L43:	mov	ax,[bp-004h]
	cmp	[bp-008h],ax
	jnl	$L44
	jmp	near ptr $L45
$L44:	mov	ax,[bp+006h]
	cmp	[bp-004h],ax
	jnz	$L46
	jmp	near ptr $L47
$L46:	mov	ax,[bp-008h]
	sub	ax,[bp-004h]
	dec	ax
	jnz	$L48
	jmp	near ptr $L47
$L48:	push	[bp+014h]
	push	[bp-006h]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
$L47:	jmp	near ptr $L49
$L45:	jmp	near ptr $L50
$L42:	mov	ax,[bp+008h]
	add	ax,[bp+006h]
	mov	[bp-004h],ax
	jmp	near ptr $L51
$L60:	mov	ax,[bp+008h]
	add	[bp-004h],ax
$L51:	mov	ax,[bp-008h]
	sub	ax,[bp+008h]
	inc	ax
	cmp	ax,[bp-004h]
	jnl	$L52
	jmp	near ptr $L35
$L52:	mov	ax,[bp+00Ch]
	mov	[bp-006h],ax
	jmp	near ptr $L53
$L59:	mov	ax,[bp-002h]
	add	[bp-006h],ax
$L53:	mov	ax,[bp-006h]
	cmp	[bp-00Ah],ax
	jnl	$L54
	jmp	near ptr $L55
$L54:	mov	ax,[bp+00Ch]
	cmp	[bp-006h],ax
	jnz	$L56
	jmp	near ptr $L57
$L56:	mov	ax,[bp-006h]
	cmp	[bp-00Ah],ax
	jnz	$L58
	jmp	near ptr $L57
$L58:	push	[bp+014h]
	push	[bp-006h]
	push	[bp-004h]
	call	far ptr _pntplt
	add	sp,+006h
$L57:	jmp	near ptr $L59
$L55:	jmp	near ptr $L60
$L35:	pop	si
	pop	di
	leave
	retf

GRID_TEXT	ENDS
	END
