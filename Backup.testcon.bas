#COMPILE EXE
#COMPILER PBCC 6
#DIM ALL
GLOBAL PICPort AS STRING
GLOBAL PICBaud AS LONG
GLOBAL nComm AS LONG
GLOBAL StringVariable AS STRING
GLOBAL HdrVer AS STRING * 20
GLOBAL ThumbDisk AS STRING * 2
GLOBAL ECODE AS INTEGER
MACRO CONST = MACRO
CONST TRUE = -1
CONST FALSE = NOT TRUE
DECLARE FUNCTION OpenComPorts  AS INTEGER
GLOBAL filenum AS INTEGER
GLOBAL bytesread AS INTEGER
GLOBAL mystring AS STRING * 20

TYPE MYTYPE
  id AS INTEGER
  Styles AS WORD
END TYPE

TYPE HEADER
  hdr AS STRING * 20
END TYPE

DECLARE SUB DFRead (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFRead2 (filenum AS INTEGER, passrec AS MYTYPE , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFWrite (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFWrite2 (filenum AS INTEGER, passrec AS mytype , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filename AS STRING, ECode AS INTEGER)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING, ECode AS INTEGER)
DECLARE SUB FClose (filenumber AS INTEGER)
DECLARE FUNCTION GetKeys$
GLOBAL myrecord AS HEADER
GLOBAL inrecord AS mytype
GLOBAL hdrrecord AS HEADER
GLOBAL  KeyTable() AS STRING

FUNCTION PBMAIN () AS LONG
 DIM II AS INTEGER
 DIM VV AS INTEGER
 DIM GG AS STRING
 DIM myinput AS STRING
 DIM aa AS STRING
 DIM KeyTable(20) AS STRING
 LOCAL hWin AS DWORD
 LOCAL widthvar AS INTEGER
 LOCAL Heightvar AS INTEGER
 GRAPHIC GET CLIENT TO widthvar, Heightvar
 GRAPHIC WINDOW "Atco MCU Test",widthvar/2, Heightvar/2, 130, 130 TO hWin
 GRAPHIC ATTACH hWin, 0

  'new keypad layout
  KeyTable(0) = ""
  KeyTable(1) = CHR$(0) + CHR$(77) 'RgtArrow
  KeyTable(2) = CHR$(0) + CHR$(75) 'LftArrow
  KeyTable(3) = CHR$(0) + CHR$(80) 'DnArrow
  KeyTable(4) = CHR$(0) + CHR$(72) 'UpArrow
  KeyTable(5) = CHR$(13)           'Ent
  KeyTable(6) = CHR$(32)           'Space
  KeyTable(7) = CHR$(8)            'BkSpace
  KeyTable(8) = CHR$(27)           'ESC
  KeyTable(9) = CHR$(46)           '.
  KeyTable(10) = CHR$(57)          '9
  KeyTable(11) = CHR$(54)          '6
  KeyTable(12) = CHR$(51)          '3
  KeyTable(13) = CHR$(48)          '0
  KeyTable(14) = CHR$(56)          '8
  KeyTable(15) = CHR$(53)          '5
  KeyTable(16) = CHR$(50)          '2
  KeyTable(17) = CHR$(46)          '.
  KeyTable(18) = CHR$(55)          '7
  KeyTable(19) = CHR$(52)          '4
  KeyTable(20) = CHR$(49)          '1
 ThumbDisk = "C:\Users\Bill\Documents\GitHub\Atco\"
 CON.CAPTION$ = "Atco Motor controllor"
 CON.SCREEN = 4,20
 CON.PRINT "       ATCO         "
 CON.PRINT "MCU-P3000      V1.00"
 CON.PRINT "COPYRIGHT 1997- 2015"
 CON.PRINT "--------------------"
 CON.LOCATE 4, 4
 CON.PRINT "X"
' con.print KeyTable(1)
 'gg = keyTable(10)
 'CON.CLS
 'con.input("Hello",II)
 'con.print II
 'con.scroll.up(4)
 PICPort  =  "\\.\COM31"
 PICBaud = 19200
 CON.PRINT gg
 gg = GetKeys$
' DO
'  aa = INKEY$
'  PRINT aa
' LOOP UNTIL LEN(aa)
 FOR VV = 1 TO 10000
    GG$ = CON.INKEY$ 'INKEY$
    IF LEFT$(GG$, 1) = "Q" OR LEFT$(GG$, 1) = "q" THEN
       END
    END IF
 NEXT  VV
 CON.WAITKEY$ TO myinput
 II = VAL(myinput)
 IF II = 1 THEN
     PRINT "Setup"
 END IF

' RESET StringVariable$
 fcreate(filenum, 0, ThumbDisk+"file2.txt", ECode)
 IF ecode = 0 THEN
    PRINT "File created!"
 END IF
 hdrrecord.hdr =  "SCU-3.00            "
 CALL DFWrite(filenum, BYVAL VARPTR(hdrrecord), 0, BytesRead, ECode)
 inrecord.id = 99
 inrecord.styles = 200
 CALL DFWrite2(filenum, BYVAL VARPTR(inrecord),LEN(hdrrecord), BytesRead, ECode)
 FClose(filenum)
 hdrrecord.hdr =  ""
 CALL DFWrite(filenum, BYVAL VARPTR(hdrrecord), 0, BytesRead, ECode)
 inrecord.id = 0
 inrecord.styles = 0
 FOpen (filenum, 0,0, ThumbDisk+"file2.txt", ECode)
 CALL DFRead(filenum, BYVAL VARPTR(hdrrecord),  0, BytesRead, ECode)
 CALL DFRead2(filenum, BYVAL VARPTR(inrecord),  LEN(hdrrecord), BytesRead, ECode)
 FClose(filenum)

 PRINT hdrrecord.hdr
 PRINT inrecord.id
 PRINT inrecord.Styles


 WAITSTAT
 END FUNCTION

 FUNCTION OpenComPorts AS INTEGER
    LOCAL ECode AS INTEGER
'   LOCAL nComm   AS LONG
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
   ' LOCAL buffer_clear AS STRING
   ' buffer_clear = STRING$(2048, zero)
   FLUSH #nComm
END SUB
SUB WriteToComm (PICPort AS STRING, SendStr AS STRING, BytesWritten AS INTEGER, ECode AS INTEGER)
    COMM SEND #nComm, SendStr
END SUB
SUB DFRead (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
    GET filenum, offset ,PASSREC
     ECode = -1
END SUB
SUB DFRead2 (filenum AS INTEGER, passrec AS MYTYPE , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
    GET filenum, offset ,PASSREC
    ECode = -1
END SUB
SUB DFWrite (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, Byteswritten AS INTEGER, ECode AS INTEGER)
        PUT filenum,  offset ,PASSREC
        ECode = -1
END SUB
SUB DFWrite2 (filenum AS INTEGER, passrec AS mytype , OFFSET AS INTEGER, Byteswritten AS INTEGER, ECode AS INTEGER)
        PUT filenum,  offset ,PASSREC
        ECode = -1
END SUB

SUB FCreate (filenumber AS INTEGER, ATTR AS INTEGER, filename AS STRING, ECode AS INTEGER)
    LOCAL FileExists AS INTEGER
    FileExists = ISFILE(FileName)
    IF FileExists THEN
        OPEN filename FOR BINARY AS filenumber BASE = 0
        ECode = -1
    ELSE
        ecode = 0
        OPEN filename FOR BINARY AS filenumber BASE = 0
    END IF
END SUB
SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING, ECode AS INTEGER)
    LOCAL FileExists AS INTEGER
    FileExists = ISFILE(FileName)
    IF FileExists THEN
        OPEN filename FOR BINARY AS filenumber BASE = 0
        ecode = -1
    ELSE
        ecode = 0
    END IF
END SUB
SUB FClose (filenumber AS INTEGER)
    CLOSE filenumber
END SUB
FUNCTION GetKeys$
 LOCAL keynum AS INTEGER
 LOCAL keybuff AS STRING
 Keybuff = INKEY$
 IF LEN(Keybuff)THEN
    KeyNum = VAL(keybuff)
 ELSE
    keyNum = 0
 END IF
 GetKeys$ = KeyTable(KeyNum)

END FUNCTION
