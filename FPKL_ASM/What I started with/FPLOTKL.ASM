; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fplotkl.asm
	.386p
	.387
	_TEXT		SEGMENT WORD PUBLIC USE 16 'CODE'
	_TEXT		ENDS
	_DATA		SEGMENT WORD PUBLIC USE 16 'DATA'
	_DATA		ENDS
	FPLOTKL_TEXT SEGMENT WORD PUBLIC USE 16 'CODE'
	FPLOTKL_TEXT ENDS
	DGROUP	GROUP	_DATA
	
	EXTRN		_nucol:WORD ; vigen.asm
	EXTRN		_video:WORD ; abios.asm
	PUBLIC		_fplot			
	PUBLIC		_fplot_egainit	
	PUBLIC		_fplot_restor	
	PUBLIC		_interlbklfp	
	PUBLIC		_interlklfp		

_DATA	SEGMENT

$S54	db	080h
		db	040h
		db	020h
		db	010h
		db	008h
		db	004h
		db	002h
		db	001h

$S25	dw	1 dup(?)   ;es saved
$S2		dw	1 dup(?)   ;pointer to sp
$S3		dw	1 dup(?)   ;pointer to sp
$S17	dw	00000h     ;address trans 
$S18	dw	00000h     ;address of table
$S4		dd	000000001h ;iscale
$S5		dw	00200h     ;n
$S6		dw	00200h     ;nperstrip
$S22	dw	00200h
$S7		dw	00000h     ;startpoint
$S8		dw	00000h     ;sp plot struc
$S9		dw	00000h     ;stripdel
$S10	dd	000000000h ;lastremainder
$S51	dw	00040h
$S11	dw	00040h     ;startpoint address
$S12	dw	00032h     ;yoff
$S14	dw	00000h     ;idel
$S15	dw	00000h     ;irec 
$S16	dw	00000h     ;type
$S1		dw	00002h     ;ipm ptr to first 2 bytes, plot mode switch; default FP_PLOT_MODE_PLOT_ONLY
$S13	db	1 dup(?)   ;color
$S27	dw	00000h     ;temp for si
$S24	dd	1 dup(?)   ;lastremainder temp
$S87	dd	1 dup(?)
_DATA	ENDS
; FP_PLOT_MODE_ERASE_ONLY         0               /**  Erase current waveform in the erase buffer  **/
; FP_PLOT_MODE_ERASE_AND_PLOT     1               /**  Erase current waveform in erase buffer and plot waveform specified by buff  **/
; FP_PLOT_MODE_PLOT_ONLY          2               /**  The waveform specified by buff is XOR'd to the screen.  The plotted waveform is also stored in the erase buffer.  **/
; FP_PLOT_MODE_ACCUMULATE         3               /**  The waveform specified by buff is OR'd to the screen, but is not saved in the erase buffer  **/
; void  fplot( short int *ipm,  struct plot *sp,  char *buff);
FPLOTKL_TEXT	SEGMENT
	assume	cs:FPLOTKL_TEXT
	_fplot:	
		push bp              ;save base pointer
		mov bp,sp            ;move stack pointer to new base pointer
		add sp,-002h         ;subtract 2 from stack pointer to point to original return address
		push ds              ;push previous regs
		mov ax,seg DGROUP    
		mov ds,ax
		push eax
		push bx
		push ecx
		push dx
		push di
		push si
		push ds
		push es
		cld 
;		   int   ipm[ NUMBER_OF_WAVEFORMS ] = {
;	       FP_PLOT_MODE_PLOT_ONLY,  FP_PLOT_MODE_PLOT_ONLY,
;	       FP_PLOT_MODE_PLOT_ONLY,  FP_PLOT_MODE_PLOT_ONLY,
;          };                
		les bx, dword ptr [bp+006h] ; int *ipm
		mov ax, es:[bx]
		assume  ds:DGROUP		
		mov	$S1,ax                  ;int *ipm plot mode switch
		les	bx,dword ptr [bp+00ah]  ;address of struct plot *sp
		mov	word ptr $S2,es         ;ptr to sp
		mov	$S3,bx                  ;ptr to sp
		mov	eax,es:[bx]             ;move 4 bytes
		mov	$S4,eax                 ;iscale
		mov	ax,es:[bx+006h]         ;n
		mov	$S5,ax                  ;n
		mov	ax,es:[bx+008h]         ;nperstrip
		mov	$S6,ax                  ;nperstrip
		mov	ax,es:[bx+00Ah]         ;startpoint
		mov	$S7,ax                  ;startpoint
		add	ax,ax                   ;zero
		add	ax,bx                   ;address of bp+00ah (struct plot *sp)
		mov	$S8,ax                  ;move sp to $S8
		mov	ax,es:[bx+00Ch]         ;stripdel
		mov	$S9,ax                  ;stripdel
		mov	eax,es:[bx+020h]        ;lastremainder
		mov	$S10,eax                ;lastremainder
		mov	ax,es:[bx+00Eh]         ;xoff
		add	ax,es:[bx+00Ah]         ;startpoint address
		mov	$S11,ax                 ;startpoint address      
		mov	ax,es:[bx+010h]         ;yoff
		mov	$S12,ax                 ;yoff
		mov	ax,es:[bx+016h]         ;color
		mov	$S13,al                 ;move low byte ;color
		mov	ax,es:[bx+018h]         ;idel
		mov	$S14,ax                 ;idel
		mov	ax,es:[bx+01Ah]         ;irec
		mov	$S15,ax                 ;irec
		mov	ax,es:[bx+01Ch]         ;type  
		mov	$S16,ax                 ;type
		lea	ax,[bx+024h]            ;address of trans
		mov	$S17,ax                 ;address of trans 
		lea	ax,[bx+0124h]           ;address of table
		mov	$S18,ax                 ;address of table 
		mov	word ptr [bp-002h],0A000h ; pointer to graphics buffer
		push	cs                    ;save code segment 
		call	_fplot_egainit        ;init ega
		cmp	word ptr $S1,+000h        ;if FP_PLOT_MODE_ERASE_ONLY          
		jz	$L19                      ;then jump to $L19
		mov	bx,$S7                    ;move startpoint to bx 
		mov	ax,bx                     ;then move to ax
		add	ax,$S6                    ;add nperstrip to startpoint
		mov	cx,$S5                    ;move n to cx(counter)
		cmp	ax,cx                     ;if nperstrip < n
		jl	$L20                      ;goto $L20
		mov	bx,cx                     ; move n to bx
		sub	bx,$S7                    ; subtract startpoint from bx
		mov	word ptr $S7,0000h        ; zero out startpoint
		jmp	short $L21                ; jump to $L21
	$L20:	
	    mov	bx,$S6                    ; move startpoint to bx
		inc	bx                        ;increment bx 
		mov	$S7,ax                    ;move nperstrip to startpoint
	$L21:	
	    mov	$S22,bx                   ;move startpoint+1 to $S22
		cmp	dword ptr $S4,00010000h   ;compare iscale to 65536
		jbe	$L23                      ;if iscale <= 65536 then goto $L23
		mov	eax,$S10                  ;move lastremainder to eax (four bytes)
		mov	$S24,eax                  ;move lastremainder to temp
		mov	ax,$S7                    ;move startpoint to ax
		mov	di,$S8                    ;move sp to di 
		add	di,08A4h                  ;add 2212 to di
		les	si,dword ptr [bp+00Eh]    ;load si with *buff
		mov	word ptr $S25,es          ;move es to $S25 
		add	si,$S14                   ;add idel to si
		add	si,$S9                    ;add stripdel to si
		push	ebp                   ;save base pointer
		mov	ebp,$S4                   ;move iscale to base pointer
		cmp	word ptr $S16,+002h       ;compare 2 (FP_PLOT_MODE_PLOT_ONLY) to type 
		jnz	$L26                      ;if not FP_PLOT_MODE_PLOT_ONLY then go to $L26
	$L32:	
		mov	$S27,si                      ;save si to $S27
		mov	dl,es:[si]                   ;move byte from *buff+idel+stripdel to dl
		inc	si                           ;increment *buff+idel+stripdel 
		mov	dh,dl                        ;move byte from low byte to high byte
		add	$S24,ebp                     ;add base pointer to lastremainder
		mov	cx,word ptr $S24 + 00002h    ;add $S24+2 to cx
		mov	word ptr $S24 + 00002h,0000h ;move zero to $S24+2
		dec	cx                           ;dec $S24+2
		jz	$L28                         ;jump when zero to $L28
	$L31:
		mov	al,es:[si]
		inc	si
		cmp	al,dl
		jnl	$L29
		mov	dl,al
		jmp	short $L30
	$L29:	cmp	al,dh
		jng	$L30
		mov	dh,al
	$L30:	loop	$L31
	$L28:	mov	es,word ptr $S2
		mov	es:[di],dx
		add	di,+002h
		mov	es,word ptr $S25
		dec	bx
		jnz	$L32
		jmp	short $L33
	$L26:	mov	$S27,si                ;
		mov	dl,es:[si]
		inc	si
		mov	dh,dl
		add	$S24,ebp
		mov	cx,word ptr $S24 + 00002h
		mov	word ptr $S24 + 00002h,0000h
		dec	cx
		jz	$L34
	$L37:	mov	al,es:[si]
		inc	si
		cmp	al,dl
		jnc	$L35
		mov	dl,al
		jmp	short $L36
	$L35:	cmp	al,dh
		jbe	$L36
		mov	dh,al
	$L36:	loop	$L37
	$L34:	mov	es,word ptr $S2
		mov	es:[di],dx
		add	di,+002h
		mov	es,word ptr $S25
		dec	bx
		jnz	$L26
	$L33:	pop	ebp
		mov	si,$S27
		sub	si,[bp+00Eh]
		sub	si,$S14
		mov	$S9,si
		push	ds
		mov	di,$S8
		add	di,08A4h
		mov	cx,$S22
		add	cx,cx
		mov	bx,$S17
		mov	ds,word ptr $S2
	$L38:	mov	al,[di]
		xlat
		mov	[di],al
		inc	di
		loop	$L38
		pop	ds
		cmp	word ptr $S15,-001h
		jnz	$L39
		mov	di,$S8
		add	di,08A4h
		mov	cx,$S22
		mov	es,word ptr $S2
		cmp	word ptr $S16,+002h
		jnz	$L40
	$L42:	mov	ax,es:[di]
		cmp	al,ah
		jng	$L41
		xchg	al,ah
		mov	es:[di],ax
	$L41:	add	di,+002h
		loop	$L42
		jmp	short $L39
	$L40:	mov	ax,es:[di]
		cmp	al,ah
		jbe	$L43
		xchg	al,ah
		mov	es:[di],ax
	$L43:	add	di,+002h
		loop	$L40
	$L39:	mov	es,word ptr $S2
		mov	di,$S8
		add	di,08A4h
		mov	cx,$S22
		dec	cx
		cmp	word ptr $S16,+002h
		jnz	$L44
	$L47:	mov	ax,es:[di]
		mov	dx,es:[di+002h]
		cmp	dl,ah
		jng	$L45
		mov	ah,dl
		jmp	short $L46
	$L45:	cmp	dh,al
		jnl	$L46
		mov	al,dh
	$L46:	mov	es:[di],ax
		add	di,+002h
		loop	$L47
		jmp	short $L48
	$L44:	mov	ax,es:[di]
		mov	dx,es:[di+002h]
		cmp	dl,ah
		jbe	$L49
		mov	ah,dl
		jmp	short $L50
	$L49:	cmp	dh,al
		jnc	$L50
		mov	al,dh
	$L50:	mov	es:[di],ax
		add	di,+002h
		loop	$L44
	$L48:	mov	di,$S8
		add	di,03A4h
		mov	cx,$S22
		dec	cx
		mov	si,$S11
		mov	$S51,si
		cmp	word ptr $S16,+002h
		jnz	$L52
	$L55:	mov	dx,es:[di+0500h]
		mov	al,dl
		cbw
		mov	bx,ax
		add	bx,$S12
		sub	dl,dh
		neg	dl
		jnz	$L53
		inc	dl
	$L53:	push	cx
		add	bx,bx
		mov	bx,[bx+_video]
		mov	ax,si
		mov	cl,03h
		sar	ax,cl
		add	bx,ax
		and	si,+007h
		mov	al,[si+$S54]
		pop	cx
		mov	dh,al
		mov	es:[di],dx
		mov	es:[di+0500h],bx
		add	di,+002h
		mov	si,$S51
		inc	si
		mov	$S51,si
		loop	$L55
		jmp	$L19
	$L52:	mov	dx,es:[di+0500h]
		mov	bl,dl
		xor	bh,bh
		add	bx,$S12
		sub	dl,dh
		neg	dl
		jnz	$L56
		inc	dl
	$L56:	push	cx
		add	bx,bx
		mov	bx,[bx+_video]
		mov	ax,si
		mov	cl,03h
		sar	ax,cl
		add	bx,ax
		and	si,+007h
		mov	al,[si+$S54]
		pop	cx
		mov	dh,al
		mov	es:[di],dx
		mov	es:[di+0500h],bx
		add	di,+002h
		mov	si,$S51
		inc	si
		mov	$S51,si
		loop	$L52
		jmp	$L19
	$L23:	cmp	dword ptr $S4,00010000h     ;iscale <= 65536
		jnc	$L57
		mov	ax,$S2
		push	ax
		mov	ax,$S8
		add	ax,08A4h
		push	ax
		les	si,dword ptr [bp+00Eh]         ;move addres of buff to si
		add	si,$S14                        ;add idel to si
		push	es                         ;save buff address on stack
		push	si                         ;save buff address on stack
		mov	eax,$S10                       ;move lastremainder to eax
		push	eax                        ;save on stack
		mov	eax,$S4                        ;move iscale to eax
		push	eax                        ;save on stack 
		push	bx                         ;save on stack 
		cmp	word ptr $S16,+002h            ;compare type to FP_PLOT_MODE_PLOT_ONLY (2) 
		jnz	$L58                           ;jump and call _interlbklfp
		call	far ptr FPLOTKL_TEXT:_interlklfp
		jmp	short $L59                     ;jump to $L59
	$L58:	call	far ptr FPLOTKL_TEXT:_interlbklfp
	$L59:	add	sp,+012h
		mov	$S24,eax
		push	ds
		mov	es,word ptr $S2
		mov	cx,$S5
		mov	bx,$S17
		mov	di,$S18
		mov	si,$S8
		add	si,08A4h
		mov	ds,word ptr $S2
	$L60:	mov	al,[si]
		inc	si
		xlat
		mov	[di],al
		inc	di
		loop	$L60
		pop	ds
		jmp	short $L61
	$L57:	push	ds
		mov	es,word ptr $S2
		mov	cx,bx
		mov	bx,$S17
		mov	di,$S18
		mov	ax,$S14
		add	ax,$S9
		lds	si,dword ptr [bp+00Eh]
		add	si,ax
	$L62:	lodsb
		xlat
		stosb
		loop	$L62
		pop	ds
		mov	ax,$S22
		dec	ax
		add	$S9,ax
	$L61:	mov	cx,$S22
		dec	cx
		mov	es,word ptr $S2
		mov	bx,$S18
		mov	di,$S8
		add	di,03A4h
		mov	si,$S11
		mov	$S51,si
		cmp	word ptr $S16,+002h
		jnz	$L63
	$L66:	mov	ax,es:[bx]
		mov	dl,ah
		cmp	al,dl
		jnl	$L64
		xchg	al,dl
	$L64:	sub	al,dl
		mov	ah,00h
		or	al,al
		jnz	$L65
		mov	al,01h
	$L65:	mov	es:[di],ax
		mov	al,dl
		cbw
		add	ax,$S12
		push	cx
		push	bx
		mov	bx,ax
		add	bx,bx
		mov	bx,[bx+_video]
		mov	ax,si
		mov	cl,03h
		sar	ax,cl

		add	bx,ax
		and	si,+007h
		mov	al,[si+$S54]
		mov	es:[di+0500h],bx
		mov	es:[di+001h],al
		pop	bx
		pop	cx
		inc	bx
		mov	si,$S51
		inc	si
		mov	$S51,si
		add	di,+002h
		loop	$L66
		jmp	short $L19
	$L63:	mov	ax,es:[bx]
		mov	dl,ah
		cmp	al,dl
		jnc	$L67
		xchg	al,dl
	$L67:	sub	al,dl
		mov	ah,00h
		or	al,al
		jnz	$L68
		mov	al,01h
	$L68:	mov	es:[di],ax
		mov	dh,00h
		add	dx,$S12
		push	cx
		push	bx
		mov	bx,dx
		add	bx,bx
		mov	bx,[bx+_video]
		mov	ax,si
		mov	cl,03h
		sar	ax,cl
		add	bx,ax
		and	si,+007h
		mov	al,[si+$S54]
		mov	es:[di+0500h],bx
		mov	es:[di+001h],al
		pop	bx
		pop	cx
		inc	bx
		mov	si,$S51
		inc	si
		mov	$S51,si
		add	di,+002h
		loop	$L63
	$L19:	mov	di,$S8 ;FP_PLOT_MODE_ERASE_ONLY
		mov	dx,_nucol
		mov	cx,$S22
		dec	cx
		cmp	word ptr $S1,+000h
		jnz	$L69
		push	ds
		mov	ds,word ptr [bp-002h]
	$L71:	push	cx
		mov	bx,es:[di+12A4h]
		mov	cx,es:[di+0DA4h]
		mov	al,ch
		xor	ch,ch
	$L70:	mov	ah,[bx]
		mov	[bx],al
		sub	bx,dx
		loop	$L70
		add	di,+002h
		pop	cx
		loop	$L71
		pop	ds
		jmp	$L72
	$L69:	cmp	word ptr $S1,+001h
		jnz	$L73
		push	ds
		mov	ds,word ptr [bp-002h]
	$L76:	push	cx
		mov	bx,es:[di+12A4h]
		mov	cx,es:[di+0DA4h]
		mov	al,ch
		xor	ch,ch
	$L74:	mov	ah,[bx]
		mov	[bx],al
		sub	bx,dx
		loop	$L74
		mov	bx,es:[di+08A4h]
		mov	es:[di+12A4h],bx
		mov	cx,es:[di+03A4h]
		mov	es:[di+0DA4h],cx
		mov	al,ch
		xor	ch,ch
	$L75:	mov	ah,[bx]
		mov	[bx],al
		sub	bx,dx
		loop	$L75
		add	di,+002h
		pop	cx
		loop	$L76
		pop	ds
		jmp	short $L72
	$L73:	cmp	word ptr $S1,+002h
		jz	$L77
		cmp	word ptr $S1,+003h
		jnz	$L72
	$L77:	push	ds
		mov	ds,word ptr [bp-002h]
	$L79:	push	cx
		mov	bx,es:[di+08A4h]
		mov	es:[di+12A4h],bx
		mov	cx,es:[di+03A4h]
		mov	es:[di+0DA4h],cx
		mov	al,ch
		xor	ch,ch
	$L78:	mov	ah,[bx]
		mov	[bx],al
		sub	bx,dx
		loop	$L78
		add	di,+002h
		pop	cx
		loop	$L79
		pop	ds
	$L72:	mov	ax,$S7
		les	bx,dword ptr [bp+00Ah]
		mov	es:[bx+00Ah],ax
		or	ax,ax
		jnz	$L80
		mov	word ptr es:[bx+00Ch],0000h
		mov	dword ptr es:[bx+020h],00000000h
		cmp	word ptr $S1,+000h
		jnz	$L81
		mov	word ptr $S1,0002h
		jmp	short $L82
	$L81:	cmp	word ptr $S1,+001h
		jnz	$L83
		mov	word ptr $S1,0001h
		jmp	short $L82
	$L83:	cmp	word ptr $S1,+002h
		jnz	$L82
		cmp	word ptr $S1,+003h
		jz	$L84
		mov	word ptr $S1,0001h
	$L84:	jmp	short $L82
	$L80:	mov	ax,$S9
		mov	es:[bx+00Ch],ax
		mov	eax,$S24
		mov	es:[bx+020h],eax
	$L82:	mov	ax,$S1
		les	bx,dword ptr [bp+006h]
		mov	es:[bx],ax
		push	cs
		call	near ptr _fplot_restor
		pop	es
		pop	ds
		pop	si
		pop	di
		pop	dx
		pop	ecx
		pop	bx
		pop	eax
		pop	ds
		mov	sp,bp
		pop	bp
		retf
	_fplot_egainit:
		mov	dx,03CEh
		mov	al,03h
		out	dx,al
		mov	dx,03CFh
		cmp	word ptr $S1,+003h
		jz	$L85
		mov	al,18h
		jmp	short $L86
	$L85:	mov	al,10h
	$L86:
		out	dx,al
		mov	dx,03C4h
		mov	al,02h
		out	dx,al
		mov	dx,03C5h
		mov	al,$S13
		out	dx,al
		mov	dx,03CEh
		mov	al,08h
		out	dx,al
		mov	dx,03CFh
		mov	al,0FFh
		out	dx,al
		retf
	_fplot_restor:
		mov	dx,03CEh
		mov	al,05h
		out	dx,al
		mov	dx,03CFh
		mov	al,00h
		out	dx,al
		mov	dx,03CEh
		mov	al,08h
		out	dx,al
		mov	dx,03CFh
		mov	al,0FFh
		out	dx,al
		mov	dx,03CEh
		mov	al,03h
		out	dx,al
		mov	dx,03CFh
		mov	al,00h
		out	dx,al
		retf
	_interlbklfp:
		push	bp
		mov	bp,sp
		push	ebx
		push	cx
		push	edx
		push	esi
		push	edi
		push	ds
		push	es
		push	fs
		mov	cx,[bp+006h]
		mov	ebx,[bp+008h]
		mov	edx,[bp+00Ch]
		les	di,dword ptr [bp+014h]
		lfs	si,dword ptr [bp+010h]
		push	ebp
		mov	ebp,ebx
		mov	ebx,edx
		shr	ebx,10h
	$L89:	mov	$S87,edx
		mov	ax,fs:[bx+si]
		mov	bl,al
		sub	al,ah
		jnbe	$L88
		neg	al
		mul	dh
		add	ah,bl
		mov	es:[di],ah
		inc	di
		add	edx,ebp
		mov	ebx,edx
		shr	ebx,10h
		dec	cx
		jnz	$L89
		pop	ebp
		mov	eax,$S87
		pop	fs
		pop	es
		pop	ds
		pop	edi
		pop	esi
		pop	edx
		pop	cx
		pop	ebx
		pop	bp
		retf
	$L88:	mul	dh
		neg	ah
		add	ah,bl
		mov	es:[di],ah
		inc	di
		add	edx,ebp
		mov	ebx,edx
		shr	ebx,10h
		dec	cx
		jnz	$L89
		pop	ebp
		mov	eax,$S87
		pop	fs
		pop	es
		pop	ds
		pop	edi
		pop	esi
		pop	edx
		pop	cx
		pop	ebx
		pop	bp
		retf
	_interlklfp:
		push	bp
		mov	bp,sp
		push	ebx
		push	cx
		push	edx
		push	esi
		push	edi
		push	ds
		push	es
		push	fs
		mov	cx,[bp+006h]
		mov	ebx,[bp+008h]
		mov	edx,[bp+00Ch]
		les	di,dword ptr [bp+014h]
		lfs	si,dword ptr [bp+010h]
		push	ebp
		mov	ebp,ebx
		mov	ebx,edx
		shr	ebx,10h
	$L91:	mov	$S87,edx
		mov	ax,fs:[bx+si]
		mov	bl,al
		sub	al,ah
		jg	$L90
		neg	al
		mul	dh
		add	ah,bl
		mov	es:[di],ah
		inc	di
		add	edx,ebp
		mov	ebx,edx
		shr	ebx,10h
		dec	cx
		jnz	$L91
		pop	ebp
		mov	eax,$S87
		pop	fs
		pop	es
		pop	ds
		pop	edi
		pop	esi
		pop	edx
		pop	cx
		pop	ebx
		pop	bp
		retf
	$L90:	mul	dh
		neg	ah
		add	ah,bl
		mov	es:[di],ah
		inc	di
		add	edx,ebp
		mov	ebx,edx
		shr	ebx,10h
		dec	cx
		jnz	$L91
		pop	ebp
		mov	eax,$S87
		pop	fs
		pop	es
		pop	ds
		pop	edi
		pop	esi
		pop	edx
		pop	cx
		pop	ebx
		pop	bp
		retf
	FPLOTKL_TEXT	ENDS
		END
