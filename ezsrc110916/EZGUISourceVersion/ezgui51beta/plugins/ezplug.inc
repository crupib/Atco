' *************************************************************************************
'         Copyright 2001 to 2006 Christopher R. Boss , All Rights Reserved !
'                   Royalty Free right to use provided EZGUI code by
'                      Developers of EZGUI 4.0 Form Plugins !
'             The code may be used ROYALTY FREE by registered EZGUI 4.0 users !
' -------------------------------------------------------------------------------------------

' *************************************************************************************
' Minimal Declares for EZGUI Plugin Form Display

DECLARE SUB EZ_Form  LIB "ezgui45.dll" (BYVAL FormName$, BYVAL Parent$, BYVAL Caption$, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL Style$)
DECLARE SUB EZ_GetScreenSize  LIB "ezgui45.dll" ( SW&, SH&)
DECLARE FUNCTION EZ_CX LIB "ezgui45.dll" (BYVAL X&) AS SINGLE
DECLARE FUNCTION EZ_CY LIB "ezgui45.dll" (BYVAL Y&) AS SINGLE
DECLARE SUB EZ_Label  LIB "ezgui45.dll" (BYVAL IDNum&, BYVAL C!, BYVAL R!, BYVAL W!, BYVAL H!, BYVAL CText$, BYVAL CProp$)
DECLARE SUB EZ_ShowForm  LIB "ezgui45.dll" (BYVAL FormName$)
DECLARE FUNCTION EZ_Handle LIB "ezgui45.dll" (BYVAL FormName$, BYVAL ID&) AS LONG
