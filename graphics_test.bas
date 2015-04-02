#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#INCLUDE "D:\PBCC60\WinAPI\WIN32API.INC"
FUNCTION PBMAIN () AS LONG
  DIM MousePoint AS POINTAPI
  LOCAL hWin AS DWORD
  LOCAL widthvar AS INTEGER
  LOCAL Heightvar AS INTEGER
  LOCAL inkeyvar AS STRING
  LOCAL NumericVar AS LONG
  LOCAL myclick AS LONG
  LOCAL myint AS INTEGER
  LOCAL cp, Q, rp AS LONG
  GRAPHIC WINDOW  "Atco MCU Test",400, 400,600, 400 TO hWin
  GRAPHIC ATTACH hWin, 0
  GRAPHIC PRINT "Hello atco  test" POS(1)
  CP = 0
  RP = 0
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
            IF Q>70 THEN
                IF Q=75 THEN cp=cp-GRAPHIC(CHR.SIZE.X) 'left
                    IF Q=77 THEN cp=cp+GRAPHIC(CHR.SIZE.X) 'right
                      IF Q=80 THEN rp=rp+GRAPHIC(CHR.SIZE.Y)  'down
                       IF Q=72 THEN rp=rp-GRAPHIC(CHR.SIZE.Y)
            END IF
            'GRAPHIC SET POS (cp,rp)
            'GRAPHIC PRINT "x"
            IF cp > (GRAPHIC(CHR.SIZE.X) * 10) THEN
                GRAPHIC SET POS (cp,rp)
                GRAPHIC PRINT "x"
            END IF
        END IF
    END IF
  LOOP

END FUNCTION
