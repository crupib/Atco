
GLOBAL ghMsgHook   AS DWORD

FUNCTION MsgFilterProc _
  ( _
  BYVAL nCode   AS LONG, _
  BYVAL wParam  AS DWORD, _
  BYVAL lParam  AS LONG _
  ) AS LONG

  LOCAL ptmsg     AS tagMSG PTR
  LOCAL lRetVal   AS LONG
  LOCAL wm AS WORD

  lRetVal = CallNextHookEx(ghMsgHook, nCode, wParam, BYVAL lParam)
  ptmsg = lParam
  IF nCode = %MSGF_DIALOGBOX THEN
    IF @ptmsg.message = %WM_KEYDOWN THEN
'        IF wParam = %VK_DOWN THEN
'            CALL MoveYVel(NegDir)
'            CALL GetXyPos
'            CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
'            CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
'            CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
            lRetVal = 0  ' 1
        END IF
 '       IF wParam = %VK_UP THEN
 '           CALL MoveYVel(PosDir)
 '               CALL GetXyPos
 '               CONTROL SET TEXT hDlg5, %IDC_LABEL_XPOSAJOG, SCANstruc.XPosStr
 '               CONTROL SET TEXT hDlg5, %IDC_LABEL_YPOSAJOG, SCANstruc.YPosStr
 '               CONTROL SET TEXT hDlg5, %IDC_LABEL_APOSAJOG, SCANstruc.APosStr
 '           lRetVal = 0  ' 1
 '       END IF
 '    END IF
  END IF

  FUNCTION = lRetVal

END FUNCTION

 '   ghMsgHook = SetWindowsHookEx(%WH_MSGFILTER, CODEPTR(MsgFilterProc), %NULL, GetCurrentThreadId())
 '   UnhookWindowsHookEx ghMsgHook
