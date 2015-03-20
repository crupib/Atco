#COMPILE EXE
#COMPILER PBCC 6
#DIM ALL
GLOBAL PICPort AS STRING
GLOBAL PICBaud AS LONG
GLOBAL nComm AS LONG
GLOBAL StringVariable AS STRING
MACRO CONST = MACRO
CONST TRUE = -1
CONST FALSE = NOT TRUE
DECLARE FUNCTION OpenComPorts  AS INTEGER
TYPE MYTYPE
  id AS INTEGER
  Styles AS WORD
END TYPE
GLOBAL myrecord AS MYTYPE
GLOBAL inrecord AS MYTYPE
FUNCTION PBMAIN () AS LONG
 DIM II AS INTEGER
 DIM VV AS INTEGER
 DIM GG AS STRING
 CON.CAPTION$ = "Atco Motor controllor"
 CON.SCREEN = 8,80
 CON.PRINT "       ATCO         "
 CON.PRINT "MCU-P3000      V1.00"
 CON.PRINT "COPYRIGHT 1997- 2015"
 CON.PRINT "--------------------"
 PICPort  =  "\\.\COM31"
 PICBaud = 19200
 FOR VV = 1 TO 10000
    GG$ = CON.INKEY$ 'INKEY$
    IF LEFT$(GG$, 1) = "Q" OR LEFT$(GG$, 1) = "q" THEN
       END
    END IF
 NEXT  VV

 RESET StringVariable$
 StringVariable$ = "Test"
 myrecord.id = 99
 myrecord.Styles = 99
 OPEN "File.txt" FOR BINARY AS #1
 PUT$ #1, StringVariable$
 PUT #1, 5, myrecord
 CLOSE #1
 OPEN "File.txt" FOR BINARY AS #1  BASE = 1
 GET$ #1, 4, StringVariable$
 GET #1, 4,  inrecord
 CLOSE #1
 PRINT StringVariable$
 PRINT inrecord.id
 PRINT inrecord.Styles
 WAITSTAT

 END FUNCTION
 FUNCTION OpenComPorts AS INTEGER
    LOCAL ECode AS INTEGER
'    LOCAL nComm   AS LONG
    LOCAL x AS INTEGER
    nComm = FREEFILE
    COMM OPEN PicPort AS #nComm
    IF ERR THEN
        OpenComPorts = FALSE
    END IF
    COMM SET #nComm, TXBUFFER = 2048
    COMM SET #nComm, RXBUFFER = 2048   ' 2 Kb receive buffer
    COMM SET #nComm, BAUD   = PICBaud  ' 19200 baud
    COMM SET #nComm, BYTE   = 8     ' 8 bits
    COMM SET #nComm, PARITY = 0     ' No parity
    COMM SET #nComm, STOP   = 1     ' 1 stop bit
'    COMM SEND #nComm, buffer_clear
    OpenComPorts = TRUE
    CALL FlushBuffers(PICPort, 0, ECode)
END FUNCTION
SUB flushbuffers (PICPort AS STRING, zero AS INTEGER, ECode AS INTEGER)
    LOCAL buffer_clear AS STRING
    buffer_clear = STRING$(2048, zero)
END SUB
SUB WriteToComm (PICPort AS STRING, SendStr AS STRING, BytesWritten AS INTEGER, ECode AS INTEGER)
    COMM SEND #nComm, SendStr
END SUB
