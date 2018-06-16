; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	linplt.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [00F6]	; Linker - Pass two marker

	EXTRN		_nucol:WORD
	EXTRN		_vm:ABS
	EXTRN		_vidseg:WORD
	EXTRN		_video:WORD
	PUBLIC		_linpl1			; Located at 2:0000h Type = 1
	PUBLIC		_linpl2			; Located at 2:0079h Type = 1
	PUBLIC		_linpl4			; Located at 2:011Fh Type = 1
	PUBLIC		_linpl8			; Located at 2:01C9h Type = 1
	PUBLIC		_linpla			; Located at 2:024Dh Type = 1
	PUBLIC		_linplc			; Located at 2:02D2h Type = 1
	PUBLIC		_colrln			; Located at 2:035Dh Type = 1
	PUBLIC		_fgln			; Located at 2:03D0h Type = 1
	PUBLIC		_vlnplt			; Located at 2:0433h Type = 1
	PUBLIC		_vlnpl2			; Located at 2:0497h Type = 1
	PUBLIC		_vlnpl4			; Located at 2:0503h Type = 1
	PUBLIC		_vlnpl8			; Located at 2:057Fh Type = 1

_data	SEGMENT

$S2	db	080h
	db	040h
	db	020h
	db	010h
	db	008h
	db	004h
	db	002h
	db	001h
	db	001h
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
$S26	db	0C0h
	db	0C0h
	db	030h
	db	030h
	db	00Ch
	db	00Ch
	db	003h
	db	003h
	db	001h
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
	db	0F0h
	db	0F0h
	db	0F0h
	db	0F0h
	db	00Fh
	db	00Fh
	db	00Fh
	db	00Fh
	db	001h
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
$S5	dw	00000h
$S1	dw	00000h
$S3	dw	00000h

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_linpl1:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+006h]
	assume	ds: DGROUP
	mov	$S1,bx
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	cx,[bp+00Ah]
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0205h
	out	dx,ax
	mov	dx,03CEh
	mov	al,08h
	mov	ah,[bx+$S2]
	out	dx,ax
	mov	word ptr $S3,es
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Eh]
	mov	bp,bx
$L4:	mov	al,08h
	out	dx,ax
	lodsb
	mov	bh,es:[di]
	mov	es:[di],al
	ror	ah,1
	inc	bp
	test	bp,0007h
	loopnz	$L4
	inc	di
	inc	cx
	loop	$L4
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	mov	ax,0FF08h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_linpl2:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,_nucol
	mov	[bp-002h],ax
	mov	bx,[bp+00Ch]
	dec	bx
	mov	[bp-006h],bx
	mul	bl
	mov	[bp-004h],ax
	mov	word ptr [bp-008h],0000h
	mov	bx,[bp+006h]
	mov	$S1,bx
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	cx,[bp+00Ah]
	mov	word ptr $S5,0000h
	mov	dx,03CEh
	mov	ax,1003h
	out	dx,ax
	mov	ax,0005h
	out	dx,ax
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	les	si,dword ptr [bp+00Eh]
	mov	word ptr $S3,es
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Eh]
	mov	ah,0C0h
$L7:	lodsb
	out	dx,al
	push	cx
	sub	di,[bp-004h]
	mov	cx,[bp-006h]
$L6:	mov	al,es:[di]
	mov	es:[di],ah
	add	di,[bp-002h]
	loop	$L6
	pop	cx
	mov	al,es:[di]
	mov	es:[di],ah
	ror	ah,1
	ror	ah,1
	add	word ptr [bp-008h],+002h
	test	word ptr [bp-008h],0007h
	loopnz	$L7
	inc	cx
	inc	di
	loop	$L7
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_linpl4:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,_nucol
	mov	[bp-002h],ax
	mov	bx,[bp+00Ch]
	dec	bx
	mov	[bp-006h],bx
	mul	bl
	mov	[bp-004h],ax
	mov	word ptr [bp-008h],0000h
	mov	bx,[bp+006h]
	mov	$S1,bx
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	cx,[bp+00Ah]
	mov	word ptr $S5,0000h
	mov	dx,03CEh
	mov	ax,1003h
	out	dx,ax
	mov	ax,0005h
	out	dx,ax
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	les	si,dword ptr [bp+00Eh]
	mov	word ptr $S3,es
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Eh]
	mov	ah,0F0h
$L9:	lodsb
	out	dx,al
	push	cx
	sub	di,[bp-004h]
	mov	cx,[bp-006h]
$L8:	mov	al,es:[di]
	mov	es:[di],ah
	add	di,[bp-002h]
	loop	$L8
	pop	cx
	mov	al,es:[di]
	mov	es:[di],ah
	ror	ah,1
	ror	ah,1
	ror	ah,1
	ror	ah,1
	add	word ptr [bp-008h],+004h
	test	word ptr [bp-008h],0007h
	loopnz	$L9
	inc	cx
	inc	di
	loop	$L9
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_linpl8:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	cld
	mov	ax,_nucol
	mov	[bp-002h],ax
	mov	bx,[bp+00Ch]
	dec	bx
	mov	[bp-006h],bx
	mul	bl
	mov	[bp-004h],ax
	mov	bx,[bp+006h]
	mov	$S1,bx
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	cx,[bp+00Ah]
	mov	word ptr $S5,0000h
	mov	dx,03CEh
	mov	ax,0FE08h
	out	dx,ax
	mov	ax,0205h
	out	dx,ax
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Eh]
	mov	ah,byte ptr es:[0FFFEh]
$L11:	lodsb
	push	cx
	sub	di,[bp-004h]
	mov	cx,[bp-006h]
$L10:	mov	es:[di],al
	add	di,[bp-002h]
	loop	$L10
	pop	cx
	sub	al,al
	stosb
	loop	$L11
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_linpla:
	push	bp
	mov	bp,sp
	sub	sp,+010h
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,_nucol
	mov	[bp-002h],ax
	mov	bx,[bp+006h]
	mov	$S1,bx
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	cx,[bp+00Ah]
	mov	word ptr $S5,0000h
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	mov	word ptr $S3,es
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+010h]
	mov	bx,0000h
	mov	ah,80h
$L15:	lodsb
	out	dx,al
	push	cx
	mov	cx,[bp+00Ch]
$L14:	push	cx
	push	di
	mov	cx,[bp+00Eh]
$L12:	mov	al,es:[di]
	mov	es:[di],ah
	sub	di,[bp-002h]
	loop	$L12
	pop	di
	pop	cx
	ror	ah,1
	inc	bx
	and	bx,+007h
	cmp	bx,+000h
	jnz	$L13
	inc	di
$L13:	loop	$L14
	pop	cx
	loop	$L15
	pop	es
	pop	ds
	pop	si
	pop	di
	mov	sp,bp
	pop	bp
	retf
_linplc:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+006h]
	mov	$S1,bx
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	cx,[bp+00Ah]
	mov	word ptr $S5,0000h
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	mov	word ptr $S3,es
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+010h]
	mov	bx,0000h
	mov	ah,80h
$L21:	push	ax
	mov	ah,00h
	push	cx
	mov	cx,[bp+00Ch]
$L17:	lodsb
	cmp	al,ah
	jc	$L16
	mov	ah,al
$L16:	loop	$L17
	pop	cx
	pop	ax
	out	dx,al
	push	cx
	mov	cx,[bp+00Ch]
$L20:	push	cx
	push	di
	mov	cx,[bp+00Eh]
$L18:	mov	al,es:[di]
	mov	es:[di],ah
	sub	di,+050h
	loop	$L18
	pop	di
	pop	cx
	ror	ah,1
	inc	bx
	and	bx,+007h
	cmp	bx,+000h
	jnz	$L19
	inc	di
$L19:	loop	$L20
	pop	cx
	loop	$L21
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_colrln:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,03CEh
	mov	al,03h
	out	dx,al
	mov	dx,03CFh
	mov	al,00h
	out	dx,al
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03CEh
	mov	al,08h
	out	dx,al
	mov	dx,03CFh
	mov	al,0FFh
	out	dx,al
	cld
	mov	bx,[bp+006h]
	mov	$S1,bx
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	cx,[bp+00Ah]
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Eh]
	push	cx
	push	di
	mov	al,00h
	repz	stosb
	pop	di
	pop	cx
	mov	dx,03C5h
	mov	ax,[bp+00Ch]
	out	dx,al
	mov	al,[bp+00Eh]
	repz	stosb
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_fgln:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	cld
	mov	ax,[bp+006h]
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	mov	es,word ptr _vidseg
	mov	dx,03C4h

	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	mov	ax,[bp+00Ch]
	out	dx,al
	mov	dx,03CEh
	mov	al,08h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+00Eh]
	cmp	al,00h
	jz	$L22
	out	dx,al
	mov	cx,[bp+00Ah]
	cmp	al,00h
	jz	$L23
	mov	al,[bp+00Eh]
$L24:	mov	ah,es:[di]
	mov	es:[di],al
	inc	di
	loop	$L24
	jmp	short $L22
$L23:	mov	al,[bp+00Eh]
	repz	stosb
$L22:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vlnplt:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+006h]
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	al,08h
	mov	ah,[bx+$S2]
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0205h
	out	dx,ax
	mov	cx,[bp+00Ah]
	mov	bx,_nucol
	cld
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Ch]
$L25:	lodsb
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	loop	$L25
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vlnpl2:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+006h]
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	al,08h
	mov	ah,[bx+$S26]
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0205h
	out	dx,ax
	mov	cx,[bp+00Ah]
	mov	bx,_nucol
	cld
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Ch]
$L27:	lodsb
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	loop	$L27
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vlnpl4:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+006h]
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	al,08h
	mov	ah,[bx+$S2 - 07FD0h[MULTIPLE FIXUP]]
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0205h
	out	dx,ax
	mov	cx,[bp+00Ah]
	mov	bx,_nucol
	cld
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Ch]
$L28:	lodsb
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	loop	$L28
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vlnpl8:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+006h]
	mov	di,[bp+008h]
	shl	di,1
	mov	di,[di+_video]
	mov	ax,bx
	sar	ax,1
	sar	ax,1
	sar	ax,1
	add	di,ax
	and	bx,+007h
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	al,08h
	mov	ah,0FFh
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0205h
	out	dx,ax
	mov	cx,[bp+00Ah]
	mov	bx,_nucol
	cld
	mov	es,word ptr _vidseg
	lds	si,dword ptr [bp+00Ch]
$L29:	lodsb
	mov	ah,es:[di]
	mov	es:[di],al
	add	di,bx
	mov	es:[di],al
	add	di,bx
	mov	es:[di],al
	add	di,bx
	mov	es:[di],al
	add	di,bx
	mov	es:[di],al
	add	di,bx
	mov	es:[di],al
	add	di,bx
	mov	es:[di],al
	add	di,bx
	mov	es:[di],al
	add	di,bx
	loop	$L29
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

_text	ENDS
	END
