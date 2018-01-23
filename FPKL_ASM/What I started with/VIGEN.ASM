; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	vigen.C
; [000C]	.286p
	.287
	; Large Memory Model
; [0014]	; CodeView Enabled
VIGEN_TEXT	SEGMENT	WORD PUBLIC 'CODE'
VIGEN_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [0101]	; Linker - Pass two marker

	COMM FAR	_chrplt_handle:BYTE:2
	EXTRN		_setvid:NEAR
	PUBLIC		_vigen			; Located at 1:0000h Type = 1
	PUBLIC		_xvideo			; Located at 2:0000h Type = 4
	PUBLIC		_xvidseg		; Located at 2:0800h Type = 4
	PUBLIC		_xvm			; Located at 2:0802h Type = 4
	PUBLIC		_nucol			; Located at 2:0804h Type = 4
struct_0	struc
s0m_0	dw	1023 dup (?)
struct_0	ends

VIGEN_TEXT	SEGMENT
	assume	cs: VIGEN_TEXT


_vigen:	enter	00004h,000h
	push	di
	push	si
	mov	ax,[bp+006h]
	assume	ds: DGROUP
	mov	_xvm,ax
	mov	ax,[bp+006h]
	jmp	$L1
$L29:	mov	word ptr _xvidseg,0A000h
	mov	word ptr [bp-004h],01E0h
	mov	word ptr _nucol,0050h
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L2
$L5:	inc	word ptr [bp-002h]
$L2:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jl	$L3
	jmp	near ptr $L4
$L3:	mov	ax,[bp-004h]
	sub	ax,[bp-002h]
	dec	ax
	imul	ax,ax,+050h
	mov	bx,[bp-002h]
	shl	bx,1
	mov	[bx+_xvideo],ax
	jmp	near ptr $L5
$L4:	jmp	$L6
$L40:	mov	word ptr _xvidseg,0A000h
	mov	word ptr [bp-004h],015Eh
	mov	word ptr _nucol,0050h
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L7
$L10:	inc	word ptr [bp-002h]
$L7:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jl	$L8
	jmp	near ptr $L9
$L8:	mov	ax,[bp-004h]
	sub	ax,[bp-002h]
	dec	ax
	imul	ax,ax,+050h
	mov	bx,[bp-002h]
	shl	bx,1
	mov	[bx+_xvideo],ax
	jmp	near ptr $L10
$L9:	jmp	$L6
$L37:	mov	word ptr _xvidseg,0A000h
	mov	word ptr [bp-004h],00C8h
	mov	word ptr _nucol,0050h
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L11
$L14:	inc	word ptr [bp-002h]
$L11:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jl	$L12
	jmp	near ptr $L13
$L12:	mov	ax,[bp-004h]
	sub	ax,[bp-002h]
	dec	ax
	imul	ax,ax,+050h
	mov	bx,[bp-002h]
	shl	bx,1
	mov	[bx+_xvideo],ax
	jmp	near ptr $L14
$L13:	jmp	$L6
$L34:	mov	word ptr _xvidseg,0B800h
	mov	word ptr [bp-004h],00C8h
	mov	word ptr _nucol,0050h
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L15
$L19:	add	word ptr [bp-002h],+002h
$L15:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jl	$L16
	jmp	near ptr $L17
$L16:	imul	ax,[bp-002h],-028h
	add	ax,3EF0h
	mov	bx,[bp-002h]
	shl	bx,1
	mov	[bx+_xvideo],ax
	mov	ax,00C6h
	sub	ax,[bp-002h]
	imul	ax,ax,+028h
	mov	bx,[bp-002h]
	shl	bx,1
	mov	[bx+$S18.s0m_0],ax
	jmp	near ptr $L19
$L17:	jmp	$L6
$L42:	mov	word ptr _xvidseg,0A000h
	mov	word ptr [bp-004h],0258h
	mov	word ptr _nucol,0064h
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L20
$L23:	inc	word ptr [bp-002h]
$L20:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jl	$L21
	jmp	near ptr $L22
$L21:	mov	ax,[bp-004h]
	sub	ax,[bp-002h]
	dec	ax
	imul	ax,ax,+064h
	mov	bx,[bp-002h]
	shl	bx,1
	mov	[bx+_xvideo],ax
	jmp	near ptr $L23
$L22:	jmp	$L6
$L46:	mov	word ptr _xvidseg,0A000h
	mov	word ptr [bp-004h],019Ah
	mov	word ptr _nucol,005Eh
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L24
$L27:	inc	word ptr [bp-002h]
$L24:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jl	$L25
	jmp	near ptr $L26
$L25:	mov	ax,[bp-004h]
	sub	ax,[bp-002h]
	dec	ax
	imul	ax,ax,+064h
	mov	bx,[bp-002h]
	shl	bx,1
	mov	[bx+_xvideo],ax
	jmp	near ptr $L27
$L26:	jmp	near ptr $L6
	jmp	near ptr $L6
$L1:	cmp	ax,0012h
	jnz	$L28
	jmp	$L29
$L28:	jng	$L30
	jmp	near ptr $L31
$L30:	sub	ax,0004h
	jnl	$L32
	jmp	near ptr $L6
$L32:	dec	ax
	dec	ax
	jg	$L33
	jmp	$L34
$L33:	sub	ax,0007h
	jnl	$L35
	jmp	near ptr $L6
$L35:	dec	ax
	jg	$L36
	jmp	$L37
$L36:	dec	ax
	jnl	$L38
	jmp	near ptr $L6
$L38:	dec	ax
	jg	$L39
	jmp	$L40
$L39:	jmp	near ptr $L6
$L31:	sub	ax,0029h
	jnz	$L41
	jmp	$L42
$L41:	sub	ax,0007h
	jnz	$L43
	jmp	$L42
$L43:	sub	ax,0028h
	jnz	$L44
	jmp	$L42
$L44:	sub	ax,0008h
	jnz	$L45
	jmp	$L46
$L45:	jmp	near ptr $L6
$L6:	push	_nucol
	push	[bp-004h]
	push	ds
	push	offset DGROUP:_xvideo
	push	_xvidseg
	push	_xvm
	call	far ptr _setvid
	add	sp,+00Ch
	pop	si
	pop	di
	leave
	retf

VIGEN_TEXT	ENDS
_DATA	SEGMENT

_xvideo	dw	00000h

$S18	struct_0	<00000h>

_xvidseg	dw	0A000h
_xvm	dw	00010h
_nucol	dw	00050h

_DATA	ENDS
_BSS	SEGMENT
	dw	1 dup(?)

_BSS	ENDS
	END
