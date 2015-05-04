
#COMPILE EXE
#DIM ALL
#INCLUDE "WIN32API.INC"
GLOBAL gOldEditClassProc AS LONG

CALLBACK FUNCTION MainDlgProc
   LOCAL i AS LONG
   SELECT CASE CBMSG
      CASE %WM_INITDIALOG
         'Subclass the editbox control
         STATIC hEdit AS LONG
         CONTROL HANDLE CBHNDL, 100 TO hEdit
         gOldEditClassProc = SetWindowLong(hEdit, %GWL_WNDPROC, CODEPTR(EditSubClassProc))
      CASE %WM_KEYDOWN
         IF CBCTL = 100 THEN
            IF CBLPARAM = %VK_RETURN THEN
               DIALOG SET TEXT CBHNDL, "Return"
            ELSEIF CBLPARAM = %VK_UP THEN
               DIALOG SET TEXT CBHNDL, "Up"
            ELSE
               DIALOG SET TEXT CBHNDL, "Capture Keys"
            END IF
         END IF
      CASE %WM_DESTROY
         'Important! Remove the subclassing
         SetWindowLong hEdit, %GWL_WNDPROC, gOldEditClassProc
   END SELECT
END FUNCTION

FUNCTION EditSubClassProc(BYVAL hWnd&, BYVAL wMsg&, BYVAL wParm&, BYVAL lParm&) AS LONG
   SELECT CASE wMsg&
      CASE %WM_KEYUP
         DIALOG SEND GetParent(hWnd&), %WM_KEYDOWN, 100, wParm&
   END SELECT
   ' Pass the message on to the original window procedure... the DDT engine!
   FUNCTION = CallWindowProc(gOldEditClassProc, hWnd&, wMsg&, wParm&, lParm&)
END FUNCTION

FUNCTION PBMAIN()
   LOCAL STYLE AS LONG, hDlg AS LONG
   STYLE = %WS_SYSMENU OR %WS_MINIMIZEBOX
   DIALOG NEW 0, "Capture Keys", , , 150, 80, STYLE TO hDlg
   CONTROL ADD TEXTBOX, hDlg, 100, "", 20, 10, 100, 40, %ES_MULTILINE OR %WS_BORDER OR %ES_WANTRETURN
   DIALOG SHOW MODAL hDlg, CALL mainDlgProc
END FUNCTION
