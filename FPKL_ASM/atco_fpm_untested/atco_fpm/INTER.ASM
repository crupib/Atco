	TITLE	inter.asm
	.586
	.MODEL flat, c

.stack	512
.data  
 stackholder2 dw 1 dup(?)
 stackholder4 dw 1 dup(?)
 stackholder44 dd 1 dup(?) ; 16bit
.code
; ///////////////////////////////////////////////////
; 16-bit routines
; ///////////////////////////////////////////////////
interlb_asm proc n:word, incr:dword, bufi:dword, bufo:dword
	mov	esi,dword ptr bufi
	mov	edi,dword ptr bufo
	xor ecx,ecx
	mov	cx,n
	;dec	cx
	mov	dx,word ptr incr
	mov	word ptr stackholder4,0000h
	mov	word ptr stackholder2,0000h
	mov	ebx,0000h
$L13:
	mov	eax,esi
	add	eax,ebx
	cmp	eax,-001h
	jc	$L9
	mov	esi,0000h
$L9:
	mov	eax,[ebx+esi]
	mov	bl,al
	sub	al,ah
	pushf
	jnbe	$L10
	neg	al
$L10:	
	mul	byte ptr stackholder2+1
	mov	al,ah
	popf
	jc	$L11
	neg	al
$L11:
	add	al,bl
	stosb
	add	stackholder4,dx
	jnc	$L12
	add	word ptr stackholder2,+001h
$L12:
	mov	ax,word ptr incr+2
	add	stackholder2,ax
	mov	bx,stackholder2
	loop	$L13
	ret
interlb_asm endp	

;void  interl( short int n,  unsigned long inc,  char *bufi,  char *bufo);
interl_asm proc n:word, incr:dword, bufi:dword, bufo:dword
	mov	esi,dword ptr bufi
	mov	edi,dword ptr bufo
	xor ecx,ecx
	mov	cx,n
	dec	cx
	mov	dx,word ptr incr
	mov	word ptr stackholder4,0000h
	mov	word ptr stackholder2,0000h
	mov	ebx,0000h	
$L18:	
	mov	eax,esi
	add	eax,ebx
	cmp	eax,-001h
	jc	$L14
	mov	esi,0000h
$L14:
	mov	eax,[ebx+esi]
	mov	bl,al
	sub	al,ah
	pushf
	jg	$L15
	neg	al
$L15:
	mul	byte ptr stackholder2+1
	mov	al,ah
	popf
	jl	$L16
	neg	al
$L16:
	add	al,bl
	stosb
	add	stackholder4,dx
	jnc	$L17
	add	word ptr stackholder2,+001h
$L17:	
    mov	ax,word ptr incr+2
	add	stackholder2,ax
	mov	bx,stackholder2
	loop	$L18
	ret
interl_asm endp	

; ///////////////////////////////////////////////////
; 32-bit routines
; ///////////////////////////////////////////////////

;;----------------------------------------------------------------------
;void  interlb32( int n,  int incr,  void *bufi,  void *bufo );
;----------------------------------------------------------------------
interlb32_asm proc n:dword, incr:qword, bufi:dword, bufo:dword
	mov	esi,dword ptr bufi
	mov	edi,dword ptr bufo
	xor ecx,ecx
	mov	ecx,n
;	dec	ecx
	mov	edx, dword ptr incr
	mov	stackholder44,0000h
	mov	stackholder2,0000h
	mov	ebx,0000h
$L13:
	mov	eax,esi
	add	eax,ebx
	cmp	eax,-001h
	jc	$L9
	mov	esi,0000h
$L9:
	mov	eax,[ebx+esi]
	mov	bl,al
	sub	al,ah
	pushf
	jnbe	$L10
	neg	al
$L10:	
	mul	byte ptr stackholder2+1
	mov	al,ah
	popf
	jc	$L11
	neg	al
$L11:
	add	al,bl
	stosb
	add	stackholder44,edx
	mov eax, stackholder44
	cmp eax,1048575
	jl  $L12
    and stackholder44,0FF0FFFFFh
	add	word ptr stackholder2,+001h
$L12:
	mov	ax,word ptr incr+3
	add	stackholder2,ax
	mov	bx,stackholder2
	loop	$L13
	ret
interlb32_asm endp
	
;void  interl32( int n,  unsigned long inc,  char *bufi,  char *bufo);
interl32_asm proc n:dword, incr:dword, bufi:dword, bufo:dword
	mov	esi,dword ptr bufi
	mov	edi,dword ptr bufo
	xor ecx,ecx
	mov	ecx,n
	;dec	cx
	mov	edx,dword ptr incr
	mov	stackholder44,0000h
	mov	stackholder2,0000h
	mov	ebx,0000h	
$L18:	
	mov	eax,esi
	add	eax,ebx
	cmp	eax,-001h
	jc	$L14
	mov	esi,0000h
$L14:
	mov	eax,[ebx+esi]
	mov	bl,al
	sub	al,ah
	pushf
	jg	$L15
	neg	al
$L15:
	mul	byte ptr stackholder2+1
	mov	al,ah
	popf
	jl	$L16
	neg	al
$L16:
	add	al,bl
	stosb
    add	stackholder44,edx
	mov eax, stackholder44
	cmp eax,1048575
	jl  $L17
    and stackholder44,0FF0FFFFFh
	add	word ptr stackholder2,+001h
$L17:
	mov	ax,word ptr incr+3
	add	stackholder2,ax
	mov	bx,stackholder2
	loop	$L18
	ret
interl32_asm endp	


	END
