/***********************************************************************************************************************
MMBasic

IOPorts.h

Include file that defines the IOPins for the PIC32 chip in MMBasic.

Copyright 2011, 2012 Geoff Graham.  All Rights Reserved.

This file and modified versions of this file are supplied to specific individuals or organisations under the following
provisions:

- This file, or any files that comprise the MMBasic source (modified or not), may not be distributed or copied to any other
  person or organisation without written permission.

- Object files (.o and .hex files) generated using this file (modified or not) may not be distributed or copied to any other
  person or organisation without written permission.

- This file is provided in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

************************************************************************************************************************/

#if !defined(__32MX695F512H__) && !defined(__32MX795F512H__)
    #error Processor must be set to 32MX695F512H or 32MX795F512H
#endif


// General defines
#define P_INPUT				1						// for setting the TRIS on I/O bits
#define P_OUTPUT			0
#define P_ON				1
#define P_OFF				0

// Constant definitions of the port registers in the 32MX695F512H, 32MX795F512H, 32MX695F512L or 32MX795F512L
#define ADDR_PORTA          (volatile unsigned int *)0xbf886010
#define ADDR_PORTB          ADDR_PORTA + 0x10
#define ADDR_PORTC          ADDR_PORTB + 0x10
#define ADDR_PORTD          ADDR_PORTC + 0x10
#define ADDR_PORTE          ADDR_PORTD + 0x10
#define ADDR_PORTF          ADDR_PORTE + 0x10
#define ADDR_PORTG          ADDR_PORTF + 0x10

// Structure that defines the SFR, bit number and mode for each I/O pin
struct s_PinDef {
    volatile unsigned int *sfr;
    int bitnbr;
    int mode;
};

// Defines for the various modes that an I/O pin can be set to
#define UNUSED       (1 << 0)
#define ANALOG_IN    (1 << 1)
#define DIGITAL_IN   (1 << 2)
#define COUNTING     (1 << 3)
#define INTERRUPT    (1 << 4)
#define DIGITAL_OUT  (1 << 5)
#define OC_OUT       (1 << 6)
#define DO_NOT_RESET (1 << 7)

#define NBRPINS				20						// number of pins for external i/o
#define NBR_SERIAL_PORTS    2



// Define the structure for the I/O pins
// the first element of the structure contains a pointer to the SFR for the port to be used
// the second element is the bit number within that port to use
// the third is a set of flags that defines what that I/O pin can do
#if defined(DEFINE_PINDEF_TABLE)
struct s_PinDef PinDef[NBRPINS + 1] = {
    { NULL,  0, UNUSED | DO_NOT_RESET },                                              // pin 0
    { ADDR_PORTB,  4, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT },             // pin 1
    { ADDR_PORTB,  3, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 2
    { ADDR_PORTB,  6, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 3
    { ADDR_PORTB,  7, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 4
    { ADDR_PORTB,  9, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 5
    { ADDR_PORTB, 10, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 6
    { ADDR_PORTB, 11, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 7
    { ADDR_PORTB, 12, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 8
    { ADDR_PORTB, 13, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 9
    { ADDR_PORTB, 15, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 10
    { ADDR_PORTD,  8, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 11
    { ADDR_PORTD,  9, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 12
    { ADDR_PORTD, 10, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 13
    { ADDR_PORTD, 11, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 14
    { ADDR_PORTE,  2, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 15
    { ADDR_PORTE,  3, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 16
    { ADDR_PORTE,  4, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 17
    { ADDR_PORTE,  5, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 18
    { ADDR_PORTE,  6, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 19
    { ADDR_PORTE,  7, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 20
};
#else
    extern struct s_PinDef PinDef[];
#endif      // DEFINE_PINDEF_TABLE


// Defines for the external I/O pins
#define P_BUTTON_IN			PORTCbits.RC13			// this is the push button
#define P_BUTTON_IN_PULLUP	CNPUEbits.CNPUE1		// and its pullup

#define P_LED_OUT			LATFbits.LATF0			// this is the LED
#define P_LED_TRIS			TRISFbits.TRISF0

// Define the counting pins
#define INT1PIN             11
#define INT2PIN             12
#define INT3PIN             13
#define INT4PIN             14

// pin used for receiving IR messages
#define WAKEUP_PIN          14

// I2C definitions
#define P_I2C_SDA           12  // I/O pin number
#define P_I2C_SCL           13  // I/O pin number



// Keyboard definitions
#define P_PS2CLK			PORTDbits.RD6			// Pin 54 input  - Keyboard clock
#define P_PS2CLK_TRIS       TRISDbits.TRISD6        // tris
#define P_PS2CLK_OUT        LATDbits.LATD6          // output latch for the clock
#define P_PS2CLK_PULLUP		CNPUEbits.CNPUE15
#define P_PS2CLK_INT		CNENbits.CNEN15

#define P_PS2DAT			PORTDbits.RD7			// Pin 55 input  - Keyboard data
#define P_PS2DAT_TRIS       TRISDbits.TRISD7        // tris
#define P_PS2DAT_OUT        LATDbits.LATD7          // output latch for the data
#define P_PS2DAT_PULLUP		CNPUEbits.CNPUE16



// video defines
#define P_VGA_COMP			PORTCbits.RC14			// VGA/Composite jumper
#define P_VGA_SELECT		1						// state when VGA selected
#define P_VGA_COMP_PULLUP	CNPUEbits.CNPUE0

#define P_VIDEO_SPI			2						// the SPI peripheral used for video.  note: pin G9 is automatically set as the framing input
#define P_SPI_INPUT			SPI2ABUF				// input buffer for the SPI peripheral
#define P_SPI_INTERRUPT		_SPI2A_TX_IRQ			// interrupt used by the video DMA
#define P_VID_OC_OPEN       OpenOC3					// the function used to open the output compare (see video.c)
#define P_VID_OC_REG        OC3R                    // the output compare register

#define P_VIDEO				PORTGbits.RG8			// video
#define P_VIDEO_TRIS		TRISGbits.TRISG8

#define P_HORIZ				PORTDbits.RD2			// horizontal sync
#define P_HORIZ_TRIS		TRISDbits.TRISD2

#define P_VERT_SET_HI		LATFSET = (1 << 1)		// set vert sync hi
#define P_VERT_SET_LO		LATFCLR = (1 << 1)		// set vert sync lo
#define P_VERT_TRIS			TRISFbits.TRISF1



// SD card defines
// This file is included in SDCard/HardwareProfile.h and replaces the defines in that file
#define P_SD_LED_SET_HI		LATESET = (1 << 1)		// SD card activity led
#define P_SD_LED_SET_LO		LATECLR = (1 << 1)		// SD card activity led
#define P_SD_ACTIVITY_TRIS	TRISEbits.TRISE1

#define SD_CS_SET_HI        LATESET = (1 << 0)		// SD-SPI Chip Set Output bit high
#define SD_CS_SET_LO        LATECLR = (1 << 0)		// SD-SPI Set Output bit low
#define SD_CS_TRIS          TRISEbits.TRISE0		// SD-SPI Chip Select TRIS bit

#define SD_CD               PORTDbits.RD4			// SD-SPI Card Detect Input bit
#define SD_CD_TRIS          TRISDbits.TRISD4		// SD-SPI Card Detect TRIS bit

#define SD_WE               PORTDbits.RD5			// SD-SPI Write Protect Check Input bit
#define SD_WE_TRIS          TRISDbits.TRISD5		// SD-SPI Write Protect Check TRIS bit

#define SPICON1             SPI3ACON				// The main SPI control register
#define SPISTAT             SPI3ASTAT				// The SPI status register
#define SPIBUF              SPI3ABUF				// The SPI Buffer
#define SPISTAT_RBF         SPI3ASTATbits.SPIRBF	// The receive buffer full bit in the SPI status register
#define SPICON1bits         SPI3ACONbits			// The bitwise define for the SPI control register (i.e. _____bits)
#define SPISTATbits         SPI3ASTATbits			// The bitwise define for the SPI status register (i.e. _____bits)
#define SPIENABLE           SPI3ACONbits.ON			// The enable bit for the SPI module
#define SPIBRG			    SPI3ABRG				// The definition for the SPI baud rate generator register (PIC32)

#define SPICLOCK            TRISBbits.TRISB14		// The TRIS bit for the SCK pin
#define SPIIN               TRISFbits.TRISF4		// The TRIS bit for the SDI pin
#define SPIOUT              TRISFbits.TRISF5		// The TRIS bit for the SDO pin

#define putcSPI(spichar)     SpiChnPutC(SPI_CHANNEL3A, spichar)	//SPI library functions
#define getcSPI()            SpiChnGetC(SPI_CHANNEL3A)
#define OpenSPI(config1, config2)   SpiChnOpen(SPI_CHANNEL3A, config1, config2)



// Serial ports defines
#define P_COM1_RX_PIN_NBR	15
#define P_COM1_RX_PORT		PORTEbits.RE2

#define P_COM1_TX_PIN_NBR	16
#define P_COM1_TX_SET_HI	LATESET = (1 << 3)
#define P_COM1_TX_SET_LO	LATECLR = (1 << 3)

#define P_COM1_RTS_PIN_NBR	17
#define P_COM1_RTS_SET_HI	LATESET = (1 << 4)
#define P_COM1_RTS_SET_LO	LATECLR = (1 << 4)

#define P_COM1_CTS_PIN_NBR	18
#define P_COM1_CTS_PORT		PORTEbits.RE5

#define P_COM2_RX_PIN_NBR	19
#define P_COM2_RX_PORT		PORTEbits.RE6

#define P_COM2_TX_PIN_NBR	20
#define P_COM2_TX_SET_HI	LATESET = (1 << 7)
#define P_COM2_TX_SET_LO	LATECLR = (1 << 7)



// sound output
#define P_SOUND_OPEN_OC     OpenOC2
#define P_SOUND_CLOSE_OC    CloseOC2
#define P_SOUND_SET_PWM     SetDCOC2PWM
#define P_SOUND_TRIS		TRISDbits.TRISD1

// the second sound channel is not available so use dummy values
#define P_SOUND2_OPEN_OC(a, b, c)
#define P_SOUND2_CLOSE_OC()
#define P_SOUND2_SET_PWM(a)
#define P_SOUND2_TRIS		P_SOUND_TRIS

