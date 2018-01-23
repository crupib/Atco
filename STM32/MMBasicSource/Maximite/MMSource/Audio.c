/***********************************************************************************************************************
MMBasic

Audio.c

Handles the SOUND and PWM commands (both are similar),the TONE command and playing of MOD files.

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

#include <p32xxxx.h>								// device specific defines
#include <plib.h>									// peripheral libraries
#include <stdio.h>
#include <stdbool.h>                                // Pascal
#include <stdint.h>                                 // Pascal

#include "MMBasic_Includes.h"
#include "Hardware_Includes.h"
#include "mod32.h"                                  // Pascal

/********************************************************************************************************************************************
commands and functions
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

// define the PWM output frequency for playing mod files
#define PWM_PERIOD      (1 << BITDEPTH)

// define the timer 1 tick frequency for playing mod files
#define TICK_PERIOD     (BUSFREQ/SAMPLERATE)


// define the PWM output frequency for making a tone
#define PWM_FREQ        80000

// define the timer 1 tick frequency for making a tone
#define TICK_FREQ       100000

unsigned int PhaseM_left, PhaseM_right;
e_CurrentlyPlaying CurrentlyPlaying = P_NOTHING;

unsigned char SineTable[256] = {
                                128, 131, 134, 137, 140, 144, 147, 150,
                                153, 156, 159, 162, 165, 168, 171, 174,
                                176, 179, 182, 185, 188, 190, 193, 196,
                                198, 201, 203, 206, 208, 211, 213, 215,
                                218, 220, 222, 224, 226, 228, 230, 232,
                                233, 235, 237, 238, 240, 241, 243, 244,
                                245, 246, 247, 248, 249, 250, 251, 252,
                                252, 253, 254, 254, 254, 255, 255, 255,
                                255, 255, 255, 255, 254, 254, 254, 253,
                                253, 252, 251, 251, 250, 249, 248, 247,
                                246, 244, 243, 242, 240, 239, 237, 236,
                                234, 232, 230, 229, 227, 225, 223, 221,
                                218, 216, 214, 212, 209, 207, 204, 202,
                                199, 197, 194, 191, 189, 186, 183, 180,
                                177, 175, 172, 169, 166, 163, 160, 157,
                                154, 151, 148, 145, 142, 138, 135, 132,
                                129, 126, 123, 120, 117, 114, 111, 107,
                                104, 101, 98, 95, 92, 89, 86, 83,
                                81, 78, 75, 72, 69, 67, 64, 61,
                                59, 56, 53, 51, 48, 46, 44, 41,
                                39, 37, 35, 33, 31, 29, 27, 25,
                                23, 21, 20, 18, 17, 15, 14, 13,
                                11, 10, 9, 8, 7, 6, 5, 4,
                                4, 3, 3, 2, 2, 1, 1, 1,
                                1, 1, 1, 1, 1, 2, 2, 3,
                                3, 4, 4, 5, 6, 7, 8, 9,
                                10, 11, 12, 14, 15, 17, 18, 20,
                                21, 23, 25, 27, 29, 31, 33, 35,
                                37, 39, 41, 44, 46, 48, 51, 53,
                                56, 58, 61, 64, 66, 69, 72, 75,
                                77, 80, 83, 86, 89, 92, 95, 98,
                                101, 104, 107, 110, 113, 116, 120, 123
                              };




// the SOUND and the PWM command (both are very similar)
void cmd_sound(void) {
	int f, period;
	unsigned int PlayDuration;
	static int dcy1 = 500;
	static int dcy2 = 500;
	static int LastFreq = 0;

	getargs(&cmdline, 5, ",");
	if((argc & 0x01) == 0) error("Invalid syntax");

	// check if the first argument was STOP.  In that case stop the output and immediately return
    if(checkstring(argv[0], "STOP")){
        StopAudio();
        return;                                                     // exit immediately
    }
    f = getinteger(argv[0]);									    // the frequency
	PlayDuration = 0xffffffff;                                      // default is to play forever

	if(cmdtoken == GetCommandValue("PWM")) {
    	if(argc >= 3 && *argv[2]) dcy1 = getnumber(argv[2]) * 100.0;// duty cycle for channel 1
    	if(argc == 5)
        #if defined(COLOUR)
    	    dcy2 = getnumber(argv[4]) * 100.0;					    // duty cycle for channel 2
        #else
            error("Only one channel can be set");
        #endif
        if(CurrentlyPlaying != P_PWM) StopAudio();                  // stop whatever else might be playing
    } else {  // is SOUND command
	    if(argc >= 3 && *argv[2]) PlayDuration = getinteger(argv[2]);// the duration
	    if(argc == 5)
	        dcy1 = dcy2 = getnumber(argv[4]) * 100.0;		        // the duty cycle
	    else
	        dcy1 = dcy2 = 50 * 100.0;		                        // the duty cycle
        if(CurrentlyPlaying != P_SOUND) StopAudio();                // stop whatever else might be playing
	}

	if(PlayDuration == 0 || f == 0) { 								// see if the user wants to cancel any playing sound
		StopAudio();
		return;
	}

	if(f < 20 || f > 1000000 || dcy1 < 0 || dcy1 > 10000 || dcy2 < 0 || dcy2 > 10000) error("Number out of bounds");

	period = BUSFREQ/f;												// convert the frequency into bus cycles
	if(f < 1250) period /= 64;										// adjust if we need to scale the timer's clock

	if(CurrentlyPlaying == P_SOUND && ((f < 1250 && LastFreq < 1250) || (f >= 1250 && LastFreq >= 1250))) {
		P_SOUND_SET_PWM((period * dcy1) / 10000);					// change the duty cycle
		P_SOUND2_SET_PWM((period * dcy2) / 10000);
		WritePeriod2(period);										// change the frequency (thanks to Bryan Rentoul, NZ)
	} else {
		// we are starting up or changing the frequency so much that the prescaler must be changed, so do the full configuration
		// enable the output compare which is used to generate the duty cycle
	    P_SOUND_OPEN_OC( OC_ON | OC_TIMER_MODE16 | OC_TIMER2_SRC | OC_PWM_FAULT_PIN_DISABLE , (period * dcy1) / 10000, 0x0000 );
	    P_SOUND2_OPEN_OC( OC_ON | OC_TIMER_MODE16 | OC_TIMER2_SRC | OC_PWM_FAULT_PIN_DISABLE , (period * dcy2) / 10000, 0x0000 );
	    // enable timer 2 and set to the desired frequency
	    OpenTimer2(T2_ON | ((f < 1250) ? T2_PS_1_64 : T2_PS_1_1), period);
	}
	LastFreq = f;													// used to detect if the frequency is different
	SoundPlay = PlayDuration;										// set the duration, each tick is 1mS.  PWM runs forever
	if(cmdtoken == GetCommandValue("PWM"))
	    CurrentlyPlaying = P_PWM;
	else
	    CurrentlyPlaying = P_SOUND;
}




// The MMBasic command:  PLAYMOD "filename", numbertimes
//   or                  TONE freq1, freq2, duration
// argument2 and argument3 are optional numeric arguments
// they might be used to specify duration, repeat number, etc.
void cmd_playmod(void) {
    char *p;
    int f_left, f_right;
    unsigned int PlayDuration;

	// get the command line arguments
	getargs(&cmdline, 7, ",");                                      // this MUST be the first executable line in the function
	if(argc%2 == 0 || argc < 1) error("Invalid number of parameters");


	// check if the first argument was STOP.  In that case stop the interrupt, close the file, stop the PWM and immediately return
    if(checkstring(argv[0], "STOP")){
        StopAudio();
        return;                                                     // exit immediately
    }

	PlayDuration = 0xffffffff;                                      // default is to play forever

	if(cmdtoken == GetCommandValue("TONE")) {
	    // this section is used when we are playing a tone
        if(argc > 5) error("Invalid number of parameters");
    	if(CurrentlyPlaying != P_TONE) StopAudio();                 // stop whatever else is playing
    	f_left = getinteger(argv[0]);                               // get the arguments
        f_right = f_left;
#if defined(COLOUR)
    	if(argc > 2 && *argv[2]) f_right = getinteger(argv[2]);
#endif
    	if(argc > 4) PlayDuration = getinteger(argv[4]);
    	if(f_left < 1 || f_left > 20000 || f_right < 1 || f_right > 20000) error("Invalid argument");

    	if(CurrentlyPlaying != P_TONE) {                            // if we are not playing a tone
        	// enable the output compare which is used to generate the duty cycle, default is 50% duty cycle
           	P_SOUND_OPEN_OC( OC_ON | OC_TIMER_MODE16 | OC_TIMER2_SRC | OC_PWM_FAULT_PIN_DISABLE , (BUSFREQ/PWM_FREQ)/2, 0x0000 );
        	P_SOUND2_OPEN_OC( OC_ON | OC_TIMER_MODE16 | OC_TIMER2_SRC | OC_PWM_FAULT_PIN_DISABLE , (BUSFREQ/PWM_FREQ)/2, 0x0000 );
        	// enable timer 2 and set to the desired frequency
        	OpenTimer2(T2_ON | T2_PS_1_1, (BUSFREQ/PWM_FREQ));

         	// setup timer 1 to generate a regular interrupt
        	OpenTimer1(T1_ON | T1_PS_1_1, (BUSFREQ/TICK_FREQ));
            mT1SetIntPriority(4);  									// medium priority
            mT1ClearIntFlag();      								// clear interrupt flag
            mT1IntEnable(1);       									// enable interrupt
        }

        PhaseM_left = (unsigned int)(((unsigned long long)0xffffffff * (unsigned long long)f_left) / (unsigned long long)TICK_FREQ);
        PhaseM_right = (unsigned int)(((unsigned long long)0xffffffff * (unsigned long long)f_right) / (unsigned long long)TICK_FREQ);
        CurrentlyPlaying = P_TONE;
        SoundPlay = PlayDuration;
        return;
    }

    // this section is used only for playing mod files
	StopAudio();                                                    // stop whatever else might be playing
    if(argc > 3) error("Invalid number of parameters");
	p = GetFileName(argv[0], NULL);
	if(argc > 2) PlayDuration = getinteger(argv[2]);                // get the second (optional) argument
	if(GetDrive(p) != FLASHFS) error("Only drive A: is valid");
	if(FlashStatus != CLOSED) error("Only one internal flash file can be open at a time");
	p = GetFName(p);
	if(strchr(p, '.') == NULL) strcat(p, ".MOD");
 	FlashOpenRead(p);	                                            // open the file
	if(MMerrno) {
        StopAudio();
        return;                                                     // exit immediately
    }

 	FsBuffer = getmemory(sizeof(struct s_FsBuffer));
 	SoundBuffer = getmemory(sizeof(struct s_SoundBuffer));
 	Mod = getmemory(sizeof(struct s_Mod));
 	Mixer = getmemory(sizeof(struct s_Mixer));
 	Player = getmemory(sizeof(struct s_Player));

	// setup the PWM
	// note:  PWM_PERIOD is defined above
	// enable the output compare which is used to generate the duty cycle, default is 50% duty cycle
	P_SOUND_OPEN_OC( OC_ON | OC_TIMER_MODE16 | OC_TIMER2_SRC | OC_PWM_FAULT_PIN_DISABLE , PWM_PERIOD/2, 0x0000 );
	P_SOUND2_OPEN_OC( OC_ON | OC_TIMER_MODE16 | OC_TIMER2_SRC | OC_PWM_FAULT_PIN_DISABLE , PWM_PERIOD/2, 0x0000 );
	// enable timer 2 and set to the desired frequency
	OpenTimer2(T2_ON | T2_PS_1_1, PWM_PERIOD);

	loadMod();
    Player->run = true;

 	// setup timer 1 to generate a regular interrupt
	// note:  TICK_PERIOD is defined above
	OpenTimer1(T1_ON | T1_PS_1_1, TICK_PERIOD);
    mT1SetIntPriority(4);  											// medium priority
    mT1ClearIntFlag();      										// clear interrupt flag
    mT1IntEnable(1);       											// enable interrupt

    CurrentlyPlaying = P_MOD;
    SoundPlay = PlayDuration;
}



/******************************************************************************************
Timer 1 interrupt.
Used to send data to the PWM
When playing music this uses up about 2% of the CPU
*******************************************************************************************/
void __ISR( _TIMER_1_VECTOR, ipl4) T1Interrupt(void) {
    static unsigned int PhaseAC_left, PhaseAC_right;
    unsigned int v_left, v_right;

    if(CurrentlyPlaying == P_MOD) {
        // play some music
        if(SoundBuffer->writePos != SoundBuffer->readPos) {
            P_SOUND2_SET_PWM(SoundBuffer->left[SoundBuffer->readPos]);  // D3 = left
            P_SOUND_SET_PWM(SoundBuffer->right[SoundBuffer->readPos]);  // D1 = right or mono MM output
            SoundBuffer->readPos++;
            SoundBuffer->readPos &= SOUNDBUFFERSIZE - 1;
        }
     } else {
        // play a tone
        PhaseAC_left += PhaseM_left;
        PhaseAC_right += PhaseM_right;
        INTDisableInterrupts();                                     // see PIC32 Errata #20
        v_left = SineTable[PhaseAC_left >> 24];
        v_right = SineTable[PhaseAC_right >> 24];
        INTEnableInterrupts();
        P_SOUND2_SET_PWM(((BUSFREQ/PWM_FREQ) * v_left)/255);        // D3 = left
        P_SOUND_SET_PWM(((BUSFREQ/PWM_FREQ) * v_right)/255);        // D1 = right or mono MM output
    }

    mT1ClearIntFlag();											    // Clear the interrupt flag
}



/**********************************************************************************************
Main loop to keep the audio buffers full when playing music
When playing music this uses up about 25% of the CPU, when not playing music it uses only 0.4%
***********************************************************************************************/
void fillAudioBuffer(void) {
    static uint16_t i = 0;
    if(Player->run) {
        while(((SoundBuffer->writePos + 1) & (SOUNDBUFFERSIZE - 1)) != SoundBuffer->readPos) {
            if(!i) {
                player();
                i = Player->samplesPerTick;
            }
            mixer();
            i--;
        }
    }
}


/******************************************************************************************
Stop playing the music or tone
*******************************************************************************************/
void StopAudio(void) {
	SoundPlay = 0;
    mT1IntEnable(0);       										    // disable interrupt
    CloseTimer1();     										        // Sample timer off

	if(CurrentlyPlaying == P_MOD) {                                 // if we have allocated memory to PLAYMOD
        FlashCloseRead();                                           // close the file
        FreeHeap(FsBuffer);
        FreeHeap(SoundBuffer);
        Player->run = false;
        FreeHeap(Player);
        FreeHeap(Mod);
        FreeHeap(Mixer);
    }

    // if PLAYMOD or TONE leave the pwm output running to avoid a click sound
	if(CurrentlyPlaying == P_MOD || CurrentlyPlaying == P_TONE || CurrentlyPlaying == P_IDLE) {
    	CurrentlyPlaying = P_IDLE;
    } else {
    	CurrentlyPlaying = P_NOTHING;
    	CloseTimer2();                                              // close the timer used to drive the PWM
    	P_SOUND_CLOSE_OC();                                         // close the output compare
    	P_SOUND2_CLOSE_OC();                                        // close the output compare for the second channel (colour only)
    }

}