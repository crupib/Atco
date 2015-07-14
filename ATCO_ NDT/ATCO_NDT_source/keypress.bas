#DIM ALL
#IF NOT %DEF(%WINAPI)

  '  Constants, udt's & declarations from WIN32API.INC
  '  Last Update: 14 January 2005

  '  Copyright (C) 1997-2005 PowerBASIC, Inc.
  '  Portions Copyright (C) 1985-1999 Microsoft Corporation
  '  All Rights Reserved.
  '  ***********************************************************************************************

  %BM_CLICK         = &HF5
  %BN_CLICKED       = 0
  %BS_DEFPUSHBUTTON = &H1&

  %IDOK             = 1

  %MOD_ALT          = &H00000001   ' }
  %MOD_CONTROL      = &H00000002   ' } From DDT.INC
  %MOD_SHIFT        = &H00000004   ' }

  %SS_CENTER        = &H00000001
  %SS_CENTERIMAGE   = &H00000200
  %SS_SUNKEN        = &H00001000

  %VK_SHIFT         = &H10
  %VK_CONTROL       = &H11
  %VK_PGUP          = &H21
  %VK_PGDN          = &H22
  %VK_END           = &H23
  %VK_HOME          = &H24
  %VK_LEFT          = &H25
  %VK_UP            = &H26
  %VK_RIGHT         = &H27
  %VK_DOWN          = &H28
  %VK_INSERT        = &H2D
  %VK_DELETE        = &H2E

  %VK_NUMPAD0       = &H60
  %VK_NUMPAD1       = &H61
  %VK_NUMPAD2       = &H62
  %VK_NUMPAD3       = &H63
  %VK_NUMPAD4       = &H64
  %VK_NUMPAD5       = &H65
  %VK_NUMPAD6       = &H66
  %VK_NUMPAD7       = &H67
  %VK_NUMPAD8       = &H68
  %VK_NUMPAD9       = &H69
  %VK_MULTIPLY      = &H6A
  %VK_ADD           = &H6B
  %VK_SUBTRACT      = &H6D
  %VK_DECIMAL       = &H6E

  %VK_F1            = &H70
  %VK_F2            = &H71
  %VK_F3            = &H72
  %VK_F4            = &H73
  %VK_F5            = &H74
  %VK_F6            = &H75
  %VK_F7            = &H76
  %VK_F8            = &H77
  %VK_F9            = &H78
  %VK_F10           = &H79

  %WH_KEYBOARD      = 2
  %WM_DESTROY       = &H2
  %WM_HELP          = &H53
  %WM_INITDIALOG    = &H110
  %WM_COMMAND       = &H111
  %WM_USER          = &H400

  %WS_MINIMIZEBOX   = &H00020000
  %WS_SYSMENU       = &H00080000
  %WS_CAPTION       = &H00C00000

  DECLARE FUNCTION GetAsyncKeyState LIB "USER32.DLL" ALIAS "GetAsyncKeyState" (BYVAL vKey AS LONG) AS INTEGER
  DECLARE FUNCTION PostMessage LIB "USER32.DLL" ALIAS "PostMessageA" (BYVAL hWnd AS DWORD, BYVAL dwMsg AS DWORD, BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS LONG
  DECLARE FUNCTION SetWindowsHookEx LIB "USER32.DLL" ALIAS "SetWindowsHookExA" (BYVAL idHook AS LONG, BYVAL lpfn AS DWORD, BYVAL hMod AS DWORD, BYVAL dwThreadId AS DWORD) AS LONG
  DECLARE FUNCTION CallNextHookEx LIB "USER32.DLL" ALIAS "CallNextHookEx" (BYVAL hHook AS DWORD, BYVAL ncode AS LONG, BYVAL wParam AS DWORD, lParam AS ANY) AS LONG
  DECLARE FUNCTION UnhookWindowsHookEx LIB "USER32.DLL" ALIAS "UnhookWindowsHookEx" (BYVAL hHook AS DWORD) AS LONG
  DECLARE FUNCTION GetCurrentThreadId LIB "KERNEL32.DLL" ALIAS "GetCurrentThreadId" () AS DWORD
#ENDIF

GLOBAL ghKeyb AS DWORD, ghDlg AS DWORD                               ' global handles

FUNCTION KeyBoardProc(BYVAL iCode AS INTEGER, BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS DWORD
  LOCAL  lShiftMode AS LONG

  IF ISFALSE(lParam AND &H80000000) THEN                             ' bit 31 (2^31) NOT set: some key is pressed
    IF ISTRUE(lParam AND &H20000000) THEN lShiftMode = %MOD_ALT      ' bit 29 (2^29) set: Alt-key is down
    IF (GetAsyncKeyState(%VK_CONTROL) AND &H8000) THEN _
                         lShiftMode = lShiftMode + %MOD_CONTROL      ' eventually add Ctrl
    IF (GetAsyncKeyState(%VK_SHIFT) AND &H8000) _
                      THEN lShiftMode = lShiftMode + %MOD_SHIFT      ' eventually add Shift
    PostMessage ghDlg, %WM_USER + 101, wParam, lShiftMode            ' wParam holds virtual keycode
  END IF
  FUNCTION = CallNextHookEx(ghKeyb, iCode, wParam, lParam)           ' proceed
END FUNCTION

CALLBACK FUNCTION MainDlgProc()

  SELECT CASE CBMSG

    CASE %WM_INITDIALOG
      CONTROL SET COLOR CBHNDL, 1001, -1, %WHITE
      ghKeyb = SetWindowsHookEx(%WH_KEYBOARD, CODEPTR(KeyBoardProc), 0, GetCurrentThreadId)

    CASE %WM_DESTROY
      UnhookWindowsHookEx ghKeyb

    CASE %WM_COMMAND
      SELECT CASE CBCTLMSG
        CASE %BN_CLICKED
          IF CBCTL = %IDOK THEN
            DIALOG END CBHNDL
          END IF
      END SELECT

    CASE %WM_HELP
      CONTROL SET TEXT CBHNDL, 1001, "F1 (help)"

    CASE %WM_USER + 101
      LOCAL sTmp AS STRING

      ' check shift mode info by processing lParam
      IF (CBLPARAM AND %MOD_ALT) THEN sTmp = "Alt+"
      IF (CBLPARAM AND %MOD_CONTROL) THEN sTmp = sTmp & "Ctrl+"
      IF (CBLPARAM AND %MOD_SHIFT) THEN sTmp = sTmp & "Shift+"

      ' now check which key (virt. key code or ASCII code) has been pressed
      SELECT CASE AS LONG CBWPARAM
        CASE 8          : sTmp = sTmp & "BackSpace"
        CASE 9          : sTmp = sTmp & "Tab"
        CASE %VK_PGUP   : sTmp = sTmp & "PgUp"
        CASE %VK_PGDN   : sTmp = sTmp & "PgDn"
        CASE %VK_END    : sTmp = sTmp & "End"
        CASE %VK_HOME   : sTmp = sTmp & "Home"
        CASE %VK_LEFT   : sTmp = sTmp & "Left Arrow"
        CASE %VK_UP     : sTmp = sTmp & "Up Arrow"
        CASE %VK_RIGHT  : sTmp = sTmp & "Right Arrow"
        CASE %VK_DOWN   : sTmp = sTmp & "Down Arrow"
        CASE %VK_INSERT : sTmp = sTmp & "Ins"
        CASE %VK_DELETE : sTmp = sTmp & "Del"

        CASE %VK_F1
          SELECT CASE AS LONG CBLPARAM
            CASE 0, _                                                ' no shift keys pressed
                 %MOD_CONTROL, _                                     ' Ctrl pressed
                 %MOD_SHIFT, _                                       ' Shift pressed
                 %MOD_CONTROL + %MOD_SHIFT, _                        ' Ctrl + Shift pressed
                 %MOD_ALT + %MOD_CONTROL + %MOD_SHIFT                ' Alt + Ctrl + Shift pressed

              ' NOTE: F1, Ctrl/F1, Shift/F1, Ctrl/Shift/F1 and Alt/Ctrl/Shift/F1 fire the %WM_HELP message
              ' so let %WM_HELP do the job and exit here
              EXIT FUNCTION
          END SELECT
          sTmp = sTmp & "F1"

        CASE %VK_F2 TO %VK_F10                                       ' function keys F2 - F10
          sTmp = sTmp & "F" & FORMAT$(CBWPARAM - %VK_F1 + 1)

        ' numpad keys
        CASE %VK_NUMPAD0 TO %VK_NUMPAD9
          sTmp = sTmp & CHR$(CBWPARAM - %VK_NUMPAD0 + 48) & " (numpad)"
        CASE %VK_MULTIPLY  : sTmp = sTmp & "Multiply (numpad)"
        CASE %VK_ADD       : sTmp = sTmp & "Add (numpad)"
        CASE %VK_SUBTRACT  : sTmp = sTmp & "Substract (numpad)"
        CASE %VK_DECIMAL   : sTmp = sTmp & "Decimal (numpad)"
        ' end numpad keys

        ' printable chars
        CASE 48 TO 57, 65 TO 90                                      ' 0 - 9, A - Z (ASCII codes)
          sTmp = sTmp & CHR$(CBWPARAM)

        CASE ELSE                                                    ' don't process unwanted keys
          EXIT FUNCTION
      END SELECT
      CONTROL SET TEXT CBHNDL, 1001, sTmp
  END SELECT
END FUNCTION

FUNCTION PBMAIN() AS LONG
  LOCAL sTxt AS STRING

  DIALOG NEW 0, " Test KeyBoardHook", , , 200, 100, %WS_CAPTION OR %WS_MINIMIZEBOX OR %WS_SYSMENU TO ghDlg
  sTxt = "Key pressed:"
  CONTROL ADD LABEL,  ghDlg,    -1, sTxt, 10, 20, 180, 12
  CONTROL ADD LABEL,  ghDlg,  1001,   "", 10, 30, 180, 12, %SS_CENTER OR %SS_SUNKEN OR %SS_CENTERIMAGE
  CONTROL ADD BUTTON, ghDlg, %IDOK, "OK", 80, 70,  40, 14, %BS_DEFPUSHBUTTON
  DIALOG SHOW MODAL ghDlg CALL MainDlgProc
END FUNCTION
