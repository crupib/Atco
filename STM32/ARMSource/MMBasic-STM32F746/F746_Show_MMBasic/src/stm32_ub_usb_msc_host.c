//--------------------------------------------------------------
// File     : stm32_ub_usb_msc_host.c
// Datum    : 08.08.2015
// Version  : 1.0
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : USB-MSC-HOST per USB-OTG-Port am F7-Discovery
//            für USB-Stick
//
// Hinweis  : Copy all USB-LoLevel Files in a new folder : "\usb"
//            and add the include Path : "${ProjDirPath}/usb"
//
//          : Add the Symbol : "USE_USB_FS" or "USE_USB_HS"
//            In Combimode (HID+MSC) MSC runs on USB_HS Port
//
//     [--USB-FS--]      [------- USB-HS -------]
//     PA10 = ID         PA3  = D0     PB11 = D4
//     PA11 = DM         PA5  = CLK    PB12 = D5
//     PA12 = DP         PB0  = D1     PB13 = D6
//     PD5  = Power      PB1  = D2     PC0  = STP
//                       PB5  = D7     PC2  = DIR
//                       PB10 = D3     PH4  = NXT
//                                     
//--------------------------------------------------------------


//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_usb_msc_host.h"


//--------------------------------------------------------------
static void USBH_UserProcess_MSC(USBH_HandleTypeDef *phost, uint8_t id);

//--------------------------------------------------------------
USBH_HandleTypeDef hUSBHost_MSC;
#ifdef USE_USB_FS
  #ifdef USE_USB_HS
    extern HCD_HandleTypeDef hhcd_HS;
  #else
    extern HCD_HandleTypeDef hhcd_FS;
  #endif
#else
  #ifdef USE_USB_HS
    extern HCD_HandleTypeDef hhcd_HS;
  #endif
#endif
MSC_ApplicationTypeDef Appli_state_MSC = APPLICATION_IDLE_MSC;



//--------------------------------------------------------------
// Init vom USB-OTG-Port als MSC-HOST
// (Host für Wechseldatenträger z.B. USB-Stick)
//--------------------------------------------------------------
void UB_USB_MSC_HOST_Init(void)
{
  RCC_PeriphCLKInitTypeDef PeriphClkInitStruct;

  // init der Variabeln
  USB_MSC_HOST_STATUS=USB_MSC_DEV_DETACHED;
  Appli_state_MSC = APPLICATION_IDLE_MSC;

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

  USB_MSC_HOST_STATUS=USB_MSC_DEV_DETACHED;
  #ifdef USE_USB_FS
    #ifdef USE_USB_HS
      USBH_Init(&hUSBHost_MSC, USBH_UserProcess_MSC, USBH_HS_ID);
    #else
      USBH_Init(&hUSBHost_MSC, USBH_UserProcess_MSC, USBH_FS_ID);
    #endif
  #else
    #ifdef USE_USB_HS
      USBH_Init(&hUSBHost_MSC, USBH_UserProcess_MSC, USBH_HS_ID);
    #endif
  #endif
  USBH_RegisterClass(&hUSBHost_MSC, USBH_MSC_CLASS);
  USBH_Start(&hUSBHost_MSC);
}


//--------------------------------------------------------------
// USB_HOST-Funktion
// diese Funktion muss zyklisch aufgerufen werden
// Return_wert :
//  USB_MSC_DEV_CONNECTED     , Device angeschlossen und bereit
//  != USB_MSC_DEV_CONNECTED  , Device nicht bereit
//
// Hinweis : falls "USB_MSC_DEV_NOT_SUPPORTED" muss die
//           Init Procedure wiederholt werden
//           (bzw ein anderer USB-Stick benutzt werden)
//--------------------------------------------------------------
USB_MSC_HOST_STATUS_t UB_USB_MSC_HOST_Do(void)
{
  USBH_Process(&hUSBHost_MSC);

  if(Appli_state_MSC==APPLICATION_IDLE_MSC) {
    // nothing to do
  }
  else if(Appli_state_MSC==APPLICATION_READY_MSC) {
    if(USB_MSC_HOST_STATUS!=USB_MSC_DEV_CONNECTED) {
      // USB-Device verbunden
      USB_MSC_HOST_STATUS=USB_MSC_DEV_CONNECTED;
    }
  }
  else if(Appli_state_MSC==APPLICATION_DISCONNECT_MSC) {
    if(USB_MSC_HOST_STATUS!=USB_MSC_DEV_DETACHED) {
      // USB-Device getrennt
      USB_MSC_HOST_STATUS=USB_MSC_DEV_DETACHED;
      Appli_state_MSC = APPLICATION_IDLE_MSC;
    }
  }

  return(USB_MSC_HOST_STATUS);
}

//--------------------------------------------------------------
// interne Funktion
//--------------------------------------------------------------
static void USBH_UserProcess_MSC(USBH_HandleTypeDef *phost, uint8_t id)
{
  switch(id)
  {
  case HOST_USER_SELECT_CONFIGURATION:
    break;

  case HOST_USER_DISCONNECTION:
    Appli_state_MSC = APPLICATION_DISCONNECT_MSC;
    break;

  case HOST_USER_CLASS_ACTIVE:
    Appli_state_MSC = APPLICATION_READY_MSC;
    break;

  case HOST_USER_CONNECTION:
    break;

  default:
    break;
  }
}

//--------------------------------------------------------------
// ISR
//--------------------------------------------------------------
#ifdef USE_USB_FS
  #ifdef USE_USB_HS
    void OTG_HS_IRQHandler(void) {
      HAL_HCD_IRQHandler(&hhcd_HS);
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

