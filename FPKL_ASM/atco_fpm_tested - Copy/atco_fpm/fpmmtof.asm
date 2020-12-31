; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

TITLE    fpmmtof.asm
.586
.MODEL flat, c
.stack
.DATA
 $S3 dd 1 dup(?)
 Vscale dd 1 dup(?)
 Voutput_size dw 1 dup(?)
 $S5 db 1 dup(?)
;fp_maxmin_reduce_tof( char  *input_array,
;                                  char           *output_maxmin_array,
;                                  char           *output_tof_array,
;                                  unsigned long  scale,
;                                  short int      connect_lines,
;                                  short int      output_size );
.CODE
fp_maxmin_reduce_tof_asm PROC  input_array:dword, output_maxmin_array:dword, output_tof_array:dword, scale:dword, connect_lines:word, output_size:word				
    mov    eax,scale       
    mov    ds:Vscale,eax
    mov    edi,output_maxmin_array
    mov    esi,input_array
    mov    ebx,output_tof_array
    mov    ax,output_size
    mov    ds:Voutput_size,ax
    mov    ds:$S3,00000000h
    cmp    scale,00100000h
    jnbe   $L4                   ; jump if above
    push   ebp
    mov    ebp,ds:Vscale
$L10:  
    mov    dl,[esi]
    inc    esi
    mov    cl,dl
    add    ds:$S3,ebp
    mov    ah,byte ptr ds:$S3 + 00002h
    mov    word ptr ds:$S3 + 00002h,0000h
    mov    ds:$S5,ah
    mov    ch,ah
    mov    dh,ah
    dec    ah
    jz    $L6
$L9:
    mov    al,[esi]
    inc    esi
    cmp    al,cl
    jnl    $L7
    mov    cx,ax
    jmp    short $L8
$L7:
    cmp    al,dl
    jl    $L8
    mov    dx,ax
$L8:
    dec    ah
    jnz    $L9
$L6:
    mov    [edi],cl
    mov    [edi+001h],dl
    add    edi,+002h
    mov    ah,ds:$S5
    mov    al,ah
    sub    al,ch
    sub    ah,dh
    shl    ah,04h
    or    al,ah
    mov    [ebx],al
    inc    ebx
    dec    word ptr ds:Voutput_size
    jnz    $L10
    pop    ebp
    jmp    short $L11
$L4:
    push    ebp
    mov     ebp,ds:VScale
$L16:  
    mov    dl,[esi]
    inc    esi
    mov    cl,dl
    add    ds:$S3,ebp
    mov    ah,byte ptr ds:$S3 + 00002h
    mov    word ptr ds:$S3 + 00002h,0000h
    mov    ds:$S5,ah
    mov    ch,ah
    mov    dh,ah
    dec    ah
    jz    $L12
$L15:
    mov    al,[esi]
    inc    esi
    cmp    al,cl
    jnl    $L13
    mov    cx,ax
    jmp    short $L14
$L13:
    cmp    al,dl
    jng    $L14
    mov    dx,ax
$L14:
    dec    ah
    jnz    $L15
$L12:
    mov    [edi],cl
    mov    [edi+001h],dl
    add    edi,+002h
    mov    ah,ds:$S5
    mov    al,ah
    sub    al,ch
    sub    ah,dh
    mov    [ebx],ax
    add    ebx,+002h
    dec    word ptr ds:Voutput_size
    jnz    $L16
    pop    ebp
$L11: 
    cmp    word ptr [connect_lines],+000h
    jz    $L17
    mov    edi,dword ptr [output_maxmin_array]
    mov    cx,[output_size]
    dec    cx
$L20:
    mov    ax,[edi]
    mov    dx,[edi+002h]
    cmp    dl,ah
    jng    $L18
    mov    ah,dl
    jmp    short $L19
$L18:
    cmp    dh,al
    jnl    $L19
    mov    al,dh
$L19:
    mov    [edi],ax
    add    edi,+002h
    dec    cx
    jnz    $L20
$L17:
    ret    
    fp_maxmin_reduce_tof_asm ENDP   
	end
