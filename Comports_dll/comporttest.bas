#COMPILE EXE
#DIM ALL

DECLARE FUNCTION comportlist LIB "atcondt_lib.dll" _
         ALIAS "comportlist" (BYREF parm1() AS STRING) AS LONG


FUNCTION PBMAIN () AS LONG
DIM comports(10) AS STRING
LOCAL num_comports AS LONG
LOCAL I AS LONG
num_comports = comportlist(comports())
FOR I = 0 TO num_comports - 1
         PRINT comports(I)
     NEXT
END FUNCTION