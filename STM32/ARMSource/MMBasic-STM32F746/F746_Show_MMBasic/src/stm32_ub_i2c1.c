//--------------------------------------------------------------
// File     : stm32_ub_i2c1.c
// Datum    : 17.07.2015
// Version  : 1.1 (MMBasic-Version)
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : I2C-LoLevel-Funktionen (I2C-1)
//
// Hinweis  : mögliche Pinbelegungen
//            I2C1 : SCL : [PB6, PB8] 
//                   SDA : [PB7, PB9]
//            externe PullUp-Widerstände an SCL+SDA notwendig
//--------------------------------------------------------------

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_i2c1.h"


//--------------------------------------------------------------
// interne Funktionen
//--------------------------------------------------------------
void P_HAL_I2C1_MspInit(void);



//--------------------------------------------------------------
// globale Variabeln
//-------------------------------------------------------------- 
I2C_HandleTypeDef I2c1Handle; 
static uint8_t init_ok=0;
uint16_t I2C1_TIMEOUT=0;


//--------------------------------------------------------------
// Init von I2C1
//-------------------------------------------------------------- 
void MM_I2C1_Init(uint16_t speed, uint16_t timeout)
{
  // initialisierung darf nur einmal gemacht werden
  if(init_ok!=0) {
    return;
  } 

  I2C1_TIMEOUT=timeout;

  I2c1Handle.Instance             = I2C1;
  I2c1Handle.Init.Timing          = I2C1_TIMING_10;
  if(speed>=10) I2c1Handle.Init.Timing          = I2C1_TIMING_10;
  if(speed>=20) I2c1Handle.Init.Timing          = I2C1_TIMING_20;
  if(speed>=30) I2c1Handle.Init.Timing          = I2C1_TIMING_30;
  if(speed>=40) I2c1Handle.Init.Timing          = I2C1_TIMING_40;
  if(speed>=50) I2c1Handle.Init.Timing          = I2C1_TIMING_50;
  if(speed>=60) I2c1Handle.Init.Timing          = I2C1_TIMING_60;
  if(speed>=70) I2c1Handle.Init.Timing          = I2C1_TIMING_70;
  if(speed>=80) I2c1Handle.Init.Timing          = I2C1_TIMING_80;
  if(speed>=90) I2c1Handle.Init.Timing          = I2C1_TIMING_90;
  if(speed>=100) I2c1Handle.Init.Timing          = I2C1_TIMING_100;
  if(speed>=200) I2c1Handle.Init.Timing          = I2C1_TIMING_200;
  if(speed>=300) I2c1Handle.Init.Timing          = I2C1_TIMING_300;
  if(speed>=400) I2c1Handle.Init.Timing          = I2C1_TIMING_400;

  I2c1Handle.Init.OwnAddress1     = 0;
  I2c1Handle.Init.AddressingMode  = I2C_ADDRESSINGMODE_7BIT;
  I2c1Handle.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
  I2c1Handle.Init.OwnAddress2     = 0;
  I2c1Handle.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
  I2c1Handle.Init.NoStretchMode   = I2C_NOSTRETCH_DISABLE;
  P_HAL_I2C1_MspInit();
  HAL_I2C_Init(&I2c1Handle);

  HAL_I2CEx_ConfigAnalogFilter(&I2c1Handle,I2C_ANALOGFILTER_ENABLE);

  // init Mode speichern
  init_ok=1;
}

//--------------------------------------------------------------
// DeInit von I2C1
// Return_wert :
//  -> ERROR   , wenn I2C noch nicht initialisiert war
//  -> SUCCESS , wenn I2C deinit ok war
//--------------------------------------------------------------
ErrorStatus MM_I2C1_DeInit(void)
{
  // test ob schon initialisiert
  if(init_ok==0) {
    return ERROR;
  }

  // deinit
  if(HAL_I2C_DeInit(&I2c1Handle) != HAL_OK) {
    return ERROR;
  }

  // init Mode speichern
  init_ok=0;

  return SUCCESS;
}

//--------------------------------------------------------------
// check ob Slave vorhanden ist
// slave_adr => I2C-Basis-Adresse vom Slave
//
// Return_wert :
//  -> ERROR   , wenn Slave nicht bereit
//  -> SUCCESS , wenn Slave bereit
//--------------------------------------------------------------
ErrorStatus MM_I2C1_CheckSlave(uint8_t slave_adr)
{

  if (HAL_I2C_IsDeviceReady(&I2c1Handle, (uint16_t)slave_adr, 2, 5) != HAL_OK) {
	  return ERROR;
  }

  return SUCCESS;
}


//--------------------------------------------------------------
// Auslesen mehrerer Daten per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// cnt       => Anzahl der Bytewert die gelesen werden sollen
// Daten die gelesen worden sind, stehen danach in "I2C1_DATA"
//
// Return_wert :
//    0   , Ok
//  < 0   , Error
//--------------------------------------------------------------
int16_t MM_I2C1_ReadMultiByte(uint8_t slave_adr, uint8_t cnt)
{
  int16_t ret_wert=0;

  I2C1_DATA[0]=0;

  // daten lesen
  if(HAL_I2C_Master_Receive(&I2c1Handle, (uint16_t)slave_adr, (uint8_t *)I2C1_DATA, cnt, I2C1_TIMEOUT) != HAL_OK)
  {
    ret_wert=-3;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-4;
  }
  if(ret_wert!=0) return(ret_wert);

  return(ret_wert);
}

//--------------------------------------------------------------
// Beschreiben mehrerer Daten per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// cnt       => Anzahl der Bytewert die geschrieben werden sollen
// Daten die geschrieben werden sollen, müssen in "I2C1_DATA" stehen
//
// Return_wert :
//    0   , Ok
//  < 0   , Error
//--------------------------------------------------------------
int16_t MM_I2C1_WriteMultiByte(uint8_t slave_adr, uint8_t cnt)
{
  int16_t ret_wert=0;

  // alle daten senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, cnt, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// Auslesen einer Adresse per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// adr       => Register Adresse die gelesen wird
//
// Return_wert :
//  0...255 , Bytewert der gelesen wurde
//  < 0     , Error
//--------------------------------------------------------------
int16_t UB_I2C1_ReadByte(uint8_t slave_adr, uint8_t adr)
{
  int16_t ret_wert=0;

  I2C1_DATA[0]=adr;

  // adresse senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, 1, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  }
  if(ret_wert!=0) return(ret_wert);

  // daten lesen
  if(HAL_I2C_Master_Receive(&I2c1Handle, (uint16_t)slave_adr, (uint8_t *)I2C1_DATA, 1, I2C1_TIMEOUT) != HAL_OK)
  {
    ret_wert=-3;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-4;
  }
  if(ret_wert!=0) return(ret_wert);

  // daten
  ret_wert=I2C1_DATA[0];

  return(ret_wert);
}

//--------------------------------------------------------------
// Beschreiben einer Adresse per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// adr       => Register Adresse die beschrieben wird
// wert      => Bytewert der geschrieben wird
//
// Return_wert :
//    0   , Ok
//  < 0   , Error
//--------------------------------------------------------------
int16_t UB_I2C1_WriteByte(uint8_t slave_adr, uint8_t adr, uint8_t wert)
{
  int16_t ret_wert=0;  

  I2C1_DATA[0]=adr;
  I2C1_DATA[1]=wert;
  
  // adresse und wert senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, 2, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  } 

  return(ret_wert);
}



//--------------------------------------------------------------
// Auslesen mehrerer Adresse per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// adr       => Start Register Adresse ab der gelesen wird
// cnt       => Anzahl der Bytewert die gelesen werden sollen
// Daten die gelesen worden sind, stehen danach in "I2C1_DATA"
//
// Return_wert :
//    0   , Ok
//  < 0   , Error
//--------------------------------------------------------------
int16_t UB_I2C1_ReadMultiByte(uint8_t slave_adr, uint8_t adr, uint8_t cnt)
{
  int16_t ret_wert=0;

  I2C1_DATA[0]=adr;

  // adresse senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, 1, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  }  
  if(ret_wert!=0) return(ret_wert);
  
  // daten lesen
  if(HAL_I2C_Master_Receive(&I2c1Handle, (uint16_t)slave_adr, (uint8_t *)I2C1_DATA, cnt, I2C1_TIMEOUT) != HAL_OK)
  {
    ret_wert=-3;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-4;
  } 
  if(ret_wert!=0) return(ret_wert);

  return(ret_wert);
}




//--------------------------------------------------------------
// Beschreiben mehrerer Adresse per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// adr       => Start Register Adresse ab der beschrieben wird
// cnt       => Anzahl der Bytewert die geschrieben werden sollen
// Daten die geschrieben werden sollen, müssen in "I2C1_DATA" stehen
//
// Return_wert :
//    0   , Ok
//  < 0   , Error
//--------------------------------------------------------------
int16_t UB_I2C1_WriteMultiByte(uint8_t slave_adr, uint8_t adr, uint8_t cnt)
{
  int16_t ret_wert=0;
  uint16_t n;

  for(n=cnt;n>0;n--) {
    I2C1_DATA[n]=I2C1_DATA[n-1];    
  } 
  I2C1_DATA[0]=adr;
  
  // adresse und alle daten senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, cnt+1, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  }
  
  return(ret_wert);
}


//--------------------------------------------------------------
// Schreiben eines Kommandos per I2C an einen Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// cmd       => Kommando das gesendet wird
//
// Return_wert :
//    0   , Ok
//  < 0   , Error
//--------------------------------------------------------------
int16_t UB_I2C1_WriteCMD(uint8_t slave_adr, uint8_t cmd)
{
  int16_t ret_wert=0;

  I2C1_DATA[0]=cmd;

  // command senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, 1, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// Auslesen einer Adresse (16bit) per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// adr       => Register Adresse die gelesen wird
//
// Return_wert :
//  0...255 , Bytewert der gelesen wurde
//  < 0     , Error
//--------------------------------------------------------------
int16_t UB_I2C1_ReadByte16(uint8_t slave_adr, uint16_t adr)
{
  int16_t ret_wert=0;
  uint8_t lo,hi;
  
  // Hi und Lo Adresse
  lo=(adr&0x00FF);
  hi=(adr>>8);  

  I2C1_DATA[0]=hi;
  I2C1_DATA[1]=lo;

  // adresse senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, 2, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  }  
  if(ret_wert!=0) return(ret_wert);
  
  // daten lesen
  if(HAL_I2C_Master_Receive(&I2c1Handle, (uint16_t)slave_adr, (uint8_t *)I2C1_DATA, 1, I2C1_TIMEOUT) != HAL_OK)
  {
    ret_wert=-3;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-4;
  } 
  if(ret_wert!=0) return(ret_wert);

  // daten
  ret_wert=I2C1_DATA[0];

  return(ret_wert);

}

//--------------------------------------------------------------
// Beschreiben einer Adresse (16bit) per I2C von einem Slave
// slave_adr => I2C-Basis-Adresse vom Slave
// adr       => Register Adresse die beschrieben wird
// wert      => Bytewert der geschrieben wird
//
// Return_wert :
//    0   , Ok
//  < 0   , Error
//--------------------------------------------------------------
int16_t UB_I2C1_WriteByte16(uint8_t slave_adr, uint16_t adr, uint8_t wert)
{
  int16_t ret_wert=0;
  uint8_t lo,hi;
  
  // Hi und Lo Adresse
  lo=(adr&0x00FF);
  hi=(adr>>8);  

  I2C1_DATA[0]=hi;
  I2C1_DATA[1]=lo;
  I2C1_DATA[2]=wert;

  // adresse und wert senden
  if(HAL_I2C_Master_Transmit(&I2c1Handle, (uint16_t)slave_adr, (uint8_t*)I2C1_DATA, 3, I2C1_TIMEOUT)!= HAL_OK)
  {
    ret_wert=-1;
    if (HAL_I2C_GetError(&I2c1Handle) != HAL_I2C_ERROR_AF) ret_wert=-2;
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// kleine Pause (ohne Timer)
//--------------------------------------------------------------
void UB_I2C1_Delay(volatile uint32_t nCount)
{
  while(nCount--)
  {
  }
}


//--------------------------------------------------------------
// interne Funktion
//-------------------------------------------------------------- 
void P_HAL_I2C1_MspInit(void)
{
  GPIO_InitTypeDef  GPIO_InitStruct;
  RCC_PeriphCLKInitTypeDef  RCC_PeriphCLKInitStruct;
  
  // I2C-Clock
  RCC_PeriphCLKInitStruct.PeriphClockSelection = RCC_PERIPHCLK_I2C1;
  RCC_PeriphCLKInitStruct.I2c1ClockSelection = RCC_I2C1CLKSOURCE_PCLK1 ;
  HAL_RCCEx_PeriphCLKConfig(&RCC_PeriphCLKInitStruct);

  // GPIO-Clock
  UB_System_ClockEnable(I2C1_SCL_PORT);
  UB_System_ClockEnable(I2C1_SDA_PORT);
  // enable
  __HAL_RCC_I2C1_CLK_ENABLE(); 

  // GPIO
  GPIO_InitStruct.Pin       = I2C1_SCL_PIN;
  GPIO_InitStruct.Mode      = GPIO_MODE_AF_OD;
  GPIO_InitStruct.Pull      = GPIO_PULLUP;
  GPIO_InitStruct.Speed     = GPIO_SPEED_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF4_I2C1;
  HAL_GPIO_Init(I2C1_SCL_PORT, &GPIO_InitStruct);
  
  GPIO_InitStruct.Pin       = I2C1_SDA_PIN;
  GPIO_InitStruct.Alternate = GPIO_AF4_I2C1;
  HAL_GPIO_Init(I2C1_SDA_PORT, &GPIO_InitStruct);
} 
