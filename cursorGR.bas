#COMPILE EXE
#DIM ALL

%USEMACROS = 1
#INCLUDE "Win32API.inc"
GLOBAL ghCur, gOldGraphicProc AS DWORD

'====================================================================
FUNCTION PBMAIN () AS LONG
    LOCAL hGC, hGW AS LONG

    GRAPHIC WINDOW "SubClassed - Cursor test", 100, 100, 300, 200 TO hGW

    ' SubClass Graphic Window's client area
    hGC  = GetWindow(hGW, %GW_CHILD) ' client area is a graphic control
    gOldGraphicProc = SetWindowLong(hGC, %GWL_WNDPROC, CODEPTR(GraphicProc))

    ' load desired cursor, or rem out to remove cursor completely
    ghCur = LoadCursor(0, BYVAL %IDC_ARROW)

    ' do whatever

    ? : ? "Move cursor over Graphic window"
    ? : ? "Close Graphic Window and press the Any key to exit.."
    WAITKEY$

    IF gOldGraphicProc THEN  ' unsubclass before exit
        SetWindowLong hGC, %GWL_WNDPROC, gOldGraphicProc
    END IF
    GRAPHIC WINDOW END

END FUNCTION


'====================================================================
' Subclass procedure
'====================================================================
FUNCTION GraphicProc(BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                     BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS LONG

  SELECT CASE AS LONG wMsg
  CASE %WM_SETCURSOR  ' if ghCur = 0, cursor will not show at all
      IF GetCursor <> ghCur THEN SetCursor ghCur
      FUNCTION = 1 : EXIT FUNCTION
  END SELECT

  FUNCTION = CallWindowProc (gOldGraphicProc, hWnd, wMsg, wParam, lParam)
END FUNCTION
