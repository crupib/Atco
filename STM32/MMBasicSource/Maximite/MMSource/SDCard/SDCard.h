
#define __COMPILER_H
#define BOOL_ALREADY_DEFINED

#include "../SDCard/HardwareProfile.h"
#include "../SDCard/Microchip/Include/MDD File System/FSIO.h"
#include "MDD File System\FSDefs.h"

#define NBRERRMSG 17
extern int ErrorCheck(void);
extern int ErrorThrow(int e);
