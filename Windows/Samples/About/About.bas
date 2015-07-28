#PBFORMS CREATED V1.51
'==============================================================================
'
'  About.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2002-2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  An About.. -dialog with system information.
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES 
#RESOURCE "About.pbr"
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#INCLUDE "PBForms.INC"
#PBFORMS END INCLUDES
#INCLUDE "PBForms.INC"
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS 
%BTN_OK          = 1002
%BTN_SysInfo     = 1003
%FRM_About       =  101
%ICO_Image1      =  102
%IMG_IMAGEX1     = 1009
%LBL_Description = 1005
%LBL_Disclaimer  = 1008
%LBL_Title       = 1006
%LBL_Version     = 1007
%LIN_Line1       = 1004
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowfrmAboutProc()
DECLARE FUNCTION ShowfrmAbout(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------

DECLARE FUNCTION zGetDiskFreeSpaceEx (lpPath AS ASCIIZ, lpFreeToCaller AS QUAD, lpTotalBytes AS QUAD, lpTotalFreeBytes AS QUAD) AS LONG

'--------------------------------------------------------------------------------
FUNCTION PBMAIN()
    ShowfrmAbout %HWND_DESKTOP
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** CallBacks **
'--------------------------------------------------------------------------------
CALLBACK FUNCTION ShowfrmAboutProc()

    SELECT CASE CBMSG
        CASE %WM_COMMAND
            SELECT CASE CBCTL
                CASE %BTN_OK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 1
                    END IF

                CASE %BTN_SysInfo
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        CALL SysInfo(CBHNDL)
                    END IF

                CASE %LBL_Description
                CASE %LBL_Disclaimer
                CASE %LBL_Title
                CASE %LBL_Version
                CASE %LIN_Line1

            END SELECT
    END SELECT

END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowfrmAbout(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG

#PBFORMS BEGIN DIALOG %FRM_About->->
    LOCAL hDlg   AS DWORD
    LOCAL hFont1 AS DWORD

    DIALOG NEW hParent, "About My Program", 143, 97, 255, 146, %WS_POPUP OR %WS_BORDER OR _
        %WS_DLGFRAME OR %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_MODALFRAME OR _
        %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT _
        OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD BUTTON, hDlg, %BTN_OK, "OK", 189, 108, 56, 14
    CONTROL ADD BUTTON, hDlg, %BTN_SysInfo, "&System Info...", 189, 126, 56, 14
    CONTROL ADD LABEL,  hDlg, %LBL_Description, "Application Description", 75, 55, 172, 40
    CONTROL SET COLOR   hDlg, %LBL_Description, %BLACK, -1
    CONTROL ADD LABEL,  hDlg, %LBL_Disclaimer, "Your Copyright Information Goes Here", 11, 108, _
        172, 34
    CONTROL SET COLOR   hDlg, %LBL_Disclaimer, %BLACK, -1
    CONTROL ADD LABEL,  hDlg, %LBL_Title, "Application Title", 75, 9, 172, 20
    CONTROL SET COLOR   hDlg, %LBL_Title, %BLACK, -1
    CONTROL ADD LABEL,  hDlg, %LBL_Version, "Version Information", 75, 31, 172, 19
    CONTROL ADD LINE,   hDlg, %LIN_Line1, "", 0, 100, 250, 1
    CONTROL ADD IMAGEX, hDlg, %IMG_IMAGEX1, "#" + FORMAT$(%ICO_Image1), 2, 10, 70, 55, %WS_CHILD _
        OR %WS_VISIBLE OR %WS_TABSTOP OR %SS_ICON

    hFont1 = PBFormsMakeFont("MS Sans Serif", 12, 700, %FALSE, %FALSE, %FALSE, %ANSI_CHARSET)

    CONTROL SEND hDlg, %LBL_Description, %WM_SETFONT, hFont1, 0
    CONTROL SEND hDlg, %LBL_Title, %WM_SETFONT, hFont1, 0
    CONTROL SEND hDlg, %LBL_Version, %WM_SETFONT, hFont1, 0
#PBFORMS END DIALOG

    DIALOG SHOW MODAL hDlg, CALL ShowfrmAboutProc TO lRslt

#PBFORMS BEGIN CLEANUP %FRM_About
    DeleteObject hFont1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
FUNCTION SysInfo(BYVAL hDlg AS DWORD) AS LONG
    LOCAL DriveNum  AS LONG
    LOCAL DiskSpace AS QUAD
    LOCAL Drive     AS STRING
    LOCAL hLIB      AS DWORD
    LOCAL pFunc     AS DWORD
    LOCAL lpFTC     AS QUAD
    LOCAL lpTB      AS QUAD
    LOCAL lpTFB     AS QUAD

    LOCAL RetVal    AS LONG

    LOCAL sMask     AS STRING
    LOCAL CName     AS ASCIIZ * %MAX_PATH
    LOCAL OSInfo    AS OSVERSIONINFO
    LOCAL lpBuffer  AS MEMORYSTATUS
    LOCAL lpBufPtr  AS MEMORYSTATUS PTR

    sMask = "#, "

    ' Find free space on first fixed drive
    FOR DriveNum = 65 TO 90

        IF GetDriveType(CHR$(DriveNum, ":\")) = %DRIVE_FIXED THEN

            hLib  = LoadLibrary("KERNEL32.DLL")
            IF hLib THEN

                ' Attempt to use explicit linking, requires OSR2+
                pFunc = GetProcAddress(hLib, "GetDiskFreeSpaceExA")

                IF pFunc THEN

                    ' Yes, the EX version of the API is present
                    CALL DWORD pFunc USING zGetDiskFreeSpaceEx( _
                        CHR$(DriveNum, ":\"), lpFTC, lpTB, lpTFB)

                    ' Return the smaller of the User-Quota and Disk-Free sizes
                    DiskSpace = MIN(lpFTC, lpTFB)

                ELSE

                    ' Fallback if the API is not present (Win95a)
                    DiskSpace = DISKFREE(CHR$(DriveNum))

                END IF

                ' Clear up
                FreeLibrary hLib

            END IF
            EXIT FOR

        END IF

    NEXT

    ' Failsafe if no drives present
    IF DriveNum > 90 THEN DriveNum = ASC($SPC)

    ' Get Computer Name
    CALL GetComputerName(CName,SIZEOF(CName))

    ' Get OS Version Info
    OSInfo.dwOSVersionInfoSize  = LEN(OSInfo)
    RetVal                      = GetVersionEX(OSInfo)

    ' Get Memory Info
    lpBufPtr = VARPTR(lpBuffer)
    CALL GlobalMemoryStatus(@lpBufPtr)

    ' Display System Info
    MessageBox hDlg, _
        "Date: "                    & $TAB & $TAB & $TAB & DATE$ & $CR & _
        "Time: "                    & $TAB & $TAB & $TAB & TIME$ & $CR & _
        "Computer Name:"            & $TAB & $TAB & CName & $CR & _
        "System Version:"           & $TAB & $TAB & FORMAT$(OSInfo.dwMajorVersion) & "." & FORMAT$(OSInfo.dwMinorVersion) & $CR & _
        "Free Space on Drive "      & CHR$(DriveNum) & $TAB & FORMAT$(DiskSpace, sMask)     & "Bytes" & $CR & _
        "Percent of Memory in Use:" & $TAB & FORMAT$(@lpBufPtr.dwMemoryLoad)                & "%"     & $CR & _
        "Total Physical Memory:"    & $TAB & FORMAT$(@lpBufPtr.dwTotalPhys/1024, sMask)     & "KB"    & $CR & _
        "Free Physical Memory:"     & $TAB & FORMAT$(@lpBufPtr.dwAvailPhys/1024, sMask)     & "KB"    & $CR & _
        "Total Page File Size:   "  & $TAB & FORMAT$(@lpBufPtr.dwTotalPageFile/1024, sMask) & "KB"    & $CR & _
        "Free Page File Size:  "    & $TAB & $TAB & FORMAT$(@lpBufPtr.dwAvailPageFile/1024, sMask) & "KB"    & $CR & _
        "Total Virtual Memory:"     & $TAB & FORMAT$(@lpBufPtr.dwTotalVirtual/1024, sMask)  & "KB"    & $CR & _
        "Free Virtual Memory:  "    & $TAB & FORMAT$(@lpBufPtr.dwAvailVirtual/1024, sMask)  & "KB", _
        "About: System Information", _
        %MB_ICONINFORMATION OR %MB_SYSTEMMODAL

END FUNCTION

