


'Converts, or maps, a set of points from a coordinate space relative
'to one Window to a coordinate space relative to another Window.

'It's versatile, in that it can do window-to-window, screen-to-window
'and window-to-screen conversions. It can also do multiple points at a
'time by passing an array of POINT structures

'Primary Code:
'Compilable Example:
'This example puts the screen coordinates in a label as the mouse is moved.
'Note that %WM_MouseMove is not received when the cursor is away from
'the dialog, so the coordinates change only when the mouse is over the dialog.
'Also, WM_MouseMove is not received by the Dialog when the cursor is over
'most controls, since most control window procedures handle mouse events.
#COMPILE EXE
#DIM ALL
#INCLUDE "Win32API.inc"
GLOBAL hDlg AS DWORD, Choice&
FUNCTION PBMAIN() AS LONG
   Dialog NEW PIXELS, 0, "Test Code",300,300,200,200, %WS_OVERLAPPEDWINDOW TO hDlg
   Control Add Label, hDlg, 100,"", 50,10,100,20
   Control Add Option, hDlg, 200,"Screen To Client", 20,40,120,20
   Control Add Option, hDlg, 201,"Client To Screen", 20,70,120,20
   Control SET Option hDlg, 200, 200, 201
   Dialog SHOW Modal hDlg CALL DlgProc
END FUNCTION
CallBack FUNCTION DlgProc() AS LONG
   SELECT CASE CB.Msg
      CASE %WM_MOUSEMOVE   'returns client coordinates
         LOCAL P AS POINT, iResult&
         IF iResult& THEN
               GetCursorPos P           'p.x and p.y are in screen coordinates
               MapWindowPoints %NULL, hDlg, P, 1     'screen to window
         ELSE
               MapWindowPoints hDlg, %NULL, P, 1     'window to screen
               p.x = LO(WORD,CB.lParam)
               p.y = HI(WORD,CB.lParam)
               Control GET Check hDlg, 201 TO iResult&
         END IF
         Control SET TEXT hDlg, 100, "X:Y " + STR$(p.x) + ":" + STR$(p.y)

   END SELECT
END FUNCTION

'gbs_00028
