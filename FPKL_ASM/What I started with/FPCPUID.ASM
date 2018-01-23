; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fpcpuid.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
FPCPUID_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
FPCPUID_TEXT	ENDS
DGROUP	GROUP	_DATA
; [0078]	; Linker - Pass two marker


	PUBLIC		_fp_cpu_id		; Located at 3:0000h Type = 1

FPCPUID_TEXT	SEGMENT
	assume	cs: FPCPUID_TEXT


_fp_cpu_id:
	push	bp
	mov	bp,sp
	add	sp,-002h
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	pushf
	pop	bx
	mov	ax,0FFFh
	and	ax,bx
	push	ax
	popf
	pushf
	pop	ax
	and	ax,0F000h
	cmp	ax,0F000h
	mov	word ptr [bp-002h],0000h
	jz	$L1
	or	bx,0F000h
	push	bx
	popf
	pushf
	pop	ax
	and	ax,0F000h
	mov	word ptr [bp-002h],0002h
	jz	$L1
	mov	bx,sp
	and	sp,-004h
	pushf
	pop	eax
	mov	ecx,eax
	xor	eax,00040000h
	push	eax
	popf
	pushf
	pop	eax
	xor	eax,ecx
	mov	word ptr [bp-002h],0003h
	jz	$L1
	mov	word ptr [bp-002h],0004h
$L1:	mov	ax,[bp-002h]
	pop	ds
	mov	sp,bp
	pop	bp
	retf

FPCPUID_TEXT	ENDS
	END
