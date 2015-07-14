#INCLUDE "mywindowsdef.inc"
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
%IDC_LABEL24 = 4008
%IDC_LABEL25 = 4009
%IDC_LABEL26 = 4010

%IDC_LABEL27 = 4011
%IDC_LABEL28 = 4012
%IDC_LABEL29 = 4013
%IDC_LABEL30 = 4014
%IDC_LABEL31 = 4015

%IDC_LABEL32 = 4016
%IDC_LABEL33 = 4017
%IDC_LABEL34 = 4018
%IDC_LABEL35 = 4019
%IDC_LABEL36 = 4020

%IDC_LABEL40 = 4021
%IDC_LABEL41 = 4022
%IDC_LABEL42 = 4023

%IDC_LABEL50 = 8021
%IDC_LABEL51 = 8022
%IDC_LABEL52 = 8023
%IDC_LABEL53 = 8023
%IDC_LABEL54 = 8024

%IDC_LABEL80 = 9021
%IDC_LABEL81 = 9022
%IDC_LABEL82 = 9023
%IDC_LABEL83 = 9023
%IDC_LABEL84 = 9024

%IDC_LABEL_XPOSPRINT = 311
%IDC_LABEL_YPOSPRINT = 312
%IDC_LABEL_APOSPRINT = 313

%IDC_LABEL_XPOSAJOG = 314
%IDC_LABEL_YPOSAJOG = 315
%IDC_LABEL_APOSAJOG = 316

%IDC_LABEL_XPOSMJOG = 3914
%IDC_LABEL_YPOSMJOG = 3915
%IDC_LABEL_APOSMJOG = 3916

%IDC_LABEL_XPOSASCAN = 317
%IDC_LABEL_YPOSASCAN = 318
%IDC_LABEL_APOSASCAN = 319

%IDC_LABEL_XPOSAUTO = 13000
%IDC_LABEL_YPOSAUTO = 13001
%IDC_LABEL_APOSAUTO = 13002

%STOP_AUTO = 13003

%IDC_LABEL100 = 13004
%IDC_LABEL101 = 13005
%IDC_LABEL102 = 13006
%IDC_LABEL103 = 13007
%IDC_LABEL104 = 13008
%IDC_LABEL105 = 13009
%IDC_LABEL106 = 13010
%IDC_LABEL107 = 13011
%IDC_LABEL108 = 13012
%IDC_LABEL109 = 13013


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
%IDC_EB_STARTEND = 3008

GLOBAL hTimer AS LONG


'=====================  Setup calls  ===================================
CALLBACK FUNCTION BTN_SETUP_CALL()
    LOCAL  x      AS LONG
    BUILDSETUPWINDOW()
    DIALOG SHOW MODELESS hDlg1, CALL DlgProcSetup
    DIALOG ENABLE hDlg1
    DIALOG SHOW STATE hDlg1, %SW_SHOWNORMAL
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg1 TO x, x
          DIALOG DOEVENTS  0
    LOOP WHILE x&
    DIALOG SHOW STATE hDlg, %SW_SHOWNORMAL
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
                SCANstruc.AutoHold = FALSE
                SCANstruc.AutoHoldSTR = "OFF       "
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


'=====================  Calibration Call ===================================
CALLBACK FUNCTION BTN_CALX_CALL()
    ExitSub = 0
    CONTROL SHOW STATE hDlg2, %CALX_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALY_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALA_BUTTON, %SW_HIDE
    CALL CalEncoder(Servo1)
END FUNCTION


CALLBACK FUNCTION BTN_CALY_CALL
    ExitSub = 0
    CONTROL SHOW STATE hDlg2, %CALX_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALY_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALA_BUTTON, %SW_HIDE
    CalEncoder(Servo3)
END FUNCTION

CALLBACK FUNCTION BTN_CALA_CALL()
    ExitSub = 0
    CONTROL SHOW STATE hDlg2, %CALX_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALY_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALA_BUTTON, %SW_HIDE
    CALL CalEncoder(Servo4)
END FUNCTION

CALLBACK FUNCTION BTN_CALENC_CALL()
    LOCAL  x      AS LONG
    BUILDCALWINDOW()
    DIALOG SHOW MODELESS hDlg2, CALL DlgProcCalEnc
    DIALOG ENABLE hDlg2
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg2 TO x, x
          DIALOG DOEVENTS  0
    LOOP WHILE x&
    IF SCANstruc.XHigh < SCANstruc.XLow THEN
        SWAP SCANstruc.XHigh, SCANstruc.XLow
        SWAP SCANstruc.XHighStr, SCANstruc.XLowStr
    END IF
    IF SCANstruc.YHigh < SCANstruc.YLow THEN
        SWAP SCANstruc.YHigh, SCANstruc.YLow
        SWAP SCANstruc.YHighStr, SCANstruc.YLowStr
    END IF
    DIALOG SHOW STATE hDlg1, %SW_SHOWNORMAL
END FUNCTION

SUB CalEncoder (EncNum)
  LOCAL TXT AS STRING
  GEncNum = EncNum
  CALL StopMtrs
  CALL GetXyPos
  IF GEncNum = Servo1 OR GEncNum = Servo4 THEN
    AxisNum = Servo1
  ELSE
    AxisNum = Servo3
  END IF
  CONTROL SHOW STATE hDlg2, %IDC_EB_STARTEND, %SW_SHOW
  CONTROL SHOW STATE hDlg2, %IDC_LABEL24, %SW_SHOW
  CONTROL SHOW STATE hDlg2, %IDC_LABEL25, %SW_SHOW
  CONTROL SHOW STATE hDlg2, %IDC_LABEL26, %SW_SHOW
  IF AxisNum = Servo1 THEN
     CONTROL SET TEXT hDlg2, %IDC_LABEL24, "Move X Axis to Start"
     CONTROL SET TEXT hDlg2, %IDC_LABEL25, "Pos; Press Enter Key"
     IF GEncNum = Servo1 THEN
        CONTROL SET TEXT hDlg2, %IDC_LABEL26, "X Pos: "
        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, ScanStruc.XPosStr
     ELSE
         CONTROL SET TEXT hDlg2, %IDC_LABEL24, ""
         CONTROL SET TEXT hDlg2, %IDC_LABEL26, "A Pos: "
         CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, ScanStruc.APosStr
     END IF
  ELSE
     CONTROL SET TEXT hDlg2, %IDC_LABEL24, "Move Y Axis to Start"
     CONTROL SET TEXT hDlg2, %IDC_LABEL25, "Pos; Press Enter Key"
     CONTROL SET TEXT hDlg2, %IDC_LABEL26, "Y Pos: "
     CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, ScanStruc.YPosStr
  END IF
  Mflag = 1
END SUB

CALLBACK FUNCTION DlgProcCalEnc () AS LONG
LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
         'Subclass the editbox control
         STATIC  hEdit8 AS LONG
         CONTROL HANDLE CBHNDL, %IDC_EB_STARTEND TO hEdit8
         gOldEditClassProc = SetWindowLong(hEdit8, %GWL_WNDPROC, CODEPTR(Edit9SubClassProc))
      CASE %WM_KEYDOWN
         IF CBCTL = %IDC_EB_STARTEND THEN
            IF CBLPARAM = %VK_UP THEN
                IF (AxisNum = 1) THEN
                    CALL MoveXVel(PosDir)
                    CALL GetXyPos
                    IF GEncNum = Servo1 THEN
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr
                    ELSE
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.APosStr
                    END IF
                END IF
                CALL StopMtrs
            ELSEIF CBLPARAM = %VK_DOWN THEN
                 IF (AxisNum = 1) THEN
                    CALL MoveXVel(NegDir)
                    CALL GetXyPos
                    IF GEncNum = Servo1 THEN
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr
                    ELSE
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.APosStr
                    END IF
                 END IF

                 CALL StopMtrs
             ELSEIF CBLPARAM = %VK_LEFT THEN
                 IF (AxisNum = 3) THEN
                    CALL MoveYVel(NegDir)
                    CALL GetXyPos
                    CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.YPosStr
                 END IF
                 CALL StopMtrs
             ELSEIF CBLPARAM = %VK_RIGHT THEN
                 IF (AxisNum = 3) THEN
                    CALL MoveYVel(PosDir)
                    CALL GetXyPos
                    CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.YPosStr
                 END IF
                 CALL StopMtrs

             ELSEIF CBLPARAM = %VK_RETURN THEN
                LOCAL EndCts AS LONG
                LOCAL StartCts AS LONG
                LOCAL TXT AS STRING
                TXT$     = SPACE$(10)
                CALL GetXyPos
                CONTROL GET TEXT hDlg2, %IDC_EB_STARTEND TO TXT$
                IF MFlag = 1 THEN      'start position cts
                     IF AxisNum = Servo1 THEN  'X encoder cal
                        IF GEncNum = Servo1 THEN
                            StartCts& = Glo.Position(Servo1)
                        ELSE
                            StartCts& = Glo.Position(Servo4)
                        END IF
                     ELSE
                            StartCts& = Glo.Position(Servo3)
                     END IF
                ELSE                   'end position cts
                     IF AxisNum = Servo1 THEN  'X encoder cal
                          IF GEncNum = Servo1 THEN
                                EndCts& = Glo.Position(Servo1)
                          ELSE
                                EndCts& = Glo.Position(Servo4)
                          END IF
                     ELSE                 'Y encoder cal
                          EndCts& = Glo.Position(Servo3)
                     END IF
                END IF
              IF MFlag = 1 THEN      'start position cts
                 IF AxisNum = Servo1 THEN
                    CONTROL SET TEXT hDlg2, %IDC_LABEL24, "Move X Axis to End"
                    CONTROL SET TEXT hDlg2, %IDC_LABEL25, "Pos; Press Enter Key"
                    IF GEncNum = Servo1 THEN
                        CONTROL SET TEXT hDlg2, %IDC_LABEL26, "X Pos: "
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, ScanStruc.XPosStr
                    ELSE
                        CONTROL SET TEXT hDlg2, %IDC_LABEL24, ""
                        CONTROL SET TEXT hDlg2, %IDC_LABEL26, "A Pos: "
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, ScanStruc.APosStr
                    END IF
                 ELSE
                    CONTROL SET TEXT hDlg2, %IDC_LABEL24, "Move Y Axis to End"
                    CONTROL SET TEXT hDlg2, %IDC_LABEL25, "Pos; Press Enter Key"
                    CONTROL SET TEXT hDlg2, %IDC_LABEL26, "Y Pos: "
                    CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, ScanStruc.YPosStr
                END IF
              END IF
              IF mflag = 2 THEN
                  CONTROL SET TEXT hDlg2, %IDC_LABEL24, ""
                  CONTROL SET TEXT hDlg2, %IDC_LABEL25, "Enter Dis: "
                  CONTROL SET TEXT hDlg2, %IDC_LABEL26, ""
                  CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, "0"
                  CONTROL GET TEXT hDlg2, %IDC_EB_STARTEND TO TXT$
                  IF VAL(TXT$) > 0 THEN
                     IF AxisNum = Servo1 THEN
                       IF GEncNum = Servo1 THEN
                          SCANstruc.XCal = VAL(TXT$)
                          SCANstruc.XCalStr = QStr(SCANstruc.XCal, 10)
                       ELSE
                          SCANstruc.ACal = VAL(TXT$)
                          SCANstruc.ACalStr = QStr(SCANstruc.ACal, 10)
                       END IF
                     ELSE
                        SCANstruc.YCal = VAL(TXT$)
                        SCANstruc.YCalStr = QStr(SCANstruc.YCal, 10)
                     END IF
                  END IF
                  IF ABS(EndCts& - StartCts&) > 0 THEN
                     IF AxisNum = Servo1 THEN
                       IF GEncNum = Servo1 THEN
                          SCANstruc.XCtr = ABS(EndCts& - StartCts&) / SCANstruc.XCal
                          SCANstruc.XCtrStr = QStr(SCANstruc.XCtr, 10)
                       ELSE
                          SCANstruc.ACtr = ABS(EndCts& - StartCts&) / SCANstruc.ACal
                          SCANstruc.ACtrStr = QStr(SCANstruc.ACtr, 10)
                       END IF
                     ELSE
                      SCANstruc.YCtr = ABS(EndCts& - StartCts&) / SCANstruc.YCal
                      SCANstruc.YCtrStr = QStr(SCANstruc.YCtr, 10)
                     END IF
                  END IF
              END IF
              mflag = 2
            ELSEIF CBLPARAM = %VK_ESCAPE THEN
                CALL StopMtrs
            END IF
         END IF
      CASE %WM_DESTROY
         'Important! Remove the subclassing
         SetWindowLong hEdit8, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION

'=====================  JoyStick call ===================================

CALLBACK FUNCTION BTN_JOYSTICK_CALL()
    LOCAL COUNT AS LONG
    LOCAL  x      AS LONG
    BUILDJOYWINDOW()

    DIALOG SHOW MODELESS hDlg4, CALL DlgProcJoyStk
    CALL SetForAuto
    CALL JogJoyStk
    DIALOG ENABLE hDlg4
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg4 TO x, x
          DIALOG DOEVENTS TO COUNT
    LOOP WHILE x&
END FUNCTION
CALLBACK FUNCTION BTN_JOYSTOP_CALL()
    Exitsub = 1
END FUNCTION

CALLBACK FUNCTION DlgProcJoyStk () AS LONG
LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
         'Subclass the editbox control
         htimer = SetTimer(CBHNDL, &hFFFF, 1, BYVAL %NULL)
         DIALOG POST CBHNDL, %WM_TIMER, &hFFFF, 0
         Exitsub = 0
      CASE %WM_TIMER
            CALL GetXyPos
            CONTROL SET TEXT hDlg4, %IDC_LABEL_XPOSPRINT, SCANstruc.XPosStr
            CONTROL SET TEXT hDlg4, %IDC_LABEL_YPOSPRINT, SCANstruc.YPosStr
            CONTROL SET TEXT hDlg4, %IDC_LABEL_APOSPRINT, SCANstruc.APosStr
      CASE %WM_LBUTTONDOWN
            exitsub = 1
      CASE %WM_DESTROY
         'Important!
         KillTimer hDlg4, &hFFFF
   END SELECT
END FUNCTION


'=====================  A-Jog call ===================================
CALLBACK FUNCTION BTN_AJOG_CALL()
'    MSGBOX "A-Jog, hit OK to continue",, "Title of subroutine 123"
    LOCAL COUNT AS LONG
    LOCAL  x      AS LONG

    BUILDAJOGWINDOW()

    DIALOG SHOW MODELESS hDlg5, CALL DlgProcAJog
    CALL SetForAuto
    JogAuto

    DIALOG ENABLE hDlg4
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg4 TO x, x
          DIALOG DOEVENTS TO COUNT
    LOOP WHILE x&
END FUNCTION

'=====================  A-Jog call ===================================
CALLBACK FUNCTION BTN_AJOGSTOP_CALL()
    CALL StopMtrs
    SetModeVel 'sets vel to 0
END FUNCTION

CALLBACK FUNCTION DlgProcAJog () AS LONG
LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
           STATIC  hEdit9 AS LONG
           CONTROL HANDLE CBHNDL, %IDC_LABEL_XPOSAJOG TO hEdit9
           gOldEditClassProc = SetWindowLong(hEdit9, %GWL_WNDPROC, CODEPTR(EditASubClassProc))
      CASE %WM_LBUTTONDOWN
          CALL MoveXVel(PosDir)
          CALL GetXyPos
          CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
      CASE %WM_RBUTTONDOWN
          CALL MoveXVel(NegDir)
          CALL GetXyPos
          CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr

      CASE %WM_MOUSEWHEEL
          CALL MoveYVel(NegDir)
          CALL GetXyPos
          CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr

      CASE %WM_MBUTTONDOWN

          CALL MoveYVel(PosDir)
          CALL GetXyPos
          CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr

      CASE %WM_KEYDOWN
           IF CBLPARAM = %VK_UP  THEN
               CALL MoveYVel(PosDir)
               CALL GetXyPos
               CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
               CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
               CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
           ELSEIF CBLPARAM = %VK_DOWN THEN
              CALL MoveYVel(NegDir)
              CALL GetXyPos
              CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
              CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
              CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
           ELSEIF CBLPARAM = %VK_RIGHT THEN
             CALL MoveXVel(PosDir)
             CALL GetXyPos
             CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
             CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
             CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
           ELSEIF CBLPARAM = %VK_LEFT THEN
             CALL MoveXVel(NegDir)
             CALL GetXyPos
             CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
             CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
             CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
          END IF
      CASE %WM_DESTROY

         'Important! Remove the subclassing
          SetWindowLong hEdit9, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION

'=====================  M-Jog call ===================================
CALLBACK FUNCTION BTN_MJOG_CALL()
    LOCAL COUNT AS LONG
    LOCAL  x      AS LONG
    BUILDMJOYWINDOW()
    DIALOG SHOW MODELESS hDlg6, CALL DlgProcMJog
    CALL SetForAuto
    JogMan
    DO
     ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg6 TO x, x
          DIALOG DOEVENTS  0
    LOOP WHILE x&
END FUNCTION

CALLBACK FUNCTION BTN_MJOYSTOP_CALL()
    Exitsub = 1
END FUNCTION

CALLBACK FUNCTION DlgProcMJog () AS LONG
LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
           STATIC  hEdit10 AS LONG
           CONTROL HANDLE CBHNDL, %IDC_LABEL_XPOSMJOG TO hEdit10
           gOldEditClassProc = SetWindowLong(hEdit10, %GWL_WNDPROC, CODEPTR(Edit11SubClassProc))
      CASE %WM_LBUTTONDOWN
          CALL ManXUP
          SetModePwm
          CALL GetXyPos
          CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr
      CASE %WM_RBUTTONDOWN
          CALL ManXDN
          SetModePwm
          CALL GetXyPos
          CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr

      CASE %WM_MOUSEWHEEL
          CALL ManYRGT
          SetModePwm
          CALL GetXyPos
          CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr

      CASE %WM_MBUTTONDOWN

          CALL ManYLFT
          SetModePwm
          CALL GetXyPos
          CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr

      CASE %WM_KEYDOWN
           IF CBLPARAM = %VK_UP  THEN
               CALL ManXUP
               SetModePwm
               CALL GetXyPos
               CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
               CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
               CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr
           ELSEIF CBLPARAM = %VK_DOWN THEN
              CALL ManXDN
              SetModePwm
              CALL GetXyPos
              CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
              CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
              CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr
           ELSEIF CBLPARAM = %VK_RIGHT THEN
             CALL ManYRGT
             SetModePwm
             CALL GetXyPos
             CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
             CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
             CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr
           ELSEIF CBLPARAM = %VK_ESCAPE THEN
             StopMtrs
             SetModeVel
             CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
             CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
             CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr
           ELSEIF CBLPARAM = %VK_LEFT THEN
             CALL ManYLFT
             SetModePwm
             CALL GetXyPos
             CONTROL SET TEXT hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr
             CONTROL SET TEXT hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr
             CONTROL SET TEXT hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr
          END IF
      CASE %WM_DESTROY

         'Important! Remove the subclassing
          SetWindowLong hEdit10, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION


'=====================  AUTOSCAN call ===================================
CALLBACK FUNCTION BTN_AUTOSCAN_CALL()
    'MSGBOX "AUTOSCAN, hit OK to continue",, "Title of subroutine 123"
    LOCAL  x      AS LONG
    BUILDAUTOSCANWINDOW()
    DIALOG SHOW MODELESS hDlg3, CALL DlgProcSetup
    DIALOG ENABLE hDlg3
     DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg3 TO x, x
          DIALOG DOEVENTS  0
    LOOP WHILE x&
END FUNCTION


CALLBACK FUNCTION BTN_AUTOSTOP_CALL()
   CALL StopMtrs
   CALL SetModeVel
   USTOP = FALSE
END FUNCTION


CALLBACK FUNCTION BTN_BEGIN_CALL()
    LOCAL COUNT AS LONG
    LOCAL  x      AS LONG
    BUILDAUTOSCAN()

    DIALOG SHOW MODELESS hDlg7, CALL DlgProcAuto
    CALL Profiler  'make sure scan ok before next scan add or subtract
    CALL SetForAuto
    ReSetMotors
    SetXCtrs  'set x encoder cts to match
   '
    DIALOG ENABLE hDlg7
    CALL GetXyPos
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg7 TO x, x
          DIALOG DOEVENTS TO COUNT
    LOOP WHILE x&
END FUNCTION

CALLBACK FUNCTION DlgProcAuto() AS LONG
LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
          STATIC  hEdit11 AS LONG
          CONTROL HANDLE CBHNDL, %IDC_LABEL_XPOSAUTO TO hEdit11
          gOldEditClassProc = SetWindowLong(hEdit11, %GWL_WNDPROC, CODEPTR(Edit12SubClassProc))
          htimer = SetTimer(CBHNDL, &hFFFF, 1, BYVAL %NULL)
          DIALOG POST CBHNDL, %WM_TIMER, &hFFFF, 0
      CASE %WM_TIMER
           IF SCANstruc.IndexY THEN  'X Scan, Y Index
               CALL XScan
           ELSE : CALL YScan   'Y Scan, X Index
           END IF
            CALL GetXyPos
            CONTROL SET TEXT hDlg7, %IDC_LABEL_XPOSAUTO, SCANstruc.XPosStr
            CONTROL SET TEXT hDlg7, %IDC_LABEL_YPOSAUTO ,SCANstruc.YPosStr
            CONTROL SET TEXT hDlg7, %IDC_LABEL_APOSAUTO, SCANstruc.APosStr
      CASE %WM_KEYDOWN
           IF CBLPARAM = %VK_ESCAPE  THEN
               USTOP=FALSE
           ELSEIF CBLPARAM = %VK_DOWN THEN
               keydown = TRUE
          END IF
      CASE %WM_DESTROY
         'Important!
         KillTimer hDlg7, &hFFFF
         'Important! Remove the subclassing
         SetWindowLong hEdit11, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION

CALLBACK FUNCTION BTN_NEXT_CALL()
END FUNCTION

CALLBACK FUNCTION BTN_ALL0_CALL()
END FUNCTION

'=============== calls  ===========================
CALLBACK FUNCTION BTN_XSPDCTRL_CALL()
    MSGBOX "XSPD CTRL, hit OK to continue",, "Title of subroutine 123"
END FUNCTION

'=============== Save and Load calls  ===========================


CALLBACK FUNCTION BTN_SAVE_CALL()

    DISPLAY SAVEFILE  hdlg, , , "Save File", "", "Cal" + CHR$(0) + "*.cal"+ CHR$(0) ,"","cal",%OFN_OVERWRITEPROMPT TO filename
    IF NOT CalSave(filename) THEN
        MSGBOX "Unable to save file!"
    END IF

END FUNCTION
CALLBACK FUNCTION BTN_LOAD_CALL()
    DISPLAY OPENFILE  hdlg, , , "Load File", "", "Cal" + CHR$(0) + "*.cal"+ CHR$(0) ,"","cal",%OFN_OVERWRITEPROMPT TO filename
    IF NOT CalLoad(filename) THEN
       MSGBOX "Unable to Load file!"
    END IF
END FUNCTION
'===================== Nozzle call ===========================
CALLBACK FUNCTION BTN_SCAN_CALL
     LOCAL ProcessID AS LONG
'     ProcessID& = Shell("Nozzle.exe", 1)  'does not wait
'    SHELL("Nozzle.exe", 1)  'waits
END FUNCTION






CALLBACK FUNCTION DlgProc () AS LONG

LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
          STATIC  hform AS LONG
          CONTROL HANDLE CBHNDL, hDlg TO hform
          gOldEditClassProc = SetWindowLong(hform, %GWL_WNDPROC, CODEPTR(hformsubclass))

      CASE %WM_KEYDOWN
           IF CBLPARAM = %VK_ESCAPE  THEN
                MSGBOX "OKAY"
          END IF
      CASE %WM_DESTROY
         SetWindowLong hform, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION
