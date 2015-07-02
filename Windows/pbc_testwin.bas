#COMPILE EXE
#CONSOLE OFF
#DIM ALL

%UNICODE = 1
#INCLUDE "WIN32API.INC"

GLOBAL rb, lb, wm, kd, ku, mm, ck, hWin, fnt1 AS LONG
GLOBAL MousePoint AS POINTAPI
GLOBAL ghCur AS DWORD

FUNCTION PBMAIN () AS LONG
 LOCAL I AS LONG
 LOCAL hGWin???, hStatic???
 LOCAL CH$,C?,L$
 GRAPHIC WINDOW "Tab,Keys,Mouse",100, 100, 750, 200 TO hWin
 GRAPHIC ATTACH hWin, 0, REDRAW
 FONT NEW "COURIER NEW",10,0,0,49,0 TO fnt1
 GRAPHIC SET FONT fnt1
 GRAPHIC SET POS(35,30)
 GRAPHIC PRINT "KEYDOWN  KEYUP         MOUSEX        MOUSEY    LEFTBUTTON     RIGHTBUTTON   MOUSEWHEEL"
 hStatic??? = GetWindow(hWin, %GW_CHILD)
 SetProp hWin, "OldStaticProc", SetWindowLong(hStatic???, %GWL_WNDPROC, CODEPTR(StaticProc))
 ghCur = LoadCursor(0, BYVAL %IDC_ARROW)
 '--------------------------------------------------------------------------
 MousePoint.x = 750/2
 MousePoint.y = 200/2
 ClientToScreen hWin, MousePoint
 SetCursorPos MousePoint.x,MousePoint.y
 '--------------------------------------------------------------------------
 rb=1
 DO
  GetCursorPos Mousepoint
  ScreenToClient hWin, MousePoint
  IF GRAPHIC(DC) = 0 THEN EXIT LOOP
  GRAPHIC INKEY$ TO CH$
  IF CH$=CHR$(27) THEN
   EXIT LOOP
  ELSEIF CH$=CHR$(0,60) THEN                         'F2 key togles on/off the mouse cursor. Using the rest of the %IDC_XXXXX it's possible to switch
   IF ghCur = LoadCursor(0, BYVAL %IDC_ARROW) THEN   'to more cursor shapes.
    ghCur = LoadCursor(0, BYVAL %IDC_CROSS)
   ELSE
    ghCur = LoadCursor(0, BYVAL %IDC_ARROW)
   END IF
  END IF
  GRAPHIC SET POS(50,50)
  GRAPHIC PRINT kd,ku,mousepoint.x,mousepoint.y,lb,rb,wm
  GRAPHIC REDRAW
  SLEEP 10
 LOOP
 GRAPHIC WINDOW END
END FUNCTION
FUNCTION StaticProc(BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS LONG
 SELECT CASE wMsg
  CASE %WM_MOUSEWHEEL
   wm = SGN(HI(INTEGER, wParam))
  CASE %WM_RBUTTONUP
   rb = 1
  CASE %WM_RBUTTONDOWN
   rb = 2
  CASE %WM_RBUTTONDBLCLK
   rb = 3
  CASE %WM_LBUTTONUP
   lb = 1
  CASE %WM_LBUTTONDOWN
   lb = 2
  CASE %WM_LBUTTONDBLCLK
   lb = 3
  CASE %WM_MOUSEMOVE
   mm = 1
  CASE %WM_KEYDOWN
   kd = wParam
   IF wParam = 17 THEN ck = 1
  CASE %WM_KEYUP
   IF wParam = 17 THEN ck = 0
   ku = wParam
  CASE %WM_SETCURSOR
   IF GetCursor <> ghCur THEN SetCursor ghCur
   FUNCTION = 1
   EXIT FUNCTION
 END SELECT
 FUNCTION = CallWindowProc(GetProp (GetParent(hWnd), "OldStaticProc"), hWnd, wMsg, wParam, lParam)
 GRAPHIC ATTACH GetParent(hWnd), 0, REDRAW
END FUNCTION
