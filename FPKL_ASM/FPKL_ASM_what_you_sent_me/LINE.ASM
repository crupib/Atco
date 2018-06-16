; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	line.C
; [000B]	.286p
	.287
	; Large Memory Model
; [0013]	; CodeView Enabled
LINE_TEXT	SEGMENT	WORD PUBLIC 'CODE'
LINE_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [00EB]	; Linker - Pass two marker

	EXTRN		_pntplt2:NEAR
	EXTRN		_pntplt:NEAR
	PUBLIC		_line			; Located at 1:0000h Type = 1
	PUBLIC		_line2			; Located at 1:00F6h Type = 1
	PUBLIC		_line_abs		; Located at 1:01EDh Type = 1

LINE_TEXT	SEGMENT
	assume	cs: LINE_TEXT


_line:	enter	0000Ch,000h
	push	di
	push	si
	mov	ax,0000h
	mov	[bp-002h],ax
	mov	[bp-008h],ax
	mov	ax,[bp+00Ah]
	sub	ax,[bp+006h]
	mov	[bp-006h],ax
	mov	ax,[bp+00Ch]
	sub	ax,[bp+008h]
	mov	[bp-00Ch],ax
	cmp	word ptr [bp-006h],+000h
	jg	$L1
	jmp	near ptr $L2
$L1:	mov	word ptr [bp-004h],0001h
	jmp	near ptr $L3
$L2:	cmp	word ptr [bp-006h],+000h
	jz	$L4
	jmp	near ptr $L5
$L4:	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L3
$L5:	mov	word ptr [bp-004h],0FFFFh
$L3:	cmp	word ptr [bp-00Ch],+000h
	jg	$L6
	jmp	near ptr $L7
$L6:	mov	word ptr [bp-00Ah],0001h
	jmp	near ptr $L8
$L7:	cmp	word ptr [bp-00Ch],+000h
	jz	$L9
	jmp	near ptr $L10
$L9:	mov	word ptr [bp-00Ah],0000h
	jmp	near ptr $L8
$L10:	mov	word ptr [bp-00Ah],0FFFFh
$L8:	push	[bp-006h]
	call	far ptr _line_abs
	add	sp,+002h
	mov	[bp-006h],ax
	push	[bp-00Ch]
	call	far ptr _line_abs
	add	sp,+002h
	mov	[bp-00Ch],ax
	mov	ax,[bp-006h]
	cmp	[bp-00Ch],ax
	jl	$L11
	jmp	near ptr $L12
$L11:	mov	di,[bp-006h]
	jmp	near ptr $L13
$L12:	mov	di,[bp-00Ch]
$L13:	mov	si,0000h
	jmp	near ptr $L14
$L21:	inc	si
$L14:	lea	ax,[di+001h]
	cmp	ax,si
	jnl	$L15
	jmp	near ptr $L16
$L15:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _pntplt
	add	sp,+006h
	mov	ax,[bp-006h]
	add	[bp-002h],ax
	mov	ax,[bp-00Ch]
	add	[bp-008h],ax
	cmp	[bp-002h],di
	jg	$L17
	jmp	near ptr $L18
$L17:	sub	[bp-002h],di
	mov	ax,[bp-004h]
	add	[bp+006h],ax
$L18:	cmp	[bp-008h],di
	jg	$L19
	jmp	near ptr $L20
$L19:	sub	[bp-008h],di
	mov	ax,[bp-00Ah]
	add	[bp+008h],ax
$L20:	jmp	near ptr $L21
$L16:	pop	si
	pop	di
	leave
	retf
_line2:	enter	0000Ch,000h
	push	di
	push	si
	mov	word ptr [bp-002h],0000h
	mov	word ptr [bp-008h],0000h
	mov	ax,[bp+00Ah]
	sub	ax,[bp+006h]
	mov	[bp-006h],ax
	mov	ax,[bp+00Ch]
	sub	ax,[bp+008h]
	mov	[bp-00Ch],ax
	cmp	word ptr [bp-006h],+000h
	jg	$L22
	jmp	near ptr $L23
$L22:	mov	word ptr [bp-004h],0001h
	jmp	near ptr $L24
$L23:	cmp	word ptr [bp-006h],+000h
	jz	$L25
	jmp	near ptr $L26
$L25:	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L24
$L26:	mov	word ptr [bp-004h],0FFFFh
$L24:	cmp	word ptr [bp-00Ch],+000h
	jg	$L27
	jmp	near ptr $L28
$L27:	mov	word ptr [bp-00Ah],0001h
	jmp	near ptr $L29
$L28:	cmp	word ptr [bp-00Ch],+000h
	jz	$L30
	jmp	near ptr $L31
$L30:	mov	word ptr [bp-00Ah],0000h
	jmp	near ptr $L29
$L31:	mov	word ptr [bp-00Ah],0FFFFh
$L29:	push	[bp-006h]
	call	far ptr _line_abs
	add	sp,+002h
	mov	[bp-006h],ax
	push	[bp-00Ch]
	call	far ptr _line_abs
	add	sp,+002h
	mov	[bp-00Ch],ax
	mov	ax,[bp-006h]
	cmp	[bp-00Ch],ax
	jl	$L32
	jmp	near ptr $L33
$L32:	mov	di,[bp-006h]
	jmp	near ptr $L34
$L33:	mov	di,[bp-00Ch]
$L34:	mov	si,0000h
	jmp	near ptr $L35
$L42:	inc	si
$L35:	lea	ax,[di+001h]
	cmp	ax,si
	jnl	$L36
	jmp	near ptr $L37
$L36:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _pntplt2
	add	sp,+006h
	mov	ax,[bp-006h]
	add	[bp-002h],ax
	mov	ax,[bp-00Ch]
	add	[bp-008h],ax
	cmp	[bp-002h],di
	jg	$L38
	jmp	near ptr $L39
$L38:	sub	[bp-002h],di
	mov	ax,[bp-004h]
	add	[bp+006h],ax
$L39:	cmp	[bp-008h],di
	jg	$L40
	jmp	near ptr $L41
$L40:	sub	[bp-008h],di
	mov	ax,[bp-00Ah]
	add	[bp+008h],ax
$L41:	jmp	near ptr $L42
$L37:	pop	si
	pop	di
	leave
	retf
_line_abs:
	enter	00000h,000h
	push	di
	push	si
	cmp	word ptr [bp+006h],+000h
	jl	$L43
	jmp	near ptr $L44
$L43:	mov	ax,[bp+006h]
	neg	ax
	jmp	near ptr $L45
	jmp	near ptr $L45
$L44:	mov	ax,[bp+006h]
	jmp	near ptr $L45
$L45:	pop	si
	pop	di
	leave
	retf

LINE_TEXT	ENDS
	END
