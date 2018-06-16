; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

	TITLE	fppkfind.asm
	.586
	.MODEL flat, c
	.DATA	

$S4	db	000h
	db	001h
	db	002h
	db	003h
	db	004h
	db	005h
	db	006h
	db	007h
	db	008h
	db	009h
	db	00Ah
	db	00Bh
	db	00Ch
	db	00Dh
	db	00Eh
	db	00Fh
	db	010h
	db	011h
	db	012h
	db	013h
	db	014h
	db	015h
	db	016h
	db	017h
	db	018h
	db	019h
	db	01Ah
	db	01Bh
	db	01Ch
	db	01Dh
	db	01Eh
	db	01Fh
	db	' !"#$'
	db	'%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]'
	db	'^_`abcdefghijklmnopqrstuvwxyz{|}~'
	db	07Fh
	db	07Fh
	db	07Fh
	db	'~}|{zyxwvutsrqponmlkjihgfedcba`_^]\[ZYXWVUTSRQPONMLKJIHGFE'
	db	'DCBA@?>=<;:9876543210/.-,+*)(''&%$'
	db	'#"! '
	db	01Fh
	db	01Eh
	db	01Dh
	db	01Ch
	db	01Bh
	db	01Ah
	db	019h
	db	018h
	db	017h
	db	016h
	db	015h
	db	014h
	db	013h
	db	012h
	db	011h
	db	010h
	db	00Fh
	db	00Eh
	db	00Dh
	db	00Ch
	db	00Bh
	db	00Ah
	db	009h
	db	008h
	db	007h
	db	006h
	db	005h
	db	004h
	db	003h
	db	002h
	db	001h
tof dd  00000000h
;int   fp_peak_find( char *buff,                   bp+006
;			         unsigned length,              bp+00A
;					 int threshold,                bp+00c
;                    int threshold_sense,		   bp+00e
;					 int absolute_value,		   bp+10
;                    int data_type,				   bp+12
;					 int edge_level_logic,		   bp+14
;                    unsigned *time_of_flight );   bp+16	
;	
.CODE
fp_peak_find_asm proc buff:ptr sbyte, lengthp:word, threshold:sword, threshold_sense:sword,absolute_value:sword,data_type:sword, edge_level_logic:sword, time_of_flight:ptr word
	cld
	xor ecx,ecx	
	xor esi,esi
	mov	edi,buff
	mov	tof,edi
	mov	si,  lengthp
	cmp	word ptr edge_level_logic,+000h
	jnz	$L1
	cmp	word ptr absolute_value,+000h
	jz	$L2
	xor	bh,bh
	mov	ax,0FFFFh
	mov	dh,byte ptr threshold
	dec	edi	
$L10:
    mov	ecx,esi
	and	esi,+003h
	and	ecx,-004h
	jz	$L3
$L9:	
	mov	bl,[edi+001h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jbe	$L5
	mov	dh,dl
	mov	eax,edi
	inc	eax
	mov	bl,[edi+002h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jbe	$L6
	mov	dh,dl
	inc	eax
	mov	bl,[edi+003h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jbe	$L7
	mov	dh,dl
	inc	eax
	mov	bl,[edi+004h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jbe	$L8
	mov	dh,dl
	inc	eax
$L8:
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L9
	jz	$L10
$L7:
	mov	bl,[edi+004h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jnle	$L11
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L9
	jz	$L10
$L6:
	mov	bl,[edi+003h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jnle	$L12
	mov	bl,[edi+004h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jnle	$L11
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L9
	jz	$L10
$L5:
	mov	bl,[edi+002h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jg	$L13
	mov	bl,[edi+003h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jg	$L12
	mov	bl,[edi+004h]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jg	$L11
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L9
	jz	$L10
$L3:	inc	edi
$L17:
	or	esi,esi
	jz	$L14
$L16:
	mov	bl,[edi]
	mov	dl,[ebx+$S4]
	cmp	dl,dh
	jg	$L15
	inc	edi
	dec	esi
	jnz	$L16
$L14:
	mov	edi, time_of_flight
	sub	eax,tof
	mov	[edi],ax
	mov	al,dh
	xor	ah,ah
	ret
$L13:
	mov	dh,dl
	add	edi,+002h
	mov	eax,edi
	add	esi,+002h
	sub	ecx,+004h
	jnz	$L9
	jz	$L10
$L12:
	mov	dh,dl
	add	edi,+003h
	mov	eax,edi
	inc	esi
	sub	ecx,+004h
	jnz	$L9
	jz	$L10
$L11:
	mov	dh,dl
	add	edi,+004h
	mov	eax,edi
	sub	ecx,+004h
	jnz	$L9
	jz	$L10
$L15:
	mov	dh,dl
	mov	eax,edi
	inc	edi
	dec	esi
	jnz	$L17
	jz	$L14
	jmp	$L18
$L2:
	cmp	word ptr threshold_sense,+001h
	jnz	$L19
	mov	eax,0FFFFh
	mov	dh,byte ptr threshold
	dec	edi
$L26:
	mov	ecx,esi
	and	esi,+003h
	and	ecx,-004h
	jz	$L20
$L25:
	mov	dl,[edi+001h]
	cmp	dl,dh
	jng	$L21
	mov	dh,dl
	mov	eax,edi
	inc	eax
	mov	dl,[edi+002h]
	cmp	dl,dh
	jng	$L22
	mov	dh,dl
	inc	eax
	mov	dl,[edi+003h]
	cmp	dl,dh
	jng	$L23
	mov	dh,dl
	inc	eax
	mov	dl,[edi+004h]
	cmp	dl,dh
	jng	$L24
	mov	dh,dl
	inc	eax
$L24:
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L25
	jz	$L26
$L23:
	mov	dl,[edi+004h]
	cmp	dl,dh
	jnle	$L27
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L25
	jz	$L26
$L22:
	mov	dl,[edi+003h]
	cmp	dl,dh
	jg	$L28
	mov	dl,[edi+004h]
	cmp	dl,dh
	jg	$L27
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L25
	jz	$L26
$L21:
	mov	dl,[edi+002h]
	cmp	dl,dh
	jg	$L29
	mov	dl,[edi+003h]
	cmp	dl,dh
	jg	$L28
	mov	dl,[edi+004h]
	cmp	dl,dh
	jg	$L27
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L25
	jz	$L26
$L20:	inc	edi
$L33:	or	esi,esi
	jz	$L30
$L32:	mov	dl,[edi]
	cmp	dl,dh
	jg	$L31
	inc	edi
	dec	esi
	jnz	$L32
$L30:	
	mov	edi,dword ptr time_of_flight
	sub	eax,tof
	mov	[edi],ax
	mov	al,dh
	xor	ah,ah
	ret
$L29:
	mov	dh,dl
	add	edi,+002h
	mov	eax,edi
	add	esi,+002h
	sub	ecx,+004h
	jnz	$L25
	jz	$L26
$L28:
	mov	dh,dl
	add	edi,+003h
	mov	eax,edi
	inc	esi
	sub	ecx,+004h
	jnz	$L25
	jz	$L26
$L27:
	mov	dh,dl
	add	edi,+004h
	mov	eax,edi
	sub	ecx,+004h
	jnz	$L25
	jz	$L26
$L31:
	mov	dh,dl
	mov	eax,edi
	inc	edi
	dec	esi
	jnz	$L33
	jz	$L30
	jmp	$L34
$L19:
	mov	eax,0FFFFh
	mov	dh,byte ptr threshold
	dec	edi
$L41:
	mov	ecx,esi
	and	esi,+003h
	and	ecx,-004h
	jz	$L35
$L40:
	mov	dl,[edi+001h]
	cmp	dl,dh
	jnl	$L36
	mov	dh,dl
	mov	eax,edi
	inc	eax
	mov	dl,[edi+002h]
	cmp	dl,dh
	jnl	$L37
	mov	dh,dl
	inc	eax
	mov	dl,[edi+003h]
	cmp	dl,dh
	jnl	$L38
	mov	dh,dl
	inc	eax
	mov	dl,[edi+004h]
	cmp	dl,dh
	jnl	$L39
	mov	dh,dl
	inc	eax
$L39:
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L40
	jz	$L41
$L38:
	mov	dl,[edi+004h]
	cmp	dl,dh
	jl	$L42
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L40
	jz	$L41
$L37:	
	mov	dl,[edi+003h]
	cmp	dl,dh
	jl	$L43
	mov	dl,[edi+004h]
	cmp	dl,dh
	jl	$L42
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L40
	jz	$L41
$L36:
	mov	dl,[edi+002h]
	cmp	dl,dh
	jl	$L44
	mov	dl,[edi+003h]
	cmp	dl,dh
	jl	$L43
	mov	dl,[edi+004h]
	cmp	dl,dh
	jl	$L42
	add	edi,+004h
	sub	ecx,+004h
	jnz	$L40
	jz	$L41
$L35:
	inc	edi
$L48:
	or	esi,esi
	jz	$L45
$L47:
	mov	dl,[edi]
	cmp	dl,dh
	jl	$L46
	inc	edi
	dec	esi
	jnz	$L47
$L45:	
    mov	edi, time_of_flight
	sub	eax,tof
	mov	[edi],ax
	mov	al,dh
	xor	ah,ah
	ret
$L44:
	mov	dh,dl
	add	edi,+002h
	mov	eax,edi
	add	esi,+002h
	sub	ecx,+004h
	jnz	$L40
	jz	$L41
$L43:
	mov	dh,dl
	add	edi,+003h
	mov	eax,edi
	inc	esi
	sub	ecx,+004h
	jnz	$L40
	jz	$L41
$L42:
	mov	dh,dl
	add	edi,+004h
	mov	eax,edi
	sub	ecx,+004h
	jnz	$L40
	jz	$L41
$L46:
	mov	dh,dl
	mov	eax,edi
	inc	edi
	dec	esi
	jnz	$L48
	jz	$L45
$L34:
	jmp	$L18
$L1:
	cmp	word ptr absolute_value,+000h
	jz	$L49
	mov	dh, byte ptr threshold
	xor	bh,bh
	mov	ecx,esi
	and	esi,+007h
	and	ecx,-008h
	jz	$L50
$L59:
	mov	bl,[edi]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L51
	mov	bl,[edi+001h]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L52
	mov	bl,[edi+002h]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L53
	mov	bl,[edi+003h]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L54
	mov	bl,[edi+004h]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L55
	mov	bl,[edi+005h]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L56
	mov	bl,[edi+006h]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L57
	mov	bl,[edi+007h]
	mov	al,[ebx+$S4]
	cmp	al,dh
	jnle	$L58
	add	edi,+008h
	sub	ecx,+008h
	jnz	$L59
$L50:	or	esi,esi
	jz	$L60
$L62:	mov	al,[edi]
	cmp	al,dh
	jnle	$L61
	inc	edi
	dec	esi
	jnz	$L62
$L60:
	xor	eax,eax
	ret
$L51:
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L52:
	inc	edi
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L53:
	add	edi,+002h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L54:
	add	edi,+003h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L55:
	add	edi,+004h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L56:
	add	edi,+005h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L57:
	add	edi,+006h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L58:
	add	edi,+007h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
$L61:
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor eax,eax
	mov	eax,0001h
	ret
	jmp	$L18
$L49:
	cmp	word ptr threshold_sense,+001h
	jnz	$L63
	mov	dh, byte ptr threshold
	mov	ecx,esi
	and	esi,+007h
	and	ecx,-008h
	jz	$L64
$L73:
	mov	eax,[edi]
	cmp	al,dh
	jg	$L65
	cmp	ah,dh
	jg	$L66
	mov	eax,[edi+002h]
	cmp	al,dh
	jg	$L67
	cmp	ah,dh
	jnle	$L68
	mov	eax,[edi+004h]
	cmp	al,dh
	jnle	$L69
	cmp	ah,dh
	jnle	$L70
	mov	eax,[edi+006h]
	cmp	al,dh
	jnle	$L71
	cmp	ah,dh
	jnle	$L72
	add	edi,+008h
	sub	ecx,+008h
	jnz	$L73
$L64:
	or	esi,esi
	jz	$L74
$L76:
	mov	al,[edi]
	cmp	al,dh
	jnle	$L75
	inc	edi
	dec	esi
	jnz	$L76
$L74:
	xor	eax,eax
	ret
$L65:
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L66:
	inc	edi
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L67:
	add	edi,+002h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L68:
	add	edi,+003h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L69:
	add	edi,+004h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L70:
	add	edi,+005h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L71:
	add	edi,+006h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L72:
	add	edi,+007h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L75:
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
	jmp	$L18
$L63:
	mov	dh, byte ptr threshold
	mov	ecx,esi
	and	esi,+007h
	and	ecx,-008h
	jz	$L77
$L86:
	mov	eax,[edi]
	cmp	al,dh
	jl	$L78
	cmp	ah,dh
	jl	$L79
	mov	eax,[edi+002h]
	cmp	al,dh
	jl	$L80
	cmp	ah,dh
	jl	$L81
	mov	eax,[edi+004h]
	cmp	al,dh
	jl	$L82
	cmp	ah,dh
	jl	$L83
	mov	eax,[edi+006h]
	cmp	al,dh
	jl	$L84
	cmp	ah,dh
	jl	$L85
	add	edi,+008h
	sub	ecx,+008h
	jnz	$L86
$L77:
	or	esi,esi
	jz	$L87
$L89:
	mov	al,[edi]
	cmp	al,dh
	jl	$L88
	inc	edi
	dec	esi
	jnz	$L89
$L87:
	xor	eax,eax
	ret
$L78:
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L79:
	inc	edi
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L80:
	add	edi,+002h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L81:
	add	edi,+003h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L82:
	add	edi,+004h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L83:
	add	edi,+005h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h	
	ret
$L84:
	add	edi,+006h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax	
	mov	eax,0001h
	ret
$L85:
	add	edi,+007h
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di
	xor	eax,eax
	mov	eax,0001h
	ret
$L88:
	sub	edi,tof
	mov	ebx,time_of_flight
	mov [ebx],di	
	xor	eax,eax
	mov	eax,0001h
	ret
$L18:	
	ret
fp_peak_find_asm	endp
	END
