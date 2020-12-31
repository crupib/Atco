#COMPILE EXE
#DIM ALL
#INCLUDE "win32api.inc"
FUNCTION PBMAIN () AS LONG
    LOCAL x AS LONG
    LOCAL timecount1, timecount2 AS DWORD
    SetPriorityClass( GetCurrentProcess(),%REALTIME_PRIORITY_CLASS)
    SetProcessAffinityMask(GetCurrentProcess(), 0)
    x = 0
    timecount1 = GetTickCount()
    WHILE x < 2000000000
        x = x + 1
        'print x
    WEND
    timecount2 = GetTickCount()
    PRINT timecount2 - timecount1
    WAITKEY$
END FUNCTION
