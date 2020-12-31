#DIM ALL
#DEBUG ERROR OFF    ' change to ON if GPF's to test for array out of bounds
#COMPILE DLL

#INCLUDE "C:\ezgui45beta\includes\ezgui50.inc"                          ' EZGUI Include file for Declares

FUNCTION LIBMAIN(BYVAL hInstance   AS LONG, _
                 BYVAL fwdReason   AS LONG, _
                 BYVAL lpvReserved AS LONG) EXPORT AS LONG
    SELECT CASE AS LONG fwdReason
        CASE 1 '    %DLL_PROCESS_ATTACH
        CASE 2 '    %DLL_THREAD_ATTACH
        CASE 3 '    %DLL_THREAD_DETACH
        CASE 0 '    %DLL_PROCESS_DETACH
        CASE ELSE
    END SELECT
    LIBMAIN=1
END FUNCTION

#INCLUDE "ezcust3.inc"

FUNCTION EZC_InitCust(BYVAL N&) EXPORT AS STRING
     EZC_ColorList_Init N&
     ' return control class name and Type index
     FUNCTION="ColorList|2|<&H000000>Black,<&H0000FF>Red,<&H00FF00>Green,<&HFF0000>Blue"
END FUNCTION
