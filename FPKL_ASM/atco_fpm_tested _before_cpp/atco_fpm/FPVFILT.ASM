; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fpvfilt.asm
	.586
	.MODEL flat, c
	
.data
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

.code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;extern void fp_video_filter(unsigned char * ibuff, unsigned char * obuff,
;					    int buflen,  unsigned int filter);
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fp_video_filter_asm proc ibuff:dword, obuff:dword,  buflen:word, filter:word
	mov	esi,ibuff
	mov	edi,obuff
	mov	cx,buflen
	dec	cx
	xor	ebx,ebx
	mov	bl,[esi]
	inc	esi
	mov	ah,[ebx+$S1]
	xor	al,al
	mov	[edi],ah
	inc	edi
	mul	word ptr filter
$L3:	
	mov	bl,[esi]
	inc	esi
	mov	ah,[ebx+$S1]
	xor	al,al
	cmp	ah,dh
	jnc	$L2
	mov	ax,dx
$L2:
	mov	[edi],ah
	inc	edi
	mul	word ptr filter
	dec	cx
	jnz	$L3
	ret

fp_video_filter_asm endp
	END
