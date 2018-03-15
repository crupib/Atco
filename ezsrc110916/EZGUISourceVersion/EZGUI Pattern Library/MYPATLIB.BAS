#DIM ALL
#COMPILE DLL
#DEBUG ERROR OFF
#INCLUDE "win32api.inc"

' Use your Resource filename below !
#RESOURCE "mypatlib.pbr"

FUNCTION LIBMAIN(BYVAL hInst&, BYVAL R&, BYVAL lpR&) AS LONG
    SELECT CASE R&
        CASE 1
            REM initialize DLL
        CASE 2
            REM restore DLL after initialized
        CASE 3
            REM EXIT DLL
        CASE ELSE
    END SELECT
    LIBMAIN=1
END FUNCTION

' This DLL is for resources only and needs no code
