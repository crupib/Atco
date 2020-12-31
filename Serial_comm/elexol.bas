#COMPILE EXE
#DIM ALL
%TRUE = -1
%FALSE = 0
MACRO CONST = MACRO

'PIN # SIGNAL TYPE DESCRIPTION
'1     VCC    PWR  +5V 50mA can be drawn when powered through USB
'2     I/O8   I/O  Programmable I/O pin with bit value of 128
'3     I/O7   I/O  Programmable I/O pin with bit value of 64
'4     I/O6   I/O  Programmable I/O pin with bit value of 32
'5     I/O5   I/O  Programmable I/O pin with bit value of 16
'6     I/O4   I/O  Programmable I/O pin with bit value of 8
'7     I/O3   I/O  Programmable I/O pin with bit value of 4
'8     I/O2   I/O  Programmable I/O pin with bit value of 2
'9     I/O1   I/O  Programmable I/O pin with bit value of 1
'10    GND    PWR  Ground signal USB BUS and all I/O

'COMMAND DATA FUNCTION
'‘?’     Responds ‘USB I/O 24f2’ Identify Device
'‘A’     1 Byte Port Data Write to Port A
'‘B’     1 Byte Port Data Write to Port B
'‘C’     1 Byte Port Data Write to Port C
'‘a’     Responds with 1 Byte Port Data Read from Port A
'‘b’     Responds with 1 Byte Port Data Read from Port B
'‘c’     Responds with 1 Byte Port Data Read from Port C
'‘!A’    1 Byte Port I/O Data Write to Port A Direction Register
'‘!B’    1 Byte Port I/O Data Write to Port B Direction Register
'‘!C’    1 Byte Port I/O Data Write to Port C Direction Register

'The commands in the above table are in ASCII format.
'All Data is sent in Binary format.

DECLARE SUB PortDirection(myport AS STRING,value AS INTEGER)
DECLARE SUB PortWrite(myport AS STRING,value AS INTEGER)
DECLARE SUB PortRead(myport AS STRING, reval AS STRING)
DECLARE SUB DISPLAYHEX(BYVAL sData AS STRING)
DECLARE SUB DISPLAYCHAR(BYVAL sData AS STRING)
DECLARE SUB GETDEVICEID(id AS STRING, retval AS STRING)
FUNCTION PBMAIN

GLOBAL hComm AS LONG
LOCAL Commport AS STRING
LOCAL retval AS STRING
LOCAL flag AS STRING

hComm = FREEFILE
CommPort = "COM4"
IF NOT OpenCommPort(hComm,Commport) THEN
   PRINT "Open CommPort failed"
   EXIT FUNCTION
END IF

'Identify Device - Responds 'USB I/O 24'
'GetDeviceID("?",retval)
'Set A to all outputs
'Then write to pin 9,8,7
''PortDirection("!A",0)
'Then write to pin 9,8,7  0000111 4+2+1 = 7
''PortWrite("A",7)
'Set A to Input 00000001
PortDirection("!A",1)
'Read 1 byte from Port A
PortRead("a",retval)
DISPLAYHEX retval
DO
    FLAG = INKEY$ ' get them
    IF FLAG = $ESC THEN Terminate
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
    RecvData = Qty
END FUNCTION

SUB DISPLAYHEX(BYVAL sData AS STRING) ' handles embedded CR/LF bytes
    LOCAL sDataPtr AS BYTE PTR
    LOCAL y AS LONG
    REPLACE $LF WITH "" IN sData ' reduce CR/LF to CR
    sDataPtr = STRPTR(sData)
    FOR y = 0 TO LEN(sData) - 1
        IF @sDataPtr[y] = 13& THEN
        PRINT ' force new line on CR
        ITERATE FOR
        END IF
        PRINT HEX$(@sDataPtr[y]); ' display current hex number
    NEXT y
END SUB

SUB DISPLAYCHAR(BYVAL sData AS STRING) ' handles embedded CR/LF bytes
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
SUB GETDEVICEID(id AS STRING, retval AS STRING)
    LOCAL Qty AS LONG
    LOCAL stuf AS STRING
    SendData(hComm,id)
    SLEEP 400
    DO WHILE  RecvData(hComm , Qty, Stuf)
        DISPLAYCHAR stuf
    LOOP
END SUB
SUB PortDirection(myport AS STRING,value AS INTEGER)
    LOCAL PortDir AS INTEGER
    LOCAL Portchanged AS STRING

    PortDir = value
    Portchanged = myport+CHR$(Portdir)
    SendData(hComm,Portchanged)
END SUB

SUB PortWrite(myport AS STRING,value AS INTEGER)
    LOCAL PortVal AS INTEGER
    LOCAL PortOut AS STRING

    PortVal = value
    PortOut = myport+CHR$(PortVal)
    SendData(hComm,PortOut)
END SUB
SUB PortRead(myport AS STRING,retvalue AS STRING)
    LOCAL PortIn AS STRING
    LOCAL Qty AS LONG
    LOCAL stuf AS STRING
    PortIn = myport
    SendData(hComm,PortIn)
    SLEEP 9
    DO WHILE  RecvData(hComm , Qty, Stuf)
        DISPLAYHEX Stuf
    LOOP
END SUB
