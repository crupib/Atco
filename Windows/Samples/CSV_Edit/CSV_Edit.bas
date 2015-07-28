#PBFORMS CREATED V1.51
'==============================================================================
'
'  CSV_Edit.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2002-2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  A useful CSV file editor.
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES 
#RESOURCE "CSV_Edit.pbr"
%USEMACROS = 1
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#IF NOT %DEF(%COMMCTRL_INC)
    #INCLUDE "COMMCTRL.INC"
#ENDIF
#INCLUDE "PBForms.INC"
#PBFORMS END INCLUDES
#INCLUDE "COMDLG32.INC"
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS 
%BTN_CLEAR           = 1020
%BTN_FLDADD          = 1013
%BTN_FLDDELETE       = 1015
%BTN_FLDUPDATE       = 1014
%BTN_UPDATENEXT      = 1019
%IDCLOSE             =    8
%IDD_ABOUT           =  106
%IDD_FILENEW         =  104
%IDD_MAIN            =  101
%IDD_RECORDADDEDIT   =  105
%IDM_FILE_EXIT       = 1006
%IDM_FILE_NEW        = 1002
%IDM_FILE_OPEN       = 1003
%IDM_FILE_SAVE       = 1004
%IDM_FILE_SAVEAS     = 1005
%IDM_HELP_ABOUT      = 1010
%IDM_RECORD_ADD      = 1007
%IDM_RECORD_DELETE   = 1009
%IDM_RECORD_EDIT     = 1008
%IDOK                =    1
%IDR_ACCELERATOR1    =  103
%IDR_IMGFILE1        =  107
%IDR_MENU1           =  102
%IMG_IMAGE1          = 1021
%LBL_ABOUT           = 1022
%LBL_FIELDNAME       = 1017
%LST_FIELDNAMES      = 1012
%LVW_SYSLISTVIEW32_1 = 1001
%LVW_SYSLISTVIEW32_2 = 1016
%TXT_FIELDNAME       = 1011
%TXT_FIELDVALUE      = 1018
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------
'   Additional Constants
'--------------------------------------------------------------------------------
%RECORD_ADD             = 0
%RECORD_EDIT            = 1
%BUF_SIZE               = 1024
$APP_TITLE              = "CSV File Editor"
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE FUNCTION ASSIGNACCEL(tAccel AS ACCELAPI, BYVAL wKey AS WORD, BYVAL wCmd _
    AS WORD, BYVAL byFVirt AS BYTE) AS LONG
DECLARE FUNCTION AttachACCELERATOR1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowMAINProc()
DECLARE CALLBACK FUNCTION ShowFILENEWProc()
DECLARE CALLBACK FUNCTION ShowRECORDADDEDITProc()
DECLARE CALLBACK FUNCTION ShowABOUTProc()
DECLARE FUNCTION ShowMAIN(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowFILENEW(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowRECORDADDEDIT(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowABOUT(BYVAL hParent AS DWORD) AS LONG
'--------------------------------------------------------------------------------
'   New Declarations Added Manually:
'--------------------------------------------------------------------------------
DECLARE FUNCTION fileNew(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION fileOpenDlg(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION fileOpen(BYVAL hDlg AS DWORD, sFile AS STRING) AS LONG
DECLARE FUNCTION fileClose(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION fileSave(BYVAL hDlg AS DWORD, sFileIn AS STRING) AS LONG
DECLARE FUNCTION fileSaveAs(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION recordAdd(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION recordEdit(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION recordDelete(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION recordEnable(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION recordLoad(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION recordSave(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION recordShow(BYVAL hDlg AS DWORD, BYVAL hList AS DWORD, BYVAL lRow AS LONG) AS LONG
DECLARE FUNCTION recordUpdate(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION aboutDlg(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION aboutGetInfo() AS STRING
DECLARE FUNCTION fieldNameAdd(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION fieldNameUpdate(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION fieldNameDelete(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION fieldNameSave(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION fieldNameEnableButtons(BYVAL hDlg AS DWORD) AS LONG
DECLARE FUNCTION listviewLoadFieldNames(BYVAL hDlg AS DWORD, asFlds() AS STRING) AS LONG
DECLARE FUNCTION listviewGetFieldNames(BYVAL hDlg AS DWORD, asFlds() AS STRING) AS LONG
DECLARE FUNCTION listviewRecordAdd(BYVAL hDlg AS DWORD, asFlds() AS STRING) AS LONG
DECLARE FUNCTION listviewRecordReplace(BYVAL hDlg AS DWORD, BYVAL lRow AS LONG, _
    asFlds() AS STRING) AS LONG
DECLARE FUNCTION listviewRecordGet(BYVAL hDlg AS DWORD, BYVAL lRow AS LONG, _
    asFlds() AS STRING) AS LONG
DECLARE FUNCTION csvRecordGetFieldCount(sBuf AS STRING) AS LONG
DECLARE FUNCTION csvRecordParseFromBuf(BYVAL pSrc AS BYTE PTR, sBuf AS STRING, _
    asFlds() AS STRING) AS LONG
DECLARE FUNCTION csvRecordSaveToBuf(asFlds() AS STRING) AS STRING
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------

TYPE tGlobalInfo
    szFile      AS ASCIIZ * %MAX_PATH
    byModified  AS BYTE
    byType      AS BYTE
    lFldCnt     AS LONG
END TYPE
GLOBAL gtInfo   AS tGlobalInfo

'--------------------------------------------------------------------------------
FUNCTION PBMAIN()
    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR %ICC_INTERNET_CLASSES)
    ShowMAIN %HWND_DESKTOP
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Menus **
'--------------------------------------------------------------------------------
FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN MENU %IDR_MENU1->%IDD_MAIN
    LOCAL hMenu   AS DWORD
    LOCAL hPopUp1 AS DWORD

    MENU NEW BAR TO hMenu
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "&File", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&New..." + $TAB + "Ctrl+N", %IDM_FILE_NEW, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Open..." + $TAB + "Ctrl+O", %IDM_FILE_OPEN, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "-", 0, 0
        MENU ADD STRING, hPopUp1, "&Save" + $TAB + "Ctrl+S", %IDM_FILE_SAVE, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Save &As...", %IDM_FILE_SAVEAS, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "-", 0, 0
        MENU ADD STRING, hPopUp1, "E&xit" + $TAB + "Alt+F4", %IDM_FILE_EXIT, %MF_ENABLED
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "&Record", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Add..." + $TAB + "Ctrl+A", %IDM_RECORD_ADD, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Edit..." + $TAB + "Ctrl+E", %IDM_RECORD_EDIT, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Delete" + $TAB + "Del", %IDM_RECORD_DELETE, %MF_ENABLED
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "&Help", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&About CSV File Editor...", %IDM_HELP_ABOUT, %MF_ENABLED

    MENU ATTACH hMenu, hDlg
#PBFORMS END MENU
    FUNCTION = hMenu
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Accelerators **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN ASSIGNACCEL 
FUNCTION ASSIGNACCEL(tAccel AS ACCELAPI, BYVAL wKey AS WORD, BYVAL wCmd AS WORD, BYVAL byFVirt AS _
    BYTE) AS LONG
    tAccel.fVirt = byFVirt
    tAccel.key   = wKey
    tAccel.cmd   = wCmd
END FUNCTION
#PBFORMS END ASSIGNACCEL
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION AttachACCELERATOR1(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN ACCEL %IDR_ACCELERATOR1->%IDD_MAIN
    LOCAL hAccel   AS DWORD
    LOCAL tAccel() AS ACCELAPI
    DIM   tAccel(1 TO 6) AS ACCELAPI

    ASSIGNACCEL tAccel(1), ASC("N"), %IDM_FILE_NEW, %FVIRTKEY OR %FCONTROL OR %FNOINVERT
    ASSIGNACCEL tAccel(2), ASC("O"), %IDM_FILE_OPEN, %FVIRTKEY OR %FCONTROL OR %FNOINVERT
    ASSIGNACCEL tAccel(3), ASC("S"), %IDM_FILE_SAVE, %FVIRTKEY OR %FCONTROL OR %FNOINVERT
    ASSIGNACCEL tAccel(4), ASC("A"), %IDM_RECORD_ADD, %FVIRTKEY OR %FCONTROL OR %FNOINVERT
    ASSIGNACCEL tAccel(5), ASC("E"), %IDM_RECORD_EDIT, %FVIRTKEY OR %FCONTROL OR %FNOINVERT
    ASSIGNACCEL tAccel(6), %VK_DELETE, %IDM_RECORD_DELETE, %FVIRTKEY OR %FNOINVERT

    ACCEL ATTACH hDlg, tAccel() TO hAccel
#PBFORMS END ACCEL
    FUNCTION = hAccel
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** CallBacks **
'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowMAINProc()
    LOCAL lFileCnt  AS LONG
    LOCAL szFile    AS ASCIIZ * %MAX_PATH
    LOCAL cx        AS LONG
    LOCAL cy        AS LONG
    LOCAL pNmLv     AS NM_LISTVIEW PTR

    SELECT CASE CBMSG
        CASE %WM_INITDIALOG
            DragAcceptFiles CBHNDL, %TRUE

        CASE %WM_DESTROY
            DragAcceptFiles CBHNDL, %FALSE

        CASE %WM_DROPFILES
            lFileCnt = DragQueryFile(CBWPARAM, -1, BYVAL 0, 0)
            IF lFileCnt > 1 THEN
                MessageBox CBHNDL, "Only one file can be opened at a time.", _
                    $APP_TITLE, %MB_ICONEXCLAMATION
            ELSE
                DragQueryFile CBWPARAM, 0, szFile, SIZEOF(szFile)
            END IF
            DragFinish CBWPARAM

            IF ASC(szFile) > 0 THEN
                'File exists.
                IF fileClose(CBHNDL) THEN
                    fileOpen CBHNDL, BYCOPY szFile
                END IF
            END IF

        CASE %WM_SIZE
            'Adjust size of ListView when size of dialog changes.
            DIALOG GET CLIENT CBHNDL TO cx, cy
            CONTROL SET SIZE CBHNDL, %LVW_SYSLISTVIEW32_1, cx, cy

        CASE %WM_NOTIFY
            SELECT CASE CBCTL
                CASE %LVW_SYSLISTVIEW32_1
                    pNmLv = CBLPARAM
                    SELECT CASE @pNmLv.hdr.code
                        CASE %NM_DBLCLK
                            DIALOG SEND CBHNDL, %WM_COMMAND, %IDM_RECORD_EDIT, 0
                    END SELECT
            END SELECT

        CASE %WM_INITMENU
            recordEnable CBHNDL

        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %LVW_SYSLISTVIEW32_1
                CASE %IDM_FILE_NEW
                    IF fileClose(CBHNDL) THEN
                        fileNew CBHNDL
                    END IF

                CASE %IDM_FILE_OPEN
                    IF fileClose(CBHNDL) THEN
                        fileOpenDlg CBHNDL
                    END IF

                CASE %IDM_FILE_SAVE
                    fileSave CBHNDL, BYCOPY gtInfo.szFile

                CASE %IDM_FILE_SAVEAS
                    fileSaveAs CBHNDL

                CASE %IDM_FILE_EXIT
                    DIALOG SEND CBHNDL, %WM_SYSCOMMAND, %SC_CLOSE, 0

                CASE %IDM_RECORD_ADD
                    recordAdd CBHNDL

                CASE %IDM_RECORD_EDIT
                    recordEdit CBHNDL

                CASE %IDM_RECORD_DELETE
                    recordDelete CBHNDL

                CASE %IDM_HELP_ABOUT
                    aboutDlg CBHNDL

            END SELECT

        CASE %WM_SYSCOMMAND
            SELECT CASE CBWPARAM
                CASE %SC_CLOSE
                    IF fileClose(CBHNDL) THEN
                        DIALOG END CBHNDL
                    END IF
                    'Returning %TRUE prevents close from happening if not already done.
                    FUNCTION = %TRUE

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowFILENEWProc()
    LOCAL sFldName  AS STRING

    SELECT CASE CBMSG
        CASE %WM_INITDIALOG
            fieldNameEnableButtons CBHNDL

        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %TXT_FIELDNAME
                    IF CBCTLMSG = %EN_CHANGE THEN
                        fieldNameEnableButtons CBHNDL
                    END IF
                CASE %LST_FIELDNAMES
                    SELECT CASE CBCTLMSG
                        CASE %LBN_SELCHANGE
                            'Get selected field name and set to text box.
                            LISTBOX GET TEXT CBHNDL, %LST_FIELDNAMES TO sFldName
                            CONTROL SET TEXT CBHNDL, %TXT_FIELDNAME, sFldName
                        CASE %LBN_DBLCLK
                            fieldNameDelete CBHNDL
                    END SELECT
                CASE %BTN_FLDADD
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        fieldNameAdd CBHNDL
                    END IF
                CASE %BTN_FLDUPDATE
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        fieldNameUpdate CBHNDL
                    END IF
                CASE %BTN_FLDDELETE
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        fieldNameDelete CBHNDL
                    END IF
                CASE %IDCLOSE
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        fieldNameSave CBHNDL
                        DIALOG END CBHNDL
                    END IF
                CASE %IDCANCEL
                    DIALOG END CBHNDL
            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowRECORDADDEDITProc()
    LOCAL hList AS DWORD
    LOCAL tLVI  AS LV_ITEM
    LOCAL pNmLv AS NM_LISTVIEW PTR

    SELECT CASE CBMSG
        CASE %WM_INITDIALOG
            'Set default button, so pressing (Enter) will activate.
            DIALOG SEND CBHNDL, %DM_SETDEFID, %BTN_UPDATENEXT, 0

        CASE %WM_NOTIFY
            SELECT CASE CBCTL
                CASE %LVW_SYSLISTVIEW32_2
                    pNmLv = CBLPARAM
                    SELECT CASE @pNmLv.hdr.code
                        CASE %LVN_ITEMCHANGED
                            recordShow CBHNDL, @pNmLv.hdr.hwndFrom, @pNmLv.iItem
                    END SELECT
            END SELECT

        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %LVW_SYSLISTVIEW32_2
                CASE %LBL_FIELDNAME
                CASE %TXT_FIELDVALUE
                    IF CBCTLMSG = %WM_SETFOCUS THEN
                        'Set default button, so pressing (Enter) will activate.
                        DIALOG SEND CBHNDL, %DM_SETDEFID, %BTN_UPDATENEXT, 0
                    END IF

                CASE %BTN_UPDATENEXT
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        recordUpdate CBHNDL
                    END IF

                CASE %BTN_CLEAR
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        CONTROL SET TEXT CBHNDL, %TXT_FIELDVALUE, ""
                    END IF

                CASE %IDCLOSE
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        recordSave CBHNDL
                        DIALOG END CBHNDL
                    END IF

                CASE %IDCANCEL
                    DIALOG END CBHNDL

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowABOUTProc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IMG_IMAGE1
                CASE %LBL_ABOUT
                CASE %IDOK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL
                    END IF

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowMAIN(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
    LOCAL hList     AS DWORD
    LOCAL lStyle    AS LONG
#PBFORMS BEGIN DIALOG %IDD_MAIN->%IDR_MENU1->%IDR_ACCELERATOR1
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "CSV File Editor", 94, 64, 345, 197, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR _
        %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_ACCEPTFILES OR _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    DIALOG  SET ICON hDlg, "#" + FORMAT$(%IDR_IMGFILE1)
    CONTROL ADD "SysListView32", hDlg, %LVW_SYSLISTVIEW32_1, "SysListView321", 0, 0, 345, 185, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER OR %WS_TABSTOP OR %LVS_REPORT OR %LVS_SINGLESEL _
        OR %LVS_SHOWSELALWAYS, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_RIGHTSCROLLBAR

    AttachMENU1 hDlg

    AttachACCELERATOR1 hDlg
#PBFORMS END DIALOG

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList
    lStyle = ListView_GetExtendedListViewStyle(hList)
    ListView_SetExtendedListViewStyle (hList, _
        lStyle OR %LVS_EX_FULLROWSELECT OR %LVS_EX_GRIDLINES)

    DIALOG SHOW MODAL hDlg, CALL ShowMAINProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_MAIN
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowFILENEW(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_FILENEW->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "New CSV File", 69, 76, 166, 120, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME _
        OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD LABEL,   hDlg, -1, "&Field Name:", 5, 5, 100, 10
    CONTROL ADD TEXTBOX, hDlg, %TXT_FIELDNAME, "", 5, 15, 100, 13
    CONTROL ADD LABEL,   hDlg, -1, "Field &Names:", 5, 35, 100, 10
    CONTROL ADD LISTBOX, hDlg, %LST_FIELDNAMES, , 5, 45, 100, 75, %WS_CHILD OR %WS_VISIBLE OR _
        %WS_TABSTOP OR %WS_VSCROLL OR %LBS_NOTIFY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD BUTTON,  hDlg, %BTN_FLDADD, "&Add", 110, 15, 50, 15
    CONTROL ADD BUTTON,  hDlg, %BTN_FLDUPDATE, "&Update", 110, 35, 50, 15
    CONTROL ADD BUTTON,  hDlg, %BTN_FLDDELETE, "&Delete", 110, 55, 50, 15
    CONTROL ADD BUTTON,  hDlg, %IDCLOSE, "&Save && Close", 110, 80, 50, 15
#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ShowFILENEWProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_FILENEW
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowRECORDADDEDIT(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
    LOCAL hList     AS DWORD
    LOCAL lStyle    AS LONG
#PBFORMS BEGIN DIALOG %IDD_RECORDADDEDIT->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Add/Edit Record", 69, 76, 280, 205, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
        %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    CONTROL ADD FRAME,   hDlg, -1, "&Fields", 5, 5, 270, 100
    CONTROL ADD "SysListView32", hDlg, %LVW_SYSLISTVIEW32_2, "SysListView322", 10, 15, 260, 85, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER OR %WS_TABSTOP OR %LVS_REPORT OR %LVS_SINGLESEL _
        OR %LVS_SHOWSELALWAYS OR %LVS_NOSORTHEADER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD FRAME,   hDlg, -1, "&Edit Field Value", 5, 110, 270, 70
    CONTROL ADD LABEL,   hDlg, %LBL_FIELDNAME, "", 10, 120, 125, 10
    CONTROL ADD TEXTBOX, hDlg, %TXT_FIELDVALUE, "", 10, 130, 185, 45, %WS_CHILD OR %WS_VISIBLE OR _
        %WS_TABSTOP OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE OR %ES_AUTOVSCROLL, _
        %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD BUTTON,  hDlg, %BTN_UPDATENEXT, "&Update/Next Field", 200, 130, 70, 15
    CONTROL ADD BUTTON,  hDlg, %BTN_CLEAR, "&Clear Field", 200, 150, 70, 15
    CONTROL ADD BUTTON,  hDlg, %IDCLOSE, "&Save && Close", 205, 185, 70, 15
#PBFORMS END DIALOG

    SELECT CASE gtInfo.byType
        CASE %RECORD_ADD
            DIALOG SET TEXT hDlg, "Add Record"
        CASE %RECORD_EDIT
            DIALOG SET TEXT hDlg, "Edit Record"
    END SELECT
    recordLoad hDlg

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_2 TO hList
    lStyle = ListView_GetExtendedListViewStyle(hList)
    ListView_SetExtendedListViewStyle (hList, _
        lStyle OR %LVS_EX_FULLROWSELECT OR %LVS_EX_GRIDLINES)

    'Limit amount of text that can be entered.
    CONTROL SEND hDlg, %TXT_FIELDVALUE, %EM_LIMITTEXT, %BUF_SIZE - 1, 0

    DIALOG SHOW MODAL hDlg, CALL ShowRECORDADDEDITProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_RECORDADDEDIT
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowABOUT(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_ABOUT->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "About CSV File Editor", 69, 76, 190, 76, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD IMAGE,  hDlg, %IMG_IMAGE1, "#" + FORMAT$(%IDR_IMGFILE1), 10, 10, 22, 19, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_ICON
    CONTROL ADD LABEL,  hDlg, %LBL_ABOUT, "Label1", 45, 10, 140, 35
    CONTROL ADD BUTTON, hDlg, %IDOK, "OK", 70, 55, 50, 15
    DIALOG  SEND        hDlg, %DM_SETDEFID, %IDOK, 0
#PBFORMS END DIALOG

    'Update the display with Version info.
    CONTROL SET TEXT hDlg, %LBL_ABOUT, aboutGetInfo()

    DIALOG SHOW MODAL hDlg, CALL ShowABOUTProc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_ABOUT
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   New Functions Added Manually:
'--------------------------------------------------------------------------------
FUNCTION fileNew(BYVAL hDlg AS DWORD) AS LONG
    ShowFILENEW hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION fileOpenDlg(BYVAL hDlg AS DWORD) AS LONG
    LOCAL sFile AS STRING

    IF OpenFileDialog(hDlg, _
        "Open CSV File", _
        sFile, _
        CURDIR$, _
        "CSV Files (*.csv)|*.csv", _
        "csv", _
        %OFN_FILEMUSTEXIST OR %OFN_HIDEREADONLY) THEN

        FUNCTION = fileOpen(hDlg, sFile)

    END IF
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION fileOpen(BYVAL hDlg AS DWORD, sFile AS STRING) AS LONG
    LOCAL hFile     AS LONG
    LOCAL sBuf      AS STRING
    LOCAL lFldCnt   AS LONG
    LOCAL pSrc      AS BYTE PTR
    LOCAL asFlds()  AS STRING
    LOCAL lRow      AS LONG
    LOCAL hList     AS DWORD
    LOCAL i         AS LONG

    hFile = FREEFILE
    OPEN sFile FOR BINARY AS hFile
    IF ERR THEN
        MessageBox hDlg, "Error #" + FORMAT$(ERR) + " - " + ERROR$(ERR) + $CR + _
            "While trying to open: " + sFile, $APP_TITLE, %MB_ICONEXCLAMATION
        EXIT FUNCTION
    END IF
    'Read file into a buffer.
    sBuf = SPACE$(LOF(hFile))
    GET hFile, 1, sBuf
    CLOSE hFile

    'Get field count and intialize array.
    lFldCnt = csvRecordGetFieldCount(sBuf)
    REDIM asFlds(0 TO lFldCnt - 1) AS STRING
    gtInfo.lFldCnt = lFldCnt

    'Parse all records and load into ListView.
    pSrc = STRPTR(sBuf)
    DO WHILE @pSrc
        pSrc = csvRecordParseFromBuf(pSrc, sBuf, asFlds())
        IF lRow = 0 THEN
            listviewLoadFieldNames hDlg, asFlds()
        ELSE
            listviewRecordAdd hDlg, asFlds()
        END IF
        INCR lRow
    LOOP

    'Automatically size columns based on data.
    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList
    FOR i = 0 TO UBOUND(asFlds)
        ListView_SetColumnWidth (hList, i, %LVSCW_AUTOSIZE)
    NEXT lCol

    'Remember and display file name in title bar.
    gtInfo.szFile = sFile
    DIALOG SET TEXT hDlg, $APP_TITLE + " - [" + sFile + "]"

    'Set as unmodified.
    gtInfo.byModified = %FALSE

    FUNCTION = %TRUE
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION fileClose(BYVAL hDlg AS DWORD) AS LONG
    LOCAL hList AS DWORD
    LOCAL lRet  AS LONG

    'Ask to save changes, if the current file has changed or not been saved.
    IF gtInfo.byModified THEN
        lRet = MessageBox(hDlg, "Save current changes?", $APP_TITLE, _
            %MB_YESNOCANCEL OR %MB_ICONQUESTION)
        SELECT CASE lRet
            CASE %IDYES
                IF ISFALSE(fileSave(hDlg, BYCOPY gtInfo.szFile)) THEN
                    EXIT FUNCTION
                END IF
            CASE %IDNO
                'Continue.
            CASE %IDCANCEL
                EXIT FUNCTION
        END SELECT
    END IF

    'Clear all data from the ListView.
    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList
    'Delete rows.
    ListView_DeleteAllItems (hList)
    'Delete columns.
    DO WHILE ListView_DeleteColumn(hList, 0)
    LOOP

    'Clear global variables.
    RESET gtInfo

    FUNCTION = %TRUE
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION fileSave(BYVAL hDlg AS DWORD, sFileIn AS STRING) AS LONG
    LOCAL sFile AS STRING
    LOCAL hFile     AS LONG
    LOCAL lFldCnt   AS LONG
    LOCAL asFlds()  AS STRING
    LOCAL hList     AS DWORD
    LOCAL lRowCnt   AS LONG
    LOCAL lRow      AS LONG

    IF LEN(sFileIn) THEN
        sFile = sFileIn
    ELSE
        sFile = gtInfo.szFile
    END IF

    IF LEN(sFile) = 0 THEN
        'Prompt for file name, if needed.
        FUNCTION = fileSaveAs(hDlg)
        EXIT FUNCTION
    END IF

    'Open file and save data.
    hFile = FREEFILE
    OPEN sFile FOR OUTPUT AS hFile
    IF ERR THEN
        MessageBox hDlg, "Error #" + FORMAT$(ERR) + " - " + ERROR$(ERR) + $CR + _
            "While trying to save: " + sFile, $APP_TITLE, %MB_ICONEXCLAMATION
        EXIT FUNCTION
    END IF

    lFldCnt = gtInfo.lFldCnt
    REDIM asFlds(0 TO lFldCnt - 1) AS STRING

    'Get field names.
    listviewGetFieldNames hDlg, asFlds()
    'Write to file.
    PRINT# hFile, csvRecordSaveToBuf(asFlds())

    'Get records.
    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList
    lRowCnt = ListView_GetItemCount(hList)
    FOR lRow = 0 TO lRowCnt - 1
        listviewRecordGet hDlg, lRow, asFlds()
        'Write to file.
        PRINT# hFile, csvRecordSaveToBuf(asFlds())
    NEXT lRow

    CLOSE hFile

    'Remember and display file name in title bar.
    gtInfo.szFile = sFile
    DIALOG SET TEXT hDlg, $APP_TITLE + " - [" + sFile + "]"

    'Set as unmodified.
    gtInfo.byModified = %FALSE

    FUNCTION = %TRUE
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION fileSaveAs(BYVAL hDlg AS DWORD) AS LONG
    LOCAL sFile AS STRING

    IF SaveFileDialog(hDlg, _
        "Save CSV File As", _
        sFile, _
        "", _
        "CSV Files (*.csv)|*.csv", _
        "csv", _
        %OFN_PATHMUSTEXIST OR %OFN_OVERWRITEPROMPT) THEN

        FUNCTION = fileSave(hDlg, sFile)

    END IF
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordAdd(BYVAL hDlg AS DWORD) AS LONG
    gtInfo.byType = %RECORD_ADD
    ShowRECORDADDEDIT hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordEdit(BYVAL hDlg AS DWORD) AS LONG
    gtInfo.byType = %RECORD_EDIT
    ShowRECORDADDEDIT hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordDelete(BYVAL hDlg AS DWORD) AS LONG
    LOCAL lRet  AS LONG
    LOCAL hList AS DWORD
    LOCAL lRow  AS LONG

    lRet = MessageBox(hDlg, "Are you sure you want to delete the selected record?", _
        $APP_TITLE, %MB_YESNO OR %MB_ICONQUESTION)
    IF lRet = %IDNO THEN
        EXIT FUNCTION
    END IF

    'Delete selected row.
    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList
    lRow = ListView_GetNextItem(hList, -1, %LVNI_SELECTED)
    ListView_DeleteItem (hList, lRow)

    'Update modified flag.
    gtInfo.byModified = %TRUE
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordEnable(BYVAL hDlg AS DWORD) AS LONG
'Enables or disables menu items.
    LOCAL hList AS DWORD
    LOCAL lRow  AS LONG
    LOCAL hMenu AS DWORD

    'See if anything is selected.
    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList
    lRow = ListView_GetNextItem(hList, -1, %LVNI_SELECTED)

    hMenu = GetMenu(hDlg)
    IF lRow > -1 THEN
        'Enable Edit & Delete.
        MENU SET STATE hMenu, BYCMD %IDM_RECORD_EDIT, %MF_ENABLED
        MENU SET STATE hMenu, BYCMD %IDM_RECORD_DELETE, %MF_ENABLED
    ELSE
        'Disable Edit & Delete.
        MENU SET STATE hMenu, BYCMD %IDM_RECORD_EDIT, %MF_GRAYED
        MENU SET STATE hMenu, BYCMD %IDM_RECORD_DELETE, %MF_GRAYED
    END IF

    IF gtInfo.lFldCnt THEN
        'Enable Add, Save, Save As.
        MENU SET STATE hMenu, BYCMD %IDM_RECORD_ADD, %MF_ENABLED
        MENU SET STATE hMenu, BYCMD %IDM_FILE_SAVE, %MF_ENABLED
        MENU SET STATE hMenu, BYCMD %IDM_FILE_SAVEAS, %MF_ENABLED
    ELSE
        'Disable Add, Save, Save As.
        MENU SET STATE hMenu, BYCMD %IDM_RECORD_ADD, %MF_GRAYED
        MENU SET STATE hMenu, BYCMD %IDM_FILE_SAVE, %MF_GRAYED
        MENU SET STATE hMenu, BYCMD %IDM_FILE_SAVEAS, %MF_GRAYED
    END IF
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordLoad(BYVAL hDlg AS DWORD) AS LONG
'Loads record into record editor from main ListView.
    LOCAL hList         AS DWORD
    LOCAL lFldCnt       AS LONG
    LOCAL lRow          AS LONG
    LOCAL asFldNames()  AS STRING
    LOCAL asFldValues() AS STRING
    LOCAL tLVC          AS LV_COLUMN
    LOCAL tLVI          AS LV_ITEM
    LOCAL szBuf         AS ASCIIZ * %BUF_SIZE
    LOCAL i             AS LONG

    'Get info from main ListView.
    '------------------------------------------------------
    CONTROL HANDLE GetParent(hDlg), %LVW_SYSLISTVIEW32_1 TO hList
    lFldCnt = gtInfo.lFldCnt

    'Get field names.
    REDIM asFldNames (0 TO lFldCnt - 1) AS STRING
    listviewGetFieldNames GetParent(hDlg), asFldNames()

    IF gtInfo.byType = %RECORD_EDIT THEN
        'Get field values.
        REDIM asFldValues(0 TO lFldCnt - 1) AS STRING
        lRow = ListView_GetNextItem(hList, -1, %LVNI_SELECTED)
        listviewRecordGet GetParent(hDlg), lRow, asFldValues()
    END IF


    'Save info to record ListView.
    '------------------------------------------------------
    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_2 TO hList

    'Set up column headers.
    tLVC.mask    = %LVCF_FMT OR %LVCF_TEXT OR %LVCF_SUBITEM
    tLVC.fmt     = %LVCFMT_LEFT
    tLVC.pszText = VARPTR(szBuf)

    szBuf = "Name"
    ListView_InsertColumn (hList, 0, tLVC)

    szBuf = "Value"
    ListView_InsertColumn (hList, 1, tLVC)

    'Set record data.
    tLVI.stateMask   = %LVIS_FOCUSED
    tLVI.pszText     = VARPTR(szBuf)

    FOR i = 0 TO lFldCnt - 1
        tLVI.iItem      = i

        'Field Name.
        tLVI.iSubItem   = 0
        szBuf           = asFldNames(i)
        tLVI.mask = %LVIF_TEXT OR %LVIF_STATE
        ListView_InsertItem (hList, tLVI)

        IF gtInfo.byType = %RECORD_EDIT THEN
            'Field Value.
            tLVI.iSubItem   = 1
            szBuf           = asFldValues(i)
            tLVI.mask       = %LVIF_TEXT
            ListView_SetItem (hList, tLVI)
        END IF
    NEXT i

    'Auto size columns.
    ListView_SetColumnWidth (hList, 0, %LVSCW_AUTOSIZE)
    IF gtInfo.byType = %RECORD_EDIT THEN
        ListView_SetColumnWidth (hList, 1, %LVSCW_AUTOSIZE)
    ELSE
        ListView_SetColumnWidth (hList, 1, %LVSCW_AUTOSIZE_USEHEADER)
    END IF
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordSave(BYVAL hDlg AS DWORD) AS LONG
'Saves record from record editor to main ListView.
    LOCAL hList         AS DWORD
    LOCAL lRowCnt       AS LONG
    LOCAL asFlds()      AS STRING
    LOCAL asFldsOld()   AS STRING
    LOCAL lRow          AS LONG
    LOCAL lSelRow       AS LONG
    LOCAL szBuf         AS ASCIIZ * %BUF_SIZE

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_2 TO hList

    'Get row count.
    lRowCnt = ListView_GetItemCount(hList)

    'Assign fields.
    REDIM asFlds(0 TO lRowCnt - 1) AS STRING
    FOR lRow = 0 TO lRowCnt - 1
        ListView_GetItemText hList, lRow, 1, szBuf, SIZEOF(szBuf)
        asFlds(lRow) = szBuf
    NEXT lRow

    CONTROL HANDLE GetParent(hDlg), %LVW_SYSLISTVIEW32_1 TO hList

    IF gtInfo.byType = %RECORD_EDIT THEN
        'Get original field values.
        REDIM asFldsOld(0 TO lRowCnt - 1) AS STRING
        lSelRow = ListView_GetNextItem(hList, -1, %LVNI_SELECTED)
        listviewRecordGet GetParent(hDlg), lSelRow, asFldsOld()

        'Check to see if any values have changed.
        FOR lRow = 0 TO lRowCnt - 1
            IF asFlds(lRow) <> asFldsOld(lRow) THEN
                'Values have changed, so update modified flag.
                gtInfo.byModified = %TRUE
                EXIT FOR
            END IF
        NEXT lRow

        IF gtInfo.byModified THEN
            'Replace original row with new values.
            listviewRecordReplace GetParent(hDlg), lSelRow, asFlds()
        END IF
    ELSE
        'Add new row and update modified flag.
        listviewRecordAdd GetParent(hDlg), asFlds()
        gtInfo.byModified = %TRUE
    END IF
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordShow(BYVAL hDlg AS DWORD, BYVAL hList AS DWORD, BYVAL lRow AS LONG) AS LONG
'Shows the selected field in the record editor.
    LOCAL szBuf     AS ASCIIZ * %BUF_SIZE

    'Get the field name and set to label.
    ListView_GetItemText hList, lRow, 0, szBuf, SIZEOF(szBuf)
    CONTROL SET TEXT hDlg, %LBL_FIELDNAME, szBuf + ":"

    'Get the field value and set to text box.
    ListView_GetItemText hList, lRow, 1, szBuf, SIZEOF(szBuf)
    CONTROL SET TEXT hDlg, %TXT_FIELDVALUE, szBuf
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION recordUpdate(BYVAL hDlg AS DWORD) AS LONG
'Updates the edited field value and moves to the next field, if applicable.
    LOCAL hList     AS DWORD
    LOCAL lRow      AS LONG
    LOCAL sBuf      AS STRING
    LOCAL lRowCnt   AS LONG

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_2 TO hList

    'Get selected row.
    lRow = ListView_GetNextItem(hList, -1, %LVNI_SELECTED)

    'Get new value.
    CONTROL GET TEXT hDlg, %TXT_FIELDVALUE TO sBuf

    'Set value to ListView.
    ListView_SetItemText hList, lRow, 1, BYCOPY sBuf

    'Get row count.
    lRowCnt = ListView_GetItemCount(hList)

    IF lRow + 1 < lRowCnt THEN
        'Move to next row.
        ListView_SetItemState (hList, lRow + 1, %LVIS_SELECTED, %LVIS_SELECTED)

        'Set focus to text box.
        CONTROL SET FOCUS hDlg, %TXT_FIELDVALUE
    ELSE
        'Set the close button as the default & set focus there also.
        DIALOG SEND hDlg, %DM_SETDEFID, %IDCLOSE, 0
        CONTROL SET FOCUS hDlg, %TXT_FIELDVALUE
    END IF
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION aboutDlg(BYVAL hDlg AS DWORD) AS LONG
    ShowABOUT hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION aboutGetInfo() AS STRING
'Gets the Version info from the executable file.

    DIM szFile      AS ASCIIZ * %MAX_PATH
    DIM lHandle     AS LONG
    DIM lSize       AS LONG
    DIM sBuf        AS STRING
    DIM lRet        AS LONG
    DIM pBuf        AS ASCIIZ PTR
    DIM lBufLen     AS LONG
    DIM sRetBuf     AS STRING

    GetModuleFileName BYVAL %NULL, szFile, SIZEOF(szFile)

    lSize = GetFileVersionInfoSize(szFile, lHandle)
    sBuf = SPACE$(lSize)
    lRet = GetFileVersionInfo(szFile, lHandle, lSize, BYVAL STRPTR(sBuf))
    IF lRet THEN
        lRet = VerQueryValue(BYVAL STRPTR(sBuf), _
            "\StringFileInfo\040904B0\ProductName", pBuf, lBufLen)
        IF lRet THEN
            sRetBuf = sRetBuf + @pBuf + $CRLF
        END IF
        lRet = VerQueryValue(BYVAL STRPTR(sBuf), _
            "\StringFileInfo\040904B0\FileDescription", pBuf, lBufLen)
        IF lRet THEN
            sRetBuf = sRetBuf + @pBuf + $CRLF
        END IF
        lRet = VerQueryValue(BYVAL STRPTR(sBuf), _
            "\StringFileInfo\040904B0\LegalCopyright", pBuf, lBufLen)
        IF lRet THEN
            sRetBuf = sRetBuf + @pBuf + $CRLF
        END IF
        lRet = VerQueryValue(BYVAL STRPTR(sBuf), _
            "\StringFileInfo\040904B0\ProductVersion", pBuf, lBufLen)
        IF lRet THEN
            sRetBuf = sRetBuf + "Version " + @pBuf
        END IF
    END IF

    FUNCTION = sRetBuf

END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION fieldNameAdd(BYVAL hDlg AS DWORD) AS LONG
    LOCAL sFldName  AS STRING

    'Get field name.
    CONTROL GET TEXT hDlg, %TXT_FIELDNAME TO sFldName

    'Add field name to list.
    LISTBOX ADD hDlg, %LST_FIELDNAMES, sFldName

    'Clear field name and set focus.
    CONTROL SET TEXT hDlg, %TXT_FIELDNAME, ""
    CONTROL SET FOCUS hDlg, %TXT_FIELDNAME

    'Clear selection.
    CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_SETCURSEL, -1, 0
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION fieldNameUpdate(BYVAL hDlg AS DWORD) AS LONG
    LOCAL sFldName  AS STRING
    LOCAL lIndex    AS LONG

    'Get field name.
    CONTROL GET TEXT hDlg, %TXT_FIELDNAME TO sFldName

    'Get index of current selection in list.
    CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_GETCURSEL, 0, 0 TO lIndex

    'Delete currently selected item (add 1 because API is 0-based and DDT is 1-based).
    LISTBOX DELETE hDlg, %LST_FIELDNAMES, lIndex + 1

    'Add field name to list where item was just deleted.
    CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_INSERTSTRING, lIndex, STRPTR(sFldName)

    'Clear field name and set focus.
    CONTROL SET TEXT hDlg, %TXT_FIELDNAME, ""
    CONTROL SET FOCUS hDlg, %TXT_FIELDNAME
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION fieldNameDelete(BYVAL hDlg AS DWORD) AS LONG
    LOCAL sFldName  AS STRING
    LOCAL lRet      AS LONG
    LOCAL lIndex    AS LONG

    'Get field name.
    LISTBOX GET TEXT hDlg, %LST_FIELDNAMES TO sFldName

    lRet = MessageBox(hDlg, "Are you sure you want to delete the '" + sFldName + _
        "' field name?", $APP_TITLE, %MB_YESNO OR %MB_ICONQUESTION)
    IF lRet = %IDNO THEN
        EXIT FUNCTION
    END IF

    'Get index of current selection in list.
    CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_GETCURSEL, 0, 0 TO lIndex

    'Delete currently selected item (add 1 because API is 0-based and DDT is 1-based).
    LISTBOX DELETE hDlg, %LST_FIELDNAMES, lIndex + 1

    'Clear field name and set focus to list.
    CONTROL SET TEXT hDlg, %TXT_FIELDNAME, ""
    CONTROL SET FOCUS hDlg, %LST_FIELDNAMES
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION fieldNameSave(BYVAL hDlg AS DWORD) AS LONG
    LOCAL hList     AS DWORD
    LOCAL lFldCnt   AS LONG
    LOCAL i         AS LONG
    LOCAL lLen      AS LONG
    LOCAL asFlds()  AS STRING

    CONTROL HANDLE hDlg, %LST_FIELDNAMES TO hList

    'Get item count in list box.
    CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_GETCOUNT, 0, 0 TO lFldCnt

    'Assign all fields in the list box to an array.
    REDIM asFlds(0 TO lFldCnt - 1) AS STRING
    FOR i = 0 TO lFldCnt - 1
        CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_GETTEXTLEN, i, 0 TO lLen
        asFlds(i) = SPACE$(lLen)
        CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_GETTEXT, i, STRPTR(asFlds(i))
    NEXT i

    listviewLoadFieldNames GetParent(hDlg), asFlds()

    'Auto size columns based upon header size.
    CONTROL HANDLE GetParent(hDlg), %LVW_SYSLISTVIEW32_1 TO hList
    FOR i = 0 TO UBOUND(asFlds)
        ListView_SetColumnWidth (hList, i, %LVSCW_AUTOSIZE_USEHEADER)
    NEXT lCol

    gtInfo.lFldCnt = lFldCnt
    gtInfo.byModified = %TRUE

END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION fieldNameEnableButtons(BYVAL hDlg AS DWORD) AS LONG
'Enable/disable buttons based upon data in the text box and selection in the list box.
'Also set default buttons based upon buttons enabled and focus.
    LOCAL sFldName  AS STRING
    LOCAL lIndex    AS LONG
    LOCAL lCount    AS LONG

    'Get field name.
    CONTROL GET TEXT hDlg, %TXT_FIELDNAME TO sFldName

    'Get index of current selection in list.
    CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_GETCURSEL, 0, 0 TO lIndex

    'Get count of items in list.
    CONTROL SEND hDlg, %LST_FIELDNAMES, %LB_GETCOUNT, 0, 0 TO lCount

    'Enable the Add button if a new field name is in the text box; otherwise disable.
    IF LEN(sFldName) THEN
        CONTROL ENABLE hDlg, %BTN_FLDADD
    ELSE
        CONTROL DISABLE hDlg, %BTN_FLDADD
    END IF

    'Enable the Update button if a new field name is in the text box and
    'a field name is selected in the list box; otherwise disable.
    IF LEN(sFldName) AND lIndex > %LB_ERR THEN
        CONTROL ENABLE hDlg, %BTN_FLDUPDATE
    ELSE
        CONTROL DISABLE hDlg, %BTN_FLDUPDATE
    END IF

    'Enable the Delete button if a field name is selected in the list box; otherwise disable.
    IF lIndex > %LB_ERR THEN
        CONTROL ENABLE hDlg, %BTN_FLDDELETE
    ELSE
        CONTROL DISABLE hDlg, %BTN_FLDDELETE
    END IF

    'Enable the Save & Close button if items in list box; otherwise disable.
    IF lCount THEN
        CONTROL ENABLE hDlg, %IDCLOSE
    ELSE
        CONTROL DISABLE hDlg, %IDCLOSE
    END IF

    IF GetDlgItem(hDlg, %TXT_FIELDNAME) = GetFocus() THEN
        'Text box has focus.
        IF IsWindowEnabled(GetDlgItem(hDlg, %BTN_FLDUPDATE)) THEN
            'Make the Update button the default button if it is enabled and the text box has
            'focus.
            DIALOG SEND hDlg, %DM_SETDEFID, %BTN_FLDUPDATE, 0
        ELSEIF IsWindowEnabled(GetDlgItem(hDlg, %BTN_FLDADD)) THEN
            'Make the Add button the default button if is enabled, the text box has focus
            'and the Update button is not enabled.
            DIALOG SEND hDlg, %DM_SETDEFID, %BTN_FLDADD, 0
        END IF
    END IF

    IF GetDlgItem(hDlg, %LST_FIELDNAMES) = GetFocus() THEN
        'List box has focus.
        IF IsWindowEnabled(GetDlgItem(hDlg, %BTN_FLDDELETE)) THEN
            'Make the Delete button the default button if it is enabled and the list box has
            'focus.
            DIALOG SEND hDlg, %DM_SETDEFID, %BTN_FLDDELETE, 0
        END IF
    END IF

END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION listviewLoadFieldNames(BYVAL hDlg AS DWORD, asFlds() AS STRING) AS LONG
    LOCAL hList AS DWORD
    LOCAL tLVC  AS LV_COLUMN
    LOCAL lCol  AS LONG

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList

    'Set up column headers.
    tLVC.mask    = %LVCF_FMT OR %LVCF_TEXT OR %LVCF_SUBITEM
    tLVC.fmt     = %LVCFMT_LEFT

    FOR lCol = 0 TO UBOUND(asFlds)
        tLVC.pszText = STRPTR(asFlds(lCol))
        tLVC.iOrder  = lCol
        ListView_InsertColumn (hList, lCol, tLVC)
    NEXT lCol
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION listviewGetFieldNames(BYVAL hDlg AS DWORD, asFlds() AS STRING) AS LONG
    LOCAL hList AS DWORD
    LOCAL tLVC  AS LV_COLUMN
    LOCAL lCol  AS LONG
    LOCAL szBuf AS ASCIIZ * %BUF_SIZE

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList

    'Get column headers.
    tLVC.mask        = %LVCF_TEXT
    tLVC.pszText     = VARPTR(szBuf)
    tLVC.cchTextMax  = SIZEOF(szBuf)

    FOR lCol = 0 TO UBOUND(asFlds)
        ListView_GetColumn (hList, lCol, tLVC)
        asFlds(lCol) = szBuf
    NEXT lCol
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION listviewRecordAdd(BYVAL hDlg AS DWORD, asFlds() AS STRING) AS LONG
    LOCAL hList     AS DWORD
    LOCAL tLVI      AS LV_ITEM
    LOCAL lCol      AS LONG
    LOCAL lStatus   AS LONG

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList

    tLVI.stateMask   = %LVIS_FOCUSED
    tLVI.iItem       = ListView_GetItemCount(hList)

    FOR lCol = 0 TO UBOUND(asFlds)
        tLVI.pszText     = STRPTR(asFlds(lCol))
        tLVI.iSubItem    = lCol
        IF lCol = 0 THEN
            tLVI.mask = %LVIF_TEXT OR %LVIF_STATE
            ListView_InsertItem (hList, tLVI)
        ELSE
            tLVI.mask = %LVIF_TEXT
            lStatus = ListView_SetItem(hList, tLVI)
        END IF
    NEXT lCol

END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION listviewRecordReplace(BYVAL hDlg AS DWORD, BYVAL lRow AS LONG, _
    asFlds() AS STRING) AS LONG
    LOCAL hList AS DWORD
    LOCAL lCol  AS LONG

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList

    FOR lCol = 0 TO UBOUND(asFlds)
        ListView_SetItemText (hList, lRow, lCol, BYCOPY asFlds(lCol))
    NEXT lCol
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION listviewRecordGet(BYVAL hDlg AS DWORD, BYVAL lRow AS LONG, _
    asFlds() AS STRING) AS LONG
    LOCAL hList AS DWORD
    LOCAL lCol  AS LONG
    LOCAL szBuf AS ASCIIZ * %BUF_SIZE

    CONTROL HANDLE hDlg, %LVW_SYSLISTVIEW32_1 TO hList

    FOR lCol = 0 TO UBOUND(asFlds)
        ListView_GetItemText (hList, lRow, lCol, szBuf, SIZEOF(szBuf))
        asFlds(lCol) = szBuf
    NEXT lCol
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION csvRecordGetFieldCount(sBuf AS STRING) AS LONG
'Gets the field count from the first record assuming the first record contains field names.
    LOCAL sDst  AS STRING

    sDst = EXTRACT$(sBuf, $CRLF)

    FUNCTION = PARSECOUNT(sDst, ",")
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION csvRecordParseFromBuf(BYVAL pSrc AS BYTE PTR, sBuf AS STRING, _
    asFlds() AS STRING) AS LONG

    LOCAL szDst     AS ASCIIZ * %BUF_SIZE
    LOCAL pDst      AS BYTE PTR
    LOCAL lQuote    AS LONG
    LOCAL lFldCnt   AS LONG

    pDst = VARPTR(szDst)
    DO WHILE @pSrc
        SELECT CASE @pSrc
            CASE 13     'Carriage Return.
                IF lQuote THEN
                    'Within quotes, so copy.
                    IF pDst - VARPTR(szDst) < %BUF_SIZE - 1 THEN
                        @pDst = @pSrc
                        INCR pDst
                    END IF
                    INCR pSrc
                    IF @pSrc = 10 THEN
                        'Copy Line Feed also.
                        IF pDst - VARPTR(szDst) < %BUF_SIZE - 1 THEN
                            @pDst = @pSrc
                            INCR pDst
                        END IF
                        INCR pSrc
                    ELSE
                        'Add Line Feed anyway.
                        IF pDst - VARPTR(szDst) < %BUF_SIZE - 1 THEN
                            @pDst = 10
                            INCR pDst
                        END IF
                    END IF
                ELSE
                    'Not within quotes, so end of record.
                    INCR pSrc
                    IF @pSrc = 10 THEN
                        'Move past line break.
                        INCR pSrc
                    END IF
                    'End field.
                    @pDst = %NULL
                    asFlds(lFldCnt) = szDst
                    EXIT DO
                END IF

            CASE 10     'Line Feed.
                IF lQuote THEN
                    'Add Carriage Return before Line Feed.
                    IF pDst - VARPTR(szDst) < %BUF_SIZE - 2 THEN
                        @pDst = 13
                        INCR pDst
                        @pDst = @pSrc
                        INCR pDst
                    END IF
                    INCR pSrc
                END IF

            CASE 34     'Double Quote (").
                lQuote = NOT lQuote
                IF lQuote = %FALSE AND @pSrc[1] = 34 THEN
                    'Next character is also a double quote, so copy one.
                    IF pDst - VARPTR(szDst) < %BUF_SIZE - 1 THEN
                        @pDst = @pSrc
                        INCR pDst
                    END IF
                    INCR pSrc
                    'Skip second double quote.
                    INCR pSrc
                    lQuote = NOT lQuote
                ELSE
                    'Skip double quote.
                    INCR pSrc
                END IF

            CASE 44     'Comma (,).
                IF lQuote THEN
                    'Within quotes, so copy.
                    IF pDst - VARPTR(szDst) < %BUF_SIZE - 1 THEN
                        @pDst = @pSrc
                        INCR pDst
                    END IF
                    INCR pSrc
                ELSE
                    'End of field.
                    @pDst = %NULL
                    asFlds(lFldCnt) = szDst
                    'Prepare for next field.
                    pDst = VARPTR(szDst)
                    'Increment field count.
                    INCR lFldCnt
                    INCR pSrc
                END IF

            CASE ELSE
                'Copy text.
                IF pDst - VARPTR(szDst) < %BUF_SIZE - 1 THEN
                    @pDst = @pSrc
                    INCR pDst
                END IF
                INCR pSrc

        END SELECT
    LOOP

    FUNCTION = pSrc
END FUNCTION
'------------------------------------------------------------------------------

'------------------------------------------------------------------------------
FUNCTION csvRecordSaveToBuf(asFlds() AS STRING) AS STRING
    LOCAL i     AS LONG
    LOCAL sBuf  AS STRING
    LOCAL sTmp  AS STRING

    FOR i = 0 TO UBOUND(asFlds)
        IF INSTR(asFlds(i), ANY $DQ + $CR + ",") THEN
            'Surround with quotes because fields include:
            'double quotes, carriage returns or commas.
            sTmp = asFlds(i)
            'Double any double quotes.
            REPLACE $DQ WITH $DQ + $DQ IN sTmp
            'Replace carriage return line feeds with just line feeds.
            REPLACE $CRLF WITH $LF IN sTmp
            sBuf = sBuf + $DQ + sTmp + $DQ + ","
        ELSE
            'No quotes needed.
            sBuf = sBuf + asFlds(i) + ","
        END IF
    NEXT i
    'Drop the last comma.
    FUNCTION = LEFT$(sBuf, LEN(sBuf) - 1)
END FUNCTION
'------------------------------------------------------------------------------

