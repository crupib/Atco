#INCLUDE "mywindowsdef.inc"

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

CALLBACK FUNCTION BTN_CALX_CALL()
    ExitSub = 0
    CONTROL SHOW STATE hDlg2, %CALX_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALY_BUTTON, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %CALA_BUTTON, %SW_HIDE
    CALL CalEncoder(Servo1)
END FUNCTION

CALLBACK FUNCTION BTN_CALY_CALL
END FUNCTION

CALLBACK FUNCTION BTN_CALA_CALL()
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

CALLBACK FUNCTION BTN_AJOGSTOP_CALL()
    CALL StopMtrs
    SetModeVel 'sets vel to 0
END FUNCTION
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
CALLBACK FUNCTION DlgProcAJog () AS LONG
LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
<<<<<<< HEAD
           STATIC  hEdit9 AS LONG
           CONTROL HANDLE CBHNDL, %IDC_LABEL_XPOSAJOG TO hEdit9
           gOldEditClassProc = SetWindowLong(hEdit9, %GWL_WNDPROC, CODEPTR(EditASubClassProc))
=======

>>>>>>> d19fb3555cf8673cd7a5cfdaf64962bbca4dfa9d
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
<<<<<<< HEAD
      CASE  %WM_MBUTTONDOWN
=======
      CASE %WM_MOUSEWHEEL
>>>>>>> d19fb3555cf8673cd7a5cfdaf64962bbca4dfa9d
          CALL MoveYVel(NegDir)
          CALL GetXyPos
          CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
<<<<<<< HEAD
      CASE %WM_MOUSEWHEEL
=======
      CASE %WM_MBUTTONDOWN
>>>>>>> d19fb3555cf8673cd7a5cfdaf64962bbca4dfa9d
          CALL MoveYVel(PosDir)
          CALL GetXyPos
          CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
          CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
      CASE %WM_DESTROY

         'Important! Remove the subclassing
          SetWindowLong hEdit9, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
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
CALLBACK FUNCTION BTN_BEGIN_CALL()
END FUNCTION
CALLBACK FUNCTION BTN_NEXT_CALL()
END FUNCTION
CALLBACK FUNCTION BTN_ALL0_CALL()
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

CALLBACK FUNCTION DlgProc () AS LONG
' Empty
END FUNCTION
GLOBAL hTimer AS LONG

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
         'Important! Remove the subclassing
         KillTimer hDlg4, &hFFFF
   END SELECT
END FUNCTION

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

            ELSEIF CBLPARAM = %VK_ESCAPE THEN
                CALL StopMtrs
            END IF
         END IF
      CASE %WM_DESTROY
         'Important! Remove the subclassing
         SetWindowLong hEdit8, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
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
