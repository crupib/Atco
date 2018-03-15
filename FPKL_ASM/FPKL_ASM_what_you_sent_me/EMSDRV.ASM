; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	emsdrv.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [0080]	; Linker - Pass two marker


	PUBLIC		_ems1			; Located at 1:0000h Type = 1
	PUBLIC		_ems2			; Located at 1:0009h Type = 1
	PUBLIC		_ems3			; Located at 1:0022h Type = 1
	PUBLIC		_ems4			; Located at 1:0043h Type = 1
	PUBLIC		_ems5			; Located at 1:0064h Type = 1
	PUBLIC		_ems6			; Located at 1:007Eh Type = 1
	PUBLIC		_ems7			; Located at 1:0090h Type = 1
	PUBLIC		_ems8			; Located at 1:0097h Type = 1
	PUBLIC		_ems9			; Located at 1:00A9h Type = 1

_text	SEGMENT
	assume	cs: _text


_ems1:	mov	ah,40h
	int	67h
	test	ah,ah
	mov	al,00h
	retf
_ems2:	push	bp
	mov	bp,sp
	push	bx
	push	si
	push	es
	mov	ah,41h
	int	67h
	test	ah,ah
	mov	al,00h
	les	si,dword ptr [bp+006h]
	mov	es:[si],bx
	pop	es
	pop	si
	pop	bx
	pop	bp
	retf
_ems3:	push	bp
	mov	bp,sp
	push	bx
	push	dx
	push	si
	push	es
	mov	ah,42h
	int	67h
	test	ah,ah
	mov	al,00h
	les	si,dword ptr [bp+006h]
	mov	es:[si],bx
	les	si,dword ptr [bp+00Ah]
	mov	es:[si],dx
	pop	es
	pop	si
	pop	dx
	pop	bx
	pop	bp
	retf
_ems4:	push	bp
	mov	bp,sp
	push	bx
	push	dx
	push	si
	push	es
	les	si,dword ptr [bp+006h]
	mov	bx,es:[si]
	mov	ah,43h
	int	67h
	test	ah,ah
	mov	al,00h
	les	si,dword ptr [bp+00Ah]
	mov	es:[si],dx
	pop	es
	pop	si
	pop	dx
	pop	bx
	pop	bp
	retf
_ems5:	push	bp
	mov	bp,sp
	push	bx
	push	dx
	mov	dx,[bp+006h]
	mov	bx,[bp+008h]
	mov	ax,[bp+00Ah]
	mov	ah,44h
	int	67h
	test	ah,ah
	mov	al,00h
	pop	dx
	pop	bx
	pop	bp
	retf
_ems6:	push	bp
	mov	bp,sp
	push	dx
	mov	dx,[bp+006h]
	mov	ah,45h
	int	67h
	test	ah,ah
	mov	al,00h
	pop	dx
	pop	bp
	retf
_ems7:	mov	ah,46h
	int	67h
	test	ah,ah
	retf
_ems8:	push	bp
	mov	bp,sp
	push	dx
	mov	dx,[bp+006h]
	mov	ah,47h
	int	67h
	test	ah,ah
	mov	al,00h
	pop	dx
	pop	bp
	retf
_ems9:	push	bp
	mov	bp,sp
	push	dx
	mov	dx,[bp+006h]
	mov	ah,48h
	int	67h
	test	ah,ah
	mov	al,00h
	pop	dx
	pop	bp
	retf

_text	ENDS
	END
