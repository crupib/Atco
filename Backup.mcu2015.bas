#COMPILE EXE
#DIM ALL
#INCLUDE "circle.inc"
#INCLUDE "Win32API.inc"
#RESOURCE ICON, exeICON, "ATCO.ico"
DEFINT A-Z

GLOBAL hDlg, hDlg1 AS DWORD, w, h AS LONG
GLOBAL IsSplashActive AS LONG
'************************************************************************************
'* Motor control globals
GLOBAL filenum AS INTEGER
GLOBAL HdrVer AS STRING * 20
GLOBAL KeyTable() AS STRING
GLOBAL nComm AS LONG
GLOBAL PicPort AS STRING
GLOBAL PicBaud AS LONG
GLOBAL Corr1()  AS BYTE
GLOBAL Corr2()  AS BYTE
GLOBAL LF() AS BYTE
GLOBAL LU() AS BYTE
GLOBAL XVel() AS LONG
GLOBAL YVel() AS LONG
GLOBAL XAcel() AS LONG
GLOBAL YAcel() AS LONG
GLOBAL XSpd()  AS LONG
GLOBAL YSpd()  AS LONG
GLOBAL nComm AS LONG
'************************************************************************************
'* Motor control Functions
DECLARE FUNCTION DelayFact& ()
FUNCTION DelayFact&

   'determine cts per milisec
   LOCAL T,x AS DOUBLE
   LOCAL CtrBegin AS LONG
   LOCAL CtrEnd,Ctr   AS LONG
   T# = TIMER 'times in seconds

   DO
     CtrBegin& = CtrEnd& + 1: CtrEnd& = CtrBegin& + 100000
     FOR Ctr& = CtrBegin& TO CtrEnd&: NEXT
     x# = TIMER - T#  'rollover at midnight, careful here!
   LOOP UNTIL x# > .5 'be > .5 seconds for accuracy and rollover

   DelayFact = Ctr& / (x# * 1000)  'divide counter by 1000 (millisecs)

   EXIT FUNCTION

END FUNCTION

'************************************************************************************
' MCU SUBS
DECLARE SUB SetTables ()
SUB SetTables

  '**************************************************************************
  '                   JoyStick Conversion Table
  '**************************************************************************

  'Correction factor for Left/Right
  FOR x = 0 TO 59
    Corr2(x) = 0   '0 to 29 = 0
  NEXT
  FOR x = 60 TO 100
   Corr2(x) = CINT((x - 60) / 40 * 127)   '30 to 100 = 0 to 127
  NEXT
  FOR x = 100 TO 173
   Corr2(x) = 127     '100 to 173 = 127
  NEXT
  FOR x = 174 TO 255
   Corr2(x) = CINT((x - 174) / 81 * 128) + 127 '174 to 255 = 127 to 255
  NEXT

  'Correction factor for up/dn
  FOR x = 0 TO 29
    Corr1(x) = 0   '0 to 29 = 0
  NEXT
  FOR x = 30 TO 125
   Corr1(x) = CINT((x - 30) / 95 * 127)   '30 to 125 = 0 to 127
  NEXT
  FOR x = 125 TO 150
   Corr1(x) = 127     '125 to 150 = 127
  NEXT
  FOR x = 151 TO 255
   Corr1(x) = CINT((x - 151) / 104 * 128) + 127 '151 to 255 = 127 to 255
  NEXT

  FOR x = 0 TO 63
     LF(x) = CINT(-((63 - x) / 63 * 100)) '0 to 63 = -100% to 0%
     LF(255 - x) = LF(x)                  '255 to 192 =-100% to 0%
  NEXT

  FOR x = 64 TO 127
     LF(x) = CINT((x - 64) / 63 * 100)    '64 to 127 = 0% to 100%
     LF(255 - x) = LF(x)                  '191 to 128 = 0% to 100%
  NEXT

  'Speed table for forward/reverse crawler motion
  FOR x = 127 TO 255
    LU(x) = CINT((x - 127) / 128 * 100)   '127 to 255 = 0% to 100%
  NEXT
  FOR x = 0 TO 126
    LU(x) = CINT((126 - x) / 126 * -100)  '0 to 126 = -100% to 0%
  NEXT

  '**************************************************************************
  '                  End JoyStick Conversion Table
  '**************************************************************************

  'Velocity Mode Tables
  'velocity = (((RPM / 60) * EncCts\Rev) / ServoTics) * 65536
  LOCAL MaxXVel, MaxYVel AS LONG
  MaxXVel& = (((6150 / 60) * 2000) / 1953) * 65536
  MaxYVel& = (((10000 / 60) * 2000) / 1953) * 65536

  'accel = velocity / ( #secstovel * ServoTics )
  FOR x = 0 TO 5
    XVel(x) = 0
    XAcel(x) = 0
    YVel(x) = 0
    YAcel(x) = 0
  NEXT

  FOR x = 6 TO 255
    XVel(x) = CLNG((MaxXVel& / 249) * (x - 6))
    XAcel(x) = CLNG(XVel(x) / (.5 * 1953))
    YVel(x) = CLNG((MaxYVel& / 249) * (x - 6))
    YAcel(x) = CLNG(YVel(x) / (.5 * 1953))
  NEXT

  'speed control tables
  FOR x = 0 TO 5
    XSpd(x) = 0
    YSpd(x) = 0
  NEXT

  FOR x = 6 TO 255
    XSpd(x) = CINT((255 / 249) * (x - 6))
    YSpd(x) = CINT((255 / 249) * (x - 6))
  NEXT


END SUB
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
    LOCAL lResult AS LONG
    CONTROL GET CHECK hDlg, %OPT1 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        central_angle = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT2 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Chord_ab = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT3 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Ed = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT4 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        OE = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT5 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        radius = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        Arc_ab = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT6 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        Chord_AB = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        ED = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT7 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        Chord_AB = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        OE = VAL(TXT$)
    END IF
    CONTROL GET CHECK hDlg, %OPT8 TO lResult&
    IF  lResult <> 0 THEN
        CONTROL GET TEXT hDlg, %IDC_EDITBOX1 TO TXT$
        ED = VAL(TXT$)
        CONTROL GET TEXT hDlg, %IDC_EDITBOX2 TO TXT$
        OE = VAL(TXT$)
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
'#EndIf
FUNCTION PBMAIN () AS LONG
'*******************************************************************************************************
'MCU                                                                                                   *
'*******************************************************************************************************
    DIM HdrVer AS STRING * 20
    DIM ThumbDisk AS STRING * 2
  'COM PORTS
    DIM  RecvSize AS LONG
    DIM  XmitSize AS LONG
    DIM  MemSize AS LONG
    DIM  PICPort AS STRING
    DIM  PICBaud AS LONG
    DIM KeyTable(20) AS STRING
  'delay timer
    DIM  DelayCtr AS LONG
    DIM  WaitX AS INTEGER
    DIM  LF(0 TO 255)
    DIM  LU(0 TO 255)
    DIM  Corr1(0 TO 255) AS BYTE
    DIM  Corr2(0 TO 255) AS BYTE
  'Vel & Accel pot tables
    DIM  XVel(255) AS LONG
    DIM  YVel(255) AS LONG
    DIM  XAcel(255) AS LONG
    DIM  YAcel(255) AS LONG
  'Speed Control tables
    DIM  XSpd(0 TO 255)
    DIM  YSpd(0 TO 255)
  '****************************************************************************************************
    HdrVer = "SCU-1.00"
    ThumbDisk = "C:\UCALS\"
    PICPort ="COM1"
    PICBaud = 19200
    nComm = FREEFILE
    DelayCtr = DelayFact
    WaitX = 1
    'joystick to pwm conversion table
    CALL SetTables
    IsSplashActive = 1
    ShowSplashDlg(5000, "atcosplash.bmp", 1, "MCU 2015",1)

    BUILDWINDOW()
    DIALOG SHOW MODAL hDlg, CALL DlgProc


END FUNCTION
