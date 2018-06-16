/**
  ******************************************************************************
  * @file    usbh_hid_keybd.c 
  * @author  MCD Application Team
  * @version V3.2.1
  * @date    26-June-2015
  * @brief   This file is the application layer for USB Host HID Keyboard handling
  *          QWERTY and AZERTY Keyboard are supported as per the selection in 
  *          usbh_hid_keybd.h              
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; COPYRIGHT 2015 STMicroelectronics</center></h2>
  *
  * Licensed under MCD-ST Liberty SW License Agreement V2, (the "License");
  * You may not use this file except in compliance with the License.
  * You may obtain a copy of the License at:
  *
  *        http://www.st.com/software_license_agreement_liberty_v2
  *
  * Unless required by applicable law or agreed to in writing, software 
  * distributed under the License is distributed on an "AS IS" BASIS, 
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  *
  ******************************************************************************
  */ 


/* Includes ------------------------------------------------------------------*/
#include "usbh_hid_keybd.h"
#include "usbh_hid_parser.h"

/** @addtogroup USBH_LIB
* @{
*/

/** @addtogroup USBH_CLASS
* @{
*/

/** @addtogroup USBH_HID_CLASS
* @{
*/

/** @defgroup USBH_HID_KEYBD 
* @brief    This file includes HID Layer Handlers for USB Host HID class.
* @{
*/ 

/** @defgroup USBH_HID_KEYBD_Private_TypesDefinitions
* @{
*/ 
/**
* @}
*/ 


/** @defgroup USBH_HID_KEYBD_Private_Defines
* @{
*/ 
/**
* @}
*/ 





#define  KBD_LEFT_CTRL                                  0x01
#define  KBD_LEFT_SHIFT                                 0x02
#define  KBD_LEFT_ALT                                   0x04
#define  KBD_LEFT_GUI                                   0x08
#define  KBD_RIGHT_CTRL                                 0x10
#define  KBD_RIGHT_SHIFT                                0x20
#define  KBD_RIGHT_ALT                                  0x40
#define  KBD_RIGHT_GUI                                  0x80
#define  KBR_MAX_NBR_PRESSED                            6

/** @defgroup USBH_HID_KEYBD_Private_Macros
* @{
*/ 
/**
* @}
*/ 

/** @defgroup USBH_HID_KEYBD_Private_FunctionPrototypes
* @{
*/ 
static USBH_StatusTypeDef USBH_HID_KeybdDecode(USBH_HandleTypeDef *phost);
/**
* @}
*/ 
 
/** @defgroup USBH_HID_KEYBD_Private_Variables
* @{
*/

HID_KEYBD_Info_TypeDef     keybd_info;
uint32_t                   keybd_report_data[2];

static const HID_Report_ItemTypedef imp_0_lctrl={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  0,     /*shift*/
  0,     /*count (only for array items)*/ 
  0,     /*signed?*/ 
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};
static const HID_Report_ItemTypedef imp_0_lshift={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  1,     /*shift*/
  0,     /*count (only for array items)*/  
  0,     /*signed?*/ 
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};
static const HID_Report_ItemTypedef imp_0_lalt={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  2,     /*shift*/
  0,     /*count (only for array items)*/  
  0,     /*signed?*/   
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};
static const HID_Report_ItemTypedef imp_0_lgui={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  3,     /*shift*/
  0,     /*count (only for array items)*/  
  0,     /*signed?*/
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};
static const HID_Report_ItemTypedef imp_0_rctrl={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  4,     /*shift*/
  0,     /*count (only for array items)*/  
  0,     /*signed?*/
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};
static const HID_Report_ItemTypedef imp_0_rshift={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  5,     /*shift*/
  0,     /*count (only for array items)*/  
  0,     /*signed?*/
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};
static const HID_Report_ItemTypedef imp_0_ralt={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  6,     /*shift*/
  0,     /*count (only for array items)*/  
  0,     /*signed?*/
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};
static const HID_Report_ItemTypedef imp_0_rgui={
  (uint8_t*)keybd_report_data+0, /*data*/
  1,     /*size*/
  7,     /*shift*/
  0,     /*count (only for array items)*/  
  0,     /*signed?*/
  0,     /*min value read can return*/
  1,     /*max value read can return*/
  0,     /*min vale device can report*/
  1,     /*max value device can report*/
  1      /*resolution*/
};

static const HID_Report_ItemTypedef imp_0_key_array={
  (uint8_t*)keybd_report_data+2, /*data*/
  8,     /*size*/
  0,     /*shift*/
  6,     /*count (only for array items)*/
  0,     /*signed?*/  
  0,     /*min value read can return*/
  101,   /*max value read can return*/
  0,     /*min vale device can report*/
  101,   /*max value device can report*/
  1      /*resolution*/
};





/**
  * @brief  USBH_HID_KeybdInit 
  *         The function init the HID keyboard.
  * @param  phost: Host handle
  * @retval USBH Status
  */
USBH_StatusTypeDef USBH_HID_KeybdInit(USBH_HandleTypeDef *phost)
{
  uint32_t x;
  HID_HandleTypeDef *HID_Handle =  (HID_HandleTypeDef *) phost->pActiveClass->pData;  
    
  keybd_info.lctrl=keybd_info.lshift= 0;
  keybd_info.lalt=keybd_info.lgui= 0;
  keybd_info.rctrl=keybd_info.rshift= 0;
  keybd_info.ralt=keybd_info.rgui=0;
  
  
  for(x=0; x< (sizeof(keybd_report_data)/sizeof(uint32_t)); x++)
  {
    keybd_report_data[x]=0;
  }
  
  if(HID_Handle->length > (sizeof(keybd_report_data)/sizeof(uint32_t)))
  {
    HID_Handle->length = (sizeof(keybd_report_data)/sizeof(uint32_t));
  }
  HID_Handle->pData = (uint8_t*)keybd_report_data;
  fifo_init(&HID_Handle->fifo, phost->device.Data, HID_QUEUE_SIZE * sizeof(keybd_report_data));
  
  return USBH_OK;    
}

/**
  * @brief  USBH_HID_GetKeybdInfo 
  *         The function return keyboard information.
  * @param  phost: Host handle
  * @retval keyboard information
  */
HID_KEYBD_Info_TypeDef *USBH_HID_GetKeybdInfo(USBH_HandleTypeDef *phost)
{
  if(USBH_HID_KeybdDecode(phost) == USBH_OK)
 {
  return &keybd_info;
 }
 else
 {
  return NULL; 
 }  
}

/**
  * @brief  USBH_HID_KeybdDecode 
  *         The function decode keyboard data.
  * @param  phost: Host handle
  * @retval USBH Status
  */
static USBH_StatusTypeDef USBH_HID_KeybdDecode(USBH_HandleTypeDef *phost)
{
  uint8_t x;
  
  HID_HandleTypeDef *HID_Handle =  (HID_HandleTypeDef *) phost->pActiveClass->pData;
  if(HID_Handle->length == 0)
  {
    return USBH_FAIL;
  }
  /*Fill report */
  if(fifo_read(&HID_Handle->fifo, &keybd_report_data, HID_Handle->length) ==  HID_Handle->length)
  {
    
    keybd_info.lctrl=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_lctrl, 0);
    keybd_info.lshift=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_lshift, 0);
    keybd_info.lalt=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_lalt, 0);
    keybd_info.lgui=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_lgui, 0);
    keybd_info.rctrl=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_rctrl, 0);
    keybd_info.rshift=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_rshift, 0);
    keybd_info.ralt=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_ralt, 0);
    keybd_info.rgui=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_rgui, 0);
    
    for(x=0; x < sizeof(keybd_info.keys); x++)
    {    
      keybd_info.keys[x]=(uint8_t)HID_ReadItem((HID_Report_ItemTypedef *) &imp_0_key_array, x);
    }
    
    return USBH_OK; 
  }

  return   USBH_FAIL;  
}

/**
  * @brief  USBH_HID_GetASCIICode 
  *         The function decode keyboard data into ASCII characters.
  * @param  phost: Host handle
  * @param  info: Keyboard information
  * @retval ASCII code
  */
uint8_t USBH_HID_GetASCIICode(HID_KEYBD_Info_TypeDef *info)
{
  uint8_t   output=0;  

  return output;  
}

// added by UB
uint8_t USBH_HID_GetKeyData(HID_KEYBD_Info_TypeDef *info, uint8_t mode)
{
  uint8_t output=0;

  if(mode==0) { // anzahl der tasten [0...2]
    output=0;
    if(info->keys[0]!=0) output=1;
    if(info->keys[1]!=0) output=2;
  }
  else if(mode==1) { // key-1
    output=info->keys[0];
  }
  else if(mode==3) { // key-2
    output=info->keys[1];
  }
  else if(mode==5) { // shift
    output=0;
    if(keybd_info.lshift!=0) output|=0x01;
    if(keybd_info.rshift!=0) output|=0x02;
    if(keybd_info.lctrl!=0) output|=0x04;
    if(keybd_info.lalt!=0) output|=0x08;
    if(keybd_info.ralt!=0) output|=0x10;
    if(keybd_info.rctrl!=0) output|=0x20;
    if(keybd_info.lgui!=0) output|=0x40;
    if(keybd_info.rgui!=0) output|=0x80;
  }

  return output;
}

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/

