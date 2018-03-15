'Compilable Example:
#COMPILE EXE
#DIM ALL

#DEBUG ERROR ON     'catch array/pointer errors - OFF in production
#DEBUG DISPLAY ON   'display untrapped errors   - OFF in production

#INCLUDE "Win32API.inc"

'Declare Sub RtlFillMemory Lib "Kernel32.dll" ( ByRef Destination As Any, ByVal Length As Long, ByVal Fill As Byte)
DECLARE SUB RtlFillMemory LIB "Kernel32.dll" (BYVAL pDest AS DWORD, BYVAL ncBytes AS DWORD, BYVAL nValue AS BYTE)

GLOBAL hDlg, hGraphic, DC_Graphic AS DWORD
FUNCTION PBMAIN() AS LONG
   DIALOG NEW PIXELS, 0, "Test Code",0,0,800,700, %WS_OVERLAPPEDWINDOW TO hDlg
   CONTROL ADD BUTTON, hDlg, 100,"Push", 50,10,100,20
   CONTROL ADD IMAGE, hDlg, 200,"", 50,40,600,600, %WS_BORDER
   CONTROL HANDLE hDlg, 200 TO hGraphic
   DC_graphic = GetDC (hGraphic)                           'DC for Image control
   DIALOG SHOW MODAL hDlg CALL DlgProc
END FUNCTION
CALLBACK FUNCTION DlgProc() AS LONG
   IF CB.MSG = %WM_COMMAND AND CB.CTL = 100 AND CB.CTLMSG = %BN_CLICKED THEN
      CreateDisplayDIBSection (600,600, "test.bmp")
   END IF
END FUNCTION
ASMDATA tof
    DD  00000000
END ASMDATA

ASMDATA peakfind
   DB  000
   DB  001
   DB  002
   DB  003
   DB  004
   DB  005
   DB  006
   DB  007
   DB  008
   DB  009
   DB  &h00A
   DB  &h00B
   DB  &h00C
   DB  &h00D
   DB  &h00E
   DB  &h00F
   DB  &h010
   DB  &h011
   DB  &h012
   DB  &h013
   DB  &h014
   DB  &h015
   DB  &h016
   DB  &h017
   DB  &h018
   DB  &h019
   DB  &h01A
   DB  &h01B
   DB  &h01C
   DB  &h01D
   DB  &h01E
   DB  &h01F
   DB  " "
   DB  "!"
   DB  "#$"
   DB  "%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]"
   DB  "^_`abcdefghijklmnopqrstuvwxyz{|}~"
   DB  &h07F
   DB  &h07F
   DB  &h07F
   DB  "~}|{zyxwvutsrqponmlkjihgfedcba`_^]\[ZYXWVUTSRQPONMLKJIHGFE"
   DB  "DCBA@?>=<;:9876543210/.-,+*)(''&%$"
   DB  "#
   DB  """
   DB  "! "
   DB  &h01F
   DB  &h01E
   DB  &h01D
   DB  &h01C
   DB  &h01B
   DB  &h01A
   DB  &h019
   DB  &h018
   DB  &h017
   DB  &h016
   DB  &h015
   DB  &h014
   DB  &h013
   DB  &h012
   DB  &h011
   DB  &h010
   DB  &h00F
   DB  &h00E
   DB  &h00D
   DB  &h00C
   DB  &h00B
   DB  &h00A
   DB  &h009
   DB  &h008
   DB  &h007
   DB  &h006
   DB  &h005
   DB  &h004
   DB  &h003
   DB  &h002
   DB  &h001
END ASMDATA
FUNCTION fp_peak_find_asm (BYVAL buff AS STRING POINTER, length AS INTEGER, threshold AS INTEGER,_
     threshold_sense AS INTEGER, _
     absolute_value AS INTEGER,data_type AS INTEGER, edge_level_logic AS INTEGER, time_of_flight AS WORD) AS INTEGER
     LOCAL peakhold AS LONG
     ! cld
     ! xor ecx,ecx
     ! xor esi,esi
     ! mov edi,buff
     ! mov tof,edi
     ! mov si,  length
     ! cmp word ptr edge_level_logic,+000
     ! jnz L1
     ! cmp word ptr absolute_value,+000
     ! jz  L2
     ! xor bh,bh
     ! mov ax,&h0FFFF
     ! mov dh,byte ptr threshold
     ! dec edi
!L10:
     ! mov  ecx,esi
     ! and esi,+003
     ! and ecx,-004
     ! jz  L3
!L9:
     ! mov bl,[edi+001]
     ! mov peakhold, ecx
     ! mov ecx, offset PEAKFIND
     ! mov dl,[ebx+ecx]
     ! mov ecx, peakhold
     ! cmp dl,dh
     ! jbe L5
     ! mov dh,dl
     ! mov eax,edi
     ! inc eax
     ! mov bl,[edi+002]
     ! mov peakhold, ecx
     ! mov peakhold, offset PEAKFIND
     ! mov dl,[ebx+ecx]
     ! mov ecx, peakhold
     ! cmp dl,dh
     ! jbe L6
     ! mov dh,dl
     ! inc eax
     ! mov bl,[edi+003]
     ! mov peakhold, ecx
     ! mov peakhold, offset PEAKFIND
     ! mov dl,[ebx+ecx]
     ! mov ecx, peakhold
     ! cmp dl,dh
     ! jbe L7
     ! mov dh,dl
     ! inc eax
     ! mov bl,[edi+004]
     ! mov peakhold, ecx
     ! mov peakhold, offset PEAKFIND
     ! mov dl,[ebx+ecx]
     ! mov ecx, peakhold
     ! cmp dl,dh
     ! jbe L8
     ! mov dh,dl
     ! inc eax
!L8:
     ! add edi,+004
     ! sub ecx,+004
     ! jnz L9
     ! jz  L10
!L7:
     ! mov bl,[edi+004]
     ! mov peakhold, ecx
     ! mov peakhold, offset PEAKFIND
     ! mov dl,[ebx+ecx]
     ! mov ecx, peakhold
     ! cmp dl,dh
     ! jnle    L11
     ! add edi,+004
     ! sub ecx,+004
     ! jnz L9
     ! jz  L10
!L6:
     ! mov bl,[edi+003]
     ! mov peakhold, ecx
     ! mov peakhold, offset PEAKFIND
     ! mov dl,[ebx+ecx]
     ! mov ecx, peakhold
     ! cmp dl,dh
     ! jnle    L12
     ! mov bl,[edi+004]
     ! mov peakhold, ecx
     ! mov peakhold, offset PEAKFIND
     ! mov dl,[ebx+ecx]
     ! mov ecx, peakhold
     ! cmp dl,dh
     ! jnle    L11
     ! add edi,+004
     ! sub ecx,+004
     ! jnz L9
     ! jz  L10
!L5:
    ! mov bl,[edi+002]
    ! mov peakhold, ecx
    ! mov peakhold, offset PEAKFIND
    ! mov dl,[ebx+ecx]
    ! mov ecx, peakhold
    ! cmp dl,dh
    ! jg  L13
    ! mov bl,[edi+003]
    ! mov peakhold, ecx
    ! mov peakhold, offset PEAKFIND
    ! mov dl,[ebx+ecx]
    ! mov ecx, peakhold
    ! cmp dl,dh
    ! jg  L12
    ! mov bl,[edi+004]
    ! mov peakhold, ecx
    ! mov peakhold, offset PEAKFIND
    ! mov dl,[ebx+ecx]
    ! mov ecx, peakhold
    ! cmp dl,dh
    ! jg  L11
    ! add edi,+004
    ! sub ecx,+004
    ! jnz L9
    ! jz  L10
!L3:
    ! inc edi
!L17:
    ! or  esi,esi
    ! jz  L14
!L16:
    ! mov bl,[edi]
    ! mov peakhold, ecx
    ! mov peakhold, offset PEAKFIND
    ! mov dl,[ebx+ecx]
    ! mov ecx, peakhold
    ! cmp dl,dh
    ! jg  L15
    ! inc edi
    ! dec esi
    ! jnz L16
!L14:
    ! mov edi, time_of_flight
    ! sub eax,tof
    ! mov [edi],ax
    ! mov al,dh
    ! xor ah,ah
    ! ret
!L13:
    ! mov dh,dl
    ! add edi,+002
    ! mov eax,edi
    ! add esi,+002
    ! sub ecx,+004
    ! jnz L9
    ! jz  L10
!L12:
    ! mov dh,dl
    ! add edi,+003
    ! mov eax,edi
    ! inc esi
    ! sub ecx,+004
    ! jnz L9
    ! jz  L10
!L11:
    ! mov dh,dl
    ! add edi,+004
    ! mov eax,edi
    ! sub ecx,+004
    ! jnz L9
    ! jz  L10
!L15:
    ! mov dh,dl
    ! mov eax,edi
    ! inc edi
    ! dec esi
    ! jnz L17
    ! jz  L14
    ! jmp L18
!L2:
    ! cmp	word ptr threshold_sense,+001
    ! jnz L19
    ! mov eax,&h0FFFF
    ! mov dh,byte ptr threshold
    ! dec edi
!L26:
    ! mov ecx,esi
    ! and esi,+003
    ! and ecx,-004
    ! jz  L20
!L25:
    ! mov dl,[edi+001h]
    ! cmp dl,dh
    ! jng $L21
    ! mov dh,dl
    ! mov eax,edi
    ! inc eax
    ! mov dl,[edi+002h]
    ! cmp dl,dh
    ! jng $L22
    ! mov dh,dl
    ! inc eax
    ! mov dl,[edi+003h]
    ! cmp dl,dh
    ! jng $L23
    ! mov dh,dl
    ! inc eax
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jng $L24
    ! mov dh,dl
    ! inc eax
$L24:
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L25
    ! jz  $L26
$L23:
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jnle    $L27
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L25
    ! jz  $L26
$L22:
    ! mov dl,[edi+003h]
    ! cmp dl,dh
    ! jg  $L28
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jg  $L27
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L25
    ! jz  $L26
$L21:
    ! mov dl,[edi+002h]
    ! cmp dl,dh
    ! jg  $L29
    ! mov dl,[edi+003h]
    ! cmp dl,dh
    ! jg  $L28
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jg  $L27
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L25
    ! jz  $L26
$L20:
    ! inc edi
$L33:
    ! or  esi,esi
    ! jz  $L30
$L32:
    ! mov dl,[edi]
    ! cmp dl,dh
    ! jg  $L31
    ! inc edi
    ! dec esi
    ! jnz $L32
$L30:
    ! mov edi,dword ptr time_of_flight
    ! sub eax,tof
    ! mov [edi],ax
    ! mov al,dh
    ! xor ah,ah
    ! ret
$L29:
    ! mov dh,dl
    ! add edi,+002h
    ! mov eax,edi
    ! add esi,+002h
    ! sub ecx,+004h
    ! jnz $L25
    ! jz  $L26
$L28:
    ! mov dh,dl
    ! add edi,+003h
    ! mov eax,edi
    ! inc esi
    ! sub ecx,+004h
    ! jnz $L25
    ! jz  $L26
$L27:
    ! mov dh,dl
    ! add edi,+004h
    ! mov eax,edi
    ! sub ecx,+004h
    ! jnz $L25
    ! jz  $L26
$L31:
    ! mov dh,dl
    ! mov eax,edi
    ! inc edi
    ! dec esi
    ! jnz $L33
    ! jz  $L30
    ! jmp $L34
$L19:
    ! mov eax,0FFFFh
    ! mov dh,byte ptr threshold
    ! dec edi
$L41:
    ! mov ecx,esi
    ! and esi,+003h
    ! and ecx,-004h
    ! jz  $L35
$L40:
    ! mov dl,[edi+001h]
    ! cmp dl,dh
    ! jnl $L36
    ! mov dh,dl
    ! mov eax,edi
    ! inc eax
    ! mov dl,[edi+002h]
    ! cmp dl,dh
    ! jnl $L37
    ! mov dh,dl
    ! inc eax
    ! mov dl,[edi+003h]
    ! cmp dl,dh
    ! jnl $L38
    ! mov dh,dl
    ! inc eax
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jnl $L39
    ! mov dh,dl
    ! inc eax
$L39:
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L40
    ! jz  $L41
$L38:
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jl  $L42
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L40
    ! jz  $L41
$L37:
    ! mov dl,[edi+003h]
    ! cmp dl,dh
    ! jl  $L43
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jl  $L42
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L40
    ! jz  $L41
$L36:
    ! mov dl,[edi+002h]
    ! cmp dl,dh
    ! jl  $L44
    ! mov dl,[edi+003h]
    ! cmp dl,dh
    ! jl  $L43
    ! mov dl,[edi+004h]
    ! cmp dl,dh
    ! jl  $L42
    ! add edi,+004h
    ! sub ecx,+004h
    ! jnz $L40
    ! jz  $L41
$L35:
    ! inc edi
$L48:
    ! or  esi,esi
    ! jz  $L45
$L47:
    ! mov dl,[edi]
    ! cmp dl,dh
    ! jl  $L46
    ! inc edi
    ! dec esi
    ! jnz $L47
$L45:
    ! mov	edi, time_of_flight
    ! sub eax,tof
    ! mov [edi],ax
    ! mov al,dh
    ! xor ah,ah
    ! ret
$L44:
    ! mov dh,dl
    ! add edi,+002h
    ! mov eax,edi
    ! add esi,+002h
    ! sub ecx,+004h
    ! jnz $L40
    ! jz  $L41
$L43:
    ! mov dh,dl
    ! add edi,+003h
    ! mov eax,edi
    ! inc esi
    ! sub ecx,+004h
    ! jnz $L40
    ! jz  $L41
$L42:
    ! mov dh,dl
    ! add edi,+004h
    ! mov eax,edi
    ! sub ecx,+004h
    ! jnz $L40
    ! jz  $L41
$L46:
    ! mov dh,dl
    ! mov eax,edi
    ! inc edi
    ! dec esi
    ! jnz $L48
    ! jz  $L45
$L34:
    ! jmp $L18
$L1:
    ! cmp word ptr absolute_value,+000h
    ! jz  $L49
    ! mov dh, byte ptr threshold
    ! xor bh,bh
    ! mov ecx,esi
    ! and esi,+007h
    ! and ecx,-008h
    ! jz  $L50
$L59:
    ! mov bl,[edi]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L51
    ! mov bl,[edi+001h]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L52
    ! mov bl,[edi+002h]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L53
    ! mov bl,[edi+003h]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L54
    ! mov bl,[edi+004h]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L55
    ! mov bl,[edi+005h]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L56
    ! mov bl,[edi+006h]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L57
    ! mov bl,[edi+007h]
    ! mov al,[ebx+$S4]
    ! cmp al,dh
    ! jnle    $L58
    ! add edi,+008h
    ! sub ecx,+008h
    ! jnz $L59
$L50:
    ! or  esi,esi
    ! jz  $L60
$L62:
    ! mov al,[edi]
    ! cmp al,dh
    ! jnle    $L61
    ! inc edi
    ! dec esi
    ! jnz $L62
$L60:
    ! xor eax,eax
    ! ret
$L51:
    ! sub edi,tof
    ! mov ebx,time_of_flight
    ! mov [ebx],di
    ! xor eax,eax
    ! mov eax,0001h
    ! ret
$L52:
    ! inc edi
    ! sub edi,tof
    ! mov ebx,time_of_flight
    ! mov [ebx],di
    ! xor eax,eax
    ! mov eax,0001h
    ! ret
$L53:
    ! add edi,+002h
    ! sub edi,tof
    ! mov ebx,time_of_flight
    ! mov [ebx],di
    ! xor eax,eax
    ! mov eax,0001h
    ! ret
$L54:
    ! add edi,+003h
    ! sub edi,tof
    ! mov ebx,time_of_flight
    ! mov [ebx],di
    ! xor eax,eax
    ! mov eax,0001h
    ! ret
$L55:
    ! add edi,+004h
    ! sub edi,tof
    ! mov ebx,time_of_flight
    ! mov [ebx],di
    ! xor eax,eax
    ! mov eax,0001h
    ! ret
$L56:
    ! add edi,+005h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L57:
    ADD edi,+006h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L58:
    ADD edi,+007h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L61:
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
    jmp $L18
$L49:
    cmp WORD PTR threshold_sense,+001h
    jnz $L63
    mov dh, BYTE PTR threshold
    mov ecx,esi
    AND esi,+007h
    AND ecx,-008h
    jz  $L64
$L73:
    mov eax,[edi]
    cmp al,dh
    jg  $L65
    cmp ah,dh
    jg  $L66
    mov eax,[edi+002h]
    cmp al,dh
    jg  $L67
    cmp ah,dh
    jnle    $L68
    mov eax,[edi+004h]
    cmp al,dh
    jnle    $L69
    cmp ah,dh
    jnle    $L70
    mov eax,[edi+006h]
    cmp al,dh
    jnle    $L71
    cmp ah,dh
    jnle    $L72
    ADD edi,+008h
    SUB ecx,+008h
    jnz $L73
$L64:
    OR  esi,esi
    jz  $L74
$L76:
    mov al,[edi]
    cmp al,dh
    jnle    $L75
    inc edi
    dec esi
    jnz $L76
$L74:
    XOR eax,eax
    ret
$L65:
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L66:
    inc edi
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L67:
    ADD edi,+002h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L68:
    ADD edi,+003h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L69:
    ADD edi,+004h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L70:
    ADD edi,+005h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L71:
    ADD edi,+006h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L72:
    ADD edi,+007h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L75:
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
    jmp $L18
$L63:
    mov dh, BYTE PTR threshold
    mov ecx,esi
    AND esi,+007h
    AND ecx,-008h
    jz  $L77
$L86:
    mov eax,[edi]
    cmp al,dh
    jl  $L78
    cmp ah,dh
    jl  $L79
    mov eax,[edi+002h]
    cmp al,dh
    jl  $L80
    cmp ah,dh
    jl  $L81
    mov eax,[edi+004h]
    cmp al,dh
    jl  $L82
    cmp ah,dh
    jl  $L83
    mov eax,[edi+006h]
    cmp al,dh
    jl  $L84
    cmp ah,dh
    jl  $L85
    ADD edi,+008h
    SUB ecx,+008h
    jnz $L86
$L77:
    OR  esi,esi
    jz  $L87
$L89:
    mov al,[edi]
    cmp al,dh
    jl  $L88
    inc edi
    dec esi
    jnz $L89
$L87:
    XOR eax,eax
    ret
$L78:
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L79:
    inc edi
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L80:
    ADD edi,+002h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L81:
    ADD edi,+003h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L82:
    ADD edi,+004h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L83:
    ADD edi,+005h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L84:
    ADD edi,+006h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L85:
    ADD edi,+007h
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L88:
    SUB edi,tof
    mov ebx,time_of_flight
    mov [ebx],di
    XOR eax,eax
    mov eax,0001h
    ret
$L18:
!   ret
!   fp_peak_find_asm    endp

END FUNCTION
SUB CreateDisplayDIBSection(w AS LONG, h AS LONG, fName AS STRING)

   'Create device context (where the DIB Section will be selected)
   LOCAL hMemDC AS DWORD
   hMemDC = CreateCompatibleDC(%NULL)
   LOCAL FileNumber       AS DWORD
   FileNumber = FREEFILE
   OPEN "test.bmp" FOR BINARY AS FileNumber BASE = 0
   'Create/fill in the BITMAPINFO data structure
   LOCAL filesize AS DWORD
   filesize = w*h*4
   LOCAL BH AS BITMAPFILEHEADER
   LOCAL BI AS BITMAPINFO
   BH.bfType =  &H4d42
   BH.bfSize = SIZEOF(BH)+filesize+SIZEOF(BI)
   BH.bfReserved1 = 0
   BH.bfReserved2 = 0
   BH.bfOffBits   = 0
   BI.bmiHeader.biSize = 40                'SizeOf(BI.bmiHeader) = 40
   BI.bmiHeader.biWidth = w
   BI.bmiHeader.biHeight = h
   BI.bmiHeader.biPlanes = 1
   BI.bmiHeader.biBitCount = 32            'must be 32 because an RGBQuad is 32 bytes
   BI.bmiHeader.biCompression = %BI_RGB    '%BI_RGB = 0
   BI.bmiHeader.biSizeImage     = 0        'zero for %BI_RGB images
   BI.bmiHeader.biXPelsPerMeter = 0        'zero (device-specific value)
   BI.bmiHeader.biYPelsPerMeter = 0        'zero (device-specific value)
   BI.bmiHeader.biClrUsed       = 0        'no palette so set to zero
   BI.bmiHeader.biClrImportant  = 0        'zero means all colors are important
   PUT FileNumber,,BH
   PUT FileNumber,,BI
   'Create the DIB Section and select it into the DC
   LOCAL hDIBSection AS DWORD, P AS DWORD
   hDIBSection = CreateDIBSection(hMemDC, BI, %DIB_RGB_COLORS, VARPTR(P), 0, 0)

   'Create the RGBQuad color data and pre-load all colors to red (for grins)
   DIM Colors(w-1,h-1) AS RGBQUAD
   LOCAL x, y AS LONG
   FOR x = 0 TO w-1 : FOR y = 0 TO h-1 : Colors(x,y).rgbRed = 128 : NEXT : NEXT
   CopyMemory(BYVAL P, BYVAL VARPTR(Colors(0)), w*h*4)      'Dest, Source, #Bytes

   'Now that the DIB Section is in a device context, you can use API to draw on it
    SelectObject(hMemDC, hDIBSection)
    ELLIPSE hMemDC, 20,20,100,100

   'If desired, you can get the info back into your array, make changes, and put changes into the DIBSection
   CopyMemory(BYVAL VARPTR(Colors(0)), BYVAL P, w*h*4)      'Dest, Source, #Bytes
   FOR x = w/2 TO w-1 : FOR y = h/2 TO h-1 : Colors(x,y).rgbRed = 64 : NEXT : NEXT
   CopyMemory(BYVAL P, BYVAL VARPTR(Colors(0)), w*h*4)      'Dest, Source, #Bytes
   PUT FileNumber,,Colors()
   'Copy the completed drawing (hMEMDC) to the graphics control
   BitBlt(DC_Graphic, 0, 0, w, h, hMemDC, 0, 0, %SRCCOPY)
   CLOSE FileNumber
END SUB
