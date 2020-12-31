'------------------------------------------------------------------------------
'
'            Windows 95/NT API Declarations for PB/DLL
'
'                     Copyright (C) 1997 PowerBASIC, Inc.
'              Portions Copyright (C) 1993 Microsoft Corporation
'
'
'  This file contains the constants, TYPE, and DECLARE statements for the
'  Windows 95 and Windows NT API.
'
'  This file is not compatible with Visual Basic.  It uses the correct
'  data type as defined in the Microsoft SDK for Windows for all API calls.
'  This includes data types which are not natively supported in Visual Basic
'  such as unsigned integers and ASCIIZ strings.
'
'  You have a royalty-free right to use, modify, reproduce and distribute
'  this file (and/or any modified version) in any way you find useful,
'  provided that you agree that PowerBASIC has no warranty, obligation or
'  liability for its contents.  Refer to the Microsoft Windows Programmer's
'  Reference for further information.
'------------------------------------------------------------------------------
' Generated from the following:
' Main source code file:  C:\PBDLL60\ezgui\Ezgui51b.bas
' Resulting include file: C:\PBDLL60\WinapiEZ\Winclean.inc
'
' Created by inClean v1.25, 05-05-2016, 14:30:52
' Press Help-button for some useful information and tips.
'
'  21062 lines of include file data read and compared against
'  43584 lines of code in 1.72 seconds.
'
'-----------------------------------------------------------------
' Equates:  1407
'-----------------------------------------------------------------
%WINAPI                                         = 1
%TRUE                                           = 1
%FALSE                                          = 0
%NULL                                           = 0
%SYNCHRONIZE                                    = &H00100000???
%STANDARD_RIGHTS_REQUIRED                       = &H000F0000???
%STANDARD_RIGHTS_ALL                            = &H001F0000???
%DLL_PROCESS_DETACH                             = 0
%DLL_PROCESS_ATTACH                             = 1
%DLL_THREAD_ATTACH                              = 2
%DLL_THREAD_DETACH                              = 3
%GMEM_MOVEABLE                                  = &H2
%MIIM_STATE                                     = &H00000001
%MIIM_ID                                        = &H00000002
%MIIM_SUBMENU                                   = &H00000004
%MIIM_TYPE                                      = &H00000010
%LANG_ENGLISH                                   = &H9
%SUBLANG_DEFAULT                                = &H1  '  user default
%FILE_ATTRIBUTE_DIRECTORY                       = &H10&
%FILE_ATTRIBUTE_NORMAL                          = &H80&
%FILE_ATTRIBUTE_DEVICE                          = &H00000040&
%HELPINFO_WINDOW                                = 1
%HELPINFO_MENUITEM                              = 2
%REG_SZ                                         = 1     ' Unicode nul terminated string
%REG_DWORD                                      = 4     ' 32-bit number
%KEY_QUERY_VALUE                                = &H1
%KEY_SET_VALUE                                  = &H2
%KEY_CREATE_SUB_KEY                             = &H4
%KEY_ENUMERATE_SUB_KEYS                         = &H8
%KEY_NOTIFY                                     = &H10
%KEY_CREATE_LINK                                = &H20
%KEY_ALL_ACCESS                                 = %STANDARD_RIGHTS_ALL OR %KEY_QUERY_VALUE OR %KEY_SET_VALUE OR %KEY_CREATE_SUB_KEY OR %KEY_ENUMERATE_SUB_KEYS OR %KEY_NOTIFY OR %KEY_CREATE_LINK AND (NOT %SYNCHRONIZE)
%DRIVE_REMOVABLE                                = 2
%DRIVE_FIXED                                    = 3
%DRIVE_REMOTE                                   = 4
%DRIVE_CDROM                                    = 5
%DRIVE_RAMDISK                                  = 6
%CP_ACP                                         = 0  '  default to ANSI code page
%CP_OEMCP                                       = 1  '  default to OEM  code page
%LR_MONOCHROME                                  = &H0001
%LR_LOADFROMFILE                                = &H0010
%LR_LOADTRANSPARENT                             = &H0020
%LR_LOADMAP3DCOLORS                             = &H1000
%LR_CREATEDIBSECTION                            = &H2000
%DFC_CAPTION                                    = 1
%DFC_MENU                                       = 2
%DFC_SCROLL                                     = 3
%DFC_BUTTON                                     = 4
%DFCS_CAPTIONCLOSE                              = &H0000
%DFCS_CAPTIONMIN                                = &H0001
%DFCS_CAPTIONMAX                                = &H0002
%DFCS_CAPTIONRESTORE                            = &H0003
%DFCS_CAPTIONHELP                               = &H0004
%DFCS_MENUARROW                                 = &H0000
%DFCS_MENUCHECK                                 = &H0001
%DFCS_MENUBULLET                                = &H0002
%DFCS_SCROLLUP                                  = &H0000
%DFCS_SCROLLDOWN                                = &H0001
%DFCS_SCROLLLEFT                                = &H0002
%DFCS_SCROLLRIGHT                               = &H0003
%DFCS_BUTTONCHECK                               = &H0000
%DFCS_BUTTONRADIO                               = &H0004
%DFCS_BUTTONPUSH                                = &H0010
%DFCS_INACTIVE                                  = &H0100
%DFCS_PUSHED                                    = &H0200
%DFCS_CHECKED                                   = &H0400
%DFCS_HOT                                       = &H1000
%DFCS_MONO                                      = &H8000
%MAX_PATH                                       = 260
%R2_NOTXORPEN                                   = 10 '  DPxn
%R2_COPYPEN                                     = 13 '  P
%SRCCOPY                                        = &HCC0020 ' (DWORD) dest = source
%SRCINVERT                                      = &H660046 ' (DWORD) dest = source XOR dest
%PATCOPY                                        = &HF00021 ' (DWORD) dest = pattern
%RGN_OR                                         = 2
%RGN_XOR                                        = 3
%HALFTONE                                       = 4
%WINDING                                        = 2
%OBJ_BITMAP                                     = 7
%OBJ_REGION                                     = 8
%OBJ_MEMDC                                      = 10
%BI_RGB                                         = 0&
%LF_FACESIZE                                    = 32
%LF_FULLFACESIZE                                = 64
%OUT_DEFAULT_PRECIS                             = 0
%CLIP_DEFAULT_PRECIS                            = 0
%DRAFT_QUALITY                                  = 1
%PROOF_QUALITY                                  = 2
%ANTIALIASED_QUALITY                            = 4
%DEFAULT_PITCH                                  = 0
%FIXED_PITCH                                    = 1
%VARIABLE_PITCH                                 = 2
%ANSI_CHARSET                                   = 0
%DEFAULT_CHARSET                                = 1
%SYMBOL_CHARSET                                 = 2
%OEM_CHARSET                                    = 255
%FF_DONTCARE                                    = 0       '  Don't care or don't know.
%FW_THIN                                        = 100
%FW_LIGHT                                       = 300
%FW_NORMAL                                      = 400
%FW_MEDIUM                                      = 500
%FW_BOLD                                        = 700
%FW_HEAVY                                       = 900
%TRANSPARENT                                    = 1
%OPAQUE                                         = 2
%GM_COMPATIBLE                                  = 1
%GM_ADVANCED                                    = 2
%MM_TEXT                                        = 1
%MM_LOMETRIC                                    = 2
%MM_HIMETRIC                                    = 3
%MM_LOENGLISH                                   = 4
%MM_HIENGLISH                                   = 5
%MM_TWIPS                                       = 6
%MM_ANISOTROPIC                                 = 8
%WHITE_BRUSH                                    = 0
%NULL_BRUSH                                     = 5
%BLACK_PEN                                      = 7
%OEM_FIXED_FONT                                 = 10
%ANSI_FIXED_FONT                                = 11
%ANSI_VAR_FONT                                  = 12
%SYSTEM_FONT                                    = 13
%SYSTEM_FIXED_FONT                              = 16
%CLR_INVALID                                    = &HFFFF
%BS_PATTERN                                     = 3
%PS_SOLID                                       = 0
%PS_DASH                                        = 1     '  -------
%PS_DOT                                         = 2     '  .......
%PS_DASHDOT                                     = 3     '  _._._._
%PS_DASHDOTDOT                                  = 4     '  _.._.._
%PS_INSIDEFRAME                                 = 6
%PRF_CHECKVISIBLE                               = &H00000001&
%PRF_NONCLIENT                                  = &H00000002&
%PRF_CLIENT                                     = &H00000004&
%PRF_ERASEBKGND                                 = &H00000008&
%PRF_CHILDREN                                   = &H00000010&
%BDR_RAISEDOUTER                                = &H0001
%BDR_SUNKENOUTER                                = &H0002
%BDR_RAISEDINNER                                = &H0004
%BDR_SUNKENINNER                                = &H0008
%EDGE_RAISED                                    = %BDR_RAISEDOUTER OR %BDR_RAISEDINNER
%EDGE_SUNKEN                                    = %BDR_SUNKENOUTER OR %BDR_SUNKENINNER
%EDGE_ETCHED                                    = %BDR_SUNKENOUTER OR %BDR_RAISEDINNER
%EDGE_BUMP                                      = %BDR_RAISEDOUTER OR %BDR_SUNKENINNER
%BF_LEFT                                        = &H0001
%BF_TOP                                         = &H0002
%BF_RIGHT                                       = &H0004
%BF_BOTTOM                                      = &H0008
%BF_RECT                                        = %BF_LEFT OR %BF_TOP OR %BF_RIGHT OR %BF_BOTTOM
%TECHNOLOGY                                     = 2     '  Device classification
%HORZRES                                        = 8     '  Horizontal width in pixels
%VERTRES                                        = 10    '  Vertical width in pixels
%RASTERCAPS                                     = 38    '  Bitblt capabilities
%LOGPIXELSX                                     = 88    '  Logical pixels/inch in X
%LOGPIXELSY                                     = 90    '  Logical pixels/inch in Y
%PHYSICALWIDTH                                  = 110   '  Physical Width in device units
%PHYSICALHEIGHT                                 = 111   '  Physical Height in device units
%DT_RASDISPLAY                                  = 1     '  Raster display
%DT_RASPRINTER                                  = 2     '  Raster printer
%RC_BITBLT                                      = 1       '  Can do standard BLT.
%RC_STRETCHDIB                                  = &H2000  '  supports StretchDIBits
%DIB_RGB_COLORS                                 = 0 '  color table in RGBs
%FLOODFILLBORDER                                = 0
%FLOODFILLSURFACE                               = 1
%CCHDEVICENAME                                  = 32
%CCHFORMNAME                                    = 32
%DM_ORIENTATION                                 = &H1&
%DM_PAPERSIZE                                   = &H2&
%DM_PAPERLENGTH                                 = &H4&
%DM_PAPERWIDTH                                  = &H8&
%DM_COPIES                                      = &H100&
%DM_DEFAULTSOURCE                               = &H200&
%DM_PRINTQUALITY                                = &H400&
%DM_COLOR                                       = &H800&
%DM_COLLATE                                     = &H8000
%DM_FORMNAME                                    = &H10000
%DMPAPER_TABLOID                                = 3    '  Tabloid 11 x 17 in
%DMPAPER_LEDGER                                 = 4    '  Ledger 17 x 11 in
%DMPAPER_LEGAL                                  = 5    '  Legal 8 1/2 x 14 in
%DMPAPER_STATEMENT                              = 6    '  Statement 5 1/2 x 8 1/2 in
%DMPAPER_EXECUTIVE                              = 7    '  Executive 7 1/4 x 10 1/2 in
%DMPAPER_USER                                   = 256
%DMCOLLATE_FALSE                                = 0
%DMCOLLATE_TRUE                                 = 1
%RDH_RECTANGLES                                 = 1
%DM_COPY                                        = 2
%DM_PROMPT                                      = 4
%DM_MODIFY                                      = 8
%DM_IN_BUFFER                                   = %DM_MODIFY
%DM_OUT_BUFFER                                  = %DM_COPY
%DEFAULT_GUI_FONT                               = 17
%SB_HORZ                                        = 0
%SB_VERT                                        = 1
%SB_CTL                                         = 2
%SB_BOTH                                        = 3
%SB_LINEUP                                      = 0
%SB_LINEDOWN                                    = 1
%SB_PAGEUP                                      = 2
%SB_PAGEDOWN                                    = 3
%SB_THUMBPOSITION                               = 4
%SB_THUMBTRACK                                  = 5
%SB_TOP                                         = 6
%SB_BOTTOM                                      = 7
%SB_ENDSCROLL                                   = 8
%SIF_RANGE                                      = &H0001
%SIF_PAGE                                       = &H0002
%SIF_POS                                        = &H0004
%SIF_TRACKPOS                                   = &H0010
%SIF_ALL                                        = %SIF_RANGE OR %SIF_PAGE OR %SIF_POS OR %SIF_TRACKPOS
%SW_HIDE                                        = 0
%SW_SHOWNORMAL                                  = 1
%SW_SHOWMAXIMIZED                               = 3
%SW_MAXIMIZE                                    = 3
%SW_SHOW                                        = 5
%SW_MINIMIZE                                    = 6
%SW_RESTORE                                     = 9
%VK_LBUTTON                                     = &H01
%VK_RBUTTON                                     = &H02
%VK_BACK                                        = &H08
%VK_TAB                                         = &H09
%VK_RETURN                                      = &H0D
%VK_SHIFT                                       = &H10
%VK_CONTROL                                     = &H11
%VK_MENU                                        = &H12
%VK_ESCAPE                                      = &H1B
%VK_SPACE                                       = &H20
%VK_PGUP                                        = &H21
%VK_PGDN                                        = &H22
%VK_END                                         = &H23
%VK_HOME                                        = &H24
%VK_LEFT                                        = &H25
%VK_UP                                          = &H26
%VK_RIGHT                                       = &H27
%VK_DOWN                                        = &H28
%VK_PRINT                                       = &H2A
%VK_INSERT                                      = &H2D
%VK_DELETE                                      = &H2E
%GWL_WNDPROC                                    = -4
%GWL_STYLE                                      = -16
%GWL_EXSTYLE                                    = -20
%GWL_USERDATA                                   = -21
%GWL_ID                                         = -12
%GCL_CBWNDEXTRA                                 = -18
%WM_USER                                        = &H400
%WM_NULL                                        = &H0
%WM_CREATE                                      = &H1
%WM_DESTROY                                     = &H2
%WM_MOVE                                        = &H3
%WM_SIZE                                        = &H5
%WM_ACTIVATE                                    = &H6
%WM_SETFOCUS                                    = &H7
%WM_KILLFOCUS                                   = &H8
%WM_ENABLE                                      = &HA
%WM_SETREDRAW                                   = &HB
%WM_SETTEXT                                     = &HC
%WM_GETTEXT                                     = &HD
%WM_GETTEXTLENGTH                               = &HE
%WM_PAINT                                       = &HF
%WM_CLOSE                                       = &H10
%WM_QUIT                                        = &H12
%WM_ERASEBKGND                                  = &H14
%WM_SYSCOLORCHANGE                              = &H15
%WM_SHOWWINDOW                                  = &H18
%WM_WININICHANGE                                = &H1A
%WM_SETTINGCHANGE                               = %WM_WININICHANGE
%WM_ACTIVATEAPP                                 = &H1C
%WM_FONTCHANGE                                  = &H1D
%WM_TIMECHANGE                                  = &H1E
%WM_SETCURSOR                                   = &H20
%WM_MOUSEACTIVATE                               = &H21
%WM_GETMINMAXINFO                               = &H24
%WM_NEXTDLGCTL                                  = &H28
%WM_DRAWITEM                                    = &H2B
%WM_MEASUREITEM                                 = &H2C
%WM_SETFONT                                     = &H30
%WM_GETFONT                                     = &H31
%WM_COMPAREITEM                                 = &H39
%WM_COMPACTING                                  = &H41
%WM_WINDOWPOSCHANGING                           = &H46
%WM_NOTIFY                                      = &H4E
%WM_HELP                                        = &H53
%WM_NOTIFYFORMAT                                = &H55
%WM_DISPLAYCHANGE                               = &H7E
%WM_SETICON                                     = &H80
%WM_NCCREATE                                    = &H81
%WM_NCCALCSIZE                                  = &H83
%WM_NCHITTEST                                   = &H84
%WM_NCPAINT                                     = &H85
%WM_NCACTIVATE                                  = &H86
%WM_GETDLGCODE                                  = &H87
%WM_NCMOUSEMOVE                                 = &HA0
%WM_NCLBUTTONDOWN                               = &HA1
%WM_NCLBUTTONUP                                 = &HA2
%WM_NCLBUTTONDBLCLK                             = &HA3
%WM_NCRBUTTONDOWN                               = &HA4
%WM_NCRBUTTONUP                                 = &HA5
%WM_NCRBUTTONDBLCLK                             = &HA6
%WM_NCMBUTTONDOWN                               = &HA7
%WM_NCMBUTTONUP                                 = &HA8
%WM_NCMBUTTONDBLCLK                             = &HA9
%WM_KEYFIRST                                    = &H100
%WM_KEYDOWN                                     = &H100
%WM_KEYUP                                       = &H101
%WM_CHAR                                        = &H102
%WM_SYSKEYDOWN                                  = &H104
%WM_SYSKEYUP                                    = &H105
%WM_SYSCHAR                                     = &H106
%WM_KEYLAST                                     = &H108
%WM_INITDIALOG                                  = &H110
%WM_COMMAND                                     = &H111
%WM_SYSCOMMAND                                  = &H112
%WM_TIMER                                       = &H113
%WM_HSCROLL                                     = &H114
%WM_VSCROLL                                     = &H115
%WM_INITMENUPOPUP                               = &H117
%WM_MENUSELECT                                  = &H11F
%WM_CTLCOLOREDIT                                = &H133
%WM_CTLCOLORLISTBOX                             = &H134
%WM_CTLCOLORBTN                                 = &H135
%WM_CTLCOLORDLG                                 = &H136
%WM_CTLCOLORSTATIC                              = &H138
%WM_MOUSEMOVE                                   = &H200
%WM_LBUTTONDOWN                                 = &H201
%WM_LBUTTONUP                                   = &H202
%WM_LBUTTONDBLCLK                               = &H203
%WM_RBUTTONDOWN                                 = &H204
%WM_RBUTTONUP                                   = &H205
%WM_RBUTTONDBLCLK                               = &H206
%WM_MBUTTONDOWN                                 = &H207
%WM_MBUTTONUP                                   = &H208
%WM_MBUTTONDBLCLK                               = &H209
%WM_MOUSEWHEEL                                  = &H20A
%WM_SIZING                                      = &H214
%WM_CAPTURECHANGED                              = &H215
%WM_MOVING                                      = &H216
%WM_MDIDESTROY                                  = &H221
%WM_MDIACTIVATE                                 = &H222
%WM_MDITILE                                     = &H226
%WM_MDICASCADE                                  = &H227
%WM_MDIICONARRANGE                              = &H228
%WM_MDIGETACTIVE                                = &H229
%WM_MDISETMENU                                  = &H230
%WM_DROPFILES                                   = &H233
%WM_PRINT                                       = &H317
%WM_PRINTCLIENT                                 = &H318
%ICON_SMALL                                     = 0
%ICON_BIG                                       = 1
%HTTRANSPARENT                                  = -1
%HTCLIENT                                       = 1
%HTCAPTION                                      = 2
%HTSYSMENU                                      = 3
%HTLEFT                                         = 10
%HTRIGHT                                        = 11
%HTTOP                                          = 12
%HTTOPLEFT                                      = 13
%HTTOPRIGHT                                     = 14
%HTBOTTOM                                       = 15
%HTBOTTOMLEFT                                   = 16
%HTBOTTOMRIGHT                                  = 17
%HTBORDER                                       = 18
%MA_NOACTIVATEANDEAT                            = 4
%SIZE_RESTORED                                  = 0
%SIZE_MINIMIZED                                 = 1
%SIZE_MAXIMIZED                                 = 2
%WS_POPUP                                       = &H80000000&
%WS_CHILD                                       = &H40000000&
%WS_VISIBLE                                     = &H10000000&
%WS_DISABLED                                    = &H8000000&
%WS_CLIPSIBLINGS                                = &H4000000&
%WS_CLIPCHILDREN                                = &H2000000&
%WS_MAXIMIZE                                    = &H1000000
%WS_CAPTION                                     = &HC00000&  '  WS_BORDER OR WS_DLGFRAME
%WS_BORDER                                      = &H800000&
%WS_DLGFRAME                                    = &H400000&
%WS_VSCROLL                                     = &H200000&
%WS_HSCROLL                                     = &H100000&
%WS_SYSMENU                                     = &H80000&
%WS_THICKFRAME                                  = &H40000&
%WS_GROUP                                       = &H20000&
%WS_TABSTOP                                     = &H10000&
%WS_MINIMIZEBOX                                 = &H20000&
%WS_MAXIMIZEBOX                                 = &H10000&
%WS_EX_DLGMODALFRAME                            = &H00000001&
%WS_EX_TOPMOST                                  = &H00000008&
%WS_EX_TRANSPARENT                              = &H00000020&
%WS_EX_MDICHILD                                 = &H00000040&
%WS_EX_TOOLWINDOW                               = &H00000080&
%WS_EX_WINDOWEDGE                               = &H00000100&
%WS_EX_CLIENTEDGE                               = &H00000200&
%WS_EX_CONTEXTHELP                              = &H00000400&
%WS_EX_CONTROLPARENT                            = &H00010000&
%WS_EX_LAYERED                                  = &H00080000
%WS_EX_COMPOSITED                               = &H02000000
%CS_VREDRAW                                     = &H1
%CS_HREDRAW                                     = &H2
%CS_DBLCLKS                                     = &H8
%CS_OWNDC                                       = &H20
%CS_PARENTDC                                    = &H80
%CS_NOCLOSE                                     = &H200
%CS_PUBLICCLASS                                 = &H4000
%CS_GLOBALCLASS                                 = %CS_PUBLICCLASS
%CF_TEXT                                        =  1
%CF_BITMAP                                      =  2
%FVIRTKEY                                       = &H1        '  Assumed to be == TRUE
%FNOINVERT                                      = &H2
%FSHIFT                                         = &H4
%FCONTROL                                       = &H8
%FALT                                           = &H10
%ODT_MENU                                       = 1
%ODT_LISTBOX                                    = 2
%ODT_COMBOBOX                                   = 3
%ODT_BUTTON                                     = 4
%ODT_STATIC                                     = 5
%ODS_SELECTED                                   = &H1
%ODS_GRAYED                                     = &H2
%ODS_DISABLED                                   = &H4
%ODS_CHECKED                                    = &H8
%ODS_FOCUS                                      = &H10
%ODS_DEFAULT                                    = &H0020
%ODS_COMBOBOXEDIT                               = &H1000
%PM_REMOVE                                      = &H1
%CW_USEDEFAULT                                  = &H80000000???
%CWP_SKIPINVISIBLE                              = &H0001
%CWP_SKIPDISABLED                               = &H0002
%HWND_DESKTOP                                   = 0
%SWP_NOSIZE                                     = &H1
%SWP_NOMOVE                                     = &H2
%SWP_NOZORDER                                   = &H4
%SWP_NOREDRAW                                   = &H8
%SWP_NOACTIVATE                                 = &H10
%SWP_FRAMECHANGED                               = &H20        '  The frame changed: send WM_NCCALCSIZE
%SWP_NOCOPYBITS                                 = &H100
%SWP_NOOWNERZORDER                              = &H200      '  Don't do owner Z ordering
%SWP_DRAWFRAME                                  = %SWP_FRAMECHANGED
%HWND_TOP                                       = 0
%HWND_BOTTOM                                    = 1
%DLGWINDOWEXTRA                                 = 30        '  Window extra bytes needed for private dialog classes
%SM_CXSCREEN                                    = 0
%SM_CYSCREEN                                    = 1
%SM_CXVSCROLL                                   = 2
%SM_CYHSCROLL                                   = 3
%SM_CYCAPTION                                   = 4
%SM_CXBORDER                                    = 5
%SM_CYBORDER                                    = 6
%SM_CXDLGFRAME                                  = 7
%SM_CYDLGFRAME                                  = 8
%SM_CXICON                                      = 11
%SM_CYICON                                      = 12
%SM_CXCURSOR                                    = 13
%SM_CYCURSOR                                    = 14
%SM_CYMENU                                      = 15
%SM_SWAPBUTTON                                  = 23
%SM_CXFRAME                                     = 32
%SM_CYFRAME                                     = 33
%SM_CMOUSEBUTTONS                               = 43
%SM_CXFIXEDFRAME                                = %SM_CXDLGFRAME  ' win40 name change
%SM_CYFIXEDFRAME                                = %SM_CYDLGFRAME  ' win40 name change
%SM_CXSIZEFRAME                                 = %SM_CXFRAME     ' win40 name change
%SM_CYSIZEFRAME                                 = %SM_CYFRAME     ' win40 name change
%SM_CXEDGE                                      = 45
%SM_CYEDGE                                      = 46
%SM_CYSMICON                                    = 50
%SM_CYSMCAPTION                                 = 51
%SM_CXMAXTRACK                                  = 59
%SM_CYMAXTRACK                                  = 60
%SM_XVIRTUALSCREEN                              = 76
%SM_YVIRTUALSCREEN                              = 77
%SM_CXVIRTUALSCREEN                             = 78
%SM_CYVIRTUALSCREEN                             = 79
%SM_CMONITORS                                   = 80
%TPM_LEFTBUTTON                                 = &H0&
%TPM_LEFTALIGN                                  = &H0&
%TPM_CENTERALIGN                                = &H4&
%TPM_RIGHTALIGN                                 = &H8&
%DT_TOP                                         = &H0
%DT_LEFT                                        = &H0
%DT_CENTER                                      = &H1
%DT_RIGHT                                       = &H2
%DT_VCENTER                                     = &H4
%DT_BOTTOM                                      = &H8
%DT_SINGLELINE                                  = &H20
%DT_CALCRECT                                    = &H400
%DT_PATH_ELLIPSIS                               = &H00004000
%DCX_WINDOW                                     = &H1&
%DCX_CACHE                                      = &H2&
%DCX_CLIPCHILDREN                               = &H8&
%DCX_CLIPSIBLINGS                               = &H10&
%DCX_PARENTCLIP                                 = &H20&
%RDW_INVALIDATE                                 = &H1
%RDW_INTERNALPAINT                              = &H2
%RDW_ERASE                                      = &H4
%RDW_ALLCHILDREN                                = &H80
%RDW_UPDATENOW                                  = &H100
%RDW_FRAME                                      = &H400
%MB_OK                                          = &H0&
%MB_OKCANCEL                                    = &H1&
%MB_ABORTRETRYIGNORE                            = &H2&
%MB_YESNOCANCEL                                 = &H3&
%MB_YESNO                                       = &H4&
%MB_RETRYCANCEL                                 = &H5&
%MB_ICONHAND                                    = &H10&
%MB_ICONQUESTION                                = &H20&
%MB_ICONEXCLAMATION                             = &H30&
%MB_ICONASTERISK                                = &H40&
%MB_USERICON                                    = &H00000080&
%MB_ICONINFORMATION                             = %MB_ICONASTERISK
%MB_ICONSTOP                                    = %MB_ICONHAND
%MB_DEFBUTTON1                                  = &H0&
%MB_DEFBUTTON2                                  = &H100&
%MB_DEFBUTTON3                                  = &H200&
%MB_TASKMODAL                                   = &H2000&
%MB_SETFOREGROUND                               = &H10000
%MB_TOPMOST                                     = &H40000&
%COLOR_ACTIVECAPTION                            = 2
%COLOR_INACTIVECAPTION                          = 3
%COLOR_MENU                                     = 4
%COLOR_WINDOW                                   = 5
%COLOR_MENUTEXT                                 = 7
%COLOR_WINDOWTEXT                               = 8
%COLOR_HIGHLIGHT                                = 13
%COLOR_HIGHLIGHTTEXT                            = 14
%COLOR_BTNFACE                                  = 15
%COLOR_BTNSHADOW                                = 16
%COLOR_GRAYTEXT                                 = 17
%COLOR_BTNTEXT                                  = 18
%COLOR_3DDKSHADOW                               = 21
%COLOR_3DFACE                                   = %COLOR_BTNFACE
%COLOR_3DSHADOW                                 = %COLOR_BTNSHADOW
%GW_HWNDNEXT                                    = 2
%GW_OWNER                                       = 4
%GW_CHILD                                       = 5
%MF_BYCOMMAND                                   = &H0&
%MF_SEPARATOR                                   = &H800&
%MF_ENABLED                                     = &H0&
%MF_GRAYED                                      = &H1&
%MF_UNCHECKED                                   = &H0&
%MF_CHECKED                                     = &H8&
%MF_STRING                                      = &H0&
%MF_OWNERDRAW                                   = &H100&
%MF_POPUP                                       = &H10&
%MF_MENUBARBREAK                                = &H20&
%MF_MENUBREAK                                   = &H40&
%MF_UNHILITE                                    = &H0&
%MF_HILITE                                      = &H80&
%MF_SYSMENU                                     = &H2000&
%MFT_STRING                                     = %MF_STRING
%MFT_OWNERDRAW                                  = %MF_OWNERDRAW
%SC_SIZE                                        = &HF000&
%SC_MINIMIZE                                    = &HF020&
%SC_MAXIMIZE                                    = &HF030&
%SC_CLOSE                                       = &HF060&
%SC_RESTORE                                     = &HF120&
%IDC_ARROW                                      = 32512&
%IDC_IBEAM                                      = 32513&
%IDC_WAIT                                       = 32514&
%IDC_CROSS                                      = 32515&
%IDC_UPARROW                                    = 32516&
%IDC_SIZENWSE                                   = 32642&
%IDC_SIZENESW                                   = 32643&
%IDC_SIZEWE                                     = 32644&
%IDC_SIZENS                                     = 32645&
%IDC_SIZEALL                                    = 32646&
%IDC_NO                                         = 32648&
%IDC_HAND                                       = 32649&
%IDC_APPSTARTING                                = 32650&
%IDC_HELP                                       = 32651&
%OIC_SAMPLE                                     = 32512
%OIC_HAND                                       = 32513
%OIC_QUES                                       = 32514
%OIC_BANG                                       = 32515
%OIC_NOTE                                       = 32516
%OIC_WINLOGO                                    = 32517
%IDOK                                           = 1
%IDCANCEL                                       = 2
%IDABORT                                        = 3
%IDRETRY                                        = 4
%IDIGNORE                                       = 5
%IDYES                                          = 6
%IDNO                                           = 7
%ES_LEFT                                        = &H0&
%ES_CENTER                                      = &H1&
%ES_RIGHT                                       = &H2&
%ES_MULTILINE                                   = &H4&
%ES_UPPERCASE                                   = &H8&
%ES_PASSWORD                                    = &H20&
%ES_AUTOVSCROLL                                 = &H40&
%ES_AUTOHSCROLL                                 = &H80&
%ES_READONLY                                    = &H800&
%ES_WANTRETURN                                  = &H1000&
%ES_NUMBER                                      = &H2000&
%EN_SETFOCUS                                    = &H100
%EN_KILLFOCUS                                   = &H200
%EN_CHANGE                                      = &H300
%EN_UPDATE                                      = &H400
%EC_LEFTMARGIN                                  = &H00000001
%EC_RIGHTMARGIN                                 = &H00000002
%EM_GETSEL                                      = &HB0
%EM_SETSEL                                      = &HB1
%EM_LINESCROLL                                  = &HB6
%EM_GETMODIFY                                   = &HB8
%EM_SETMODIFY                                   = &HB9
%EM_GETLINECOUNT                                = &HBA
%EM_LIMITTEXT                                   = &HC5
%EM_CANUNDO                                     = &HC6
%EM_UNDO                                        = &HC7
%EM_GETFIRSTVISIBLELINE                         = &HCE
%EM_SETREADONLY                                 = &HCF
%EM_SETMARGINS                                  = &HD3
%EM_GETMARGINS                                  = &HD4
%EM_SETLIMITTEXT                                = %EM_LIMITTEXT
%EM_GETLIMITTEXT                                = &HD5
%BS_PUSHBUTTON                                  = &H0&
%BS_DEFPUSHBUTTON                               = &H1&
%BS_CHECKBOX                                    = &H2&
%BS_AUTOCHECKBOX                                = &H3&
%BS_RADIOBUTTON                                 = &H4&
%BS_3STATE                                      = &H5&
%BS_AUTO3STATE                                  = &H6&
%BS_GROUPBOX                                    = &H7&
%BS_AUTORADIOBUTTON                             = &H9&
%BS_OWNERDRAW                                   = &HB&
%BS_LEFTTEXT                                    = &H20&
%BS_ICON                                        = &H40&
%BS_BITMAP                                      = &H80&
%BS_LEFT                                        = &H100&
%BS_RIGHT                                       = &H200&
%BS_CENTER                                      = &H300&
%BS_PUSHLIKE                                    = &H1000&
%BS_MULTILINE                                   = &H2000&
%BS_NOTIFY                                      = &H4000&
%BS_FLAT                                        = &H8000&
%BN_CLICKED                                     = 0
%BN_DOUBLECLICKED                               = 5
%BN_SETFOCUS                                    = 6
%BN_KILLFOCUS                                   = 7
%BN_DBLCLK                                      = %BN_DOUBLECLICKED
%BM_GETCHECK                                    = &HF0
%BM_SETCHECK                                    = &HF1
%BM_SETSTYLE                                    = &HF4
%BM_CLICK                                       = &HF5
%BM_GETIMAGE                                    = &HF6
%BM_SETIMAGE                                    = &HF7
%SS_LEFT                                        = &H0000&
%SS_CENTER                                      = &H0001&
%SS_RIGHT                                       = &H0002&
%SS_ICON                                        = &H0003&
%SS_OWNERDRAW                                   = &H000D&
%SS_BITMAP                                      = &H000E&
%SS_NOPREFIX                                    = &H0080& '  Don't do "&" character translation
%SS_NOTIFY                                      = &H0100&
%SS_CENTERIMAGE                                 = &H0200&
%STM_SETICON                                    = &H170
%STM_SETIMAGE                                   = &H172
%STM_GETIMAGE                                   = &H173
%STN_CLICKED                                    = 0
%STN_DBLCLK                                     = 1
%STN_DISABLE                                    = 3
%DWL_DLGPROC                                    = 4
%DDL_READWRITE                                  = &H0&
%DDL_READONLY                                   = &H1&
%DDL_HIDDEN                                     = &H2&
%DDL_SYSTEM                                     = &H4&
%DDL_DIRECTORY                                  = &H10&
%DDL_ARCHIVE                                    = &H20&
%DDL_DRIVES                                     = &H4000&
%DDL_EXCLUSIVE                                  = &H8000&
%DS_SYSMODAL                                    = &H0002&
%DS_MODALFRAME                                  = &H0080& '  Can be combined with WS_CAPTION
%DS_CONTROL                                     = &H0400&
%DM_GETDEFID                                    = %WM_USER + 0
%DM_SETDEFID                                    = %WM_USER + 1
%DLGC_HASSETSEL                                 = &H8    '  Understands EM_SETSEL message
%LBN_SELCHANGE                                  = 1
%LBN_DBLCLK                                     = 2
%LBN_SETFOCUS                                   = 4
%LBN_KILLFOCUS                                  = 5
%LB_ADDSTRING                                   = &H180
%LB_INSERTSTRING                                = &H181
%LB_DELETESTRING                                = &H182
%LB_RESETCONTENT                                = &H184
%LB_SETSEL                                      = &H185
%LB_SETCURSEL                                   = &H186
%LB_GETSEL                                      = &H187
%LB_GETCURSEL                                   = &H188
%LB_GETTEXT                                     = &H189
%LB_GETTEXTLEN                                  = &H18A
%LB_GETCOUNT                                    = &H18B
%LB_DIR                                         = &H18D
%LB_GETTOPINDEX                                 = &H18E
%LB_GETSELCOUNT                                 = &H190
%LB_SETCOLUMNWIDTH                              = &H195
%LB_SETTOPINDEX                                 = &H197
%LB_GETITEMRECT                                 = &H198
%LB_GETITEMDATA                                 = &H199
%LB_SETCARETINDEX                               = &H19E
%LB_GETCARETINDEX                               = &H19F
%LB_SETITEMHEIGHT                               = &H1A0
%LB_GETITEMHEIGHT                               = &H1A1
%LB_FINDSTRINGEXACT                             = &H1A2
%LB_ITEMFROMPOINT                               = &H1A9
%LBS_NOTIFY                                     = &H1&
%LBS_SORT                                       = &H2&
%LBS_MULTIPLESEL                                = &H8&
%LBS_OWNERDRAWFIXED                             = &H10&
%LBS_OWNERDRAWVARIABLE                          = &H20&
%LBS_HASSTRINGS                                 = &H40&
%LBS_USETABSTOPS                                = &H80&
%LBS_NOINTEGRALHEIGHT                           = &H100&
%LBS_MULTICOLUMN                                = &H200&
%LBS_NODATA                                     = &H2000&
%LBS_STANDARD                                   = %LBS_NOTIFY OR %LBS_SORT OR %WS_VSCROLL OR %WS_BORDER
%CBN_SELCHANGE                                  = 1
%CBN_DBLCLK                                     = 2
%CBN_SETFOCUS                                   = 3
%CBN_KILLFOCUS                                  = 4
%CBN_EDITCHANGE                                 = 5
%CBN_EDITUPDATE                                 = 6
%CBN_DROPDOWN                                   = 7
%CBN_CLOSEUP                                    = 8
%CBS_SIMPLE                                     = &H1&
%CBS_DROPDOWN                                   = &H2&
%CBS_DROPDOWNLIST                               = &H3&
%CBS_OWNERDRAWFIXED                             = &H10&
%CBS_OWNERDRAWVARIABLE                          = &H20&
%CBS_SORT                                       = &H100&
%CBS_HASSTRINGS                                 = &H200&
%CBS_NOINTEGRALHEIGHT                           = &H400&
%CB_LIMITTEXT                                   = &H141
%CB_ADDSTRING                                   = &H143
%CB_DELETESTRING                                = &H144
%CB_GETCOUNT                                    = &H146
%CB_GETCURSEL                                   = &H147
%CB_GETLBTEXT                                   = &H148
%CB_GETLBTEXTLEN                                = &H149
%CB_RESETCONTENT                                = &H14B
%CB_FINDSTRING                                  = &H14C
%CB_SETCURSEL                                   = &H14E
%CB_SHOWDROPDOWN                                = &H14F
%CB_GETITEMDATA                                 = &H150
%CB_GETDROPPEDCONTROLRECT                       = &H152
%CB_SETITEMHEIGHT                               = &H153
%CB_SETEXTENDEDUI                               = &H155
%CB_GETEXTENDEDUI                               = &H156
%CB_GETDROPPEDSTATE                             = &H157
%CB_GETTOPINDEX                                 = &H15B
%CB_SETTOPINDEX                                 = &H15C
%CB_GETDROPPEDWIDTH                             = &H15F
%CB_SETDROPPEDWIDTH                             = &H160
%SBS_HORZ                                       = &H0&
%SBS_VERT                                       = &H1&
%MDIS_ALLCHILDSTYLES                            = &H1
%MDITILE_VERTICAL                               = &H0
%MDITILE_HORIZONTAL                             = &H1
%HELP_CONTEXT                                   = &H1    '  Display topic in ulTopic
%HELP_QUIT                                      = &H2    '  Terminate help
%HELP_CONTEXTPOPUP                              = &H8&
%HELP_KEY                                       = &H101  '  Display topic for keyword in offabData
%HELP_COMMAND                                   = &H102&
%HELP_FINDER                                    = &H000B
%SPI_SETDRAGFULLWINDOWS                         = 37
%SPI_GETDRAGFULLWINDOWS                         = 38
%SPI_SETWORKAREA                                = 47
%SPI_GETWORKAREA                                = 48
%SPI_GETFONTSMOOTHING                           = 74
%SPI_SETFONTSMOOTHING                           = 75
%ERROR_SUCCESS                                  = 0&
%DI_MASK                                        = &H0001
%DI_IMAGE                                       = &H0002
%DI_NORMAL                                      = &H0003
%PRINTER_ENUM_LOCAL                             = &H2
%PRINTER_ENUM_CONNECTIONS                       = &H4
%HKEY_CLASSES_ROOT                              = &H80000000
%HKEY_CURRENT_USER                              = &H80000001
%HKEY_LOCAL_MACHINE                             = &H80000002
%HKEY_USERS                                     = &H80000003
%HKEY_PERFORMANCE_DATA                          = &H80000004
%HKEY_CURRENT_CONFIG                            = &H80000005
%HKEY_DYN_DATA                                  = &H80000006
%NIM_ADD                                        = &H00000000
%NIM_MODIFY                                     = &H00000001
%NIM_DELETE                                     = &H00000002
%NIM_SETVERSION                                 = &H00000004
%NIF_MESSAGE                                    = &H00000001
%NIF_ICON                                       = &H00000002
%NIF_TIP                                        = &H00000004
%NIF_STATE                                      = &H00000008
%NIF_INFO                                       = &H00000010
%NIS_HIDDEN                                     = &H00000001
%NIS_SHAREDICON                                 = &H00000002
%NIIF_INFO                                      = &H00000001
%NIIF_WARNING                                   = &H00000002
%NIIF_ERROR                                     = &H00000003
%SHGFI_ICON                                     = &H100&   '  get icon
%SHGFI_SYSICONINDEX                             = &H4000&  '  get system icon index
%SHGFI_LARGEICON                                = &H0&     '  get large icon
%SHGFI_SMALLICON                                = &H1&     '  get small icon
%SHGFI_USEFILEATTRIBUTES                        = &H10&    '  use passed dwFileAttribute
%PROCESS_ALL_ACCESS                             = %STANDARD_RIGHTS_REQUIRED OR %SYNCHRONIZE OR &HFFF???
%VER_PLATFORM_WIN32_NT                          = 2
%PRINTER_FONTTYPE                               = &H4000
%SCREEN_FONTTYPE                                = &H2000
%PSD_DEFAULTMINMARGINS                          = &H0 '  default (printer's)
%PSD_MARGINS                                    = &H2 '  use caller's
%PSD_INTHOUSANDTHSOFINCHES                      = &H4 '  2nd of 4 possible
%PSD_INHUNDREDTHSOFMILLIMETERS                  = &H8 '  3rd of 4 possible
%PSD_DISABLEMARGINS                             = &H10
%PSD_ENABLEPAGESETUPHOOK                        = &H2000 '  must be same as PD_*
%NM_FIRST                                       = (0???-  0???)  ' generic to all controls
%IMAGE_BITMAP                                   = 0
%IMAGE_ICON                                     = 1
%IMAGE_CURSOR                                   = 2
%BIF_RETURNONLYFSDIRS                           = &H0001  ' For finding a folder to start document searching
%BIF_EDITBOX                                    = &H0010   ' Add an editbox to the dialog
%BIF_NEWDIALOGSTYLE                             = &H0040   ' Use the new dialog layout with the ability to resize
%BIF_BROWSEINCLUDEFILES                         = &H4000  ' Browsing for Everything
%BFFM_INITIALIZED                               = 1
%BFFM_SELCHANGED                                = 2
%BFFM_ENABLEOK                                  = %WM_USER + 101
%BFFM_SETSELECTION                              = %WM_USER + 102
%CSIDL_DESKTOP                                  = &H0000  ' <desktop>
%CSIDL_PROGRAMS                                 = &H0002  ' Start Menu\Programs
%CSIDL_PRINTERS                                 = &H0004  ' My Computer\Printers
%CSIDL_PERSONAL                                 = &H0005  ' My Documents
%CSIDL_DRIVES                                   = &H0011  ' My Computer
%CSIDL_FONTS                                    = &H0014  ' windows\fonts
%CSIDL_WINDOWS                                  = &H0024  ' GetWindowsDirectory()
%CSIDL_SYSTEM                                   = &H0025  ' GetSystemDirectory()
%CSIDL_PROGRAM_FILES                            = &H0026  ' C:\Program Files
%CSIDL_CONNECTIONS                              = &H0031  ' Network and Dial-up Connections
%ODT_HEADER                                     = 100
%ODT_TAB                                        = 101
%ODT_LISTVIEW                                   = 102
%LVM_FIRST                                      = &H1000      ' ListView messages
%TV_FIRST                                       = &H1100      ' TreeView messages
%HDM_FIRST                                      = &H1200      ' Header messages
%NM_CLICK                                       = (%NM_FIRST-2)
%NM_DBLCLK                                      = (%NM_FIRST-3)
%NM_SETFOCUS                                    = (%NM_FIRST-7)
%NM_KILLFOCUS                                   = (%NM_FIRST-8)
%NM_CUSTOMDRAW                                  = %NM_FIRST - 12
%CDRF_NEWFONT                                   = &H00000002
%CDRF_NOTIFYITEMDRAW                            = &H00000020
%CDRF_NOTIFYSUBITEMDRAW                         = &H00000020  ' flags are the same, we can distinguish by context
%CDDS_PREPAINT                                  = &H00000001
%CDDS_ITEM                                      = &H00010000
%CDDS_ITEMPREPAINT                              = (%CDDS_ITEM OR %CDDS_PREPAINT)
%CDIS_SELECTED                                  = &H0001
%CDIS_GRAYED                                    = &H0002
%CDIS_DISABLED                                  = &H0004
%CDIS_CHECKED                                   = &H0008
%CDIS_FOCUS                                     = &H0010
%CDIS_DEFAULT                                   = &H0020
%CDIS_HOT                                       = &H0040
%CDIS_MARKED                                    = &H0080
%CDIS_INDETERMINATE                             = &H0100
%TBCDRF_NOEDGES                                 = &H00010000 ' Don't draw button edges
%TBCDRF_HILITEHOTTRACK                          = &H00020000 ' Use color of the button bk when hottracked
%TBCDRF_NOOFFSET                                = &H00040000 ' Don't offset button if pressed
%TBCDRF_NOETCHEDEFFECT                          = &H00100000 ' Don't draw etched effect for disabled items
%CCS_TOP                                        = &H00000001&
%CCS_BOTTOM                                     = &H00000003&
%CCS_NORESIZE                                   = &H00000004&
%CCS_NOPARENTALIGN                              = &H00000008&
%CCS_ADJUSTABLE                                 = &H00000020&
%CCS_NODIVIDER                                  = &H00000040&
%CCM_FIRST                                      = &H2000
%CCM_SETBKCOLOR                                 = (%CCM_FIRST + 1) ' lParam is bkColor
%CCM_SETCOLORSCHEME                             = (%CCM_FIRST + 2) ' lParam is color scheme
%LVN_FIRST                                      = (0???-100???)       ' listview
%TVN_FIRST                                      = (0???-400???)       ' treeview
%TTN_FIRST                                      = (0???-520???)       ' tooltips
%TCN_FIRST                                      = (0???-550???)       ' tab control
%TBN_FIRST                                      = (0???-700???)      ' toolbar
%MCN_FIRST                                      = (0???-750???)       ' monthcal
%DTN_FIRST                                      = (0???-760???)       ' datetimepick
%PGN_FIRST                                      = (0???-900???)       ' Pager Control
%ICC_WIN95_CLASSES                              = &H000000FF
%RBIM_IMAGELIST                                 = &H00000001
%RBS_VARHEIGHT                                  = &H0200
%RBS_BANDBORDERS                                = &H0400
%RBS_FIXEDORDER                                 = &H0800
%RBS_AUTOSIZE                                   = &H2000
%RBBS_BREAK                                     = &H00000001  ' break to new line
%RBBS_FIXEDSIZE                                 = &H00000002  ' band can't be sized
%RBBS_CHILDEDGE                                 = &H00000004  ' edge around top & bottom of child window
%RBBS_HIDDEN                                    = &H00000008  ' don't show
%RBBS_VARIABLEHEIGHT                            = &H00000040  ' allow autosizing of this child vertically
%RBBS_GRIPPERALWAYS                             = &H00000080  ' always show the gripper
%RBBS_NOGRIPPER                                 = &H00000100  ' never show the gripper
%RBBIM_STYLE                                    = &H00000001
%RBBIM_COLORS                                   = &H00000002
%RBBIM_TEXT                                     = &H00000004
%RBBIM_IMAGE                                    = &H00000008
%RBBIM_CHILD                                    = &H00000010
%RBBIM_CHILDSIZE                                = &H00000020
%RBBIM_SIZE                                     = &H00000040
%RBBIM_BACKGROUND                               = &H00000080
%RBBIM_ID                                       = &H00000100
%RBBIM_IDEALSIZE                                = &H00000200
%RBBIM_HEADERSIZE                               = &H00000800  ' control the size of the header
%RB_INSERTBAND                                  = (%WM_USER +  1)
%RB_SETBARINFO                                  = (%WM_USER +  4)
%RB_GETBANDCOUNT                                = (%WM_USER +  12)
%RB_GETTOOLTIPS                                 = (%WM_USER +  17)
%RB_SETBKCOLOR                                  = (%WM_USER +  19) ' sets the default BK color
%RB_GETBKCOLOR                                  = (%WM_USER +  20) ' defaults to CLR_NONE
%RB_SETTEXTCOLOR                                = (%WM_USER +  21)
%RB_GETTEXTCOLOR                                = (%WM_USER +  22) ' defaults to &H00000000
%RB_MINIMIZEBAND                                = (%WM_USER + 30)
%RB_MAXIMIZEBAND                                = (%WM_USER + 31)
%RB_SHOWBAND                                    = (%WM_USER + 35)      ' show/hide band
%CLR_NONE                                       = &HFFFFFFFF&
%CLR_DEFAULT                                    = &HFF000000&
%ILC_MASK                                       = &H0001
%ILC_COLOR24                                    = &H0018
%ILCF_MOVE                                      = &H00000000
%ILD_TRANSPARENT                                = &H0001
%ILD_BLEND25                                    = &H0002
%ILD_BLEND50                                    = &H0004
%HDI_FORMAT                                     = &H0004
%HDF_OWNERDRAW                                  = &H8000
%HDM_GETITEMCOUNT                               = (%HDM_FIRST + 0)
%HDM_SETITEM                                    = (%HDM_FIRST + 4)
%TBSTATE_ENABLED                                = &H04
%TBSTATE_WRAP                                   = &H20
%TBSTYLE_BUTTON                                 = &H00
%TBSTYLE_SEP                                    = &H01
%TBSTYLE_CHECK                                  = &H02
%TBSTYLE_GROUP                                  = &H04
%TBSTYLE_DROPDOWN                               = &H0008
%BTNS_WHOLEDROPDOWN                             = &H0080          ' draw drop-down arrow, but without split arrow section
%TBSTYLE_TOOLTIPS                               = &H0100
%TBSTYLE_WRAPABLE                               = &H0200
%TBSTYLE_ALTDRAG                                = &H0400
%TBSTYLE_FLAT                                   = &H0800
%TBSTYLE_LIST                                   = &H1000
%TB_ENABLEBUTTON                                = %WM_USER + 1
%TB_CHECKBUTTON                                 = %WM_USER + 2
%TB_HIDEBUTTON                                  = %WM_USER + 4
%TB_ISBUTTONHIDDEN                              = %WM_USER + 12
%TB_ADDBITMAP                                   = %WM_USER + 19
%TB_ADDBUTTONS                                  = %WM_USER + 20
%TB_BUTTONCOUNT                                 = %WM_USER + 24
%TB_COMMANDTOINDEX                              = %WM_USER + 25
%TB_ADDSTRING                                   = %WM_USER + 28
%TB_GETITEMRECT                                 = %WM_USER + 29
%TB_BUTTONSTRUCTSIZE                            = %WM_USER + 30
%TB_SETBUTTONSIZE                               = %WM_USER + 31
%TB_SETBITMAPSIZE                               = %WM_USER + 32
%TB_AUTOSIZE                                    = %WM_USER + 33
%TB_GETTOOLTIPS                                 = %WM_USER + 35
%TB_GETROWS                                     = %WM_USER + 40
%TB_GETBUTTONTEXT                               = %WM_USER + 45
%TB_SETIMAGELIST                                = %WM_USER + 48
%TB_GETRECT                                     = %WM_USER + 51  ' wParam is the Cmd instead of index
%TB_SETHOTIMAGELIST                             = %WM_USER + 52
%TB_SETDISABLEDIMAGELIST                        = %WM_USER + 54
%TB_SETINSERTMARKCOLOR                          = %WM_USER + 88
%TB_GETINSERTMARKCOLOR                          = %WM_USER + 89
%TBIF_IMAGE                                     = &H00000001
%TBIF_STYLE                                     = &H00000008
%TBIF_LPARAM                                    = &H00000010
%TB_GETBUTTONINFO                               = %WM_USER + 65
%TB_SETBUTTONINFO                               = %WM_USER + 66
%HINST_COMMCTRL                                 = -1
%IDB_STD_SMALL_COLOR                            = 0
%IDB_STD_LARGE_COLOR                            = 1
%IDB_VIEW_SMALL_COLOR                           = 4
%IDB_VIEW_LARGE_COLOR                           = 5
%TBN_TOOLBARCHANGE                              = (%TBN_FIRST-8)
%TBN_DROPDOWN                                   = %TBN_FIRST - 10
%TTS_ALWAYSTIP                                  = &H01
%TTS_NOPREFIX                                   = &H02
%TTS_NOANIMATE                                  = &H10
%TTS_NOFADE                                     = &H20
%TTS_BALLOON                                    = &H40
%TTF_IDISHWND                                   = &H00000001
%TTF_SUBCLASS                                   = &H00000010
%TTF_TRANSPARENT                                = &H00000100
%TTM_ADDTOOL                                    = (%WM_USER +  4)
%TTM_GETCURRENTTOOL                             = (%WM_USER + 15)
%TTM_SETTIPBKCOLOR                              = (%WM_USER + 19)
%TTM_SETTIPTEXTCOLOR                            = (%WM_USER + 20)
%TTM_SETMAXTIPWIDTH                             = (%WM_USER + 24)
%TTM_UPDATE                                     = (%WM_USER + 29)
%TTN_NEEDTEXT                                   = (%TTN_FIRST - 0)
%SBARS_SIZEGRIP                                 = &H0100
%SB_SETTEXT                                     = (%WM_USER+1)
%SB_SETPARTS                                    = (%WM_USER+4)
%SB_SIMPLE                                      = (%WM_USER+9)
%SB_SETBKCOLOR                                  = %CCM_SETBKCOLOR  ' lParam = bkColor
%SBT_OWNERDRAW                                  = &H1000
%SBT_NOBORDERS                                  = &H0100
%SBT_POPOUT                                     = &H0200
%TBS_AUTOTICKS                                  = &H0001
%TBS_VERT                                       = &H0002
%TBS_HORZ                                       = &H0000
%TBS_LEFT                                       = &H0004
%TBS_BOTH                                       = &H0008
%TBS_NOTICKS                                    = &H0010
%TBS_FIXEDLENGTH                                = &H0040
%TBS_TOOLTIPS                                   = &H0100
%TBM_GETPOS                                     = (%WM_USER)
%TBM_GETRANGEMIN                                = (%WM_USER+1)
%TBM_GETRANGEMAX                                = (%WM_USER+2)
%TBM_SETPOS                                     = (%WM_USER+5)
%TBM_SETRANGEMIN                                = (%WM_USER+7)
%TBM_SETRANGEMAX                                = (%WM_USER+8)
%TBM_SETTICFREQ                                 = (%WM_USER+20)
%TBM_SETPAGESIZE                                = (%WM_USER+21)
%TBM_GETPAGESIZE                                = (%WM_USER+22)
%TBM_SETLINESIZE                                = (%WM_USER+23)
%TBM_GETLINESIZE                                = (%WM_USER+24)
%TBM_SETTHUMBLENGTH                             = (%WM_USER+27)
%TBM_GETTOOLTIPS                                = %WM_USER + 30
%DL_BEGINDRAG                                   = (%WM_USER+133)
%DL_DRAGGING                                    = (%WM_USER+134)
%DL_DROPPED                                     = (%WM_USER+135)
%DL_CANCELDRAG                                  = (%WM_USER+136)
%DL_STOPCURSOR                                  = 1
%DL_COPYCURSOR                                  = 2
%DL_MOVECURSOR                                  = 3
$DRAGLISTMSGSTRING                              = "commctrl_DragListMsg"
%UDM_SETBUDDY                                   = (%WM_USER+105)
%UDM_GETBUDDY                                   = (%WM_USER+106)
%UDM_SETRANGE32                                 = %WM_USER + 111
%UDM_SETPOS32                                   = %WM_USER + 113
%UDM_GETPOS32                                   = %WM_USER + 114
%PBM_SETRANGE                                   = (%WM_USER+1)
%PBM_SETPOS                                     = (%WM_USER+2)
%PBM_DELTAPOS                                   = (%WM_USER+3)
%PBM_SETRANGE32                                 = (%WM_USER+6)
%PBM_GETPOS                                     = %WM_USER + 8
%PBM_SETBARCOLOR                                = (%WM_USER+9)
%PBM_SETBKCOLOR                                 =  %CCM_SETBKCOLOR
%PBS_SMOOTH                                     = &H0001
%PBS_VERTICAL                                   = &H04
%LVS_ICON                                       = &H0000
%LVS_REPORT                                     = &H0001
%LVS_LIST                                       = &H0003
%LVS_SINGLESEL                                  = &H0004
%LVS_SHOWSELALWAYS                              = &H0008
%LVS_SHAREIMAGELISTS                            = &H0040
%LVS_EDITLABELS                                 = &H0200
%LVS_NOSCROLL                                   = &H2000
%LVS_ALIGNTOP                                   = &H0000
%LVS_ALIGNLEFT                                  = &H0800
%LVS_OWNERDRAWFIXED                             = &H0400
%LVS_NOCOLUMNHEADER                             = &H4000
%LVM_SETEXTENDEDLISTVIEWSTYLE                   = %LVM_FIRST + 54  ' optional wParam == mask
%LVM_GETEXTENDEDLISTVIEWSTYLE                   = %LVM_FIRST + 55
%LVS_EX_GRIDLINES                               = &H00000001
%LVS_EX_SUBITEMIMAGES                           = &H00000002
%LVS_EX_CHECKBOXES                              = &H00000004
%LVS_EX_HEADERDRAGDROP                          = &H00000010
%LVS_EX_FULLROWSELECT                           = &H00000020 ' applies to report mode only
%LVS_EX_MULTIWORKAREAS                          = &H00002000
%LVS_EX_LABELTIP                                = &H00004000 ' listview unfolds partly hidden labels if it does not have infotip text
%LVM_GETTOOLTIPS                                = %LVM_FIRST + 78
%LVM_GETHEADER                                  = %LVM_FIRST + 31
%LVM_GETBKCOLOR                                 = (%LVM_FIRST + 0)
%LVM_SETBKCOLOR                                 = (%LVM_FIRST + 1)
%LVM_GETIMAGELIST                               = (%LVM_FIRST + 2)
%LVSIL_NORMAL                                   = 0
%LVSIL_SMALL                                    = 1
%LVSIL_STATE                                    = 2
%LVM_SETIMAGELIST                               = (%LVM_FIRST + 3)
%LVM_GETITEMCOUNT                               = (%LVM_FIRST + 4)
%LVM_GETSUBITEMRECT                             = %LVM_FIRST + 56
%LVIF_TEXT                                      = &H0001
%LVIF_IMAGE                                     = &H0002
%LVIF_PARAM                                     = &H0004
%LVIF_STATE                                     = &H0008
%LVIS_FOCUSED                                   = &H0001
%LVIS_SELECTED                                  = &H0002
%LVIS_DROPHILITED                               = &H0008
%LVIS_STATEIMAGEMASK                            = &HF000
%LVM_GETITEM                                    = (%LVM_FIRST + 5)
%LVM_SETITEM                                    = (%LVM_FIRST + 6)
%LVM_INSERTITEM                                 = (%LVM_FIRST + 7)
%LVM_DELETEITEM                                 = (%LVM_FIRST + 8)
%LVM_DELETEALLITEMS                             = (%LVM_FIRST + 9)
%LVNI_SELECTED                                  = &H0002
%LVM_GETNEXTITEM                                = (%LVM_FIRST + 12)
%LVIR_BOUNDS                                    = 0
%LVM_GETITEMRECT                                = (%LVM_FIRST + 14)
%LVM_GETITEMPOSITION                            = (%LVM_FIRST + 16)
%LVM_HITTEST                                    = (%LVM_FIRST + 18)
%LVM_ENSUREVISIBLE                              = (%LVM_FIRST + 19)
%LVM_SCROLL                                     = (%LVM_FIRST + 20)
%LVM_EDITLABEL                                  = (%LVM_FIRST + 23)
%LVM_GETEDITCONTROL                             = (%LVM_FIRST + 24)
%LVCF_FMT                                       = &H0001
%LVCF_WIDTH                                     = &H0002
%LVCF_TEXT                                      = &H0004
%LVCF_SUBITEM                                   = &H0008
%LVCFMT_LEFT                                    = &H0000
%LVCFMT_RIGHT                                   = &H0001
%LVCFMT_CENTER                                  = &H0002
%LVM_SETCOLUMN                                  = (%LVM_FIRST + 26)
%LVM_INSERTCOLUMN                               = (%LVM_FIRST + 27)
%LVM_DELETECOLUMN                               = (%LVM_FIRST + 28)
%LVM_GETCOLUMNWIDTH                             = (%LVM_FIRST + 29)
%LVM_GETCOLUMNORDERARRAY                        = %LVM_FIRST + 59
%LVM_CREATEDRAGIMAGE                            = (%LVM_FIRST + 33)
%LVM_GETTEXTCOLOR                               = (%LVM_FIRST + 35)
%LVM_SETTEXTCOLOR                               = (%LVM_FIRST + 36)
%LVM_GETTEXTBKCOLOR                             = (%LVM_FIRST + 37)
%LVM_SETTEXTBKCOLOR                             = (%LVM_FIRST + 38)
%LVM_GETTOPINDEX                                = (%LVM_FIRST + 39)
%LVM_GETCOUNTPERPAGE                            = (%LVM_FIRST + 40)
%LVM_UPDATE                                     = (%LVM_FIRST + 42)
%LVM_SETITEMSTATE                               = (%LVM_FIRST + 43)
%LVM_GETITEMSTATE                               = (%LVM_FIRST + 44)
%LVM_SETITEMCOUNT                               = (%LVM_FIRST + 47)
%LVM_SORTITEMS                                  = (%LVM_FIRST + 48)
%LVM_GETSELECTEDCOUNT                           = (%LVM_FIRST + 50)
%LVM_GETSELECTIONMARK                           = %LVM_FIRST + 66
%LVM_SETSELECTIONMARK                           = %LVM_FIRST + 67
%LVN_ITEMCHANGING                               = (%LVN_FIRST-0)
%LVN_BEGINLABELEDIT                             = (%LVN_FIRST-5)
%LVN_ENDLABELEDIT                               = (%LVN_FIRST-6)
%LVN_COLUMNCLICK                                = (%LVN_FIRST-8)
%LVN_BEGINDRAG                                  = (%LVN_FIRST-9)
%LVN_BEGINRDRAG                                 = (%LVN_FIRST-11)
%TVS_HASBUTTONS                                 = &H0001
%TVS_HASLINES                                   = &H0002
%TVS_LINESATROOT                                = &H0004
%TVS_EDITLABELS                                 = &H0008
%TVS_DISABLEDRAGDROP                            = &H0010
%TVS_NOTOOLTIPS                                 = &H0080
%TVS_CHECKBOXES                                 = &H0100
%TVS_NOSCROLL                                   = &H2000
%TVIF_TEXT                                      = &H0001
%TVIF_IMAGE                                     = &H0002
%TVIF_PARAM                                     = &H0004
%TVIF_STATE                                     = &H0008
%TVIF_SELECTEDIMAGE                             = &H0020
%TVIF_CHILDREN                                  = &H0040
%TVIS_FOCUSED                                   = &H0001
%TVIS_SELECTED                                  = &H0002
%TVIS_CUT                                       = &H0004
%TVIS_DROPHILITED                               = &H0008
%TVIS_BOLD                                      = &H0010
%TVIS_EXPANDED                                  = &H0020
%TVIS_EXPANDEDONCE                              = &H0040
%TVIS_STATEIMAGEMASK                            = &HF000
%TVI_ROOT                                       = &HFFFF0000&
%TVI_LAST                                       = &HFFFF0002&
%TVM_GETTOOLTIPS                                = (%TV_FIRST + 25)
%TVM_INSERTITEM                                 = (%TV_FIRST + 0)
%TVM_DELETEITEM                                 = (%TV_FIRST + 1)
%TVM_EXPAND                                     = (%TV_FIRST + 2)
%TVE_COLLAPSE                                   = &H0001
%TVE_EXPAND                                     = &H0002
%TVE_COLLAPSERESET                              = &H8000
%TVM_GETCOUNT                                   = (%TV_FIRST + 5)
%TVM_GETINDENT                                  = (%TV_FIRST + 6)
%TVM_SETINDENT                                  = (%TV_FIRST + 7)
%TVM_GETIMAGELIST                               = (%TV_FIRST + 8)
%TVSIL_NORMAL                                   = 0
%TVSIL_STATE                                    = 2
%TVM_SETIMAGELIST                               = (%TV_FIRST + 9)
%TVM_GETNEXTITEM                                = (%TV_FIRST + 10)
%TVGN_ROOT                                      = &H0000
%TVGN_NEXT                                      = &H0001
%TVGN_PREVIOUS                                  = &H0002
%TVGN_PARENT                                    = &H0003
%TVGN_CHILD                                     = &H0004
%TVGN_FIRSTVISIBLE                              = &H0005
%TVGN_NEXTVISIBLE                               = &H0006
%TVGN_PREVIOUSVISIBLE                           = &H0007
%TVGN_CARET                                     = &H0009
%TVGN_LASTVISIBLE                               = &H000A
%TVM_SELECTITEM                                 = (%TV_FIRST + 11)
%TVM_GETITEM                                    = (%TV_FIRST + 12)
%TVM_SETITEM                                    = (%TV_FIRST + 13)
%TVM_EDITLABEL                                  = (%TV_FIRST + 14)
%TVM_GETEDITCONTROL                             = (%TV_FIRST + 15)
%TVM_GETVISIBLECOUNT                            = (%TV_FIRST + 16)
%TVM_GETBKCOLOR                                 = %TV_FIRST + 31
%TVM_GETTEXTCOLOR                               = %TV_FIRST + 32
%TVM_GETLINECOLOR                               = %TV_FIRST + 41
%TVM_GETITEMHEIGHT                              = %TV_FIRST + 28
%TVM_SETITEMHEIGHT                              = %TV_FIRST + 27
%TVM_GETINSERTMARKCOLOR                         = %TV_FIRST + 38
%TVM_SETBKCOLOR                                 = %TV_FIRST + 29
%TVM_SETTEXTCOLOR                               = %TV_FIRST + 30
%TVM_SETLINECOLOR                               = %TV_FIRST + 40
%TVM_SETINSERTMARKCOLOR                         = %TV_FIRST + 37
%TVM_HITTEST                                    = (%TV_FIRST + 17)
%TVM_CREATEDRAGIMAGE                            = (%TV_FIRST + 18)
%TVM_SORTCHILDREN                               = (%TV_FIRST + 19)
%TVM_ENSUREVISIBLE                              = (%TV_FIRST + 20)
%TVM_ENDEDITLABELNOW                            = (%TV_FIRST + 22)
%TVN_SELCHANGING                                = (%TVN_FIRST-1)
%TVN_ITEMEXPANDING                              = (%TVN_FIRST-5)
%TVN_BEGINDRAG                                  = (%TVN_FIRST-7)
%TVN_BEGINRDRAG                                 = (%TVN_FIRST-8)
%TVN_BEGINLABELEDIT                             = (%TVN_FIRST-10)
%TVN_ENDLABELEDIT                               = (%TVN_FIRST-11)
%TCS_BOTTOM                                     = &H0002
%TCS_RIGHT                                      = &H0002
%TCS_FLATBUTTONS                                = &H0008
%TCS_FORCEICONLEFT                              = &H0010
%TCS_VERTICAL                                   = &H0080
%TCS_BUTTONS                                    = &H0100
%TCS_MULTILINE                                  = &H0200
%TCS_FIXEDWIDTH                                 = &H0400
%TCS_FOCUSONBUTTONDOWN                          = &H1000
%TCS_OWNERDRAWFIXED                             = &H2000
%TCS_TOOLTIPS                                   = &H4000
%TCM_FIRST                                      = &H1300
%TCM_SETMINTABWIDTH                             = %TCM_FIRST + 49
%TCM_GETIMAGELIST                               = (%TCM_FIRST + 2)
%TCM_SETIMAGELIST                               = (%TCM_FIRST + 3)
%TCM_GETITEMCOUNT                               = (%TCM_FIRST + 4)
%TCIF_TEXT                                      = &H0001
%TCIF_IMAGE                                     = &H0002
%TCM_SETITEM                                    = (%TCM_FIRST + 6)
%TCM_INSERTITEM                                 = (%TCM_FIRST + 7)
%TCM_DELETEITEM                                 = (%TCM_FIRST + 8)
%TCM_DELETEALLITEMS                             = (%TCM_FIRST + 9)
%TCM_GETITEMRECT                                = (%TCM_FIRST + 10)
%TCM_GETCURSEL                                  = (%TCM_FIRST + 11)
%TCM_SETCURSEL                                  = (%TCM_FIRST + 12)
%TCM_SETITEMSIZE                                = (%TCM_FIRST + 41)
%TCM_GETROWCOUNT                                = (%TCM_FIRST + 44)
%TCM_GETTOOLTIPS                                = (%TCM_FIRST + 45)
%TCM_GETCURFOCUS                                = (%TCM_FIRST + 47)
%TCM_SETCURFOCUS                                = (%TCM_FIRST + 48)
%TCN_SELCHANGE                                  = (%TCN_FIRST - 1)
%TCN_SELCHANGING                                = (%TCN_FIRST - 2)
%ACS_CENTER                                     = &H0001
%ACS_TRANSPARENT                                = &H0002
%ACS_AUTOPLAY                                   = &H0004
%ACM_OPEN                                       = (%WM_USER+100)
%ACM_PLAY                                       = (%WM_USER+101)
%ACM_STOP                                       = (%WM_USER+102)
%MCM_FIRST                                      = &H1000
%MCM_GETCURSEL                                  = %MCM_FIRST + 1
%MCM_SETCURSEL                                  = %MCM_FIRST + 2
%MCM_GETSELRANGE                                = %MCM_FIRST + 5
%MCM_SETSELRANGE                                = %MCM_FIRST + 6
%MCM_SETCOLOR                                   = %MCM_FIRST + 10
%MCM_GETCOLOR                                   = %MCM_FIRST + 11
%MCSC_BACKGROUND                                = 0   ' the background color (between months)
%MCSC_TITLETEXT                                 = 3
%MCSC_MONTHBK                                   = 4   ' background within the month cal
%MCSC_TRAILINGTEXT                              = 5   ' the text color of header & trailing days
%MCM_SETFIRSTDAYOFWEEK                          = %MCM_FIRST + 15
%MCM_GETFIRSTDAYOFWEEK                          = %MCM_FIRST + 16
%MCM_GETRANGE                                   = %MCM_FIRST + 17
%MCM_SETRANGE                                   = %MCM_FIRST + 18
%MCN_SELCHANGE                                  = %MCN_FIRST + 1
%MCS_DAYSTATE                                   = &H0001
%MCS_MULTISELECT                                = &H0002
%MCS_WEEKNUMBERS                                = &H0004
%MCS_NOTODAYCIRCLE                              = &H0008
%MCS_NOTODAY                                    = &H0010
%DTM_FIRST                                      = &H1000
%DTM_GETSYSTEMTIME                              = %DTM_FIRST + 1
%DTM_SETSYSTEMTIME                              = %DTM_FIRST + 2
%DTM_SETRANGE                                   = %DTM_FIRST + 4
%DTM_SETFORMAT                                  = %DTM_FIRST + 5
%DTM_SETMCCOLOR                                 = %DTM_FIRST + 6
%DTM_GETMCCOLOR                                 = %DTM_FIRST + 7
%DTS_UPDOWN                                     = &H0001 ' use UPDOWN instead of MONTHCAL
%DTS_SHOWNONE                                   = &H0002 ' allow a NONE selection
%DTS_SHORTDATEFORMAT                            = &H0000 ' use the short date format (app must forward WM_WININICHANGE messages)
%DTS_LONGDATEFORMAT                             = &H0004 ' use the long date format (app must forward WM_WININICHANGE messages)
%DTS_SHORTDATECENTURYFORMAT                     = &H000C ' short date format with century (app must forward WM_WININICHANGE messages)
%DTS_TIMEFORMAT                                 = &H0009 ' use the time format (app must forward WM_WININICHANGE messages)
%DTN_DATETIMECHANGE                             = %DTN_FIRST + 1 ' the systemtime has changed
%GDTR_MIN                                       = &H0001
%GDTR_MAX                                       = &H0002
%GDT_VALID                                      = 0
%GDT_NONE                                       = 1
%MCSC_TEXT                                      = 1   ' the dates
%MCSC_TITLEBK                                   = 2   ' background of the title
%PGS_VERT                                       = &H00000000
%PGS_HORZ                                       = &H00000001
%PGS_AUTOSCROLL                                 = &H00000002
%PGM_FIRST                                      = &H1400      ' Pager control messages
%PGM_SETCHILD                                   = %PGM_FIRST + 1  ' lParam == hwnd
%PGM_RECALCSIZE                                 = %PGM_FIRST + 2
%PGM_SETBKCOLOR                                 = %PGM_FIRST + 4
%PGM_GETBKCOLOR                                 = %PGM_FIRST + 5
%PGM_SETBORDER                                  = %PGM_FIRST + 6
%PGM_GETBORDER                                  = %PGM_FIRST + 7
%PGM_SETPOS                                     = %PGM_FIRST + 8
%PGM_GETPOS                                     = %PGM_FIRST + 9
%PGM_SETBUTTONSIZE                              = %PGM_FIRST + 10
%PGM_GETBUTTONSIZE                              = %PGM_FIRST + 11
%PGN_SCROLL                                     = %PGN_FIRST - 1
%PGN_CALCSIZE                                   = %PGN_FIRST - 2
%PGF_CALCWIDTH                                  = 1
%PGF_CALCHEIGHT                                 = 2
%CC_RGBINIT                                     = &H00000001&
%CC_FULLOPEN                                    = &H00000002&
%CC_PREVENTFULLOPEN                             = &H00000004&
%CC_ENABLEHOOK                                  = &H00000010&
%FR_DOWN                                        = &H00000001&
%FR_WHOLEWORD                                   = &H00000002&
%FR_MATCHCASE                                   = &H00000004&
%FR_FINDNEXT                                    = &H00000008&
%FR_REPLACE                                     = &H00000010&
%FR_REPLACEALL                                  = &H00000020&
%FR_DIALOGTERM                                  = &H00000040&
%FR_ENABLEHOOK                                  = &H00000100&
%FR_NOUPDOWN                                    = &H00000400&
%FR_NOMATCHCASE                                 = &H00000800&
%FR_NOWHOLEWORD                                 = &H00001000&
%FR_HIDEUPDOWN                                  = &H00004000&
%FR_HIDEMATCHCASE                               = &H00008000&
%FR_HIDEWHOLEWORD                               = &H00010000&
%CF_SCREENFONTS                                 = &H00000001&
%CF_PRINTERFONTS                                = &H00000002&
%CF_BOTH                                        = %CF_SCREENFONTS + %CF_PRINTERFONTS
%CF_ENABLEHOOK                                  = &H00000008&
%CF_INITTOLOGFONTSTRUCT                         = &H00000040&
%CF_EFFECTS                                     = &H00000100&
%CF_LIMITSIZE                                   = &H00002000&
%CF_FIXEDPITCHONLY                              = &H00004000&
%CF_TTONLY                                      = &H00040000&
$FINDMSGSTRING                                  = "commdlg_FindReplace"
%PD_ALLPAGES                                    = &H00000000&
%PD_SELECTION                                   = &H00000001&
%PD_PAGENUMS                                    = &H00000002&
%PD_NOSELECTION                                 = &H00000004&
%PD_NOPAGENUMS                                  = &H00000008&
%PD_COLLATE                                     = &H00000010&
%PD_RETURNDC                                    = &H00000100&
%PD_RETURNDEFAULT                               = &H00000400&
%PD_ENABLEPRINTHOOK                             = &H00001000&
%PD_HIDEPRINTTOFILE                             = &H00100000&
%OFN_OVERWRITEPROMPT                            = &H00000002???
%OFN_HIDEREADONLY                               = &H00000004???
%OFN_NOCHANGEDIR                                = &H00000008???
%OFN_ENABLEHOOK                                 = &H00000020???
%OFN_ALLOWMULTISELECT                           = &H00000200???
%OFN_PATHMUSTEXIST                              = &H00000800???
%OFN_FILEMUSTEXIST                              = &H00001000???
%OFN_CREATEPROMPT                               = &H00002000???
%OFN_NOREADONLYRETURN                           = &H00008000???
%OFN_EXPLORER                                   = &H00080000??? ' new look commdlg
%OFN_LONGNAMES                                  = &H00200000??? ' force long names for 3.x modules
%OFN_ENABLESIZING                               = &H00800000???
%CDN_INITDONE                                   = -601
%EM_EXGETSEL                                    = (%WM_USER + 52)
%EM_EXLIMITTEXT                                 = (%WM_USER + 53)
%EM_EXSETSEL                                    = (%WM_USER + 55)
%EM_FORMATRANGE                                 = (%WM_USER + 57)
%EM_GETCHARFORMAT                               = (%WM_USER + 58)
%EM_GETEVENTMASK                                = (%WM_USER + 59)
%EM_GETPARAFORMAT                               = (%WM_USER + 61)
%EM_HIDESELECTION                               = (%WM_USER + 63)
%EM_SETBKGNDCOLOR                               = (%WM_USER + 67)
%EM_SETCHARFORMAT                               = (%WM_USER + 68)
%EM_SETEVENTMASK                                = (%WM_USER + 69)
%EM_SETPARAFORMAT                               = (%WM_USER + 71)
%EM_STREAMIN                                    = (%WM_USER + 73)
%EM_STREAMOUT                                   = (%WM_USER + 74)
%EM_AUTOURLDETECT                               = %WM_USER + 91
%EN_LINK                                        = &H070b
%ENM_CHANGE                                     = &H00000001
%ENM_LINK                                       = &H04000000
%ES_DISABLENOSCROLL                             = &H00002000
%ES_SELECTIONBAR                                = &H01000000
%CFM_BOLD                                       = &H00000001
%CFM_ITALIC                                     = &H00000002
%CFM_UNDERLINE                                  = &H00000004
%CFM_STRIKEOUT                                  = &H00000008
%CFM_SIZE                                       = &H80000000
%CFM_COLOR                                      = &H40000000
%CFM_FACE                                       = &H20000000
%CFM_OFFSET                                     = &H10000000
%CFM_CHARSET                                    = &H08000000
%CFM_LINK                                       = &H00000020    ' Exchange hyperlink extension
%CFM_BACKCOLOR                                  = &H04000000
%CFM_WEIGHT                                     = &H00400000
%CFM_DISABLED                                   = &H2000
%CFM_UNDERLINETYPE                              = &H00800000
%CFE_BOLD                                       = &H0001
%CFE_ITALIC                                     = &H0002
%CFE_UNDERLINE                                  = &H0004
%CFE_STRIKEOUT                                  = &H0008
%CFE_LINK                                       = &H0020
%CFE_AUTOBACKCOLOR                              = %CFM_BACKCOLOR
%CFE_AUTOCOLOR                                  = &H40000000
%SCF_SELECTION                                  = &H0001
%SCF_WORD                                       = &H0002
%SCF_DEFAULT                                    = &H0000    ' Set default charformat or paraformat
%SCF_ALL                                        = &H0004    ' Not valid with SCF_SELECTION or SCF_WORD
%SF_TEXT                                        = &H0001
%SF_RTF                                         = &H0002
%SFF_SELECTION                                  = &H8000
%MAX_TAB_STOPS                                  = 32
%PFM_STARTINDENT                                = &H00000001
%PFM_RIGHTINDENT                                = &H00000002
%PFM_OFFSET                                     = &H00000004
%PFM_ALIGNMENT                                  = &H00000008
%PFM_TABSTOPS                                   = &H00000010
%PFM_NUMBERING                                  = &H00000020
%PFN_BULLET                                     = &H0001
%PFA_LEFT                                       = &H0001
%PFA_RIGHT                                      = &H0002
%PFA_CENTER                                     = &H0003

'-----------------------------------------------------------------
' TYPE and UNION structures:  85
'-----------------------------------------------------------------
TYPE RECT
  nLeft AS LONG
  nTop AS LONG
  nRight AS LONG
  nBottom AS LONG
END TYPE

TYPE POINTAPI
  x AS LONG
  y AS LONG
END TYPE

TYPE tagMSG
  hwnd AS DWORD
  message AS DWORD
  wParam AS DWORD
  lParam AS DWORD
  time AS DWORD
  pt AS POINTAPI
END TYPE

TYPE SECURITY_ATTRIBUTES
  nLength AS LONG
  lpSecurityDescriptor AS LONG
  bInheritHandle AS LONG
END TYPE

TYPE SYSTEMTIME
  wYear AS INTEGER
  wMonth AS INTEGER
  wDayOfWeek AS INTEGER
  wDay AS INTEGER
  wHour AS INTEGER
  wMinute AS INTEGER
  wSecond AS INTEGER
  wMilliseconds AS INTEGER
END TYPE

TYPE TPMPARAMS
  cbSize AS LONG
  rcExclude AS Rect
END TYPE

TYPE WNDCLASSEX
  cbSize AS LONG
  STYLE AS LONG
  lpfnWndProc AS LONG
  cbClsExtra AS LONG
  cbWndExtra AS LONG
  hInstance AS LONG
  hIcon AS LONG
  hCursor AS LONG
  hbrBackground AS LONG
  lpszMenuName AS ASCIIZ PTR
  lpszClassName AS ASCIIZ PTR
  hIconSm AS LONG
END TYPE

TYPE CRITICAL_SECTION
  dummy AS STRING * 24
END TYPE

TYPE XFORM
  eM11 AS SINGLE
  eM12 AS SINGLE
  eM21 AS SINGLE
  eM22 AS SINGLE
  eDx AS SINGLE
  eDy AS SINGLE
END TYPE

TYPE BITMAP                             '14 bytes
  bmType AS LONG
  bmWidth AS LONG
  bmHeight AS LONG
  bmWidthBytes AS LONG
  bmPlanes AS INTEGER
  bmBitsPixel AS INTEGER
  bmBits AS LONG
END TYPE

TYPE RGBQUAD
  rgbBlue AS BYTE
  rgbGreen AS BYTE
  rgbRed AS BYTE
  rgbReserved AS BYTE
END TYPE

TYPE BITMAPINFOHEADER                   '40 bytes
  biSize AS LONG
  biWidth AS LONG
  biHeight AS LONG
  biPlanes AS INTEGER
  biBitCount AS INTEGER
  biCompression AS LONG
  biSizeImage AS LONG
  biXPelsPerMeter AS LONG
  biYPelsPerMeter AS LONG
  biClrUsed AS LONG
  biClrImportant AS LONG
END TYPE

TYPE BITMAPINFO
  bmiHeader AS BITMAPINFOHEADER
  bmiColors(256) AS RGBQUAD
END TYPE

TYPE SIZEL
  cx AS LONG
  cy AS LONG
END TYPE

TYPE FONTSIGNATURE
  fsUsb0 AS DWORD
  fsUsb1 AS DWORD
  fsUsb2 AS DWORD
  fsUsb3 AS DWORD
  fsCsb0 AS DWORD
  fsCsb1 AS DWORD
END TYPE

TYPE NEWTEXTMETRICEX_SAFE
  tmHeight AS LONG
  tmAscent AS LONG
  tmDescent AS LONG
  tmInternalLeading AS LONG
  tmExternalLeading AS LONG
  tmAveCharWidth AS LONG
  tmMaxCharWidth AS LONG
  tmWeight AS LONG
  tmOverhang AS LONG
  tmDigitizedAspectX AS LONG
  tmDigitizedAspectY AS LONG
  tmFirstChar AS BYTE
  tmLastChar AS BYTE
  tmDefaultChar AS BYTE
  tmBreakChar AS BYTE
  tmItalic AS BYTE
  tmUnderlined AS BYTE
  tmStruckOut AS BYTE
  tmPitchAndFamily AS BYTE
  tmCharSet AS BYTE
  ntmFlags AS DWORD
  ntmSizeEM AS DWORD
  ntmCellHeight AS DWORD
  ntmAveWidth AS DWORD
  ntmFontSig AS FONTSIGNATURE
END TYPE

TYPE LOGBRUSH
  lbStyle AS LONG
  lbColor AS LONG
  lbHatch AS LONG
END TYPE

TYPE LOGFONT
  lfHeight AS LONG
  lfWidth AS LONG
  lfEscapement AS LONG
  lfOrientation AS LONG
  lfWeight AS LONG
  lfItalic AS BYTE
  lfUnderline AS BYTE
  lfStrikeOut AS BYTE
  lfCharSet AS BYTE
  lfOutPrecision AS BYTE
  lfClipPrecision AS BYTE
  lfQuality AS BYTE
  lfPitchAndFamily AS BYTE
  lfFaceName AS ASCIIZ * 32 '(%LF_FACESIZE) AS BYTE
END TYPE

TYPE DEVMODE
  dmDeviceName AS ASCIIZ * %CCHDEVICENAME
  dmSpecVersion AS WORD
  dmDriverVersion AS WORD
  dmSize AS WORD
  dmDriverExtra AS WORD
  dmFields AS DWORD
  dmOrientation AS INTEGER
  dmPaperSize AS INTEGER
  dmPaperLength AS INTEGER
  dmPaperWidth AS INTEGER
  dmScale AS INTEGER
  dmCopies AS INTEGER
  dmDefaultSource AS INTEGER
  dmPrintQuality AS INTEGER
  dmColor AS INTEGER
  dmDuplex AS INTEGER
  dmYResolution AS INTEGER
  dmTTOption AS INTEGER
  dmCollate AS INTEGER
  dmFormName AS ASCIIZ * %CCHFORMNAME
  dmLogPixels AS WORD
  dmBitsPerPel AS DWORD
  dmPelsWidth AS LONG
  dmPelsHeight AS LONG
  dmDisplayFlags AS LONG
  dmDisplayFrequency AS LONG
END TYPE

TYPE RGNDATAHEADER
  dwSize AS LONG
  iType AS LONG
  nCount AS LONG
  nRgnSize AS LONG
  rcBound AS Rect
END TYPE

TYPE RGNDATA
  rdh AS RGNDATAHEADER
  Buffer AS BYTE
END TYPE

TYPE DOCINFO
  cbSize AS LONG
  lpszDocName AS ASCIIZ PTR
  lpszOutput AS ASCIIZ PTR
  lpszpDataType AS ASCIIZ PTR
  fwType AS DWORD
END TYPE

TYPE MINMAXINFO
  ptReserved AS POINTAPI
  ptMaxSize AS POINTAPI
  ptMaxPosition AS POINTAPI
  ptMinTrackSize AS POINTAPI
  ptMaxTrackSize AS POINTAPI
END TYPE

TYPE WINDOWPOS
  hwnd AS LONG
  hWndInsertAfter AS LONG
  x AS LONG
  y AS LONG
  cx AS LONG
  cy AS LONG
  flags AS LONG
END TYPE

TYPE ACCEL_API
  fVirt AS INTEGER
  key AS INTEGER
  cmd AS INTEGER
END TYPE

TYPE PAINTSTRUCT
  hdc AS LONG
  fErase AS LONG
  rcPaint AS Rect
  fRestore AS LONG
  fIncUpdate AS LONG
  rgbReserved(1 TO 32) AS BYTE
END TYPE

TYPE MEASUREITEMSTRUCT
  CtlType AS LONG
  CtlID AS LONG
  itemID AS LONG
  itemWidth AS LONG
  itemHeight AS LONG
  itemData AS LONG
END TYPE

TYPE DRAWITEMSTRUCT
  CtlType AS LONG
  CtlID AS LONG
  itemID AS LONG
  itemAction AS LONG
  itemState AS LONG
  hwndItem AS LONG
  hdc AS LONG
  rcItem AS Rect
  itemData AS LONG
END TYPE

TYPE COMPAREITEMSTRUCT
  CtlType AS LONG
  CtlID AS LONG
  hwndItem AS LONG
  itemID1 AS LONG
  itemData1 AS LONG
  itemID2 AS LONG
  itemData2 AS LONG
  dwLocalID AS DWORD
END TYPE

TYPE DlgTemplate        ' extended version
     dlgver        AS WORD     ' set to 1     :older API docs reverse
     signature     AS WORD     ' set to &FFFF :meaning of first two members
     helpid        AS DWORD
     ExtendedStyle AS DWORD
     STYLE         AS DWORD
     NumberOfItems AS WORD
     x             AS WORD
     y             AS WORD
     cx            AS WORD
     cy            AS WORD
END TYPE

TYPE CLIENTCREATESTRUCT
  hWindowMenu AS LONG
  idFirstChild AS LONG
END TYPE

TYPE PRINTER_INFO_4
  pPrinterName AS ASCIIZ PTR
  pServerName AS ASCIIZ PTR
  Attributes AS LONG
END TYPE

TYPE PRINTER_INFO_5
  pPrinterName AS ASCIIZ PTR
  pPortName AS ASCIIZ PTR
  Attributes AS DWORD
  DeviceNotSelected AS DWORD
  TransmissionRetryTimeout AS DWORD
END TYPE

TYPE NOTIFYICONDATA
  cbSize AS LONG
  hwnd AS LONG
  uID AS LONG
  uFlags AS LONG
  uCallbackMessage AS LONG
  hIcon AS LONG
  szTip AS ASCIIZ * 64
END TYPE

TYPE NOTIFYICONDATA5
  cbSize AS LONG
  hwnd AS LONG
  uID AS LONG
  uFlags AS LONG
  uCallbackMessage AS LONG
  hIcon AS LONG
  szTip AS ASCIIZ * 128     ' 64 extra bytes than standard structure
  dwState AS DWORD
  dwStateMask AS DWORD
  szInfo AS ASCIIZ *256
  uTimeout AS DWORD
  szInfoTitle AS ASCIIZ*64
  dwInfoFlags AS DWORD
END TYPE

TYPE SHFILEINFO
  hIcon AS LONG                         'out: icon
  iIcon AS LONG                         'out: icon index
  dwAttributes AS LONG                  'out: SFGAO_ flags
  szDisplayName AS ASCIIZ * %MAX_PATH   'out: display name (or path)
  szTypeName AS ASCIIZ * 80             'out: type name
END TYPE

TYPE HELPINFO
  cbSize AS LONG
  iContextType AS LONG
  iCtrlId AS LONG
  hItemHandle AS LONG
  dwContextId AS LONG
  MousePos AS POINTAPI
END TYPE

TYPE OSVERSIONINFO
  dwOSVersionInfoSize AS LONG
  dwMajorVersion AS LONG
  dwMinorVersion AS LONG
  dwBuildNumber AS LONG
  dwPlatformId AS LONG
  szCSDVersion AS ASCIIZ * 128          'Maintenance string for PSS usage
END TYPE

TYPE NMHDR
  hwndFrom AS LONG
  idfrom AS LONG
  CODE AS LONG
END TYPE

TYPE MENUITEMINFO
  cbSize AS LONG
  fMask AS LONG
  fType AS LONG
  fState AS LONG
  wID AS LONG
  hSubMenu AS LONG
  hbmpChecked AS LONG
  hbmpUnchecked AS LONG
  dwItemData AS LONG
  dwTypeData AS ASCIIZ PTR
  cch AS LONG
END TYPE

TYPE SCROLLINFO
  cbSize AS LONG
  fMask AS LONG
  nMin AS LONG
  nMax AS LONG
  nPage AS LONG
  nPos AS LONG
  nTrackPos AS LONG
END TYPE

TYPE MSGBOXPARAMS
  cbSize AS LONG
  hwndOwner AS LONG
  hInstance AS LONG
  lpszText AS ASCIIZ PTR
  lpszCaption AS ASCIIZ PTR
  dwStyle AS LONG
  lpszIcon AS ASCIIZ PTR
  dwContextHelpId AS LONG
  lpfnMsgBoxCallback AS LONG
  dwLanguageId AS LONG
END TYPE

TYPE TOOLTIPTEXT
  hdr AS NMHDR
  lpszText AS ASCIIZ PTR
  szText AS ASCIIZ * 80
  hinst AS LONG
  uFlags AS WORD
END TYPE

TYPE ShortItemId
  cb   AS LONG
  abID AS BYTE
END TYPE

TYPE ITEMIDLIST
  mkid AS ShortItemId
END TYPE

TYPE BROWSEINFO
  hWndOwner      AS DWORD
  pIDLRoot       AS DWORD
  pszDisplayName AS ASCIIZ PTR
  lpszTitle      AS ASCIIZ PTR
  ulFlags        AS DWORD
  lpfnCallback   AS DWORD
  lParam         AS LONG
  iImage         AS LONG
END TYPE

TYPE INIT_COMMON_CONTROLSEX
  dwSize AS LONG
  dwICC  AS LONG
END TYPE

TYPE NMCUSTOMDRAW
    hdr         AS NMHDR
    dwDrawStage AS DWORD
    hdc         AS DWORD
    rc          AS RECT
    dwItemSpec  AS DWORD  ' this is control specific, but it's how to specify an item. valid only with CDDS_ITEM bit set
    uItemState  AS DWORD
    lItemlParam AS LONG
END TYPE

TYPE NMTBCUSTOMDRAW
    nmcd                 AS NMCUSTOMDRAW
    hbrMonoDither        AS DWORD
    hbrLines             AS DWORD  ' For drawing lines on buttons
    hpenLines            AS DWORD  ' For drawing lines on buttons
    clrText              AS DWORD  ' Color of text
    clrMark              AS DWORD  ' Color of text bk when marked (only if TBSTATE_MARKED)
    clrTextHighlight     AS DWORD  ' Color of text when highlighted
    clrBtnFace           AS DWORD  ' Background of the button
    clrBtnHighlight      AS DWORD  ' 3D highlight
    clrHighlightHotTrack AS DWORD  ' In conjunction with fHighlightHotTrack,
    rcText               AS RECT   ' will cause button to highlight like a menu
    nStringBkMode        AS LONG   ' Rect for text
    nHLStringBkMode      AS LONG
END TYPE

TYPE NMLVCUSTOMDRAW
    nmcd AS NMCUSTOMDRAW
    clrText AS DWORD
    clrTextBk AS DWORD
    iSubItem AS LONG
END TYPE

TYPE NMTVCUSTOMDRAW
    nmcd      AS NMCUSTOMDRAW
    clrText   AS DWORD
    clrTextBk AS DWORD
    iLevel    AS LONG
END TYPE

TYPE REBARINFO
  cbSize AS LONG
  fMask AS LONG
  himl AS LONG
END TYPE

TYPE REBARBANDINFO
  cbSize AS LONG
  fMask AS LONG
  fStyle AS LONG
  clrFore AS LONG
  clrBack AS LONG
  lpText AS ASCIIZ PTR
  cch AS LONG
  iImage AS LONG
  hWndChild AS LONG
  cxMinChild AS LONG
  cyMinChild AS LONG
  cx AS LONG
  hbmBack AS LONG
  wID AS LONG
  cyChild AS LONG
  cyMaxChild AS LONG
  cyIntegral AS LONG
  cxIdeal AS LONG
  lParam AS LONG
  cxHeader AS LONG
END TYPE

TYPE HD_ITEM
  Mask          AS DWORD
  cxy           AS LONG
  pszText       AS ASCIIZ PTR
  hbm           AS LONG
  cchTextMax    AS LONG
  fmt           AS LONG
  lParam        AS LONG
END TYPE

TYPE TBBUTTON
  iBitmap AS LONG
  idCommand AS LONG
  fsState AS BYTE
  fsStyle AS BYTE
  bReserved(1 TO 2) AS BYTE
  dwData AS DWORD
  iString AS LONG
END TYPE

TYPE TBBUTTONINFO
    cbSize AS DWORD
    dwMask AS DWORD
    idCommand AS LONG
    iImage AS LONG
    fsState AS BYTE
    fsStyle AS BYTE
    cx AS WORD
    lParam AS DWORD
    pszText AS ASCIIZ PTR
    cchText AS LONG
END TYPE

TYPE tagTBADDBITMAP
  hInst         AS DWORD
  nId           AS DWORD
END TYPE

TYPE NMTOOLBAR
    hdr       AS NMHDR
    iItem     AS LONG
    tbButton  AS TBBUTTON
    cchText   AS LONG
    pszText   AS ASCIIZ PTR
    rcButton  AS RECT
END TYPE

TYPE TOOLINFO5
  cbSize            AS DWORD
  uFlags            AS DWORD
  hWnd              AS LONG
  uId               AS DWORD
  rect              AS RECT
  hInst             AS LONG
  lpszText          AS ASCIIZ PTR
  lParam            AS LONG
  lpReserved        AS LONG PTR ' only for Windows XP, otherwise make structure 4 bytes smaller
END TYPE

TYPE DRAGLISTINFO
  uNotification AS DWORD
  hWnd AS LONG
  ptCursor AS POINTAPI
END TYPE

TYPE LV_ITEM
  mask AS DWORD
  iItem AS LONG
  iSubItem AS LONG
  STATE AS DWORD
  stateMask AS DWORD
  pszText AS ASCIIZ PTR
  cchTextMax AS LONG
  iImage AS LONG
  lParam AS LONG
END TYPE

TYPE LV_HITTESTINFO
  pt AS POINTAPI
  flags AS DWORD
  iItem AS LONG
END TYPE

TYPE LV_COLUMN
  mask AS DWORD
  fmt AS LONG
  cx AS LONG
  pszText AS ASCIIZ PTR
  cchTextMax AS LONG
  iSubItem AS LONG
END TYPE

TYPE NM_LISTVIEW
  hdr AS NMHDR
  iItem AS LONG
  iSubItem AS LONG
  uNewState AS DWORD
  uOldState AS DWORD
  uChanged AS DWORD
  ptAction AS POINTAPI
  lParam AS LONG
END TYPE

TYPE LV_DISPINFO
  hdr AS NMHDR
  ITEM AS LV_ITEM
END TYPE

TYPE TV_ITEM
  mask AS DWORD
  hItem AS LONG
  STATE AS DWORD
  stateMask AS DWORD
  pszText AS ASCIIZ PTR
  cchTextMax AS LONG
  iImage AS LONG
  iSelectedImage AS LONG
  cChildren AS LONG
  lParam AS LONG
END TYPE

TYPE TV_INSERTSTRUCT
  hParent AS LONG
  hInsertAfter AS LONG
  ITEM AS TV_ITEM
END TYPE

TYPE TV_HITTESTINFO
  pt AS POINTAPI
  flags AS DWORD
  hItem AS LONG
END TYPE

TYPE NM_TREEVIEW
  hdr AS NMHDR
  action AS DWORD
  itemOld AS TV_ITEM
  itemNew AS TV_ITEM
  ptDrag AS POINTAPI
END TYPE

TYPE TV_DISPINFO
  hdr AS NMHDR
  ITEM AS TV_ITEM
END TYPE

TYPE TC_ITEM
  Mask          AS DWORD
  lpReserved1   AS DWORD
  lpReserved2   AS DWORD
  pszText       AS ASCIIZ PTR
  cchTextMax    AS LONG
  iImage        AS LONG
  lParam        AS LONG
END TYPE

TYPE NMPGSCROLL BYTE
    hdr      AS NMHDR
    fwKeys   AS WORD  ' Specifies which keys are down when this notification is sent
    rcParent AS RECT  ' Contains Parent Window Rect
    iDir     AS LONG  ' Scrolling Direction
    iXpos    AS LONG  ' Horizontal scroll position
    iYpos    AS LONG  ' Vertical scroll position
    iScroll  AS LONG  ' [in/out] Amount to scroll
END TYPE

TYPE NMPGCALCSIZE
    hdr AS NMHDR
    dwFlag AS DWORD
    iWidth AS LONG
    iHeight AS LONG
END TYPE

TYPE CHOOSECOLORAPI
  lStructSize    AS LONG
  hwndOwner      AS LONG
  hInstance      AS LONG
  rgbResult      AS DWORD
  lpCustColors   AS DWORD PTR
  Flags          AS LONG
  lCustData      AS LONG
  lpfnHook       AS DWORD
  lpTemplateName AS ASCIIZ PTR
END TYPE

TYPE FINDREPLACE
  lStructSize      AS LONG
  hWndOwner        AS LONG
  hInstance        AS LONG
  Flags            AS LONG
  lpstrFindWhat    AS ASCIIZ PTR
  lpstrReplaceWith AS ASCIIZ PTR
  wFindWhatLen     AS WORD
  wReplaceWithLen  AS WORD
  lCustData        AS LONG
  lpfnHook         AS DWORD
  lpTemplateName   AS ASCIIZ PTR
END TYPE

TYPE CHOOSEFONTAPI
  lStructSize    AS LONG
  hWndOwner      AS LONG
  hDC            AS LONG
  lpLogFont      AS LOGFONT PTR
  iPointSize     AS LONG
  Flags          AS LONG
  rgbColors      AS LONG
  lCustData      AS LONG
  lpfnHook       AS DWORD
  lpTemplateName AS ASCIIZ PTR
  hInstance      AS LONG
  lpszStyle      AS ASCIIZ PTR
  nFontType      AS WORD
  Alignment      AS WORD
  nSizeMin       AS LONG
  nSizeMax       AS LONG
END TYPE

TYPE PRINTDLGAPI
  lStructSize              AS LONG
  hWndOwner                AS LONG
  hDevMode                 AS LONG
  hDevNames                AS LONG
  hDC                      AS LONG
  Flags                    AS LONG
  nFromPage                AS INTEGER
  nToPage                  AS INTEGER
  nMinPage                 AS INTEGER
  nMaxPage                 AS INTEGER
  nCopies                  AS INTEGER
  hInstance                AS LONG
  lCustData                AS LONG
  lpfnPrintHook            AS DWORD
  lpfnSetupHook            AS DWORD
  lpPrintTemplateName      AS ASCIIZ PTR
  lpPrintSetupTemplateName AS ASCIIZ PTR
  hPrintTemplate           AS LONG
  hSetupTemplate           AS LONG
END TYPE

TYPE tagPSD
    lStructSize AS LONG
    hwndOwner AS LONG
    hDevMode AS LONG
    hDevNames AS LONG
    Flags AS LONG
    ptPaperSize AS POINTAPI
    rtMinMargin AS RECT
    rtMargin AS RECT
    hInstance AS LONG
    lCustData AS LONG
    lpfnPageSetupHook AS LONG
    lpfnPagePaintHook AS LONG
    lpPageSetupTemplateName AS ASCIIZ PTR
    hPageSetupTemplate AS LONG
END TYPE

TYPE OPENFILENAME
  lStructSize       AS LONG
  hWndOwner         AS LONG
  hInstance         AS LONG
  lpstrFilter       AS ASCIIZ PTR
  lpstrCustomFilter AS ASCIIZ PTR
  nMaxCustFilter    AS LONG
  nFilterIndex      AS LONG
  lpstrFile         AS ASCIIZ PTR
  nMaxFile          AS LONG
  lpstrFileTitle    AS ASCIIZ PTR
  nMaxFileTitle     AS LONG
  lpstrInitialDir   AS ASCIIZ PTR
  lpstrTitle        AS ASCIIZ PTR
  Flags             AS LONG
  nFileOffset       AS INTEGER
  nFileExtension    AS INTEGER
  lpstrDefExt       AS ASCIIZ PTR
  lCustData         AS LONG
  lpfnHook          AS DWORD
  lpTemplateName    AS ASCIIZ PTR
  reserve1          AS DWORD
  reserve2          AS DWORD
  flagsex           AS DWORD
END TYPE

TYPE CHARFORMAT2 BYTE
  cbSize AS LONG
  dwMask AS DWORD
  dwEffects AS DWORD
  yHeight AS LONG
  yOffset AS LONG                ' > 0 for superscript, < 0 for subscript
  crTextColor AS DWORD
  bCharSet AS BYTE
  bPitchAndFamily AS BYTE
  szFaceName AS ASCIIZ * %LF_FACESIZE
  dummypadding AS INTEGER        ' adds two extra bytes from CHARFORMAT
  wWeight AS WORD                ' Font weight (LOGFONT value)
  sSpacing AS INTEGER              ' Amount to space between letters
  crBackColor AS DWORD           ' Background color
  lcid AS DWORD                  ' Locale ID
  dwReserved AS DWORD            ' Reserved. Must be 0
  sStyle AS INTEGER              ' Style handle
  wKerning AS WORD               ' Twip size above which to kern char pair
  bUnderlineType AS BYTE         ' Underline type
  bAnimation AS BYTE             ' Animated text like marching ants
  bRevAuthor AS BYTE             ' Revision author index
  bReserved AS BYTE
END TYPE

TYPE CHARRANGE
  cpMin AS LONG
  cpMax AS LONG
END TYPE

TYPE ENLINK DWORD
  NMHDR AS NMHDR
  msg AS DWORD
  wParam AS LONG
  lParam AS LONG
  chrg AS CHARRANGE
END TYPE

TYPE EDITSTREAM
  dwCookie AS DWORD    '* user value passed to callback as first parameter *
  dwError AS DWORD     '* last error *
  pfnCallback AS DWORD
END TYPE

TYPE FORMATRANGE
  hdc AS LONG
  hdcTarget AS LONG
  rc AS RECT
  rcPage AS RECT
  chrg AS CHARRANGE
END TYPE

TYPE PARAFORMAT
  cbSize AS LONG
  dwMask AS DWORD
  wNumbering AS WORD
  wReserved AS WORD
  dxStartIndent AS LONG
  dxRightIndent AS LONG
  dxOffset AS LONG
  wAlignment AS WORD
  cTabCount AS INTEGER
  rgxTabs(1 TO %MAX_TAB_STOPS) AS LONG
END TYPE

'-----------------------------------------------------------------
' Declared Functions:  307
'-----------------------------------------------------------------
DECLARE FUNCTION AbortDoc LIB "GDI32.DLL" ALIAS "AbortDoc" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION AppendMenu LIB "USER32.DLL" ALIAS "AppendMenuA" (BYVAL hMenu AS LONG, BYVAL wFlags AS LONG, BYVAL wIDNewItem AS LONG, lpNewItem AS ASCIIZ) AS LONG
DECLARE FUNCTION ARC LIB "GDI32.DLL" ALIAS "Arc" (BYVAL hdc AS LONG, BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG, BYVAL X3 AS LONG, BYVAL Y3 AS LONG, BYVAL X4 AS LONG, BYVAL Y4 AS LONG) AS LONG
DECLARE FUNCTION BeginDeferWindowPos LIB "USER32.DLL" ALIAS "BeginDeferWindowPos" (BYVAL nNumWindows AS LONG) AS LONG
DECLARE FUNCTION BeginPaint LIB "USER32.DLL" ALIAS "BeginPaint" (BYVAL hwnd AS LONG, lpPaint AS PAINTSTRUCT) AS LONG
DECLARE FUNCTION BeginPath LIB "GDI32.DLL" ALIAS "BeginPath" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION BitBlt LIB "GDI32.DLL" ALIAS "BitBlt" (BYVAL hDestDC AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL nWidth AS LONG, BYVAL nHeight AS LONG, BYVAL hSrcDC AS LONG, BYVAL xSrc AS LONG, BYVAL ySrc AS LONG, BYVAL dwRop AS LONG) AS LONG
DECLARE FUNCTION CallWindowProc LIB "USER32.DLL" ALIAS "CallWindowProcA" (BYVAL lpPrevWndFunc AS LONG, BYVAL hWnd AS LONG, BYVAL Msg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION ChildWindowFromPointEx LIB "USER32.DLL" ALIAS "ChildWindowFromPointEx" (BYVAL hWnd AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL un AS LONG) AS LONG
DECLARE FUNCTION ChooseColor LIB "COMDLG32.DLL" ALIAS "ChooseColorA" (lpcc AS CHOOSECOLORAPI) AS LONG
DECLARE FUNCTION ChooseFont LIB "COMDLG32.DLL" ALIAS "ChooseFontA" (lpcf AS CHOOSEFONTAPI) AS LONG
DECLARE FUNCTION Chord LIB "GDI32.DLL" ALIAS "Chord" (BYVAL hdc AS LONG, BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG, BYVAL X3 AS LONG, BYVAL Y3 AS LONG, BYVAL X4 AS LONG, BYVAL Y4 AS LONG) AS LONG
DECLARE FUNCTION ClientToScreen LIB "USER32.DLL" ALIAS "ClientToScreen" (BYVAL hwnd AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION CloseClipboard LIB "USER32.DLL" ALIAS "CloseClipboard" () AS LONG
DECLARE FUNCTION CloseHandle LIB "KERNEL32.DLL" ALIAS "CloseHandle" (BYVAL hObject AS LONG) AS LONG
DECLARE FUNCTION CombineRgn LIB "GDI32.DLL" ALIAS "CombineRgn" (BYVAL hDestRgn AS LONG, BYVAL hSrcRgn1 AS LONG, BYVAL hSrcRgn2 AS LONG, BYVAL nCombineMode AS LONG) AS LONG
DECLARE FUNCTION CopyFile LIB "KERNEL32.DLL" ALIAS "CopyFileA" (lpExistingFileName AS ASCIIZ, lpNewFileName AS ASCIIZ, BYVAL bFailIfExists AS LONG) AS LONG
DECLARE FUNCTION CopyImage LIB "USER32.DLL" ALIAS "CopyImage" (BYVAL xHandle AS LONG, BYVAL un1 AS LONG, BYVAL n1 AS LONG, BYVAL n2 AS LONG, BYVAL un2 AS LONG) AS LONG
DECLARE FUNCTION CreateAcceleratorTable LIB "USER32.DLL" ALIAS "CreateAcceleratorTableA" (lpaccl AS ACCEL_API, BYVAL cEntries AS LONG) AS LONG
DECLARE FUNCTION CreateBrushIndirect LIB "GDI32.DLL" ALIAS "CreateBrushIndirect" (lpLogBrush AS LOGBRUSH) AS LONG
DECLARE FUNCTION CreateCompatibleBitmap LIB "GDI32.DLL" ALIAS "CreateCompatibleBitmap" (BYVAL hdc AS LONG, BYVAL nWidth AS LONG, BYVAL nHeight AS LONG) AS LONG
DECLARE FUNCTION CreateCompatibleDC LIB "GDI32.DLL" ALIAS "CreateCompatibleDC" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION CreateDC LIB "GDI32.DLL" ALIAS "CreateDCA" (lpDriverName AS ASCIIZ, lpDeviceName AS ASCIIZ, lpOutput AS ASCIIZ, lpInitData AS DEVMODE) AS LONG
DECLARE FUNCTION CreateDialogIndirectParam LIB "USER32.DLL" ALIAS "CreateDialogIndirectParamA" (BYVAL hInstance AS LONG, lpTemplate AS DLGTEMPLATE, BYVAL hWndParent AS LONG, BYVAL lpDialogFunc AS LONG, BYVAL dwInitParam AS LONG) AS LONG
DECLARE FUNCTION CreateDIBSection LIB "GDI32.DLL" ALIAS "CreateDIBSection" (BYVAL hDC AS LONG, pBitmapInfo AS BITMAPINFO, BYVAL un AS LONG, BYVAL lplpVoid AS LONG, BYVAL xHandle AS LONG, BYVAL DW AS LONG) AS LONG
DECLARE FUNCTION CreateEllipticRgn LIB "GDI32.DLL" ALIAS "CreateEllipticRgn" (BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG) AS LONG
DECLARE FUNCTION CreateFont LIB "GDI32.DLL" ALIAS "CreateFontA" (BYVAL H AS LONG, BYVAL W AS LONG, BYVAL E AS LONG, BYVAL O AS LONG, BYVAL W AS LONG, BYVAL I AS LONG, BYVAL u AS LONG, BYVAL S AS LONG, BYVAL C AS LONG, BYVAL OP AS LONG, _
              BYVAL CP AS LONG, BYVAL Q AS LONG, BYVAL PAF AS LONG, F AS ASCIIZ) AS LONG
DECLARE FUNCTION CreateFontIndirect LIB "GDI32.DLL" ALIAS "CreateFontIndirectA" (lpLogFont AS LOGFONT) AS LONG
DECLARE FUNCTION CreateHatchBrush LIB "GDI32.DLL" ALIAS "CreateHatchBrush" (BYVAL nIndex AS LONG, BYVAL crColor AS LONG) AS LONG
DECLARE FUNCTION CreateMenu LIB "USER32.DLL" ALIAS "CreateMenu" () AS LONG
DECLARE FUNCTION CreatePen LIB "GDI32.DLL" ALIAS "CreatePen" (BYVAL nPenStyle AS LONG, BYVAL nWidth AS LONG, BYVAL crColor AS LONG) AS LONG
DECLARE FUNCTION CreatePolygonRgn LIB "GDI32.DLL" ALIAS "CreatePolygonRgn" (lpPoint AS POINTAPI, BYVAL nCount AS LONG, BYVAL nPolyFillMode AS LONG) AS LONG
DECLARE FUNCTION CreatePopupMenu LIB "USER32.DLL" ALIAS "CreatePopupMenu" () AS LONG
DECLARE FUNCTION CreateRectRgn LIB "GDI32.DLL" ALIAS "CreateRectRgn" (BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG) AS LONG
DECLARE FUNCTION CreateRoundRectRgn LIB "GDI32.DLL" ALIAS "CreateRoundRectRgn" (BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG, BYVAL X3 AS LONG, BYVAL Y3 AS LONG) AS LONG
DECLARE FUNCTION CreateSolidBrush LIB "GDI32.DLL" ALIAS "CreateSolidBrush" (BYVAL crColor AS LONG) AS LONG
DECLARE FUNCTION CreateThread LIB "KERNEL32.DLL" ALIAS "CreateThread" (BYVAL lpThreadAttributes AS DWORD, BYVAL dwStackSize AS LONG, BYVAL StartAddress AS LONG, BYVAL lpParameter AS LONG, BYVAL dwCreationFlags AS LONG, lpThreadId AS LONG) AS LONG
DECLARE FUNCTION CreateWindowEx LIB "USER32.DLL" ALIAS "CreateWindowExA" _
   (BYVAL dwExStyle AS LONG, lpClassName AS ASCIIZ, lpWindowName AS ASCIIZ, BYVAL dwStyle AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, _
    BYVAL nWidth AS LONG, BYVAL nHeight AS LONG, BYVAL hWndParent AS LONG, BYVAL hMenu AS LONG, BYVAL hInstance AS LONG, lpParam AS ANY) AS LONG
DECLARE FUNCTION DefDlgProc LIB "USER32.DLL" ALIAS "DefDlgProcA" (BYVAL hDlg AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION DeferWindowPos LIB "USER32.DLL" ALIAS "DeferWindowPos" (BYVAL hWinPosInfo AS LONG, BYVAL hwnd AS LONG, BYVAL hWndInsertAfter AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL cx AS LONG, BYVAL cy AS LONG, _
              BYVAL wFlags AS LONG) AS LONG
DECLARE FUNCTION DefFrameProc LIB "USER32.DLL" ALIAS "DefFrameProcA" (BYVAL hwnd AS LONG, BYVAL hWndMDIClient AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION DefMDIChildProc LIB "USER32.DLL" ALIAS "DefMDIChildProcA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION DefWindowProc LIB "USER32.DLL" ALIAS "DefWindowProcA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION DeleteDC LIB "GDI32.DLL" ALIAS "DeleteDC" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION DeleteMenu LIB "USER32.DLL" ALIAS "DeleteMenu" (BYVAL hMenu AS LONG, BYVAL nPosition AS LONG, BYVAL wFlags AS LONG) AS LONG
DECLARE FUNCTION DeleteObject LIB "GDI32.DLL" ALIAS "DeleteObject" (BYVAL hObject AS LONG) AS LONG
DECLARE FUNCTION DestroyAcceleratorTable LIB "USER32.DLL" ALIAS "DestroyAcceleratorTable" (BYVAL haccel AS LONG) AS LONG
DECLARE FUNCTION DestroyCursor LIB "USER32.DLL" ALIAS "DestroyCursor" (BYVAL hCursor AS LONG) AS LONG
DECLARE FUNCTION DestroyIcon LIB "USER32.DLL" ALIAS "DestroyIcon" (BYVAL hIcon AS LONG) AS LONG
DECLARE FUNCTION DestroyMenu LIB "USER32.DLL" ALIAS "DestroyMenu" (BYVAL hMenu AS LONG) AS LONG
DECLARE FUNCTION DestroyWindow LIB "USER32.DLL" ALIAS "DestroyWindow" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION DispatchMessage LIB "USER32.DLL" ALIAS "DispatchMessageA" (lpMsg AS tagMSG) AS LONG
DECLARE FUNCTION DPtoLP LIB "GDI32.DLL" ALIAS "DPtoLP" (BYVAL hdc AS LONG, lpPoint AS POINTAPI, BYVAL nCount AS LONG) AS LONG
DECLARE FUNCTION DragQueryFile LIB "SHELL32.DLL" ALIAS "DragQueryFileA" (BYVAL HDROP AS LONG, BYVAL UINT AS LONG, lpStr AS ASCIIZ, BYVAL ch AS LONG) AS LONG
DECLARE FUNCTION DragQueryPoint LIB "SHELL32.DLL" ALIAS "DragQueryPoint" (BYVAL HDROP AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION DrawEdge LIB "USER32.DLL" ALIAS "DrawEdge" (BYVAL hdc AS LONG, qrc AS RECT, BYVAL edge AS LONG, BYVAL grfFlags AS LONG) AS LONG
DECLARE FUNCTION DrawFocusRect LIB "USER32.DLL" ALIAS "DrawFocusRect" (BYVAL hdc AS LONG, lpRect AS RECT) AS LONG
DECLARE FUNCTION DrawFrameControl LIB "USER32.DLL" ALIAS "DrawFrameControl" (BYVAL hDC AS LONG, lpRect AS RECT, BYVAL un1 AS LONG, BYVAL un2 AS LONG) AS LONG
DECLARE FUNCTION DrawIconEx LIB "USER32.DLL" ALIAS "DrawIconEx" (BYVAL hdc AS LONG, BYVAL xLeft AS LONG, BYVAL yTop AS LONG, BYVAL hIcon AS LONG, BYVAL cxWidth AS LONG, BYVAL cyWidth AS LONG, BYVAL istepIfAniCur AS LONG, _
              BYVAL hbrFlickerFreeDraw AS LONG, BYVAL diFlags AS LONG) AS LONG
DECLARE FUNCTION DrawMenuBar LIB "USER32.DLL" ALIAS "DrawMenuBar" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION DrawText LIB "USER32.DLL" ALIAS "DrawTextA" (BYVAL hdc AS LONG, BYVAL lpString AS LONG, BYVAL nCount AS LONG, lpRect AS RECT, BYVAL wFormat AS LONG) AS LONG
DECLARE FUNCTION ELLIPSE LIB "GDI32.DLL" ALIAS "Ellipse" (BYVAL hdc AS LONG, BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG) AS LONG
DECLARE FUNCTION EmptyClipboard LIB "USER32.DLL" ALIAS "EmptyClipboard" () AS LONG
DECLARE FUNCTION EnableMenuItem LIB "USER32.DLL" ALIAS "EnableMenuItem" (BYVAL hMenu AS LONG, BYVAL wIDEnableItem AS LONG, BYVAL wEnable AS LONG) AS LONG
DECLARE FUNCTION EnableWindow LIB "USER32.DLL" ALIAS "EnableWindow" (BYVAL hwnd AS LONG, BYVAL fEnable AS LONG) AS LONG
DECLARE FUNCTION EndDeferWindowPos LIB "USER32.DLL" ALIAS "EndDeferWindowPos" (BYVAL hWinPosInfo AS LONG) AS LONG
DECLARE FUNCTION EndDoc LIB "GDI32.DLL" ALIAS "EndDoc" (BYVAL hDC AS LONG) AS LONG
DECLARE FUNCTION EndPage LIB "GDI32.DLL" ALIAS "EndPage" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION EndPaint LIB "USER32.DLL" ALIAS "EndPaint" (BYVAL hwnd AS LONG, lpPaint AS PAINTSTRUCT) AS LONG
DECLARE FUNCTION EndPath LIB "GDI32.DLL" ALIAS "EndPath" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION EnumChildWindows LIB "USER32.DLL" ALIAS "EnumChildWindows" (BYVAL hWndParent AS LONG, BYVAL lpEnumFunc AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION EnumFontFamiliesEx LIB "GDI32.DLL" ALIAS "EnumFontFamiliesExA" (BYVAL hdc AS LONG, lpLogFont AS LOGFONT, BYVAL lpEnumFontProc AS LONG, BYVAL lParam AS LONG, BYVAL DW AS LONG) AS LONG
DECLARE FUNCTION EnumResourceNames LIB "KERNEL32.DLL" ALIAS "EnumResourceNamesA" (BYVAL hModule AS LONG, lpType AS ASCIIZ, BYVAL lpEnumFunc AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION ExtCreateRegion LIB "GDI32.DLL" ALIAS "ExtCreateRegion" (lpXform AS xform, BYVAL nCount AS LONG, lpRgnData AS RGNDATA) AS LONG
DECLARE FUNCTION ExtFloodFill LIB "GDI32.DLL" ALIAS "ExtFloodFill" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL crColor AS LONG, BYVAL wFillType AS LONG) AS LONG
DECLARE FUNCTION FillPath LIB "GDI32.DLL" ALIAS "FillPath" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION FindResource LIB "KERNEL32.DLL" ALIAS "FindResourceA" (BYVAL hInstance AS LONG, lpName AS ASCIIZ, lpType AS ASCIIZ) AS LONG
DECLARE FUNCTION FindText LIB "COMDLG32.DLL" ALIAS "FindTextA" (lpfr AS FINDREPLACE) AS LONG
DECLARE FUNCTION FreeLibrary LIB "KERNEL32.DLL" ALIAS "FreeLibrary" (BYVAL hLibModule AS LONG) AS LONG
DECLARE FUNCTION GdiFlush LIB "GDI32.DLL" ALIAS "GdiFlush" () AS LONG
DECLARE FUNCTION GetAsyncKeyState LIB "USER32.DLL" ALIAS "GetAsyncKeyState" (BYVAL vKey AS LONG) AS INTEGER
DECLARE FUNCTION GetBrushOrgEx LIB "GDI32.DLL" ALIAS "GetBrushOrgEx" (BYVAL hDC AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION GetClassInfoEx LIB "USER32.DLL" ALIAS "GetClassInfoExA" (BYVAL hInst AS LONG, lpszClass AS ASCIIZ, lpWndClass AS WNDCLASSEX) AS LONG
DECLARE FUNCTION GetClassLong LIB "USER32.DLL" ALIAS "GetClassLongA" (BYVAL hwnd AS LONG, BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetClassName LIB "USER32.DLL" ALIAS "GetClassNameA" (BYVAL hwnd AS LONG, lpClassName AS ASCIIZ, BYVAL nMaxCount AS LONG) AS LONG
DECLARE FUNCTION GetClientRect LIB "USER32.DLL" ALIAS "GetClientRect" (BYVAL hwnd AS LONG, lpRect AS RECT) AS LONG
DECLARE FUNCTION GetClipboardData LIB "USER32.DLL" ALIAS "GetClipboardData" (BYVAL wFormat AS LONG) AS LONG
DECLARE FUNCTION GetClipBox LIB "GDI32.DLL" ALIAS "GetClipBox" (BYVAL hdc AS LONG, lpRect AS RECT) AS LONG
DECLARE FUNCTION GetCurrentObject LIB "GDI32.DLL" ALIAS "GetCurrentObject" (BYVAL hdc AS LONG, BYVAL uObjectType AS LONG) AS LONG
DECLARE FUNCTION GetCurrentPositionEx LIB "GDI32.DLL" ALIAS "GetCurrentPositionEx" (BYVAL hdc AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION GetCursorPos LIB "USER32.DLL" ALIAS "GetCursorPos" (lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION GetDC LIB "USER32.DLL" ALIAS "GetDC" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION GetDCEx LIB "USER32.DLL" ALIAS "GetDCEx" (BYVAL hwnd AS LONG, BYVAL hrgnclip AS LONG, BYVAL fdwOptions AS LONG) AS LONG
DECLARE FUNCTION GetDesktopWindow LIB "USER32.DLL" ALIAS "GetDesktopWindow" () AS LONG
DECLARE FUNCTION GetDeviceCaps LIB "GDI32.DLL" ALIAS "GetDeviceCaps" (BYVAL hdc AS LONG, BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetDialogBaseUnits LIB "USER32.DLL" ALIAS "GetDialogBaseUnits" () AS LONG
DECLARE FUNCTION GetDIBits LIB "GDI32.DLL" ALIAS "GetDIBits" (BYVAL aHDC AS LONG, BYVAL hBitmap AS LONG, BYVAL nStartScan AS LONG, BYVAL nNumScans AS LONG, lpBits AS ANY, lpBI AS BITMAPINFO, BYVAL wUsage AS LONG) AS LONG
DECLARE FUNCTION GetDlgCtrlID LIB "USER32.DLL" ALIAS "GetDlgCtrlID" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION GetDlgItem LIB "USER32.DLL" ALIAS "GetDlgItem" (BYVAL hDlg AS LONG, BYVAL nIDDlgItem AS LONG) AS LONG
DECLARE FUNCTION GetDoubleClickTime LIB "USER32.DLL" ALIAS "GetDoubleClickTime" () AS LONG
DECLARE FUNCTION GetDriveType LIB "KERNEL32.DLL" ALIAS "GetDriveTypeA" (nDrive AS ASCIIZ) AS LONG
DECLARE FUNCTION GetExitCodeThread LIB "KERNEL32.DLL" ALIAS "GetExitCodeThread" (BYVAL hThread AS LONG, lpExitCode AS LONG) AS LONG
DECLARE FUNCTION GetFocus LIB "USER32.DLL" ALIAS "GetFocus" () AS LONG
DECLARE FUNCTION GetKeyState LIB "USER32.DLL" ALIAS "GetKeyState" (BYVAL nVirtKey AS LONG) AS INTEGER
DECLARE FUNCTION GetLastError LIB "KERNEL32.DLL" ALIAS "GetLastError" () AS LONG
DECLARE FUNCTION GetMapMode LIB "GDI32.DLL" ALIAS "GetMapMode" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION GetMenuItemCount LIB "USER32.DLL" ALIAS "GetMenuItemCount" (BYVAL hMenu AS LONG) AS LONG
DECLARE FUNCTION GetMenuItemInfo LIB "USER32.DLL" ALIAS "GetMenuItemInfoA" (BYVAL hMenu AS LONG, BYVAL un AS LONG, BYVAL b AS LONG, lpMenuItemInfo AS MENUITEMINFO) AS LONG
DECLARE FUNCTION GetMessage LIB "USER32.DLL" ALIAS "GetMessageA" (lpMsg AS tagMSG, BYVAL hwnd AS LONG, BYVAL wMsgFilterMin AS LONG, BYVAL wMsgFilterMax AS LONG) AS LONG
DECLARE FUNCTION GetModuleFileName LIB "KERNEL32.DLL" ALIAS "GetModuleFileNameA" (BYVAL hModule AS LONG, lpFileName AS ASCIIZ, BYVAL nSize AS LONG) AS LONG
DECLARE FUNCTION GetModuleHandle LIB "KERNEL32.DLL" ALIAS "GetModuleHandleA" (lpModuleName AS ASCIIZ) AS LONG
DECLARE FUNCTION GetNextDlgTabItem LIB "USER32.DLL" ALIAS "GetNextDlgTabItem" (BYVAL hDlg AS LONG, BYVAL hCtl AS LONG, BYVAL bPrevious AS LONG) AS LONG
DECLARE FUNCTION GetObject LIB "GDI32.DLL" ALIAS "GetObjectA" (BYVAL hObject AS LONG, BYVAL nCount AS LONG, lpObject AS ANY) AS LONG
DECLARE FUNCTION GetObjectType LIB "GDI32.DLL" ALIAS "GetObjectType" (BYVAL hgdiobj AS LONG) AS LONG
DECLARE FUNCTION GetOpenFileName LIB "COMDLG32.DLL" ALIAS "GetOpenFileNameA" (lpofn AS OPENFILENAME) AS LONG
DECLARE FUNCTION GetParent LIB "USER32.DLL" ALIAS "GetParent" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION GetPixel LIB "GDI32.DLL" ALIAS "GetPixel" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG) AS LONG
DECLARE FUNCTION GetPolyFillMode LIB "GDI32.DLL" ALIAS "GetPolyFillMode" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION GetProcAddress LIB "KERNEL32.DLL" ALIAS "GetProcAddress" (BYVAL hModule AS LONG, lpProcName AS ASCIIZ) AS LONG
DECLARE FUNCTION GetProp LIB "USER32.DLL" ALIAS "GetPropA" (BYVAL hwnd AS LONG, lpString AS ASCIIZ) AS LONG
DECLARE FUNCTION GetROP2 LIB "GDI32.DLL" ALIAS "GetROP2" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION GetSaveFileName LIB "COMDLG32.DLL" ALIAS "GetSaveFileNameA" (lpofn AS OPENFILENAME) AS LONG
DECLARE FUNCTION GetScrollInfo LIB "USER32.DLL" ALIAS "GetScrollInfo" (BYVAL hWnd AS LONG, BYVAL n AS LONG, lpScrollInfo AS SCROLLINFO) AS LONG
DECLARE FUNCTION GetStockObject LIB "GDI32.DLL" ALIAS "GetStockObject" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetSysColor LIB "USER32.DLL" ALIAS "GetSysColor" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetSysColorBrush LIB "USER32.DLL" ALIAS "GetSysColorBrush" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetSystemMenu LIB "USER32.DLL" ALIAS "GetSystemMenu" (BYVAL hwnd AS LONG, BYVAL bRevert AS LONG) AS LONG
DECLARE FUNCTION GetSystemMetrics LIB "USER32.DLL" ALIAS "GetSystemMetrics" (BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetTextCharacterExtra LIB "GDI32.DLL" ALIAS "GetTextCharacterExtra" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION GetTextColor LIB "GDI32.DLL" ALIAS "GetTextColor" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION GetTextExtentPoint32 LIB "GDI32.DLL" ALIAS "GetTextExtentPoint32A" (BYVAL hdc AS LONG, lpsz AS ASCIIZ, BYVAL cbString AS LONG, lpSize AS SIZEL) AS LONG
DECLARE FUNCTION GetTextFace LIB "GDI32.DLL" ALIAS "GetTextFaceA" (BYVAL hdc AS LONG, BYVAL nCount AS LONG, lpFacename AS ASCIIZ) AS LONG
DECLARE FUNCTION GetTextMetrics LIB "GDI32.DLL" ALIAS "GetTextMetricsA" (BYVAL hdc AS LONG, lpMetrics AS NEWTEXTMETRICEX_SAFE) AS LONG
DECLARE FUNCTION GetTickCount LIB "KERNEL32.DLL" ALIAS "GetTickCount" () AS DWORD
DECLARE FUNCTION GetUpdateRgn LIB "USER32.DLL" ALIAS "GetUpdateRgn" (BYVAL hwnd AS LONG, BYVAL hRgn AS LONG, BYVAL fErase AS LONG) AS LONG
DECLARE FUNCTION GetVersionEx LIB "KERNEL32.DLL" ALIAS "GetVersionExA" (lpVersionInformation AS OSVERSIONINFO) AS LONG
DECLARE FUNCTION GetWindow LIB "USER32.DLL" ALIAS "GetWindow" (BYVAL hwnd AS LONG, BYVAL wCmd AS LONG) AS LONG
DECLARE FUNCTION GetWindowExtEx LIB "GDI32.DLL" ALIAS "GetWindowExtEx" (BYVAL hdc AS LONG, lpSize AS SIZEL) AS LONG
DECLARE FUNCTION GetWindowLong LIB "USER32.DLL" ALIAS "GetWindowLongA" (BYVAL hWnd AS LONG, BYVAL nIndex AS LONG) AS LONG
DECLARE FUNCTION GetWindowOrgEx LIB "GDI32.DLL" ALIAS "GetWindowOrgEx" (BYVAL hdc AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION GetWindowRect LIB "USER32.DLL" ALIAS "GetWindowRect" (BYVAL hwnd AS LONG, lpRect AS RECT) AS LONG
DECLARE FUNCTION GetWindowRgn LIB "USER32.DLL" ALIAS "GetWindowRgn" (BYVAL hWnd AS LONG, BYVAL hRgn AS LONG) AS LONG
DECLARE FUNCTION GetWindowText LIB "USER32.DLL" ALIAS "GetWindowTextA" (BYVAL hwnd AS LONG, lpString AS ASCIIZ, BYVAL cch AS LONG) AS LONG
DECLARE FUNCTION GetWindowTextLength LIB "USER32.DLL" ALIAS "GetWindowTextLengthA" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION GlobalAddAtom LIB "KERNEL32.DLL" ALIAS "GlobalAddAtomA" (lpString AS ASCIIZ) AS LONG
DECLARE FUNCTION GlobalAlloc LIB "KERNEL32.DLL" ALIAS "GlobalAlloc" (BYVAL wFlags AS LONG, BYVAL dwBytes AS LONG) AS LONG
DECLARE FUNCTION GlobalDeleteAtom LIB "KERNEL32.DLL" ALIAS "GlobalDeleteAtom" (BYVAL nAtom AS LONG) AS LONG
DECLARE FUNCTION GlobalFree LIB "KERNEL32.DLL" ALIAS "GlobalFree" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalLock LIB "KERNEL32.DLL" ALIAS "GlobalLock" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalSize LIB "KERNEL32.DLL" ALIAS "GlobalSize" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION GlobalUnlock LIB "KERNEL32.DLL" ALIAS "GlobalUnlock" (BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION ImageList_AddMasked LIB "COMCTL32.DLL" ALIAS "ImageList_AddMasked" (BYVAL himl AS DWORD, BYVAL hbmImage AS DWORD, BYVAL crMask AS LONG) AS LONG
DECLARE FUNCTION ImageList_BeginDrag LIB "COMCTL32.DLL" ALIAS "ImageList_BeginDrag" (BYVAL himlTrack AS DWORD, BYVAL iTrack AS LONG, BYVAL dxHotSpot AS LONG, BYVAL dyHotSpot AS LONG) AS LONG
DECLARE FUNCTION ImageList_Copy  LIB "COMCTL32.DLL"  ALIAS "ImageList_Copy" (BYVAL himlDst AS DWORD, BYVAL iDst AS LONG, _
    BYVAL himlSrc AS DWORD, BYVAL iSrc AS LONG, BYVAL uFlags AS DWORD) AS LONG
DECLARE FUNCTION ImageList_Create LIB "COMCTL32.DLL" ALIAS "ImageList_Create" (BYVAL cx AS LONG, BYVAL cy AS LONG, BYVAL flags AS DWORD, BYVAL cInitial AS LONG, BYVAL cGrow AS LONG) AS LONG
DECLARE FUNCTION ImageList_Destroy LIB "COMCTL32.DLL" ALIAS "ImageList_Destroy" (BYVAL himl AS DWORD) AS LONG
DECLARE FUNCTION ImageList_DragEnter LIB "COMCTL32.DLL" ALIAS "ImageList_DragEnter" (BYVAL hWndLock AS DWORD, BYVAL x AS LONG, BYVAL y AS LONG) AS LONG
DECLARE FUNCTION ImageList_DragLeave LIB "COMCTL32.DLL" ALIAS "ImageList_DragLeave" (BYVAL hWndLock AS DWORD) AS LONG
DECLARE FUNCTION ImageList_DragMove LIB "COMCTL32.DLL" ALIAS "ImageList_DragMove" (BYVAL x AS LONG, BYVAL y AS LONG) AS LONG
DECLARE FUNCTION ImageList_DrawEx LIB "COMCTL32.DLL" ALIAS "ImageList_DrawEx" (BYVAL himl AS DWORD, BYVAL i AS LONG, BYVAL hdcDst AS DWORD, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL dx AS LONG, BYVAL dy AS LONG, BYVAL rgbBk AS LONG, BYVAL rgbFg AS LONG, _
                            BYVAL fStyle AS LONG) AS LONG
DECLARE FUNCTION ImageList_Duplicate LIB "COMCTL32.DLL" ALIAS "ImageList_Duplicate" (BYVAL hImg&) AS LONG
DECLARE FUNCTION ImageList_GetDragImage LIB "COMCTL32.DLL" ALIAS "ImageList_GetDragImage" (ppt AS POINTAPI, pptHotSpot AS POINTAPI) AS DWORD
DECLARE FUNCTION ImageList_GetIconSize LIB "COMCTL32.DLL" ALIAS "ImageList_GetIconSize" (BYVAL himl AS DWORD, cx AS LONG, cy AS LONG) AS LONG
DECLARE FUNCTION ImageList_GetImageCount LIB "COMCTL32.DLL" ALIAS "ImageList_GetImageCount" (BYVAL himl AS DWORD) AS LONG
DECLARE FUNCTION ImageList_ReplaceIcon LIB "COMCTL32.DLL" ALIAS "ImageList_ReplaceIcon" (BYVAL himl AS DWORD, BYVAL i AS LONG, BYVAL hIcon AS LONG) AS LONG
DECLARE FUNCTION InsertMenuItem LIB "USER32.DLL" ALIAS "InsertMenuItemA" (BYVAL hMenu AS LONG, BYVAL un AS LONG, BYVAL bool AS LONG, lpcMenuItemInfo AS MENUITEMINFO) AS LONG
DECLARE FUNCTION IntersectRect LIB "USER32.DLL" ALIAS "IntersectRect" (lpDestRect AS RECT, lpSrc1Rect AS RECT, lpSrc2Rect AS RECT) AS LONG
DECLARE FUNCTION InvalidateRect LIB "USER32.DLL" ALIAS "InvalidateRect" (BYVAL hwnd AS LONG, lpRect AS RECT, BYVAL bErase AS LONG) AS LONG
DECLARE FUNCTION InvalidateRgn LIB "USER32.DLL" ALIAS "InvalidateRgn" (BYVAL hwnd AS LONG, BYVAL hRgn AS LONG, BYVAL bErase AS LONG) AS LONG
DECLARE FUNCTION IsBadReadPtr LIB "KERNEL32.DLL" ALIAS "IsBadReadPtr" (BYVAL lp AS LONG, BYVAL ucb AS LONG) AS LONG
DECLARE FUNCTION IsBadWritePtr LIB "KERNEL32.DLL" ALIAS "IsBadWritePtr" (BYVAL lp AS LONG, BYVAL ucb AS LONG) AS LONG
DECLARE FUNCTION IsChild LIB "USER32.DLL" ALIAS "IsChild" (BYVAL hWndParent AS LONG, BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION IsClipboardFormatAvailable LIB "USER32.DLL" ALIAS "IsClipboardFormatAvailable" (BYVAL wFormat AS LONG) AS LONG
DECLARE FUNCTION IsDialogMessage LIB "USER32.DLL" ALIAS "IsDialogMessageA" (BYVAL hDlg AS LONG, lpMsg AS tagMSG) AS LONG
DECLARE FUNCTION IsIconic LIB "USER32.DLL" ALIAS "IsIconic" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION IsMenu LIB "USER32.DLL" ALIAS "IsMenu" (BYVAL hMenu AS LONG) AS LONG
DECLARE FUNCTION IsWindow LIB "USER32.DLL" ALIAS "IsWindow" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION IsWindowEnabled LIB "USER32.DLL" ALIAS "IsWindowEnabled" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION IsWindowVisible LIB "USER32.DLL" ALIAS "IsWindowVisible" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION IsZoomed LIB "USER32.DLL" ALIAS "IsZoomed" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION KillTimer LIB "USER32.DLL" ALIAS "KillTimer" (BYVAL hwnd AS LONG, BYVAL nIDEvent AS LONG) AS LONG
DECLARE FUNCTION LBItemFromPt LIB "COMCTL32.DLL" ALIAS "LBItemFromPt" (BYVAL hLB AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL bAutoScroll AS LONG) AS LONG
DECLARE FUNCTION LineTo LIB "GDI32.DLL" ALIAS "LineTo" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG) AS LONG
DECLARE FUNCTION LoadCursor LIB "USER32.DLL" ALIAS "LoadCursorA" (BYVAL hInstance AS LONG, lpCursorName AS ASCIIZ) AS LONG
DECLARE FUNCTION LoadCursorFromFile LIB "USER32.DLL" ALIAS "LoadCursorFromFileA" (lpFileName AS ASCIIZ) AS LONG
DECLARE FUNCTION LoadIcon LIB "USER32.DLL" ALIAS "LoadIconA" (BYVAL hInstance AS LONG, lpIconName AS ASCIIZ) AS LONG
DECLARE FUNCTION LoadImage LIB "USER32.DLL" ALIAS "LoadImageA" (BYVAL hInst AS LONG, lpsz AS ASCIIZ, BYVAL un1 AS LONG, BYVAL n1 AS LONG, BYVAL n2 AS LONG, BYVAL un2 AS LONG) AS LONG
DECLARE FUNCTION LoadLibrary LIB "KERNEL32.DLL" ALIAS "LoadLibraryA" (lpLibFileName AS ASCIIZ) AS LONG
DECLARE FUNCTION LoadResource LIB "KERNEL32.DLL" ALIAS "LoadResource" (BYVAL hInstance AS LONG, BYVAL hResInfo AS LONG) AS LONG
DECLARE FUNCTION LockResource LIB "KERNEL32.DLL" ALIAS "LockResource" (BYVAL hResData AS LONG) AS LONG
DECLARE FUNCTION LPtoDP LIB "GDI32.DLL" ALIAS "LPtoDP" (BYVAL hdc AS LONG, lpPoint AS POINTAPI, BYVAL nCount AS LONG) AS LONG
DECLARE FUNCTION MakeDragList LIB "COMCTL32.DLL" ALIAS "MakeDragList" (BYVAL hLB AS LONG) AS LONG
DECLARE FUNCTION MapWindowPoints LIB "USER32.DLL" ALIAS "MapWindowPoints" (BYVAL hwndFrom AS LONG, BYVAL hwndTo AS LONG, lppt AS ANY, BYVAL cPoints AS LONG) AS LONG
DECLARE FUNCTION MessageBeep LIB "USER32.DLL" ALIAS "MessageBeep" (BYVAL wType AS LONG) AS LONG
DECLARE FUNCTION MessageBox LIB "USER32.DLL" ALIAS "MessageBoxA" (BYVAL hwnd AS LONG, lpText AS ASCIIZ, lpCaption AS ASCIIZ, BYVAL wType AS LONG) AS LONG
DECLARE FUNCTION MessageBoxIndirect LIB "USER32.DLL" ALIAS "MessageBoxIndirectA" (lpMsgBoxParams AS MSGBOXPARAMS) AS LONG
DECLARE FUNCTION MoveMemory LIB "KERNEL32.DLL" ALIAS "RtlMoveMemory" (BYVAL lpDest AS DWORD, BYVAL lpSource AS DWORD, BYVAL cbMove AS DWORD) AS LONG
DECLARE FUNCTION MoveToEx LIB "GDI32.DLL" ALIAS "MoveToEx" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION MoveWindow LIB "USER32.DLL" ALIAS "MoveWindow" (BYVAL hwnd AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL nWidth AS LONG, BYVAL nHeight AS LONG, BYVAL bRepaint AS LONG) AS LONG
DECLARE FUNCTION MulDiv LIB "KERNEL32.DLL" ALIAS "MulDiv" (BYVAL nNumber AS LONG, BYVAL nNumerator AS LONG, BYVAL nDenominator AS LONG) AS LONG
DECLARE FUNCTION MultiByteToWideChar LIB "KERNEL32.DLL" ALIAS "MultiByteToWideChar" (BYVAL CodePage AS LONG, BYVAL dwFlags AS LONG, lpMultiByteStr AS ASCIIZ, BYVAL cchMultiByte AS LONG, lpWideCharStr AS ASCIIZ, BYVAL cchWideChar AS LONG) AS LONG
DECLARE FUNCTION OffsetClipRgn LIB "GDI32.DLL" ALIAS "OffsetClipRgn" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG) AS LONG
DECLARE FUNCTION OffsetRgn LIB "GDI32.DLL" ALIAS "OffsetRgn" (BYVAL hRgn AS LONG, BYVAL x AS LONG, BYVAL y AS LONG) AS LONG
DECLARE FUNCTION OpenClipboard LIB "USER32.DLL" ALIAS "OpenClipboard" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION OpenProcess LIB "KERNEL32.DLL" ALIAS "OpenProcess" (BYVAL dwDesiredAccess AS DWORD, BYVAL bInheritHandle AS LONG, BYVAL dwProcessId AS DWORD) AS LONG
DECLARE FUNCTION PageSetupDlg LIB "COMDLG32.DLL" ALIAS "PageSetupDlgA" (PSD AS tagPSD) AS LONG
DECLARE FUNCTION PatBlt LIB "GDI32.DLL" ALIAS "PatBlt" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL nWidth AS LONG, BYVAL nHeight AS LONG, BYVAL dwRop AS LONG) AS LONG
DECLARE FUNCTION PathToRegion LIB "GDI32.DLL" ALIAS "PathToRegion" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION PeekMessage LIB "USER32.DLL" ALIAS "PeekMessageA" (lpMsg AS tagMSG, BYVAL hwnd AS LONG, BYVAL wMsgFilterMin AS LONG, BYVAL wMsgFilterMax AS LONG, BYVAL wRemoveMsg AS LONG) AS LONG
DECLARE FUNCTION PIE LIB "GDI32.DLL" ALIAS "Pie" (BYVAL hdc AS LONG, BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG, BYVAL X3 AS LONG, BYVAL Y3 AS LONG, BYVAL X4 AS LONG, BYVAL Y4 AS LONG) AS LONG
DECLARE FUNCTION PolyBezier LIB "GDI32.DLL" ALIAS "PolyBezier" (BYVAL hdc AS LONG, lppt AS POINTAPI, BYVAL cPoints AS LONG) AS LONG
DECLARE FUNCTION POLYGON LIB "GDI32.DLL" ALIAS "Polygon" (BYVAL hdc AS LONG, lpPoint AS POINTAPI, BYVAL nCount AS LONG) AS LONG
DECLARE FUNCTION POLYLINE LIB "GDI32.DLL" ALIAS "Polyline" (BYVAL hdc AS LONG, lpPoint AS POINTAPI, BYVAL nCount AS LONG) AS LONG
DECLARE FUNCTION PostMessage LIB "USER32.DLL" ALIAS "PostMessageA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION PrintDlg LIB "COMDLG32.DLL" ALIAS "PrintDlgA" (lpPd AS PRINTDLGAPI) AS LONG
DECLARE FUNCTION QueryPerformanceCounter LIB "KERNEL32.DLL" ALIAS "QueryPerformanceCounter" (lpPerformanceCount AS QUAD) AS LONG
DECLARE FUNCTION QueryPerformanceFrequency LIB "KERNEL32.DLL" ALIAS "QueryPerformanceFrequency" (lpFrequency AS QUAD) AS LONG
DECLARE FUNCTION Rectangle LIB "GDI32.DLL" ALIAS "Rectangle" (BYVAL hdc AS LONG, BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG) AS LONG
DECLARE FUNCTION RectVisible LIB "GDI32.DLL" ALIAS "RectVisible" (BYVAL hdc AS LONG, lpRect AS RECT) AS LONG
DECLARE FUNCTION RedrawWindow LIB "USER32.DLL" ALIAS "RedrawWindow" (BYVAL hwnd AS LONG, lprcUpdate AS RECT, BYVAL hrgnUpdate AS LONG, BYVAL fuRedraw AS LONG) AS LONG
DECLARE FUNCTION RegCloseKey LIB "ADVAPI32.DLL" ALIAS "RegCloseKey" (BYVAL hKey AS LONG) AS LONG
DECLARE FUNCTION RegCreateKeyEx LIB "ADVAPI32.DLL" ALIAS "RegCreateKeyExA" (BYVAL hKey AS LONG, lpSubKey AS ASCIIZ, BYVAL Reserved AS LONG, lpClass AS ASCIIZ, BYVAL dwOptions AS LONG, BYVAL samDesired AS LONG, _
              lpSecurityAttributes AS SECURITY_ATTRIBUTES, phkResult AS LONG, lpdwDisposition AS LONG) AS LONG
DECLARE FUNCTION RegDeleteKey LIB "ADVAPI32.DLL" ALIAS "RegDeleteKeyA" (BYVAL hKey AS LONG, lpSubKey AS ASCIIZ) AS LONG
DECLARE FUNCTION RegisterClassEx LIB "USER32.DLL" ALIAS "RegisterClassExA" (pcWndClassEx AS WNDCLASSEX) AS LONG
DECLARE FUNCTION RegisterClipboardFormat LIB "USER32.DLL" ALIAS "RegisterClipboardFormatA" (lpString AS ASCIIZ) AS LONG
DECLARE FUNCTION RegisterWindowMessage LIB "USER32.DLL" ALIAS "RegisterWindowMessageA" (lpString AS ASCIIZ) AS LONG
DECLARE FUNCTION RegOpenKeyEx LIB "ADVAPI32.DLL" ALIAS "RegOpenKeyExA" (BYVAL hKey AS LONG, lpSubKey AS ASCIIZ, BYVAL ulOptions AS LONG, BYVAL samDesired AS LONG, phkResult AS LONG) AS LONG
DECLARE FUNCTION RegQueryValueEx LIB "ADVAPI32.DLL" ALIAS "RegQueryValueExA" (BYVAL hKey AS LONG, lpValueName AS ASCIIZ, BYVAL lpReserved AS LONG, lpType AS LONG, lpData AS ANY, lpcbData AS LONG) AS LONG
DECLARE FUNCTION RegSetValueEx LIB "ADVAPI32.DLL" ALIAS "RegSetValueExA" (BYVAL hKey AS LONG, lpValueName AS ASCIIZ, BYVAL Reserved AS LONG, BYVAL dwType AS LONG, lpData AS ANY, BYVAL cbData AS LONG) AS LONG
DECLARE FUNCTION ReleaseCapture LIB "USER32.DLL" ALIAS "ReleaseCapture" () AS LONG
DECLARE FUNCTION ReleaseDC LIB "USER32.DLL" ALIAS "ReleaseDC" (BYVAL hwnd AS LONG, BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION RemoveProp LIB "USER32.DLL" ALIAS "RemovePropA" (BYVAL hwnd AS LONG, lpString AS ASCIIZ) AS LONG
DECLARE FUNCTION ReplaceText LIB "COMDLG32.DLL" ALIAS "ReplaceTextA" (lpfr AS FINDREPLACE) AS LONG
DECLARE FUNCTION ResetDC LIB "GDI32.DLL" ALIAS "ResetDCA" (BYVAL hdc AS LONG, lpInitData AS DEVMODE) AS LONG
DECLARE FUNCTION RestoreDC LIB "GDI32.DLL" ALIAS "RestoreDC" (BYVAL hdc AS LONG, BYVAL nSavedDC AS LONG) AS LONG
DECLARE FUNCTION ResumeThread LIB "KERNEL32.DLL" ALIAS "ResumeThread" (BYVAL hThread AS LONG) AS LONG
DECLARE FUNCTION RoundRect LIB "GDI32.DLL" ALIAS "RoundRect" (BYVAL hdc AS LONG, BYVAL X1 AS LONG, BYVAL Y1 AS LONG, BYVAL X2 AS LONG, BYVAL Y2 AS LONG, BYVAL X3 AS LONG, BYVAL Y3 AS LONG) AS LONG
DECLARE FUNCTION SaveDC LIB "GDI32.DLL" ALIAS "SaveDC" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION ScreenToClient LIB "USER32.DLL" ALIAS "ScreenToClient" (BYVAL hwnd AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION ScrollDC LIB "USER32.DLL" ALIAS "ScrollDC" (BYVAL hdc AS LONG, BYVAL dx AS LONG, BYVAL dy AS LONG, lprcScroll AS RECT, lprcClip AS RECT, BYVAL hrgnUpdate AS LONG, lprcUpdate AS RECT) AS LONG
DECLARE FUNCTION ScrollWindow LIB "USER32.DLL" ALIAS "ScrollWindow" (BYVAL hWnd AS LONG, BYVAL XAmount AS LONG, BYVAL YAmount AS LONG, lpRect AS RECT, lpClipRect AS RECT) AS LONG
DECLARE FUNCTION SelectClipRgn LIB "GDI32.DLL" ALIAS "SelectClipRgn" (BYVAL hdc AS LONG, BYVAL hRgn AS LONG) AS LONG
DECLARE FUNCTION SelectObject LIB "GDI32.DLL" ALIAS "SelectObject" (BYVAL hdc AS LONG, BYVAL hObject AS LONG) AS LONG
DECLARE FUNCTION SendMessage LIB "USER32.DLL" ALIAS "SendMessageA" (BYVAL hwnd AS LONG, BYVAL wMsg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) AS LONG
DECLARE FUNCTION SetAbortProc LIB "GDI32.DLL" ALIAS "SetAbortProc" (BYVAL hDC AS LONG, BYVAL lpAbortProc AS LONG) AS LONG
DECLARE FUNCTION SetBkColor LIB "GDI32.DLL" ALIAS "SetBkColor" (BYVAL hdc AS LONG, BYVAL crColor AS LONG) AS LONG
DECLARE FUNCTION SetBkMode LIB "GDI32.DLL" ALIAS "SetBkMode" (BYVAL hdc AS LONG, BYVAL nBkMode AS LONG) AS LONG
DECLARE FUNCTION SetBrushOrgEx LIB "GDI32.DLL" ALIAS "SetBrushOrgEx" (BYVAL hdc AS LONG, BYVAL nXOrg AS LONG, BYVAL nYOrg AS LONG, lppt AS POINTAPI) AS LONG
DECLARE FUNCTION SetCapture LIB "USER32.DLL" ALIAS "SetCapture" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION SetClipboardData LIB "USER32.DLL" ALIAS "SetClipboardData" (BYVAL wFormat AS LONG, BYVAL hMem AS LONG) AS LONG
DECLARE FUNCTION SetCursor LIB "USER32.DLL" ALIAS "SetCursor" (BYVAL hCursor AS LONG) AS LONG
DECLARE FUNCTION SetDIBits LIB "GDI32.DLL" ALIAS "SetDIBits" (BYVAL hdc AS LONG, BYVAL hBitmap AS LONG, BYVAL nStartScan AS LONG, BYVAL nNumScans AS LONG, lpBits AS ANY, lpBI AS BITMAPINFO, BYVAL wUsage AS LONG) AS LONG
DECLARE FUNCTION SetFocus LIB "USER32.DLL" ALIAS "SetFocus" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION SetForegroundWindow LIB "USER32.DLL" ALIAS "SetForegroundWindow" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION SetGraphicsMode LIB "GDI32.DLL" ALIAS "SetGraphicsMode" (BYVAL hdc AS LONG, BYVAL iMode AS LONG) AS LONG
DECLARE FUNCTION SetMapMode LIB "GDI32.DLL" ALIAS "SetMapMode" (BYVAL hdc AS LONG, BYVAL nMapMode AS LONG) AS LONG
DECLARE FUNCTION SetMenu LIB "USER32.DLL" ALIAS "SetMenu" (BYVAL hwnd AS LONG, BYVAL hMenu AS LONG) AS LONG
DECLARE FUNCTION SetMenuItemInfo LIB "USER32.DLL" ALIAS "SetMenuItemInfoA" (BYVAL hMenu AS LONG, BYVAL un AS LONG, BYVAL bool AS LONG, lpcMenuItemInfo AS MENUITEMINFO) AS LONG
DECLARE FUNCTION SetParent LIB "USER32.DLL" ALIAS "SetParent" (BYVAL hWndChild AS LONG, BYVAL hWndNewParent AS LONG) AS LONG
DECLARE FUNCTION SetPixel LIB "GDI32.DLL" ALIAS "SetPixel" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL crColor AS LONG) AS LONG
DECLARE FUNCTION SetPixelV LIB "GDI32.DLL" ALIAS "SetPixelV" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL crColor AS LONG) AS LONG
DECLARE FUNCTION SetPolyFillMode LIB "GDI32.DLL" ALIAS "SetPolyFillMode" (BYVAL hdc AS LONG, BYVAL nPolyFillMode AS LONG) AS LONG
DECLARE FUNCTION SetProp LIB "USER32.DLL" ALIAS "SetPropA" (BYVAL hwnd AS LONG, lpString AS ASCIIZ, BYVAL hData AS LONG) AS LONG
DECLARE FUNCTION SetROP2 LIB "GDI32.DLL" ALIAS "SetROP2" (BYVAL hdc AS LONG, BYVAL nDrawMode AS LONG) AS LONG
DECLARE FUNCTION SetScrollInfo LIB "USER32.DLL" ALIAS "SetScrollInfo" (BYVAL hWnd AS LONG, BYVAL n AS LONG, lpcScrollInfo AS SCROLLINFO, BYVAL bool AS LONG) AS LONG
DECLARE FUNCTION SetStretchBltMode LIB "GDI32.DLL" ALIAS "SetStretchBltMode" (BYVAL hdc AS LONG, BYVAL nStretchMode AS LONG) AS LONG
DECLARE FUNCTION SetTextCharacterExtra LIB "GDI32.DLL" ALIAS "SetTextCharacterExtra" (BYVAL hdc AS LONG, BYVAL nCharExtra AS LONG) AS LONG
DECLARE FUNCTION SetTextColor LIB "GDI32.DLL" ALIAS "SetTextColor" (BYVAL hdc AS LONG, BYVAL crColor AS LONG) AS LONG
DECLARE FUNCTION SetThreadPriority LIB "KERNEL32.DLL" ALIAS "SetThreadPriority" (BYVAL hThread AS LONG, BYVAL nPriority AS LONG) AS LONG
DECLARE FUNCTION SetTimer LIB "USER32.DLL" ALIAS "SetTimer" (BYVAL hWnd AS LONG, BYVAL nIDEvent AS LONG, BYVAL uElapse AS LONG, BYVAL lpTimerFunc AS LONG) AS LONG
DECLARE FUNCTION SetViewportExtEx LIB "GDI32.DLL" ALIAS "SetViewportExtEx" (BYVAL hdc AS LONG, BYVAL nX AS LONG, BYVAL nY AS LONG, lpSize AS SIZEL) AS LONG
DECLARE FUNCTION SetViewportOrgEx LIB "GDI32.DLL" ALIAS "SetViewportOrgEx" (BYVAL hdc AS LONG, BYVAL nX AS LONG, BYVAL nY AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION SetWindowExtEx LIB "GDI32.DLL" ALIAS "SetWindowExtEx" (BYVAL hdc AS LONG, BYVAL nX AS LONG, BYVAL nY AS LONG, lpSize AS SIZEL) AS LONG
DECLARE FUNCTION SetWindowLong LIB "USER32.DLL" ALIAS "SetWindowLongA" (BYVAL hwnd AS LONG, BYVAL nIndex AS LONG, BYVAL dwNewLong AS LONG) AS LONG
DECLARE FUNCTION SetWindowOrgEx LIB "GDI32.DLL" ALIAS "SetWindowOrgEx" (BYVAL hdc AS LONG, BYVAL nX AS LONG, BYVAL nY AS LONG, lpPoint AS POINTAPI) AS LONG
DECLARE FUNCTION SetWindowPos LIB "USER32.DLL" ALIAS "SetWindowPos" (BYVAL hwnd AS LONG, BYVAL hWndInsertAfter AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL cx AS LONG, BYVAL cy AS LONG, BYVAL wFlags AS LONG) AS LONG
DECLARE FUNCTION SetWindowRgn LIB "USER32.DLL" ALIAS "SetWindowRgn" (BYVAL hWnd AS LONG, BYVAL hRgn AS LONG, BYVAL bRedraw AS LONG) AS LONG
DECLARE FUNCTION SetWindowText LIB "USER32.DLL" ALIAS "SetWindowTextA" (BYVAL hwnd AS LONG, lpString AS ASCIIZ) AS LONG
DECLARE FUNCTION SHBrowseForFolder LIB "SHELL32.DLL" ALIAS "SHBrowseForFolderA" (lpbi AS BROWSEINFO) AS DWORD
DECLARE FUNCTION ShellExecute LIB "SHELL32.DLL" ALIAS "ShellExecuteA" (BYVAL hwnd AS LONG, lpOperation AS ASCIIZ, lpFile AS ASCIIZ, lpParameters AS ASCIIZ, lpDirectory AS ASCIIZ, BYVAL nShowCmd AS LONG) AS LONG
DECLARE FUNCTION Shell_NotifyIcon LIB "SHELL32.DLL" ALIAS "Shell_NotifyIconA" (BYVAL dwMessage AS LONG, lpData AS NOTIFYICONDATA) AS LONG
DECLARE FUNCTION SHGetFileInfo LIB "SHELL32.DLL" ALIAS "SHGetFileInfoA" (pszPath AS ASCIIZ, BYVAL dwFileAttributes AS LONG, psfi AS SHFILEINFO, BYVAL cbFileInfo AS LONG, BYVAL uFlags AS LONG) AS LONG
DECLARE FUNCTION SHGetPathFromIDList LIB "SHELL32.DLL" ALIAS "SHGetPathFromIDListA" (pidList AS ITEMIDLIST, lpBuffer AS ASCIIZ) AS LONG
DECLARE FUNCTION SHGetSpecialFolderLocation LIB "shell32.dll" ALIAS "SHGetSpecialFolderLocation" (BYVAL hwndOwner AS DWORD, BYVAL nFolder AS LONG, pidl AS ITEMIDLIST) AS DWORD
DECLARE FUNCTION ShowCursor LIB "USER32.DLL" ALIAS "ShowCursor" (BYVAL bShow AS LONG) AS LONG
DECLARE FUNCTION ShowOwnedPopups LIB "USER32.DLL" ALIAS "ShowOwnedPopups" (BYVAL hwnd AS LONG, BYVAL fShow AS LONG) AS LONG
DECLARE FUNCTION ShowScrollBar LIB "USER32.DLL" ALIAS "ShowScrollBar" (BYVAL hwnd AS LONG, BYVAL wBar AS LONG, BYVAL bShow AS LONG) AS LONG
DECLARE FUNCTION ShowWindow LIB "USER32.DLL" ALIAS "ShowWindow" (BYVAL hwnd AS LONG, BYVAL nCmdShow AS LONG) AS LONG
DECLARE FUNCTION SizeofResource LIB "KERNEL32.DLL" ALIAS "SizeofResource" (BYVAL hInstance AS LONG, BYVAL hResInfo AS LONG) AS LONG
DECLARE FUNCTION StartDoc LIB "GDI32.DLL" ALIAS "StartDocA" (BYVAL hdc AS LONG, lpdi AS DOCINFO) AS LONG
DECLARE FUNCTION StartPage LIB "GDI32.DLL" ALIAS "StartPage" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION StretchBlt LIB "GDI32.DLL" ALIAS "StretchBlt" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL nWidth AS LONG, BYVAL nHeight AS LONG, BYVAL hSrcDC AS LONG, BYVAL xSrc AS LONG, BYVAL ySrc AS LONG, _
              BYVAL nSrcWidth AS LONG, BYVAL nSrcHeight AS LONG, BYVAL dwRop AS LONG) AS LONG
DECLARE FUNCTION StretchDIBits LIB "GDI32.DLL" ALIAS "StretchDIBits" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL dx AS LONG, BYVAL dy AS LONG, BYVAL SrcX AS LONG, BYVAL SrcY AS LONG, BYVAL wSrcWidth AS LONG, _
              BYVAL wSrcHeight AS LONG, lpBits AS ANY, lpBitsInfo AS BITMAPINFO, BYVAL wUsage AS LONG, BYVAL dwRop AS LONG) AS LONG
DECLARE FUNCTION StrokeAndFillPath LIB "GDI32.DLL" ALIAS "StrokeAndFillPath" (BYVAL hdc AS LONG) AS LONG
DECLARE FUNCTION SuspendThread LIB "KERNEL32.DLL" ALIAS "SuspendThread" (BYVAL hThread AS LONG) AS LONG
DECLARE FUNCTION SystemParametersInfo LIB "USER32.DLL" ALIAS "SystemParametersInfoA" (BYVAL uAction AS LONG, BYVAL uParam AS LONG, BYVAL lpvParam AS DWORD, BYVAL fuWinIni AS LONG) AS LONG
DECLARE FUNCTION TextOut LIB "GDI32.DLL" ALIAS "TextOutA" (BYVAL hdc AS LONG, BYVAL x AS LONG, BYVAL y AS LONG, BYVAL lpString AS LONG, BYVAL nCount AS LONG) AS LONG
DECLARE FUNCTION TrackPopupMenuEx LIB "USER32.DLL" ALIAS "TrackPopupMenuEx" (BYVAL hMenu AS LONG, BYVAL un AS LONG, BYVAL n1 AS LONG, BYVAL n2 AS LONG, BYVAL hWnd AS LONG, lpTPMParams AS TPMPARAMS) AS LONG
DECLARE FUNCTION TranslateAccelerator LIB "USER32.DLL" ALIAS "TranslateAcceleratorA" (BYVAL hwnd AS LONG, BYVAL hAccTable AS LONG, lpMsg AS tagMSG) AS LONG
DECLARE FUNCTION TranslateMDISysAccel LIB "USER32.DLL" ALIAS "TranslateMDISysAccel" (BYVAL hWndClient AS LONG, lpMsg AS tagMSG) AS LONG
DECLARE FUNCTION TranslateMessage LIB "USER32.DLL" ALIAS "TranslateMessage" (lpMsg AS tagMSG) AS LONG
DECLARE FUNCTION UnregisterClass LIB "USER32.DLL" ALIAS "UnregisterClassA" (lpClassName AS ASCIIZ, BYVAL hInstance AS LONG) AS LONG
DECLARE FUNCTION UpdateWindow LIB "USER32.DLL" ALIAS "UpdateWindow" (BYVAL hwnd AS LONG) AS LONG
DECLARE FUNCTION WaitForInputIdle LIB "USER32.DLL" ALIAS "WaitForInputIdle" (BYVAL hProcess AS LONG, BYVAL dwMilliseconds AS LONG) AS LONG
DECLARE FUNCTION WideCharToMultiByte LIB "KERNEL32.DLL" ALIAS "WideCharToMultiByte" (BYVAL CodePage AS LONG, BYVAL dwFlags AS LONG, lpWideCharStr AS ASCIIZ, BYVAL cchWideChar AS LONG, lpMultiByteStr AS ASCIIZ, BYVAL cchMultiByte AS LONG, _
              lpDefaultChar AS ASCIIZ, BYVAL lpUsedDefaultChar AS LONG) AS LONG
DECLARE FUNCTION WindowFromPoint LIB "USER32.DLL" ALIAS "WindowFromPoint" (BYVAL xPoint AS LONG, BYVAL yPoint AS LONG) AS LONG
DECLARE FUNCTION WinHelp LIB "USER32.DLL" ALIAS "WinHelpA" (BYVAL hwnd AS LONG, lpHelpFile AS ASCIIZ, BYVAL wCommand AS LONG, BYVAL dwData AS LONG) AS LONG

'-----------------------------------------------------------------
' Declared Subs:  12
'-----------------------------------------------------------------
DECLARE SUB apiSleep LIB "KERNEL32.DLL" ALIAS "Sleep" (BYVAL dwMilliseconds AS LONG)
DECLARE SUB CoTaskMemFree LIB "ole32.dll" ALIAS "CoTaskMemFree" (BYVAL pMem AS DWORD)
DECLARE SUB DeleteCriticalSection LIB "KERNEL32.DLL" ALIAS "DeleteCriticalSection" (lpCriticalSection AS CRITICAL_SECTION)
DECLARE SUB DragAcceptFiles LIB "SHELL32.DLL" ALIAS "DragAcceptFiles" (BYVAL hwnd AS LONG, BYVAL fAccept AS LONG)
DECLARE SUB DragFinish LIB "SHELL32.DLL" ALIAS "DragFinish" (BYVAL hDrop AS LONG)
DECLARE SUB DrawInsert LIB "COMCTL32.DLL" ALIAS "DrawInsert" (BYVAL handParent AS LONG, BYVAL hLB AS LONG, BYVAL nItem AS LONG)
DECLARE SUB EnterCriticalSection LIB "KERNEL32.DLL" ALIAS "EnterCriticalSection" (lpCriticalSection AS CRITICAL_SECTION)
DECLARE SUB ImageList_EndDrag LIB "COMCTL32.DLL" ALIAS "ImageList_EndDrag" ()
DECLARE SUB InitCommonControlsEx LIB "COMCTL32.DLL" ALIAS "InitCommonControlsEx" (icc AS INIT_COMMON_CONTROLSEX)
DECLARE SUB InitializeCriticalSection LIB "KERNEL32.DLL" ALIAS "InitializeCriticalSection" (lpCriticalSection AS CRITICAL_SECTION)
DECLARE SUB LeaveCriticalSection LIB "KERNEL32.DLL" ALIAS "LeaveCriticalSection" (lpCriticalSection AS CRITICAL_SECTION)
DECLARE SUB PostQuitMessage LIB "USER32.DLL" ALIAS "PostQuitMessage" (BYVAL nExitCode AS LONG)
