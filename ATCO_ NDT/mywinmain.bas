#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#INCLUDE "C:\PBCC60\WinAPI\WIN32API.INC"
MACRO CONST = MACRO
CONST KeyUP = 72
CONST KeyDN = 80
CONST KeyLft = 75
CONST KeyRgt = 77
CONST KeyEsc = 27
CONST KeyEnter = 13
FUNCTION PBMAIN () AS LONG
  LOCAL hWin AS DWORD
  LOCAL widthvar AS LONG
  LOCAL Heightvar AS LONG
  DIM MousePoint AS POINTAPI
  LOCAL myclick AS LONG
  LOCAL spacer AS LONG
  LOCAL CH,  keynum AS STRING
  LOCAL Q AS LONG
  LOCAL x1,y1,x2,y2 AS LONG
  LOCAL fgcolor, bgcolor AS LONG
  LOCAL captxt AS STRING
  DESKTOP GET SIZE TO widthvar, Heightvar
  GRAPHIC WINDOW  "Atco MCU Test 2015",widthvar/4, Heightvar/4,600, 400 TO hWin , NORMALIZE
  GRAPHIC ATTACH hWin, 0
  x1 = 20
  x2 = 95
  y1 = 20
  y2 = 60
  fgcolor = %BLUE
  bgcolor = %WHITE
  captxt = "Setup"
  CALL mk_button(x1,y1,x2,y2,fgcolor,bgcolor,captxt,0)

  x1 = 20
  x2 = 95
  y1 = 70
  y2 = 110
  fgcolor = %BLUE
  bgcolor = %WHITE
  captxt = "Joy Stick"
  CALL mk_button(x1,y1,x2,y2,fgcolor,bgcolor,captxt,0)

  x1 = 20
  x2 = 95
  y1 = 120
  y2 = 160
  fgcolor = %BLUE
  bgcolor = %WHITE
  captxt = "A-Jog
  CALL mk_button(x1,y1,x2,y2,fgcolor,bgcolor,captxt,0)

  x1 = 20
  x2 = 95
  y1 = 170
  y2 = 210
  fgcolor = %BLUE
  bgcolor = %WHITE
  captxt = "Save
  CALL mk_button(x1,y1,x2,y2,fgcolor,bgcolor,captxt,0)

  DO
   GetCursorPos Mousepoint
   ScreenToClient hwin, mousepoint

   GRAPHIC INKEY$ TO CH$
   IF CH$=CHR$(KeyEsc) THEN
     EXIT LOOP
   END IF
   IF CH$=CHR$(KeyEnter) THEN
     EXIT LOOP
   END IF
   IF LEN(CH$) > 1 THEN
      Q=ASC(RIGHT$(CH$,1))
      IF Q=KeyDn THEN
        x1 = 20
        x2 = 95
        y1 = 70
        y2 = 110
        fgcolor = %BLUE
        bgcolor = %WHITE
        captxt = "Joy Stick"
        CALL mk_button(x1,y1,x2,y2,fgcolor,bgcolor,captxt,5)
      END IF
    END IF

    GRAPHIC WINDOW CLICK TO myclick , mousepoint.x,mousepoint.y
    'IF myclick THEN
    '    EXIT loop
    'END IF
    IF (Mousepoint.x > 20 AND mousepoint.x <95) AND (mousepoint.y > 20 AND mousepoint.y < 60) THEN
        EXIT LOOP
    END IF
    IF (Mousepoint.x > 20 AND mousepoint.x <95) AND (mousepoint.y > 70 AND mousepoint.y < 110) THEN
        EXIT LOOP
    END IF
    IF (Mousepoint.x > 20 AND mousepoint.x <95) AND (mousepoint.y > 120 AND mousepoint.y < 160) THEN
        EXIT LOOP
    END IF
    IF (Mousepoint.x > 20 AND mousepoint.x <95) AND (mousepoint.y > 170 AND mousepoint.y < 210) THEN
        EXIT LOOP
    END IF
  LOOP
  GRAPHIC WINDOW END
END FUNCTION
SUB mk_button(x1 AS LONG, y1 AS LONG, x2 AS LONG, y2 AS LONG,fgcolor AS LONG, bgcolor AS LONG, captxt AS STRING, STYLE AS LONG)
     LOCAL XPOS,YPOS, temp, temp2, temp3 AS LONG
     GRAPHIC ELLIPSE (x1, y1) - (x2, y2), fgcolor,bgcolor, STYLE
     TEMP = LEN(captxt)/3
     TEMP2 = (x2-x1)/2
     TEMP3 = (y2-y1)/2
     XPOS = TEMP2+TEMP
     YPOS =  y1+TEMP3-5
     GRAPHIC SET POS (XPOS,YPOS)
     GRAPHIC PRINT captxt
END SUB
