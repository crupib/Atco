#COMPILE EXE
#DIM ALL
#CONSOLE OFF
#INCLUDE "D:\PBCC60\WinAPI\WIN32API.INC"
FUNCTION PBMAIN () AS LONG
  LOCAL underline&, NormalFont&
  LOCAL mystrings() AS STRING
  DIM MousePoint AS POINTAPI
  LOCAL hWin AS DWORD
  LOCAL widthvar AS LONG
  LOCAL Heightvar AS LONG
  LOCAL inkeyvar AS STRING
  LOCAL NumericVar AS LONG
  LOCAL myclick AS LONG
  LOCAL myint AS INTEGER
  LOCAL cp, Q, rp, colpt,rowpt AS LONG
  LOCAL temppt AS LONG
  DIM mystrings$(3)
  LOCAL numrows AS LONG
  LOCAL mystring, s, mystring1, mystring3 AS STRING
  DESKTOP GET SIZE TO widthvar, Heightvar
  GRAPHIC WINDOW  "Atco MCU Test",widthvar/4, Heightvar/4,600, 400 TO hWin
  GRAPHIC ATTACH hWin, 0
  numrows = 3
  mystring  = "Hello atco  test"
  mystring1 = "Hello junk  test"
  mystring3 = "Hello shit  test"
  mystrings$(1) = mystring
  mystrings$(2) = mystring1
  mystrings$(3) = mystring3
  FONT NEW "myfont", 10, 4, 0, 1 TO underline&
  FONT NEW "myfont1",10 , 0, 0, 1 TO NormalFont&
  GRAPHIC SET FONT NormalFont&
  GRAPHIC PRINT mystrings$(1) POS(1)
  GRAPHIC SET POS(1,GRAPHIC(CHR.SIZE.Y))
  GRAPHIC PRINT mystrings$(2)POS(1)
  temppt =  GRAPHIC(CHR.SIZE.Y)
  temppt = temppt+GRAPHIC(CHR.SIZE.Y)
  GRAPHIC SET POS(1,temppt)
  GRAPHIC PRINT mystrings$(3)POS(1)
  'FONT END NormalFont&
  GRAPHIC SET FONT underline&
  GRAPHIC SET POS(1,0)
  s$  = MID$(mystrings$(1), 1, 1)
  GRAPHIC PRINT s$ POS(1)
  'FONT END underline&
  CP = 0 'GRAPHIC(CHR.SIZE.X)
  RP = 0
  colpt = 1
  rowpt = 1
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
            IF Q = 77 THEN
               colpt = colpt + 1
               cp = cp+GRAPHIC(CHR.SIZE.X)
               IF colpt > LEN(mystrings$(rowpt)) THEN
                    colpt = colpt - 1
                    cp = cp-GRAPHIC(CHR.SIZE.X)
               END IF
               GRAPHIC SET FONT underline&
               GRAPHIC SET POS(cp,rp)
               s$  = MID$(mystrings$(rowpt), colpt, 1)
               GRAPHIC PRINT s$ POS(cp)
               GRAPHIC SET FONT NormalFont&
               GRAPHIC SET POS(cp-GRAPHIC(CHR.SIZE.X),rp)
               s$  = MID$(mystrings$(rowpt), colpt-1, 1)
               GRAPHIC PRINT s$ POS(cp)

            END IF
            IF Q = 75 THEN
               colpt = colpt - 1
               cp = cp-GRAPHIC(CHR.SIZE.X)
               IF colpt < 1 THEN
                    colpt = 1
                    cp = cp+GRAPHIC(CHR.SIZE.X)
               END IF
               GRAPHIC SET FONT underline&
               GRAPHIC SET POS(cp,rp)
               s$  = MID$(mystrings$(rowpt), colpt, 1)
               GRAPHIC PRINT s$ POS(cp)
               GRAPHIC SET FONT NormalFont&
               GRAPHIC SET POS(cp+GRAPHIC(CHR.SIZE.X),rp)
               s$  = MID$(mystrings$(rowpt), colpt+1, 1)
               GRAPHIC PRINT s$ POS(cp)
            END IF
            IF Q=80 THEN
               rowpt = rowpt + 1
               rp = rp+GRAPHIC(CHR.SIZE.Y)
               IF rowpt > numrows THEN
                    rowpt = rowpt - 1
                    rp = rp-GRAPHIC(CHR.SIZE.Y)
               END IF
               GRAPHIC SET FONT underline&
               GRAPHIC SET POS(cp,rp)
               s$  = MID$(mystrings$(rowpt), colpt, 1)
               GRAPHIC PRINT s$ POS(cp)
               GRAPHIC SET FONT NormalFont&
               GRAPHIC SET POS(cp,rp-GRAPHIC(CHR.SIZE.Y))
               s$  = MID$(mystrings$(rowpt-1), colpt, 1)
               GRAPHIC PRINT s$ POS(cp)
            END IF
            IF Q=72 THEN
               rowpt = rowpt - 1
               rp = rp-GRAPHIC(CHR.SIZE.Y)
               IF rowpt < 1 THEN
                    rowpt = rowpt + 1
                    rp = rp+GRAPHIC(CHR.SIZE.Y)
               END IF
               GRAPHIC SET FONT underline&
               GRAPHIC SET POS(cp,rp)
               s$  = MID$(mystrings$(rowpt), colpt, 1)
               GRAPHIC PRINT s$ POS(cp)
               GRAPHIC SET FONT NormalFont&
               GRAPHIC SET POS(cp,rp+GRAPHIC(CHR.SIZE.Y))
               s$  = MID$(mystrings$(rowpt+1), colpt, 1)
               GRAPHIC PRINT s$ POS(cp)
            END IF
        END IF
    END IF
  LOOP

END FUNCTION
