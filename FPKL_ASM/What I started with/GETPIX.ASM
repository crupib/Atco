; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	getpix.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [00D4]	; Linker - Pass two marker

	EXTRN		_video:WORD
	PUBLIC		_getpix			; Located at 2:0000h Type = 1
	PUBLIC		_getpix2		; Located at 2:0087h Type = 1
	PUBLIC		_getpixh		; Located at 2:00D9h Type = 1
	PUBLIC		_getpixv		; Located at 2:0116h Type = 1
	PUBLIC		_prnbufa		; Located at 2:0172h Type = 1
	PUBLIC		_vpwrite		; Located at 2:0196h Type = 1
	PUBLIC		_vpread			; Located at 2:01D1h Type = 1
	PUBLIC		_vgaread		; Located at 2:0208h Type = 1
	PUBLIC		_vgawrite		; Located at 2:0252h Type = 1
	PUBLIC		_getvga			; Located at 2:0298h Type = 1

_data	SEGMENT

$S1	db	080h
	db	040h
	db	020h
	db	010h
	db	008h
	db	004h
	db	002h
	db	001h
	db	007h
	db	006h
	db	005h
	db	004h
	db	003h
	db	002h
	db	001h
	db	000h
	db	008h
	db	004h
	db	002h
	db	001h
	db	001h
	db	002h
	db	004h
	db	008h

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_getpix:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,0A000h
	mov	es,ax
	mov	bx,[bp+006h]
	mov	ax,[bp+008h]
	shl	bx,1
	assume	ds: DGROUP
	mov	bx,[bx+_video]
	add	bx,ax
	mov	dx,03CEh
	mov	al,04h
	out	dx,al
	mov	al,00h
	mov	dx,03CFh
	out	dx,al
	mov	cl,es:[bx]
	mov	al,01h
	out	dx,al
	mov	ch,es:[bx]
	push	cx
	mov	al,02h
	out	dx,al
	mov	cl,es:[bx]
	mov	al,03h
	out	dx,al
	mov	ch,es:[bx]
	push	cx
	mov	ax,seg DGROUP
	mov	ds,ax
	les	si,dword ptr [bp+00Ah]
	mov	bx,0000h
	mov	cx,0008h
	pop	dx
	pop	ax
$L6:	mov	byte ptr es:[bx+si],00h
	test	al,[bx+$S1]
	jz	$L2
	add	byte ptr es:[bx+si],01h
$L2:	test	ah,[bx+$S1]
	jz	$L3
	add	byte ptr es:[bx+si],02h
$L3:	test	dl,[bx+$S1]
	jz	$L4
	add	byte ptr es:[bx+si],04h
$L4:	test	dh,[bx+$S1]
	jz	$L5
	add	byte ptr es:[bx+si],08h
$L5:	inc	bx
	loop	$L6
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_getpix2:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,0A000h
	mov	es,ax
	mov	bx,[bp+006h]
	mov	ax,[bp+008h]
	shl	bx,1
	mov	bx,[bx+_video]
	add	bx,ax
	mov	dx,03CEh
	mov	al,04h
	out	dx,al
	mov	al,00h
	mov	dx,03CFh
	out	dx,al
	mov	cl,es:[bx]
	mov	al,01h
	out	dx,al
	mov	ch,es:[bx]
	push	cx
	mov	al,02h
	out	dx,al
	mov	cl,es:[bx]
	mov	al,03h
	out	dx,al
	mov	ch,es:[bx]
	pop	ax
	les	bx,dword ptr [bp+00Ah]
	mov	es:[bx],ax
	mov	es:[bx+002h],cx
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_getpixh:
	push	bp
	mov	bp,sp
	push	cx
	push	dx
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	si,[bp+006h]
	mov	ax,[bp+008h]
	shl	si,1
	mov	si,[si+_video]
	add	si,ax
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+00Ah]
	sar	cx,1
	mov	ax,0A000h
	mov	ds,ax
	mov	dx,03CEh
	mov	al,04h
	mov	ah,[bp+00Ch]
	out	dx,ax
	cld
	repz	movsw
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bp
	retf
_getpixv:
	push	bp
	mov	bp,sp
	push	cx
	push	dx
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+006h]
	mov	si,[bp+008h]
	shl	si,1
	mov	si,[si+_video]
	mov	ax,bx
	mov	cl,03h
	sar	ax,cl
	add	si,ax
	and	bx,+007h
	mov	ah,[bx+$S1]
	push	ax
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+00Ah]
	mov	bx,0A000h
	mov	ds,bx
	mov	dx,03CEh
	mov	al,04h
	mov	ah,[bp+00Ch]
	out	dx,ax
	mov	bl,80h
	pop	ax
$L9:	mov	al,[si]
	test	al,ah
	jz	$L7
	or	es:[di],bl
$L7:	ror	bl,1
	jnc	$L8
	inc	di
$L8:	sub	si,+064h
	loop	$L9
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	dx
	pop	cx
	pop	bp
	retf
_prnbufa:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	cx,[bp+00Ah]
	lds	si,dword ptr [bp+006h]
$L11:	sub	ah,ah
	lodsb
	int	17h
	cmp	ah,01h
	jz	$L10
	loop	$L11
$L10:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vpwrite:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,0A000h
	mov	es,ax
	mov	dx,03C4h
	mov	cl,[bp+006h]
	mov	ah,01h
	shl	ah,cl
	mov	al,02h
	out	dx,ax
	mov	cx,[bp+00Ch]
	mov	bx,[bp+008h]
	mov	ax,[bp+00Ah]
	shl	bx,1
	mov	di,[bx+_video]
	add	di,ax
	lds	si,dword ptr [bp+00Eh]
	cld
	repz	movsb
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vpread:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+00Ch]
	mov	dx,03CEh
	mov	al,04h
	mov	ah,[bp+006h]
	out	dx,ax
	mov	bx,[bp+008h]
	mov	ax,[bp+00Ah]
	shl	bx,1
	mov	si,[bx+_video]
	add	si,ax
	mov	ax,0A000h
	mov	ds,ax
	cld
	repz	movsb
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vgaread:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,0A000h
	mov	es,ax
	mov	di,[bp+00Ch]
	mov	cx,[bp+00Ah]
	mov	dx,03CEh
	mov	ax,0105h
	out	dx,ax
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	inc	dx
	mov	ax,000Fh
	out	dx,al
	mov	bx,[bp+008h]
	shl	bx,1
	mov	si,[bx+_video]
	add	si,[bp+006h]
	mov	ax,0A000h
	mov	ds,ax
	cld
	repz	movsb
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_vgawrite:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,0A000h
	mov	es,ax
	mov	cx,[bp+00Ah]
	mov	dx,03CEh
	mov	ax,0105h
	out	dx,ax
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	bx,[bp+008h]
	shl	bx,1
	mov	di,[bx+_video]
	add	di,[bp+006h]
	mov	ax,0A000h
	mov	ds,ax
	mov	si,[bp+00Ch]
	cld
	repz	movsb
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_getvga:
	push	bp
	mov	bp,sp
	push	di
	push	es
	cld
	les	di,dword ptr [bp+006h]
	mov	dx,03CEh
	mov	al,00h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,01h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,02h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,03h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,04h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,05h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,06h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,07h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03CEh
	mov	al,08h
	out	dx,al
	mov	dx,03CFh
	in	al,dx
	stosb
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	in	al,dx
	stosb
	pop	es
	pop	di
	pop	bp
	retf

_text	ENDS
	END
