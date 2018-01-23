' Main source code file:  C:\PBDLL60\ezgui\EZGUISourceVersion\EZCustomControls\ezmci50.bas
' Resulting include file: C:\PBDLL60\ezgui\EZGUISourceVersion\EZCustomControls\WINCLEAN.INC
'
' Created by inClean v1.25, 06-07-2016, 11:55:54
' Press Help-button for some useful information and tips.
'
'  21062 lines of include file data read and compared against
'    706 lines of code in 0.62 seconds.
'
'-----------------------------------------------------------------
' Equates:  29
'-----------------------------------------------------------------
%WINAPI                                         = 1
%TRUE                                           = 1
%NULL                                           = 0
%DLL_PROCESS_DETACH                             = 0
%DLL_PROCESS_ATTACH                             = 1
%DLL_THREAD_ATTACH                              = 2
%DLL_THREAD_DETACH                              = 3
%GMEM_MOVEABLE                                  = &H2
%BLACK_BRUSH                                    = 4
%GWL_ID                                         = -12
%WM_USER                                        = &H400
%WM_CREATE                                      = &H1
%WM_DESTROY                                     = &H2
%WM_SETTEXT                                     = &HC
%WM_GETTEXT                                     = &HD
%WM_GETTEXTLENGTH                               = &HE
%WM_NOTIFY                                      = &H4E
%CS_VREDRAW                                     = &H1
%CS_HREDRAW                                     = &H2
%CS_DBLCLKS                                     = &H8
%SM_CYCAPTION                                   = 4
%SM_CXFRAME                                     = 32
%SM_CYFRAME                                     = 33
%SM_CXSIZEFRAME                                 = %SM_CXFRAME     ' win40 name change
%SM_CYSIZEFRAME                                 = %SM_CYFRAME     ' win40 name change
%IDC_ARROW                                      = 32512&
%SPI_GETWORKAREA                                = 48
%MM_MCINOTIFY                                   = &H3B9  '  MCI
%MM_MCISIGNAL                                   = &H3CB

'-----------------------------------------------------------------
' TYPE and UNION structures:  2
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

'-----------------------------------------------------------------
' Declared Functions:  20
'-----------------------------------------------------------------
DECLARE FUNCTION DefWindowProc LIB "USER32.DLL" ALIAS "DefWindowProcA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION GetClientRect LIB "USER32.DLL" ALIAS "GetClientRect" (BYVAL hwnd AS LONG, lpRect AS RECT) AS LONG
DECLARE FUNCTION GetModuleHandle LIB "KERNEL32.DLL" ALIAS "GetModuleHandleA" (lpModuleName AS ASCIIZ) AS LONG
DECLARE FUNCTION GetParent LIB "USER32.DLL" ALIAS "GetParent" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION GetStockObject LIB "GDI32.DLL" ALIAS "GetStockObject" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetSystemMetrics LIB "USER32.DLL" ALIAS "GetSystemMetrics" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetWindowLong LIB "USER32.DLL" ALIAS "GetWindowLongA" (BYVAL hWnd AS LONG, BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GlobalAlloc LIB "KERNEL32.DLL" ALIAS "GlobalAlloc" (BYVAL wFlags AS LONG, BYVAL dwBytes AS LONG) AS LONG
DECLARE FUNCTION GlobalFree LIB "KERNEL32.DLL" ALIAS "GlobalFree" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalLock LIB "KERNEL32.DLL" ALIAS "GlobalLock" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalSize LIB "KERNEL32.DLL" ALIAS "GlobalSize" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalUnlock LIB "KERNEL32.DLL" ALIAS "GlobalUnlock" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION IsWindow LIB "USER32.DLL" ALIAS "IsWindow" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION LoadCursor LIB "USER32.DLL" ALIAS "LoadCursorA" (BYVAL hInstance AS LONG, lpCursorName AS ASCIIZ) AS LONG
DECLARE FUNCTION mciGetErrorString LIB "WINMM.DLL" ALIAS "mciGetErrorStringA" (BYVAL dwError AS LONG, lpstrBuffer AS ASCIIZ, BYVAL uLength AS LONG) AS LONG
DECLARE FUNCTION mciSendString LIB "WINMM.DLL" ALIAS "mciSendStringA" (lpstrCommand AS ASCIIZ, lpstrReturnString AS ASCIIZ, BYVAL uReturnLength AS LONG, BYVAL hwndCallback AS LONG) AS LONG
DECLARE FUNCTION RegisterClassEx LIB "USER32.DLL" ALIAS "RegisterClassExA" (pcWndClassEx AS WNDCLASSEX) AS LONG
DECLARE FUNCTION SendMessage LIB "USER32.DLL" ALIAS "SendMessageA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION SetWindowLong LIB "USER32.DLL" ALIAS "SetWindowLongA" (BYVAL hwnd AS LONG, BYVAL nIndex AS LONG, BYVAL dwNewLong AS LONG) AS LONG
DECLARE FUNCTION SystemParametersInfo LIB "USER32.DLL" ALIAS "SystemParametersInfoA" (BYVAL uAction AS LONG, BYVAL uParam AS LONG, BYVAL lpvParam AS DWORD, BYVAL fuWinIni AS LONG) AS LONG

