#IF %DEF(%PB_CC32)
  #CONSOLE OFF
#ENDIF
#COMPILE EXE
'#DIM ALL

#DEBUG ERROR ON
DEFLNG a-z
#INCLUDE "WIN32API.INC"

FUNCTION PBMAIN () AS LONG
 DIM MousePoint AS POINTAPI
 DIM XVar AS INTEGER
 DIM YVar AS INTEGER
 LOCAL hGWin???, sKey$
 GRAPHIC WINDOW "Graphic Window", 300, 300, 400, 300 TO hGWin
    ' subclass hGWin to access window procedure
 SetProp hGWin, "OldGWProc", SetWindowLong(hGWin, %GWL_WNDPROC, CODEPTR(GWProc))
 SendMessage hGWin, %WM_USER +1000, 0, 0 ' Initialize (load cursor)
 GRAPHIC ATTACH hGWin, 0
 FONT NEW "Lucida Console",12,0,0,0,0 TO F1
 GRAPHIC SET FONT F1: GRAPHIC CHR SIZE TO W1,H1 ' Find pixel width and height of fnt1 graphic font
 'RANDOMIZE(1.5)
 DO WHILE GRAPHIC(DC)
    GRAPHIC INKEY$ TO sKey
    SLEEP 1
    SELECT CASE LEN(sKey)
      CASE 1
      IF ASC(sKey) = 27 THEN GRAPHIC WINDOW END   ' Esc to quit
    END SELECT

    'GRAPHIC GET DC TO hGwin: IF hGwin=0 THEN EXIT DO
    GetCursorPos Mousepoint
    ScreenToClient hGwin, mousepoint


 '   GRAPHIC GET POS To XVar, YVar
 '   GRAPHIC SET POS (0,0): GRAPHIC PRINT "X:";XVar;"   Y:";YVar;"    ": GRAPHIC REDRAW
 '   Graphic set pos (150,0): Graphic print RND(1,100)
     GRAPHIC SET POS (0,0): GRAPHIC PRINT "X:";Mousepoint.x;"   Y:";Mousepoint.y;"    ": GRAPHIC REDRAW
    'IF ink$="" THEN ITERATE
  '------------------------------------------------ Trying to get a caret --------------------
   ' DestroyCaret
   ' CaretWidth=12: CaretHeight=9
   ' CreateCaret(hwin,%null,caretWidth,CaretHeight)
   ' SetCaretPos(x,y): ShowCaret (hwin)
  '--------------------------------------------------------------------------------------------
 '  IF ink$=CHR$(13) THEN
 '    IF y<600 THEN y=y+h1: x=0: ink$="": ITERATE ELSE BEEP ' Return for next line
  ' END IF
  '---------------------------------------------------------------------------------------------
   'GRAPHIC SET POS (x,y): GRAPHIC PRINT ink$
   'IF x<800 THEN x=x+w1 ELSE BEEP
   GRAPHIC REDRAW
 LOOP
 ' Cleanup
  SetWindowLong(hGWin, %GWL_WNDPROC, GetProp(hGWin, "OldGWProc"))
  RemoveProp hGWin, "OldGWProc"
  GRAPHIC WINDOW END
END FUNCTION
'------------------/PBMain

FUNCTION GwProc(BYVAL hWnd AS DWORD, BYVAL wMsg AS DWORD, _
                BYVAL wParam AS DWORD, BYVAL lParam AS LONG) AS LONG
 STATIC hCursor AS LONG
  SELECT CASE AS LONG wMsg
    CASE %WM_USER + 1000                    ' Startup - initialize cursor
 '     hCursor = LoadCursorFromFile ("C:\Windows\Cursors\larrow.cur")
       hCursor = LoadCursorFromFile ("Submarine.cur")
    CASE %WM_SetCursor
      IF hCursor THEN
         SetCursor hCursor                  ' set hCursor if loaded
         FUNCTION = 1                       ' return one so that default process doesnt overwrite
         EXIT FUNCTION
      END IF
  END SELECT
 ' pass unhandled messages on to original window procedure
 FUNCTION = CallWindowProc(GetProp(hWnd, "OldGWProc"), hWnd, wMsg, wParam, lParam)
END FUNCTION
'------------------/GWProc
