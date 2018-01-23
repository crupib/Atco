//--------------------------------------------------------------
// File     : stm32_ub_spi.c
// Datum    : 17.07.2015
// Version  : 1.0 (MMBasic-Version)
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : SPI-LoLevel-Funktionen (SPI-2+5) Full-Duplex-Mode
//
// Hinweis  : mögliche Pinbelegungen
//            SPI2 : SCK  : [PA9, PB10, PB13, PD3, PI1] 
//                   MISO : [PB14, PC2, PI2]
//                   MOSI : [PB15, PC1, PC3, PI3] 
//            SPI5 : SCK  : [PF7, PH6] 
//                   MISO : [PF8, PH7]
//                   MOSI : [PF9, PF11]
//-------------------------------------------------------------- 



//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_spi.h"


//--------------------------------------------------------------
// interne Funktionen
//--------------------------------------------------------------
void P_HAL_SPI2_MspInit(uint8_t ss);
void P_HAL_SPI5_MspInit(uint8_t ss);



//--------------------------------------------------------------
// globale Variabeln
//-------------------------------------------------------------- 
SPI_HandleTypeDef Spi2Handle;
SPI_HandleTypeDef Spi5Handle;
uint8_t spi2_init_ok=0;
uint8_t spi5_init_ok=0;


//--------------------------------------------------------------
// Init von SPI2 (im Full-Duplex-Mode) 
// Return_wert :
//  -> ERROR   , wenn SPI schon mit anderem Mode initialisiert
//  -> SUCCESS , wenn SPI init ok war
// mode : 0...3
// speed : 0..7
// order : 0=msb, 1=lsb
// ss : 0=ohne SS-Pin, 1=mit SS-Pin
//--------------------------------------------------------------
ErrorStatus MM_SPI2_Init(uint8_t mode, uint8_t speed, uint8_t order, uint8_t ss)
{  

  // initialisierung darf nur einmal gemacht werden
  if(spi2_init_ok!=0) {    
    return ERROR;
  }

  Spi2Handle.Instance               = SPI2;
  Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_256;
  if(speed==0) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_256;
  if(speed==1) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_128;
  if(speed==2) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_64;
  if(speed==3) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_32;
  if(speed==4) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_16;
  if(speed==5) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_8;
  if(speed==6) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_4;
  if(speed==7) Spi2Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_2;
  Spi2Handle.Init.Direction         = SPI_DIRECTION_2LINES;
  if(mode==0) {
    Spi2Handle.Init.CLKPhase          = SPI_PHASE_1EDGE;
    Spi2Handle.Init.CLKPolarity       = SPI_POLARITY_LOW;
  }else if(mode==1) {
    Spi2Handle.Init.CLKPhase          = SPI_PHASE_2EDGE;
    Spi2Handle.Init.CLKPolarity       = SPI_POLARITY_LOW;
  }else if(mode==2) {
    Spi2Handle.Init.CLKPhase          = SPI_PHASE_1EDGE;
    Spi2Handle.Init.CLKPolarity       = SPI_POLARITY_HIGH;
  }else {
    Spi2Handle.Init.CLKPhase          = SPI_PHASE_2EDGE;
    Spi2Handle.Init.CLKPolarity       = SPI_POLARITY_HIGH;
  }
  Spi2Handle.Init.DataSize          = SPI_DATASIZE_8BIT;
  if(order==0) {
    Spi2Handle.Init.FirstBit          = SPI_FIRSTBIT_MSB;
  }
  else {
    Spi2Handle.Init.FirstBit          = SPI_FIRSTBIT_LSB;
  }
  Spi2Handle.Init.TIMode            = SPI_TIMODE_DISABLE;
  Spi2Handle.Init.CRCCalculation    = SPI_CRCCALCULATION_DISABLE;
  Spi2Handle.Init.CRCPolynomial     = 7;
  Spi2Handle.Init.NSS               = SPI_NSS_SOFT;
  Spi2Handle.Init.Mode = SPI_MODE_MASTER;
  P_HAL_SPI2_MspInit(ss);
  if(HAL_SPI_Init(&Spi2Handle) != HAL_OK) {
    return ERROR; 
  }
  
  // init Mode speichern
  spi2_init_ok=1;  

  return SUCCESS;
}



//--------------------------------------------------------------
// DeInit von SPI2 
// Return_wert :
//  -> ERROR   , wenn SPI noch nicht initialisiert war
//  -> SUCCESS , wenn SPI deinit ok war
//--------------------------------------------------------------
ErrorStatus MM_SPI2_DeInit(void)
{
  // test ob schon initialisiert
  if(spi2_init_ok==0) {    
    return ERROR;
  }

  // deinit
  if(HAL_SPI_DeInit(&Spi2Handle) != HAL_OK) {
    return ERROR; 
  }

  // init Mode speichern
  spi2_init_ok=0;  

  return SUCCESS;  
}

//--------------------------------------------------------------
// sendet und empfängt ein Byte per SPI2 (im Full-Duplex-Mode)
// ChipSelect-Signal muss von rufender Funktion gemacht werden
//--------------------------------------------------------------
uint8_t MM_SPI2_SendByte(uint8_t wert, uint8_t ss)
{ 
  uint8_t ret_wert=0;

  if(ss==0) {
    HAL_SPI_TransmitReceive(&Spi2Handle, &wert, &ret_wert, 1, SPI2_TX_TIMEOUT);
  }
  else {
	  SPI2_SS_PORT->BSRR = (uint32_t)SPI2_SS_PIN << 16;
	  HAL_SPI_TransmitReceive(&Spi2Handle, &wert, &ret_wert, 1, SPI2_TX_TIMEOUT);
	  SPI2_SS_PORT->BSRR = (uint32_t)SPI2_SS_PIN;
  }

  return(ret_wert);
}


//--------------------------------------------------------------
// sendet und empfängt mehrere Bytes per SPI2 (im Full-Duplex-Mode)
// ChipSelect-Signal muss von rufender Funktion gemacht werden
// tx_buf = daten die gesendet werden
// rx_buf = daten die empfangen wurden
// cnt = Anzahl der Daten die gesendet/empfangen werden sollen
//--------------------------------------------------------------
void UB_SPI2_SendArray(uint8_t *tx_buf, uint8_t *rx_buf, uint16_t cnt)
{
  if(cnt==0) return;
  
  HAL_SPI_TransmitReceive(&Spi2Handle, tx_buf, rx_buf, cnt, SPI2_TX_TIMEOUT); 
}



//--------------------------------------------------------------
// Init von SPI5 (im Full-Duplex-Mode) 
// Return_wert :
//  -> ERROR   , wenn SPI schon mit anderem Mode initialisiert
//  -> SUCCESS , wenn SPI init ok war
// mode : 0...3
// speed : 0..7
// order : 0=msb, 1=lsb
// ss : 0=ohne SS-Pin, 1=mit SS-Pin
//--------------------------------------------------------------
ErrorStatus MM_SPI5_Init(uint8_t mode, uint8_t speed, uint8_t order, uint8_t ss)
{  

  // initialisierung darf nur einmal gemacht werden
  if(spi5_init_ok!=0) {    
    return ERROR;
  }

  Spi5Handle.Instance               = SPI5;
  Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_256;
  if(speed==0) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_256;
  if(speed==1) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_128;
  if(speed==2) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_64;
  if(speed==3) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_32;
  if(speed==4) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_16;
  if(speed==5) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_8;
  if(speed==6) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_4;
  if(speed==7) Spi5Handle.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_2;
  Spi5Handle.Init.Direction         = SPI_DIRECTION_2LINES;
  if(mode==0) {
    Spi5Handle.Init.CLKPhase          = SPI_PHASE_1EDGE;
    Spi5Handle.Init.CLKPolarity       = SPI_POLARITY_LOW;
  }else if(mode==1) {
    Spi5Handle.Init.CLKPhase          = SPI_PHASE_2EDGE;
    Spi5Handle.Init.CLKPolarity       = SPI_POLARITY_LOW;
  }else if(mode==2) {
    Spi5Handle.Init.CLKPhase          = SPI_PHASE_1EDGE;
    Spi5Handle.Init.CLKPolarity       = SPI_POLARITY_HIGH;
  }else {
    Spi5Handle.Init.CLKPhase          = SPI_PHASE_2EDGE;
    Spi5Handle.Init.CLKPolarity       = SPI_POLARITY_HIGH;
  }
  Spi5Handle.Init.DataSize          = SPI_DATASIZE_8BIT;
  if(order==0) {
    Spi5Handle.Init.FirstBit          = SPI_FIRSTBIT_MSB;
  }
  else {
    Spi5Handle.Init.FirstBit          = SPI_FIRSTBIT_LSB;
  }
  Spi5Handle.Init.TIMode            = SPI_TIMODE_DISABLE;
  Spi5Handle.Init.CRCCalculation    = SPI_CRCCALCULATION_DISABLE;
  Spi5Handle.Init.CRCPolynomial     = 7;
  Spi5Handle.Init.NSS               = SPI_NSS_SOFT;
  Spi5Handle.Init.Mode = SPI_MODE_MASTER;
  P_HAL_SPI5_MspInit(ss);
  if(HAL_SPI_Init(&Spi5Handle) != HAL_OK) {
    return ERROR; 
  }
  
  // init Mode speichern
  spi5_init_ok=1;  

  return SUCCESS;
}


//--------------------------------------------------------------
// DeInit von SPI5 
// Return_wert :
//  -> ERROR   , wenn SPI noch nicht initialisiert war
//  -> SUCCESS , wenn SPI deinit ok war
//--------------------------------------------------------------
ErrorStatus MM_SPI5_DeInit(void)
{
  // test ob schon initialisiert
  if(spi5_init_ok==0) {    
    return ERROR;
  }

  // deinit
  if(HAL_SPI_DeInit(&Spi5Handle) != HAL_OK) {
    return ERROR; 
  }

  // init Mode speichern
  spi5_init_ok=0;  

  return SUCCESS;  
}


//--------------------------------------------------------------
// sendet und empfängt ein Byte per SPI5 (im Full-Duplex-Mode)
// ChipSelect-Signal muss von rufender Funktion gemacht werden
//--------------------------------------------------------------
uint8_t MM_SPI5_SendByte(uint8_t wert, uint8_t ss)
{ 
  uint8_t ret_wert=0;

  if(ss==0) {
    HAL_SPI_TransmitReceive(&Spi5Handle, &wert, &ret_wert, 1, SPI5_TX_TIMEOUT);
  }
  else {
	  SPI5_SS_PORT->BSRR = (uint32_t)SPI5_SS_PIN << 16;
	  HAL_SPI_TransmitReceive(&Spi5Handle, &wert, &ret_wert, 1, SPI5_TX_TIMEOUT);
	  SPI5_SS_PORT->BSRR = (uint32_t)SPI5_SS_PIN;
  }

  return(ret_wert);
} 

//--------------------------------------------------------------
// sendet und empfängt mehrere Bytes per SPI5 (im Full-Duplex-Mode)
// ChipSelect-Signal muss von rufender Funktion gemacht werden
// tx_buf = daten die gesendet werden
// rx_buf = daten die empfangen wurden
// cnt = Anzahl der Daten die gesendet/empfangen werden sollen
//--------------------------------------------------------------
void UB_SPI5_SendArray(uint8_t *tx_buf, uint8_t *rx_buf, uint16_t cnt)
{
  if(cnt==0) return;
  
  HAL_SPI_TransmitReceive(&Spi5Handle, tx_buf, rx_buf, cnt, SPI5_TX_TIMEOUT); 
}



//--------------------------------------------------------------
// interne Funktion
//-------------------------------------------------------------- 
void P_HAL_SPI2_MspInit(uint8_t ss)
{
  GPIO_InitTypeDef  GPIO_InitStruct;

  // GPIO-Clock
  UB_System_ClockEnable(SPI2_SCK_PORT);
  UB_System_ClockEnable(SPI2_MISO_PORT);
  UB_System_ClockEnable(SPI2_MOSI_PORT);
  // enable
  __HAL_RCC_SPI2_CLK_ENABLE();

  // GPIO
  GPIO_InitStruct.Pin       = SPI2_SCK_PIN;
  GPIO_InitStruct.Mode      = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull      = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed     = GPIO_SPEED_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI2;
  HAL_GPIO_Init(SPI2_SCK_PORT, &GPIO_InitStruct);

  GPIO_InitStruct.Pin = SPI2_MISO_PIN;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI2;
  HAL_GPIO_Init(SPI2_MISO_PORT, &GPIO_InitStruct);

  GPIO_InitStruct.Pin = SPI2_MOSI_PIN;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI2;
  HAL_GPIO_Init(SPI2_MOSI_PORT, &GPIO_InitStruct); 

  if(ss==1) {
	UB_System_ClockEnable(SPI2_SS_PORT);
    GPIO_InitStruct.Pin       = SPI2_SS_PIN;
	GPIO_InitStruct.Mode      = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull      = GPIO_NOPULL;
	GPIO_InitStruct.Speed     = GPIO_SPEED_HIGH;
	HAL_GPIO_Init(SPI2_SS_PORT, &GPIO_InitStruct);
	SPI2_SS_PORT->BSRR = (uint32_t)SPI2_SS_PIN;
  }

}


//--------------------------------------------------------------
// interne Funktion
//-------------------------------------------------------------- 
void P_HAL_SPI5_MspInit(uint8_t ss)
{
  GPIO_InitTypeDef  GPIO_InitStruct;

  // GPIO-Clock
  UB_System_ClockEnable(SPI5_SCK_PORT);
  UB_System_ClockEnable(SPI5_MISO_PORT);
  UB_System_ClockEnable(SPI5_MOSI_PORT);
  // enable
  __HAL_RCC_SPI5_CLK_ENABLE();

  // GPIO
  GPIO_InitStruct.Pin       = SPI5_SCK_PIN;
  GPIO_InitStruct.Mode      = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull      = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed     = GPIO_SPEED_HIGH;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI5;
  HAL_GPIO_Init(SPI5_SCK_PORT, &GPIO_InitStruct);

  GPIO_InitStruct.Pin = SPI5_MISO_PIN;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI5;
  HAL_GPIO_Init(SPI5_MISO_PORT, &GPIO_InitStruct);

  GPIO_InitStruct.Pin = SPI5_MOSI_PIN;
  GPIO_InitStruct.Alternate = GPIO_AF5_SPI5;
  HAL_GPIO_Init(SPI5_MOSI_PORT, &GPIO_InitStruct); 

  if(ss==1) {
	UB_System_ClockEnable(SPI5_SS_PORT);
    GPIO_InitStruct.Pin       = SPI5_SS_PIN;
	GPIO_InitStruct.Mode      = GPIO_MODE_OUTPUT_PP;
	GPIO_InitStruct.Pull      = GPIO_NOPULL;
	GPIO_InitStruct.Speed     = GPIO_SPEED_HIGH;
	HAL_GPIO_Init(SPI5_SS_PORT, &GPIO_InitStruct);
	SPI5_SS_PORT->BSRR = (uint32_t)SPI5_SS_PIN;
  }

}
