#
# Makefile to build the RTTarget-32 demo "PBasic"
#

!ifndef RTTARGET
RTTARGET_Not_Defined:
   @echo .
   @echo You must define environment variable RTTARGET to compile this example.
   @echo Run batch file VARSVC.BAT in RTTarget-32's installation directory first.
!endif


# Define some environment variables so the compiler and linker
# find everything

INCLUDE = $(RTTARGET)\Include;$(INCLUDE)
LIB     = $(RTTARGET)\Libmsvc;$(LIB)


PBasic: PBasic.rtb

Rttdll.def: PBasic.exe MyWin32API.txt
   MakeDef -M \
      -EPBasic.exe \
      "-I$(RTTARGET)\Source" \
      RTTDLL.DLL \
      Rttdll.def \
      Rtt32api.txt \
      Win32api.txt \
      W32apimt.txt \
      Rtf32api.txt \
      Rtu32api.txt \
      MyWin32API.txt

PBasic.rtb: PBasic.exe Rttdll.dll PBasic.cfg
   RTLoc -Rd PBasic Demopc.cfg PBasic.cfg

Rttdll.dll: MyWin32API.c Init.c Rttdll.def
   cl /MT /Fm /LD /FeRttdll.dll \
      MyWin32API.c \
      Init.c \
      Usbinit.c \
      Rtusb.lib \
      RtfilesX.lib \
      Rtfsk32.lib \
      Rtk32.lib Clkpc.lib Hrtpent.lib Drvrt32.lib \
      Rttheap.lib Acpica.lib Rtt32.lib \
      Libcmt.lib \
      -link /map /fixed:no /opt:ref /opt:icf /def:Rttdll.def /nodefaultlib:kernel32.lib /include:_malloc /include:_EnterCriticalSection@4 /include:_RTFileSystemList /include:__DllMainCRTStartup@12 /machine:ix86 /incremental:no
clean:
	del *.obj
        del *.lib
        del rtt*.*
        del *.loc
        del *.rtb
