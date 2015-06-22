#COMPILE EXE
#DIM ALL
TYPE TestRecord
   header AS STRING  * 20
   NumModules AS INTEGER
   StatusDef AS LONG
   MyArray(10) AS SINGLE
   MyMulti(10,10) AS DOUBLE
END TYPE

GLOBAL TestStruc AS TestRecord
DECLARE SUB DFRead (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
DECLARE SUB DFWrite (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filename AS STRING)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING)

FUNCTION PBMAIN () AS LONG
   LOCAL I,J AS INTEGER
   LOCAL filename AS STRING
   filename = "Test.cal"
   FOR I%=0 TO 10
      TestStruc.MyArray(I%) = I%
   NEXT I%
   FOR I%=0 TO 10
       FOR J%=0 TO 10
           TestStruc.MyMulti(I,J) = J%
       NEXT J%
   NEXT I%
   TestStruc.header = "Atco Cal file"
   TestStruc.NumModules = 3
   TestStruc.StatusDef = 10
   CalSave(filename)
   CalLoad(filename)
   PRINT TestStruc.MyMulti(5,5)
   PRINT TestStruc.header
   PRINT TestStruc.MyArray(4)
END FUNCTION
FUNCTION CalSave(filename AS STRING) AS INTEGER
    LOCAL filenumber AS INTEGER
    FCreate (filenumber, 0, filename)
    CALL DFWrite(filenumber, BYVAL VARPTR(TestStruc), 0)
    CALL FClose(filenumber)
END FUNCTION

FUNCTION CalLoad(filename AS STRING) AS INTEGER
   LOCAL filenumber AS INTEGER
   CALL FOpen (filenumber, 0,0, filename)
   CALL DFRead(filenumber, BYVAL VARPTR(TestStruc),0)
END FUNCTION

SUB DFRead (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
    GET filenum, offset ,PASSREC
END SUB

SUB DFWrite (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
        PUT filenum,  offset ,PASSREC
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
