
#COMPILER PBCC 6
#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG

LOCAL sResult AS STRING
LOCAL hwin AS LONG
LOCAL num AS DWORD


LOCAL hFont AS LONG

LOCAL WidthVar,HeightVar AS LONG

LOCAL cm, mm, ppiX, ppiY, x, y, x1, y1, x2, y2, x3, x4 AS LONG

LOCAL w!, h!


GRAPHIC WINDOW NEW "Preview", 10, 10, 1000, 1000 TO hwin
GRAPHIC SET VIRTUAL 5100, 6900 ,USERSIZE

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


INPUT "Press any key ", sResult

CALL PrintGC_Style1 ' print preview to the graphic window

XPRINT PREVIEW CLOSE

INPUT "EXIT Do you want to print scale Y/N? ", sResult

IF UCASE$(sResult) = "Y" THEN ' ok to print
IF ERR OR LEN(XPRINT$) = 0 THEN ' on failure
? "XPRINT ATTACH failed!" ' print reason and exit
ELSE
CALL PrintGC_Style1 ' print to the host printer
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
' unsigned int binaryToGray(unsigned int num)
' {
' return num ^ (num >> 1);
' }

FUNCTION binaryToGray(num AS DWORD) AS DWORD

LOCAL num1 AS DWORD

num1 = num

SHIFT RIGHT num1, 1

binaryToGray = num XOR num1

EXIT FUNCTION

END FUNCTION




' Print a GrayCode style 1
'
SUB PrintGC_Style1

LOCAL xpos1,ypos1,xpos2,ypos2, xoffset, yoffset, gwidth, gheight AS SINGLE
LOCAL num, nums, nume, gcode AS DWORD

xoffset = 10 : yoffset = 10
gwidth = 4 : gheight = 4

'nums = 0 : nume = 1023
nums = 64500 : nume = 65535 '16 bit gray scale: set gray code start, to gray code end


FOR num = nums TO nume

xpos1 = ((num-nums) * gwidth) + xoffset
xpos2 = xpos1 + gwidth

gcode = binaryToGray(num)

IF (gcode AND 1) THEN
yPos1 = yoffset
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 2) THEN
yPos1 = yoffset + gheight
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 4) THEN
yPos1 = yoffset + (gheight * 2)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 8) THEN
yPos1 = yoffset + (gheight * 3)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 16) THEN
yPos1 = yoffset + (gheight * 4)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 32) THEN
yPos1 = yoffset + (gheight * 5)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 64) THEN
yPos1 = yoffset + (gheight * 6)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 128) THEN
yPos1 = yoffset + (gheight * 7)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 256) THEN
yPos1 = yoffset + (gheight * 8)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 512) THEN
yPos1 = yoffset + (gheight * 9)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 1024) THEN
yPos1 = yoffset + (gheight * 10)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 2048) THEN
yPos1 = yoffset + (gheight * 11)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 4096) THEN
yPos1 = yoffset + (gheight * 12)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 8192) THEN
yPos1 = yoffset + (gheight * 13)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 16384) THEN
yPos1 = yoffset + (gheight * 14)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

IF (gcode AND 32768) THEN
yPos1 = yoffset + (gheight * 15)
ypos2 = ypos1 + gheight
XPRINT BOX (xpos1, ypos1) - (xpos2, ypos2), 0, -1, -1, 0
END IF

NEXT

BEEP


END SUB
