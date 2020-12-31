' *************************************************************************************
'                    Portions: Copyright Christoper R. Boss, 2003 to 2011
'                                    All Rights Reserved !
'                 Registered EZGUI 5.0 users may use this code Royalty Free !
' *************************************************************************************

#COMPILE EXE
#DIM ALL
#CONSOLE OFF
' --------------------
#INCLUDE "..\includes\ezgui50.inc"
#INCLUDE "D:\PBWin10\WinAPI\Win32Api.inc"
#INCLUDE "atco.inc"
#INCLUDE "atcoser.inc"
#INCLUDE "file.inc"
' --------------------
GLOBAL hMenu1&
GLOBAL hSubMenu1&
GLOBAL hSubMenu2&
GLOBAL hSubMenu3&
GLOBAL hSubMenu4&
GLOBAL hSubMenu5&
GLOBAL hSubMenu6&
GLOBAL ColorNum&
GLOBAL MyColor&
GLOBAL MyColorFG&
' --------------------
#INCLUDE "..\includes\ezwmain50.inc"
' --------------------
%App_ButtonShape        =   -2
%App_DlgColorFG        =   0
%App_DlgColorBG        =   -2
'
DECLARE SUB MJOGFORM_STOPBTN1_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB MJOGFORM_TEXT1_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB EZ_SETUPFORM_Display(BYVAL FParent$)
DECLARE SUB EZ_SETUPFORM_Design()
DECLARE SUB EZ_SETUPFORM_ParseEvents(CID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_Events(CID&, CMsg&, CVal&, Cancel&)
' ------------------------------------------------

' -------------------------------
%SETUPFORM_Thread1_ID            =1
' -------------------------------
DECLARE SUB SETUPFORM_Thread1Events(BYVAL FormName$, BYVAL CID&, BYVAL CMsg&, CVal&, Cancel&)
' -------------------------------
%SETUPFORM_XSTART             = 100
%SETUPFORM_LABELXSTART        = 105
%SETUPFORM_LABELXEND          = 110
%SETUPFORM_LABELYSTART        = 115
%SETUPFORM_LABELYEND          = 120
%SETUPFORM_LABELXINDEX        = 125
%SETUPFORM_LABELYINDEX        = 130
%SETUPFORM_LABELXSPEED        = 135
%SETUPFORM_LABELYSPEED        = 140
%SETUPFORM_LABELXPOS          = 145
%SETUPFORM_LABELYPOS          = 150
%SETUPFORM_LABELXCTIN         = 155
%SETUPFORM_LABELYCTIN         = 160
%SETUPFORM_LABELXPLUSMIN      = 165
%SETUPFORM_LABELYPLUSMIN      = 170
%SETUPFORM_LABELIDXHL         = 175
%SETUPFORM_LABELXONOFF        = 180
%SETUPFORM_LABELYONOFF        = 185
%SETUPFORM_LABELAUTOHD        = 190
%SETUPFORM_LABELDUALRAS       = 195
%SETUPFORM_LABELOVERLAP       = 200
%SETUPFORM_LABELAPOS          = 205
%SETUPFORM_LABELACTIN         = 210
%SETUPFORM_XEND               = 215
%SETUPFORM_YSTART             = 220
%SETUPFORM_YEND               = 225
%SETUPFORM_XINDEX             = 230
%SETUPFORM_YINDEX             = 235
%SETUPFORM_XSPEED             = 240
%SETUPFORM_YSPEED             = 245
%SETUPFORM_XPOS               = 250
%SETUPFORM_YPOS               = 255
%SETUPFORM_XCTIN              = 260
%SETUPFORM_YCTIN              = 265
%SETUPFORM_XPLUSMIN           = 270
%SETUPFORM_YPLUSMIN           = 275
%SETUPFORM_INDEX              = 280
%SETUPFORM_IDXHL              = 285
%SETUPFORM_XONOFF             = 290
%SETUPFORM_YONOFF             = 295
%SETUPFORM_AUTOHD             = 300
%SETUPFORM_DUALRAS            = 305
%SETUPFORM_OVERLAP            = 310
%SETUPFORM_APOS               = 315
%SETUPFORM_ACTIN              = 320
%SETUPFORM_LABELINDEX         = 325
%SETUPFORM_CALBTN             = 330

DECLARE SUB SETUPFORM_XSTART_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_XEND_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YSTART_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YEND_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_XINDEX_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YINDEX_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_XSPEED_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YSPEED_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_XPOS_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YPOS_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_XCTIN_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YCTIN_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_XPLUSMIN_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YPLUSMIN_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_INDEX_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_IDXHL_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_XONOFF_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_YONOFF_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_AUTOHD_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_DUALRAS_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_OVERLAP_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_APOS_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_ACTIN_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SETUPFORM_CALBTN_Events(MyID&, CMsg&, CVal&, Cancel&)
DECLARE SUB EZ_SPLASHFORM_Display(BYVAL FParent$)
DECLARE SUB EZ_SPLASHFORM_Design()
DECLARE SUB EZ_SPLASHFORM_ParseEvents(CID&, CMsg&, CVal&, Cancel&)
DECLARE SUB SPLASHFORM_Events(CID&, CMsg&, CVal&, Cancel&)
' ------------------------------------------------

SUB EZ_Main(VerNum&)
'    EZ_DebugForm "Debug1"
    EZ_Reg  %EZ_CUSTID ,%EZ_REGNUM
    EZ_LoadPatternLib "", ""
    EZ_FreeColor 19
    EZ_FreeColor 20
    EZ_DefFont -1, "Arial", 30, "BI"
    hMenu1&=EZ_DefMainMenu( 900, "&File", "")
    EZ_Color %App_DlgColorFG, %App_DlgColorBG
    EZ_Form "Main", "", "Common Dialogs", 0,0, 70,24,"CNT"
END SUB
'
SUB EZ_DesignWindow(FormName$)
    SELECT CASE FormName$
        CASE "MAIN"
          MyColor&=RGB(0,255,0)
          EZ_DefColorL 20, MyColor&
          MyColorFG&=RGB(255,255,255)
          EZ_DefColorL  19, MyColorFG&
          EZ_Color 19,2
          EZ_DefFont 10, "Arial", 30, "BI"
          EZ_UseFont 10
          EZ_Label 100, 5, 4, 40, 12, "Common Dialogs", "CF"
          EZ_Color -1,-1
          EZ_AddMenuItem hMenu1&, 910, 0, "&Colors", ""
          EZ_AddMenuItem hMenu1&, 920, 0, "F&onts", ""
          EZ_AddMenuItem hMenu1&, 930, 0, "&Help", ""
          hSubMenu1&=EZ_DefSubMenu(901, "&Open (New Style Dlg)", "")
          EZ_AddMenuItem hSubMenu1&, 902, 0, "Open (O&ld Style Dlg)", ""
          EZ_AddMenuItem hSubMenu1&, 903, 0, "Browse Dlg Files", ""
          EZ_AddMenuItem hSubMenu1&, 904, 0, "Browse Dlg Folders", ""
          EZ_AddMenuItem hSubMenu1&, 905, 0, "Browse Dlg Printers", ""
          EZ_AddMenuItem hSubMenu1&, 906, 0, "E&xit", ""
          EZ_SetSubMenu hMenu1&, 900, hSubMenu1&
          hSubMenu2&=EZ_DefSubMenu(911, "Define Color Style 1", "")
          EZ_AddMenuItem hSubMenu2&, 912, 0, "Define Color Style 2", ""
          EZ_AddMenuItem hSubMenu2&, 913, 0, "Define Color Style 3", ""
          EZ_SetSubMenu hMenu1&, 910, hSubMenu2&
          hSubMenu3&=EZ_DefSubMenu(921, "Define Font Style 1", "")
          EZ_AddMenuItem hSubMenu3&, 922, 0, "Define Font Style 2", ""
          EZ_AddMenuItem hSubMenu3&, 923, 0, "Define Font Style 3", ""
          EZ_SetSubMenu hMenu1&, 920, hSubMenu3&
          hSubMenu4&=EZ_DefSubMenu(931, "&About Program", "")
          EZ_SetSubMenu hMenu1&, 930, hSubMenu4&
'          hSubMenu5&=EZ_DefSubMenu(915, "Option 1", "")
'          EZ_AddMenuItem hSubMenu5&, 916, 0, "Option 2", ""
'          EZ_SetSubMenu hSubMenu1&, 905, hSubMenu5&
        CASE "SETUPFORM"
           EZ_SETUPFORM_Design
        CASE "DLGCHILD"
            EZ_Color 0,15
            EZ_Canvas 100,0,0,26,13, "S"
        CASE ELSE
    END SELECT
END SUB
SUB EZ_SETUPFORM_Display(BYVAL FParent$)     ' (PROTECTED)
     EZ_Color -1, -1
     EZ_AllowLoadingEvent 2
     EZ_Form "SETUPFORM", FParent$, "MCU Settings", 0, 0, 106, 46, "CRZ"
END SUB

SUB EZ_SETUPFORM_Design()     ' (PROTECTED)
     LOCAL CText$
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_SubClass 2
     EZ_Text %SETUPFORM_XSTART, 17, 2, 15, 1, "", "EST"
     EZ_SubClass 0
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXSTART, 2, 2, 12, 1, "X Start", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXEND, 2, 4, 12, 1, "X End", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYSTART, 2, 6, 12, 1, "Y Start", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYEND, 2, 8, 12, 1, "Y End", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXINDEX, 2, 10, 12, 1, "X Index", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYINDEX, 2, 12, 12, 1, "Y Index", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXSPEED, 2, 14, 12, 1, "X Speed", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYSPEED, 2, 16, 12, 1, "Y Speed", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXPOS, 34.375, 1.9375, 12, 1, "X POS", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYPOS, 34.375, 3.9375, 12, 1, "Y POS", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXCTIN, 34.375, 5.9375, 12, 1, "X CT/IN", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYCTIN, 34.375, 7.9375, 12, 1, "Y  CT/IN", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXPLUSMIN, 34.375, 9.9375, 12, 1, "X +/-", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYPLUSMIN, 34.375, 11.9375, 12, 1, "Y +/-", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELIDXHL, 34.375, 15.9375, 12, 1, "IDX H/L", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELXONOFF, 66.25, 2, 12, 1, "X ON/OFF", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELYONOFF, 66.25, 4, 12, 1, "Y ON/OFF", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELAUTOHD, 66.25, 6, 12, 1, "AUTO HD", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELDUALRAS, 66.25, 8, 12, 1, "DUALRAS", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELOVERLAP, 66.25, 10, 12, 1, "OVERLAP", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELAPOS, 66.25, 12, 12, 1, "A POS", "C"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELACTIN, 66.25, 14, 12, 1, "A CT/IN", "C"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_XEND, 17, 4, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YSTART, 17, 6, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YEND, 17, 8, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_XINDEX, 17, 9.875, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YINDEX, 17, 11.875, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_XSPEED, 17, 13.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YSPEED, 17, 15.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_XPOS, 48.375, 1.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YPOS, 48.375, 3.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_XCTIN, 48.375, 5.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YCTIN, 48.375, 7.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_XPLUSMIN, 48.375, 9.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YPLUSMIN, 48.375, 11.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_INDEX, 48.375, 14, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_IDXHL, 48.375, 15.9375, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_XONOFF, 80.25, 2, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_YONOFF, 80.25, 4, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_AUTOHD, 80.25, 6, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_DUALRAS, 80.25, 8, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_OVERLAP, 80.25, 10, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_APOS, 80.25, 12, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color-1,-1
     EZ_UseFont 4
     EZ_AllowLoadingEvent 2
     EZ_UseAutoSize "VH"
     EZ_Text %SETUPFORM_ACTIN, 80.25, 14, 15, 1, "", "EST"
     ' -----------------------------------------------
     EZ_Color 0, 11
     EZ_UseFont 4
     EZ_UseAutoSize "VH"
     EZ_Label %SETUPFORM_LABELINDEX, 34.375, 13.9375, 12, 1, "INDEX", "C"
     ' -----------------------------------------------
     EZ_Color 12, 15
     EZ_UseFont 4
     EZ_ODButton %SETUPFORM_CALBTN, 2, 19, 25, 6, "Calibrate Encoders", "T"
     EZ_SetRegion "SetupForm", %SETUPFORM_CALBTN,-2,0
     ' -----------------------------------------------
END SUB

SUB SETUPFORM_Events(CID&, CMsg&, CVal&, Cancel&)
     SELECT CASE CID&
          CASE %EZ_Window
               SELECT CASE CMsg&
                    CASE %EZ_Loading
                    CASE %EZ_Loaded
                         'CALL SetDefaults
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XSTART,  SCANstruc.XLowStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XEND,    SCANstruc.XHighStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YSTART,  SCANstruc.YLowStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YEND,    SCANstruc.YHighStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XINDEX,  SCANstruc.XIndexSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YINDEX,  SCANstruc.YIndexSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XSPEED,  SCANstruc.XSpeedSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YSPEED,  SCANstruc.YSpeedSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XPOS,    SCANstruc.XPosStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YPOS,    SCANstruc.YPosStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XCTIN,   SCANstruc.XCtrStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YCTIN,   SCANstruc.YCtrStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XPLUSMIN,SCANstruc.XPlusSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YPLUSMIN,SCANstruc.YPlusSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_INDEX,   SCANstruc.IndexYSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_IDXHL,   SCANstruc.IndexLowStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_XONOFF,  SCANstruc.XEnableSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_YONOFF,  SCANstruc.YEnableSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_AUTOHD,  SCANstruc.AutoHoldSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_DUALRAS, SCANstruc.DualRasSTR
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_OVERLAP, SCANstruc.OverLapStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_APOS,    SCANstruc.APosStr
                         EZ_SetText   "SETUPFORM",  %SETUPFORM_ACTIN,   SCANstruc.ACtrStr
                         '-----------------------------------------------------------------------------
                    CASE %EZ_Started
                    CASE %EZ_Close
                    CASE ELSE
               END SELECT
          CASE ELSE
     END SELECT
END SUB

SUB EZ_SETUPFORM_ParseEvents(CID&, CMsg&, CVal&, Cancel&)     ' (PROTECTED)
     SELECT CASE CID&
          CASE %EZ_Window
               SETUPFORM_Events CID&, CMsg&, CVal&, Cancel&
               IF CMsg&=%EZ_Started OR CMsg&=%EZ_Close THEN
                    SETUPFORM_Thread1Events "SETUPFORM", %SETUPFORM_Thread1_ID, CMsg&, CVal&, Cancel&
               END IF
          CASE %SETUPFORM_Thread1_ID
               SETUPFORM_Thread1Events "SETUPFORM", CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XSTART
               SETUPFORM_XSTART_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XEND
               SETUPFORM_XEND_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YSTART
               SETUPFORM_YSTART_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YEND
               SETUPFORM_YEND_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XINDEX
               SETUPFORM_XINDEX_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YINDEX
               SETUPFORM_YINDEX_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XSPEED
               SETUPFORM_XSPEED_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YSPEED
               SETUPFORM_YSPEED_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XPOS
               SETUPFORM_XPOS_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YPOS
               SETUPFORM_YPOS_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XCTIN
               SETUPFORM_XCTIN_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YCTIN
               SETUPFORM_YCTIN_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XPLUSMIN
               SETUPFORM_XPLUSMIN_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YPLUSMIN
               SETUPFORM_YPLUSMIN_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_INDEX
               SETUPFORM_INDEX_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_IDXHL
               SETUPFORM_IDXHL_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_XONOFF
               SETUPFORM_XONOFF_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_YONOFF
               SETUPFORM_YONOFF_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_AUTOHD
               SETUPFORM_AUTOHD_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_DUALRAS
               SETUPFORM_DUALRAS_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_OVERLAP
               SETUPFORM_OVERLAP_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_APOS
               SETUPFORM_APOS_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_ACTIN
               SETUPFORM_ACTIN_Events CID&, CMsg&, CVal&, Cancel&
          CASE  %SETUPFORM_CALBTN
               SETUPFORM_CALBTN_Events CID&, CMsg&, CVal&, Cancel&
               IF CMsg&=%EZ_OwnerDraw THEN
                    EZ_Draw3DButtonRR "SetupForm", %SETUPFORM_CALBTN, CVal&, 15, 12,  4
               END IF
          CASE ELSE
               SETUPFORM_Events CID&, CMsg&, CVal&, Cancel&
     END SELECT
END SUB

SUB SETUPFORM_Thread1Events(BYVAL FormName$, BYVAL CID&, BYVAL CMsg&, CVal&, Cancel&)
     LOCAL STM&
     SELECT CASE CMsg&
          CASE %EZ_ThreadCode     ' Non-GUI Thread Code
               ' Cancel&=0      ' prevents %EZ_Thread event
          CASE %EZ_Thread         ' GUI Thread Code
          CASE %EZ_Started        ' Start Thread !
               STM&=10             ' millisecond delay
               EZ_StartThread FormName$, CID&, STM&
          CASE %EZ_Close          ' Terminate Thread when form closes !
               EZ_CloseThread FormName$, CID&
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XSTART_Events( MyID&, CMsg&, CVal&, Cancel&)
LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                  SCANstruc.XLow = ABS(VAL(TXT$))
                  SCANstruc.XLowStr = QStr$(SCANstruc.XLow, 10)
                END IF
          CASE %EZ_LButtonDown
          CASE %EZ_Loading
            '     V$ = EZ_GetLoadStr("T")
            '      EZ_SetLoadStr "T", "Hello World!"
          CASE %EZ_KeyDown
          CASE %EZ_Loaded
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XEND_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change

          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                   SCANstruc.XHigh = ABS(VAL(TXT$))
                   SCANstruc.XHighStr = QStr$(SCANstruc.XHigh, 10)
                END IF
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YSTART_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YLow = ABS(VAL(TXT$))
                       SCANstruc.YLowStr = QStr$(SCANstruc.YLow, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YEND_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YHigh = ABS(VAL(TXT$))
                       SCANstruc.YHighStr = QStr$(SCANstruc.YHigh, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XINDEX_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                 IF GoodSNG(TXT$) THEN
                       SCANstruc.XIndex = ABS(VAL(TXT$))
                       SCANstruc.XIndexSTR = QStr$(SCANstruc.XIndex, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YINDEX_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YIndex = ABS(VAL(TXT$))
                       SCANstruc.YIndexSTR = QStr$(SCANstruc.YIndex, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XSPEED_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                       SCANstruc.XSpeed = ABS(VAL(TXT$))
                       SCANstruc.XSpeedSTR = QStr$(SCANstruc.XSpeed, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YSPEED_Events( MyID&, CMsg&, CVal&, Cancel&)
    LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
               IF GoodSNG(TXT$) THEN
                       SCANstruc.YSpeed = ABS(VAL(TXT$))
                       SCANstruc.YSpeedSTR = QStr$(SCANstruc.YSpeed, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XPOS_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                       SCANstruc.XPos = ABS(VAL(TXT$))
                       SCANstruc.XPosStr = QStr$(SCANstruc.XPos, 10)
                       SCANstruc.XOffset = GetXCord(CLNG(SCANstruc.XPos * SCANstruc.XCtr))
                       CALL ResetPosition(Servo1)
                       CALL ResetPosition(Servo2)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YPOS_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                       SCANstruc.YPos = VAL(TXT$)
                       SCANstruc.YPosStr = QStr$(SCANstruc.YPos, 10)
                       SCANstruc.YOffset = GetYCord(CLNG(SCANstruc.YPos * SCANstruc.YCtr))
                       CALL ResetPosition(Servo3)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XCTIN_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodLNG(TXT$) THEN
                       SCANstruc.XCtr = ABS(VAL(TXT$))
                       SCANstruc.XCtrStr = QStr$(SCANstruc.XCtr, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YCTIN_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_NoFocus
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodLNG(TXT$) THEN
                     SCANstruc.YCtr = ABS(VAL(TXT$))
                     SCANstruc.YCtrStr = QStr$(SCANstruc.YCtr, 10)
                END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XPLUSMIN_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
          CASE %EZ_KeyDown
               IF CVal& = %EZK_RIGHT THEN
                    SCANstruc.XPlus = TRUE
                    SCANstruc.XPlusSTR = "POSITIVE  "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_XPLUSMIN, "POSITIVE"
                ELSEIF CVal& = %EZK_LEFT THEN
                    SCANstruc.XPlus = FALSE
                    SCANstruc.XPlusSTR = "NEGATIVE  "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_XPLUSMIN, "NEGATIVE"
            END IF
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YPLUSMIN_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_KeyDown
               IF CVal& = %EZK_RIGHT THEN
                    SCANstruc.YPlus = TRUE
                    SCANstruc.YPlusSTR = "POSITIVE  "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_YPLUSMIN, "POSITIVE"
                ELSEIF CVal& = %EZK_LEFT THEN
                    SCANstruc.YPlus = FALSE
                    SCANstruc.YPlusSTR = "NEGATIVE  "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_YPLUSMIN, "NEGATIVE"
            END IF
          CASE %EZ_Change
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_INDEX_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
          CASE %EZ_KeyDown
              IF CVal& = %EZK_RIGHT THEN
                SCANstruc.IndexY = FALSE
                SCANstruc.IndexYSTR = "X         "
                EZ_SetText   "SETUPFORM",  %SETUPFORM_INDEX, "X         "
              ELSEIF CVal& = %EZK_LEFT THEN
                SCANstruc.IndexY = TRUE
                SCANstruc.IndexYSTR = "Y         "
                EZ_SetText   "SETUPFORM",  %SETUPFORM_INDEX,  "Y         "
            END IF
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_IDXHL_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
          CASE %EZ_KeyDown
           IF CVal& = %EZK_RIGHT THEN
                SCANstruc.IndexLow = TRUE
                SCANstruc.IndexLowStr = "HIGH - LOW"
                EZ_SetText   "SETUPFORM",  %SETUPFORM_IDXHL, "HIGH - LOW"
           ELSEIF CVal& = %EZK_LEFT THEN
               SCANstruc.IndexLow = FALSE
               SCANstruc.IndexLowStr = "LOW - HIGH"
               EZ_SetText   "SETUPFORM",  %SETUPFORM_IDXHL,  "LOW - HIGH"
         END IF
'----------------------------
'----------------------------
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_XONOFF_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
          CASE %EZ_KeyDown
           IF CVal& = %EZK_RIGHT THEN
                SCANstruc.XEnable = FALSE
                SCANstruc.XEnableSTR = "OFF       "
                CALL EnableAmpl(SCANstruc.XEnable, Servo1)
                CALL EnableAmpl(SCANstruc.XEnable, Servo2)
                EZ_SetText   "SETUPFORM",  %SETUPFORM_XONOFF,  "OFF       "
           ELSEIF CVal& = %EZK_LEFT THEN
               SCANstruc.XEnable = TRUE
               SCANstruc.XEnableSTR = "ON        "
               CALL StopXMtrs
               EZ_SetText   "SETUPFORM",  %SETUPFORM_XONOFF,   "ON        "
           END IF
'----------------------------
'----------------------------
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_YONOFF_Events( MyID&, CMsg&, CVal&, Cancel&)
    LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
          CASE %EZ_KeyDown
          IF CVal& = %EZK_RIGHT THEN
              SCANstruc.YEnable = FALSE
              SCANstruc.YEnableSTR = "OFF       "
              CALL EnableAmpl(SCANstruc.YEnable, Servo1)
              CALL EnableAmpl(SCANstruc.YEnable, Servo2)
              EZ_SetText   "SETUPFORM",  %SETUPFORM_YONOFF,  "OFF       "
          ELSEIF CVal& = %EZK_LEFT THEN
              SCANstruc.YEnable = FALSE
              SCANstruc.YEnableSTR = "ON        "
              CALL StopYMtr
              EZ_SetText   "SETUPFORM",  %SETUPFORM_YONOFF,   "ON        "
          END IF
'----------------------------
'----------------------------
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_AUTOHD_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
          CASE %EZ_KeyDown
              IF CVal& = %EZK_RIGHT THEN
                    SCANstruc.AutoHold = FALSE
                    SCANstruc.AutoHoldSTR = "OFF       "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_AUTOHD,   "OFF       "
              ELSEIF CVal& = %EZK_LEFT THEN
                    SCANstruc.AutoHold = TRUE
                    SCANstruc.AutoHoldSTR = "ON        "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_AUTOHD,   "ON        "
              END IF
'----------------------------
'----------------------------
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_DUALRAS_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
          CASE %EZ_KeyDown
              IF CVal& = %EZK_RIGHT THEN
                    SCANstruc.DualRas = FALSE
                    SCANstruc.DualRasSTR = "OFF       "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_DUALRAS,   "OFF       "
              ELSEIF CVal& = %EZK_LEFT THEN
                    SCANstruc.DualRas = TRUE
                    SCANstruc.DualRasSTR = "ON        "
                    EZ_SetText   "SETUPFORM",  %SETUPFORM_DUALRAS,   "ON        "
              END IF
          CASE %EZ_Loaded
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_OVERLAP_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                 IF GoodSNG(TXT$) THEN
                    SCANstruc.OverLap = ABS(VAL(TXT$))
                    SCANstruc.OverLapStr = QStr$(SCANstruc.OverLap, 10)
                END IF
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_APOS_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodSNG(TXT$) THEN
                    SCANstruc.APos = ABS(VAL(TXT$))
                    SCANstruc.APosStr = QStr$(SCANstruc.APos, 10)
                    SCANstruc.AOffset = GetXCord(CLNG(SCANstruc.APos * SCANstruc.ACtr))
                    CALL ResetPosition(Servo4)
                END IF
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_ACTIN_Events( MyID&, CMsg&, CVal&, Cancel&)
     LOCAL TXT AS STRING
     SELECT CASE CMsg&
          CASE %EZ_Change
                TXT$ = EZ_GetText( "SETUPFORM",  MyID& )
                IF GoodLNG(TXT$) THEN
                    SCANstruc.ACtr = ABS(VAL(TXT$))
                    SCANstruc.ACtrStr = QStr$(SCANstruc.ACtr, 10)
                 END IF
          CASE ELSE
     END SELECT
END SUB

SUB SETUPFORM_CALBTN_Events( MyID&, CMsg&, CVal&, Cancel&)
     SELECT CASE CMsg&
          CASE %EZ_Click
             'EZ_CALFORM_Display "CALFORM"
          CASE ELSE
     END SELECT
END SUB




SUB DS_Draw3DButton(BYVAL FormName$, BYVAL CID&, BYVAL CVal&)
    EZ_Color 0,31
    IF EZ_Handle(FormName$,CID&)<>0 THEN
        SELECT CASE %App_ButtonShape
            CASE 1
                EZ_Draw3DButtonE FormName$, CID&, CVal&, 31, 0, 4
            CASE 2, -2
                EZ_Draw3DButtonRR FormName$, CID&, CVal&, 31, 0, 4
            CASE ELSE
                EZ_Draw3DButton FormName$, CID&, CVal&, 31, 0, 4
        END SELECT
    END IF
END SUB
'
SUB UpdateCanvas(BYVAL P$)
    LOCAL PN$, CW&, CH&, PW&, PH&, X&, Y&
    IF P$<>"" THEN PN$=EZ_LoadPicture(P$)
    IF PN$<>"" THEN
        EZ_GetCanvasSize "DLGCHILD", 100, CW&, CH&
        EZ_StartDraw "DLGCHILD", 100, CW&, CH&, ""
            EZ_Clear "DLGCHILD", 100
            EZ_GetPictureSize PN$, PW&, PH&
            IF PW&>CW& THEN PW&=CW&
            IF PH&>CH& THEN PH&=CH&
            X&=(CW&-PW&)/2
            Y&=(CH&-PH&)/2
            EZ_SetDrawMode  1,3
            EZ_CDrawPicture X&, Y&, PW&, PH&, PN$,""
        EZ_EndDraw
        EZ_FreeImage PN$
    ELSE
        EZ_Clear "DLGCHILD", 100
    END IF
END SUB
'
SUB EZ_Events(FormName$, CID&, CMsg&, CVal&, Cancel&)
LOCAL X&, CP$, D$, P$, TF$, PS&, FP$
SELECT CASE FormName$
    CASE "MAIN"     ' or any Form Name you choose
        SELECT CASE CID&
            CASE %EZ_Window         ' This is a Window message
                IF CMsg&=%EZ_ShowCommonDlg THEN
                END IF
            CASE 901, 902
                IF CMsg&=%EZ_Click THEN
                   P$="PRZ"
                   IF CID&=902 THEN P$=P$+"NS"
                   EZ_Color %App_DlgColorFG,%App_DlgColorBG
                   EZ_ChangeDlgButtons %App_ButtonShape
                   D$=EZ_OpenFile("Main","Select Bitmap:", "", "Bitmaps (*.bmp))|*.bmp|", P$)
                   EZ_Color 15, -56
                   EZ_MsgBox "Main", D$, "Filename Returned", "OK"
                   EZ_Color -1, -1
                END IF
            CASE 903, 904, 905
                IF CMsg&=%EZ_Click THEN
                   EZ_Color %App_DlgColorFG,%App_DlgColorBG
                   EZ_ChangeDlgButtons %App_ButtonShape
                   SELECT CASE CID&
                       CASE 903
                           D$=EZ_BrowseFolderDlg("Main", "Search for Files:", EZ_AppPath,"F")
                       CASE 904
                           D$=EZ_BrowseFolderDlg("Main", "Search for Folders:", "","D")
                       CASE 905
                           D$=EZ_BrowseFolderDlg("Main", "Search for Printers:","","P")
                   END SELECT
                   EZ_Color 15, -56
                   EZ_MsgBox "Main", D$, "Filename Returned", "OK"
                END IF
            CASE 911
                IF CMsg&=%EZ_Click THEN
                   EZ_Color %App_DlgColorFG,%App_DlgColorBG
                   EZ_ChangeDlgButtons %App_ButtonShape
                   IF EZ_ChooseColor("Main", MyColor&, "") THEN
                      GOSUB ChangeColor
                   END IF
                END IF
            CASE 912
                IF CMsg&=%EZ_Click THEN
                   EZ_Color %App_DlgColorFG,%App_DlgColorBG
                   EZ_ChangeDlgButtons %App_ButtonShape
                   IF EZ_ChooseColor("Main", MyColor&, "F") THEN
                      GOSUB ChangeColor
                   END IF
                END IF
            CASE 913
                IF CMsg&=%EZ_Click THEN
                   EZ_Color %App_DlgColorFG,%App_DlgColorBG
                   EZ_ChangeDlgButtons %App_ButtonShape
                   IF EZ_ChooseColor("Main", MyColor&, "N") THEN
                      GOSUB ChangeColor
                   END IF
                END IF
            CASE 931
                LOCAL T AS STRING
                LOCAL RV AS LONG
                IF CMsg&=%EZ_Click THEN
                 '   T$="!Are you ready to go on ?|Only one chance !{?}"
                 '   RV& = EZ_MsgBox("Main", T$, "Message Alert!", "YN")
                     EZ_SETUPFORM_Display "SETUPFORM"
                END IF
            CASE 921, 922, 923
                IF CMsg&=%EZ_Click THEN
                   P$="C"
                   IF CID&=922 THEN P$="F"
                   IF CID&=923 THEN P$=P$+"S"
                   EZ_Color %App_DlgColorFG,%App_DlgColorBG
                   EZ_ChangeDlgButtons %App_ButtonShape
                   IF EZ_ChooseFont("Main", MyColorFG&, P$) THEN
                      EZ_UnloadControl "Main", 100
                      EZ_SetForm "Main", 0
                      EZ_FreeColor 19
                      EZ_FreeColor 20
                      EZ_DefColorL 19, MyColorFG&
                      EZ_DefColorL 20, MyColor&
                      EZ_Color 19,20
                      EZ_FreeFont 10
                      EZ_DefSFont 10
                      EZ_GetSFont TF$, PS&, FP$
                      EZ_UseFont 10
                      EZ_Label 100, 5, 4, 40, 12, "Common Dialogs", "C"
                      EZ_Color 15, -56
                      EZ_MsgBox "Main", "EZ_GetSFont returns:"+CHR$(13)+CHR$(10)+TF$+STR$(PS&)+" Point ("+FP$+")", "Font Selected", "OK"
                      EZ_Color -1,-1
                   END IF
                END IF
            CASE 906
                IF CMsg&=%EZ_Click THEN
                   EZ_UnloadForm "Main"
                END IF
            CASE ELSE
        END SELECT
    CASE "{OPENDLGX}", "{OPENDLG}"
        SELECT CASE CID&
            CASE %EZ_Window
                  IF CMsg&=%EZ_Loaded THEN
                     DIM CW!, CH!
                     EZ_GetSize FormName$, CW!, CH!,0
                     EZ_ExpandForm FormName$, 30,0
                     EZ_HideC FormName$, -1,-1  ' hide corner scrollbar
                     EZ_Color 0,15
                     EZ_Form "DLGCHILD", FormName$, "", CW!+1, .5, 26, 13,"P"
                     EZ_CenterForm "Main", FormName$,0
                 END IF
             CASE 1152, 1148  ' textbox on standard dialog or combobox on explorer dialog
                 IF CMsg&=%EZ_Change THEN
                    UpdateCanvas EZ_GetText(FormName$,CID&)
                 END IF
            CASE ELSE
                 IF CMsg&=%EZ_OwnerDraw THEN
                    DS_Draw3DButton FormName$, CID&, CVal&
                 END IF
        END SELECT
    CASE  "{SAVEDLG}" ,  "{SAVEDLGX}", _
         "{COLORDLG}"
         SELECT CASE CID&
             CASE %EZ_Window
                 IF CMsg&=%EZ_Click THEN
                 END IF
                 IF CMsg&=%EZ_Change THEN
                 END IF
                 IF CMsg&=%EZ_Loaded THEN
                     EZ_CenterForm "Main", FormName$,0
                 END IF
             CASE ELSE
                 IF CMsg&=%EZ_OwnerDraw THEN
                    DS_Draw3DButton FormName$, CID&, CVal&
                 END IF
         END SELECT
    CASE "{FONTDLG}"
         SELECT CASE CID&
             CASE %EZ_Window
                 IF CMsg&=%EZ_Loaded THEN
                     EZ_CenterForm "Main", FormName$,0
                     EZ_HideC FormName$, 1139,1139  ' hide color combobox
                     EZ_HideC FormName$, 1091,1091  ' hide color label
                 END IF
             CASE ELSE
                 IF CMsg&=%EZ_OwnerDraw THEN
                    DS_Draw3DButton FormName$, CID&, CVal&
                 END IF
         END SELECT
    CASE "{BROWSEDLG}"
         SELECT CASE CID&
             CASE %EZ_Window
                 IF CMsg&=%EZ_Loaded THEN
                     EZ_CenterForm "Main", FormName$,0
'                     EZ_HideC FormName$, 1139,1139  ' hide color combobox
'                     EZ_HideC FormName$, 1091,1091  ' hide color label
                 END IF
             CASE ELSE
                 IF CMsg&=%EZ_OwnerDraw THEN
                    DS_Draw3DButton FormName$, CID&, CVal&
                 END IF
         END SELECT
    CASE ELSE
END SELECT
EXIT SUB
'
ChangeColor:
EZ_UnloadControl "Main", 100
EZ_SetForm "Main", 0
EZ_FreeColor 20
EZ_DefColorL 20, MyColor&
EZ_Color 19, 20
EZ_Label 100, 5, 4, 40, 12, "Common Dialogs", "C"
EZ_Color -1,-1
RETURN
'
END SUB
