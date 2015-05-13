#INCLUDE "mywindowsdef.inc"

'***************************************************************************************************************************************

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

CALLBACK FUNCTION BTN_CALX_CALL()
    ExitSub = 0
    CONTROL SHOW STATE hDlg2, %CALX_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALY_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALA_BUTTON, %SW_HIDE
    CALL CalXEncoder(Servo1)
END FUNCTION

CALLBACK FUNCTION BTN_CALY_CALL
END FUNCTION

CALLBACK FUNCTION BTN_CALA_CALL()
END FUNCTION

SUB CalXEncoder (EncNum)
  GEncNum = EncNum
  CALL StopMtrs
  CALL GetXyPos
  IF GEncNum = Servo1 OR GEncNum = Servo4 THEN
    AxisNum = Servo1
  END IF
  IF AxisNum = Servo1 THEN
     CONTROL SHOW STATE hDlg2, %IDC_EB_STARTEND, %SW_SHOW
     CONTROL SHOW STATE hDlg2, %IDC_LABEL24, %SW_SHOW
     CONTROL SHOW STATE hDlg2, %IDC_LABEL25, %SW_SHOW
     CONTROL SHOW STATE hDlg2, %IDC_LABEL26, %SW_SHOW
  END IF
  IF GEncNum = Servo1 THEN
     CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr
  END IF
END SUB
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
    LOCAL  x      AS LONG
    BUILDCALWINDOW()
    DIALOG SHOW MODELESS hDlg2, CALL DlgProcSetup
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
            CASE %IDC_EB_ACTIN
                CONTROL GET TEXT hDlg1, %IDC_EB_ACTIN TO TXT$
                 IF GoodLNG(TXT$) THEN
                    SCANstruc.ACtr = ABS(VAL(TXT$))
                    SCANstruc.ACtrStr = QStr$(SCANstruc.ACtr, 10)
                 END IF
    'Calibrate x y a
            CASE %IDC_EB_STARTEND

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
FUNCTION Edit9SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         keypress = 1
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_EB_STARTEND  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION

CALLBACK FUNCTION DlgProcSetup () AS LONG
 LOCAL i AS LONG
 LOCAL TXT AS STRING
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
         'Subclass the editbox control
         STATIC hEdit, hEdit1, hEdit2, hEdit3, hEdit4, hEdit5, hEdit6, hEdit7, hEdit8 AS LONG
         CONTROL HANDLE CBHNDL, %IDC_EB_XPLUSMIN TO hEdit
         CONTROL HANDLE CBHNDL, %IDC_EB_YPLUSMIN TO hEdit1
         CONTROL HANDLE CBHNDL, %IDC_EB_INDEX TO hEdit2
         CONTROL HANDLE CBHNDL, %IDC_EB_IDXHL TO hEdit3
         CONTROL HANDLE CBHNDL, %IDC_EB_XONOFF TO hEdit4
         CONTROL HANDLE CBHNDL, %IDC_EB_YONOFF TO hEdit5
         CONTROL HANDLE CBHNDL, %IDC_EB_AUTOHD TO hEdit6
         CONTROL HANDLE CBHNDL, %IDC_EB_DUALRAS TO hEdit7
         CONTROL HANDLE CBHNDL, %IDC_EB_STARTEND TO hEdit8
         gOldEditClassProc = SetWindowLong(hEdit, %GWL_WNDPROC, CODEPTR(EditSubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit1, %GWL_WNDPROC, CODEPTR(Edit2SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit2, %GWL_WNDPROC, CODEPTR(Edit3SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit3, %GWL_WNDPROC, CODEPTR(Edit4SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit4, %GWL_WNDPROC, CODEPTR(Edit5SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit5, %GWL_WNDPROC, CODEPTR(Edit6SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit6, %GWL_WNDPROC, CODEPTR(Edit7SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit7, %GWL_WNDPROC, CODEPTR(Edit8SubClassProc))
         gOldEditClassProc = SetWindowLong(hEdit8, %GWL_WNDPROC, CODEPTR(Edit9SubClassProc))
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
         IF CBCTL = %IDC_EB_STARTEND THEN
            IF CBLPARAM = %VK_RETURN THEN
                LOCAL EndCts AS LONG
                LOCAL StartCts AS LONG
                TXT$     = SPACE$(10)
                CONTROL GET TEXT hDlg2, %IDC_EB_STARTEND TO TXT$
                IF mflag  <> 2 THEN
                    IF AxisNum = Servo1 THEN
                        IF  GEncNum = Servo1 THEN
                            SCANstruc.XCal = VAL(TXT$)
                            SCANstruc.XCalStr = QStr(SCANstruc.XCal, 10)
                        END IF
                    END IF
                    IF ABS(EndCts& - StartCts&) > 0 THEN
                        IF AxisNum = Servo1 THEN
                            IF GEncNum = Servo1 THEN
                             SCANstruc.XCtr = ABS(EndCts& - StartCts&) / SCANstruc.XCal
                             SCANstruc.XCtrStr = QStr(SCANstruc.XCtr, 10)
                            END IF
                        END IF
                    END IF

                    IF AxisNum = Servo1 THEN 'X
                       CONTROL SET TEXT hDlg2, %IDC_LABEL24, "Move X Axis to End  "
                    END IF
                    IF GEncNum = Servo1 THEN
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr
                    END IF
                END IF
                IF MFlag = 2 THEN
                     CONTROL SET TEXT hDlg2, %IDC_LABEL24, ""
                     CONTROL SET TEXT hDlg2, %IDC_LABEL25, ""
                     CONTROL SET TEXT hDlg2, %IDC_LABEL26, "Enter Dis : "
                     CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, "0"
                     MFlag = 0
                     TXT$ = SPACE$(10)
                     CONTROL GET TEXT hDlg2, %IDC_EB_STARTEND TO TXT$
                     IF VAL(TXT$) > 0 THEN
                        IF AxisNum = Servo1 THEN
                           IF GEncNum = Servo1 THEN
                                SCANstruc.XCal = VAL(TXT$)
                                SCANstruc.XCalStr = QStr(SCANstruc.XCal, 10)
                           END IF
                        END IF
                     END IF
                     IF ABS(EndCts& - StartCts&) > 0 THEN
                          IF AxisNum = Servo1 THEN
                            IF GEncNum = Servo1 THEN
                              SCANstruc.XCtr = ABS(EndCts& - StartCts&) / SCANstruc.XCal
                              SCANstruc.XCtrStr = QStr(SCANstruc.XCtr, 10)

                            END IF
                          END IF
                    END IF

                 END IF
            ELSEIF CBLPARAM = %VK_ESCAPE THEN
                CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr
                CALL StopMtrs
            ELSEIF CBLPARAM = %VK_UP THEN
                IF (AxisNum = 1) THEN
                    CALL MoveXVel(PosDir)
                    CALL GetXyPos
                    IF GEncNum = Servo1 THEN
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr
                    END IF
                END IF
                CALL StopMtrs
            END IF
            ELSEIF CBLPARAM = %VK_DOWN THEN
                 MFlag = 2
                IF (AxisNum = 1) THEN
                    CALL MoveXVel(NegDir)
                    CALL GetXyPos
                    IF GEncNum = Servo1 THEN
                        CONTROL SET TEXT hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr
                    END IF
                END IF
                CALL StopMtrs
                CALL GetXyPos
                IF MFlag = 1 THEN      'start position cts
                    IF AxisNum = Servo1 THEN  'X encoder cal
                        IF GEncNum = Servo1 THEN
                            StartCts& = Glo.Position(Servo1)
                        END IF
                    END IF
                    ELSE                   'end position cts
                    IF AxisNum = Servo1 THEN  'X encoder cal
                        IF GEncNum = Servo1 THEN
                            EndCts& = Glo.Position(Servo1)
                        END IF
                    END IF
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
         SetWindowLong hEdit8, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION
