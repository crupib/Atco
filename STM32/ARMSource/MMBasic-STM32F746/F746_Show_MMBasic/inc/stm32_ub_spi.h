//--------------------------------------------------------------
// File     : stm32_ub_spi.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STM32F7_UB_SPI_H
#define __STM32F7_UB_SPI_H

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_system.h"






//--------------------------------------------------------------
// SPI-Clock
// Grundfrequenz (SPI2)= APB1 (APB1=50MHz)
// Mögliche Vorteiler = 2,4,8,16,32,64,128,256
//--------------------------------------------------------------
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_2   // Frq = 25 MHz
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_4   // Frq = 12.5 MHz
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_8   // Frq = 6.25 MHz
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_16  // Frq = 3.125 MHz
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_32  // Frq = 1.562 MHz
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_64  // Frq = 781.2 MHz
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_128 // Frq = 390.6 kHz
//#define SPI2_VORTEILER     SPI_BAUDRATEPRESCALER_256 // Frq = 195.3 kHz



//--------------------------------------------------------------
// SPI-GPIO-Pins
// moegliche Pinbelegung :
//   SCK  : [PA9, PB10, PB13, PD3, PI1]
//   MISO : [PB14, PC2, PI2]
//   MOSI : [PB15, PC1, PC3, PI3]
//--------------------------------------------------------------
#define  SPI2_SCK_PORT     GPIOI
#define  SPI2_SCK_PIN      GPIO_PIN_1

#define  SPI2_MISO_PORT    GPIOB
#define  SPI2_MISO_PIN     GPIO_PIN_14

#define  SPI2_MOSI_PORT    GPIOB
#define  SPI2_MOSI_PIN     GPIO_PIN_15

#define  SPI2_SS_PORT     GPIOA
#define  SPI2_SS_PIN      GPIO_PIN_8



//--------------------------------------------------------------
#define  SPI2_TX_TIMEOUT   1000





//--------------------------------------------------------------
// SPI-Clock
// Grundfrequenz (SPI5)= APB2 (APB2=100MHz)
// Mögliche Vorteiler = 2,4,8,16,32,64,128,256
//--------------------------------------------------------------
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_2   // Frq = 50 MHz
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_4   // Frq = 25 MHz
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_8   // Frq = 12,5 MHz
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_16  // Frq = 6.25 MHz
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_32  // Frq = 3.125 MHz
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_64  // Frq = 1.562 MHz
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_128 // Frq = 781.2 kHz
//#define SPI5_VORTEILER     SPI_BAUDRATEPRESCALER_256 // Frq = 390.6 kHz



//--------------------------------------------------------------
// SPI-GPIO-Pins
// moegliche Pinbelegung :
//   SCK  : [PF7, PH6]
//   MISO : [PF8, PH7]
//   MOSI : [PF9, PF11]
//--------------------------------------------------------------
#define  SPI5_SCK_PORT     GPIOF
#define  SPI5_SCK_PIN      GPIO_PIN_7

#define  SPI5_MISO_PORT    GPIOF
#define  SPI5_MISO_PIN     GPIO_PIN_8

#define  SPI5_MOSI_PORT    GPIOF
#define  SPI5_MOSI_PIN     GPIO_PIN_9

#define  SPI5_SS_PORT     GPIOF
#define  SPI5_SS_PIN      GPIO_PIN_6


//--------------------------------------------------------------
#define  SPI5_TX_TIMEOUT   1000




//--------------------------------------------------------------
// Globale Funktionen
//--------------------------------------------------------------
ErrorStatus MM_SPI2_Init(uint8_t mode, uint8_t speed, uint8_t order, uint8_t ss);
ErrorStatus MM_SPI2_DeInit(void);
uint8_t MM_SPI2_SendByte(uint8_t wert, uint8_t ss);

ErrorStatus MM_SPI5_Init(uint8_t mode, uint8_t speed, uint8_t order, uint8_t ss);
ErrorStatus MM_SPI5_DeInit(void);
uint8_t MM_SPI5_SendByte(uint8_t wert, uint8_t ss);

void UB_SPI2_SendArray(uint8_t *tx_buf, uint8_t *rx_buf, uint16_t cnt);
void UB_SPI5_SendArray(uint8_t *tx_buf, uint8_t *rx_buf, uint16_t cnt);

//--------------------------------------------------------------
#endif // __STM32F7_UB_SPI_H
