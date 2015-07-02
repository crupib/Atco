#COMPILE EXE
#DIM ALL
DECLARE SUB DFReadLong (filenum AS INTEGER, passrec AS LONG , OFFSET AS INTEGER)
DECLARE SUB DFWriteLong (filenum AS INTEGER, passrec AS LONG , OFFSET AS INTEGER)
DECLARE SUB DFReadArray (filenum AS INTEGER, passrec() AS DOUBLE , OFFSET AS INTEGER)
DECLARE SUB DFWriteArray (filenum AS INTEGER,  passrec() AS DOUBLE , OFFSET AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filename AS STRING)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING)
#INCLUDE "C:\ezgui50pro\includes\ezgui50.inc"

FUNCTION PBMAIN () AS LONG
   LOCAL I,J AS INTEGER
   LOCAL filename AS STRING
   LOCAL myheader AS LONG
   LOCAL HEADER AS LONG
   LOCAL filenumber AS INTEGER
   LOCAL offset AS INTEGER
   DIM myarray1(5) AS DOUBLE
   DIM myarray2(5) AS DOUBLE
   DIM myarray3(5) AS DOUBLE
   DIM myarray4(5) AS DOUBLE
   DIM myarray5(5) AS DOUBLE
   DIM arrayreadin (5) AS DOUBLE
   filename = "Test.cal"
   HEADER = 5
   myheader = 9999
   FOR I%=0 TO 5
      MyArray1(I%) = 1.0
      MyArray2(I%) = 2.0
      MyArray3(I%) = 3.0
      MyArray4(I%) = 4.0
      MyArray4(I%) = 5.0
   NEXT I%
   FCreate (filenumber, 0, filename)
   CALL DFWriteLong(filenumber, BYVAL VARPTR(HEADER), 0)
   offset = LEN(HEADER)
   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray1()) ,offset)
   offset = offset+50
   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray2()) ,offset)
   offset = offset+50
   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray3()) ,offset)
   offset = offset+50
   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray4()) ,offset)
   offset = offset+50
   CALL DFWriteArray( filenumber,BYVAL VARPTR(myarray5()) ,offset)
   offset = offset+50

   CALL DFReadLong (filenumber, BYVAL VARPTR(myheader), 0)
   offset = LEN(HEADER)
   CALL DFReadArray (filenumber,BYVAL VARPTR(arrayreadin()) , offset)
   PRINT myheader
   FOR I%=0 TO 5
      PRINT arrayreadin(I%)
   NEXT I%
   offset = offset+50
   CALL DFReadArray (filenumber,BYVAL VARPTR(arrayreadin()) , offset)
   FOR I%=0 TO 5
      PRINT arrayreadin(I%)
   NEXT I%
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

SUB DFReadArray (filenum AS INTEGER, passrec() AS DOUBLE , OFFSET AS INTEGER)
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
