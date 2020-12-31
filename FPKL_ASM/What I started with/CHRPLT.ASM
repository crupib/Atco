; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	chrplt.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [00C7]	; Linker - Pass two marker

	EXTRN		_nucol:WORD
	EXTRN		_vm:WORD
	EXTRN		_vidseg:WORD
	EXTRN		_video:WORD
	PUBLIC		_chrplt			; Located at 2:0000h Type = 1
	PUBLIC		bml			; Located at 2:023Eh Type = 1
	PUBLIC		bmh			; Located at 2:0250h Type = 1
	PUBLIC		clrcpl			; Located at 2:0262h Type = 1
	PUBLIC		enco			; Located at 2:028Ah Type = 1
	PUBLIC		disco			; Located at 2:029Ch Type = 1
	PUBLIC		getpla			; Located at 2:02ADh Type = 1
	PUBLIC		egainit			; Located at 2:02ECh Type = 1
	PUBLIC		restor			; Located at 2:0314h Type = 1
struct_0	struc
s0m_0	dw	20 dup (?)
struct_0	ends

_data	SEGMENT

$S7	dw	00008h
	db	000h

$S14	dd	1 dup(?)
$S2	dw	1 dup(?)
$S33	db	000h
$S1	db	000h

$S11	dw	1 dup(?)
$S9	dw	1 dup(?)
$S10	dw	1 dup(?)
$S3	db	000h
	db	000h
	db	001h
	db	001h
	db	002h
	db	002h
	db	002h
	db	002h
	db	003h
	db	003h
	db	003h
	db	003h
	db	003h
	db	003h
	db	003h
	db	003h

$S4	db	1 dup(?)
$S20	struct_0	<00000h>

$S12	db	000h
$S13	dw	00000h

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_chrplt:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	bx,[bp+00Eh]
	mov	ax,bx
	assume	ds: DGROUP
	mov	$S1,bh
	and	bx,+07Fh
	mov	$S2,bx
	and	bl,0Fh
	mov	bl,[bx+$S3]
	mov	$S4,bl
	cmp	word ptr _vm,+00Dh
	jnc	$L5
	jmp	$L6
$L5:	call	egainit
	mov	bh,03h
	mov	word ptr $S7,0008h
	cmp	word ptr $S2,+020h
	jc	$L8
	mov	bh,02h
	mov	word ptr $S7,000Eh
	cmp	word ptr $S2,+040h
	jc	$L8
	mov	bh,06h
	mov	word ptr $S7,0010h
$L8:	push	bp
	mov	al,30h
	mov	ah,11h
	int	10h
	mov	$S9,bp
	mov	word ptr $S10,es
	pop	bp
	mov	dx,[bp+00Ah]
	mov	bx,[bp+00Ch]
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,dx
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	mov	$S11,bx
	and	dx,+007h
	mov	$S12,dl
	mov	cl,dl
	mov	dx,00FFh
	ror	dx,cl
	mov	$S13,dx
	mov	word ptr $S14,0000h
$L24:	les	bx,dword ptr [bp+006h]
	add	bx,$S14
	mov	al,es:[bx]
	cmp	al,00h
	jnz	$L15
	jmp	$L16
$L15:	cmp	al,0Ah
	jnz	$L17
	jmp	$L16
$L17:	cmp	al,0Dh
	jnz	$L18
	jmp	$L16
$L18:	mov	ah,00h
	mov	bx,$S7
	mul	bl
	mov	bx,$S9
	add	bx,ax
	add	bx,$S7
	dec	bx
	mov	si,0000h
	mov	cx,$S7
	mov	es,word ptr $S10
$L21:	push	cx
	mov	cl,$S12
	mov	al,es:[bx]
	test	word ptr $S2,0010h
	jz	$L19
	xor	al,0FFh
$L19:	mov	ah,00h
	ror	ax,cl
	mov	[si+$S20.s0m_0],ax
	add	si,+002h
	dec	bx
	pop	cx
	loop	$L21
	mov	si,0000h
	mov	es,word ptr _vidseg
	mov	bx,$S11
	call	bml
	call	clrcpl
	mov	cx,$S7
$L22:	mov	al,es:[bx]
	mov	al,byte ptr [si+$S20.s0m_0]
	mov	es:[bx],al
	sub	bx,_nucol
	add	si,+002h
	loop	$L22
	mov	si,0001h
	mov	bx,$S11
	add	bx,+001h
	call	bmh
	call	clrcpl
	mov	cx,$S7
$L23:	mov	al,es:[bx]
	mov	al,byte ptr [si+$S20.s0m_0]
	mov	es:[bx],al
	sub	bx,_nucol
	add	si,+002h
	loop	$L23
	inc	word ptr $S11
	inc	word ptr $S14
	jmp	$L24
$L6:	mov	word ptr $S9,0FA6Eh
	mov	word ptr $S10,0F000h
	mov	word ptr $S7,0008h
	mov	dx,[bp+00Ah]
	mov	bx,[bp+00Ch]
	shl	bx,1
	mov	bx,[bx+_video]
	mov	ax,dx
	mov	cl,03h
	sar	ax,cl
	add	bx,ax
	mov	$S11,bx
	and	dx,+007h
	mov	$S12,dl
	mov	cl,dl
	mov	dx,0FF00h
	ror	dx,cl
	mov	$S13,dx
	mov	word ptr $S14,0000h
$L30:	les	bx,dword ptr [bp+006h]
	add	bx,$S14
	mov	al,es:[bx]
	cmp	al,00h
	jnz	$L25
	jmp	$L16
$L25:	cmp	al,0Ah
	jnz	$L26
	jmp	$L16
$L26:	mov	ah,00h
	mov	bx,$S7
	mul	bl
	mov	bx,$S9
	add	bx,ax
	add	bx,$S7
	dec	bx
	mov	si,0000h
	mov	cx,$S7
	mov	es,word ptr $S10
$L28:	push	cx
	mov	cl,$S12
	mov	al,es:[bx]
	test	word ptr $S2,0010h
	jz	$L27
	xor	al,0FFh
$L27:	mov	ah,00h
	ror	ax,cl
	mov	[si+$S20.s0m_0],ax
	add	si,+002h
	dec	bx
	pop	cx
	loop	$L28
	mov	si,0000h
	mov	es,word ptr _vidseg
	mov	bx,$S11
	mov	cx,$S7
	push	di
	push	dx
	mov	di,0E000h
	mov	dx,1FB0h
	test	bx,2000h
	jnz	$L29
	xchg	di,dx
$L29:	mov	ax,es:[bx]
	and	ax,$S13
	or	ax,[si+$S20.s0m_0]
	mov	es:[bx],ax
	add	bx,di
	xchg	di,dx
	add	si,+002h
	loop	$L29
	pop	dx
	pop	di
	inc	word ptr $S11
	inc	word ptr $S14
	jmp	$L30
$L16:	cmp	word ptr _vm,+00Dh
	jc	$L31
	call	restor
$L31:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
bml:	push	ax
	push	dx
	mov	dx,03CEh
	mov	al,08h
	out	dx,al
	mov	dx,03CFh
	mov	al,byte ptr $S13
	out	dx,al
	pop	dx
	pop	ax
	ret
bmh:	push	ax
	push	dx
	mov	dx,03CEh
	mov	al,08h
	out	dx,al
	mov	dx,03CFh
	mov	al,byte ptr $S13 + 00001h
	out	dx,al
	pop	dx
	pop	ax
	ret
clrcpl:	push	ax
	push	bx
	push	dx
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	mov	al,0Fh
	out	dx,al
	mov	cx,$S7
$L32:	mov	al,es:[bx]
	mov	byte ptr es:[bx],00h
	sub	bx,_nucol
	loop	$L32
	mov	ax,$S2
	out	dx,al
	pop	dx
	pop	bx
	pop	ax
	ret
enco:	push	ax
	push	dx
	mov	dx,03CEh
	mov	al,01h
	out	dx,al
	mov	dx,03CFh
	mov	al,$S1
	out	dx,al
	pop	dx
	pop	ax
	ret
disco:	push	ax
	push	dx
	mov	dx,03CEh
	mov	al,01h
	out	dx,al
	mov	dx,03CFh
	mov	al,00h
	out	dx,al
	pop	dx
	pop	ax
	ret
getpla:	push	cx
	push	dx
	sub	cx,cx
	mov	dx,03CEh
	mov	al,04h
	out	dx,al
	mov	dx,03CFh
	mov	al,00h
	out	dx,al
	or	cx,es:[bx]
	test	byte ptr $S33,01h
	jz	$L34
	mov	al,01h
	out	dx,al
	or	cx,es:[bx]
$L34:	test	byte ptr $S33,02h
	jz	$L35
	mov	al,02h
	out	dx,al
	or	cx,es:[bx]
$L35:	test	byte ptr $S33,03h
	jz	$L36
	mov	al,03h
	out	dx,al
	or	cx,es:[bx]
$L36:	mov	ax,cx
	pop	dx
	pop	cx
	ret
egainit:
	mov	dx,03CEh
	mov	al,01h
	out	dx,al
	mov	dx,03CFh
	mov	al,$S1
	out	dx,al
	mov	dx,03CEh
	mov	al,00h
	out	dx,al
	mov	dx,03CFh
	mov	al,$S1
	out	dx,al
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	mov	ax,$S2
	out	dx,al
	ret
restor:	mov	dx,03CEh
	mov	al,08h
	out	dx,al
	mov	dx,03CFh
	mov	al,0FFh
	out	dx,al
	mov	dx,03CEh
	mov	al,01h
	out	dx,al
	mov	dx,03CFh
	mov	al,00h
	out	dx,al
	ret

_text	ENDS
	END
