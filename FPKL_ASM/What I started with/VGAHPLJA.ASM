; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	vgahplja.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
_TEXT	ENDS
_DATA	SEGMENT	WORD PUBLIC USE16 'DATA'
_DATA	ENDS
VGAHPLJA_TEXT	SEGMENT	WORD PUBLIC USE16 'CODE'
VGAHPLJA_TEXT	ENDS
DGROUP	GROUP	_DATA
; [00A7]	; Linker - Pass two marker

	EXTRN		_nucol:WORD
	EXTRN		_video:WORD
	EXTRN		_prnbuf:NEAR
	PUBLIC		_hp_laser_screen_dump_func
						; Located at 3:0000h Type = 1

_DATA	SEGMENT

$S1	dw	1 dup(?)
$S4	dw	1 dup(?)
$S12	dw	1 dup(?)
$S13	dw	1 dup(?)
$S5	dw	1 dup(?)
$S18	dw	1 dup(?)
$S20	dw	1 dup(?)
$S10	dw	1 dup(?)
$S11	dw	1 dup(?)
$S6	dw	1 dup(?)
$S7	dw	1 dup(?)
$S8	dw	1 dup(?)
$S9	dw	1 dup(?)
$S2	dw	1 dup(?)
$S3	dw	1 dup(?)
$S21	dw	1 dup(?)
$S22	df	1 dup(?)

_DATA	ENDS
VGAHPLJA_TEXT	SEGMENT
	assume	cs: VGAHPLJA_TEXT


_hp_laser_screen_dump_func:
	push	bp
	mov	bp,sp
	push	ds
	mov	ax,seg DGROUP
	mov	ds,ax
	push	es
	push	fs
	push	gs
	push	si
	push	di
	mov	ax,[bp+006h]
	assume	ds: DGROUP
	mov	$S1,ax
	mov	ax,[bp+01Ch]
	mov	$S2,ax
	mov	ax,[bp+01Eh]
	mov	$S3,ax
	mov	di,[bp+008h]
	shl	di,1
	mov	ax,[di+_video]
	mov	$S4,ax
	mov	gs,word ptr [bp+00Ch]
	mov	ax,[bp+00Eh]
	mov	$S5,ax
	mov	dx,03CEh
	mov	al,04h
	out	dx,al
	les	bx,dword ptr [bp+014h]
	mov	ax,es
	mov	$S6,ax
	mov	$S7,bx
	les	bx,dword ptr [bp+018h]
	mov	ax,es
	mov	$S8,ax
	mov	$S9,bx
	les	bx,dword ptr [bp+010h]
	mov	ax,es
	mov	$S10,ax
	mov	$S11,bx
	mov	ax,[bp+020h]
	mov	$S12,ax
	mov	ax,[bp+00Ah]
	mov	$S13,ax
$L31:	mov	si,$S4
	add	si,$S1
	mov	fs,si
	mov	bx,$S11
	mov	dx,03CFh
	mov	cx,gs
	mov	bp,_nucol
	push	ds
	mov	ax,0A000h
	mov	ds,ax
	lea	di,[bx]
	mov	al,00h
	out	dx,al
$L14:	mov	eax,[si]
	sub	si,bp
	mov	es:[di],eax
	add	di,+004h
	loop	$L14
	mov	si,fs
	mov	cx,gs
	lea	di,[bx+0960h]
	mov	al,01h
	out	dx,al
$L15:	mov	eax,[si]
	sub	si,bp
	mov	es:[di],eax
	add	di,+004h
	loop	$L15
	mov	si,fs
	mov	cx,gs
	lea	di,[bx+12C0h]
	mov	al,02h
	out	dx,al
$L16:	mov	eax,[si]
	sub	si,bp
	mov	es:[di],eax
	add	di,+004h
	loop	$L16
	mov	si,fs
	mov	cx,gs
	lea	di,[bx+1C20h]
	mov	al,03h
	out	dx,al
$L17:	mov	eax,[si]
	sub	si,bp
	mov	es:[di],eax
	add	di,+004h
	loop	$L17
	pop	ds
	mov	word ptr $S18,0000h
$L30:	mov	si,bx
	add	si,$S18
	mov	di,bx
	mov	fs,word ptr $S6
	xor	ebx,ebx
	xor	ebp,ebp
	mov	bx,$S7
	mov	cx,gs
$L19:	mov	al,es:[si]
	mov	ah,es:[si+0960h]
	mov	dl,es:[si+12C0h]
	mov	dh,es:[si+1C20h]
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	xor	bp,bp
	rcl	dh,1
	rcl	bp,1
	rcl	dl,1
	rcl	bp,1
	rcl	ah,1
	rcl	bp,1
	rcl	al,1
	rcl	bp,1
	mov	bp,fs:[ebx+ebp*2]
	mov	es:[di+2580h],bp
	add	di,+002h
	add	si,+004h
	dec	cx
	jnz	$L19
	mov	word ptr $S20,0000h
$L29:	mov	ax,$S5
	mov	$S21,ax
$L28:	mov	bx,$S11
	mov	si,bx
	add	si,$S20
	mov	di,bx
	mov	bp,bx
	mov	bl,08h
	mov	word ptr $S22,gs
$L27:	mov	cx,$S5
$L26:	mov	dx,es:[si+2580h]
	add	dx,es:[di+4B02h]
	cmp	dx,013Bh
	jnl	$L23
	clc
	jmp	short $L24
$L23:	sub	dx,0276h
	stc
$L24:	rcl	bh,1
	dec	bl
	jnz	$L25
	mov	es:[bp+6E40h],bh
	inc	bp
	mov	bl,08h
$L25:	mov	ax,dx
	shl	ax,1
	add	ax,dx
	sar	ax,04h
	add	es:[di+5CA0h],ax
	mov	ax,dx
	shl	ax,02h
	add	ax,dx
	sar	ax,04h
	add	es:[di+5CA2h],ax
	add	di,+002h
	mov	ax,dx
	shl	ax,03h
	sub	ax,dx
	sar	ax,04h
	add	es:[di+4B02h],ax
	sar	dx,04h
	add	es:[di+5CA2h],dx
	loop	$L26
	add	si,+010h
	mov	ax,$S22
	dec	ax
	mov	$S22,ax
	jnz	$L27
	mov	fs,word ptr $S8
	mov	bx,$S9
	mov	ax,$S2
	push	ax
	push	fs
	push	bx
	call	far ptr _prnbuf
	add	sp,+006h
	mov	bx,$S11
	lea	bx,[bx+6E40h]
	mov	ax,$S12
	mov	es,word ptr $S10
	push	ax
	push	es
	push	bx
	call	far ptr _prnbuf
	add	sp,+006h
	mov	es,word ptr $S10
	mov	cx,$S3
	mov	dx,cx
	mov	bx,$S11
	push	ds
	mov	ds,word ptr $S10
	lea	si,[bx+5CA2h]
	lea	di,[bx+4B02h]
	repz	movsd
	xor	eax,eax
	mov	cx,dx
	lea	di,[bx+5CA2h]
	repz	stosd
	pop	ds
	mov	ax,$S21
	dec	ax
	mov	$S21,ax
	jnz	$L28
	mov	ax,$S20
	add	ax,+002h
	mov	$S20,ax
	cmp	ax,+010h
	jnz	$L29
	mov	ax,$S18
	inc	ax
	mov	$S18,ax
	mov	bx,$S11
	cmp	ax,+004h
	jnz	$L30
	add	word ptr $S1,+004h
	mov	ax,$S13
	dec	ax
	mov	$S13,ax
	jnz	$L31
	pop	di
	pop	si
	pop	gs
	pop	fs
	pop	es
	pop	ds
	pop	bp
	retf

VGAHPLJA_TEXT	ENDS
	END
