#PBFORMS CREATED V1.51
'==============================================================================
'
'  TabControl.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2002-2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Build a tab control with child dialog pages and respond to page change.
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "TabControl.pbr"
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
%IDC_IMAGEX1           = 1002
%IDC_SYSTABCONTROL32_1 = 1001
%IDC_TEXTBOX1          = 1011
%IDC_TEXTBOX2          = 1012
%IDC_TEXTBOX3          = 1013
%IDC_TEXTBOX4          = 1014
%IDC_TEXTBOX5          = 1015
%IDD_DIALOG1           =  101
%IDD_DIALOG2           =  102
%IDD_DIALOG3           =  103
%IDD_DIALOG4           =  104
%IDD_DIALOG5           =  105
%IDD_DIALOG6           =  106
%IDOK                  =    1
%IDR_IMGFILE2          =  107
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG2Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG3Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG4Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG5Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG6Proc()
DECLARE FUNCTION SampleTabCtrl(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL _
    lCount AS LONG) AS LONG
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG3(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG4(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG5(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG6(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------

GLOBAL gPage() AS DWORD

'--------------------------------------------------------------------------------
FUNCTION PBMAIN()

    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR %ICC_INTERNET_CLASSES)

    ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** CallBacks **
'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()

    SELECT CASE CBMSG
        CASE %WM_NOTIFY
            LOCAL pNMHDR AS NMHDR PTR
            LOCAL Result AS LONG
            pNMHDR = CBLPARAM

            SELECT CASE @pNMHDR.idFrom
                CASE %IDC_SYSTABCONTROL32_1
                    ' Get the current tab page number (zero based)
                    CONTROL SEND CBHNDL, %IDC_SYSTABCONTROL32_1, %TCM_GETCURSEL, 0, 0 TO Result

                    SELECT CASE @pNMHDR.code
                        CASE %TCN_SELCHANGING
                            DIALOG SHOW STATE gPage(Result), %SW_HIDE
                        CASE %TCN_SELCHANGE
                            DIALOG SHOW STATE gPage(Result), %SW_SHOW
                    END SELECT
            END SELECT

        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_IMAGEX1
                CASE %IDC_SYSTABCONTROL32_1
                CASE %IDOK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 1
                    END IF
                CASE %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 0
                    END IF

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG2Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_TEXTBOX1

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG3Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_TEXTBOX2

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG4Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_TEXTBOX3

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG5Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_TEXTBOX4

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG6Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_TEXTBOX5

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Sample Code **
'--------------------------------------------------------------------------------
FUNCTION SampleTabCtrl(BYVAL hDlg AS DWORD, BYVAL lID AS LONG, BYVAL lCount AS _
    LONG) AS LONG
    LOCAL tTC_Item    AS TC_ITEM
    LOCAL szBuf       AS ASCIIZ * 32
    LOCAL i           AS LONG
    LOCAL hCtl        AS DWORD

    CONTROL HANDLE hDlg, lID TO hCtl

    tTC_Item.Mask       = %TCIF_TEXT
    tTC_Item.iImage     = -1
    tTC_Item.pszText    = VARPTR(szBuf)

    FOR i = 0 TO lCount - 1
        szBuf = "Tab " + FORMAT$(i)
        TabCtrl_InsertItem (hCtl, i, tTC_Item)
    NEXT i
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "PBForms Tab Control Example", 88, 64, 247, 172, %WS_POPUP OR %WS_BORDER _
        OR %WS_DLGFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_VISIBLE OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    DIALOG  SET ICON    hDlg, "#" + FORMAT$(%IDR_IMGFILE2)
    CONTROL ADD IMAGEX, hDlg, %IDC_IMAGEX1, "#" + FORMAT$(%IDR_IMGFILE2), 6, 148, 20, 20, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_ICON
    CONTROL ADD "SysTabControl32", hDlg, %IDC_SYSTABCONTROL32_1, "SysTabControl321", 6, 10, 234, _
        135, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %TCS_SINGLELINE OR %TCS_RIGHTJUSTIFY, _
        %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL ADD BUTTON, hDlg, %IDOK, "OK", 135, 151, 50, 15
    DIALOG  SEND        hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON, hDlg, %IDCANCEL, "Cancel", 190, 151, 50, 15
#PBFORMS END DIALOG

    SampleTabCtrl hDlg, %IDC_SYSTABCONTROL32_1, 5

    DIM gPage(0:5) AS GLOBAL DWORD
    gPage(0) = ShowDIALOG2(hDlg)
    gPage(1) = ShowDIALOG3(hDlg)
    gPage(2) = ShowDIALOG4(hDlg)
    gPage(3) = ShowDIALOG5(hDlg)
    gPage(4) = ShowDIALOG6(hDlg)

    LOCAL z AS LONG
    FOR z = 0 TO 4
        DIALOG SET LOC gPage(z), 6 + 1, 10 + 14
        DIALOG SHOW STATE gPage(z), IIF&(z = 0, %SW_SHOW, %SW_HIDE)
    NEXT x

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG2->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Page 1", 115, 122, 230, 118, %WS_CHILD OR %WS_VISIBLE OR %DS_CONTROL OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX1, "TextBox1", 5, 5, 220, 110, %WS_CHILD OR _
        %WS_VISIBLE OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE OR _
        %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
        OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

    DIALOG SHOW MODELESS hDlg, CALL ShowDIALOG2Proc

    FUNCTION = hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG3(BYVAL hParent AS DWORD) AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG3->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Page 2", 115, 122, 230, 118, %WS_CHILD OR %WS_VISIBLE OR %DS_CONTROL OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX2, "TextBox2", 5, 5, 110, 110, %WS_CHILD OR _
        %WS_VISIBLE OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE OR _
        %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
        OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

    DIALOG SHOW MODELESS hDlg, CALL ShowDIALOG3Proc

    FUNCTION = hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG4(BYVAL hParent AS DWORD) AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG4->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Page 3", 115, 122, 230, 118, %WS_CHILD OR %WS_VISIBLE OR %DS_CONTROL OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX3, "TextBox3", 115, 5, 110, 110, %WS_CHILD OR _
        %WS_VISIBLE OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE OR _
        %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
        OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

    DIALOG SHOW MODELESS hDlg, CALL ShowDIALOG4Proc

    FUNCTION = hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG5(BYVAL hParent AS DWORD) AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG5->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Page 4", 115, 122, 230, 118, %WS_CHILD OR %WS_VISIBLE OR %DS_CONTROL OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX4, "TextBox4", 5, 5, 220, 55, %WS_CHILD OR %WS_VISIBLE _
        OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE OR _
        %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
        OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

    DIALOG SHOW MODELESS hDlg, CALL ShowDIALOG5Proc

    FUNCTION = hDlg
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG6(BYVAL hParent AS DWORD) AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG6->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Page 5", 115, 122, 230, 118, %WS_CHILD OR %WS_VISIBLE OR %DS_CONTROL OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX5, "TextBox5", 5, 60, 220, 55, %WS_CHILD OR _
        %WS_VISIBLE OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR %ES_LEFT OR %ES_MULTILINE OR _
        %ES_AUTOHSCROLL OR %ES_AUTOVSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT _
        OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

    DIALOG SHOW MODELESS hDlg, CALL ShowDIALOG6Proc

    FUNCTION = hDlg
END FUNCTION
'--------------------------------------------------------------------------------
