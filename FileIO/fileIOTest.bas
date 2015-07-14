#COMPILE EXE
#DIM ALL
DECLARE SUB DFReadLong (filenum AS INTEGER, passrec AS LONG , OFFSET AS INTEGER)
DECLARE SUB DFWriteLong (filenum AS INTEGER, passrec AS LONG , OFFSET AS INTEGER)
DECLARE SUB DFReadArray (filenum AS INTEGER, passrec() AS DOUBLE , OFFSET AS INTEGER)
DECLARE SUB DFReadArray2 (filenum AS INTEGER, passrec() AS EXT , OFFSET AS INTEGER)
DECLARE SUB DFWriteArray (filenum AS INTEGER,  passrec() AS DOUBLE , OFFSET AS INTEGER)
DECLARE SUB DFWriteArray2 (filenum AS INTEGER,  passrec() AS EXT , OFFSET AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filename AS STRING)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING)
DECLARE SUB FClose (FileNumber AS INTEGER)
#INCLUDE "C:\ezgui50pro\includes\ezgui50.inc"

FUNCTION PBMAIN () AS LONG
   LOCAL I,J AS INTEGER
   LOCAL filename AS STRING
   LOCAL myheader AS LONG
   LOCAL HEADER AS LONG
   LOCAL filenumber AS INTEGER
   LOCAL offset AS INTEGER
   DIM myarray1(10000) AS EXT
   DIM myarray2(5) AS DOUBLE
   DIM myarray3(5) AS DOUBLE
   DIM myarray4(5) AS DOUBLE
   DIM myarray5(5) AS DOUBLE
   DIM myarray6(10000) AS EXT
   DIM arrayreadin (5) AS EXT
   filename = "Test.cal"
   HEADER = 5
   myheader = 9999
   FOR I%=0 TO 9999
      MyArray1(I%) = 1.2
'      MyArray2(I%) = 2.0
'      MyArray3(I%) = 3.0
'      MyArray4(I%) = 4.0
'      MyArray5(I%) = 5.0
      MyArray6(I%) =  5.3
'      PRINT MyArray1(I%)
'      PRINT MyArray6(I%)
   NEXT I%
'   WAITKEY$
  'FCreate (filenumber, 0, filename)
    filenumber = FREEFILE
    OPEN filename FOR BINARY AS filenumber BASE = 0
    PUT filenumber,  0 , myarray1()
    PUT filenumber, 100000,   myarray6()
   'CALL DFWriteLong(filenumber, BYVAL VARPTR(HEADER), 0)
   'offset = LEN(HEADER)
  ' offset = 0
  ' CALL DFWriteArray2( filenumber,BYVAL VARPTR(myarray1()) ,offset)
  ' offset = offset + 100000
  ' CALL DFWriteArray2( filenumber,BYVAL VARPTR(myarray6()) ,offset)
'   offset = offset+50
'   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray3()) ,offset)
'   offset = offset+50
'   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray4()) ,offset)
'   offset = offset+50
'   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray5()) ,offset)
'   offset = offset+50
'   CALL DFWriteArray2( filenumber,BYVAL VARPTR(myarray6()) ,offset)
'   offset = offset+50
'   CALL DFReadLong (filenumber, BYVAL VARPTR(myheader), 0)
'   offset = LEN(HEADER)
   CLOSE filenumber
   OPEN filename FOR BINARY AS filenumber BASE = 0
   GET filenumber, 0 ,arrayreadin()
   FOR I%=0 TO 4
      PRINT arrayreadin(I%)
   NEXT I%
   GET filenumber, 100000 ,arrayreadin()
   CLOSE filenumber
   FOR I%=0 TO 4
     PRINT arrayreadin(I%)
   NEXT I%
'   OPEN filename FOR BINARY AS filenumber BASE = 0
   'OPEN filename FOR BINARY AS filenumber BASE = 0
   'fcreate(filenumber,0,filename)
   'CALL DFReadArray2 (filenumber,BYVAL VARPTR(arrayreadin()) ,0)
'   PRINT myheader
'   FOR I%=0 TO 4
'      PRINT arrayreadin(I%)
'   NEXT I%
'   CALL DFReadArray2 (filenumber,BYVAL VARPTR(arrayreadin()) , offset)
'   FOR I%=0 TO 4
'      PRINT arrayreadin(I%)
'   NEXT I%
   WAITKEY$
END FUNCTION

SUB DFReadLong (filenum AS INTEGER, passrec AS LONG , OFFSET AS INTEGER)
    GET filenum, offset ,PASSREC
END SUB

SUB DFWriteLong (filenum AS INTEGER, passrec AS LONG , OFFSET AS INTEGER)
        PUT filenum,  offset ,PASSREC
END SUB

SUB DFWriteArray (filenum AS INTEGER,  passrec() AS DOUBLE , OFFSET AS INTEGER)
        PUT filenum,  offset , PASSREC()
END SUB
SUB DFWriteArray2 (filenum AS INTEGER,  passrec() AS EXT , OFFSET AS INTEGER)
        PUT filenum,  offset , PASSREC()
END SUB
SUB DFReadArray (filenum AS INTEGER, passrec() AS DOUBLE , OFFSET AS INTEGER)
    GET filenum, offset ,PASSREC()
END SUB
SUB DFReadArray2 (filenum AS INTEGER, passrec() AS EXT , OFFSET AS INTEGER)
    GET filenum, offset ,PASSREC()
END SUB

SUB FCreate (filenumber AS INTEGER, ATTR AS INTEGER, filename AS STRING)
    LOCAL FileExists AS INTEGER
    FileExists = ISFILE(FileName)
    IF FileExists THEN
        OPEN filename FOR BINARY AS filenumber BASE = 0
    ELSE
        OPEN filename FOR BINARY AS filenumber BASE = 0
    END IF
END SUB

SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING)
    LOCAL FileExists AS INTEGER
    FileExists = ISFILE(FileName)
    IF FileExists THEN
        OPEN filename FOR BINARY AS filenumber BASE = 0
    END IF
END SUB

SUB FClose (filenumber AS INTEGER)
    CLOSE filenumber
END SUB
