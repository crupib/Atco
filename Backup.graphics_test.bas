#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#INCLUDE "C:\PBCC60\WinAPI\WIN32API.INC"
FUNCTION PBMAIN () AS LONG
  DIM MousePoint AS POINTAPI
  LOCAL hWin AS DWORD
  LOCAL widthvar AS INTEGER
  LOCAL Heightvar AS INTEGER
  LOCAL inkeyvar AS STRING
  LOCAL NumericVar AS LONG
  LOCAL myclick AS LONG
  LOCAL myint AS INTEGER
  LOCAL cp, Q AS LONG
  GRAPHIC WINDOW "Atco MCU Test",400, 400,600, 400 TO hWin
  GRAPHIC ATTACH hWin, 0
  'GRAPHIC BOX (10, 10) - (120, 120), 0, %BLUE
 ' GRAPHIC PRINT "Hello atco  test" POS(1)
  GRAPHIC SET POS (1, 20)
 ' GRAPHIC PRINT "Hello atco  test" POS(1)
  CP = 0
  DO WHILE 1
    GetCursorPos Mousepoint
    ScreenToClient hwin, mousepoint
    'GRAPHIC SET POS (mousepoint.x,mousepoint.y)

 '   GRAPHIC PRINT "                                                         "
 '   GRAPHIC SET POS (1, 60)
 '   GRAPHIC PRINT "hello" + STR$(mousepoint.x,10) +   STR$(mousepoint.y,10)
 '   GRAPHIC WINDOW CLICK TO myclick , mousepoint.x,mousepoint.y
    IF myclick THEN
        EXIT FUNCTION
    END IF
    GRAPHIC INSTAT TO NumericVar
    IF (NumericVar) THEN
        GRAPHIC INKEY$ TO inkeyVar$
'        GRAPHIC SET POS (1, 90)
'        graphic print len(inkeyvar$)
'        myint = len(inkeyvar$)
'        if myint = 2 then
'            graphic print val(inkeyvar$) pos(100)
'        end if
        'GRAPHIC SET POS (1, 90)
        'GRAPHIC PRINT inkeyVar$
        'EXIT FUNCTION

        IF LEN(inkeyVar$)>1 THEN
            Q=ASC(RIGHT$(inkeyVar$,1))

        IF Q>70 THEN
            IF Q=75 THEN cp=cp-10 'left
                IF Q=77 THEN cp=cp+10 'right
                END IF
            GRAPHIC SET POS(cp,1)

        END IF

    END IF
    IF cp > 20 THEN
        GRAPHIC PRINT "fuck" POS(cp)
    END IF

  LOOP

END FUNCTION
