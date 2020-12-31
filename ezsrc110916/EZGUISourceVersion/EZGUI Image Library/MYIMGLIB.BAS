#DIM ALL
#COMPILE DLL
#DEBUG ERROR OFF

#INCLUDE "win32api.inc"

' Use the name of your Resource file below
#RESOURCE "myimglib.pbr"

FUNCTION LIBMAIN(BYVAL hInst&, BYVAL R&, BYVAL lpR&) AS LONG
    SELECT CASE R&
        CASE 1
            REM initialize DLL
        CASE 2
            REM restore DLL after initialized
        CASE 3
            REM exit DLL
        CASE ELSE
    END SELECT
    LIBMAIN=1
END FUNCTION

' This DLL is for resources only and needs no code
