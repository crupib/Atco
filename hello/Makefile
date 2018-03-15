#
# Makefile to build the RTTarget-32 demo "Hello"
#

!ifndef RTTARGET
RTTARGET_Not_Defined:
   @echo .
   @echo You must define environment variable RTTARGET to compile this example.
   @echo Run batch file VARSVC.BAT in RTTarget-32's installation directory first.
!endif


# Define some environment variables so the compiler and linker
# find everything

INCLUDE = $(RTTARGET)\include;$(INCLUDE)
LIB     = $(RTTARGET)\libmsvc;$(LIB)


# Set linker options to ensure the correct libraries are linked
# and that a relocation table is generated

LNKOPT  = -link /map /fixed:no /opt:ref /opt:icf /nodefaultlib:kernel32.lib /include:_malloc /include:_EnterCriticalSection@4 /include:_RTFileSystemList


HELLO: hello.rtb

hello.rtb: hello.exe Monitor.rtb hello.cfg Demopc.cfg
   RTLoc -g+ Hello Demopc.cfg Hello.cfg

hello.exe: hello.c
   cl /Fm /Zi hello.c Acpica.lib Rtt32.lib $(LNKOPT)

Monitor.rtb: Monitor.cfg Demopc.cfg
   RTLoc -DBOOT Monitor Demopc.cfg Monitor.cfg
