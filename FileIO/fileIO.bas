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
GLOBAL Stand_alone_array() AS EXT
FUNCTION PBMAIN () AS LONG
   DIM Stand_alone_array(1000) AS EXT
   LOCAL I,J AS INTEGER
   LOCAL filename AS STRING
   filename = "Test.cal"
   FOR I%=0 TO 9
      TestStruc.MyArray(I%) = I%
   NEXT I%
   FOR I%=0 TO 9
       FOR J%=0 TO 9
           TestStruc.MyMulti(I,J) = J%
       NEXT J%
   NEXT I%
   TestStruc.header = "Atco Cal file"
   TestStruc.NumModules = 3
   TestStruc.StatusDef = 10
   FOR I%=0 TO 999
      Stand_alone_array(I%) = I%*.022
   NEXT I%

   CalSave(filename)
   SLEEP 100
   CalLoad(filename)
   PRINT STR$(TestStruc.MyMulti(5,5))
   PRINT TestStruc.header
   PRINT STR$(TestStruc.MyArray(4))
 '  print Stand_alone_array(500)
   WAITKEY$
END FUNCTION
FUNCTION CalSave(filename AS STRING) AS INTEGER
    LOCAL filenumber AS INTEGER
    FCreate (filenumber, 0, filename)
    CALL DFWriteStruc(filenumber, BYVAL VARPTR(TestStruc), 0)

    'CALL DFWriteArray( filenumber,BYVAL VARPTR(Stand_alone_array()) ,0)
    CALL FClose(filenumber)
END FUNCTION

FUNCTION CalLoad(filename AS STRING) AS INTEGER
   LOCAL filenumber AS INTEGER
   CALL FOpen (filenumber, 0,0, filename)
   CALL DFReadStruc(filenumber, BYVAL VARPTR(TestStruc),0)
   'CALL DFReadArray(filenumber, BYVAL VARPTR(Stand_alone_array()) ,0)
END FUNCTION

SUB DFReadStruc (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
    GET filenum, offset ,PASSREC
END SUB

SUB DFWriteStruc (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
        PUT filenum,  offset ,PASSREC
END SUB

SUB DFWriteArray (filenum AS INTEGER,  passrec() AS EXT , OFFSET AS INTEGER)
        PUT filenum,  offset , PASSREC()
END SUB

SUB DFReadArray (filenum AS INTEGER, passrec() AS EXT , OFFSET AS INTEGER)
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
