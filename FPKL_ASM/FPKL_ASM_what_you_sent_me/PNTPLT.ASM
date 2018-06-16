; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	pntplt.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [00AC]	; Linker - Pass two marker

	EXTRN		_nucol:WORD
	EXTRN		_vm:WORD
	EXTRN		_vidseg:WORD
	EXTRN		_video:WORD
	PUBLIC		_pntplt			; Located at 2:0000h Type = 1
	PUBLIC		_cfunct			; Located at 2:0091h Type = 1
	PUBLIC		_pntplt2		; Located at 2:00A3h Type = 1
	PUBLIC		_vertln			; Located at 2:00F7h Type = 1
	PUBLIC		_blnkln			; Located at 2:0155h Type = 1

_data	SEGMENT

$S5	db	002h
$S2	db	080h
	db	040h
	db	020h
	db	010h
	db	008h
	db	004h
	db	002h
	db	001h
$S8	db	07Fh
	db	0BFh
	db	0DFh
	db	0EFh
	db	0F7h
	db	0FBh
	db	0FDh
	db	0FEh

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_pntplt:
	push	bp
	mov	bp,sp
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	si,[bp+006h]
	mov	bx,[bp+008h]
	assume	ds: DGROUP
	cmp	word ptr _vm,+00Eh
	jc	$L1
	mov	dx,03C4h
	mov	al,02h
	mov	ah,[bp+00Ah]
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0FF08h
	out	dx,ax
	mov	es,word ptr _vidseg
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,si
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	and	si,+007h
	mov	al,[si+$S2]
	mov	ah,es:[bx]
	mov	es:[bx],al
	jmp	short $L3
$L1:	mov	es,word ptr _vidseg
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,si
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	and	si,+007h
	cmp	byte ptr [bp+00Ah],00h
	jz	$L4
	mov	al,[si+$S2]
	cmp	byte ptr $S5,03h
	jnz	$L6
	xor	es:[bx],al
	jmp	short $L3
$L6:	cmp	byte ptr $S5,01h
	jnz	$L7
	xor	es:[bx],al
	jmp	short $L3
$L7:	or	es:[bx],al
	jmp	short $L3
$L4:	mov	al,[si+$S8]
	and	es:[bx],al
$L3:	pop	es
	pop	ds
	pop	si
	pop	bp
	retf
_cfunct:
	push	bp
	mov	bp,sp
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	al,[bp+006h]
	mov	$S5,al
	pop	ds
	pop	bp
	retf
_pntplt2:
	push	bp
	mov	bp,sp
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	si,[bp+006h]
	mov	bx,[bp+008h]
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0205h
	out	dx,ax
	mov	es,word ptr _vidseg
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,si
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	and	si,+007h
	mov	ah,[si+$S2]
	mov	al,08h
	out	dx,ax
	mov	al,[bp+00Ah]
	mov	ah,es:[bx]
	mov	es:[bx],al
	mov	dx,03CEh
	mov	ax,0005h
	out	dx,ax
	mov	ax,0FF08h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	bp
	retf
_vertln:
	push	bp
	mov	bp,sp
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	si,[bp+006h]
	mov	bx,[bp+008h]
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0F01h
	out	dx,ax
	mov	al,00h
	mov	ah,[bp+00Ch]
	out	dx,ax
	mov	es,word ptr _vidseg
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,si
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	and	si,+007h
	mov	ah,[si+$S2]
	mov	al,08h
	out	dx,ax
	mov	dx,_nucol
	mov	cx,[bp+00Ah]
$L9:	mov	ah,es:[bx]
	mov	es:[bx],al
	sub	bx,dx
	loop	$L9
	mov	dx,03CEh
	mov	ax,0001h
	out	dx,ax
	pop	es
	pop	ds
	pop	si
	pop	bp
	retf
_blnkln:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	dx,03C4h
	mov	ax,0F02h
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0003h
	out	dx,ax
	mov	dx,03CEh
	mov	al,05h
	out	dx,ax
	in	al,dx
	mov	dx,03CEh
	mov	ax,0001h
	out	dx,ax
	mov	dx,03CEh
	mov	ax,0FF08h
	out	dx,ax
	cld
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
	mov	es,word ptr _vidseg
	mov	cx,[bp+00Ah]
	mov	al,00h
	repz	stosb
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

_text	ENDS
	END
