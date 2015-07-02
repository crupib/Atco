#COMPILE EXE
#DIM ALL
#REGISTER NONE
#INCLUDE "Win32Api.Inc"
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

FUNCTION PBMAIN () AS LONG

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
 DIM    comlist(10) AS STRING
 LOCAL  comlistidx AS INTEGER
 LOCAL  I AS INTEGER
     ClassImageListData.cbSize = SIZEOF(ClassImageListData)
     SetupDiGetClassImageList ClassImageListData
     hImageList = ClassImageListData.hImageList

'The complete list
'     Device = "1394/1394debug/61883/adapter/apmsupport/avc/battery/biometric/" & _
'              "bluetooth/cdrom/computer/decoder/diskdrive/display/"            & _
'              "dot4print/enum1394/fdc/floppydisk/gps/hdc/hidclass/image/"      & _
'              "infrared/keyboard/legacydriver/media/mediumchanger/mtd/modem/"  & _
'              "monitor/mouse/multifunction/multiportserial/net/netclient/"     & _
'              "netservice/nettrans/nodriver/pcmcia/ports/printer/"             & _
'              "printer upgrade/pnpprinters/processor/sbp2/scsiadapter/"        & _
'              "security accelerator/smartcardreader/sound/system/tapedrive/"   & _
'              "unknown/usb/volume/volumesnapshot/wceusbs"
     'Device = "Ports/Modem/Printer"     'Try this
     'Device = "Modem"                   'or this
      Device = "Ports"                   'or this...
     'Device = "Infrared"                'or this...
     'Device = "Image"                   'or this...
     'The next function will return an hardware description array based on the device string
     DeviceCount = GetDeviceInfo(Device, InfoArray())
     comlistidx = 0
     'msgbox  str$(DeviceCount)
     FOR Looper = 1 TO DeviceCount
       zClassName = InfoArray(%ClassName, Looper)
       Retval = SetupDiClassGuidsFromName(zClassName, GuidInfo, SIZEOF(GuidInfo) , RequiredSize)
       Retval = SetupDiLoadClassIcon(GuidInfo, hIcon, ImageIndex )
       IF LEN(InfoArray(%Friendly, Looper)) THEN
       END IF
       IF LEN(InfoArray(%Manufacturer, Looper)) THEN
       END IF
       IF LEN(InfoArray(%PortName, Looper)) THEN
          comlist(comlistidx) = InfoArray(%PortName, Looper)
          comlistidx = comlistidx+1
       END IF
     NEXT
     FOR I = 1 TO DeviceCount
         MSGBOX comlist(I-1)
     NEXT
END FUNCTION
