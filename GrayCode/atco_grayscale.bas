'File Name: Print_GrayCode_9E.BAS

#COMPILER PBCC 6
#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG

LOCAL sResult AS STRING
LOCAL hwin AS LONG
LOCAL gCodeI AS DWORD

LOCAL hFont AS LONG

LOCAL WidthVar,HeightVar AS LONG

LOCAL cm, mm, ppiX, ppiY, x, y, x1, y1, x2, y2, x3, x4 AS LONG

LOCAL w!, h!

LOCAL pageWidth, pageHeight AS DWORD

pageWidth = 4000 * 8.50#
pageHeight = 4000 * 11.50#


GRAPHIC WINDOW NEW "Preview", 10, 10, 1000, 1000 TO hwin
GRAPHIC SET VIRTUAL 5100, 6900 ,USERSIZE

'GRAPHIC SET VIRTUAL pageWidth, pageHeight, USERSIZE

XPRINT ATTACH DEFAULT, "Print GrayScale"
XPRINT PREVIEW hWin, 0

XPRINT SET QUALITY 1&
XPRINT WIDTH 1&

'----------------------------------------------------------------
' Get Printer Info
'----------------------------------------------------------------
XPRINT GET PPI TO ppiX, ppiY
XPRINT GET MARGIN TO x1, y1, x2, y2
XPRINT GET SIZE TO WidthVar, HeightVar
XPRINT GET CANVAS TO w,h

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

PRINT GrayToBinary(65535)

PRINT BinaryToGray(43690)

'INPUT "Press any key ", sResult

CALL PrintGC_Style3 ' print preview to the graphic window

XPRINT PREVIEW CLOSE

INPUT "EXIT Do you want to print scale Y/N? ", sResult

IF UCASE$(sResult) = "Y" THEN ' ok to print
IF ERR OR LEN(XPRINT$) = 0 THEN ' on failure
? "XPRINT ATTACH failed!" ' print reason and exit
ELSE
CALL PrintGC_Style3 ' print to the host printer
END IF
END IF

XPRINT CLOSE

INPUT "PRESS ANY KEY TO EXIT ", sResult

END FUNCTION

' /*
' * This function converts an unsigned binary
' * number to reflected binary Gray code.
' *
' * The operator >> is shift right. The operator ^ is exclusive or.
' */
' unsigned int binaryToGray(unsigned int gCodeI)
' {
' return gCodeI ^ (gCodeI >> 1);
' }

FUNCTION binaryToGray(num AS DWORD) AS DWORD

binaryToGray = num XOR SR(num,1)

EXIT FUNCTION

END FUNCTION

' /*
' * This function converts a reflected binary
' * Gray code number to a binary number.
' * Each Gray code bit is exclusive-ored with all
' * more significant bits.
' * A more efficient version, for Gray codes of 32 or fewer bits.
' */
' unsigned int grayToBinary32(unsigned int num)
' {
' num = num ^ (num >> 16);
' num = num ^ (num >> 8);
' num = num ^ (num >> 4);
' num = num ^ (num >> 2);
' num = num ^ (num >> 1);
' return num;
' }

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



' Print GrayCode style 3
'
SUB PrintGC_Style3

LOCAL xpos1, ypos1, xpos2, ypos2, xoffset, yoffset AS SINGLE

LOCAL gCodePtsH, gCodePtsA, gZoom AS SINGLE
LOCAL gCodeI, gCodeS, gCodeE, gCodePtsB, gCodeB, gCode AS DWORD

LOCAL corner AS LONG
LOCAL Pi2 AS DOUBLE

LOCAL pRes AS DWORD 'printer resolution, ppi
LOCAL gCodeInchW, gCodeInchH, gCodeInchA, gCodeInchB, gCodeInchT AS DOUBLE 'physical size of printed code, per bit, in inches
LOCAL gScaleL AS DOUBLE 'physical length of printed gray coded scale
LOCAL gCodePtsW AS DWORD 'physical size of printed code, per bit, in points
LOCAL gCodePtsT AS DWORD '
LOCAL gCodeT AS DWORD 'number of codes to print, uses (3) spaces per code: blank space, alignment line, code line

Pi2 = 4 * ATN(1) * 2 ' Calculate Pi

pRes = 4000 'set printer resolution, points per inch

gCodeInchW = .0100## '.00600## 'gray code width, inches
gCodePtsW = pRes * gCodeInchW 'gray code width, printer points

gCodeInchA = .0100## '.00600## 'alignment line width, inches
gCodePtsA = pRes * gCodeInchA 'alignment line width, printer points

gCodeInchB = .0200## '.01200## '0600## 'column space between gray codes, inches
gCodePtsB = pRes * gCodeInchB 'column space between gray codes, printer points

gCodeInchT = gCodeInchW+gCodeInchA+gCodeInchB 'gray code total width, inches
gCodePtsT = pRes * gCodeInchT 'gray code total width, printer points

gCodeInchH = .0100## '.00600## 'gray code height, inches
gCodePtsH = pRes * gCodeInchH 'gray code height, printer points

'apply Zoom factor
gZoom = 1.00!
gCodePtsW = gCodePtsW * gZoom
gCodePtsA = gCodePtsA * gZoom
gCodePtsB = gCodePtsB * gZoom
gCodePtsH = gCodePtsH * gZoom
gCodePtsT = gCodePtsT * gZoom

gScaleL = 10.000## '6.500## 'length of scale to be printed, in inches

gCodeT = (gScaleL*pRes)/gCodePtsT 'number of gray codes that fit into specified scale length

'gCodeS = 43690 : gCodeE = gCodeS + gCodeT '16 bit gray scale: set gray code start, to gray code end

'gCodeE = 4095 : gCodeS = gCodeE - gCodeT '16 bit gray scale: set gray code start, to gray code end

gCodeS = 0 : gCodeE = gCodeS + gCodeT '16 bit gray scale: set gray code start, to gray code end

PRINT gCodeT

gCodeB = 12 'gray scale, number of bits

xoffset = 2000

'The percentage of roundness of the corners, in the range of 0 to 100
corner = 0


XPRINT COLOR %BLACK, %WHITE 'red 'white '%WHITE ,%BLACK

LOCAL gScale, gScaleS, gScaleE AS DWORD

gScaleS = 0 : gScaleE = 16


FOR gScale = gScaleS TO gScaleE


gCodeS = gScale * 250: gCodeE = gCodeS + 249 'gCodeS + gCodeT '16 bit gray scale: set gray code start, to gray code end
'yoffset = 34000 - 1200 - (2000*gScale) ''32000 ' start printing from 1.00" left and top, margin
yoffset = 34000 - 2000 - (1900*gScale) ''32000 ' start printing from 1.00" left and top, margin

PRINT gCodeS; gCodeE; yoffset


FOR gCodeI = gCodeS TO gCodeE

IF gCodeI > 4095 THEN EXIT FOR ' cut out if past 12 bits

xpos1 = xoffset + (gCodeI-gCodeS) * gCodePtsT '(gCodePtsW+gCodePtsA+gCodePtsB)
xpos2 = xpos1 + gCodePtsW

gCode = binaryToGray(gCodeI)

IF (gCode AND 1) THEN
yPos1 = yoffset + (gCodePtsH * 11) '0)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 2) THEN
yPos1 = yoffset + (gCodePtsH * 10)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 4) THEN
yPos1 = yoffset + (gCodePtsH * 9)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 8) THEN
yPos1 = yoffset + (gCodePtsH * 8)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 16) THEN
yPos1 = yoffset + (gCodePtsH * 7)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 32) THEN
yPos1 = yoffset + (gCodePtsH * 6)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 64) THEN
yPos1 = yoffset + (gCodePtsH * 5)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 128) THEN
yPos1 = yoffset + (gCodePtsH * 4)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 256) THEN
yPos1 = yoffset + (gCodePtsH * 3)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 512) THEN
yPos1 = yoffset + (gCodePtsH * 2)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 1024) THEN
yPos1 = yoffset + (gCodePtsH * 1)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 2048) THEN
yPos1 = yoffset + (gCodePtsH * 0)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF


IF (gCode AND 4096) THEN
yPos1 = yoffset + (gCodePtsH * 0)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
'XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 8192) THEN
yPos1 = yoffset + (gCodePtsH * 1)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

IF (gCode AND 16384) THEN
yPos1 = yoffset + (gCodePtsH * 14)
ypos2 = ypos1 + gCodePtsH
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
END IF

IF (gCode AND 32768) THEN
yPos1 = yoffset + (gCodePtsH * 15)
ypos2 = ypos1 + gCodePtsH
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0
END IF

'Print vertical alignment marker
xpos2 = xpos1
xpos1 = xpos2 - gCodePtsA

yPos1 = yoffset
ypos2 = yPos1 + (gCodePtsH * gCodeB)
'XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), corner, -1, -1, 0
XPRINT BOX (ypos1, xpos1) - (ypos2, xpos2), corner, -1, -1, 0

NEXT

NEXT

BEEP


END SUB
