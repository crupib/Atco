#PBFORMS CREATED V1.51
'==============================================================================
'
'  PopupDlg.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Parent and child popup dialog.
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#PBFORMS END INCLUDES
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDCANCEL    =   2
%IDC_LABEL1  =   3
%IDC_LABEL2  =   4
%IDD_DIALOG1 = 101
%IDD_DIALOG2 = 102
%IDOK        =   1
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG2Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'--------------------------------------------------------------------------------------------------
FUNCTION PBMAIN()
    ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** CallBacks **
'--------------------------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()

    SELECT CASE AS LONG CBMSG
        CASE %WM_INITDIALOG
            ' Initialization handler

        CASE %WM_NCACTIVATE
            STATIC hWndSaveFocus AS DWORD
            IF ISFALSE CBWPARAM THEN
                ' Save control focus
                hWndSaveFocus = GetFocus()
            ELSEIF hWndSaveFocus THEN
                ' Restore control focus
                SetFocus(hWndSaveFocus)
                hWndSaveFocus = 0
            END IF

        CASE %WM_COMMAND
            ' Process control notifications
            SELECT CASE AS LONG CBCTL
                CASE %IDOK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        ShowDIALOG2 CBHNDL
                    END IF

                CASE %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 0
                    END IF

                CASE %IDC_LABEL1

            END SELECT
    END SELECT
END FUNCTION
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG2Proc()

    SELECT CASE AS LONG CBMSG
        CASE %WM_INITDIALOG
            ' Initialization handler

        CASE %WM_NCACTIVATE
            STATIC hWndSaveFocus AS DWORD
            IF ISFALSE CBWPARAM THEN
                ' Save control focus
                hWndSaveFocus = GetFocus()
            ELSEIF hWndSaveFocus THEN
                ' Restore control focus
                SetFocus(hWndSaveFocus)
                hWndSaveFocus = 0
            END IF

        CASE %WM_COMMAND
            ' Process control notifications
            SELECT CASE AS LONG CBCTL
                CASE %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 0
                    END IF

                CASE %IDC_LABEL2

            END SELECT
    END SELECT
END FUNCTION
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG, sTxt AS STRING

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Main dialog", 86, 64, 201, 115, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME _
        OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD BUTTON, hDlg, %IDOK, "Dialog 2", 90, 95, 50, 15
    DIALOG  SEND        hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON, hDlg, %IDCANCEL, "E&xit", 145, 95, 50, 15
    CONTROL ADD LABEL,  hDlg, %IDC_LABEL1, "Info text comes here", 5, 5, 190, 85, %WS_CHILD OR _
        %WS_VISIBLE OR %SS_LEFT, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR %WS_EX_LTRREADING
    CONTROL SET COLOR   hDlg, %IDC_LABEL1, -1, RGB(255, 255, 219)
#PBFORMS END DIALOG

    sTxt = "An exampe of how to create a main + a popup dialog. " + $CRLF + $CRLF + _
           "Button id's has been changed to %IDOK and %IDCANCEL in the properties " + _
           "dialog, and the code was later changed in the PBWin IDE, so a call to " + _
           "ShowDIALOG2 was moved from PBMAIN to be triggered by the ""Dialog 2"" button " + _
           "in Function ShowDIALOG1Proc. This text was added in ShowDIALOG1." + _
           $CRLF + $CRLF + _
           "Click on ""Dialog 2"" to see the popup dialog."

    CONTROL SET TEXT hDlg, %IDC_LABEL1, sTxt

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG2->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Popup dialog", 89, 67, 141, 70, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME _
        OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD BUTTON, hDlg, %IDCANCEL, "Ok", 45, 50, 50, 15
    CONTROL ADD LABEL,  hDlg, %IDC_LABEL2, "PBForms created popup dialog.", 5, 5, 130, 40, _
        %WS_CHILD OR %WS_VISIBLE OR %SS_CENTER, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING
    CONTROL SET COLOR   hDlg, %IDC_LABEL2, -1, RGB(176, 215, 234)
#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG2Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG2
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------------------------
