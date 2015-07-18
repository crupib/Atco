#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
LOCAL filename AS STRING
DIM sNum AS LOCAL  LONG
DIM tempNum AS LOCAL LONG
filename = "mytest.bin"
LOCAL filenumber AS LONG
filenumber = FREEFILE
tempNum = 0
OPEN filename FOR BINARY AS filenumber BASE = 0
sNum = 1000
PUT filenumber,  0 ,sNum
CLOSE filenumber
SLEEP 100
OPEN filename FOR BINARY AS #filenumber BASE = 0
GET filenumber, 0, tempNum
PRINT tempNum
WAITKEY$
END FUNCTION
