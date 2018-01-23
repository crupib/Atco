; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fpxfer.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
FPXFER_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
FPXFER_TEXT	ENDS
DGROUP	GROUP	_DATA
; [00A3]	; Linker - Pass two marker


	PUBLIC		_fp_xfer32_align_source	; Located at 3:0000h Type = 1
	PUBLIC		_fp_xfer32_align_source_lace
						; Located at 3:004Bh Type = 1

_DATA	SEGMENT

$S8	dw	00000h
	db	000h
	db	000h
	dw	FPXFER_TEXT:$S1
	db	000h
	db	000h
	dw	FPXFER_TEXT:$S2
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	dw	FPXFER_TEXT:$S3
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	dw	FPXFER_TEXT:$S4
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	db	000h
	dw	FPXFER_TEXT:$S5

_DATA	ENDS
FPXFER_TEXT	SEGMENT
	assume	cs: FPXFER_TEXT


_fp_xfer32_align_source:
	push	bp
	mov	bp,sp
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	push	dx
	push	di
	push	si
	push	es
	cld
	mov	dx,[bp+00Eh]
	les	di,dword ptr [bp+006h]
	lds	si,dword ptr [bp+00Ah]
	mov	cx,si
	and	cx,+003h
	jz	$L6
	sub	cx,+004h
	neg	cx
	sub	dx,cx
	jc	$L7
	repz	movsb
$L6:	mov	cx,dx
	shr	cx,02h
	repz	movsd
	mov	cx,dx
	and	cx,+003h
	repz	movsb
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$L7:	mov	cx,[bp+00Eh]
	repz	movsb
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
_fp_xfer32_align_source_lace:
	push	bp
	mov	bp,sp
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	push	dx
	push	di
	push	si
	push	es
	mov	dx,[bp+00Eh]
	les	di,dword ptr [bp+006h]
	lds	si,dword ptr [bp+00Ah]
	mov	bx,[bp+010h]
	assume	ds: DGROUP
	jmp	[bx+$S8]
$S1:	mov	cx,si
	and	cx,+003h
	jz	$L9
	sub	cx,+004h
	neg	cx
	sub	dx,cx
	jb	$L10
$L11:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+002h
	dec	cx
	jnz	$L11
$L9:	mov	cx,dx
	shr	cx,05h
	jz	$L12
$L13:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+002h],ah
	shr	eax,10h
	mov	es:[di+004h],al
	mov	es:[di+006h],ah
	mov	eax,[si+004h]
	mov	es:[di+008h],al
	mov	es:[di+00Ah],ah
	shr	eax,10h
	mov	es:[di+00Ch],al
	mov	es:[di+00Eh],ah
	mov	eax,[si+008h]
	mov	es:[di+010h],al
	mov	es:[di+012h],ah
	shr	eax,10h
	mov	es:[di+014h],al
	mov	es:[di+016h],ah
	mov	eax,[si+00Ch]
	mov	es:[di+018h],al
	mov	es:[di+01Ah],ah
	shr	eax,10h
	mov	es:[di+01Ch],al
	mov	es:[di+01Eh],ah
	mov	eax,[si+010h]
	mov	es:[di+020h],al
	mov	es:[di+022h],ah
	shr	eax,10h
	mov	es:[di+024h],al
	mov	es:[di+026h],ah
	mov	eax,[si+014h]
	mov	es:[di+028h],al
	mov	es:[di+02Ah],ah
	shr	eax,10h
	mov	es:[di+02Ch],al
	mov	es:[di+02Eh],ah
	mov	eax,[si+018h]
	mov	es:[di+030h],al
	mov	es:[di+032h],ah
	shr	eax,10h
	mov	es:[di+034h],al
	mov	es:[di+036h],ah
	mov	eax,[si+01Ch]
	mov	es:[di+038h],al
	mov	es:[di+03Ah],ah
	shr	eax,10h
	mov	es:[di+03Ch],al
	mov	es:[di+03Eh],ah
	add	si,+020h
	add	di,+040h
	dec	cx
	jnz	$L13
$L12:	mov	cx,dx
	and	cx,+01Fh
	shr	cx,02h
	jz	$L14
$L15:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+002h],ah
	shr	eax,10h
	mov	es:[di+004h],al
	mov	es:[di+006h],ah
	add	si,+004h
	add	di,+008h
	dec	cx
	jnz	$L15
$L14:	mov	cx,dx
	and	cx,+003h
	jz	$L16
$L17:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+002h
	dec	dx
	jnz	$L17
$L16:	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$L10:	add	dx,cx
$L18:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+002h
	dec	dx
	jnz	$L18
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$S2:	mov	cx,si
	and	cx,+003h
	jz	$L19
	sub	cx,+004h
	neg	cx
	sub	dx,cx
	jb	$L20
$L21:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+004h
	dec	cx
	jnz	$L21
$L19:	mov	cx,dx
	shr	cx,05h
	jz	$L22
$L23:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+004h],ah
	shr	eax,10h
	mov	es:[di+008h],al
	mov	es:[di+00Ch],ah
	mov	eax,[si+004h]
	mov	es:[di+010h],al
	mov	es:[di+014h],ah
	shr	eax,10h
	mov	es:[di+018h],al
	mov	es:[di+01Ch],ah
	mov	eax,[si+008h]
	mov	es:[di+020h],al
	mov	es:[di+024h],ah
	shr	eax,10h
	mov	es:[di+028h],al
	mov	es:[di+02Ch],ah
	mov	eax,[si+00Ch]
	mov	es:[di+030h],al
	mov	es:[di+034h],ah
	shr	eax,10h
	mov	es:[di+038h],al
	mov	es:[di+03Ch],ah
	mov	eax,[si+010h]
	mov	es:[di+040h],al
	mov	es:[di+044h],ah
	shr	eax,10h
	mov	es:[di+048h],al
	mov	es:[di+04Ch],ah
	mov	eax,[si+014h]
	mov	es:[di+050h],al
	mov	es:[di+054h],ah
	shr	eax,10h
	mov	es:[di+058h],al
	mov	es:[di+05Ch],ah
	mov	eax,[si+018h]
	mov	es:[di+060h],al
	mov	es:[di+064h],ah
	shr	eax,10h
	mov	es:[di+068h],al
	mov	es:[di+06Ch],ah
	mov	eax,[si+01Ch]
	mov	es:[di+070h],al
	mov	es:[di+074h],ah
	shr	eax,10h
	mov	es:[di+078h],al
	mov	es:[di+07Ch],ah
	add	si,+020h
	add	di,0080h
	dec	cx
	jnz	$L23
$L22:	mov	cx,dx
	and	cx,+01Fh
	shr	cx,02h
	jz	$L24
$L25:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+004h],ah
	shr	eax,10h
	mov	es:[di+008h],al
	mov	es:[di+00Ch],ah
	add	si,+004h
	add	di,+010h
	dec	cx
	jnz	$L25
$L24:	mov	cx,dx
	and	cx,+003h
	jz	$L26
$L27:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+004h
	dec	dx
	jnz	$L27
$L26:	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$L20:	add	dx,cx
$L28:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+004h
	dec	dx
	jnz	$L28
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$S3:	mov	cx,si
	and	cx,+003h
	jz	$L29
	sub	cx,+004h
	neg	cx
	sub	dx,cx
	jb	$L30
$L31:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+008h
	dec	cx
	jnz	$L31
$L29:	mov	cx,dx
	shr	cx,05h
	jz	$L32
$L33:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+008h],ah
	shr	eax,10h
	mov	es:[di+010h],al
	mov	es:[di+018h],ah
	mov	eax,[si+004h]
	mov	es:[di+020h],al
	mov	es:[di+028h],ah
	shr	eax,10h
	mov	es:[di+030h],al
	mov	es:[di+038h],ah
	mov	eax,[si+008h]
	mov	es:[di+040h],al
	mov	es:[di+048h],ah
	shr	eax,10h
	mov	es:[di+050h],al
	mov	es:[di+058h],ah
	mov	eax,[si+00Ch]
	mov	es:[di+060h],al
	mov	es:[di+068h],ah
	shr	eax,10h
	mov	es:[di+070h],al
	mov	es:[di+078h],ah
	mov	eax,[si+010h]
	mov	es:[di+0080h],al
	mov	es:[di+0088h],ah
	shr	eax,10h
	mov	es:[di+0090h],al
	mov	es:[di+0098h],ah
	mov	eax,[si+014h]
	mov	es:[di+00A0h],al
	mov	es:[di+00A8h],ah
	shr	eax,10h
	mov	es:[di+00B0h],al
	mov	es:[di+00B8h],ah
	mov	eax,[si+018h]
	mov	es:[di+00C0h],al
	mov	es:[di+00C8h],ah
	shr	eax,10h
	mov	es:[di+00D0h],al
	mov	es:[di+00D8h],ah
	mov	eax,[si+01Ch]
	mov	es:[di+00E0h],al
	mov	es:[di+00E8h],ah
	shr	eax,10h
	mov	es:[di+00F0h],al
	mov	es:[di+00F8h],ah
	add	si,+020h
	add	di,0100h
	dec	cx

	jnz	$L33
$L32:	mov	cx,dx
	and	cx,+01Fh
	shr	cx,02h
	jz	$L34
$L35:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+008h],ah
	shr	eax,10h
	mov	es:[di+010h],al
	mov	es:[di+018h],ah
	add	si,+004h
	add	di,+020h
	dec	cx
	jnz	$L35
$L34:	mov	cx,dx
	and	cx,+003h
	jz	$L36
$L37:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+008h
	dec	dx
	jnz	$L37
$L36:	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$L30:	add	dx,cx
$L38:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+008h
	dec	dx
	jnz	$L38
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$S4:	mov	cx,si
	and	cx,+003h
	jz	$L39
	sub	cx,+004h
	neg	cx
	sub	dx,cx
	jb	$L40
$L41:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+010h
	dec	cx
	jnz	$L41
$L39:	mov	cx,dx
	shr	cx,05h
	jz	$L42
$L43:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+010h],ah
	shr	eax,10h
	mov	es:[di+020h],al
	mov	es:[di+030h],ah
	mov	eax,[si+004h]
	mov	es:[di+040h],al
	mov	es:[di+050h],ah
	shr	eax,10h
	mov	es:[di+060h],al
	mov	es:[di+070h],ah
	mov	eax,[si+008h]
	mov	es:[di+0080h],al
	mov	es:[di+0090h],ah
	shr	eax,10h
	mov	es:[di+00A0h],al
	mov	es:[di+00B0h],ah
	mov	eax,[si+00Ch]
	mov	es:[di+00C0h],al
	mov	es:[di+00D0h],ah
	shr	eax,10h
	mov	es:[di+00E0h],al
	mov	es:[di+00F0h],ah
	mov	eax,[si+010h]
	mov	es:[di+0100h],al
	mov	es:[di+0110h],ah
	shr	eax,10h
	mov	es:[di+0120h],al
	mov	es:[di+0130h],ah
	mov	eax,[si+014h]
	mov	es:[di+0140h],al
	mov	es:[di+0150h],ah
	shr	eax,10h
	mov	es:[di+0160h],al
	mov	es:[di+0170h],ah
	mov	eax,[si+018h]
	mov	es:[di+0180h],al
	mov	es:[di+0190h],ah
	shr	eax,10h
	mov	es:[di+01A0h],al
	mov	es:[di+01B0h],ah
	mov	eax,[si+01Ch]
	mov	es:[di+01C0h],al
	mov	es:[di+01D0h],ah
	shr	eax,10h
	mov	es:[di+01E0h],al
	mov	es:[di+01F0h],ah
	add	si,+020h
	add	di,0200h
	dec	cx
	jnz	$L43
$L42:	mov	cx,dx
	and	cx,+01Fh
	shr	cx,02h
	jz	$L44
$L45:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+010h],ah
	shr	eax,10h
	mov	es:[di+020h],al
	mov	es:[di+030h],ah
	add	si,+004h
	add	di,+040h
	dec	cx
	jnz	$L45
$L44:	mov	cx,dx
	and	cx,+003h
	jz	$L46
$L47:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+010h
	dec	dx
	jnz	$L47
$L46:	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$L40:	add	dx,cx
$L48:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+010h
	dec	dx
	jnz	$L48
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$S5:	mov	cx,si
	and	cx,+003h
	jz	$L49
	sub	cx,+004h
	neg	cx
	sub	dx,cx
	jb	$L50
$L51:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+020h
	dec	cx
	jnz	$L51
$L49:	mov	cx,dx
	shr	cx,05h
	jz	$L52
$L53:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+020h],ah
	shr	eax,10h
	mov	es:[di+040h],al
	mov	es:[di+060h],ah
	mov	eax,[si+004h]
	mov	es:[di+0080h],al
	mov	es:[di+00A0h],ah
	shr	eax,10h
	mov	es:[di+00C0h],al
	mov	es:[di+00E0h],ah
	mov	eax,[si+008h]
	mov	es:[di+0100h],al
	mov	es:[di+0120h],ah
	shr	eax,10h
	mov	es:[di+0140h],al
	mov	es:[di+0160h],ah
	mov	eax,[si+00Ch]
	mov	es:[di+0180h],al
	mov	es:[di+01A0h],ah
	shr	eax,10h
	mov	es:[di+01C0h],al
	mov	es:[di+01E0h],ah
	mov	eax,[si+010h]
	mov	es:[di+0200h],al
	mov	es:[di+0220h],ah
	shr	eax,10h
	mov	es:[di+0240h],al
	mov	es:[di+0260h],ah
	mov	eax,[si+014h]
	mov	es:[di+0280h],al
	mov	es:[di+02A0h],ah
	shr	eax,10h
	mov	es:[di+02C0h],al
	mov	es:[di+02E0h],ah
	mov	eax,[si+018h]
	mov	es:[di+0300h],al
	mov	es:[di+0320h],ah
	shr	eax,10h
	mov	es:[di+0340h],al
	mov	es:[di+0360h],ah
	mov	eax,[si+01Ch]
	mov	es:[di+0380h],al
	mov	es:[di+03A0h],ah
	shr	eax,10h
	mov	es:[di+03C0h],al
	mov	es:[di+03E0h],ah
	add	si,+020h
	add	di,0400h
	dec	cx
	jnz	$L53
$L52:	mov	cx,dx
	and	cx,+01Fh
	shr	cx,02h
	jz	$L54
$L55:	mov	eax,[si]
	mov	es:[di],al
	mov	es:[di+020h],ah
	shr	eax,10h
	mov	es:[di+040h],al
	mov	es:[di+060h],ah
	add	si,+004h
	add	di,0080h
	dec	cx
	jnz	$L55
$L54:	mov	cx,dx
	and	cx,+003h
	jz	$L56
$L57:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+020h
	dec	dx
	jnz	$L57
$L56:	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf
$L50:	add	dx,cx
$L58:	mov	al,[si]
	inc	si
	mov	es:[di],al
	add	di,+020h
	dec	dx
	jnz	$L58
	pop	es
	pop	si
	pop	di
	pop	dx
	pop	ds
	pop	bp
	retf

FPXFER_TEXT	ENDS
	END
