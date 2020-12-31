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
'Make sure usb4.dll is in the same directory as your exe

PRINT "===================="
PRINT "USB4 Hello Kevin!"
PRINT "===================="
PRINT "Hit Escape key to end"

iResult = USB4_Initialize(iDeviceCount)
IF NOT (iResult = %USB4_SUCCESS) THEN
    PRINT iResult
    PRINT "Failed to initialize USB4 driver!"
    EXIT FUNCTION
END IF
'encoder number is 0-3 (1-4)
                           ' This function sets the quadrature counter multiplier mode for the specified encoder channel
USB4_SetMultiplier(0,0,0)  ' USB4_SetMultiplier(BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL iVal AS LONG) AS INTEGER
                           ' iDeviceNo: identifies the USB4 device (zero based).
                           ' iEncoder: identifies the encoder channel (zero based, 0-3).
                           ' iVal: identifies when the quadrature counter multiplier mode.
                           '    0 = clock/direction mode. “A” input is clock, “B” input is direction
                           '    1 = x1 quadrature mode. counter inc/dec once every four quadrature states.
                           '    2 = x2 quadrature mode. counter inc/dec once every two quadrature states.
                           '    3 = x4 quadrature mode. counter inc/dec once every quadrature state.
USB4_SetCounterMode(0,0,0) ' This function sets the 2 counter mode bits in the Control register for the specified encoder channel.
                           ' The remaining bits of the Control register are not changed.
                           ' USB4_SetCounterModeBYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL iVal AS LONG) AS INTEGER
                           ' iDeviceNo: identifies the USB4 device (zero based).
                           ' iEncoder: identifies the encoder channel (zero based, 0-3).
                           ' iVal: parameter containing the counter mode.
                           ' 0 = 24-bit counter.
                           ' 1 = 24-bit counter with preset register in range-limit mode .
                           ' 2 = 24-bit counter with preset register in non-recycle mode.
                           ' 3 = 24-bit counter with preset register in modulo-N mode.
USB4_SetCounterEnabled(0,0,%TRUE) '// Enable the counter. **IMPORTANT**
                           ' USB4_SetCounterEnabled (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL bVal AS BYTE) AS INTEGER
                           ' This function enables or disables the specified encoder channel.
                           ' iDeviceNo: identifies the USB4 device (zero based).
                           ' iEncoder: identifies the encoder channel (zero based, 0-3).
                           ' bVal: TRUE: enable the encoder channel
                           ' FALSE: disable the encoder channel

USB4_SetCount(0,0,0)       ' This function writes a value to the counter for the specified encoder channel.
                           ' USB4_SetCount (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYVAL ulVal AS LONG) AS INTEGER
                           ' iDeviceNo: identifies the USB4 device (zero based).
                           ' iEncoder: identifies the encoder channel (zero based, 0-3).
                           ' ulVal: value to be written to the counter register (unsigned 24-bit integer).
WHILE -1
    MyInput = INKEY$ ' get them
    IF MyInput = $ESC THEN Terminate
                                   ' USB4_GetCount (BYVAL iDeviceNo AS DWORD, BYVAL iEncoder AS DWORD, BYREF pulVal AS LONG) AS INTEGER
    USB4_GetCount(0,0,ulCount)     ' THIS FUNCTION gets the COUNT value FOR the specified encoder channel
                                   ' iDeviceNo: identifies the USB4 device (zero based).
                                   ' iEncoder: identifies the encoder channel (zero based, 0-3).
                                   ' pulVal: contains the encoder count value.
    IF NOT (ulPrevCount = ulCount) THEN
        PRINT CINT(ulCount)
    END IF
    ulPrevCount = ulCount
    SLEEP 1
WEND
Terminate:
USB4_ShutDown
END FUNCTION
