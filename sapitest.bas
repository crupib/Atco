'Code to find hardware info, minimum Win98 or Win2000 (No 95 or NT4).
'Make use of the setupapi DLL.
'Will find modem port for any modem, PCMCIA, WinModem etc...
'Will find infrared port devices, serial or parallel ...
'Will find USB, scanner, SCSI, display, mouse, keyboard, CDRom, HID, etc...
'Icon are from setupapi's dll imagelist.

'Info about ClassName and ClassGUID:  http://www.osr.com/ddk/install/setup-cls_2i1z.htm

'Have fun, Pierre

'Updated on 2008/01/05 - SetupDiOpenDevRegKey will now work as it should.

#COMPILE EXE '#Win 8.04#
#DIM ALL
#REGISTER NONE
#INCLUDE "Win32Api.Inc" '#2005-01-27#

%Listbox1                          = 101

%ClassName                         = 001
%GuidTxt                           = 002
%Friendly                          = 003
%DevDesc                           = 004
%DevDriver                         = 005
%PortName                          = 006
%Manufacturer                      = 007

%DIGCF_DEFAULT                     = 001
%DIGCF_PRESENT                     = 002
%DIGCF_ALLCLASSES                  = 004
%DIGCF_PROFILE                     = 008
%DIGCF_DEVICEINTERFACE             = 016

%MAX_CLASS_NAME_LEN                = 128

%DIREG_DEV                         = 001
%DIREG_DRV                         = 002

%DICS_FLAG_GLOBAL                  = 001
%DICS_FLAG_CONFIGSPECIFIC          = 002

%SPDRP_DEVICEDESC                  = 000
%SPDRP_HARDWAREID                  = 001
%SPDRP_COMPATIBLEIDS               = 002
%SPDRP_SERVICE                     = 004
%SPDRP_CLASS                       = 007
%SPDRP_CLASSGUID                   = 008
%SPDRP_DRIVER                      = 009
%SPDRP_CONFIGFLAGS                 = 010
%SPDRP_MFG                         = 011
%SPDRP_FRIENDLYNAME                = 012
%SPDRP_LOCATION_INFORMATION        = 013
%SPDRP_PHYSICAL_DEVICE_OBJECT_NAME = 014
%SPDRP_CAPABILITIES                = 015
%SPDRP_UI_NUMBER                   = 016
%SPDRP_UPPERFILTERS                = 017
%SPDRP_LOWERFILTERS                = 018
%SPDRP_BUSTYPEGUID                 = 019
%SPDRP_LEGACYBUSTYPE               = 020
%SPDRP_BUSNUMBER                   = 021
%SPDRP_ENUMERATOR_NAME             = 022
%SPDRP_SECURITY                    = 023
%SPDRP_SECURITY_SDS                = 024
%SPDRP_DEVTYPE                     = 025
%SPDRP_EXCLUSIVE                   = 026
%SPDRP_CHARACTERISTICS             = 027
%SPDRP_ADDRESS                     = 028
%SPDRP_UI_NUMBER_DESC_FORMAT       = 030

TYPE SP_CLASSIMAGELIST_DATA
  cbSize              AS DWORD
  hImageList          AS DWORD
  Reserved            AS DWORD
END TYPE

TYPE SP_DEVINFO_DATA
  cbSize              AS DWORD
  ClassGuid           AS GUIDAPI
  DevInst             AS DWORD
  Reserved            AS DWORD
END TYPE

TYPE SP_DEVICE_INTERFACE_DATA
  cbSize              AS DWORD
  InterfaceClassGuid  AS GUIDAPI
  Flags               AS DWORD
  Reserved            AS DWORD PTR
END TYPE

TYPE SP_DEVICE_INTERFACE_DETAIL_DATA
  cbSize              AS DWORD
  DevicePath          AS ASCIIZ * 512
END TYPE

DECLARE FUNCTION SetupDiLoadClassIcon LIB "SetupApi.DLL" ALIAS "SetupDiLoadClassIcon"( _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF hIconBig                      AS DWORD  , _
  BYREF ImageIndex                    AS LONG) AS LONG

DECLARE FUNCTION SetupDiGetClassImageList LIB "SetupApi.DLL" ALIAS "SetupDiGetClassImageList"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA) AS LONG

DECLARE FUNCTION SetupDiGetClassImageListEx LIB "SetupApi.DLL" ALIAS "SetupDiGetClassImageListExA"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA, _
  BYREF MachineName                   AS ASCIIZ                , _
  BYVAL Reserved                      AS DWORD) AS LONG

DECLARE FUNCTION SetupDiDestroyClassImageList LIB "SetupApi.DLL" ALIAS "SetupDiDestroyClassImageList"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA) AS LONG

DECLARE FUNCTION SetupDiGetClassImageIndex LIB "SetupApi.DLL" ALIAS "SetupDiGetClassImageIndex"( _
  BYREF ClassImageListData            AS SP_CLASSIMAGELIST_DATA, _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF ImageIndex                    AS LONG) AS LONG

DECLARE FUNCTION SetupDiOpenClassRegKey LIB "SetupApi.DLL" ALIAS "SetupDiOpenClassRegKey"( _
  BYREF ClassGuidList                 AS GUIDAPI, _
  BYREF samDesired                    AS DWORD) AS LONG

DECLARE FUNCTION SetupDiOpenClassRegKeyEx LIB "SetupApi.DLL" ALIAS "SetupDiOpenClassRegKeyExA"( _
  BYREF ClassGuidList                 AS GUIDAPI, _
  BYREF samDesired                    AS DWORD  , _
  BYREF Flags                         AS DWORD  , _
  BYREF MachineName                   AS ASCIIZ , _
  BYREF Reserved                      AS DWORD) AS LONG

DECLARE FUNCTION SetupDiEnumDeviceInfo LIB "SetupApi.DLL" ALIAS "SetupDiEnumDeviceInfo"( _
  BYVAL hDeviceInfoSet                AS DWORD, _
  BYVAL MemberIndex                   AS DWORD, _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA) AS LONG

DECLARE FUNCTION SetupDiClassGuidsFromName LIB "SetupApi.DLL" ALIAS "SetupDiClassGuidsFromNameA"( _
  BYREF ClassName                     AS ASCIIZ , _
  BYREF ClassGuidList                 AS GUIDAPI, _
  BYREF ClassGuidListSize             AS DWORD  , _
  BYREF RequiredSize                  AS DWORD) AS LONG

DECLARE FUNCTION SetupDiClassNameFromGuid LIB "SetupApi.DLL" ALIAS "SetupDiClassNameFromGuidA"( _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF ClassName                     AS ASCIIZ , _
  BYVAL ClassNameSize                 AS DWORD  , _
  BYREF RequiredSize                  AS DWORD) AS LONG

 DECLARE FUNCTION SetupDiGetClassDevs LIB "SetupApi.DLL" ALIAS "SetupDiGetClassDevsA"( _
  BYREF ClassGuid                     AS GUIDAPI, _
  BYREF Enumerator                    AS ASCIIZ , _
  BYVAL hwndParent                    AS DWORD  , _
  BYVAL Flags                         AS DWORD) AS DWORD

DECLARE FUNCTION SetupDiEnumDeviceInterfaces LIB "SetupApi.DLL" ALIAS "SetupDiEnumDeviceInterfaces"( _
  BYVAL hDeviceInfoSet                AS DWORD          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA, _
  BYREF InterfaceClassGuid            AS GUIDAPI        , _
  BYVAL MemberIndex                   AS DWORD          , _
  BYREF DeviceInterfaceData           AS SP_DEVICE_INTERFACE_DATA) AS LONG

DECLARE FUNCTION SetupDiGetDeviceRegistryProperty LIB "SetupApi.DLL" ALIAS "SetupDiGetDeviceRegistryPropertyA"( _
  BYVAL hDeviceInfoSet                AS DWORD          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA, _
  BYVAL Property                      AS LONG           , _
  BYREF PropertyRegDataType           AS LONG           , _
  BYREF PropertyBuffer                AS ASCIIZ         , _
  BYVAL PropertyBufferSize            AS DWORD          , _
  BYREF RequiredSize                  AS DWORD) AS LONG

DECLARE FUNCTION SetupDiGetDeviceInterfaceDetail LIB "SetupApi.DLL" ALIAS "SetupDiGetDeviceInterfaceDetailA"( _
  BYVAL hDeviceInfoSet                AS DWORD                          , _
  BYREF DeviceInterfaceData           AS SP_DEVICE_INTERFACE_DATA       , _
  BYREF DeviceInterfaceDetailData     AS SP_DEVICE_INTERFACE_DETAIL_DATA, _
  BYVAL DeviceInterfaceDetailDataSize AS DWORD                          , _
  BYREF RequiredSize                  AS DWORD                          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA) AS LONG

DECLARE FUNCTION SetupDiDestroyDeviceInfoList LIB "SetupApi.DLL" ALIAS "SetupDiDestroyDeviceInfoList"( _
  BYVAL hDeviceInfoSet                AS DWORD) AS LONG

DECLARE FUNCTION SetupDiOpenDevRegKey LIB "SetupApi.DLL" ALIAS "SetupDiOpenDevRegKey"( _
  BYVAL hDeviceInfoSet                AS DWORD          , _
  BYREF DeviceInfoData                AS SP_DEVINFO_DATA, _
  BYVAL Scope                         AS DWORD          , _
  BYVAL HwProfile                     AS DWORD          , _
  BYVAL KeyType                       AS DWORD          , _
  BYVAL samDesired                    AS DWORD) AS LONG

DECLARE FUNCTION SetupDiOpenDeviceInterfaceRegKey LIB "SetupApi.DLL" ALIAS "SetupDiOpenDeviceInterfaceRegKey"( _
  BYVAL hDeviceInfoSet                AS DWORD                   , _
  BYREF DeviceInterfaceData           AS SP_DEVICE_INTERFACE_DATA, _
  BYVAL Reserved                      AS DWORD                   , _
  BYVAL samDesired                    AS DWORD) AS LONG
'______________________________________________________________________________

FUNCTION GetDeviceInfo(Device AS STRING, InfoArray() AS STRING) AS LONG
 LOCAL zClassName                AS ASCIIZ * %MAX_CLASS_NAME_LEN
 LOCAL zBuffer                   AS ASCIIZ * %MAX_CLASS_NAME_LEN
 LOCAL DeviceInterfaceData       AS SP_DEVICE_INTERFACE_DATA
 LOCAL DeviceInfoData            AS SP_DEVINFO_DATA
 LOCAL hDeviceInfoSet            AS DWORD
 LOCAL RequiredSize              AS DWORD
 LOCAL hKeyDevice                AS DWORD
 LOCAL HwProfile                 AS DWORD
 LOCAL PropertyRegDataType       AS DWORD
 LOCAL DevCount                  AS LONG
 LOCAL Retval                    AS LONG
 LOCAL DeviceCount               AS LONG
 LOCAL Looper                   AS LONG

 FOR Looper = 1 TO PARSECOUNT(Device, "/")
   zClassName = PARSE$(Device, "/", Looper)
   DevCount = 0

   Retval = SetupDiClassGuidsFromName(zClassName, BYVAL 0, BYVAL 0, RequiredSize)
   IF RequiredSize THEN
     REDIM GuidArray(1 TO RequiredSize) AS GUIDAPI
     Retval = SetupDiClassGuidsFromName(zClassName, GuidArray(1), _
                                        SIZEOF(GUIDAPI) * RequiredSize, RequiredSize)
   ELSE
     ITERATE
   END IF

   'Get info by ClassGUID, like GUID$("{4D36E978E325-11CE-BFC1-08002BE10318})" for "Ports"
   hDeviceInfoSet = SetupDiGetClassDevs(GuidArray(1), BYVAL %NULL, BYVAL %NULL, %DIGCF_PRESENT)

   'Get info by registry keyname like "FLOP" in "HKEY_LOCAL_MACHINE\Enum\FLOP"
   'zBuffer = "Flop" 'For floppy
   'hDeviceInfoSet = SetupDiGetClassDevs(byval %NULL, zBuffer, BYVAL %NULL, %DIGCF_PRESENT OR %DIGCF_ALLCLASSES)

   'List all devices
   'hDeviceInfoSet = SetupDiGetClassDevs(byval %NULL, BYVAL %NULL, BYVAL %NULL, %DIGCF_PRESENT OR %DIGCF_ALLCLASSES)

   IF hDeviceInfoSet = %INVALID_HANDLE_VALUE THEN ITERATE
   DeviceInfoData.cbSize      = SIZEOF(DeviceInfoData)
   DeviceInterfaceData.CbSize = SIZEOF(DeviceInterfaceData)

   DO 'Loop to get all devices of a class

     'Get a device based on DevCount, exit if no more
     Retval = SetupDiEnumDeviceInfo(hDeviceInfoSet, DevCount, DeviceInfoData)
     IF Retval = 0 THEN EXIT DO 'Last device

     INCR DeviceCount
     REDIM PRESERVE InfoArray(1 TO 7, 1 TO DeviceCount)

     InfoArray(%ClassName, DeviceCount) = zClassName
     InfoArray(%GuidTxt, DeviceCount) =  GUIDTXT$(GuidArray(DeviceCount))

     'Get friendly name
     zBuffer = ""
     Retval = SetupDiGetDeviceRegistryProperty( _
                hDeviceInfoSet      , _
                DeviceInfoData      , _
                %SPDRP_FRIENDLYNAME , _ 'Get friendly name
                PropertyRegDataType , _
                zBuffer             , _ 'Like "Communication port (COM1)"
                SIZEOF(zBuffer)     , _
                RequiredSize)
     InfoArray(%Friendly, DeviceCount) = zBuffer

     'Get device description
     zBuffer = "None"
     Retval = SetupDiGetDeviceRegistryProperty( _
                hDeviceInfoSet      , _
                DeviceInfoData      , _
                %SPDRP_DEVICEDESC   , _
                PropertyRegDataType , _
                zBuffer             , _
                SIZEOF(zBuffer)     , _
                RequiredSize)
     InfoArray(%DevDesc, DeviceCount) = zBuffer

     'Get Device driver
     zBuffer = "None"
     Retval = SetupDiGetDeviceRegistryProperty( _
                hDeviceInfoSet      , _
                DeviceInfoData      , _
                %SPDRP_DRIVER       , _
                PropertyRegDataType , _
                zBuffer             , _
                SIZEOF(zBuffer)     , _
                RequiredSize)
     InfoArray(%DevDriver, DeviceCount) = zBuffer

     'Get device manufacturer
     zBuffer = ""
     Retval = SetupDiGetDeviceRegistryProperty( _
                hDeviceInfoSet      , _
                DeviceInfoData      , _
                %SPDRP_MFG          , _
                PropertyRegDataType , _
                zBuffer             , _
                SIZEOF(zBuffer)     , _
                RequiredSize)
     InfoArray(%Manufacturer, DeviceCount) = zBuffer

     'Get a handle to the current registry, where device was found
     hKeyDevice = SetupDiOpenDevRegKey( _
                    hDeviceInfoSet    , _
                    DeviceInfoData    , _
                    %DICS_FLAG_GLOBAL , _
                    HwProfile         , _
                    %DIREG_DEV        , _
                    %KEY_QUERY_VALUE)

     'Get PortName
     zBuffer = ""
     Retval = RegQueryValueEx( _
                hKeyDevice        , _  'Handle of key to query
                BYCOPY "portname" , _  'Address of name of value to query
                BYVAL %NULL       , _  'Reserved
                BYVAL %NULL       , _  'Address of buffer for value type
                zBuffer           , _  'Address of data buffer
                SIZEOF(zBuffer))       'Address of data buffer size
     RegCloseKey hKeyDevice
     InfoArray(%PortName,  DeviceCount) = zBuffer

     INCR DevCount
   LOOP

   IF hDeviceInfoSet THEN
     SetupDiDestroyDeviceInfoList hDeviceInfoSet
     hDeviceInfoSet = 0
   END IF

 NEXT

 FUNCTION = DeviceCount

END FUNCTION
'______________________________________________________________________________

CALLBACK FUNCTION DlgProc
 STATIC ClassImageListData        AS SP_CLASSIMAGELIST_DATA
 LOCAL  lpdis                     AS DRAWITEMSTRUCT PTR
 LOCAL  zClassName                AS ASCIIZ * %MAX_CLASS_NAME_LEN
 LOCAL  zTxt                      AS ASCIIZ * 300
 LOCAL  zBuf                      AS ASCIIZ * 300
 LOCAL  GuidInfo                  AS GUIDAPI
 LOCAL  rc                        AS RECT
 LOCAL  Looper                    AS LONG
 LOCAL  DeviceCount               AS LONG
 LOCAL  itd                       AS LONG
 LOCAL  Retval                    AS LONG
 STATIC hList                     AS DWORD
 STATIC hImageList                AS DWORD
 LOCAL  hIcon                     AS DWORD
 LOCAL  ImageIndex                AS DWORD
 LOCAL  RequiredSize              AS DWORD
 LOCAL  IconPos                   AS DWORD
 LOCAL  Device                    AS STRING
 DIM    InfoArray(1 TO 7, 1 TO 1) AS STRING

 SELECT CASE CBMSG
   CASE %WM_INITDIALOG
     ClassImageListData.cbSize = SIZEOF(ClassImageListData)
     SetupDiGetClassImageList ClassImageListData
     hImageList = ClassImageListData.hImageList

     CONTROL HANDLE CBHNDL, %Listbox1 TO hList
     CONTROL SEND CBHNDL, %Listbox1, %LB_SETITEMHEIGHT, 0, 20
     CONTROL SEND CBHNDL, %LISTBOX1, %LB_SETHORIZONTALEXTENT, 1200, 0

     'The complete list
     Device = "1394/1394debug/61883/adapter/apmsupport/avc/battery/biometric/" & _
              "bluetooth/cdrom/computer/decoder/diskdrive/display/"            & _
              "dot4print/enum1394/fdc/floppydisk/gps/hdc/hidclass/image/"      & _
              "infrared/keyboard/legacydriver/media/mediumchanger/mtd/modem/"  & _
              "monitor/mouse/multifunction/multiportserial/net/netclient/"     & _
              "netservice/nettrans/nodriver/pcmcia/ports/printer/"             & _
              "printer upgrade/pnpprinters/processor/sbp2/scsiadapter/"        & _
              "security accelerator/smartcardreader/sound/system/tapedrive/"   & _
              "unknown/usb/volume/volumesnapshot/wceusbs"
     'Device = "Ports/Modem/Printer"     'Try this
     'Device = "Modem"                   'or this
     'Device = "Ports"                   'or this...
     'Device = "Infrared"                'or this...
     'Device = "Image"                   'or this...

     'The next function will return an hardware description array based on the device string
     DeviceCount = GetDeviceInfo(Device, InfoArray())

     'Fill listbox with data and icon
     LISTBOX ADD CBHNDL, %Listbox1, $TAB & "*** Dialog is resizable ***"
     LISTBOX ADD CBHNDL, %Listbox1, "FriendlyName," & $TAB & "Manufacturer and Port like COM1 or LPT1 are shown for some items"
     LISTBOX ADD CBHNDL, %Listbox1, "Devices found: " & $TAB & FORMAT$(DeviceCount)
     LISTBOX ADD CBHNDL, %Listbox1, STRING$(75, "-")
     LISTBOX SELECT CBHNDL, %Listbox1, 4
     IconPos = 4
     FOR Looper = 1 TO DeviceCount
       zClassName = InfoArray(%ClassName, Looper)
       Retval = SetupDiClassGuidsFromName(zClassName, GuidInfo, SIZEOF(GuidInfo) , RequiredSize)
       Retval = SetupDiLoadClassIcon(GuidInfo, hIcon, ImageIndex )
       LISTBOX ADD CBHNDL, %Listbox1, "Class: " & $TAB & InfoArray(%ClassName, Looper)
       CONTROL SEND CBHNDL, %Listbox1, %LB_SETITEMDATA, IconPos, hIcon
       LISTBOX ADD CBHNDL, %Listbox1, "Guid: "  & $TAB & InfoArray(%GuidTxt, Looper)
       IF LEN(InfoArray(%Friendly, Looper)) THEN
         LISTBOX ADD CBHNDL, %Listbox1, "FriendlyName: " & $TAB & InfoArray(%Friendly, Looper)
         INCR IconPos
       END IF
       LISTBOX ADD CBHNDL, %Listbox1, "Description: " & $TAB & InfoArray(%DevDesc, Looper)
       IF LEN(InfoArray(%Manufacturer, Looper)) THEN
         LISTBOX ADD CBHNDL, %Listbox1, "Manufacturer: " & $TAB & InfoArray(%Manufacturer, Looper)
         INCR IconPos
       END IF
       LISTBOX ADD CBHNDL, %Listbox1, "Driver: " & $TAB & InfoArray(%DevDriver, Looper)

       IF LEN(InfoArray(%PortName, Looper)) THEN
         MSGBOX InfoArray(%PortName, Looper)
         LISTBOX ADD CBHNDL, %Listbox1, "PortName: " & $TAB & InfoArray(%PortName, Looper)
         INCR IconPos
       END IF
       LISTBOX ADD CBHNDL, %Listbox1, STRING$(75, "-")
       IconPos = IconPos + 5
     NEXT

   CASE %WM_SIZE
     MoveWindow hList, 0, 0, LOWRD(CBLPARAM), HIWRD(CBLPARAM), %TRUE
     FUNCTION = 0
     EXIT FUNCTION

   CASE %WM_COMMAND
     SELECT CASE LOWRD(CBWPARAM)
       CASE %IDCANCEL
       DIALOG END CBHNDL, 0
     END SELECT

   CASE %WM_DESTROY
     IF ClassImageListData.hImageList THEN
       SetupDiDestroyClassImageList ClassImageListData
     END IF

   CASE %WM_DRAWITEM, %WM_MEASUREITEM  'Thank's to Borje
     IF CBWPARAM = %Listbox1 THEN
       lpdis = CBLPARAM
       IF @lpdis.itemID = &HFFFFFFFF THEN EXIT FUNCTION

       SELECT CASE @lpdis.itemAction
         CASE %ODA_DRAWENTIRE, %ODA_SELECT
           'CLEAR BACKGROUND
           IF (@lpdis.itemState AND %ODS_SELECTED) = 0 THEN                         'if not selected
             FillRect @lpdis.hDC, @lpdis.rcItem, GetSysColorBrush(%COLOR_WINDOW)    'clear background
             CALL SetBkColor(@lpdis.hDC, GetSysColor(%COLOR_WINDOW))                'text background
             CALL SetTextColor(@lpdis.hDC, GetSysColor(%COLOR_WINDOWTEXT))          'text color
           ELSE
             FillRect @lpdis.hDC, @lpdis.rcItem, GetSysColorBrush(%COLOR_HIGHLIGHT) 'clear background
             CALL SetBkColor(@lpdis.hDC, GetSysColor(%COLOR_HIGHLIGHT))             'text background
             CALL SetTextColor(@lpdis.hDC, GetSysColor(%COLOR_HIGHLIGHTTEXT))       'text color
           END IF

           'DRAW TEXT
           CALL SendMessage(GetDlgItem(CBHNDL, %Listbox1), %LB_GETTEXT, @lpdis.itemID, VARPTR(zTxt)) 'Get text
           rc = @lpdis.rcItem
           rc.nLeft = 35
           zBuf = LEFT$(zTxt, INSTR(zTxt, $TAB) - 1)
           CALL DrawText(@lpdis.hDC, zBuf, LEN(zBuf), rc, %DT_SINGLELINE OR %DT_LEFT OR %DT_VCENTER)
           zBuf = MID$(zTxt, INSTR(zTxt, $TAB) + 1)
           rc.nLeft = rc.nLeft + 75
           CALL DrawText(@lpdis.hDC, zBuf, LEN(zBuf), rc, %DT_SINGLELINE OR %DT_LEFT OR %DT_VCENTER)

           'DRAW ICON
           itd = SendMessage(GetDlgItem(CBHNDL, %Listbox1), %LB_GETITEMDATA, @lpdis.itemID, 0)
           IF itd THEN
             CALL DrawIconEx(@lpdis.hDC, @lpdis.rcItem.nLeft + 3, @lpdis.rcItem.ntop + 1, _
                             itd, 18, 18, 0, 0, %DI_NORMAL)
           END IF
           FUNCTION = %TRUE : EXIT FUNCTION

       END SELECT

     END IF
     FUNCTION = 0
     EXIT FUNCTION

 END SELECT
END FUNCTION
'______________________________________________________________________________

FUNCTION PBMAIN
 LOCAL hDlg AS DWORD

 DIALOG NEW %HWND_DESKTOP, "Hardware devices enumeration", , , 350, 300, _
            %WS_OVERLAPPEDWINDOW OR %DS_MODALFRAME, 0 TO hDlg

 CONTROL ADD LISTBOX, hDlg, %Listbox1,, 5, 5, 340, 290, %WS_CHILD OR %WS_VISIBLE OR %LBS_NOTIFY OR _
             %WS_TABSTOP OR %WS_HSCROLL OR %WS_VSCROLL OR %LBS_USETABSTOPS OR  %LBS_OWNERDRAWFIXED _
             OR %LBS_HASSTRINGS, %WS_EX_CLIENTEDGE

 DIALOG SHOW MODAL hDlg CALL DlgProc

END FUNCTION
'_________________________________________
