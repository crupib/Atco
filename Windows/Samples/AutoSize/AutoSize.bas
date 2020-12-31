#PBFORMS CREATED V1.51
'==============================================================================
'
'  AutoSize.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Auto-size a control to dialog on resize.
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
%IDC_TEXTBOX1 = 1001
%IDD_DIALOG1  =  101
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
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
    LOCAL x, y, w, h AS LONG

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
                CASE %IDC_TEXTBOX1

            END SELECT

        CASE %WM_SIZE  ' is sent on resize
            IF CBWPARAM <> %SIZE_MINIMIZED THEN  ' avoid minimized state
                ' grab TextBox location
                CONTROL GET LOC CBHNDL, %IDC_TEXTBOX1 TO x, y

                w = LO(WORD, CBLPARAM)  ' dialog client area's width in pixels
                h = HI(WORD, CBLPARAM)  ' dialog client area's height in pixels
                DIALOG PIXELS CBHNDL, w, h TO UNITS w, h  ' convert to dialog units
                h = h - y  ' remove TextBox top location from calculated height
                ' (TextBox top location was set to 20 Dlg Units, to make room
                '  for a ToolBar or some buttons, whatever..)
                CONTROL SET SIZE CBHNDL, %IDC_TEXTBOX1, w, h  ' auto-size..
            END IF

    END SELECT
END FUNCTION
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "AutoSize", 109, 98, 201, 121, %WS_OVERLAPPED OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_MAXIMIZEBOX OR _
        %WS_CLIPSIBLINGS OR %WS_CLIPCHILDREN OR %WS_VISIBLE OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
        %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX1, "How to auto-size a control to dialog size.", 0, _
        20, 145, 92, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR _
        %ES_LEFT OR %ES_MULTILINE OR %ES_AUTOHSCROLL OR %ES_WANTRETURN, %WS_EX_CLIENTEDGE OR _
        %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------------------------
