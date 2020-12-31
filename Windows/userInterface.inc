
#INCLUDE "win32api.inc"
''''Return values
%MB_YES = 6
'%MB_OK = 1
%MB_NO = 7
%MB_Cancel = 2
%MB_Abort = 3
%MB_RETRY = 4
%MB_IGNORE = 5
'''''Type of MessageBox
'%MB_OKOnly
'%MB_OKCANCEL
'''''Displays OK AND CANCEL buttons.
'%MB_AbortRetryIgnore
'''''Displays Abort, Retry, AND Ignore buttons.
'%MB_YesNoCancel
'''''Displays Yes, No, and Cancel buttons.
'%MB_YesNo
'''''Displays Yes and No buttons.
'%MB_RetryCancel
'''''Displays Retry and Cancel buttons.
'%MB_Critical
'''''Displays Critical Message icon.
'%MB_Question
'''''Displays Warning Query icon.
'%MB_Exclamation
'''''Displays Warning Message icon.
'%MB_Information

DECLARE FUNCTION KLJMessageBox LIB "UIdll.DLL" _
          ALIAS "KLJMessageBox" (BYREF Message AS STRING , BYREF title AS STRING, BYVAL typebox AS LONG)  AS LONG
DECLARE FUNCTION KLJInput LIB "UIdll.DLL" _
         ALIAS "KLJInput" (BYREF prompt AS STRING , BYREF title AS STRING, BYREF defaultstring AS STRING, BYVAL xpos AS LONG, BYVAL ypos AS LONG)  AS STRING
