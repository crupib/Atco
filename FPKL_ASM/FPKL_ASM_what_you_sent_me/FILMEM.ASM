; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	filmem.asm
	.386p					; Enable USE32/USE16 usage
	.387					; Enable floating point also
_text	SEGMENT	BYTE PUBLIC USE16 'code'
_text	ENDS
; [003A]	; Linker - Pass two marker


	PUBLIC		_filmem			; Located at 1:0000h Type = 1

_text	SEGMENT
	assume	cs: _text


_filmem:
	push	bp
	mov	bp,sp
	push	di
	push	es
	cld
	mov	cx,[bp+00Ah]
	mov	ax,[bp+00Ch]
	les	di,dword ptr [bp+006h]
	repz	stosw
	pop	es
	pop	di
	mov	sp,bp
	pop	bp
	retf

_text	ENDS
	END
