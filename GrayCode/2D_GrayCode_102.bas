#COMPILER PBCC 6
#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG

    LOCAL sResult AS STRING
    LOCAL hwin AS LONG
    LOCAL xCode AS DWORD

    LOCAL hFont AS LONG

    LOCAL WidthVar,HeightVar AS LONG

    LOCAL cm, mm, ppiX, ppiY, x, y, x1, y1, x2, y2, x3, x4 AS LONG

    LOCAL w!, h!

    LOCAL ncWidth!, ncHeight!

    LOCAL pageWidth, pageHeight AS DWORD

    'XPRINT ATTACH DEFAULT, "Print GrayScale"

    'XPRINT GET PPI TO ppiX, ppiY

    'PRINT "ppiX, ppiY: " ppiX, ppiY

    pageWidth = 4000 * 8.50#
    pageHeight = 4000 * 11.00#

    'pageWidth = 600 * 8.50#
    'pageHeight = 600 * 11.00#

    'pageWidth = 600 * 8.50#
    'pageHeight = 600 * 11.00#

    pageWidth = 5100 '8500 '* 8.50#
    pageHeight = 6600 '10000 '* 11.00#

    'GRAPHIC WINDOW NEW "Print GrayScale", 10, 10, 850, 1100 TO hwin
    GRAPHIC WINDOW NEW "Print GrayScale", 10, 10, 425, 500 TO hwin

    'GRAPHIC SET VIRTUAL  5100, 6600 ,USERSIZE

    'GRAPHIC SET VIRTUAL  4000, 2000 ,USERSIZE

    'GRAPHIC WINDOW NEW "Preview", 10, 10, 1000, 1000 TO hwin
    GRAPHIC SET VIRTUAL  pageWidth, pageHeight ,USERSIZE


    'GRAPHIC SET VIRTUAL  pageWidth, pageHeight', USERSIZE

    XPRINT ATTACH DEFAULT, "Print GrayScale"
    XPRINT PREVIEW hWin, 0

    XPRINT SET QUALITY 4&
    XPRINT WIDTH 1&

    '----------------------------------------------------------------
    ' Get Printer Info
    '----------------------------------------------------------------
    XPRINT GET PPI TO ppiX, ppiY
    XPRINT GET MARGIN TO x1, y1, x2, y2
    XPRINT GET SIZE TO WidthVar, HeightVar
    XPRINT GET CANVAS TO w,h

    ' Retrieve the client size (printable area) of the printer page

    XPRINT GET CLIENT TO ncWidth!, ncHeight!

    PRINT "ppi X ="; ppiX
    PRINT "ppi Y ="; ppiY

    PRINT "Margin x1 ="; x1
    PRINT "Margin x2 ="; x2
    PRINT "Margin y1 ="; y1
    PRINT "Margin y2 ="; y2
    PRINT "Width ="; WidthVar
    PRINT "Height ="; Heightvar
    PRINT "Canvas Width ="; w
    PRINT "Canvas Height ="; h
    PRINT "Client Width ="; ncWidth!
    PRINT "Client Height ="; ncHeight!

    CALL PrintGC_Style4    ' print preview to the graphic window

    XPRINT PREVIEW CLOSE

    INPUT "EXIT Do you want to print scale Y/N? ", sResult

    IF UCASE$(sResult) = "Y" THEN  ' ok to print
       IF ERR OR LEN(XPRINT$) = 0 THEN  ' on failure
          ? "XPRINT ATTACH failed!"    ' print reason and exit
       ELSE
          CALL PrintGC_Style4    ' print to the host printer
       END IF
    END IF

    XPRINT CLOSE

    INPUT "PRESS ANY KEY TO EXIT ", sResult

END FUNCTION

'    /*
'    * This function converts an unsigned binary
'    * number to reflected binary Gray code.
'    *
'    * The operator >> is shift right. The operator ^ is exclusive or.
'    */
'    unsigned int binaryToGray(unsigned int xCode)
'    {
'    return xCode ^ (xCode >> 1);
'    }

FUNCTION binaryToGray(num AS DWORD) AS DWORD

         binaryToGray = num XOR SR(num,1)

         EXIT FUNCTION

END FUNCTION

'   /*
'   * This function converts a reflected binary
'   * Gray code number to a binary number.
'   * Each Gray code bit is exclusive-ored with all
'   * more significant bits.
'   * A more efficient version, for Gray codes of 32 or fewer bits.
'    */
'   unsigned int grayToBinary32(unsigned int num)
'   {
'       num = num ^ (num >> 16);
'       num = num ^ (num >> 8);
'       num = num ^ (num >> 4);
'       num = num ^ (num >> 2);
'       num = num ^ (num >> 1);
'       return num;
'   }

FUNCTION GrayToBinary(BYVAL num AS DWORD) AS DWORD

         'num = num XOR SR(num,16)
         num = num XOR SR(num,8)
         num = num XOR SR(num,4)
         num = num XOR SR(num,2)
         num = num XOR SR(num,1)

         GrayToBinary = num

         EXIT FUNCTION

END FUNCTION


FUNCTION SR(BYVAL num AS DWORD, nBits AS DWORD) AS DWORD

         SHIFT RIGHT num, nBits

         SR = num

         EXIT FUNCTION

END FUNCTION

' Print GrayCode style 4
'
SUB PrintGC_Style4

    LOCAL xpos1, ypos1, xpos2, ypos2 AS SINGLE

    LOCAL gZoom AS SINGLE
    LOCAL xCode, xCodeS, xCodeE,gCodeBits, gCode AS DWORD

    LOCAL ans$

    LOCAL Pi2 AS DOUBLE

    LOCAL pRes,ppiX, ppiY   AS DWORD       'printer resolution, ppi

    LOCAL xLength AS DOUBLE  'physical length of printed gray coded scale

    LOCAL gCodeInchW, gCodeInchH, gCodeInchA, gCodeInchB, gCodeInchTw, gCodeInchTh AS DOUBLE  'size of printed codes, inches
    LOCAL gCodePtsW, gCodePtsH, gCodePtsA, gCodePtsB, gCodePtsTw, gCodePtsTh  AS SINGLE  'size of printed codes, points
    LOCAL xOffsetPts, yOffsetPts, pageW, pageH, canvasW, canvasH, marginL, marginR, marginT, marginB, marginS AS SINGLE

    LOCAL NumXCodes AS DWORD    'number of codes to print, uses (3) spaces per code: blank space, alignment line, code line

    LOCAL corner, rgbColor, fillcolor, fillstyle, corner2, rgbColor2, fillcolor2, fillstyle2  AS LONG

    LOCAL Reverse AS LONG


    'Pi2 = 4 * ATN(1) * 2                             ' Calculate Pi

    'gCodeBits = 16 'gray scale, number of bits

    XPRINT GET PPI TO ppiX, ppiY

    pRes = ppiX                     'set printer resolution, points per inch

    gCodeInchW = .0100##            'gray code bit width, inches
    gCodePtsW = pRes * gCodeInchW   'gray code bit width, printer points

    gCodeInchA = .0100##            'alignment block width, inches
    gCodePtsA = pRes * gCodeInchA   'alignment block width, printer points

    gCodeInchB = .0100##          'column space between gray codes, inches
    gCodePtsB = pRes * gCodeInchB   'column space between gray codes, printer points

    gCodeInchH = .0100##            'gray code bit height, inches
    gCodePtsH = pRes * gCodeInchH   'gray code bit height, printer points

    gCodeInchTw = 0.080## 'gCodeInchW+gCodeInchA+gCodeInchB 'single gray code total width, inches
    gCodePtsTw = pRes * gCodeInchTw                 'single gray code total width, printer points

    gCodeInchTh = 0.080# 'gCodeInchH * gCodeBits 'single gray code total height, inches
    gCodePtsTh = pRes * gCodeInchTh      'single gray code total height, printer points

    'apply Zoom factor
    gZoom = 1.00!
    gCodePtsW = gCodePtsW * gZoom
    gCodePtsA = gCodePtsA * gZoom
    gCodePtsB = gCodePtsB * gZoom
    gCodePtsH = gCodePtsH * gZoom
    gCodePtsTw = gCodePtsTw * gZoom
    gCodePtsTh = gCodePtsTh * gZoom
    gCodeInchTw = gCodeInchTw * gZoom
    gCodeInchTh = gCodeInchTh * gZoom

    corner = 0          'The percentage of roundness of the corners, in the range of 0 to 100

    'Bit ON
    rgbColor = %BLACK 'gray 'white 'gray '%white 'ltgray '%BLACK   'If fillstyle& is omitted, the default fill style is solid (0).
    fillcolor = %BLACK  'If fillcolor& is omitted (or -2), the interior of the box is not filled,
    fillstyle = 0       '0=Solid(default):1=Horizontal:2=Vertical:3=Upward Diag:4=Downward Diag:5=Crossed:6=Diag Crossed

    'Bit OFF
    rgbColor2 = %BLACK '%BLACK '%white   'If fillstyle& is omitted, the default fill style is solid (0).
    fillcolor2 = -2 '%white  'If fillcolor& is omitted (or -2), the interior of the box is not filled,
    fillstyle2 = 0       '0=Solid(default):1=Horizontal:2=Vertical:3=Upward Diag:4=Downward Diag:5=Crossed:6=Diag Crossed

    LOCAL yCode, yCodeS, yCodeE, NumYCodes AS DWORD
    LOCAL yLength AS SINGLE

    LOCAL gBit AS DWORD
    LOCAL x, y, y1, y2, x1, x2 AS SINGLE

    pageW = 8.50!
    pageH = 11.00!
    marginL = 0.500!
    marginR = marginL
    marginT = marginL
    marginB = marginL
    'marginS = 0.500!  'margin between printed scales

    canvasH =  pageH - (marginT + marginB)  'available page height print area, inches
    NumXCodes = FIX(canvasH/gCodeInchTh)    'number of X-Axis gray code increments, that fit available print area
    xLength = (NumXCodes * gCodeInchTh)     'resulting width of X-Axis gray codes, in inches

    canvasW = pageW - (marginL + marginR)   'available page width print area, inches
    NumYCodes = FIX(canvasW/gCodeInchTw)    'number of Y-Axis gray code increments, that fit into available page width
    yLength = (NumYCodes * gCodeInchTw)     'resulting height of Y-Axis gray codes, in inches

    yCodeS = 0 : yCodeE = NumYCodes-1       'number of gray codes to print along Y-Axis

    Reverse = 0 'if = 1, reverse image for printing transparency (print is viewed with printed surface on bottom)


    FOR yCode = yCodeS TO yCodeE  'Y-Axis gray code start to gray code end

        xCodeS = 0 : xCodeE = NumXCodes - 1 'X-Axis gray code start to gray code end

        yOffsetPts = ((pageW-marginR)*pRes)-(gCodePtsTh*yCode) 'start printing at RIGHT margin and (marginS) between subsequent scale's printed

        FOR xCode = xCodeS TO xCodeE    'X-Axis gray code start to gray code end

            IF Reverse THEN  'reverse image for transparency
               xOffsetPts = ((pageH-marginT)*pRes)-(gCodePtsTw*xCode)
            ELSE
               xOffsetPts = (pRes * marginT) + (gCodePtsTw * (xCode-xCodeS))  'start printing .500" from top, margin
            END IF

            gCode = binaryToGray(xCode)

            FOR x = 0 TO 2          'X-AXIS: print individual bits of current gray code

                IF Reverse THEN  'reverse image for transparency
                   x1 = xOffsetPts - (gCodePtsW*x)
                   x2 = x1 - gCodePtsW
                ELSE
                   x1 = xOffsetPts + (gCodePtsW*x)
                   x2 = x1 + gCodePtsW
                END IF

                FOR y = 0 TO 5

                    IF (x = 2) AND (y > 3) THEN EXIT FOR

                    y1 = yOffsetPts - (gCodePtsH*y)
                    y2 = y1 - gCodePtsH

                    gbit = y + (x*6)

                    IF (gCode AND (2 ^ gbit)) THEN  'bit on, draw bit box, fill
                       XPRINT BOX  (y1,  x1) - (y2, x2), corner, rgbColor, fillcolor, fillstyle
                    ELSE                            'bit off, draw bit box, blank
                       XPRINT BOX  (y1,  x1) - (y2, x2), corner, rgbColor2, fillcolor2, fillstyle2
                    END IF

                NEXT

            NEXT

            gCode = binaryToGray(yCode)

            FOR x = 3 TO 5   'Y-AXIS: print individual bits of current gray code

                IF Reverse THEN  'reverse image for transparency
                   x1 = xOffsetPts - (gCodePtsW*x)
                   x2 = x1 - gCodePtsW
                ELSE
                   x1 = xOffsetPts + (gCodePtsW*x)
                   x2 = x1 + gCodePtsW
                END IF

                FOR y = 0 TO 5

                    IF (x = 5) AND (y > 3) THEN EXIT FOR

                    y1 = yOffsetPts - (gCodePtsH*y)
                    y2 = y1 - gCodePtsH

                    gbit = y + ((x-3)*6)

                    IF (gCode AND (2 ^ gbit)) THEN  'bit on, fill bit box
                       XPRINT BOX  (y1,  x1) - (y2, x2), corner, rgbColor, fillcolor, fillstyle
                    ELSE                            'bit off, blank bit box
                       XPRINT BOX  (y1,  x1) - (y2, x2), corner, rgbColor2, fillcolor2, fillstyle2
                    END IF

                NEXT

            NEXT

        NEXT  'next xCode

    NEXT      'next yCode

    'print Y axis alignment lines

    FOR yCode = 0 TO NumYCodes         'number of Gray Codes printed along Y-Axis

        yOffsetPts = ((pageW-marginR)*pRes) - (gCodePtsTh*yCode) 'start printing at RIGHT margin and (marginS) between subsequent scale's printed

        IF Reverse THEN  'reverse image for transparency
           x1 = ((pageH-marginB) * pRes) + (1.500# * gCodePtsW)
           x2 = x1 - ((xLength*pRes) + gCodePtsW)
        ELSE
           x1 = (marginB * pRes) - (1.500# * gCodePtsW)
           x2 = x1 + (xLength*pRes) + gCodePtsW
        END IF

        y1 = yOffsetPts + (1.500# * gCodePtsH)
        y2 = y1 - gCodePtsH

        XPRINT BOX(y1,  x1) - (y2, x2), corner, %BLACK, %BLACK, 0  'print Y axis alignment line

    NEXT

    'print X axis alignment lines

    FOR xCode = 0 TO NumXCodes     'number of Gray Codes printed along X-Axis

        IF Reverse THEN  'reverse image for transparency
           xOffsetPts = ((pageH-marginB) * pRes) - (gCodePtsTW*xCode)  'start printing .500" from top, margin
           x1 = xOffsetPts + (1.500# * gCodePtsW)
           x2 = x1 - gCodePtsW
        ELSE
           xOffsetPts = (pRes * marginT) + (gCodePtsTW*xCode)  'start printing .500" from top, margin
           x1 = xOffsetPts - (1.500# * gCodePtsW)
           x2 = x1 + gCodePtsW
        END IF

        y1 = ((pageW-marginR) * pRes) + (1.500# * gCodePtsH)
        y2 = y1 - ((yLength*pRes) + gCodePtsH)

        XPRINT BOX(y1,  x1) - (y2, x2), corner, %BLACK, %BLACK, 0 'print X axis alignment line

    NEXT

    BEEP

END SUB
