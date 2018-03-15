//--------------------------------------------------------------
// File     : stm32_ub_usb_hid_host.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STM32F7_UB_USB_HID_HOST_H
#define __STM32F7_UB_USB_HID_HOST_H

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
#include "usbh_hid.h"
#include "usbh_hid_parser.h"


//--------------------------------------------------------------
typedef enum {
  APPLICATION_IDLE_HID = 0,
  APPLICATION_DISCONNECT_HID,
  APPLICATION_START_HID,
  APPLICATION_READY_HID,
  APPLICATION_RUNNING_HID,
}HID_ApplicationTypeDef;


//--------------------------------------------------------------
// Status der USB-Verbindung
//--------------------------------------------------------------
typedef enum {
  USB_HID_HOST_NO_INIT =0,   // USB-Schnittstelle noch nicht initialisiert
  USB_HID_DEV_DETACHED,      // kein Device angeschlossen
  USB_HID_SPEED_OK,          // USB-Speed wird unterstützt
  USB_HID_SPEED_ERROR,       // USB-Speed wird nicht unterstützt
  USB_HID_DEV_NOT_SUPPORTED, // Device wird nicht untersützt
  USB_HID_OVER_CURRENT,      // Überstrom erkannt
  USB_HID_DEV_CONNECTED,     // Device verbunden noch nicht bereit
  USB_HID_MOUSE_CONNECTED,   // Mouse verbunden und bereit
  USB_HID_KEYBOARD_CONNECTED // Tastatur verbunden und bereit
}USB_HID_HOST_STATUS_t;
USB_HID_HOST_STATUS_t USB_HID_HOST_STATUS;


//--------------------------------------------------------------
#define   USB_MOUSE_XPOS_MAX  480-1
#define   USB_MOUSE_YPOS_MAX  272-1

//--------------------------------------------------------------
typedef enum {
  MOUSE_BTN_RELEASED =0,      // Maus Taste losgelassen
  MOUSE_BTN_PRESSED           // Maus Taste betätigt
}USB_HID_BTN;


//--------------------------------------------------------------
// Globale Struktur der Mouse-Daten
//--------------------------------------------------------------
typedef struct {
  USB_HID_BTN btn_left;     // Status der linken Maustaste
  USB_HID_BTN btn_right;    // Status der rechten Maustaste
  USB_HID_BTN btn_center;   // Status der mittleren Maustaste
  uint16_t xpos;            // aktuelle X-Pos
  uint16_t ypos;            // aktuelle Y-Pos
}USB_MOUSE_DATA_t;
USB_MOUSE_DATA_t USB_MOUSE_DATA;




//--------------------------------------------------------------
// Bit-Nr der Shift-Tasten
//--------------------------------------------------------------
#define SHIFTBIT_LSHIFT    0x01  // linke SHIFT Taste
#define SHIFTBIT_RSHIFT    0x02  // rechte SHIFT Taste
#define SHIFTBIT_LSTRG     0x04  // linke STRG Taste
#define SHIFTBIT_LALT      0x08  // linke ALT Taste
#define SHIFTBIT_RALT      0x10  // rechte ALT Taste (ALT GR)
#define SHIFTBIT_RSTRG     0x20  // rechte STRG Taste
#define SHIFTBIT_LGUI      0x40  // linke GUI Taste
#define SHIFTBIT_RGUI      0x80  // rechte GUI Taste



//--------------------------------------------------------------
// Globale Struktur der Keyboard-Daten
//--------------------------------------------------------------
typedef struct {
  uint8_t akt_key1;         // Tastencode der Taste 1
  uint8_t akt_key2;         // Tastencode der Taste 2
  uint8_t akt_shift;        // Shift-Status
}USB_KEY_DATA_t;
USB_KEY_DATA_t USB_KEY_DATA;



//--------------------------------------------------------------
// Globale Funktionen
//--------------------------------------------------------------
void UB_USB_HID_HOST_Init(void);
USB_HID_HOST_STATUS_t UB_USB_HID_HOST_Do(void);
uint8_t UB_USB_HID_HOST_GetKey(void);
uint8_t UB_USB_HID_HOST_GetKeyAnz(void);
uint8_t UB_USB_HID_HOST_GetShift(void);
uint8_t UB_USB_HID_HOST_GetMouse(void);





//--------------------------------------------------------------
#endif // __STM32F7_UB_USB_HID_HOST_H
