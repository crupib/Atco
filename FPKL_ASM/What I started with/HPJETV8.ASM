; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	hpjetv8.C
; [000E]	.286p
	.287
	; Large Memory Model
; [0016]	; CodeView Enabled
HPJETV8_TEXT	SEGMENT	WORD PUBLIC 'CODE'
HPJETV8_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [0191]	; Linker - Pass two marker

	EXTRN		_fopen:NEAR
	EXTRN		_fclose:NEAR
	EXTRN		_prnbufa:NEAR
	EXTRN		_getpixv:NEAR
	EXTRN		__aFftol:NEAR
	EXTRN		_filmem:NEAR
	EXTRN		_vm:WORD
	EXTRN		_getkey:NEAR
	EXTRN		_chkey:NEAR
	EXTRN		_sprintf:NEAR
	EXTRN		_getcregs:NEAR
	EXTRN		_prnstr:NEAR
	EXTRN		_getmode:NEAR
	EXTRN		_chkprn:NEAR
	EXTRN		_fscanf:NEAR
	EXTRN		FIWRQQ:ABS
	EXTRN		FIDRQQ:ABS
	EXTRN		FIERQQ:ABS
	EXTRN		FISRQQ:ABS
	EXTRN		FJSRQQ:ABS
	EXTRN		FIARQQ:ABS
	EXTRN		FJARQQ:ABS
	EXTRN		FICRQQ:ABS
	EXTRN		FJCRQQ:ABS
	EXTRN		__fltused:ABS
	PUBLIC		_hpjet			; Located at 1:0000h Type = 1

HPJETV8_TEXT	SEGMENT
	assume	cs: HPJETV8_TEXT


_hpjet:	enter	0013Eh,000h
	push	di
	push	si
	mov	word ptr [bp-064h],0000h
	call	far ptr _chkprn
	inc	ax
	jz	$L1
	jmp	near ptr $L2
$L1:	mov	ax,0FFFFh
	jmp	$L3
$L2:	call	far ptr _getmode

	assume	ds: DGROUP
	mov	es,word ptr $S4
	mov	es:_vm,ax
	push	ds
	push	offset DGROUP:$S5
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _fopen
	add	sp,+008h
	mov	[bp-00CAh],ax
	mov	[bp-00C8h],dx
	mov	ax,[bp-00C8h]
	or	ax,[bp-00CAh]
	jnz	$L6
	jmp	near ptr $L7
$L6:	lea	ax,[bp-062h]
	push	ss
	push	ax
	lea	ax,[bp-0122h]
	push	ss
	push	ax
	push	ds
	push	offset DGROUP:$S8
	push	[bp-00C8h]
	push	[bp-00CAh]
	call	far ptr _fscanf
	add	sp,+010h
$L12:	lea	ax,[bp-00C4h]
	push	ss
	push	ax
	push	ds
	push	offset DGROUP:$S9
	push	[bp-00C8h]
	push	[bp-00CAh]
	call	far ptr _fscanf
	add	sp,+00Ch
	mov	[bp-060h],ax
	inc	ax
	jnz	$L10
	jmp	near ptr $L11
$L10:	lea	ax,[bp-00C4h]
	push	ss
	push	ax
	call	far ptr _prnstr
	add	sp,+004h
	jmp	near ptr $L12
$L11:	push	[bp-00C8h]
	push	[bp-00CAh]
	call	far ptr _fclose
	add	sp,+004h
$L7:	cmp	word ptr [bp-062h],+000h
	jg	$L13
	jmp	$L14
$L13:	lea	ax,[bp-032h]
	push	ss
	push	ax
	call	far ptr _getcregs
	add	sp,+004h
	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L15
$L30:	inc	word ptr [bp-06Ah]
$L15:	cmp	word ptr [bp-06Ah],+010h
	jl	$L16
	jmp	$L14
$L16:	mov	si,[bp-06Ah]
	mov	ax,si
	shl	si,1
	add	si,ax
	mov	al,[bp+si-032h]
	cbw
	mov	[bp-070h],ax
	mov	si,[bp-06Ah]
	mov	ax,si
	shl	si,1
	add	si,ax
	mov	al,[bp+si-031h]
	cbw
	mov	[bp-034h],ax
	mov	si,[bp-06Ah]
	mov	ax,si
	shl	si,1
	add	si,ax
	mov	al,[bp+si-030h]
	cbw
	mov	[bp-06Eh],ax
	cmp	word ptr [bp-06Ah],+000h
	jz	$L17
	jmp	near ptr $L18
$L17:	cmp	word ptr [bp-062h],+003h
	jl	$L19
	jmp	near ptr $L18
$L19:	mov	word ptr [bp-070h],005Ah
	mov	word ptr [bp-034h],0058h
	mov	word ptr [bp-06Eh],0055h
	jmp	near ptr $L20
$L18:	cmp	word ptr [bp-06Ah],+00Fh
	jz	$L21
	jmp	near ptr $L22
$L21:	cmp	word ptr [bp-062h],+002h
	jl	$L23
	jmp	near ptr $L22
$L23:	mov	ax,0004h
	mov	[bp-070h],ax
	mov	[bp-034h],ax
	mov	word ptr [bp-06Eh],0006h
	jmp	near ptr $L20

$L22	dw	FIDRQQ - 02065h
	inc	si
	nop
	dw	FIDRQQ - 02365h
	push	cs
	dw	DGROUP:$S24
	dw	FIDRQQ - 02365h
	push	es
	dw	DGROUP:$S25
	call	far ptr __aFftol
	mov	[bp-070h],ax
	dw	FIDRQQ - 02065h
	inc	si
	int	3
	dw	FIDRQQ - 02365h
	push	cs
	dw	DGROUP:$S26
	dw	FIDRQQ - 02365h
	push	es
	dw	DGROUP:$S25
	call	far ptr __aFftol
	mov	[bp-034h],ax
	dw	FIDRQQ - 02065h
	inc	si
	xchg	ax,dx
	dw	FIDRQQ - 02365h
	push	cs
	dw	DGROUP:$S27
	dw	FIDRQQ - 02365h
	push	es
	dw	DGROUP:$S28
	call	far ptr __aFftol
	mov	[bp-06Eh],ax
$L20:	push	[bp-06Ah]
	push	[bp-06Eh]
	push	[bp-034h]
	push	[bp-070h]
	push	ds
	push	offset DGROUP:$S29
	lea	ax,[bp-05Ch]
	push	ss
	push	ax
	call	far ptr _sprintf
	add	sp,+010h
	lea	ax,[bp-05Ch]
	push	ss
	push	ax
	call	far ptr _prnstr
	add	sp,+004h
	jmp	$L30
$L14:	mov	word ptr [bp-0124h],0000h
	jmp	near ptr $L31
$L49:	inc	word ptr [bp-0124h]
$L31:	cmp	word ptr [bp-0124h],0320h
	jl	$L32
	jmp	$L33
$L32:	call	far ptr _chkey
	cmp	ax,0000h
	jnz	$L34
	jmp	near ptr $L35
$L34:	call	far ptr _getkey
	mov	[bp-066h],al
	cmp	byte ptr [bp-066h],1Bh
	jz	$L36
	jmp	near ptr $L35
$L36:	jmp	$L33
$L35:	cmp	byte ptr [bp-0122h],0Ah
	jnz	$L37
	jmp	near ptr $L38
$L37:	lea	ax,[bp-0122h]
	push	ss
	push	ax
	call	far ptr _prnstr
	add	sp,+004h
$L38:	mov	word ptr [bp-06Ch],0000h
	jmp	near ptr $L39
$L48:	inc	word ptr [bp-06Ch]
$L39:	cmp	word ptr [bp-06Ch],+004h
	jl	$L40
	jmp	near ptr $L41
$L40:	push	+000h
	push	+026h
	push	ds
	push	offset DGROUP:$S42
	call	far ptr _filmem
	add	sp,+008h
	push	ds
	push	offset DGROUP:$S42
	push	[bp-06Ch]
	push	0258h
	push	+000h
	push	[bp-0124h]
	call	far ptr _getpixv
	add	sp,+00Ch
	cmp	word ptr [bp-06Ch],+003h
	jl	$L43
	jmp	near ptr $L44
$L43:	push	+006h
	push	ds
	push	offset DGROUP:$S45
	call	far ptr _prnbufa
	add	sp,+006h
	mov	[bp-060h],ax
	jmp	near ptr $L46
$L44:	push	+006h
	push	ds
	push	offset DGROUP:$S47
	call	far ptr _prnbufa
	add	sp,+006h
	mov	[bp-060h],ax
$L46:	push	+04Bh
	push	ds
	push	offset DGROUP:$S42
	call	far ptr _prnbufa
	add	sp,+006h
	mov	[bp-060h],ax
	jmp	near ptr $L48
$L41:	jmp	$L49
$L33:	push	ds
	push	offset DGROUP:$S50
	call	far ptr _prnstr
	add	sp,+004h
	push	ds
	push	offset DGROUP:$S51
	call	far ptr _prnstr
	add	sp,+004h
	mov	ax,0000h
	jmp	near ptr $L3
$L3:	pop	si
	pop	di
	leave
	retf

HPJETV8_TEXT	ENDS
_DATA	SEGMENT

$S5	db	072h
	db	000h
$S8	db	'%s %i',000h
$S9	db	'%s',000h
$S29	db	01Bh,'*v%-iA',01Bh,'*v%-iB',01Bh,'*v%-iC',01Bh,'*v%-iI'
	db	000h
$S50	db	01Bh,'*r0B',000h
$S51	db	00Ch
	db	00Dh
	db	000h

	db	1 dup(?)
$S45	db	01Bh,'*b75V',000h
	db	000h
$S47	db	01Bh,'*b75W',000h
	db	000h

_DATA	ENDS
CONST	SEGMENT

$S4	dw	_vm

$S24	db	0D7h
	db	0A3h
	db	'p=',00Ah
	db	0D7h
	db	0F5h
	db	03Fh
$S25	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	010h
	db	040h
$S26	db	087h
	db	016h
	db	0D9h
	db	0CEh
	db	0F7h
	db	053h
	db	0F5h
	db	03Fh
$S27	db	0AAh
	db	0F1h
	db	0D2h
	db	04Dh
	db	062h
	db	010h
	db	0F4h
	db	03Fh
$S28	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	018h
	db	040h

CONST	ENDS
_BSS	SEGMENT

	dd	1 dup(?)
$S42	db	100 dup(?)

_BSS	ENDS
	END
