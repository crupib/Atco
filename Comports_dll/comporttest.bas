#COMPILE EXE
#DIM ALL
'atcondt_lib includes functions specific for atco. This includes getting the number of FTDI comm ports:
'
#INCLUDE "atcondt_lib.inc"

FUNCTION PBMAIN () AS LONG
DIM comports(10) AS STRING
LOCAL num_comports AS LONG
LOCAL I AS LONG
num_comports = comportlist(comports())
IF NOT num_comports THEN
    PRINT "No Serial FTDI ports"
END IF

FOR I = 0 TO num_comports - 1
         PRINT comports(I)
     NEXT
WAITSTAT
END FUNCTION
