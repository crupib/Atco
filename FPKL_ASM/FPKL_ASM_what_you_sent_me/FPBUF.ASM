; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fpbuf.C
; [000C]	.286p
	.287
	; Large Memory Model
; [0014]	; CodeView Enabled
FPBUF_TEXT	SEGMENT	WORD PUBLIC 'CODE'
FPBUF_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [00DC]	; Linker - Pass two marker

	EXTRN		_pfba:WORD
	EXTRN		__aFNalshl:NEAR
	EXTRN		_ems5:NEAR
	PUBLIC		_fp_ems_bufems		; Located at 1:0000h Type = 1

FPBUF_TEXT	SEGMENT
	assume	cs: FPBUF_TEXT


_fp_ems_bufems:
	enter	00014h,000h
	push	di
	push	si
	mov	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	mov	al,ah
	mov	ah,dl
	mov	dl,dh
	shl	dh,1
	sbb	dh,dh
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	mov	[bp-006h],ax
	mov	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	add	ax,[bp+00Eh]
	adc	dx,+000h
	mov	al,ah
	mov	ah,dl
	mov	dl,dh
	shl	dh,1
	sbb	dh,dh
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	sar	dx,1
	rcr	ax,1
	mov	[bp-014h],ax
	mov	ax,[bp-006h]
	mov	[bp-010h],ax
	jmp	near ptr $L1
$L4:	inc	word ptr [bp-010h]
$L1:	mov	ax,[bp-014h]
	cmp	[bp-010h],ax
	jng	$L2
	jmp	near ptr $L3
$L2:	mov	al,[bp-010h]
	and	ax,0003h
	push	ax
	push	[bp-010h]
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L4
$L3:	mov	ax,[bp+00Ah]
	mov	[bp-012h],ax

	assume	ds: DGROUP
	mov	es,word ptr $S5
	mov	ax,es:_pfba
	cwd
	mov	[bp-00Eh],ax
	mov	[bp-00Ch],dx
	push	+010h
	lea	ax,[bp-00Eh]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp-012h]
	sub	dx,dx
	add	[bp-00Eh],ax
	adc	[bp-00Ch],dx
	push	[bp-00Ch]
	push	[bp-00Eh]
	push	[bp+00Eh]
	push	[bp+008h]
	call	dword ptr [bp+010h]
	add	sp,+008h
	mov	ax,[bp-008h]
	jmp	near ptr $L6
$L6:	pop	si
	pop	di
	leave
	retf

FPBUF_TEXT	ENDS
CONST	SEGMENT

$S5	dw	_pfba

CONST	ENDS
	END
