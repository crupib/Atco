#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#INCLUDE "D:\PBCC60\WinAPI\WIN32API.INC"

FUNCTION PBMAIN () AS LONG
  LOCAL hWin AS DWORD
  LOCAL widthvar AS LONG
  LOCAL Heightvar AS LONG
  DIM MousePoint AS POINTAPI
  LOCAL myclick AS LONG
  LOCAL spacer AS LONG
  LOCAL CH AS STRING
  LOCAL x1,y1,x2,y2 AS LONG
  LOCAL fgcolor, bgcolor AS LONG
  LOCAL captxt AS STRING
  DESKTOP GET SIZE TO widthvar, Heightvar
  GRAPHIC WINDOW  "Atco MCU Test 2015",widthvar/4, Heightvar/4,600, 400 TO hWin , NORMALIZE
  GRAPHIC ATTACH hWin, 0
  x1 = 20
  x2 = 100
  y1 = 20
  y2 = 80
  fgcolor = %BLUE
  bgcolor = %WHITE
  captxt = "Setup"

  CALL mk_button(x1,y1,x2,y2,fgcolor,bgcolor,captxt)

'  GRAPHIC ELLIPSE (15, 25) - (100, 80), %BLUE, RGB(255,255,255), 0
'  GRAPHIC SET POS (40,45)
'  GRAPHIC PRINT "Setup"
'  GRAPHIC ELLIPSE (15, 100) - (100, 155), %BLUE, RGB(255,255,255), 0
'  GRAPHIC SET POS (40,125)
'  GRAPHIC PRINT "JoyStk"
'  GRAPHIC ELLIPSE (15, 160) - (100, 210), %BLUE, RGB(255,255,255), 0
'  GRAPHIC SET POS (40,205)
'  GRAPHIC PRINT "A-Jog"
'  GRAPHIC ELLIPSE (15, 215) - (100, 270), %BLUE, RGB(255,255,255), 0
'  GRAPHIC SET POS (40,225)
'  GRAPHIC PRINT "Save"

  DO
   GetCursorPos Mousepoint
   ScreenToClient hwin, mousepoint

   GRAPHIC INKEY$ TO CH$
   IF CH$=CHR$(27) THEN
     EXIT LOOP
   END IF
    GRAPHIC WINDOW CLICK TO myclick , mousepoint.x,mousepoint.y
    'IF myclick THEN
    '    EXIT loop
    'END IF
    IF (Mousepoint.x > 20 AND mousepoint.x <80) AND (mousepoint.y > 20 AND mousepoint.y < 80) THEN
        EXIT LOOP
    END IF
  LOOP
  GRAPHIC WINDOW END
END FUNCTION
SUB mk_button(x1 AS LONG, y1 AS LONG, x2 AS LONG, y2 AS LONG,fgcolor AS LONG, bgcolor AS LONG, captxt AS STRING)
     GRAPHIC ELLIPSE (x1, y1) - (x2, y2), fgcolor,bgcolor, 0
     GRAPHIC SET POS ((x1+5),(y2-y1)/2)
     GRAPHIC PRINT captxt
END SUB
