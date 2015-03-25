/* save-res.c  
 * 
 * This file contains code for save/restore of tuning params.
 * The 33 series pics do not have eeprom, so we read and write
 * to a block of code space flash.
 *
 *  Copyright (C) 2009 By Lawrence Glaister VE7IT
 *             (ve7it@shaw.ca)
 */

#include "servo-dual.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>		// for PI etc
#include <libpic30.h>

extern struct PID pid[2];

// a _FLASH_ROW = 64 words, _FLASH_PAGE=512 words where a word is a 3 byte instruction
// declare blocks of code space (flash) data to read/write
int __attribute__((space(prog),aligned(_FLASH_PAGE*2))) dat0[_FLASH_PAGE];
int __attribute__((space(prog),aligned(_FLASH_PAGE*2))) dat1[_FLASH_PAGE];

//=============================================================================
// Routine to calculate a checksum on a section of memory
// call with array size in 16 bit words and ptr to start.
//=============================================================================
int calc_cksum(int sizew, int *adr)
{
	int i;
	int cksum = 0;
	for (i=0; i < sizew; i++)
		cksum += *adr++;
//	printf("cksum of %d 16bit words is %d\r\n",sizew,cksum);
	return cksum; 
}


// code for read and write to pgm space for nvram
// see http://www.microchip.com/forums/tm.aspx?m=435700
// 
//
// Be warned, many of the dspic33F's have a guaranteed flash life of 100
// write cycles. You could call WriteNV() thousands of times a second and
// trash your PIC's flash in a second. Make sure you don't!!!
// These functions are documented in the C30 manual, and the headers are
// fairly helpful, and if you search for them in the forum there will be
// many hits.   see page 205 of 51456E.PDF (16 bit language tools libraries)
void ReadNV(void)
{
	int size;
	_prog_addressT p;

	size = 10 * sizeof(float) + 2 * sizeof(short);	// bytes for a block of servo tuning params

	memset((void *)&pid[0].pgain, 0, size);		 // init our ram storage to 0
	// first servo block in flash
	_init_prog_address(p, dat0);
	_memcpy_p2d16((void *)&pid[0].pgain, p, size); // read data from code space
	
	// 2nd servo block in flash
	memset((void *)&pid[1].pgain, 0, size);		 // init our ram storage to 0
	_init_prog_address(p, dat1);
	_memcpy_p2d16((void *)&pid[1].pgain, p, size); // read data from code space
}

void WriteNV(void)
{
	_prog_addressT p;
	printf("writing servo 1 params...");
	// write out first servos params
    _init_prog_address(p, dat0);
   	_erase_flash(p);		// erase 1 page == 512 24bit instructions in 33f
	pid[0].cksum = -calc_cksum(((long int)&pid[0].cksum - (long int)&pid[0])/sizeof(int),
                            (int*)&pid[0]);
    _init_prog_address(p, dat0);
	// the following write only dies 64 words... the flash page is 512 words
	// this gives lots of unsed room for future expansion
   	_write_flash16(p, (void*)&pid[0].pgain);	//write 64 words at a time

	// write out second servos tuning params
	printf("servo 2 params...");
    _init_prog_address(p, dat1);
   	_erase_flash(p);		// erase 1 page == 512 24bit instructions in 33f
	pid[1].cksum = -calc_cksum(((long int)&pid[1].cksum - (long int)&pid[1])/sizeof(int),
                            (int*)&pid[1]);
    _init_prog_address(p, dat1);
   	_write_flash16(p, (void*)&pid[1].pgain);	//write 64 words at a time
	printf("done\r\n");
}



 
