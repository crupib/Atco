#COMPILE EXE
#DIM ALL
#INCLUDE "win32api.inc"
FUNCTION PBMAIN () AS LONG

SetPriorityClass(GetCurrentProcess(), %REALTIME_PRIORITY_CLASS)

WHILE 1
    PRINT 1
WEND

END FUNCTION
