$COMPILE EXE
$INCLUDE "win32api.inc"

GLOBAL hDlg AS LONG, hTimer AS LONG

CALLBACK FUNCTION CbMain
  SELECT CASE CBMSG
    CASE %WM_INITDIALOG
      hTimer = SetTimer (CBHNDL, &hFFFF, 50, BYVAL 0)
    CASE %WM_DESTROY
      KillTimer hDlg, &hFFFF
    CASE %WM_TIMER
      DIALOG SET TEXT hDlg,TIME$
      DIALOG REDRAW hDlg
  END SELECT
END FUNCTION

FUNCTION PBMAIN () AS LONG
  LOCAL COUNT AS LONG
  DIALOG NEW 0, "Test", 50, 50, 195, 75,%WS_SYSMENU TO  hDlg
  DIALOG SHOW MODELESS hDlg, CALL CbMain
  DO
    DIALOG DOEVENTS TO COUNT
  LOOP WHILE COUNT
END FUNCTION
