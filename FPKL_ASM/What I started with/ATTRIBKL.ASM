; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	attribkl.C
; [000F]	.286p
	.287
	; Large Memory Model
; [0017]	; CodeView Enabled
ATTRIBKL_TEXT	SEGMENT	WORD PUBLIC 'CODE'
ATTRIBKL_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [00BA]	; Linker - Pass two marker


	PUBLIC		_attrib			; Located at 1:0000h Type = 1

ATTRIBKL_TEXT	SEGMENT
	assume	cs: ATTRIBKL_TEXT


_attrib:
	enter	00012h,000h
	push	di
	push	si
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+012h]
	mov	[bp-012h],ax
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+014h]
	mov	[bp-004h],ax
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+010h]
	mov	[bp-008h],ax
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+01Ah]
	mov	[bp-006h],ax
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+004h]
	mov	[bp-00Ch],ax
	mov	word ptr [bp-010h],0000h
	jmp	near ptr $L1
$L34:	inc	word ptr [bp-010h]
$L1:	cmp	word ptr [bp-010h],0100h
	jl	$L2
	jmp	$L3
$L2:	les	bx,dword ptr [bp+006h]
	cmp	word ptr es:[bx+01Ch],+000h
	jz	$L4
	jmp	near ptr $L5
$L4:	mov	ax,[bp-010h]
	mov	[bp-00Ah],ax
	jmp	near ptr $L6
$L5:	les	bx,dword ptr [bp+006h]
	cmp	word ptr es:[bx+01Ch],+001h
	jz	$L7
	jmp	near ptr $L8
$L7:	mov	ax,[bp-010h]
	sub	ax,0080h
	mov	[bp-00Ah],ax
	jmp	near ptr $L6
$L8:	les	bx,dword ptr [bp+006h]
	cmp	word ptr es:[bx+01Ch],+002h
	jz	$L9
	jmp	near ptr $L6
$L9:	cmp	word ptr [bp-010h],0080h
	jl	$L10
	jmp	near ptr $L11
$L10:	mov	ax,[bp-010h]
	mov	[bp-00Ah],ax
	jmp	near ptr $L6
$L11:	cmp	word ptr [bp-010h],0080h
	jz	$L12
	jmp	near ptr $L13
$L12:	mov	word ptr [bp-00Ah],0FF81h
	jmp	near ptr $L6
$L13:	mov	ax,[bp-010h]
	sub	ax,0100h
	mov	[bp-00Ah],ax
$L6:	cmp	word ptr [bp-00Ch],+000h
	jg	$L14
	jmp	near ptr $L15
$L14:	mov	cl,[bp-00Ch]
	sar	word ptr [bp-00Ah],cl
	jmp	near ptr $L16
$L15:	cmp	word ptr [bp-00Ch],+000h
	jl	$L17
	jmp	near ptr $L16
$L17:	mov	cl,[bp-00Ch]
	neg	cl
	shl	word ptr [bp-00Ah],cl
$L16:	les	bx,dword ptr [bp+006h]
	cmp	word ptr es:[bx+01Ch],+000h
	jz	$L18
	jmp	near ptr $L19
$L18:	cmp	word ptr [bp-00Ah],00FFh
	jg	$L20
	jmp	near ptr $L21
$L20:	mov	word ptr [bp-00Ah],00FFh
$L21:	jmp	near ptr $L22
$L19:	cmp	word ptr [bp-00Ah],+07Fh
	jg	$L23
	jmp	near ptr $L24
$L23:	mov	word ptr [bp-00Ah],007Fh
$L24:	cmp	word ptr [bp-00Ah],-07Fh
	jl	$L25
	jmp	near ptr $L22
$L25:	mov	word ptr [bp-00Ah],0FF81h
$L22:	cmp	word ptr [bp-006h],+000h
	jl	$L26
	jmp	near ptr $L27
$L26:	les	bx,dword ptr [bp+006h]
	cmp	word ptr es:[bx+01Ch],+000h
	jnz	$L28
	jmp	near ptr $L27
$L28:	cmp	word ptr [bp-00Ah],+000h
	jl	$L29
	jmp	near ptr $L27
$L29:	neg	[bp-00Ah]
$L27:	mov	ax,[bp-008h]
	add	ax,[bp-00Ah]
	mov	[bp-00Eh],ax
	mov	ax,[bp-00Eh]
	cmp	[bp-012h],ax
	jg	$L30
	jmp	near ptr $L31
$L30:	mov	ax,[bp-012h]
	sub	ax,[bp-008h]
	mov	[bp-00Ah],ax
	jmp	near ptr $L32
$L31:	mov	ax,[bp-00Eh]
	cmp	[bp-004h],ax
	jl	$L33
	jmp	near ptr $L32
$L33:	mov	ax,[bp-004h]
	sub	ax,[bp-008h]
	mov	[bp-00Ah],ax
$L32:	mov	al,[bp-00Ah]
	mov	bx,[bp-010h]
	les	si,dword ptr [bp+006h]
	mov	es:[bx+si+024h],al
	jmp	$L34
$L3:	pop	si
	pop	di
	leave
	retf

ATTRIBKL_TEXT	ENDS
	END
