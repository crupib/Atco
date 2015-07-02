#COMPILE EXE
#CONSOLE OFF
#DIM ALL        '   This is helpful to prevent errors in coding

' --------------------
#INCLUDE ".\includes\ezgui50.inc"                          ' EZGUI Include file for Declares
' --------------------
#RESOURCE ".\rcdata\scanctrl.pbr"


' -------------------------------------------------------------------------------------
' Important routines for apps back end
' -------------------------------------------------------------------------------------

' -------------------------------------------------------------------------------------
DECLARE FUNCTION Main_Initialize(BYVAL VerNum&) AS LONG
' *************************************************************************************
'                               SPLASH Form
' *************************************************************************************
DECLARE SUB EZ_SPLASH_Display(BYVAL FParent$)
DECLARE SUB EZ_SPLASH_Design()
DECLARE SUB EZ_SPLASH_ParseEvents(CID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SPLASH_Events(CID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SPLASH_TimerEvents(BYVAL FormName$, BYVAL CID&, BYVAL CMsg&, CVal&, Cancel&)
' ------------------------------------------------
%SPLASH_Timer_ID         = 3
' -------------------------------
%SPLASH_LABELAPPNAME       = 100
%SPLASH_LABELAPPINFO       = 105
' *************************************************************************************
'                              INPUTBOX Form
' *************************************************************************************
DECLARE SUB EZ_INPUTBOX_Display(BYVAL FParent$)
DECLARE SUB EZ_INPUTBOX_Design()
DECLARE SUB EZ_INPUTBOX_ParseEvents(CID&, CMsg&, CVal&, Cancel&)
' ------------------------------------------------
%INPUTBOX_LABELDESCRIPTION   = 100
%INPUTBOX_TEXTINPUTDATA      = 105
%INPUTBOX_BUTTONAPPLY        = 110
%INPUTBOX_BUTTONCANCEL       = 115
' *************************************************************************************
'                               MAIN Form
' *************************************************************************************
DECLARE SUB EZ_MAIN_Display(BYVAL FParent$)
DECLARE SUB EZ_MAIN_Design()
DECLARE SUB EZ_MAIN_ParseEvents(CID&, CMsg&, CVal&, Cancel&)
DECLARE SUB MAIN_CANVASJOGCONTROL_Draw(BYVAL FMode&)
DECLARE SUB MAIN_MAINCANVAS_Draw(BYVAL FMode&)
DECLARE SUB MAIN_MAINCANVAS_Events(MyID&, CMsg&, CVal&, Cancel&)
' ----------------------------------------------------------
%MAIN_FILEMENU                               = 9000
%MAIN_FILE1                                  = 9005
GLOBAL App_MAIN_FILE_Count&
%MAIN_EXITAPP                                = 9099
%MAIN_SETUPMENU                              = 9100
%MAIN_SETUP1                                 = 9105
GLOBAL App_MAIN_SETUP_Count&
%MAIN_WINMENU                                = 9200
%MAIN_WINDOW1                                = 9205
GLOBAL App_MAIN_WINDOW_Count&
%MAIN_ABOUTMENU                              = 9300
%MAIN_ABOUTBOX                               = 9305
' ----------------------------------------------------------
%MAIN_TEXTXPOS           = 100
GLOBAL App_XMotorPos AS DOUBLE
%MAIN_BUTTONXPOS         = 105
%MAIN_BUTTONXONOFF       = 110
GLOBAL App_XMotorState&
%MAIN_TEXTYPOS           = 115
GLOBAL App_YMotorPos AS DOUBLE
%MAIN_BUTTONYPOS         = 120
%MAIN_BUTTONYONOFF       = 125
GLOBAL App_YMotorState&
%MAIN_TEXTRPOS           = 130
GLOBAL App_RMotorPos AS DOUBLE
%MAIN_BUTTONRPOS         = 135
%MAIN_BUTTONRONOFF       = 140
GLOBAL App_RMotorState&
%MAIN_BUTTONPOLAR        = 145
%MAIN_BUTTONCARTESIAN    = 150
%MAIN_BUTTONALLPOS       = 155
%MAIN_BUTTONALLOFF       = 160
%MAIN_BUTTONALLON        = 165
%MAIN_BUTTONGOSCAN       = 170
%MAIN_BUTTONEXTRASCAN    = 175
%MAIN_BUTTONSTOPSCAN     = 180
%MAIN_BUTTONJOGYPLUS     = 185
%MAIN_BUTTONJOGXMINUS    = 190
%MAIN_BUTTONJOGXPLUS     = 195
%MAIN_BUTTONJOGYMINUS    = 200
%MAIN_BUTTONJOGRPLUS     = 205
%MAIN_BUTTONJOGRMINUS    = 210
%MAIN_CANVASJOGCONTROL   = 215
%MAIN_TRACKBARJOGRATE    = 220
%MAIN_TEXTJOGRATE        = 225
%MAIN_BUTTONJOGCONT      = 230
%MAIN_BUTTONJOGSTEP      = 235
%MAIN_BUTTONEXTRA        = 240     ' first extra button ID (18 buttons total)
%MAIN_MAINCANVAS         = 330
%MAIN_LABELSTATUS        = 335
%MAIN_LABELXPOS          = 340
%MAIN_LABELYPOS          = 345
%MAIN_LABELRPOS          = 350
%MAIN_LABELCOORSYS       = 355
%MAIN_LABEL1             = 360
%MAIN_LABEL2             = 365
%MAIN_LABEL3             = 370
%MAIN_LABELJOGRATE       = 375
'
' --------------------
#INCLUDE ".\includes\ezwmain50.inc"                          ' EZGUI Include file for WinMain
' --------------------

#INCLUDE "backend.inc"

SUB EZ_Main(VerNum&)     ' (PROTECTED)
     EZ_Reg 6071, 570416930   ' Bills Registration codes for now
     EZ_DefImageFolder "Graphics"
     EZ_AllowCommandEvents  0
     EZ_AllowMouseMoveEvents 1
     EZ_AllowCursorEvents 1
     EZ_DefFont 6, "Arial Narrow", 10, " BV"
     EZ_DefFont 7, "Arial Narrow", 12, " BV"
     EZ_DefFont 8, "Arial Narrow", 10, " L+V"
     EZ_DefFont 9, "Arial Narrow", 20, " BV"
     EZ_DefFont 10, "Courier New", 12, " BF"
     EZ_DefSystemColor 32, 4
     EZ_DefSystemColor 33, 5
     EZ_DefSystemColor 34, 15
     EZ_DefSystemColor 35, 24
     EZ_DefColorL 36, &H00FFE2C6
     EZ_DefColorL 37, &H00F0E1FF
     EZ_DefColorL 38, &H00E8D0D0
     EZ_DefColorL 39, &H00FFC488
     EZ_DefColorL 40, &H00BFBFFF
     EZ_DefColorL 41, &H00D9FFD9
     EZ_DefColorL 42, &H0000E800
     EZ_DefColorL 43, &H007D7DFF
     IF Main_Initialize(VerNum&) THEN
          EZ_SPLASH_Display ""
     END IF
END SUB


' -------------------------------------------------------------------------------------

SUB EZ_DesignWindow(FormName$)     ' All calls must be forwarded for each form from here
     SELECT CASE FormName$
          CASE "SPLASH"
               EZ_SPLASH_Design
          CASE "INPUTBOX"
               EZ_INPUTBOX_Design
          CASE "MAIN"
               EZ_MAIN_Design
          CASE ELSE
     END SELECT
END SUB

' -------------------------------------------------------------------------------------

SUB EZ_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)     ' All calls must be forwarded for each form from here
     SELECT CASE FormName$
          CASE "SPLASH"
               EZ_SPLASH_ParseEvents CID&, CMsg&, CVal&, Cancel&
          CASE "INPUTBOX"
               EZ_INPUTBOX_ParseEvents CID&, CMsg&, CVal&, Cancel&
          CASE "MAIN"
               EZ_MAIN_ParseEvents CID&, CMsg&, CVal&, Cancel&
          CASE ELSE
     END SELECT
END SUB

' -------------------------------------------------------------------------------------
' --------------Kevin ------ Setup code -----------------------------------------------
FUNCTION Main_Initialize(BYVAL VerNum&) AS LONG
     LOCAL RV&
     LOCAL Par1 AS MyData, Par2 AS MyData, Par3 AS MyData, Par4 AS MyData, SPar AS STRING, ErrFlag AS LONG
     ErrFlag&=0
     ProcessInput %TA_GetXYRMotorDefaults, Par1, Par2, Par3, Par4, SPar, ErrFlag&
     IF ErrFlag&=0 THEN
          App_XMotorState&=Par1.Q
          App_YMotorState&=Par2.Q
          App_RMotorState&=Par3.Q
     ELSE
          App_XMotorState&=0
          App_YMotorState&=0
          App_RMotorState&=0
     END IF

     ErrFlag&=0
     ProcessInput %TA_GetXYRPosDefaults, Par1, Par2, Par3, Par4, SPar, ErrFlag&
     IF ErrFlag&=0 THEN
           App_XMotorPos = Par1.D
           App_YMotorPos = Par2.D
           App_RMotorPos = Par3.D
     ELSE
           App_XMotorPos = 0#
           App_YMotorPos = 0#
           App_RMotorPos = 0#
     END IF
     RV&=1
     FUNCTION=RV&
END FUNCTION

SUB MainMsg(BYVAL T$)
     EZ_MsgBox "Main", T$, "",""
END SUB


$NumFieldMask1 = "{+###.###}"
$NumFieldFormat = "###.###"


FUNCTION XYRStr(BYVAL Index&) AS STRING
     LOCAL V AS DOUBLE, RV$
     SELECT CASE Index&
          CASE 1: V = App_XMotorPos
          CASE 2: V = App_YMotorPos
          CASE 3: V = App_RMotorPos
          CASE ELSE: V = 0
     END SELECT
     IF V<0# THEN
          RV$=FORMAT$(ABS(V), $NumFieldFormat)
          RV$="-"+RIGHT$("       "+RV$,7)
     ELSE
          RV$=FORMAT$(V, $NumFieldFormat)
          RV$=" "+RIGHT$("       "+RV$,7)
     END IF
     FUNCTION=RV$
END FUNCTION


' *************************************************************************************
'                           SPLASH Form code
' *************************************************************************************

SUB EZ_SPLASH_Display(BYVAL FParent$)
     LOCAL PN$
     PN$=EZ_LoadPicture("splash.bmp")
     EZ_ShapeFormToPicture PN$, -1
     EZ_Color -1, -1
     EZ_Form "SPLASH", FParent$, "", 0, 0, 63.75, 24.875, "CS"
     EZ_FreeImage PN$
END SUB

SUB EZ_SPLASH_Design()
     LOCAL CText$
     EZ_Color 15, 15
     EZ_UseFont 9
     EZ_Label %SPLASH_LABELAPPNAME, 12.25, 6.5, 40.5, 6, "Scanner App 1.0", "^CI"
     ' -----------------------------------------------
     EZ_Color 15, 15
     EZ_UseFont 7
     EZ_Label %SPLASH_LABELAPPINFO, 12.25, 13.125, 40.5, 6, "Copyright 2015", "^CI"
     ' -----------------------------------------------
END SUB

SUB EZ_SPLASH_ParseEvents(CID&, CMsg&, CVal&, Cancel&)     ' (PROTECTED)
     SELECT CASE CID&
          CASE %EZ_Window
               SPLASH_Events CID&, CMsg&, CVal&, Cancel&
               IF CMsg&=%EZ_LButtonDown THEN
                    EZ_DragForm "SPLASH"
               END IF
               IF CMsg&=%EZ_Started OR CMsg&=%EZ_Close THEN
                    SPLASH_TimerEvents "SPLASH", %SPLASH_Timer_ID, CMsg&, CVal&, Cancel&
               END IF
          CASE %SPLASH_Timer_ID
               SPLASH_TimerEvents "SPLASH", CID&, CMsg&, CVal&, Cancel&
          CASE ELSE
               SPLASH_Events CID&, CMsg&, CVal&, Cancel&
     END SELECT
END SUB

SUB SPLASH_Events(CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE CID&
          CASE %EZ_Window
               SELECT CASE CMsg&
                    CASE %EZ_Loading
                    CASE %EZ_Loaded
                    CASE %EZ_Started
                    CASE %EZ_Close
                    CASE ELSE
               END SELECT
          CASE ELSE
     END SELECT
END SUB

SUB SPLASH_TimerEvents(BYVAL FormName$, BYVAL CID&, BYVAL CMsg&, CVal&, Cancel&)
     LOCAL TM!
     STATIC TFlag&
     SELECT CASE CMsg&
          CASE %EZ_Timer          ' Timer Event !
               EZ_StopTimer FormName$, CID&
               TFlag&=0
               EZ_MAIN_Display ""
               EZ_UnloadForm "Splash"
          CASE %EZ_Started        ' Start Timer !
               TM!=5.0            ' Timer delay in seconds
               EZ_StartTimer FormName$, CID&, TM!
               TFlag&=1
          CASE %EZ_Close          ' Terminate Timer when form closes !
               IF TFlag&=1 THEN
                    EZ_StopTimer FormName$, CID&
               END IF
          CASE ELSE
     END SELECT
END SUB

' *************************************************************************************
'                             INPUTBOX Form code
' *************************************************************************************
GLOBAL App_InputTitle$
GLOBAL App_InputDesc$
GLOBAL App_InputValue$
GLOBAL App_InputMask$
GLOBAL App_InputFont&
GLOBAL App_InputCaretPos&

FUNCTION ShowInputBox(BYVAL Title$, BYVAL IDesc$, BYVAL IValue$, BYVAL MaskType&) AS STRING
     App_InputTitle$=Title$
     App_InputDesc$=IDesc$
     App_InputValue$=IValue$
     SELECT CASE MaskType&
          CASE 1
               App_InputMask$ = ">"+$NumFieldMask1 ' makes it right justified
               App_InputFont& = 10 ' Courier New
               App_InputCaretPos&=8
          CASE ELSE
               App_InputMask$ = ""
               App_InputFont& = 4
               App_InputCaretPos&=0
     END SELECT
     EZ_INPUTBOX_Display "MAIN"
     FUNCTION=App_InputValue$
END FUNCTION

SUB EZ_INPUTBOX_Display(BYVAL FParent$)     ' (PROTECTED)
     EZ_Color -1, -1
     EZ_Form "INPUTBOX", FParent$, App_InputTitle$, 0, 0, 50, 10, "CRZM"
END SUB

SUB EZ_INPUTBOX_Design()     ' (PROTECTED)
     LOCAL CText$
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %INPUTBOX_LABELDESCRIPTION, .75, .625, 48.25, 1.25, App_InputDesc$, "C"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont App_InputFont&
     EZ_UseAutoSize "VH"
     EZ_SubClass 2
     EZ_Text %INPUTBOX_TEXTINPUTDATA, .5, 3, 49, 1.875, App_InputValue$, "CEST"+App_InputMask$
     EZ_SubClass 0
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Button %INPUTBOX_BUTTONAPPLY, 30.25, 5.75, 18, 3.5, "Apply", "T"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Button %INPUTBOX_BUTTONCANCEL, 1.75, 7.375, 18, 1.875, "Cancel", "T"
     ' -----------------------------------------------
END SUB


SUB EZ_INPUTBOX_ParseEvents(CID&, CMsg&, CVal&, Cancel&)     ' (PROTECTED)
     STATIC IValue$
     SELECT CASE CID&
          CASE %EZ_Window
               SELECT CASE CMsg&
                    CASE %EZ_Loading
                    CASE %EZ_Loaded
                         IValue$=App_InputValue$
                    CASE %EZ_Started
                    CASE %EZ_Close
                    CASE %EZ_NoAutoSize
                         Cancel&=1 ' turns ON autosize for this form
                    CASE ELSE
               END SELECT
          CASE %INPUTBOX_TEXTINPUTDATA
               SELECT CASE CMsg&
                    CASE %EZ_Change
                         IValue$=EZ_GetText("INPUTBOX", CID&)
                    CASE %EZ_EditSetSel
                         LOCAL SMin&,SMax&
                         EZ_GetSelVal CVal&, SMin&, SMax&
                         SMin&=App_InputCaretPos&
                         SMax&=App_InputCaretPos&
                         EZ_SetSelVal CVal&, SMin&, SMax&
                    CASE ELSE
               END SELECT
          CASE %INPUTBOX_BUTTONAPPLY
               SELECT CASE CMsg&
                    CASE %EZ_Click
                         App_InputValue$=IValue$
                         IValue$=""
                         EZ_UnloadForm "INPUTBOX"
               END SELECT
          CASE %INPUTBOX_BUTTONCANCEL
               SELECT CASE CMsg&
                    CASE %EZ_Click
                         IValue$=""
                         EZ_UnloadForm "INPUTBOX"
               END SELECT
          CASE ELSE
     END SELECT
END SUB

' *************************************************************************************
'                              MAIN Form code
' *************************************************************************************

SUB EZ_MAIN_Display(BYVAL FParent$)     ' (PROTECTED)
     LOCAL hMainMenu&
     ' Main Menu handle automatically stored by EZGUI
     hMainMenu&=EZ_DefMainMenu( %MAIN_FILEMENU, "&File", "")
     EZ_Color -1, -1
     EZ_Form "MAIN", FParent$, "Scan Control Pad 1.0", 0, 0, 119, 40, "^_CZ"
END SUB

FUNCTION MakeButtonRedGreen(BYVAL T$, BYVAL BState&) AS STRING
     IF BState&=0 THEN
          FUNCTION=T$+"[[12]]"
     ELSE
          FUNCTION=T$+"[[10]]"
     END IF
END FUNCTION

SUB SetRedGreenState(BYVAL FormName$, BYVAL CID&, BYVAL BState&)
     LOCAL T$
     T$=EZ_GetText(FormName$, CID&)
     T$=PARSE$(T$,"[",1)
     T$=MakeButtonRedGreen(T$, BState&)
     EZ_SetText FormName$, CID&, T$
END SUB


' ----------------------------
'   Key form design routine
' ----------------------------
SUB EZ_MAIN_Design()
     ' separate each menu item with the | character
     ' FILE menu Items
     DATA "Open|Save|File Item 3|File Item 4|File Item 5|File Item 6"
     ' SETUP menu items
     DATA "SETUP Item 1|SETUP Item 2|SETUP Item 3|SETUP Item 4|SETUP Item 5|SETUP Item 6"
     ' WINDOW menu items
     DATA "WINDOW Item 1|WINDOW Item 2|WINDOW Item 3|WINDOW Item 4|WINDOW Item 5|WINDOW Item 6"
     ' extra button in area to left
     DATA "N/A"
     ' -------------------------------------------------
     ' Extra Button List. Must be 18 button names
     ' -------------------------------------------------
     DATA "Button 1", "Button 2", "Button 3"
     DATA "Button 4", "Button 5", "Button 6"
     DATA "Button 7", "Button 8", "Button 9"
     DATA "Button 10", "Button 11", "Button 12"
     DATA "Button 13", "Button 14", "Button 15"
     DATA "Button 16", "Button 17", "Button 18"
     ' -------------------------------------------------
     LOCAL CText$, T$, MText$, MCT&, J&, MenuID&, MI&
     LOCAL hMainMenu&, hDropMenu&, hSubMenu&
     hMainMenu&=EZ_GetMenu("MAIN", 0)
     EZ_AddMenuItem hMainMenu&, %MAIN_SETUPMENU, 0, "&Setup", ""
     EZ_AddMenuItem hMainMenu&, %MAIN_WINMENU, 0, "&Window", ""
     EZ_AddMenuItem hMainMenu&, %MAIN_ABOUTMENU, 0, "&About", ""
     ' -------------------------------------------------
     MI&=1
     MenuID&=%MAIN_FILE1
     GOSUB BuildDropMenu
     App_MAIN_FILE_Count&=MCT&
     EZ_AddMenuItem hDropMenu&,%MAIN_EXITAPP, 0, "E&xit Application", ""
     EZ_SaveMenu "MAIN", 1, hDropMenu&
     EZ_SetSubMenu hMainMenu& , %MAIN_FILEMENU, hDropMenu&
     ' -------------------------------------------------
     MI&=2
     MenuID&=%MAIN_SETUP1
     GOSUB BuildDropMenu
     App_MAIN_SETUP_Count&=MCT&
     EZ_SaveMenu "MAIN", 2, hDropMenu&
     EZ_SetSubMenu hMainMenu& , %MAIN_SETUPMENU, hDropMenu&
     ' -------------------------------------------------
     MI&=3
     MenuID&=%MAIN_WINDOW1
     GOSUB BuildDropMenu
     App_MAIN_WINDOW_Count&=MCT&
     EZ_SaveMenu "MAIN", 3, hDropMenu&
     EZ_SetSubMenu hMainMenu& , %MAIN_WINMENU, hDropMenu&
     ' -------------------------------------------------
     hDropMenu&=EZ_DefSubMenu( %MAIN_ABOUTBOX, "&About this app", "")
     EZ_SaveMenu "MAIN", 4, hDropMenu&
     EZ_SetSubMenu hMainMenu& , %MAIN_ABOUTMENU, hDropMenu&
     ' ------------------------------------------------
     EZ_Color 0, 36
     EZ_UseFont 10
     EZ_UseAutoSize "VH"
     EZ_Text %MAIN_TEXTXPOS, 5, .25, 12.5, 1.75, XYRStr(1), "CST"
     ' -----------------------------------------------
     EZ_Color 0, 36
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONXPOS, 18.25, .25, 8.75, 1.75, "Set X Pos", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONXPOS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 36
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONXONOFF, 27.625, .25, 11.75, 1.75, MakeButtonRedGreen("  X Motor ON",App_XMotorState&), "T"
     EZ_SetRegion "Main", %MAIN_BUTTONXONOFF,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 37
     EZ_UseFont 10
     EZ_UseAutoSize "VH"
     EZ_Text %MAIN_TEXTYPOS, 5, 2.375, 12.5, 1.75, XYRStr(2), "CST"
     ' -----------------------------------------------
     EZ_Color 0, 37
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONYPOS, 18.25, 2.375, 8.75, 1.75, "Set Y Pos", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONYPOS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 37
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONYONOFF, 27.625, 2.375, 11.75, 1.75, MakeButtonRedGreen("  Y Motor ON",App_YMotorState&), "T"
     EZ_SetRegion "Main", %MAIN_BUTTONYONOFF,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 38
     EZ_UseFont 10
     EZ_UseAutoSize "VH"
     EZ_Text %MAIN_TEXTRPOS, 5, 4.5, 12.5, 1.75, XYRStr(3), "CST"
     ' -----------------------------------------------
     EZ_Color 0, 38
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONRPOS, 18.25, 4.5, 8.75, 1.75, "Set R Pos", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONRPOS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 38
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONRONOFF, 27.625, 4.5, 11.75, 1.75, MakeButtonRedGreen("  R Motor ON",App_RMotorState&), "T"
     EZ_SetRegion "Main", %MAIN_BUTTONRONOFF,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 31
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONPOLAR, .5, 7.375, 6.875, 1.625, "    Polar[[7]]", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONPOLAR,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 31
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONCARTESIAN, 8, 7.375, 9.5, 1.625, "    Cartesian[[0]]", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONCARTESIAN,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 31
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONALLPOS, 18.25, 7.25, 8.75, 1.75, "Set All Pos", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONALLPOS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 40
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONALLOFF, 27.625, 7.25, 5.5, 1.75, "All Off", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONALLOFF,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 41
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONALLON, 33.875, 7.25, 5.5, 1.75, "All On", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONALLON,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 42
     EZ_UseFont 7
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONGOSCAN, .5, 9.5, 12.5, 2.125, "GO Auto Scan", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONGOSCAN,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 31
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     T$=READ$(4)
     EZ_ODButton %MAIN_BUTTONEXTRASCAN, 13.75, 9.5, 12.5, 2.125, T$, "T"
     EZ_SetRegion "Main", %MAIN_BUTTONEXTRASCAN,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 43
     EZ_UseFont 7
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONSTOPSCAN, 27, 9.5, 12.5, 2.125, "STOP Scan", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONSTOPSCAN,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 37
     EZ_UseFont 9
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGYPLUS, 45, 1, 4, 1.875, "Y+", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGYPLUS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 36
     EZ_UseFont 9
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGXMINUS, 42, 3.25, 4, 2, "X-", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGXMINUS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 36
     EZ_UseFont 9
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGXPLUS, 48, 3.25, 4, 2, "X+", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGXPLUS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 37
     EZ_UseFont 9
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGYMINUS, 45, 5.625, 4, 2, "Y-", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGYMINUS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 38
     EZ_UseFont 9
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGRPLUS, 74.25, 1, 4, 2, "R+", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGRPLUS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 38
     EZ_UseFont 9
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGRMINUS, 74.25, 5.625, 4, 2, "R-", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGRMINUS,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 33
     EZ_UseFont 4
     EZ_UseAutoSize "VHE1"
     EZ_SubClass 2
     EZ_Canvas %MAIN_CANVASJOGCONTROL, 54.25, 0, 18, 9, "{DIB}"
     EZ_SetRegion "Main", %MAIN_CANVASJOGCONTROL, 1,0
     EZ_SubClass 0
     MAIN_CANVASJOGCONTROL_Draw -1
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_HTrackBar %MAIN_TRACKBARJOGRATE, 41.75, 8.625, 28.5, 1.375, "!=4T"
     ' -----------------------------------------------
     EZ_Color 0, 15
     EZ_UseFont 6
     EZ_UseAutoSize "VH"
     EZ_Text %MAIN_TEXTJOGRATE, 69.5, 8.875, 8.75, 1.375, "999", "CST"
     ' -----------------------------------------------
     EZ_Color 0, 31
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGCONT, 45.25, 10.5, 12.25, 1.375, "    Continuous[[7]]", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGCONT,-2,0
     ' -----------------------------------------------
     EZ_Color 0, 31
     EZ_UseFont 6
     EZ_UseAutoSize "VH-2"
     EZ_ODButton %MAIN_BUTTONJOGSTEP, 58.25, 10.5, 8, 1.375, "    Step[[0]]", "T"
     EZ_SetRegion "Main", %MAIN_BUTTONJOGSTEP,-2,0
     ' -----------------------------------------------
     ' 18 extra buttons
     LOCAL N&, I&, C!, R!, ID&
     R!=.125
     ID&=0
     FOR N&=1 TO 6
          C!=80.375
          FOR I&=1 TO 3
               EZ_Color 0, 31
               EZ_UseFont 6
               EZ_UseAutoSize "VH-2"
               T$=READ$(ID&+5)
               EZ_ODButton %MAIN_BUTTONEXTRA+ID&, C!, R!, 12.25, 1.75, T$, "T"
               EZ_SetRegion "Main", %MAIN_BUTTONEXTRA+ID&,-2,0
               ID&=ID+1
               C!=C!+13
          NEXT I&
          R!=R!+2
     NEXT N&
     ' -----------------------------------------------
     EZ_Color 0, 0
     EZ_UseFont 4
     EZ_UseAutoSize "FL,FR,VE"
     EZ_SubClass 2
     EZ_Canvas %MAIN_MAINCANVAS, 0, 12.5, 119, 26.25, "+T{DIB}"
     EZ_SubClass 0
     MAIN_MAINCANVAS_Draw -1
     ' -----------------------------------------------
     EZ_Color 0, 15
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %MAIN_LABELSTATUS, 0, 38.75, 119, 1.25, "Current Status", "^CST"
     ' -----------------------------------------------
     EZ_Color 0, 36
     EZ_UseFont 9
     EZ_UseAutoSize "VH2"
     EZ_Label %MAIN_LABELXPOS, .5, .25, 4, 1.75, "X", "^C"
     EZ_SetRegion "Main", %MAIN_LABELXPOS, 2,0
     ' -----------------------------------------------
     EZ_Color 0, 37
     EZ_UseFont 9
     EZ_UseAutoSize "VH2"
     EZ_Label %MAIN_LABELYPOS, .5, 2.375, 4, 1.75, "Y", "^C"
     EZ_SetRegion "Main", %MAIN_LABELYPOS, 2,0
     ' -----------------------------------------------
     EZ_Color 0, 38
     EZ_UseFont 9
     EZ_UseAutoSize "VH2"
     EZ_Label %MAIN_LABELRPOS, .5, 4.5, 4, 1.75, "R", "^C"
     EZ_SetRegion "Main", %MAIN_LABELRPOS, 2,0
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 8
     EZ_UseAutoSize "VH"
     EZ_Label %MAIN_LABELCOORSYS, 1.25, 6.25, 15.25, 1.125, "Coordinate System", "C"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %MAIN_LABEL1, 40.25, .125, 1, 12, "[[25,17,5]]", "CO"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %MAIN_LABEL2, 79, .125, 1, 12, "[[25,17,5]]", "CO"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %MAIN_LABEL3, 0, 12, 119, .5, "[[25,17,7]]", "CO"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 8
     EZ_UseAutoSize "VH"
     EZ_Label %MAIN_LABELJOGRATE, 70.75, 10.5, 7, 1.125, "Jog Rate", "C"
     ' -----------------------------------------------
     EXIT SUB

BuildDropMenu:
     MText$=READ$(MI&)
     MCT&=PARSECOUNT(MText$,"|")
     FOR J&=1 TO MCT&
          IF J&=1 THEN
               hDropMenu&=EZ_DefSubMenu( MenuID&, PARSE$(MText$,"|", J&), "")
          ELSE
               EZ_AddMenuItem hDropMenu&, MenuID&, 0, PARSE$(MText$,"|", J&), ""
          END IF
          MenuID&=MenuID&+1
     NEXT J&
RETURN

END SUB


'TYPE GUIEvent
'     MyID AS LONG
'     MyText AS STRING
'     MyParam1 AS DOUBLE
'     MyParam2 AS DOUBLE
'     MyParam3 AS DOUBLE
'     MyParam4 AS DOUBLE
'END TYPE

'%EZ_TalkToGUI  = %EZ_UserEvent + 1

SUB GUIRequest(BYVAL CVal&)
     LOCAL E AS GUIEvent PTR
     E=CVal&
     '@E.MyText
     '@E.MyParam1
     '@E.MyParam2
     '@E.MyParam3
     '@E.MyParam4
     SELECT CASE @E.MyID

          CASE ELSE
     END SELECT
END SUB

SUB EZ_MAIN_ParseEvents(CID&, CMsg&, CVal&, Cancel&)
     LOCAL MenuN&, EText$, RV$
     LOCAL Par1 AS MyData, Par2 AS MyData, Par3 AS MyData, Par4 AS MyData, SPar AS STRING, ErrFlag AS LONG
     ErrFlag&=0
     SELECT CASE CID&
          ' -------------
          ' Form events
          ' -------------
          CASE %EZ_Window
               SELECT CASE CMsg&
                    CASE %EZ_TalkToGUI
                         GUIRequest CVal&
                    CASE %EZ_Loading
                    CASE %EZ_Loaded
                    CASE %EZ_Started
                    CASE %EZ_Close
                    CASE %EZ_NoAutoSize
                         Cancel&=1 ' turns ON autosize for this form
                    CASE ELSE
               END SELECT
          ' -------------
          ' Menu events
          ' -------------
          CASE %MAIN_FILE1 TO %MAIN_FILE1+App_MAIN_FILE_Count&-1
               MenuN&=CID&-%MAIN_FILE1+1
               SELECT CASE CMsg&
                    CASE %EZ_Click
                         MainMsg "File"+STR$(MenuN&)
                         IF MenuN& = 1 THEN
                             ErrFlag& = 0
                             ProcessInput %OPEN_FILE_NAME, Par1, Par2, Par3, Par4, SPar, ErrFlag&
                             IF ErrFlag&=0 THEN
                               MainMsg "File Open worked!"+Par1.S
                             ELSE
                               MainMsg "File not allowed to be open!"
                             END IF
                         END IF
                         IF MenuN& = 2 THEN
                             ErrFlag& = 0
                             ProcessInput %SAVE_FILE_NAME, Par1, Par2, Par3, Par4, SPar, ErrFlag&
                             IF ErrFlag&=0 THEN
                               MainMsg "File Save worked! "+Par1.OF
                             ELSE
                               MainMsg "File not allowed to be saved!"
                             END IF
                         END IF
               END SELECT
          CASE %MAIN_EXITAPP
               SELECT CASE CMsg&
                    CASE %EZ_Click
                         EZ_UnloadForm "Main"
               END SELECT
          CASE %MAIN_SETUP1 TO %MAIN_SETUP1+App_MAIN_SETUP_Count&-1
               MenuN&=CID&-%MAIN_SETUP1+1
               SELECT CASE CMsg&
                    CASE %EZ_Click
                         MainMsg "Setup"+STR$(MenuN&)
               END SELECT
          CASE %MAIN_WINDOW1 TO %MAIN_WINDOW1+App_MAIN_WINDOW_Count&-1
               MenuN&=CID&-%MAIN_WINDOW1+1
               SELECT CASE CMsg&
                    CASE %EZ_Click
                         MainMsg "Window"+STR$(MenuN&)
               END SELECT
          CASE %MAIN_ABOUTBOX
               SELECT CASE CMsg&
                    CASE %EZ_Click
                         MainMsg "Scanner App 1.0"
               END SELECT
          ' -------------
          ' Control events
          ' -------------
          CASE  %MAIN_BUTTONXPOS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         'EText$=EZ_GetText("MAIN", %MAIN_TEXTXPOS)
                         'RV$=ShowInputBox("Set CRUX Position", "Enter New X Position",EText$, 1)
                         'IF RV$<>EText$ THEN
                         '     EZ_SetText "MAIN", %MAIN_TEXTXPOS, RV$
                         'END IF
                         'on click processInput
                         ProcessInput %SET_XPOS_SET, Par1, Par2, Par3, Par4, SPar, ErrFlag&
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONXPOS, CVal&, 36, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONXONOFF
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         IF App_XMotorState&=0 THEN App_XMotorState&=1 ELSE App_XMotorState&=0
                         SetRedGreenState "MAIN", CID&, App_XMotorState&
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONXONOFF, CVal&, 36, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONYPOS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         EText$=EZ_GetText("MAIN", %MAIN_TEXTYPOS)
                         RV$=ShowInputBox("Set Y Position", "Enter New Y Position",EText$,1)
                         IF RV$<>EText$ THEN
                              EZ_SetText "MAIN", %MAIN_TEXTYPOS, RV$
                         END IF

                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONYPOS, CVal&, 37, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONYONOFF
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         IF App_YMotorState&=0 THEN App_YMotorState&=1 ELSE App_YMotorState&=0
                         SetRedGreenState "MAIN", CID&, App_YMotorState&
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONYONOFF, CVal&, 37, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONRPOS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         EText$=EZ_GetText("MAIN", %MAIN_TEXTRPOS)
                         RV$=ShowInputBox("Set R Position", "Enter New R Position",EText$,1)
                         IF RV$<>EText$ THEN
                              EZ_SetText "MAIN", %MAIN_TEXTRPOS, RV$
                         END IF

                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONRPOS, CVal&, 38, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONRONOFF
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         IF App_RMotorState&=0 THEN App_RMotorState&=1 ELSE App_RMotorState&=0
                         SetRedGreenState "MAIN", CID&, App_RMotorState&
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONRONOFF, CVal&, 38, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONPOLAR
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONPOLAR, CVal&, 31, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONCARTESIAN
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONCARTESIAN, CVal&, 31, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONALLPOS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         EText$=""
                         RV$=ShowInputBox("Set All Positions", "Enter New X,Y,R (All) Position",EText$,1)
                         IF RV$<>EText$ THEN
                              EZ_SetText "MAIN", %MAIN_TEXTXPOS, RV$
                              EZ_SetText "MAIN", %MAIN_TEXTYPOS, RV$
                              EZ_SetText "MAIN", %MAIN_TEXTRPOS, RV$
                         END IF

                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONALLPOS, CVal&, 31, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONALLOFF
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         App_XMotorState&=0
                         App_YMotorState&=0
                         App_RMotorState&=0
                         SetRedGreenState "MAIN", %MAIN_BUTTONXONOFF, 0
                         SetRedGreenState "MAIN", %MAIN_BUTTONYONOFF, 0
                         SetRedGreenState "MAIN", %MAIN_BUTTONRONOFF, 0
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONALLOFF, CVal&, 40, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONALLON
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         App_XMotorState&=1
                         App_YMotorState&=1
                         App_RMotorState&=1
                         SetRedGreenState "MAIN", %MAIN_BUTTONXONOFF, 1
                         SetRedGreenState "MAIN", %MAIN_BUTTONYONOFF, 1
                         SetRedGreenState "MAIN", %MAIN_BUTTONRONOFF, 1
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONALLON, CVal&, 41, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONGOSCAN
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                      ProcessInput %GO_AUTO_SCAN, Par1, Par2, Par3, Par4, SPar, ErrFlag&
                    CASE %EZ_OwnerDraw
                          EZ_Draw3DButtonRR "Main", %MAIN_BUTTONGOSCAN, CVal&, 42, 0,  7
               END SELECT
          CASE  %MAIN_BUTTONEXTRASCAN
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONEXTRASCAN, CVal&, 31, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONSTOPSCAN
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONSTOPSCAN, CVal&, 43, 0,  7
               END SELECT
          CASE  %MAIN_BUTTONJOGYPLUS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGYPLUS, CVal&, 37, 0,  9
               END SELECT
          CASE  %MAIN_BUTTONJOGXMINUS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGXMINUS, CVal&, 36, 0,  9
               END SELECT
          CASE  %MAIN_BUTTONJOGXPLUS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGXPLUS, CVal&, 36, 0,  9
               END SELECT
          CASE  %MAIN_BUTTONJOGYMINUS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGYMINUS, CVal&, 37, 0,  9
               END SELECT
          CASE  %MAIN_BUTTONJOGRPLUS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGRPLUS, CVal&, 38, 0,  9
               END SELECT
          CASE  %MAIN_BUTTONJOGRMINUS
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGRMINUS, CVal&, 38, 0,  9
               END SELECT
          CASE %MAIN_CANVASJOGCONTROL
               SELECT CASE CMsg&
                    CASE %EZ_ScaleMe
                         LOCAL OX&,OY&,OW&,OH&,NX&,NY&,NW&, NH&
                         EZ_GetScaleMe CVal&, OX&,OY&,OW&,OH&,NX&,NY&,NW&, NH&
                         IF NW&>NH& THEN
                              NW&=NH&
                         ELSE
                              IF NH&>NW& THEN NH&=NW&
                         END IF
                         EZ_SetScaleMe CVal&, NX&, NY&, NW&, NH&
               END SELECT
          CASE  %MAIN_BUTTONJOGCONT
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGCONT, CVal&, 31, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONJOGSTEP
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", %MAIN_BUTTONJOGSTEP, CVal&, 31, 0,  6
               END SELECT
          CASE  %MAIN_BUTTONEXTRA TO %MAIN_BUTTONEXTRA+17
               LOCAL BN&
               BN&=CID&-%MAIN_BUTTONEXTRA+1   ' buttons 1 to 18
               SELECT CASE CMsg&
                    CASE %EZ_Click, %EZ_DClick
                         ' Buttons will be numbered 1 to 18
                    CASE %EZ_OwnerDraw
                         EZ_Draw3DButtonRR "Main", CID&, CVal&, 31, 0,  6
               END SELECT
          CASE  %MAIN_MAINCANVAS
               MAIN_MAINCANVAS_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %MAIN_LABEL1
               IF CMsg&=%EZ_OwnerDraw THEN EZ_DrawLabel CVal&,-1, -1,  "[[25,17,5]]"
          CASE  %MAIN_LABEL2
               IF CMsg&=%EZ_OwnerDraw THEN EZ_DrawLabel CVal&,-1, -1,  "[[25,17,5]]"
          CASE  %MAIN_LABEL3
               IF CMsg&=%EZ_OwnerDraw THEN EZ_DrawLabel CVal&,-1, -1,  "[[25,17,7]]"
          CASE ELSE
     END SELECT
END SUB

SUB MAIN_CANVASJOGCONTROL_Draw(BYVAL FMode&)
     LOCAL AFG&, ABG&, AFnt&, CW&, CH&
     AFG&=EZ_FG
     ABG&=EZ_BG
     AFnt&=EZ_Font
     IF FMode&=-1 THEN     ' Initial Data
          CW&=800     ' emulate 8 inches by .01 inch units
          CH&=1050    ' emulate 10.5 inches by .01 inch units
          EZ_StartDraw "Main", %MAIN_CANVASJOGCONTROL, CW&, CH&, ""
          EZ_EndDraw
     END IF
     EZ_Color AFG&, ABG&
     EZ_UseFont AFnt&
END SUB

SUB MAIN_MAINCANVAS_Draw(BYVAL FMode&)
     LOCAL AFG&, ABG&, AFnt&, CW&, CH&
     AFG&=EZ_FG
     ABG&=EZ_BG
     AFnt&=EZ_Font
     IF FMode&=-1 THEN     ' Initial Data
          CW&=800     ' emulate 8 inches by .01 inch units
          CH&=1050    ' emulate 10.5 inches by .01 inch units
          EZ_StartDraw "Main", %MAIN_MAINCANVAS, CW&, CH&, ""
          EZ_EndDraw
     END IF
     EZ_Color AFG&, ABG&
     EZ_UseFont AFnt&
END SUB

SUB MAIN_MAINCANVAS_Events( MyID&, CMsg&, CVal&, Cancel&)
     SELECT CASE CMsg&
          CASE %EZ_SelectCursor
               EZ_SetCursor "",7
               Cancel& = 1
          CASE %EZ_MouseMove
               LOCAL MyX&, MyY&
               ' use EZ_ConvertMousePos to convert to parent Forms coordinates
               MyX&=LOWRD(CVal&)
               MyY&=HIWRD(CVal&)
          CASE %EZ_MouseEnter
          CASE %EZ_MouseLeave
          CASE %EZ_RButtonUp
          CASE %EZ_Size
          CASE %EZ_FreeNow
          CASE %EZ_LButtonDC
          CASE %EZ_LButtonDown
          CASE %EZ_LButtonUp
          CASE %EZ_Sizing
          CASE %EZ_Redraw
          CASE %EZ_Loaded
          CASE %EZ_Click
          CASE ELSE
     END SELECT
END SUB
