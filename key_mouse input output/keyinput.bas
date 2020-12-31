'=======================================================================
'     KEYBOARD INTERCEPTION TOOL  by Maciej Neyman.
'Born out of frustration, produced with great help from members of this forum.
'This program is released as a tool for the members of the Power Basic fraternity
'with thanks for the help in my projects.
'Feel free to use and modify the code. This Program is NOT for sale.
'The program is not perfect. For instance it does not trap the F10 key,
'but it traps most of the keys, a specially arrows, and I think it may be a good
'tool for those who want quickly to learn and implement keys trapping in theirs programs.
'The relevant lines on the display window are referred to the source code as the “Code Block's”
'If you come with an improvement please post it here so all PB users can get the benefit.
'
'Disclaimer:
'This code is provided as-is and it does not have any warranty of any kind.
'If it causes collapse of the Universe, the Author does not want to know it.
'Refer that case to Inteligent Designer and blame Billy G. for it.
'
'User is  responsible for any use and/or misuse of the code.
'If you don't agree please don't use this code.
'=====================================================================

#COMPILE EXE
#REGISTER NONE
DEFLNG A-Z
#INCLUDE "Win32Api.Inc"
GLOBAL Finito&
GLOBAL V AS LONG
GLOBAL S AS STRING
DECLARE FUNCTION fVKDDT
DECLARE FUNCTION ClearDisp

%IDC_TEXT1    = 141
%IDC_TEXT2    = 142
%IDC_TEXT3    = 143
%IDC_TEXT4    = 144
%IDC_TEXT5    = 145
%IDC_TEXT6    = 146
%IDC_TEXT7    = 147
%IDC_TEXT8    = 148
%IDC_TEXT9    = 149
%IDC_TEXT10   = 150

%IDC_LABEL11    = 211
%IDC_LABEL12    = 212

CALLBACK FUNCTION hDlg_CB   ' Callback procedure for the main dialog

 SELECT CASE AS LONG CBMSG
  CASE %WM_DESTROY: Finito = 1

  CASE %WM_INITDIALOG
      ' %WM_INITDIALOG is sent right before the dialog is shown.
  '------------------------------------------------------------------
  CASE %WM_COMMAND                ' <- a control is calling
      SELECT CASE AS LONG CBCTL   ' <- look at control's id
      '--------------------------------------------------------------
      CASE %IDOK                  ' <- Ok or Enter key was pressed

          IF CBCTLMSG = %BN_CLICKED THEN
                   'Enter key is beheaving here as the TAB key!
              SELECT CASE GetDlgCtrlId(GetFocus) 'Which control has focus?
              CASE %IDC_TEXT1 TO %IDC_TEXT8
                  IF (GetKeyState(%VK_SHIFT) AND &H8000) = 0 THEN   'move focus

                      ' Is the above line another posibility to trap some keys?

                      SetFocus GetNextDlgTabItem(CBHNDL, GetFocus, 0)
                  ELSE 'Shift + Enter = move to previous control
                      SetFocus GetNextDlgTabItem(CBHNDL, GetFocus, 1)
                  END IF

              CASE %IDOK  ' If Ok button has focus

                   MSGBOX "%IDOK", %MB_TASKMODAL, "DDT Equate"   ' your code here

              CASE %IDCANCEL  ' If Cancel button has focus
                  DIALOG END CBHNDL, 0   '<- End prog

              END SELECT
        END IF
       '----------------------------------------------
      CASE %IDCANCEL  ' <- Cancel button was pressed
          IF CBCTLMSG = %BN_CLICKED THEN
              DIALOG END CBHNDL, 0   '<- End prog
          END IF
      '--------------------------------------------------------------
      END SELECT
   END SELECT

END FUNCTION

FUNCTION PBMAIN()

GLOBAL hDlg AS DWORD

  DIALOG NEW 0, "Keyboard Interception Tool by M.Neyman",,, 350, 200, _
                 %DS_CENTER OR %WS_CAPTION OR %WS_SYSMENU, 0 TO hDlg

  '------------------------------------------------------------------
  CONTROL ADD LABEL, hDlg, -1, "&Text Box",   5,  7, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT1, "Press any key", 55,  5, 100, 13
  CONTROL ADD LABEL, hDlg, %IDC_LABEL11, "INTERCEPTED USING:",   180,  7, 100, 10
  CONTROL SET COLOR  hDlg, %IDC_LABEL11, %RED, -1

  CONTROL ADD LABEL, hDlg, -1, "&Code Block 2",      5, 27, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT2, "", 55, 25, 100, 13
  CONTROL ADD LABEL, hDlg, -1, "%WM_SYSKEYDOWN  (-Alt- key used)",   160,  27, 150, 10

  CONTROL ADD LABEL, hDlg, -1, "C&ode Block 3",      5, 47, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT3, "", 55, 45, 100, 13
  CONTROL ADD LABEL, hDlg, -1, "%WM_KEYUP",   160,  47, 75, 10

  CONTROL ADD LABEL, hDlg, -1, "Co&de Block 4",      5, 67, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT4, "", 55, 65, 100, 13
  CONTROL ADD LABEL, hDlg, -1, "%VK_CONTROL - %WM_KEYUP",   160,  67, 125, 10

  CONTROL ADD LABEL, hDlg, -1, "Cod&e Block 5",      5, 87, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT5, "", 55, 85, 100, 13
  CONTROL ADD LABEL, hDlg, -1, "%VK_SHIFT - %WM_KEYUP",   160,  87, 105, 10

  CONTROL ADD LABEL, hDlg, -1, "Code &Block 6",      5, 107, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT6, "", 55, 105, 100, 13
  CONTROL ADD LABEL, hDlg, -1, "%WM_CHAR",   160,  107, 75, 10

  CONTROL ADD LABEL, hDlg, -1, "Code B&lock 7",      5, 127, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT7, "", 55, 125, 100, 13
  CONTROL ADD LABEL, hDlg, -1, "%WM_KEYUP",   160,  127, 75, 10

  CONTROL ADD LABEL, hDlg, -1, "Code Bloc&k 8",      5, 147, 45, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT8, "", 55, 145, 100, 13
  CONTROL ADD LABEL, hDlg, -1, "%WM_KEYDOWN",   160,  147, 70, 10

  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT10, "", 225, 105, 15, 13
  CONTROL ADD LABEL, hDlg, -1, "Character",    245, 108, 45, 10

  CONTROL ADD LABEL, hDlg, %IDC_LABEL12, "DDT EQUATE :",     250, 137, 70, 10
  CONTROL ADD TEXTBOX, hDlg, %IDC_TEXT9, "",                 225, 147, 100, 13
  CONTROL SET COLOR  hDlg, %IDC_LABEL12, %RED, -1


  CONTROL ADD BUTTON, hDlg, %IDOK,     "Ok",       82, 175, 50, 14
  CONTROL ADD BUTTON, hDlg, %IDCANCEL, "&Cancel", 136, 175, 50, 14

     DIALOG SHOW MODELESS hDlg CALL hDlg_CB

'------------------------------------------------------------------

 LOCAL Mes AS tagMsg  ' Windows inherent sub classing (Win32API)! Look under MSG

 DO WHILE GetMessage(Mes, %NULL, 0, 0)

'============
'Code Block 6
'============
 SELECT CASE Mes.message
'---------------------------
 CASE %WM_CHAR               ' interception of the mainly printable characters

     Info6$ = "DEC = " + STR$(Mes.wParam)+ "     HEX = " + HEX$(Mes.wParam)
     CONTROL SET TEXT hDlg, %IDC_TEXT6, Info6$        ' put your code here
     CONTROL SET TEXT hDlg, %IDC_TEXT10, CHR$(Mes.wParam)
     Info6$ = ""
'=============
' Code Block 2
'=============
CASE %WM_SYSKEYDOWN
  SELECT CASE Mes.wParam
    CASE %VK_LEFT  : Info2$ = " ALT + LEFT ARROW"
    CASE %VK_RIGHT : Info2$ = " ALT + RIGHT ARROW"
    CASE %VK_DOWN  : Info2$ = " ALT + ARROW DOWN"
    CASE %VK_UP    : Info2$ = " ALT + ARROW UP"
    CASE %VK_RETURN: Info2$ = " ALT + ENTER"
    CASE 1 TO 255  : Info2$ = " DEC = " + STR$(Mes.wParam)+ "     HEX = " + HEX$(Mes.wParam)
  END SELECT
  CALL ClearDisp
 CONTROL SET TEXT hDlg, %IDC_TEXT2, Info2$
 Info2$ =""
'=============
' Code Block 8
'=============
CASE %WM_KEYDOWN
 SELECT CASE Mes.wParam
'You can use all tests(CASE's) from %WM_KEYUP option with interesting
'results. However thy are omited here for clarity. You can experiment
'with them if you wish.
 CASE 27
     Finito = 1
     MSGBOX "You have pressed Escape key, the program will terminate" + _
            $CRLF + $CRLF + "  DDT Equate =  %VK_ESCAPE,    DEC = 27,   HEX = 1B, " +  _
            $CRLF + $CRLF + "   intercepted using   %WM_KEYDOWN   -  Code Block 8"
                 'Info2$ = "" :CONTROL SET TEXT hDlg, %IDC_TEXT2, ""   'cleaning display
 CASE 1 TO 255 : Info8$ ="DEC = " + STR$(Mes.wParam)+ "     HEX = " + HEX$(Mes.wParam)  'interception of all keys
     V = Mes.wParam                          ' value for the translation into %VK_xxx equate
     CALL ClearDisp
     CONTROL SET TEXT hDlg, %IDC_TEXT8, Info8$          ' your code here
     CALL fVKDDT()                                      ' your code here
     CONTROL SET TEXT hDlg, %IDC_TEXT9, S    ' S = %VK_xxx equate derived from value of V (above)
     Info8$ = ""
  END SELECT
'============
'Code Block 3
'============
CASE %WM_KEYUP

SELECT CASE Mes.wParam
CASE %VK_LEFT  : Info3$ = " LEFT ARROW"
CASE %VK_RIGHT : Info3$ = " RIGHT ARROW"
CASE %VK_DOWN  : Info3$ = " ARROW DOWN"
CASE %VK_UP    : Info3$ = " ARROW UP"
CASE %VK_RETURN: Info3$ = " Enter"
    '------------
    'Code Block 7
    '------------
CASE 1 TO 255 : Info7$ ="DEC = " + STR$(Mes.wParam)+ "     HEX = " + HEX$(Mes.wParam)  'interception of keyboard keys
TranslateMessage Mes                                                                    'yours code here
DispatchMessage Mes
END SELECT

CONTROL SET TEXT hDlg, %IDC_TEXT3, Info3$     ' your code here
Info3$ = ""  'clear "sticky" message
CONTROL SET TEXT hDlg, %IDC_TEXT7, Info7$     ' your code here
Info7$ = ""  'clear "sticky" message

'=============
' Code Block 4
'=============
IF ISTRUE(LOWRD(GetKeyState(%VK_CONTROL)) AND &H8000) THEN  'interception of Ctrl + character keys
SELECT CASE Mes.wParam
CASE %VK_LEFT : Info4$ = "Ctrl + LEFT ARROW"
CASE %VK_RIGHT: Info4$ = "Ctrl + RIGHT ARROW"
CASE %VK_DOWN : Info4$ = "Ctrl + ARROW DOWN"
CASE %VK_UP   : Info4$ = "Ctrl + ARROW UP"
CASE %VK_RETURN:Info4$ = "Ctrl + ENTER"
CASE 1 TO 255 : Info4$ = "Ctrl+" + CHR$(Mes.wParam)+ ";  DEC =" + STR$(Mes.wParam)+ "   HEX = " + HEX$(Mes.wParam)
END SELECT
CONTROL SET TEXT hDlg, %IDC_TEXT4, Info4$      ' your code here
 Info4$ = ""

'=============
' Code Block 5
'=============
ELSEIF ISTRUE(LOWRD(GetKeyState(%VK_SHIFT)) AND &H8000) THEN  'interception of Shift + character keys
SELECT CASE Mes.wParam
CASE %VK_LEFT : Info5$ = "SHIFT + LEFT ARROW"
CASE %VK_RIGHT: Info5$ = "SHIFT + RIGHT ARROW"
CASE %VK_DOWN : Info5$ = "SHIFT + ARROW DOWN"
CASE %VK_UP   : Info5$ = "SHIFT + ARROW UP"
CASE %VK_RETURN:Info5$ = "Shift + ENTER"
CASE 30 TO 90 : Info5$ = "SHIFT + " + CHR$(Mes.wParam)
END SELECT

CONTROL SET TEXT hDlg, %IDC_TEXT5, Info5$      'your code here
Info5$ =""
END IF

END SELECT

 IF IsDialogMessage(hDlg, Mes) = %FALSE THEN
    TranslateMessage Mes
    DispatchMessage Mes
 END IF
IF Finito <> 0 THEN EXIT DO
LOOP
END FUNCTION

'-------------------------------------------
FUNCTION ClearDisp
     CONTROL SET TEXT hDlg, %IDC_TEXT2, ""    'removal
     CONTROL SET TEXT hDlg, %IDC_TEXT3, ""    'of the
     CONTROL SET TEXT hDlg, %IDC_TEXT4, ""    'previous
     CONTROL SET TEXT hDlg, %IDC_TEXT5, ""    'displays
     CONTROL SET TEXT hDlg, %IDC_TEXT6, ""
     CONTROL SET TEXT hDlg, %IDC_TEXT7, ""
     CONTROL SET TEXT hDlg, %IDC_TEXT8, ""
     CONTROL SET TEXT hDlg, %IDC_TEXT9, ""
     CONTROL SET TEXT hDlg, %IDC_TEXT10,""
END FUNCTION
'================================
FUNCTION fVKDDT                      'placement of the DDT equates into array
'--------------------------------    'for the display purpose only.
DIM VKDDT(255) AS STRING             'not important for your coding

VKDDT(1) = "%VK_LBUTTON"
VKDDT(2) = "%VK_RBUTTON"
VKDDT(3) = "%VK_CANCEL"
VKDDT(4) = "%VK_MBUTTON"
VKDDT(5) = "%VK_XBUTTON1"
VKDDT(6) = "%VK_XBUTTON2"
VKDDT(8) = "%VK_BACK"
VKDDT(9) = "%VK_TAB"
VKDDT(10) = "%VK_LINEFEED"
VKDDT(12) = "%VK_CLEAR"
VKDDT(13) = "%VK_RETURN"
VKDDT(16) = "%VK_SHIFT"
VKDDT(17) = "%VK_CONTROL"
VKDDT(18) = "%VK_MENU"
VKDDT(19) = "%VK_PAUSE"
VKDDT(20) = "%VK_CAPITAL"
VKDDT(21) = "%VK_KANA "
VKDDT(22) = "%VK_HANGUL"
VKDDT(23) = "%VK_JUNJA"
VKDDT(24) = "%VK_FINAL"
VKDDT(25) = "%VK_HANJA"
VKDDT(26) = "%VK_KANJI"
VKDDT(27) = "%VK_ESCAPE"
VKDDT(28) = "%VK_CONVERT"
VKDDT(29) = "%VK_NONCONVERT"
VKDDT(30) = "%VK_ACCEPT"
VKDDT(31) = "%VK_MODECHANGE"
VKDDT(32) = "%VK_SPACE"
VKDDT(33) = "%VK_PGUP"
VKDDT(34) = "%VK_NEXT"
VKDDT(34) = "%VK_PGDN"
VKDDT(35) = "%VK_END"
VKDDT(36) = "%VK_HOME"
VKDDT(37) = "%VK_LEFT"
VKDDT(38) = "%VK_UP"
VKDDT(39) = "%VK_RIGHT"
VKDDT(40) = "%VK_DOWN "
VKDDT(41) = "%VK_SELECT"
VKDDT(42) = "%VK_PRINT"
VKDDT(43) = "%VK_EXECUTE "
VKDDT(44) = "%VK_SNAPSHOT"
VKDDT(45) = "%VK_INSERT "
VKDDT(46) = "%VK_DELETE "
VKDDT(47) = "%VK_HELP "
VKDDT(48) = "%VK_0"
VKDDT(49) = "%VK_1"
VKDDT(50) = "%VK_2"
VKDDT(51) = "%VK_3"
VKDDT(52) = "%VK_4"
VKDDT(53) = "%VK_5"
VKDDT(54) = "%VK_6"
VKDDT(55) = "%VK_7"
VKDDT(56) = "%VK_8"
VKDDT(57) = "%VK_9"
VKDDT(65) = "%VK_A"
VKDDT(66) = "%VK_B"
VKDDT(67) = "%VK_C"
VKDDT(68) = "%VK_D"
VKDDT(69) = "%VK_E"
VKDDT(70) = "%VK_F"
VKDDT(71) = "%VK_G"
VKDDT(72) = "%VK_H"
VKDDT(73) = "%VK_I"
VKDDT(74) = "%VK_J"
VKDDT(75) = "%VK_K"
VKDDT(76) = "%VK_L"
VKDDT(77) = "%VK_M"
VKDDT(78) = "%VK_N"
VKDDT(79) = "%VK_O"
VKDDT(80) = "%VK_P"
VKDDT(81) = "%VK_Q"
VKDDT(82) = "%VK_R"
VKDDT(83) = "%VK_S"
VKDDT(84) = "%VK_T"
VKDDT(85) = "%VK_U"
VKDDT(86) = "%VK_V"
VKDDT(87) = "%VK_W"
VKDDT(88) = "%VK_X"
VKDDT(89) = "%VK_Y"
VKDDT(90) = "%VK_Z"
VKDDT(91) = "%VK_LWIN"
VKDDT(92) = "%VK_RWIN"
VKDDT(93) = "%VK_APPS"
VKDDT(95) = "%VK_SLEEP"
VKDDT(96) = "%VK_NUMPAD0"
VKDDT(97) = "%VK_NUMPAD1"
VKDDT(98) = "%VK_NUMPAD2"
VKDDT(99) = "%VK_NUMPAD3"
VKDDT(100) = "%VK_NUMPAD4"
VKDDT(101) = "%VK_NUMPAD5"
VKDDT(102) = "%VK_NUMPAD6"
VKDDT(103) = "%VK_NUMPAD7"
VKDDT(104) = "%VK_NUMPAD8"
VKDDT(105) = "%VK_NUMPAD9"
VKDDT(106) = "%VK_MULTIPLY"
VKDDT(107) = "%VK_ADD"
VKDDT(108) = "%VK_SEPARATOR"
VKDDT(109) = "%VK_SUBTRACT "
VKDDT(110) = "%VK_DECIMAL "
VKDDT(111) = "%VK_DIVIDE"
VKDDT(112) = "%VK_F1"
VKDDT(113) = "%VK_F2"
VKDDT(114) = "%VK_F3"
VKDDT(115) = "%VK_F4"
VKDDT(116) = "%VK_F5"
VKDDT(117) = "%VK_F6"
VKDDT(118) = "%VK_F7"
VKDDT(119) = "%VK_F8"
VKDDT(120) = "%VK_F9"
VKDDT(121) = "%VK_F10"
VKDDT(122) = "%VK_F11"
VKDDT(123) = "%VK_F12"
VKDDT(124) = "%VK_F13"
VKDDT(125) = "%VK_F14"
VKDDT(126) = "%VK_F15"
VKDDT(127) = "%VK_F16"
VKDDT(128) = "%VK_F17"
VKDDT(129) = "%VK_F18"
VKDDT(130) = "%VK_F19"
VKDDT(131) = "%VK_F20"
VKDDT(132) = "%VK_F21"
VKDDT(133) = "%VK_F22"
VKDDT(134) = "%VK_F23"
VKDDT(135) = "%VK_F24"
VKDDT(144) = "%VK_NUMLOCK "
VKDDT(145) = "%VK_SCROLL "
VKDDT(146) = "%VK_OEM_NEC_EQUAL"
VKDDT(147) = "%VK_OEM_FJ_MASSHOU"
VKDDT(148) = "%VK_OEM_FJ_TOUROKU"
VKDDT(149) = "%VK_OEM_FJ_LOYA"
VKDDT(150) = "%VK_OEM_FJ_ROYA"
VKDDT(160) = "%VK_LSHIFT"
VKDDT(161) = "%VK_RSHIFT"
VKDDT(162) = "%VK_LCONTROL"
VKDDT(163) = "%VK_RCONTROL"
VKDDT(164) = "%VK_LMENU"
VKDDT(165) = "%VK_RMENU"
VKDDT(166) = "%VK_BROWSER_BACK"
VKDDT(167) = "%VK_BROWSER_FORWARD"
VKDDT(168) = "%VK_BROWSER_REFRESH"
VKDDT(169) = "%VK_BROWSER_STOP"
VKDDT(170) = "%VK_BROWSER_SEARCH "
VKDDT(171) = "%VK_BROWSER_FAVORITES"
VKDDT(172) = "%VK_BROWSER_HOME"
VKDDT(173) = "%VK_VOLUME_MUTE"
VKDDT(174) = "%VK_VOLUME_DOWN"
VKDDT(175) = "%VK_VOLUME_UP"
VKDDT(176) = "%VK_MEDIA_NEXT_TRACK"
VKDDT(177) = "%VK_MEDIA_PREV_TRACK"
VKDDT(178) = "%VK_MEDIA_STOP"
VKDDT(179) = "%VK_MEDIA_PLAY_PAUSE "
VKDDT(180) = "%VK_LAUNCH_MAIL"
VKDDT(181) = "%VK_LAUNCH_MEDIA_SELECT"
VKDDT(182) = "%VK_LAUNCH_APP1"
VKDDT(183) = "%VK_LAUNCH_APP2"
VKDDT(186) = "%VK_OEM_1"
VKDDT(187) = "%VK_OEM_PLUS"
VKDDT(188) = "%VK_OEM_COMMA"
VKDDT(189) = "%VK_OEM_MINUS"
VKDDT(190) = "%VK_OEM_PERIOD"
VKDDT(191) = "%VK_OEM_2"
VKDDT(192) = "%VK_OEM_3"
VKDDT(219) = "%VK_OEM_4"
VKDDT(220) = "%VK_OEM_5"
VKDDT(221) = "%VK_OEM_6 "
VKDDT(222) = "%VK_OEM_7"
VKDDT(223) = "%VK_OEM_8"
VKDDT(225) = "%VK_OEM_AX"
VKDDT(226) = "%VK_OEM_102"
VKDDT(227) = "%VK_ICO_HELP"
VKDDT(228) = "%VK_ICO_00"
VKDDT(229) = "%VK_PROCESSKEY"
VKDDT(230) = "%VK_ICO_CLEAR"
VKDDT(231) = "%VK_PACKET"
VKDDT(233) = "%VK_OEM_RESET"
VKDDT(234) = "%VK_OEM_JUMP"
VKDDT(235) = "%VK_OEM_PA1"
VKDDT(236) = "%VK_OEM_PA2 "
VKDDT(237) = "%VK_OEM_PA3 "
VKDDT(238) = "%VK_OEM_WSCTRL"
VKDDT(239) = "%VK_OEM_CUSEL"
VKDDT(240) = "%VK_OEM_ATTN"
VKDDT(241) = "%VK_OEM_FINISH"
VKDDT(242) = "%VK_OEM_COPY"
VKDDT(243) = "%VK_OEM_AUTO"
VKDDT(244) = "%VK_OEM_ENLW"
VKDDT(245) = "%VK_OEM_BACKTAB"
VKDDT(246) = "%VK_ATTN"
VKDDT(247) = "%VK_CRSEL"
VKDDT(248) = "%VK_EXSEL"
VKDDT(249) = "%VK_EREOF"
VKDDT(250) = "%VK_PLAY "
VKDDT(251) = "%VK_ZOOM "
VKDDT(252) = "%VK_NONAME"
VKDDT(253) = "%VK_PA1"
VKDDT(254) = "%VK_OEM_CLEAR"

S = VKDDT(V)

END FUNCTION
'==========================
