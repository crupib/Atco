#PBFORMS CREATED V1.51
'==============================================================================
'
'  Interface Explorer.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Frame-work for the real program in \Interface Explorer (Final)\
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES 
#RESOURCE "Interface Explorer.pbr"
%USEMACROS = 1
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#IF NOT %DEF(%COMMCTRL_INC)
    #INCLUDE "COMMCTRL.INC"
#ENDIF
#INCLUDE "PBForms.INC"
#PBFORMS END INCLUDES
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
%IDR_IMGFILE1          =  301
%IDR_MENU1             =  102
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG2Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG3Proc()
DECLARE FUNCTION SampleTreeViewInsertItem(BYVAL hTree AS DWORD, BYVAL hParent AS _
    DWORD, sItem AS STRING) AS LONG
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG3(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION PBMAIN()

    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR %ICC_INTERNET_CLASSES)

    ShowDIALOG1 %HWND_DESKTOP
    ShowDIALOG2 %HWND_DESKTOP
    ShowDIALOG3 %HWND_DESKTOP
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Menus **
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
'   ** CallBacks **
'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_LABEL1
                CASE %IDC_SYSTREEVIEW32_1
                CASE %IDC_LABEL2
                CASE %IDC_LABEL3
                CASE %IDC_BUTTON1
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        MSGBOX "%IDC_BUTTON1=" + FORMAT$(%IDC_BUTTON1), _
                            %MB_SYSTEMMODAL
                    END IF
                CASE %IDC_BUTTON2
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        MSGBOX "%IDC_BUTTON2=" + FORMAT$(%IDC_BUTTON2), _
                            %MB_SYSTEMMODAL
                    END IF
                CASE %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        MSGBOX "%IDCANCEL=" + FORMAT$(%IDCANCEL), _
                            %MB_SYSTEMMODAL
                    END IF
                CASE %IDC_LINE1
                CASE %IDC_ABOUT
                    MSGBOX "%IDC_ABOUT=" + FORMAT$(%IDC_ABOUT), %MB_SYSTEMMODAL

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG2Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_FRAME1
                CASE %IDC_CHECKBOX1
                CASE %IDC_CHECKBOX2
                CASE %IDC_CHECKBOX3
                CASE %IDC_CHECKBOX4
                CASE %IDC_LABEL4
                CASE %IDC_TEXTBOX1
                CASE %IDC_MSCTLS_UPDOWN32_1
                CASE %IDOK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        MSGBOX "%IDOK=" + FORMAT$(%IDOK), %MB_SYSTEMMODAL
                    END IF
                CASE %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        MSGBOX "%IDCANCEL=" + FORMAT$(%IDCANCEL), _
                            %MB_SYSTEMMODAL
                    END IF

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG3Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_LABEL5
                CASE %IDC_LABEL6
                CASE %IDOK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        MSGBOX "%IDOK=" + FORMAT$(%IDOK), %MB_SYSTEMMODAL
                    END IF

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Sample Code **
'--------------------------------------------------------------------------------
FUNCTION SampleTreeViewInsertItem(BYVAL hTree AS DWORD, BYVAL hParent AS DWORD, _
    sItem AS STRING) AS LONG
    LOCAL tTVInsert   AS TV_INSERTSTRUCT
    LOCAL tTVItem     AS TV_ITEM

    IF hParent THEN
        tTVItem.mask        = %TVIF_CHILDREN OR %TVIF_HANDLE
        tTVItem.hItem       = hParent
        tTVItem.cchildren   = 1
        TreeView_SetItem (hTree, tTVItem)
    END IF

    tTVInsert.hParent                   = hParent
    tTVInsert.Item.Item.mask            = %TVIF_TEXT
    tTVInsert.Item.Item.pszText         = STRPTR(sItem)
    tTVInsert.Item.Item.cchTextMax      = LEN(sItem)

    FUNCTION = TreeView_InsertItem(hTree, tTVInsert)
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION SampleTreeView(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL lCount AS _
    LONG) AS LONG
    LOCAL hRoot   AS DWORD
    LOCAL hParent AS DWORD
    LOCAL i       AS LONG
    LOCAL j       AS LONG
    LOCAL k       AS LONG
    LOCAL hCtl    AS DWORD

    CONTROL HANDLE hDlg, lID TO hCtl

    FOR i = 1 TO lCount
        hRoot = SampleTreeViewInsertItem(hCtl, %NULL, "Root" + FORMAT$(i))
        FOR j = 1 TO lCount
            hParent = SampleTreeViewInsertItem(hCtl, hRoot, "Item" + FORMAT$(j))
            FOR k = 1 TO lCount
                CALL SampleTreeViewInsertItem(hCtl, hParent, "SubItem" + _
                    FORMAT$(j) + "." + FORMAT$(k))
            NEXT k
        NEXT j
    NEXT i
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG1->%IDR_MENU1->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Interface Explorer", 104, 70, 300, 212, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_CLIPSIBLINGS OR _
        %WS_CLIPCHILDREN OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT OR _
        %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    DIALOG  SET ICON    hDlg, "#" + FORMAT$(%IDR_IMGFILE1)
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

    SampleTreeView hDlg, %IDC_SYSTREEVIEW32_1, 3

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG2->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Interface Explorer Options", 174, 132, 161, 86, %WS_POPUP OR %WS_BORDER _
        OR %WS_DLGFRAME OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    DIALOG  SET ICON      hDlg, "#" + FORMAT$(%IDR_IMGFILE1)
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
FUNCTION ShowDIALOG3(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG3->->
    LOCAL hDlg   AS DWORD
    LOCAL hFont1 AS DWORD

    DIALOG NEW hParent, "About Interface Explorer", 184, 140, 140, 70, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR _
        %DS_MODALFRAME OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    DIALOG  SET ICON    hDlg, "#" + FORMAT$(%IDR_IMGFILE1)
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

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG3Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG3
    DeleteObject hFont1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

