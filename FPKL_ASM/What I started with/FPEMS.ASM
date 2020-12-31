; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fpems.C
; [000C]	.286p
	.287
	; Large Memory Model
; [0014]	; CodeView Enabled
FPEMS_TEXT	SEGMENT	WORD PUBLIC 'CODE'
FPEMS_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [02A8]	; Linker - Pass two marker

	EXTRN		_xfer:NEAR
	EXTRN		_write:NEAR
	EXTRN		_filmem:NEAR
	EXTRN		_read:NEAR
	EXTRN		__aFNalshl:NEAR
	EXTRN		__aFldiv:NEAR
	EXTRN		_ems6:NEAR
	EXTRN		_ems5:NEAR
	EXTRN		_ems4:NEAR
	EXTRN		_total:ABS
	EXTRN		_unalpgs:ABS
	EXTRN		_pfba:WORD
	EXTRN		_xferco:NEAR
	EXTRN		_memcpy:NEAR
	EXTRN		_get_ems:NEAR
	EXTRN		_xferci:NEAR
	PUBLIC		_fp_ems_alloc		; Located at 1:0000h Type = 1
	PUBLIC		_fp_ems_erase		; Located at 1:0091h Type = 1
	PUBLIC		_fp_ems_read		; Located at 1:0135h Type = 1
	PUBLIC		_fp_ems_redemc		; Located at 1:023Bh Type = 1
	PUBLIC		_fp_ems_write		; Located at 1:0307h Type = 1
	PUBLIC		_fp_ems_free		; Located at 1:040Dh Type = 1
	PUBLIC		_fp_dsk_ems		; Located at 1:0425h Type = 1
	PUBLIC		_fp_ems_dsk		; Located at 1:0540h Type = 1
	PUBLIC		_fp_ems_init		; Located at 1:065Bh Type = 1
	PUBLIC		_fp_ems_read_col	; Located at 1:06E4h Type = 1
	PUBLIC		_fp_ems_write_col	; Located at 1:07B8h Type = 1
	PUBLIC		_fp_ems_seek		; Located at 1:088Ch Type = 1

FPEMS_TEXT	SEGMENT
	assume	cs: FPEMS_TEXT


_fp_ems_alloc:
	enter	00004h,000h
	push	di
	push	si
	cmp	word ptr [bp+008h],+000h
	jng	$L1
	jmp	near ptr $L2
$L1:	jnl	$L3
	jmp	near ptr $L4
$L3:	cmp	word ptr [bp+006h],+000h
	jbe	$L4
	jmp	near ptr $L2
$L4:	mov	ax,0FFFFh
	jmp	near ptr $L5
$L2:	push	seg _total
	push	offset _total
	push	seg _unalpgs
	push	offset _unalpgs
	push	seg _pfba
	push	offset _pfba
	call	far ptr _get_ems
	add	sp,+00Ch
	cmp	ax,0000h
	jnz	$L6
	jmp	near ptr $L7
$L6:	mov	ax,0FFFFh
	jmp	near ptr $L5
$L7:	push	+000h
	push	4000h
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	sub	ax,0001h
	sbb	dx,+000h
	push	dx
	push	ax
	call	far ptr __aFldiv
	inc	ax
	mov	[bp-002h],ax
	lea	ax,[bp-004h]
	push	ss
	push	ax
	lea	ax,[bp-002h]
	push	ss
	push	ax
	call	far ptr _ems4
	add	sp,+008h
	cmp	ax,0000h
	jnz	$L8
	jmp	near ptr $L9
$L8:	mov	ax,0FFFFh
	jmp	near ptr $L5
$L9:	mov	ax,[bp-004h]
	jmp	near ptr $L5
$L5:	pop	si
	pop	di
	leave
	retf
_fp_ems_erase:
	enter	00008h,000h
	push	di
	push	si
	cmp	word ptr [bp+00Ah],+000h
	jng	$L10
	jmp	near ptr $L11
$L10:	jnl	$L12
	jmp	near ptr $L13
$L12:	cmp	word ptr [bp+008h],+000h
	jbe	$L13
	jmp	near ptr $L11
$L13:	mov	ax,0FFFFh
	jmp	near ptr $L14
$L11:	push	+000h
	push	4000h
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
	sub	ax,0001h
	sbb	dx,+000h
	push	dx
	push	ax
	call	far ptr __aFldiv
	inc	ax
	mov	[bp-004h],ax

	assume	ds: DGROUP
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	mov	word ptr [bp-008h],0000h
	mov	[bp-006h],ax
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L16
$L21:	inc	word ptr [bp-002h]
$L16:	mov	ax,[bp-004h]
	cmp	[bp-002h],ax
	jl	$L17
	jmp	near ptr $L18
$L17:	push	+000h
	push	[bp-002h]
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	cmp	ax,0000h
	jnz	$L19
	jmp	near ptr $L20
$L19:	mov	ax,0001h
	jmp	near ptr $L14
$L20:	push	[bp+00Ch]
	push	2000h
	push	[bp-006h]
	push	[bp-008h]
	call	far ptr _filmem
	add	sp,+008h
	jmp	near ptr $L21
$L18:	mov	ax,0000h
	jmp	near ptr $L14
$L14:	pop	si
	pop	di
	leave
	retf
_fp_ems_read:
	enter	0000Ch,000h
	push	di
	push	si
	mov	ax,[bp+00Ch]
	mov	dx,[bp+00Eh]
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
	mov	[bp-002h],ax
	mov	ax,[bp+00Ch]
	mov	dx,[bp+00Eh]
	add	ax,[bp+010h]
	adc	dx,+000h
	sub	ax,0001h
	sbb	dx,+000h
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
	sub	ax,[bp-002h]
	inc	ax
	mov	[bp-008h],ax
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L22
$L28:	inc	word ptr [bp-006h]
$L22:	mov	ax,[bp-008h]
	cmp	[bp-006h],ax
	jl	$L23
	jmp	near ptr $L24
$L23:	push	[bp-006h]
	mov	ax,[bp-006h]
	add	ax,[bp-002h]
	push	ax
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	cmp	ax,0000h
	jnz	$L25
	jmp	near ptr $L26
$L25:	mov	ax,0001h
	jmp	near ptr $L27
$L26:	jmp	near ptr $L28
$L24:	mov	ax,[bp+00Ch]
	and	ax,3FFFh
	mov	[bp-004h],ax
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	mov	cx,[bp-004h]
	mov	[bp-00Ch],cx
	mov	[bp-00Ah],ax
	test	byte ptr [bp+010h],01h
	jnz	$L29
	jmp	near ptr $L30
$L29:	push	[bp+010h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _memcpy
	add	sp,+00Ah
	jmp	near ptr $L31
$L30:	push	[bp+010h]
	push	[bp+00Ah]
	push	[bp+008h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	call	far ptr _xfer
	add	sp,+00Ah
$L31:	mov	ax,0000h
	jmp	near ptr $L27
$L27:	pop	si
	pop	di
	leave
	retf
_fp_ems_redemc:
	enter	00012h,000h
	push	di
	push	si
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	cwd
	mov	[bp-00Ch],ax
	mov	[bp-00Ah],dx
	push	+010h
	lea	ax,[bp-00Ch]
	push	ax
	call	far ptr __aFNalshl
	mov	word ptr [bp-004h],0FFFFh
	mov	word ptr [bp-00Eh],0000h
	jmp	near ptr $L32
$L37:	inc	word ptr [bp-00Eh]
$L32:	mov	ax,[bp+012h]
	cmp	[bp-00Eh],ax
	jc	$L33
	jmp	$L34
$L33:	mov	ax,[bp+00Ch]
	mov	dx,[bp+00Eh]
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
	mov	[bp-010h],ax
	mov	ax,[bp-010h]
	cmp	[bp-004h],ax
	jnz	$L35
	jmp	near ptr $L36
$L35:	push	+000h
	push	[bp-010h]
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-002h],ax
$L36:	mov	ax,[bp+00Ch]
	and	ax,3FFFh
	mov	[bp-012h],ax
	mov	ax,[bp-00Ch]
	mov	dx,[bp-00Ah]
	add	ax,[bp-012h]
	adc	dx,+000h
	mov	[bp-008h],ax
	mov	[bp-006h],dx
	les	bx,dword ptr [bp-008h]
	mov	al,es:[bx]
	les	bx,dword ptr [bp+008h]
	mov	si,[bp-00Eh]
	mov	es:[bx+si],al
	mov	ax,[bp+010h]
	sub	dx,dx
	add	[bp+00Ch],ax
	adc	[bp+00Eh],dx
	mov	ax,[bp-010h]
	mov	[bp-004h],ax
	jmp	$L37
$L34:	mov	ax,[bp-002h]
	jmp	near ptr $L38
$L38:	pop	si
	pop	di
	leave
	retf
_fp_ems_write:
	enter	0000Ch,000h
	push	di
	push	si
	mov	ax,[bp+00Ch]
	mov	dx,[bp+00Eh]
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
	mov	[bp-002h],ax
	mov	ax,[bp+00Ch]
	mov	dx,[bp+00Eh]
	add	ax,[bp+010h]
	adc	dx,+000h
	sub	ax,0001h
	sbb	dx,+000h
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
	sub	ax,[bp-002h]
	inc	ax
	mov	[bp-008h],ax
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L39
$L45:	inc	word ptr [bp-006h]
$L39:	mov	ax,[bp-008h]
	cmp	[bp-006h],ax
	jl	$L40
	jmp	near ptr $L41
$L40:	push	[bp-006h]
	mov	ax,[bp-006h]
	add	ax,[bp-002h]
	push	ax
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	cmp	ax,0000h
	jnz	$L42
	jmp	near ptr $L43
$L42:	mov	ax,0001h
	jmp	near ptr $L44
$L43:	jmp	near ptr $L45
$L41:	mov	ax,[bp+00Ch]
	and	ax,3FFFh
	mov	[bp-004h],ax
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	mov	cx,[bp-004h]
	mov	[bp-00Ch],cx
	mov	[bp-00Ah],ax
	test	byte ptr [bp+010h],01h
	jnz	$L46
	jmp	near ptr $L47
$L46:	push	[bp+010h]
	push	[bp+00Ah]
	push	[bp+008h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	call	far ptr _memcpy
	add	sp,+00Ah
	jmp	near ptr $L48
$L47:	push	[bp+010h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _xfer
	add	sp,+00Ah
$L48:	mov	ax,0000h
	jmp	near ptr $L44
$L44:	pop	si
	pop	di
	leave
	retf
_fp_ems_free:
	enter	00000h,000h
	push	di
	push	si
	push	[bp+006h]
	call	far ptr _ems6
	add	sp,+002h
	jmp	near ptr $L49
$L49:	pop	si
	pop	di
	leave
	retf
_fp_dsk_ems:
	enter	00012h,000h
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
	mov	[bp-00Ch],ax
	mov	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	add	ax,[bp+00Eh]
	adc	dx,+000h
	sub	ax,0001h
	sbb	dx,+000h
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
	mov	[bp-004h],ax
	mov	word ptr [bp-002h],0000h
	mov	word ptr [bp-00Ah],0000h
	mov	ax,[bp-00Ch]
	mov	[bp-00Eh],ax
	jmp	near ptr $L50
$L54:	inc	word ptr [bp-00Ah]
	inc	word ptr [bp-00Eh]
$L50:	cmp	word ptr [bp-00Ah],+004h
	jl	$L51
	jmp	near ptr $L52
$L51:	mov	ax,[bp-00Eh]
	cmp	[bp-004h],ax
	jnl	$L53
	jmp	near ptr $L52
$L53:	push	[bp-00Ah]
	push	[bp-00Eh]
	push	[bp+008h]
	call	far ptr _ems5
	add	sp,+006h
	or	[bp-002h],ax
	jmp	near ptr $L54
$L52:	cmp	word ptr [bp-002h],+000h
	jnz	$L55
	jmp	near ptr $L56
$L55:	mov	ax,[bp-002h]
	jmp	near ptr $L57
$L56:	mov	ax,[bp+00Ah]
	and	ax,3FFFh
	mov	[bp-008h],ax
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	cwd
	mov	[bp-012h],ax
	mov	[bp-010h],dx
	push	+010h
	lea	ax,[bp-012h]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp-008h]
	sub	dx,dx
	add	[bp-012h],ax
	adc	[bp-010h],dx
	push	[bp+00Eh]
	push	[bp-010h]
	push	[bp-012h]
	push	[bp+006h]
	call	far ptr _read
	add	sp,+008h
	mov	[bp-006h],ax
	cmp	ax,[bp+00Eh]
	jz	$L58
	jmp	near ptr $L59
$L58:	mov	ax,0000h
	jmp	near ptr $L57
	jmp	near ptr $L57
$L59:	mov	ax,0FFFFh
	jmp	near ptr $L57
$L57:	pop	si
	pop	di
	leave
	retf
_fp_ems_dsk:
	enter	00012h,000h
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
	mov	[bp-00Ch],ax
	mov	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	add	ax,[bp+00Eh]
	adc	dx,+000h
	sub	ax,0001h
	sbb	dx,+000h
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
	mov	[bp-004h],ax
	mov	word ptr [bp-002h],0000h
	mov	word ptr [bp-00Ah],0000h
	mov	ax,[bp-00Ch]
	mov	[bp-00Eh],ax
	jmp	near ptr $L60
$L64:	inc	word ptr [bp-00Ah]
	inc	word ptr [bp-00Eh]
$L60:	cmp	word ptr [bp-00Ah],+004h
	jl	$L61
	jmp	near ptr $L62
$L61:	mov	ax,[bp-00Eh]
	cmp	[bp-004h],ax
	jnl	$L63
	jmp	near ptr $L62
$L63:	push	[bp-00Ah]
	push	[bp-00Eh]
	push	[bp+008h]
	call	far ptr _ems5
	add	sp,+006h
	or	[bp-002h],ax
	jmp	near ptr $L64
$L62:	cmp	word ptr [bp-002h],+000h
	jnz	$L65
	jmp	near ptr $L66
$L65:	mov	ax,[bp-002h]
	jmp	near ptr $L67
$L66:	mov	ax,[bp+00Ah]
	and	ax,3FFFh
	mov	[bp-008h],ax
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	cwd
	mov	[bp-012h],ax
	mov	[bp-010h],dx
	push	+010h
	lea	ax,[bp-012h]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp-008h]
	sub	dx,dx
	add	[bp-012h],ax
	adc	[bp-010h],dx
	push	[bp+00Eh]
	push	[bp-010h]
	push	[bp-012h]
	push	[bp+006h]
	call	far ptr _write
	add	sp,+008h
	mov	[bp-006h],ax
	cmp	ax,[bp+00Eh]
	jz	$L68
	jmp	near ptr $L69
$L68:	mov	ax,0000h
	jmp	near ptr $L67
	jmp	near ptr $L67
$L69:	mov	ax,0FFFFh
	jmp	near ptr $L67
$L67:	pop	si
	pop	di
	leave
	retf
_fp_ems_init:
	enter	0000Ch,000h
	push	di
	push	si
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	cwd
	mov	[bp-00Ah],ax
	mov	[bp-008h],dx
	push	+010h
	lea	ax,[bp-00Ah]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp+008h]
	mov	[bp-00Ch],ax
	jmp	near ptr $L70
$L76:	inc	word ptr [bp-00Ch]
$L70:	mov	ax,[bp+00Ah]
	add	ax,[bp+008h]
	cmp	ax,[bp-00Ch]
	jnl	$L71
	jmp	near ptr $L72
$L71:	push	+000h
	push	[bp-00Ch]
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],+000h
	jnz	$L73
	jmp	near ptr $L74
$L73:	mov	ax,[bp-002h]
	jmp	near ptr $L75
$L74:	mov	ax,[bp-00Ah]
	mov	dx,[bp-008h]
	mov	[bp-006h],ax
	mov	[bp-004h],dx
	push	[bp+00Ch]
	push	2000h
	push	[bp-004h]
	push	[bp-006h]
	call	far ptr _filmem
	add	sp,+008h
	jmp	near ptr $L76
$L72:	mov	ax,0000h
	jmp	near ptr $L75
$L75:	pop	si
	pop	di
	leave
	retf
_fp_ems_read_col:
	enter	00016h,000h
	push	di
	push	si
	push	+000h
	push	[bp+00Eh]
	push	+001h
	push	+000h
	call	far ptr __aFldiv
	mov	[bp-016h],ax
	mov	ax,[bp+010h]
	dec	ax
	sub	dx,dx
	div	word ptr [bp-016h]
	inc	ax
	mov	[bp-006h],ax
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	cwd
	mov	[bp-00Eh],ax
	mov	[bp-00Ch],dx
	push	+010h
	lea	ax,[bp-00Eh]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp+00Ch]
	sub	dx,dx
	add	[bp-00Eh],ax
	adc	[bp-00Ch],dx
	mov	word ptr [bp-014h],0000h
	mov	word ptr [bp-012h],0000h
	jmp	near ptr $L77
$L84:	inc	word ptr [bp-012h]
$L77:	mov	ax,[bp-012h]
	cmp	[bp-006h],ax
	jg	$L78
	jmp	near ptr $L79
$L78:	mov	ax,[bp-012h]
	shl	ax,02h
	mov	[bp-004h],ax
	mov	ax,[bp-004h]
	add	ax,0004h
	mov	[bp-002h],ax
	mov	ax,[bp-004h]
	mov	[bp-010h],ax
	jmp	near ptr $L80
$L83:	inc	word ptr [bp-010h]
$L80:	mov	ax,[bp-002h]
	cmp	[bp-010h],ax
	jl	$L81
	jmp	near ptr $L82
$L81:	mov	al,[bp-010h]
	and	ax,0003h
	push	ax
	push	[bp-010h]
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L83
$L82:	push	[bp+00Eh]
	push	[bp-016h]
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
	add	ax,[bp-014h]
	push	dx
	push	ax
	push	[bp-00Ch]
	push	[bp-00Eh]
	call	far ptr _xferci
	add	sp,+00Ch
	mov	ax,[bp-016h]
	add	[bp-014h],ax
	jmp	near ptr $L84
$L79:	pop	si
	pop	di
	leave
	retf
_fp_ems_write_col:
	enter	00014h,000h
	push	di
	push	si
	push	+000h
	push	[bp+00Eh]
	push	+001h
	push	+000h
	call	far ptr __aFldiv
	mov	[bp-014h],ax
	mov	ax,[bp+010h]
	dec	ax
	sub	dx,dx
	div	word ptr [bp-014h]
	inc	ax
	mov	[bp-006h],ax
	mov	es,word ptr $S15
	mov	ax,es:_pfba
	cwd
	mov	[bp-00Ch],ax
	mov	[bp-00Ah],dx
	push	+010h
	lea	ax,[bp-00Ch]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp+00Ch]
	sub	dx,dx
	add	[bp-00Ch],ax
	adc	[bp-00Ah],dx
	mov	word ptr [bp-012h],0000h
	mov	word ptr [bp-010h],0000h
	jmp	near ptr $L85
$L92:	inc	word ptr [bp-010h]
$L85:	mov	ax,[bp-010h]
	cmp	[bp-006h],ax
	jg	$L86
	jmp	near ptr $L87
$L86:	mov	ax,[bp-010h]
	shl	ax,02h
	mov	[bp-004h],ax
	mov	ax,[bp-004h]
	add	ax,0004h
	mov	[bp-002h],ax
	mov	ax,[bp-004h]

	mov	[bp-00Eh],ax
	jmp	near ptr $L88
$L91:	inc	word ptr [bp-00Eh]
$L88:	mov	ax,[bp-002h]
	cmp	[bp-00Eh],ax
	jl	$L89
	jmp	near ptr $L90
$L89:	mov	al,[bp-00Eh]
	and	ax,0003h
	push	ax
	push	[bp-00Eh]
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L91
$L90:	push	[bp+00Eh]
	push	[bp-014h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
	add	ax,[bp-012h]
	push	dx
	push	ax
	call	far ptr _xferco
	add	sp,+00Ch
	mov	ax,[bp-014h]
	add	[bp-012h],ax
	jmp	near ptr $L92
$L87:	pop	si
	pop	di
	leave
	retf
_fp_ems_seek:
	enter	00004h,000h
	push	di
	push	si
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
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
	mov	[bp-002h],ax
	push	+000h
	push	[bp-002h]
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	cmp	ax,0000h
	jnz	$L93
	jmp	near ptr $L94
$L93:	mov	ax,0001h
	jmp	near ptr $L95
$L94:	mov	word ptr [bp-004h],0001h
	jmp	near ptr $L96
$L99:	inc	word ptr [bp-004h]
$L96:	cmp	word ptr [bp-004h],+004h
	jl	$L97
	jmp	near ptr $L98
$L97:	push	[bp-004h]
	mov	ax,[bp-004h]
	add	ax,[bp-002h]
	push	ax
	push	[bp+006h]
	call	far ptr _ems5
	add	sp,+006h
	jmp	near ptr $L99
$L98:	mov	es,word ptr $S15
	mov	ax,es:_pfba
	mov	cx,[bp+008h]
	and	cx,3FFFh
	les	bx,dword ptr [bp+00Ch]
	mov	es:[bx],cx
	mov	es:[bx+002h],ax
$L95:	pop	si
	pop	di
	leave
	retf

FPEMS_TEXT	ENDS
CONST	SEGMENT

$S15	dw	_pfba

CONST	ENDS
	END
