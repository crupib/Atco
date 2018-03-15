/**************************************************************************/
/*                                                                        */
/*  File: USBInit.cpp                            Copyright (c) 2002,2015  */
/*  Version: 6.0                                 On Time Informatik GmbH  */
/*                                                                        */
/*                                                                        */
/*                                      On Time        /////////////----- */
/*                                    Informatik GmbH /////////////       */
/* --------------------------------------------------/////////////        */
/*                                  Real-Time and System Software         */
/*                                                                        */
/**************************************************************************/

/* Source file to initialize RTUSB-32.

   Function FindUSBControllers() is used by the RTUSB-32 demos to
   initialize RTUSB-32. It is recommended that this file is copied
   and then customized for every project which will use RTUSB-32.

   For more information, please see section "Function FindUSBControllers"
   in the RTUSB-32 Programming Manual.
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <Rttarget.h>
#include <Rttbios.h>

#include <Rtk32.h>
#include <Rtkeybrd.h>

#include <Rtusb.h>
#include <Rtusys.h>
#include <Rtuprv.h>

// fix PCI latency timers if they are too low
#define MIN_UHCI_PCI_TIMER_LATENCY  32
#define MIN_OHCI_PCI_TIMER_LATENCY  32
#define MIN_EHCI_PCI_TIMER_LATENCY  32
#define MIN_XHCI_PCI_TIMER_LATENCY  32

// #define PEG        // don't call KBInit() for RTPEG-32 programs, which contains its own keyboard handling
#define VERBOSE       // tell us what controllers have been found
#define INCLUDE_UHCI  // look for UHCI controllers
#define INCLUDE_OHCI  // look for OHCI controllers
#define INCLUDE_EHCI  // look for EHCI controllers
#define INCLUDE_XHCI  // look for XHCI controllers

#ifdef INCLUDE_EHCI
/*-----------------------------------*/
static void TakeEHCIOwnership(const BYTE * CapRegs, BYTE Bus, BYTE DeviceFunc)
{
   BYTE EECP = CapRegs[9];  // EHCI Extended Capabilities Pointer
   DWORD EEC;               // USB Legacy Support Extended Capability Register
   DWORD T = RTUSYSGetTime();

   while (EECP >= 0x40)
   {
      // see if this controller supports Pre-OS to OS Handoff Synchronization
      RTT_BIOS_ReadConfigData(Bus, DeviceFunc, EECP, 4, (void *) &EEC);
      if ((EEC & 0xFFul) == 0x01ul) // Pre-OS to OS Handoff Synchronization
      {
         // request ownership by setting HC OS Owned Semaphore
         RTT_BIOS_WriteConfigData(Bus, DeviceFunc, EECP+3, 1, 1);
         // wait up to 1 second until BIOS gives up ownership
         while ((RTUSYSGetTime() - T) < 1000)
         {
            // Read HC BIOS Owned Semaphore
            RTT_BIOS_ReadConfigData(Bus, DeviceFunc, EECP, 4, (void *) &EEC);
            if (EEC & (1ul<<16))
               RTUSYSDelay(1000);
            else
               break; // the BIOS has released it
         }
         if (EEC & (1ul<<16))
            RTUDiagMessage("warning: The BIOS failed to release ownership of the EHCI controller,\n"
                           "will try to use it anyway...\n");
         // disable EHCI SMIs
         RTT_BIOS_WriteConfigData(Bus, DeviceFunc, EECP+4, 4, 0);
      }
      EECP = (EEC >> 8) & 0xFF;
   }
}
#endif

#ifdef INCLUDE_OHCI
/*-----------------------------------*/
static int IsPCIDevice(BYTE Bus, BYTE DeviceFunc, WORD VendorID, WORD DeviceID)
{
   WORD V, D;

   RTT_BIOS_ReadConfigData(Bus, DeviceFunc, RTT_BIOS_VENDOR_ID, sizeof(WORD), &V);
   RTT_BIOS_ReadConfigData(Bus, DeviceFunc, RTT_BIOS_DEVICE_ID, sizeof(WORD), &D);
   return VendorID == V && DeviceID == D;
}
#endif

/*-----------------------------------*/
static DWORD GetHCResources(const char * Name, BYTE Bus, BYTE DeviceFunc, BYTE BAR, BYTE * IRQ, int TimerLatency)
{
   WORD Cmd;
   BYTE Latency;
   DWORD Temp;

   // enable I/O and memory space access as well as bus master
   RTT_BIOS_ReadConfigData(Bus, DeviceFunc, RTT_BIOS_COMMAND, 2, &Cmd);
   RTT_BIOS_WriteConfigData(Bus, DeviceFunc, RTT_BIOS_COMMAND, 2, Cmd | 0x07);

   // fix latency timer
   RTT_BIOS_ReadConfigData(Bus, DeviceFunc, RTT_BIOS_LATTIMER, 1, &Latency);
   if (Latency < TimerLatency)
      RTT_BIOS_WriteConfigData(Bus, DeviceFunc, RTT_BIOS_LATTIMER, 1, TimerLatency);

   RTT_BIOS_ReadConfigData(Bus, DeviceFunc, RTT_BIOS_IRQ, sizeof(*IRQ), IRQ);
   if (*IRQ == 0 || *IRQ > 31)  // make sure the IRQ value makes sense
      RTUDiagMessage("Warning: USB host controller with invalid IRQ\n");

   RTT_BIOS_ReadConfigData(Bus, DeviceFunc, BAR, sizeof(DWORD), &Temp);
   Temp = Temp & ((Temp & 1) ? 0x0000FFFC : 0xFFFFFF00);

   #ifdef VERBOSE
   {
      char B[80];
      sprintf(B, "%s controller at %04X, IRQ %i\n", Name, Temp, *IRQ);
      RTUDiagMessage(B);
   }
   #endif

   return Temp;
}

/*-----------------------------------*/
int FindUSBControllers(void)
{
   int i, Count = 0;
   BYTE Bus, DeviceFunc, IRQ;
   DWORD BaseAddress;
   void * MappedRegisters;

   // The VC++ 8.0 run-time system needs more than 16k stack space for
   // writing to files. Since all USB client callbacks are called from the
   // Hub task, and some use printf() to write to file stdout, we need
   // a little more stack space.
   #if _MSC_VER >= 1400
      RTUSBConfig.HubTaskStackSize = 32 * 1024;
   #endif

#ifndef INCLUDE_UHCI
#ifndef INCLUDE_OHCI
   RTUSBConfig.Flags |= RTU_NO_EHCI_COMPANION;
#endif
#endif

   if (!RTT_BIOS_Installed())
   {
      RTUDiagMessage("No PCI BIOS found\n");
      return 0;
   }

   RTMPSetAPICModeACPI(0);          // switch to APIC mode, if supported by this target

   // initialize the kernel (if not done already)
   RTKernelInit(0);
   RTKClearStatistic();

   if (!RTKDebugVersion())          // switch off all diagnostics messages
   {
      RTUSetMessageHandler(NULL);
      RTUSBConfig.Flags |= RTU_NOEXIT_ON_ERROR; // keep on going after fatal errors
   }

#ifndef PEG
   KBInit();         // we want blocking keyboard I/O
#endif

   // make sure RTUSB-32 will be shut down properly
   atexit(RTUShutDown);

#ifdef INCLUDE_UHCI
   // The UHCI spec allows USB legacy emulation using standard IRQs rather
   // through SMIs. We must thus disable such emulation first before enabling
   // any (potentially shared) IRQs of other USB host controllers).
   for (i=0; RTT_BIOS_FindClassCode(RTU_PCI_CLASS_UHCI, i, &Bus, &DeviceFunc) == RTT_BIOS_SUCCESSFUL; i++)
      RTT_BIOS_WriteConfigData(Bus, DeviceFunc, 0xC0, 2, 0x0000);
#endif

#ifdef INCLUDE_XHCI
   for (i=0; RTT_BIOS_FindClassCode(RTU_PCI_CLASS_XHCI, i, &Bus, &DeviceFunc) == RTT_BIOS_SUCCESSFUL; i++)
   {
      // The XHCI spec says we should use MSIs
      if (RTMPIsAPICMode() && RTT_BIOS_LocateCapability(Bus, DeviceFunc, RTT_BIOS_CAP_ID_MSI, 0))
         RTMPSetupMSI(Bus, DeviceFunc, 0);
      BaseAddress = GetHCResources("XHCI", Bus, DeviceFunc, 0x10, &IRQ, MIN_XHCI_PCI_TIMER_LATENCY);
      MappedRegisters = RTMapPhysMem((void*)BaseAddress, 0x8000+4096, RT_PG_USERREADWRITE);
      RTURegisterXHCI(MappedRegisters,
                      RTMapPhysMem((void*)(BaseAddress + RTUSYSLE32((DWORD*)MappedRegisters)[5]), 256*4, RT_PG_USERREADWRITE), // doorbell array offset
                      RTMapPhysMem((void*)(BaseAddress + RTUSYSLE32((DWORD*)MappedRegisters)[6]),    64, RT_PG_USERREADWRITE), // runtime registers
                      IRQ);
      Count++;
   }
#endif

#ifdef INCLUDE_EHCI
   for (i=0; RTT_BIOS_FindClassCode(RTU_PCI_CLASS_EHCI, i, &Bus, &DeviceFunc) == RTT_BIOS_SUCCESSFUL; i++)
   {
      BaseAddress = GetHCResources("EHCI", Bus, DeviceFunc, 0x10, &IRQ, MIN_EHCI_PCI_TIMER_LATENCY);
      MappedRegisters = RTMapPhysMem((void*) BaseAddress, 1024, RT_PG_USERREADWRITE);
      TakeEHCIOwnership((BYTE*)MappedRegisters, Bus, DeviceFunc);
      RTURegisterEHCI(MappedRegisters, IRQ);
      Count++;
   }
#endif

#ifdef INCLUDE_OHCI
   for (i=0; RTT_BIOS_FindClassCode(RTU_PCI_CLASS_OHCI, i, &Bus, &DeviceFunc) == RTT_BIOS_SUCCESSFUL; i++)
   {
      BaseAddress = GetHCResources("OHCI", Bus, DeviceFunc, 0x10, &IRQ, MIN_OHCI_PCI_TIMER_LATENCY);
      if (IsPCIDevice(Bus, DeviceFunc, 0x1131, 0x1561)) // Philips ISP1561
         RTUSBConfig.Flags |= RTU_OHCI_3_PHASE_SCHED;
      RTURegisterOHCI(RTMapPhysMem((void*) BaseAddress, 256, RT_PG_USERREADWRITE), IRQ);
      Count++;
   }
#endif

#ifdef INCLUDE_UHCI
   for (i=0; RTT_BIOS_FindClassCode(RTU_PCI_CLASS_UHCI, i, &Bus, &DeviceFunc) == RTT_BIOS_SUCCESSFUL; i++)
   {
      BaseAddress = GetHCResources("UHCI", Bus, DeviceFunc, 0x20, &IRQ, MIN_UHCI_PCI_TIMER_LATENCY);
      RTURegisterUHCI((WORD)BaseAddress, IRQ);
      // enable interrupts after the controller has been initialized
      RTT_BIOS_WriteConfigData(Bus, DeviceFunc, 0xC0, 2, 0x2000);
      Count++;
   }
#endif

   return Count;
}
