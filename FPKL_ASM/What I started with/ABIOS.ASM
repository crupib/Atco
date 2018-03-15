; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	abios.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_data	SEGMENT	WORD PUBLIC USE16 'data'
_data	ENDS
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
DGROUP	GROUP	_data
; [00E9]	; Linker - Pass two marker


	PUBLIC		_vm			; Located at 1:0000h Type = 4
	PUBLIC		_vidseg			; Located at 1:0002h Type = 4
	PUBLIC		_video			; Located at 1:0004h Type = 0
	PUBLIC		_xnucol			; Located at 1:0804h Type = 4
	PUBLIC		_blklin			; Located at 2:0000h Type = 1
	PUBLIC		_chkey			; Located at 2:0037h Type = 1
	PUBLIC		_chkeye			; Located at 2:0044h Type = 1
	PUBLIC		_setvid			; Located at 2:0051h Type = 1
	PUBLIC		_c_cli			; Located at 2:0085h Type = 1
	PUBLIC		_c_sti			; Located at 2:0087h Type = 1
	PUBLIC		_chabs			; Located at 2:0089h Type = 1
	PUBLIC		_decim			; Located at 2:0105h Type = 1
struct_0	struc
s0m_0	dw	1024 dup (?)
struct_0	ends

_data	SEGMENT

_vm	dw	00006h
_vidseg	dw	0B800h

_video	struct_0	<00000h>

_xnucol	dw	00050h

_data	ENDS
_text	SEGMENT
	assume	cs: _text


_blklin:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	es
	mov	dx,0000h
	mov	ax,0140h
	mov	bx,[bp+006h]
	mul	bx
	mov	si,ax
	cld
	mov	ax,0B800h
	mov	es,ax
	mov	di,si
	mov	cx,00A0h
	mov	ax,0000h
	repz	stosw
	mov	ax,0BA00h
	mov	es,ax
	mov	di,si
	mov	cx,00A0h
	mov	ax,0000h
	repz	stosw
	pop	es
	pop	si
	pop	di
	pop	bp
	retf
_chkey:	mov	ah,01h
	int	16h
	mov	ax,0000h
	jz	$L1
	mov	ax,0FFFFh
$L1:	retf
_chkeye:
	mov	ah,11h
	int	16h
	mov	ax,0000h
	jz	$L2
	mov	ax,0FFFFh
$L2:	retf
_setvid:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	ax,[bp+010h]
	assume	ds: DGROUP
	mov	_xnucol,ax
	mov	ax,[bp+006h]
	mov	_vm,ax
	mov	ax,[bp+008h]
	mov	_vidseg,ax
	mov	cx,[bp+00Eh]
	mov	ax,ds
	mov	es,ax
	mov	di,offset DGROUP:_video.s0m_0
	lds	si,dword ptr [bp+00Ah]
	cld
	repz	movsw
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_c_cli:	cli
	retf
_c_sti:	sti
	retf
_chabs:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	mov	ax,seg DGROUP
	mov	ds,ax
	mov	cx,[bp+00Eh]
	mov	bx,[bp+010h]
	les	di,dword ptr [bp+00Ah]
	lds	si,dword ptr [bp+006h]
	cmp	bx,+001h
	jnz	$L3
$L4:	lodsb
	add	al,80h
	stosb
	loop	$L4
	jmp	short $L5
$L3:	cmp	bx,+002h
	jnz	$L6
$L8:	lodsb
	cmp	al,80h
	jc	$L7
	neg	al
	cmp	al,80h
	jnz	$L7
	dec	al
$L7:	shl	al,1
	stosb
	loop	$L8
	jmp	short $L5
$L6:	cmp	bx,+003h
	jnz	$L9
$L11:	lodsb
	cmp	al,80h
	jc	$L10
	sub	al,al
	stosb
	loop	$L11
	jmp	short $L5
$L10:	shl	al,1
	stosb
	loop	$L11
	jmp	short $L5
$L9:	cmp	bx,+004h
	jnz	$L5
$L14:	lodsb
	cmp	al,80h
	jc	$L12
	cmp	al,80h
	jnz	$L13
	inc	al
$L13:	neg	al
	shl	al,1
	stosb
	loop	$L14
	jmp	short $L5
$L12:	sub	al,al
	stosb
	loop	$L14
	jmp	short $L5
$L5:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf
_decim:	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	lds	si,dword ptr [bp+00Ah]
	les	di,dword ptr [bp+00Eh]
	mov	cx,[bp+008h]
	cmp	byte ptr [bp+012h],00h
	jnz	$L15
	jmp	short $L16
$L15:	cmp	byte ptr [bp+012h],01h
	jnz	$L17
	jmp	short $L18
$L17:	cmp	byte ptr [bp+012h],02h
	jnz	$L19
	jmp	short $L20
$L19:	jmp	$L21
$L16:	push	cx
	mov	cx,[bp+006h]
	mov	dx,0000h
$L23:	lodsb
	cmp	al,dl
	jc	$L22
	mov	dl,al
$L22:	loop	$L23
	mov	al,dl
	stosb
	pop	cx
	loop	$L16
	jmp	short $L21
$L18:	push	cx
	mov	cx,[bp+006h]
	mov	dx,0000h
$L26:	lodsb
	sub	al,80h
	cmp	al,00h
	jg	$L24
	cmp	al,dh
	jg	$L25
	mov	dh,al
	jmp	short $L25
$L24:	cmp	al,dl
	jc	$L25
	mov	dl,al
$L25:	loop	$L26
	cmp	dh,80h
	jnz	$L27
	mov	dh,81h
$L27:	mov	ax,dx
	neg	dh
	cmp	dl,dh
	jg	$L28
	mov	al,ah
$L28:	add	al,80h
	stosb
	pop	cx
	loop	$L18
	jmp	short $L21
$L20:	push	cx
	mov	cx,[bp+006h]
	mov	dx,0000h
$L31:	lodsb
	cmp	al,00h
	jg	$L29
	cmp	al,dh
	jg	$L30
	mov	dh,al
	jmp	short $L30
$L29:	cmp	al,dl
	jl	$L30
	mov	dl,al
$L30:	loop	$L31
	cmp	dh,80h
	jnz	$L32
	mov	dh,81h
$L32:	mov	ax,dx
	neg	dh
	cmp	dl,dh
	jg	$L33
	mov	al,ah
$L33:	stosb
	pop	cx
	loop	$L20
	jmp	short $L21
$L21:	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

_text	ENDS
	END
