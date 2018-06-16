' Main source code file:  C:\PBDLL60\ezgui\EZGUISourceVersion\EZCustomControls\Ezmedit5.bas
' Resulting include file: C:\PBDLL60\ezgui\EZGUISourceVersion\EZCustomControls\WINCLEAN.INC
'
' Created by inClean v1.25, 06-07-2016, 11:58:17
' Press Help-button for some useful information and tips.
'
'  21062 lines of include file data read and compared against
'    674 lines of code in 0.50 seconds.
'
'-----------------------------------------------------------------
' Equates:  32
'-----------------------------------------------------------------
%WINAPI                                         = 1
%NULL                                           = 0
%DLL_PROCESS_DETACH                             = 0
%DLL_PROCESS_ATTACH                             = 1
%DLL_THREAD_ATTACH                              = 2
%DLL_THREAD_DETACH                              = 3
%GMEM_MOVEABLE                                  = &H2
%VK_RETURN                                      = &H0D
%VK_LEFT                                        = &H25
%VK_UP                                          = &H26
%VK_RIGHT                                       = &H27
%VK_DOWN                                        = &H28
%VK_INSERT                                      = &H2D
%VK_DELETE                                      = &H2E
%GWL_STYLE                                      = -16
%WM_USER                                        = &H400
%WM_CREATE                                      = &H1
%WM_DESTROY                                     = &H2
%WM_SETFOCUS                                    = &H7
%WM_KILLFOCUS                                   = &H8
%WM_GETTEXTLENGTH                               = &HE
%WM_NEXTDLGCTL                                  = &H28
%WM_GETDLGCODE                                  = &H87
%WM_KEYDOWN                                     = &H100
%WM_KEYUP                                       = &H101
%WM_CHAR                                        = &H102
%CS_PUBLICCLASS                                 = &H4000
%CS_GLOBALCLASS                                 = %CS_PUBLICCLASS
%ES_MULTILINE                                   = &H4&
%EM_GETSEL                                      = &HB0
%EM_SETSEL                                      = &HB1
%DLGC_HASSETSEL                                 = &H8    '  Understands EM_SETSEL message

'-----------------------------------------------------------------
' TYPE and UNION structures:  3
'-----------------------------------------------------------------
TYPE RECT
  nLeft AS LONG
  nTop AS LONG
  nRight AS LONG
  nBottom AS LONG
END TYPE

TYPE WNDCLASSEX
  cbSize AS LONG
  STYLE AS LONG
  lpfnWndProc AS LONG
  cbClsExtra AS LONG
  cbWndExtra AS LONG
  hInstance AS LONG
  hIcon AS LONG
  hCursor AS LONG
  hbrBackground AS LONG
  lpszMenuName AS ASCIIZ PTR
  lpszClassName AS ASCIIZ PTR
  hIconSm AS LONG
END TYPE

TYPE PAINTSTRUCT
  hdc AS LONG
  fErase AS LONG
  rcPaint AS Rect
  fRestore AS LONG
  fIncUpdate AS LONG
  rgbReserved(1 TO 32) AS BYTE
END TYPE

'-----------------------------------------------------------------
' Declared Functions:  16
'-----------------------------------------------------------------
DECLARE FUNCTION CallWindowProc LIB "USER32.DLL" ALIAS "CallWindowProcA" (BYVAL lpPrevWndFunc AS LONG, BYVAL hWnd AS LONG, BYVAL Msg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION GetClassInfoEx LIB "USER32.DLL" ALIAS "GetClassInfoExA" (BYVAL hInst AS LONG, lpszClass AS ASCIIZ, lpWndClass AS WNDCLASSEX) AS LONG
DECLARE FUNCTION GetModuleHandle LIB "KERNEL32.DLL" ALIAS "GetModuleHandleA" (lpModuleName AS ASCIIZ) AS LONG
DECLARE FUNCTION GetParent LIB "USER32.DLL" ALIAS "GetParent" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION GetWindowLong LIB "USER32.DLL" ALIAS "GetWindowLongA" (BYVAL hWnd AS LONG, BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetWindowText LIB "USER32.DLL" ALIAS "GetWindowTextA" (BYVAL hwnd AS LONG, lpString AS ASCIIZ, BYVAL cch AS LONG) AS LONG
DECLARE FUNCTION GlobalAlloc LIB "KERNEL32.DLL" ALIAS "GlobalAlloc" (BYVAL wFlags AS LONG, BYVAL dwBytes AS LONG) AS LONG
DECLARE FUNCTION GlobalFree LIB "KERNEL32.DLL" ALIAS "GlobalFree" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalLock LIB "KERNEL32.DLL" ALIAS "GlobalLock" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalSize LIB "KERNEL32.DLL" ALIAS "GlobalSize" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalUnlock LIB "KERNEL32.DLL" ALIAS "GlobalUnlock" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION IsWindow LIB "USER32.DLL" ALIAS "IsWindow" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION RegisterClassEx LIB "USER32.DLL" ALIAS "RegisterClassExA" (pcWndClassEx AS WNDCLASSEX) AS LONG
DECLARE FUNCTION SendMessage LIB "USER32.DLL" ALIAS "SendMessageA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION SetWindowLong LIB "USER32.DLL" ALIAS "SetWindowLongA" (BYVAL hwnd AS LONG, BYVAL nIndex AS LONG, BYVAL dwNewLong AS LONG) AS LONG
DECLARE FUNCTION SetWindowText LIB "USER32.DLL" ALIAS "SetWindowTextA" (BYVAL hwnd AS LONG, lpString AS ASCIIZ) AS LONG

