'==============================================================================
'
'  Serial Communications example for PowerBASIC Console Compiler
'  Copyright (c) 1999-2011 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Simple "dumb terminal" program. Set $COMPORT to the desired port.
'
'==============================================================================

#COMPILER PBCC 6
#COMPILE EXE
#DIM ALL


'------------------------------------------------------------------------------
' Com port settings
'
' Set this to the desired comm port.
$COMPORT = "\\.\COM33"


'------------------------------------------------------------------------------
' Main program entry point...
'
FUNCTION PBMAIN () AS LONG

    LOCAL fEcho   AS LONG    ' whether to do "local echo"
    LOCAL nComm   AS LONG    ' file number of open comm port.
    LOCAL ncbData AS LONG    ' bytes of data waiting
    LOCAL sData   AS STRING  ' data received or to send

    STDOUT "COMM  Copyright (c) 1999-2011 PowerBASIC, Inc.  Dumb Terminal Example Program"
    STDOUT "All Rights Reserved."
    STDOUT

    ERRCLEAR

    ' Open the comm port. Exit if it can't be opened.
    nComm = FREEFILE
    COMM OPEN $COMPORT AS #nComm
    IF ERR THEN
        STDERR "Can't open comm port " & $COMPORT
        WAITKEY$
        EXIT FUNCTION
    END IF

    STDOUT "Communicating on " & $COMPORT & " ... Press <ESC> key to end."
    STDOUT

    COMM SET #nComm, BAUD   = 9600  ' 9600 baud
    COMM SET #nComm, BYTE   = 8     ' 8 bits
    COMM SET #nComm, PARITY = 0     ' No parity
    COMM SET #nComm, STOP   = 0     ' 1 stop bit

    fEcho = -1                      ' Turn local echo ON

    DO

        ' Handle data from the serial port.
        ncbData = COMM(#nComm, RXQUE)
        IF ncbData THEN
            COMM RECV #nComm, ncbData, sData
            STDOUT sData;
        END IF

        ' Handle data from the keyboard.
        IF INSTAT THEN
            sData = INKEY$
            IF sData = $ESC THEN
                EXIT DO
            END IF
        END IF
            sData = HEX$(&HAA010001)
            COMM SEND #nComm, sData
'            IF fEcho THEN
'                STDOUT sData;
'            END IF
'        END IF

        ' Give other processes a chance to run.
        SLEEP 100

    LOOP

    ' Close the comm port.
    COMM CLOSE #nComm

END FUNCTION
