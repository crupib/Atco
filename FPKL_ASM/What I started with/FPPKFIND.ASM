; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fppkfind.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
FPPKFIND_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
FPPKFIND_TEXT	ENDS
DGROUP	GROUP	_DATA
; [007D]	; Linker - Pass two marker


	PUBLIC		_fp_peak_find		; Located at 3:0000h Type = 1

_DATA	SEGMENT

$S4	db	000h
	db	001h
	db	002h
	db	003h
	db	004h
	db	005h
	db	006h
	db	007h
	db	008h
	db	009h
	db	00Ah
	db	00Bh
	db	00Ch
	db	00Dh
	db	00Eh
	db	00Fh
	db	010h
	db	011h
	db	012h
	db	013h
	db	014h
	db	015h
	db	016h
	db	017h
	db	018h
	db	019h
	db	01Ah
	db	01Bh
	db	01Ch
	db	01Dh
	db	01Eh
	db	01Fh
	db	' !"#$'
	db	'%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]'
	db	'^_`abcdefghijklmnopqrstuvwxyz{|}~'
	db	07Fh
	db	07Fh
	db	07Fh
	db	'~}|{zyxwvutsrqponmlkjihgfedcba`_^]\[ZYXWVUTSRQPONMLKJIHGFE'
	db	'DCBA@?>=<;:9876543210/.-,+*)(''&%$'
	db	'#"! '
	db	01Fh
	db	01Eh
	db	01Dh
	db	01Ch
	db	01Bh
	db	01Ah
	db	019h
	db	018h
	db	017h
	db	016h
	db	015h
	db	014h
	db	013h
	db	012h
	db	011h
	db	010h
	db	00Fh
	db	00Eh
	db	00Dh
	db	00Ch
	db	00Bh
	db	00Ah
	db	009h
	db	008h
	db	007h
	db	006h
	db	005h
	db	004h
	db	003h
	db	002h
	db	001h

_DATA	ENDS
FPPKFIND_TEXT	SEGMENT
	assume	cs: FPPKFIND_TEXT


_fp_peak_find:
	push	bp
	mov	bp,sp
	add	sp,-002h
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	push	dx
	push	di
	push	si
	push	es
	cld
	les	di,dword ptr [bp+006h]
	mov	[bp-002h],di
	mov	si,[bp+00Ah]
	cmp	word ptr [bp+014h],+000h
	jnz	$L1
	cmp	word ptr [bp+010h],+000h
	jz	$L2
	xor	bh,bh
	mov	ax,0FFFFh
	mov	dh,[bp+00Ch]
	dec	di
$L10:	mov	cx,si
	and	si,+003h
	and	cx,-004h
	jz	$L3
$L9:	mov	bl,es:[di+001h]
	assume	ds: DGROUP
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jbe	$L5
	mov	dh,dl
	mov	ax,di
	inc	ax
	mov	bl,es:[di+002h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jbe	$L6
	mov	dh,dl
	inc	ax
	mov	bl,es:[di+003h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jbe	$L7
	mov	dh,dl
	inc	ax
	mov	bl,es:[di+004h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jbe	$L8
	mov	dh,dl
	inc	ax
$L8:	add	di,+004h
	sub	cx,+004h
	jnz	$L9
	jz	$L10
$L7:	mov	bl,es:[di+004h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jnle	$L11
	add	di,+004h
	sub	cx,+004h
	jnz	$L9
	jz	$L10
$L6:	mov	bl,es:[di+003h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jnle	$L12
	mov	bl,es:[di+004h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jnle	$L11
	add	di,+004h
	sub	cx,+004h
	jnz	$L9
	jz	$L10
$L5:	mov	bl,es:[di+002h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jg	$L13
	mov	bl,es:[di+003h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jg	$L12
	mov	bl,es:[di+004h]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jg	$L11
	add	di,+004h
	sub	cx,+004h
	jnz	$L9
	jz	$L10
$L3:	inc	di
$L17:	or	si,si
	jz	$L14
$L16:	mov	bl,es:[di]
	mov	dl,[bx+$S4]
	cmp	dl,dh
	jg	$L15
	inc	di
	dec	si
	jnz	$L16
$L14:	les	di,dword ptr [bp+016h]
	sub	ax,[bp-002h]
	mov	es:[di],ax
	mov	al,dh
	xor	ah,ah
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L13:	mov	dh,dl
	add	di,+002h
	mov	ax,di
	add	si,+002h
	sub	cx,+004h
	jnz	$L9
	jz	$L10
$L12:	mov	dh,dl
	add	di,+003h
	mov	ax,di
	inc	si
	sub	cx,+004h
	jnz	$L9
	jz	$L10
$L11:	mov	dh,dl
	add	di,+004h
	mov	ax,di
	sub	cx,+004h
	jnz	$L9
	jz	$L10
$L15:	mov	dh,dl
	mov	ax,di
	inc	di
	dec	si
	jnz	$L17
	jz	$L14
	jmp	$L18
$L2:	cmp	word ptr [bp+00Eh],+001h
	jnz	$L19
	mov	ax,0FFFFh
	mov	dh,[bp+00Ch]
	dec	di
$L26:	mov	cx,si
	and	si,+003h
	and	cx,-004h
	jz	$L20
$L25:	mov	dl,es:[di+001h]
	cmp	dl,dh
	jng	$L21
	mov	dh,dl
	mov	ax,di
	inc	ax
	mov	dl,es:[di+002h]
	cmp	dl,dh
	jng	$L22
	mov	dh,dl
	inc	ax
	mov	dl,es:[di+003h]
	cmp	dl,dh
	jng	$L23
	mov	dh,dl
	inc	ax
	mov	dl,es:[di+004h]
	cmp	dl,dh
	jng	$L24
	mov	dh,dl
	inc	ax
$L24:	add	di,+004h
	sub	cx,+004h
	jnz	$L25
	jz	$L26
$L23:	mov	dl,es:[di+004h]
	cmp	dl,dh
	jnle	$L27
	add	di,+004h
	sub	cx,+004h
	jnz	$L25
	jz	$L26
$L22:	mov	dl,es:[di+003h]
	cmp	dl,dh
	jg	$L28
	mov	dl,es:[di+004h]
	cmp	dl,dh
	jg	$L27
	add	di,+004h
	sub	cx,+004h
	jnz	$L25
	jz	$L26
$L21:	mov	dl,es:[di+002h]
	cmp	dl,dh
	jg	$L29
	mov	dl,es:[di+003h]
	cmp	dl,dh
	jg	$L28
	mov	dl,es:[di+004h]
	cmp	dl,dh
	jg	$L27
	add	di,+004h
	sub	cx,+004h
	jnz	$L25
	jz	$L26
$L20:	inc	di
$L33:	or	si,si
	jz	$L30
$L32:	mov	dl,es:[di]
	cmp	dl,dh
	jg	$L31
	inc	di
	dec	si
	jnz	$L32
$L30:	les	di,dword ptr [bp+016h]
	sub	ax,[bp-002h]
	mov	es:[di],ax
	mov	al,dh
	xor	ah,ah
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L29:	mov	dh,dl
	add	di,+002h
	mov	ax,di
	add	si,+002h
	sub	cx,+004h
	jnz	$L25
	jz	$L26
$L28:	mov	dh,dl
	add	di,+003h
	mov	ax,di
	inc	si
	sub	cx,+004h
	jnz	$L25
	jz	$L26
$L27:	mov	dh,dl
	add	di,+004h
	mov	ax,di
	sub	cx,+004h
	jnz	$L25
	jz	$L26
$L31:	mov	dh,dl
	mov	ax,di
	inc	di
	dec	si
	jnz	$L33
	jz	$L30
	jmp	$L34
$L19:	mov	ax,0FFFFh
	mov	dh,[bp+00Ch]
	dec	di
$L41:	mov	cx,si
	and	si,+003h
	and	cx,-004h
	jz	$L35
$L40:	mov	dl,es:[di+001h]
	cmp	dl,dh
	jnl	$L36
	mov	dh,dl
	mov	ax,di
	inc	ax
	mov	dl,es:[di+002h]
	cmp	dl,dh
	jnl	$L37
	mov	dh,dl
	inc	ax
	mov	dl,es:[di+003h]
	cmp	dl,dh
	jnl	$L38
	mov	dh,dl
	inc	ax
	mov	dl,es:[di+004h]
	cmp	dl,dh
	jnl	$L39
	mov	dh,dl
	inc	ax
$L39:	add	di,+004h
	sub	cx,+004h
	jnz	$L40
	jz	$L41
$L38:	mov	dl,es:[di+004h]
	cmp	dl,dh
	jl	$L42
	add	di,+004h
	sub	cx,+004h
	jnz	$L40
	jz	$L41
$L37:	mov	dl,es:[di+003h]
	cmp	dl,dh
	jl	$L43
	mov	dl,es:[di+004h]
	cmp	dl,dh
	jl	$L42
	add	di,+004h
	sub	cx,+004h
	jnz	$L40
	jz	$L41
$L36:	mov	dl,es:[di+002h]
	cmp	dl,dh
	jl	$L44
	mov	dl,es:[di+003h]
	cmp	dl,dh
	jl	$L43
	mov	dl,es:[di+004h]
	cmp	dl,dh
	jl	$L42
	add	di,+004h
	sub	cx,+004h
	jnz	$L40
	jz	$L41
$L35:	inc	di
$L48:	or	si,si
	jz	$L45
$L47:	mov	dl,es:[di]
	cmp	dl,dh
	jl	$L46
	inc	di
	dec	si
	jnz	$L47
$L45:	les	di,dword ptr [bp+016h]
	sub	ax,[bp-002h]
	mov	es:[di],ax
	mov	al,dh
	xor	ah,ah
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L44:	mov	dh,dl
	add	di,+002h
	mov	ax,di
	add	si,+002h
	sub	cx,+004h
	jnz	$L40
	jz	$L41
$L43:	mov	dh,dl
	add	di,+003h
	mov	ax,di
	inc	si
	sub	cx,+004h
	jnz	$L40
	jz	$L41
$L42:	mov	dh,dl
	add	di,+004h
	mov	ax,di
	sub	cx,+004h
	jnz	$L40
	jz	$L41
$L46:	mov	dh,dl
	mov	ax,di
	inc	di
	dec	si
	jnz	$L48
	jz	$L45
$L34:	jmp	$L18
$L1:	cmp	word ptr [bp+010h],+000h
	jz	$L49
	mov	dh,[bp+00Ch]
	xor	bh,bh
	mov	cx,si
	and	si,+007h
	and	cx,-008h
	jz	$L50
$L59:	mov	bl,es:[di]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L51
	mov	bl,es:[di+001h]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L52
	mov	bl,es:[di+002h]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L53
	mov	bl,es:[di+003h]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L54
	mov	bl,es:[di+004h]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L55
	mov	bl,es:[di+005h]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L56

	mov	bl,es:[di+006h]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L57
	mov	bl,es:[di+007h]
	mov	al,[bx+$S4]
	cmp	al,dh
	jnle	$L58
	add	di,+008h
	sub	cx,+008h
	jnz	$L59
$L50:	or	si,si
	jz	$L60
$L62:	mov	al,es:[di]
	cmp	al,dh
	jnle	$L61
	inc	di
	dec	si
	jnz	$L62
$L60:	xor	ax,ax
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L51:	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L52:	inc	di
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L53:	add	di,+002h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L54:	add	di,+003h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L55:	add	di,+004h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L56:	add	di,+005h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L57:	add	di,+006h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L58:	add	di,+007h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L61:	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
	jmp	$L18
$L49:	cmp	word ptr [bp+00Eh],+001h
	jnz	$L63
	mov	dh,[bp+00Ch]
	mov	cx,si
	and	si,+007h
	and	cx,-008h
	jz	$L64
$L73:	mov	ax,es:[di]
	cmp	al,dh
	jg	$L65
	cmp	ah,dh
	jg	$L66
	mov	ax,es:[di+002h]
	cmp	al,dh
	jg	$L67
	cmp	ah,dh
	jnle	$L68
	mov	ax,es:[di+004h]
	cmp	al,dh
	jnle	$L69
	cmp	ah,dh
	jnle	$L70
	mov	ax,es:[di+006h]
	cmp	al,dh
	jnle	$L71
	cmp	ah,dh
	jnle	$L72
	add	di,+008h
	sub	cx,+008h
	jnz	$L73
$L64:	or	si,si
	jz	$L74
$L76:	mov	al,es:[di]
	cmp	al,dh
	jnle	$L75
	inc	di
	dec	si
	jnz	$L76
$L74:	xor	ax,ax
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L65:	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L66:	inc	di
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L67:	add	di,+002h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L68:	add	di,+003h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L69:	add	di,+004h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L70:	add	di,+005h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L71:	add	di,+006h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L72:	add	di,+007h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L75:	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
	jmp	$L18
$L63:	mov	dh,[bp+00Ch]
	mov	cx,si
	and	si,+007h
	and	cx,-008h
	jz	$L77
$L86:	mov	ax,es:[di]
	cmp	al,dh
	jl	$L78
	cmp	ah,dh
	jl	$L79
	mov	ax,es:[di+002h]
	cmp	al,dh
	jl	$L80
	cmp	ah,dh
	jl	$L81
	mov	ax,es:[di+004h]
	cmp	al,dh
	jl	$L82
	cmp	ah,dh
	jl	$L83
	mov	ax,es:[di+006h]
	cmp	al,dh
	jl	$L84
	cmp	ah,dh
	jl	$L85
	add	di,+008h
	sub	cx,+008h
	jnz	$L86
$L77:	or	si,si
	jz	$L87
$L89:	mov	al,es:[di]
	cmp	al,dh
	jl	$L88
	inc	di
	dec	si
	jnz	$L89
$L87:	xor	ax,ax
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L78:	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L79:	inc	di
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L80:	add	di,+002h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L81:	add	di,+003h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L82:	add	di,+004h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L83:	add	di,+005h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L84:	add	di,+006h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L85:	add	di,+007h
	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L88:	sub	di,[bp-002h]
	les	bx,dword ptr [bp+016h]
	mov	es:[bx],di
	mov	ax,0001h
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf
$L18:	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	mov	sp,bp
	pop	bp
	retf

FPPKFIND_TEXT	ENDS
	END
