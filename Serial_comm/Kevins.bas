#COMPILE EXE
#DIM ALL
%TRUE = -1
%FALSE = 0
MACRO CONST = MACRO
CONST newLine =   CHR$(13)+CHR$(11)
CONST SetQuad =   "W0000"+CHR$(13)+CHR$(11)
CONST GetCount =  "R0E"+CHR$(13)+CHR$(11)
CONST ClearREG =  "W153"+CHR$(13)+CHR$(11)
DECLARE SUB DISPLAY(BYVAL sData AS STRING)
FUNCTION PBMAIN
GLOBAL hComm AS LONG
LOCAL Echo AS LONG
LOCAL Qty AS LONG
LOCAL Stuf AS STRING
LOCAL MyInput AS STRING
LOCAL Commport AS STRING
hComm = FREEFILE
CommPort = "COM3"
IF NOT OpenCommPort(hComm,Commport) THEN
   PRINT "Open CommPort failed"
   EXIT FUNCTION
END IF
myinput =  "W153"+CHR$(13)+CHR$(11)
SendData(hComm,myinput)
WHILE  -1
Qty = COMM(#hComm, RXQUE)
    IF ISTRUE Qty THEN
        COMM RECV #hComm, Qty, Stuf ' read incoming characters
    END IF

IF qty > 0 THEN
    EXIT LOOP
END IF
WEND
DISPLAY stuf
myinput =  "W0000"+CHR$(13)+CHR$(11)
SendData(hComm,myinput)
WHILE  -1
Qty = COMM(#hComm, RXQUE)
    IF ISTRUE Qty THEN
        COMM RECV #hComm, Qty, Stuf ' read incoming characters
    END IF

    IF qty > 0  THEN
        EXIT LOOP
    END IF
WEND
DISPLAY stuf
DO

myinput = "R0E"+CHR$(13)+CHR$(11)
SendData(hComm,myinput)
WHILE  -1
Qty = COMM(#hComm, RXQUE)
    IF ISTRUE Qty THEN
        COMM RECV #hComm, Qty, Stuf ' read incoming characters
    END IF

    IF qty > 0 THEN
        EXIT LOOP
    END IF
WEND
DISPLAY stuf
MyInput = INKEY$ ' get them

IF MyInput = $ESC THEN Terminate
LOOP
WAITSTAT
Terminate:
CloseCommport(hComm)
END FUNCTION

FUNCTION SetQSB(cmd AS STRING) AS STRING
    LOCAL qty AS LONG
    LOCAL stuf AS STRING
    SendData(hcomm,cmd)
    RecvData(hComm,qty,Stuf)
    SetQSB = Stuf
END FUNCTION
FUNCTION GetQSB(cmd AS STRING) AS STRING
    LOCAL qty AS LONG
    LOCAL stuf AS STRING
    SendData(hcomm,cmd)
    RecvData(hComm,qty,Stuf)
    GetQSB = Stuf
END FUNCTION

FUNCTION OpenCommPort(hComm AS LONG, CommPort AS STRING) AS INTEGER
    COMM OPEN CommPort AS #hComm
    OpenCommPort = %FALSE
    IF ERRCLEAR THEN EXIT FUNCTION 'Exit if port cannot be opened
    COMM SET #hComm, BAUD     = 230400    ' 14K4 baud
    COMM SET #hComm, BYTE     = 8        ' 8 bits
    COMM SET #hComm, PARITY   = %FALSE   ' No parity
    COMM SET #hComm, STOP     = 0        ' 1 stop bit
    COMM SET #hComm, TXBUFFER = 1024     ' 1 Kb transmit buffer
    COMM SET #hComm, RXBUFFER = 1024     ' 1 Kb receive buffer
    OpenCommPort = %TRUE
END FUNCTION

FUNCTION CloseCommport(hComm AS LONG) AS INTEGER
    COMM CLOSE #hComm ' Close the comm port and exit
END FUNCTION

FUNCTION SendData (hComm AS LONG, MyInput AS STRING) AS INTEGER
    COMM SEND #hComm, MyInput
END FUNCTION

FUNCTION RecvData(hcomm AS LONG, Qty AS LONG, Stuf AS STRING) AS INTEGER
    Qty = COMM(#hComm, RXQUE)
    IF ISTRUE Qty THEN
        COMM RECV #hComm, Qty, Stuf ' read incoming characters
    END IF
END FUNCTION

SUB DISPLAY(BYVAL sData AS STRING) ' handles embedded CR/LF bytes
    LOCAL sDataPtr AS BYTE PTR
    LOCAL y AS LONG
    REPLACE $LF WITH "" IN sData ' reduce CR/LF to CR
    sDataPtr = STRPTR(sData)
    FOR y = 0 TO LEN(sData) - 1
        IF @sDataPtr[y] = 13& THEN
        PRINT ' force new line on CR
        ITERATE FOR
        END IF
        PRINT CHR$(@sDataPtr[y]); ' display current char
    NEXT y
END SUB
