DECLARE SUB DFRead (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFRead2 (filenum AS INTEGER, passrec AS ScanParms , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFWrite (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB DFWrite2 (filenum AS INTEGER, passrec AS ScanParms , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
DECLARE SUB FCreate (filenumber AS INTEGER, myattr AS INTEGER, filename AS STRING, ECode AS INTEGER)
DECLARE SUB FOpen (FileNumber AS INTEGER, ReadWrite AS INTEGER, Sharing AS INTEGER, filename AS STRING, ECode AS INTEGER)


SUB DFRead (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
    GET filenum, offset ,PASSREC
     ECode = -1
END SUB

SUB DFRead2 (filenum AS INTEGER, passrec AS scanparms , OFFSET AS INTEGER, BytesRead AS INTEGER, ECode AS INTEGER)
    GET filenum, offset ,PASSREC
    ECode = -1
END SUB

SUB DFWrite (filenum AS INTEGER, passrec AS HEADER , OFFSET AS INTEGER, Byteswritten AS INTEGER, ECode AS INTEGER)
        PUT filenum,  offset ,PASSREC
        ECode = -1
END SUB

SUB DFWrite2 (filenum AS INTEGER, passrec AS scanparms , OFFSET AS INTEGER, Byteswritten AS INTEGER, ECode AS INTEGER)
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
        ecode = -1
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
