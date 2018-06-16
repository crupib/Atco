/**	
 * |----------------------------------------------------------------------
 * | Copyright (C) Tilen Majerle, 2014
 * | 
 * | This program is free software: you can redistribute it and/or modify
 * | it under the terms of the GNU General Public License as published by
 * | the Free Software Foundation, either version 3 of the License, or
 * | any later version.
 * |  
 * | This program is distributed in the hope that it will be useful,
 * | but WITHOUT ANY WARRANTY; without even the implied warranty of
 * | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * | GNU General Public License for more details.
 * | 
 * | You should have received a copy of the GNU General Public License
 * | along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * |----------------------------------------------------------------------
 */
#include "stm32_ub_mpu6050.h"

/* Default I2C address */
#define MPU6050_I2C_ADDR			0xD0

/* Who I am register value */
#define MPU6050_I_AM				0x68

/* MPU6050 registers */
#define MPU6050_AUX_VDDIO			0x01
#define MPU6050_SMPLRT_DIV			0x19
#define MPU6050_CONFIG				0x1A
#define MPU6050_GYRO_CONFIG			0x1B
#define MPU6050_ACCEL_CONFIG		0x1C
#define MPU6050_MOTION_THRESH		0x1F
#define MPU6050_INT_PIN_CFG			0x37
#define MPU6050_INT_ENABLE			0x38
#define MPU6050_INT_STATUS			0x3A
#define MPU6050_ACCEL_XOUT_H		0x3B
#define MPU6050_ACCEL_XOUT_L		0x3C
#define MPU6050_ACCEL_YOUT_H		0x3D
#define MPU6050_ACCEL_YOUT_L		0x3E
#define MPU6050_ACCEL_ZOUT_H		0x3F
#define MPU6050_ACCEL_ZOUT_L		0x40
#define MPU6050_TEMP_OUT_H			0x41
#define MPU6050_TEMP_OUT_L			0x42
#define MPU6050_GYRO_XOUT_H			0x43
#define MPU6050_GYRO_XOUT_L			0x44
#define MPU6050_GYRO_YOUT_H			0x45
#define MPU6050_GYRO_YOUT_L			0x46
#define MPU6050_GYRO_ZOUT_H			0x47
#define MPU6050_GYRO_ZOUT_L			0x48
#define MPU6050_MOT_DETECT_STATUS	0x61
#define MPU6050_SIGNAL_PATH_RESET	0x68
#define MPU6050_MOT_DETECT_CTRL		0x69
#define MPU6050_USER_CTRL			0x6A
#define MPU6050_PWR_MGMT_1			0x6B
#define MPU6050_PWR_MGMT_2			0x6C
#define MPU6050_FIFO_COUNTH			0x72
#define MPU6050_FIFO_COUNTL			0x73
#define MPU6050_FIFO_R_W			0x74
#define MPU6050_WHO_AM_I			0x75

/* Gyro sensitivities in degrees/s */
#define MPU6050_GYRO_SENS_250		((float) 131)
#define MPU6050_GYRO_SENS_500		((float) 65.5)
#define MPU6050_GYRO_SENS_1000		((float) 32.8)
#define MPU6050_GYRO_SENS_2000		((float) 16.4)

/* Acce sensitivities in g/s */
#define MPU6050_ACCE_SENS_2			((float) 16384)
#define MPU6050_ACCE_SENS_4			((float) 8192)
#define MPU6050_ACCE_SENS_8			((float) 4096)
#define MPU6050_ACCE_SENS_16		((float) 2048)

// Global Variables
TM_MPU6050_t	MPU6050;
uint8_t			mpu6050_initialized = 0;

TM_MPU6050_Result_t TM_MPU6050_Init(TM_MPU6050_t* DataStruct, TM_MPU6050_Device_t DeviceNumber, TM_MPU6050_Accelerometer_t AccelerometerSensitivity, TM_MPU6050_Gyroscope_t GyroscopeSensitivity) {
	int16_t check;
	
	/* Format I2C address */
	DataStruct->Address = MPU6050_I2C_ADDR | (uint8_t)DeviceNumber;
	
	/* Check if device is connected */
	if (MM_I2C1_CheckSlave(DataStruct->Address) != SUCCESS) {
		/* Return error */
		return TM_MPU6050_Result_DeviceNotConnected;
	}
	
	/* Check who am I */
	check=UB_I2C1_ReadByte(DataStruct->Address,MPU6050_WHO_AM_I);
	if (check != MPU6050_I_AM) {
		/* Return error */
		return TM_MPU6050_Result_DeviceInvalid;
	}
	
	/* Wakeup MPU6050 */
	UB_I2C1_WriteByte(DataStruct->Address, MPU6050_PWR_MGMT_1, 0x00);
	
	/* Set sample rate to 1kHz */
	TM_MPU6050_SetDataRate(DataStruct, TM_MPU6050_DataRate_1KHz);
	
	/* Config accelerometer */
	TM_MPU6050_SetAccelerometer(DataStruct, AccelerometerSensitivity);
	
	/* Config accelerometer */
	TM_MPU6050_SetGyroscope(DataStruct, GyroscopeSensitivity);
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_SetGyroscope(TM_MPU6050_t* DataStruct, TM_MPU6050_Gyroscope_t GyroscopeSensitivity) {
	uint8_t temp;
	int16_t check;
	
	/* Config gyroscope */
	check=UB_I2C1_ReadByte(DataStruct->Address, MPU6050_GYRO_CONFIG);
	if(check<0) return TM_MPU6050_Result_Error;
	temp=(uint8_t)(check);
	temp = (temp & 0xE7) | (uint8_t)GyroscopeSensitivity << 3;
	UB_I2C1_WriteByte(DataStruct->Address, MPU6050_GYRO_CONFIG, temp);
	
	switch (GyroscopeSensitivity) {
		case TM_MPU6050_Gyroscope_250s:
			DataStruct->Gyro_Mult = (float)1 / MPU6050_GYRO_SENS_250; 
			break;
		case TM_MPU6050_Gyroscope_500s:
			DataStruct->Gyro_Mult = (float)1 / MPU6050_GYRO_SENS_500; 
			break;
		case TM_MPU6050_Gyroscope_1000s:
			DataStruct->Gyro_Mult = (float)1 / MPU6050_GYRO_SENS_1000; 
			break;
		case TM_MPU6050_Gyroscope_2000s:
			DataStruct->Gyro_Mult = (float)1 / MPU6050_GYRO_SENS_2000; 
			break;
		default:
			break;
	}
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_SetAccelerometer(TM_MPU6050_t* DataStruct, TM_MPU6050_Accelerometer_t AccelerometerSensitivity) {
	uint8_t temp;
	int16_t check;
	
	/* Config accelerometer */
	check=UB_I2C1_ReadByte(DataStruct->Address, MPU6050_ACCEL_CONFIG);
	if(check<0) return TM_MPU6050_Result_Error;
	temp=(uint8_t)(check);
	temp = (temp & 0xE7) | (uint8_t)AccelerometerSensitivity << 3;
	UB_I2C1_WriteByte(DataStruct->Address, MPU6050_ACCEL_CONFIG, temp);
	
	/* Set sensitivities for multiplying gyro and accelerometer data */
	switch (AccelerometerSensitivity) {
		case TM_MPU6050_Accelerometer_2G:
			DataStruct->Acce_Mult = (float)1 / MPU6050_ACCE_SENS_2; 
			break;
		case TM_MPU6050_Accelerometer_4G:
			DataStruct->Acce_Mult = (float)1 / MPU6050_ACCE_SENS_4; 
			break;
		case TM_MPU6050_Accelerometer_8G:
			DataStruct->Acce_Mult = (float)1 / MPU6050_ACCE_SENS_8; 
			break;
		case TM_MPU6050_Accelerometer_16G:
			DataStruct->Acce_Mult = (float)1 / MPU6050_ACCE_SENS_16; 
			break;
		default:
			break;
	}
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_SetDataRate(TM_MPU6050_t* DataStruct, uint8_t rate) {
	/* Set data sample rate */
	if (UB_I2C1_WriteByte(DataStruct->Address, MPU6050_SMPLRT_DIV, rate) != 0) {
		/* Return error */
		return TM_MPU6050_Result_Error;
	}
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}
	

TM_MPU6050_Result_t TM_MPU6050_EnableInterrupts(TM_MPU6050_t* DataStruct) {
	uint8_t temp;
	int16_t check;
	
	/* Enable interrupts for data ready and motion detect */
	UB_I2C1_WriteByte(DataStruct->Address, MPU6050_INT_ENABLE, 0x21);
	
	/* Clear IRQ flag on any read operation */
	check=UB_I2C1_ReadByte(DataStruct->Address, MPU6050_INT_PIN_CFG);
	if(check<0) return TM_MPU6050_Result_Error;
	temp=(uint8_t)(check);
	temp |= 0x10;
	UB_I2C1_WriteByte(DataStruct->Address, MPU6050_INT_PIN_CFG, temp);
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_DisableInterrupts(TM_MPU6050_t* DataStruct) {
	/* Disable interrupts */
	if (UB_I2C1_WriteByte(DataStruct->Address, MPU6050_INT_ENABLE, 0x00) != 0) {
		/* Return error */
		return TM_MPU6050_Result_Error;
	}
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_ReadInterrupts(TM_MPU6050_t* DataStruct, TM_MPU6050_Interrupt_t* InterruptsStruct) {
	uint8_t read;
	int16_t check;
	
	/* Reset structure */
	InterruptsStruct->Status = 0;
	
	/* Read interrupts status register */
	check=UB_I2C1_ReadByte(DataStruct->Address, MPU6050_INT_STATUS);
	if(check<0) return TM_MPU6050_Result_Error;
	
	/* Fill value */
	read=(uint8_t)(check);
	InterruptsStruct->Status = read;
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_ReadAccelerometer(TM_MPU6050_t* DataStruct) {
	int16_t check;
	
	/* Read accelerometer data */
	check=UB_I2C1_ReadMultiByte(DataStruct->Address, MPU6050_ACCEL_XOUT_H,6);
	if(check<0) return TM_MPU6050_Result_Error;
	
	/* Format */
	DataStruct->Accelerometer_X = (int16_t)(I2C1_DATA[0] << 8 | I2C1_DATA[1]);
	DataStruct->Accelerometer_Y = (int16_t)(I2C1_DATA[2] << 8 | I2C1_DATA[3]);
	DataStruct->Accelerometer_Z = (int16_t)(I2C1_DATA[4] << 8 | I2C1_DATA[5]);
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_ReadGyroscope(TM_MPU6050_t* DataStruct) {
	int16_t check;
	
	/* Read gyroscope data */
	check=UB_I2C1_ReadMultiByte(DataStruct->Address, MPU6050_GYRO_XOUT_H,6);
	if(check<0) return TM_MPU6050_Result_Error;
	
	/* Format */
	DataStruct->Gyroscope_X = (int16_t)(I2C1_DATA[0] << 8 | I2C1_DATA[1]);
	DataStruct->Gyroscope_Y = (int16_t)(I2C1_DATA[2] << 8 | I2C1_DATA[3]);
	DataStruct->Gyroscope_Z = (int16_t)(I2C1_DATA[4] << 8 | I2C1_DATA[5]);

	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_ReadTemperature(TM_MPU6050_t* DataStruct) {
	int16_t check;
	
	/* Read temperature */
	check=UB_I2C1_ReadMultiByte(DataStruct->Address, MPU6050_TEMP_OUT_H,2);
	if(check<0) return TM_MPU6050_Result_Error;
	
	/* Format temperature */
	check = (I2C1_DATA[0] << 8 | I2C1_DATA[1]);
	DataStruct->Temperature = (float)((int16_t)check / (float)340.0 + (float)36.53);
	
	/* Return OK */
	return TM_MPU6050_Result_Ok;
}

TM_MPU6050_Result_t TM_MPU6050_ReadAll(TM_MPU6050_t* DataStruct) {
	int16_t check;
	
	/* Read full raw data, 14bytes */
	check=UB_I2C1_ReadMultiByte(DataStruct->Address, MPU6050_ACCEL_XOUT_H,14);
	if(check<0) return TM_MPU6050_Result_Error;
	
	/* Format accelerometer data */
	/*
	DataStruct->Accelerometer_X = (int16_t)(I2C1_DATA[0] << 8 | I2C1_DATA[1]);
	DataStruct->Accelerometer_Y = (int16_t)(I2C1_DATA[2] << 8 | I2C1_DATA[3]);
	DataStruct->Accelerometer_Z = (int16_t)(I2C1_DATA[4] << 8 | I2C1_DATA[5]);
	*/
	DataStruct->Gyroscope_X = (int16_t)(I2C1_DATA[0] << 8 | I2C1_DATA[1]);
	DataStruct->Gyroscope_Y = (int16_t)(I2C1_DATA[2] << 8 | I2C1_DATA[3]);
	DataStruct->Gyroscope_Z = (int16_t)(I2C1_DATA[4] << 8 | I2C1_DATA[5]);

	/* Format temperature */
	check = (I2C1_DATA[6] << 8 | I2C1_DATA[7]);
	DataStruct->Temperature = (float)((float)((int16_t)check) / (float)340.0 + (float)36.53);
	
	/* Format gyroscope data */
	/*
	DataStruct->Gyroscope_X = (int16_t)(I2C1_DATA[8] << 8 | I2C1_DATA[9]);
	DataStruct->Gyroscope_Y = (int16_t)(I2C1_DATA[10] << 8 | I2C1_DATA[11]);
	DataStruct->Gyroscope_Z = (int16_t)(I2C1_DATA[12] << 8 | I2C1_DATA[13]);
	*/
	DataStruct->Accelerometer_X = (int16_t)(I2C1_DATA[8] << 8 | I2C1_DATA[9]);
	DataStruct->Accelerometer_Y = (int16_t)(I2C1_DATA[10] << 8 | I2C1_DATA[11]);
	DataStruct->Accelerometer_Z = (int16_t)(I2C1_DATA[12] << 8 | I2C1_DATA[13]);

	/* Return OK */
	return TM_MPU6050_Result_Ok;
}
