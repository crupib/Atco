; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	picfil.C
; [000D]	.286p
	.287
	; Large Memory Model
; [0015]	; CodeView Enabled
PICFIL_TEXT	SEGMENT	WORD PUBLIC 'CODE'
PICFIL_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC 'DATA'
_DATA	ENDS
CONST	SEGMENT	WORD PUBLIC 'CONST'
CONST	ENDS
_BSS	SEGMENT	WORD PUBLIC 'BSS'
_BSS	ENDS
DGROUP	GROUP	CONST, _BSS, _DATA
; [025F]	; Linker - Pass two marker

	EXTRN		_xdir:NEAR
	EXTRN		_filmem:NEAR
	EXTRN		_getkey:NEAR
	EXTRN		_ed:NEAR
	EXTRN		_strncmp:NEAR
	EXTRN		_ndir:NEAR
	EXTRN		_strncpy:NEAR
	EXTRN		_dspla2:NEAR
	EXTRN		_blank:NEAR
	EXTRN		_qsort:NEAR
	EXTRN		_mkdir:NEAR
	EXTRN		_getcwd:NEAR
	EXTRN		_chdir:NEAR
	EXTRN		_dsplaf:NEAR
	EXTRN		_border:NEAR
	EXTRN		__dos_setdrive:NEAR
	EXTRN		_sprintf:NEAR
	EXTRN		_strcpy:NEAR
	EXTRN		_malloc:NEAR
	EXTRN		_dsplin:NEAR
	EXTRN		_fixfn:NEAR
	EXTRN		__dos_getdrive:NEAR
	EXTRN		_free:NEAR
	EXTRN		_chkey:NEAR
	PUBLIC		_picfil			; Located at 1:0000h Type = 1
	PUBLIC		_showcl			; Located at 1:0AE8h Type = 1
	PUBLIC		_datico			; Located at 1:0B14h Type = 1
	PUBLIC		_strcvt			; Located at 1:0BB8h Type = 1
	PUBLIC		_dispage		; Located at 1:0C95h Type = 1
	PUBLIC		_clrdsp			; Located at 1:0E1Ah Type = 1
	PUBLIC		_comp_name		; Located at 1:0E73h Type = 1
	PUBLIC		_comp_date		; Located at 1:0E96h Type = 1
	PUBLIC		_comp_size		; Located at 1:0EFFh Type = 1
	PUBLIC		_change_dir		; Located at 1:0F68h Type = 1

PICFIL_TEXT	SEGMENT
	assume	cs: PICFIL_TEXT


_picfil:
	enter	000A0h,000h
	push	di
	push	si
	push	[bp+008h]
	push	[bp+006h]
	push	+071h
	push	+070h
	call	far ptr _border
	add	sp,+008h
	les	bx,dword ptr [bp+01Eh]
	mov	word ptr es:[bx],0000h
	les	bx,dword ptr [bp+022h]
	mov	word ptr es:[bx],0000h
	assume	ds: DGROUP
	mov	word ptr $S1,0012h
	push	+071h
	push	+002h
	push	+001h
	push	ds
	push	offset DGROUP:$S2
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	+071h
	push	+02Ch
	push	+001h
	push	ds
	push	offset DGROUP:$S3
	call	far ptr _dsplaf
	add	sp,+00Ah
	lea	ax,[bp-009Ah]
	push	ss
	push	ax
	call	far ptr __dos_getdrive
	add	sp,+004h
	push	+01Fh
	lea	ax,[bp-020h]
	push	ss
	push	ax
	call	far ptr _getcwd
	add	sp,+006h
	mov	[bp-064h],ax
	mov	[bp-062h],dx
$L101:	les	bx,dword ptr [bp+00Eh]
	cmp	byte ptr es:[bx+001h],3Ah
	jz	$L4
	jmp	near ptr $L5
$L4:	les	bx,dword ptr [bp+00Eh]
	mov	al,es:[bx]
	cbw
	mov	[bp-009Ch],ax
	cmp	word ptr [bp-009Ch],+041h
	jnl	$L6
	jmp	near ptr $L7
$L6:	cmp	word ptr [bp-009Ch],+05Ah
	jng	$L8
	jmp	near ptr $L7
$L8:	mov	ax,[bp-009Ch]
	sub	ax,0040h
	mov	[bp-032h],ax
$L7:	cmp	word ptr [bp-009Ch],+061h
	jnl	$L9
	jmp	near ptr $L10
$L9:	cmp	word ptr [bp-009Ch],+07Ah
	jng	$L11
	jmp	near ptr $L10
$L11:	mov	ax,[bp-009Ch]
	sub	ax,0060h
	mov	[bp-032h],ax
$L10:	cmp	word ptr [bp-032h],+001h
	jnl	$L12
	jmp	near ptr $L13
$L12:	cmp	word ptr [bp-032h],+01Ah
	jg	$L13
	jmp	near ptr $L14
$L13:	mov	word ptr [bp-032h],0003h
$L14:	lea	ax,[bp-0098h]
	push	ss
	push	ax
	push	[bp-032h]
	call	far ptr __dos_setdrive
	add	sp,+006h
$L5:	mov	ax,[bp-062h]
	or	ax,[bp-064h]
	jnz	$L15
	jmp	near ptr $L16
$L15:	push	[bp+010h]
	push	[bp+00Eh]
	call	far ptr _chdir
	add	sp,+004h
	mov	[bp-022h],ax
$L16:	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L17
$L20:	inc	word ptr [bp-06Ah]
$L17:	cmp	word ptr [bp-06Ah],+013h
	jl	$L18
	jmp	near ptr $L19
$L18:	mov	si,[bp-06Ah]
	mov	byte ptr [bp+si-056h],20h
	jmp	near ptr $L20
$L19:	mov	byte ptr [bp-043h],00h
	push	+01Fh
	push	+015h
	push	+001h
	lea	ax,[bp-056h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	+020h
	lea	ax,[bp-056h]
	push	ss
	push	ax
	call	far ptr _getcwd
	add	sp,+006h
	push	+014h
	lea	ax,[bp-056h]
	push	ss
	push	ax
	push	[bp+010h]
	push	[bp+00Eh]
	call	far ptr _strncpy
	add	sp,+00Ah
	push	+01Fh
	push	+015h
	push	+001h
	lea	ax,[bp-056h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
	push	+01Fh
	push	+03Eh
	push	+009h
	push	[bp+00Ch]
	push	[bp+00Ah]
	call	far ptr _dsplaf
	add	sp,+00Ah
	call	far ptr _showcl
	les	bx,dword ptr [bp+012h]
	mov	byte ptr es:[bx],00h
	push	[bp+00Ch]
	push	[bp+00Ah]
	call	far ptr _ndir
	add	sp,+004h
	mov	$S21,ax
	imul	ax,$S21,+014h
	mov	[bp-066h],ax
	cmp	word ptr $S21,+000h
	jg	$L22
	jmp	$L23
$L22:	push	[bp-066h]
	call	far ptr _malloc
	add	sp,+002h
	mov	[bp-030h],ax
	mov	[bp-02Eh],dx
	mov	ax,[bp-02Eh]
	or	ax,[bp-030h]
	jz	$L24
	jmp	near ptr $L25
$L24:	push	+074h
	push	+017h
	push	+00Ch
	push	ds
	push	offset DGROUP:$S26
	call	far ptr _dsplaf
	add	sp,+00Ah
	call	far ptr _getkey
	mov	word ptr [bp-058h],001Bh
	jmp	$L27
$L25:	push	+000h
	mov	ax,[bp-066h]
	sar	ax,1
	push	ax
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _filmem
	add	sp,+008h
	push	[bp-02Eh]
	push	[bp-030h]
	push	[bp+00Ch]
	push	[bp+00Ah]
	call	far ptr _xdir
	add	sp,+008h
	mov	$S21,ax
	mov	cx,0014h
	mov	ax,$S21
	cwd
	idiv	cx
	mov	$S21,ax
	cmp	word ptr $S28,+000h
	jz	$L29
	jmp	near ptr $L30
$L29:	push	seg _comp_name
	push	offset _comp_name
	push	+014h
	push	$S21
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _qsort
	add	sp,+00Ch
	jmp	near ptr $L23
$L30:	cmp	word ptr $S28,+001h
	jz	$L31
	jmp	near ptr $L32
$L31:	push	seg _comp_date
	push	offset _comp_date
	push	+014h
	push	$S21
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _qsort
	add	sp,+00Ch
	jmp	near ptr $L23
$L32:	cmp	word ptr $S28,+002h
	jz	$L33
	jmp	near ptr $L23
$L33:	push	seg _comp_size
	push	offset _comp_size
	push	+014h
	push	$S21
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _qsort
	add	sp,+00Ch
$L23:	mov	ax,0000h
	mov	[bp-026h],ax
	mov	[bp-02Ch],ax
	mov	word ptr [bp-034h],0000h
	cmp	word ptr $S21,+000h
	jg	$L34
	jmp	near ptr $L35
$L34:	mov	ax,$S21
	dec	ax
	mov	cx,0024h
	cwd
	idiv	cx
	mov	[bp-06Eh],ax
	jmp	near ptr $L36
$L35:	mov	word ptr [bp-06Eh],0001h
$L36:	imul	ax,[bp-034h],+024h
	mov	[bp-02Ah],ax
	mov	ax,[bp-02Ah]
	add	ax,0024h
	mov	[bp-024h],ax
	mov	ax,$S21
	cmp	[bp-024h],ax
	jg	$L37
	jmp	near ptr $L38
$L37:	mov	ax,$S21
	mov	[bp-024h],ax
$L38:	mov	word ptr [bp-028h],0003h
	mov	word ptr [bp-05Ch],0001h
	call	far ptr _clrdsp
	push	[bp-034h]
	push	[bp-02Eh]
	push	[bp-030h]
	push	[bp-024h]
	push	[bp-02Ah]
	call	far ptr _dispage
	add	sp,+00Ah
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _strcvt
	add	sp,+008h
$L121:	mov	word ptr [bp-058h],0000h
	mov	word ptr $S39,0000h
$L47:	call	far ptr _chkey
	cmp	ax,0000h
	jz	$L40
	jmp	near ptr $L41
$L40:	cmp	word ptr $S39,+000h
	jz	$L42
	jmp	near ptr $L41
$L42:	cmp	word ptr $S43,+000h
	jz	$L44
	jmp	near ptr $L41
$L44:	cmp	word ptr $S45,+000h
	jz	$L46
	jmp	near ptr $L41
$L46:	jmp	near ptr $L47
$L41:	call	far ptr _chkey
	cmp	ax,0000h
	jnz	$L48
	jmp	near ptr $L49
$L48:	call	far ptr _getkey
	mov	[bp-058h],ax
$L49:	cmp	word ptr $S50,+000h
	jnz	$L51
	jmp	near ptr $L52
$L51:	cmp	word ptr $S43,+000h
	jnz	$L53
	jmp	near ptr $L52
$L53:	mov	word ptr [bp-058h],000Dh
$L52:	cmp	word ptr $S50,+000h
	jnz	$L54
	jmp	near ptr $L55
$L54:	cmp	word ptr $S45,+000h
	jnz	$L56
	jmp	near ptr $L55
$L56:	mov	word ptr [bp-058h],001Bh
$L55:	cmp	word ptr [bp-058h],+00Dh
	jz	$L57
	jmp	$L58

$L57:	cmp	word ptr $S21,+000h
	jg	$L59
	jmp	$L60
$L59:	imul	ax,[bp-02Ch],+014h
	add	ax,[bp-030h]
	mov	dx,[bp-02Eh]
	mov	[bp-060h],ax
	mov	[bp-05Eh],dx
	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L61
$L64:	inc	word ptr [bp-06Ah]
$L61:	cmp	word ptr [bp-06Ah],+00Ch
	jl	$L62
	jmp	near ptr $L63
$L62:	les	bx,dword ptr [bp-060h]
	mov	si,[bp-06Ah]
	mov	al,es:[bx+si]
	les	bx,dword ptr [bp+012h]
	mov	si,[bp-06Ah]
	mov	es:[bx+si],al
	jmp	near ptr $L64
$L63:	les	bx,dword ptr [bp+012h]
	mov	byte ptr es:[bx+00Ch],00h
	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L65
$L68:	inc	word ptr [bp-06Ah]
$L65:	cmp	word ptr [bp-06Ah],+004h
	jl	$L66
	jmp	near ptr $L67
$L66:	mov	bx,[bp-06Ah]
	les	si,dword ptr [bp-060h]
	mov	al,es:[bx+si+00Ch]
	les	bx,dword ptr [bp+016h]
	mov	si,[bp-06Ah]
	mov	es:[bx+si],al
	jmp	near ptr $L68
$L67:	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L69
$L72:	inc	word ptr [bp-06Ah]
$L69:	cmp	word ptr [bp-06Ah],+004h
	jl	$L70
	jmp	near ptr $L71
$L70:	mov	bx,[bp-06Ah]
	les	si,dword ptr [bp-060h]
	mov	al,es:[bx+si+010h]
	les	bx,dword ptr [bp+01Ah]
	mov	si,[bp-06Ah]
	mov	es:[bx+si],al
	jmp	near ptr $L72
$L71:	jmp	$L73
	jmp	near ptr $L74
$L60:	cmp	word ptr [bp-058h],+01Bh
	jz	$L75
	jmp	near ptr $L76
$L75:	jmp	near ptr $L76
$L76:	les	bx,dword ptr [bp+012h]
	mov	byte ptr es:[bx],00h
	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L77
$L80:	inc	word ptr [bp-06Ah]
$L77:	cmp	word ptr [bp-06Ah],+004h
	jl	$L78
	jmp	near ptr $L79
$L78:	les	bx,dword ptr [bp+016h]
	mov	si,[bp-06Ah]
	mov	byte ptr es:[bx+si],00h
	jmp	near ptr $L80
$L79:	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L81
$L84:	inc	word ptr [bp-06Ah]
$L81:	cmp	word ptr [bp-06Ah],+004h
	jl	$L82
	jmp	near ptr $L83
$L82:	les	bx,dword ptr [bp+01Ah]
	mov	si,[bp-06Ah]
	mov	byte ptr es:[bx+si],00h
	jmp	near ptr $L84
$L83:	jmp	$L73
$L74:	jmp	$L85
$L58:	cmp	word ptr [bp-058h],+01Bh
	jz	$L86
	jmp	near ptr $L87
$L86:	les	bx,dword ptr [bp+012h]
	mov	byte ptr es:[bx],00h
	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L88
$L91:	inc	word ptr [bp-06Ah]
$L88:	cmp	word ptr [bp-06Ah],+004h
	jl	$L89
	jmp	near ptr $L90
$L89:	les	bx,dword ptr [bp+016h]
	mov	si,[bp-06Ah]
	mov	byte ptr es:[bx+si],00h
	jmp	near ptr $L91
$L90:	mov	word ptr [bp-06Ah],0000h
	jmp	near ptr $L92
$L95:	inc	word ptr [bp-06Ah]
$L92:	cmp	word ptr [bp-06Ah],+004h
	jl	$L93
	jmp	near ptr $L94
$L93:	les	bx,dword ptr [bp+01Ah]
	mov	si,[bp-06Ah]
	mov	byte ptr es:[bx+si],00h
	jmp	near ptr $L95
$L94:	jmp	$L73
	jmp	$L85
$L87:	cmp	word ptr [bp-058h],+063h
	jnz	$L96
	jmp	near ptr $L97
$L96:	cmp	word ptr [bp-058h],+043h
	jz	$L97
	jmp	near ptr $L98
$L97:	cmp	word ptr $S21,+000h
	jg	$L99
	jmp	near ptr $L100
$L99:	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _free
	add	sp,+004h
$L100:	push	+071h
	push	+001h
	push	+017h
	push	+04Eh
	call	far ptr _blank
	add	sp,+008h
	push	[bp+010h]
	push	[bp+00Eh]
	push	+017h
	call	far ptr _change_dir
	add	sp,+006h
	les	bx,dword ptr [bp+01Eh]
	mov	word ptr es:[bx],0001h
	jmp	$L101
	jmp	$L85
$L98:	cmp	word ptr [bp-058h],+074h
	jnz	$L102
	jmp	near ptr $L103
$L102:	cmp	word ptr [bp-058h],+054h
	jz	$L103
	jmp	$L104
$L103:	cmp	word ptr $S21,+000h
	jg	$L105
	jmp	near ptr $L106
$L105:	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _free
	add	sp,+004h
$L106:	push	+071h
	push	+001h
	push	+017h
	push	+04Eh
	call	far ptr _blank
	add	sp,+008h
	push	+071h
	push	+016h
	push	+017h
	push	ds
	push	offset DGROUP:$S107
	call	far ptr _dsplaf
	add	sp,+00Ah
	lea	ax,[bp-009Eh]
	push	ss
	push	ax
	push	+01Fh
	push	+071h
	push	+02Fh
	push	+017h
	push	+00Ch
	push	[bp+00Ch]
	push	[bp+00Ah]
	push	+000h
	call	far ptr _ed
	add	sp,+014h
	push	+01Fh
	push	+03Eh
	push	+001h
	push	+00Ch
	call	far ptr _blank
	add	sp,+008h
	push	+01Fh
	push	+03Eh
	push	+001h
	push	[bp+00Ch]
	push	[bp+00Ah]
	call	far ptr _dsplaf
	add	sp,+00Ah
	call	far ptr _showcl
	les	bx,dword ptr [bp+022h]
	mov	word ptr es:[bx],0001h
	jmp	$L16
	jmp	$L85
$L104:	cmp	word ptr [bp-058h],+073h
	jnz	$L108
	jmp	near ptr $L109
$L108:	cmp	word ptr [bp-058h],+053h
	jz	$L109
	jmp	$L85
$L109:	cmp	word ptr $S21,+000h
	jnz	$L110
	jmp	$L85
$L110:	inc	word ptr $S28
	cmp	word ptr $S28,+002h
	jg	$L111
	jmp	near ptr $L112
$L111:	mov	word ptr $S28,0000h
$L112:	cmp	word ptr $S28,+000h
	jz	$L113
	jmp	near ptr $L114
$L113:	push	seg _comp_name
	push	offset _comp_name
	push	+014h
	push	$S21
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _qsort
	add	sp,+00Ch
	jmp	near ptr $L115
$L114:	cmp	word ptr $S28,+001h
	jz	$L116
	jmp	near ptr $L117
$L116:	push	seg _comp_date
	push	offset _comp_date
	push	+014h
	push	$S21
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _qsort
	add	sp,+00Ch
	jmp	near ptr $L115
$L117:	cmp	word ptr $S28,+002h
	jz	$L118
	jmp	near ptr $L115
$L118:	push	seg _comp_size
	push	offset _comp_size
	push	+014h
	push	$S21
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _qsort
	add	sp,+00Ch
$L115:	mov	word ptr [bp-02Ch],0000h
	mov	word ptr [bp-034h],0000h
	imul	ax,[bp-034h],+024h
	mov	[bp-02Ah],ax
	mov	ax,[bp-02Ah]
	add	ax,0024h
	mov	[bp-024h],ax
	mov	ax,$S21
	cmp	[bp-024h],ax
	jg	$L119
	jmp	near ptr $L120
$L119:	mov	ax,$S21
	mov	[bp-024h],ax
$L120:	lea	ax,[bp-0096h]
	push	ss
	push	ax
	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _strcvt
	add	sp,+008h
	push	[bp-034h]
	push	[bp-02Eh]
	push	[bp-030h]
	push	[bp-024h]
	push	[bp-02Ah]
	call	far ptr _dispage
	add	sp,+00Ah
	mov	word ptr [bp-02Ch],0000h
	mov	ax,[bp-02Ch]
	sub	ax,[bp-02Ah]
	cwd
	idiv	word ptr $S1
	add	dx,+003h
	mov	[bp-028h],dx
	mov	ax,[bp-02Ch]
	sub	ax,[bp-02Ah]
	cwd
	idiv	word ptr $S1
	imul	ax,ax,+02Ah
	inc	ax
	mov	[bp-05Ch],ax
	jmp	$L121
$L85:	cmp	word ptr $S50,+000h
	jnz	$L122
	jmp	$L123
$L122:	cmp	word ptr $S39,-001h
	jz	$L124
	jmp	$L123
$L124:	mov	word ptr $S39,0000h
	mov	ax,$S125
	sar	ax,03h
	imul	word ptr $S1
	mov	cx,$S126
	sar	cx,03h
	add	ax,cx
	mov	[bp-02Ch],ax
	imul	ax,[bp-034h],+024h
	add	[bp-02Ch],ax
	cmp	word ptr [bp-02Ch],+000h

	jl	$L127
	jmp	near ptr $L128
$L127:	mov	word ptr [bp-02Ch],0000h
	jmp	near ptr $L129
$L128:	mov	ax,$S21
	cmp	[bp-02Ch],ax
	jnl	$L130
	jmp	near ptr $L129
$L130:	mov	ax,$S21
	mov	[bp-02Ch],ax
$L129:	mov	ax,[bp-02Ch]
	cmp	[bp-026h],ax
	jnz	$L131
	jmp	near ptr $L132
$L131:	push	+070h
	push	[bp-05Ch]
	push	[bp-028h]
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
$L132:	mov	ax,[bp-02Ch]
	mov	[bp-026h],ax
	mov	ax,[bp-02Ch]
	cmp	[bp-02Ah],ax
	jg	$L133
	jmp	near ptr $L134
$L133:	mov	word ptr [bp-058h],4900h
	jmp	near ptr $L135
$L134:	mov	ax,[bp-02Ch]
	cmp	[bp-024h],ax
	jng	$L136
	jmp	near ptr $L135
$L136:	mov	word ptr [bp-058h],5100h
$L135:	jmp	$L137
$L123:	cmp	word ptr [bp-058h],4D00h
	jz	$L138
	jmp	near ptr $L139
$L138:	cmp	word ptr $S21,+000h
	jnz	$L140
	jmp	near ptr $L139
$L140:	push	+070h
	push	[bp-05Ch]
	push	[bp-028h]
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
	mov	ax,[bp-02Ch]
	mov	[bp-036h],ax
	mov	ax,$S1
	add	[bp-02Ch],ax
	mov	ax,[bp-02Ch]
	cmp	[bp-024h],ax
	jng	$L141
	jmp	near ptr $L142
$L141:	mov	ax,[bp-036h]
	mov	[bp-02Ch],ax
$L142:	mov	ax,[bp-02Ch]
	mov	[bp-026h],ax
	jmp	$L137
$L139:	cmp	word ptr [bp-058h],4B00h
	jz	$L143
	jmp	near ptr $L144
$L143:	cmp	word ptr $S21,+000h
	jnz	$L145
	jmp	near ptr $L144
$L145:	push	+070h
	push	[bp-05Ch]
	push	[bp-028h]
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
	mov	ax,[bp-02Ch]
	mov	[bp-036h],ax
	mov	ax,$S1
	sub	[bp-02Ch],ax
	mov	ax,[bp-02Ch]
	cmp	[bp-02Ah],ax
	jg	$L146
	jmp	near ptr $L147
$L146:	mov	ax,[bp-036h]
	mov	[bp-02Ch],ax
$L147:	mov	ax,[bp-02Ch]
	mov	[bp-026h],ax
	jmp	$L137
$L144:	cmp	word ptr [bp-058h],5000h
	jz	$L148
	jmp	near ptr $L149
$L148:	cmp	word ptr $S21,+000h
	jnz	$L150
	jmp	near ptr $L149
$L150:	push	+070h
	push	[bp-05Ch]
	push	[bp-028h]
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
	inc	word ptr [bp-02Ch]
	mov	ax,$S21
	cmp	[bp-02Ch],ax
	jnl	$L151
	jmp	near ptr $L152
$L151:	mov	ax,$S21
	dec	ax
	mov	[bp-02Ch],ax
	jmp	near ptr $L153
$L152:	mov	ax,[bp-02Ch]
	cmp	[bp-024h],ax
	jng	$L154
	jmp	near ptr $L153
$L154:	mov	word ptr [bp-058h],5100h
$L153:	mov	ax,[bp-02Ch]
	mov	[bp-026h],ax
	jmp	near ptr $L137
$L149:	cmp	word ptr [bp-058h],4800h
	jz	$L155
	jmp	near ptr $L137
$L155:	cmp	word ptr $S21,+000h
	jnz	$L156
	jmp	near ptr $L137
$L156:	push	+070h
	push	[bp-05Ch]
	push	[bp-028h]
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
	dec	word ptr [bp-02Ch]
	cmp	word ptr [bp-02Ch],+000h
	jl	$L157
	jmp	near ptr $L158
$L157:	mov	word ptr [bp-02Ch],0000h
	jmp	near ptr $L159
$L158:	mov	ax,[bp-02Ch]
	cmp	[bp-02Ah],ax
	jg	$L160
	jmp	near ptr $L159
$L160:	mov	word ptr [bp-058h],4900h
$L159:	mov	ax,[bp-02Ch]
	mov	[bp-026h],ax
$L137:	cmp	word ptr [bp-058h],4900h
	jz	$L161
	jmp	near ptr $L162
$L161:	cmp	word ptr $S21,+000h
	jnz	$L163
	jmp	near ptr $L162
$L163:	dec	word ptr [bp-034h]
	cmp	word ptr [bp-034h],+000h
	jl	$L164
	jmp	near ptr $L165
$L164:	mov	word ptr [bp-034h],0000h
$L165:	imul	ax,[bp-034h],+024h
	mov	[bp-02Ah],ax
	mov	ax,[bp-02Ah]
	add	ax,0024h
	mov	[bp-024h],ax
	mov	ax,$S21
	cmp	[bp-024h],ax
	jg	$L166
	jmp	near ptr $L167
$L166:	mov	ax,$S21
	mov	[bp-024h],ax
$L167:	push	[bp-034h]
	push	[bp-02Eh]
	push	[bp-030h]
	push	[bp-024h]
	push	[bp-02Ah]
	call	far ptr _dispage
	add	sp,+00Ah
	mov	ax,[bp-02Ah]
	mov	[bp-02Ch],ax
	jmp	$L168
$L162:	cmp	word ptr [bp-058h],5100h
	jnz	$L169
	jmp	near ptr $L170
$L169:	cmp	word ptr $S171,+000h
	jnz	$L170
	jmp	$L168
$L170:	cmp	word ptr $S21,+000h
	jg	$L172
	jmp	near ptr $L168
$L172:	inc	word ptr [bp-034h]
	cmp	word ptr [bp-058h],5100h
	jz	$L173
	jmp	near ptr $L174
$L173:	mov	ax,[bp-06Eh]
	cmp	[bp-034h],ax
	jg	$L175
	jmp	near ptr $L174
$L175:	mov	ax,[bp-06Eh]
	mov	[bp-034h],ax
	jmp	near ptr $L176
$L174:	cmp	word ptr $S171,+000h
	jnz	$L177
	jmp	near ptr $L176
$L177:	mov	ax,[bp-06Eh]
	cmp	[bp-034h],ax
	jg	$L178
	jmp	near ptr $L176
$L178:	mov	word ptr [bp-034h],0000h
$L176:	mov	word ptr $S171,0000h
	imul	ax,[bp-034h],+024h
	mov	[bp-02Ah],ax
	mov	ax,[bp-02Ah]
	add	ax,0024h
	mov	[bp-024h],ax
	mov	ax,$S21
	cmp	[bp-024h],ax
	jg	$L179
	jmp	near ptr $L180
$L179:	mov	ax,$S21
	mov	[bp-024h],ax
$L180:	push	[bp-034h]
	push	[bp-02Eh]
	push	[bp-030h]
	push	[bp-024h]
	push	[bp-02Ah]
	call	far ptr _dispage
	add	sp,+00Ah
	mov	ax,[bp-02Ah]
	mov	[bp-02Ch],ax
$L168:	cmp	word ptr $S21,+000h
	jnz	$L181
	jmp	near ptr $L182
$L181:	mov	ax,[bp-02Ch]
	sub	ax,[bp-02Ah]
	cwd
	idiv	word ptr $S1
	add	dx,+003h
	mov	[bp-028h],dx
	mov	ax,[bp-02Ch]
	sub	ax,[bp-02Ah]
	cwd
	idiv	word ptr $S1
	imul	ax,ax,+02Ah
	inc	ax
	mov	[bp-05Ch],ax
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	imul	cx,[bp-02Ch],+014h
	add	cx,[bp-030h]
	mov	dx,[bp-02Eh]
	push	dx
	push	cx
	call	far ptr _strcvt
	add	sp,+008h
	push	+01Fh
	push	[bp-05Ch]
	push	[bp-028h]
	lea	ax,[bp-0096h]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
$L182:	jmp	$L121
$L73:	mov	ax,0000h
	mov	$S39,ax
	mov	$S183,ax
	mov	$S45,ax
	mov	$S184,ax
	mov	$S171,ax
	mov	$S185,ax
	mov	$S43,ax
	cmp	word ptr $S21,+000h
	jg	$L186
	jmp	near ptr $L27
$L186:	push	[bp-02Eh]
	push	[bp-030h]
	call	far ptr _free
	add	sp,+004h
$L27:	lea	ax,[bp-0098h]
	push	ss
	push	ax
	push	[bp-009Ah]
	call	far ptr __dos_setdrive
	add	sp,+006h
	mov	ax,[bp-062h]
	or	ax,[bp-064h]
	jnz	$L187
	jmp	near ptr $L188
$L187:	lea	ax,[bp-020h]
	push	ss
	push	ax
	call	far ptr _chdir
	add	sp,+004h
	mov	[bp-022h],ax
$L188:	mov	ax,[bp-058h]
	jmp	near ptr $L189
$L189:	pop	si
	pop	di
	leave
	retf
_showcl:
	enter	00000h,000h
	push	di
	push	si
	push	+071h
	push	+001h
	push	+017h
	push	+04Eh
	call	far ptr _blank
	add	sp,+008h
	push	+071h
	push	+002h
	push	+017h
	push	ds
	push	offset DGROUP:$S190
	call	far ptr _dsplaf
	add	sp,+00Ah
	pop	si
	pop	di
	leave
	retf

_datico:
	enter	0000Ch,000h
	push	di
	push	si
	les	bx,dword ptr [bp+006h]
	mov	al,es:[bx+001h]
	shr	al,1
	sub	ah,ah
	mov	[bp-002h],ax
	add	word ptr [bp-002h],+050h
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx]
	and	ax,01E0h
	sar	ax,05h
	mov	[bp-006h],ax
	les	bx,dword ptr [bp+006h]
	mov	al,es:[bx]
	and	ax,001Fh
	mov	[bp-00Ch],ax
	les	bx,dword ptr [bp+00Ah]
	mov	al,es:[bx+001h]
	shr	al,03h
	sub	ah,ah
	mov	[bp-00Ah],ax
	les	bx,dword ptr [bp+00Ah]
	mov	ax,es:[bx]
	and	ax,07E0h
	sar	ax,05h
	mov	[bp-004h],ax
	push	[bp-002h]
	push	[bp-00Ch]
	push	[bp-006h]
	push	ds
	push	offset DGROUP:$S191
	push	[bp+014h]
	push	[bp+012h]
	call	far ptr _sprintf
	add	sp,+00Eh
	push	[bp-004h]
	push	[bp-00Ah]
	push	ds
	push	offset DGROUP:$S192
	push	[bp+018h]
	push	[bp+016h]
	call	far ptr _sprintf
	add	sp,+00Ch
	les	bx,dword ptr [bp+00Eh]
	push	es:[bx+002h]
	push	es:[bx]
	push	ds
	push	offset DGROUP:$S193
	push	[bp+01Ch]
	push	[bp+01Ah]
	call	far ptr _sprintf
	add	sp,+00Ch
	pop	si
	pop	di
	leave
	retf
_strcvt:
	enter	00022h,000h
	push	di
	push	si
	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L194
$L197:	inc	word ptr [bp-004h]
$L194:	cmp	word ptr [bp-004h],+025h
	jl	$L195
	jmp	near ptr $L196
$L195:	les	bx,dword ptr [bp+00Ah]
	mov	si,[bp-004h]
	mov	byte ptr es:[bx+si],20h
	jmp	near ptr $L197
$L196:	les	bx,dword ptr [bp+00Ah]
	mov	byte ptr es:[bx+025h],00h
	les	bx,dword ptr [bp+00Ah]
	mov	byte ptr es:[bx+026h],00h
	les	bx,dword ptr [bp+00Ah]
	mov	byte ptr es:[bx+027h],00h
	mov	word ptr [bp-004h],0000h
	jmp	near ptr $L198
$L203:	inc	word ptr [bp-004h]
$L198:	cmp	word ptr [bp-004h],+00Ch
	jl	$L199
	jmp	near ptr $L200
$L199:	les	bx,dword ptr [bp+006h]
	mov	si,[bp-004h]
	mov	al,es:[bx+si]
	cbw
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],+000h
	jz	$L201
	jmp	near ptr $L202
$L201:	jmp	near ptr $L200
$L202:	mov	al,[bp-002h]
	les	bx,dword ptr [bp+00Ah]
	mov	si,[bp-004h]
	mov	es:[bx+si],al
	jmp	near ptr $L203
$L200:	lea	ax,[bp-00Eh]
	push	ss
	push	ax
	lea	cx,[bp-022h]
	push	ss
	push	cx
	lea	dx,[bp-018h]
	push	ss
	push	dx
	mov	bx,[bp+006h]
	mov	si,[bp+008h]
	add	bx,+010h
	push	si
	push	bx
	mov	bx,[bp+006h]
	mov	si,[bp+008h]
	add	bx,+00Ch
	push	si
	push	bx
	mov	bx,[bp+006h]
	mov	si,[bp+008h]
	add	bx,+00Eh
	push	si
	push	bx
	call	far ptr _datico
	add	sp,+018h
	lea	ax,[bp-00Eh]
	push	ss
	push	ax
	lea	ax,[bp-022h]
	push	ss
	push	ax
	lea	ax,[bp-018h]
	push	ss
	push	ax
	push	ds
	push	offset DGROUP:$S204
	mov	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	add	ax,000Ch
	push	dx
	push	ax
	call	far ptr _sprintf
	add	sp,+014h
	pop	si
	pop	di
	leave
	retf
_dispage:
	enter	0003Ch,000h
	push	di
	push	si
	cmp	word ptr $S21,+000h
	jz	$L205
	jmp	near ptr $L206
$L205:	call	far ptr _clrdsp
	push	+074h
	push	+014h
	push	+00Ch
	push	ds
	push	offset DGROUP:$S207
	call	far ptr _dsplaf
	add	sp,+00Ah
	jmp	$L208
$L206:	mov	ax,[bp+006h]
	mov	[bp-010h],ax
	jmp	near ptr $L209
$L217:	inc	word ptr [bp-010h]
$L209:	mov	ax,[bp+008h]
	cmp	[bp-010h],ax
	jl	$L210
	jmp	$L211
$L210:	mov	ax,[bp-010h]
	sub	ax,[bp+006h]
	mov	[bp-012h],ax
	lea	ax,[bp-03Ah]
	push	ss
	push	ax
	imul	ax,[bp-010h],+014h
	add	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	push	dx
	push	ax
	call	far ptr _strcvt
	add	sp,+008h
	mov	ax,$S21
	cmp	[bp-010h],ax
	jg	$L212
	jmp	near ptr $L213
$L212:	jmp	near ptr $L211
$L213:	mov	ax,[bp-012h]
	cwd
	idiv	word ptr $S1
	add	dx,+003h
	mov	[bp-002h],dx
	mov	ax,[bp-012h]
	cwd
	idiv	word ptr $S1
	imul	ax,ax,+02Ah
	inc	ax
	mov	[bp-004h],ax
	mov	ax,[bp+006h]
	cmp	[bp-010h],ax
	jz	$L214
	jmp	near ptr $L215
$L214:	push	+01Fh
	push	[bp-004h]
	push	[bp-002h]
	lea	ax,[bp-03Ah]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
	jmp	near ptr $L216
$L215:	push	+070h
	push	[bp-004h]
	push	[bp-002h]
	lea	ax,[bp-03Ah]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
$L216:	jmp	$L217
$L211:	lea	ax,[bp-03Ah]
	push	ss
	push	ax
	imul	ax,[bp+006h],+014h
	add	ax,[bp+00Ah]
	mov	dx,[bp+00Ch]
	push	dx
	push	ax
	call	far ptr _strcvt
	add	sp,+008h
	cmp	word ptr [bp+008h],+000h
	jg	$L218
	jmp	near ptr $L219
$L218:	mov	ax,[bp+008h]
	dec	ax
	mov	cx,0024h
	cwd
	idiv	cx
	inc	dx
	mov	[bp-03Ch],dx
	jmp	near ptr $L220
$L219:	mov	word ptr [bp-03Ch],0000h
$L220:	mov	ax,[bp-03Ch]
	mov	[bp-010h],ax
	jmp	near ptr $L221
$L228:	inc	word ptr [bp-010h]
$L221:	cmp	word ptr [bp-010h],+024h
	jl	$L222
	jmp	near ptr $L223
$L222:	mov	ax,[bp-010h]
	cwd
	idiv	word ptr $S1
	add	dx,+003h
	mov	[bp-002h],dx
	mov	ax,[bp-010h]
	cwd
	idiv	word ptr $S1
	cmp	ax,0000h
	jnz	$L224
	jmp	near ptr $L225
$L224:	mov	word ptr [bp-004h],0028h
	jmp	near ptr $L226
$L225:	mov	word ptr [bp-004h],0001h
$L226:	push	+070h
	push	[bp-004h]
	push	[bp-002h]
	push	ds
	push	offset DGROUP:$S227
	call	far ptr _dsplaf
	add	sp,+00Ah
	jmp	near ptr $L228
$L223:	mov	ax,[bp+00Eh]
	inc	ax
	push	ax
	push	ds
	push	offset DGROUP:$S229
	lea	ax,[bp-00Eh]
	push	ss
	push	ax
	call	far ptr _sprintf
	add	sp,+00Ah
	push	+074h
	push	+024h
	push	+015h
	lea	ax,[bp-00Eh]
	push	ss
	push	ax
	call	far ptr _dsplaf
	add	sp,+00Ah
$L208:	pop	si
	pop	di
	leave
	retf
_clrdsp:
	enter	00052h,000h
	push	di
	push	si
	mov	word ptr [bp-052h],0000h
	jmp	near ptr $L230
$L233:	inc	word ptr [bp-052h]
$L230:	cmp	word ptr [bp-052h],+04Eh
	jl	$L231
	jmp	near ptr $L232
$L231:	mov	si,[bp-052h]
	mov	byte ptr [bp+si-050h],20h
	jmp	near ptr $L233
$L232:	mov	word ptr [bp-052h],0000h
	jmp	near ptr $L234
$L237:	inc	word ptr [bp-052h]
$L234:	cmp	word ptr [bp-052h],+012h
	jl	$L235
	jmp	near ptr $L236
$L235:	push	+070h
	push	+001h
	mov	ax,[bp-052h]
	add	ax,0003h
	push	ax
	push	+04Eh
	lea	ax,[bp-050h]
	push	ss
	push	ax
	call	far ptr _dspla2
	add	sp,+00Ch
	jmp	near ptr $L237
$L236:	pop	si
	pop	di
	leave
	retf
_comp_name:
	enter	00000h,000h
	push	di
	push	si
	push	+004h
	push	[bp+00Ch]
	push	[bp+00Ah]
	push	[bp+008h]
	push	[bp+006h]
	call	far ptr _strncmp
	add	sp,+00Ah
	jmp	near ptr $L238
$L238:	pop	si
	pop	di
	leave
	retf
_comp_date:
	enter	00000h,000h
	push	di
	push	si
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+00Ch]
	mov	dx,es:[bx+00Eh]
	les	bx,dword ptr [bp+00Ah]
	cmp	es:[bx+00Eh],dx
	jnl	$L239
	jmp	near ptr $L240
$L239:	jng	$L241
	jmp	near ptr $L242
$L241:	cmp	es:[bx+00Ch],ax
	jnbe	$L242
	jmp	near ptr $L240
$L242:	mov	ax,0001h

	jmp	near ptr $L243
$L240:	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+00Ch]
	mov	dx,es:[bx+00Eh]
	les	bx,dword ptr [bp+00Ah]
	cmp	es:[bx+00Eh],dx
	jng	$L244
	jmp	near ptr $L245
$L244:	jnl	$L246
	jmp	near ptr $L247
$L246:	cmp	es:[bx+00Ch],ax
	jc	$L247
	jmp	near ptr $L245
$L247:	mov	ax,0FFFFh
	jmp	near ptr $L243
	jmp	near ptr $L243
$L245:	mov	ax,0000h
	jmp	near ptr $L243
$L243:	pop	si
	pop	di
	leave
	retf
_comp_size:
	enter	00000h,000h
	push	di
	push	si
	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+010h]
	mov	dx,es:[bx+012h]
	les	bx,dword ptr [bp+00Ah]
	cmp	es:[bx+012h],dx
	jnl	$L248
	jmp	near ptr $L249
$L248:	jng	$L250
	jmp	near ptr $L251
$L250:	cmp	es:[bx+010h],ax
	jnbe	$L251
	jmp	near ptr $L249
$L251:	mov	ax,0001h
	jmp	near ptr $L252
$L249:	les	bx,dword ptr [bp+006h]
	mov	ax,es:[bx+010h]
	mov	dx,es:[bx+012h]
	les	bx,dword ptr [bp+00Ah]
	cmp	es:[bx+012h],dx
	jng	$L253
	jmp	near ptr $L254
$L253:	jnl	$L255
	jmp	near ptr $L256
$L255:	cmp	es:[bx+010h],ax
	jc	$L256
	jmp	near ptr $L254
$L256:	mov	ax,0FFFFh
	jmp	near ptr $L252
	jmp	near ptr $L252
$L254:	mov	ax,0000h
	jmp	near ptr $L252
$L252:	pop	si
	pop	di
	leave
	retf
_change_dir:
	enter	0004Ch,000h
	push	di
	push	si
	push	+071h
	push	+00Ah
	push	[bp+006h]
	push	ds
	push	offset DGROUP:$S257
	call	far ptr _dsplaf
	add	sp,+00Ah
	mov	word ptr [bp-04Ah],0000h
	jmp	near ptr $L258
$L261:	inc	word ptr [bp-04Ah]
$L258:	cmp	word ptr [bp-04Ah],+020h
	jl	$L259
	jmp	near ptr $L260
$L259:	mov	si,[bp-04Ah]
	mov	byte ptr [bp+si-042h],00h
	jmp	near ptr $L261
$L260:	lea	ax,[bp-04Ch]
	push	ss
	push	ax
	push	+01Fh
	push	+071h
	push	+032h
	push	[bp+006h]
	push	+014h
	lea	ax,[bp-042h]
	push	ss
	push	ax
	push	+000h
	call	far ptr _ed
	add	sp,+014h
	mov	[bp-044h],ax
	cmp	word ptr [bp-044h],+01Bh
	jnz	$L262
	jmp	$L263
$L262:	lea	ax,[bp-042h]
	push	ss
	push	ax
	call	far ptr _fixfn
	add	sp,+004h
	push	+01Fh
	lea	ax,[bp-022h]
	push	ss
	push	ax
	call	far ptr _getcwd
	add	sp,+006h
	mov	[bp-048h],ax
	mov	[bp-046h],dx
	mov	ax,[bp-046h]
	or	ax,[bp-048h]
	jnz	$L264
	jmp	$L263
$L264:	lea	ax,[bp-042h]
	push	ss
	push	ax
	call	far ptr _chdir
	add	sp,+004h
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],-001h
	jz	$L265
	jmp	near ptr $L266
$L265:	push	+071h
	push	+00Ah
	push	[bp+006h]
	push	ds
	push	offset DGROUP:$S267
	call	far ptr _dsplin
	add	sp,+00Ah
	call	far ptr _getkey
	mov	[bp-044h],ax
	cmp	word ptr [bp-044h],+079h
	jnz	$L268
	jmp	near ptr $L269
$L268:	cmp	word ptr [bp-044h],+059h
	jz	$L269
	jmp	near ptr $L270
$L269:	lea	ax,[bp-042h]
	push	ss
	push	ax
	call	far ptr _mkdir
	add	sp,+004h
	mov	[bp-002h],ax
	cmp	word ptr [bp-002h],-001h
	jz	$L271
	jmp	near ptr $L272
$L271:	push	+071h
	push	+00Ah
	push	[bp+006h]
	push	ds
	push	offset DGROUP:$S273
	call	far ptr _dsplin
	add	sp,+00Ah
	call	far ptr _getkey
	jmp	near ptr $L270
$L272:	lea	ax,[bp-042h]
	push	ss
	push	ax
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _strcpy
	add	sp,+008h
$L270:	jmp	near ptr $L274
$L266:	lea	ax,[bp-042h]
	push	ss
	push	ax
	push	[bp+00Ah]
	push	[bp+008h]
	call	far ptr _strcpy
	add	sp,+008h
$L274:	lea	ax,[bp-022h]
	push	ss
	push	ax
	call	far ptr _chdir
	add	sp,+004h
	mov	[bp-002h],ax
$L263:	mov	ax,[bp-044h]
	jmp	near ptr $L275
$L275:	pop	si
	pop	di
	leave
	retf

PICFIL_TEXT	ENDS
_DATA	SEGMENT

$S2	db	'CURRENT DIRECTORY:',000h
$S3	db	'CURRENT TEMPLATE:',000h
$S26	db	'DIRECTORY IS TOO LARGE, REMOVE SOME FILES',000h
$S107	db	'Enter New File Template:',000h

$S50	dw	00000h
$S39	dw	00000h
$S43	dw	00000h
$S185	dw	00000h
$S171	dw	00000h
$S184	dw	00000h
$S45	dw	00000h
$S183	dw	00000h
	db	000h
	db	000h
	db	000h
	db	000h
$S125	dw	00000h
$S126	dw	00000h
$S28	dw	00000h

$S190	db	'Esc = Exit; C = ChDir; Ret = Select; T = Template; S = Sor'
	db	't;  PgUp,PgDn',000h
$S191	db	'%2i/%2.2i/%2.2i',000h
	db	000h
$S192	db	'%2i:%2.2i',000h
	db	000h
$S193	db	'%9ld',000h
$S204	db	'%9s%6s%9s',000h
	db	000h
	db	000h
$S207	db	'NO FILES FOUND WITH THE CURRENT TEMPLATE',000h
$S229	db	'Page %2i',000h

	db	1 dup(?)
$S227	db	'                                       ',000h

$S257	db	'Enter Directory Path Name:',000h
$S267	db	'Directory Does Not Exist -- Create? (Y/N):',000h
$S273	db	'Invalid Directory Name -- Hit Any Key',000h

_DATA	ENDS
_BSS	SEGMENT

$S1	dw	1 dup(?)
$S21	dw	1 dup(?)

_BSS	ENDS
	END
