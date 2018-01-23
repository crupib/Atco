; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	vgahplj.C
; [000E]	.286p
	.287
	; Large Memory Model
; [0016]	; CodeView Enabled
VGAHPLJ_TEXT	SEGMENT	WORD PUBLIC 'CODE'
VGAHPLJ_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [018D]	; Linker - Pass two marker

	EXTRN		_calloc:NEAR
	EXTRN		_getcregs:NEAR
	EXTRN		__aFftol:NEAR
	EXTRN		_sprintf:NEAR
	EXTRN		_hp_laser_screen_dump_func:NEAR
	EXTRN		_prnchr:NEAR
	EXTRN		_prnbuf:NEAR
	EXTRN		_free:NEAR
	EXTRN		_strlen:NEAR
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
	PUBLIC		_hp_laser_screen_dump	; Located at 1:0000h Type = 1

VGAHPLJ_TEXT	SEGMENT
	assume	cs: VGAHPLJ_TEXT


_hp_laser_screen_dump:
	enter	0008Eh,000h
	push	di
	push	si
	mov	ax,[bp+00Ch]
	add	ax,[bp+008h]
	dec	ax
	mov	[bp-036h],ax
	sar	[bp+008h],03h
	mov	ax,[bp-036h]
	sub	ax,[bp+008h]
	add	ax,0010h
	sar	ax,05h
	mov	[bp-008Eh],ax
	mov	ax,[bp-008Eh]
	shl	ax,05h
	mov	[bp+00Ch],ax
	mov	ax,[bp+00Eh]
	add	ax,0007h
	and	ax,0FFF8h
	mov	[bp+00Eh],ax
	cmp	word ptr [bp+00Eh],+000h
	jg	$L1
	jmp	near ptr $L2
$L1:	cmp	word ptr [bp+00Ch],+000h
	jng	$L2
	jmp	near ptr $L3
$L2:	mov	ax,0001h
	jmp	$L4
$L3:	cmp	word ptr [bp+010h],+000h
	jz	$L5
	jmp	near ptr $L6
$L5:	mov	word ptr [bp-02Eh],05DCh
	mov	word ptr [bp-004h],0465h
	jmp	near ptr $L7
$L6:	mov	word ptr [bp-02Eh],0BB8h
	mov	word ptr [bp-004h],08CAh
$L7:	cmp	word ptr [bp+006h],+000h
	jg	$L8
	jmp	near ptr $L9
$L8:	mov	ax,[bp+00Ch]
	imul	word ptr [bp+006h]
	mov	[bp-032h],ax
	mov	ax,[bp+00Eh]
	imul	word ptr [bp+006h]
	mov	[bp-002h],ax
	mov	ax,[bp-032h]
	cmp	[bp-02Eh],ax
	jl	$L10
	jmp	near ptr $L11
$L10:	mov	ax,[bp-02Eh]
	cwd
	idiv	word ptr [bp+006h]
	mov	[bp+00Ch],ax
	and	word ptr [bp+00Ch],-020h
$L11:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jg	$L12
	jmp	near ptr $L13
$L12:	mov	ax,[bp-004h]
	cwd
	idiv	word ptr [bp+006h]
	mov	[bp+00Eh],ax
	and	word ptr [bp+00Eh],-008h
$L13:	jmp	near ptr $L14
$L9:	mov	ax,[bp-004h]
	cwd
	idiv	word ptr [bp+00Eh]
	mov	cx,ax
	mov	ax,[bp-02Eh]
	cwd
	idiv	word ptr [bp+00Ch]
	cmp	ax,cx
	jg	$L15
	jmp	near ptr $L16
$L15:	mov	ax,cx
$L16:	mov	[bp+006h],ax
$L14:	mov	ax,[bp+00Eh]
	imul	word ptr [bp+006h]
	add	ax,0007h
	sar	ax,03h
	mov	[bp-030h],ax
	push	[bp-030h]
	push	ds
	push	offset DGROUP:$S17
	lea	ax,[bp-02Ch]
	push	ss
	push	ax
	call	far ptr _sprintf
	add	sp,+00Ah
	push	6F5Ah
	push	+001h
	call	far ptr _calloc
	add	sp,+004h
	mov	[bp-03Ah],ax
	mov	[bp-038h],dx
	or	dx,ax
	jz	$L18
	jmp	near ptr $L19
$L18:	mov	ax,0001h
	jmp	$L4
$L19:	cmp	word ptr [bp+010h],+000h
	jz	$L20
	jmp	near ptr $L21
$L20:	push	+007h
	push	ds
	push	offset DGROUP:$S22
	call	far ptr _prnbuf
	add	sp,+006h
	jmp	near ptr $L23
$L21:	cmp	word ptr [bp+010h],+001h
	jz	$L24
	jmp	near ptr $L23
$L24:	push	+007h
	push	ds
	push	offset DGROUP:$S25
	call	far ptr _prnbuf
	add	sp,+006h
$L23:	lea	ax,[bp-008Ch]
	push	ss
	push	ax
	call	far ptr _getcregs
	db	083h
$L30:	les	ax,dword ptr [si]
	mov	word ptr [bp-034h],0000h
	jmp	near ptr $L26
$L40:	inc	word ptr [bp-034h]

$L26:	cmp	word ptr [bp-034h],+010h
	jl	$L27
	jmp	$L28
$L27:	mov	si,[bp-034h]
	mov	ax,si
	shl	si,1
$L35:	add	si,ax
	mov	al,[bp+si-008Bh]
	sub	ah,ah
	shl	ax,1
	mov	si,[bp-034h]
	mov	cx,si
	shl	si,1
	add	si,cx
	mov	cl,[bp+si-008Ch]
	sub	ch,ch
	add	ax,cx
	mov	cx,ax
	shl	ax,1
	add	ax,cx
	mov	si,[bp-034h]
	mov	cx,si
	shl	si,1
	add	si,cx
	mov	cl,[bp+si-008Ah]
	sub	ch,ch
	add	ax,cx
	mov	[bp-03Ch],ax
	dw	FIDRQQ - 02065h
	inc	si
	db	0C4h
	dw	FIDRQQ - 02365h
	push	ss
	dw	DGROUP:$S29
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L30
	jc	$L31
	jmp	near ptr $L32
$L31:	mov	word ptr [bp-03Ch],0000h
	jmp	near ptr $L33

$L32	dw	FIDRQQ - 02065h
	inc	si
	db	0C4h
	dw	FIDRQQ - 02365h
	push	ss
	dw	DGROUP:$S34
	dw	FIDRQQ - 02265h
	db	0D8h
	dw	FIDRQQ - 02065h
	loopnz	$L35
	jnbe	$L36
	jmp	near ptr $L37
$L36:	mov	word ptr [bp-03Ch],0276h
	jmp	near ptr $L33

$L37	dw	FIDRQQ - 02065h
	inc	si
	db	0C4h
	dw	FIDRQQ - 02365h
	push	cs
	dw	DGROUP:$S38
	dw	FIDRQQ - 02365h
	push	cs
	dw	DGROUP:$S34
	dw	FIDRQQ - 02365h
	push	es
	dw	DGROUP:$S39
	call	far ptr __aFftol
	mov	[bp-03Ch],ax
$L33:	mov	ax,0276h
	sub	ax,[bp-03Ch]
	mov	si,[bp-034h]
	shl	si,1
	mov	[bp+si-05Ch],ax
	jmp	$L40
$L28:	push	[bp-030h]
	mov	ax,[bp+00Eh]
	imul	word ptr [bp+006h]
	shl	ax,1
	add	ax,0003h
	cwd
	xor	ax,dx
	sub	ax,dx
	sar	ax,02h
	xor	ax,dx
	sub	ax,dx
	push	ax
	lea	ax,[bp-02Ch]
	push	ss
	push	ax
	call	far ptr _strlen
	add	sp,+004h
	push	ax
	lea	ax,[bp-02Ch]
	push	ss
	push	ax
	lea	ax,[bp-05Ch]
	push	ss
	push	ax
	push	[bp-038h]
	push	[bp-03Ah]
	push	[bp+006h]
	push	[bp+00Eh]
	push	[bp-008Eh]
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _hp_laser_screen_dump_func
	add	sp,+01Ch
	push	+004h
	push	ds
	push	offset DGROUP:$S41
	call	far ptr _prnbuf
	add	sp,+006h
	push	+00Ch
	call	far ptr _prnchr
	add	sp,+002h
	push	[bp-038h]
	push	[bp-03Ah]
	call	far ptr _free
	add	sp,+004h
$L4:	pop	si
	pop	di
	leave
	retf

VGAHPLJ_TEXT	ENDS
_DATA	SEGMENT

$S17	db	01Bh,'*b%dW',000h
$S22	db	01Bh,'*t150R',000h
$S25	db	01Bh,'*t300R',000h
$S41	db	01Bh,'*rB',000h

_DATA	ENDS
CONST	SEGMENT

$S29	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h

$S34	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	0B0h
	db	083h
	db	040h

$S38	db	01Ah
	db	0A0h
	db	001h
	db	01Ah
	db	0A0h
	db	001h
	db	05Ah
	db	03Fh
$S39	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	0E0h
	db	03Fh

CONST	ENDS
	END
