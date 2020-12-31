' *************************************************************************************
'         Copyright 2001 to 2011 Christopher R. Boss , All Rights Reserved !
'                   Royalty Free right to use provided EZGUI code by
'                Licensed users of  EZGUI 5.0 Professional DLL Library
'
' The text in this file MUST NOT be published publicly in any way shape or form.
' It MUST NOT be distributed with any of your EZGUI applications.
' This is proprietary information that can only be used by Licensed users of EZGUI 5.0.
' Any unauthorized distribution of this document by the Licensee of EZGUI will be
' considered a breach of the License Agreement and will be grounds for revoking such
' License and possibly grounds for lawsuit for any damages caused by such unauthorized
' distribution. An EZGUI application that is compiled does not need this file to run.
' *************************************************************************************

' -------------------------------
' Enter your User number and
' Registration number below:
' -------------------------------
%EZ_CUSTID      =   0
%EZ_REGNUM      =   0
' -------------------------------
%EZ_NOSKIPCODE  =   0

TYPE EZGUIMAX
    MaxColors AS LONG
    MaxFonts AS LONG
    MaxImages AS LONG
    MaxControls AS LONG
    MaxForms AS LONG
    MaxMenus AS LONG
END TYPE

%EZ_DECtrls       =     32
%EZ_LastPatNum    =   -57
%EZ_FirstPatNum   =   -2

' Equates for Drag Handle control

%EZ_USER                    = &H400     ' Same thing as %WM_USER in API header file


%EZDC_SETCOLOR              =   %EZ_USER+100    ' wParam = RGB Color, lParam = 0,1,2 (Inside Color 1, Border Color, Inside Color 2)
%EZDC_SETBUDDY              =   %EZ_USER+101    ' wParam = Buddy Window Handle
%EZDC_SETSIZE               =   %EZ_USER+102    ' wParam = Size of handles in Pixels
%EZDC_GETCOLOR              =   %EZ_USER+120    ' wParam = Not Used, lParam = 0,1,2 (Inside Color 1, Border Color, Inside Color 2)
%EZDC_GETBUDDY              =   %EZ_USER+121    ' No Parameters
%EZDC_GETSIZE               =   %EZ_USER+122    ' No Parameters
%EZDC_GETOFFSET             =   %EZ_USER+123    ' No Parameters


'        Equates for Events

%EZ_VScroll     =   -1
%EZ_HScroll     =   -2
%EZ_Window      =   0
%EZ_Close       =   0
%EZ_Click       =   1
%EZ_DClick      =   2
%EZ_Focus       =   3
%EZ_NoFocus     =   4
%EZ_Disable     =   5
%EZ_Change      =   6
%EZ_Timer       =   7
%EZ_ToolTip     =   8
%EZ_UnKnown     =   9
%EZ_Command     =   9       ' same as %EZ_UnKnown
%EZ_Notify      =   10
%EZ_Redraw      =   11      ' request for manual redraw of control
%EZ_CtrlError   =   -1      ' Custom Controls can use this indicate an error occurred
%EZ_PrintError  =   -1      ' Printer Error - Send to Abort Dialog
%EZ_AllowEdit   =   20      ' for ListView control
%EZ_DragForm    =   21
%EZ_SysMenu     =   22
%EZ_DClickCap   =   23
%EZ_NoDClick    =   24
%EZ_DoMDIMsg    =   28
%EZ_GameLoop    =   29

%EZ_KeyDown     =   30
%EZ_KeyUp       =   31
%EZ_KeyPress    =   32
%EZ_Enable      =   34   ' not used currently
' ---------------------
' new to 5.0
' ---------------------
%EZ_HelpShow    =   35
%EZ_HelpShowC   =   36
%EZ_HelpShowM   =   37
%EZ_HelpShowID  =   38
' ---------------------
%EZ_SysKeyDown  =   40
%EZ_SysKeyUp    =   41
%EZ_SysKeyPress =   42
%EZ_ActivateMe  =   43

%EZ_FinishMCI   =   50
%EZ_FlagMCI     =   51

%EZ_AppFocus    =   55
%EZ_NoAppFocus  =   56
%EZ_CBDropDown  =  57
%EZ_CBDropUp    =  58

%EZ_NoAutoSize  =   59
%EZ_ChangeZOrder =   60
%EZ_ChangeSize   =   61
%EZ_ChangePos    =   62
%EZ_PollCtrl     =   63
' -------------------------------------
'  values for Cancel& parameter of %EZ_PollCtrl
' -------------------------------------
    %EZ_PollStopSel     =   &H100000
    %EZ_PollCustomCode  =   &H400000
' -------------------------------------
%EZ_NextCtrl     =   64
%EZ_CaptureOff  =   65
%EZ_AllowFirstCtrl= 66
%EZ_RTFLink     =   70
%EZ_Updated     =   75
%EZ_ConvBtnPos  =   77
%EZ_DoDefFocus  =  78
%EZ_Compare     =   81
%EZ_InitPropDlg =   82
%EZ_Loading     =   85
%EZ_Started     =   86
%EZ_Loaded      =   87

%EZ_FreeNow     =   88
%EZ_LButtonDown =   89
%EZ_LButtonUp   =   90

%EZ_LButtonDC   =   93
%EZ_MButtonUp   =   94
%EZ_RButtonUp   =   95
%EZ_DragClear   =   97   ' EZGUI 5.0 event
%EZ_DragPos     =   98   ' EZGUI 5.0 event
%EZ_SubClass    =   99
%EZ_Drag        =   100
%EZ_Drop        =   101
%EZ_Size        =   102
%EZ_DropFiles   =   103
%EZ_Cancel      =   104
%EZ_NoDrag      =   105
%EZ_DragItem    =   106
%EZ_Move        =   107
%EZ_Dropping    =   108
%EZ_DragItemDrop =  109


%EZ_Default     =   -1

' --------------------------------------
' new 3.0 events
%EZ_Maximize    =   110
%EZ_Minimize    =   111
%EZ_Restore     =   112
%EZ_MouseMove   =   120
%EZ_MouseEnter  =   122
%EZ_MouseLeave  =   123
%EZ_Sizing      =   125
%EZ_AutoSizeStart   =     126
%EZ_AutoSizeEnd     =    127
%EZ_ScaleMe         =    128

%EZ_SelectCursor        =   130
%EZ_TrayLButtonDown     =   200
%EZ_TrayLButtonUp       =   205
%EZ_TrayRButtonDown     =   210
%EZ_TrayRButtonUp       =   215
%EZ_TrayDClick          =   220

%EZ_HotMouseMove        =   221    ' new to 5.0
%EZ_HotMouseEnter       =   222    ' new to 5.0
%EZ_HotMouseLeave       =   223    ' new to 5.0

%EZ_FormSizable         =   229
%EZ_TextUpdated         =   230
%EZ_AttrUpdated         =   231
%EZ_ColorUpdated        =   232
%EZ_FontUpdated         =   233
%EZ_SelUpdated          =   234
%EZ_ClearUpdated        =   235
%EZ_BitmapUpdated       =   236
%EZ_IconUpdated         =   237
%EZ_CmpSet              =   238
%EZ_CmpGet              =   239


%EZ_OwnerDraw           =   300
%EZ_OwnerSize           =   310
%EZ_NoCustomDraw        =   315
%EZ_CustomDraw          =   316
%EZ_PaintBG             =   320
%EZ_EraseBG             =   %EZ_PaintBG
%EZ_PaintSP             =   322    ' new to EZGUI 5.0 for splitter control
%EZ_EraseSP             =   %EZ_PaintSP
%EZ_Thread              =   400
%EZ_ThreadP             =   405
%EZ_ThreadCode          =   407
%EZ_Post                =   410
%EZ_Collapse            =   500
%EZ_Expand              =   510
%EZ_Selected            =   520
%EZ_SMSelected          =   522
%EZ_MenuClose           =   523
%EZ_MenuShow            =   524
%EZ_UnSelected          =   530
%EZ_Terminate           =   -100
%EZ_ScrollBG            =   600
%EZ_ScrollBGKey         =   610
%EZ_DragItemID          =   611
%EZ_DragItemDraw        =   612
%EZ_NoLeftSize          =   700
%EZ_NoRightSize         =   701
%EZ_NoTopSize           =   702
%EZ_NoBottomSize        =   703
%EZ_MinMax              =   750
%EZ_EditSetSel          =   800
%EZ_SaveSetSel          =   801
%EZ_LVClickInfo         =   900
%EZ_LVDClickInfo        =   910
%EZ_SetODChildID        =   920
' --------------------------------------
'    EZGUI 4.0 Events
' --------------------------------------
%EZ_FindDlgTerminate    =   950
%EZ_FindDlgFindNext     =   951
%EZ_FindDlgReplace      =   952
%EZ_FindDlgReplaceAll   =   953
%EZ_ShowCommonDlg       =   960
' --------------------------------------
'    EZGUI 5.0 Events
' --------------------------------------
%EZ_ChildFocus             =  970   ' must be in increment by 1 sequence the following events
%EZ_ChildNoFocus           =  971
%EZ_ChildReturn            =  972
%EZ_ChildEscape            =  973
%EZ_ChildShow              =  974
%EZ_ChildHide              =  975
%EZ_ChildUpdate            =  976
' --------------------------------------
%EZ_NoTheme                =  -9
%EZ_NoVirtualSize          =  -10
%EZ_SysChange              =  -11
%EZ_PTimer                 =  -12
' --------------------------------------

%EZ_UserEvent              = 9000   ' allow user defined events


' new EZGUI 3.0 constants
%MDIClientID   =   25


%EZNULL_BRUSH   =   -58

' *************************************************************************************
'                            EZGUI  Functions
' *************************************************************************************
DECLARE SUB EZ_Form  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Parent$, BYVAL Caption$, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL Style$)
DECLARE SUB EZ_SetForm  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL FmFocus&)
DECLARE SUB EZ_ShowForm  LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_HideForm  LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_UnloadForm  LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_SetRowCol  LIB "ezgui50.dll" (BYVAL Flag&)
DECLARE SUB EZ_DefCharSize  LIB "ezgui50.dll" (BYVAL W&, BYVAL H&)
DECLARE SUB EZ_GetScreenSize  LIB "ezgui50.dll" ( SW&, SH&)

' --------------------------------------------------------------

DECLARE SUB EZ_SetText  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL CText$)
DECLARE FUNCTION EZ_GetText LIB "ezgui50.dll"  (BYVAL FormName$, BYVAL ID&) AS STRING
DECLARE SUB EZ_SetCheck  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL V&)
DECLARE FUNCTION EZ_GetCheck  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE FUNCTION EZ_LoadPicture  LIB "ezgui50.dll" (BYVAL BName$) AS STRING
DECLARE FUNCTION EZ_LoadIcon  LIB "ezgui50.dll" (BYVAL BName$) AS STRING
DECLARE SUB EZ_FreeImage LIB "ezgui50.dll" (BYVAL IName$)
DECLARE SUB EZ_SetVScroll LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL SMin&, BYVAL SMax&, BYVAL SPos&, BYVAL SJmp&)
DECLARE SUB EZ_SetHScroll LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL SMin&, BYVAL SMax&, BYVAL SPos&, BYVAL SJmp&)
DECLARE SUB EZ_DefHColor LIB "ezgui50.dll" (BYVAL N&, BYVAL H&, BYVAL R&, BYVAL G&, BYVAL B&)
DECLARE SUB EZ_DefColor LIB "ezgui50.dll" (BYVAL N&, BYVAL R&, BYVAL G&, BYVAL B&)
DECLARE SUB EZ_Color  LIB "ezgui50.dll" (BYVAL FG&, BYVAL BG&)
DECLARE SUB EZ_Sleep LIB "ezgui50.dll" (BYVAL S!)
DECLARE FUNCTION EZ_SendMessageR LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL M&, BYVAL P1&, BYVAL P2&) AS LONG
DECLARE SUB EZ_SendMessage LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL M&, BYVAL P1&, BYVAL P2&)
DECLARE FUNCTION EZ_GetTextLen  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE SUB EZ_AddItems LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL LText$)
DECLARE SUB EZ_SetImage LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IName$)
DECLARE SUB EZ_SwapImage LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IName$, BYVAL IName2$)
DECLARE SUB EZ_Delay LIB "ezgui50.dll" (BYVAL S!)
DECLARE SUB EZ_Clear LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_SelectItem LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&)
DECLARE SUB EZ_ShowC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID1&, OPTIONAL BYVAL ID2&)
DECLARE SUB EZ_HideC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID1&, OPTIONAL BYVAL ID2&)
DECLARE SUB EZ_DChar LIB "ezgui50.dll" (BYVAL C$)
DECLARE FUNCTION EZ_Handle LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE SUB EZ_AddList LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, AList$(), BYVAL P1&, BYVAL P2&)
DECLARE FUNCTION EZ_GetItemText  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&) AS STRING
DECLARE SUB EZ_DeleteItem  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&)
DECLARE FUNCTION EZ_FindNext LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IText$, BYVAL SIndex&) AS LONG
DECLARE FUNCTION EZ_FindNextNC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IText$, BYVAL SIndex&) AS LONG
DECLARE FUNCTION EZ_FindNextLeft LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IText$, BYVAL SIndex&) AS LONG
DECLARE FUNCTION EZ_FindNextLeftNC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IText$, BYVAL SIndex&) AS LONG
DECLARE FUNCTION EZ_FindNextAny LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IText$, BYVAL SIndex&) AS LONG
DECLARE FUNCTION EZ_FindNextAnyNC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IText$, BYVAL SIndex&) AS LONG
DECLARE FUNCTION EZ_FindNextSel LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL SIndex&) AS LONG
DECLARE FUNCTION EZ_FindLast LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE SUB EZ_SetSelect LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&, BYVAL SFlag&)
DECLARE SUB EZ_ShowPage  LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_SetEditLen LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL L&)
DECLARE SUB EZ_SetFocus LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_SetNextTab LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_SetPrevTab LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE FUNCTION EZ_DefMainMenu LIB "ezgui50.dll" (BYVAL ID&, BYVAL MText$, BYVAL CProp$) AS LONG
DECLARE SUB EZ_AddMenuItem LIB "ezgui50.dll" (BYVAL hMenu&, BYVAL ID&, BYVAL ID2&, BYVAL MText$, BYVAL CProp$)
DECLARE SUB EZ_UpdateMenu LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE FUNCTION EZ_DefSubMenu LIB "ezgui50.dll" (BYVAL ID&, BYVAL MText$, BYVAL CProp$) AS LONG
DECLARE SUB EZ_SetSubMenu LIB "ezgui50.dll" (BYVAL hMenu&, BYVAL ID&, BYVAL hSubMenu&)
DECLARE SUB EZ_SetMenuItem LIB "ezgui50.dll" (BYVAL hMenu&, BYVAL ID&, BYVAL MText$, BYVAL CProp$)
DECLARE SUB EZ_DelMenuItem LIB "ezgui50.dll" (BYVAL hMenu&, BYVAL ID&)
DECLARE SUB EZ_DelMenu  LIB "ezgui50.dll" (BYVAL hMenu&)
DECLARE FUNCTION EZ_MsgBox  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL MText$, BYVAL MTitle$, BYVAL CProp$) AS LONG
DECLARE SUB EZ_SubClass  LIB "ezgui50.dll" (BYVAL V&)
DECLARE SUB EZ_ToolBar LIB "ezgui50.dll" (BYVAL ID&, BYVAL BName$, BYVAL BInfo$, BYVAL CProp$)
DECLARE SUB EZ_UnloadControl  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_SubClassMode LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_SetGrid  LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&)
DECLARE SUB EZ_SetClipboard LIB "ezgui50.dll" (BYVAL D$)
DECLARE FUNCTION EZ_GetClipboard LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_DefFont  LIB "ezgui50.dll" (BYVAL N&, BYVAL TFace$, BYVAL APSize!, BYVAL FProp$)
DECLARE SUB EZ_SetFont  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&)
DECLARE SUB EZ_UseFont  LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_ResizeC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!)
DECLARE SUB EZ_StartTimer LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL TM!)
DECLARE SUB EZ_StopTimer LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_FreeColor  LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_FreeFont  LIB "ezgui50.dll" (BYVAL N&)
DECLARE FUNCTION EZ_OpenFile  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Title$, BYVAL InitDir$, BYVAL Filter$, BYVAL DProp$) AS STRING
DECLARE FUNCTION EZ_SaveFile  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Title$, BYVAL InitDir$, BYVAL SFile$, BYVAL Filter$, BYVAL DExt$, BYVAL DProp$) AS STRING
DECLARE FUNCTION EZ_ChooseColor LIB "ezgui50.dll" (BYVAL FormName$, MyColor&, BYVAL CProp$) AS LONG
DECLARE SUB EZ_DefColorL LIB "ezgui50.dll" (BYVAL N&, BYVAL C&)
DECLARE FUNCTION EZ_ChooseFont LIB "ezgui50.dll" (BYVAL FormName$, MyColor&, BYVAL DProp$) AS LONG
DECLARE SUB EZ_DefSFont LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_DefAccel LIB "ezgui50.dll" (BYVAL FormName$, BYVAL AccelR$)
DECLARE SUB EZ_GetSizeC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, C!, R!, W!, H!)
DECLARE FUNCTION EZ_ControlEX LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CName$, BYVAL Caption$, BYVAL CStyle&, BYVAL CEXStyle&) AS LONG
DECLARE SUB EZ_SetToolTip  LIB "ezgui50.dll" (BYVAL TT$)
DECLARE SUB EZ_SetZorder LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDList$)
DECLARE SUB EZ_GetSFont LIB "ezgui50.dll" (TFace$, PSize&, FProp$)
DECLARE SUB EZ_GetSize LIB "ezgui50.dll" (BYVAL FormName$, W!, H!, BYVAL SMode&)

DECLARE SUB EZ_SetPBar LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL SMin&, BYVAL SMax&, BYVAL SPos&)
DECLARE SUB EZ_SetDepth  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL D$)

DECLARE SUB EZ_Enable LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_Disable LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_EnableC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_DisableC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_EnableTB LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL ID2&)
DECLARE SUB EZ_DisableTB LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL ID2&)
DECLARE SUB EZ_SetCheckTB LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL ID2&, BYVAL CV&)
DECLARE SUB EZ_ShowTB LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL ID2&)
DECLARE SUB EZ_HideTB LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL ID2&)
DECLARE SUB EZ_ShowPopups LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_HidePopups LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_ResizeForm  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL MFlag&)
DECLARE SUB EZ_DragForm LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_SetFormIcon LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IName$)
DECLARE SUB EZ_SetLayer LIB "ezgui50.dll" (BYVAL Layer&)
DECLARE SUB EZ_DisplayLayer LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Layer&, BYVAL Mode&)
DECLARE FUNCTION EZ_CopyFile LIB "ezgui50.dll" (BYVAL Source$, BYVAL Dest$) AS LONG
DECLARE FUNCTION EZ_GetAppPathName LIB "ezgui50.dll" () AS STRING
DECLARE FUNCTION EZ_GetPathText LIB "ezgui50.dll" (BYVAL P$) AS STRING
DECLARE FUNCTION EZ_GetFileText LIB "ezgui50.dll" (BYVAL P$) AS STRING
DECLARE SUB EZ_SetTextMode LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE SUB EZ_MinimizeForm LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_MaximizeForm LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE FUNCTION EZ_ImageHandle LIB "ezgui50.dll" (BYVAL IName$) AS LONG
DECLARE FUNCTION EZ_IconHandle LIB "ezgui50.dll" (BYVAL IName$) AS LONG
DECLARE FUNCTION EZ_BrushHandle LIB "ezgui50.dll" (BYVAL N&) AS LONG
DECLARE FUNCTION EZ_FontHandle LIB "ezgui50.dll" (BYVAL N&) AS LONG
DECLARE SUB EZ_RedrawForm LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_DoEvents LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_PopupMenu LIB "ezgui50.dll" (BYVAL hMenu&, BYVAL FormName$, BYVAL X!, BYVAL Y!, BYVAL MProp$)
DECLARE FUNCTION EZ_CharX LIB "ezgui50.dll" (BYVAL CV&, BYVAL OFlag&) AS SINGLE
DECLARE FUNCTION EZ_CharY LIB "ezgui50.dll" (BYVAL CV&, BYVAL OFlag&) AS SINGLE
DECLARE SUB EZ_HookDialogProc LIB "ezgui50.dll" (CP AS DWORD)
DECLARE SUB EZ_SetFGrid LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_AddToolTip LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE FUNCTION EZ_DProc LIB "ezgui50.dll" ()AS DWORD
DECLARE SUB EZ_HookMsgLoopProc LIB "ezgui50.dll" (CP AS DWORD)
DECLARE SUB EZ_MoveControls LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDList$, BYVAL X&, BYVAL Y&)
DECLARE FUNCTION EZ_GetDropList LIB "ezgui50.dll" ()AS STRING
DECLARE SUB EZ_SetDropFiles LIB "ezgui50.dll" (BYVAL FormName$, BYVAL DFlag&)

DECLARE FUNCTION EZ_SaveRegString LIB "ezgui50.dll" (BYVAL MKey$, BYVAL SKey$, BYVAL KClass$, BYVAL VName$, BYVAL VText$) AS LONG
DECLARE FUNCTION EZ_SaveRegDWord LIB "ezgui50.dll" (BYVAL MKey$, BYVAL SKey$, BYVAL KClass$, BYVAL VName$, BYVAL VNum AS DWORD) AS LONG
DECLARE FUNCTION EZ_ReadReg LIB "ezgui50.dll" (BYVAL MKey$, BYVAL SKey$, BYVAL VName$, VText$, VNum AS DWORD) AS LONG
DECLARE FUNCTION EZ_RegExist LIB "ezgui50.dll" (BYVAL MKey$, BYVAL SKey$) AS LONG

DECLARE FUNCTION EZ_RegDelete LIB "ezgui50.dll" (BYVAL MKey$, BYVAL SKey$) AS LONG

DECLARE SUB EZ_DPrint LIB "ezgui50.dll" (BYVAL D$)
DECLARE SUB EZ_DebugForm LIB "ezgui50.dll" (BYVAL FormName$)

DECLARE SUB EZ_Reg LIB "ezgui50.dll" (BYVAL ID&, BYVAL RNum&)

DECLARE FUNCTION EZ_WinHelp LIB "ezgui50.dll" (BYVAL FormName$, BYVAL HelpName$, BYVAL KeyName$, BYVAL HProp$) AS LONG

DECLARE FUNCTION EZ_AnsiToUnicode LIB "ezgui50.dll" (BYVAL Text$, BYVAL NFlag&) AS STRING
DECLARE FUNCTION EZ_UnicodeToAnsi LIB "ezgui50.dll" (BYVAL Text$, BYVAL NFlag&) AS STRING
DECLARE FUNCTION EZ_ScaleToCharSize LIB "ezgui50.dll" (BYVAL SV!, BYVAL SMode$) AS SINGLE

DECLARE FUNCTION EZ_GetBestColorMatch LIB "ezgui50.dll" (BYVAL C&, BYVAL N1&, BYVAL N2&) AS LONG

DECLARE SUB EZ_GetPos LIB "ezgui50.dll" (BYVAL FormName$, C!, R!, BYVAL SMode&)


DECLARE SUB EZ_GetCharSize LIB "ezgui50.dll" (BYVAL FontNum&, W&, H&, BYVAL Mode&)
DECLARE SUB EZ_GetTextSize LIB "ezgui50.dll" (BYVAL FontNum&, BYVAL Text$, W!, H!, BYVAL Mode&)
DECLARE SUB EZ_SetCharSize LIB "ezgui50.dll" (BYVAL FontNum&, BYVAL Mode&)

DECLARE SUB EZ_SetGridCharSize LIB "ezgui50.dll" (BYVAL FontNum&, BYVAL Mode&)
DECLARE SUB EZ_SetGridPosByChar LIB "ezgui50.dll" (BYVAL Mode&)

DECLARE SUB EZ_SetCursor LIB "ezgui50.dll" (BYVAL Mode$, BYVAL CurNum&)

DECLARE FUNCTION EZ_SetCapture LIB "ezgui50.dll" (BYVAL FormName$) AS LONG

DECLARE SUB EZ_SnapControl LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)

DECLARE SUB EZ_AllowNotifyEvents LIB "ezgui50.dll" (BYVAL NFlag&)
DECLARE SUB EZ_AllowCommandEvents LIB "ezgui50.dll" (BYVAL NFlag&)

DECLARE SUB EZ_RichText1 LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_SetRichText LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL CText$, BYVAL RTF_Flag&, BYVAL Sel_Flag&)
DECLARE FUNCTION EZ_GetRichText LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL RTF_Flag&, BYVAL Sel_Flag&) AS STRING
DECLARE FUNCTION EZ_GetRichTextLen LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL RTF_Flag&, BYVAL Sel_Flag&) AS LONG
DECLARE SUB EZ_SetRichTextLen LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL L&)

DECLARE SUB EZ_HandleCtrl LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_SetHCtrlColor LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL ColorNum&)
DECLARE SUB EZ_SetHCtrlBuddy LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL IDBuddy&, BYVAL AFlag&)

DECLARE FUNCTION EZ_X LIB "ezgui50.dll" (BYVAL CX!) AS LONG
DECLARE FUNCTION EZ_Y LIB "ezgui50.dll" (BYVAL CY!) AS LONG
DECLARE SUB EZ_SetFormHandle LIB "ezgui50.dll" (BYVAL FormName$, BYVAL hWnd AS LONG)

DECLARE SUB EZ_SetDragRectAttributes LIB "ezgui50.dll" (BYVAL PenWidth&, BYVAL PenColor&, BYVAL RectStyle&)

DECLARE SUB EZ_AddLVColumn LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL CText$, BYVAL CIndex&)
DECLARE SUB EZ_SetLVColumn LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL CText$, BYVAL CIndex&)
DECLARE SUB EZ_ListView  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_AddLVItem LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL IText$, BYVAL IPictNum&, BYVAL LVIndex&, BYVAL LVItem&, BYVAL LVProp$)
DECLARE SUB EZ_SetLVItem LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL IText$, BYVAL IPictNum&, BYVAL LVIndex&, BYVAL LVItem&, BYVAL LVProp$)

DECLARE SUB EZ_LoadCursor LIB "ezgui50.dll" (BYVAL CName$, BYVAL CurNum&)
DECLARE SUB EZ_AppendStyle LIB "ezgui50.dll" (BYVAL WStyle&)
DECLARE SUB EZ_SetTBar LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL SMin&, BYVAL SMax&, BYVAL SPos&)

DECLARE SUB EZ_SetGridDisplay LIB "ezgui50.dll" (BYVAL FormName$, BYVAL GridVal&)

DECLARE FUNCTION EZ_Row LIB "ezgui50.dll" (BYVAL CVal&) AS LONG
DECLARE FUNCTION EZ_Col LIB "ezgui50.dll" (BYVAL CVal&) AS LONG

DECLARE SUB EZ_SetAutoRedrawState LIB "ezgui50.dll" (BYVAL ARState&)
DECLARE SUB EZ_SetReDrawState LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL FDState&)
DECLARE SUB EZ_RedrawControl LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)
DECLARE SUB EZ_LoadPatternLib LIB "ezgui50.dll" (BYVAL PFileName$, BYVAL IProp$)
DECLARE SUB EZ_LoadImageLib LIB "ezgui50.dll" (BYVAL StubFileName$)
DECLARE SUB EZ_SetColor LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL FG&, BYVAL BG&)

DECLARE SUB EZ_GetTurtleXY LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, X&, Y&, BYVAL XView&, BYVAL YView&)
DECLARE SUB EZ_AllowKeyEvents LIB "ezgui50.dll" (BYVAL KFlag&)
DECLARE FUNCTION EZ_GetKeyState LIB "ezgui50.dll" (BYVAL VKey&, BYVAL Async&) AS LONG

DECLARE SUB EZ_SetGridColor LIB "ezgui50.dll" (BYVAL ColNum&, BYVAL ColMode&)

DECLARE SUB EZ_UseDialogProc  LIB "ezgui50.dll" (CP AS DWORD)

' --------------------------------------------------------------


    %EZ_PRINTALL        =    1
    %EZ_PRINTPAGES      =    2
    %EZ_PRINTSELECT     =    3
    %EZ_RETURNDEFAULT   =    0

    %EZ_PIXELS          =    0
    %EZ_LOINCH          =    1
    %EZ_HIINCH          =    2
    %EZ_LOMM            =    3
    %EZ_HIMM            =    4
    %EZ_TWIPS           =    5

    TYPE EZPRINTER
        hDC AS LONG
        FromPage AS INTEGER
        ToPage AS INTEGER
        MinPage AS INTEGER
        MaxPage AS INTEGER
        COPIES AS INTEGER
        PrintWhat AS LONG       ' 1=All, 2=Pages, 3=Selection , 0=Just Return Default Printer DC
        AllowPages AS LONG
        AllowSelection AS LONG
        CollateFlag AS LONG
        PUnits AS LONG          ' 0 = Pixels, 1 - .01 inch, 2 - .001 inch, 3 - .1 mm , 4 - .01 mm
        PWidth AS LONG
        PHeight AS LONG
        AWidth AS LONG
        AHeight AS LONG
        DPIx AS LONG
        DPIy AS LONG
        PrnName AS ASCIIZ*256
        PrnNameSetup AS LONG        ' 0 = Use Defaults, 1 = Display Setup Dlg, 2 =  Customize
        ' following members only good for PrnNameSetup = 2 and PrnName defined
        ' only items not zero get set
        PrnOrientation AS LONG      ' 1 = Portrait, 2 = LandScape
        PrnPaperSize AS LONG        ' 1 = Letter, 5 = Legal or any %DMPAPER_ API constants
        PrnPaperWidth AS LONG       ' custom size if not zero
        PrnPaperLength AS LONG      ' custom size if not zero
        PrnBin AS LONG              ' Bin ID - any %DMBIN_ API constants
        PrnQuality AS LONG          ' 1 = Draft, 2 = Low, 3 = Medium, 4 = High
        PrnColor AS LONG            ' 1 = Monochrome, 2 = Color
        PrnVerifyName AS LONG       ' verify printer name is valid
    END TYPE

    %EZ_CPError     =   -9999       ' EZ_ChoosePrinter Error code
    %EZ_PError  = -1
    %EZ_PAbort  = -2
    %EZ_PCancel = -3

' --------------------------------------------------------------
DECLARE FUNCTION EZ_ChoosePrinter LIB "ezgui50.dll" (BYVAL FormName$, EZP AS EZPRINTER) AS LONG
' --------------------------------------------------------------
DECLARE SUB EZ_StartDoc LIB "ezgui50.dll" (BYVAL  DocName$)
DECLARE SUB EZ_StartPage LIB "ezgui50.dll" ()
DECLARE SUB EZ_EndPage LIB "ezgui50.dll" ()
DECLARE SUB EZ_EndDoc LIB "ezgui50.dll" ()
DECLARE SUB EZ_LPrint  LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL MyText$)
' --------------------------------------------------------------
    TYPE EZPAGE
        UseMetric AS LONG
        UseDefaultMargins AS LONG
        DisableMargins AS LONG
        LeftMargin AS SINGLE
        TopMargin AS SINGLE
        RightMargin AS SINGLE
        BottomMargin AS SINGLE
    END TYPE
' --------------------------------------------------------------
DECLARE FUNCTION EZ_PageSetup  LIB "ezgui50.dll" (BYVAL FormName$, EZP AS EZPAGE) AS LONG
' --------------------------------------------------------------

%EZ_CUSTOBJ     = -9999
%EZ_FLOODFILL   =   -3
%EZ_FLOODFILLB  =   -2
%EZ_XLINE       =   5   ' changed from 3.0 (was -1)

%EZ_LINE        =   0
%EZ_RECT        =   1
%EZ_RRECT       =   2
%EZ_ELLIPSE     =   3
%EZ_FILL        =   4

%EZ_EDGE_B      =   10
%EZ_EDGE_E      =   11
%EZ_EDGE_R      =   12
%EZ_EDGE_S      =   13

%EZ_BTNDEF      =   17
%EZ_BTNHOT      =   18   ' new to 5.0
%EZ_BTNDIS      =   19   ' new to 5.0
%EZ_BTNUP       =   20
%EZ_BTNDN       =   21
%EZ_CHECK_0     =   22
%EZ_CHECK_1     =   23
%EZ_RADIO_0     =   24
%EZ_RADIO_1     =   25
%EZ_BULLET      =   26
%EZ_MCHECK      =   27
%EZ_MARROW      =   28
%EZ_DROPDN      =   29
%EZ_DROPUP      =   30
%EZ_DROPLF      =   31
%EZ_DROPRT      =   32
' NEW in EZGUI 5.0
%EZ_XBTNUP        =   33
%EZ_XBTNDN        =   34
%EZ_HBTNUP        =   35
%EZ_HBTNDN        =   36
%EZ_MXBTNUP       =   37
%EZ_MXBTNDN       =   38
%EZ_MNBTNUP       =   39
%EZ_MNBTNDN       =   40
%EZ_RBTNUP        =   41
%EZ_RBTNDN        =   42
%EZ_CAPA          =   43
%EZ_CAPI          =   44
%EZ_CAPAR         =   45
%EZ_CAPIR         =   46
%EZ_TABBG         =   47
%EZ_TABBGF        =   48
%EZ_REBARBG       =   49

%EZ_POLY        =   50
%EZ_POLYBEZ     =   51
%EZ_DOTS        =   256

DECLARE SUB EZ_LDraw LIB "ezgui50.dll" (BYVAL DObj&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL PenWidth&, BYVAL FillFlag&)
DECLARE SUB EZ_AbortDoc LIB "ezgui50.dll" ()
DECLARE SUB EZ_HookComDialogProc LIB "ezgui50.dll" (CP AS DWORD)

DECLARE SUB EZ_ScrollTo LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL PosFlag&, BYVAL OffSet&)

DECLARE SUB EZ_DefLayerGroup  LIB "ezgui50.dll" (BYVAL LayerMin&, BYVAL LayerMax&, BYVAL EFlag&)

DECLARE FUNCTION EZ_CurrentForm LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_SetOnLayer LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL L&)

DECLARE SUB EZ_StatusBar LIB "ezgui50.dll" (BYVAL ID&, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_SetSBParts LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL Parts&, BYVAL PPerc$)
DECLARE SUB EZ_SetSBText LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL Part&, BYVAL CText$, BYVAL CProp$)

DECLARE SUB EZ_LDrawPicture  LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL Pict$, BYVAL PProp$)

DECLARE SUB EZ_LoadMaskEditLib  LIB "ezgui50.dll" (BYVAL F$, BYVAL CName$)

' --------------------------------------------------------------

DECLARE SUB EZ_Button  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_CheckBox  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_Radio  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_VScroll  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_HScroll  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_ListBox  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_ComboBox  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_Frame  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_Text  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_Label  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_Picture  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL BName$, BYVAL CProp$)
DECLARE SUB EZ_Icon  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL IName$, BYVAL CProp$)
DECLARE SUB EZ_PButton  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL BName$, BYVAL CProp$)
DECLARE SUB EZ_IButton  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL IName$, BYVAL CProp$)

DECLARE SUB EZ_TabControl  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_ProgressBar  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)

DECLARE SUB EZ_UpDown  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_SetUpDown LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL SMin&, BYVAL SMax&, BYVAL SPos&)
DECLARE SUB EZ_TurtlePicture LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)

DECLARE SUB EZ_VTrackBar  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_HTrackBar  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE FUNCTION EZ_ColorVal  LIB "ezgui50.dll" (BYVAL N&, BYVAL Mode&) AS LONG

' -------------------------------------------------------------------------------------

' New commands in EZGUI 2.1
DECLARE SUB EZ_MDIClient LIB "ezgui50.dll" ()
DECLARE SUB EZ_ResizeMDI LIB "ezgui50.dll" (BYVAL FormName$, BYVAL C!, BYVAL R!, BYVAL W!,  BYVAL H!, BYVAL Mode&)
DECLARE FUNCTION EZ_MDIClientHandle LIB "ezgui50.dll" (BYVAL FormName$) AS LONG
DECLARE SUB EZ_ArrangeMDI LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Mode$)
DECLARE SUB EZ_AllowMouseMoveEvents LIB "ezgui50.dll" (BYVAL KFlag&)
DECLARE SUB EZ_TreeView  LIB "ezgui50.dll"  (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE FUNCTION EZ_ToolTipHandle LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IsTBarFlag&) AS LONG
DECLARE FUNCTION EZ_StatusBarHandle LIB "ezgui50.dll" (BYVAL FormName$) AS LONG
DECLARE FUNCTION EZ_AccelHandle LIB "ezgui50.dll" (BYVAL FormName$) AS LONG
DECLARE SUB EZ_Canvas LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)

%EZCV_GETLASTXPOS               =   %EZ_USER+100
%EZCV_GETLASTYPOS               =   %EZ_USER+101
%EZCV_GETMEMDC                  =   %EZ_USER+102
%EZCV_SETVIEW                   =   %EZ_USER+103

DECLARE SUB EZ_GetCanvasXY LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, X&, Y&, BYVAL XView&, BYVAL YView&)
DECLARE SUB EZ_StartDraw LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, BYVAL W&, BYVAL H&, BYVAL CProp$)
DECLARE SUB EZ_EndDraw LIB "ezgui50.dll" ()
DECLARE SUB EZ_CDraw  LIB "ezgui50.dll" (BYVAL DObj&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL PenWidth&, BYVAL FillFlag&)
DECLARE SUB EZ_CDrawPicture LIB "ezgui50.dll"  (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL Pict$, BYVAL PProp$)
DECLARE SUB EZ_CPrint LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL MyText$)
DECLARE SUB EZ_LDrawGradient LIB "ezgui50.dll" (BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL Mode&)
DECLARE SUB EZ_CDrawGradient LIB "ezgui50.dll" (BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL Mode&)
DECLARE SUB EZ_StartCList LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ClassName$)
DECLARE SUB EZ_EndCList LIB "ezgui50.dll" ()
DECLARE FUNCTION EZ_GetCListCount LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_GetCListID LIB "ezgui50.dll" (BYVAL N&) AS LONG
DECLARE FUNCTION EZ_GetCListHandle LIB "ezgui50.dll" (BYVAL N&) AS LONG
DECLARE FUNCTION EZ_GetCListClass LIB "ezgui50.dll" (BYVAL N&, BYVAL Mode&) AS STRING
DECLARE SUB EZ_GetCanvasSize LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, W&, H&)

DECLARE FUNCTION EZ_ActiveCanvasDC LIB "ezgui50.dll" () AS LONG
DECLARE SUB EZ_DCPrint LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL X&, BYVAL Y&, BYVAL MyText$)
DECLARE SUB EZ_DCDrawPicture LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hBmp&)
DECLARE SUB EZ_DCDraw  LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL DObj&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL PenWidth&, BYVAL FillFlag&)
DECLARE SUB EZ_DCDrawGradient LIB "ezgui50.dll" (BYVAL CurrentDC AS LONG, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL N1&)
DECLARE SUB EZ_AllowCursorEvents LIB "ezgui50.dll" (BYVAL CFlag&)
DECLARE SUB EZ_DefMDIDefaultID LIB "ezgui50.dll" (BYVAL ID&)
DECLARE SUB EZ_CScroll LIB "ezgui50.dll" (BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL HScrollU&, BYVAL VScrollU&)
DECLARE SUB EZ_DCScroll LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL HScrollU&, BYVAL VScrollU&)
DECLARE SUB EZ_CalcPoint  LIB "ezgui50.dll" (BYVAL AX&,BYVAL AY&,BYVAL AL&,BYVAL ADG&,RX&,RY&)
DECLARE FUNCTION EZ_AddTVItem LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL hParent&, BYVAL hAfter&, BYVAL IText$, BYVAL NSImage1&, BYVAL SImage&, BYVAL TVProp$) AS LONG
DECLARE SUB EZ_SetTVItem LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL hItem&, BYVAL IText$, BYVAL NSImage1&, BYVAL SImage&, BYVAL TVProp$)
DECLARE SUB EZ_GetBitmapSize LIB "ezgui50.dll" (BYVAL hBmp&, W&, H&)
DECLARE SUB EZ_GetPictureSize LIB "ezgui50.dll" (BYVAL PName$, W&, H&)

DECLARE FUNCTION EZ_StartDrawByPtr LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, BYVAL Buffer2Flag&) AS LONG
DECLARE SUB EZ_EndDrawByPtr LIB "ezgui50.dll" ()
DECLARE SUB EZ_DIBPut16 LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL ColorV%)
DECLARE FUNCTION EZ_DIBGet16 LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&) AS INTEGER
DECLARE SUB EZ_DIBPut24 LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL ColorV&)
DECLARE FUNCTION EZ_DIBGet24 LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&) AS LONG
DECLARE SUB EZ_DIBPut32 LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL ColorV&)
DECLARE FUNCTION EZ_DIBGet32 LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&) AS LONG
DECLARE FUNCTION EZ_DIBOffsetY LIB "ezgui50.dll" (BYVAL Y&) AS LONG
DECLARE FUNCTION EZ_DIBPtrY LIB "ezgui50.dll" (BYVAL Y&) AS LONG

DECLARE SUB EZ_SetTrayIcon LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IName$, BYVAL TText$)
DECLARE SUB EZ_CSelectBuffer LIB "ezgui50.dll" (BYVAL BufferN&)
DECLARE SUB EZ_CCopyBuffer LIB "ezgui50.dll" (BYVAL SrcBuf&, BYVAL DestBuf&, BYVAL RasterMode&)
DECLARE SUB EZ_ShapeFormToPicture LIB "ezgui50.dll" (BYVAL FPicture$, BYVAL TColor&)
DECLARE SUB EZ_SetWDragMode LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE FUNCTION EZ_IsForm LIB "ezgui50.dll" (BYVAL FormName$, BYVAL FState$) AS LONG
DECLARE SUB EZ_PlayBeep LIB "ezgui50.dll" (BYVAL Mode$)
DECLARE SUB EZ_SetPrintFormat LIB "ezgui50.dll" (BYVAL Mode&, BYVAL Par1&, BYVAL Par2&, BYVAL Par3&, BYVAL Par4&)
DECLARE SUB EZ_SetWFontSmoothMode LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE SUB EZ_ODButton  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE FUNCTION EZ_StartOwnerDraw  LIB "ezgui50.dll" (BYVAL CVal&, hMyDC&, X2&, Y2&, IsSel&, IsGry&, IsDis&, IsChk&, IsFoc&, IsDef&) AS LONG
DECLARE SUB EZ_EndOwnerDraw  LIB "ezgui50.dll" ()
DECLARE FUNCTION EZ_AppPath LIB "ezgui50.dll" () AS STRING
DECLARE FUNCTION EZ_GetMenuItem  LIB "ezgui50.dll" (BYVAL hMenu&, ID&, MText$, CProp$, hSubMenu&, BYVAL PosFlag&) AS LONG
DECLARE FUNCTION EZ_GetMenuCount LIB "ezgui50.dll" (BYVAL hMenu&) AS LONG
DECLARE FUNCTION EZ_StartOwnerSize LIB "ezgui50.dll" (BYVAL CVal&, W&, H&, Item1&, Item2&) AS LONG
DECLARE SUB EZ_EndOwnerSize LIB "ezgui50.dll" (BYVAL CVal&, BYVAL W&, BYVAL H&)
DECLARE FUNCTION EZ_SendThreadEvent LIB "ezgui50.dll" (BYVAL hDlg&, BYVAL IDNum&, BYVAL CVal&) AS LONG
DECLARE SUB EZ_MCIControl LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_CDrawIcon  LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL IName$, BYVAL DProp$)
DECLARE SUB EZ_DCDrawIcon LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hIcon&, BYVAL DProp$)
DECLARE SUB EZ_DBox LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE FUNCTION EZ_NamePicture LIB "ezgui50.dll" (BYVAL hBmp&) AS STRING
DECLARE FUNCTION EZ_CreatePicture LIB "ezgui50.dll" (BYVAL W&, BYVAL H&) AS STRING
DECLARE FUNCTION EZ_CreateDIBPicture LIB "ezgui50.dll" (BYVAL BPP&, BYVAL W&, BYVAL H&, BYVAL DProp$, PA&) AS STRING
DECLARE FUNCTION EZ_StartPictureDraw LIB "ezgui50.dll" (BYVAL PName$) AS LONG
DECLARE SUB EZ_EndPictureDraw LIB "ezgui50.dll" ()
DECLARE SUB EZ_ODListBox LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_GetODItem LIB "ezgui50.dll" (BYVAL CVal&, X1&, Y1&, Item1&, IsEdit&)
DECLARE FUNCTION EZ_StartEraseBG LIB "ezgui50.dll" (BYVAL CVal&, MyhDC&, X2&, Y2&) AS LONG
DECLARE SUB EZ_EndEraseBG LIB "ezgui50.dll" (Cancel&)
DECLARE SUB EZ_DCDrawTurtle LIB "ezgui50.dll" (BYVAL hDC&, BYVAL tbuffer$, BYVAL X1&, BYVAL Y1&, BYVAL W&, BYVAL H&)
DECLARE SUB EZ_LDrawTurtle LIB "ezgui50.dll" (BYVAL tbuffer$, BYVAL X1&, BYVAL Y1&, BYVAL W&, BYVAL H&)
DECLARE SUB EZ_CDrawTurtle LIB "ezgui50.dll" (BYVAL tbuffer$, BYVAL X1&, BYVAL Y1&, BYVAL W&, BYVAL H&)
DECLARE FUNCTION EZ_GetClass LIB "ezgui50.dll" (BYVAL Form$, BYVAL IDNum&, BYVAL Mode&) AS STRING
DECLARE SUB EZ_Animate LIB "ezgui50.dll"(BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL AFile$, BYVAL CProp$)
DECLARE SUB EZ_SetAnimate LIB "ezgui50.dll"(BYVAL Form$, BYVAL IDNum&, BYVAL Action$)
DECLARE SUB EZ_FillWithSystemColors LIB "ezgui50.dll" (BYVAL N&)
DECLARE FUNCTION EZ_GetPostThreadStr LIB "ezgui50.dll" (BYVAL CVal&) AS STRING
DECLARE FUNCTION EZ_GetPostThreadCount LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_PostThreadEvent LIB "ezgui50.dll" (BYVAL hDlg&, BYVAL IDNum&, BYVAL D$) AS LONG
DECLARE FUNCTION EZ_ConvertMousePos LIB "ezgui50.dll" (BYVAL hWnd1&, BYVAL hWnd2&, BYVAL CVal&) AS LONG
DECLARE SUB EZ_PostMessage LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL M&, BYVAL P1&, BYVAL P2&)
DECLARE SUB EZ_PostEvent LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL CVal&)
DECLARE FUNCTION EZ_FG LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_BG LIB "ezgui50.dll" () AS LONG
DECLARE SUB EZ_SaveColors LIB "ezgui50.dll" (BYVAL N1&, BYVAL N2&)
DECLARE SUB EZ_RestoreColors LIB "ezgui50.dll" ()
DECLARE FUNCTION EZ_GetFormName LIB "ezgui50.dll" (BYVAL hWnd&) AS STRING
DECLARE FUNCTION EZ_GetFormParent LIB "ezgui50.dll" (BYVAL FormName$) AS STRING
DECLARE FUNCTION EZ_GetParentForm LIB "ezgui50.dll" (BYVAL hCtrl&) AS STRING
DECLARE FUNCTION EZ_ActiveMDIChild LIB "ezgui50.dll" () AS STRING
DECLARE FUNCTION EZ_GetTVRoot LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE FUNCTION EZ_GetTVNext LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_GetTVChild LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_GetTVParent LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_GetTVPrevious LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_GetTVFirstV LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE FUNCTION EZ_GetTVNextV LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_GetTVPreviousV LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_GetTVSel LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE SUB EZ_StartTVEdit LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&)
DECLARE SUB EZ_EndTVEdit LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_TVExpand LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&)
DECLARE SUB EZ_TVCollapse LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&)
DECLARE SUB EZ_TVClearChildren LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&)
DECLARE FUNCTION EZ_GetTVCount LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE FUNCTION EZ_GetTVCountV LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE SUB EZ_TVSelect LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&)
DECLARE SUB EZ_TVPosTop LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&)
DECLARE SUB EZ_TVSortChildren LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&)
DECLARE FUNCTION EZ_GetTVItem LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL hTVItem&, Txt$, Pict1&, Pict2&, Prop$) AS LONG
DECLARE SUB EZ_DefImageList LIB "ezgui50.dll" (BYVAL N&, BYVAL XY&, BYVAL MaxI&)
DECLARE SUB EZ_FreeImageList LIB "ezgui50.dll" (BYVAL N&)
DECLARE FUNCTION EZ_AddImage LIB "ezgui50.dll" (BYVAL N&, BYVAL Pict$, BYVAL TColor&) AS LONG
DECLARE SUB EZ_TVUseImageList LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&, BYVAL SFlag&)
DECLARE SUB EZ_LVUseImageList LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&, BYVAL SFlag&)
DECLARE FUNCTION EZ_GetLVItem LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, IText$, IPictNum&, BYVAL LVIndex&, BYVAL LVItem&, LVProp$) AS LONG
%EZ_LVBitCol            =   65536&
DECLARE SUB EZ_SearchLVCol LIB "ezgui50.dll" (BYVAL ColN&)
DECLARE SUB EZ_DelLVColumn LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL CIndex&)
DECLARE SUB EZ_StartLVEdit LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL Item&)
DECLARE SUB EZ_EndLVEdit LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE FUNCTION EZ_GetLVSelCount LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE FUNCTION EZ_GetLVTopV LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE SUB EZ_SetLVMaxCount LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL MaxItems&)
DECLARE SUB EZ_SortLV LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL DFlag&)
DECLARE SUB EZ_TABSetImage LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL TIndex&, BYVAL ImgIndex&)
DECLARE SUB EZ_TABUseImageList LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&)
DECLARE FUNCTION EZ_ImgListHandle LIB "ezgui50.dll" (BYVAL N&) AS LONG
DECLARE SUB EZ_SelTab LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL TIndex&)
DECLARE FUNCTION EZ_GetTabSel LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)  AS LONG
DECLARE FUNCTION EZ_GetTabRows LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
DECLARE SUB EZ_DCTilePicture LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL hBmp&)
DECLARE SUB EZ_CTilePicture LIB "ezgui50.dll" (BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL Pict$)
DECLARE SUB EZ_RichText2 LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_RestoreForm LIB "ezgui50.dll" (BYVAL FormName$)
DECLARE SUB EZ_DateTime LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_SetDateTime LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL MN%, BYVAL DY%, BYVAL YR%, BYVAL HR%, BYVAL Mnt%, BYVAL Sec%)
DECLARE SUB EZ_GetDateTime LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, MN%, DY%, YR%, HR%, Mnt%, Sec%, WDay%, MSec%)
DECLARE SUB EZ_SetDateTimeMinMax  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL MN1%, BYVAL DY1%, BYVAL YR1%, BYVAL HR1%, BYVAL Mnt1%, BYVAL Sec1%,_
                                                                                 BYVAL MN2%, BYVAL DY2%, BYVAL YR2%, BYVAL HR2%, BYVAL Mnt2%, BYVAL Sec2%)
DECLARE SUB EZ_SetLVTransparentBG LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)

DECLARE SUB EZ_DCDrawImage LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL X&, BYVAL Y&, BYVAL ImgListNum&, BYVAL ImgIndex&, BYVAL Mode&)
DECLARE SUB EZ_CDrawImage LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL ImgListNum&, BYVAL ImgIndex&, BYVAL Mode&)
DECLARE SUB EZ_DefCharSizeA  LIB "ezgui50.dll" (BYVAL W&, BYVAL H&)
DECLARE SUB EZ_GetTBPos  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL ButtonID&, BYVAL DForm$, X1!, Y1!, X2!, Y2!)
DECLARE SUB EZ_SetFormSysMenu  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL MItem$, BYVAL EFlag&)
DECLARE FUNCTION EZ_LoadLibrary LIB "ezgui50.dll" (BYVAL DLLName$) AS LONG
DECLARE SUB EZ_LVEnsureVisible LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL Item&)
DECLARE SUB EZ_SetHCtrlSize  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL HSize&, BYVAL PFlag&)
DECLARE SUB EZ_LDrawCanvas LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&)
DECLARE SUB EZ_Shape LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL DotText$, BYVAL CProp$)
DECLARE SUB EZ_ChangeParent LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL NewParentName$)
DECLARE SUB EZ_SetRichFont LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL TFace$, BYVAL APSize!, BYVAL FProp$, BYVAL FColor&, BYVAL FMask$, BYVAL Mode&)
DECLARE SUB EZ_GetRichFont LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, TFace$, APSize!, FProp$, FColor&, BYVAL Mode&)
DECLARE FUNCTION EZ_LPrintRichText LIB "ezgui50.dll" (BYVAL FormName$, BYVAL RichID&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL CharStart&, BYVAL CharEnd&, BYVAL LFlag&) AS LONG
DECLARE SUB EZ_GetRichSel LIB "ezgui50.dll" (BYVAL FormName$, BYVAL RichID&, P1&, P2&)
DECLARE SUB EZ_SetRichSel LIB "ezgui50.dll" (BYVAL FormName$, BYVAL RichID&, BYVAL P1&, BYVAL P2&)
DECLARE SUB EZ_SetFormMinMax LIB "ezgui50.dll" (BYVAL FormName$,BYVAL MinW!, BYVAL MinH!, BYVAL MaxW!, BYVAL MaxH!)
DECLARE SUB EZ_DelayDrawClient LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)
DECLARE SUB EZ_GetMinMax LIB "ezgui50.dll" (BYVAL CVal&, MinW!, MinH!, MaxW!, MaxH!)
DECLARE SUB EZ_SetMinMax LIB "ezgui50.dll" (BYVAL CVal&, BYVAL MinW!, BYVAL MinH!, BYVAL MaxW!, BYVAL MaxH!)
DECLARE SUB EZ_DefAutoStartDoc LIB "ezgui50.dll" (BYVAL D$)
DECLARE SUB EZ_SetSelVal LIB "ezgui50.dll" (BYVAL CVal&, BYVAL SMin&, BYVAL SMax&)
DECLARE SUB EZ_GetSelVal LIB "ezgui50.dll" (BYVAL CVal&, SMin&, SMax&)
DECLARE FUNCTION EZ_MsgBoxEx LIB "ezgui50.dll" (BYVAL FormName$, BYVAL MText$, BYVAL MTitle$, BYVAL B1$, BYVAL B2$, BYVAL B3$, BYVAL Pict$, BYVAL Prop$, BYVAL Font1&, BYVAL Font2&) AS LONG
DECLARE FUNCTION EZ_Font LIB "ezgui50.dll" () AS LONG
DECLARE SUB EZ_Draw3DButton LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL DKColor&, BYVAL TXColor&, BYVAL FontN&)
DECLARE SUB EZ_DrawColorButton LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL BColor&, BYVAL TXColor&, BYVAL FontN&)
DECLARE SUB EZ_CShowRect LIB "ezgui50.dll" (BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&)
DECLARE FUNCTION EZ_GetPrinter LIB "ezgui50.dll" (BYVAL I&) AS STRING
DECLARE FUNCTION EZ_GetFont LIB "ezgui50.dll" (BYVAL I&, BYVAL FaceName$, BYVAL Prop$) AS STRING
DECLARE SUB EZ_SaveState LIB "ezgui50.dll" ()
DECLARE SUB EZ_RestoreState LIB "ezgui50.dll" ()
DECLARE FUNCTION EZ_GetLVColWidth LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL ColIndex&) AS LONG
DECLARE SUB EZ_GetLVClickInfo LIB "ezgui50.dll" (BYVAL CVal&, AxPos&, AyPos&, SubXPos&, SubYPos&, ACol&, I&)
DECLARE SUB EZ_DCPrintVText LIB "ezgui50.dll" (BYVAL hMyDC&, BYVAL T$, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL RFlag&)
DECLARE FUNCTION EZ_GetResourceNames LIB "ezgui50.dll" (BYVAL Src&, BYVAL RType&, BYVAL hMod&) AS STRING
DECLARE SUB EZ_SetTVLong LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&, BYVAL N&)
DECLARE FUNCTION EZ_GetTVLong LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL hTV&) AS LONG
DECLARE SUB EZ_SetRegion LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL RType&, BYVAL MyRgn&)
DECLARE SUB EZ_AssignID LIB "ezgui50.dll" (BYVAL hCtrl&, BYVAL NewIDNum&)
DECLARE SUB EZ_PutOnLayer LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)
DECLARE SUB EZ_DefMaxLayer LIB "ezgui50.dll" (BYVAL MaxL&)
DECLARE FUNCTION EZ_GetLVColOrder LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL Columns&) AS STRING
DECLARE SUB EZ_SetClipboardFormat LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE SUB EZ_SetIconCursor LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL CursorNum&)
DECLARE FUNCTION EZ_GetOS LIB "ezgui50.dll" (BYVAL Mode&) AS LONG
DECLARE SUB EZ_StartCSect LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_EndCSect LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_AppendTBPict LIB "ezgui50.dll" (BYVAL PName$)
DECLARE FUNCTION EZ_AddPictToImgList LIB "ezgui50.dll" (BYVAL N&, BYVAL Pict$, BYVAL TColor&) AS LONG
DECLARE FUNCTION EZ_GetCDrawItem LIB "ezgui50.dll" (BYVAL CVal&, SubItem&) AS LONG
DECLARE SUB EZ_SetCDrawItem LIB "ezgui50.dll" (BYVAL CVal&, BYVAL FontN&, BYVAL FGC&, BYVAL BGC&)

'------------------------------------------------------------------------------
'            New Commands and Constants for EZGUI 4.0
'------------------------------------------------------------------------------

%EZ_SmallBlock              =   4&
%EZ_TinyBlock               =   8&

DECLARE SUB EZ_SetDrawMode LIB "ezgui50.dll" (BYVAL Item&, BYVAL Mode&)
DECLARE SUB EZ_FindTextDlg LIB "ezgui50.dll" (BYVAL ParentForm$, BYVAL FText$, BYVAL RText$, BYVAL DProp$)
DECLARE FUNCTION EZ_GetFindText LIB "ezgui50.dll" () AS STRING
DECLARE FUNCTION EZ_GetReplaceText LIB "ezgui50.dll" () AS STRING
DECLARE FUNCTION EZ_FindDlgVal LIB "ezgui50.dll" (BYVAL CVal&, BYVAL DProp$) AS LONG
DECLARE SUB EZ_SetFindTextError LIB "ezgui50.dll" (BYVAL EMsg$, BYVAL ECaption$)
DECLARE SUB EZ_AddRBForm  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL W!, BYVAL H!, BYVAL RBForm$, BYVAL BText$, BYVAL ImgIndex&, BYVAL HWidth&, BYVAL BGPict$, BYVAL BProp$)
DECLARE SUB EZ_Rebar LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL ImgListN&, BYVAL CProp$)
DECLARE FUNCTION EZ_CallLibFunc LIB "ezgui50.dll" (BYVAL hLib&, BYVAL CData$) AS LONG
DECLARE SUB EZ_DefToolTipProp LIB "ezgui50.dll" (BYVAL FGC&, BYVAL BGC&, BYVAL TProp$)
DECLARE FUNCTION EZ_GetLibFuncAddr LIB "ezgui50.dll" (BYVAL hLib&, BYVAL FName$) AS DWORD
DECLARE SUB EZ_Pager LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_AddPGForm  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL W!, BYVAL H!, BYVAL PGForm$, BYVAL FProp$)
DECLARE FUNCTION EZ_GetAttr  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL Attr$)  AS LONG
DECLARE SUB EZ_SetAttr LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL Attr$, BYVAL V&)
DECLARE SUB EZ_SelectFormHandleEX LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_SetFormHandleEX LIB "ezgui50.dll" (BYVAL FormName$, BYVAL hWnd AS LONG, BYVAL N&)
DECLARE SUB EZ_SetCDrawItemEx LIB "ezgui50.dll" (BYVAL CVal&, BYVAL ExColor&, BYVAL DMode&)
DECLARE SUB EZ_GetCDrawItemState LIB "ezgui50.dll" (BYVAL CVal&, SelFlag&, GrayFlag&, DisFlag&, ChkFlag&, FocFlag&, DefFlag&, HotFlag&, MarkFlag&, IFlag&)
DECLARE FUNCTION EZ_StartWindowDraw LIB "ezgui50.dll" (BYVAL Form$, BYVAL ID&, BYVAL DProp$) AS LONG
DECLARE SUB EZ_EndWindowDraw LIB "ezgui50.dll" ()
DECLARE SUB EZ_DCCopyBlock LIB "ezgui50.dll" (BYVAL hDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hDCDest&, BYVAL DX&, BYVAL DY&)
DECLARE SUB EZ_GetMouseXY LIB "ezgui50.dll" (BYVAL CVal&, X&, Y&)
DECLARE FUNCTION EZ_SetMouseXY LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&) AS LONG
DECLARE SUB EZ_GetAreaPixels LIB "ezgui50.dll" (BYVAL hWnd&, X&, Y&, W&, H&, BYVAL AType$, BYVAL Info1&, BYVAL Info2&)
DECLARE SUB EZ_GetArea LIB "ezgui50.dll" (BYVAL Form$, BYVAL ID&, X!, Y!, W!, H!, BYVAL AType$, BYVAL Info1&, BYVAL Info2&)
DECLARE SUB EZ_HookDialogProcEx LIB "ezgui50.dll" (CP AS DWORD)
DECLARE SUB EZ_DefRichFontEx LIB "ezgui50.dll" (BYVAL BColor&, BYVAL FutureP&)
DECLARE SUB EZ_GetRichFontEx LIB "ezgui50.dll" (BKColor&, FutureP&)
DECLARE SUB EZ_RTFLinkMsg LIB "ezgui50.dll" (BYVAL CVal&, LinkCMsg&, LinkCVal&)
DECLARE FUNCTION EZ_RTFLinkGetText LIB "ezgui50.dll" (BYVAL CVal&) AS STRING
DECLARE SUB EZ_SetRichAutoURL LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL Mode&)
DECLARE SUB EZ_SetLVLong LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&, BYVAL V&)
DECLARE FUNCTION EZ_GetLVLong LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&) AS LONG
DECLARE SUB EZ_PListBox  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_FListBox  LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_FLUseImageList LIB "ezgui50.dll" (BYVAL Formname$, BYVAL ID&, BYVAL N&)
DECLARE SUB EZ_RegisterFileType LIB "ezgui50.dll" (BYVAL FT$, BYVAL I&)
DECLARE SUB EZ_FLSetStyle LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL FStyle$)
DECLARE SUB EZ_Calendar LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE SUB EZ_DefCalendarExColors LIB "ezgui50.dll" (BYVAL TFG&, BYVAL TBG&, BYVAL TT&)
DECLARE SUB EZ_SetDate  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL MN%, BYVAL DY%, BYVAL YR%)
DECLARE SUB EZ_GetDate  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, MN%, DY%, YR%, WD%)
DECLARE SUB EZ_SetDateMinMax LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL MN1%, BYVAL DY1%, BYVAL YR1%, BYVAL MN2%, BYVAL DY2%, BYVAL YR2%)
DECLARE SUB EZ_GetDateMinMax LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, MN1%, DY1%, YR1%, MN2%, DY2%, YR2%)
DECLARE SUB EZ_SetDateRange LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL MN1%, BYVAL DY1%, BYVAL YR1%, BYVAL MN2%, BYVAL DY2%, BYVAL YR2%)
DECLARE SUB EZ_GetDateRange LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, MN1%, DY1%, YR1%, MN2%, DY2%, YR2%)
DECLARE FUNCTION EZ_CX LIB "ezgui50.dll" (BYVAL X&) AS SINGLE
DECLARE FUNCTION EZ_CY LIB "ezgui50.dll" (BYVAL Y&) AS SINGLE
DECLARE SUB EZ_ColorRGB LIB "ezgui50.dll" (BYVAL FGC&, BYVAL BGC&)
DECLARE FUNCTION EZ_DIBCol LIB "ezgui50.dll" (BYVAL DV&) AS LONG
DECLARE SUB EZ_GetPLInfo LIB "ezgui50.dll" (BYVAL T$, T1$, T2$, T3$, PCode$)
DECLARE FUNCTION EZ_DefPLInfo LIB "ezgui50.dll" (BYVAL PName$, BYVAL PVal$, BYVAL PList$, BYVAL PCode$, BYVAL DCFlag&) AS STRING
DECLARE SUB EZ_SetPLProp LIB "ezgui50.dll" (BYVAL Form$, BYVAL ID&, BYVAL PName$, BYVAL PVal$)
DECLARE SUB EZ_GetNotify LIB "ezgui50.dll" (BYVAL CVal&, hCtrl&, ID&, NCode&)
DECLARE SUB EZ_GetSubClass LIB "ezgui50.dll" (BYVAL CVal&, hCtrl&, Msg&, wParam&, lParam&)
DECLARE SUB EZ_UseIFont LIB "ezgui50.dll" (BYVAL TFace$, BYVAL APSize!, BYVAL FProp$)
DECLARE FUNCTION EZ_IFontNum LIB "ezgui50.dll" (BYVAL TFace$, BYVAL APSize!, BYVAL FProp$) AS LONG
DECLARE SUB EZ_SetRichPar LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL BFlag&, BYVAL I!, BYVAL LI!, BYVAL RI!, BYVAL AL$, BYVAL TabList$, BYVAL PMask$)
DECLARE FUNCTION EZ_ODIFont LIB "ezgui50.dll" () AS LONG
DECLARE SUB EZ_FreeCursor LIB "ezgui50.dll" (BYVAL CurNum&)
DECLARE SUB EZ_GetCompareVal LIB "ezgui50.dll" (Item1&, Item2&, Item1V&, Item2V&)
DECLARE SUB EZ_SetUserData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL N&, BYVAL V&)
DECLARE FUNCTION EZ_GetUserData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL N&) AS LONG
DECLARE SUB EZ_SaveMenu LIB "ezgui50.dll" (BYVAL FormName$, BYVAL N&, BYVAL V&)
DECLARE FUNCTION EZ_GetMenu LIB "ezgui50.dll" (BYVAL FormName$, BYVAL N&) AS LONG
DECLARE SUB EZ_AllowLoadingEvent LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE FUNCTION EZ_GetLoadVal LIB "ezgui50.dll" (BYVAL I$) AS SINGLE
DECLARE SUB EZ_SetLoadVal LIB "ezgui50.dll" (BYVAL I$, BYVAL V!)
DECLARE FUNCTION EZ_GetLoadStr LIB "ezgui50.dll" (BYVAL I$) AS STRING
DECLARE SUB EZ_SetLoadStr LIB "ezgui50.dll" (BYVAL I$, BYVAL V$)
DECLARE FUNCTION EZ_WO LIB "ezgui50.dll" (BYVAL WObj$) AS LONG
DECLARE SUB EZ_DefPoly LIB "ezgui50.dll" (BYVAL ShapeInfo$)
DECLARE FUNCTION EZ_IsControl LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL FState$) AS LONG
DECLARE SUB EZ_MoveForm LIB "ezgui50.dll" (BYVAL FormName$, BYVAL C!, BYVAL R!)
DECLARE FUNCTION EZ_GetVKey LIB "ezgui50.dll" (BYVAL K$) AS LONG
DECLARE SUB EZ_SetFGridHOffset LIB "ezgui50.dll" (BYVAL PH&)
DECLARE SUB EZ_TrapESC LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE SUB EZ_CenterForm LIB "ezgui50.dll" (BYVAL PFormName$, BYVAL FormName$, BYVAL DFlag&)
DECLARE FUNCTION EZ_GetLVColCount LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS LONG
DECLARE SUB EZ_MatchClass LIB "ezgui50.dll" (BYVAL NewClass$, BYVAL MatchClass$)
DECLARE FUNCTION EZ_DCPrintRichText LIB "ezgui50.dll" (BYVAL hDC&, BYVAL FormName$, BYVAL RichID&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL CharStart&, BYVAL CharEnd&, BYVAL LFlag&) AS LONG
DECLARE SUB EZ_DefSystemColor LIB "ezgui50.dll" (BYVAL N&, BYVAL SC&)
DECLARE SUB EZ_Draw3DButtonRR LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL DKColor&, BYVAL TXColor&, BYVAL FontN&)
DECLARE SUB EZ_Draw3DButtonE LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL DKColor&, BYVAL TXColor&, BYVAL FontN&)
DECLARE FUNCTION EZ_AverageColor LIB "ezgui50.dll" (BYVAL C1&, BYVAL C2&) AS LONG
DECLARE FUNCTION EZ_CurrentDForm LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_DefCorner LIB "ezgui50.dll" (BYVAL N&)
DECLARE SUB EZ_ChangeDlgButtons LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE SUB EZ_SetCurrentProp LIB "ezgui50.dll" (BYVAL T$)
DECLARE FUNCTION EZ_GetCurrentProp LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_UseGradientAngle LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE FUNCTION EZ_GetDrawMacro LIB "ezgui50.dll" (BYVAL T$) AS LONG
DECLARE SUB EZ_DCDrawMacro LIB "ezgui50.dll" (BYVAL hDC&, BYVAL Obj&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL TC&, BYVAL LC&)
DECLARE FUNCTION EZ_CheckLight LIB "ezgui50.dll" (T$, LColorN&) AS LONG
DECLARE SUB EZ_DCDrawLight LIB "ezgui50.dll" (BYVAL hDC&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL LColorN&)
DECLARE FUNCTION EZ_CheckGradMacro LIB "ezgui50.dll" (T$) AS LONG
DECLARE SUB EZ_DCDrawGradMacro LIB "ezgui50.dll" (BYVAL hDC&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&)
DECLARE SUB EZ_DefImageFolder LIB "ezgui50.dll" (BYVAL F$)
DECLARE SUB EZ_FitFormInScreen LIB "ezgui50.dll" (BYVAL FormName$, BYVAL DFlag&)
DECLARE SUB EZ_MaxByClient LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Offset&, BYVAL DFlag&)
DECLARE SUB EZ_MaxByScreen LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Offset&, BYVAL DFlag&)
DECLARE FUNCTION EZ_GetFocusID LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_GetFocusForm LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_SetSizeMode LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE FUNCTION EZ_ActivePrinterDC LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_ChooseCanvas LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, EZP AS EZPRINTER) AS LONG
DECLARE SUB EZ_ExpandForm  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL XW!, BYVAL XH!)
DECLARE FUNCTION EZ_GetLVItemText  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL LVRow&, BYVAL LVCol&) AS STRING
DECLARE SUB EZ_SetLVItemText LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL LVRow&, BYVAL LVCol&, BYVAL LVText$)
DECLARE SUB EZ_DrawBG LIB "ezgui50.dll" (BYVAL CVal&, Cancel&, BYVAL FGC&, BYVAL BGC&, BYVAL DProp$)
DECLARE SUB EZ_DrawTab LIB "ezgui50.dll" (BYVAL CVal&, BYVAL FGC&, BYVAL BGC&, BYVAL TXC&, BYVAL FntNum&, BYVAL TabText$, BYVAL DFlag&, BYVAL DProp$)
DECLARE SUB EZ_DrawLabel LIB "ezgui50.dll" (BYVAL CVal&, BYVAL FG&, BYVAL BG&, BYVAL T$)
DECLARE FUNCTION EZ_ToggleCheckMacro LIB "ezgui50.dll" (BYVAL IText$) AS STRING
DECLARE FUNCTION EZ_ToggleImageMacro LIB "ezgui50.dll" (BYVAL IText$, BYVAL IMin&, BYVAL IMax&, BYVAL DFlag&) AS STRING
DECLARE SUB EZ_DrawListview  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL MFont&, BYVAL ImgList&, BYVAL MProp$, BYVAL Columns&)
DECLARE SUB EZ_SizeListview  LIB "ezgui50.dll" (BYVAL CVal&, BYVAL MFont&)
DECLARE SUB EZ_DrawListBox   LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL MFont&, BYVAL ImgList&, BYVAL MProp$)
DECLARE SUB EZ_SizeListBox LIB "ezgui50.dll" (BYVAL CVal&, BYVAL MFont&)
DECLARE SUB EZ_DrawComboBox  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CVal&, BYVAL MFont&, BYVAL ImgList&, BYVAL MProp$)
DECLARE SUB EZ_SizeComboBox  LIB "ezgui50.dll" (BYVAL CVal&, BYVAL MFont&)
DECLARE SUB EZ_DrawMenu  LIB "ezgui50.dll" (BYVAL CVal&, BYVAL MFont&, BYVAL MText$, BYVAL ImgList&, BYVAL ImgN&, BYVAL MProp$)
DECLARE SUB EZ_SizeMenu  LIB "ezgui50.dll" (BYVAL CVal&, BYVAL MFont&, BYVAL MText$, BYVAL MProp$)
DECLARE FUNCTION EZ_GetFontName LIB "ezgui50.dll" (BYVAL FontN&) AS STRING
DECLARE SUB EZ_StartDrag LIB "ezgui50.dll" (BYVAL N&, BYVAL I&, BYVAL X&, BYVAL Y&, BYVAL DProp$)
DECLARE FUNCTION EZ_GetSelect LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&, BYVAL N&) AS LONG
DECLARE SUB EZ_LVSetItemFocus LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&, BYVAL SFlag&)
DECLARE SUB EZ_LVSetItemStateImg LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&, BYVAL ImgN&)
DECLARE FUNCTION EZ_LVGetItemFocus LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&) AS LONG
DECLARE FUNCTION EZ_LVGetItemStateImg LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&) AS LONG
DECLARE SUB EZ_TVSetItemFocus LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL hTV&, BYVAL SFlag&)
DECLARE SUB EZ_TVSetItemStateImg LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL hTV&, BYVAL ImgN&)
DECLARE FUNCTION EZ_TVGetItemFocus LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_TVGetItemStateImg LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL hTV&) AS LONG
DECLARE FUNCTION EZ_IsRightDrag LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_IsDragOver LIB "ezgui50.dll" () AS STRING
DECLARE FUNCTION EZ_StartDragDraw LIB "ezgui50.dll" (BYVAL CVal&, MyhDC&, X1&, Y1&, X2&, Y2&, IconNum&) AS LONG
DECLARE SUB EZ_EndDragDraw LIB "ezgui50.dll" ()
DECLARE FUNCTION EZ_GetDragInfo LIB "ezgui50.dll" (X&, Y&, ItemN&) AS LONG
#IF NOT %DEF(%EZDesigner)
    DECLARE SUB EZ_InitSpriteBuffers LIB "ezgui50.dll" (BYVAL MaxSP&, BYVAL W!, BYVAL H!)
    DECLARE SUB EZ_DefSprite LIB "ezgui50.dll" (BYVAL SName$, BYVAL W&, BYVAL H&, BYVAL SFrames&, BYVAL TColor&)
    DECLARE SUB EZ_FreeSprite LIB "ezgui50.dll" (BYVAL SName$)
    DECLARE FUNCTION EZ_StartSpriteDraw LIB "ezgui50.dll" (BYVAL SName$, BYVAL IFrame&, MyhDC&, X1&, Y1&, X2&, Y2&) AS LONG
    DECLARE SUB EZ_EndSpriteDraw LIB "ezgui50.dll" (BYVAL AFlag&)
    DECLARE FUNCTION EZ_GetSpriteXY LIB "ezgui50.dll" (BYVAL SName$, X&, Y&) AS LONG
    DECLARE SUB EZ_AssignSprites LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, BYVAL SName$)
    DECLARE SUB EZ_MoveSprites LIB "ezgui50.dll" (BYVAL SName$, BYVAL X&, BYVAL Y&, BYVAL Mode&)
    DECLARE SUB EZ_ShowSprites LIB "ezgui50.dll" (BYVAL SName$, BYVAL SFlag&)
    DECLARE SUB EZ_SetSpritesFrame LIB "ezgui50.dll" (BYVAL SName$, BYVAL Frm&, BYVAL Mode&, BYVAL UFlag&)
    DECLARE SUB EZ_SetSpritesEffect LIB "ezgui50.dll" (BYVAL SName$, BYVAL EFlag&, BYVAL UFlag&)
    DECLARE SUB EZ_SetSpritesFlip LIB "ezgui50.dll" (BYVAL SName$, BYVAL HorzFlip&, BYVAL VertFlip&, BYVAL UFlag&)
    DECLARE SUB EZ_DrawSprites LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL BufNum&, BYVAL HFlag&)
    DECLARE SUB EZ_StartFrame LIB "ezgui50.dll" ()
    DECLARE SUB EZ_EndFrame LIB "ezgui50.dll" (BYVAL FPS&, BYVAL Mode&)
    DECLARE SUB EZ_DefGameLoop LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL MaxCount&)
#ENDIF
DECLARE SUB EZ_UpdateClient LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE FUNCTION EZ_BrowseFolderDlg LIB "ezgui50.dll" (BYVAL FormName$, BYVAL BText$, BYVAL FPath$, BYVAL BProp$) AS STRING
DECLARE SUB EZ_DoPopupMenu LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CVal&, BYVAL FirstID&, BYVAL MenuD$, BYVAL MProp$)
DECLARE SUB EZ_SetFormAttrEx LIB "ezgui50.dll" (BYVAL FormName$, BYVAL TransPColor&, BYVAL AlphaBl!, BYVAL FProp$)
' changed to return extended float
DECLARE FUNCTION EZ_GetPTime LIB "ezgui50.dll" () AS EXTENDED
#IF NOT %DEF(%EZDesigner)
    DECLARE SUB EZ_DefSpriteByPict LIB "ezgui50.dll" (BYVAL SName$, BYVAL Pict$, BYVAL NFrames&, BYVAL TColor&, BYVAL AFlag&)
    DECLARE SUB EZ_StartThread LIB "ezgui50.dll" (BYVAL FormName$, BYVAL TN&, BYVAL STM&)
    DECLARE SUB EZ_PauseThread LIB "ezgui50.dll" (BYVAL FormName$, BYVAL TN&)
    DECLARE SUB EZ_ResumeThread LIB "ezgui50.dll" (BYVAL FormName$, BYVAL TN&)
    DECLARE SUB EZ_CloseThread LIB "ezgui50.dll" (BYVAL FormName$, BYVAL TN&)
    DECLARE SUB EZ_BCopyBlock LIB "ezgui50.dll" (BYVAL hSBmp&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hDBmp&, BYVAL DX&, BYVAL DY&)
    DECLARE SUB EZ_PCopyBlock LIB "ezgui50.dll" (BYVAL SrcP$, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL DestP$, BYVAL DX&, BYVAL DY&)
    DECLARE SUB EZ_CCopyBlockC LIB "ezgui50.dll" (BYVAL SrcFormName$, BYVAL SrcIDNum&, BYVAL SrcBufN&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL DestFormName$, BYVAL DestIDNum&, BYVAL DestBufN&, BYVAL DX&, BYVAL DY&)
    DECLARE SUB EZ_CCopyBlockP LIB "ezgui50.dll" (BYVAL SrcFormName$, BYVAL SrcIDNum&, BYVAL SrcBufN&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL P$, BYVAL DX&, BYVAL DY&)
    DECLARE SUB EZ_PCopyBlockC LIB "ezgui50.dll" (BYVAL P$, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL DestFormName$, BYVAL DestIDNum&, BYVAL DestBufN&, BYVAL DX&, BYVAL DY&)
#ENDIF
DECLARE FUNCTION EZ_GetFocusHandle LIB "ezgui50.dll" () AS LONG
DECLARE SUB EZ_SetTBButtons LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL BtnID&, BYVAL BInfo$)
DECLARE SUB EZ_HHelp LIB "ezgui50.dll" (BYVAL FormName$, BYVAL HFile$, BYVAL HData$, BYVAL HType$)
DECLARE FUNCTION EZ_GetFormTopLevel LIB "ezgui50.dll" (BYVAL FormName$) AS STRING
DECLARE FUNCTION EZ_StartThreadEx LIB "ezgui50.dll" (BYVAL FormName$, BYVAL TN&, BYVAL STM&, BYVAL CodeAddress AS DWORD) AS LONG
DECLARE SUB EZ_SetThread LIB "ezgui50.dll" (BYVAL FormName$, BYVAL TN&, BYVAL TPriority&)
DECLARE FUNCTION EZ_GetCanvasPict LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, BYVAL BufferNum&, BYVAL NW&, BYVAL NH&) AS STRING
DECLARE SUB EZ_SavePicture LIB "ezgui50.dll" (BYVAL Pict$, BYVAL F$)
DECLARE SUB EZ_SwapSpriteOrder LIB "ezgui50.dll" (BYVAL SName1$, BYVAL SName2$)
DECLARE SUB EZ_SetTBLong LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL BID&, BYVAL V&)
DECLARE FUNCTION EZ_GetTBLong LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL BID&)AS LONG
DECLARE SUB EZ_HookCanvasPaint LIB "ezgui50.dll" (BYVAL MyHook AS DWORD)
#IF NOT %DEF(%EZDesigner)
    DECLARE SUB EZ_SetPageAttr LIB "ezgui50.dll" (EZP AS EZPRINTER)
#ENDIF
DECLARE SUB EZ_SetNextNoClip LIB "ezgui50.dll" ()
DECLARE FUNCTION EZ_IsMsg LIB "ezgui50.dll" (BYVAL Msg&, BYVAL MType$) AS LONG
DECLARE SUB EZ_DefDPI LIB "ezgui50.dll" (BYVAL DPIx&, BYVAL DPIy&)
DECLARE SUB EZ_SetCaptureEx LIB "ezgui50.dll" (BYVAL hWnd&)
DECLARE FUNCTION EZ_GetSpriteWH LIB "ezgui50.dll" (BYVAL SName$, W&, H&) AS LONG
DECLARE FUNCTION EZ_GetSpriteFR LIB "ezgui50.dll" (BYVAL SName$, MaxF&, CurF&) AS LONG
DECLARE FUNCTION EZ_GetSpriteST LIB "ezgui50.dll" (BYVAL SName$, BYVAL Mode$) AS LONG
DECLARE FUNCTION EZ_TestSpriteColl LIB "ezgui50.dll" (BYVAL SName$) AS STRING
DECLARE SUB EZ_GetRichPar LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BFlag&, I!, LI!, RI!, AL$, TabList$)
DECLARE SUB EZ_SetDlgMsgMode LIB "ezgui50.dll" (BYVAL Mode&)
DECLARE FUNCTION EZ_TestSpriteClick LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL CX&, BYVAL CY&) AS STRING
DECLARE FUNCTION EZ_SubClassDefault LIB "ezgui50.dll" (BYVAL CVal&, BYVAL DefFlag&) AS LONG
DECLARE SUB EZ_SetSubClassRVal LIB "ezgui50.dll" (BYVAL CVal&, BYVAL RV&)
DECLARE SUB EZ_UseMCI LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)
DECLARE SUB EZ_SetMCI LIB "ezgui50.dll" (BYVAL CText$)
DECLARE FUNCTION EZ_GetMCI LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_ScrollForm LIB "ezgui50.dll" (BYVAL FormName$, BYVAL XOffset!, BYVAL YOffset!, BYVAL SProp$)
DECLARE SUB EZ_SubClassEx LIB "ezgui50.dll" (BYVAL hCtrl&, BYVAL SCFlag&)
DECLARE FUNCTION EZ_GetFrameInfo LIB "ezgui50.dll" (BYVAL Mode&) AS LONG
DECLARE FUNCTION EZ_EstimateCPUSpeed LIB "ezgui50.dll" () AS LONG
DECLARE SUB EZ_SetCtrlUserData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL V&)
DECLARE FUNCTION EZ_GetCtrlUserData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS LONG

'------------------------------------------------------------------------------
' The following portions of code are "based" on the win32api.inc file
' that comes with the Powerbasic Compiler.  The equate/type names
' are slightly different, while the values/structures are the similiar to API values.
'
' The win32api.file contains the following Copyright notices:
'
' ************************************************************************
'  WIN32API.INC -- Win32 API Declarations for PB/DLL
'  Copyright (C) 1997-99 PowerBASIC, Inc.
'  Some portions Copyright (C) 1994 Microsoft Corporation
'
'  You have a royalty-free right to use, modify, reproduce and distribute
'  this file (and/or any modified version) in any way you find useful,
'  provided that you agree that both PowerBASIC and Microsoft have no
'  warranty, obligation or liability for its contents.  Refer to the
'  PowerBASIC DLL Compiler Reference Guide for further information.
' ************************************************************************
'------------------------------------------------------------------------------

' this line is listed in beginning of this include
' %EZ_USER                    = &H400     ' Same thing as %WM_USER in API header file

' TYPE for %EZ_Notify event

TYPE EZ_NMHDR
  hwndFrom AS LONG
  idfrom AS LONG
  CODE AS LONG
END TYPE

' -------------------------------------------------------------------
'               EZGUI Constants for Common Keys
' -------------------------------------------------------------------
%EZK_LBUTTON                                  = &H01    ' Mouse Button
%EZK_RBUTTON                                  = &H02    ' Mouse Button
%EZK_MBUTTON                                  = &H04    ' Mouse Button
%EZK_BACK                                     = &H08
%EZK_TAB                                      = &H09
%EZK_ENTER                                    = &H0D
%EZK_SHIFT                                    = &H10
%EZK_CTRL                                     = &H11
%EZK_ALT                                      = &H12
%EZK_ESC                                      = &H1B
%EZK_PGUP                                     = &H21
%EZK_PGDN                                     = &H22
%EZK_END                                      = &H23
%EZK_HOME                                     = &H24
%EZK_LEFT                                     = &H25
%EZK_UP                                       = &H26
%EZK_RIGHT                                    = &H27
%EZK_DOWN                                     = &H28
%EZK_INS                                      = &H2D
%EZK_DEL                                      = &H2E
' -------------------------------------------------------------------
%EZK_F1                                       = &H70
%EZK_F2                                       = &H71
#IF NOT %DEF(%EZDesigner)
    %EZK_F3                                       = &H72
    %EZK_F4                                       = &H73
    %EZK_F5                                       = &H74
    %EZK_F6                                       = &H75
    %EZK_F7                                       = &H76
    %EZK_F8                                       = &H77
    %EZK_F9                                       = &H78
    %EZK_F10                                      = &H79
    %EZK_F11                                      = &H7A
    %EZK_F12                                      = &H7B
#ENDIF

' -------------------------------------------------------------------

%EZ_Top         =   1
%EZ_Bottom      =   2
%EZ_Left        =   4
%EZ_Right       =   8
%EZ_Center      =   16
%EZ_VCenter     =   32

%EZ_WordBreak                                = &H10
%EZ_UseTabs                                  = &H40
%EZ_NoPrefix                                 = &H800

%EZTV_LAST               =  0
%EZTV_FIRST              = &HFFFF0001&
%EZTV_SORT               = &HFFFF0003&

' -------------------------------------------------------------------------------------
'  EZGUI 5.0 new SUB/FUNCTION Declares
' -------------------------------------------------------------------------------------

DECLARE SUB EZ_DefCustomControl LIB "ezgui50.dll" (BYVAL N&, BYVAL CName$, BYVAL CType&, BYVAL DProp$, BYVAL CP AS DWORD)
DECLARE SUB EZ_CustControl LIB "ezgui50.dll" (BYVAL N&,BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_StartCC LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ID&)
DECLARE SUB EZ_GetCC LIB "ezgui50.dll" (FormName$, IDNum&)
DECLARE SUB EZ_EndCC LIB "ezgui50.dll" ()
DECLARE SUB EZ_AddComponent LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL CMPName$, BYVAL InitText$, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL Style$)
DECLARE FUNCTION EZ_E LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_DefComponent LIB "ezgui50.dll" (BYVAL CMPName$, BYVAL InitData$, BYVAL DESIGNA AS DWORD, BYVAL EVENTA AS DWORD)
DECLARE SUB  EZ_GetComponentData LIB "ezgui50.dll" (BYVAL N&, CMPName$, InitData$)
DECLARE FUNCTION EZ_LoadComponent LIB "ezgui50.dll" (BYVAL CMPPath$, BYVAL CMPPrefix$) AS LONG
DECLARE SUB EZ_ToolBarStrip LIB "ezgui50.dll" (BYVAL ID&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL BName$, BYVAL BInfo$, BYVAL CProp$)
DECLARE SUB EZ_AutoSizeTBStrip LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL VFlag&)
DECLARE SUB EZ_ShowFormScrollBars LIB "ezgui50.dll" (BYVAL FormName$, BYVAL SProp$)
DECLARE SUB EZ_HideFormScrollBars LIB "ezgui50.dll" (BYVAL FormName$, BYVAL SProp$)
DECLARE FUNCTION EZ_GetCurrentPropName LIB "ezgui50.dll" () AS STRING
DECLARE FUNCTION EZ_GetCurrentPropIndex LIB "ezgui50.dll" () AS LONG


DECLARE SUB EZ_DCDrawCanvas  LIB "ezgui50.dll" (BYVAL hDC&, BYVAL FormName$, BYVAL CanvasID&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&)
DECLARE SUB EZ_DCDrawCanvasSP  LIB "ezgui50.dll" (BYVAL hDC&, BYVAL FormName$, BYVAL CanvasID&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&)
DECLARE SUB EZ_LDrawCanvasSP  LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CanvasID&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&)
%EZ_AltCopy = 1024&
DECLARE FUNCTION EZ_CopyWindow LIB "ezgui50.dll" (BYVAL hWnd&, BYVAL Mode&) AS STRING
DECLARE FUNCTION EZ_CopyForm LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Mode&) AS STRING
DECLARE FUNCTION EZ_CopyControl LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL Mode&) AS STRING
DECLARE SUB EZ_CloneSprite LIB "ezgui50.dll" (BYVAL SName$, BYVAL CName$)
DECLARE FUNCTION EZ_GetFastSPIndex LIB "ezgui50.dll" () AS LONG
DECLARE SUB EZ_MoveSP LIB "ezgui50.dll" (BYVAL I&, BYVAL X&, BYVAL Y&, BYVAL Mode&)
DECLARE SUB EZ_SetSPAttr LIB "ezgui50.dll" (BYVAL I&, BYVAL SFlag&, BYVAL Frm&, BYVAL Mode&, BYVAL HorzFlip&, BYVAL VertFlip&, BYVAL EFlag&, BYVAL UFlag&)
DECLARE SUB EZ_GetAPITextSize LIB "ezgui50.dll" (BYVAL TesthDC&, BYVAL hFont&, BYVAL Text$, W!, H!, BYVAL Mode&)
DECLARE SUB EZ_SetSpriteDefTColor LIB "ezgui50.dll" (BYVAL C&)
DECLARE SUB EZ_CStartEffects LIB "ezgui50.dll" (BYVAL TColor&)
DECLARE SUB EZ_CEndEffects LIB "ezgui50.dll" (BYVAL HorzFlip&, BYVAL VertFlip&, BYVAL EFlag&, BYVAL AFlag&)
DECLARE SUB EZ_SetCustCtrlPData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&, BYVAL V&)
DECLARE FUNCTION EZ_GetCustCtrlPData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&) AS LONG
DECLARE SUB EZ_SetCtrlPData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&, BYVAL V&)
DECLARE FUNCTION EZ_GetCtrlPData LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL I&) AS LONG
DECLARE FUNCTION EZ_CopySL LIB "ezgui50.dll" (BYVAL V!) AS LONG
DECLARE FUNCTION EZ_CopyLS LIB "ezgui50.dll" (BYVAL V&) AS SINGLE
DECLARE SUB EZ_AnimateForm LIB "ezgui50.dll" (BYVAL FormName$, BYVAL AProp$)
DECLARE SUB EZ_AnimateControl LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL AProp$)
DECLARE SUB EZ_DCDrawPictureEx LIB "ezgui50.dll" (BYVAL CurrentDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hBmp&, BYVAL FMode&, BYVAL Param1&)
DECLARE SUB EZ_LDrawPictureEx LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL Pict$, BYVAL PProp$, BYVAL FMode&, BYVAL Param1&)
DECLARE SUB EZ_CDrawPictureEx LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL Pict$, BYVAL PProp$, BYVAL FMode&, BYVAL Param1&)

    '  EZ_DCDrawPictureEx Filter constants
    ' ------------------------------------
    %EZ_DPGray256       =   -1
    %EZ_DPGray256I      =   -2
    %EZ_RedOnly         =   -3
    %EZ_DPBlueOnly      =   -4
    %EZ_DPGreenOnly     =   -5
    %EZ_DPMaskRed       =   -6
    %EZ_DPMaskBlue      =   -7
    %EZ_DPMaskGreen     =   -8
    %EZ_DPInvertColor   =   -9
    %EZ_DPTintN         =   -10
    %EZ_DPTintNI        =   -11
    %EZ_DPTintNA        =   -12
    %EZ_DPTintNAI       =   -13
    %EZ_DPTint          =   -14
    %EZ_DPTintI         =   -15
    %EZ_DPTintA         =   -16
    %EZ_DPTintAI        =   -17
    %EZ_DPMono          =   -18
    %EZ_DPGray4         =   -19
    %EZ_DPGray8         =   -20
    %EZ_DPGray16        =   -21
    %EZ_DPColor256      =   -22

DECLARE SUB EZ_GetBitmapInfo LIB "ezgui50.dll" (BYVAL hBmp&, W&, H&, PixelBits&, DIBPtr&)
DECLARE SUB EZ_GetPictureInfo LIB "ezgui50.dll" (BYVAL PName$, W&, H&, PixelBits&, DIBPtr&)
DECLARE FUNCTION EZ_LoadDIBPicture LIB "ezgui50.dll" (BYVAL BName$) AS STRING
DECLARE SUB EZ_DCBlendPicture LIB "ezgui50.dll" (BYVAL hDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hBmp&, BYVAL AFlag&)
DECLARE SUB EZ_DCBlendBlock LIB "ezgui50.dll" (BYVAL hDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hBmp&, BYVAL SX&, BYVAL SY&, BYVAL SW&, BYVAL SH&, BYVAL AFlag&)
DECLARE SUB EZ_CBlendPicture LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL P$, BYVAL AFlag&)
DECLARE SUB EZ_CBlendBlock LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL P$, BYVAL SX&, BYVAL SY&, BYVAL SW&, BYVAL SH&, BYVAL AFlag&)
DECLARE SUB EZ_DCDrawTPicture LIB "ezgui50.dll" (BYVAL hDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hBmp&, BYVAL TColor&)
DECLARE SUB EZ_DCDrawTBlock LIB "ezgui50.dll" (BYVAL hDC&, BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL hBmp&, BYVAL SX&, BYVAL SY&, BYVAL SW&, BYVAL SH&, BYVAL TColor&)
DECLARE SUB EZ_CDrawTPicture LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL P$, BYVAL TColor&)
DECLARE SUB EZ_CDrawTBlock LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL P$, BYVAL SX&, BYVAL SY&, BYVAL SW&, BYVAL SH&, BYVAL TColor&)
DECLARE FUNCTION EZ_CopyPictToDIB LIB "ezgui50.dll" (BYVAL P$, PA&, BYVAL FMode&, BYVAL Param1&, BYVAL TColor&, BYVAL AColor25&, BYVAL AColor50&, BYVAL AColor75&) AS STRING
DECLARE FUNCTION EZ_GetImageListCount LIB "ezgui50.dll" (BYVAL N&) AS LONG

    TYPE EZGUISTAT
        BmpCT AS LONG
        BmpKB AS LONG
        IconCT AS LONG
        ImagesFree AS LONG
        FontCT AS LONG
        SCursorCT AS LONG
        DCursorCT AS LONG
        ImgListCT AS LONG
        ImgListIconCT AS LONG
        ColorCT AS LONG
        SpriteCT AS LONG
        FormCT AS LONG
        CmpCT AS LONG
        ControlCT AS LONG
        MaxFormCmps AS LONG
        MaxControls AS LONG
        MaxImages AS LONG
        MaxFonts AS LONG
        MaxCursors AS LONG
        MaxColors AS LONG
        MaxImgLists AS LONG
        MaxSprites AS LONG
    END TYPE

DECLARE SUB EZ_GetGUIStats LIB "ezgui50.dll" (G AS EZGUISTAT)

DECLARE FUNCTION EZ_GetFreeFont LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_GetFreeColor LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_GetFreeSCursor LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_GetFreeDCursor LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_GetFreeImgList LIB "ezgui50.dll" () AS LONG

DECLARE FUNCTION EZ_GetResourceData LIB "ezgui50.dll" (BYVAL RName$, BYVAL RType&, BYVAL FFlag&) AS STRING


DECLARE FUNCTION EZ_GetThemeStatus LIB "ezgui50.dll" (BYVAL TMode&) AS LONG
DECLARE SUB EZ_SetThemeOff LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)

DECLARE FUNCTION EZ_VDisplayCount LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_VDisplayName LIB "ezgui50.dll" (BYVAL DNum&) AS STRING
DECLARE SUB EZ_GetVDisplayArea LIB "ezgui50.dll" (BYVAL DNum&, C!, R!, W!, H!, BYVAL DMode&)

DECLARE FUNCTION EZ_GetFormVDisplay LIB "ezgui50.dll" (BYVAL FormName$) AS LONG
DECLARE FUNCTION EZ_GetCtrlVDisplay LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&) AS LONG


DECLARE SUB EZ_DefRotateBuffer LIB "ezgui50.dll" (BYVAL W&, BYVAL H&)
DECLARE SUB EZ_DCRotateScalePicture LIB "ezgui50.dll" (BYVAL hDC&, BYVAL hBmp&, BYVAL X&, BYVAL Y&, BYVAL RDeg!, BYVAL XScale&, BYVAL YScale&, BYVAL TColor&,BYVAL RProp$)
DECLARE SUB EZ_CRotateScalePicture LIB "ezgui50.dll" (BYVAL P$, BYVAL X&, BYVAL Y&, BYVAL RDeg!, BYVAL XScale&, BYVAL YScale&, BYVAL TColor&,BYVAL RProp$)
DECLARE FUNCTION EZ_StartCSectEx LIB "ezgui50.dll" (BYVAL N&) AS LONG
DECLARE SUB EZ_UseDoubleBuffer LIB "ezgui50.dll" ()
DECLARE SUB EZ_GetHelpInfo LIB "ezgui50.dll" (IDNum&, X&, Y&, HID&)
DECLARE SUB EZ_DefPolyEx LIB "ezgui50.dll" (BYVAL ShapeInfo$, BYVAL MaxRange&)
DECLARE SUB EZ_SetDefaultRgnPict LIB "ezgui50.dll" (BYVAL P$)

DECLARE SUB EZ_StartPrivateTimer LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL PTime&)
DECLARE SUB EZ_StopPrivateTimer LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)
DECLARE FUNCTION EZ_GetPrivateTime LIB "ezgui50.dll" () AS LONG


%EZ_CmpFGAttr   =   1
%EZ_CmpBGAttr   =   2
%EZ_CmpFontAttr =   3
%EZ_CmpSelAttr  =   4
%EZ_CmpBmpAttr  =   5
%EZ_CmpIcoAttr  =   6

DECLARE SUB EZ_SetCmpAttr LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL N&, BYVAL V&)
DECLARE FUNCTION EZ_GetCmpAttr LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL N&) AS LONG

DECLARE SUB EZ_SetSplitterMode LIB "ezgui50.dll" (BYVAL FormName$, BYVAL ShapeID&, BYVAL BuddyID1&, BYVAL BuddyID2&, BYVAL SProp$)
DECLARE SUB EZ_SetSplitterFormat LIB "ezgui50.dll" (BYVAL BSize1&, BYVAL BSize2&, BYVAL SMode&)
DECLARE FUNCTION EZ_GetMe LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_SetCmpText LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL IText$, BYVAL TIndex&)
DECLARE FUNCTION EZ_GetCmpText LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL TIndex&) AS STRING
DECLARE FUNCTION EZ_CmpFG LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_CmpBG LIB "ezgui50.dll" ()  AS LONG
DECLARE FUNCTION EZ_CmpFont LIB "ezgui50.dll" () AS LONG
DECLARE FUNCTION EZ_GetThemeClass LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS STRING
DECLARE SUB EZ_EndTheme LIB "ezgui50.dll" ()
DECLARE SUB EZ_StartTheme LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)
DECLARE FUNCTION EZ_StartThemeEx LIB "ezgui50.dll" (BYVAL hWnd&, BYVAL TC$) AS LONG
DECLARE SUB EZ_EndThemeEx LIB "ezgui50.dll" (BYVAL hTheme&)
DECLARE SUB EZ_UseNoTheme LIB "ezgui50.dll" ()
DECLARE SUB EZ_UseAutoSize LIB "ezgui50.dll" (BYVAL P$)
DECLARE SUB EZ_AddAutoSize LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL P$)
DECLARE SUB EZ_AddAutoSizeW LIB "ezgui50.dll" (BYVAL FormName$, BYVAL hWnd&, BYVAL P$)
DECLARE SUB EZ_FormEx LIB "ezgui50.dll" (BYVAL FormName$, BYVAL Parent$, BYVAL Caption$, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL Style$, BYVAL DWPTR AS DWORD, BYVAL EVPTR AS DWORD)
DECLARE SUB EZ_SetUserString LIB "ezgui50.dll" (BYVAL FormName$, BYVAL SIndex&,BYVAL T$)
DECLARE FUNCTION EZ_GetUserString LIB "ezgui50.dll" (BYVAL FormName$, BYVAL SIndex&) AS STRING
DECLARE FUNCTION EZ_SendEvent LIB "ezgui50.dll" (BYVAL FormName$, BYVAL CID&, BYVAL CMsg&, BYVAL CVal&) AS LONG
DECLARE FUNCTION EZ_SendMEEvent LIB "ezgui50.dll" (BYVAL CMsg&, BYVAL CVal&) AS LONG
DECLARE FUNCTION EZ_GetBitmapName LIB "ezgui50.dll" (BYVAL hBmp&) AS STRING
DECLARE FUNCTION EZ_GetIconName LIB "ezgui50.dll" (BYVAL hIcon&) AS STRING
DECLARE SUB EZ_SetCmp LIB "ezgui50.dll" (BYVAL FormName$, IDNum&, BYVAL CmpCommand$, BYVAL D$)
DECLARE FUNCTION EZ_GetCmp LIB "ezgui50.dll" (BYVAL FormName$, IDNum&, BYVAL CmpCommand$) AS STRING
DECLARE SUB EZ_CmpGetData LIB "ezgui50.dll" (Cmd$, D$)
DECLARE SUB EZ_CmpSetData LIB "ezgui50.dll" (BYVAL D$)
DECLARE FUNCTION EZ_NameIcon LIB "ezgui50.dll" (BYVAL hIcon&) AS STRING
DECLARE FUNCTION EZ_CMPName LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS STRING
DECLARE FUNCTION EZ_SetCaptureD LIB "ezgui50.dll" (BYVAL FormName$) AS LONG
DECLARE SUB EZ_AddDragRect LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&)
DECLARE SUB EZ_MoveMem LIB "ezgui50.dll" (BYVAL SrcMemPTR AS DWORD, BYVAL DestMemPTR AS DWORD, BYVAL MemLen&)
DECLARE FUNCTION EZ_AreaFitP LIB "ezgui50.dll" (BYVAL X&, BYVAL Y&, BYVAL W&, BYVAL H&, BYVAL TX&, BYVAL TY&, BYVAL TW&, BYVAL TH&) AS LONG
DECLARE FUNCTION EZ_AreaFit LIB "ezgui50.dll" (BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL TC!, BYVAL TR!, BYVAL TW!, BYVAL TH!) AS LONG
' ----------------------------------------------------------------

DECLARE SUB EZ_UseSuperClass LIB "ezgui50.dll" (BYVAL SClass$)
DECLARE SUB EZ_SuperClass LIB "ezgui50.dll" (BYVAL NewClass$, BYVAL UseClass$, BYVAL CP AS DWORD)
DECLARE FUNCTION EZ_GetSuperAddress LIB "ezgui50.dll" () AS DWORD
DECLARE FUNCTION EZ_CallSuperProc LIB "ezgui50.dll" (BYVAL CP AS DWORD, BYVAL hWnd AS LONG, BYVAL Msg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE SUB EZ_SetSuperClassProp LIB "ezgui50.dll" (BYVAL hWnd&, BYVAL N&, BYVAL V&)
DECLARE FUNCTION EZ_GetSuperClassProp LIB "ezgui50.dll" (BYVAL hWnd&, BYVAL N&) AS LONG
DECLARE SUB EZ_InitSuperClassProps LIB "ezgui50.dll" (BYVAL hWnd&)
DECLARE SUB EZ_FreeSuperClassProps LIB "ezgui50.dll" (BYVAL hWnd&)
DECLARE SUB EZ_SetSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&, BYVAL D$)
DECLARE FUNCTION EZ_GetSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&) AS STRING
DECLARE SUB EZ_FreeSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&)
DECLARE SUB EZ_LockSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&, lpAddress AS DWORD, SLen&)
DECLARE SUB EZ_UnlockSuperClassString LIB "ezgui50.dll" (BYVAL hWnd AS LONG, BYVAL N&)

' ----------------------------------------------------------------
DECLARE SUB EZ_GLCanvas LIB "ezgui50.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CProp$)
DECLARE FUNCTION EZ_GetRealClass LIB "ezgui50.dll" (BYVAL hWnd&) AS STRING
DECLARE FUNCTION EZ_StartGL LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS LONG
DECLARE SUB EZ_GL LIB "ezgui50.dll" (BYVAL Cmd$)
DECLARE SUB EZ_ExecGL LIB "ezgui50.dll" ()
DECLARE SUB EZ_EndGL LIB "ezgui50.dll" ()
DECLARE SUB EZ_DoGL LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL Cmd$)
DECLARE FUNCTION EZ_GetGL LIB "ezgui50.dll" () AS STRING
DECLARE SUB EZ_PreloadGL LIB "ezgui50.dll" ()
DECLARE SUB EZ_GetCColors LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, FG&, BG&)
DECLARE FUNCTION EZ_GetCFont LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS LONG
DECLARE SUB EZ_StopDrag LIB "ezgui50.dll" (BYVAL FormName$)

' ----------------------------------------------------------------
DECLARE SUB EZ_GetDragPos LIB "ezgui50.dll" (DX1&, DY1&, DX2&, DY2&)       ' use only in new event %EZ_DragPos

DECLARE SUB EZ_GetScaleMe LIB "ezgui50.dll" (BYVAL CVal&, OX&, OY&, OW&, OH&, NX&, NY&, NW&, NH&)
DECLARE SUB EZ_SetScaleMe LIB "ezgui50.dll" (BYVAL CVal&, BYVAL NX&, BYVAL NY&, BYVAL NW&, BYVAL NH&)
DECLARE SUB EZ_HookScaleMeProc LIB "ezgui50.dll" (BYVAL SMProc AS DWORD)
DECLARE SUB EZ_HotTrackControl LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL HProp$)
DECLARE FUNCTION EZ_IsHot LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS LONG
DECLARE SUB EZ_ResizePForm LIB "ezgui50.dll" (BYVAL FormName$, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!)
DECLARE SUB EZ_SetDropFilesEx LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL DFlag&)
DECLARE FUNCTION EZ_DefSysImageList LIB "ezgui50.dll" (BYVAL N&, BYVAL FontNum&, BYVAL ExPixels&) AS LONG
DECLARE FUNCTION EZ_GetSysImgIndex LIB "ezgui50.dll" (BYVAL F$) AS LONG
DECLARE SUB EZ_FillSysImageList LIB "ezgui50.dll" (BYVAL ExtList$)
DECLARE SUB EZ_EnableSnapTo LIB "ezgui50.dll" ()
DECLARE SUB EZ_DisableSnapTo LIB "ezgui50.dll" ()

DECLARE SUB EZ_DefCustObjDraw LIB "ezgui50.dll" (BYVAL CB AS DWORD)
DECLARE SUB EZ_DefTClass LIB "ezgui50.dll" (BYVAL C$)

DECLARE SUB EZ_ThemeDrawEdge LIB "ezgui50.dll" (BYVAL hTheme&, BYVAL hDC&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL PartID&, BYVAL StateID&, BYVAL Edge&, BYVAL Flags&)
DECLARE SUB EZ_ThemeDrawBG LIB "ezgui50.dll" (BYVAL hTheme&, BYVAL hDC&, BYVAL X1&, BYVAL Y1&, BYVAL X2&, BYVAL Y2&, BYVAL PartID&, BYVAL StateID&)
DECLARE SUB EZ_ResetAutoSize LIB "ezgui50.dll" (BYVAL FormName$, BYVAL FW!, BYVAL FH!)
DECLARE FUNCTION EZ_IsProcessReady LIB "ezgui50.dll" (BYVAL hProcessID&) AS LONG
DECLARE SUB EZ_ForceRichVersion LIB "ezgui50.dll" (BYVAL VerNum&)
DECLARE SUB EZ_SubClassSet LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL sMode&)
DECLARE SUB EZ_UseStyles LIB "ezgui50.dll" (BYVAL wStyle&, BYVAL wExStyle&, BYVAL SMode&)
DECLARE SUB EZ_DefTopHalfBGDraw LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL Color1&, BYVAL Color2&, BYVAL DProp$)
DECLARE SUB EZ_GetFColors LIB "ezgui50.dll" (BYVAL FormName$, FG&, BG&)
DECLARE SUB EZ_TABSetSize LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL X&, BYVAL Y&, BYVAL SMode&)
DECLARE FUNCTION EZ_SubClassGet LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&) AS LONG
DECLARE FUNCTION EZ_TestRGBColor LIB "ezgui50.dll" (BYVAL TestC&, BYVAL CmpC&, BYVAL Mode&) AS LONG
DECLARE SUB EZ_HidePLChildren LIB "ezgui50.dll" (BYVAL Form$, BYVAL ID&)
DECLARE SUB EZ_ChangeProp LIB "ezgui50.dll" (BYVAL FormName$, BYVAL IDNum&, BYVAL Prop$, BYVAL RFlag&)
