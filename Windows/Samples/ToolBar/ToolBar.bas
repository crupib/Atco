#PBFORMS CREATED V1.51
'==============================================================================
'
'  ToolBar.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2002-2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Build a toolbar control
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
#RESOURCE "ToolBar.pbr"
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#PBFORMS END INCLUDES
#INCLUDE "COMMCTRL.INC"
#INCLUDE "PBForms.INC"
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDCANCEL     =   2
%IDC_TOOLBAR  = 104
%IDD_DIALOG1  = 102
%IDR_IMGFILE1 = 103
%IDR_IMGFILE2 = 104
%IDR_MENU1    = 101
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------
%ToolButtons  = 9
%ID_Btn1      = 1001
%ID_Btn2      = 1002
%ID_Btn3      = 1003
%ID_Btn4      = 1004
%ID_Btn5      = 1005
%ID_Btn6      = 1006
%IDR_IMGFILE2 = 104
'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------
DECLARE FUNCTION SetToolbarButtons(BYVAL hDlg AS DWORD) AS LONG
'--------------------------------------------------------------------------------
FUNCTION PBMAIN()
    PBFormsInitComCtls (%ICC_WIN95_CLASSES)
    ShowDIALOG1 %HWND_DESKTOP
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
        MENU ADD STRING, hPopUp1, "&Close", %IDCANCEL, %MF_ENABLED

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
        CASE %WM_INITDIALOG
            ' Force TB to initially resize before we display the dialog
            DIALOG POST CBHNDL, %WM_SIZE, 0, 0

        CASE %WM_SIZE
            ' Resize the toolbar as the dialog is resized
            CONTROL POST CBHNDL, %IDC_TOOLBAR, CBMSG, 0, 0
            FUNCTION = 1

        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDC_TOOLBAR
                CASE %ID_Btn1
                    MSGBOX "New=" + FORMAT$(%ID_Btn1), %MB_TASKMODAL
                CASE %ID_Btn2
                    MSGBOX "Open=" + FORMAT$(%ID_Btn2), %MB_TASKMODAL
                CASE %ID_Btn3
                    MSGBOX "Save=" + FORMAT$(%ID_Btn3), %MB_TASKMODAL
                CASE %ID_Btn4
                    MSGBOX "Cut=" + FORMAT$(%ID_Btn4), %MB_TASKMODAL
                CASE %ID_Btn5
                    MSGBOX "Copy=" + FORMAT$(%ID_Btn5), %MB_TASKMODAL
                CASE %ID_Btn6
                    MSGBOX "Paste=" + FORMAT$(%ID_Btn6), %MB_TASKMODAL
                CASE %IDCANCEL  ' exit on Esc
                    DIALOG END CBHNDL

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG1->%IDR_MENU1->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Toolbar Example", 90, 66, 250, 142, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_THICKFRAME OR %WS_CAPTION OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR _
        %WS_MAXIMIZEBOX OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT OR _
        %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    DIALOG  SET ICON hDlg, "#" + FORMAT$(%IDR_IMGFILE1)
    DIALOG  SET COLOR hDlg, -1, %WHITE
    CONTROL ADD "ToolbarWindow32", hDlg, %IDC_TOOLBAR, "Toolbar", 0, 0, 249, 25, _
        %WS_CHILD OR %WS_VISIBLE OR %WS_BORDER OR %CCS_TOP OR %TBSTYLE_TOOLTIPS OR _
        %TB_AUTOSIZE, %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR

    AttachMENU1 hDlg
#PBFORMS END DIALOG

    CALL SetToolbarButtons(hDlg)
    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION SetToolbarButtons(BYVAL hDlg AS DWORD) AS LONG
    LOCAL x     AS LONG
    LOCAL a$
    LOCAL Tbb() AS TBBUTTON
    LOCAL Tabm  AS TBADDBITMAP
    DIM Tbb(0 TO %ToolButtons - 1) AS LOCAL TBBUTTON

    ' Init Tbb array.
    FOR x = 0 TO %ToolButtons - 1
        ' Set the initial states for each button
        Tbb(x).iBitmap = 0
        Tbb(x).idCommand = 0
        Tbb(x).fsState = %TBSTATE_ENABLED
        Tbb(x).fsStyle = %TBSTYLE_BUTTON
        Tbb(x).dwData = 0
        Tbb(x).iString = 0
        SELECT CASE AS CONST x
            CASE 0,4,8
                ' Gap creation buttons.
                Tbb(x).fsStyle = %TBSTYLE_SEP
            CASE 1
                Tbb(x).iBitmap = 0
                Tbb(x).idCommand = %ID_Btn1
                Tbb(x).iString = 0
            CASE 2
                Tbb(x).iBitmap = 1
                Tbb(x).idCommand = %ID_Btn2
                Tbb(x).iString = 1
            CASE 3
                Tbb(x).iBitmap = 2
                Tbb(x).idCommand = %ID_Btn3
                Tbb(x).iString = 2
            CASE 5
                Tbb(x).iBitmap = 4
                Tbb(x).idCommand = %ID_Btn4
                Tbb(x).iString = 3
            CASE 6
                Tbb(x).iBitmap = 5
                Tbb(x).idCommand = %ID_Btn5
                Tbb(x).iString = 4
            CASE 7
                Tbb(x).iBitmap = 6
                Tbb(x).idCommand = %ID_Btn6
                Tbb(x).iString = 5
        END SELECT
    NEXT x

    ' Set the individual image size for the TB
    CONTROL SEND hDlg, %IDC_TOOLBAR, %TB_SETBITMAPSIZE, 0, MAKLNG(24,24)

    ' Set the imge list for the TB
    Tabm.hInst = GetModuleHandle(BYVAL %NULL)
    Tabm.nID = %IDR_IMGFILE2
    CONTROL SEND hDlg, %IDC_TOOLBAR, %TB_ADDBITMAP, %ToolButtons, VARPTR(Tabm)

    ' Set the buttons
    CONTROL SEND hDlg, %IDC_TOOLBAR, %TB_BUTTONSTRUCTSIZE, SIZEOF(Tbb(0)), 0
    CONTROL SEND hDlg, %IDC_TOOLBAR, %TB_ADDBUTTONS, %ToolButtons, VARPTR(Tbb(0))

    ' Note: Widest string sets all buttons width. "Paste" is here
    '       made a little wider to make all buttons wider.
    a$ = "New" & $NUL & "Open" & $NUL & "Save" & $NUL & _
         "Cut" & $NUL & "Copy" & $NUL & "  Paste  " & $NUL & $NUL
    CONTROL SEND hDlg, %IDC_TOOLBAR, %TB_ADDSTRING, 0, STRPTR(a$)

END FUNCTION
