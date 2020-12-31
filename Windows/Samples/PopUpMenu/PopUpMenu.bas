#PBFORMS CREATED V1.51
'==============================================================================
'
'  PopUpMenu.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2002-2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  How to dynamically build and show a popup menu on right-click.
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES 
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#PBFORMS END INCLUDES
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS 
%IDD_DIALOG1           =  101
%IDD_DIALOG2           =  103
%IDM_EDIT_COPY         = 1007
%IDM_EDIT_CUT          = 1006
%IDM_EDIT_PASTE        = 1008
%IDM_FILE_EXIT         = 1005
%IDM_FILE_NEW          = 1001
%IDM_FILE_OPEN         = 1002
%IDM_FILE_SAVE         = 1003
%IDM_FILE_SAVEAS       = 1004
%IDM_HELP_HELPCONTENTS = 1009
%IDM_POPUP_CLEAR       = 1012
%IDM_POPUP_INSERT      = 1011
%IDM_POPUP_PROPERTIES  = 1010
%IDR_ACCELERATOR1      =  105
%IDR_MENU1             =  102
%IDR_MENU2             =  104
%OPT_EDIT              = 1014
%OPT_FILE              = 1013
%OPT_OTHER             = 1015
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE FUNCTION AttachMENU1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE FUNCTION AttachMENU2(BYVAL hDlg AS DWORD) AS DWORD
DECLARE FUNCTION ASSIGNACCEL(tAccel AS ACCELAPI, BYVAL wKey AS WORD, BYVAL wCmd _
    AS WORD, BYVAL byFVirt AS BYTE) AS LONG
DECLARE FUNCTION AttachACCELERATOR1(BYVAL hDlg AS DWORD) AS DWORD
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE CALLBACK FUNCTION ShowDIALOG2Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
DECLARE FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION PBMAIN()
    ShowDIALOG1 %HWND_DESKTOP
    'ShowDIALOG2 %HWND_DESKTOP
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
        MENU ADD STRING, hPopUp1, "&New", %IDM_FILE_NEW, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Open...", %IDM_FILE_OPEN, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "-", 0, 0
        MENU ADD STRING, hPopUp1, "&Save", %IDM_FILE_SAVE, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Save &As...", %IDM_FILE_SAVEAS, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "-", 0, 0
        MENU ADD STRING, hPopUp1, "E&xit", %IDM_FILE_EXIT, %MF_ENABLED
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "&Edit", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "Cu&t", %IDM_EDIT_CUT, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Copy", %IDM_EDIT_COPY, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Paste", %IDM_EDIT_PASTE, %MF_ENABLED
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "&Help", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Help Contents..." + $TAB + "F1", %IDM_HELP_HELPCONTENTS, _
            %MF_ENABLED

    MENU ATTACH hMenu, hDlg
#PBFORMS END MENU
    FUNCTION = hMenu
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION AttachMENU2(BYVAL hDlg AS DWORD) AS DWORD
#PBFORMS BEGIN MENU %IDR_MENU2->%IDD_DIALOG2
    LOCAL hMenu   AS DWORD
    LOCAL hPopUp1 AS DWORD

    MENU NEW BAR TO hMenu
    MENU NEW POPUP TO hPopUp1
    MENU ADD POPUP, hMenu, "Popup", hPopUp1, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Properties...", %IDM_POPUP_PROPERTIES, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Insert...", %IDM_POPUP_INSERT, %MF_ENABLED
        MENU ADD STRING, hPopUp1, "&Clear", %IDM_POPUP_CLEAR, %MF_ENABLED

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
#PBFORMS BEGIN ACCEL %IDR_ACCELERATOR1->%IDD_DIALOG1
    LOCAL hAccel   AS DWORD
    LOCAL tAccel() AS ACCELAPI
    DIM   tAccel(1 TO 1) AS ACCELAPI

    ASSIGNACCEL tAccel(1), %VK_F1, %IDM_HELP_HELPCONTENTS, %FVIRTKEY OR %FNOINVERT

    ACCEL ATTACH hDlg, tAccel() TO hAccel
#PBFORMS END ACCEL
    FUNCTION = hAccel
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** CallBacks **
'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
    LOCAL lTemp     AS LONG
    LOCAL lMenuPos  AS LONG
    LOCAL hPopUp1   AS DWORD
    LOCAL pt        AS POINTAPI

    SELECT CASE CBMSG
        CASE %WM_CONTEXTMENU
            'Determine which menu to display.
            CONTROL GET CHECK CBHNDL, %OPT_FILE TO lTemp
            IF lTemp THEN
                lMenuPos = 0
            END IF
            CONTROL GET CHECK CBHNDL, %OPT_EDIT TO lTemp
            IF lTemp THEN
                lMenuPos = 1
            END IF
            CONTROL GET CHECK CBHNDL, %OPT_OTHER TO lTemp
            IF lTemp THEN
                lMenuPos = 2
            END IF

            IF lMenuPos < 2 THEN
                hPopUp1 = GetSubMenu(GetMenu(CBHNDL), lMenuPos)
            ELSE
                MENU NEW POPUP TO hPopUp1
                MENU ADD STRING, hPopUp1, "&Properties...", %IDM_POPUP_PROPERTIES, _
                    %MF_ENABLED
                MENU ADD STRING, hPopUp1, "&Insert...", %IDM_POPUP_INSERT, %MF_ENABLED
                MENU ADD STRING, hPopUp1, "&Clear", %IDM_POPUP_CLEAR, %MF_ENABLED
            END IF

            'Get position to show menu.
            GetCursorPos pt

            'Show menu.
            TrackPopupMenu _
                hPopUp1, %TPM_LEFTALIGN OR %TPM_LEFTBUTTON, _
                pt.x, pt.y, 0, CBHNDL, BYVAL %NULL

            IF lMenuPos = 2 THEN
                DestroyMenu hPopUp1
            END IF

        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %OPT_FILE
                CASE %OPT_EDIT
                CASE %OPT_OTHER
                CASE %IDM_FILE_NEW
                    MSGBOX "%IDM_FILE_NEW=" + FORMAT$(%IDM_FILE_NEW), _
                        %MB_SYSTEMMODAL
                CASE %IDM_FILE_OPEN
                    MSGBOX "%IDM_FILE_OPEN=" + FORMAT$(%IDM_FILE_OPEN), _
                        %MB_SYSTEMMODAL
                CASE %IDM_FILE_SAVE
                    MSGBOX "%IDM_FILE_SAVE=" + FORMAT$(%IDM_FILE_SAVE), _
                        %MB_SYSTEMMODAL
                CASE %IDM_FILE_SAVEAS
                    MSGBOX "%IDM_FILE_SAVEAS=" + FORMAT$(%IDM_FILE_SAVEAS), _
                        %MB_SYSTEMMODAL
                CASE %IDM_FILE_EXIT
                    MSGBOX "%IDM_FILE_EXIT=" + FORMAT$(%IDM_FILE_EXIT), _
                        %MB_SYSTEMMODAL
                CASE %IDM_EDIT_CUT
                    MSGBOX "%IDM_EDIT_CUT=" + FORMAT$(%IDM_EDIT_CUT), _
                        %MB_SYSTEMMODAL
                CASE %IDM_EDIT_COPY
                    MSGBOX "%IDM_EDIT_COPY=" + FORMAT$(%IDM_EDIT_COPY), _
                        %MB_SYSTEMMODAL
                CASE %IDM_EDIT_PASTE
                    MSGBOX "%IDM_EDIT_PASTE=" + FORMAT$(%IDM_EDIT_PASTE), _
                        %MB_SYSTEMMODAL
                CASE %IDM_HELP_HELPCONTENTS
                    MSGBOX "%IDM_HELP_HELPCONTENTS=" + _
                        FORMAT$(%IDM_HELP_HELPCONTENTS), %MB_SYSTEMMODAL
                CASE %IDM_POPUP_PROPERTIES
                    MSGBOX "%IDM_POPUP_PROPERTIES=" + _
                        FORMAT$(%IDM_POPUP_PROPERTIES), %MB_SYSTEMMODAL
                CASE %IDM_POPUP_INSERT
                    MSGBOX "%IDM_POPUP_INSERT=" + FORMAT$(%IDM_POPUP_INSERT), _
                        %MB_SYSTEMMODAL
                CASE %IDM_POPUP_CLEAR
                    MSGBOX "%IDM_POPUP_CLEAR=" + FORMAT$(%IDM_POPUP_CLEAR), _
                        %MB_SYSTEMMODAL

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG2Proc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %IDM_POPUP_PROPERTIES
                    MSGBOX "%IDM_POPUP_PROPERTIES=" + _
                        FORMAT$(%IDM_POPUP_PROPERTIES), %MB_SYSTEMMODAL
                CASE %IDM_POPUP_INSERT
                    MSGBOX "%IDM_POPUP_INSERT=" + FORMAT$(%IDM_POPUP_INSERT), _
                        %MB_SYSTEMMODAL
                CASE %IDM_POPUP_CLEAR
                    MSGBOX "%IDM_POPUP_CLEAR=" + FORMAT$(%IDM_POPUP_CLEAR), _
                        %MB_SYSTEMMODAL

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG1->%IDR_MENU1->%IDR_ACCELERATOR1
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Pop-up Menu Example", 95, 71, 195, 133, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT OR %DS_MODALFRAME OR %DS_CENTER, %WS_EX_WINDOWEDGE OR _
        %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO _
        hDlg
    CONTROL ADD FRAME,  hDlg, -1, "Pop-up Menu", 5, 5, 55, 45
    CONTROL ADD OPTION, hDlg, %OPT_FILE, "File", 10, 15, 40, 10
    CONTROL ADD OPTION, hDlg, %OPT_EDIT, "Edit", 10, 25, 40, 10
    CONTROL ADD OPTION, hDlg, %OPT_OTHER, "Other", 10, 35, 40, 10

    AttachMENU1 hDlg

    AttachACCELERATOR1 hDlg
#PBFORMS END DIALOG

    CONTROL SET CHECK hDlg, %OPT_FILE, 1

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG2(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG2->%IDR_MENU2->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Dialog2", 90, 66, 195, 133, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR _
        %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_3DLOOK OR %DS_NOFAILCREATE OR _
        %DS_SETFONT OR %DS_MODALFRAME OR %DS_CENTER, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg

    AttachMENU2 hDlg
#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG2Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG2
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

