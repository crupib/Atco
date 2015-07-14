'AtcoNDT Library - written by Bill Crupi
'comportlist - returns FTDI comm ports

DECLARE FUNCTION comportlist LIB "atcondt_lib.dll" _
         ALIAS "comportlist" (BYREF parm1() AS STRING) AS LONG
