#COMPILE EXE
#DIM ALL

FUNCTION PBMAIN () AS LONG
LOCAL x,y AS LONG
CON.CURSOR.ON
x = 60
y = 1
DO WHILE 1

  IF CON.INSTAT THEN
      CON.LOCATE TO x,y
      CON.PRINT "hello"
  END IF
LOOP
END FUNCTION
