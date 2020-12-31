; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	getkeys.C
; [000E]	.286p
	.287
	; Large Memory Model
; [0016]	; CodeView Enabled
GETKEYS_TEXT	SEGMENT	WORD PUBLIC 'CODE'
GETKEYS_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [00DD]	; Linker - Pass two marker

	EXTRN		__bios_keybrd:NEAR
	PUBLIC		_getkeyc		; Located at 1:0000h Type = 1
	PUBLIC		_getkey			; Located at 1:0092h Type = 1

GETKEYS_TEXT	SEGMENT
	assume	cs: GETKEYS_TEXT


_getkeyc:
	enter	00008h,000h
	push	di
	push	si
	mov	word ptr [bp-006h],0000h
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0001h
	mov	bx,0040h
	mov	es,bx
	mov	bx,0096h
	test	byte ptr es:[bx],10h
	jnz	$L1
	jmp	near ptr $L2
$L1:	mov	word ptr [bp-004h],0010h
	mov	word ptr [bp-002h],0011h
$L2:	push	[bp-002h]
	call	far ptr __bios_keybrd
	add	sp,+002h
	cmp	ax,0000h
	jnz	$L3
	jmp	near ptr $L4
$L3:	push	[bp-004h]
	call	far ptr __bios_keybrd
	add	sp,+002h
	jmp	near ptr $L2
$L4:	push	[bp-004h]
	call	far ptr __bios_keybrd
	add	sp,+002h
	mov	[bp-008h],ax
	mov	al,[bp-008h]
	sub	ah,ah
	mov	[bp-006h],ax
	cmp	word ptr [bp-006h],00E0h
	jz	$L5
	jmp	near ptr $L6
$L5:	sub	word ptr [bp-008h],00E0h
	jmp	near ptr $L7
$L6:	cmp	word ptr [bp-006h],+000h
	jnz	$L8
	jmp	near ptr $L7
$L8:	mov	ax,[bp-006h]
	mov	[bp-008h],ax
$L7:	mov	ax,[bp-008h]
	jmp	near ptr $L9
$L9:	pop	si
	pop	di
	leave
	retf
_getkey:
	enter	00008h,000h
	push	di
	push	si
	mov	word ptr [bp-006h],0000h
	mov	word ptr [bp-004h],0000h
	mov	word ptr [bp-002h],0001h
	mov	bx,0040h
	mov	es,bx
	mov	bx,0096h
	test	byte ptr es:[bx],10h
	jnz	$L10
	jmp	near ptr $L11
$L10:	mov	word ptr [bp-004h],0010h
	mov	word ptr [bp-002h],0011h
$L11:	push	[bp-004h]
	call	far ptr __bios_keybrd
	add	sp,+002h
	mov	[bp-008h],ax
	mov	al,[bp-008h]
	sub	ah,ah
	mov	[bp-006h],ax
	cmp	word ptr [bp-006h],00E0h
	jz	$L12
	jmp	near ptr $L13
$L12:	sub	word ptr [bp-008h],00E0h
	jmp	near ptr $L14
$L13:	cmp	word ptr [bp-006h],+000h
	jnz	$L15
	jmp	near ptr $L14
$L15:	mov	ax,[bp-006h]
	mov	[bp-008h],ax
$L14:	mov	ax,[bp-008h]
	jmp	near ptr $L16
$L16:	pop	si
	pop	di
	leave
	retf

GETKEYS_TEXT	ENDS
	END
