#COMPILE EXE
#COMPILER PBCC 6
#DIM ALL
GLOBAL PICPort AS STRING
GLOBAL PICBaud AS LONG
GLOBAL nComm AS LONG
GLOBAL StringVariable AS STRING
GLOBAL HdrVer AS STRING * 20
GLOBAL temp AS STRING * 20
GLOBAL ThumbDisk AS STRING * 2
GLOBAL ECODE AS INTEGER
MACRO CONST = MACRO
CONST TRUE = -1
CONST FALSE = NOT TRUE
DECLARE FUNCTION OpenComPorts  AS INTEGER
GLOBAL filenum AS INTEGER
GLOBAL bytesread AS INTEGER
DECLARE SUB DFRead (filenum AS INTEGER, DSeg AS STRING * 20  , DOfs AS STRING * 20, BYTES AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filehandle AS INTEGER, ECode AS INTEGER)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filehandle AS INTEGER, ECode AS INTEGER)
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
  HdrVer = "SCU-1.00            "
  ThumbDisk = "C:\UCALS\"
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
 HdrVer = "SCU-1.00            "
 'temp = HdrVer
 myrecord.id = 99
 myrecord.Styles = 99
 'OPEN "File.txt" FOR BINARY AS filenum
 FOpen (filenum, 0,0, filenum, ECode)
 'PUT$ filenum, HdrVer
 'PUT filenum, 21, myrecord
 'CLOSE filenum
 'OPEN "File.txt" FOR BINARY AS filenum  BASE = 1
 CALL DFRead(filenum, temp, temp, LEN(HdrVer), BytesRead, ECode)
 'GET$ filenum, 20, HdrVer
 GET filenum, 21,  inrecord
' CLOSE #filenum
 PRINT
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
SUB DFRead (filenum AS INTEGER, DSeg AS STRING * 20, DOfs AS STRING * 20, BYTES AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
    GET$ filenum, 20, dseg
    GET filenum, 21,  inrecord
END SUB
SUB FCreate (filenumber AS INTEGER, ATTR AS INTEGER, filehandle AS INTEGER, ECode AS INTEGER)
    OPEN "File.txt" FOR BINARY AS filenumber
END SUB
SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filehandle AS INTEGER, ECode AS INTEGER)
    OPEN "File.txt" FOR BINARY AS filenumber
END SUB
