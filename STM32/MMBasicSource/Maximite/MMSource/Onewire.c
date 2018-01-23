/***********************************************************************************************************************
MMBasic

Onewire.c

Handles all the commands and functions related to One Wire support.

The one wire support is based on code from Dallas Semiconductor Corporation:


Copyright 2012 Gerard Sexton
This file is free software: you can redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
option) any later version.

 Copyright (C) 1999-2006 Dallas Semiconductor Corporation,
 All Rights Reserved.

 Permission is hereby granted, free of charge,
 to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to
 deal in the Software without restriction, including
 without limitation the rights to use, copy, modify,
 merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom
 the Software is furnished to do so, subject to the
 following conditions:

 The above copyright notice and this permission notice
 shall be included in all copies or substantial portions
 of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
 ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 PARTICULAR PURPOSE AND NONINFRINGEMENT.
 IN NO EVENT SHALL DALLAS SEMICONDUCTOR BE LIABLE FOR ANY
 CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.

************************************************************************************************************************/



#include <plib.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"


void owReset(char *p);
void owWrite(char *p);
void owRead(char *p);
void owSearch(char *p);


#ifdef INCLUDE_1WIRE_SEARCH
static int LastDiscrepancy;
static int LastFamilyDiscrepancy;
static int LastDeviceFlag;
static unsigned char SerialNum[8];
static unsigned short utilcrc16;
static unsigned char utilcrc8;

static const unsigned char dscrc_table[] = {
        0, 94,188,226, 97, 63,221,131,194,156,126, 32,163,253, 31, 65,
      157,195, 33,127,252,162, 64, 30, 95,  1,227,189, 62, 96,130,220,
       35,125,159,193, 66, 28,254,160,225,191, 93,  3,128,222, 60, 98,
      190,224,  2, 92,223,129, 99, 61,124, 34,192,158, 29, 67,161,255,
       70, 24,250,164, 39,121,155,197,132,218, 56,102,229,187, 89,  7,
      219,133,103, 57,186,228,  6, 88, 25, 71,165,251,120, 38,196,154,
      101, 59,217,135,  4, 90,184,230,167,249, 27, 69,198,152,122, 36,
      248,166, 68, 26,153,199, 37,123, 58,100,134,216, 91,  5,231,185,
      140,210, 48,110,237,179, 81, 15, 78, 16,242,172, 47,113,147,205,
       17, 79,173,243,112, 46,204,146,211,141,111, 49,178,236, 14, 80,
      175,241, 19, 77,206,144,114, 44,109, 51,209,143, 12, 82,176,238,
       50,108,142,208, 83, 13,239,177,240,174, 76, 18,145,207, 45,115,
      202,148,118, 40,171,245, 23, 73,  8, 86,180,234,105, 55,213,139,
       87,  9,235,181, 54,104,138,212,149,203, 41,119,244,170, 72, 22,
      233,183, 85, 11,136,214, 52,106, 43,117,151,201, 74, 20,246,168,
      116, 42,200,150, 21, 75,169,247,182,232, 10, 84,215,137,107, 53};

#endif

static int mmOWvalue;                                               // value of MM.OW
static const unsigned short oddparity[16] = { 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0 };


void ow_pinChk(int pin);
int ow_reset(int pin);
void ow_writeByte(int pin, int data);
int ow_readByte(int pin);
int ow_verifyByte(int pin, int data);
int ow_touchByte(int pin, int data);
int ow_touchBit(int pin, int );
void ow_writeBit(int pin, int );
int ow_readBit(int pin);

void setcrc16(unsigned short reset);
unsigned short docrc16(unsigned short cdata);
void setcrc8(unsigned char reset);
unsigned char docrc8(unsigned char cdata);

int ow_first(int pin, int do_reset, int alarm_only);
int ow_next(int pin, int do_reset, int alarm_only);
int ow_verify(int pin, int alarm_only);
void ow_serialNum(unsigned char *serialnum_buf, int do_read);
void ow_familySearchSetup(int search_family);
void ow_skipFamily(void);



// the main OneWire command
void cmd_onewire(void) {
    char *p;

    if((p = checkstring(cmdline, "RESET")) != NULL)
        owReset(p);
    else if((p = checkstring(cmdline, "WRITE")) != NULL)
        owWrite(p);
    else if((p = checkstring(cmdline, "READ")) != NULL)
        owRead(p);
#ifdef INCLUDE_1WIRE_SEARCH
    else if((p = checkstring(cmdline, "SEARCH")) != NULL)
        owSearch(p);
#endif
    else
        error("Unknown command");
}




/****************************************************************************************************************************
 The DS18B20 command and function
*****************************************************************************************************************************/


void Init_ds18b20(int pin, int precision) {
    // set up initial pin status (open drain, output, high)
    ow_pinChk(pin);
    ExtCfg(pin, EXT_NOT_CONFIG);                                    // set pin to unconfigured
    PinSetBit(pin, ODCSET);
    PinSetBit(pin, LATSET);
    PinSetBit(pin, TRISCLR);

    ow_reset(pin);
    ow_writeByte(pin, 0xcc);                                        // command skip the ROM
    ow_writeByte(pin, 0x4E);                                        // write to the scratchpad
    ow_writeByte(pin, 0x00);                                        // dummy data to TH
    ow_writeByte(pin, 0x00);                                        // dummy data to TL
    ow_writeByte(pin, precision << 5);                              // select the resolution
    ow_reset(pin);
    ow_writeByte(pin, 0xcc);                                        // skip the ROM
    ow_writeByte(pin, 0x44);                                        // command start the conversion
    PinSetBit(pin, ODCCLR);                                         // set strong pullup
    ds18b20Timer = 100 << precision;                                // start the conversion timer
}



void cmd_ds18b20(void) {
    int pin, precision;
	getargs(&cmdline, 3, ",");
    if(argc < 1) error("Invalid syntax");
//    if(checkstring(argv[0], "START") == NULL) error("Unknown command");
    if(ds18b20Timer != -1) error("Already open");
    pin = GetPinNbr(argv[0]);
    ow_pinChk(pin);
    precision = 1;
    if(argc == 3) precision = getint(argv[2], 0, 3);
    Init_ds18b20(pin, precision);
}



void fun_ds18b20(void) {
    int pin, b1, b2;

    pin = GetPinNbr(ep);
    ow_pinChk(pin);

    if(ds18b20Timer == -1) {
        Init_ds18b20(pin, 1);                                       // 200mS to convert 10 bits
    }
	while(ds18b20Timer);
    ds18b20Timer = -1;

	if(!ow_readBit(pin)) {
		ExtCfg(pin, EXT_NOT_CONFIG);
		error("DS18B20 not responding");
	}
	ow_reset(pin);
	ow_writeByte(pin, 0xcc);                                        // skip the ROM (again)
	ow_writeByte(pin, 0xBE);                                        // command read data
	b1  = ow_readByte(pin);
	b2  = ow_readByte(pin);
	ow_reset(pin);
	ExtCfg(pin, EXT_NOT_CONFIG);									// set pin to unconfigured

    fret = (float)(((b2 & 0b111) << 8) | b1) / 16.0;
    if(b2 & 0b1000) fret = -fret;
}




/****************************************************************************************************************************
 General functions
*****************************************************************************************************************************/




// send one wire reset and optionally return presence response
void owReset(char *p) {
	int pin;

	pin = GetPinNbr(p);
	ow_pinChk(pin);

// set up initial pin status (open drain, output, high)
	ExtCfg(pin, EXT_NOT_CONFIG);									// set pin to unconfigured
	PinSetBit(pin, ODCSET);
	PinSetBit(pin, LATSET);
	PinSetBit(pin, TRISCLR);

	ow_reset(pin);
	return;
}


// send one wire data
void owWrite(char *p) {
	int pin, flag, len, i, buf[255], type = 0;
	char *cp;

	getargs(&p, MAX_ARG_COUNT*2, ",");
	if (!(argc & 0x01) || (argc < 7)) error("Invalid syntax");
	pin = GetPinNbr(argv[0]);
	ow_pinChk(pin);

	flag = getinteger(argv[2]);
	if (flag < 0 || flag > 15) error("Number out of bounds");
	len = getinteger(argv[4]);
	if (len < 1 || len > 255) error("Number out of bounds");

	// check the first char for a legal variable name
	cp = argv[6];
	skipspace(cp);
	if (isnamestart(*cp)) type = 1;
	//if (argc > 7 || (len == 1 && type == 0)) {                    // numeric expressions for data
		if (len != ((argc - 5) >> 1)) error("Incorrect argument count");
		for (i = 0; i < len; i++) {
			buf[i] = getinteger(argv[i + i + 6]);
		}

// set up initial pin status (open drain, output, high)
	ExtCfg(pin, EXT_NOT_CONFIG);									// set pin to unconfigured
	PinSetBit(pin, ODCSET);
	PinSetBit(pin, LATSET);
	PinSetBit(pin, TRISCLR);

	if (flag & 0x01) ow_reset(pin);
	for (i = 0; i < len; i++) {
		if (flag & 0x04) {
			ow_writeBit(pin, buf[i]);
		} else {
			ow_writeByte(pin, buf[i]);
		}
	}
	if (flag & 0x02) ow_reset(pin);

	if (flag & 0x08) {												// strong pullup required?
		PinSetBit(pin, ODCCLR);										// set strong pullup
	}
	return;
}


// read one wire data
void owRead(char *p) {
	int pin, flag, len, i, buf[255];
	void *ptr = NULL;

	getargs(&p, MAX_ARG_COUNT*2, ",");
	if (!(argc & 0x01) || (argc < 7)) error("Invalid syntax");
	pin = GetPinNbr(argv[0]);
	ow_pinChk(pin);

	flag = getinteger(argv[2]);
	if (flag < 0 || flag > 15) error("Number out of bounds");
	len = getinteger(argv[4]);
	if (len < 1 || len > 255) error("Number out of bounds");

    if (len != ((argc - 5) >> 1)) error("Incorrect argument count");
    for (i = 0; i < len; i++) {
        ptr = findvar(argv[i + i + 6], V_FIND);
        if (!(vartbl[VarIndex].type & T_NBR) || vartbl[VarIndex].dims[0] != 0) error("Invalid variable");
    }

// set up initial pin status (open drain, output, high)
	ExtCfg(pin, EXT_NOT_CONFIG);									// set pin to unconfigured
	PinSetBit(pin, ODCSET);
	PinSetBit(pin, LATSET);
	PinSetBit(pin, TRISCLR);

	if (flag & 0x01) ow_reset(pin);
	for (i = 0; i < len; i++) {
		if (flag & 0x04) {
			buf[i] = ow_readBit(pin);
		} else {
			buf[i] = ow_readByte(pin);
		}
	}
	if (flag & 0x02) ow_reset(pin);

	if (flag & 0x08) {												// strong pullup required?
		PinSetBit(pin, ODCCLR);										// set strong pullup
	}

	for (i = 0; i < len; i++) {
			ptr = findvar(argv[i + i + 6], V_FIND);
			*((float *)ptr) = buf[i];
	}

	return;
}


#ifdef INCLUDE_1WIRE_SEARCH
// One wire search
// flag:  1 = reset search
//        2 = alarm set
//        4 = family search
//        8 = skip current family
//       16 = verify
//
void owSearch(char *p) {
	int pin, flag, alarm, i;
	void *ptr = NULL;
	unsigned char buf[8];

	getargs(&p, MAX_ARG_COUNT*2, ",");
	if (!(argc & 0x01) || (argc < 5)) error("Invalid syntax");
	pin = GetPinNbr(argv[0]);
	ow_pinChk(pin);

	flag = getinteger(argv[2]);
	if (flag < 0 || flag > 31) error("Number out of bounds");
	if (((flag & 0x01) && flag > 3) || ((flag & 0x04) && flag > 7) || ((flag & 0x08) && flag > 15)) error("Invalid flag combination");

	if ((flag & 0x04) || (flag & 0x10)) {
		ptr = findvar(argv[4], V_NOFIND_NULL);
	} else {
		ptr = findvar(argv[4], V_FIND);
	}
	if (ptr == NULL) error("Cannot find variable");
    if (8 != ((argc - 3) >> 1)) error("Incorrect argument count");
    for (i = 0; i < 8; i++) {
        if (flag & 0x10) {
            ptr = findvar(argv[i + i + 4], V_NOFIND_NULL);
        } else {
            ptr = findvar(argv[i + i + 4], V_FIND);
        }
        if (ptr == NULL) error("Variable not found");
        if (!(vartbl[VarIndex].type & T_NBR) || vartbl[VarIndex].dims[0] != 0) error("Invalid variable");
        if ((flag & 0x04) && (i == 0)) buf[0] = (unsigned char)(*((float *)ptr));
        if (flag & 0x10) buf[i] = (unsigned char)(*((float *)ptr));
    }
	if (flag & 0x02) alarm = 1; else alarm = 0;

	// set up initial pin status (open drain, output, high)
	ExtCfg(pin, EXT_NOT_CONFIG);									// set pin to unconfigured
	PinSetBit(pin, ODCSET);
	PinSetBit(pin, LATSET);
	PinSetBit(pin, TRISCLR);

	if (flag & 0x01) {
		mmOWvalue = ow_first(pin, 1, alarm);
	} else if (flag & 0x04) {
		ow_familySearchSetup(buf[0]);
		mmOWvalue = ow_next(pin, 1, alarm);
	} else if (flag & 0x08) {
		ow_skipFamily();
		mmOWvalue = ow_next(pin, 1, alarm);
	} else if (flag & 0x10) {
		ow_serialNum(buf, 0);
		mmOWvalue = ow_verify(pin, alarm);
	} else {
		mmOWvalue = ow_next(pin, 1, alarm);
	}

	for (i = 0; i < 8; i++) {
			ptr = findvar(argv[i + i + 4], V_FIND);
			*((float *)ptr) = SerialNum[i];
	}

	return;
}
#endif

//void fun_owCRC8(void){
//	int len, i, x;
//	unsigned char buf[255], uc = 0;
//
//	getargs(&ep, MAX_ARG_COUNT*2, ",");								// this is a macro and must be the first executable stmt in a block
//	if (!(argc & 0x01) || (argc < 3)) error("Invalid syntax");
//	len = getinteger(argv[0]);
//	if ((len < 1) || (len > 255)) error("Number out of bounds");
//
//    if (len != ((argc - 1) >> 1)) error("Incorrect argument count");
//    for (i = 0; i < len; i++) {
//        x = getinteger(argv[i + i + 6]);
//        if (x < 0 || x > 255) error("Number out of bounds");
//        buf[i] = (unsigned char)x;
//    }
//	setcrc8(0);
//	for (i = 0; i < len; i++) {
//		uc = docrc8(buf[i]);
//	}
//	fret = (float)uc;
//}


//void fun_owCRC16(void){
//	int len, i, x;
//	unsigned short buf[255], us = 0;
//
//	getargs(&ep, MAX_ARG_COUNT*2, ",");								// this is a macro and must be the first executable stmt in a block
//	if (!(argc & 0x01) || (argc < 3)) error("Invalid syntax");
//	len = getinteger(argv[0]);
//	if ((len < 1) || (len > 255)) error("Number out of bounds");
//    if (len != ((argc - 1) >> 1)) error("Incorrect argument count");
//    for (i = 0; i < len; i++) {
//        x = getinteger(argv[i + i + 6]);
//        if (x < 0 || x > 65535) error("Number out of bounds");
//        buf[i] = (unsigned short)x;
//    }
//	setcrc16(0);
//	for (i = 0; i < len; i++) {
//		us = docrc16(buf[i]);
//	}
//	fret = (float)us;
//}


void fun_mmOW(void) {
	fret = (float)mmOWvalue;
}


void ow_pinChk(int pin) {
	if (pin < 1 || pin > NBRPINS) error("Invalid I/O pin");
	if (ExtCurrentConfig[pin] >= EXT_COM_RESERVED) error("Pin is allocated to a communications function");
}


// send one wire reset and detect presence response - returns 1 if found else 0
int ow_reset(int pin) {
	PinSetBit(pin, LATCLR);											// drive pin low
	uSec(481);														// wait 481uSec
	PinSetBit(pin, LATSET);											// release the bus
	PinSetBit(pin, TRISSET);										// set as input
	uSec(70);														// wait 70uSec
	mmOWvalue = PinRead(pin) ^ 0x01;                                // read pin and invert response
	PinSetBit(pin, TRISCLR);										// set as output
	uSec(411);														// wait 411uSec
	return mmOWvalue;
}


void ow_writeByte(int pin, int data) {
	int loop;

	for (loop = 0; loop < 8; loop++) {
		ow_writeBit(pin, data & 0x01);
		data >>= 1;
	}
	return;
}


int ow_readByte(int pin) {
	int loop, result = 0;

	for (loop = 0; loop < 8; loop++) {
		result >>= 1;
		if (ow_readBit(pin)) result |= 0x80;
	}
	return result;
}


int ow_touchByte(int pin, int data) {
	int loop, result = 0;

	for (loop = 0; loop < 8; loop++) {
		result >>= 1;
		if (data & 0x01) {                                          // if sending a '1' then read a bit else write a '0'
			if (ow_readBit(pin)) result |= 0x80;
		} else {
			ow_writeBit(pin, 0x00);
		}
		data >>= 1;
	}
	return result;
}


int ow_touchBit(int pin, int bit) {
	int result = 0;

	if (bit & 0x01) {                                               // if sending a '1' then read a bit else write a '0'
		if (ow_readBit(pin)) result = 1;
	} else {
		ow_writeBit(pin, 0x00);
	}
	return result;
}


// note that the uSec() function will not time short delays at low clock speeds
// so we directly use the core timer for short delays
void ow_writeBit(int pin, int bit) {
    unsigned int us;

	if (bit) {
		// Write '1' bit
        us = (8000u) / (2000000000u/CLOCKFREQ);                     // delay for 6uS
        PinSetBit(pin, LATCLR);										// drive pin low
        WriteCoreTimer(0);
        while(ReadCoreTimer() < us);                                // delay for 6uS
		PinSetBit(pin, LATSET);										// release the bus
		uSec(64);													// wait 64Sec
	} else {
		// Write '0' bit
        us = (10000u) / (2000000000u/CLOCKFREQ);                    // delay for 10uS
		PinSetBit(pin, LATCLR);										// drive pin low
		uSec(60);													// wait 60uSec
		PinSetBit(pin, LATSET);										// release the bus
        WriteCoreTimer(0);
        while(ReadCoreTimer() < us);                                // delay for 10uS
	}
	return;
}


// note that the uSec() function will not time short delays at low clock speeds
// so we directly use the core timer for short delays
int ow_readBit(int pin) {
	int result;
    unsigned int us;

    us = (6000u) / (2000000000u/CLOCKFREQ);                         // delay for 6uS
	PinSetBit(pin, LATCLR);											// drive pin low
    WriteCoreTimer(0);
    while(ReadCoreTimer() < us);                                    // delay for 6uS
	PinSetBit(pin, LATSET);											// release the bus
    us = (8000u) / (2000000000u/CLOCKFREQ);                         // delay for 8uS
	PinSetBit(pin, TRISSET);										// set as input
    WriteCoreTimer(0);
    while(ReadCoreTimer() < us);                                    // delay for 8uS
	result = PinRead(pin);											// read pin
	PinSetBit(pin, TRISCLR);										// set as output
	uSec(56);														// wait 56uSec
	return result;
}


#ifdef INCLUDE_1WIRE_SEARCH


int ow_verifyByte(int pin, int data) {
	return (ow_touchByte(pin, data) == data) ? 1 : 0;
}

//--------------------------------------------------------------------------
// The 'ow_first' finds the first device on the 1-Wire Net
//
// When 'alarm_only' is TRUE (1) the find alarm command 0xEC is
// sent instead of the normal search command 0xF0.
// Using the find alarm command 0xEC will limit the search to only
// 1-Wire devices that are in an 'alarm' state.
//
// 'pin'        - I/O Pin.
// 'do_reset'   - TRUE (1) perform reset before search, FALSE (0) do not
//                perform reset before search.
// 'alarm_only' - TRUE (1) the find alarm command 0xEC is
//                sent instead of the normal search command 0xF0
//
// Returns:   TRUE (1) : when a 1-Wire device was found and it's
//                        Serial Number placed in the global SerialNum[portnum]
//            FALSE (0): There are no devices on the 1-Wire Net.
//
int ow_first(int pin, int do_reset, int alarm_only) {
	// reset the search state
	LastDiscrepancy = 0;
	LastDeviceFlag = FALSE;
	LastFamilyDiscrepancy = 0;

	return ow_next(pin, do_reset, alarm_only);
}


//--------------------------------------------------------------------------
// The 'ow_next' function does a general search.  This function
// continues from the previos search state. The search state
// can be reset by using the 'ow_first' function.
//
// When 'alarm_only' is TRUE (1) the find alarm command
// 0xEC is sent instead of the normal search command 0xF0.
// Using the find alarm command 0xEC will limit the search to only
// 1-Wire devices that are in an 'alarm' state.
//
// 'pin'        - I/O Pin.
// 'do_reset'   - TRUE (1) perform reset before search, FALSE (0) do not
//                perform reset before search.
// 'alarm_only' - TRUE (1) the find alarm command 0xEC is
//                sent instead of the normal search command 0xF0
//
// Returns:   TRUE (1) : when a 1-Wire device was found and it's
//                       Serial Number placed in the global SerialNum[portnum]
//            FALSE (0): when no new device was found.  Either the
//                       last search was the last device or there
//                       are no devices on the 1-Wire Net.
//
int ow_next(int pin, int do_reset, int alarm_only) {
	int bit_test, search_direction, bit_number;
	int last_zero, serial_byte_number, next_result;
	unsigned char serial_byte_mask, lastcrc8;

	// initialize for search
	bit_number = 1;
	last_zero = 0;
	serial_byte_number = 0;
	serial_byte_mask = 1;
	next_result = 0;
	lastcrc8 = 0;
	setcrc8(0);

	// if the last call was not the last one
	if (!LastDeviceFlag) {
		// check if reset first is requested
		if (do_reset)	{
			// reset the 1-wire
			// if there are no parts on 1-wire, return FALSE
			if (!ow_reset(pin)) {
				// reset the search
				LastDiscrepancy = 0;
				LastFamilyDiscrepancy = 0;
				return FALSE;
			}
		}

		// If finding alarming devices issue a different command
		if (alarm_only) {
			ow_writeByte(pin, 0xEC);                                // issue the alarming search command
		} else {
			ow_writeByte(pin, 0xF0);                                // issue the search command
		}

		// loop to do the search
		do {
			// read a bit and its compliment
			bit_test = ow_touchBit(pin, 1) << 1;
			bit_test |= ow_touchBit(pin, 1);

			// check for no devices on 1-wire
			if (bit_test == 3) break;
			else {
				// all devices coupled have 0 or 1
				if (bit_test > 0) {
				  search_direction = !(bit_test & 0x01);            // bit write value for search
				} else {
					// if this discrepancy if before the Last Discrepancy
					// on a previous next then pick the same as last time
					if (bit_number < LastDiscrepancy)
						search_direction = ((SerialNum[serial_byte_number] & serial_byte_mask) > 0);
					else
						// if equal to last pick 1, if not then pick 0
						search_direction = (bit_number == LastDiscrepancy);

					// if 0 was picked then record its position in LastZero
					if (search_direction == 0) {
						last_zero = bit_number;

						// check for Last discrepancy in family
						if (last_zero < 9) LastFamilyDiscrepancy = last_zero;
					}
				}

				// set or clear the bit in the SerialNum byte serial_byte_number
				// with mask serial_byte_mask
				if (search_direction == 1)
				  SerialNum	[serial_byte_number] |= serial_byte_mask;
				else
				  SerialNum	[serial_byte_number] &= ~serial_byte_mask;

				// serial number search direction write bit
				ow_touchBit(pin, search_direction);

				// increment the byte counter bit_number
				// and shift the mask serial_byte_mask
				bit_number++;
				serial_byte_mask <<= 1;

				// if the mask is 0 then go to new SerialNum byte serial_byte_number
				// and reset mask
				if (serial_byte_mask == 0) {
					// The below has been added to accomodate the valid CRC with the
					// possible changing serial number values of the DS28E04.
					if (((SerialNum[0] & 0x7F) == 0x1C) && (serial_byte_number == 1))
						lastcrc8 = docrc8(0x7F);
					else
						lastcrc8 = docrc8(SerialNum[serial_byte_number]);  // accumulate the CRC

					serial_byte_number++;
					serial_byte_mask = 1;
				}
			}
		} while(serial_byte_number < 8);  // loop until through all SerialNum[portnum] bytes 0-7

		// if the search was successful then
		if (!((bit_number < 65) || lastcrc8)) {
			// search successful so set LastDiscrepancy, LastDeviceFlag, next_result
			LastDiscrepancy = last_zero;
			LastDeviceFlag = (LastDiscrepancy == 0);
			next_result = TRUE;
		}
	}

	// if no device found then reset counters so next 'next' will be
	// like a first
	if (!next_result || !SerialNum[0]) {
		LastDiscrepancy = 0;
		LastDeviceFlag = FALSE;
		LastFamilyDiscrepancy = 0;
		next_result = FALSE;
	}

	return next_result;
}


//--------------------------------------------------------------------------
// The 'ow_verify' function checks that the device with the serial number
// in the global SerialNum buffer is present.
//
// When 'alarm_only' is TRUE (1) the find alarm command
// 0xEC is sent instead of the normal search command 0xF0.
// Using the find alarm command 0xEC will limit the search to only
// 1-Wire devices that are in an 'alarm' state.
//
// 'pin'        - I/O Pin.
// 'alarm_only' - TRUE (1) the find alarm command 0xEC is
//                sent instead of the normal search command 0xF0
//
// Returns:   TRUE (1) : device verified present.
//            FALSE (0): device not present.
//
int ow_verify(int pin, int alarm_only) {
	unsigned char serialNum_backup[8];
	int i, rslt, ld_backup, ldf_backup, lfd_backup;

	// keep a backup copy of the current state
	for (i = 0; i < 8; i++) serialNum_backup[i] = SerialNum[i];
	ld_backup = LastDiscrepancy;
	ldf_backup = LastDeviceFlag;
	lfd_backup = LastFamilyDiscrepancy;

	// set search to find the same device
	LastDiscrepancy = 64;
	LastDeviceFlag = FALSE;
	if (ow_next(pin, 1, alarm_only)) {
		// check if same device found
		rslt = TRUE;
		for (i = 0; i < 8; i++) {
			if (serialNum_backup[i] != SerialNum[i]) {
				rslt = FALSE;
				break;
			}
		}
	} else {
		rslt = FALSE;
	}

	// restore the search state
	for (i = 0; i < 8; i++) SerialNum[i] = serialNum_backup[i];
	LastDiscrepancy = ld_backup;
	LastDeviceFlag = ldf_backup;
	LastFamilyDiscrepancy = lfd_backup;

	// return the result of the verify
	return rslt;
}

//--------------------------------------------------------------------------
// The 'ow_serialNum' function either reads or sets the SerialNum buffer
// that is used in the search functions 'ow_first' and 'ow_next'.
// This function contains two parameters, 'serialnum_buf' is a pointer
// to a buffer provided by the caller.  'serialnum_buf' should point to
// an array of 8 unsigned chars.  The second parameter is a flag called
// 'do_read' that is TRUE (1) if the operation is to read and FALSE
// (0) if the operation is to set the internal SerialNum buffer from
// the data in the provided buffer.
//
// 'serialnum_buf' - buffer to that contains the serial number to set
//                   when do_read = FALSE (0) and buffer to get the serial
//                   number when do_read = TRUE (1).
// 'do_read'       - flag to indicate reading (1) or setting (0) the current
//                   serial number.
//
void ow_serialNum(unsigned char *serialnum_buf, int do_read)
{
	unsigned char i;

	// read the internal buffer and place in 'serialnum_buf'
	if (do_read) {
		for (i = 0; i < 8; i++) serialnum_buf[i] = SerialNum[i];
	} else { // set the internal buffer from the data in 'serialnum_buf'
		for (i = 0; i < 8; i++) SerialNum[i] = serialnum_buf[i];
	}
}


//--------------------------------------------------------------------------
// Setup the search algorithm to find a certain family of devices
// the next time a search function is called 'owNext'.
//
// 'search_family' - family code type to set the search algorithm to find
//                   next.
//
void ow_familySearchSetup(int search_family)
{
	int i;

	// set the search state to find SearchFamily type devices
	SerialNum[0] = search_family;
	for (i = 1; i < 8; i++) SerialNum[i] = 0;
	LastDiscrepancy = 64;
	LastDeviceFlag = FALSE;
}


//--------------------------------------------------------------------------
// Set the current search state to skip the current family code.
//
void ow_skipFamily(void)
{
	// set the Last discrepancy to last family discrepancy
	LastDiscrepancy = LastFamilyDiscrepancy;
	LastFamilyDiscrepancy = 0;

	// check for end of list
	if (LastDiscrepancy == 0) LastDeviceFlag = TRUE;
}


void setcrc16(unsigned short reset) {
	utilcrc16 = reset;
	return;
}

unsigned short docrc16(unsigned short cdata) {
	cdata = (cdata ^ (utilcrc16 & 0xff)) & 0xff;
	utilcrc16 >>= 8;

	if (oddparity[cdata & 0xf] ^ oddparity[cdata >> 4])	utilcrc16 ^= 0xc001;

	cdata <<= 6;
	utilcrc16 ^= cdata;
	cdata <<= 1;
	utilcrc16 ^= cdata;

	return utilcrc16;
}


void setcrc8(unsigned char reset) {
	utilcrc8 = reset;
	return;
}

unsigned char docrc8(unsigned char cdata) {
	utilcrc8 = dscrc_table[utilcrc8 ^ cdata];
	return utilcrc8;
}

#endif
