
	TITLE	fpchabs.asm
	.586
	.MODEL flat, c
	.data
	.stack
	
;extern void  chabs( void *in,  void *out,  int n,  int type );	
.code
chabs_asm	proc  input:ptr dword , output:ptr dword , n:word, chtype:word
	mov	cx,n
	mov	bx,chtype
	mov	edi,dword ptr output
	mov	esi,dword ptr input
	cmp	bx,+001h
	jnz	$L3
$L4:	
	lodsb
	add	al,80h
	stosb
	loop	$L4
	jmp	short $L5
$L3:
	cmp	bx,+002h
	jnz	$L6
$L8:
	lodsb
	cmp	al,80h
	jc	$L7
	neg	al
	cmp	al,80h
	jnz	$L7
	dec	al
$L7:
	shl	al,1
	stosb
	loop	$L8
	jmp	short $L5
$L6:
	cmp	bx,+003h
	jnz	$L9
$L11:
	lodsb
	cmp	al,80h
	jc	$L10
	sub	al,al
	stosb
	loop	$L11
	jmp	short $L5
$L10:
	shl	al,1
	stosb
	loop	$L11
	jmp	short $L5
$L9:
	cmp	bx,+004h
	jnz	$L5
$L14:
	lodsb
	cmp	al,80h
	jc	$L12
	cmp	al,80h
	jnz	$L13
	inc	al
$L13:
	neg	al
	shl	al,1
	stosb
	loop	$L14
	jmp	short $L5
$L12:
	sub	al,al
	stosb
	loop	$L14
	jmp	short $L5
$L5:
	ret
chabs_asm	endp
end	