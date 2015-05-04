#COMPILE EXE
#DIM ALL
%IDC_EB_XSTART = 111
%IDC_LABEL1 = 1112
GLOBAL hDlg, hDlg1 AS DWORD, w, h AS LONG
FUNCTION PBMAIN () AS LONG
    LOCAL  x      AS LONG
    LOCAL TXT AS STRING
    DIALOG NEW hdlg1, " MCU 2015 Setup", 0, 0, 500, 300, %WS_OVERLAPPEDWINDOW, TO hDlg1

    TXT$ = "X Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XSTART, "", 100, 10, 80,    12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL1, TXT$,    10, 10, 50, 20
    DIALOG SHOW MODELESS hDlg1, CALL DlgProcSetup
    DIALOG ENABLE hDlg1
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg1 TO x, x
          DIALOG DOEVENTS  0
    LOOP WHILE x&
    DIALOG SHOW STATE hDlg, %SW_SHOWNORMAL
END FUNCTION
CALLBACK FUNCTION EditControlCallback()
    LOCAL TXT AS STRING
    LOCAL InkeyVar AS STRING
    IF CB.CTLMSG = %EN_CHANGE THEN
       SELECT CASE CB.CTL
    'X START
            CASE %IDC_EB_XSTART
                CONTROL GET TEXT hDlg1, %IDC_EB_XSTART TO TXT$
       END SELECT
    END IF
END FUNCTION
CALLBACK FUNCTION DlgProcSetup () AS LONG
 SELECT CASE AS LONG CB.MSG
    CASE %WM_INITDIALOG
      ' Create the Agent Control Object
    CASE %WM_KEYDOWN
        MSGBOX "Keydown"
  END SELECT
END FUNCTION


'__________________
