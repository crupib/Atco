#PBFORMS CREATED V1.51
'==============================================================================
'
'  Interface Explorer.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2002-2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  The complete Interface Explorer program
'  See also code in Interface Explorer.inc
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES 
%USEMACROS = 1
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#IF NOT %DEF(%COMMCTRL_INC)
    #INCLUDE "COMMCTRL.INC"
#ENDIF
#INCLUDE "PBForms.INC"
#PBFORMS END INCLUDES
#INCLUDE  "COMDLG32.INC"
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS 
%IDCANCEL              =    2
%IDC_ABOUT             = 1008
%IDC_BUTTON1           = 1005
%IDC_BUTTON2           = 1006
%IDC_CHECKBOX1         = 1102
%IDC_CHECKBOX2         = 1103
%IDC_CHECKBOX3         = 1104
%IDC_CHECKBOX4         = 1105
%IDC_FRAME1            = 1101
%IDC_LABEL1            = 1001
%IDC_LABEL2            = 1003
%IDC_LABEL3            = 1004
%IDC_LABEL4            = 1106
%IDC_LABEL5            = 1201
%IDC_LABEL6            = 1202
%IDC_LINE1             = 1007
%IDC_MSCTLS_UPDOWN32_1 = 1108
%IDC_SYSTREEVIEW32_1   = 1002
%IDC_TEXTBOX1          = 1107
%IDD_DIALOG1           =  100
%IDD_DIALOG2           =  200
%IDD_DIALOG3           =  300
%IDOK                  =    1
%IDR_MENU1             =  102
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE          FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
DECLARE          FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowDIALOG2Proc()
DECLARE          FUNCTION ShowDIALOG2(BYVAL hDlg AS DWORD) AS LONG
DECLARE CALLBACK FUNCTION ShowDIALOG3Proc()
DECLARE          FUNCTION ShowDIALOG3(BYVAL hDlg AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------

#INCLUDE  "Interface Explorer.inc"

'--------------------------------------------------------------------------------
FUNCTION PBMAIN()
    REDIM gWork(0) AS GLOBAL STRING

    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR %ICC_INTERNET_CLASSES)

    CALL SetDefaultOptions

    ' Launch the main app dialog
    ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** CallBacks **
'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
    STATIC File AS STRING
    LOCAL  a    AS STRING
    LOCAL  x    AS LONG

    SELECT CASE CBMSG
        CASE %WM_INITDIALOG
            ' Subclass the TREEVIEW to capture and prevent "*" events since an
            ' interface may recurse endlessly and exceed the TREEVIEW limits.
            gOldTVProc = SetWindowLong(GetDlgItem(CBHNDL, %IDC_SYSTREEVIEW32_1), _
                %GWL_WNDPROC, CODEPTR(LVSubclass))

            ' Flag the dialog as accepting drag/drop files
            DragAcceptFiles CBHNDL, %TRUE

        CASE %WM_DESTROY
            ' Unsubclass to clean up
            SetWindowLong GetDlgItem(CBHNDL, %IDC_SYSTREEVIEW32_1), _
                %GWL_WNDPROC, gOldTVProc

            ' Switch off drag/drop mode
            DragAcceptFiles CBHNDL, %TRUE

        CASE %WM_DROPFILES
            ' Get one dropped file.  First check the number of dropped files
            x = DragQueryFile(CBWPARAM, &HFFFFFFFF&, BYVAL %NULL, 0)

            IF ISTRUE x THEN
                ' If there is at least one file, grab it and test it is
                ' actually a file
                a = SPACE$(%MAX_PATH)
                IF DragQueryFile(CBWPARAM, 0, BYVAL STRPTR(a), LEN(a)) THEN

                    ' Make sure it's a file, not a folder
                    IF ISTRUE LEN(a) AND ISFALSE (GETATTR(a) AND 16) THEN
                        ' Yes, signal a scan to commence
                        File = a
                        DIALOG POST CBHNDL, %WM_USER + 999&, 0, 1
                        SetForegroundWindow CBHNDL
                        FUNCTION = 1
                    END IF
                END IF
            END IF

            ' We're done here
            CALL DragFinish(CBWPARAM)

        CASE %WM_COMMAND

            SELECT CASE CBCTL

                CASE %IDC_SYSTREEVIEW32_1
                    ' Nothing to do here, see %WM_NOTIFY

                CASE %IDC_BUTTON1
                    ' Options button
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        IF ShowDIALOG2(CBHNDL) = 1 THEN ' Clicked OK, so rescan
                            IF ISTRUE LEN(File) THEN
                                DIALOG SEND CBHNDL, %WM_USER + 999&, 0, 0
                            END IF
                        END IF
                    END IF

                CASE %IDC_BUTTON2
                    ' Open button
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        a = File
                        IF IEOpenFileDialog(CBHNDL, a) THEN
                            File = a
                            DIALOG SEND CBHNDL, %WM_USER + 999&, 0, 0
                        END IF
                    END IF

                CASE %IDCANCEL
                    ' Quit button
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 0 ' Close the application
                    END IF

                CASE %IDC_ABOUT
                    ' Menu activated only, so CBCTLMSG test is unnecessary
                    ShowDIALOG3 CBHNDL

            END SELECT

        CASE %WM_NOTIFY
            ' TREEVIEW control occurs through this handler
            FUNCTION = TVNotifyHandler(CBHNDL, %IDC_SYSTREEVIEW32_1, CBLPARAM)

        CASE %WM_USER + 999&
            DragAcceptFiles CBHNDL, %FALSE
            CONTROL DISABLE CBHNDL, %IDC_BUTTON1
            CONTROL DISABLE CBHNDL, %IDC_BUTTON2

            IF ProcessFile(CBHNDL, %IDC_SYSTREEVIEW32_1, File) THEN
                a = " - " & MID$(File, INSTR(-1, File, "\") + 1)
            ELSE
                a = ""
            END IF

            ' Set the app title
            DIALOG SET TEXT CBHNDL, "Interface Explorer" & a

            CONTROL ENABLE CBHNDL, %IDC_BUTTON1
            CONTROL ENABLE CBHNDL, %IDC_BUTTON2
            DragAcceptFiles CBHNDL, %TRUE

    END SELECT
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL hImageList AS LONG
    LOCAL hInstance  AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->%IDR_MENU1->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Interface Explorer", 48, 62, 300, 212, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR _
        %WS_CLIPCHILDREN OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT OR _
        %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    DIALOG  SET COLOR   hDlg, -1, RGB(132, 207, 253)
    CONTROL ADD LABEL,  hDlg, %IDC_LABEL1, " &Interface tree", 5, 5, 235, 10, %WS_CHILD OR _
        %WS_VISIBLE OR %WS_BORDER OR %SS_LEFT, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR   hDlg, %IDC_LABEL1, %WHITE, %BLUE
    CONTROL ADD "SysTreeView32", hDlg, %IDC_SYSTREEVIEW32_1, "SysTreeView321", 5, 15, 235, 180, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER OR %WS_TABSTOP OR %TVS_HASBUTTONS OR _
        %TVS_HASLINES OR %TVS_LINESATROOT OR %TVS_DISABLEDRAGDROP OR %TVS_SHOWSELALWAYS OR _
        %TVS_FULLROWSELECT, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD LABEL,  hDlg, %IDC_LABEL2, " Status", 245, 5, 50, 10, %WS_CHILD OR %WS_VISIBLE OR _
        %WS_BORDER OR %SS_LEFT, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR   hDlg, %IDC_LABEL2, %WHITE, %BLUE
    CONTROL ADD LABEL,  hDlg, %IDC_LABEL3, "", 245, 15, 50, 50, %WS_CHILD OR %WS_VISIBLE OR _
        %WS_BORDER OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR   hDlg, %IDC_LABEL3, %BLACK, RGB(255, 255, 222)
    CONTROL ADD BUTTON, hDlg, %IDC_BUTTON1, "O&ptions", 245, 70, 50, 15
    CONTROL ADD BUTTON, hDlg, %IDC_BUTTON2, "&Open File", 245, 160, 50, 15
    CONTROL ADD BUTTON, hDlg, %IDCANCEL, "&Quit", 245, 180, 50, 15
    CONTROL ADD LINE,   hDlg, %IDC_LINE1, "Line2", 0, 0, 300, 1

    AttachMENU1 hDlg
#PBFORMS END DIALOG

    ' Create our icon image list for the TREEVIEW
    hImageList = ImageList_Create( 16, 16, %ILC_MASK, 3, 1 )
    hInstance = GetModuleHandle(BYVAL %NULL)
    CALL ImageList_AddIcon(hImageList, LoadIcon(hInstance, "IMAGE_OBJECT"))
    CALL ImageList_AddIcon(hImageList, LoadIcon(hInstance, "IMAGE_INTERFACE"))
    CALL ImageList_AddIcon(hImageList, LoadIcon(hInstance, "IMAGE_METHOD"))
    CONTROL SEND hDlg, %IDC_SYSTREEVIEW32_1, %TVM_SETIMAGELIST, %TVSIL_NORMAL, hImageList

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD

#PBFORMS BEGIN MENU %IDR_MENU1->%IDD_DIALOG1
    LOCAL hMenu   AS DWORD
    LOCAL hPopUp1 AS DWORD

    MENU NEW BAR TO hMenu
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "&File", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Open File", %IDC_BUTTON2, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "-", 0, 0
        MENU ADD STRING, hPopUp1, "O&ptions", %IDC_BUTTON1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "-", 0, 0
        MENU ADD STRING, hPopUp1, "E&xit", %IDCANCEL, %MF_ENABLED
    MENU ADD STRING, hMenu, "&About!", %IDC_ABOUT, %MF_ENABLED

    MENU ATTACH hMenu, hDlg
#PBFORMS END MENU

    FUNCTION = hMenu
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG2Proc()
    LOCAL  Txt    AS STRING
    STATIC Update AS LONG

    SELECT CASE CBMSG
        CASE %WM_INITDIALOG
            ' Preconfigure the options
            CONTROL SET CHECK CBHNDL, %IDC_CHECKBOX1, gChk1
            CONTROL SET CHECK CBHNDL, %IDC_CHECKBOX2, gChk2
            CONTROL SET CHECK CBHNDL, %IDC_CHECKBOX3, gChk3
            CONTROL SET CHECK CBHNDL, %IDC_CHECKBOX4, gChk4
            CONTROL SET TEXT  CBHNDL, %IDC_TEXTBOX1, FORMAT$(gDepth)
            CONTROL SEND CBHNDL, %IDC_MSCTLS_UPDOWN32_1, %UDM_SETRANGE, 0, _
                MAKLNG(0,10)
            Update = %FALSE

        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_CHECKBOX1, %IDC_CHECKBOX2, %IDC_CHECKBOX3, %IDC_CHECKBOX4
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN Update = %TRUE

                CASE %IDC_TEXTBOX1
                    IF CBCTLMSG = %EN_CHANGE THEN Update = %TRUE

                CASE %IDC_MSCTLS_UPDOWN32_1
                    ' Nothing to do - see %IDC_TEXTBOX1

                CASE %IDOK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        CONTROL GET CHECK CBHNDL, %IDC_CHECKBOX1 TO gChk1
                        CONTROL GET CHECK CBHNDL, %IDC_CHECKBOX2 TO gChk2
                        CONTROL GET CHECK CBHNDL, %IDC_CHECKBOX3 TO gChk3
                        CONTROL GET CHECK CBHNDL, %IDC_CHECKBOX4 TO gChk4
                        gDepth = GetDlgItemInt(CBHNDL, %IDC_TEXTBOX1, BYVAL 0,0)
                        DIALOG END CBHNDL, Update ' Signal OK if any changes
                    END IF

                CASE %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 0 ' Signal Cancel (0)
                    END IF

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG2->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Interface Explorer Options", 174, 132, 161, 86, %WS_POPUP OR %WS_BORDER _
        OR %WS_DLGFRAME OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
        %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    DIALOG  SET COLOR     hDlg, -1, RGB(252, 216, 131)
    CONTROL ADD FRAME,    hDlg, %IDC_FRAME1, "Options", 5, 5, 95, 75
    CONTROL SET COLOR     hDlg, %IDC_FRAME1, -1, RGB(252, 216, 131)
    CONTROL ADD CHECKBOX, hDlg, %IDC_CHECKBOX1, "&Show Prefix", 15, 16, 84, 10
    CONTROL SET COLOR     hDlg, %IDC_CHECKBOX1, -1, RGB(252, 216, 131)
    CONTROL ADD CHECKBOX, hDlg, %IDC_CHECKBOX2, "Show &Types", 15, 27, 84, 10
    CONTROL SET COLOR     hDlg, %IDC_CHECKBOX2, -1, RGB(252, 216, 131)
    CONTROL ADD CHECKBOX, hDlg, %IDC_CHECKBOX3, "Show &Parameters", 15, 38, 84, 10
    CONTROL SET COLOR     hDlg, %IDC_CHECKBOX3, -1, RGB(252, 216, 131)
    CONTROL ADD CHECKBOX, hDlg, %IDC_CHECKBOX4, "Show Methods/P&rops", 15, 49, 84, 10
    CONTROL SET COLOR     hDlg, %IDC_CHECKBOX4, -1, RGB(252, 216, 131)
    CONTROL ADD LABEL,    hDlg, %IDC_LABEL4, "Scan &Depth", 43, 63, 56, 10
    CONTROL SET COLOR     hDlg, %IDC_LABEL4, -1, RGB(252, 216, 131)
    CONTROL ADD TEXTBOX,  hDlg, %IDC_TEXTBOX1, "FORMAT$(gDepth)", 15, 61, 25, 13, %WS_CHILD OR _
        %WS_VISIBLE OR %WS_TABSTOP OR %ES_LEFT OR %ES_AUTOHSCROLL OR %ES_NUMBER, _
        %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD "msctls_updown32", hDlg, %IDC_MSCTLS_UPDOWN32_1, "", 35, 61, 11, 13, %WS_CHILD OR _
        %WS_VISIBLE OR %UDS_SETBUDDYINT OR %UDS_ALIGNRIGHT OR %UDS_AUTOBUDDY OR %UDS_ARROWKEYS
    CONTROL ADD BUTTON,   hDlg, %IDOK, "OK", 105, 10, 50, 15
    DIALOG  SEND          hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON,   hDlg, %IDCANCEL, "Cancel", 105, 30, 50, 15
#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG2Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG2
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG3Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDOK, %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 0
                    END IF
            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG3(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG3->->
    LOCAL hDlg   AS DWORD
    LOCAL hFont1 AS DWORD

    DIALOG NEW hParent, "About Interface Explorer", 98, 100, 140, 70, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
        %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR, TO hDlg
    DIALOG  SET COLOR   hDlg, -1, RGB(139, 197, 197)
    CONTROL ADD LABEL,  hDlg, %IDC_LABEL5, "Interface Explorer", 5, 5, 135, 15, %WS_CHILD OR _
        %WS_VISIBLE OR %SS_CENTER, %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR   hDlg, %IDC_LABEL5, -1, RGB(139, 197, 197)
    CONTROL ADD LABEL,  hDlg, %IDC_LABEL6, "A PowerBASIC Forms Example project by PowerBASIC, " + _
        "Inc. Copyright © 2005.", 5, 20, 135, 20, %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR   hDlg, %IDC_LABEL6, -1, RGB(139, 197, 197)
    CONTROL ADD BUTTON, hDlg, %IDOK, "OK", 45, 50, 50, 15
    DIALOG  SEND        hDlg, %DM_SETDEFID, %IDOK, 0

    hFont1 = PBFormsMakeFont("Arial", 14, 400, %FALSE, %FALSE, %FALSE, %ANSI_CHARSET)

    CONTROL SEND hDlg, %IDC_LABEL5, %WM_SETFONT, hFont1, 0
#PBFORMS END DIALOG

    SndPlaySound ENVIRON$("windir") & "\media\The Microsoft Sound.wav", %SND_ASYNC
    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG3Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG3
    DeleteObject hFont1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

