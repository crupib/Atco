PROJ = TEST
PROJFILE = TEST.MAK
DEBUG = 0

CC  = cl
CFLAGS_G  = /AL /W4 /G2 /BATCH
CFLAGS_D  = /qc /Gi.\$(PROJ).mdt /Zr /Zi /Od
CFLAGS_R  = /Ot /Oi /Ol /Oe /Og /Gs
MAPFILE_D  = NUL
MAPFILE_R  = NUL
LFLAGS_G  = /NOI /BATCH
LFLAGS_D  = /CO /INC /FAR /PACKC
LFLAGS_R  = /EXE /FAR /PACKC
LINKER	= link
ILINK  = ilink
LRF  = echo > NUL
LLIBS_R  =  /NOD:LLIBCE LLIBCER
LLIBS_D  =  /NOD:LLIBCE LLIBCER


all: .\$(PROJ).exe

.SUFFIXES:
.SUFFIXES:


.\$(PROJ).exe : 
!IF $(DEBUG)
	$(ILINK) -a -e "$(LINKER) @.\$(PROJ).lrf" $@
!ELSE
	$(LINKER) @.\$(PROJ).lrf
!ENDIF



run: .\$(PROJ).exe
	.\$(PROJ).exe $(RUNFLAGS)

debug: .\$(PROJ).exe
	CV $(CVFLAGS) .\$(PROJ).exe $(RUNFLAGS)
