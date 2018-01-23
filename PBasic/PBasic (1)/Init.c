#define STRICT
#define WIN32_LEAN_AND_MEAN
#define _WIN32_WINNT 0x0400
#include <windows.h>

#include <process.h>

#include <Rttarget.h>
#include <Rtk32.h>
#include <Rtfiles.h>
#include <Rtusb.h>

#define RTF_BUFFER_SIZE   4096  // size of each sector buffer
#define RTF_MAX_DRIVES       8  // max logical drives, can be set up to 32
#define RTF_MAX_FILES        8  // max open files, can be set to any value >= 2
#define RTF_MAX_BUFFERS     32  // number of sector buffers

#include <Rtfdata.c>            // replace default tables with our own

static RTFDrvIDEData  IDE[4]    = {0};
static RTFDrvIDEData  SATA[4]   = {0};
static RTFDrvAHCIData AHCI[4]   = {0};

// let's support 1 USB floppy, 2 standard disk plus 1 card reader with 4 slots
static RTFDrvUSBData USBFloppy[1]  = {0};
static RTFDrvUSBData USBDisks[2]   = {0};
static RTFDrvUSBData CardReader[4] = {0};

#define DEVICE_FLAGS  0

// The RTFiles-32 device list. RTFiles-32 will scan this device listed at
// program startup to mount disk volumes.

RTFDevice RTFDeviceList[] = {
   // one USB floppy
   { RTF_DEVICE_FLOPPY, 0, DEVICE_FLAGS,        &RTFDrvUSB,  USBFloppy + 0 },

   // IDE primary master and slave
   { RTF_DEVICE_FDISK , 0, DEVICE_FLAGS,        &RTFDrvIDE,  IDE + 0 },
   { RTF_DEVICE_FDISK , 1, DEVICE_FLAGS,        &RTFDrvIDE,  IDE + 1 },

   // IDE secondary master and slave
   { RTF_DEVICE_FDISK , 2, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvIDE,  IDE + 2 },
   { RTF_DEVICE_FDISK , 3, DEVICE_FLAGS,        &RTFDrvIDE,  IDE + 3 },

   // four SATA ports
   { RTF_DEVICE_FDISK , 8, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvIDE,  SATA + 0 },
   { RTF_DEVICE_FDISK , 9, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvIDE,  SATA + 1 },
   { RTF_DEVICE_FDISK ,10, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvIDE,  SATA + 2 },
   { RTF_DEVICE_FDISK ,11, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvIDE,  SATA + 3 },

   // four AHCI ports
   { RTF_DEVICE_FDISK , 0, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvAHCI, AHCI + 0 },
   { RTF_DEVICE_FDISK , 1, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvAHCI, AHCI + 1 },
   { RTF_DEVICE_FDISK , 2, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvAHCI, AHCI + 2 },
   { RTF_DEVICE_FDISK , 3, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvAHCI, AHCI + 3 },

   // standard USB disks
   { RTF_DEVICE_FDISK , 0, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvUSB,  USBDisks + 0},
   { RTF_DEVICE_FDISK , 0, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvUSB,  USBDisks + 1},

   // this is the USB card reader
   { RTF_DEVICE_FDISK , 0, DEVICE_FLAGS |
                           RTF_DEVICE_NEW_LOCK, &RTFDrvUSB,  CardReader + 0},
   { RTF_DEVICE_FDISK , 1, DEVICE_FLAGS,        &RTFDrvUSB,  CardReader + 1},
   { RTF_DEVICE_FDISK , 2, DEVICE_FLAGS,        &RTFDrvUSB,  CardReader + 2},
   { RTF_DEVICE_FDISK , 3, DEVICE_FLAGS,        &RTFDrvUSB,  CardReader + 3},

   { 0 } // end of list
};


/*-----------------------------------*/
BOOL WINAPI DllMain(HINSTANCE hDllHandle, DWORD nReason, LPVOID Reserved)
{
   switch (nReason)
   {
      case DLL_PROCESS_ATTACH:
         RTDisplayString("System DLL Init function called\n");
         RTCMOSExtendHeap();
         RTDisplayString("(1)\n");
         RTKConfig.Flags       |= RF_PREEMPTIVE;
         RTKConfig.DriverFlags |= DF_IDLE_HALT;
         RTKernelInit(0);
         RTDisplayString("(2)");
         CLKSetTimerIntVal(10*1000);  // 10 milliseconds
         RTDisplayString("(3)");
         RTCMOSSetSystemTime();
         RTDisplayString("(4)");
         RTURegisterCallback(USBKeyboard);
         RTDisplayString("(5)");
         RTURegisterCallback(USBDisk);
         RTDisplayString("(6)");
         FindUSBControllers();
         RTDisplayString("(7)");
         RTUWaitInitialEnumDone();
         RTDisplayString("(8)");
         atexit(RTFShutDown);
         RTDisplayString("(9)\n");
         break;
      case DLL_PROCESS_DETACH:
         RTDisplayString("System DLL Exit function called\n");
         break;
   }
   return TRUE;
}
