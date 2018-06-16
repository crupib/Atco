/***********************************************************************************************************************
Maximite

timers.c

This module manages various timers (counting variables), the date/time,
counting inputs and generates the sound.  All this is contained within the timer 4 interrupt.
  
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

#define INCLUDE_FUNCTION_DEFINES

#include <p32xxxx.h>
#include <plib.h>

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"

// timer variables
volatile unsigned int SecondsTimer = 0;
volatile unsigned int PauseTimer = 0;
volatile unsigned int IntPauseTimer = 0;
volatile unsigned int CursorTimer = 0;
volatile unsigned int InkeyTimer = 0;
volatile unsigned int USBBannerTimer = 0;
volatile unsigned int WDTimer = 0;
volatile int ds18b20Timer = -1;

// sound variables
volatile unsigned int SoundPlay;

volatile unsigned int mSecTimer = 0;													// this is used to count mSec
volatile int second = 0;														        // date/time counters
volatile int minute = 0;
volatile int hour = 0;
volatile int day = 1;
volatile int month = 1;
volatile int year = 2000;

volatile int SDActivityLED = 0;

const char DaysInMonth[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

volatile int SDCardRemoved = true;
volatile int CheckingSD = false;

unsigned char PulsePin[NBR_PULSE_SLOTS];
unsigned char PulseDirection[NBR_PULSE_SLOTS];
int PulseCnt[NBR_PULSE_SLOTS];
int PulseActive;

/***************************************************************************************************
InitTimers
Initialise the 0.5 mSec timer used for internal timekeeping.
****************************************************************************************************/
void initTimers(void) {
 	// setup timer 4
    PR4 = 500 * ((BUSFREQ/2)/1000000) - 1;       					// 500 uSec
    T4CON = 0x8010;         										// T4 on, prescaler 1:2
    mT4SetIntPriority(1);  											// lower priority
    mT4ClearIntFlag();      										// clear interrupt flag
    mT4IntEnable(1);       											// enable interrupt 

	P_SD_ACTIVITY_TRIS = 0; P_SD_LED_SET_LO;						// initialise the SD card activity led (maintained by timers.c)
}



/****************************************************************************************************************
Timer 4 interrupt processor
This fires every 500 uSec and is responsible for tracking the time and the counts of various timing variables
*****************************************************************************************************************/
void __ISR( _TIMER_4_VECTOR, ipl1) T4Interrupt(void) {
    static unsigned int xt = 0;
    static int IrTimeout, IrTick;
    static int NextIrTick;
    
    CheckUSB();                                                     // check the USB every 500uSec
    if(xt++ & 1) { mT4ClearIntFlag(); return; }                     // exit if not a new millisecond

    /////////////////// we only reach here once every millisecond /////////////////////////
    
	/////////////////////////////// count up timers /////////////////////////////////////				
	
	// if we are measuring period increment the count
	if(INT1PIN > 0 && ExtCurrentConfig[INT1PIN] == EXT_PER_IN) INT1Count++;
	if(INT2PIN > 0 && ExtCurrentConfig[INT2PIN] == EXT_PER_IN) INT2Count++;
	if(INT3PIN > 0 && ExtCurrentConfig[INT3PIN] == EXT_PER_IN) INT3Count++;
	if(INT4PIN > 0 && ExtCurrentConfig[INT4PIN] == EXT_PER_IN) INT4Count++;
	
	mSecTimer++;													// used by the TIMER function
	PauseTimer++;													// used by the PAUSE command
	IntPauseTimer++;												// used by the PAUSE command inside an interrupt
	InkeyTimer++;													// used to delay on an escape character
	
	if(InterruptUsed) {
    	int i;
	    for(i = 0; i < NBRSETTICKS; i++) TickTimer[i]++;			// used in the interrupt tick
	}
	
	if(WDTimer)
    	if(--WDTimer == 0) EnableWDT();                             // crude way of implementing a watchdog timer.  
    	                                                            // Using EnableWDT() ensures that the watchdog bit is set on reboot

    if(ds18b20Timer > 0) ds18b20Timer--;

	if(++CursorTimer > CURSOR_OFF + CURSOR_ON) CursorTimer = 0;		// used to control cursor blink rate

	if (I2C_Timer) {
		if (--I2C_Timer == 0) {
			I2C_Status |= I2C_Status_Timeout;
			mI2C1MSetIntFlag();
		}
	}
	if (I2C_Status & I2C_Status_MasterCmd) {
		if (!(I2C1STAT & _I2C1STAT_S_MASK)) {
			I2C_Status &= ~I2C_Status_MasterCmd;
			I2C_State = I2C_State_Start;
			I2C1CONSET =_I2C1CON_SEN_MASK;
		}
	}

	if(SDActivityLED) {
    	if(SDActivityLED == 1)
		    P_SD_LED_SET_LO;
	    else
    		P_SD_LED_SET_HI;
    	SDActivityLED--;
	}
		
	// check if the sound has expired
	if(SoundPlay && SoundPlay != 0xffffffff) {						// if we are still playing the sound and it is not forever
		SoundPlay--;
		if(SoundPlay == 0) {
    		StopAudio();
		}
	}		
	
	if(USBBannerTimer) {										    // if we are timing a USB connection
        char *p;
		USBBannerTimer--;
	    if(USBBannerTimer == 2) for(p = MES_SIGNON; *p; p++) USBPutchar(*p);
	    if(USBBannerTimer == 1) for(p = MES_COPYRIGHT; *p; p++) USBPutchar(*p);
        if(USBBannerTimer == 0 && CurrentLinePtr == NULL) for(p = "\r\n> "; *p; p++) USBPutchar(*p);
	}	

    // check if any pulse commands are running
    if(PulseActive) {
        int i;
        for(PulseActive = i = 0; i < NBR_PULSE_SLOTS; i++) {
            if(PulseCnt[i] > 0) {                                   // if the pulse timer is running
                PulseCnt[i]--;                                      // and decrement our count
                if(PulseCnt[i] == 0)                                // if this is the last count reset the pulse
                    PinSetBit(PulsePin[i], PulseDirection[i] ? LATSET : LATCLR);
                else
                    PulseActive = true;                             // there is at least one pulse still active
            }
        }    
    } 

    // check for any IR receive activity
    // IrTick counts how many mS since the key was first pressed
    // NextIrTick is used to time the auto repeat
    // IrTimeout is used to detect when the key is released
    // IrGotMsg is a signal to the interrupt handler that an interrupt is required
    if(IrState > IR_WAIT_START && elapsed > 2800) {
        // we have received something on the IR
        if(IrCount == 12 || IrCount == 15 || IrCount == 20) {
            if(IrTick > IrTimeout) {
                // this is a new keypress
                IrTick = 0;
                NextIrTick = 650;
            }
            if(IrTick == 0 || IrTick > NextIrTick) {
                *IrDev = ((IrBits >> 7) & 0b11111);
                *IrCmd = (IrBits & 0b1111111) | ((IrBits >> 5) & ~0b1111111);
                IrGotMsg = true;
                NextIrTick += 250;
            }
            IrTimeout = IrTick + 150;
        }
        IrReset();
    }

    IrTick++;
    

	//////////////////////////////// keep track of the date and time ////////////////////////////////
	////////////////////////////////// this code runs once a second /////////////////////////////////
	if(++SecondsTimer >= 1000) {
		SecondsTimer = 0;											// reset every second
		
		// detect SD card removal on the original Maximite that used a socket with a card detect pin
		if(SD_CD) SDCardRemoved = true;
		

		if(INT1PIN > 0 && ExtCurrentConfig[INT1PIN] == EXT_FREQ_IN) { INT1Value = INT1Count; INT1Count = 0; }
		if(INT2PIN > 0 && ExtCurrentConfig[INT2PIN] == EXT_FREQ_IN) { INT2Value = INT2Count; INT2Count = 0; }
		if(INT3PIN > 0 && ExtCurrentConfig[INT3PIN] == EXT_FREQ_IN) { INT3Value = INT3Count; INT3Count = 0; }
		if(INT4PIN > 0 && ExtCurrentConfig[INT4PIN] == EXT_FREQ_IN) { INT4Value = INT4Count; INT4Count = 0; }
		if(++second >= 60) {										// keep track of the time and date
			second = 0 ;
			if(++minute >= 60) {
				minute = 0;
				if(++hour >= 24) {
					hour = 0;
					if(++day > DaysInMonth[month + ((month == 2 && (year % 4) == 0)?1:0)]) {
						day = 1;
						if(++month > 12) {
							month = 1;
							year++;
						}
					}
				}
			}
		}
	}
	
#if defined(DUINOMITE)
	// detect SD card removal on clones that use the micro SD and pull CS low with a high value resistor
	if(SecondsTimer == 0) {
    	CheckingSD = SD_CS_READ_LAT;                                // if the card is not currently being accessed
    	if(CheckingSD) SD_CS_TRIS = INPUT;                          // turn CS into an input.  the remainder of the test will be done later
	}

	// complete the check for removal of the micro SD card, this is done 10mS later to let the pin settle
	if(CheckingSD && SecondsTimer == 10) {                          // if we need to complete the SD card check
		if(SD_CS_READ_PORT == 0) SDCardRemoved = true;              // CD pulled low means that there is no card present
   		SD_CS_TRIS = OUTPUT;                                        // return chip select pin to its normal mode
   		CheckingSD = false;
    }     		
#endif

    if(CurrentlyPlaying == P_MOD) fillAudioBuffer();                 // when playing MOD files
            
    // Clear the interrupt flag
    mT4ClearIntFlag();
}
