#COMPILE EXE
#DIM ALL
#INCLUDE "userinterface.inc"
FUNCTION PBMAIN () AS LONG
LOCAL lRetVal  AS LONG
LOCAL string_variable AS STRING

lRetVal = KLJMessageBox( "Calibration failed", "Atco Scanner",%MB_YESNOCANCEL )
IF lRetVal = %MB_YES  THEN
   PRINT "Yes"
   WAITKEY$
END IF
string_variable = KLJInput("Enter X value", "ATCO Input ", "", 100,100)
PRINT string_variable
WAITKEY$
END FUNCTION
