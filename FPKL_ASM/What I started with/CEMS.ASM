; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	cems.C
; [000B]	.286p
	.287
	; Large Memory Model
; [0013]	; CodeView Enabled
CEMS_TEXT	SEGMENT	WORD PUBLIC 'CODE'
CEMS_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [0316]	; Linker - Pass two marker

	EXTRN		__aFldiv:NEAR
	COMM FAR	_$e:BYTE:4
	EXTRN		_write:NEAR
	EXTRN		_read:NEAR
	COMM FAR	_total:BYTE:2
	COMM FAR	_unalpgs:BYTE:2
	EXTRN		_ems6:NEAR
	EXTRN		_filmem:NEAR
	EXTRN		_ems4:NEAR
	EXTRN		__aFNalshl:NEAR
	EXTRN		_hfree:NEAR
	EXTRN		_halloc:NEAR
	EXTRN		_xferco:NEAR
	EXTRN		_ems2:NEAR
	EXTRN		_ems1:NEAR
	EXTRN		_xfer:NEAR
	EXTRN		_ems3:NEAR
	EXTRN		_ems5:NEAR
	EXTRN		_xferci:NEAR
	PUBLIC		_get_unal		; Located at 1:0000h Type = 1
	PUBLIC		_get_ems		; Located at 1:002Ch Type = 1
	PUBLIC		_emalloc		; Located at 1:0075h Type = 1
	PUBLIC		_get_pfba		; Located at 1:02CFh Type = 1
	PUBLIC		_wrtems			; Located at 1:0317h Type = 1
	PUBLIC		_redems			; Located at 1:07F3h Type = 1
	PUBLIC		_redemc			; Located at 1:0CDEh Type = 1
	PUBLIC		_wrtemc			; Located at 1:0F29h Type = 1
	PUBLIC		_initems		; Located at 1:0FFBh Type = 1
	PUBLIC		_redcol			; Located at 1:1137h Type = 1
	PUBLIC		_wrtcol			; Located at 1:12D3h Type = 1
	PUBLIC		_unalloc		; Located at 1:146Fh Type = 1
	PUBLIC		_emsdsk			; Located at 1:1547h Type = 1
	PUBLIC		_dskems			; Located at 1:162Dh Type = 1
	PUBLIC		_bufems			; Located at 1:1713h Type = 1
	PUBLIC		_pfba			; Located at 2:0000h Type = 4
	PUBLIC		_handle			; Located at 2:0002h Type = 4
	PUBLIC		_iemssw			; Located at 2:0004h Type = 4
	PUBLIC		_$a			; Located at 2:0006h Type = 4
	PUBLIC		_$b			; Located at 2:000Ah Type = 4
	PUBLIC		_$c			; Located at 2:000Eh Type = 4
	PUBLIC		_$d			; Located at 2:0012h Type = 4
	PUBLIC		_$f			; Located at 2:0016h Type = 4
	PUBLIC		_$ia			; Located at 2:001Ah Type = 4
	PUBLIC		_$ib			; Located at 2:001Ch Type = 4
	PUBLIC		_$ic			; Located at 2:001Eh Type = 4
	PUBLIC		_$id			; Located at 2:0020h Type = 4
	PUBLIC		_$ie			; Located at 2:0022h Type = 4
	PUBLIC		_$if			; Located at 2:0024h Type = 4

CEMS_TEXT	SEGMENT
	assume	cs: CEMS_TEXT


_get_unal:
	enter	00002h,000h
	push	di
	push	si
	push	seg _total
	push	offset _total
	push	seg _unalpgs
	push	offset _unalpgs
	call	far ptr _ems3
	add	sp,+008h
	mov	[bp-002h],ax

	assume	ds: DGROUP
	mov	es,word ptr $S1
	mov	ax,word ptr es:_unalpgs
	jmp	near ptr $L2
$L2:	pop	si
	pop	di
	leave
	retf
_get_ems:
	enter	00004h,000h
	push	di
	push	si
	call	far ptr _ems1
	mov	[bp-004h],ax
	cmp	word ptr [bp-004h],+000h
	jz	$L3
	jmp	near ptr $L4
$L3:	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _ems2
	add	sp,+004h
	mov	[bp-002h],ax
	push	[bp+010h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	push	[bp+00Ah]
	call	far ptr _ems3
	add	sp,+008h
	mov	[bp-002h],ax
$L4:	mov	ax,[bp-004h]
	jmp	near ptr $L5
$L5:	pop	si
	pop	di
	leave
	retf
_emalloc:
	enter	00002h,000h
	push	di
	push	si
	cmp	word ptr [bp+008h],+001h
	jz	$L6
	jmp	near ptr $L7
$L6:	call	far ptr _ems1
	mov	_iemssw,ax
	jmp	near ptr $L8
$L7:	mov	word ptr _iemssw,0001h
$L8:	cmp	word ptr _iemssw,+000h
	jnz	$L9
	jmp	near ptr $L10
$L9:	mov	word ptr _iemssw,0001h
$L10:	cmp	word ptr _iemssw,+000h
	jz	$L11
	jmp	$L12
$L11:	push	ds
	push	offset DGROUP:_pfba
	call	far ptr _ems2
	add	sp,+004h
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],+000h
	jz	$L13
	jmp	near ptr $L14
$L13:	push	seg _total
	push	offset _total
	push	seg _unalpgs
	push	offset _unalpgs
	call	far ptr _ems3
	add	sp,+008h
	mov	[bp-002h],ax
	jmp	near ptr $L15
$L14:	mov	ax,[bp-002h]
	jmp	$L16
$L15:	mov	es,word ptr $S1
	mov	ax,[bp+006h]
	cmp	word ptr es:_unalpgs,ax
	jnl	$L17
	jmp	near ptr $L18
$L17:	cmp	word ptr [bp+006h],+000h
	jng	$L18
	jmp	near ptr $L19
$L18:	mov	es,word ptr $S1
	mov	ax,word ptr es:_unalpgs
	mov	[bp+006h],ax
$L19:	cmp	word ptr [bp-002h],+000h
	jz	$L20
	jmp	near ptr $L21
$L20:	push	ds
	push	offset DGROUP:_handle
	lea	ax,[bp+006h]
	push	ss
	push	ax
	call	far ptr _ems4
	add	sp,+008h
	mov	[bp-002h],ax
	jmp	near ptr $L22
$L21:	mov	ax,[bp-002h]
	jmp	$L16
$L22:	mov	ax,[bp-002h]
	jmp	$L16
	jmp	$L16
$L12:	cmp	word ptr [bp+006h],+000h
	jg	$L23
	jmp	near ptr $L24
$L23:	cmp	word ptr [bp+006h],+018h
	jnl	$L24
	jmp	near ptr $L25
$L24:	mov	word ptr [bp+006h],0018h
$L25:	mov	es,word ptr $S1
	mov	word ptr es:_unalpgs,0000h
	cmp	word ptr [bp+006h],+004h
	jnl	$L26
	jmp	near ptr $L27
$L26:	push	+001h
	push	+001h
	push	+000h
	call	far ptr _halloc
	add	sp,+006h
	mov	_$a,ax
	mov	$S28,dx
$L27:	mov	ax,$S28
	or	ax,_$a
	jnz	$L29
	jmp	$L16
$L29:	mov	word ptr _$ia,0001h
	mov	es,word ptr $S1
	mov	word ptr es:_unalpgs,0004h
	cmp	word ptr [bp+006h],+008h
	jnl	$L30
	jmp	near ptr $L31
$L30:	push	+001h
	push	+001h
	push	+000h
	call	far ptr _halloc
	add	sp,+006h
	mov	_$b,ax
	mov	$S32,dx
$L31:	mov	ax,$S32
	or	ax,_$b
	jnz	$L33
	jmp	$L16
$L33:	mov	word ptr _$ib,0001h
	mov	es,word ptr $S1
	mov	word ptr es:_unalpgs,0008h
	cmp	word ptr [bp+006h],+00Ch
	jnl	$L34
	jmp	near ptr $L35
$L34:	push	+001h
	push	+001h
	push	+000h
	call	far ptr _halloc
	add	sp,+006h
	mov	_$c,ax
	mov	$S36,dx
$L35:	mov	ax,$S36
	or	ax,_$c
	jnz	$L37
	jmp	$L16
$L37:	mov	word ptr _$ic,0001h
	mov	es,word ptr $S1
	mov	word ptr es:_unalpgs,000Ch
	cmp	word ptr [bp+006h],+010h
	jnl	$L38
	jmp	near ptr $L39
$L38:	push	+001h
	push	+001h
	push	+000h
	call	far ptr _halloc
	add	sp,+006h
	mov	_$d,ax
	mov	$S40,dx
$L39:	mov	ax,$S40
	or	ax,_$d
	jnz	$L41
	jmp	$L16
$L41:	mov	word ptr _$id,0001h
	mov	es,word ptr $S1
	mov	word ptr es:_unalpgs,0010h
	cmp	word ptr [bp+006h],+014h
	jnl	$L42
	jmp	near ptr $L43
$L42:	push	+001h
	push	+001h
	push	+000h
	call	far ptr _halloc
	add	sp,+006h

	mov	es,word ptr $S44
	mov	word ptr es:_$e,ax
	mov	word ptr es:_$e + 00002h,dx
$L43:	mov	es,word ptr $S44
	mov	ax,word ptr es:_$e + 00002h
	or	ax,word ptr es:_$e
	jnz	$L45
	jmp	near ptr $L16
$L45:	mov	word ptr _$ie,0001h
	mov	es,word ptr $S1
	mov	word ptr es:_unalpgs,0014h
	cmp	word ptr [bp+006h],+018h
	jnl	$L46
	jmp	near ptr $L47
$L46:	push	+001h
	push	+001h
	push	+000h
	call	far ptr _halloc
	add	sp,+006h
	mov	_$f,ax
	mov	$S48,dx
$L47:	mov	ax,$S48
	or	ax,_$f
	jnz	$L49
	jmp	near ptr $L16
$L49:	mov	word ptr _$if,0001h
	mov	es,word ptr $S1
	mov	word ptr es:_unalpgs,0018h
$L16:	pop	si
	pop	di
	leave
	retf
_get_pfba:
	enter	00002h,000h
	push	di
	push	si
	push	ds
	push	offset DGROUP:_pfba
	call	far ptr _ems2
	add	sp,+004h
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],+000h
	jz	$L50
	jmp	near ptr $L51
$L50:	push	seg _total
	push	offset _total
	push	seg _unalpgs
	push	offset _unalpgs
	call	far ptr _ems3
	add	sp,+008h
	mov	[bp-002h],ax
	jmp	near ptr $L52
$L51:	mov	ax,[bp-002h]
	jmp	near ptr $L53
$L52:	mov	ax,[bp-002h]
	jmp	near ptr $L53
$L53:	pop	si
	pop	di
	leave
	retf
_wrtems:
	enter	00014h,000h
	push	di
	push	si
	cmp	word ptr _iemssw,+000h
	jz	$L54
	jmp	$L55
$L54:	mov	ax,[bp+00Ah]
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
	jmp	near ptr $L56
$L59:	inc	word ptr [bp-010h]
$L56:	mov	ax,[bp-010h]
	cmp	[bp-014h],ax
	jnl	$L57
	jmp	near ptr $L58
$L57:	mov	al,[bp-010h]
	and	ax,0003h
	push	ax
	push	[bp-010h]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L59
$L58:	mov	ax,[bp+00Ah]
	mov	[bp-012h],ax
	mov	ax,_pfba
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
	push	[bp+00Eh]
	push	[bp-00Ch]
	push	[bp-00Eh]
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
	mov	ax,[bp-008h]
	jmp	$L60
	jmp	$L60
$L55:	mov	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	add	ax,[bp+00Eh]
	adc	dx,+000h
	mov	[bp-004h],ax
	mov	[bp-002h],dx
	cmp	word ptr [bp-002h],+001h
	jng	$L61
	jmp	near ptr $L62
$L61:	jnl	$L63
	jmp	near ptr $L64
$L63:	cmp	word ptr [bp-004h],+000h
	jbe	$L64
	jmp	near ptr $L62
$L64:	cmp	word ptr _$ia,+000h
	jnz	$L65
	jmp	near ptr $L62
$L65:	push	[bp+00Eh]
	mov	ax,_$a
	mov	dx,$S28
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L60
$L62:	cmp	word ptr [bp+00Ch],+001h
	jng	$L66
	jmp	near ptr $L67
$L66:	jnl	$L68
	jmp	near ptr $L69
$L68:	cmp	word ptr [bp+00Ah],+000h
	jc	$L69
	jmp	near ptr $L67
$L69:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ia,+000h
	jnz	$L70
	jmp	near ptr $L71
$L70:	push	[bp-010h]
	mov	ax,_$a
	mov	dx,$S28
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
$L71:	cmp	word ptr _$ib,+000h
	jnz	$L72
	jmp	near ptr $L73
$L72:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	push	$S32
	push	_$b
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L73:	jmp	$L60
$L67:	cmp	word ptr [bp-002h],+002h
	jng	$L74
	jmp	near ptr $L75
$L74:	jnl	$L76
	jmp	near ptr $L77
$L76:	cmp	word ptr [bp-004h],+000h
	jbe	$L77
	jmp	near ptr $L75
$L77:	cmp	word ptr _$ib,+000h
	jnz	$L78
	jmp	near ptr $L75
$L78:	push	[bp+00Eh]
	mov	ax,_$b
	mov	dx,$S32
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L60
$L75:	cmp	word ptr [bp+00Ch],+002h
	jng	$L79
	jmp	near ptr $L80
$L79:	jnl	$L81
	jmp	near ptr $L82
$L81:	cmp	word ptr [bp+00Ah],+000h
	jc	$L82
	jmp	near ptr $L80
$L82:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ib,+000h
	jnz	$L83
	jmp	near ptr $L84
$L83:	push	[bp-010h]
	mov	ax,_$b
	mov	dx,$S32
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
$L84:	cmp	word ptr _$ic,+000h
	jnz	$L85
	jmp	near ptr $L86
$L85:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	push	$S36
	push	_$c
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L86:	jmp	$L60
$L80:	cmp	word ptr [bp-002h],+003h
	jng	$L87
	jmp	near ptr $L88
$L87:	jnl	$L89
	jmp	near ptr $L90
$L89:	cmp	word ptr [bp-004h],+000h
	jbe	$L90
	jmp	near ptr $L88
$L90:	cmp	word ptr _$ic,+000h
	jnz	$L91
	jmp	near ptr $L88
$L91:	push	[bp+00Eh]
	mov	ax,_$c
	mov	dx,$S36
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L60
$L88:	cmp	word ptr [bp+00Ch],+003h
	jng	$L92
	jmp	near ptr $L93
$L92:	jnl	$L94
	jmp	near ptr $L95
$L94:	cmp	word ptr [bp+00Ah],+000h
	jc	$L95
	jmp	near ptr $L93
$L95:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ic,+000h
	jnz	$L96
	jmp	near ptr $L97
$L96:	push	[bp-010h]
	mov	ax,_$c
	mov	dx,$S36
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
$L97:	cmp	word ptr _$id,+000h
	jnz	$L98
	jmp	near ptr $L99
$L98:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]

	push	ax
	push	$S40
	push	_$d
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L99:	jmp	$L60
$L93:	cmp	word ptr [bp-002h],+004h
	jng	$L100
	jmp	near ptr $L101
$L100:	jnl	$L102
	jmp	near ptr $L103
$L102:	cmp	word ptr [bp-004h],+000h
	jbe	$L103
	jmp	near ptr $L101
$L103:	cmp	word ptr _$id,+000h
	jnz	$L104
	jmp	near ptr $L101
$L104:	push	[bp+00Eh]
	mov	ax,[bp+00Ah]
	add	ax,_$d
	mov	dx,$S40
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L60
$L101:	cmp	word ptr [bp+00Ch],+004h
	jng	$L105
	jmp	near ptr $L106
$L105:	jnl	$L107
	jmp	near ptr $L108
$L107:	cmp	word ptr [bp+00Ah],+000h
	jc	$L108
	jmp	near ptr $L106
$L108:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$id,+000h
	jnz	$L109
	jmp	near ptr $L110
$L109:	push	[bp-010h]
	mov	ax,[bp+00Ah]
	add	ax,_$d
	mov	dx,$S40
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
$L110:	cmp	word ptr _$ie,+000h
	jnz	$L111
	jmp	near ptr $L112
$L111:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	mov	es,word ptr $S44
	push	word ptr es:_$e + 00002h
	push	word ptr es:_$e
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L112:	jmp	$L60
$L106:	cmp	word ptr [bp-002h],+005h
	jng	$L113
	jmp	near ptr $L114
$L113:	jnl	$L115
	jmp	near ptr $L116
$L115:	cmp	word ptr [bp-004h],+000h
	jbe	$L116
	jmp	near ptr $L114
$L116:	cmp	word ptr _$ie,+000h
	jnz	$L117
	jmp	near ptr $L114
$L117:	push	[bp+00Eh]
	mov	es,word ptr $S44
	mov	ax,word ptr es:_$e
	mov	dx,word ptr es:_$e + 00002h
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L60
$L114:	cmp	word ptr [bp+00Ch],+005h
	jng	$L118
	jmp	near ptr $L119
$L118:	jnl	$L120
	jmp	near ptr $L121
$L120:	cmp	word ptr [bp+00Ah],+000h
	jc	$L121
	jmp	near ptr $L119
$L121:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ie,+000h
	jnz	$L122
	jmp	near ptr $L123
$L122:	push	[bp-010h]
	mov	es,word ptr $S44
	mov	ax,word ptr es:_$e
	mov	dx,word ptr es:_$e + 00002h
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
$L123:	cmp	word ptr _$if,+000h
	jnz	$L124
	jmp	near ptr $L125
$L124:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	push	$S48
	push	_$f
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L125:	jmp	near ptr $L60
$L119:	cmp	word ptr [bp-002h],+006h
	jng	$L126
	jmp	near ptr $L60
$L126:	jnl	$L127
	jmp	near ptr $L128
$L127:	cmp	word ptr [bp-004h],+000h
	jbe	$L128
	jmp	near ptr $L60
$L128:	cmp	word ptr _$if,+000h
	jnz	$L129
	jmp	near ptr $L60
$L129:	push	[bp+00Eh]
	mov	ax,[bp+00Ah]
	add	ax,_$f
	mov	dx,$S48
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xfer
	add	sp,+00Ah
$L60:	pop	si
	pop	di
	leave
	retf
_redems:
	enter	00014h,000h
	push	di
	push	si
	cmp	word ptr _iemssw,+000h
	jz	$L130
	jmp	$L131
$L130:	mov	ax,[bp+00Ah]
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
	jmp	near ptr $L132
$L135:	inc	word ptr [bp-010h]
$L132:	mov	ax,[bp-010h]
	cmp	[bp-014h],ax
	jnl	$L133
	jmp	near ptr $L134
$L133:	mov	al,[bp-010h]
	and	ax,0003h
	push	ax
	push	[bp-010h]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L135
$L134:	mov	ax,[bp+00Ah]
	mov	[bp-012h],ax
	mov	ax,_pfba
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
	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	push	[bp-00Ch]
	push	[bp-00Eh]
	call	far ptr _xfer
	add	sp,+00Ah
	mov	ax,[bp-008h]
	jmp	$L136
	jmp	$L136
$L131:	mov	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	add	ax,[bp+00Eh]
	adc	dx,+000h
	mov	[bp-004h],ax
	mov	[bp-002h],dx
	cmp	word ptr [bp-002h],+001h
	jng	$L137
	jmp	near ptr $L138
$L137:	jnl	$L139
	jmp	near ptr $L140
$L139:	cmp	word ptr [bp-004h],+000h
	jbe	$L140
	jmp	near ptr $L138
$L140:	cmp	word ptr _$ia,+000h
	jnz	$L141
	jmp	near ptr $L138
$L141:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,_$a
	mov	dx,$S28
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L136
$L138:	cmp	word ptr [bp+00Ch],+001h
	jng	$L142
	jmp	near ptr $L143
$L142:	jnl	$L144
	jmp	near ptr $L145
$L144:	cmp	word ptr [bp+00Ah],+000h
	jc	$L145
	jmp	near ptr $L143
$L145:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ia,+000h
	jnz	$L146
	jmp	near ptr $L147
$L146:	push	[bp-010h]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,_$a
	mov	dx,$S28
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L147:	cmp	word ptr _$ib,+000h
	jnz	$L148
	jmp	near ptr $L149
$L148:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	push	$S32
	push	_$b
	call	far ptr _xfer
	add	sp,+00Ah
$L149:	jmp	$L136
$L143:	cmp	word ptr [bp-002h],+002h
	jng	$L150
	jmp	near ptr $L151
$L150:	jnl	$L152
	jmp	near ptr $L153
$L152:	cmp	word ptr [bp-004h],+000h
	jbe	$L153
	jmp	near ptr $L151
$L153:	cmp	word ptr _$ib,+000h
	jnz	$L154
	jmp	near ptr $L151

$L154:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,_$b
	mov	dx,$S32
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L136
$L151:	cmp	word ptr [bp+00Ch],+002h
	jng	$L155
	jmp	near ptr $L156
$L155:	jnl	$L157
	jmp	near ptr $L158
$L157:	cmp	word ptr [bp+00Ah],+000h
	jc	$L158
	jmp	near ptr $L156
$L158:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ib,+000h
	jnz	$L159
	jmp	near ptr $L160
$L159:	push	[bp-010h]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,_$b
	mov	dx,$S32
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L160:	cmp	word ptr _$ic,+000h
	jnz	$L161
	jmp	near ptr $L162
$L161:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	push	$S36
	push	_$c
	call	far ptr _xfer
	add	sp,+00Ah
$L162:	jmp	$L136
$L156:	cmp	word ptr [bp-002h],+003h
	jng	$L163
	jmp	near ptr $L164
$L163:	jnl	$L165
	jmp	near ptr $L166
$L165:	cmp	word ptr [bp-004h],+000h
	jbe	$L166
	jmp	near ptr $L164
$L166:	cmp	word ptr _$ic,+000h
	jnz	$L167
	jmp	near ptr $L164
$L167:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,_$c
	mov	dx,$S36
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L136
$L164:	cmp	word ptr [bp+00Ch],+003h
	jng	$L168
	jmp	near ptr $L169
$L168:	jnl	$L170
	jmp	near ptr $L171
$L170:	cmp	word ptr [bp+00Ah],+000h
	jc	$L171
	jmp	near ptr $L169
$L171:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ic,+000h
	jnz	$L172
	jmp	near ptr $L173
$L172:	push	[bp-010h]
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	mov	ax,_$c
	mov	dx,$S36
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L173:	cmp	word ptr _$id,+000h
	jnz	$L174
	jmp	near ptr $L175
$L174:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	push	$S40
	push	_$d
	call	far ptr _xfer
	add	sp,+00Ah
$L175:	jmp	$L136
$L169:	cmp	word ptr [bp-002h],+004h
	jng	$L176
	jmp	near ptr $L177
$L176:	jnl	$L178
	jmp	near ptr $L179
$L178:	cmp	word ptr [bp-004h],+000h
	jbe	$L179
	jmp	near ptr $L177
$L179:	cmp	word ptr _$id,+000h
	jnz	$L180
	jmp	near ptr $L177
$L180:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,[bp+00Ah]
	add	ax,_$d
	mov	dx,$S40
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L136
$L177:	cmp	word ptr [bp+00Ch],+004h
	jng	$L181
	jmp	near ptr $L182
$L181:	jnl	$L183
	jmp	near ptr $L184
$L183:	cmp	word ptr [bp+00Ah],+000h
	jc	$L184
	jmp	near ptr $L182
$L184:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$id,+000h
	jnz	$L185
	jmp	near ptr $L186
$L185:	push	[bp-010h]
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	mov	ax,[bp+00Ah]
	add	ax,_$d
	mov	dx,$S40
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L186:	cmp	word ptr _$ie,+000h
	jnz	$L187
	jmp	near ptr $L188
$L187:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	mov	es,word ptr $S44
	push	word ptr es:_$e + 00002h
	push	word ptr es:_$e
	call	far ptr _xfer
	add	sp,+00Ah
$L188:	jmp	$L136
$L182:	cmp	word ptr [bp-002h],+005h
	jng	$L189
	jmp	near ptr $L190
$L189:	jnl	$L191
	jmp	near ptr $L192
$L191:	cmp	word ptr [bp-004h],+000h
	jbe	$L192
	jmp	near ptr $L190
$L192:	cmp	word ptr _$ie,+000h
	jnz	$L193
	jmp	near ptr $L190
$L193:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	mov	es,word ptr $S44
	mov	ax,word ptr es:_$e
	mov	dx,word ptr es:_$e + 00002h
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
	jmp	$L136
$L190:	cmp	word ptr [bp+00Ch],+005h
	jng	$L194
	jmp	near ptr $L195
$L194:	jnl	$L196
	jmp	near ptr $L197
$L196:	cmp	word ptr [bp+00Ah],+000h
	jc	$L197
	jmp	near ptr $L195
$L197:	mov	ax,[bp+00Ah]
	neg	ax
	mov	[bp-010h],ax
	cmp	word ptr _$ie,+000h
	jnz	$L198
	jmp	near ptr $L199
$L198:	push	[bp-010h]
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	mov	es,word ptr $S44
	mov	ax,word ptr es:_$e
	mov	dx,word ptr es:_$e + 00002h
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L199:	cmp	word ptr _$if,+000h
	jnz	$L200
	jmp	near ptr $L201
$L200:	mov	ax,[bp+00Eh]
	sub	ax,[bp-010h]
	push	ax
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-010h]
	push	dx
	push	ax
	push	$S48
	push	_$f
	call	far ptr _xfer
	add	sp,+00Ah
$L201:	jmp	near ptr $L136
$L195:	cmp	word ptr [bp-002h],+006h
	jng	$L202
	jmp	near ptr $L136
$L202:	jnl	$L203
	jmp	near ptr $L204
$L203:	cmp	word ptr [bp-004h],+000h
	jbe	$L204
	jmp	near ptr $L136
$L204:	cmp	word ptr _$if,+000h
	jnz	$L205
	jmp	near ptr $L136
$L205:	push	[bp+00Eh]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,[bp+00Ah]
	add	ax,_$f
	mov	dx,$S48
	push	dx
	push	ax
	call	far ptr _xfer
	add	sp,+00Ah
$L136:	pop	si
	pop	di
	leave
	retf
_redemc:
	enter	00022h,000h
	push	di
	push	si
	cmp	word ptr _iemssw,+000h
	jz	$L206
	jmp	$L207
$L206:	mov	ax,_pfba
	cwd
	mov	[bp-018h],ax
	mov	[bp-016h],dx
	push	+010h
	lea	ax,[bp-018h]
	push	ax
	call	far ptr __aFNalshl
	mov	word ptr [bp-010h],0FFFFh
	mov	word ptr [bp-01Ah],0000h
	jmp	near ptr $L208
$L213:	inc	word ptr [bp-01Ah]
$L208:	mov	ax,[bp+010h]
	cmp	[bp-01Ah],ax
	jc	$L209
	jmp	$L210
$L209:	mov	ax,[bp+00Ah]
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
	mov	[bp-01Ch],ax
	mov	ax,[bp-01Ch]
	cmp	[bp-010h],ax
	jnz	$L211
	jmp	near ptr $L212
$L211:	push	+000h
	push	[bp-01Ch]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-004h],ax
$L212:	mov	ax,[bp+00Ah]
	and	ax,3FFFh
	mov	[bp-020h],ax

	mov	ax,[bp-018h]
	mov	dx,[bp-016h]
	add	ax,[bp-020h]
	adc	dx,+000h
	mov	[bp-014h],ax
	mov	[bp-012h],dx
	les	bx,dword ptr [bp-014h]
	mov	al,es:[bx]
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-01Ah]
	mov	es:[bx+si],al
	mov	ax,[bp+00Eh]
	sub	dx,dx
	add	[bp+00Ah],ax
	adc	[bp+00Ch],dx
	mov	ax,[bp-01Ch]
	mov	[bp-010h],ax
	jmp	$L213
$L210:	mov	ax,[bp-004h]
	jmp	$L214
	jmp	$L214
$L207:	mov	word ptr [bp-01Ah],0000h
	jmp	near ptr $L215
$L247:	inc	word ptr [bp-01Ah]
$L215:	mov	ax,[bp+010h]
	cmp	[bp-01Ah],ax
	jc	$L216
	jmp	$L214
$L216:	mov	ax,[bp+00Ah]
	mov	[bp-01Eh],ax
	cmp	word ptr [bp+00Ch],+001h
	jng	$L217
	jmp	near ptr $L218
$L217:	jnl	$L219
	jmp	near ptr $L220
$L219:	cmp	word ptr [bp+00Ah],+000h
	jc	$L220
	jmp	near ptr $L218
$L220:	cmp	word ptr _$ia,+000h
	jnz	$L221
	jmp	near ptr $L218
$L221:	les	bx,dword ptr _$a
	mov	si,[bp-01Eh]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-01Ah]
	mov	es:[bx+si],al
	jmp	$L222
$L218:	cmp	word ptr [bp+00Ch],+002h
	jng	$L223
	jmp	near ptr $L224
$L223:	jnl	$L225
	jmp	near ptr $L226
$L225:	cmp	word ptr [bp+00Ah],+000h
	jc	$L226
	jmp	near ptr $L224
$L226:	cmp	word ptr _$ib,+000h
	jnz	$L227
	jmp	near ptr $L224
$L227:	les	bx,dword ptr _$b
	mov	si,[bp-01Eh]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-01Ah]
	mov	es:[bx+si],al
	jmp	$L222
$L224:	cmp	word ptr [bp+00Ch],+003h
	jng	$L228
	jmp	near ptr $L229
$L228:	jnl	$L230
	jmp	near ptr $L231
$L230:	cmp	word ptr [bp+00Ah],+000h
	jc	$L231
	jmp	near ptr $L229
$L231:	cmp	word ptr _$ic,+000h
	jnz	$L232
	jmp	near ptr $L229
$L232:	les	bx,dword ptr _$c
	mov	si,[bp-01Eh]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-01Ah]
	mov	es:[bx+si],al
	jmp	$L222
$L229:	cmp	word ptr [bp+00Ch],+004h
	jng	$L233
	jmp	near ptr $L234
$L233:	jnl	$L235
	jmp	near ptr $L236
$L235:	cmp	word ptr [bp+00Ah],+000h
	jc	$L236
	jmp	near ptr $L234
$L236:	cmp	word ptr _$id,+000h
	jnz	$L237
	jmp	near ptr $L234
$L237:	les	bx,dword ptr _$d
	mov	si,[bp-01Eh]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-01Ah]
	mov	es:[bx+si],al
	jmp	near ptr $L222
$L234:	cmp	word ptr [bp+00Ch],+005h
	jng	$L238
	jmp	near ptr $L239
$L238:	jnl	$L240
	jmp	near ptr $L241
$L240:	cmp	word ptr [bp+00Ah],+000h
	jc	$L241
	jmp	near ptr $L239
$L241:	cmp	word ptr _$ie,+000h
	jnz	$L242
	jmp	near ptr $L239
$L242:	mov	es,word ptr $S44
	les	bx,dword ptr es:_$e
	mov	si,[bp-01Eh]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-01Ah]
	mov	es:[bx+si],al
	jmp	near ptr $L222
$L239:	cmp	word ptr [bp+00Ch],+006h
	jng	$L243
	jmp	near ptr $L222
$L243:	jnl	$L244
	jmp	near ptr $L245
$L244:	cmp	word ptr [bp+00Ah],+000h
	jc	$L245
	jmp	near ptr $L222
$L245:	cmp	word ptr _$if,+000h
	jnz	$L246
	jmp	near ptr $L222
$L246:	les	bx,dword ptr _$f
	mov	si,[bp-01Eh]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-01Ah]
	mov	es:[bx+si],al
$L222:	mov	ax,[bp+00Eh]
	sub	dx,dx
	add	[bp+00Ah],ax
	adc	[bp+00Ch],dx
	jmp	$L247
$L214:	pop	si
	pop	di
	leave
	retf
_wrtemc:
	enter	00018h,000h
	push	di
	push	si
	mov	ax,_pfba
	cwd
	mov	[bp-010h],ax
	mov	[bp-00Eh],dx
	push	+010h
	lea	ax,[bp-010h]
	push	ax
	call	far ptr __aFNalshl
	mov	word ptr [bp-008h],0FFFFh
	cmp	word ptr _iemssw,+000h
	jz	$L248
	jmp	$L249
$L248:	mov	word ptr [bp-012h],0000h
	jmp	near ptr $L250
$L255:	inc	word ptr [bp-012h]
$L250:	mov	ax,[bp+010h]
	cmp	[bp-012h],ax
	jc	$L251
	jmp	$L252
$L251:	mov	ax,[bp+00Ah]
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
	mov	[bp-014h],ax
	mov	ax,[bp-014h]
	cmp	[bp-008h],ax
	jnz	$L253
	jmp	near ptr $L254
$L253:	push	+000h
	push	[bp-014h]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-004h],ax
$L254:	mov	ax,[bp+00Ah]
	and	ax,3FFFh
	mov	[bp-016h],ax
	mov	ax,[bp-010h]
	mov	dx,[bp-00Eh]
	add	ax,[bp-016h]
	adc	dx,+000h
	mov	[bp-00Ch],ax
	mov	[bp-00Ah],dx
	les	bx,dword ptr [bp+006h]
	mov	si,[bp-012h]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp-00Ch]
	mov	es:[bx],al
	mov	ax,[bp+00Eh]
	sub	dx,dx
	add	[bp+00Ah],ax
	adc	[bp+00Ch],dx
	mov	ax,[bp-014h]
	mov	[bp-008h],ax
	jmp	$L255
$L252:	mov	ax,[bp-004h]
	jmp	near ptr $L249
$L249:	pop	si
	pop	di
	leave
	retf
_initems:
	enter	00008h,000h
	push	di
	push	si
	mov	ax,_pfba
	cwd
	mov	[bp-006h],ax
	mov	[bp-004h],dx
	push	+010h
	lea	ax,[bp-006h]
	push	ax
	call	far ptr __aFNalshl
	cmp	word ptr _iemssw,+000h
	jz	$L256
	jmp	near ptr $L257
$L256:	mov	ax,[bp+006h]
	mov	[bp-008h],ax
	jmp	near ptr $L258
$L261:	inc	word ptr [bp-008h]
$L258:	mov	ax,[bp+008h]
	add	ax,[bp+006h]
	cmp	ax,[bp-008h]
	jnl	$L259
	jmp	near ptr $L260
$L259:	push	+000h
	push	[bp-008h]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-002h],ax
	push	+000h
	push	2000h
	push	[bp-004h]
	push	[bp-006h]
	call	far ptr _filmem
	add	sp,+008h
	jmp	near ptr $L261
$L260:	jmp	$L262
$L257:	cmp	word ptr _$ia,+000h
	jnz	$L263
	jmp	near ptr $L264
$L263:	push	+000h
	push	+000h
	push	8000h
	push	$S28
	push	_$a
	call	far ptr _filmem
	add	sp,+00Ah
$L264:	cmp	word ptr _$ib,+000h
	jnz	$L265
	jmp	near ptr $L266
$L265:	push	+000h
	push	+000h
	push	8000h
	push	$S32
	push	_$b
	call	far ptr _filmem
	add	sp,+00Ah
$L266:	cmp	word ptr _$ic,+000h
	jnz	$L267
	jmp	near ptr $L268
$L267:	push	+000h
	push	+000h
	push	8000h
	push	$S36
	push	_$c
	call	far ptr _filmem
	add	sp,+00Ah
$L268:	cmp	word ptr _$id,+000h
	jnz	$L269
	jmp	near ptr $L270
$L269:	push	+000h
	push	+000h
	push	8000h
	push	$S40
	push	_$d
	call	far ptr _filmem
	add	sp,+00Ah
$L270:	cmp	word ptr _$ie,+000h
	jnz	$L271
	jmp	near ptr $L272
$L271:	push	+000h
	push	+000h
	push	8000h
	mov	es,word ptr $S44
	push	word ptr es:_$e + 00002h
	push	word ptr es:_$e
	call	far ptr _filmem
	add	sp,+00Ah
$L272:	cmp	word ptr _$if,+000h
	jnz	$L273
	jmp	near ptr $L262
$L273:	push	+000h
	push	+000h
	push	8000h

	push	$S48
	push	_$f
	call	far ptr _filmem
	add	sp,+00Ah
$L262:	pop	si
	pop	di
	leave
	retf
_redcol:
	enter	00016h,000h
	push	di
	push	si
	push	+000h
	push	[bp+00Ch]
	push	+001h
	push	+000h
	call	far ptr __aFldiv
	mov	[bp-016h],ax
	mov	ax,[bp+00Eh]
	dec	ax
	sub	dx,dx
	div	word ptr [bp-016h]
	inc	ax
	mov	[bp-006h],ax
	cmp	word ptr _iemssw,+000h
	jz	$L274
	jmp	$L275
$L274:	mov	ax,_pfba
	cwd
	mov	[bp-00Eh],ax
	mov	[bp-00Ch],dx
	push	+010h
	lea	ax,[bp-00Eh]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp+00Ah]
	sub	dx,dx
	add	[bp-00Eh],ax
	adc	[bp-00Ch],dx
	mov	word ptr [bp-014h],0000h
	mov	word ptr [bp-012h],0000h
	jmp	near ptr $L276
$L283:	inc	word ptr [bp-012h]
$L276:	mov	ax,[bp-012h]
	cmp	[bp-006h],ax
	jg	$L277
	jmp	near ptr $L278
$L277:	mov	ax,[bp-012h]
	shl	ax,02h
	mov	[bp-004h],ax
	mov	ax,[bp-004h]
	add	ax,0004h
	mov	[bp-002h],ax
	mov	ax,[bp-004h]
	mov	[bp-010h],ax
	jmp	near ptr $L279
$L282:	inc	word ptr [bp-010h]
$L279:	mov	ax,[bp-010h]
	cmp	[bp-002h],ax
	jg	$L280
	jmp	near ptr $L281
$L280:	mov	al,[bp-010h]
	and	ax,0003h
	push	ax
	push	[bp-010h]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L282
$L281:	push	[bp+00Ch]
	push	[bp-016h]
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-014h]
	push	dx
	push	ax
	push	[bp-00Ch]
	push	[bp-00Eh]
	call	far ptr _xferci
	add	sp,+00Ch
	mov	ax,[bp-016h]
	add	[bp-014h],ax
	jmp	near ptr $L283
$L278:	jmp	$L284
$L275:	cmp	word ptr _$ia,+000h
	jnz	$L285
	jmp	near ptr $L286
$L285:	push	[bp+00Ch]
	push	[bp-016h]
	push	[bp+008h]
	push	[bp+006h]
	mov	ax,_$a
	mov	dx,$S28
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xferci
	add	sp,+00Ch
$L286:	cmp	word ptr _$ib,+000h
	jnz	$L287
	jmp	near ptr $L288
$L287:	push	[bp+00Ch]
	push	[bp-016h]
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-016h]
	push	dx
	push	ax
	mov	ax,_$b
	mov	dx,$S32
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xferci
	add	sp,+00Ch
$L288:	cmp	word ptr _$ic,+000h
	jnz	$L289
	jmp	near ptr $L290
$L289:	push	[bp+00Ch]
	push	[bp-016h]
	mov	ax,[bp-016h]
	shl	ax,1
	add	ax,[bp+006h]
	mov	dx,[bp+008h]
	push	dx
	push	ax
	mov	ax,_$c
	mov	dx,$S36
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xferci
	add	sp,+00Ch
$L290:	cmp	word ptr _$id,+000h
	jnz	$L291
	jmp	near ptr $L284
$L291:	push	[bp+00Ch]
	push	[bp-016h]
	mov	ax,[bp-016h]
	mov	cx,ax
	shl	ax,1
	add	ax,cx
	add	ax,[bp+006h]
	mov	dx,[bp+008h]
	push	dx
	push	ax
	mov	ax,_$d
	mov	dx,$S40
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	call	far ptr _xferci
	add	sp,+00Ch
$L284:	pop	si
	pop	di
	leave
	retf
_wrtcol:
	enter	00014h,000h
	push	di
	push	si
	push	+000h
	push	[bp+00Ch]
	push	+001h
	push	+000h
	call	far ptr __aFldiv
	mov	[bp-014h],ax
	mov	ax,[bp+00Eh]
	dec	ax
	sub	dx,dx
	div	word ptr [bp-014h]
	inc	ax
	mov	[bp-006h],ax
	cmp	word ptr _iemssw,+000h
	jz	$L292
	jmp	$L293
$L292:	mov	ax,_pfba
	cwd
	mov	[bp-00Ch],ax
	mov	[bp-00Ah],dx
	push	+010h
	lea	ax,[bp-00Ch]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp+00Ah]
	sub	dx,dx
	add	[bp-00Ch],ax
	adc	[bp-00Ah],dx
	mov	word ptr [bp-012h],0000h
	mov	word ptr [bp-010h],0000h
	jmp	near ptr $L294
$L301:	inc	word ptr [bp-010h]
$L294:	mov	ax,[bp-010h]
	cmp	[bp-006h],ax
	jg	$L295
	jmp	near ptr $L296
$L295:	mov	ax,[bp-010h]
	shl	ax,02h
	mov	[bp-004h],ax
	mov	ax,[bp-004h]
	add	ax,0004h
	mov	[bp-002h],ax
	mov	ax,[bp-004h]
	mov	[bp-00Eh],ax
	jmp	near ptr $L297
$L300:	inc	word ptr [bp-00Eh]
$L297:	mov	ax,[bp-002h]
	cmp	[bp-00Eh],ax
	jl	$L298
	jmp	near ptr $L299
$L298:	mov	al,[bp-00Eh]
	and	ax,0003h
	push	ax
	push	[bp-00Eh]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L300
$L299:	push	[bp+00Ch]
	push	[bp-014h]
	push	[bp-00Ah]
	push	[bp-00Ch]
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-012h]
	push	dx
	push	ax
	call	far ptr _xferco
	add	sp,+00Ch
	mov	ax,[bp-014h]
	add	[bp-012h],ax
	jmp	near ptr $L301
$L296:	jmp	$L302
$L293:	cmp	word ptr _$ia,+000h
	jnz	$L303
	jmp	near ptr $L304
$L303:	push	[bp+00Ch]
	push	[bp-014h]
	mov	ax,_$a
	mov	dx,$S28
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _xferco
	add	sp,+00Ch
$L304:	cmp	word ptr _$ib,+000h
	jnz	$L305
	jmp	near ptr $L306
$L305:	push	[bp+00Ch]
	push	[bp-014h]
	mov	ax,_$b
	mov	dx,$S32
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	mov	ax,[bp+006h]
	mov	dx,[bp+008h]
	add	ax,[bp-014h]
	push	dx
	push	ax
	call	far ptr _xferco
	add	sp,+00Ch
$L306:	cmp	word ptr _$ic,+000h
	jnz	$L307
	jmp	near ptr $L308
$L307:	push	[bp+00Ch]
	push	[bp-014h]
	mov	ax,_$c
	mov	dx,$S36
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	mov	ax,[bp-014h]
	shl	ax,1
	add	ax,[bp+006h]
	mov	dx,[bp+008h]
	push	dx
	push	ax
	call	far ptr _xferco
	add	sp,+00Ch
$L308:	cmp	word ptr _$id,+000h
	jnz	$L309
	jmp	near ptr $L302
$L309:	push	[bp+00Ch]
	push	[bp-014h]
	mov	ax,_$d
	mov	dx,$S40
	add	ax,[bp+00Ah]
	push	dx
	push	ax
	mov	ax,[bp-014h]
	mov	cx,ax
	shl	ax,1
	add	ax,cx
	add	ax,[bp+006h]
	mov	dx,[bp+008h]
	push	dx
	push	ax
	call	far ptr _xferco
	add	sp,+00Ch
$L302:	pop	si
	pop	di
	leave
	retf
_unalloc:
	enter	00002h,000h
	push	di
	push	si
	cmp	word ptr _iemssw,+000h
	jz	$L310
	jmp	near ptr $L311
$L310:	cmp	word ptr _handle,-001h
	jnz	$L312
	jmp	near ptr $L313
$L312:	push	_handle
	call	far ptr _ems6
	add	sp,+002h
	mov	[bp-002h],ax
$L313:	mov	ax,[bp-002h]
	jmp	$L314
	jmp	$L314
$L311:	cmp	word ptr _$ia,+000h
	jnz	$L315
	jmp	near ptr $L316
$L315:	push	$S28
	push	_$a
	call	far ptr _hfree
	add	sp,+004h
$L316:	cmp	word ptr _$ib,+000h
	jnz	$L317
	jmp	near ptr $L318
$L317:	push	$S32
	push	_$b
	call	far ptr _hfree
	add	sp,+004h

$L318:	cmp	word ptr _$ic,+000h
	jnz	$L319
	jmp	near ptr $L320
$L319:	push	$S36
	push	_$c
	call	far ptr _hfree
	add	sp,+004h
$L320:	cmp	word ptr _$id,+000h
	jnz	$L321
	jmp	near ptr $L322
$L321:	push	$S40
	push	_$d
	call	far ptr _hfree
	add	sp,+004h
$L322:	cmp	word ptr _$ie,+000h
	jnz	$L323
	jmp	near ptr $L324
$L323:	mov	es,word ptr $S44
	push	word ptr es:_$e + 00002h
	push	word ptr es:_$e
	call	far ptr _hfree
	add	sp,+004h
$L324:	cmp	word ptr _$if,+000h
	jnz	$L325
	jmp	near ptr $L314
$L325:	push	$S48
	push	_$f
	call	far ptr _hfree
	add	sp,+004h
$L314:	pop	si
	pop	di
	leave
	retf
_emsdsk:
	enter	00016h,000h
	push	di
	push	si
	cmp	word ptr _iemssw,+000h
	jz	$L326
	jmp	$L327
$L326:	mov	ax,[bp+008h]
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
	mov	[bp-006h],ax
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
	add	ax,[bp+00Ch]
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
	mov	[bp-016h],ax
	mov	word ptr [bp-012h],0000h
	jmp	near ptr $L328
$L331:	inc	word ptr [bp-012h]
$L328:	cmp	word ptr [bp-012h],+004h
	jl	$L329
	jmp	near ptr $L330
$L329:	push	[bp-012h]
	mov	ax,[bp-006h]
	add	ax,[bp-012h]
	push	ax
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L331
$L330:	mov	ax,[bp+008h]
	and	ax,3FFFh
	mov	[bp-014h],ax
	mov	ax,_pfba
	cwd
	mov	[bp-010h],ax
	mov	[bp-00Eh],dx
	push	+010h
	lea	ax,[bp-010h]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp-014h]
	sub	dx,dx
	add	[bp-010h],ax
	adc	[bp-00Eh],dx
	push	[bp+00Ch]
	push	[bp-00Eh]
	push	[bp-010h]
	push	[bp+006h]
	call	far ptr _write
	add	sp,+008h
	mov	[bp-00Ah],ax
	mov	ax,[bp-008h]
	jmp	near ptr $L327
$L327:	pop	si
	pop	di
	leave
	retf
_dskems:
	enter	00016h,000h
	push	di
	push	si
	cmp	word ptr _iemssw,+000h
	jz	$L332
	jmp	$L333
$L332:	mov	ax,[bp+008h]
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
	mov	[bp-006h],ax
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
	add	ax,[bp+00Ch]
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
	mov	[bp-016h],ax
	mov	word ptr [bp-012h],0000h
	jmp	near ptr $L334
$L337:	inc	word ptr [bp-012h]
$L334:	cmp	word ptr [bp-012h],+004h
	jl	$L335
	jmp	near ptr $L336
$L335:	push	[bp-012h]
	mov	ax,[bp-006h]
	add	ax,[bp-012h]
	push	ax
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L337
$L336:	mov	ax,[bp+008h]
	and	ax,3FFFh
	mov	[bp-014h],ax
	mov	ax,_pfba
	cwd
	mov	[bp-010h],ax
	mov	[bp-00Eh],dx
	push	+010h
	lea	ax,[bp-010h]
	push	ax
	call	far ptr __aFNalshl
	mov	ax,[bp-014h]
	sub	dx,dx
	add	[bp-010h],ax
	adc	[bp-00Eh],dx
	push	[bp+00Ch]
	push	[bp-00Eh]
	push	[bp-010h]
	push	[bp+006h]
	call	far ptr _read
	add	sp,+008h
	mov	[bp-00Ah],ax
	mov	ax,[bp-008h]
	jmp	near ptr $L333
$L333:	pop	si
	pop	di
	leave
	retf
_bufems:
	enter	00014h,000h
	push	di
	push	si
	cmp	word ptr _iemssw,+000h
	jz	$L338
	jmp	$L339
$L338:	mov	ax,[bp+008h]
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
	mov	[bp-006h],ax
	mov	ax,[bp+008h]
	mov	dx,[bp+00Ah]
	add	ax,[bp+00Ch]
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
	jmp	near ptr $L340
$L343:	inc	word ptr [bp-010h]
$L340:	mov	ax,[bp-010h]
	cmp	[bp-014h],ax
	jnl	$L341
	jmp	near ptr $L342
$L341:	mov	al,[bp-010h]
	and	ax,0003h
	push	ax
	push	[bp-010h]
	push	_handle
	call	far ptr _ems5
	add	sp,+006h
	mov	[bp-008h],ax
	jmp	near ptr $L343
$L342:	mov	ax,[bp+008h]
	mov	[bp-012h],ax
	mov	ax,_pfba
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
	push	[bp+00Ch]
	push	[bp+006h]
	call	dword ptr [bp+00Eh]
	add	sp,+008h
	mov	ax,[bp-008h]
	jmp	near ptr $L339
$L339:	pop	si
	pop	di
	leave
	retf

CEMS_TEXT	ENDS
_DATA	SEGMENT

_pfba	dw	0E000h
_handle	dw	0FFFFh
_iemssw	dw	00001h
_$a	dw	00000h
$S28	dw	00000h
_$b	dw	00000h
$S32	dw	00000h
_$c	dw	00000h
$S36	dw	00000h
_$d	dw	00000h
$S40	dw	00000h
_$f	dw	00000h
$S48	dw	00000h
_$ia	dw	00000h
_$ib	dw	00000h
_$ic	dw	00000h
_$id	dw	00000h
_$ie	dw	00000h
_$if	dw	00000h

_DATA	ENDS
CONST	SEGMENT

$S1	dw	_unalpgs

$S44	dw	_$e

CONST	ENDS
	END
