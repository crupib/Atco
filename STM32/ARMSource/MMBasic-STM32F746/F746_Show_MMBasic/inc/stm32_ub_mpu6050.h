/**
 * @author  Tilen Majerle
 * @email   tilen@majerle.eu
 * @website http://stm32f4-discovery.com
 * @link    http://stm32f4-discovery.com/2015/10/hal-library-30-mpu6050-for-stm32fxxx
 * @version v1.0
 * @ide     Keil uVision
 * @license GNU GPL v3
 * @brief   MPU6050 library for STM32Fxxx devices
 *	
@verbatim
   ----------------------------------------------------------------------
    Copyright (C) Tilen Majerle, 2015
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.
     
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
   ----------------------------------------------------------------------
 * | Modified the 2015-10-19 for Stm32F7_Mite by Fabrice
 * |----------------------------------------------------------------------
@endverbatim
 */
#ifndef TM_MPU6050_H
#define TM_MPU6050_H 100

/* C++ detection */
#ifdef __cplusplus
extern "C" {
#endif



#include "stm32_ub_system.h"
#include "stm32_ub_i2c1.h"



#define TM_MPU6050_DataRate_8KHz       0   /*!< Sample rate set to 8 kHz */
#define TM_MPU6050_DataRate_4KHz       1   /*!< Sample rate set to 4 kHz */
#define TM_MPU6050_DataRate_2KHz       3   /*!< Sample rate set to 2 kHz */
#define TM_MPU6050_DataRate_1KHz       7   /*!< Sample rate set to 1 kHz */
#define TM_MPU6050_DataRate_500Hz      15  /*!< Sample rate set to 500 Hz */
#define TM_MPU6050_DataRate_250Hz      31  /*!< Sample rate set to 250 Hz */
#define TM_MPU6050_DataRate_125Hz      63  /*!< Sample rate set to 125 Hz */
#define TM_MPU6050_DataRate_100Hz      79  /*!< Sample rate set to 100 Hz */

typedef enum _TM_MPU6050_Device_t {
	TM_MPU6050_Device_0 = 0x00, /*!< AD0 pin is set to low */
	TM_MPU6050_Device_1 = 0x02  /*!< AD0 pin is set to high */
} TM_MPU6050_Device_t;


typedef enum _TM_MPU6050_Result_t {
	TM_MPU6050_Result_Ok = 0x00,          /*!< Everything OK */
	TM_MPU6050_Result_Error,              /*!< Unknown error */
	TM_MPU6050_Result_DeviceNotConnected, /*!< There is no device with valid slave address */
	TM_MPU6050_Result_DeviceInvalid       /*!< Connected device with address is not MPU6050 */
} TM_MPU6050_Result_t;


typedef enum _TM_MPU6050_Accelerometer_t {
	TM_MPU6050_Accelerometer_2G = 0x00, /*!< Range is +- 2G */
	TM_MPU6050_Accelerometer_4G = 0x01, /*!< Range is +- 4G */
	TM_MPU6050_Accelerometer_8G = 0x02, /*!< Range is +- 8G */
	TM_MPU6050_Accelerometer_16G = 0x03 /*!< Range is +- 16G */
} TM_MPU6050_Accelerometer_t;


typedef enum _TM_MPU6050_Gyroscope_t {
	TM_MPU6050_Gyroscope_250s = 0x00,  /*!< Range is +- 250 degrees/s */
	TM_MPU6050_Gyroscope_500s = 0x01,  /*!< Range is +- 500 degrees/s */
	TM_MPU6050_Gyroscope_1000s = 0x02, /*!< Range is +- 1000 degrees/s */
	TM_MPU6050_Gyroscope_2000s = 0x03  /*!< Range is +- 2000 degrees/s */
} TM_MPU6050_Gyroscope_t;


typedef struct _TM_MPU6050_t {
	/* Private */
	uint8_t Address;         /*!< I2C address of device. Only for private use */
	float Gyro_Mult;         /*!< Gyroscope corrector from raw data to "degrees/s". Only for private use */
	float Acce_Mult;         /*!< Accelerometer corrector from raw data to "g". Only for private use */
	/* Public */
	int16_t Accelerometer_X; /*!< Accelerometer value X axis */
	int16_t Accelerometer_Y; /*!< Accelerometer value Y axis */
	int16_t Accelerometer_Z; /*!< Accelerometer value Z axis */
	int16_t Gyroscope_X;     /*!< Gyroscope value X axis */
	int16_t Gyroscope_Y;     /*!< Gyroscope value Y axis */
	int16_t Gyroscope_Z;     /*!< Gyroscope value Z axis */
	float Temperature;       /*!< Temperature in degrees */
} TM_MPU6050_t;


typedef union _TM_MPU6050_Interrupt_t {
	struct {
		uint8_t DataReady:1;       /*!< Data ready interrupt */
		uint8_t reserved2:2;       /*!< Reserved bits */
		uint8_t Master:1;          /*!< Master interrupt. Not enabled with library */
		uint8_t FifoOverflow:1;    /*!< FIFO overflow interrupt. Not enabled with library */
		uint8_t reserved1:1;       /*!< Reserved bit */
		uint8_t MotionDetection:1; /*!< Motion detected interrupt */
		uint8_t reserved0:1;       /*!< Reserved bit */
	} F;
	uint8_t Status;
} TM_MPU6050_Interrupt_t;



// Global Variables
extern TM_MPU6050_t MPU6050;
extern uint8_t		mpu6050_initialized;


TM_MPU6050_Result_t TM_MPU6050_Init(TM_MPU6050_t* DataStruct, TM_MPU6050_Device_t DeviceNumber, TM_MPU6050_Accelerometer_t AccelerometerSensitivity, TM_MPU6050_Gyroscope_t GyroscopeSensitivity);
TM_MPU6050_Result_t TM_MPU6050_SetGyroscope(TM_MPU6050_t* DataStruct, TM_MPU6050_Gyroscope_t GyroscopeSensitivity);
TM_MPU6050_Result_t TM_MPU6050_SetAccelerometer(TM_MPU6050_t* DataStruct, TM_MPU6050_Accelerometer_t AccelerometerSensitivity);
TM_MPU6050_Result_t TM_MPU6050_SetDataRate(TM_MPU6050_t* DataStruct, uint8_t rate);
TM_MPU6050_Result_t TM_MPU6050_EnableInterrupts(TM_MPU6050_t* DataStruct);
TM_MPU6050_Result_t TM_MPU6050_DisableInterrupts(TM_MPU6050_t* DataStruct);
TM_MPU6050_Result_t TM_MPU6050_ReadInterrupts(TM_MPU6050_t* DataStruct, TM_MPU6050_Interrupt_t* InterruptsStruct);
TM_MPU6050_Result_t TM_MPU6050_ReadAccelerometer(TM_MPU6050_t* DataStruct);
TM_MPU6050_Result_t TM_MPU6050_ReadGyroscope(TM_MPU6050_t* DataStruct);
TM_MPU6050_Result_t TM_MPU6050_ReadTemperature(TM_MPU6050_t* DataStruct);
TM_MPU6050_Result_t TM_MPU6050_ReadAll(TM_MPU6050_t* DataStruct);


/* C++ detection */
#ifdef __cplusplus
}
#endif

#endif
