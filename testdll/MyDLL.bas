'===============================================================================
'
'  Generic DLL Template for PowerBASIC for Windows
'  Copyright (c) 1997-2011 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  LIBMAIN function Purpose:
'
'    User-defined function called by Windows each time a DLL is loaded into,
'    and unloaded from, memory. In 32-bit Windows, LibMain is called each
'    time a DLL is loaded by an application or process.  Your code should
'    never call LibMain explicitly.
'
'    hInstance is the DLL instance handle.  This handle is used by the
'    calling application to identify the DLL being called.  To access
'    resources in the DLL, this handle will need to be stored in a global
'    variable.  Use the GetModuleHandle(BYVAL 0&) to get the instance
'    handle of the calling EXE.
'
'    fdwReason specifies a flag indicating why the DLL entry-point
'    (LibMain) is being called by Windows.
'
'    lpvReserved specifies further aspects of the DLL initialization
'    and cleanup.  If fdwReason is %DLL_PROCESS_ATTACH, lpvReserved is
'    NULL (zero) for dynamic loads and non-NULL for static loads.  If
'    fdwReason is %DLL_PROCESS_DETACH, lpvReserved is NULL if LibMain
'    has been called by using the FreeLibrary API call and non-NULL if
'    LibMain has been called during process termination.
'
' Return
'
'    If LibMain is called with %DLL_PROCESS_ATTACH, your LibMain function
'    should return a zero (0) if any part of your initialization process
'    fails or a one (1) if no errors were encountered.  If a zero is
'    returned, Windows will abort and unload the DLL from memory. When
'    LibMain is called with any other value than %DLL_PROCESS_ATTACH, the
'    return value is ignored.
'
'===============================================================================

#COMPILER PBWIN 10
#COMPILE DLL

#INCLUDE ONCE "Win32api.inc"
MACRO CONST = MACRO
CONST TRUE = -1
CONST FALSE = 0
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
%IDC_LABSPIN = 125
%IDC_EB_STARTEND = 3008
%DoneBtn = 127
TYPE ScanParms
   YCtr          AS SINGLE       'YCts/inch
   XCtr          AS SINGLE       'XCts/inch
   ACtr          AS SINGLE       'Aux Enc Cts/inch
   YCal          AS SINGLE       'Y Cal Inch distance
   XCal          AS SINGLE       'X Cal Inch distance
   ACal          AS SINGLE       'Aux Cal Inch distance
   XOffset       AS SINGLE       'X inch pos when counter zeroed
   YOffset       AS SINGLE       'Y inch pos when counter zeroed
   AOffset       AS SINGLE       'A Inch pos when counter zeroed
   XPos          AS SINGLE       'current X inch position
   YPos          AS SINGLE       'current Y inch position
   APos          AS SINGLE       'current A inch position
   XPlus         AS INTEGER      'X scan +/-
   YPlus         AS INTEGER      'Y scan +/-
   XDataStart    AS LONG         'x array position for scan start
   YDataStart    AS LONG         'y array position for scan start
   XDataEnd      AS LONG         'x array position for scan end
   YDataEnd      AS LONG         'y array position for scan end
   XIndex        AS SINGLE       'x inch index
   YIndex        AS SINGLE       'y inch index
   XIndexCts     AS LONG         'x actual value (+/-) counts per index
   YIndexCts     AS LONG         'y actual value (+/-) counts per index
   IndexLow      AS INTEGER      'Index towards High or Low
   XCts          AS LONG         'x absolute value scan start counts
   YCts          AS LONG         'y absolute value scan start counts
   ACts          AS LONG         'A absolute value scan start counts
   XStartCts     AS LONG         'x actual value (+/-) scan start counts
   YStartCts     AS LONG         'y actual value (+/-) scan start counts
   XEndCts       AS LONG         'x actual value (+/-) scan end counts
   YEndCts       AS LONG         'y actual value (+/-) scan end counts
   XLow          AS SINGLE       'x scan start inch position
   YLow          AS SINGLE       'y scan start inch position
   XHigh         AS SINGLE       'x scan end inch position
   YHigh         AS SINGLE       'y scan end inch position
   OverLap       AS SINGLE       'added si scan overlap
   XSpeed        AS SINGLE       'x scan speed in inches
   YSpeed        AS SINGLE       'y scan speed in inches
   XEnable       AS INTEGER      'flag true/false X axis on
   YEnable       AS INTEGER      'flag true/false Y axis on
   XSpdDir       AS INTEGER      'flag X speed cntrl direction
   IndexY        AS INTEGER      'flag true/false X or Y
   StopChk       AS INTEGER      'flag true/false autoOff on/off
   DualRas     AS INTEGER      'flag true/false step index
   AutoHold      AS INTEGER      'flag true/false Auto Hold
   IndexCt AS INTEGER            'index loop counter
   IndexInc AS INTEGER           'index loop incrementer
   ScanFlag AS INTEGER           '
   Index AS INTEGER              'scan direction
   NextFlag AS INTEGER           'added for si auto scan increment
   YCtrStr AS STRING * 10
   XCtrStr AS STRING * 10
   ACtrStr AS STRING * 10
   YCalStr AS STRING * 10      'Y Cal Inch distance
   XCalStr AS STRING * 10      'X Cal Inch distance
   ACalStr AS STRING * 10      'A Cal Inch distance
   XPosStr AS STRING * 10
   YPosStr AS STRING * 10
   APosStr AS STRING * 10
   XPlusSTR AS STRING * 10
   YPlusSTR AS STRING * 10
   XIndexSTR AS STRING * 10
   YIndexSTR AS STRING * 10
   IndexLowStr AS STRING * 10
   XLowStr AS STRING * 10
   YLowStr AS STRING * 10
   XHighStr AS STRING * 10
   YHighStr AS STRING * 10
   OverLapStr AS STRING * 10
   XSpeedSTR AS STRING * 10
   YSpeedSTR AS STRING * 10
   XEnableSTR AS STRING * 10
   YEnableSTR AS STRING * 10
   XSpdDirSTR AS STRING * 10
   IndexYSTR AS STRING * 10
   StopChkSTR AS STRING * 10
   DualRasSTR AS STRING * 10
   NextFlagSTR AS STRING * 10
   AutoHoldSTR AS STRING * 10
  END TYPE
GLOBAL SCANstruc AS scanparms
GLOBAL ghInstance AS DWORD
GLOBAL hDlg, hDlg1, hDlg2, hDlg3, hDlg4, hDlg5, hDlg6, hDlg7 AS DWORD, w, h AS LONG
GLOBAL gOldEditClassProc AS LONG
DECLARE FUNCTION QStr (BYVAL Amount!, BYVAL Places AS INTEGER) AS STRING
GLOBAL done_edit AS BYTE
'-------------------------------------------------------------------------------
' Main DLL entry point called by Windows...
'
FUNCTION LIBMAIN (BYVAL hInstance   AS LONG, _
                  BYVAL fwdReason   AS LONG, _
                  BYVAL lpvReserved AS LONG) AS LONG

    SELECT CASE fwdReason

    CASE %DLL_PROCESS_ATTACH
        'Indicates that the DLL is being loaded by another process (a DLL
        'or EXE is loading the DLL).  DLLs can use this opportunity to
        'initialize any instance or global data, such as arrays.

        ghInstance = hInstance

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!  This will prevent the EXE from running.

    CASE %DLL_PROCESS_DETACH
        'Indicates that the DLL is being unloaded or detached from the
        'calling application.  DLLs can take this opportunity to clean
        'up all resources for all threads attached and known to the DLL.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_ATTACH
        'Indicates that the DLL is being loaded by a new thread in the
        'calling application.  DLLs can use this opportunity to
        'initialize any thread local storage (TLS).

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    CASE %DLL_THREAD_DETACH
        'Indicates that the thread is exiting cleanly.  If the DLL has
        'allocated any thread local storage, it should be released.

        FUNCTION = 1   'success!

        'FUNCTION = 0   'failure!

    END SELECT

END FUNCTION


'-------------------------------------------------------------------------------
' Examples of exported Subs and functions...
'
'FUNCTION MyFunction1 ALIAS "MyFunction1" (BYVAL Param1 AS LONG) EXPORT AS LONG
'    ' code goes here
'    MSGBOX "MYDLL.DLL has recevied: " + STR$(Param1)
'    FUNCTION = 1  ' return 1 to calling program
'END FUNCTION
FUNCTION MyFunction1 ALIAS "MyFunction1" (BYVAL Param1 AS LONG) EXPORT AS LONG
      LOCAL ProcessID AS LONG
     ProcessID& = SHELL("mcu2015.exe", 1)  'does not wait
'    SHELL("Nozzle.exe", 1)  'waits
END FUNCTION

FUNCTION LOAD_FILE ALIAS "Load_File" () EXPORT AS STRING
    LOCAL filename AS STRING
    DISPLAY OPENFILE  0, , , "Load File", "", "Cal" + CHR$(0) + "*.cal"+ CHR$(0) ,"","cal",%OFN_OVERWRITEPROMPT TO filename
    Load_FILE =  filename
END FUNCTION

FUNCTION SAVE_FILE ALIAS "Save_File" () EXPORT AS STRING
    LOCAL filename AS STRING
    DISPLAY SAVEFILE  0, , , "Save File", "", "Cal" + CHR$(0) + "*.cal"+ CHR$(0) ,"","cal",%OFN_OVERWRITEPROMPT TO filename
    SAVE_FILE =  filename
END FUNCTION

FUNCTION SETUP_CALL(BYREF parm1 AS scanparms)  EXPORT AS STRING
    LOCAL  x      AS LONG
    SCANstruc = parm1
    done_edit = false
    BUILDSETUPWINDOW()
    DIALOG SHOW MODELESS hDlg1, CALL DlgProcSetup
    DIALOG ENABLE hDlg1
    SCANstruc = parm1
    DIALOG SHOW STATE hDlg1, %SW_SHOWNORMAL
    DO
          ' Allow messages to be dispatched
          DIALOG GET SIZE hDlg1 TO x, x
          DIALOG DOEVENTS  0
    LOOP WHILE x&
    parm1 = scanstruc
    setup_call = "return"
END FUNCTION
CALLBACK FUNCTION DoneBtn_call() AS BYTE
     DIALOG END CB.HNDL
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
               'SCANstruc.IndexLow = FALSE
               'SCANstruc.IndexLowStr = "LOW - HIGH"
               CONTROL SET TEXT hDlg1, %IDC_EB_IDXHL, "LOW - HIGH"
            END IF
         END IF
         IF CBCTL = %IDC_EB_XONOFF THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.XEnable = FALSE
                SCANstruc.XEnableSTR = "OFF       "
                'CALL EnableAmpl(SCANstruc.XEnable, Servo1)
                'CALL EnableAmpl(SCANstruc.XEnable, Servo2)
                CONTROL SET TEXT hDlg1, %IDC_EB_XONOFF, "OFF       "
            ELSEIF CBLPARAM = %VK_LEFT THEN
                SCANstruc.XEnable = TRUE
                SCANstruc.XEnableSTR = "ON        "
                'CALL StopXMtrs
                CONTROL SET TEXT hDlg1, %IDC_EB_XONOFF, "ON        "
            END IF
         END IF
         IF CBCTL = %IDC_EB_YONOFF THEN
            IF CBLPARAM = %VK_RIGHT THEN
                SCANstruc.YEnable = FALSE
                SCANstruc.YEnableSTR = "OFF       "
                'CALL EnableAmpl(SCANstruc.YEnable, Servo1)
                'CALL EnableAmpl(SCANstruc.YEnable, Servo2)
                CONTROL SET TEXT hDlg1, %IDC_EB_YONOFF, "OFF       "
            ELSEIF CBLPARAM = %VK_LEFT THEN
                SCANstruc.YEnable = TRUE
                SCANstruc.YEnableSTR = "ON        "
                'CALL StopYMtr
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
         SetWindowLong hEdit,  %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit1, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit2, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit3, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit4, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit5, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit6, %GWL_WNDPROC, gOldEditClassProc
         SetWindowLong hEdit7, %GWL_WNDPROC, gOldEditClassProc

   END SELECT
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
    DIALOG NEW PIXELS, hdlg, " MCU 2015 Setup", w/4, h/4, 1000, 600, %WS_OVERLAPPEDWINDOW, TO hDlg1
    DIALOG SET USER hDlg1, 1, hdlg
    DIALOG SET ICON hDlg1, exeICON$   '
    FONT NEW "myfont1",20 , 0, 0, 1 TO NormalFont&
    GRAPHIC SET FONT NormalFont&



    CONTROL ADD BUTTON, hDlg1, %DoneBtn, "Done", 100, 500, 400, 50, %BS_PUSHLIKE , , _
    CALL DoneBtn_call()
    CONTROL SET FONT hDlg1, %DoneBtn, NormalFont&

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
    IF SCANstruc.XPlusSTR = "NOT VALID " THEN
      CONTROL SET COLOR hDlg1, %IDC_EB_XPLUSMIN, %RGB_WHITE, %RGB_RED
    END IF
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
'=============== Edit Control  call back ==================================
CALLBACK FUNCTION EditControlCallback()
    LOCAL TXT AS STRING
    LOCAL InkeyVar AS STRING
    IF CB.CTLMSG = %EN_CHANGE THEN
       SELECT CASE CB.CTL
    'X START
            CASE %IDC_EB_XSTART
                CONTROL GET TEXT hDlg1, %IDC_EB_XSTART TO TXT$
                'IF GoodSNG(TXT$) THEN
                  SCANstruc.XLow = ABS(VAL(TXT$))
                  SCANstruc.XLowStr = QStr$(SCANstruc.XLow, 10)
                'END IF
    'X END
            CASE %IDC_EB_XEND
                CONTROL GET TEXT hDlg1, %IDC_EB_XEND TO TXT$
                'IF GoodSNG(TXT$) THEN
                   SCANstruc.XHigh = ABS(VAL(TXT$))
                   SCANstruc.XHighStr = QStr$(SCANstruc.XHigh, 10)
                'END IF
    'Y START
            CASE %IDC_EB_YSTART
                CONTROL GET TEXT hDlg1, %IDC_EB_YSTART TO TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.YLow = ABS(VAL(TXT$))
                       SCANstruc.YLowStr = QStr$(SCANstruc.YLow, 10)
                'END IF
    'Y END
           CASE %IDC_EB_YEND
                CONTROL GET TEXT hDlg1, %IDC_EB_YEND TO TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.YHigh = ABS(VAL(TXT$))
                       SCANstruc.YHighStr = QStr$(SCANstruc.YHigh, 10)
                'END IF
                'X INDEX
           CASE %IDC_EB_XINDEX
                CONTROL GET TEXT hDlg1, %IDC_EB_XINDEX TO TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.XIndex = ABS(VAL(TXT$))
                       SCANstruc.XIndexSTR = QStr$(SCANstruc.XIndex, 10)
                'END IF
    'Y INDEX
           CASE %IDC_EB_YINDEX
                CONTROL GET TEXT hDlg1, %IDC_EB_YINDEX TO TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.YIndex = ABS(VAL(TXT$))
                       SCANstruc.YIndexSTR = QStr$(SCANstruc.YIndex, 10)
                'END IF
    'X SPEED
            CASE %IDC_EB_XSPEED
                CONTROL GET TEXT hDlg1, %IDC_EB_XSPEED TO TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.XSpeed = ABS(VAL(TXT$))
                       SCANstruc.XSpeedSTR = QStr$(SCANstruc.XSpeed, 10)
                'END IF
    'Y SPEED
            CASE %IDC_EB_YSPEED
                CONTROL GET TEXT hDlg1, %IDC_EB_YSPEED TO TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.YSpeed = ABS(VAL(TXT$))
                       SCANstruc.YSpeedSTR = QStr$(SCANstruc.YSpeed, 10)
                'END IF
    'X POS
            CASE %IDC_EB_XPOS
                CONTROL GET TEXT hDlg1, %IDC_EB_XPOS TO TXT$
                'MSGBOX TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.XPos = ABS(VAL(TXT$))
                       SCANstruc.XPosStr = QStr$(SCANstruc.XPos, 10)
                       SCANstruc.XOffset = GetXCord(CLNG(SCANstruc.XPos * SCANstruc.XCtr))
                   '    CALL ResetPosition(Servo1)
                    '   CALL ResetPosition(Servo2)
                'END IF
    'Y POS
            CASE %IDC_EB_YPOS
                CONTROL GET TEXT hDlg1, %IDC_EB_YPOS TO TXT$
                'IF GoodSNG(TXT$) THEN
                       SCANstruc.YPos = VAL(TXT$)
                       SCANstruc.YPosStr = QStr$(SCANstruc.YPos, 10)
                       SCANstruc.YOffset = GetYCord(CLNG(SCANstruc.YPos * SCANstruc.YCtr))
                '       CALL ResetPosition(Servo3)
                'END IF
    'X CT/IN
            CASE %IDC_EB_XCTIN
                CONTROL GET TEXT hDlg1, %IDC_EB_XCTIN TO TXT$
                'IF GoodLNG(TXT$) THEN
                       SCANstruc.XCtr = ABS(VAL(TXT$))
                       SCANstruc.XCtrStr = QStr$(SCANstruc.XCtr, 10)
                'END IF
    'Y CT/IN
            CASE %IDC_EB_YCTIN

                CONTROL GET TEXT hDlg1, %IDC_EB_YCTIN TO TXT$
                'IF GoodLNG(TXT$) THEN
                     SCANstruc.YCtr = ABS(VAL(TXT$))
                     SCANstruc.YCtrStr = QStr$(SCANstruc.YCtr, 10)
                'END IF
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
               ' IF GoodSNG(TXT$) THEN
                    SCANstruc.OverLap = ABS(VAL(TXT$))
                    SCANstruc.OverLapStr = QStr$(SCANstruc.OverLap, 10)
               ' END IF
    'A POS
            CASE %IDC_EB_APOS
                CONTROL GET TEXT hDlg1, %IDC_EB_APOS TO TXT$
                'IF GoodSNG(TXT$) THEN
                    SCANstruc.APos = ABS(VAL(TXT$))
                    SCANstruc.APosStr = QStr$(SCANstruc.APos, 10)
                    SCANstruc.AOffset = GetXCord(CLNG(SCANstruc.APos * SCANstruc.ACtr))
                '    CALL ResetPosition(Servo4)
                'END IF
    'A CT/IN
            CASE %IDC_EB_ACTIN
                CONTROL GET TEXT hDlg1, %IDC_EB_ACTIN TO TXT$
                ' IF GoodLNG(TXT$) THEN
                    SCANstruc.ACtr = ABS(VAL(TXT$))
                    SCANstruc.ACtrStr = QStr$(SCANstruc.ACtr, 10)
                 'END IF
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
       '  keypress = 1
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_EB_STARTEND  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION EditASubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
       '  keypress = 1
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_LABEL_XPOSAJOG  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit11SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         'keypress = 1
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_LABEL_XPOSMJOG  , wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION
FUNCTION Edit12SubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN,%IDC_LABEL_XPOSAUTO  , wParm&
         'USTOP = FALSE
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION

SUB MySub1 ALIAS "MySub1" (BYVAL Param1 AS LONG) EXPORT

    ' code goes here

END SUB
FUNCTION QStr(BYVAL Amount!, BYVAL Places AS INTEGER) AS STRING

    QStr = LEFT$(LTRIM$(STR$(Amount!)) + SPACE$(Places), Places)

END FUNCTION
FUNCTION GetXCord& (Cts&)
  IF SCANstruc.XPlus = TRUE THEN 'X positive direction
    GetXCord& = Cts&
  ELSE
    GetXCord& = -Cts&   'X negative direction
  END IF

  EXIT FUNCTION

END FUNCTION

FUNCTION GetYCord& (Cts&)

  IF SCANstruc.YPlus = TRUE THEN 'Y positive cts
    GetYCord& = Cts&
  ELSE
    GetYCord& = -Cts&  'Y negative cts
  END IF

  EXIT FUNCTION

END FUNCTION
