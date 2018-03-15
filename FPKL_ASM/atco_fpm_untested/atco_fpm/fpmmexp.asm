
; OBJASM version 2.0 released on Jan 3, 1991
; (C) Copyright 1988,1989,1990,1991 by Robert F. Day.  All rights reserved

    TITLE    fpmmexp.asm
.586
.MODEL flat, c
.stack
.DATA
$S4    dw    08000h
    db    'UU',000h
    db    '@33'
    db    0AAh
    db    02Ah
    db    092h
    db    '$'
    db    000h
    db    ' q'
    db    01Ch
    db    099h
    db    019h
    db    045h
    db    017h
    db    055h
    db    015h
    db    0B1h
    db    013h
    db    049h
    db    012h
    db    011h
    db    011h
    db    000h
    db    010h
    db    00Fh
    db    00Fh
    db    038h
    db    00Eh
    db    079h
    db    00Dh
    db    0CCh
    db    00Ch
    db    030h
    db    00Ch
    db    0A2h
    db    00Bh
    db    021h
    db    00Bh
    db    0AAh
    db    00Ah,'=',00Ah
    db    0D8h
    db    009h
    db    07Bh
    db    009h
    db    024h
    db    009h
    db    0D3h
    db    008h
    db    088h
    db    008h
    db    042h
    db    008h
    db    000h
    db    008h
    
; void  fp_maxmin_expand( char  *input_maxmin_array,
;                        char   *input_tof_array,
;                        char   *output_array,
;                        unsigned long   scale,
;                        unsigned long   input_size );

.code
fp_maxmin_expand_asm PROC  input_maxmin_array:dword, input_tof_array:dword, output_array:dword, scale:dword, input_size:dword				
    mov    edi,input_maxmin_array
    mov    esi,output_array
    mov    ebx,input_tof_array
    xor    eax,eax
    mov    [ebp-004h],eax
    mov    [ebp-005h],al
    dec    al
    mov    [ebp-006h],al
    cmp    scale,00100000h
    jnbe   $L1
$L15:     
    mov    al,[ebx]
    mov    ah,al
    and    al,0Fh
    shr    ah,04h
    cmp    al,ah
    jnb    $L2
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,al
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L3
    mov    bl,cl
    movsx  eax,byte ptr[edi]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1    
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L5:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L5
$L3:
    mov    al,[edi]
    mov    [esi],al
    inc    esi
    mov    al,[edi+001h]
    xor    ebx,ebx
    mov    cl,[ebp-008h]
    sub    cl,[ebp-007h]
    jz    $L6
    dec    cl
    jz    $L7
    mov    bl,cl
    movsx  eax,byte ptr[edi+001h]
    mov    ch,[edi]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L8:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L8
    mov    al,[edi+001h]
$L7:
    mov    [esi],al
    inc    esi
$L6:
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-008h]
    mov    [ebp-006h],al
    jmp    $L9
$L2:
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,ah
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L10
    mov    bl,cl
    movsx  eax,byte ptr [edi+001h]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L11:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L11
$L10:
    mov    al,[edi+001h]
    mov    [esi],al
    inc    esi
    mov    al,[edi]
    xor    ebx,ebx
    mov    cl,[ebp-007h]
    sub    cl,[ebp-008h]
    jz    $L12
    dec    cl
    jz    $L13
    mov    bl,cl
    movsx  eax,byte ptr [edi]
    mov    ch,[edi+001h]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L14:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L14
    mov    al,[edi]
$L13: 
    mov [esi],al
    inc    esi
$L12:
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-007h]
    mov    [ebp-006h],al
$L9:
    mov    ebx,input_tof_array
    inc    ebx
    mov    input_tof_array,ebx
    dec    input_size
    jnz    $L15
    jmp    $L16
$L1:
    mov    ax,[ebx]
    cmp    al,ah
    jnb    $L17
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,al
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L18
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L19:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L19
$L18:
    mov  al,[edi]
    mov    [esi],al
    inc    esi
    mov    al,[edi+001h]
    xor    ebx,ebx
    mov    cl,[ebp-008h]
    sub    cl,[ebp-007h]
    jz    $L20
    dec    cl
    jz    $L21
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi+001h]
    mov    ch,[edi]
    movsx    edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L22:
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L22
    mov    al,[edi+001h]
$L21:
    mov  [esi],al
    inc    esi
$L20: 
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-008h]
    mov    [ebp-006h],al
    jmp    $L23
$L17:
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,ah
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L24
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi+001h]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L25:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L25
$L24:
    mov    al,[edi+001h]
    mov    [esi],al
    inc    esi
    mov    al,[edi]
    xor    ebx,ebx
    mov    cl,[ebp-007h]
    sub    cl,[ebp-008h]
    jz    $L26
    dec    cl
    jz    $L27
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi]
    mov    ch,[edi+001h]
    movsx  edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L28:
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L28
    mov    al,[edi]
$L27:
    mov  [esi],al
    inc    esi
$L26:
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-007h]
    mov    [ebp-006h],al
$L23:
    mov    ebx,input_tof_array
    add    ebx,+002h
    mov    input_tof_array,ebx
    dec    input_size
    jnz    $L1
$L16:   
    ret
fp_maxmin_expand_asm  ENDP   
;	end
; void  fp_maxmin32_expand( char  *input_maxmin_array,
;                        char   *input_tof_array,
;                        char   *output_array,
;                        unsigned long   scale,
;                        unsigned long   input_size );

.code
fp_maxmin_expand32_asm PROC  input_maxmin_array:dword, input_tof_array:dword, output_array:dword, scale:dword, input_size:dword				
    mov    edi,input_maxmin_array
    mov    esi,output_array
    mov    ebx,input_tof_array
    xor    eax,eax
    mov    [ebp-004h],eax
    mov    [ebp-005h],al
    dec    al
    mov    [ebp-006h],al
    cmp    scale,00100000h
    jnbe   $L1
$L15:     
    mov    al,[ebx]
    mov    ah,al
    and    al,0Fh
    shr    ah,04h
    cmp    al,ah
    jnb    $L2
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,al
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L3
    mov    bl,cl
    movsx  eax,byte ptr[edi]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1    
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L5:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L5
$L3:
    mov    al,[edi]
    mov    [esi],al
    inc    esi
    mov    al,[edi+001h]
    xor    ebx,ebx
    mov    cl,[ebp-008h]
    sub    cl,[ebp-007h]
    jz    $L6
    dec    cl
    jz    $L7
    mov    bl,cl
    movsx  eax,byte ptr[edi+001h]
    mov    ch,[edi]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L8:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L8
    mov    al,[edi+001h]
$L7:
    mov    [esi],al
    inc    esi
$L6:
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-008h]
    mov    [ebp-006h],al
    jmp    $L9
$L2:
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,ah
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L10
    mov    bl,cl
    movsx  eax,byte ptr [edi+001h]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L11:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L11
$L10:
    mov    al,[edi+001h]
    mov    [esi],al
    inc    esi
    mov    al,[edi]
    xor    ebx,ebx
    mov    cl,[ebp-007h]
    sub    cl,[ebp-008h]
    jz    $L12
    dec    cl
    jz    $L13
    mov    bl,cl
    movsx  eax,byte ptr [edi]
    mov    ch,[edi+001h]
    movsx  edx,ch
    sub    eax,edx
    shl    bl,1
    mov    bx,[ebx+ds:$S4 - 00002h]
    imul   ebx,eax
    xor    eax,eax
$L14:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L14
    mov    al,[edi]
$L13: 
    mov [esi],al
    inc    esi
$L12:
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-007h]
    mov    [ebp-006h],al
$L9:
    mov    ebx,input_tof_array
    inc    ebx
    mov    input_tof_array,ebx
    dec    input_size
    jnz    $L15
    jmp    $L16
$L1:
    mov    ax,[ebx]
    cmp    al,ah
    jnb    $L17
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,al
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L18
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L19:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L19
$L18:
    mov  al,[edi]
    mov    [esi],al
    inc    esi
    mov    al,[edi+001h]
    xor    ebx,ebx
    mov    cl,[ebp-008h]
    sub    cl,[ebp-007h]
    jz    $L20
    dec    cl
    jz    $L21
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi+001h]
    mov    ch,[edi]
    movsx    edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L22:
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L22
    mov    al,[edi+001h]
$L21:
    mov  [esi],al
    inc    esi
$L20: 
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-008h]
    mov    [ebp-006h],al
    jmp    $L23
$L17:
    mov    [ebp-007h],al
    mov    [ebp-008h],ah
    xor    ebx,ebx
    mov    cl,ah
    sub    cl,[ebp-006h]
    dec    cl
    jz    $L24
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi+001h]
    mov    ch,[ebp-005h]
    movsx  edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L25:    
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L25
$L24:
    mov    al,[edi+001h]
    mov    [esi],al
    inc    esi
    mov    al,[edi]
    xor    ebx,ebx
    mov    cl,[ebp-007h]
    sub    cl,[ebp-008h]
    jz    $L26
    dec    cl
    jz    $L27
    xor    ebx,ebx
    mov    bl,cl
    movsx  eax,byte ptr [edi]
    mov    ch,[edi+001h]
    movsx  edx,ch
    sub    eax,edx
    shl    eax,10h
    cdq
    idiv   ebx
    mov    ebx,eax
    xor    eax,eax
$L28:
    add    eax,ebx
    mov    edx,eax
    shr    edx,10h
    add    dl,ch
    mov    [esi],dl
    inc    esi
    dec    cl
    jnz    $L28
    mov    al,[edi]
$L27:
    mov  [esi],al
    inc    esi
$L26:
    mov    [ebp-005h],al
    add    edi,+002h
    mov    eax,[ebp-004h]
    add    eax,scale
    mov    [ebp-004h],ax
    shr    eax,10h
    neg    al
    add    al,[ebp-007h]
    mov    [ebp-006h],al
$L23:
    mov    ebx,input_tof_array
    add    ebx,+002h
    mov    input_tof_array,ebx
    dec    input_size
    jnz    $L1
$L16:   
    ret
fp_maxmin_expand32_asm  ENDP   
	end
