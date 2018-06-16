/***********************************************************************************************************************
MMBasic

IOPorts.h

Include file that defines the IOPins for Duinomite in MMBasic.

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


#define NBRPINS				21						// number of pins for external i/o
#define NBR_SERIAL_PORTS    4

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


// Define the structure for the I/O pins
// the first element of the structure contains a pointer to the SFR for the port to be used
// the second element is the bit number within that port to use
// the third is a set of flags that defines what that I/O pin can do
#if defined(DEFINE_PINDEF_TABLE)
struct s_PinDef PinDef[NBRPINS + 1] = {
    { NULL,  0, UNUSED | DO_NOT_RESET },                                              // pin 0
    { ADDR_PORTB,  3, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT },             // pin 1
    { ADDR_PORTB,  4, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 2
    { ADDR_PORTB,  6, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 3
    { ADDR_PORTB,  7, ANALOG_IN | DIGITAL_IN | INTERRUPT | DIGITAL_OUT  },            // pin 4
    { ADDR_PORTB,  9, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 5
    { ADDR_PORTB, 10, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 6
#if defined(DM_REVA)
    { ADDR_PORTB, 13, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 7 on Rev A of the PCB
#else
    { ADDR_PORTD, 11, DIGITAL_IN | COUNTING | INTERRUPT | DIGITAL_OUT | OC_OUT },     // pin 7 on Rev B of the PCB
#endif
    { NULL,  0, UNUSED | DO_NOT_RESET },                                              // pin 8
    { NULL,  0, UNUSED | DO_NOT_RESET },                                              // pin 9
    { NULL,  0, UNUSED | DO_NOT_RESET },                                              // pin 10
    { ADDR_PORTE,  0, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },     			  // pin 11
    { ADDR_PORTE,  1, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },     			  // pin 12
    { ADDR_PORTE,  2, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },     			  // pin 13
    { ADDR_PORTE,  3, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },     			  // pin 14
    { ADDR_PORTE,  4, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 15
    { ADDR_PORTE,  5, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 16
    { ADDR_PORTE,  6, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 17
    { ADDR_PORTE,  7, DIGITAL_IN | INTERRUPT | DIGITAL_OUT | OC_OUT },                // pin 18
    { NULL,  0, UNUSED | DO_NOT_RESET },                                              // pin 19
    { NULL,  0, UNUSED | DO_NOT_RESET },                                              // pin 20
    { ADDR_PORTB,  2, ANALOG_IN | DO_NOT_RESET }		            				  // pin 21 DuinoMite battery
};
#else
extern struct s_PinDef PinDef[];
#endif      // DEFINE_PINDEF_TABLE



// Defines for the external I/O pins
#define P_BUTTON_IN			PORTDbits.RD8			// this is the push button
#define P_BUTTON_IN_PULLUP  i                       // for the DuinoMite use a dummy variable as this pin has a pullup

#define P_LED_OUT			LATBbits.LATB15			// this is the LED
#define P_LED_TRIS			TRISBbits.TRISB15


// Define the counting pins (the number is the pin number as used in the PIN() function in BASIC)
// negative numbers means that this function is not supported
#define INT1PIN            -1
#define INT2PIN             5
#define INT3PIN             6
#define INT4PIN             7

// pin used for receiving IR messages
#define WAKEUP_PIN          7

// I2C definitions
#define P_I2C_SDA           6                       // I/O pin number, 12 on MM
#define P_I2C_SCL           5                       // I/O pin number, 13 on MM


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


// special hardware for the DuinoMite to turn on the I/O
#if defined(DM_REVA)
  #define P_DM_STNB         ODCDbits.ODCD11 = 1; TRISDbits.TRISD11 = 0; PORTDbits.RD11 = 0;
#else
  #define P_DM_STNB         ODCBbits.ODCB13 = 1; TRISBbits.TRISB13 = 0; PORTBbits.RB13 = 0;
#endif


// video defines
#define P_VGA_SELECT		0						// state when VGA selected
#define P_VGA_COMP		    PORTBbits.RB11			// VGA/Composite jumper
#define P_VGA_COMP_PULLUP	vga                     // give the video driver a non important variable as we do not want to pull anything up

#define P_VIDEO_SPI			2						// the SPI peripheral used for video.  note: pin G9 is automatically set as the framing input
#define P_SPI_INPUT			SPI2ABUF				// input buffer for the SPI peripheral
#define P_SPI_INTERRUPT		_SPI2A_TX_IRQ			// interrupt used by the video DMA
#define P_VID_OC_OPEN       OpenOC5					// the function used to open the output compare (see video.c)
#define P_VID_OC_REG        OC5R                    // the output compare register

#define P_VIDEO				PORTGbits.RG8			// video
#define P_VIDEO_TRIS		TRISGbits.TRISG8

#define P_HORIZ				PORTDbits.RD4			// horizontal sync
#define P_HORIZ_TRIS		TRISDbits.TRISD4

#define P_VERT_SET_HI		LATBSET = (1 << 12)	    // set vert sync hi
#define P_VERT_SET_LO		LATBCLR = (1 << 12)	    // set vert sync lo
#define P_VERT_TRIS			TRISBbits.TRISB12



// SD card defines
// This file is included in SDCard/HardwareProfile.h and replaces the defines in that file
#define P_SD_LED_SET_HI		LATBSET = (1 << 15)	    // SD card activity led
#define P_SD_LED_SET_LO		LATBCLR = (1 << 15)	    // SD card activity led

#define P_SD_ACTIVITY_TRIS	TRISBbits.TRISB15

#define SD_CS_SET_HI        LATDSET = (1 << 5)		// SD-SPI Chip Set Output bit high
#define SD_CS_SET_LO        LATDCLR = (1 << 5)		// SD-SPI Set Output bit low
#define SD_CS_TRIS          TRISDbits.TRISD5		// SD-SPI Chip Select TRIS bit
#define SD_CS_READ_LAT      LATDbits.LATD5          // get the current setting of the LAT register
#define SD_CS_READ_PORT     PORTDbits.RD5           // get the current value of the port as an input

#define SD_CD               0           			// SD-SPI Card Detect Input is not implemented
#define SD_CD_TRIS          TRISDbits.TRISD2		// SD-SPI Card Detect TRIS bit - this will have the effect of doing nothing
#define SD_WE               0           			// SD-SPI Write Protect Check Input is not implemented
#define SD_WE_TRIS          TRISDbits.TRISD2		// SD-SPI Write Protect Check TRIS bit -  this will have the effect of doing nothing

#define SPICON1             SPI3CON				    // The main SPI control register
#define SPISTAT             SPI3STAT				// The SPI status register
#define SPIBUF              SPI3BUF				    // The SPI Buffer
#define SPISTAT_RBF         SPI3STATbits.SPIRBF	    // The receive buffer full bit in the SPI status register
#define SPICON1bits         SPI3CONbits			    // The bitwise define for the SPI control register (i.e. _____bits)
#define SPISTATbits         SPI3STATbits			// The bitwise define for the SPI status register (i.e. _____bits)
#define SPIENABLE           SPI3CONbits.ON			// The enable bit for the SPI module
#define SPIBRG		        SPI3BRG				    // The definition for the SPI baud rate generator register (PIC32)

#define SPICLOCK            TRISDbits.TRISD1		// The TRIS bit for the SCK pin
#define SPIIN               TRISDbits.TRISD2		// The TRIS bit for the SDI pin
#define SPIOUT              TRISDbits.TRISD3		// The TRIS bit for the SDO pin

#define putcSPI(spichar)     SpiChnPutC(3, spichar)	//SPI library functions
#define getcSPI()            SpiChnGetC(3)
#define OpenSPI(config1, config2)   SpiChnOpen(3, config1, config2)



// Serial ports defines
#define P_COM1_RX_PIN_NBR	15
#define P_COM1_RX_PORT		PORTEbits.RE4

#define P_COM1_TX_PIN_NBR	16
#define P_COM1_TX_SET_HI	LATESET = (1 << 5)
#define P_COM1_TX_SET_LO	LATECLR = (1 << 5)

#define P_COM1_RTS_PIN_NBR	17
#define P_COM1_RTS_SET_HI	LATESET = (1 << 6)
#define P_COM1_RTS_SET_LO	LATECLR = (1 << 6)

#define P_COM1_CTS_PIN_NBR	18
#define P_COM1_CTS_PORT		PORTEbits.RE7

#define P_COM2_RX_PIN_NBR	13
#define P_COM2_RX_PORT		PORTEbits.RE2

#define P_COM2_TX_PIN_NBR	14
#define P_COM2_TX_SET_HI	LATESET = (1 << 3)
#define P_COM2_TX_SET_LO	LATECLR = (1 << 3)

#define P_COM4_RX_PIN_NBR	11
#define P_COM4_TX_PIN_NBR	12



// sound output
#define P_SOUND_OPEN_OC     OpenOC1
#define P_SOUND_CLOSE_OC    CloseOC1
#define P_SOUND_SET_PWM     SetDCOC1PWM
#define P_SOUND_TRIS		TRISDbits.TRISD0

// the second sound channel is not available on the DuinoMite so use dummy values
#define P_SOUND2_OPEN_OC(a, b, c)
#define P_SOUND2_CLOSE_OC()
#define P_SOUND2_SET_PWM(a)
#define P_SOUND2_TRIS		P_SOUND_TRIS

