'***************************************************************************************************************************************
DECLARE SUB ShowSplashDlg(BYVAL nDelay AS LONG, BYVAL sBitmapID AS STRING, _
                          BYVAL IsFile AS LONG, OPTIONAL BYVAL sAppName AS STRING, _
                          OPTIONAL BYVAL nModeless AS LONG)

CALLBACK FUNCTION BTN_SETUP_CALL()
    DIALOG END hDlg
    BUILDSETUPWINDOW()
    DIALOG SHOW MODAL hDlg1, CALL DlgProc
    BUILDWINDOW()
    DIALOG SHOW MODAL hDlg, CALL DlgProc
END FUNCTION
CALLBACK FUNCTION BTN_JOYSTICK_CALL()
    MSGBOX "JoyStick, hit OK to continue",, "Title of subroutine 123"
END FUNCTION
CALLBACK FUNCTION BTN_AJOG_CALL()
    MSGBOX "A-Jog, hit OK to continue",, "Title of subroutine 123"
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

    CONTROL ADD BUTTON, hDlg, %SETUP_BUTTON, "Setup", 100, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_SETUP_CALL()
    CONTROL SET FONT hDlg, %SETUP_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg, %JOYSTICK_BUTTON, "Joy Stick", 100, 200, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_JOYSTICK_CALL()
    CONTROL SET FONT hDlg, %JOYSTICK_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg,%AJOG, "A-Jog", 100, 300, 200, 50,%BS_PUSHLIKE , , _
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

    CONTROL ADD BUTTON, hDlg,%MJOG, "M-Jog", 600, 300, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_MJOG_CALL()
    CONTROL SET FONT hDlg, %MJOG, NormalFont&

    CONTROL ADD BUTTON, hDlg,%LOAD, "Load", 600, 400, 200, 50,%BS_PUSHLIKE , , _
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
    DIALOG NEW PIXELS, 0, "MCU 2015 Setup",,, w/2, h/2,%WS_OVERLAPPEDWINDOW  , 0 TO hDlg1
    DIALOG SET ICON hDlg1, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg1, %CALIBRATEENC, "Calibrate Encoders", 10, 400, 400, 50,%BS_PUSHLIKE , , _
    CALL BTN_CALENC_CALL()
    CONTROL SET FONT hDlg1, %CALIBRATEENC, NormalFont&

    TXT$ = "X Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX1, "", 100, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL1, TXT$,    10, 10, 50, 20

    TXT$ = "X End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX2, "", 100, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL2, TXT$, 10,    40, 50, 20

    TXT$ = "Y Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX3 , "", 100, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL3, TXT$, 10,     70, 50, 20

    TXT$ = "Y End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX4 , "", 100, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL4, TXT$, 10,     100, 50, 20

    TXT$ = "X Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX5 , "", 100, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL5, TXT$, 10,     130, 50, 20

    TXT$ = "Y Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX6 , "", 100, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL6, TXT$, 10,     160, 50, 20

    TXT$ = "X Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX7 , "", 100, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL7, TXT$, 10,     190, 50, 20

    TXT$ = "Y Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX8 , "", 100, 220, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL8, TXT$, 10,     220, 50, 20

    TXT$ = "X POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX9, "", 410, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL9, TXT$,    300, 10, 50, 20

    TXT$ = "Y POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX10, "", 410, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL10, TXT$, 300,    40, 50, 20

    TXT$ = "X CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX11 , "", 410, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL11, TXT$, 300,     70, 50, 20

    TXT$ = "Y CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX12 , "", 410, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL12, TXT$, 300,     100, 50, 20

    TXT$ = "X +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX12 , "", 410, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL5, TXT$, 300,     130, 50, 20

    TXT$ = "Y +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX13 , "", 410, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL13, TXT$, 300,     160, 50, 20

    TXT$ = "INDEX"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX14 , "", 410, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL14, TXT$, 300,     190, 50, 20

    TXT$ = "IDX H/L"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX15 , "", 410, 220, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL15, TXT$, 300,     220, 50, 20

    TXT$ = "X ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX20, "", 730, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL20, TXT$,    600, 10, 60, 20

    TXT$ = "Y ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX21, "", 730, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL21, TXT$, 600,    40, 60, 20

    TXT$ = "AUTO HD"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX22 , "", 730, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL22, TXT$, 600,     70, 60, 20

    TXT$ = "DUALRAS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX23 , "", 730, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL23, TXT$, 600,     100, 60, 20

    TXT$ = "OVERLAP"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX24 , "", 730, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL24, TXT$, 600,     130, 60, 20

    TXT$ = "A POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX25 , "", 730, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL13, TXT$, 600,     160, 60, 20

    TXT$ = "A CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EDITBOX25, "", 730, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL25, TXT$, 600,     190, 60, 20

 END FUNCTION

CALLBACK FUNCTION EditControlCallback()
    LOCAL TXT AS STRING
    LOCAL lResult AS LONG
    CONTROL GET CHECK hDlg, %OPT1 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
    '    central_angle = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT2 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        'radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
     '   Chord_ab = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT3 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
      '  Ed = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT4 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
    '    radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
     '   OE = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT5 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
     '   radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
     '   Arc_ab = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT6 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
     '   Chord_AB = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
     '   ED = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT7 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
     '   Chord_AB = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
     '   OE = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT8 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
   '     ED = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
  '      OE = VAL(TXT$)
    END IF

END FUNCTION
CALLBACK FUNCTION DlgProc () AS LONG
    LOCAL temp$
    SELECT CASE CB.MSG
        CASE %WM_INITDIALOG   ' <- Sent right before the dialog is shown
        CASE %WM_COMMAND      ' <- A control is calling
            SELECT CASE CB.CTL  ' <- Look at control's id
            CASE %IDCANCEL
             IF CB.CTLMSG = %BN_CLICKED THEN ' Exit on Esc
                DIALOG END CB.HNDL
             END IF
            END SELECT
         CASE %WM_NOTIFY
            SELECT CASE CB.NMID
                CASE %IDC_UpDown
                 SELECT CASE CB.NMCODE
                  CASE %UDN_DeltaPOS
                     LOCAL UPD AS NMUPDOWN PTR
                     UPD = CB.LPARAM
                     'old value will be @upd.iPos
                     'change (delta) to old value will be @upd.iDelta
               END SELECT
         END SELECT
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
    IF nDelay = 0 THEN nDelay = 2500

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
