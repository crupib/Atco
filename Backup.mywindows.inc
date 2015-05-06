'Windows consts, variables, routines, etc....
%IDC_LABEL1 = 1112
%IDC_LABEL2 = 1113
%IDC_LABEL3 = 1114
%IDC_LABEL4 = 1115
%IDC_LABEL5 = 1116
%IDC_LABEL6 = 1117
%IDC_LABEL7 = 1118
%IDC_LABEL8 = 1119
%IDC_LABEL9 = 1110
%IDC_LABEL10 = 1101
%IDC_LABEL11 = 1102
%IDC_LABEL12 = 1103
%IDC_LABEL13 = 1104
%IDC_LABEL14 = 1105
%IDC_LABEL15 = 1106
%IDC_LABEL16 = 4000
%IDC_LABEL17 = 4001
%IDC_LABEL18 = 4002
%IDC_LABEL19 = 4003
%IDC_LABEL20 = 4004
%IDC_LABEL21 = 4005
%IDC_LABEL22 = 4006
%IDC_LABEL23 = 4007

%IDC_EB_XSTART = 111
%IDC_EB_XEND = 113
%IDC_EB_YSTART = 114
%IDC_EB_YEND = 115
%IDC_EB_XINDEX = 116
%IDC_EB_YINDEX = 117
%IDC_EB_XSPEED = 118
%IDC_EB_YSPEED = 119
%IDC_EB_XPOS = 120
%IDC_EB_YPOS = 121
%IDC_EB_XCTIN = 122
%IDC_EB_YCTIN = 123
%IDC_EB_XPLUSMIN = 124
%IDC_EB_YPLUSMIN = 125
%IDC_EB_INDEX = 126
%IDC_EB_IDXHL = 3000
%IDC_EB_XONOFF = 3001
%IDC_EB_YONOFF = 3002
%IDC_EB_AUTOHD = 3003
%IDC_EB_DUALRAS = 3004
%IDC_EB_OVERLAP = 3005
%IDC_EB_APOS = 3006
%IDC_EB_ACTIN = 3007
%IDC_TextBox   = 123
%IDC_UpDown = 124
%IDC_LABSPIN = 125

%OPT1 = 1001
%OPT2 = 1002
%OPT3 = 1003
%OPT4 = 1004
%OPT5 = 1005
%OPT6 = 1006
%OPT7 = 1007
%OPT8 = 1008
%OPT9 = 1009

%SETUP_BUTTON = 2000
%JOYSTICK_BUTTON = 2010
%AJOG = 2020
%SAVE = 2030
%AUTOSCAN = 2040
%XSPDCTRL = 2050
%MJOG = 2060
%LOAD = 2070
%CALIBRATEENC = 2080

GLOBAL ghMsgHook   AS DWORD
GLOBAL hDlg, hDlg1 AS DWORD, w, h AS LONG
GLOBAL IsSplashActive AS LONG
GLOBAL gOldEditClassProc AS LONG
'***************************************************************************************************************************************
DECLARE SUB ShowSplashDlg(BYVAL nDelay AS LONG, BYVAL sBitmapID AS STRING, _
                          BYVAL IsFile AS LONG, OPTIONAL BYVAL sAppName AS STRING, _
                          OPTIONAL BYVAL nModeless AS LONG)

CALLBACK FUNCTION BTN_SETUP_CALL()
    LOCAL  x      AS LONG
    BUILDSETUPWINDOW()
    DIALOG SHOW MODELESS hDlg1, CALL DlgProcSetup
    DIALOG ENABLE hDlg1
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg1 TO x, x
          DIALOG DOEVENTS  0
    LOOP WHILE x&
    DIALOG SHOW STATE hDlg, %SW_SHOWNORMAL
END FUNCTION

CALLBACK FUNCTION BTN_JOYSTICK_CALL()
    MSGBOX "JoyStick, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_AJOG_CALL()
    MSGBOX "A-Jog, hit OK to continue",, "Title of subroutine 123"
    CALL SetForAuto
'    JogAuto
END FUNCTION
CALLBACK FUNCTION BTN_SAVE_CALL()
    MSGBOX "SAVE, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_AUTOSCAN_CALL()
    MSGBOX "AUTOSCAN, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_XSPDCTRL_CALL()
    MSGBOX "XSPD CTRL, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_MJOG_CALL()
    MSGBOX "MJOG, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_LOAD_CALL()
    MSGBOX "Load, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_CALENC_CALL()
    MSGBOX "Calculate Encoders, hit OK to continue",, "Title of subroutine 123"
END FUNCTION

FUNCTION BUILDWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, 0, "Atco MCU2015",,, w/2, h/2,%WS_OVERLAPPEDWINDOW , 0 TO hDlg
    DIALOG SET ICON hDlg, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg, %SETUP_BUTTON, "Set&up", 100, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_SETUP_CALL()
    CONTROL SET FONT hDlg, %SETUP_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg, %JOYSTICK_BUTTON, "&Joy Stick", 100, 200, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_JOYSTICK_CALL()
    CONTROL SET FONT hDlg, %JOYSTICK_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg,%AJOG, "A-Jo&g", 100, 300, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_AJOG_CALL()
    CONTROL SET FONT hDlg, %AJOG, NormalFont&


    CONTROL ADD BUTTON, hDlg,%SAVE, "&Save", 100, 400, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_SAVE_CALL()
    CONTROL SET FONT hDlg, %SAVE, NormalFont&

    CONTROL ADD BUTTON, hDlg,%AUTOSCAN, "&Auto Scan", 600, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_AUTOSCAN_CALL()
    CONTROL SET FONT hDlg, %AUTOSCAN, NormalFont&

    CONTROL ADD BUTTON, hDlg,%XSPDCTRL, "&XSPD CTRL", 600, 200, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_XSPDCTRL_CALL()
    CONTROL SET FONT hDlg, %XSPDCTRL, NormalFont&

    CONTROL ADD BUTTON, hDlg,%MJOG, "&M-Jog", 600, 300, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_MJOG_CALL()
    CONTROL SET FONT hDlg, %MJOG, NormalFont&

    CONTROL ADD BUTTON, hDlg,%LOAD, "&Load", 600, 400, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_LOAD_CALL()
    CONTROL SET FONT hDlg, %LOAD, NormalFont&

END FUNCTION

FUNCTION BUILDSETUPWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
   ' DIALOG NEW PIXELS, 0, "MCU 2015 Setup",,, w/2, h/2,%WS_OVERLAPPEDWINDOW  , 0 TO hDlg1
    DIALOG NEW hdlg, " MCU 2015 Setup", 0, 0, w/2, h/2, %WS_OVERLAPPEDWINDOW, TO hDlg1
    DIALOG SET USER hDlg1, 1, hdlg
    DIALOG SET ICON hDlg1, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg1, %CALIBRATEENC, "Calibrate Encoders", 10, 400, 400, 50,%BS_PUSHLIKE , , _
    CALL BTN_CALENC_CALL()
    CONTROL SET FONT hDlg1, %CALIBRATEENC, NormalFont&

    TXT$ = "X Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XSTART, SCANstruc.XLowStr, 100, 10, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL1, TXT$,    10, 10, 50, 20

    TXT$ = "X End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XEND, SCANstruc.XHighStr, 100, 40, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL2, TXT$, 10,    40, 50, 20

    TXT$ = "Y Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YSTART , SCANstruc.YLowStr, 100, 70, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL3, TXT$, 10,     70, 50, 20

    TXT$ = "Y End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YEND , SCANstruc.YLowStr, 100, 100, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL4, TXT$, 10,     100, 50, 20

    TXT$ = "X Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XINDEX , SCANstruc.XIndexSTR, 100, 130, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL5, TXT$, 10,     130, 50, 20

    TXT$ = "Y Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YINDEX , SCANstruc.YIndexSTR, 100, 160, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL6, TXT$, 10,     160, 50, 20

    TXT$ = "X Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XSPEED , SCANstruc.XSpeedSTR, 100, 190, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL7, TXT$, 10,     190, 50, 20

    TXT$ = "Y Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YSPEED , SCANstruc.YSpeedSTR, 100, 220, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL8, TXT$, 10,     220, 50, 20

    TXT$ = "X POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XPOS, SCANstruc.XPosStr, 410, 10, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL9, TXT$,    300, 10, 50, 20

    TXT$ = "Y POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YPOS, SCANstruc.YPosStr, 410, 40, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL10, TXT$, 300,    40, 50, 20

    TXT$ = "X CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XCTIN , SCANstruc.XCtrStr, 410, 70, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL11, TXT$, 300,     70, 50, 20

    TXT$ = "Y CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YCTIN , SCANstruc.YCtrStr, 410, 100, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL12, TXT$, 300,     100, 50, 20

    TXT$ = "X +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XPLUSMIN , SCANstruc.XPlusSTR, 410, 130, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL13, TXT$, 300,     130, 50, 20

    TXT$ = "Y +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YPLUSMIN , SCANstruc.YPlusSTR, 410, 160, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL14, TXT$, 300,     160, 50, 20

    TXT$ = "INDEX"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_INDEX , SCANstruc.IndexYSTR, 410, 190, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL15, TXT$, 300,     190, 50, 20

    TXT$ = "IDX H/L"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_IDXHL, SCANstruc.IndexLowStr, 410, 220, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL16, TXT$, 300,     220, 50, 20

    TXT$ = "X ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XONOFF, SCANstruc.XEnableSTR, 730, 10, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL17, TXT$,    600, 10, 60, 20

    TXT$ = "Y ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YONOFF, SCANstruc.YEnableSTR, 730, 40, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL18, TXT$, 600,    40, 60, 20

    TXT$ = "AUTO HD"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_AUTOHD , SCANstruc.AutoHoldSTR, 730, 70, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL19, TXT$, 600,     70, 60, 20

    TXT$ = "DUALRAS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_DUALRAS ,SCANstruc.DualRasSTR, 730, 100, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL20, TXT$, 600,     100, 60, 20

    TXT$ = "OVERLAP"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_OVERLAP , SCANstruc.OverLapStr, 730, 130, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL21, TXT$, 600,     130, 60, 20

    TXT$ = "A POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_APOS , SCANstruc.APosStr, 730, 160, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL22, TXT$, 600,     160, 60, 20

    TXT$ = "A CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_ACTIN, SCANstruc.ACtrStr, 730, 190, 80, 12, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL23, TXT$, 600,     190, 60, 20

 END FUNCTION

CALLBACK FUNCTION EditControlCallback()
    LOCAL TXT AS STRING
    LOCAL InkeyVar AS STRING
    IF CB.CTLMSG = %EN_CHANGE THEN
       SELECT CASE CB.CTL
    'X START
            CASE %IDC_EB_XSTART
                CONTROL GET TEXT hDlg1, %IDC_EB_XSTART TO TXT$
                IF GoodSNG(TXT$) THEN
                  SCANstruc.XLow = ABS(VAL(TXT$))
                  SCANstruc.XLowStr = QStr$(SCANstruc.XLow, 10)
                END IF
    'X END
            CASE %IDC_EB_XEND
                CONTROL GET TEXT hDlg1, %IDC_EB_XEND TO TXT$
                IF GoodSNG(TXT$) THEN
                   SCANstruc.XHigh = ABS(VAL(TXT$))
                   SCANstruc.XHighStr = QStr$(SCANstruc.XHigh, 10)
                END IF
    'Y START
            CASE %IDC_EB_YSTART
                CONTROL GET TEXT hDlg1, %IDC_EB_YSTART TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YLow = ABS(VAL(TXT$))
                       SCANstruc.YLowStr = QStr$(SCANstruc.YLow, 10)
                END IF

    'Y END
           CASE %IDC_EB_YEND
                CONTROL GET TEXT hDlg1, %IDC_EB_YEND TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YHigh = ABS(VAL(TXT$))
                       SCANstruc.YHighStr = QStr$(SCANstruc.YHigh, 10)
                END IF
                'X INDEX
           CASE %IDC_EB_XINDEX
                CONTROL GET TEXT hDlg1, %IDC_EB_XINDEX TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.XIndex = ABS(VAL(TXT$))
                       SCANstruc.XIndexSTR = QStr$(SCANstruc.XIndex, 10)
                END IF
    'Y INDEX
           CASE %IDC_EB_YINDEX
                CONTROL GET TEXT hDlg1, %IDC_EB_YINDEX TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YIndex = ABS(VAL(TXT$))
                       SCANstruc.YIndexSTR = QStr$(SCANstruc.YIndex, 10)
                END IF
    'X SPEED
            CASE %IDC_EB_XSPEED
                CONTROL GET TEXT hDlg1, %IDC_EB_XSPEED TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.XSpeed = ABS(VAL(TXT$))
                       SCANstruc.XSpeedSTR = QStr$(SCANstruc.XSpeed, 10)
                END IF
    'Y SPEED
            CASE %IDC_EB_YSPEED
                CONTROL GET TEXT hDlg1, %IDC_EB_YSPEED TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YSpeed = ABS(VAL(TXT$))
                       SCANstruc.YSpeedSTR = QStr$(SCANstruc.YSpeed, 10)
                END IF
    'X POS
            CASE %IDC_EB_XPOS
                CONTROL GET TEXT hDlg1, %IDC_EB_XPOS TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.XPos = ABS(VAL(TXT$))
                       SCANstruc.XPosStr = QStr$(SCANstruc.XPos, 10)
                       SCANstruc.XOffset = GetXCord(CLNG(SCANstruc.XPos * SCANstruc.XCtr))
                       CALL ResetPosition(Servo1)
                       CALL ResetPosition(Servo2)
                END IF
    'Y POS
            CASE %IDC_EB_YPOS
                CONTROL GET TEXT hDlg1, %IDC_EB_YPOS TO TXT$
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YPos = VAL(TXT$)
                       SCANstruc.YPosStr = QStr$(SCANstruc.YPos, 10)
                       SCANstruc.YOffset = GetYCord(CLNG(SCANstruc.YPos * SCANstruc.YCtr))
                       CALL ResetPosition(Servo3)
                END IF
    'X CT/IN
            CASE %IDC_EB_XCTIN
                CONTROL GET TEXT hDlg1, %IDC_EB_XCTIN TO TXT$
                IF GoodLNG(TXT$) THEN
                       SCANstruc.XCtr = ABS(VAL(TXT$))
                       SCANstruc.XCtrStr = QStr$(SCANstruc.XCtr, 10)
                END IF
    'Y CT/IN
            CASE %IDC_EB_YCTIN

                CONTROL GET TEXT hDlg1, %IDC_EB_YCTIN TO TXT$
                IF GoodLNG(TXT$) THEN
                     SCANstruc.YCtr = ABS(VAL(TXT$))
                     SCANstruc.YCtrStr = QStr$(SCANstruc.YCtr, 10)
                END IF
    'X +/-
            CASE %IDC_EB_XPLUSMIN

    'Y +/-
            CASE %IDC_EB_YPLUSMIN
    'Index
            CASE %IDC_EB_INDEX
    'IDX/HL
            CASE %IDC_EB_IDXHL
    'X ON/OFF
            CASE %IDC_EB_XONOFF
    'Y ON/OFF
            CASE %IDC_EB_YONOFF
    'Auto HD
            CASE %IDC_EB_AUTOHD
    'DUALRAS
            CASE %IDC_EB_DUALRAS
            CASE %IDC_EB_OVERLAP
                CONTROL GET TEXT hDlg1, %IDC_EB_OVERLAP TO TXT$
                IF GoodSNG(TXT$) THEN
                    SCANstruc.OverLap = ABS(VAL(TXT$))
                    SCANstruc.OverLapStr = QStr$(SCANstruc.OverLap, 10)
                END IF
    'A POS
            CASE %IDC_EB_APOS
                CONTROL GET TEXT hDlg1, %IDC_EB_APOS TO TXT$
                IF GoodSNG(TXT$) THEN
                    SCANstruc.APos = ABS(VAL(TXT$))
                    SCANstruc.APosStr = QStr$(SCANstruc.APos, 10)
                    SCANstruc.AOffset = GetXCord(CLNG(SCANstruc.APos * SCANstruc.ACtr))
                    CALL ResetPosition(Servo4)
                END IF
    'A CT/IN
            CASE %ID_EB_ACTIN
                CONTROL GET TEXT hDlg1, %IDC_EB_ACTIN TO TXT$
                 IF GoodLNG(TXT$) THEN
                    SCANstruc.ACtr = ABS(VAL(TXT$))
                    SCANstruc.ACtrStr = QStr$(SCANstruc.ACtr, 10)
                 END IF
       END SELECT
 END IF

END FUNCTION
CALLBACK FUNCTION DlgProc () AS LONG

END FUNCTION
FUNCTION EditSubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN, %IDC_EB_XPLUSMIN, wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit2SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN, %IDC_EB_YPLUSMIN, wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit3SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN, %IDC_EB_INDEX, wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit4SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN, %IDC_EB_IDXHL , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit5SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_EB_XONOFF  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit6SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_EB_YONOFF  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit7SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_EB_AUTOHD  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION

FUNCTION Edit8SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_EB_DUALRAS  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION

CALLBACK FUNCTION DlgProcSetup () AS LONG
 LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
         'Subclass the editbox control
         STATIC hEdit, hEdit1, hEdit2, hEdit3, hEdit4, hEdit5, hEdit6, hEdit7 AS LONG
         CONTROL HANDLE CBHNDL, %IDC_EB_XPLUSMIN TO hEdit
         CONTROL HANDLE CBHNDL, %IDC_EB_YPLUSMIN TO hEdit1
         CONTROL HANDLE CBHNDL, %IDC_EB_INDEX TO hEdit2
         CONTROL HANDLE CBHNDL, %IDC_EB_IDXHL TO hEdit3
         CONTROL HANDLE CBHNDL, %IDC_EB_XONOFF TO hEdit4
         CONTROL HANDLE CBHNDL, %IDC_EB_YONOFF TO hEdit5
         CONTROL HANDLE CBHNDL, %IDC_EB_AUTOHD TO hEdit6
         CONTROL HANDLE CBHNDL, %IDC_EB_DUALRAS TO hEdit7
         gOldEditClassProc = SetWindowLong(hEdit, %GWL_WNDPROC, CODEPTR(EditSubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit1, %GWL_WNDPROC, CODEPTR(Edit2SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit2, %GWL_WNDPROC, CODEPTR(Edit3SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit3, %GWL_WNDPROC, CODEPTR(Edit4SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit4, %GWL_WNDPROC, CODEPTR(Edit5SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit5, %GWL_WNDPROC, CODEPTR(Edit6SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit6, %GWL_WNDPROC, CODEPTR(Edit7SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit7, %GWL_WNDPROC, CODEPTR(Edit8SubClassProc))
      CASE %WM_KEYDOWN
         IF CBCTL = %IDC_EB_XPLUSMIN THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.XPlus = TRUE
                SCANstruc.XPlusSTR = "POSITIVE  "
                CONTROL SET TEXT hDlg1, %IDC_EB_XPLUSMIN, "POSITIVE"
            ELSEIF CBLPARAM = %VK_LEFT THEN
               SCANstruc.XPlus = FALSE
               SCANstruc.XPlusSTR = "NEGATIVE  "
               CONTROL SET TEXT hDlg1, %IDC_EB_XPLUSMIN, "NEGATIVE"
            END IF
         END IF
         IF CBCTL = %IDC_EB_YPLUSMIN THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.YPlus = TRUE
                SCANstruc.YPlusSTR = "POSITIVE  "
                CONTROL SET TEXT hDlg1, %IDC_EB_YPLUSMIN, "POSITIVE"
            ELSEIF CBLPARAM = %VK_LEFT THEN
               SCANstruc.YPlus = FALSE
               SCANstruc.YPlusSTR = "NEGATIVE  "
               CONTROL SET TEXT hDlg1, %IDC_EB_YPLUSMIN, "NEGATIVE"
            END IF
         END IF

         IF CBCTL = %IDC_EB_INDEX THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.IndexY = FALSE
                SCANstruc.IndexYSTR = "X         "
                CONTROL SET TEXT hDlg1, %IDC_EB_INDEX, "X         "

            ELSEIF CBLPARAM = %VK_LEFT THEN
                SCANstruc.IndexY = TRUE
                SCANstruc.IndexYSTR = "Y         "
                CONTROL SET TEXT hDlg1, %IDC_EB_INDEX, "Y         "
            END IF
         END IF
         IF CBCTL = %IDC_EB_IDXHL THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.IndexLow = TRUE
                SCANstruc.IndexLowStr = "HIGH - LOW"
                CONTROL SET TEXT hDlg1, %IDC_EB_IDXHL, "HIGH - LOW"
            ELSEIF CBLPARAM = %VK_LEFT THEN
               SCANstruc.IndexLow = FALSE
               SCANstruc.IndexLowStr = "LOW - HIGH"
               CONTROL SET TEXT hDlg1, %IDC_EB_IDXHL, "LOW - HIGH"
            END IF
         END IF
         IF CBCTL = %IDC_EB_IDXHL THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.IndexLow = TRUE
                SCANstruc.IndexLowStr = "HIGH - LOW"
                CONTROL SET TEXT hDlg1, %IDC_EB_IDXHL, "HIGH - LOW"
            ELSEIF CBLPARAM = %VK_LEFT THEN
               SCANstruc.IndexLow = FALSE
               SCANstruc.IndexLowStr = "LOW - HIGH"
               CONTROL SET TEXT hDlg1, %IDC_EB_IDXHL, "LOW - HIGH"
            END IF
         END IF
         IF CBCTL = %IDC_EB_XONOFF THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.XEnable = FALSE
                SCANstruc.XEnableSTR = "OFF       "
                CALL EnableAmpl(SCANstruc.XEnable, Servo1)
                CALL EnableAmpl(SCANstruc.XEnable, Servo2)
                CONTROL SET TEXT hDlg1, %IDC_EB_XONOFF, "OFF       "
            ELSEIF CBLPARAM = %VK_LEFT THEN
                SCANstruc.XEnable = TRUE
                SCANstruc.XEnableSTR = "ON        "
                CALL StopXMtrs
                CONTROL SET TEXT hDlg1, %IDC_EB_XONOFF, "ON        "
            END IF
         END IF
         IF CBCTL = %IDC_EB_YONOFF THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.YEnable = FALSE
                SCANstruc.YEnableSTR = "OFF       "
                CALL EnableAmpl(SCANstruc.YEnable, Servo1)
                CALL EnableAmpl(SCANstruc.YEnable, Servo2)
                CONTROL SET TEXT hDlg1, %IDC_EB_YONOFF, "OFF       "
            ELSEIF CBLPARAM = %VK_LEFT THEN
                SCANstruc.YEnable = TRUE
                SCANstruc.YEnableSTR = "ON        "
                CALL StopYMtr
                CONTROL SET TEXT hDlg1, %IDC_EB_YONOFF, "ON        "
            END IF
         END IF
         IF CBCTL = %IDC_EB_AUTOHD THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.YEnable = FALSE
                SCANstruc.YEnableSTR = "OFF       "
                CALL EnableAmpl(SCANstruc.YEnable, Servo1)
                CALL EnableAmpl(SCANstruc.YEnable, Servo2)
                CONTROL SET TEXT hDlg1, %IDC_EB_AUTOHD, "OFF       "
            ELSEIF CBLPARAM = %VK_LEFT THEN
                SCANstruc.AutoHold = TRUE
                SCANstruc.AutoHoldSTR = "ON        "
                CONTROL SET TEXT hDlg1, %IDC_EB_AUTOHD, "ON        "
            END IF
         END IF
         IF CBCTL = %IDC_EB_DUALRAS THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.DualRas = FALSE
                SCANstruc.DualRasSTR = "OFF       "
                CONTROL SET TEXT hDlg1, %IDC_EB_DUALRAS, "OFF       "
            ELSEIF CBLPARAM = %VK_LEFT THEN
                SCANstruc.DualRas = TRUE
                SCANstruc.DualRasSTR = "ON        "
                CONTROL SET TEXT hDlg1, %IDC_EB_DUALRAS, "ON        "
            END IF
         END IF

      CASE %WM_DESTROY
         'Important! Remove the subclassing
         SetWindowLong hEdit, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit1, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit2, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit3, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit4, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit5, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit6, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit7, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION


'________________________________________________________________________________________
'
' Splash Dialog Box function
' ==========================
'
' Function to display a splash-screen for specified amount of time
'
' Update: now includes modal\modeless dialog (return immediately).
'
'
' By KGP Software, June 2002. Posted April 2004.
'________________________________________________________________________________________


'#If Not %Def(%FUNCTION_SPLASH)

'%FUNCTION_SPLASH = 1




'------------------------------------------------------------------------------
' Callback for the splash dialog
'------------------------------------------------------------------------------
CALLBACK FUNCTION dlgSplashProc

  SELECT CASE CBMSG

         CASE %WM_TIMER, %WM_LBUTTONDOWN, %WM_RBUTTONDOWN, %WM_KEYDOWN
              ' React to mouse or key movements, or when the dialog times out...
              KillTimer CBHNDL, 100
              IsSplashActive = %False
              DeleteObject SendDlgItemMessage(CBHNDL, 100, %STM_GETIMAGE, %IMAGE_BITMAP, 0)
              DIALOG END CBHNDL
  END SELECT

END FUNCTION

FUNCTION MsgFilterProc _
  ( _
  BYVAL nCode   AS LONG, _
  BYVAL wParam  AS DWORD, _
  BYVAL lParam  AS LONG _
  ) AS LONG

  LOCAL ptmsg     AS tagMSG PTR
  LOCAL lRetVal   AS LONG
  LOCAL wm AS WORD
  ptmsg = lParam

  lRetVal = CallNextHookEx(ghMsgHook, nCode, wParam, BYVAL lParam)

  IF nCode = %MSGF_DIALOGBOX THEN
    IF @ptmsg.message = %WM_KEYDOWN THEN
        IF wParam = %VK_BACK THEN
            MSGBOX "MsgFilterProc: WM_KEYDOWN"
            lRetVal = 0  ' 1
        END IF
     END IF
  END IF

  FUNCTION = lRetVal

END FUNCTION


'------------------------------------------------------------------------------
' Displays splash dialog
'
'  nDelay is number of milliseconds to display
'  sBitmapID is either a resource ID or file name
'  IsFile is nonzero if sBitmapID is a file name
'  sAppName is an (optional) string to display on the screen
'  nModeless is nonzero to return from function immediately.
'
'------------------------------------------------------------------------------
SUB ShowSplashDlg(BYVAL nDelay AS LONG, BYVAL sBitmapID AS STRING, BYVAL isfilea AS LONG, OPTIONAL BYVAL sAppName AS STRING,  OPTIONAL BYVAL nModeless AS LONG)

    LOCAL hDlg AS DWORD, hBmp AS DWORD, tObj AS BITMAP

    IsSplashActive = 1

    ' Default delay...
    IF nDelay = 0 THEN nDelay = 1500

    IF isfilea THEN
       hBmp = LoadImage(0, BYCOPY sBitmapID, %IMAGE_BITMAP, 0, 0, %LR_LOADFROMFILE)
    ELSE
       hBmp = LoadImage(GetModuleHandle(BYVAL %NULL), BYCOPY sBitmapID, %IMAGE_BITMAP, 0,0,0)
    END IF

    ' Get size of bitmap and size window accordingly...
    IF GetObject(hBmp, SIZEOF(tObj), tObj) = 0 THEN EXIT SUB

    ' Create the dialog...
    DIALOG NEW 0, "", , , 0, 0, %DS_3DLOOK ,%WS_EX_TOPMOST  TO hDlg
    SetWindowPos hDlg, 0, (GetSystemMetrics(%SM_CXSCREEN)/2)-(tObj.bmWidth/2), _
                          (GetSystemMetrics(%SM_CYSCREEN)/2)-(tObj.bmHeight/2), _
                          tObj.bmWidth, tObj.bmHeight, %SWP_NOZORDER

    ' Create the label (image) and size it also...
    CONTROL ADD LABEL, hDlg, 100, "", 0, 0, 0, 0, %SS_BITMAP OR %SS_CENTERIMAGE
    SetWindowPos GetDlgItem(hDlg, 100), 0, 0, 0, tObj.bmWidth, tObj.bmHeight, %SWP_NOZORDER
    CONTROL SEND hDlg, 100, %STM_SETIMAGE, %IMAGE_BITMAP, hBmp

    ' Display application data string if specified...
    IF LEN(sAppName) THEN
       CONTROL ADD LABEL, hDlg, 10, sAppName, 0, 0, 200, 10
       SetWindowPos GetDlgItem(hDlg, 10), 0, 15, tObj.bmHeight-20, 0, 0, %SWP_NOSIZE OR %SWP_NOZORDER
       CONTROL SET COLOR hDlg, 10, RGB(255,255,255), -2
    END IF

    SetTimer hDlg, 100, nDelay, 0

    IF nModeless = %False THEN
       DIALOG SHOW MODAL hDlg CALL dlgSplashProc
    ELSE
       DIALOG SHOW MODELESS hDlg CALL dlgSplashProc
    END IF
END SUB

'===================================================================
