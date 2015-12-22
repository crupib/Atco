#COMPILE EXE
#DIM ALL
%TRUE = -1
%FALSE = 0
MACRO CONST = MACRO

DECLARE SUB DISPLAY(BYVAL sData AS STRING)
FUNCTION PBMAIN
GLOBAL hComm AS LONG
LOCAL IOVALA AS LONG
LOCAL IOVALB AS LONG
LOCAL IOVALC AS LONG
LOCAL MyInput AS STRING
LOCAL Commport AS STRING
hComm = FREEFILE
CommPort = "COM4"
IF NOT OpenCommPort(hComm,Commport) THEN
   PRINT "Open CommPort failed"
   EXIT FUNCTION
END IF
IOVALA = 0
myinput =   "!A" + CHR$(IOVALA) ' Write to Port A Direction Register
SendData(hComm,myinput)
IOVALA = 7
myinput = "A" + CHR$(IOVALA)
SendData(hComm,myinput)
WAITSTAT
DO
    MyInput = INKEY$ ' get them
    IF MyInput = $ESC THEN Terminate
LOOP

Terminate:
CloseCommport(hComm)
END FUNCTION


FUNCTION OpenCommPort(hComm AS LONG, CommPort AS STRING) AS INTEGER
    COMM OPEN CommPort AS #hComm
    OpenCommPort = %FALSE
    IF ERRCLEAR THEN EXIT FUNCTION 'Exit if port cannot be opened
    COMM SET #hComm, NULL = %FALSE
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
