#PBFORMS CREATED V1.51
'==============================================================================
'
'  Graphic.bas example for PBForms and PowerBASIC for Windows
'  Copyright (c) 2005 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  Graphic window demo
'
'==============================================================================

#COMPILE EXE
#DIM ALL

'--------------------------------------------------------------------------------------------------
'   ** Includes **
'--------------------------------------------------------------------------------------------------
#PBFORMS BEGIN INCLUDES
%USEMACROS = 1
#IF NOT %DEF(%WINAPI)
    #INCLUDE "WIN32API.INC"
#ENDIF
#IF NOT %DEF(%COMMCTRL_INC)
    #INCLUDE "COMMCTRL.INC"
#ENDIF
#INCLUDE "PBForms.INC"
#PBFORMS END INCLUDES
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Constants **
'--------------------------------------------------------------------------------------------------
#PBFORMS BEGIN CONSTANTS
%IDCANCEL     =    2
%IDC_GRAPHIC1 = 1001
%IDC_LABEL1   = 1002
%IDC_LABEL2   = 1005
%IDC_LISTBOX1 = 1004
%IDC_TEXTBOX1 = 1003
%IDD_DIALOG1  =  101
%IDOK         =    1
#PBFORMS END CONSTANTS
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Declarations **
'--------------------------------------------------------------------------------------------------
DECLARE CALLBACK FUNCTION ShowDIALOG1Proc()
DECLARE FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
#PBFORMS DECLARATIONS
'--------------------------------------------------------------------------------------------------
DECLARE SUB ShowDiagram (BYVAL hDlg AS LONG, BYVAL n AS SINGLE)
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Main Application Entry Point **
'--------------------------------------------------------------------------------------------------
FUNCTION PBMAIN()
    PBFormsInitComCtls (%ICC_WIN95_CLASSES OR %ICC_DATE_CLASSES OR %ICC_INTERNET_CLASSES)
    ShowDIALOG1 %HWND_DESKTOP
END FUNCTION
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** CallBacks **
'--------------------------------------------------------------------------------------------------
CALLBACK FUNCTION ShowDIALOG1Proc()
    LOCAL sTxt AS STRING

    SELECT CASE AS LONG CBMSG
        CASE %WM_INITDIALOG
            ' Initialization handler
            ' Begin by showing a graph for 2^y
            ShowDiagram (CBHNDL, 2)

        CASE %WM_NCACTIVATE
            STATIC hWndSaveFocus AS DWORD
            IF ISFALSE CBWPARAM THEN
                ' Save control focus
                hWndSaveFocus = GetFocus()
            ELSEIF hWndSaveFocus THEN
                ' Restore control focus
                SetFocus(hWndSaveFocus)
                hWndSaveFocus = 0
            END IF

        CASE %WM_COMMAND
            ' Process control notifications
            SELECT CASE AS LONG CBCTL
                CASE %IDC_GRAPHIC1

                CASE %IDC_LABEL1

                CASE %IDC_TEXTBOX1

                CASE %IDOK
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        CONTROL GET TEXT CBHNDL, %IDC_TEXTBOX1 TO sTxt
                        IF VAL(sTxt) > 0 THEN
                            LISTBOX RESET CBHNDL, %IDC_LISTBOX1
                            ShowDiagram (CBHNDL, VAL(sTxt))
                        ELSE
                            MSGBOX "Not a valid value. Try something like 2 or 1.5 instead..", _
                                   %MB_TASKMODAL, "Input error"
                        END IF
                        CONTROL SET FOCUS CBHNDL, %IDC_TEXTBOX1
                    END IF

                CASE %IDCANCEL
                    IF CBCTLMSG = %BN_CLICKED OR CBCTLMSG = 1 THEN
                        DIALOG END CBHNDL, 0
                    END IF

            END SELECT
    END SELECT
END FUNCTION
'--------------------------------------------------------------------------------------------------

'--------------------------------------------------------------------------------------------------
'   ** Dialogs **
'--------------------------------------------------------------------------------------------------
FUNCTION ShowDIALOG1(BYVAL hParent AS DWORD) AS LONG
    LOCAL lRslt AS LONG, sTxt AS STRING

#PBFORMS BEGIN DIALOG %IDD_DIALOG1->->
    LOCAL hDlg  AS DWORD

    DIALOG NEW hParent, "Graphic", 50, 51, 300, 221, %WS_POPUP OR %WS_BORDER OR %WS_DLGFRAME OR _
        %WS_SYSMENU OR %WS_CLIPSIBLINGS OR %WS_VISIBLE OR %DS_CENTER OR %DS_3DLOOK OR _
        %DS_NOFAILCREATE OR %DS_SETFONT, %WS_EX_CONTROLPARENT OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR, TO hDlg
    CONTROL ADD GRAPHIC, hDlg, %IDC_GRAPHIC1, "", 5, 5, 200, 210, %WS_CHILD OR %WS_VISIBLE, _
        %WS_EX_CLIENTEDGE
    GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1
    GRAPHIC COLOR -1, %WHITE
    GRAPHIC CLEAR
    CONTROL ADD LABEL,   hDlg, %IDC_LABEL1, "Input a number:", 230, 150, 50, 10
    CONTROL ADD TEXTBOX, hDlg, %IDC_TEXTBOX1, "", 230, 160, 50, 13, %WS_CHILD OR %WS_VISIBLE OR _
        %WS_TABSTOP OR %ES_CENTER OR %ES_AUTOHSCROLL, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD BUTTON,  hDlg, %IDOK, "Show graph", 230, 180, 50, 15
    DIALOG  SEND         hDlg, %DM_SETDEFID, %IDOK, 0
    CONTROL ADD BUTTON,  hDlg, %IDCANCEL, "&Close", 230, 200, 50, 15
    CONTROL ADD LISTBOX, hDlg, %IDC_LISTBOX1, , 210, 5, 85, 85, %WS_CHILD OR %WS_VISIBLE OR _
        %WS_TABSTOP OR %WS_VSCROLL OR %LBS_NOTIFY, %WS_EX_CLIENTEDGE OR %WS_EX_LEFT OR _
        %WS_EX_LTRREADING OR %WS_EX_RIGHTSCROLLBAR
    CONTROL ADD LABEL,   hDlg, %IDC_LABEL2, "Info text will go here", 210, 95, 85, 50
#PBFORMS END DIALOG

    CONTROL SET TEXT hDlg, %IDC_LABEL2, _
                     "Example of how to draw a graph in a Graphic control. " + _
                     "Input a number like 2 or 2.5 and get a graph showing " + _
                     "a curve for x^y."

    DIALOG SHOW MODAL hDlg, CALL ShowDIALOG1Proc TO lRslt

#PBFORMS BEGIN CLEANUP %IDD_DIALOG1
#PBFORMS END CLEANUP

    FUNCTION = lRslt
END FUNCTION


'====================================================================
SUB ShowDiagram (BYVAL hDlg AS LONG, BYVAL n AS SINGLE)
'--------------------------------------------------------------------
  ' Simple routine that draws a graph for n^0 - n^0.1, etc.
  '------------------------------------------------------------------

  LOCAL b, c, x, h, w, hGW AS LONG, y AS EXT, sResult AS STRING

  b =  40
  h = 450
  w = 430

  GRAPHIC ATTACH hDlg, %IDC_GRAPHIC1, REDRAW
  GRAPHIC SCALE (0, 0) - (w, h)
  GRAPHIC COLOR RGB(0,0,0), RGB(255,255,255)
  GRAPHIC CLEAR

  '------------------------------------------------------------------
  ' DRAW GRID LINES
  '------------------------------------------------------------------
  GRAPHIC FONT "Arial", 10, 1
  GRAPHIC SET POS (15, h - b + 5)
  GRAPHIC PRINT STR$(n) + "^"

  GRAPHIC FONT "Courier New", 5, 1
  GRAPHIC WIDTH 1                                          '
  FOR x = 0 TO h - b STEP 10  ' draw horizontal lines
      y = h - b - x
      IF x AND x MOD 100 = 0 THEN
          GRAPHIC LINE (b, y) - (w+2, y), RGB(191,0,0)
      ELSE
          GRAPHIC LINE (b, y) - (w+2, y), RGB(191,191,191)
      END IF

      IF x THEN
          GRAPHIC SET POS (b - 25, y - 6)
          GRAPHIC PRINT USING$("###", x)
      END IF
  NEXT

  FOR x = b TO w STEP (w \ 10)  ' draw vertical lines
      IF x MOD (b + w \ 2) = 0 THEN
          GRAPHIC LINE (x, 0) - (x, h - b), RGB(0,191,191)  ' MIN&(w - b, x)
      ELSE
          GRAPHIC LINE (x, 0) - (x, h - b), RGB(191,191,191)
      END IF

      IF c THEN
          GRAPHIC SET POS (x - 3, h - b + 5)
          GRAPHIC PRINT FORMAT$(c)
      END IF
      INCR c
  NEXT

  '------------------------------------------------------------------
  ' DRAW GRAPH AND CREATE TABLE IN LISTBOX
  '------------------------------------------------------------------
  GRAPHIC SET POS (b, h - b)
  GRAPHIC WIDTH 2
  FOR x = 0 TO w - b
      y = n ^ (x / (w \ 10))           ' Calculate y point
      IF y < 32000 THEN
          GRAPHIC LINE STEP - (b + x, h - y - b), RGB(0,0,255)
      END IF
      IF x MOD (w \ 10) = 0 THEN
          sResult = STR$(n) + "^" + FORMAT$(x / (w \ 10)) + " =" + STR$(y)
          LISTBOX ADD hDlg, %IDC_LISTBOX1, sResult
      END IF
  NEXT

  GRAPHIC WIDTH 1
  GRAPHIC PAINT REPLACE (5, 5), RGB(239,239,239), RGB(255,255,255), 7

  GRAPHIC REDRAW

END SUB
