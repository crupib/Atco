; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	border.C
; [000D]	.286p
	.287
	; Large Memory Model
; [0015]	; CodeView Enabled
BORDER_TEXT	SEGMENT	WORD PUBLIC 'CODE'
BORDER_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [00EB]	; Linker - Pass two marker

	EXTRN		_dsplaf:NEAR
	EXTRN		_filscr:NEAR
	EXTRN		_mode:NEAR
	EXTRN		_getmode:NEAR
	EXTRN		_strlen:NEAR
	EXTRN		_strcat:NEAR
	PUBLIC		_border			; Located at 1:0000h Type = 1

BORDER_TEXT	SEGMENT
	assume	cs: BORDER_TEXT


_border:
	enter	00056h,000h
	push	di
	push	si
	call	far ptr _getmode
	cmp	ax,0003h
	jnz	$L1
	jmp	near ptr $L2
$L1:	push	+003h
	call	far ptr _mode
	add	sp,+002h
$L2:	push	[bp+008h]
	push	+020h
	call	far ptr _filscr
	add	sp,+004h
	push	[bp+006h]
	push	+000h
	push	+000h
	push	ds
	push	offset DGROUP:$S3
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	[bp+006h]
	push	+04Fh
	push	+000h
	push	ds
	push	offset DGROUP:$S4
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	[bp+006h]
	push	+000h
	push	+018h
	push	ds
	push	offset DGROUP:$S5
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	[bp+006h]
	push	+04Fh
	push	+018h
	push	ds
	push	offset DGROUP:$S6
	call	far ptr _dsplaf
	add	sp,+00Ah
	mov	word ptr [bp-054h],0001h
	jmp	near ptr $L7
$L12:	inc	word ptr [bp-054h]
$L7:	cmp	word ptr [bp-054h],+04Fh
	jl	$L8
	jmp	near ptr $L9
$L8:	push	[bp+006h]
	push	[bp-054h]
	push	+000h
	push	ds
	push	offset DGROUP:$S10
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	[bp+006h]
	push	[bp-054h]
	push	+018h
	push	ds
	push	offset DGROUP:$S11
	call	far ptr _dsplaf
	add	sp,+00Ah
	jmp	near ptr $L12
$L9:	mov	word ptr [bp-054h],0001h
	jmp	near ptr $L13
$L18:	inc	word ptr [bp-054h]
$L13:	cmp	word ptr [bp-054h],+018h
	jl	$L14
	jmp	near ptr $L15
$L14:	push	[bp+006h]
	push	+000h
	push	[bp-054h]
	push	ds
	push	offset DGROUP:$S16
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	[bp+006h]
	push	+04Fh
	push	[bp-054h]
	push	ds
	push	offset DGROUP:$S17
	call	far ptr _dsplaf
	add	sp,+00Ah
	jmp	near ptr $L18
$L15:	les	bx,dword ptr [bp+00Ah]
	cmp	byte ptr es:[bx],00h
	jnz	$L19
	jmp	near ptr $L20
$L19:	mov	byte ptr [bp-052h],00h
	push	ds
	push	offset DGROUP:$S21
	lea	ax,[bp-052h]
	push	ss
	push	ax
	call	far ptr _strcat
	add	sp,+008h
	push	[bp+00Ch]
	push	[bp+00Ah]
	lea	ax,[bp-052h]
	push	ss
	push	ax
	call	far ptr _strcat
	add	sp,+008h
	push	ds
	push	offset DGROUP:$S22
	lea	ax,[bp-052h]
	push	ss
	push	ax
	call	far ptr _strcat
	add	sp,+008h
	lea	ax,[bp-052h]
	push	ss
	push	ax
	call	far ptr _strlen
	add	sp,+004h
	mov	[bp-056h],ax
	mov	ax,0050h
	sub	ax,[bp-056h]
	sar	ax,1
	mov	[bp-056h],ax
	push	[bp+006h]
	push	[bp-056h]
	push	+000h
	lea	ax,[bp-052h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
$L20:	pop	si
	pop	di
	leave
	retf

BORDER_TEXT	ENDS
_DATA	SEGMENT

$S3	db	0C9h
	db	000h
$S4	db	0BBh
	db	000h
$S5	db	0C8h
	db	000h
$S6	db	0BCh
	db	000h
$S10	db	0CDh
	db	000h
$S11	db	0CDh
	db	000h
$S16	db	0BAh
	db	000h
$S17	db	0BAh
	db	000h
$S21	db	0AFh
	db	0AFh
	db	020h
	db	000h
$S22	db	020h
	db	0AEh
	db	0AEh
	db	000h

_DATA	ENDS
	END
