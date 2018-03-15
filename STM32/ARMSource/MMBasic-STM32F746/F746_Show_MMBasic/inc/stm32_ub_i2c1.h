//--------------------------------------------------------------
// File     : stm32_ub_i2c1.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STM32F7_UB_I2C1_H
#define __STM32F7_UB_I2C1_H

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_system.h"



//--------------------------------------------------------------
// MultiByte defines
//--------------------------------------------------------------
#define    I2C1_MULTIBYTE_ANZ   255        // anzahl der Bytes
uint8_t    I2C1_DATA[I2C1_MULTIBYTE_ANZ];  // Array



//--------------------------------------------------------------
// APB1-Clock = 50MHz
// Standard-Mode
// (Rise time = 700 ns, Fall time = 100 ns, Digital Filter = 1)
//--------------------------------------------------------------
#define I2C1_TIMING_10       0xC03084F7   // 10kHz
#define I2C1_TIMING_20       0x50709AFD   // 20kHz
#define I2C1_TIMING_30       0x507021EB   // 30kHz
#define I2C1_TIMING_40       0x30B031FA   // 40kHz
#define I2C1_TIMING_50       0x20F041FB   // 50kHz
#define I2C1_TIMING_60       0x30B05E65   // 60kHz
#define I2C1_TIMING_70       0x30B04C59   // 70kHz
#define I2C1_TIMING_80       0x20F0417E   // 80kHz
#define I2C1_TIMING_90       0x4090273D   // 90kHz
#define I2C1_TIMING_100      0x40912732   // 100kHz
// Fast-Mode
// (Rise time = 300 ns, Fall time = 100 ns, Digital Filter = 1)
#define I2C1_TIMING_200      0x10900D61   // 200kHz
#define I2C1_TIMING_300      0x20600D20   // 300kHz
#define I2C1_TIMING_400      0x20600817   // 400kHz




//--------------------------------------------------------------
// Defines
//-------------------------------------------------------------- 




//--------------------------------------------------------------
// I2C-GPIO-Pins
// moegliche Pinbelegung :
//   SCL : [PB6, PB8]
//   SDA : [PB7, PB9]
//--------------------------------------------------------------
#define  I2C1_SCL_PORT    GPIOB
#define  I2C1_SCL_PIN     GPIO_PIN_8

#define  I2C1_SDA_PORT    GPIOB
#define  I2C1_SDA_PIN     GPIO_PIN_9


//--------------------------------------------------------------
// Globale Funktionen
//--------------------------------------------------------------
void MM_I2C1_Init(uint16_t speed, uint16_t timeout);
ErrorStatus MM_I2C1_DeInit(void);
ErrorStatus MM_I2C1_CheckSlave(uint8_t slave_adr);
int16_t MM_I2C1_ReadMultiByte(uint8_t slave_adr, uint8_t cnt);
int16_t MM_I2C1_WriteMultiByte(uint8_t slave_adr, uint8_t cnt);
void UB_I2C1_Delay(volatile uint32_t nCount);

int16_t UB_I2C1_ReadByte(uint8_t slave_adr, uint8_t adr);
int16_t UB_I2C1_WriteByte(uint8_t slave_adr, uint8_t adr, uint8_t wert);
int16_t UB_I2C1_ReadMultiByte(uint8_t slave_adr, uint8_t adr, uint8_t cnt);
int16_t UB_I2C1_WriteMultiByte(uint8_t slave_adr, uint8_t adr, uint8_t cnt);
int16_t UB_I2C1_WriteCMD(uint8_t slave_adr, uint8_t cmd);
int16_t UB_I2C1_ReadByte16(uint8_t slave_adr, uint16_t adr);
int16_t UB_I2C1_WriteByte16(uint8_t slave_adr, uint16_t adr, uint8_t wert);



//--------------------------------------------------------------
#endif // __STM32F7_UB_I2C1_H
