; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	bios.C
; [000B]	.286p
	.287
	; Large Memory Model
; [0013]	; CodeView Enabled
BIOS_TEXT	SEGMENT	WORD PUBLIC 'CODE'
BIOS_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [03EF]	; Linker - Pass two marker

	EXTRN		_int86x:NEAR
	EXTRN		_setdac:NEAR
	EXTRN		_funct:NEAR
	EXTRN		_strlen:NEAR
	EXTRN		_fscanf:NEAR
	EXTRN		_chrplt:NEAR
	EXTRN		_dsplaf:NEAR
	EXTRN		_fputc:NEAR
	EXTRN		_fopen:NEAR
	EXTRN		_int86:NEAR
	EXTRN		_fclose:NEAR
	COMM FAR	_pfptr:BYTE:4
	COMM FAR	_sregs:BYTE:8
	PUBLIC		_mode			; Located at 1:0000h Type = 1
	PUBLIC		_getmode		; Located at 1:0096h Type = 1
	PUBLIC		_getxsize		; Located at 1:00EDh Type = 1
	PUBLIC		_cursor			; Located at 1:0124h Type = 1
	PUBLIC		_tblank			; Located at 1:0164h Type = 1
	PUBLIC		_blank			; Located at 1:01A0h Type = 1
	PUBLIC		_chkprn			; Located at 1:01EDh Type = 1
	PUBLIC		_rdcurs			; Located at 1:0239h Type = 1
	PUBLIC		_cgapal			; Located at 1:027Dh Type = 1
	PUBLIC		_setpal			; Located at 1:02B8h Type = 1
	PUBLIC		_getpregs		; Located at 1:02F8h Type = 1
	PUBLIC		_getcregs		; Located at 1:0347h Type = 1
	PUBLIC		_setbor			; Located at 1:03E8h Type = 1
	PUBLIC		_setvga			; Located at 1:0422h Type = 1
	PUBLIC		_dsplac			; Located at 1:0480h Type = 1
	PUBLIC		_dsplay			; Located at 1:04F9h Type = 1
	PUBLIC		_gdisp			; Located at 1:0575h Type = 1
	PUBLIC		_dsplin			; Located at 1:06F8h Type = 1
	PUBLIC		_dspchr			; Located at 1:0790h Type = 1
	PUBLIC		_keysta			; Located at 1:082Fh Type = 1
	PUBLIC		_getkeye		; Located at 1:0869h Type = 1
	PUBLIC		_keyrate		; Located at 1:08A3h Type = 1
	PUBLIC		_scroll			; Located at 1:08DDh Type = 1
	PUBLIC		_scrdmp			; Located at 1:0958h Type = 1
	PUBLIC		_setpag			; Located at 1:098Ah Type = 1
	PUBLIC		_pfopen			; Located at 1:09B9h Type = 1
	PUBLIC		_pfclose		; Located at 1:09FDh Type = 1
	PUBLIC		_prnstr			; Located at 1:0A1Dh Type = 1
	PUBLIC		_prnbuf			; Located at 1:0AE3h Type = 1
	PUBLIC		_prnchr			; Located at 1:0BA1h Type = 1
	PUBLIC		_select_printer_port	; Located at 1:0C27h Type = 1
	PUBLIC		_printer_port_number	; Located at 2:0000h Type = 4
	PUBLIC		_intno			; Located at 2:0002h Type = 4
	PUBLIC		_regs			; Located at 2:0004h Type = 3
	PUBLIC		_iprfsw			; Located at 2:0012h Type = 4

BIOS_TEXT	SEGMENT
	assume	cs: BIOS_TEXT


_mode:	enter	00002h,000h
	push	di
	push	si
	assume	ds: DGROUP
	mov	byte ptr $S1,00h
	mov	al,[bp+006h]
	mov	_regs,al
	mov	word ptr _intno,0010h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	cmp	word ptr [bp+006h],+038h
	jnz	$L2
	jmp	near ptr $L3
$L2:	cmp	word ptr [bp+006h],+030h
	jz	$L3
	jmp	near ptr $L4
$L3:	push	+000h
	push	+000h
	push	00FFh
	call	far ptr _setdac
	add	sp,+006h
	push	+03Fh
	push	3F3Fh
	push	+000h
	call	far ptr _setdac
	add	sp,+006h
	jmp	near ptr $L5
$L4:	cmp	word ptr [bp+006h],+010h
	jnl	$L6
	jmp	near ptr $L5
$L6:	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L7
$L9:	inc	word ptr [bp-002h]
$L7:	cmp	word ptr [bp-002h],+010h
	jl	$L8
	jmp	near ptr $L5
$L8:	push	[bp-002h]
	push	[bp-002h]
	call	far ptr _setpal
	add	sp,+004h
	jmp	near ptr $L9
$L5:	mov	ax,0000h
	jmp	near ptr $L10
$L10:	pop	si
	pop	di
	leave
	retf
_getmode:
	enter	00008h,000h
	push	di
	push	si
	mov	byte ptr $S1,0Fh
	mov	word ptr _intno,0010h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	al,_regs
	sub	ah,ah
	mov	[bp-004h],ax
	mov	word ptr [bp-002h],0000h
	mov	al,$S1
	sub	ah,ah
	mov	[bp-008h],ax
	mov	word ptr [bp-006h],0000h
	mov	ax,[bp-008h]
	sub	cx,cx
	add	[bp-004h],cx
	adc	[bp-002h],ax
	mov	ax,[bp-004h]
	mov	dx,[bp-002h]
	jmp	near ptr $L11
$L11:	pop	si
	pop	di
	leave
	retf
_getxsize:
	enter	00002h,000h
	push	di
	push	si
	mov	byte ptr $S1,0Fh
	mov	word ptr _intno,0010h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	al,$S1
	sub	ah,ah
	mov	[bp-002h],ax
	mov	ax,[bp-002h]
	jmp	near ptr $L12
$L12:	pop	si
	pop	di
	leave
	retf
_cursor:
	enter	00000h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	byte ptr $S1,02h
	mov	al,[bp+008h]
	mov	$S13,al
	mov	al,[bp+006h]
	mov	$S14,al
	mov	byte ptr $S15,00h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,0000h
	jmp	near ptr $L16
$L16:	pop	si
	pop	di
	leave
	retf
_tblank:
	enter	00002h,000h
	push	di
	push	si
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L17
$L21:	inc	word ptr [bp-002h]
$L17:	mov	ax,[bp-002h]
	cmp	[bp+006h],ax
	jg	$L18
	jmp	near ptr $L19
$L18:	push	[bp+00Ch]
	mov	ax,[bp-002h]
	add	ax,[bp+00Ah]
	push	ax
	push	[bp+008h]
	push	ds
	push	offset DGROUP:$S20
	call	far ptr _dsplaf
	add	sp,+00Ah
	jmp	near ptr $L21
$L19:	pop	si
	pop	di
	leave
	retf
_blank:	enter	00000h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _cursor
	add	sp,+004h
	mov	byte ptr $S1,09h
	mov	byte ptr _regs,20h
	mov	byte ptr $S15,00h
	mov	ax,[bp+006h]
	mov	$S22,ax
	mov	al,[bp+00Ch]
	mov	$S23,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	pop	si
	pop	di
	leave
	retf
_chkprn:
	enter	00002h,000h
	push	di
	push	si
	mov	word ptr _intno,0017h
	mov	byte ptr $S1,02h
	mov	word ptr $S13,0000h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	cmp	byte ptr $S1,90h
	jz	$L24
	jmp	near ptr $L25
$L24:	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L26
$L25:	mov	word ptr [bp-002h],0001h
$L26:	mov	ax,[bp-002h]
	jmp	near ptr $L27
$L27:	pop	si
	pop	di
	leave
	retf
_rdcurs:
	enter	00000h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	byte ptr $S1,03h
	mov	byte ptr $S15,00h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	al,$S14
	sub	ah,ah
	les	bx,dword ptr [bp+006h]
	mov	es:[bx],ax
	mov	al,$S13
	sub	ah,ah
	les	bx,dword ptr [bp+00Ah]
	mov	es:[bx],ax
	pop	si
	pop	di
	leave
	retf
_cgapal:
	enter	00000h,000h
	push	di
	push	si
	mov	byte ptr $S1,0Bh
	mov	al,[bp+006h]
	mov	$S15,al
	mov	al,[bp+008h]
	mov	$S23,al
	mov	word ptr _intno,0010h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,0000h
	jmp	near ptr $L28
$L28:	pop	si
	pop	di
	leave
	retf
_setpal:
	enter	00000h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	byte ptr $S1,10h
	mov	byte ptr _regs,00h
	mov	al,[bp+006h]
	mov	$S23,al
	mov	al,[bp+008h]
	mov	$S15,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,0000h
	jmp	near ptr $L29
$L29:	pop	si
	pop	di
	leave
	retf
_getpregs:
	enter	00004h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	byte ptr $S1,10h
	mov	byte ptr _regs,09h
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	mov	[bp-004h],ax
	mov	[bp-002h],dx
	mov	ax,[bp-004h]
	mov	word ptr $S13,ax
	mov	ax,[bp-002h]

	mov	es,word ptr $S30
	mov	word ptr es:_sregs,ax
	push	es
	push	offset _sregs
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86x
	add	sp,+00Eh
	pop	si
	pop	di
	leave
	retf
_getcregs:
	enter	00006h,000h
	push	di
	push	si
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L31
$L34:	inc	word ptr [bp-002h]
$L31:	cmp	word ptr [bp-002h],+010h
	jl	$L32
	jmp	$L33
$L32:	mov	word ptr _intno,0010h
	mov	byte ptr $S1,10h
	mov	byte ptr _regs,07h
	mov	al,[bp-002h]
	mov	$S23,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	byte ptr $S1,10h
	mov	byte ptr _regs,17h
	mov	al,$S15
	sub	ah,ah
	mov	word ptr $S23,ax
	mov	word ptr $S22,0001h
	mov	ax,[bp-002h]
	mov	cx,ax
	shl	ax,1
	add	ax,cx
	add	ax,[bp+006h]
	mov	dx,[bp+008h]
	mov	[bp-006h],ax
	mov	[bp-004h],dx
	mov	ax,[bp-006h]
	mov	word ptr $S13,ax
	mov	ax,[bp-004h]
	mov	es,word ptr $S30
	mov	word ptr es:_sregs,ax
	push	es
	push	offset _sregs
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86x
	add	sp,+00Eh
	jmp	$L34
$L33:	pop	si
	pop	di
	leave
	retf
_setbor:
	enter	00000h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	byte ptr $S1,10h
	mov	byte ptr _regs,01h
	mov	al,[bp+006h]
	mov	$S15,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,0000h
	jmp	near ptr $L35
$L35:	pop	si
	pop	di
	leave
	retf
_setvga:
	enter	00004h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	word ptr [bp-004h],0000h
	mov	byte ptr $S1,10h
	mov	byte ptr _regs,10h
	mov	ax,[bp+006h]
	mov	word ptr $S23,ax
	mov	al,[bp+008h]
	mov	$S14,al
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
	mov	al,ah
	mov	ah,dl
	mov	dl,dh
	shl	dh,1
	sbb	dh,dh
	mov	byte ptr $S22 + 00001h,al
	mov	al,[bp+00Ah]
	mov	byte ptr $S22,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,0000h
	jmp	near ptr $L36
$L36:	pop	si
	pop	di
	leave
	retf
_dsplac:
	enter	00004h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L37
$L40:	inc	word ptr [bp-004h]
$L37:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	mov	al,es:[bx+si]
	mov	[bp-002h],al
	cmp	al,00h
	jnz	$L38
	jmp	near ptr $L39
$L38:	push	[bp+00Ch]
	push	[bp+00Ah]
	call	far ptr _cursor
	add	sp,+004h
	mov	al,[bp-002h]
	mov	_regs,al
	mov	byte ptr $S1,09h
	mov	al,[bp+00Fh]
	mov	$S15,al
	mov	word ptr $S22,0001h
	mov	al,[bp+00Eh]
	mov	$S23,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	inc	word ptr [bp+00Ch]
	jmp	near ptr $L40
$L39:	mov	ax,0000h
	jmp	near ptr $L41
$L41:	pop	si
	pop	di
	leave
	retf
_dsplay:
	enter	00004h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L42
$L45:	inc	word ptr [bp-004h]
$L42:	mov	ax,[bp+00Ah]
	cmp	[bp-004h],ax
	jl	$L43
	jmp	near ptr $L44
$L43:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	mov	al,es:[bx+si]
	mov	[bp-002h],al
	push	[bp+00Eh]
	push	[bp+00Ch]
	call	far ptr _cursor
	add	sp,+004h
	mov	al,[bp-002h]
	mov	_regs,al
	mov	byte ptr $S1,09h
	mov	byte ptr $S15,00h
	mov	word ptr $S22,0001h
	mov	al,[bp+010h]
	mov	$S23,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	inc	word ptr [bp+00Eh]
	jmp	near ptr $L45
$L44:	mov	ax,0000h
	jmp	near ptr $L46
$L46:	pop	si
	pop	di
	leave
	retf
_gdisp:	enter	0005Ch,000h
	push	di
	push	si
	call	far ptr _getmode
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],+010h
	jl	$L47
	jmp	near ptr $L48
$L47:	mov	word ptr [bp-05Ah],00C8h
	jmp	near ptr $L49
$L48:	cmp	word ptr [bp-002h],+010h
	jz	$L50
	jmp	near ptr $L51
$L50:	mov	word ptr [bp-05Ah],015Eh
	jmp	near ptr $L49
$L51:	cmp	word ptr [bp-002h],+012h
	jz	$L52
	jmp	near ptr $L53
$L52:	mov	word ptr [bp-05Ah],01E0h
	jmp	near ptr $L49
$L53:	cmp	word ptr [bp-002h],+012h
	jg	$L54
	jmp	near ptr $L49
$L54:	mov	word ptr [bp-05Ah],0258h
$L49:	cmp	word ptr [bp-002h],+004h
	jnl	$L55
	jmp	near ptr $L56
$L55:	cmp	word ptr [bp-002h],+007h
	jz	$L56
	jmp	near ptr $L57
$L56:	mov	word ptr _intno,0010h
	mov	word ptr [bp-05Ch],0000h
	jmp	near ptr $L58
$L61:	inc	word ptr [bp-05Ch]
$L58:	mov	ax,[bp-05Ch]
	cmp	[bp+00Ah],ax
	jg	$L59
	jmp	near ptr $L60
$L59:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-05Ch]
	mov	al,es:[bx+si]
	mov	[bp-058h],al
	push	[bp+00Eh]
	push	[bp+00Ch]
	call	far ptr _cursor
	add	sp,+004h
	mov	al,[bp-058h]
	mov	_regs,al
	mov	byte ptr $S1,09h
	mov	byte ptr $S15,00h
	mov	word ptr $S22,0001h
	mov	al,[bp+010h]
	mov	$S23,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	inc	word ptr [bp+00Eh]
	jmp	near ptr $L61
$L60:	jmp	$L62
$L57:	push	+000h
	call	far ptr _funct
	add	sp,+002h
	mov	word ptr [bp-05Ch],0000h
	jmp	near ptr $L63
$L67:	inc	word ptr [bp-05Ch]
$L63:	mov	ax,[bp-05Ch]
	cmp	[bp+00Ah],ax
	jg	$L64
	jmp	near ptr $L65
$L64:	cmp	word ptr [bp-05Ch],+050h
	jl	$L66
	jmp	near ptr $L65
$L66:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-05Ch]
	mov	al,es:[bx+si]
	mov	si,[bp-05Ch]
	mov	[bp+si-056h],al
	jmp	near ptr $L67
$L65:	cmp	word ptr [bp+00Ah],+050h
	jl	$L68
	jmp	near ptr $L69
$L68:	mov	si,[bp+00Ah]
	mov	byte ptr [bp+si-056h],00h
	jmp	near ptr $L70
$L69:	mov	byte ptr [bp-006h],00h
$L70:	cmp	word ptr [bp-05Ah],00C8h
	jnz	$L71
	jmp	near ptr $L72
$L71:	cmp	word ptr [bp+010h],+020h
	jl	$L72
	jmp	near ptr $L73
$L72:	mov	ax,0FFFFh
	sub	ax,[bp+00Ch]
	shl	ax,03h
	add	ax,[bp-05Ah]
	mov	[bp-004h],ax
	jmp	near ptr $L74
$L73:	mov	ax,0FFFFh
	sub	ax,[bp+00Ch]
	mov	cx,ax
	shl	ax,1
	add	ax,cx
	shl	ax,1
	add	ax,cx
	shl	ax,1
	add	ax,[bp-05Ah]
	mov	[bp-004h],ax

$L74:	push	[bp+010h]
	push	[bp-004h]
	mov	ax,[bp+00Eh]
	shl	ax,03h
	push	ax
	lea	ax,[bp-056h]
	push	ss
	push	ax
	call	far ptr _chrplt
	add	sp,+00Ah
$L62:	mov	ax,0000h
	jmp	near ptr $L75
$L75:	pop	si
	pop	di
	leave
	retf
_dsplin:
	enter	00008h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	ax,[bp+00Ch]
	mov	[bp-002h],ax
	mov	word ptr [bp-006h],0000h
	jmp	near ptr $L76
$L79:	inc	word ptr [bp-006h]
$L76:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-006h]
	mov	al,es:[bx+si]
	mov	[bp-004h],al
	cmp	al,00h
	jnz	$L77
	jmp	near ptr $L78
$L77:	inc	word ptr [bp-002h]
	push	[bp+00Ch]
	push	[bp+00Ah]
	call	far ptr _cursor
	add	sp,+004h
	mov	al,[bp-004h]
	mov	_regs,al
	mov	byte ptr $S1,09h
	mov	byte ptr $S15,00h
	mov	word ptr $S22,0001h
	mov	al,[bp+00Eh]
	mov	$S23,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	inc	word ptr [bp+00Ch]
	jmp	near ptr $L79
$L78:	mov	ax,004Fh
	sub	ax,[bp-002h]
	mov	[bp-008h],ax
	push	[bp+00Eh]
	push	[bp-002h]
	push	[bp+00Ah]
	push	[bp-008h]
	call	far ptr _blank
	add	sp,+008h
	pop	si
	pop	di
	leave
	retf
_dspchr:
	enter	00004h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	mov	al,[bp+006h]
	mov	_regs,al
	cmp	byte ptr [bp+006h],08h
	jz	$L80
	jmp	near ptr $L81
$L80:	mov	byte ptr _regs,20h
$L81:	mov	byte ptr $S1,09h
	mov	byte ptr $S15,00h
	mov	word ptr $S22,0001h
	mov	al,[bp+008h]
	mov	$S23,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	lea	ax,[bp-004h]
	push	ss
	push	ax
	lea	cx,[bp-002h]
	push	ss
	push	cx
	call	far ptr _rdcurs
	add	sp,+008h
	cmp	byte ptr [bp+006h],08h
	jz	$L82
	jmp	near ptr $L83
$L82:	dec	word ptr [bp-004h]
	cmp	word ptr [bp-004h],+000h
	jl	$L84
	jmp	near ptr $L85
$L84:	mov	word ptr [bp-004h],0000h
$L85:	jmp	near ptr $L86
$L83:	inc	word ptr [bp-004h]
$L86:	cmp	word ptr [bp-004h],+04Fh
	jg	$L87
	jmp	near ptr $L88
$L87:	mov	word ptr [bp-004h],0000h
	inc	word ptr [bp-002h]
$L88:	push	[bp-004h]
	push	[bp-002h]
	call	far ptr _cursor
	add	sp,+004h
	pop	si
	pop	di
	leave
	retf
_keysta:
	enter	00002h,000h
	push	di
	push	si
	mov	byte ptr $S1,02h
	mov	word ptr _intno,0016h
	mov	word ptr [bp-002h],0000h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,word ptr _regs
	mov	[bp-002h],ax
	mov	ax,[bp-002h]
	jmp	near ptr $L89
$L89:	pop	si
	pop	di
	leave
	retf
_getkeye:
	enter	00002h,000h
	push	di
	push	si
	mov	word ptr [bp-002h],0000h
	mov	byte ptr $S1,10h
	mov	word ptr _intno,0016h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,word ptr _regs
	mov	[bp-002h],ax
	mov	ax,[bp-002h]
	jmp	near ptr $L90
$L90:	pop	si
	pop	di
	leave
	retf
_keyrate:
	enter	00000h,000h
	push	di
	push	si
	mov	word ptr _intno,0016h
	mov	byte ptr $S1,03h
	mov	byte ptr _regs,05h
	mov	al,[bp+006h]
	mov	$S23,al
	mov	al,[bp+008h]
	mov	$S15,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	pop	si
	pop	di
	leave
	retf
_scroll:
	enter	00000h,000h
	push	di
	push	si
	mov	word ptr _intno,0010h
	cmp	byte ptr [bp+006h],75h
	jnz	$L91
	jmp	near ptr $L92
$L91:	cmp	byte ptr [bp+006h],55h
	jz	$L92
	jmp	near ptr $L93
$L92:	mov	byte ptr $S1,06h
	jmp	near ptr $L94
$L93:	cmp	byte ptr [bp+006h],64h
	jnz	$L95
	jmp	near ptr $L96
$L95:	cmp	byte ptr [bp+006h],44h
	jz	$L96
	jmp	near ptr $L94
$L96:	mov	byte ptr $S1,07h
$L94:	mov	al,[bp+008h]
	mov	_regs,al
	mov	al,[bp+00Ah]
	mov	$S15,al
	mov	byte ptr $S22,00h
	mov	byte ptr $S22 + 00001h,00h
	mov	byte ptr $S13,4Fh
	mov	byte ptr $S14,18h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	mov	ax,0000h
	jmp	near ptr $L97
$L97:	pop	si
	pop	di
	leave
	retf
_scrdmp:
	enter	00000h,000h
	push	di
	push	si
	call	far ptr _chkprn
	dec	ax
	jz	$L98
	jmp	near ptr $L99
$L98:	jmp	near ptr $L100
$L99:	mov	word ptr _intno,0005h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
$L100:	pop	si
	pop	di
	leave
	retf
_setpag:
	enter	00000h,000h
	push	di
	push	si
	mov	byte ptr $S1,05h
	mov	al,[bp+006h]
	mov	_regs,al
	mov	word ptr _intno,0010h
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	pop	si
	pop	di
	leave
	retf
_pfopen:
	enter	00000h,000h
	push	di
	push	si
	push	ds
	push	offset DGROUP:$S101
	push	ds
	push	offset DGROUP:$S102
	call	far ptr _fopen
	add	sp,+008h

	mov	es,word ptr $S103
	mov	word ptr es:_pfptr,ax
	mov	word ptr es:_pfptr + 00002h,dx
	mov	ax,word ptr es:_pfptr + 00002h
	or	ax,word ptr es:_pfptr
	jz	$L104
	jmp	near ptr $L105
$L104:	mov	ax,0FFFFh
	jmp	near ptr $L106
	jmp	near ptr $L106
$L105:	mov	ax,0000h
	jmp	near ptr $L106
$L106:	pop	si
	pop	di
	leave
	retf
_pfclose:
	enter	00000h,000h
	push	di
	push	si
	mov	es,word ptr $S103
	push	word ptr es:_pfptr + 00002h
	push	word ptr es:_pfptr
	call	far ptr _fclose
	add	sp,+004h
	pop	si
	pop	di
	leave
	retf
_prnstr:
	enter	00004h,000h
	push	di
	push	si
	mov	ax,_printer_port_number
	mov	word ptr $S13,ax
	mov	word ptr _intno,0017h
	cmp	word ptr _iprfsw,+000h
	jz	$L107
	jmp	near ptr $L108
$L107:	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L109
$L115:	inc	word ptr [bp-004h]
$L109:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	cmp	byte ptr es:[bx+si],00h
	jnz	$L110
	jmp	near ptr $L111
$L110:	mov	byte ptr $S1,00h
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	mov	al,es:[bx+si]
	mov	_regs,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	cmp	byte ptr $S1,01h
	jz	$L112
	jmp	near ptr $L113
$L112:	mov	ax,[bp-004h]
	jmp	near ptr $L114
$L113:	jmp	near ptr $L115
$L111:	jmp	near ptr $L116
$L108:	cmp	word ptr _iprfsw,+001h
	jz	$L117
	jmp	near ptr $L116
$L117:	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L118
$L120:	inc	word ptr [bp-004h]
$L118:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	cmp	byte ptr es:[bx+si],00h
	jnz	$L119
	jmp	near ptr $L116
$L119:	mov	es,word ptr $S103
	push	word ptr es:_pfptr + 00002h
	push	word ptr es:_pfptr
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	mov	al,es:[bx+si]
	cbw
	push	ax
	call	far ptr _fputc
	add	sp,+006h
	mov	[bp-002h],ax
	jmp	near ptr $L120
$L116:	mov	ax,[bp-004h]
	jmp	near ptr $L114
$L114:	pop	si
	pop	di
	leave
	retf
_prnbuf:
	enter	00004h,000h
	push	di
	push	si
	mov	ax,_printer_port_number
	mov	word ptr $S13,ax
	mov	word ptr _intno,0017h
	cmp	word ptr _iprfsw,+000h
	jz	$L121
	jmp	near ptr $L122
$L121:	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L123
$L129:	inc	word ptr [bp-004h]
$L123:	mov	ax,[bp+00Ah]
	cmp	[bp-004h],ax
	jl	$L124
	jmp	near ptr $L125
$L124:	mov	byte ptr $S1,00h
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	mov	al,es:[bx+si]
	mov	_regs,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	cmp	byte ptr $S1,01h
	jz	$L126
	jmp	near ptr $L127
$L126:	mov	ax,[bp-004h]
	jmp	near ptr $L128
$L127:	jmp	near ptr $L129
$L125:	jmp	near ptr $L130
$L122:	cmp	word ptr _iprfsw,+001h
	jz	$L131
	jmp	near ptr $L130
$L131:	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L132
$L134:	inc	word ptr [bp-004h]
$L132:	mov	ax,[bp+00Ah]
	cmp	[bp-004h],ax
	jl	$L133
	jmp	near ptr $L130
$L133:	mov	es,word ptr $S103
	push	word ptr es:_pfptr + 00002h
	push	word ptr es:_pfptr
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	mov	al,es:[bx+si]
	cbw
	push	ax
	call	far ptr _fputc
	add	sp,+006h
	mov	[bp-002h],ax
	jmp	near ptr $L134
$L130:	mov	ax,[bp-004h]
	jmp	near ptr $L128
$L128:	pop	si
	pop	di
	leave
	retf
_prnchr:
	enter	00002h,000h
	push	di
	push	si
	cmp	word ptr _iprfsw,+000h
	jz	$L135
	jmp	near ptr $L136
$L135:	mov	ax,_printer_port_number
	mov	word ptr $S13,ax
	mov	word ptr _intno,0017h
	mov	byte ptr $S1,00h
	mov	al,[bp+006h]
	mov	_regs,al
	push	ds
	push	offset DGROUP:_regs
	push	ds
	push	offset DGROUP:_regs
	push	_intno
	call	far ptr _int86
	add	sp,+00Ah
	cmp	byte ptr $S1,01h
	jz	$L137
	jmp	near ptr $L138
$L137:	mov	ax,0FFFFh
	jmp	near ptr $L139
$L138:	mov	ax,0000h
	jmp	near ptr $L139
	jmp	near ptr $L140
$L136:	cmp	word ptr _iprfsw,+001h
	jz	$L141
	jmp	near ptr $L140
$L141:	mov	es,word ptr $S103
	push	word ptr es:_pfptr + 00002h
	push	word ptr es:_pfptr
	mov	al,[bp+006h]
	cbw
	push	ax
	call	far ptr _fputc
	add	sp,+006h
	mov	[bp-002h],ax
$L140:	mov	ax,[bp-002h]
	jmp	near ptr $L139
$L139:	pop	si
	pop	di
	leave
	retf
_select_printer_port:
	enter	00058h,000h
	push	di
	push	si
	mov	word ptr [bp-058h],0001h
	push	ds
	push	offset DGROUP:$S142
	push	ds
	push	offset DGROUP:$S143
	call	far ptr _fopen
	add	sp,+008h
	mov	[bp-056h],ax
	mov	[bp-054h],dx
	mov	ax,[bp-054h]
	or	ax,[bp-056h]
	jnz	$L144
	jmp	near ptr $L145
$L144:	lea	ax,[bp-052h]
	push	ss
	push	ax
	push	ds
	push	offset DGROUP:$S146
	push	[bp-054h]
	push	[bp-056h]
	call	far ptr _fscanf
	add	sp,+00Ch
	push	[bp-054h]
	push	[bp-056h]
	call	far ptr _fclose
	add	sp,+004h
$L145:	mov	word ptr _printer_port_number,0000h
	lea	ax,[bp-052h]
	push	ss
	push	ax
	call	far ptr _strlen
	add	sp,+004h
	mov	[bp-058h],ax
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L147
$L156:	inc	word ptr [bp-002h]
$L147:	mov	ax,[bp-058h]
	cmp	[bp-002h],ax
	jl	$L148
	jmp	near ptr $L149
$L148:	mov	si,[bp-002h]
	cmp	byte ptr [bp+si-052h],31h
	jz	$L150
	jmp	near ptr $L151
$L150:	mov	word ptr _printer_port_number,0000h
	jmp	near ptr $L149
	jmp	near ptr $L152
$L151:	mov	si,[bp-002h]
	cmp	byte ptr [bp+si-052h],32h
	jz	$L153
	jmp	near ptr $L154
$L153:	mov	word ptr _printer_port_number,0001h
	jmp	near ptr $L149
	jmp	near ptr $L152
$L154:	mov	si,[bp-002h]
	cmp	byte ptr [bp+si-052h],33h
	jz	$L155
	jmp	near ptr $L152
$L155:	mov	word ptr _printer_port_number,0002h
	jmp	near ptr $L149
$L152:	jmp	near ptr $L156
$L149:	pop	si
	pop	di
	leave
	retf

BIOS_TEXT	ENDS
_DATA	SEGMENT

_printer_port_number	dw	00000h
_intno	dw	00010h
_regs	db	001h
$S1	db	000h
$S23	db	001h
$S15	db	000h
$S22	dw	00001h
$S13	db	001h
$S14	db	000h
	db	001h
	db	000h
	db	001h
	db	000h
	db	001h
	db	000h
_iprfsw	dw	00000h

$S20	db	020h
	db	000h
$S101	db	'w+b',000h
$S102	db	'printer.tmp',000h
$S142	db	072h
	db	000h
$S143	db	'\sonix\printer\port',000h
$S146	db	'%s',000h

_DATA	ENDS
CONST	SEGMENT

$S30	dw	_sregs

$S103	dw	_pfptr

CONST	ENDS
	END
