'Windows consts, variables, routines, etc....

#INCLUDE "CruBas.inc"

%ID_TIMER = 500
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
%ID_Timer = 500
%OPT1 = 1001
%OPT2 = 1002
%OPT3 = 1003
%OPT4 = 1004
%OPT5 = 1005
%OPT6 = 1006
%OPT7 = 1007
%OPT8 = 1008
%OPT9 = 1009
%STOP_JOY = 5000
%STOP_AJOY = 6000
%STOP_MJOY = 11000
%SETUP_BUTTON = 2000
%JOYSTICK_BUTTON = 2010
%AJOG = 2020
%SAVE = 2030
%AUTOSCAN = 2040
%XSPDCTRL = 2050
%MJOG = 2060
%LOAD = 2070
%SCAN = 2090
%CALIBRATEENC = 2080
%CALX_BUTTON = 2081
%CALY_BUTTON = 2082
%CALA_BUTTON  = 2083
%BEGIN = 6000
%NEXT  = 6001
%ALL0  = 6002


GLOBAL hDlg, hDlg1, hDlg2, hDlg3, hDlg4, hDlg5, hDlg6, hDlg7 AS DWORD, w, h AS LONG
GLOBAL gOldEditClassProc AS LONG
GLOBAL keypress AS INTEGER
GLOBAL AxisNum, MFlag, GEncNum AS INTEGER
GLOBAL filename AS STRING
GLOBAL filenumber AS INTEGER


'=====================  Main window ===================================
FUNCTION BUILDWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, 0, "Atco MCU2015",,, w, h,%WS_OVERLAPPEDWINDOW , 0 TO hDlg
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

    CONTROL ADD BUTTON, hDlg,%SCAN, "&Nozzle Scan Plan", 1100, 100, 300, 50,%BS_PUSHLIKE , , _
    CALL BTN_SCAN_CALL()
    CONTROL SET FONT hDlg, %SCAN, NormalFont&

END FUNCTION


'=====================  Setup window ===================================
'===================================================================
FUNCTION BUILDSETUPWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
   ' DIALOG NEW PIXELS, 0, "MCU 2015 Setup",,, w/2, h/2,%WS_OVERLAPPEDWINDOW  , 0 TO hDlg1
    DIALOG NEW PIXELS, hdlg, " MCU 2015 Setup", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg1
    DIALOG SET USER hDlg1, 1, hdlg
    DIALOG SET ICON hDlg1, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg1, %CALIBRATEENC, "Calibrate Encoders", 100, 300, 400, 50,%BS_PUSHLIKE , , _
    CALL BTN_CALENC_CALL()
    CONTROL SET FONT hDlg1, %CALIBRATEENC, NormalFont&

    TXT$ = "X Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XSTART, SCANstruc.XLowStr, 100, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL1, TXT$,    10, 10, 50, 20

    TXT$ = "X End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XEND, SCANstruc.XHighStr, 100, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL2, TXT$, 10,    40, 50, 20

    TXT$ = "Y Start"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YSTART , SCANstruc.YLowStr, 100, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL3, TXT$, 10,     70, 50, 20

    TXT$ = "Y End"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YEND , SCANstruc.YHighStr, 100, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL4, TXT$, 10,     100, 50, 20

    TXT$ = "X Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XINDEX , SCANstruc.XIndexSTR, 100, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL5, TXT$, 10,  130, 50, 20

    TXT$ = "Y Index"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YINDEX , SCANstruc.YIndexSTR, 100, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL6, TXT$, 10,     160, 50, 20

    TXT$ = "X Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XSPEED , SCANstruc.XSpeedSTR, 100, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL7, TXT$, 10,     190, 50, 20

    TXT$ = "Y Speed"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YSPEED , SCANstruc.YSpeedSTR, 100, 220, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL8, TXT$, 10,     220, 50, 20

    TXT$ = "X POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XPOS, SCANstruc.XPosStr, 410, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL9, TXT$,    300, 10, 50, 20

    TXT$ = "Y POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YPOS, SCANstruc.YPosStr, 410, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL10, TXT$, 300,    40, 50, 20

    TXT$ = "X CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XCTIN , SCANstruc.XCtrStr, 410, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL11, TXT$, 300,     70, 50, 20

    TXT$ = "Y CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YCTIN , SCANstruc.YCtrStr, 410, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL12, TXT$, 300,     100, 50, 20

    TXT$ = "X +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XPLUSMIN , SCANstruc.XPlusSTR, 410, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL13, TXT$, 300,     130, 50, 20

    TXT$ = "Y +/-"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YPLUSMIN , SCANstruc.YPlusSTR, 410, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL14, TXT$, 300,     160, 50, 20

    TXT$ = "INDEX"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_INDEX , SCANstruc.IndexYSTR, 410, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL15, TXT$, 300,     190, 50, 20

    TXT$ = "IDX H/L"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_IDXHL, SCANstruc.IndexLowStr, 410, 220, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL16, TXT$, 300,     220, 50, 20

    TXT$ = "X ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_XONOFF, SCANstruc.XEnableSTR, 730, 10, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL17, TXT$,    600, 10, 60, 20

    TXT$ = "Y ON/OFF"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_YONOFF, SCANstruc.YEnableSTR, 730, 40, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL18, TXT$, 600,    40, 60, 20

    TXT$ = "AUTO HD"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_AUTOHD , SCANstruc.AutoHoldSTR, 730, 70, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL19, TXT$, 600,     70, 60, 20

    TXT$ = "DUALRAS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_DUALRAS ,SCANstruc.DualRasSTR, 730, 100, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL20, TXT$, 600,     100, 60, 20

    TXT$ = "OVERLAP"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_OVERLAP , SCANstruc.OverLapStr, 730, 130, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL21, TXT$, 600,     130, 60, 20

    TXT$ = "A POS"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_APOS , SCANstruc.APosStr, 730, 160, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL22, TXT$, 600,     160, 60, 20

    TXT$ = "A CT/IN"
    CONTROL ADD TEXTBOX, hDlg1, %IDC_EB_ACTIN, SCANstruc.ACtrStr, 730, 190, 80, 20, , , _
    CALL EditControlCallback() ' Use default styles
    CONTROL ADD LABEL, hDlg1, %IDC_LABEL23, TXT$, 600,     190, 60, 20

 END FUNCTION

'=====================  Calibrate window ===================================
 FUNCTION BUILDCALWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, hdlg, "MCU 2015 Calibrate Encoders", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg2
    DIALOG SET USER hDlg2, 1, hdlg
    DIALOG SET ICON hDlg2, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg2, %CALX_BUTTON, "CAL &X Encoder", 100, 100, 300, 50,%BS_PUSHLIKE , , _
    CALL BTN_CALX_CALL()
    CONTROL SET FONT hDlg2, %CALX_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg2, %CALY_BUTTON, "CAL &Y Encoder", 100, 200, 300, 50,%BS_PUSHLIKE , , _
    CALL BTN_CALY_CALL()
    CONTROL SET FONT hDlg2, %CALY_BUTTON, NormalFont&

    CONTROL ADD BUTTON, hDlg2,%CALA_BUTTON, "CAL &A Encoder", 100, 300, 300, 50,%BS_PUSHLIKE , , _
    CALL BTN_CALA_CALL()
    CONTROL SET FONT hDlg2, %CALA_BUTTON, NormalFont&

    TXT$ = "Move X Axis to Start"
    CONTROL ADD LABEL, hDlg2, %IDC_LABEL24, TXT$,    550, 20, 100, 20
    TXT$ = "Pos; Press Enter Key"
    CONTROL ADD LABEL, hDlg2, %IDC_LABEL25, TXT$,    550, 50, 150, 20
    TXT$ = "X Pos: "
    CONTROL ADD LABEL, hDlg2, %IDC_LABEL26, TXT$,    550, 100, 150, 20
    CONTROL ADD TEXTBOX, hDlg2, %IDC_EB_STARTEND, SCANstruc.XPosStr, 850, 100, 80, 20,%WS_TABSTOP  , , _
    CALL EditControlCallback() ' Use default styles

    CONTROL SHOW STATE hDlg2, %IDC_EB_STARTEND, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %IDC_LABEL24, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %IDC_LABEL25, %SW_HIDE
    CONTROL SHOW STATE hDlg2, %IDC_LABEL26, %SW_HIDE
END FUNCTION


'=====================  Auto Scan 1st window ===================================
FUNCTION BUILDAUTOSCANWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, hdlg, "MCU 2015 Auto Scan", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg3
    DIALOG SET USER hDlg3, 1, hdlg
    DIALOG SET ICON hDlg3, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD BUTTON, hDlg3,%BEGIN, "&Begin", 600, 400, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_BEGIN_CALL()
    CONTROL SET FONT hDlg3, %BEGIN, NormalFont&

    CONTROL ADD BUTTON, hDlg3,%NEXT, "&Next", 600, 500, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_NEXT_CALL()
    CONTROL SET FONT hDlg3, %NEXT, NormalFont&

    CONTROL ADD BUTTON, hDlg3,%ALL0, "&All0", 600, 600, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_ALL0_CALL()
    CONTROL SET FONT hDlg3, %ALL0, NormalFont&

    TXT$ = "X Pos: "
    CONTROL ADD LABEL, hDlg3, %IDC_LABEL40, TXT$,    550, 100, 150, 20
    TXT$ = "Y Pos: "
    CONTROL ADD LABEL, hDlg3, %IDC_LABEL41, TXT$,    550, 150, 150, 20
    TXT$ = "A Pos: "
    CONTROL ADD LABEL, hDlg3, %IDC_LABEL42, TXT$,    550, 200, 150, 20
    TXT$ = ""
    CONTROL ADD LABEL, hDlg3, %IDC_LABEL_XPOSASCAN, SCANstruc.XPosStr, 850, 100, 80, 20
    CONTROL ADD LABEL, hDlg3, %IDC_LABEL_YPOSASCAN, SCANstruc.YPosStr, 850, 150, 80, 20
    CONTROL ADD LABEL, hDlg3, %IDC_LABEL_APOSASCAN, SCANstruc.APosStr, 850, 200, 80, 20,

END FUNCTION
'=====================  Auto scan running window ===================================
FUNCTION BUILDAUTOSCAN() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, hdlg, "MCU 2015 Auto Scan Begin", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg7
    DIALOG SET USER hDlg7, 1, hdlg
    DIALOG SET ICON hDlg7, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD LABEL, hDlg7, %IDC_LABEL_XPOSAUTO, SCANstruc.XPosStr, 850, 100, 80, 20 ,%WS_TABSTOP
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL_YPOSAUTO, SCANstruc.YPosStr, 850, 150, 80, 20
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL_APOSAUTO, SCANstruc.APosStr, 850, 200, 80, 20,
    CONTROL ADD BUTTON, hDlg7, %STOP_AUTO, "Stop Auto Scan", 100, 100, 200, 50,%BS_PUSHLIKE , , _
            CALL BTN_AUTOSTOP_CALL()

    TXT$ = "* Check Motors On *"
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL100, TXT$,    550, 20, 150, 20
    TXT$ = "*  Press Any Key  *"
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL101, TXT$,    550, 50, 150, 20

    TXT$ = "X Pos: "
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL102, TXT$,    550, 100, 150, 20
    TXT$ = "Y Pos: "
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL103, TXT$,    550, 150, 150, 20
    TXT$ = "A Pos: "
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL104, TXT$,    550, 200, 150, 20

    TXT$ = "Keyboard short cuts:"
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL105, TXT$,    550, 250, 150, 20

    TXT$ = "X POS <-"
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL106, TXT$,    550, 280, 150, 20
    TXT$ = "X NEG ->"
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL107, TXT$,    550, 310, 150, 20

    TXT$ = "Y POS ^"
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL108, TXT$,    550, 340, 100, 20
    TXT$ = "Y NEG v"
    CONTROL ADD LABEL, hDlg7, %IDC_LABEL109, TXT$,    550, 370, 150, 20

END FUNCTION

'===================== A-Jog window ===================================
FUNCTION BUILDAJOGWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, hdlg, "MCU 2015 Auto Jog", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg5
    DIALOG SET USER hDlg5, 1, hdlg
    DIALOG SET ICON hDlg5, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    CONTROL ADD LABEL, hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr, 850, 100, 80, 20 ,%WS_TABSTOP
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr, 850, 150, 80, 20
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr, 850, 200, 80, 20,
    CONTROL ADD BUTTON, hDlg5, %STOP_AJOY, "Stop AJOG", 100, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_AJOGSTOP_CALL()

    TXT$ = "* Check Motors On *"
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL32, TXT$,    550, 20, 150, 20
    TXT$ = "*  Press Any Key  *"
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL33, TXT$,    550, 50, 150, 20

    TXT$ = "X Pos: "
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL34, TXT$,    550, 100, 150, 20
    TXT$ = "Y Pos: "
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL35, TXT$,    550, 150, 150, 20
    TXT$ = "A Pos: "
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL36, TXT$,    550, 200, 150, 20


    TXT$ = "Keyboard short cuts:"
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL54, TXT$,    550, 250, 150, 20

    TXT$ = "X POS <-"
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL50, TXT$,    550, 280, 150, 20
    TXT$ = "X NEG ->"
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL51, TXT$,    550, 310, 150, 20

    TXT$ = "Y POS ^"
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL52, TXT$,    550, 340, 100, 20
    TXT$ = "Y NEG v"
    CONTROL ADD LABEL, hDlg5, %IDC_LABEL53, TXT$,    550, 370, 150, 20

END FUNCTION

'=====================  M-Jog window ===================================
FUNCTION BUILDMJOYWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, hdlg, "MCU 2015 Manual Jog", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg6
    DIALOG SET USER hDlg6, 1, hdlg
    DIALOG SET ICON hDlg6, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    TXT$ = "* Check Motors On *"
    CONTROL ADD LABEL, hDlg6, %IDC_LABEL80, TXT$,    550, 20, 150, 20
    TXT$ = "*  Press Any Key  *"
    CONTROL ADD LABEL, hDlg6, %IDC_LABEL81, TXT$,    550, 50, 150, 20
    TXT$ = "X Pos: "
    CONTROL ADD LABEL, hDlg6, %IDC_LABEL82, TXT$,    550, 100, 150, 20
    TXT$ = "Y Pos: "
    CONTROL ADD LABEL, hDlg6, %IDC_LABEL83, TXT$,    550, 150, 150, 20
    TXT$ = "A Pos: "
    CONTROL ADD LABEL, hDlg6, %IDC_LABEL84, TXT$,    550, 200, 150, 20
    TXT$ = ""

    CONTROL ADD LABEL, hDlg6, %IDC_LABEL_XPOSMJOG, SCANstruc.XPosStr, 850, 100, 80, 20, %WS_TABSTOP
    CONTROL ADD LABEL, hDlg6, %IDC_LABEL_YPOSMJOG, SCANstruc.YPosStr, 850, 150, 80, 20
    CONTROL ADD LABEL, hDlg6, %IDC_LABEL_APOSMJOG, SCANstruc.APosStr, 850, 200, 80, 20,
    CONTROL ADD BUTTON, hDlg6, %STOP_MJOY, "Stop Manual JoyStick", 100, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_MJOYSTOP_CALL()
END FUNCTION

'=====================  JoyStick window ===================================
FUNCTION BUILDJOYWINDOW() AS LONG
    LOCAL exeICON AS STRING
    LOCAL lResult AS LONG
    LOCAL TXT AS STRING
    exeICON = "exeICON"
    LOCAL NormalFont&
    DESKTOP GET SIZE TO w, h
    DIALOG NEW PIXELS, hdlg, "MCU 2015 JoyStick", 0, 0, w, h, %WS_OVERLAPPEDWINDOW, TO hDlg4
    DIALOG SET USER hDlg4, 1, hdlg
    DIALOG SET ICON hDlg4, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&

    TXT$ = "* Check Motors On *"
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL27, TXT$,    550, 20, 150, 20
    TXT$ = "*  Press Any Key  *"
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL28, TXT$,    550, 50, 150, 20
    TXT$ = "X Pos: "
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL29, TXT$,    550, 100, 150, 20
    TXT$ = "Y Pos: "
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL30, TXT$,    550, 150, 150, 20
    TXT$ = "A Pos: "
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL31, TXT$,    550, 200, 150, 20
    TXT$ = ""
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL_XPOSPRINT, SCANstruc.XPosStr, 850, 100, 80, 20
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL_YPOSPRINT, SCANstruc.YPosStr, 850, 150, 80, 20
    CONTROL ADD LABEL, hDlg4, %IDC_LABEL_APOSPRINT, SCANstruc.APosStr, 850, 200, 80, 20,
    CONTROL ADD BUTTON, hDlg4, %STOP_JOY, "Stop JoyStick", 100, 100, 200, 50,%BS_PUSHLIKE , , _
    CALL BTN_JOYSTOP_CALL()
END FUNCTION


'=============== Edit Control  call back ==================================
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
                MSGBOX TXT$
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
'============= Edit Sub Classing ======================================================
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
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN, %IDC_EB_DUALRAS  , wParm&
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
FUNCTION EditASubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         keypress = 1
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_LABEL_XPOSAJOG  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit11SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         keypress = 1
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_LABEL_XPOSMJOG  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit12SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_LABEL_XPOSAUTO  , wParm&
         USTOP = FALSE
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
