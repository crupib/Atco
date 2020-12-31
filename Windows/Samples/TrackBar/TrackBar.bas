#PBFORMS CREATED V1.51
'==============================================================================
'
'  TrackBar.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Simple TrackBar demo
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
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS 
%IDC_MSCTLS_TRACKBAR32_1 = 1001
%IDC_TEXTBOX1            = 1002
%IDD_DIALOG1             =  101
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------

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
  LOCAL tbPos AS LONG, txt AS STRING 'we need a few variables
 
    SELECT CASE CBMSG
        CASE %WM_HSCROLL 'is sent to parent dialog on trackbar scrollpos change
           IF CBLPARAM = GetDlgItem(CBHNDL, %IDC_MSCTLS_TRACKBAR32_1) THEN 'if our trackbar
               CONTROL SEND CBHNDL, %IDC_MSCTLS_TRACKBAR32_1, _
                            %TBM_GETPOS, 0, 0 TO tbPos                'grab trackbar's pos
               CONTROL SET TEXT CBHNDL, %IDC_TEXTBOX1, FORMAT$(tbPos) 'and show it in textbox
           END IF
 
        CASE %WM_COMMAND 'message from a control
            SELECT CASE CBCTL      'what control?
                CASE %IDC_TEXTBOX1 'from our textbox
                   IF CBCTLMSG = %EN_CHANGE THEN 'what message? - look for text change in textbox
                      CONTROL GET TEXT CBHNDL, %IDC_TEXTBOX1 TO txt 'grab text
                      txt = TRIM$(txt)    'trim away eventual space characters..
                      IF LEN(txt) THEN    'if it has length
                         tbPos = VAL(txt) 'convert to numeric value
                         CONTROL SEND CBHNDL, %IDC_MSCTLS_TRACKBAR32_1, _
                                      %TBM_SETPOS, %TRUE, tbPos 'set trackbar's pos
                      END IF
                   END IF
 
            END SELECT
    END SELECT
 
END FUNCTION
'--------------------------------------------------------------------------------

'--------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG
#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "TrackBar demo", 50, 50, 314, 66, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME _
        OR %WS_THICKFRAME OR %WS_SYSMENU OR %WS_MINIMIZEBOX OR %WS_VISIBLE OR %DS_CENTER OR _
        %DS_MODALFRAME OR %DS_SETFOREGROUND OR %DS_3DLOOK OR %DS_NOFAILCREATE OR %DS_SETFONT, _
        %WS_EX_WINDOWEDGE OR %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR %WS_EX_LTRREADING OR _
        %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD "msctls_trackbar32", hDlg, %IDC_MSCTLS_TRACKBAR32_1, "msctls_trackbar321", 7, 8, _
        300, 25, %WS_CHILD OR %WS_VISIBLE OR %WS_TABSTOP OR %TBS_HORZ OR %TBS_BOTH OR _
        %TBS_AUTOTICKS OR %TBS_ENABLESELRANGE OR %TBS_FIXEDLENGTH OR %TBS_TOOLTIPS, _
        %WS_EX_STATICEDGE
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX1, "", 6, 45, 75, 13, %WS_CHILD OR %WS_VISIBLE OR _
        %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
#PBFORMS END DIALOG

    CONTROL SEND hdlg, %IDC_MSCTLS_TRACKBAR32_1, %TBM_SETRANGEMIN , %TRUE, 0
    CONTROL SEND hdlg, %IDC_MSCTLS_TRACKBAR32_1, %TBM_SETRANGEMAX , %TRUE, 10

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION
'--------------------------------------------------------------------------------  

