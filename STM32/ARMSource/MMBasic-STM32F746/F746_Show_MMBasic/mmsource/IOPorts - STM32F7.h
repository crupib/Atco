/***********************************************************************************************************************
MMBasic

IOPorts - ColourMM.h

Include file that defines the IOPins for the STM32F7 chip in the F746 version of MMBasic.

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

#if !defined(STM32F7)
    #error Processor must be set to STM32F7
#endif

#include "stm32f7xx.h"
#include "stm32f7xx_hal.h"

// General defines
#define P_INPUT				1						// for setting the TRIS on I/O bits
#define P_OUTPUT			0
#define P_ON				1
#define P_OFF				0

// Constant definitions of the port registers in the 32MX695F512H, 32MX795F512H, 32MX695F512L or 32MX795F512L
#define ADDR_PORTA          GPIOA
#define ADDR_PORTB          GPIOB
#define ADDR_PORTC          GPIOC
#define ADDR_PORTD          GPIOD
#define ADDR_PORTE          GPIOE
#define ADDR_PORTF          GPIOF
#define ADDR_PORTG          GPIOG
#define ADDR_PORTH          GPIOH
#define ADDR_PORTI          GPIOI

// Structure that defines the SFR, bit number and mode for each I/O pin
struct s_PinDef {
	GPIO_TypeDef *sfr;
    int bitnbr;
    int mode;
};

// Defines for the various modes that an I/O pin can be set to
#define PINUNUSED    (1 << 0)
#define ANALOG_IN    (1 << 1)
#define DIGITAL_IN   (1 << 2)
#define COUNTING     (1 << 3)
#define INTERRUPT    (1 << 4)
#define DIGITAL_OUT  (1 << 5)
#define OC_OUT       (1 << 6)
#define DO_NOT_RESET (1 << 7)

#define NBRPINS				23						// number of pins for external i/o
#define NBR_SERIAL_PORTS    2
#define NBR_SPI_PORTS       2

#define D0_PINNR            1    // number of arduino pin D0
#define A0_PINNR           17    // number of arduino pin A0
#define LED_PINNR          14    // number of led pin

// Define the structure for the I/O pins
// the first element of the structure contains a pointer to the SFR for the port to be used
// the second element is the bit number within that port to use
// the third is a set of flags that defines what that I/O pin can do
#if defined(DEFINE_PINDEF_TABLE)
struct s_PinDef PinDef[NBRPINS + 1] = {
    { NULL,  0, PINUNUSED | DO_NOT_RESET },                                           			  // pin  0
    { ADDR_PORTC,  GPIO_PIN_7, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  1 CN4/1  Arduino D0 (set D0_PINNR)
    { ADDR_PORTC,  GPIO_PIN_6, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  2 CN4/2  Arduino D1
    { ADDR_PORTG,  GPIO_PIN_6, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  3 CN4/3  Arduino D2
    { ADDR_PORTB,  GPIO_PIN_4, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  4 CN4/4  Arduino D3
    { ADDR_PORTG,  GPIO_PIN_7, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  5 CN4/5  Arduino D4
    { ADDR_PORTI,  GPIO_PIN_0, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  6 CN4/6  Arduino D5
    { ADDR_PORTH,  GPIO_PIN_6, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  7 CN4/7  Arduino D6
    { ADDR_PORTI,  GPIO_PIN_3, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  8 CN4/8  Arduino D7
    { ADDR_PORTI,  GPIO_PIN_2, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin  9 CN7/1  Arduino D8
    { ADDR_PORTA, GPIO_PIN_15, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin 10 CN7/2  Arduino D9
    { ADDR_PORTA,  GPIO_PIN_8, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin 11 CN7/3  Arduino D10
    { ADDR_PORTB, GPIO_PIN_15, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin 12 CN7/4  Arduino D11
    { ADDR_PORTB, GPIO_PIN_14, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin 13 CN7/5  Arduino D12
    { ADDR_PORTI,  GPIO_PIN_1, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin 14 CN7/6  Arduino D13 (LED green) (set LED_PINNR)
    { ADDR_PORTB,  GPIO_PIN_9, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin 15 CN7/9  Arduino D14
    { ADDR_PORTB,  GPIO_PIN_8, INTERRUPT | DIGITAL_IN | DIGITAL_OUT },                            // pin 16 CN7/10  Arduino D15
    { ADDR_PORTA,  GPIO_PIN_0, INTERRUPT | DIGITAL_IN | DIGITAL_OUT | ANALOG_IN },                // pin 17 CN5/1  Arduino A0 (set A0_PINNR)
    { ADDR_PORTF, GPIO_PIN_10, INTERRUPT | DIGITAL_IN | DIGITAL_OUT | ANALOG_IN },                // pin 18 CN5/2  Arduino A1
    { ADDR_PORTF,  GPIO_PIN_9, INTERRUPT | DIGITAL_IN | DIGITAL_OUT | ANALOG_IN },                // pin 19 CN5/3  Arduino A2
    { ADDR_PORTF,  GPIO_PIN_8, INTERRUPT | DIGITAL_IN | DIGITAL_OUT | ANALOG_IN },                // pin 20 CN5/4  Arduino A3
    { ADDR_PORTF,  GPIO_PIN_7, INTERRUPT | DIGITAL_IN | DIGITAL_OUT | ANALOG_IN },                // pin 21 CN5/5  Arduino A4
    { ADDR_PORTF,  GPIO_PIN_6, INTERRUPT | DIGITAL_IN | DIGITAL_OUT | ANALOG_IN },                // pin 22 CN5/6  Arduino A5
    { ADDR_PORTI, GPIO_PIN_11, INTERRUPT | DIGITAL_IN }                                           // pin 23 User-Button
};

int UBW32Colour;                                    // set to true if this is the UBW32 version of the Colour Maximite

#else       // DEFINE_PINDEF_TABLE

extern struct s_PinDef PinDef[];
extern int UBW32Colour;

#endif      // !DEFINE_PINDEF_TABLE





// Define the pins that are associated with the external interrupts (used for counting)
#define INT1PIN             11
#define INT2PIN             14
#define INT3PIN             13
#define INT4PIN             12

// pin used for receiving IR messages
#define WAKEUP_PIN          12

// Serial ports defines (I2C1)
#define P_I2C1_SDA          15  // PB9
#define P_I2C1_SCL          16  // PB8


// Serial ports defines (SPI1)
#define P_SPI1_SCK_PIN_NBR	14   // PI1
#define P_SPI1_MOSI_PIN_NBR	12   // PB15
#define P_SPI1_MISO_PIN_NBR	13   // PB14
#define P_SPI1_SS_PIN_NBR	11   // PA8


// Serial ports defines (SPI2)
#define P_SPI2_SCK_PIN_NBR	21   // PF7
#define P_SPI2_MOSI_PIN_NBR	19   // PF9
#define P_SPI2_MISO_PIN_NBR	20   // PF8
#define P_SPI2_SS_PIN_NBR	22   // PF6



// Serial ports defines (COM1)
#define P_COM1_RX_PIN_NBR	1   // PC7
#define P_COM1_TX_PIN_NBR	2   // PC6

// Serial ports defines (COM2)
#define P_COM2_RX_PIN_NBR	22  // PF6
#define P_COM2_TX_PIN_NBR	21  // PF7
#define P_COM2_RTS_PIN_NBR	20  // PF8
#define P_COM2_CTS_PIN_NBR	19  // PF9




// sound output - Left Channel
#define P_SOUND_OPEN_OC     OpenOC2
#define P_SOUND_CLOSE_OC    CloseOC2
#define P_SOUND_SET_PWM     SetDCOC2PWM
#define P_SOUND_TRIS		TRISDbits.TRISD1

// sound output - Right Channel
#define P_SOUND2_OPEN_OC    OpenOC4
#define P_SOUND2_CLOSE_OC   CloseOC4
#define P_SOUND2_SET_PWM    SetDCOC4PWM
#define P_SOUND2_TRIS		TRISDbits.TRISD3


// touch input defines
