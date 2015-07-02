#COMPILE EXE
   #DIM ALL
   #INCLUDE "WIN32API.INC"

   GLOBAL OldDialogProc AS DWORD

'----------------------------------------------------------

   FUNCTION MyDialogProc( BYVAL hWnd   AS DWORD, BYVAL wMsg   AS DWORD, _
                          BYVAL wParam AS DWORD, BYVAL lParam AS DWORD) AS DWORD

      SELECT CASE wMsg
         CASE %WM_KEYDOWN
           MSGBOX "MyDialogProc: WM_KEYDOWN"
      END SELECT

      FUNCTION = CallWindowProc( OldDialogProc, hWnd, wMsg, wParam, lParam )

   END FUNCTION

'----------------------------------------------------------

   CALLBACK FUNCTION DlgProc() AS LONG

      SELECT CASE AS LONG CBMSG

         CASE %WM_INITDIALOG
            OldDialogProc = SetWindowLong( CBHNDL, %GWL_WNDPROC, CODEPTR(MyDialogProc) )

         CASE %WM_KEYDOWN
            MSGBOX "DlgProc: WM_KEYDOWN"

      END SELECT

   END FUNCTION

'----------------------------------------------------------

   FUNCTION PBMAIN()

      LOCAL hDlg AS DWORD

      DIALOG NEW 0, "KeyEvent",,, 100, 100, %WS_OVERLAPPEDWINDOW, %WS_EX_TOPMOST TO hDlg
      CONTROL ADD BUTTON, hDlg, 1234, "Button", 30, 30, 50, 14
      DIALOG SHOW MODAL hDlg CALL DlgProc

   END FUNCTION
