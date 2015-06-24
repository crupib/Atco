#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#INCLUDE "C:\PBCC60\WinAPI\WIN32API.INC"

FUNCTION PBMAIN () AS LONG
  LOCAL hWin AS DWORD
  LOCAL widthvar AS LONG
  LOCAL Heightvar AS LONG
  DIM MousePoint AS POINTAPI
  LOCAL myclick AS LONG
  LOCAL CH AS STRING
  DESKTOP GET SIZE TO widthvar, Heightvar
  GRAPHIC WINDOW  "Atco MCU Test",widthvar/4, Heightvar/4,600, 400 TO hWin , NORMALIZE
  GRAPHIC ATTACH hWin, 0
  GRAPHIC ELLIPSE (15, 25) - (95, 50), %BLUE, RGB(191,191,191), 0
  GRAPHIC SET POS (40,30)
  GRAPHIC PRINT "Setup"
  GRAPHIC ELLIPSE (15, 60) - (95, 85), %BLUE, RGB(191,191,191), 0
  GRAPHIC SET POS (40,65)
  GRAPHIC PRINT "A-Jog"

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
    IF (Mousepoint.x > 15 AND mousepoint.x < 95) AND (mousepoint.y > 25 AND mousepoint.y < 50) THEN
        GRAPHIC PRINT mousepoint.x
        GRAPHIC PRINT mousepoint.y
        EXIT LOOP
    END IF
  LOOP
  GRAPHIC WINDOW END
END FUNCTION
