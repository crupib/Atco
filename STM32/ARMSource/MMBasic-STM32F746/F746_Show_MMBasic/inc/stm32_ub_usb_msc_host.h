//--------------------------------------------------------------
// File     : stm32_ub_usb_msc_host.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STM32F7_UB_USB_MSC_HOST_H
#define __STM32F7_UB_USB_MSC_HOST_H


#ifndef USE_USB_FS
  #ifndef USE_USB_HS
    #error "Please define USE_USB_FS or USE_USB_HS"
  #endif
#endif


//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_system.h"
#include "usbh_core.h"
#include "usbh_msc.h"


//--------------------------------------------------------------
typedef enum {
  APPLICATION_IDLE_MSC = 0,
  APPLICATION_READY_MSC,
  APPLICATION_DISCONNECT_MSC,
}MSC_ApplicationTypeDef;



//--------------------------------------------------------------
// Status der USB-Verbindung
//--------------------------------------------------------------
typedef enum {
  USB_MSC_HOST_NO_INIT =0,   // USB-Schnittstelle noch nicht initialisiert
  USB_MSC_DEV_DETACHED,      // kein Device angeschlossen
  USB_MSC_SPEED_ERROR,       // USB-Speed wird nicht unterstützt
  USB_MSC_DEV_NOT_SUPPORTED, // Device wird nicht untersützt
  USB_MSC_DEV_WRITE_PROTECT, // Device ist schreibgeschützt
  USB_MSC_OVER_CURRENT,      // Überstrom erkannt
  USB_MSC_DEV_CONNECTED      // Device verbunden und bereit
}USB_MSC_HOST_STATUS_t;
USB_MSC_HOST_STATUS_t USB_MSC_HOST_STATUS;





//--------------------------------------------------------------
// Globale Funktionen
//--------------------------------------------------------------
void UB_USB_MSC_HOST_Init(void);
USB_MSC_HOST_STATUS_t UB_USB_MSC_HOST_Do(void);




//--------------------------------------------------------------
#endif // __STM32F7_UB_USB_MSC_HOST_H
