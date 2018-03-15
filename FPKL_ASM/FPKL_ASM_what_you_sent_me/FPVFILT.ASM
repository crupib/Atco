; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fpvfilt.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
FPVFILT_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
FPVFILT_TEXT	ENDS
DGROUP	GROUP	_DATA
; [007E]	; Linker - Pass two marker


	PUBLIC		_fp_video_filter	; Located at 3:0000h Type = 1

_DATA	SEGMENT

$S1	db	000h
	db	002h
	db	004h
	db	006h
	db	008h
	db	00Ah
	db	00Ch
	db	00Eh
	db	010h
	db	012h
	db	014h
	db	016h
	db	018h
	db	01Ah
	db	01Ch
	db	01Eh
	db	' "$'
	db	'&(*,.02468:<>@BDFHJLNPRTVXZ\^`bdfhjlnprtvxz|~'
	db	080h
	db	082h
	db	084h
	db	086h
	db	088h
	db	08Ah
	db	08Ch
	db	08Eh
	db	090h
	db	092h
	db	094h
	db	096h
	db	098h
	db	09Ah
	db	09Ch
	db	09Eh
	db	0A0h
	db	0A2h
	db	0A4h
	db	0A6h
	db	0A8h
	db	0AAh
	db	0ACh
	db	0AEh
	db	0B0h
	db	0B2h
	db	0B4h
	db	0B6h
	db	0B8h
	db	0BAh
	db	0BCh
	db	0BEh
	db	0C0h
	db	0C2h
	db	0C4h
	db	0C6h
	db	0C8h
	db	0CAh
	db	0CCh
	db	0CEh
	db	0D0h
	db	0D2h
	db	0D4h
	db	0D6h
	db	0D8h
	db	0DAh
	db	0DCh
	db	0DEh
	db	0E0h
	db	0E2h
	db	0E4h
	db	0E6h
	db	0E8h
	db	0EAh
	db	0ECh
	db	0EEh
	db	0F0h
	db	0F2h
	db	0F4h
	db	0F6h
	db	0F8h
	db	0FAh
	db	0FCh
	db	0FEh
	db	0FEh
	db	0FEh
	db	0FCh
	db	0FAh
	db	0F8h
	db	0F6h
	db	0F4h
	db	0F2h
	db	0F0h
	db	0EEh
	db	0ECh
	db	0EAh
	db	0E8h
	db	0E6h
	db	0E4h
	db	0E2h
	db	0E0h
	db	0DEh
	db	0DCh
	db	0DAh
	db	0D8h
	db	0D6h
	db	0D4h
	db	0D2h
	db	0D0h
	db	0CEh
	db	0CCh
	db	0CAh
	db	0C8h
	db	0C6h
	db	0C4h
	db	0C2h
	db	0C0h
	db	0BEh
	db	0BCh
	db	0BAh
	db	0B8h
	db	0B6h
	db	0B4h
	db	0B2h
	db	0B0h
	db	0AEh
	db	0ACh
	db	0AAh
	db	0A8h
	db	0A6h
	db	0A4h
	db	0A2h
	db	0A0h
	db	09Eh
	db	09Ch
	db	09Ah
	db	098h
	db	096h
	db	094h
	db	092h
	db	090h
	db	08Eh
	db	08Ch
	db	08Ah
	db	088h
	db	086h
	db	084h
	db	082h
	db	080h
	db	'~|zxvtrpnljhfdb`^\ZXVTRPNLJHFDB@><:86420.,*(&$'
	db	'" '
	db	01Eh
	db	01Ch
	db	01Ah
	db	018h
	db	016h
	db	014h
	db	012h
	db	010h
	db	00Eh
	db	00Ch
	db	00Ah
	db	008h
	db	006h
	db	004h
	db	002h

_DATA	ENDS
FPVFILT_TEXT	SEGMENT
	assume	cs: FPVFILT_TEXT


_fp_video_filter:
	push	bp
	mov	bp,sp
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	push	bx
	push	cx
	push	dx
	push	es
	push	fs
	push	si
	push	di
	les	si,dword ptr [bp+006h]
	lfs	di,dword ptr [bp+00Ah]
	mov	cx,[bp+00Eh]
	dec	cx
	xor	bh,bh
	mov	bl,es:[si]
	inc	si
	assume	ds: DGROUP
	mov	ah,[bx+$S1]
	xor	al,al
	mov	fs:[di],ah
	inc	di
	mul	word ptr [bp+010h]
$L3:	mov	bl,es:[si]
	inc	si
	mov	ah,[bx+$S1]
	xor	al,al
	cmp	ah,dh
	jnc	$L2
	mov	ax,dx
$L2:	mov	fs:[di],ah
	inc	di
	mul	word ptr [bp+010h]
	dec	cx
	jnz	$L3
	pop	di
	pop	si
	pop	fs
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ds
	pop	bp
	retf

FPVFILT_TEXT	ENDS
	END
