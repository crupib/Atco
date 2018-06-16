/***********************************************************************************************************************
MMBasic

I2C_F7.c

Handles all the I2C related commands and functions for the STM32F7 version of MMBasic.


Copyright 2011 - 2014 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following 
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/

#include <stdio.h>

#include <stdio.h>
#include <math.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"



//-----------------------------------------
// internal functions
void i2cEnable(char *p);
void i2c_enable(int bps, int timeout);
void i2cDisable(char *p);
void i2c_disable(void);
void i2cSend(char *p);
void i2cReceive(char *p);
//-----------------------------------------
char CvtToBCD(char *p, int min, int max);
//-----------------------------------------


//-----------------------------------------
// internal variables
int i2c1 = 0;														// true if I2C1 is enabled
static float *I2C_Rcvbuf_Float;										// pointer to the master receive buffer for a float
static char *I2C_Rcvbuf_String;										// pointer to the master receive buffer for a string

// defines for MM.I2C
#define I2C_MMI2C_NoAck				1
#define I2C_MMI2C_Timeout			2
static int mmI2Cvalue;												// value of MM.I2C


/********************************************************************************************************************************************
 custom commands and functions
 each function is responsible for decoding a command
 all function names are in the form cmd_xxxx() (for a basic command) or fun_xxxx() (for a basic function) so, if you want to search for the
 function responsible for the NAME command look for cmd_name

 There are 4 items of information that are setup before the command is run.
 All these are globals.

 int cmdtoken	This is the token number of the command (some commands can handle multiple
				statement types and this helps them differentiate)

 char *cmdline	This is the command line terminated with a zero char and trimmed of leading
				spaces.  It may exist anywhere in memory (or even ROM).

 char *nextstmt	This is a pointer to the next statement to be executed.  The only thing a
				command can do with it is save it or change it to some other location.

 char *CurrentLinePtr  This is read only and is set to NULL if the command is in immediate mode.

 The only actions a command can do to change the program flow is to change nextstmt or
 execute longjmp(mark, 1) if it wants to abort the program.

 ********************************************************************************************************************************************/

/****************************************************************************************************************************
 BASIC I2C Commands and Functions
*****************************************************************************************************************************/


// basic i2c commands
// syntax : I2C OPEN speed,timeout
// syntax : I2C CLOSE
// syntax : I2C WRITE adr,option,cnt,data
// syntax : I2C READ adr,option,cnt,buffer
void cmd_i2c(void) {

    char *p;

    if((p = checkstring(cmdline, "OPEN")) != NULL)
        i2cEnable(p);
    else if((p = checkstring(cmdline, "CLOSE")) != NULL)
        i2cDisable(p);
    else if((p = checkstring(cmdline, "WRITE")) != NULL)
        i2cSend(p);
    else if((p = checkstring(cmdline, "READ")) != NULL)
        i2cReceive(p);
    else error("Unknown command");
}

// function to return i2c status
// syntax : MM.I2C
void fun_mmi2c(void) {
	fret = (float)mmI2Cvalue;
}

// enable the I2C1 module - master mode
void i2cEnable(char *p) {
	int speed, timeout;
	getargs(&p, 3, ",");
	if(argc != 3) error("Invalid syntax");
	speed = getinteger(argv[0]);
	if(speed < 10 || speed > 400) error("Number out of bounds");
	timeout = getinteger(argv[2]);
	if(timeout < 0 || (timeout > 0 && timeout < 100)) error("Number out of bounds" );

	i2c_enable(speed,timeout);
}

// disable the I2C1 module - master mode
void i2cDisable(char *p) {

	i2c_disable();
}

// send data to an I2C slave - master mode
void i2cSend(char *p) {
	int addr, i2c_options, sendlen, i;
	void *ptr = NULL;
	unsigned char *cptr = NULL;
	int i2c_ret;

	getargs(&p, 99, ",");
	if(!(argc & 0x01) || (argc < 7)) error("Invalid syntax");
	if(!i2c1) error("I2C port not open");
	addr = getinteger(argv[0]);
	i2c_options = getinteger(argv[2]);
	if(i2c_options < 0 || i2c_options > 3) error("Number out of bounds");
	if(i2c_options !=0) error("option must be 0");
	if(addr < 0x00 || (addr > 0x00 && addr < 0x08) || addr > 0x77) error("Invalid address");
	sendlen = getinteger(argv[4]);
	if(sendlen < 1 || sendlen > 255) error("Number out of bounds");
	if(sendlen == 1) {		// single data
		if(sendlen != ((argc - 5) >> 1)) error("Incorrect argument count");
		I2C1_DATA[0] = getinteger(argv[6]);
	}
	else if(argc > 7) {		// numeric expressions for data
		if(sendlen != ((argc - 5) >> 1)) error("Incorrect argument count");
		for (i = 0; i < sendlen; i++) {
			I2C1_DATA[i] = getinteger(argv[i + i + 6]);
		}
	} else {		// an array of float or a string
		ptr = findvar(argv[6], V_NOFIND_NULL);
		if(ptr == NULL) error("Invalid variable");
		if((vartbl[VarIndex].type & T_STR) && vartbl[VarIndex].dims[0] == 0) {		// string
			cptr = (unsigned char *)ptr;
			cptr++;																	// skip the length byte in a MMBasic string
			for (i = 0; i < sendlen; i++) {
				I2C1_DATA[i] = (int)(*(cptr + i));
			}
		} else if((vartbl[VarIndex].type & T_NBR) && vartbl[VarIndex].dims[0] != 0 && vartbl[VarIndex].dims[1] == 0) {		// numeric array
			if( (((float *)ptr - vartbl[VarIndex].val.fa) + sendlen) > (vartbl[VarIndex].dims[0] + 1 - OptionBase) ) {
				error("Insufficient data");
			} else {
				for (i = 0; i < sendlen; i++) {
					I2C1_DATA[i] = (int)(*((float *)ptr + i));
				}
			}
		} else error("Invalid variable");
	}

	// send data over i2c
	i2c_ret=MM_I2C1_WriteMultiByte((addr<<1),sendlen);
	mmI2Cvalue=0;
	if(i2c_ret<0) mmI2Cvalue=I2C_MMI2C_NoAck;
}

// receive data from an I2C slave - master mode
void i2cReceive(char *p) {
	int addr, i2c_options, rcvlen;
	void *ptr = NULL;
	int i,i2c_ret;

	getargs(&p, 7, ",");
	if(argc != 7) error("Invalid syntax");
	if(!i2c1) error("I2C port not open");
	addr = getinteger(argv[0]);
	i2c_options = getinteger(argv[2]);
	if(i2c_options < 0 || i2c_options > 3) error("Number out of bounds");
	if(i2c_options !=0) error("option must be 0");
	if(addr < 0x01 || (addr > 0x00 && addr < 0x08) || addr > 0x77) error("Invalid address");
	rcvlen = getinteger(argv[4]);
	if(rcvlen < 1 || rcvlen > 255) error("Number out of bounds");
	ptr = findvar(argv[6], V_FIND);
	if(ptr == NULL) error("Invalid variable");
	if(vartbl[VarIndex].type & T_NBR) {
        if(vartbl[VarIndex].dims[1] != 0) error("Invalid variable");
        if(vartbl[VarIndex].dims[0] == 0) {		// Not an array
            if(rcvlen != 1) error("Invalid variable");
        } else {		// An array
            if( (((float *)ptr - vartbl[VarIndex].val.fa) + rcvlen) > (vartbl[VarIndex].dims[0] + 1 - OptionBase) )
                error("Insufficient space in array");
        }
        I2C_Rcvbuf_Float = (float*)ptr;
        I2C_Rcvbuf_String = NULL;
    } else if(vartbl[VarIndex].type & T_STR) {
        if(vartbl[VarIndex].dims[0] != 0) error("Invalid variable");
        *(char *)ptr = rcvlen;
        I2C_Rcvbuf_String = (char *)ptr + 1;
        I2C_Rcvbuf_Float = NULL;
    } else
        error("Invalid variable");

	// receive data over i2c
	i2c_ret=MM_I2C1_ReadMultiByte((addr<<1),rcvlen);
	if(i2c_ret<0) {
		mmI2Cvalue=I2C_MMI2C_NoAck;
		if(I2C_Rcvbuf_Float != NULL) {
       	  for(i=0;i<rcvlen;i++) {
               I2C_Rcvbuf_Float[i] = 0;
       	  }
		}
		else {
       	  for(i=0;i<rcvlen;i++) {
       		  I2C_Rcvbuf_String[i] = 0;
       	  }
		}
	}
	else {
		mmI2Cvalue=0;
		if(I2C_Rcvbuf_Float != NULL) {
       	  for(i=0;i<rcvlen;i++) {
               I2C_Rcvbuf_Float[i] = I2C1_DATA[i];
       	  }
		}
		else {
       	  for(i=0;i<rcvlen;i++) {
       		  I2C_Rcvbuf_String[i] = I2C1_DATA[i];
       	  }
		}
	}
}


/**************************************************************************************************
Enable the I2C1 module - master mode
***************************************************************************************************/
void i2c_enable(int bps, int timeout) {
	if(!i2c1) {
		i2c1 = true;
		ExtCfg(P_I2C1_SDA, EXT_COM_RESERVED);						// reserve the pin for com use
		ExtCfg(P_I2C1_SCL, EXT_COM_RESERVED);
		MM_I2C1_Init(bps,timeout);

	}
	else error("I2C port is already open");
}


/**************************************************************************************************
Disable the I2C1 module - master mode
***************************************************************************************************/
void i2c_disable(void) {
	if(i2c1) {
		i2c1 = false;

		ExtCfg(P_I2C1_SDA, EXT_NOT_CONFIG);								// set pins to unconfigured
		ExtCfg(P_I2C1_SCL, EXT_NOT_CONFIG);
		MM_I2C1_DeInit();
		I2C_Rcvbuf_Float = NULL;
		I2C_Rcvbuf_String = NULL;
	}
}



/****************************************************************************************************************************
 RTC Commands and Functions (external RTC-IC : PCF8563 or PCF8583)
*****************************************************************************************************************************/


// commands for external I2C-IC (typ = PCF8563 or PCF8583)
// syntax : RTC GETTIME [typ]
// syntax : RTC SETTIME y,m,d,h,m,s[,typ]
void cmd_rtc(void) {
    int temp_enabled=0;
    char *p,y,d;
    int i2c_ret, slave_adr,rtc_ic;

    if(!i2c1) {     // enable i2c temporarily
    	temp_enabled=1;
        i2c_enable(100,100); // standard settings 100kHz, 100ms
    }

    if((p = checkstring(cmdline, "GETTIME")) != NULL) {
      // get rtc typ
      getargs(&p, 3, ",");
      rtc_ic=0; // default = PCF8563
      if(argc == 1) {
    	if((p = checkstring(argv[0], "PCF8583")) != NULL) rtc_ic=1;
      }
      if(argc > 1) error("Invalid syntax");
      // read time from rtc
      if(rtc_ic==0) {
    	// RTC = PCF8563
    	slave_adr=0x51;
    	// send one byte to RTC
    	I2C1_DATA[0]=0x02; // register adr
    	i2c_ret=MM_I2C1_WriteMultiByte((slave_adr<<1),1);
    	if(i2c_ret<0) error("PCF8563 not responding");
    	// read 7 bytes from RTC
    	i2c_ret=MM_I2C1_ReadMultiByte((slave_adr<<1),7);
    	if(i2c_ret<0) error("PCF8563 not responding");
    	// convert data in time
        second = ((I2C1_DATA[0] & 0x7f) >> 4) * 10 + (I2C1_DATA[0] & 0x0f);
        minute = ((I2C1_DATA[1] & 0x7f) >> 4) * 10 + (I2C1_DATA[1] & 0x0f);
        hour = ((I2C1_DATA[2] & 0x3f) >> 4) * 10 + (I2C1_DATA[2] & 0x0f);
        day = ((I2C1_DATA[3] & 0x3f) >> 4) * 10 + (I2C1_DATA[3] & 0x0f);
        month = ((I2C1_DATA[5] & 0x1f) >> 4) * 10 + (I2C1_DATA[5] & 0x0f);
        year = (I2C1_DATA[6] >> 4) * 10 + (I2C1_DATA[6] & 0x0f) + 2000;
      }
      else if(rtc_ic==1) {
    	// RTC = PCF8583
    	slave_adr=0x50;
    	// send one byte to RTC
    	I2C1_DATA[0]=0x02; // register adr
    	i2c_ret=MM_I2C1_WriteMultiByte((slave_adr<<1),1);
    	if(i2c_ret<0) error("PCF8583 not responding");
    	// read 5 bytes from RTC
    	i2c_ret=MM_I2C1_ReadMultiByte((slave_adr<<1),5);
    	if(i2c_ret<0) error("PCF8583 not responding");
    	// convert data in time
        second = ((I2C1_DATA[0] & 0x7f) >> 4) * 10 + (I2C1_DATA[0] & 0x0f);
        minute = ((I2C1_DATA[1] & 0x7f) >> 4) * 10 + (I2C1_DATA[1] & 0x0f);
        hour = ((I2C1_DATA[2] & 0x3f) >> 4) * 10 + (I2C1_DATA[2] & 0x0f);
        day = ((I2C1_DATA[3] & 0x3f) >> 4) * 10 + (I2C1_DATA[3] & 0x0f);
        month = ((I2C1_DATA[4] & 0x1f) >> 4) * 10 + (I2C1_DATA[4] & 0x0f);
        year = ((I2C1_DATA[3] & 0xC0) >> 6) + 2015;
      }
    } else if((p = checkstring(cmdline, "SETTIME")) != NULL) {
      // get rtc typ
      getargs(&p, 13, ",");
      if((argc < 11) || (argc > 13)) error("Invalid syntax");
      rtc_ic=0; // default = PCF8563
      if(argc == 13) {
   		if((p = checkstring(argv[12], "PCF8583")) != NULL) rtc_ic=1;
      }
      // send time to rtc
      if(rtc_ic==0) {
      	// RTC = PCF8563
      	slave_adr=0x51;
      	// send 8 bytes to RTC
    	I2C1_DATA[0]=0x02; // register adr
    	I2C1_DATA[1] = CvtToBCD(argv[10], 0, 59);    // s
    	I2C1_DATA[2] = CvtToBCD(argv[8], 0, 59); // m
    	I2C1_DATA[3] = CvtToBCD(argv[6], 0, 23); // h
    	I2C1_DATA[4] = CvtToBCD(argv[4], 1, 31); // d
    	I2C1_DATA[5] = 1;
    	I2C1_DATA[6] = CvtToBCD(argv[2], 1, 12); // m
    	I2C1_DATA[7] = CvtToBCD(argv[0], 0, 99); // y
    	i2c_ret=MM_I2C1_WriteMultiByte((slave_adr<<1),8);
    	if(i2c_ret<0) error("PCF8563 not responding");
      }
      else if(rtc_ic==1) {
    	// RTC = PCF8583
    	slave_adr=0x50;
    	// send 6 bytes to RTC
    	I2C1_DATA[0]=0x02; // register adr
    	I2C1_DATA[1] = CvtToBCD(argv[10], 0, 59); // s
    	I2C1_DATA[2] = CvtToBCD(argv[8], 0, 59); // m
    	I2C1_DATA[3] = CvtToBCD(argv[6], 0, 23); // h
    	d=CvtToBCD(argv[4], 1, 31); //d
    	y=getinteger(argv[0]); // y
    	if((y<15) || (y>18)) error("Number out of bounds");
    	y=((y-15)<<6);
    	I2C1_DATA[4] = (y|d);
    	I2C1_DATA[5] = CvtToBCD(argv[2], 1, 12); // m
    	i2c_ret=MM_I2C1_WriteMultiByte((slave_adr<<1),6);
    	if(i2c_ret<0) error("PCF8583 not responding");
      }
    } else
        error("Unknown command");


    if(temp_enabled==1) { // close i2c
    	i2c_disable();
    }
}

// rtc data converter
char CvtToBCD(char *p, int min, int max) {
    int t;
    t = getinteger(p);
    if(t < min || t > max) error("Number out of bounds");
    return ((t / 10) << 4) | (t % 10);
}



/****************************************************************************************************************************
 MPU6050 Commands and Functions (external MPU-IC : MPU6050)
*****************************************************************************************************************************/


// commands for external I2C-IC (typ = MPU6050)
// syntax : MPU6050 INIT
void cmd_mpu6050(void) {
	char *p;
	int temp_enabled=0;
	TM_MPU6050_Result_t check;

	if((p = checkstring(cmdline, "INIT")) != NULL) {
		// enable i2c if necessary
	    if(!i2c1) {
	    	temp_enabled=1;
	    	i2c_enable(100,100); // standard settings 100kHz, 100ms
	    }
	    mpu6050_initialized = 0;
	    check=TM_MPU6050_Init(&MPU6050, TM_MPU6050_Device_0, TM_MPU6050_Accelerometer_8G, TM_MPU6050_Gyroscope_250s);
		if(check == TM_MPU6050_Result_Ok){
			mpu6050_initialized = 1;
			MPU6050.Accelerometer_X = 0;
			MPU6050.Accelerometer_Y = 0;
			MPU6050.Accelerometer_Z = 0;
			MPU6050.Gyroscope_X = 0;
			MPU6050.Gyroscope_Y = 0;
			MPU6050.Gyroscope_Z = 0;
			MPU6050.Temperature = 0.0;
		}
		else {
		    if(temp_enabled==1) { // close i2c
		    	i2c_disable();
		    }
		}
		if(check == TM_MPU6050_Result_Error) error("MPU6050 Unknown error");
		if(check == TM_MPU6050_Result_DeviceNotConnected) error("MPU6050 not connected");
		if(check == TM_MPU6050_Result_DeviceInvalid) error("MPU6050 not at this address");
		return;
    } else
        error("Unknown command");
}

// function for external I2C-IC (typ = MPU6050)
// syntax : MPU6050(#S)
// syntax : MPU6050(#GyroX) or MPU6050(#GyroY) or MPU6050(#GyroZ)
// syntax : MPU6050(#AccX) or MPU6050(#AccY) or MPU6050(#AccZ)
// syntax : MPU6050(#TEMP)
void fun_mpu6050(void) {
	char *p;
	TM_MPU6050_Result_t check;

	if(mpu6050_initialized == 0) error("Initialize the MPU6050 first");

	if((p = checkstring(ep, "#S")) != NULL) { // read all data and get status (0=ok, -1=error)
		check=TM_MPU6050_ReadAll(&MPU6050);
		fret=(float)(0);
		if(check!=TM_MPU6050_Result_Ok) fret=(float)(-1);
		return;
	}
	if((p = checkstring(ep, "#GYROX")) != NULL) { // read gyro_x
		fret=(int16_t)(MPU6050.Gyroscope_X);
		return;
	}
	if((p = checkstring(ep, "#GYROY")) != NULL) { // read gyro_x
		fret=(int16_t)(MPU6050.Gyroscope_Y);
		return;
	}
	if((p = checkstring(ep, "#GYROZ")) != NULL) { // read gyro_y
		fret=(int16_t)(MPU6050.Gyroscope_Z);
		return;
	}
	if((p = checkstring(ep, "#ACCX")) != NULL) { // read acc_x
		fret=(int16_t)(MPU6050.Accelerometer_X);
		return;
	}
	if((p = checkstring(ep, "#ACCY")) != NULL) { // read acc_y
		fret=(int16_t)(MPU6050.Accelerometer_Y);
		return;
	}
	if((p = checkstring(ep, "#ACCZ")) != NULL) { // read acc_z
		fret=(int16_t)(MPU6050.Accelerometer_Z);
		return;
	}
	if((p = checkstring(ep, "#TEMP")) != NULL) { // read temp
		fret=(float)(MPU6050.Temperature);
		return;
	}

	error("Invalid Syntax");
}




