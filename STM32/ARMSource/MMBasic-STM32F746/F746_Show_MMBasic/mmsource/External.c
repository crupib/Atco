/***********************************************************************************************************************
MMBasic

External.c

Handles reading and writing to the digital and analog input/output pins ising the SETPIN and PIN commands

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


#include "stm32f7xx.h"
extern uint8_t led_d13_enable;
ADC_HandleTypeDef    AdcHandle;
// Atari / Amiga standard joystick variables
int Joy_Up , Joy_Down , Joy_Left , Joy_Right , Joy_B1 , Joy_B2;
int joy_initialized = 0;
void joyparam(char *p, int *jup, int *jdw, int *jlft, int *jrgt, int *jb1, int *jb2);


#include "MMBasic_Includes.h"
#define DEFINE_PINDEF_TABLE
#include "Hardware_Includes.h"

int ExtCurrentConfig[NBRPINS + 1];

volatile int INT1Count, INT1Value;
volatile int INT2Count, INT2Value;
volatile int INT3Count, INT3Value;
volatile int INT4Count, INT4Value;

int InterruptUsed;




/*******************************************************************************************
External I/O related commands in MMBasic
========================================
These are the functions responsible for executing the ext I/O related  commands in MMBasic
They are supported by utility functions that are grouped at the end of this file

Each function is responsible for decoding a command
all function names are in the form cmd_xxxx() (for a basic command) or fun_xxxx() (for a
basic function) so, if you want to search for the function responsible for the LOCATE command
look for cmd_name

There are 4 items of information that are setup before the command is run.
All these are globals.

int cmdtoken	This is the token number of the command (some commands can handle multiple
				statement types and this helps them differentiate)

char *cmdline	This is the command line terminated with a zero char and trimmed of leading
				spaces.  It may exist anywhere in memory (or even ROM).

char *nextstmt	This is a pointer to the next statement to be executed.  The only thing a
				y=spi(1,2,3command can do with it is save it or change it to some other location.

char *CurrentLinePtr  This is read only and is set to NULL if the command is in immediate mode.

The only actions a command can do to change the program flow is to change nextstmt or
execute longjmp(mark, 1) if it wants to abort the program.

********************************************************************************************/


// function used to get the pin number
// only used in the BASIC commands and functions below and in 1-Wire
int GetPinNbr(char *p) {
    if(toupper(*p) == 'D' && isdigit(*(p + 1)))
        return D0_PINNR + atoi(p+1);
    if(toupper(*p) == 'A' && isdigit(*(p + 1)))
        return A0_PINNR + atoi(p+1);
    return getinteger(p);
}



// this is invoked as a command (ie, pin(3) = 1)
// first get the argument then step over the closing bracket.  Search through the rest of the command line looking
// for the equals sign and step over it, evaluate the rest of the command and set the pin accordingly
void cmd_pin(void) {
	int pin, value;

	pin = GetPinNbr(cmdline);
    if(pin < 0 || pin > NBRPINS) error("Invalid pin");
	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	++cmdline;
	if(!*cmdline) error("Invalid syntax");
	value = getinteger(cmdline);
	ExtSet(pin, value);
}



// this is invoked as a function (ie, x = pin(3) )
void fun_pin(void) {
#if !defined(STM32F7) // PIC
	// these two defines control the averaging of analog samples.  ANA_AVERAGE is the total number of samples to take
	// while ANA_DISCARD is the the number of highest value samples to discard and the same for the lowest samples
	// this leaves us with ANA_AVERAGE - ANA_DISCARD*2 samples which are averaged to give the final value
	#define ANA_AVERAGE		10
	#define ANA_DISCARD		2

	int pin, value, i, j, b[ANA_AVERAGE];
	float t;

	pin = GetPinNbr(ep);
	//if(pin == 0) { fret = (float)1; return;}
    if(pin < 0 || pin > NBRPINS) error("Invalid pin");

	value = ExtInp(pin);

    if(ExtCurrentConfig[pin] == EXT_DIG_IN || ExtCurrentConfig[pin] == EXT_INT_HI || ExtCurrentConfig[pin] == EXT_INT_LO || ExtCurrentConfig[pin] == EXT_INT_BOTH || ExtCurrentConfig[pin] == EXT_OC_OUT) {
		if(pin == 0)
			fret = (float)(value?0:1);							    // invert if we are reading the pushbotton
		else
			fret = (float)value;								    // all other inputs report as normal
	}
	else if(ExtCurrentConfig[pin] == EXT_ANA_IN) {
		// for analog we take ANA_AVERAGE readings and sort them into descending order in buffer b[].
		b[0] = value;									            // this reading was taken earlier
		for(i = 1; i < ANA_AVERAGE; i++) {						    // so this loop uses one less
			b[i] = ExtInp(pin);									    // get the value
			for(j = i; j > 0; j--) {							    // and sort into position
				if(b[j - 1] < b[j]) {
					t = b[j - 1];
					b[j - 1] = b[j];
					b[j] = t;
				}
				else
					break;
			}
		}
		// we then discard the top ANA_DISCARD samples and the bottom ANA_DISCARD samples and add up the remainder
		for(j = 0, i = ANA_DISCARD; i < ANA_AVERAGE - ANA_DISCARD; i++) j += b[i];

		// the total is averaged and scaled
   	  	fret = ((float)j * 3.3) / (float)(1023 * (ANA_AVERAGE - ANA_DISCARD*2));
   	  	if (pin == 21) fret *= 3.13;                                // this is only for the DuinoMite battery
   	}
    else if(ExtCurrentConfig[pin] == EXT_FREQ_IN || ExtCurrentConfig[pin] == EXT_PER_IN || ExtCurrentConfig[pin] == EXT_CNT_IN) {
		fret = (float)value;								    	// all other inputs report as normal
	}
   	else
   		error("Pin is not an input");
#else // STM32F746
	// these two defines control the averaging of analog samples.  ANA_AVERAGE is the total number of samples to take
	// while ANA_DISCARD is the the number of highest value samples to discard and the same for the lowest samples
	// this leaves us with ANA_AVERAGE - ANA_DISCARD*2 samples which are averaged to give the final value
	#define ANA_AVERAGE		10
	#define ANA_DISCARD		2

	int i, j, b[ANA_AVERAGE];
    int pin, value;
    float t;

	pin = GetPinNbr(ep);
    if(pin < 0 || pin > NBRPINS) error("Invalid pin");

	value = ExtInp(pin);

	if(ExtCurrentConfig[pin] == EXT_DIG_IN || ExtCurrentConfig[pin] == EXT_INT_HI || ExtCurrentConfig[pin] == EXT_INT_LO || ExtCurrentConfig[pin] == EXT_INT_BOTH) {
		fret = (float)value;
	}
    else if(ExtCurrentConfig[pin] == EXT_ANA_IN) {
		// for analog we take ANA_AVERAGE readings and sort them into descending order in buffer b[].
		b[0] = value;									            // this reading was taken earlier
		for(i = 1; i < ANA_AVERAGE; i++) {						    // so this loop uses one less
			b[i] = ExtInp(pin);									    // get the value
			for(j = i; j > 0; j--) {							    // and sort into position
				if(b[j - 1] < b[j]) {
					t = b[j - 1];
					b[j - 1] = b[j];
					b[j] = t;
				}
				else
					break;
			}
		}
		// we then discard the top ANA_DISCARD samples and the bottom ANA_DISCARD samples and add up the remainder
		for(j = 0, i = ANA_DISCARD; i < ANA_AVERAGE - ANA_DISCARD; i++) j += b[i];

		// the total is averaged and scaled
   	  	fret = ((float)j * 3.3) / (float)(1023 * (ANA_AVERAGE - ANA_DISCARD*2));
    }
   	else
   		error("Pin is not an input");

#endif // STM32F746
}






// this is invoked as a command (ie, port(3, 8) = Value)
// first get the arguments then step over the closing bracket.  Search through the rest of the command line looking
// for the equals sign and step over it, evaluate the rest of the command and set the pins accordingly
void cmd_port(void) {
	int pin, nbr, value;
    int i;
	getargs(&cmdline, NBRPINS * 4, ",");

	if((argc & 0b11) != 0b11) error("Invalid syntax");

    // step over the equals sign and get the value for the assignment
	while(*cmdline && tokenfunction(*cmdline) != op_equal) cmdline++;
	if(!*cmdline) error("Invalid syntax");
	++cmdline;
	if(!*cmdline) error("Invalid syntax");
	value = getinteger(cmdline);

    for(i = 0; i < argc; i += 4) {
        pin = GetPinNbr(argv[i]);
        nbr = GetPinNbr(argv[i + 2]);

        if(nbr <= 0 || pin <= 0) error("Invalid argument");
        if((nbr+pin-1)>NBRPINS) error("Invalid argument");

        while(nbr) {
            if(!(ExtCurrentConfig[pin] == EXT_DIG_OUT || ExtCurrentConfig[pin] == EXT_OC_OUT)) error("Invalid output pin");
            ExtSet(pin, value & 1);
            value >>= 1;
            nbr--;
            pin++;
        }
    }
}



// this is invoked as a function (ie, x = port(10,8) )
void fun_port(void) {
	int pin, nbr, i, value = 0;

	getargs(&ep, NBRPINS * 4, ",");
	if((argc & 0b11) != 0b11) error("Invalid syntax");

    for(i = 0; i < argc; i += 4) {
        pin = GetPinNbr(argv[i]);
        nbr = GetPinNbr(argv[i + 2]);

        if(nbr <= 0 || pin <= 0) error("Invalid argument");
        if((nbr+pin-1)>NBRPINS) error("Invalid argument");

        while(nbr) {
            if(!(ExtCurrentConfig[pin] == EXT_DIG_IN || ExtCurrentConfig[pin] == EXT_INT_HI || ExtCurrentConfig[pin] == EXT_INT_LO || ExtCurrentConfig[pin] == EXT_INT_BOTH)) error("Invalid input pin");
            value <<= 1;
            value |= PinGetIO_F7(pin);
            nbr--;
            pin++;
        }
    }

    fret = (float)value;
}



void cmd_setpin(void) {
	int pin, value, intv = 0;
	getargs(&cmdline, 7, ",");
	if(argc%2 == 0 || argc == 0) error("Invalid syntax");

	pin = GetPinNbr(argv[0]);
    if(pin < 1 || pin > NBRPINS || (PinDef[pin].mode & PINUNUSED)) error("Invalid pin");

    if(ExtCurrentConfig[pin] >= EXT_COM_RESERVED)  error("Pin is in use");
    if(checkstring(argv[2], "OFF"))
        value = EXT_NOT_CONFIG;
    else if(checkstring(argv[2], "AIN"))
        value = EXT_ANA_IN;
    else if(checkstring(argv[2], "DIN"))
        value = EXT_DIG_IN;
    else if(checkstring(argv[2], "FIN"))
        value = EXT_FREQ_IN;
    else if(checkstring(argv[2], "PIN"))
        value = EXT_PER_IN;
    else if(checkstring(argv[2], "CIN"))
        value = EXT_CNT_IN;
    else if(checkstring(argv[2], "INTH")) {
        value = EXT_INT_HI;
        intv = T_LOHI;
    }
    else if(checkstring(argv[2], "INTL")) {
        value = EXT_INT_LO;
        intv = T_HILO;
    }
    else if(checkstring(argv[2], "DOUT"))
        value = EXT_DIG_OUT;
    else if(checkstring(argv[2], "OOUT"))
        value = EXT_OC_OUT;
    else if(checkstring(argv[2], "INTB")) {
        value = EXT_INT_BOTH;
         intv = T_BOTH;
    }
    else
        value = getinteger(argv[2]);

    // set flags for pullup resistors
    if(((argc==5) && (value==EXT_DIG_IN)) ||
      ((argc==7) && ((value==EXT_INT_LO) || (value==EXT_INT_HI) || (value==EXT_INT_BOTH)))) {

    	if(checkstring(argv[4], "NONE")) {
    		 // no resistor
    	}
    	else if(checkstring(argv[4], "UP"))
    		value |= EXT_DIN_PULL_UP; // pull up
    	else if(checkstring(argv[4], "DOWN"))
    		value |= EXT_DIN_PULL_DOWN; // pull down
    	else error("Invalid syntax");

    }

    ExtCfg(pin, value);

	if(intv != 0) {
		// we need to set up a software interrupt
		if(argc < 5) error("Invalid syntax");
		if(!(PinDef[pin].mode & INTERRUPT)) error("Invalid configuration");
		inttbl[pin].intp = GetIntAddress(argv[argc-1]);					// get the interrupt routine's location
		inttbl[pin].last = ExtInp(pin);								// save the current pin value for the first test
		inttbl[pin].lohi = intv;					                // and set trigger polarity
		InterruptUsed = true;
	}
}



void cmd_pulse(void) {
#if !defined(STM32F7) // PIC
    int pin, i, x, y, state;
    float f;

	getargs(&cmdline, 3, ",");
	if(argc != 3) error("Invalid syntax");
	pin = GetPinNbr(argv[0]);
	if(!(ExtCurrentConfig[pin] == EXT_DIG_OUT || ExtCurrentConfig[pin] == EXT_OC_OUT)) error("Pin is not configured for output");

    f = getnumber(argv[2]);                                         // get the pulse width
    if(f < 0) error("Number out of bounds");
    x = f;                                                          // get the integer portion (in mSec)
    y = (int)((f - (float)x) * 1000.0);                             // get the fractional portion (in uSec)

    for(i = 0; i < NBR_PULSE_SLOTS; i++)                            // search looking to see if the pin is in use
        if(PulseCnt[i] != 0 && PulsePin[i] == pin) {
            mT4IntEnable(0);       									// disable the timer interrupt to prevent any conflicts while updating
            PulseCnt[i] = x;                                        // and if the pin is in use, set its time to the new setting or reset if the user wants to terminate
            mT4IntEnable(1);
            if(x == 0) PinSetBit(PulsePin[i], PulseDirection[i] ? LATSET : LATCLR);
            return;
        }

    if(x == 0 && y == 0) return;                                    // silently ignore a zero pulse width

    state = ((*GetPortAddr(pin, LAT) >> GetPinBit(pin)) & 1);       // get the current state of the output

    if(x < 3) {                                                     // if this is under 3 milliseconds just do it now
        PinSetBit(pin, state ? LATCLR : LATSET);                    // starting edge of the pulse
        uSec(x * 1000 + y);
        PinSetBit(pin, state ? LATSET : LATCLR);                    // finishing edge
        return;
    }

    for(i = 0; i < NBR_PULSE_SLOTS; i++)
        if(PulseCnt[i] == 0) break;                                 // find a spare slot

    if(i >= NBR_PULSE_SLOTS) error("Too many concurrent PULSE commands");

    PinSetBit(pin, state ? LATCLR : LATSET);                        // starting edge of the pulse
    if(x == 1) uSec(500);                                           // prevent too narrow a pulse if there is just one count
    PulsePin[i] = pin;                                              // save the details
    PulseDirection[i] = state;
    PulseCnt[i] = x;
    PulseActive = true;
#else // STM32F746
    error("cmd_pulse");
#endif // STM32F746
}




/****************************************************************************************************************************
IR routines
*****************************************************************************************************************************/

void cmd_ir(void) {
#if !defined(STM32F7) // PIC
    char *p;
    int i, pin, dev, cmd;
    if(checkstring(cmdline, "CLOSE")) {
        T1CON = 0;
        IrState = IR_CLOSED;
        mINT4IntEnable(0);
        IrInterrupt = NULL;
        ExtCfg(WAKEUP_PIN, EXT_NOT_CONFIG);
    } else if((p = checkstring(cmdline, "SEND"))) {
        getargs(&p, 5, ",");
        pin = GetPinNbr(argv[0]);
        dev = getint(argv[2], 0, 0b11111);
        cmd = getint(argv[4], 0, 0b1111111);
        if(ExtCurrentConfig[pin] >= EXT_COM_RESERVED)  error("Pin is in use");
        ExtCfg(pin, EXT_DIG_OUT);
        cmd = (dev << 7) | cmd;
        IRSendSignal(pin, 186);
        for(i = 0; i < 12; i++) {
            uSec(600);
            if(cmd & 1)
                IRSendSignal(pin, 92);
            else
                IRSendSignal(pin, 46);
            cmd >>= 1;
        }
    } else {
        getargs(&cmdline, 5, ",");
        if(IrState != IR_CLOSED) error("Already open");
        if(argc%2 == 0 || argc == 0) error("Invalid syntax");
        IrDev = findvar(argv[0], V_FIND);
        if(!(vartbl[VarIndex].type & T_NBR)) error("Invalid variable");
        IrCmd = findvar(argv[2], V_FIND);
        if(!(vartbl[VarIndex].type & T_NBR)) error("Invalid variable");
        InterruptUsed = true;
        IrInterrupt = GetIntAddress(argv[4]);							// get the interrupt location
        IrInit();
    }
#else // STM32F746
    error("cmd_ir");
#endif // STM32F746
}


void IrInit(void) {
#if !defined(STM32F7) // PIC
    PR1 = 0xffff;
    TMR1 = 0;
    T1CON = 0b1000000000010000;                                     // turn timer 1 on, use 1:8 prescale peripheral bus clock
    if(ExtCurrentConfig[WAKEUP_PIN] >= EXT_COM_RESERVED)  error("Pin is in use");
    ExtCfg(WAKEUP_PIN, EXT_DIG_IN);
    ExtCfg(WAKEUP_PIN, EXT_COM_RESERVED);
    IrReset();
#else // STM32F746
    error("IrInit");
#endif // STM32F746
}



void IrReset(void) {
#if !defined(STM32F7) // PIC
    ConfigINT4(EXT_INT_PRI_2 | FALLING_EDGE_INT | EXT_INT_ENABLE);  // setup the interrupt for the start piulse
    IrState = IR_WAIT_START;
    IrCount = 0;
    TMR1 = 0;
#else // STM32F746
    error("IrReset");
#endif // STM32F746
}


// this modulates (at about 38KHz) the IR beam for transmit
// half_cycles is the number of half cycles to send.  ie, 186 is about 2.4mSec
void IRSendSignal(int pin, int half_cycles) {
#if !defined(STM32F7) // PIC
    while(half_cycles--) {
        PinSetBit(pin, LATINV);
        uSec(13);
    }
#else // STM32F746
    error("IRSendSignal");
#endif // STM32F746
}




/****************************************************************************************************************************
 The LCD command
*****************************************************************************************************************************/

void LCD_Nibble(int Data, int Flag, int Wait_uSec);
void LCD_Byte(int Data, int Flag, int Wait_uSec);
void LcdPinSet(int pin, int val);
static char lcd_pins[6];

void cmd_lcd(void) {
#if !defined(STM32F7) // PIC
    char *p;
    int i, j;

    if((p = checkstring(cmdline, "INIT"))) {
        getargs(&p, 11, ",");
        if(argc != 11) error("Invalid syntax");
        if(*lcd_pins) error("Already open");
        for(i = 0; i < 6; i++) {
            lcd_pins[i] = GetPinNbr(argv[i * 2]);
            if(ExtCurrentConfig[(int)lcd_pins[i]] >= EXT_COM_RESERVED)  error("Pin is in use");
            ExtCfg(lcd_pins[i], EXT_DIG_OUT);
            ExtCfg(lcd_pins[i], EXT_COM_RESERVED);
        }
        LCD_Nibble(0b0011, 0, 5000);                                // reset
        LCD_Nibble(0b0011, 0, 5000);                                // reset
        LCD_Nibble(0b0011, 0, 5000);                                // reset
        LCD_Nibble(0b0010, 0, 2000);                                // 4 bit mode
        LCD_Byte(0b00101100, 0, 600);                               // 4 bits, 2 lines
        LCD_Byte(0b00001100, 0, 600);                               // display on, no cursor
        LCD_Byte(0b00000110, 0, 600);                               // increment on write
        LCD_Byte(0b00000001, 0, 3000);                              // clear the display
        return;
    }

    if(!*lcd_pins) error("Not open");
    if(checkstring(cmdline, "CLOSE")) {
        for(i = 0; i < 6; i++) {
			ExtCfg(lcd_pins[i], EXT_NOT_CONFIG);					// all set to unconfigured
			ExtSet(lcd_pins[i], 0);									// all outputs (when set) default to low
            *lcd_pins = 0;
        }
    } else if((p = checkstring(cmdline, "CLEAR"))) {                // clear the display
        LCD_Byte(0b00000001, 0, 3000);
    } else if((p = checkstring(cmdline, "CMD")) || (p = checkstring(cmdline, "DATA"))) { // send a command or data
        getargs(&p, MAX_ARG_COUNT * 2, ",");
        for(i = 0; i < argc; i += 2) {
            j = getint(argv[i], 0, 255);
            LCD_Byte(j, toupper(*cmdline) == 'D', 0);
        }
    } else {
        const char linestart[4] = {0, 64, 20, 84};
        int center, pos;

        getargs(&cmdline, 5, ",");
        if(argc != 5) error("Invalid syntax");
        i = getint(argv[0], 1, 4);
        pos = 1;
        if(checkstring(argv[2], "C8"))
            center = 8;
        else if(checkstring(argv[2], "C16"))
            center = 16;
        else if(checkstring(argv[2], "C20"))
            center = 20;
        else if(checkstring(argv[2], "C40"))
            center = 40;
        else {
            center = 0;
            pos = getint(argv[2], 1, 256);
        }
        p = getstring(argv[4]);                                     // returns an MMBasic string
        i = 128 + linestart[i - 1] + (pos - 1);
        LCD_Byte(i, 0, 600);
        for(j = 0; j < (center - *p) / 2; j++) {
            LCD_Byte(' ', 1, 0);
        }
        for(i = 1; i <= *p; i++) {
            LCD_Byte(p[i], 1, 0);
            j++;
        }
        for(; j < center; j++) {
            LCD_Byte(' ', 1, 0);
        }
    }
#else // STM32F746
    error("cmd_lcd");
#endif // STM32F746
}



void LCD_Nibble(int Data, int Flag, int Wait_uSec) {
#if !defined(STM32F7) // PIC
    int i;
    LcdPinSet(lcd_pins[4], Flag);
    for(i = 0; i < 4; i++)
        LcdPinSet(lcd_pins[i], (Data >> i) & 1);
    LcdPinSet(lcd_pins[5], 1); uSec(250); LcdPinSet(lcd_pins[5], 0);
    if(Wait_uSec) {
        uSec(Wait_uSec);
    } else {
        uSec(250);
    }
#else // STM32F746
    error("LCD_Nibble");
#endif // STM32F746
}


void LCD_Byte(int Data, int Flag, int Wait_uSec) {
#if !defined(STM32F7) // PIC
    LCD_Nibble(Data/16, Flag, 0);
    LCD_Nibble(Data, Flag, Wait_uSec);
#else // STM32F746
    error("LCD_Byte");
#endif // STM32F746
}


void LcdPinSet(int pin, int val) {
#if !defined(STM32F7) // PIC
    PinSetBit(pin, val ? LATSET : LATCLR);
#else // STM32F746
    error("LcdPinSet");
#endif // STM32F746
}



/****************************************************************************************************************************
 The DISTANCE function
*****************************************************************************************************************************/

void fun_distance(void) {
#if !defined(STM32F7) // PIC
    int trig, echo;

	getargs(&ep, 3, ",");
	if((argc &1) != 1) error("Invalid syntax");
    trig = GetPinNbr(argv[0]);
    if(argc == 3)
        echo = GetPinNbr(argv[2]);
    else
        echo = trig;
    if((PinDef[trig].mode & UNUSED) || (PinDef[echo].mode & UNUSED)) error("Invalid pin");
    if(ExtCurrentConfig[trig] >= EXT_COM_RESERVED || ExtCurrentConfig[echo] >= EXT_COM_RESERVED)  error("Pin is in use");
    ExtCfg(echo, EXT_DIG_IN);
    PinSetBit(trig, LATCLR);
    ExtCfg(trig, EXT_DIG_OUT);
    PinSetBit(trig, LATSET);
    uSec(20);
    PinSetBit(trig, LATCLR);
    uSec(50);
    ExtCfg(echo, EXT_DIG_IN);                                       // this is in case the sensor is a 3-pin type
    uSec(50);
    PauseTimer = 0;
    while(PinRead(echo)) if(PauseTimer > 50) { fret = -2; return; }
    while(!PinRead(echo)) if(PauseTimer > 100) { fret = -2; return; }
    PauseTimer = 0;
    WriteCoreTimer(0);
    while(PinRead(echo)) {
        if(PauseTimer > 32) {
            fret = -1;
            return;
        }
    }
    fret = (int)((float)(ReadCoreTimer() * (2000000000u/CLOCKFREQ)) / 5782.0) / 10.0;
#else // STM32F746
    error("fun_distance");
#endif // STM32F746
}




/****************************************************************************************************************************
 The KEYPAD command
*****************************************************************************************************************************/

static char keypad_pins[8];
float *KeypadVar;
char *KeypadInterrupt = NULL;
void KeypadClose(void);

void cmd_keypad(void) {
#if !defined(STM32F7) // PIC
    int i;

    if(checkstring(cmdline, "CLOSE"))
        KeypadClose();
    else {
        getargs(&cmdline, 19, ",");
        if(argc%2 == 0 || argc < 17) error("Invalid syntax");
        if(KeypadInterrupt != NULL) error("Already open");
        KeypadVar = findvar(argv[0], V_FIND);
        if(!(vartbl[VarIndex].type & T_NBR)) error("Invalid variable");
        InterruptUsed = true;
        KeypadInterrupt = GetIntAddress(argv[2]);							// get the interrupt location
        for(i = 0; i < 8; i++) {
            if(i == 7 && argc < 19) {
                keypad_pins[i] = 0;
                break;
            }
            keypad_pins[i] = GetPinNbr(argv[(i + 2) * 2]);
            if(ExtCurrentConfig[(int)keypad_pins[i]] >= EXT_COM_RESERVED)  error("Pin is in use");
            if(i < 4) {
                ExtCfg(keypad_pins[i], EXT_DIG_IN);
//                PinSetBit(keypad_pins[i], CNPUSET);
            } else {
                ExtCfg(keypad_pins[i], EXT_OC_OUT);
                PinSetBit(keypad_pins[i], LATSET);
            }
            ExtCfg(keypad_pins[i], EXT_COM_RESERVED);
        }
    }
#else // STM32F746
    error("cmd_keypad");
#endif // STM32F746
}


void KeypadClose(void) {
#if !defined(STM32F7) // PIC
    int i;
    if(KeypadInterrupt == NULL) return;
    for(i = 0; i < 8; i++) {
        if(keypad_pins[i]) {
            ExtCfg(keypad_pins[i], EXT_NOT_CONFIG);					    // all set to unconfigured
//            PinSetBit(keypad_pins[i], CNPUCLR);                         // with no pullup
            PinSetBit(keypad_pins[i], LATCLR);						    // all outputs (when set) default to low
        }
    }
    KeypadInterrupt = NULL;
#else // STM32F746
    error("KeypadClose");
#endif // STM32F746
}


int KeypadCheck(void) {
#if !defined(STM32F7) // PIC
    static unsigned char count = 0, keydown = false;
    int i, j;
    const char PadLookup[16] = { 1, 2, 3, 20, 4, 5, 6, 21, 7, 8, 9, 22, 10, 0, 11, 23 };

    if(count++ % 64) return false;                                  // only check every 64 loops through the interrupt processor

    for(j = 4; j < 8; j++) {                                        // j controls the pull down pins
        if(keypad_pins[j]) {                                        // we might just have 3 pull down pins
            PinSetBit(keypad_pins[j], LATCLR);                      // pull it low
            for(i = 0; i < 4; i++) {                                // i is the row sense inputs
                if(PinRead(keypad_pins[i]) == 0) {                  // if it is low we have found a keypress
                    if(keydown) goto exitcheck;                     // we have already reported this, so just exit
                    uSec(40 * 1000);                                // wait 40mS and check again
                    if(PinRead(keypad_pins[i]) != 0) goto exitcheck;// must be contact bounce if it is now high
                    *KeypadVar = PadLookup[(i << 2) | (j - 4)];     // lookup the key value and set the variable
                    PinSetBit(keypad_pins[j], LATSET);
                    keydown = true;                                 // record that we know that the key is down
                    return true;                                    // and tell the interrupt processor that we are good to go
                }
            }
            PinSetBit(keypad_pins[j], LATSET);                      // wasn't this pin, clear the pulldown
        }
    }
    keydown = false;                                                // no key down, record the fact
    return false;

exitcheck:
    PinSetBit(keypad_pins[j], LATSET);
    return false;
#else // STM32F746
    error("KeypadCheck");
    return 0;
#endif // STM32F746
}



/*******************************************************************************************
********************************************************************************************

Utility routines for the external I/O commands and functions in MMBasic

********************************************************************************************
********************************************************************************************/


void ClearExternalIO(void) {
#if !defined(STM32F7) // PIC
	int i;

//	GS I2C Start
	i2c_disable();
	i2c_slave_disable();
//	GS I2C End

    for(i = 1; i <= NBR_SERIAL_PORTS; i++)
        if(SerialConsole != i)
            SerialClose(i);

    // stop any music that might be playing
    mT1IntEnable(0);       										    // disable interrupt
    CloseTimer1();     										        // Timer 1 off

	// stop the sound
	StopAudio();

    // clear any sprites (ClearRuntime() will automatically recover the memory)
    SpriteNbr = 0;

    IrState = IR_CLOSED;
    IrInterrupt = NULL;
    IrGotMsg = false;
    KeypadClose();
    *lcd_pins = 0;                                                  // close the LCD

	for(i = 1; i < NBRPINS + 1; i++) {
		inttbl[i].intp = NULL;										// disable all interrupts
		if(!(PinDef[i].mode & DO_NOT_RESET) && ExtCurrentConfig[i] != EXT_CONSOLE_RESERVED) { 			// don't reset the serial console
			ExtCfg(i, EXT_NOT_CONFIG);								// all set to unconfigured
			ExtSet(i, 0);											// all outputs (when set) default to low
		}
	}
	InterruptReturn = NULL;
	InterruptUsed = false;
    OnKeyGOSUB = NULL;
    #if defined(TFT_MAXIMITE)
	    for(i = 0; i <= MAX_NBR_OF_BTNS; i++) item_active[i] = 0;	    // de-validize all touch objects
	    touch_active = 0;
        OnTouchGOSUB = NULL;
    #endif

    for(i = 0; i < NBRSETTICKS; i++) TickInt[i] = NULL;

	for(i = 0; i < NBR_PULSE_SLOTS; i++) PulseCnt[i] = 0;           // disable any pending pulse commands
    PulseActive = false;
#else // STM32F746
    int i;

    // close all seriell ports
    for(i = 1; i <= NBR_SERIAL_PORTS; i++)
        if(SerialConsole != i)
            SerialClose(i);

    // close all spi ports
    for(i = 1; i <= NBR_SPI_PORTS; i++)
    	SpiClose(i);

    // close i2c port
    i2c_disable();

    // set all io-pins to "not_config"
	for(i = 1; i < NBRPINS + 1; i++) {
		inttbl[i].intp = NULL;										// disable all interrupts
		if(!(PinDef[i].mode & DO_NOT_RESET) && ExtCurrentConfig[i] != EXT_CONSOLE_RESERVED) { 			// don't reset the serial console
			ExtCfg(i, EXT_NOT_CONFIG);								// all set to unconfigured
		}
	}

	InterruptReturn = NULL;
	InterruptUsed = false;
    OnKeyGOSUB = NULL;

    for(i = 0; i <= MAX_NBR_OF_BTNS; i++) item_active[i] = 0;	    // de-validize all touch objects
    touch_active = 0;
    OnTouchGOSUB = NULL;

#endif // STM32F746
}



/****************************************************************************************************************************
Initialise the I/O pins
*****************************************************************************************************************************/
void initExtIO(void) {
#if !defined(STM32F7) // PIC
	int i;

	for(i = 1; i < NBRPINS + 1; i++) {
        if(PinDef[i].mode & UNUSED) continue;
		ExtCfg(i, EXT_NOT_CONFIG);									// all set to unconfigured
		ExtSet(i, 0);												// all outputs (when set) default to low
	}

 	P_BUTTON_IN_PULLUP = 1;											// turn on the pullup for the program push button
	ExtCurrentConfig[0] = EXT_DIG_IN;								// and show that we can read from it

	#if defined(COLOUR)
		UBW32Colour = !P_BUTTON_IN_CMM;                             // detect if we are running on the UBW32 colour schematic
	#endif

	P_LED_TRIS = P_OUTPUT; 											// make the LED pin an output
	ExtSet(0, 0);													// and turn it off

	// setup the analog (ADC) function
	AD1CON1 = 0x00E0;       										// automatic conversion after sampling
 	AD1CSSL = 0;       												// no scanning required
	AD1CON2 = 0;       												// use MUXA, use AVdd   &   AVss as Vref+/-
	AD1CON3 = 0x1F3F;  												// Tsamp = 32 x Tad;
	AD1CON1bits.ADON = 1; 											// turn on the ADC

#if defined(DUINOMITE)
    ExtCfg(21, EXT_ANA_IN);                                         // for the DuinoMite battery measurement (pin 21)
#endif
#else // STM32F746
    error("initExtIO");
#endif // STM32F746
}



/****************************************************************************************************************************
Configure an I/O pin
*****************************************************************************************************************************/
void ExtCfg(int pin, int cfg) {
#if !defined(STM32F7) // PIC
	int tris, ana, oc;

    if(PinDef[pin].mode & UNUSED) error("Invalid pin");

	// make sure that interrupts are disabled in case we are changing from an interrupt input
	if(pin == INT1PIN) ConfigINT1(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_DISABLE);
	if(pin == INT2PIN) ConfigINT2(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_DISABLE);
	if(pin == INT3PIN) ConfigINT3(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_DISABLE);
	if(pin == INT4PIN && IrState == IR_CLOSED) ConfigINT4(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_DISABLE);

	inttbl[pin].intp = NULL;										// also disable a software interrupt on this pin

	switch(cfg) {
		case EXT_NOT_CONFIG:	tris = 1; ana = 1; oc = 1;
								break;

		case EXT_ANA_IN:
                                if(!(PinDef[pin].mode & ANALOG_IN)) error("Invalid configuration");
								tris = 1; ana = 0; oc = 1;
								break;

   		case EXT_FREQ_IN:											// same as counting, so fall through
		case EXT_PER_IN:											// same as counting, so fall through
		case EXT_CNT_IN:
                        		if(pin == INT1PIN) {
						    		ConfigINT1(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_ENABLE);
									INT1Count = INT1Value = 0;
						    		tris = 1; ana = 1; oc = 1;
									break;
								}
								if(pin == INT2PIN) {
						    		ConfigINT2(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_ENABLE);
									INT2Count = INT2Value = 0;
						    		tris = 1; ana = 1; oc = 1;
									break;
								}
								if(pin == INT3PIN) {
						    		ConfigINT3(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_ENABLE);
									INT3Count = INT3Value = 0;
						    		tris = 1; ana = 1; oc = 1;
									break;
								}
								if(pin == INT4PIN) {
						    		ConfigINT4(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_ENABLE);
									INT4Count = INT4Value = 0;
						    		tris = 1; ana = 1; oc = 1;
									break;
								}
								error("Invalid configuration");		// not an interrupt enabled pin
								return;

		case EXT_INT_LO:											// same as digital input, so fall through
		case EXT_INT_HI:											// same as digital input, so fall through
		case EXT_INT_BOTH:											// same as digital input, so fall through
		                        if(!(PinDef[pin].mode & INTERRUPT)) error("Invalid configuration");
		case EXT_DIG_IN:		if(!(PinDef[pin].mode & DIGITAL_IN)) error("Invalid configuration");
		                        tris = 1; ana = 1; oc = 1;
								break;

		case EXT_DIG_OUT:		if(!(PinDef[pin].mode & DIGITAL_OUT)) error("Invalid configuration");
		                        tris = 0; ana = 1; oc = 0;
								break;

		case EXT_OC_OUT:		if(!(PinDef[pin].mode & OC_OUT)) error("Invalid configuration");
		                        if(pin < 11) error("Invalid configuration");
								tris = 0; ana = 1; oc = 1;
								break;

		case EXT_COM_RESERVED:
		case EXT_CONSOLE_RESERVED:
								ExtCurrentConfig[pin] = cfg;		// don't do anything except set the config type
								return;

		default:				error("Invalid configuration");
		                        return;
	}

	ExtCurrentConfig[pin] = cfg;
	PinSetBit(pin, tris ? TRISSET : TRISCLR);
	PinSetBit(pin, oc ? ODCSET : ODCCLR);
    if(ana) AD1PCFGSET = (1 << GetPinBit(pin)); else AD1PCFGCLR = (1 << GetPinBit(pin));
	if(cfg == EXT_NOT_CONFIG) ExtSet(pin, 0);						// set the default output to low
#else // STM32F746
	int din_resistor=0;

	if(PinDef[pin].mode & PINUNUSED) error("Invalid pin");

	inttbl[pin].intp = NULL;										// also disable a software interrupt on this pin

	// save resistor status
	din_resistor=cfg;
	// mask resistor status
	cfg &= ~EXT_DIN_PULL_UP;
	cfg &= ~EXT_DIN_PULL_DOWN;

	switch(cfg) {
		case EXT_NOT_CONFIG:
								break;
		case EXT_ANA_IN:
                                if(!(PinDef[pin].mode & ANALOG_IN)) error("Invalid configuration");
								break;
		case EXT_INT_HI:
		case EXT_INT_LO:
		case EXT_INT_BOTH:
								if(!(PinDef[pin].mode & INTERRUPT)) error("Invalid configuration");
								break;
		case EXT_DIG_IN:		if(!(PinDef[pin].mode & DIGITAL_IN)) error("Invalid configuration");
								break;
		case EXT_DIG_OUT:		if(!(PinDef[pin].mode & DIGITAL_OUT)) error("Invalid configuration");
								break;
		case EXT_COM_RESERVED:
		case EXT_CONSOLE_RESERVED:
								ExtCurrentConfig[pin] = cfg;		// don't do anything except set the config type
								return;
		default:				error("Invalid configuration");
		                        return;
	}
	ExtCurrentConfig[pin] = cfg;
	PinInitIO_F7(pin, cfg, din_resistor);
	// special for led-pin on f746-disco board
	if(pin==LED_PINNR) {
		if(cfg == EXT_NOT_CONFIG) {
		  ExtCurrentConfig[pin] = EXT_DIG_OUT;
		  PinInitIO_F7(pin, EXT_DIG_OUT, EXT_DIN_PULL_NONE);
		  led_d13_enable=true;
		}
		else {
          led_d13_enable=false;
		}
	}
#endif // STM32F746
}





/****************************************************************************************************************************
Set the output of a digital I/O pin
*****************************************************************************************************************************/
void ExtSet(int pin, int val){
	if(pin == 0) {
		error("Pin0 not defined");
	}
	else {
    	if(ExtCurrentConfig[pin] == EXT_DIG_OUT || ExtCurrentConfig[pin] == EXT_OC_OUT) {
    		PinSetIO_F7(pin, val);
	    }
	    else
	        error("Pin is not an output");
	}
}




/****************************************************************************************************************************
Get the value of an I/O pin and returns it
For digital returns 0 if low or 1 if high
For analog returns the reading as a 10 bit number with 0b1111111111 = 3.3V
*****************************************************************************************************************************/
int ExtInp(int pin){
#if !defined(STM32F7) // PIC

	// read from a digital input
	if(ExtCurrentConfig[pin] == EXT_DIG_IN || ExtCurrentConfig[pin] == EXT_INT_HI || ExtCurrentConfig[pin] == EXT_INT_LO || ExtCurrentConfig[pin] == EXT_INT_BOTH || ExtCurrentConfig[pin] == EXT_OC_OUT) {
		if(pin == 0)				                                // this is the push button
		    #if defined(COLOUR)
		        if(UBW32Colour)
		            return P_BUTTON_IN_UBW32;
		        else
		            return P_BUTTON_IN_CMM;
		    #else
			    return P_BUTTON_IN;
			#endif
		else
		    return PinRead(pin);
	}

	// read from an analog input
	if(ExtCurrentConfig[pin] == EXT_ANA_IN) {
    	AD1CHSbits.CH0SA = GetPinBit(pin);
		AD1CON1bits.SAMP = 1;       								// start sampling
		while (!AD1CON1bits.DONE && !MMAbort);  					// wait conversion complete
		return ADC1BUF0;											// and get the result
	}

	// read from a frequency/period input
	if(ExtCurrentConfig[pin] == EXT_FREQ_IN || ExtCurrentConfig[pin] == EXT_PER_IN) {
		switch(pin) {       										// select input channel
    		case INT1PIN:  return INT1Value;
			case INT2PIN:  return INT2Value;
			case INT3PIN:  return INT3Value;
			case INT4PIN:  return INT4Value;
	        default: error("Invalid pin");
		}
	}

	// read from a counter input
	if(ExtCurrentConfig[pin] == EXT_CNT_IN) {
		switch(pin) {       										// select input channel
			case INT1PIN:  return INT1Count;
			case INT2PIN:  return INT2Count;
			case INT3PIN:  return INT3Count;
			case INT4PIN:  return INT4Count;
    	    default: error("Invalid pin");
		}
	}
	return 0;
#else // STM32F746
	if(ExtCurrentConfig[pin] == EXT_DIG_IN || ExtCurrentConfig[pin] == EXT_INT_HI || ExtCurrentConfig[pin] == EXT_INT_LO || ExtCurrentConfig[pin] == EXT_INT_BOTH) { // read from a digital input
	    return PinGetIO_F7(pin);
	}
	else if(ExtCurrentConfig[pin] == EXT_ANA_IN) { // read from an analog input
		return PinGetADC_F7(pin);
	}
	return 0;
#endif // STM32F746
}



/****************************************************************************************************************************
New, more portable, method of manipulating an I/O pin
*****************************************************************************************************************************/

// set or clear a bit in the pin's sfr register
inline void PinSetBit(int pin, unsigned int offset) {
#if !defined(STM32F7) // PIC
    *(PinDef[pin].sfr + offset) = (1 << PinDef[pin].bitnbr);
#else // STM32F746
    error("PinSetBit");
#endif // STM32F746
}


// return the value of a pin's input
inline int PinRead(int pin) {
#if !defined(STM32F7) // PIC
    return (*(PinDef[pin].sfr) >> PinDef[pin].bitnbr) & 1;
#else // STM32F746
    error("PinRead");
    return 0;
#endif // STM32F746
}



// return a pointer to the pin's sfr register
inline volatile unsigned int *GetPortAddr(int pin, unsigned int offset) {
#if !defined(STM32F7) // PIC
    return PinDef[pin].sfr + offset;
#else // STM32F746
    error("GetPortAddr");
    return 0;
#endif // STM32F746
}


// return an integer representing the bit number in the sfr corresponding to the pin's bit
inline int GetPinBit(int pin) {
#if !defined(STM32F7) // PIC
    return PinDef[pin].bitnbr;
#else // STM32F746
    error("GetPinBit");
    return 0;
#endif // STM32F746
}



// init a gpio of STM32F746
// resistor [EXT_DIN_PULL_NONE, EXT_DIN_PULL_UP, EXT_DIN_PULL_DOWN]
void PinInitIO_F7(int pin, int cfg, int din_resistor) {
	GPIO_InitTypeDef GPIO_InitStruct;
	static int adc3_init=0;

	// Clock Enable
	UB_System_ClockEnable(PinDef[pin].sfr);

	switch(cfg) {
		case EXT_ANA_IN:
			if(adc3_init==0) {
				adc3_init=1;
				// clock enable
				__HAL_RCC_ADC3_CLK_ENABLE();

				AdcHandle.Instance          = ADC3;
				AdcHandle.Init.ClockPrescaler        = ADC_CLOCKPRESCALER_PCLK_DIV4;
				AdcHandle.Init.Resolution            = ADC_RESOLUTION_10B;
				AdcHandle.Init.ScanConvMode          = DISABLE;
				AdcHandle.Init.ContinuousConvMode    = DISABLE;
				AdcHandle.Init.DiscontinuousConvMode = DISABLE;
				AdcHandle.Init.NbrOfDiscConversion   = 0;
				AdcHandle.Init.ExternalTrigConvEdge  = ADC_EXTERNALTRIGCONVEDGE_NONE;
				AdcHandle.Init.ExternalTrigConv      = ADC_EXTERNALTRIGCONV_T1_CC1;
				AdcHandle.Init.DataAlign             = ADC_DATAALIGN_RIGHT;
				AdcHandle.Init.NbrOfConversion       = 1;
				AdcHandle.Init.DMAContinuousRequests = DISABLE;
				AdcHandle.Init.EOCSelection          = DISABLE;
				HAL_ADC_Init(&AdcHandle);

			}
			// config as analog input
		    GPIO_InitStruct.Pin = PinDef[pin].bitnbr;
		    GPIO_InitStruct.Mode = GPIO_MODE_ANALOG;
		    GPIO_InitStruct.Pull = GPIO_NOPULL;
		    HAL_GPIO_Init(PinDef[pin].sfr, &GPIO_InitStruct);
			break;
		case EXT_NOT_CONFIG:
		case EXT_DIG_IN:
		case EXT_INT_HI:
		case EXT_INT_LO:
		case EXT_INT_BOTH:
			// config as digital input
		    GPIO_InitStruct.Pin = PinDef[pin].bitnbr;
		    GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
		    GPIO_InitStruct.Pull = GPIO_NOPULL;
		    if((din_resistor&EXT_DIN_PULL_UP)!=0) GPIO_InitStruct.Pull = GPIO_PULLUP;
		    if((din_resistor&EXT_DIN_PULL_DOWN)!=0) GPIO_InitStruct.Pull = GPIO_PULLDOWN;
		    GPIO_InitStruct.Speed = GPIO_SPEED_LOW;
		    HAL_GPIO_Init(PinDef[pin].sfr, &GPIO_InitStruct);
			break;
		case EXT_DIG_OUT:
		    // config as digital output
		    GPIO_InitStruct.Pin = PinDef[pin].bitnbr;
		    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
		    GPIO_InitStruct.Pull = GPIO_NOPULL;
		    GPIO_InitStruct.Speed = GPIO_SPEED_LOW;
		    HAL_GPIO_Init(PinDef[pin].sfr, &GPIO_InitStruct);
			break;
		default:				error("Invalid IO configuration");
		                        return;
	}
}

// write a gpio of STM32F746
void PinSetIO_F7(int pin, int val) {
	if(val==0) {
		PinDef[pin].sfr->BSRR = (uint32_t)PinDef[pin].bitnbr << 16;
	}
	else {
		PinDef[pin].sfr->BSRR = (uint32_t)PinDef[pin].bitnbr;
	}
}

// read a gpio of STM32F746
int PinGetIO_F7(int pin) {
	if(HAL_GPIO_ReadPin(PinDef[pin].sfr, PinDef[pin].bitnbr)==GPIO_PIN_RESET) {
		return 0;
	}
	else {
		return 1;
	}
}

// read a adc of STM32F746
int PinGetADC_F7(int pin) {
	ADC_ChannelConfTypeDef sConfig;

  sConfig.Channel      = ADC_CHANNEL_0;
  if(PinDef[pin].bitnbr==GPIO_PIN_0) sConfig.Channel      = ADC_CHANNEL_0;
  if(PinDef[pin].bitnbr==GPIO_PIN_6) sConfig.Channel      = ADC_CHANNEL_4;
  if(PinDef[pin].bitnbr==GPIO_PIN_7) sConfig.Channel      = ADC_CHANNEL_5;
  if(PinDef[pin].bitnbr==GPIO_PIN_8) sConfig.Channel      = ADC_CHANNEL_6;
  if(PinDef[pin].bitnbr==GPIO_PIN_9) sConfig.Channel      = ADC_CHANNEL_7;
  if(PinDef[pin].bitnbr==GPIO_PIN_10) sConfig.Channel      = ADC_CHANNEL_8;
  sConfig.Rank         = 1;
  sConfig.SamplingTime = ADC_SAMPLETIME_3CYCLES;
  sConfig.Offset       = 0;

  if (HAL_ADC_ConfigChannel(&AdcHandle, &sConfig) != HAL_OK) return 0;
  if (HAL_ADC_Start(&AdcHandle) != HAL_OK) return 0;
  HAL_ADC_PollForConversion(&AdcHandle, 10);
  if (HAL_ADC_GetState(&AdcHandle) == HAL_ADC_STATE_EOC_REG) return  HAL_ADC_GetValue(&AdcHandle);

	return 0;
}

void Init_AtariJoy_F7(int pin_up , int pin_down , int pin_left , int pin_right , int pin_b1 , int pin_b2){
	PinInitIO_F7(pin_up		, EXT_DIG_IN, EXT_DIN_PULL_UP);
	PinInitIO_F7(pin_down	, EXT_DIG_IN, EXT_DIN_PULL_UP);
	PinInitIO_F7(pin_left	, EXT_DIG_IN, EXT_DIN_PULL_UP);
	PinInitIO_F7(pin_right	, EXT_DIG_IN, EXT_DIN_PULL_UP);
	PinInitIO_F7(pin_b1		, EXT_DIG_IN, EXT_DIN_PULL_UP);
	PinInitIO_F7(pin_b2		, EXT_DIG_IN, EXT_DIN_PULL_UP);
//	Give the pin value to the joystick global variables
	Joy_Up 		= pin_up;
	Joy_Down 	= pin_down;
	Joy_Left 	= pin_left;
	Joy_Right 	= pin_right;
	Joy_B1 		= pin_b1;
	Joy_B2 		= pin_b2;
	joy_initialized = 1;
}

int Get_AtariJoy_F7(int pin){
	return PinGetIO_F7(pin);
}



float *IrDev, *IrCmd;
char IrState, IrGotMsg;
int IrBits, IrCount;
char *IrInterrupt;



/****************************************************************************************************************************
Interrupt service routines for the counting functions (eg, frequency, period)
*****************************************************************************************************************************/

// perform the counting functions for pin 11
#if !defined(STM32F7) // PIC
void __ISR( _EXTERNAL_1_VECTOR , ipl2) INT1Interrupt(void) {
	if(ExtCurrentConfig[INT1PIN] == EXT_PER_IN) {
		INT1Value = INT1Count;
		INT1Count = 0;
	}
	else
		INT1Count++;

    mINT1ClearIntFlag();    										// Clear the interrupt flag
    return;
}
#else // STM32F746

#endif // STM32F746



// perform the counting functions for pin 12
#if !defined(STM32F7) // PIC
void __ISR( _EXTERNAL_2_VECTOR , ipl2) INT2Interrupt(void) {
	if(ExtCurrentConfig[INT2PIN] == EXT_PER_IN) {
		INT2Value = INT2Count;
		INT2Count = 0;
	}
	else
		INT2Count++;

    mINT2ClearIntFlag();    										// Clear the interrupt flag
    return;
}
#else // STM32F746

#endif // STM32F746




// perform the counting functions for pin 13
#if !defined(STM32F7) // PIC
void __ISR( _EXTERNAL_3_VECTOR , ipl2) INT3Interrupt(void) {
	if(ExtCurrentConfig[INT3PIN] == EXT_PER_IN) {
		INT3Value = INT3Count;
		INT3Count = 0;
	}
	else
		INT3Count++;

    mINT3ClearIntFlag();    										// Clear the interrupt flag
    return;
}
#else // STM32F746

#endif // STM32F746



// perform the counting functions for pin 14
// this interrupt is also used by the IR command
#if !defined(STM32F7) // PIC
void __ISR( _EXTERNAL_4_VECTOR , ipl2) INT4Interrupt(void) {
    if(IrState == IR_CLOSED) {
        // this is a COUNTING interrupt
        if(ExtCurrentConfig[INT4PIN] == EXT_PER_IN) {
            INT4Value = INT4Count;
            INT4Count = 0;
        }
        else
            INT4Count++;
    } else {
        // this is an IR interrupt
        switch(IrState) {
            case IR_WAIT_START:
                TMR1 = 0;                                           // reset the timer
                ConfigINT4(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_ENABLE);   // now trigger on the trailing edge of the start pulse
                IrState = IR_WAIT_START_END;                        // wait for the end of the start bit
                break;
            case IR_WAIT_START_END:
                if(elapsed < 2000 || elapsed > 2800) { IrReset(); break; }
                IrCount = 0;                                        // count the bits in the message
                IrBits = 0;                                         // reset the bit acumulator
                TMR1 = 0;                                           // reset the timer
                ConfigINT4(EXT_INT_PRI_2 | FALLING_EDGE_INT | EXT_INT_ENABLE);   // now trigger on the leading edge of the first data bit
                IrState = IR_WAIT_BIT_START;                        // now wait for the first data bit
                break;
            case IR_WAIT_BIT_START:
                if(elapsed < 300 || elapsed > 900) { IrReset(); break; }
                TMR1 = 0;                                           // reset the timer
                ConfigINT4(EXT_INT_PRI_2 | RISING_EDGE_INT | EXT_INT_ENABLE);   // now trigger on the trailing edge of a data bit
                IrState = IR_WAIT_BIT_END;                          // wait for the end of this data bit
                break;
            case IR_WAIT_BIT_END:
                if(elapsed < 300 || elapsed > 1500 || IrCount > 20) { IrReset(); break; }
                IrBits |= (elapsed > 900) << IrCount;               // get the data bit
                IrCount++;                                          // and increment our count
                TMR1 = 0;                                           // reset the timer
                ConfigINT4(EXT_INT_PRI_2 | FALLING_EDGE_INT | EXT_INT_ENABLE);   // now trigger on the leading edge of the next data bit
                IrState = IR_WAIT_BIT_START;                        // go back and wait for the next data bit
                break;
        }
    }

    mINT4ClearIntFlag();    										// Clear the interrupt flag
    return;
}
#else // STM32F746

#endif // STM32F746


// Setup the pins for the connected joystick
// Syntax : JoyInit( up , down , left , right , button1 , button2)
// Each of the parameters correspond to a pin number
void cmd_joyinit(void){
	int p_up,p_down,p_left,p_right,p_b1,p_b2;
	getargs(&cmdline, 1, " ");
	if(*argv[0] != '(') error("Expected opening bracket");   // arg0 must be '('
	if(argc < 1) error("syntax error");
	// get 3 koordinate pairs
	joyparam(argv[0] + 1, &p_up, &p_down, &p_left, &p_right, &p_b1, &p_b2);

	if((p_up < 1)		|| (p_up > 22))		error("pin number must be 1 to 22 (Joy Up)");
	if((p_down < 1)		|| (p_down > 22))	error("pin number must be 1 to 22 (Joy Down)");
	if((p_left < 1)		|| (p_left > 22))	error("pin number must be 1 to 22 (Joy Left)");
	if((p_right < 1)	|| (p_right > 22))	error("pin number must be 1 to 22 (Joy Right)");
	if((p_b1 < 1)		|| (p_b1 > 22))		error("pin number must be 1 to 22 (Joy Button 1)");
	if((p_b2 < 1)		|| (p_b2 > 22))		error("pin number must be 1 to 22 (Joy Button 2)");
	Init_AtariJoy_F7(p_up , p_down , p_left , p_right , p_b1 , p_b2);
}

// Get joystick data
void fun_joyget(void){
	char *p;

	if (joy_initialized != 1) error("Initialize Joystick first ...");

	// Syntax : JoyGet(#UP)
	if((p = checkstring(ep, "#UP")) != NULL) { // Read Joystick UP
		fret=Get_AtariJoy_F7(Joy_Up);
		return;
	}

	// Syntax : JoyGet(#DOWN)
	if((p = checkstring(ep, "#DOWN")) != NULL) { // Read Joystick DOWN
		fret=Get_AtariJoy_F7(Joy_Down);
		return;
	}

	// Syntax : JoyGet(#LEFT)
	if((p = checkstring(ep, "#LEFT")) != NULL) { // Read Joystick LEFT
		fret=Get_AtariJoy_F7(Joy_Left);
		return;
	}

	// Syntax : JoyGet(#RIGHT)
	if((p = checkstring(ep, "#RIGHT")) != NULL) { // Read Joystick RIGHT
		fret=Get_AtariJoy_F7(Joy_Right);
		return;
	}

	// Syntax : JoyGet(#B1)
	if((p = checkstring(ep, "#B1")) != NULL) { // Read Joystick Button 1
		fret=Get_AtariJoy_F7(Joy_B1);
		return;
	}

	// Syntax : JoyGet(#B2)
	if((p = checkstring(ep, "#B2")) != NULL) { // Read Joystick Button 2
		fret=Get_AtariJoy_F7(Joy_B2);
		return;
	}

	error("Invalid Syntax");
}


void joyparam(char *p, int *jup, int *jdw, int *jlft, int *jrgt, int *jb1, int *jb2) {
	char *tp, *ttp;
	char b[STRINGSIZE];

	tp = getclosebracket(p);
	*tp = 0;														// remove the closing brackets
	strcpy(b, p);													// copy the coordinates to the temp buffer
	*tp = ')';														// put back the closing bracket
	ttp = b;														// kludge (todo: fix this)
	{
		getargs(&ttp, 11, ",");										// this is a macro and must be the first executable stmt in a block
		if(argc != 11) error("Invalid Syntax");
		*jup = getinteger(argv[0]);
		*jdw = getinteger(argv[2]);
		*jlft = getinteger(argv[4]);
		*jrgt = getinteger(argv[6]);
		*jb1 = getinteger(argv[8]);
		*jb2 = getinteger(argv[10]);
	}
}

