' *************************************************************************************
'                    Copyright Christopher R. Boss 1999 to 2006
'                               All Rights reserved !
'                Licensed users of EZGUI 4.0 may use this code Royalty Free
' *************************************************************************************

DECLARE FUNCTION EZ_SCANRECORD  LIB "ezgui5bt.dll" (BYVAL SPOS&, BYVAL F$, BYVAL CMP$, BYVAL P1&, BYVAL P2&, DBRET$, BYVAL AL& ) AS LONG
DECLARE FUNCTION EZ_REBALANCEBTREE  LIB "ezgui5bt.dll" (BYVAL F$, BYVAL KL&, BYVAL DL& , BYVAL IMAX&, BYVAL CBAddress AS DWORD) AS LONG
DECLARE FUNCTION EZ_IMPORTBTREE LIB "ezgui5bt.dll" (BYVAL TStart&, BYVAL F$, BYVAL TF$, BYVAL FL1&, BYVAL FL2&, BYVAL FL3&, BYVAL FL4&, BYVAL FL5&, BYVAL FL6&, BYVAL FL7&, BYVAL FL8&, BYVAL PS$, BYVAL CBAddress AS DWORD) AS LONG
DECLARE FUNCTION EZ_ADDRECORD  LIB "ezgui5bt.dll" (BYVAL F$, BYVAL DB$, BYVAL KL& ) AS LONG
DECLARE FUNCTION EZ_FINDRECORD  LIB "ezgui5bt.dll" (BYVAL F$, BYVAL DB$, DBRET$, BYVAL KL&) AS LONG
DECLARE FUNCTION EZ_SAVERECORD  LIB "ezgui5bt.dll" (BYVAL F$, BYVAL DB$, BYVAL KL&) AS LONG
DECLARE FUNCTION EZ_RANDOMIZE  LIB "ezgui5bt.dll" (BYVAL F$, BYVAL F2$, BYVAL MAXI&) AS LONG
