//--------------------------------------------------------------
// File     : stm32_ub_usb_hid_host.c
// Datum    : 08.08.2015
// Version  : 1.2
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : USB-HID-HOST per USB-OTG-Port am F7-Discovery
//            für USB-Mouse oder USB-Keyboard
//
// Hinweis  : Copy all USB-LoLevel Files in a new folder : "\usb"
//            and add the include Path : "${ProjDirPath}/usb"
//
//          : Add the Symbol : "USE_USB_FS" or "USE_USB_HS"
//            In Combimode (HID+MSC) HID runs on USB_FS Port
//
//     [--USB-FS--]      [------- USB-HS -------]
//     PA10 = ID         PA3  = D0     PB11 = D4
//     PA11 = DM         PA5  = CLK    PB12 = D5
//     PA12 = DP         PB0  = D1     PB13 = D6
//     PD5  = Power      PB1  = D2     PC0  = STP
//                       PB5  = D7     PC2  = DIR
//                       PB10 = D3     PH4  = NXT
//                       
//              
//--------------------------------------------------------------

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_usb_hid_host.h"



//--------------------------------------------------------------
static void USBH_UserProcess_HID(USBH_HandleTypeDef *phost, uint8_t id);
static void USBH_UserKeyboard(USBH_HandleTypeDef *phost);
static void USBH_UserMouse(USBH_HandleTypeDef *phost);



//--------------------------------------------------------------
USBH_HandleTypeDef hUSBHost_HID;
#ifdef USE_USB_FS
  #ifdef USE_USB_HS
    extern HCD_HandleTypeDef hhcd_FS;
  #else
    extern HCD_HandleTypeDef hhcd_FS;
  #endif
#else
  #ifdef USE_USB_HS
    extern HCD_HandleTypeDef hhcd_HS;
  #endif
#endif
HID_ApplicationTypeDef Appli_state_HID = APPLICATION_IDLE_HID;
volatile uint8_t hid_new_maus_data=0;



//--------------------------------------------------------------
// Init vom USB-OTG-Port als HID-HOST
// (Host für HID-Devices z.B. USB-Mouse oder USB-Keyboard)
//--------------------------------------------------------------
void UB_USB_HID_HOST_Init(void)
{
  RCC_PeriphCLKInitTypeDef PeriphClkInitStruct;

  // init der Variabeln
  USB_HID_HOST_STATUS=USB_HID_DEV_DETACHED;
  Appli_state_HID = APPLICATION_IDLE_HID;

  USB_KEY_DATA.akt_key1=0;
  USB_KEY_DATA.akt_key2=0;
  USB_KEY_DATA.akt_shift=0;
  hid_new_maus_data=0;
  USB_MOUSE_DATA.btn_left=MOUSE_BTN_RELEASED;
  USB_MOUSE_DATA.btn_right=MOUSE_BTN_RELEASED;
  USB_MOUSE_DATA.btn_center=MOUSE_BTN_RELEASED;
  USB_MOUSE_DATA.xpos=0;
  USB_MOUSE_DATA.ypos=0;

  /* Select PLLSAI output as USB clock source */
  PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_CLK48;
  PeriphClkInitStruct.Clk48ClockSelection = RCC_CLK48SOURCE_PLLSAIP;
  PeriphClkInitStruct.PLLSAI.PLLSAIN = 192;
  PeriphClkInitStruct.PLLSAI.PLLSAIQ = 2;
  PeriphClkInitStruct.PLLSAI.PLLSAIP = RCC_PLLSAIP_DIV4;
  PeriphClkInitStruct.PLLSAI.PLLSAIR = 2;
  PeriphClkInitStruct.PLLSAIDivQ = 1;
  PeriphClkInitStruct.PLLSAIDivR = RCC_PLLSAIDIVR_2;
  HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct);

  HAL_Delay(200);

  #ifdef USE_USB_FS
    #ifdef USE_USB_HS
      USBH_Init(&hUSBHost_HID, USBH_UserProcess_HID, USBH_FS_ID);
    #else
      USBH_Init(&hUSBHost_HID, USBH_UserProcess_HID, USBH_FS_ID);
    #endif
  #else
    #ifdef USE_USB_HS
      USBH_Init(&hUSBHost_HID, USBH_UserProcess_HID, USBH_HS_ID);
    #endif
  #endif
  USBH_RegisterClass(&hUSBHost_HID, USBH_HID_CLASS);
  USBH_Start(&hUSBHost_HID);
}


//--------------------------------------------------------------
// USB_HOST-Funktion
// diese Funktion muss zyklisch aufgerufen werden
// Return_wert :
//  USB_HID_MOUSE_CONNECTED    , USB-Mouse angeschlossen und bereit
//  USB_HID_KEYBOARD_CONNECTED , USB-Tastatur angeschlossen und bereit
//  !=                         , Device nicht bereit
//
// Hinweis : falls "USB_HID_DEV_NOT_SUPPORTED" muss die
//           Init Procedure wiederholt werden
//           (bzw ein anderes USB-Device benutzt werden)
//--------------------------------------------------------------
USB_HID_HOST_STATUS_t UB_USB_HID_HOST_Do(void)
{
  USBH_Process(&hUSBHost_HID);

  if(Appli_state_HID==APPLICATION_IDLE_HID) {
    // nothing to do
  }
  else if(Appli_state_HID==APPLICATION_START_HID) {
    if(USB_HID_HOST_STATUS!=USB_HID_DEV_CONNECTED) {
      // USB-Device verbunden
      USB_HID_HOST_STATUS=USB_HID_DEV_CONNECTED;
    }
  }
  else if(Appli_state_HID==APPLICATION_READY_HID) {
    if(USB_HID_HOST_STATUS==USB_HID_DEV_CONNECTED) {
      if(USBH_HID_GetDeviceType(&hUSBHost_HID) == HID_KEYBOARD) {
        // USB-Keyboard wurde eingesteckt
        USB_HID_HOST_STATUS=USB_HID_KEYBOARD_CONNECTED;
      }
      else if(USBH_HID_GetDeviceType(&hUSBHost_HID) == HID_MOUSE) {
        // USB-Mouse wurde eingesteckt
        USB_HID_HOST_STATUS=USB_HID_MOUSE_CONNECTED;
      }
      else {
        // USB-Device wird nicht unterstützt
        USB_HID_HOST_STATUS=USB_HID_DEV_NOT_SUPPORTED;
      }
    }
    else if(USB_HID_HOST_STATUS==USB_HID_KEYBOARD_CONNECTED) {
      // USB-Keyboard zyklisch bearbeiten
      USBH_UserKeyboard(&hUSBHost_HID);
    }
    else if(USB_HID_HOST_STATUS==USB_HID_MOUSE_CONNECTED) {
      // USB-Mouse zyklisch bearbeiten
      USBH_UserMouse(&hUSBHost_HID);
    }
  }
  else if(Appli_state_HID==APPLICATION_DISCONNECT_HID) {
    if(USB_HID_HOST_STATUS!=USB_HID_DEV_DETACHED) {
      // USB-Device getrennt
      USB_HID_HOST_STATUS=USB_HID_DEV_DETACHED;
      Appli_state_HID = APPLICATION_IDLE_HID;
    }
  }

  return(USB_HID_HOST_STATUS);
}


//--------------------------------------------------------------
// auslesen vom aktuellen Tastenwert
// ret_wert : 0           = Tastaturpuffer leer
// ret_wert : >0          = Key-Code der Taste
//--------------------------------------------------------------
uint8_t UB_USB_HID_HOST_GetKey(void)
{
  uint8_t ret_wert=0;

  if(USB_HID_HOST_STATUS==USB_HID_KEYBOARD_CONNECTED) {
    if(USB_KEY_DATA.akt_key1!=0) {
      ret_wert=USB_KEY_DATA.akt_key1;
      USB_KEY_DATA.akt_key1=0;
    }
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// Anzhal der gedrueckten Tasten auslesen [0,1,2]
//
// ret_wert : 0  = keine Taste gedrueckt
// ret_wert : 1  = eine Taste ist gedrueckt
//                   -> USB_KEY_DATA.akt_key1
// ret_wert : 2  = zwei Tasten sind gedrueckt
//                   -> USB_KEY_DATA.akt_key1
//                   -> USB_KEY_DATA.akt_key2
//--------------------------------------------------------------
uint8_t UB_USB_HID_HOST_GetKeyAnz(void)
{
  uint8_t ret_wert=0;

  if(USB_HID_HOST_STATUS==USB_HID_KEYBOARD_CONNECTED) {
    ret_wert=0;
    if(USB_KEY_DATA.akt_key1!=0) ret_wert=1;
    if(USB_KEY_DATA.akt_key2!=0) ret_wert=2;
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// auslesen vom aktuellen Shiftwert
// ret_wert : 0           = keine Shift-Taste gedruekt
//            BIT0 (0x01) = linke Shift-Taste
//            BIT1 (0x02) = rechte Shift-Taste
//            BIT2 (0x04) = linke STRG-Taste
//            BIT3 (0x08) = linke ALT-Taste
//            BIT4 (0x10) = rechte ALT-Taste (ALT GR)
//            BIT5 (0x20) = rechte STRG-Taste
//            BIT6 (0x60) = linke GUI-Taste
//            BIT7 (0x80) = rechte GUI-Taste
//--------------------------------------------------------------
uint8_t UB_USB_HID_HOST_GetShift(void)
{
  uint8_t ret_wert=0;

  if(USB_HID_HOST_STATUS==USB_HID_KEYBOARD_CONNECTED) {
    ret_wert=USB_KEY_DATA.akt_shift;
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// auslesen der aktuellen Mausdaten
// ret_wert : 0  = keine neue Mausdaten vorhanden
// ret_wert : 1  = Neue Daten in der Struktur "USB_MOUSE_DATA"
//
// USB_MOUSE_DATA.btn_left   : [MOUSE_BTN_PRESSED, MOUSE_BTN_RELEASED]
// USB_MOUSE_DATA.btn_right  : [MOUSE_BTN_PRESSED, MOUSE_BTN_RELEASED]
// USB_MOUSE_DATA.btn_center : [MOUSE_BTN_PRESSED, MOUSE_BTN_RELEASED]
// USB_MOUSE_DATA.xpos       : [0...USB_MOUSE_XPOS_MAX]
// USB_MOUSE_DATA.ypos       : [0...USB_MOUSE_YPOS_MAX]
//--------------------------------------------------------------
uint8_t UB_USB_HID_HOST_GetMouse(void)
{
  uint8_t ret_wert=0;

  if(USB_HID_HOST_STATUS==USB_HID_MOUSE_CONNECTED) {
    if(hid_new_maus_data>0) {
      ret_wert=1;
      hid_new_maus_data=0;
    }
  }

  return(ret_wert);
}



//--------------------------------------------------------------
// interne Funktion
//--------------------------------------------------------------
static void USBH_UserProcess_HID(USBH_HandleTypeDef *phost, uint8_t id)
{
  switch(id)
  {
  case HOST_USER_SELECT_CONFIGURATION:
    break;

  case HOST_USER_DISCONNECTION:
    Appli_state_HID = APPLICATION_DISCONNECT_HID;
    break;

  case HOST_USER_CLASS_ACTIVE:
    Appli_state_HID = APPLICATION_READY_HID;
    break;

  case HOST_USER_CONNECTION:
    Appli_state_HID = APPLICATION_START_HID;
    break;

  default:
    break;
  }
}


//--------------------------------------------------------------
// interne Funktion
// zum bearbeiten vom USB-Keyboard
//--------------------------------------------------------------
static void USBH_UserKeyboard(USBH_HandleTypeDef *phost)
{
  HID_KEYBD_Info_TypeDef *k_pinfo;
  uint8_t n;

  k_pinfo = USBH_HID_GetKeybdInfo(phost);

  if(k_pinfo != NULL) {
    USB_KEY_DATA.akt_key1=0;
    USB_KEY_DATA.akt_key2=0;
    USB_KEY_DATA.akt_shift=0;
    n=USBH_HID_GetKeyData(k_pinfo,0);
    if(n>0) {
      USB_KEY_DATA.akt_key1=USBH_HID_GetKeyData(k_pinfo,1);      
    }
    if(n>1) {
      USB_KEY_DATA.akt_key2=USBH_HID_GetKeyData(k_pinfo,3);      
    }
    USB_KEY_DATA.akt_shift=USBH_HID_GetKeyData(k_pinfo,5);
  }
}

//--------------------------------------------------------------
// interne Funktion
// zum bearbeiten der USB-Mouse
//--------------------------------------------------------------
static void USBH_UserMouse(USBH_HandleTypeDef *phost)
{
  HID_MOUSE_Info_TypeDef *m_pinfo;
  uint8_t akt_x, akt_y,delta;

  m_pinfo = USBH_HID_GetMouseInfo(phost);
  if(m_pinfo != NULL) {
    hid_new_maus_data=1;
    // position
    akt_x=m_pinfo->x;
    akt_y=m_pinfo->y;
    if(akt_x!=0) {
      if((akt_x&0x80)==0) {
        // rechts
        delta=akt_x;
        USB_MOUSE_DATA.xpos+=delta;
        if(USB_MOUSE_DATA.xpos>USB_MOUSE_XPOS_MAX) USB_MOUSE_DATA.xpos=USB_MOUSE_XPOS_MAX;
      }
      else {
        // links
        delta=255-akt_x;
        delta++;
        if(USB_MOUSE_DATA.xpos>=delta) {
          USB_MOUSE_DATA.xpos-=delta;
        }
        else {
          USB_MOUSE_DATA.xpos=0;
        }
      }
    }
    if(akt_y!=0) {
      if((akt_y&0x80)==0) {
        // runter
        delta=akt_y;
        USB_MOUSE_DATA.ypos+=delta;
        if(USB_MOUSE_DATA.ypos>USB_MOUSE_YPOS_MAX) USB_MOUSE_DATA.ypos=USB_MOUSE_YPOS_MAX;
      }
      else {
        // hoch
        delta=255-akt_y;
        delta++;
        if(USB_MOUSE_DATA.ypos>=delta) {
          USB_MOUSE_DATA.ypos-=delta;
        }
        else {
          USB_MOUSE_DATA.ypos=0;
        }
      }
    }
    // buttons
    USB_MOUSE_DATA.btn_left=MOUSE_BTN_RELEASED;
    USB_MOUSE_DATA.btn_right=MOUSE_BTN_RELEASED;
    USB_MOUSE_DATA.btn_center=MOUSE_BTN_RELEASED;
    if(m_pinfo->buttons[0]!=0) USB_MOUSE_DATA.btn_left=MOUSE_BTN_PRESSED;
    if(m_pinfo->buttons[1]!=0) USB_MOUSE_DATA.btn_right=MOUSE_BTN_PRESSED;
    if(m_pinfo->buttons[2]!=0) USB_MOUSE_DATA.btn_center=MOUSE_BTN_PRESSED;
  }
}


//--------------------------------------------------------------
// ISR
//--------------------------------------------------------------
#ifdef USE_USB_FS
  #ifdef USE_USB_HS
    void OTG_FS_IRQHandler(void) {
      HAL_HCD_IRQHandler(&hhcd_FS);
    }
  #else
    void OTG_FS_IRQHandler(void) {
      HAL_HCD_IRQHandler(&hhcd_FS);
    }
  #endif
#else
  #ifdef USE_USB_HS
    void OTG_HS_IRQHandler(void) {
      HAL_HCD_IRQHandler(&hhcd_HS);
    }
  #endif
#endif

