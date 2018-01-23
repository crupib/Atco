; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	egadrv.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [00D3]	; Linker - Pass two marker


	PUBLIC		_setre			; Located at 1:0000h Type = 1
	PUBLIC		_enasr			; Located at 1:0012h Type = 1
	PUBLIC		_colco			; Located at 1:0024h Type = 1
	PUBLIC		_rotat			; Located at 1:0036h Type = 1
	PUBLIC		_funct			; Located at 1:0048h Type = 1
	PUBLIC		_rdmap			; Located at 1:0062h Type = 1
	PUBLIC		_wrmod			; Located at 1:0074h Type = 1
	PUBLIC		_rdmod			; Located at 1:0088h Type = 1
	PUBLIC		_codoc			; Located at 1:00A2h Type = 1
	PUBLIC		_btmsk			; Located at 1:00B4h Type = 1
	PUBLIC		_mpmsk			; Located at 1:00C6h Type = 1
	PUBLIC		_stadd			; Located at 1:00D8h Type = 1
	PUBLIC		_rowsca			; Located at 1:00F7h Type = 1
	PUBLIC		_selseg			; Located at 1:0109h Type = 1
	PUBLIC		_setdac			; Located at 1:011Eh Type = 1
	PUBLIC		_revvid			; Located at 1:0138h Type = 1

_text	SEGMENT
	assume	cs: _text


_setre:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,00h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_enasr:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,01h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_colco:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,02h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_rotat:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,03h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_funct:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,03h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	and	al,03h
	rol	al,1
	rol	al,1
	rol	al,1
	out	dx,al
	pop	bp
	retf
_rdmap:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,04h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_wrmod:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,05h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	and	al,03h
	out	dx,al
	pop	bp
	retf
_rdmod:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,05h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	and	al,01h
	rol	al,1
	rol	al,1
	rol	al,1
	out	dx,al
	pop	bp
	retf
_codoc:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,07h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_btmsk:	push	bp
	mov	bp,sp
	mov	dx,03CEh
	mov	al,08h
	out	dx,al
	mov	dx,03CFh
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_mpmsk:	push	bp
	mov	bp,sp
	mov	dx,03C4h
	mov	al,02h
	out	dx,al
	mov	dx,03C5h
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_stadd:	push	bp
	mov	bp,sp
	mov	dx,03D4h
	mov	al,0Ch
	out	dx,al
	mov	dx,03D5h
	mov	al,[bp+007h]
	out	dx,al
	mov	dx,03D4h
	mov	al,0Dh
	out	dx,al
	mov	dx,03D5h
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_rowsca:
	push	bp
	mov	bp,sp
	mov	dx,03D4h
	mov	al,08h
	out	dx,al
	mov	dx,03D5h
	mov	al,[bp+006h]
	out	dx,al
	pop	bp
	retf
_selseg:
	push	bp
	mov	bp,sp
	mov	bl,[bp+006h]
	mov	al,[bp+008h]
	mov	cl,04h
	shl	al,cl
	or	al,bl
	mov	dx,03CDh
	out	dx,al
	pop	bp
	retf
_setdac:
	push	bp
	mov	bp,sp
	mov	al,[bp+006h]
	mov	dx,03C8h
	out	dx,al
	mov	ax,[bp+008h]
	mov	dx,03C9h
	out	dx,al
	xchg	al,ah
	out	dx,al
	mov	ax,[bp+00Ah]
	out	dx,al
	pop	bp
	retf
_revvid:
	push	bp
	mov	bp,sp
	push	di
	push	si
	push	ds
	push	es
	cld
	mov	ax,0B800h
	mov	es,ax
	mov	ds,ax
	mov	cx,1000h
	mov	si,0000h
	mov	di,0000h
$L1:	lodsw
	not	ax
	stosw
	loop	$L1
	mov	ax,0BA00h
	mov	es,ax
	mov	ds,ax
	mov	cx,1000h
	mov	si,0000h
	mov	di,0000h
$L2:	lodsw
	not	ax
	stosw
	loop	$L2
	pop	es
	pop	ds
	pop	si
	pop	di
	pop	bp
	retf

_text	ENDS
	END
