#COMPILE EXE
#DIM ALL
#INCLUDE "win32api.inc"
#INCLUDE "COMDLG32.INC"

TYPE TestRecord
   header AS STRING  * 20      ' (a string needs to have a size otherwise it doesn't compile
   NumModules AS INTEGER
   StatusDef AS LONG
   MyArray(10) AS SINGLE
   MyMulti(10,10) AS DOUBLE
END TYPE

GLOBAL TestStruc AS TestRecord

'I/O routines

DECLARE SUB DFRead (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
DECLARE SUB DFWrite (filenum AS INTEGER, passrec AS TestRecord , OFFSET AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filename AS STRING)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING)

GLOBAL Stand_alone_array() AS EXT

FUNCTION PBMAIN () AS LONG
   DIM Stand_alone_array(1000) AS EXT
   DIM retval AS LONG, hWnd AS LONG
   LOCAL I,J AS INTEGER
   LOCAL sfilename AS STRING
   LOCAL sPath AS STRING

   sPath = CURDIR$

   ' Fill 1 dimension array in structure
   FOR I%=0 TO 9
      TestStruc.MyArray(I%) = I%
   NEXT I%
   ' Fill 2 dimension array in structure
   FOR I%=0 TO 9
       FOR J%=0 TO 9
           TestStruc.MyMulti(I,J) = J%
       NEXT J%
   NEXT I%
   'Update other fields
   TestStruc.header = "Atco Cal file"
   TestStruc.NumModules = 3
   TestStruc.StatusDef = 10
   ' Update Stand alone array
   FOR I%=0 TO 999
      Stand_alone_array(I%) = I%*.022
   NEXT I%
   ' Windows Save file '
   retval = SaveFileDialog(BYVAL %HWND_DESKTOP, _
        "Save File To Folder", _
        sFilename, _
        sPath, _
        "Nozzle Scan Files (*.nsf)|*.nsf", _
        "nsf", _
        %OFN_CREATEPROMPT OR %OFN_EXPLORER OR _
        %OFN_FILEMUSTEXIST OR %OFN_NODEREFERENCELINKS _
    )
    CLS
    ? sFilename

   'Save both to disk
   CalSave(sFilename)
   'allow time to finish writing
   SLEEP 100
WAITKEY$
   'Load files back into
   sPath = CURDIR$
    OpenFileDialog(BYVAL %HWND_DESKTOP, _
        "Open existing file", _
        sFilename, _
        sPath, _
        "Nozzle Scan Files (*.nsf)|*.nsf", _
        "nsf", _
        %OFN_ALLOWMULTISELECT OR %OFN_EXPLORER OR _
        %OFN_FILEMUSTEXIST OR %OFN_NODEREFERENCELINKS _
    )
    ? sFilename
   CalLoad(sFilename)
   PRINT "Some values"
   PRINT STR$(TestStruc.MyMulti(5,5))
   PRINT TestStruc.header
   PRINT STR$(TestStruc.MyArray(4))
   PRINT Stand_alone_array(500)
   WAITKEY$
END FUNCTION
FUNCTION CalSave(filename AS STRING) AS INTEGER
    LOCAL filenumber AS INTEGER
    FCreate (filenumber, 0, filename)
    CALL DFWriteStruc(filenumber, BYVAL VARPTR(TestStruc), 0)
    CALL DFWriteArray( filenumber,BYVAL VARPTR(Stand_alone_array()) ,SIZEOF(TestStruc))
    CALL FClose(filenumber)
END FUNCTION

FUNCTION CalLoad(filename AS STRING) AS INTEGER
   LOCAL filenumber AS INTEGER
   CALL FOpen (filenumber, 0,0, filename)
   CALL DFReadStruc(filenumber, BYVAL VARPTR(TestStruc),0)
   CALL DFReadArray(filenumber, BYVAL VARPTR(Stand_alone_array()) ,SIZEOF(TestStruc))
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
