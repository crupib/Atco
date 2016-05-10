'====================================================================
'
'  PrintCircle.bas example for PowerBASIC Console Compiler
'  Copyright (c) 2006 - 2016 ATCO, Inc.
'  All Rights Reserved.
'
'  Small XPRINT example, printing circle, line, box
'
'====================================================================

#COMPILER PBCC 6
#COMPILE EXE
#DIM ALL

' Program entrance.
'
FUNCTION PBMAIN () AS LONG

    LOCAL sResult AS STRING

    DO
        CLS
        INPUT "Do you want to print Geometric shapes (Y/N)? ", sResult
        CLS
        IF UCASE$(sResult) = "Y" THEN  ' ok to print
     '       XPRINT_CIRCLE
            XPRINT_PREVIEW
        ELSE
            EXIT FUNCTION  ' else quit
        END IF

        PRINT "Press Esc to exit, else press any key to repeat."
    LOOP UNTIL WAITKEY$ = $ESC

END FUNCTION



' Print a simple Circle
'
SUB XPRINT_PREVIEW
    LOCAL h AS LONG
 '   GRAPHIC WINDOW NEW "Preview", 0,0,1200,1000 TO h&
    GRAPHIC WINDOW NEW "Preview", 10, 10, 500, 500 TO h&
    GRAPHIC SET VIRTUAL 5100, 6600 ,USERSIZE
    XPRINT ATTACH DEFAULT, "Print Circle"
    IF ERR OR LEN(XPRINT$) = 0 THEN  ' on failure
      ? "XPRINT ATTACH failed!"    ' print reason and exit
      EXIT SUB
    END IF

    XPRINT PREVIEW h&, 0
    CALL PrintIt
    XPRINT PREVIEW CLOSE
    CALL PrintIt
    XPRINT CLOSE

END SUB
SUB PrintIt()
    LOCAL cm, mm, w, h, ppiX, ppiY, x, y, x1, y1, x2, y2, x3, x4 AS LONG
    LOCAL MarginLeft, MarginRight, MarginTop AS LONG
    LOCAL hFont AS LONG
    '----------------------------------------------------------------
    ' Calculate margins
    '----------------------------------------------------------------
    XPRINT GET PPI TO ppiX, ppiY
    XPRINT GET MARGIN TO x1, y1, x2, y2
    MarginLeft  = 0.8 * ppiX - x1
    MarginRight = 0.8 * ppiX - x2
    MarginTop   = 0.4 * ppiX - y1

    '----------------------------------------------------------------
    ' Print centered title
    '----------------------------------------------------------------
    XPRINT COLOR -1, -1

    FONT NEW "Times New Roman", 36, 3 TO hFont
    XPRINT SET FONT hFont
    XPRINT TEXT SIZE "Circle" TO x, y
    XPRINT GET CANVAS TO w, h
  '  w = 1200
  '  h = 1000

    XPRINT SET POS (x, MarginTop)
    XPRINT "Circle"

    '----------------------------------------------------------------
    ' Print "Circle"
    '----------------------------------------------------------------
    XPRINT WIDTH (0.01 * ppiX)
    y = 0.4 * ppiY        ' row height
    x4 = w - MarginRight  ' right side
    XPRINT ELLIPSE (x,y+800) - (x+800,y+1600)
    'Print Square'

    XPRINT BOX  (x,  y+1800) - (x+800, y+2600), 3, -1, -2, 0

    FOR x = 16 TO 22       ' draw horizontal lines
        XPRINT LINE (MarginLeft,  x * y - y1) - (x4,  x * y - y1)
    NEXT


    FONT END hFont
END SUB

SUB XPRINT_CIRCLE

    LOCAL cm, mm, w, h, ppiX, ppiY, x, y, x1, y1, x2, y2, x3, x4 AS LONG
    LOCAL MarginLeft, MarginRight, MarginTop AS LONG
    LOCAL hFont AS LONG

    XPRINT ATTACH DEFAULT, "Print Circle"

    IF ERR OR LEN(XPRINT$) = 0 THEN  ' on failure
        ? "XPRINT ATTACH failed!"    ' print reason and exit
        EXIT SUB
    END IF

    '----------------------------------------------------------------
    ' Calculate margins
    '----------------------------------------------------------------
    XPRINT GET PPI TO ppiX, ppiY
    XPRINT GET MARGIN TO x1, y1, x2, y2
    MarginLeft  = 0.8 * ppiX - x1
    MarginRight = 0.8 * ppiX - x2
    MarginTop   = 0.4 * ppiX - y1

    '----------------------------------------------------------------
    ' Print centered title
    '----------------------------------------------------------------
    XPRINT COLOR -1, -1

    FONT NEW "Times New Roman", 36, 3 TO hFont
    XPRINT SET FONT hFont
    XPRINT TEXT SIZE "Invoice" TO x, y
    XPRINT GET CANVAS TO w, h
    x = (w - x) / 2      ' centered x pos
    XPRINT SET POS (x, MarginTop)
    XPRINT "Circle"

    '----------------------------------------------------------------
    ' Print "Circle"
    '----------------------------------------------------------------
    XPRINT WIDTH (0.01 * ppiX)
    y = 0.4 * ppiY        ' row height
    x4 = w - MarginRight  ' right side
    XPRINT ELLIPSE (x,y+800) - (x+800,y+1600)
    'Print Square'

    XPRINT BOX  (x,  y+1800) - (x+800, y+2600), 3, -1, -2, 0

    FOR x = 16 TO 22       ' draw horizontal lines
        XPRINT LINE (MarginLeft,  x * y - y1) - (x4,  x * y - y1)
    NEXT


    FONT END hFont

    XPRINT CLOSE

END SUB
