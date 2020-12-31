' "Interface Explorer.inc" - #Include file for "Interface Explorer.bas"

'--------------------------------------------------------------------------------
' Declarations

DECLARE CALLBACK FUNCTION OpenDlgHookProc

DECLARE CALLBACK FUNCTION LVSubclass

DECLARE FUNCTION ProcessFile(BYVAL hDlg AS DWORD, _
                       BYVAL ID AS LONG, _
                       BYVAL File AS STRING) AS LONG

DECLARE FUNCTION TVNotifyHandler(BYVAL hDlg AS DWORD, _
                       BYVAL ID AS LONG, _
                       BYVAL pNMTV AS NM_TREEVIEW PTR) AS LONG

DECLARE FUNCTION EnumInterface(BYVAL hDlg   AS DWORD, _
                       BYVAL ID     AS LONG, _
                       BYVAL Master AS STRING, _
                       BYVAL hRoot  AS DWORD, _
                       BYVAL Indent AS LONG) AS LONG

DECLARE FUNCTION TVInsertItem(BYVAL hDlg AS DWORD, _
                       BYVAL ID      AS LONG, _
                       BYVAL hParent AS DWORD, _
                       BYVAL Expand  AS LONG, _
                       BYREF sTxt    AS STRING, _
                       BYVAL iImage  AS LONG) AS LONG

DECLARE SUB UpdateStatus(BYVAL hDlg AS DWORD, _
                       BYVAL ID1  AS LONG, _
                       BYVAL ID2  AS LONG, _
                       BYVAL x    AS LONG)

DECLARE FUNCTION IEOpenFileDialog (BYVAL hWnd AS LONG, _
                                   BYREF sFileSpec AS STRING) AS LONG

'--------------------------------------------------------------------------------
' Global variables for settings
GLOBAL gChk1        AS LONG
GLOBAL gChk2        AS LONG
GLOBAL gChk3        AS LONG
GLOBAL gChk4        AS LONG
GLOBAL gDepth       AS LONG
GLOBAL gProgID      AS STRING
GLOBAL gPrefix      AS STRING
GLOBAL gWork()      AS STRING
GLOBAL gIsLoaded    AS LONG
GLOBAL gOldTVProc   AS DWORD

'--------------------------------------------------------------------------------
' Equates

'Treeview image list index
%IMAGE_OBJECT       = 0
%IMAGE_INTERFACE    = 1
%IMAGE_MEMBER       = 2

' Syntax definitions for parsing code
$INTERFACEDISPATCH  = "INTERFACE DISPATCH "
$ENDINTERFACE       = "END INTERFACE"

'--------------------------------------------------------------------------------
' Code starts here

FUNCTION SetDefaultOptions() AS LONG
    ' Set the default Options
    gChk1  = 0
    gChk2  = 0
    gChk3  = 1
    gChk4  = 1
    gDepth = 0
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ProcessFile(BYVAL hDlg AS DWORD, _
                     BYVAL ID AS LONG, _
                     BYVAL File AS STRING) AS LONG

    ' Register variables
    LOCAL  x         AS LONG
    LOCAL  hRoot     AS LONG

    ' Memory variables
    LOCAL  y         AS LONG
    LOCAL  hItem     AS DWORD
    LOCAL  a         AS STRING

    ' Clear out the TreeView
    gIsLoaded = 0
    CONTROL SEND hDlg, ID, %TVM_DELETEITEM, 0, %TVI_ROOT

    ' Read the interface file from disk
    TRY
        OPEN File FOR BINARY LOCK SHARED AS #1
        GET$ #1, LOF(1), a
        CLOSE #1
        IF ISFALSE LEN(a) THEN ERROR 53
    CATCH
        CONTROL SET TEXT hDlg, %IDC_LABEL3, $CR & "Error opening the Interface file..."
        GOTO FinishScan
    END TRY

    gProgID = PARSE$(REMAIN$(a, "$PROGID_"), $DQ,2)
    IF ISFALSE LEN(gProgID) THEN gProgId = "<No ProgID>"

    ' Extract the Prefix text
    gPrefix = ""
    IF ISFALSE gChk1 THEN
        gPrefix = LTRIM$(REMAIN$(a, "Interface Prefix:"))
        gPrefix = RTRIM$(EXTRACT$(gPrefix, $CR))
    END IF

    ' Apply capitalization to the important keywords
    REPLACE MCASE$($INTERFACEDISPATCH) WITH $INTERFACEDISPATCH IN a
    REPLACE MCASE$($ENDINTERFACE) WITH $ENDINTERFACE IN a
    REPLACE "Member " WITH "MEMBER " IN a
    REPLACE " Get " WITH " GET " IN a
    REPLACE " Set " WITH " SET " IN a
    REPLACE " Let " WITH " LET " IN a
    REPLACE " Call " WITH " CALL " IN a
    REPLACE " As " WITH " AS " IN a

    ' Remove everything before the 1st interface definition
    a = $INTERFACEDISPATCH & REMAIN$(a, $INTERFACEDISPATCH)

    ' Remove everything after the last interface definition
    a = LEFT$(a, INSTR(-1, a, $ENDINTERFACE) - 1) & $ENDINTERFACE

    ' Compact/remove unwanted padding/spaces/characters/etc
    REPLACE $CRLF WITH $CR IN a
    WHILE INSTR(a, $CR & $CR)
        REPLACE $CR & $CR WITH $CR IN a
    WEND
    WHILE INSTR(a, CHR$(32,32))
        REPLACE CHR$(32,32) WITH CHR$(32) IN a
    WEND

    ' Anything left to do?  Processed file must always contain $INTERFACEDISPATCH
    IF LEN(a) <= LEN($INTERFACEDISPATCH) OR _
        ISFALSE INSTR(a, $ENDINTERFACE) OR _
        PARSECOUNT(a,$CR) < 3 THEN
        BEEP
        CONTROL SET TEXT hDlg, %IDC_LABEL3, $CR & "No Interfaces in file!"
        GOTO FinishScan
    END IF

    ' Break the data apart
    REDIM gWork(PARSECOUNT(a, $CR)) AS GLOBAL STRING
    IF ERR THEN EXIT FUNCTION
    PARSE a, gWork(), $CR
    a = ""

    ' Condition the array (remove surplus headers, white space, etc)
    x = -1
    WHILE x < UBOUND(gWork(1))
        INCR x

        ' Get rid of comments
        gWork(x) = IIF$(INSTR(-1, gWork(x), "'"), _
                       TRIM$(EXTRACT$(gWork(x),"'")), _
                       TRIM$(gWork(x)))

        ' Merge continued/wrapped lines of code
        IF RIGHT$(gWork(x),1) = "_" AND x < UBOUND(gWork(1)) THEN
            gWork(x) = RTRIM$(gWork(x), ANY " _") & " " & gWork(x + 1)
            ARRAY DELETE gWork(x + 1)
            REDIM PRESERVE gWork(UBOUND(gWork(1)) - 1) AS GLOBAL STRING
            DECR x
            ITERATE LOOP
        END IF

        ' Remove hex ID's
        IF INSTR(gWork(x), ">") < INSTR(gWork(x), "<") THEN
            gWork(x) = ""
            ITERATE LOOP
        END IF
        WHILE INSTR(gWork(x), "<")
            gWork(x) = EXTRACT$(gWork(x), "<") & REMAIN$(gWork(x), ">")
        WEND

        ' Remove Parameters
        IF ISFALSE gChk3 THEN
            REPLACE "()" WITH "" IN gWork(x)
            WHILE INSTR(gWork(x), "(")
                gWork(x) = EXTRACT$(gWork(x), "(") & REMAIN$(gWork(x), ")")
            WEND
        END IF

        ' Remove MEMBER prefixes
        IF LEFT$(gWork(x), 7) = "MEMBER " THEN
            gWork(x) = TRIM$(MID$(gWork(x),8))
            ' remove the method type GET, SET, LET, CALL?
            IF ISFALSE gChk2 THEN
                gWork(x) = REMAIN$(gWork(x), " ")
            END IF

        ELSEIF INSTR(gWork(x), $INTERFACEDISPATCH) THEN
            ' Append a "*" so a precise match can be made in the Enum
            gWork(x) = gWork(x) & "*"
        END IF
    WEND

    ' At this point, gWork() should contain nothing but the pruned Interface list
    ' Lets scan it and add all top level Interface definitions to the tree

    ' Set the gProgID as the root item for the TREEVIEW list
    hRoot = TVInsertItem(hDlg, ID, 0, %TRUE, gProgID, %IMAGE_OBJECT)
    IF ISFALSE hRoot THEN FinishScan ' TREEVIEW error occurred, better stop

    ' Iterate the top level interfaces of the COM Server
    FOR x = 0 TO UBOUND(gWork(1))

        ' Update the GUI status, etc
        CALL UpdateStatus(hDlg, ID, %IDC_LABEL3, x)

        ' Is this an interface prototype line?
        IF INSTR(gWork(x), $INTERFACEDISPATCH) THEN

            ' Get the Interface name, ignoring case variations of the prefix
            a = gWork(x)
            MID$(a, 1, LEN($INTERFACEDISPATCH & gPrefix)) = UCASE$($INTERFACEDISPATCH & gPrefix)
            a = REMAIN$(a, UCASE$($INTERFACEDISPATCH & gPrefix))

            ' Add the top level Interface to the TREEVIEW
            hItem = TVInsertItem(hDlg, ID, hRoot, %TRUE, a, %IMAGE_INTERFACE)
            IF ISFALSE hItem THEN FinishScan ' TREEVIEW error occurred?

            ' Expand the root item as soon as we have some branches
            IF y < 3 THEN CONTROL SEND hDlg, ID, %TVM_EXPAND, %TVE_EXPAND, hRoot

            ' Are we doing auto-enumeration?
            IF gDepth > 0 THEN
                CALL EnumInterface(hDlg, ID, a, hItem, 0)
            END IF
        END IF
    NEXT x

    ' Set the status and set focus to the TREEVIEW root item
    CONTROL SET TEXT hDlg, %IDC_LABEL3, CHR$($CR, "Scan", $CR, "completed", $CR, "successfully!")
    CONTROL SEND hDlg, ID, %TVM_SELECTITEM, %TVGN_CARET, hRoot
    CONTROL SET FOCUS hDlg, ID

    FUNCTION = 1

FinishScan:

    ' Processing complete signal
    gIsLoaded = %TRUE

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION EnumInterface(BYVAL hDlg   AS DWORD, _
                       BYVAL ID     AS LONG, _
                       BYVAL Master AS STRING, _
                       BYVAL hRoot  AS DWORD, _
                       BYVAL Indent AS LONG) AS LONG

    ' Register variables
    LOCAL x       AS LONG
    LOCAL y       AS LONG

    ' Memory variables
    LOCAL Strt    AS LONG
    LOCAL Stp     AS LONG
    LOCAL hItem   AS DWORD
    LOCAL a       AS STRING
    LOCAL b       AS STRING

    ' Update the recursive indent level
    INCR Indent

    ' Find the start and end of the specified INTERFACE block in gWork()
    ARRAY SCAN gWork(), COLLATE UCASE, = $INTERFACEDISPATCH & gPrefix & Master, TO Strt
    IF ISFALSE Strt THEN EXIT FUNCTION

    ARRAY SCAN gWork(Strt), COLLATE UCASE, = $ENDINTERFACE, TO Stp
    IF ISFALSE Stp THEN EXIT FUNCTION

    ' The Strt and Stp indexes will include the INTERFACE/END-INTERFACE lines
    Stp = (Strt - LBOUND(gWork(1))) + (Stp - LBOUND(gWork(1))) - 2

    ' Sort the Interface members into Alphanumeric order
    ARRAY SORT gWork(Strt) FOR Stp - Strt + 1, COLLATE UCASE

    ' Update the screen
    IF Indent THEN CALL UpdateStatus(hDlg, ID, %IDC_LABEL3, 0)
    MOUSEPTR 11

    ' Examine just the lines between INTERFACE/END-INTERFACE
    FOR x = Strt TO Stp
        ' Extract the last word from the line
        y = INSTR(-1, gWork(x), ANY " >)")
        a = LTRIM$(MID$(gWork(x), y)) & "*"

        IF LEN(a) > 1 THEN
            ' Is the return parameter an Interface name?
            ARRAY SCAN gWork(), COLLATE UCASE, = $INTERFACEDISPATCH & a, TO y

            ' It returns an interface, so it must be expandable
            IF y THEN
                ' Add a suffix and capitalize the AS keyword
                b = gWork(x) & "*"
                IF LEN(gPrefix) THEN REPLACE "AS " & gPrefix WITH "AS " IN b

                ' Add it to the TREEVIEW list
                hItem = TVInsertItem(hDlg, ID, hRoot, %TRUE, b, %IMAGE_INTERFACE)
                IF ISFALSE hItem THEN EXIT FOR ' TREEVIEW error occurred

                CONTROL SEND hDlg, ID, %TVM_EXPAND, %TVE_EXPAND, hRoot

                ' Do we need to enumerate branch items
                IF Indent > 0 AND Indent < gDepth THEN
                    b = MID$(b, INSTR(-1, b, $SPC) + 1)
                    CALL EnumInterface(hDlg, ID, b, hItem, Indent)
                END IF

                ITERATE FOR
            END IF
        END IF

        ' Do we display normal Member items?
        IF ISTRUE gChk4 THEN
            hItem = TVInsertItem(hDlg, ID, hRoot, %FALSE, gWork(x), %IMAGE_MEMBER)
            IF ISFALSE hItem THEN EXIT FUNCTION ' TREEVIEW error occurred
        END IF

        DIALOG DOEVENTS

    NEXT x
    IF hRoot THEN CONTROL SEND hDlg, ID, %TVM_EXPAND, %TVE_EXPAND, hRoot
    MOUSEPTR 1
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION TVInsertItem(BYVAL hDlg    AS DWORD, _         ' Parent Dialog handle
                      BYVAL ID      AS LONG, _          ' The tree ID
                      BYVAL hParent AS DWORD, _         ' Parent item handle
                      BYVAL Expand  AS LONG, _          ' Make item expandable
                      BYREF sTxt    AS STRING, _        ' The item to insert
                      BYVAL iImage  AS LONG) AS LONG    ' Image type for item

    STATIC utvInsert AS TV_INSERTSTRUCT
    LOCAL  hItem     AS LONG

    utvInsert.hParent                  = hParent
    utvInsert.item.mask           = %TVIF_CHILDREN OR %TVIF_TEXT OR _
                                         %TVIF_IMAGE OR %TVIF_SELECTEDIMAGE
    utvInsert.item.pszText        = STRPTR(sTxt)
    utvInsert.item.cchTextMax     = LEN(sTxt)
    utvInsert.item.iImage         = iImage
    utvInsert.item.iSelectedImage = iImage
    utvInsert.item.cchildren      = Expand

    ' Make expandable items (Interface names) bold
    IF ISTRUE Expand THEN
        utvInsert.item.mask       = (utvInsert.item.mask OR %TVIF_STATE)
        utvInsert.item.statemask  = %TVIS_BOLD
        utvInsert.item.state      = %TVIS_BOLD
    END IF

    CONTROL SEND hDlg, ID, %TVM_INSERTITEM, 0, VARPTR(utvInsert) TO hItem
    FUNCTION = hItem

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION TVNotifyHandler(BYVAL hDlg AS DWORD, _
                       BYVAL ID AS LONG, _
                       BYVAL pNMTV AS NM_TREEVIEW PTR) AS LONG
    STATIC Busy  AS LONG
    LOCAL  TV    AS TV_ITEM
    LOCAL  a     AS STRING
    LOCAL  hParent AS DWORD

    ' We only need to handle TREEVIEW messages
    IF @pNMTV.hdr.idFrom <> ID THEN EXIT FUNCTION

    ' We only want to handle TREEVIEW expansion messages
    IF @pNMTV.hdr.code <> %TVN_ITEMEXPANDING THEN EXIT FUNCTION

    ' A branch is being expanded or collapsed, so we need to know whether to
    ' delete the branch, or leave it intack if it is the first level branch
    CONTROL SEND hDlg, ID, %TVM_GETNEXTITEM, %TVGN_PARENT, _
        @pNMTV.itemNew.hItem TO hParent
    IF ISFALSE hParent THEN EXIT FUNCTION

    ' Process expanding and collapsing notification messages
    IF @pNMTV.action = %TVE_EXPAND THEN

        ' Prevent recursive notifications when adding items programmatically
        IF ISTRUE Busy OR ISFALSE gIsLoaded THEN EXIT FUNCTION
        Busy = 1

        ' Get the text from the item being expanded
        a             = STRING$(4096, $NUL)
        TV.mask       = %TVIF_TEXT OR %TVIF_HANDLE
        TV.hItem      = @pNMTV.itemNew.hItem
        TV.pszText    = STRPTR(a)
        TV.cchTextMax = LEN(a)
        CONTROL SEND hDlg, ID, %TVM_GETITEM, 0, VARPTR(TV)

        ' Use just the last word, which should be an interface name
        a = EXTRACT$(MID$(a, INSTR(-1, a, $SPC) + 1), $NUL)

        ' Now add the interfaces for this item (no auto-enumeration)
        EnumInterface hDlg, ID, a, @pNMTV.itemNew.hItem, -1

        ' Must return zero or the expanded branch is not shown
        FUNCTION = 0
        Busy = 0

    ELSEIF @pNMTV.action = %TVE_COLLAPSE THEN

        ' Delete all branched below the top level
        CONTROL SEND hDlg, %IDC_SYSTREEVIEW32_1, %TVM_EXPAND, _
            (%TVE_COLLAPSE OR %TVE_COLLAPSERESET), @pNMTV.itemNew.hItem

        ' Return 1 to indicate we handled the collapse ok
        FUNCTION = 1

    END IF

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
SUB UpdateStatus(BYVAL hDlg AS DWORD, _
                 BYVAL ID1  AS LONG, _
                 BYVAL ID2  AS LONG, _
                 BYVAL x    AS LONG)
    LOCAL y AS LONG
    LOCAL z AS LONG

    ' How many do we have so far?
    CONTROL SEND hDlg, ID1, %TVM_GETCOUNT, 0, 0 TO y
    z = UBOUND(gWork(1))

    ' Update the processing status when the "percent done" changes
    IF x = 0 OR x \ z <> (x - 1) \ z THEN
        CONTROL SET TEXT hDlg, %IDC_LABEL3, "Scanning Interface tree" & $CR & _
            FORMAT$(x / z, "0%") & " (" & FORMAT$(y) & ")" & _
            $CR & $CR & "Please wait..."
    END IF

END SUB
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION LVSubclass
    IF CBMSG = %WM_KEYDOWN THEN
        IF CBWPARAM = %VK_MULTIPLY THEN
            BEEP
            EXIT FUNCTION
        END IF
    END IF
    FUNCTION = CallWindowProc(gOldTVProc, CBHNDL, CBMSG, CBWPARAM, CBLPARAM)
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION IsWin2000orXP AS LONG
  LOCAL os AS OSVERSIONINFO
  os.dwOSVersionInfoSize = SIZEOF(os)

  IF GetVersionEx(os) THEN
     FUNCTION = ((os.dwPlatformId = %VER_PLATFORM_WIN32_NT) AND _
                (os.dwMajorVersion > 4)) '5 or higher..
  END IF
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION IEOpenFileDialog (BYVAL hWnd AS LONG, _
                           BYREF sFileSpec AS STRING) AS LONG

    LOCAL ix            AS LONG
    LOCAL Ofn           AS OPENFILENAME
    LOCAL sCaption      AS STRING
    LOCAL sFilter       AS STRING
    LOCAL sDefExtension AS STRING
    LOCAL sInitialDir   AS STRING

    ' Show Open File dialog and retrieve a file
    sCaption            = "Open PowerBrowser Interface file"
    sFilter             =          "INC Files (*.INC)|*.INC|"
    sFilter             = sFilter & "BAS Files (*.BAS)|*.BAS|"
    sFilter             = sFilter & "All Files (*.*)|*.*||"
    sDefExtension       = "INC"
    sInitialDir         = CURDIR$

    REPLACE "|" WITH $NUL IN sFilter

    ix = INSTR(sFileSpec, $NUL)
    IF ix THEN
        sFileSpec = LEFT$(sFileSpec, ix) + SPACE$(%OFN_FILEBUFFERSIZE - ix)
    ELSE
        sFileSpec = sFileSpec + $NUL + SPACE$(%OFN_FILEBUFFERSIZE - (LEN(sFileSpec) + 1))
    END IF

    ofn.lStructSize     = IIF&(IsWin2000orXP, SIZEOF(OPENFILENAME$), SIZEOF(OPENFILENAME))
    Ofn.hWndOwner       = hWnd
    Ofn.lpstrFilter     = STRPTR(sFilter)
    Ofn.lpstrFile       = STRPTR(sFilespec)
    Ofn.nMaxFile        = %MAX_PATH
    Ofn.lpstrInitialDir = STRPTR(sInitialDir)
    ofn.lpstrTitle      = STRPTR(sCaption)
    Ofn.Flags           = %OFN_ENABLEHOOK OR %OFN_EXPLORER OR %OFN_FILEMUSTEXIST
    Ofn.lpfnHook        = CODEPTR(OpenDlgHookProc)
    Ofn.lpstrDefExt     = STRPTR(sDefExtension)

    ' Note: The following Select block must be adjusted to match the
    ' Filter string in use.  The same must be performed in the hooked
    ' procedure if one is used)
    SELECT CASE UCASE$(sDefExtension)
        CASE "INC" : ofn.nFilterIndex = 1 ' nFilterIndex determines
        CASE "BAS" : ofn.nFilterIndex = 2 ' the Filetype combobox's
        CASE ELSE  : ofn.nFilterIndex = 3 ' listitem setting
    END SELECT

    FUNCTION = GetOpenFilename(BYVAL VARPTR(ofn))
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION OpenDlgHookProc
    LOCAL x    AS LONG
    LOCAL y    AS LONG
    LOCAL R    AS RECT
    LOCAL pOfn AS OFNOTIFY PTR

    pOfn = CBLPARAM
    IF CBMSG = %WM_NOTIFY AND @pOfn.hdr.Code = %CDN_INITDONE THEN
        ' Center the COMDLG in parent window
        GetWindowRect GetParent(GetParent(CBHNDL)), R   ' Get Parent window size
        x = R.nLeft + ((R.nRight   - R.nLeft) \ 2)      ' Calculate Parent width
        y = R.nTop  + ((R.nBottom  - R.nTop)  \ 2)      ' Calculate Parent height

        GetWindowRect GetParent(CBHNDL), R              ' Get dialog width and height
        x = x - (( R.nRight   - R.nLeft ) \ 2)
        y = y - (( R.nBottom  - R.nTop  ) \ 2)
        SetWindowPos GetParent(CBHNDL), %NULL, x, y, 0, 0, %SWP_NOSIZE OR %SWP_NOZORDER

        FUNCTION = %TRUE
    END IF
END FUNCTION
'--------------------------------------------------------------------------------
