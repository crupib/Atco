#COMPILE EXE
#DIM ALL
#INCLUDE "atcondt_lib.inc"

FUNCTION PBMAIN () AS LONG

LOCAL iDeviceCount AS DWORD
LOCAL iResult AS INTEGER
LOCAL ulCount, ulPrevCount, ctrlmode AS LONG
LOCAL MyInput AS STRING
PRINT "===================="
PRINT "USB4 Hello Kevin!"
PRINT "===================="
iDeviceCount = 0
iResult = 0
ctrlmode = 0
ulPrevCount = &HFFFFFFFF


PRINT "===================="
PRINT "USB4 Hello Kevin!"
PRINT "===================="
iResult = USB4_Initialize(iDeviceCount)
IF NOT (iResult = %USB4_SUCCESS) THEN
    PRINT iResult
    PRINT "Failed to initialize USB4 driver!"
    EXIT FUNCTION
END IF

USB4_SetMultiplier(0,0,0)
USB4_SetCounterMode(0,0,0) '// Set counter mode to modulo-N.
'USB4_SetForward(0,0,TRUE); '// Optional: determines the direction of counting.
USB4_SetCounterEnabled(0,0,%TRUE) '// Enable the counter. **IMPORTANT**
'USB4_ResetCount(0,0);
USB4_SetCount(0,0,0)

PRINT "Reading encoder channel 0. Press any key to exit"
WHILE -1
    MyInput = INKEY$ ' get them
    IF MyInput = $ESC THEN Terminate
    USB4_GetCount(0,0,ulCount)
    IF NOT (ulPrevCount = ulCount) THEN
        PRINT ulCount
    END IF
    ulPrevCount = ulCount
    SLEEP 1
WEND
Terminate:
USB4_ShutDown
END FUNCTION
