; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	ed.C
; [0009]	.286p
	.287
	; Large Memory Model
; [0011]	; CodeView Enabled
ED_TEXT	SEGMENT	WORD PUBLIC 'CODE'
ED_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [00DB]	; Linker - Pass two marker

	EXTRN		_getkey:NEAR
	EXTRN		_cursor:NEAR
	EXTRN		_gdisp:NEAR
	EXTRN		_strlen:NEAR
	PUBLIC		_ed			; Located at 1:0000h Type = 1
	PUBLIC		_outit			; Located at 1:0692h Type = 1

ED_TEXT	SEGMENT
	assume	cs: ED_TEXT


_ed:	enter	000AAh,000h
	push	di
	push	si
	mov	word ptr [bp-008Eh],000Dh
	mov	word ptr [bp-0094h],0008h
	mov	word ptr [bp-00A6h],4B00h
	mov	word ptr [bp-008Ch],4D00h
	mov	word ptr [bp-009Eh],7300h
	mov	word ptr [bp-004h],7400h
	mov	word ptr [bp-002h],4900h
	mov	word ptr [bp-00AAh],5100h
	mov	word ptr [bp-009Ah],4700h
	mov	word ptr [bp-0098h],4F00h
	mov	word ptr [bp-0092h],5200h
	mov	word ptr [bp-0090h],5300h
	mov	word ptr [bp-0096h],4800h
	mov	word ptr [bp-008Ah],5000h
	mov	word ptr [bp-00A0h],001Bh
	mov	word ptr [bp-00A4h],0000h
	les	bx,dword ptr [bp+016h]
	mov	word ptr es:[bx],0000h
	cmp	word ptr [bp+00Ch],0080h
	jg	$L1
	jmp	near ptr $L2
$L1:	mov	word ptr [bp+00Ch],0080h
$L2:	mov	word ptr [bp-009Ch],0000h
	jmp	near ptr $L3
$L6:	inc	word ptr [bp-009Ch]
$L3:	mov	ax,[bp+00Ch]
	cmp	[bp-009Ch],ax
	jl	$L4
	jmp	near ptr $L5
$L4:	mov	si,[bp-009Ch]
	mov	byte ptr [bp+si-0088h],20h
	jmp	near ptr $L6
$L5:	mov	si,[bp+00Ch]
	mov	byte ptr [bp+si-0089h],00h
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _strlen
	add	sp,+004h
	mov	[bp-00A2h],ax
	mov	ax,[bp+00Ch]
	cmp	[bp-00A2h],ax
	jg	$L7
	jmp	near ptr $L8
$L7:	mov	ax,[bp+00Ch]
	mov	[bp-00A2h],ax
$L8:	mov	word ptr [bp-009Ch],0000h
	jmp	near ptr $L9
$L12:	inc	word ptr [bp-009Ch]
$L9:	mov	ax,[bp-009Ch]
	cmp	[bp-00A2h],ax
	jg	$L10
	jmp	near ptr $L11
$L10:	les	bx,dword ptr [bp+008h]
	mov	si,[bp-009Ch]
	mov	al,es:[bx+si]
	mov	si,[bp-009Ch]
	mov	[bp+si-0088h],al
	jmp	near ptr $L12
$L11:	push	[bp+014h]
	push	[bp+010h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
	push	[bp+010h]
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
$L105:	call	far ptr _getkey
	mov	[bp-00A8h],ax
	mov	ax,[bp-00A8h]
	assume	ds: DGROUP
	cmp	$S13,ax
	jz	$L14
	jmp	near ptr $L15
$L14:	cmp	word ptr $S13,+001h
	sbb	ax,ax
	neg	ax
	mov	$S13,ax
	jmp	$L16
$L15:	mov	ax,[bp-00A8h]
	cmp	[bp-00A0h],ax
	jnz	$L17
	jmp	near ptr $L18
$L17:	mov	ax,[bp-008Eh]
	cmp	[bp-00A8h],ax
	jnz	$L19
	jmp	near ptr $L18
$L19:	mov	ax,[bp-00A8h]
	cmp	[bp-0096h],ax
	jnz	$L20
	jmp	near ptr $L18
$L20:	mov	ax,[bp-00A8h]
	cmp	[bp-008Ah],ax
	jnz	$L21
	jmp	near ptr $L18
$L21:	mov	ax,[bp-00A6h]
	cmp	[bp-00A8h],ax
	jnz	$L22
	jmp	near ptr $L18
$L22:	mov	ax,[bp-008Ch]
	cmp	[bp-00A8h],ax
	jnz	$L23
	jmp	near ptr $L18
$L23:	mov	ax,[bp-002h]
	cmp	[bp-00A8h],ax
	jnz	$L24
	jmp	near ptr $L18
$L24:	mov	ax,[bp-00AAh]
	cmp	[bp-00A8h],ax
	jz	$L18
	jmp	near ptr $L25
$L18:	push	[bp+012h]
	push	[bp+010h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
	push	[bp+00Ch]
	push	[bp+00Ah]
	push	[bp+008h]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _outit
	add	sp,+00Ah
	mov	ax,[bp-00A8h]
	jmp	$L26
	jmp	$L16
$L25:	mov	ax,[bp-00A6h]
	cmp	[bp-00A8h],ax
	jz	$L27
	jmp	near ptr $L28
$L27:	cmp	word ptr [bp+006h],+000h
	jz	$L29
	jmp	near ptr $L30
$L29:	push	[bp+00Ch]
	push	[bp+00Ah]
	push	[bp+008h]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _outit
	add	sp,+00Ah
	mov	ax,[bp-00A8h]
	jmp	$L26
$L30:	cmp	word ptr [bp-00A4h],+000h
	jg	$L31
	jmp	near ptr $L32
$L31:	dec	word ptr [bp-00A4h]
$L32:	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	jmp	$L16
$L28:	mov	ax,[bp-008Ch]
	cmp	[bp-00A8h],ax
	jz	$L33
	jmp	near ptr $L34
$L33:	cmp	word ptr [bp+006h],+000h
	jz	$L35
	jmp	near ptr $L36
$L35:	push	[bp+00Ch]
	push	[bp+00Ah]
	push	[bp+008h]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _outit
	add	sp,+00Ah
	mov	ax,[bp-00A8h]
	jmp	$L26
$L36:	mov	ax,[bp+00Ch]
	dec	ax
	cmp	ax,[bp-00A4h]
	jg	$L37
	jmp	near ptr $L38
$L37:	inc	word ptr [bp-00A4h]
$L38:	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	jmp	$L16
$L34:	mov	ax,[bp-009Ah]
	cmp	[bp-00A8h],ax
	jz	$L39
	jmp	near ptr $L40
$L39:	push	[bp+010h]
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	mov	word ptr [bp-00A4h],0000h
	jmp	$L16
$L40:	mov	ax,[bp-009Eh]
	cmp	[bp-00A8h],ax
	jz	$L41
	jmp	near ptr $L42
$L41:	dec	word ptr [bp-00A4h]
	cmp	word ptr [bp-00A4h],+000h
	jl	$L43
	jmp	near ptr $L44
$L43:	mov	word ptr [bp-00A4h],0000h
$L44:	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	jmp	$L16
$L42:	mov	ax,[bp-004h]
	cmp	[bp-00A8h],ax
	jz	$L45
	jmp	near ptr $L46
$L45:	inc	word ptr [bp-00A4h]
	mov	ax,[bp+00Ch]
	dec	ax
	cmp	ax,[bp-00A4h]
	jl	$L47
	jmp	near ptr $L48
$L47:	mov	ax,[bp+00Ch]
	dec	ax
	mov	[bp-00A4h],ax
$L48:	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	jmp	$L16
$L46:	mov	ax,[bp-0098h]
	cmp	[bp-00A8h],ax
	jz	$L49
	jmp	near ptr $L50
$L49:	mov	ax,[bp+00Ch]
	dec	ax
	mov	[bp-009Ch],ax
	jmp	near ptr $L51
$L57:	dec	word ptr [bp-009Ch]
$L51:	cmp	word ptr [bp-009Ch],+000h
	jnl	$L52
	jmp	near ptr $L53
$L52:	mov	si,[bp-009Ch]
	cmp	byte ptr [bp+si-0088h],20h
	jnz	$L54
	jmp	near ptr $L55
$L54:	mov	si,[bp-009Ch]
	cmp	byte ptr [bp+si-0088h],00h
	jnz	$L56
	jmp	near ptr $L55
$L56:	jmp	near ptr $L53
$L55:	jmp	near ptr $L57
$L53:	mov	ax,[bp-009Ch]
	mov	[bp-00A4h],ax
	cmp	word ptr [bp-00A4h],+000h
	jl	$L58
	jmp	near ptr $L59
$L58:	mov	word ptr [bp-00A4h],0000h
$L59:	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	jmp	$L16
$L50:	mov	ax,[bp-0094h]
	cmp	[bp-00A8h],ax

	jz	$L60
	jmp	near ptr $L61
$L60:	cmp	word ptr [bp-00A4h],+000h
	jg	$L62
	jmp	near ptr $L63
$L62:	mov	si,[bp-00A4h]
	cmp	byte ptr [bp+si-0088h],20h
	jnz	$L64
	jmp	near ptr $L65
$L64:	mov	si,[bp-00A4h]
	cmp	byte ptr [bp+si-0088h],00h
	jz	$L65
	jmp	near ptr $L63
$L65:	dec	word ptr [bp-00A4h]
$L63:	mov	si,[bp-00A4h]
	mov	byte ptr [bp+si-0088h],20h
	push	[bp+014h]
	push	[bp+010h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	jmp	$L16
$L61:	mov	ax,[bp-0090h]
	cmp	[bp-00A8h],ax
	jz	$L66
	jmp	near ptr $L67
$L66:	mov	ax,[bp-00A4h]
	mov	[bp-009Ch],ax
	jmp	near ptr $L68
$L71:	inc	word ptr [bp-009Ch]
$L68:	mov	ax,[bp+00Ch]
	dec	ax
	cmp	ax,[bp-009Ch]
	jnl	$L69
	jmp	near ptr $L70
$L69:	mov	si,[bp-009Ch]
	mov	al,[bp+si-0087h]
	mov	si,[bp-009Ch]
	mov	[bp+si-0088h],al
	jmp	near ptr $L71
$L70:	mov	si,[bp+00Ch]
	mov	byte ptr [bp+si-0089h],20h
	push	[bp+014h]
	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	mov	ax,[bp+00Ch]
	sub	ax,[bp-00A4h]
	push	ax
	mov	si,[bp-00A4h]
	lea	ax,[bp+si-0088h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	les	bx,dword ptr [bp+016h]
	inc	word ptr es:[bx]
	jmp	$L16
$L67:	mov	ax,[bp-0092h]
	cmp	[bp-00A8h],ax
	jz	$L72
	jmp	near ptr $L73
$L72:	cmp	word ptr $S13,+000h
	jz	$L74
	jmp	near ptr $L75
$L74:	mov	word ptr $S13,0001h
	jmp	near ptr $L76
$L75:	mov	word ptr $S13,0000h
$L76:	jmp	$L16
$L73:	cmp	word ptr [bp-00A8h],3500h
	jnl	$L77
	jmp	near ptr $L78
$L77:	cmp	word ptr [bp-00A8h],6700h
	jng	$L79
	jmp	near ptr $L78
$L79:	mov	ax,[bp-00A8h]
	jmp	$L26
	jmp	$L16
$L78:	cmp	word ptr $S13,+000h
	jz	$L80
	jmp	$L81
$L80:	cmp	word ptr [bp+006h],+000h
	jz	$L82
	jmp	near ptr $L83
$L82:	les	bx,dword ptr [bp+016h]
	cmp	word ptr es:[bx],+000h
	jz	$L84
	jmp	near ptr $L83
$L84:	mov	word ptr [bp-009Ch],0000h
	jmp	near ptr $L85
$L88:	inc	word ptr [bp-009Ch]
$L85:	mov	ax,[bp+00Ch]
	cmp	[bp-009Ch],ax
	jl	$L86
	jmp	near ptr $L87
$L86:	mov	si,[bp-009Ch]
	mov	byte ptr [bp+si-0088h],00h
	jmp	near ptr $L88
$L87:	push	[bp+014h]
	push	[bp+010h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
$L83:	mov	al,[bp-00A8h]
	mov	si,[bp-00A4h]
	mov	[bp+si-0088h],al
	push	[bp+014h]
	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	push	+001h
	lea	ax,[bp-00A8h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
	mov	ax,[bp+00Ch]
	dec	ax
	cmp	ax,[bp-00A4h]
	jg	$L89
	jmp	near ptr $L90
$L89:	inc	word ptr [bp-00A4h]
$L90:	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	les	bx,dword ptr [bp+016h]
	inc	word ptr es:[bx]
	jmp	$L16
$L81:	cmp	word ptr $S13,+001h
	jz	$L91
	jmp	$L16
$L91:	cmp	word ptr [bp+006h],+000h
	jz	$L92
	jmp	near ptr $L93
$L92:	les	bx,dword ptr [bp+016h]
	cmp	word ptr es:[bx],+000h
	jz	$L94
	jmp	near ptr $L93
$L94:	mov	word ptr [bp-009Ch],0000h
	jmp	near ptr $L95
$L98:	inc	word ptr [bp-009Ch]
$L95:	mov	ax,[bp+00Ch]
	cmp	[bp-009Ch],ax
	jl	$L96
	jmp	near ptr $L97
$L96:	mov	si,[bp-009Ch]
	mov	byte ptr [bp+si-0088h],00h
	jmp	near ptr $L98
$L97:	push	[bp+014h]
	push	[bp+010h]
	push	[bp+00Eh]
	push	[bp+00Ch]
	lea	ax,[bp-0088h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
$L93:	mov	ax,[bp+00Ch]
	dec	ax
	mov	[bp-009Ch],ax
	jmp	near ptr $L99
$L102:	dec	word ptr [bp-009Ch]
$L99:	mov	ax,[bp-00A4h]
	cmp	[bp-009Ch],ax
	jnl	$L100
	jmp	near ptr $L101
$L100:	mov	si,[bp-009Ch]
	mov	al,[bp+si-0089h]
	mov	si,[bp-009Ch]
	mov	[bp+si-0088h],al
	jmp	near ptr $L102
$L101:	mov	al,[bp-00A8h]
	mov	si,[bp-00A4h]
	mov	[bp+si-0088h],al
	push	[bp+014h]
	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	mov	ax,[bp+00Ch]
	sub	ax,[bp-00A4h]
	push	ax
	mov	si,[bp-00A4h]
	lea	ax,[bp+si-0088h]
	push	ss
	push	ax
	call	far ptr _gdisp
	add	sp,+00Ch
	mov	ax,[bp+00Ch]
	dec	ax
	cmp	ax,[bp-00A4h]
	jg	$L103
	jmp	near ptr $L104
$L103:	inc	word ptr [bp-00A4h]
$L104:	mov	ax,[bp-00A4h]
	add	ax,[bp+010h]
	push	ax
	push	[bp+00Eh]
	call	far ptr _cursor
	add	sp,+004h
	les	bx,dword ptr [bp+016h]
	inc	word ptr es:[bx]
$L16:	jmp	$L105
$L26:	pop	si
	pop	di
	leave
	retf
_outit:	enter	00002h,000h
	push	di
	push	si
	mov	ax,[bp+00Eh]
	dec	ax
	mov	[bp-002h],ax
	jmp	near ptr $L106
$L112:	dec	word ptr [bp-002h]
$L106:	cmp	word ptr [bp-002h],+000h
	jnl	$L107
	jmp	near ptr $L108
$L107:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-002h]
	cmp	byte ptr es:[bx+si],00h
	jz	$L109
	jmp	near ptr $L110
$L109:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-002h]
	cmp	byte ptr es:[bx+si],20h
	jnz	$L110
	jmp	near ptr $L111
$L110:	jmp	near ptr $L108
$L111:	jmp	near ptr $L112
$L108:	mov	bx,[bp-002h]
	les	si,dword ptr [bp+006h]
	mov	byte ptr es:[bx+si+001h],00h
	mov	word ptr [bp-002h],0000h
	jmp	near ptr $L113
$L116:	inc	word ptr [bp-002h]
$L113:	mov	ax,[bp+00Eh]
	cmp	[bp-002h],ax
	jl	$L114
	jmp	near ptr $L115
$L114:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-002h]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+00Ah]
	mov	si,[bp-002h]
	mov	es:[bx+si],al
	jmp	near ptr $L116
$L115:	pop	si
	pop	di
	leave
	retf

ED_TEXT	ENDS
_DATA	SEGMENT

$S13	dw	00000h
	db	000h
	db	000h

_DATA	ENDS
	END
