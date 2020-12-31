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

#INCLUDE "ezcust2.inc"

FUNCTION EZC_InitCust(BYVAL N&) EXPORT AS STRING
     EZC_FontCombo_Init N&
     ' return control class name and Type index
     FUNCTION="FontCombo|1|Arial<R>ABC ,Arial Black<R>ABC ,Courier New<R>ABC ,Tahoma<R>ABC "
END FUNCTION