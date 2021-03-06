#COMPILE EXE
#DIM ALL
#INCLUDE "Win32API.inc"
%IDC_LABEL_XPOSAJOG = 314
%IDC_LABEL_YPOSAJOG = 315
%IDC_LABEL_APOSAJOG = 316
%IDC_LABEL32 = 4016
%IDC_LABEL33 = 4017
%IDC_LABEL34 = 4018
%IDC_LABEL35 = 4019
%IDC_LABEL36 = 4020
GLOBAL hdlg, w, h AS LONG
GLOBAL gOldEditClassProc AS LONG
FUNCTION PBMAIN () AS LONG
    LOCAL TXT AS STRING
    LOCAL  x, mycount      AS LONG
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, hdlg, "MCU 2015 Auto Jog", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg
    DIALOG SET USER hDlg, 1, hdlg


    TXT$ = "* Check Motors On *"
    CONTROL ADD LABEL, hDlg, %IDC_LABEL32, TXT$,    550, 20, 150, 20
    TXT$ = "*  Press Any Key  *"
    CONTROL ADD LABEL, hDlg, %IDC_LABEL33, TXT$,    550, 50, 150, 20
    TXT$ = "X Pos: "
    CONTROL ADD LABEL, hDlg, %IDC_LABEL34, TXT$,    550, 100, 150, 20
    TXT$ = "Y Pos: "
    CONTROL ADD LABEL, hDlg, %IDC_LABEL35, TXT$,    550, 150, 150, 20
    TXT$ = "A Pos: "
    CONTROL ADD LABEL, hDlg, %IDC_LABEL36, TXT$,    550, 200, 150, 20
    TXT$ = ""
    CONTROL ADD LABEL, hDlg, %IDC_LABEL_XPOSAJOG, "0", 850, 100, 80, 20 ,%WS_TABSTOP
    CONTROL ADD LABEL, hDlg, %IDC_LABEL_YPOSAJOG, "0", 850, 150, 80, 20
    CONTROL ADD LABEL, hDlg, %IDC_LABEL_APOSAJOG, "0", 850, 200, 80, 20,
    DIALOG SHOW MODELESS hDlg, CALL DlgProcAJog
    DIALOG ENABLE hDlg
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg TO x, x
          DIALOG DOEVENTS TO mycount
    LOOP WHILE x&
END FUNCTION
                  CALLBACK FUNCTION DlgProcAJog () AS LONG
LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
           STATIC  hEdit9 AS LONG
           CONTROL HANDLE CBHNDL, %IDC_LABEL_XPOSAJOG TO hEdit9
           gOldEditClassProc = SetWindowLong(hEdit9, %GWL_WNDPROC, CODEPTR(EditASubClassProc))
      CASE %WM_LBUTTONDOWN

          CONTROL SET TEXT hDlg, %IDC_LABEL_XPOSAJOG, "1"
          CONTROL SET TEXT hDlg, %IDC_LABEL_YPOSAJOG, "1"
          CONTROL SET TEXT hDlg, %IDC_LABEL_APOSAJOG, "1"
      CASE %WM_RBUTTONDOWN

          CONTROL SET TEXT hDlg, %IDC_LABEL_XPOSAJOG, "2"
          CONTROL SET TEXT hDlg, %IDC_LABEL_YPOSAJOG, "2"
          CONTROL SET TEXT hDlg, %IDC_LABEL_APOSAJOG, "2"
      CASE  %WM_MBUTTONDOWN

          CONTROL SET TEXT hDlg, %IDC_LABEL_XPOSAJOG, "3"
          CONTROL SET TEXT hDlg, %IDC_LABEL_YPOSAJOG, "3"
          CONTROL SET TEXT hDlg, %IDC_LABEL_APOSAJOG, "3"
      CASE %WM_MOUSEWHEEL

          CONTROL SET TEXT hDlg, %IDC_LABEL_XPOSAJOG, "4"
          CONTROL SET TEXT hDlg, %IDC_LABEL_YPOSAJOG,  "4"
          CONTROL SET TEXT hDlg, %IDC_LABEL_APOSAJOG,  "4"
      CASE %WM_KEYDOWN
          MSGBOX "key"
      CASE %WM_DESTROY
         'Important! Remove the subclassing
          SetWindowLong hEdit9, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION
FUNCTION EditASubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP

         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_LABEL_XPOSAJOG  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
