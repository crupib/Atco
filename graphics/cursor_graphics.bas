#COMPILE EXE
#BREAK ON
#CONSOLE OFF
#DEBUG ERROR ON
 DEFLNG a-z
#INCLUDE "WIN32API.INC"

FUNCTION PBMAIN () AS LONG

  DIM MousePoint AS POINTAPI
  LOCAL hWin AS LONG
  GRAPHIC WINDOW "Show Cursor Position and input any characters.  Return for next line.  Esc to end.",0,0,800,600 TO hwin
  GRAPHIC ATTACH hWin, 0, REDRAW
  FONT NEW "Lucida Console",12,0,0,0,0 TO F1
  GRAPHIC SET FONT F1: GRAPHIC CHR SIZE TO W1,H1 ' Find pixel width and height of fnt1 graphic font
  x=0: y=H1

 DO
   GRAPHIC INKEY$ TO ink$: SLEEP 1
   GRAPHIC GET DC TO hwin: IF hwin=0 THEN EXIT DO
   GetCursorPos Mousepoint: ScreenToClient hWin,mousepoint
   GRAPHIC SET POS (0,0): GRAPHIC PRINT "X:";Mousepoint.x;"   Y:";Mousepoint.y;"    ": GRAPHIC REDRAW
   IF ink$="" THEN ITERATE
  '------------------------------------------------ Trying to get a caret --------------------
   DestroyCaret
   CaretWidth=12: CaretHeight=9
   CreateCaret(hwin,%null,caretWidth,CaretHeight)
   SetCaretPos(x,y): ShowCaret (hwin)
  '--------------------------------------------------------------------------------------------
   IF ink$=CHR$(13) THEN
     IF y<600 THEN y=y+h1: x=0: ink$="": ITERATE ELSE BEEP ' Return for next line
   END IF
  '---------------------------------------------------------------------------------------------
   GRAPHIC SET POS (x,y): GRAPHIC PRINT ink$
   IF x<800 THEN x=x+w1 ELSE BEEP
   GRAPHIC REDRAW
 LOOP UNTIL ink$=CHR$(27)

 GRAPHIC WINDOW END

END FUNCTION
