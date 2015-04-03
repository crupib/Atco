#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#INCLUDE "C:\PBCC60\WinAPI\WIN32API.INC"
FUNCTION PBMAIN () AS LONG
  LOCAL hFont&, hFont1&

  DIM MousePoint AS POINTAPI
  LOCAL hWin AS DWORD
  LOCAL widthvar AS LONG
  LOCAL Heightvar AS LONG
  LOCAL inkeyvar AS STRING
  LOCAL NumericVar AS LONG
  LOCAL myclick AS LONG
  LOCAL myint AS INTEGER
  LOCAL cp, Q, rp, curpt AS LONG
  LOCAL mystring, s AS STRING
  DESKTOP GET SIZE TO widthvar, Heightvar
  GRAPHIC WINDOW  "Atco MCU Test",widthvar/4, Heightvar/4,600, 400 TO hWin
  GRAPHIC ATTACH hWin, 0
  mystring = "Hello atco  test"
  FONT NEW "myfont", 20, 3, 0, 1 TO hFont&
  FONT NEW "myfont1",20 , 1, 0, 1 TO hFont1&
  GRAPHIC SET FONT hFont1&
  GRAPHIC PRINT mystring POS(1)
  FONT END hfont1&
  CP = 1
  RP = 0
  curpt = 1
  DO WHILE 1
    GetCursorPos Mousepoint
    ScreenToClient hwin, mousepoint
    GRAPHIC WINDOW CLICK TO myclick , mousepoint.x,mousepoint.y
    IF myclick THEN
        EXIT FUNCTION
    END IF
    myint =  GRAPHIC(CHR.SIZE.X)
    GRAPHIC INSTAT TO NumericVar
    IF (NumericVar) THEN
        GRAPHIC INKEY$ TO inkeyVar$
        IF LEN(inkeyVar$)>1 THEN
            Q=ASC(RIGHT$(inkeyVar$,1))
            'IF Q>70 THEN
              '  IF Q=75 THEN cp=cp-GRAPHIC(CHR.SIZE.X) 'left
      '              IF Q=77 THEN cp=cp+GRAPHIC(CHR.SIZE.X) 'right
'                     IF Q=77 THEN cp=cp+1 'right
                    '  IF Q=80 THEN rp=rp+GRAPHIC(CHR.SIZE.Y)  'down
                     '  IF Q=72 THEN rp=rp-GRAPHIC(CHR.SIZE.Y)
            ' END IF
            'GRAPHIC SET POS (cp,rp)
            'GRAPHIC PRINT "x"

            IF Q = 77 THEN
               GRAPHIC SET FONT hFont&
               GRAPHIC SET POS(cp,rp)
               s$  = MID$(mystring, curpt, 1)
               GRAPHIC PRINT s$ POS(cp)
               curpt = curpt + 1
               cp = cp+GRAPHIC(CHR.SIZE.X)
             END IF
'            IF cp > (GRAPHIC(CHR.SIZE.X) * 10) THEN
'                GRAPHIC SET POS (cp,rp)
'                GRAPHIC PRINT "_"
'            END IF
        END IF
    END IF
  LOOP

END FUNCTION
