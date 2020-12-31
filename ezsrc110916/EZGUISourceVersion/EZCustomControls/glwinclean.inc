' Main source code file:  C:\PBDLL60\ezgui\EZGUISourceVersion\EZCustomControls\ezgui5gl.bas
' Resulting include file: C:\PBDLL60\ezgui\EZGUISourceVersion\EZCustomControls\WINCLEAN.INC
'
' Created by inClean v1.25, 06-07-2016, 12:01:53
' Press Help-button for some useful information and tips.
'
'  21062 lines of include file data read and compared against
'   5571 lines of code in 0.58 seconds.
'
'-----------------------------------------------------------------
' Equates:  26
'-----------------------------------------------------------------
%WINAPI                                         = 1
%NULL                                           = 0
%DLL_PROCESS_DETACH                             = 0
%DLL_PROCESS_ATTACH                             = 1
%DLL_THREAD_ATTACH                              = 2
%DLL_THREAD_DETACH                              = 3
%OBJ_BITMAP                                     = 7
%BI_RGB                                         = 0&
%PRF_CLIENT                                     = &H00000004&
%DIB_RGB_COLORS                                 = 0 '  color table in RGBs
%GWL_STYLE                                      = -16
%WM_USER                                        = &H400
%WM_CREATE                                      = &H1
%WM_DESTROY                                     = &H2
%WM_SIZE                                        = &H5
%WM_SETTEXT                                     = &HC
%WM_GETTEXT                                     = &HD
%WM_GETTEXTLENGTH                               = &HE
%WM_PAINT                                       = &HF
%WM_ERASEBKGND                                  = &H14
%WM_LBUTTONUP                                   = &H202
%WM_PRINTCLIENT                                 = &H318
%WS_CLIPSIBLINGS                                = &H4000000&
%WS_CLIPCHILDREN                                = &H2000000&
%HWND_DESKTOP                                   = 0
%IMAGE_BITMAP                                   = 0

'-----------------------------------------------------------------
' TYPE and UNION structures:  6
'-----------------------------------------------------------------
TYPE RECT
  nLeft AS LONG
  nTop AS LONG
  nRight AS LONG
  nBottom AS LONG
END TYPE

TYPE BITMAP                             '14 bytes
  bmType AS LONG
  bmWidth AS LONG
  bmHeight AS LONG
  bmWidthBytes AS LONG
  bmPlanes AS INTEGER
  bmBitsPixel AS INTEGER
  bmBits AS LONG
END TYPE

TYPE RGBQUAD
  rgbBlue AS BYTE
  rgbGreen AS BYTE
  rgbRed AS BYTE
  rgbReserved AS BYTE
END TYPE

TYPE BITMAPINFOHEADER                   '40 bytes
  biSize AS LONG
  biWidth AS LONG
  biHeight AS LONG
  biPlanes AS INTEGER
  biBitCount AS INTEGER
  biCompression AS LONG
  biSizeImage AS LONG
  biXPelsPerMeter AS LONG
  biYPelsPerMeter AS LONG
  biClrUsed AS LONG
  biClrImportant AS LONG
END TYPE

TYPE BITMAPINFO
  bmiHeader AS BITMAPINFOHEADER
  bmiColors(256) AS RGBQUAD
END TYPE

TYPE PIXELFORMATDESCRIPTOR
  nSize AS WORD
  nVersion AS WORD
  dwFlags AS DWORD
  iPixelType AS BYTE
  cColorBits AS BYTE
  cRedBits AS BYTE
  cRedShift AS BYTE
  cGreenBits AS BYTE
  cGreenShift AS BYTE
  cBlueBits AS BYTE
  cBlueShift AS BYTE
  cAlphaBits AS BYTE
  cAlphaShift AS BYTE
  cAccumBits AS BYTE
  cAccumRedBits AS BYTE
  cAccumGreenBits AS BYTE
  cAccumBlueBits AS BYTE
  cAccumAlphaBits AS BYTE
  cDepthBits AS BYTE
  cStencilBits AS BYTE
  cAuxBuffers AS BYTE
  iLayerType AS BYTE
  bReserved AS BYTE
  dwLayerMask AS DWORD
  dwVisibleMask AS DWORD
  dwDamageMask AS DWORD
END TYPE

'-----------------------------------------------------------------
' Declared Functions:  23
'-----------------------------------------------------------------
DECLARE FUNCTION ChoosePixelFormat LIB "GDI32.DLL" ALIAS "ChoosePixelFormat" (BYVAL hDC AS LONG, pPixelFormatDescriptor AS PIXELFORMATDESCRIPTOR) AS LONG
DECLARE FUNCTION CreateCompatibleDC LIB "GDI32.DLL" ALIAS "CreateCompatibleDC" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION CreateDIBSection LIB "GDI32.DLL" ALIAS "CreateDIBSection" (BYVAL hDC AS LONG, pBitmapInfo AS BITMAPINFO, BYVAL un AS LONG, BYVAL lplpVoid AS LONG, BYVAL xHandle AS LONG, BYVAL DW AS LONG) AS LONG
DECLARE FUNCTION DeleteDC LIB "GDI32.DLL" ALIAS "DeleteDC" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION DeleteObject LIB "GDI32.DLL" ALIAS "DeleteObject" (BYVAL hObject AS LONG) AS LONG
DECLARE FUNCTION GdiFlush LIB "GDI32.DLL" ALIAS "GdiFlush" () AS LONG
DECLARE FUNCTION GetClientRect LIB "USER32.DLL" ALIAS "GetClientRect" (BYVAL hwnd AS LONG, lpRect AS RECT) AS LONG
DECLARE FUNCTION GetDC LIB "USER32.DLL" ALIAS "GetDC" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION GetDIBits LIB "GDI32.DLL" ALIAS "GetDIBits" (BYVAL aHDC AS LONG, BYVAL hBitmap AS LONG, BYVAL nStartScan AS LONG, BYVAL nNumScans AS LONG, lpBits AS ANY, lpBI AS BITMAPINFO, BYVAL wUsage AS LONG) AS LONG
DECLARE FUNCTION GetObject LIB "GDI32.DLL" ALIAS "GetObjectA" (BYVAL hObject AS LONG, BYVAL nCount AS LONG, lpObject AS ANY) AS LONG
DECLARE FUNCTION GetObjectType LIB "GDI32.DLL" ALIAS "GetObjectType" (BYVAL hgdiobj AS LONG) AS LONG
DECLARE FUNCTION GetWindowLong LIB "USER32.DLL" ALIAS "GetWindowLongA" (BYVAL hWnd AS LONG, BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION InvalidateRect LIB "USER32.DLL" ALIAS "InvalidateRect" (BYVAL hwnd AS LONG, lpRect AS RECT, BYVAL bErase AS LONG) AS LONG
DECLARE FUNCTION IsWindow LIB "USER32.DLL" ALIAS "IsWindow" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION LoadImage LIB "USER32.DLL" ALIAS "LoadImageA" (BYVAL hInst AS LONG, lpsz AS ASCIIZ, BYVAL un1 AS LONG, BYVAL n1 AS LONG, BYVAL n2 AS LONG, BYVAL un2 AS LONG) AS LONG
DECLARE FUNCTION MoveMemory LIB "KERNEL32.DLL" ALIAS "RtlMoveMemory" (BYVAL lpDest AS DWORD, BYVAL lpSource AS DWORD, BYVAL cbMove AS DWORD) AS LONG
DECLARE FUNCTION ReleaseDC LIB "USER32.DLL" ALIAS "ReleaseDC" (BYVAL hwnd AS LONG, BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION SelectObject LIB "GDI32.DLL" ALIAS "SelectObject" (BYVAL hdc AS LONG, BYVAL hObject AS LONG) AS LONG
DECLARE FUNCTION SendMessage LIB "USER32.DLL" ALIAS "SendMessageA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION SetPixelFormat LIB "GDI32.DLL" ALIAS "SetPixelFormat" (BYVAL hDC AS LONG, BYVAL n AS LONG, pcPixelFormatDescriptor AS PIXELFORMATDESCRIPTOR) AS LONG
DECLARE FUNCTION SetWindowLong LIB "USER32.DLL" ALIAS "SetWindowLongA" (BYVAL hwnd AS LONG, BYVAL nIndex AS LONG, BYVAL dwNewLong AS LONG) AS LONG
DECLARE FUNCTION SwapBuffers LIB "GDI32.DLL" ALIAS "SwapBuffers" (BYVAL hDC AS LONG) AS LONG
DECLARE FUNCTION ValidateRect LIB "USER32.DLL" ALIAS "ValidateRect" (BYVAL hwnd AS LONG, lpRect AS RECT) AS LONG

