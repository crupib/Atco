; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	pop_up.C
; [000D]	.286p
	.287
	; Large Memory Model
; [0015]	; CodeView Enabled
POP_UP_TEXT	SEGMENT	WORD PUBLIC 'CODE'
POP_UP_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [0174]	; Linker - Pass two marker

	EXTRN		_fp_ems_free:NEAR
	EXTRN		_fp_ems_alloc:NEAR
	EXTRN		_funct:NEAR
	EXTRN		_wrmod:NEAR
	EXTRN		_vpwrite:NEAR
	EXTRN		_enasr:NEAR
	EXTRN		_vpread:NEAR
	EXTRN		_btmsk:NEAR
	EXTRN		_fp_ems_write:NEAR
	EXTRN		_fp_ems_read:NEAR
	COMM FAR	_scanline_buffer:BYTE:640
	PUBLIC		_init_pop_up		; Located at 1:0000h Type = 1
	PUBLIC		_pop_up			; Located at 1:0031h Type = 1
	PUBLIC		_pop_back		; Located at 1:00DAh Type = 1

POP_UP_TEXT	SEGMENT
	assume	cs: POP_UP_TEXT


_init_pop_up:
	enter	00006h,000h
	push	di
	push	si
	mov	ax,[bp+008h]
	imul	word ptr [bp+006h]
	sar	dx,1
	rcr	ax,1
	mov	[bp-004h],ax
	mov	[bp-002h],dx
	push	[bp-002h]
	push	[bp-004h]
	call	far ptr _fp_ems_alloc
	add	sp,+004h
	mov	[bp-006h],ax
	mov	ax,[bp-006h]
	jmp	near ptr $L1
$L1:	pop	si
	pop	di
	leave
	retf
_pop_up:
	enter	0000Ch,000h
	push	di
	push	si
	sub	ax,ax
	mov	[bp-00Ah],ax
	mov	[bp-00Ch],ax
	mov	ax,[bp+00Ah]
	cwd
	xor	ax,dx
	sub	ax,dx
	sar	ax,03h
	xor	ax,dx
	sub	ax,dx
	mov	[bp-002h],ax
	mov	ax,[bp+006h]
	cwd
	xor	ax,dx
	sub	ax,dx
	sar	ax,03h
	xor	ax,dx
	sub	ax,dx
	mov	[bp-004h],ax
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L2
$L9:	inc	word ptr [bp-006h]
$L2:	cmp	word ptr [bp-006h],+004h
	jl	$L3
	jmp	near ptr $L4
$L3:	mov	ax,[bp+008h]
	mov	[bp-008h],ax
	jmp	near ptr $L5
$L8:	inc	word ptr [bp-008h]
$L5:	mov	ax,[bp+008h]
	add	ax,[bp+00Ch]
	dec	ax
	cmp	ax,[bp-008h]
	jnl	$L6
	jmp	near ptr $L7
$L6:	push	seg _scanline_buffer
	push	offset _scanline_buffer
	push	[bp-002h]
	push	[bp-004h]
	push	[bp-008h]
	push	[bp-006h]
	call	far ptr _vpread
	add	sp,+00Ch
	push	[bp-002h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	push	seg _scanline_buffer
	push	offset _scanline_buffer
	push	[bp+00Eh]
	call	far ptr _fp_ems_write
	add	sp,+00Ch
	mov	ax,[bp-002h]
	cwd
	add	[bp-00Ch],ax
	adc	[bp-00Ah],dx
	jmp	near ptr $L8
$L7:	jmp	near ptr $L9
$L4:	pop	si
	pop	di
	leave
	retf
_pop_back:
	enter	0000Ch,000h
	push	di
	push	si
	sub	ax,ax
	mov	[bp-00Ah],ax
	mov	[bp-00Ch],ax
	push	+000h
	call	far ptr _funct
	add	sp,+002h
	push	00FFh
	call	far ptr _btmsk
	add	sp,+002h
	push	+000h
	call	far ptr _enasr
	add	sp,+002h
	push	+000h
	call	far ptr _wrmod
	add	sp,+002h
	mov	ax,[bp+00Ah]
	cwd
	xor	ax,dx
	sub	ax,dx
	sar	ax,03h
	xor	ax,dx
	sub	ax,dx
	mov	[bp-002h],ax
	mov	ax,[bp+006h]
	cwd
	xor	ax,dx
	sub	ax,dx
	sar	ax,03h
	xor	ax,dx
	sub	ax,dx
	mov	[bp-004h],ax
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L10
$L17:	inc	word ptr [bp-006h]
$L10:	cmp	word ptr [bp-006h],+004h
	jl	$L11
	jmp	near ptr $L12
$L11:	mov	ax,[bp+008h]
	mov	[bp-008h],ax
	jmp	near ptr $L13
$L16:	inc	word ptr [bp-008h]
$L13:	mov	ax,[bp+00Ch]
	add	ax,[bp+008h]
	dec	ax
	cmp	ax,[bp-008h]
	jnl	$L14
	jmp	near ptr $L15
$L14:	push	[bp-002h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	push	seg _scanline_buffer
	push	offset _scanline_buffer
	push	[bp+00Eh]
	call	far ptr _fp_ems_read
	add	sp,+00Ch
	push	seg _scanline_buffer
	push	offset _scanline_buffer
	push	[bp-002h]
	push	[bp-004h]
	push	[bp-008h]
	push	[bp-006h]
	call	far ptr _vpwrite
	add	sp,+00Ch
	mov	ax,[bp-002h]
	cwd
	add	[bp-00Ch],ax
	adc	[bp-00Ah],dx
	jmp	near ptr $L16
$L15:	jmp	near ptr $L17
$L12:	push	[bp+00Eh]
	call	far ptr _fp_ems_free
	add	sp,+002h
	mov	word ptr [bp+00Eh],0000h
	pop	si
	pop	di
	leave
	retf

POP_UP_TEXT	ENDS
	END
