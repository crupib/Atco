'==============================================================================
'
'  Address.bas for PowerBASIC for Windows
'  Copyright (c) 1999-2011 PowerBASIC, Inc.
'  All Rights Reserved.
'
'  A simple application to test MyDLL.DLL
'
'==============================================================================

#COMPILER PBWIN 10
#COMPILE EXE

'--------------------------------------------------------------------
DECLARE FUNCTION MyFunction1 LIB "MYDLL.DLL" _
          ALIAS "MyFunction1" (BYVAL Param1 AS LONG) AS LONG
DECLARE FUNCTION LOAD_FILE LIB "MYDLL.DLL" _
          ALIAS "Load_File" () AS STRING
'--------------------------------------------------------------------

FUNCTION PBMAIN () AS LONG
    LOCAL lRes AS LONG
    LOCAL filename AS STRING
    lres = 9
    lRes = MyFunction1(lRes)  ' call MyFunction1 in My.DLL

    MSGBOX "Exe result from MYDLL.DLL:" + STR$(lRes)
    filename =  LOAD_FILE()
    MSGBOX "FileName = " + filename

END FUNCTION
