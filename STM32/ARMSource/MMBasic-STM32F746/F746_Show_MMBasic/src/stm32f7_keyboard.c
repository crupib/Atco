//--------------------------------------------------------------
// File     : stm32f7_keyboard.c
// Datum    : 12.07.2015
// Version  : 1.0
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : LEER
//--------------------------------------------------------------

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32f7_keyboard.h"
#include "stm32_ub_uart.h"  // nur zur debug test
char buf[20];               // nur zur debug test

const unsigned int KeyboardOption = 0x1fffffff;						// used to store the keyboard layout output
const unsigned int TabOption = 0x2fffffff;						    // use to hold the tab space setting in flash
volatile int KeyDown;



//-------------------------------------------------
// Keyboard Layout
//   0 = QWERTZ
//   1 = QWERTY
//   2 = AZERTY
//-------------------------------------------------

#if defined(USER_UB)
  uint8_t KBD_Layout=0; // default=QWERTZ
#else
  uint8_t KBD_Layout=2; // default=AZERTY
#endif






//-------------------------------------------------
// table to convert
// usb_keycode in mmbasic_keycode
//
// normal keys (with shift-button inaktiv)
//-------------------------------------------------

const uint8_t keyCodes[KEY_MAX_LAYOUT][KEY_MAX_BUTTONS]=	{
	// DE Layout (QWERTZ)
	{
	0,	0,	0,	0,	'a',	'b',	'c',	'd',	'e',	'f',	//   0-  9
	'g',	'h',	'i',	'j',	'k',	'l',	'm',	'n',	'o',	'p',	//  10- 19
	'q',	'r',	's',	't',	'u',	'v',	'w',	'x',	'z',	'y',	//  20- 29
	'1',	'2',	'3',	'4',	'5',	'6',	'7',	'8',	'9',	'0',	//  30- 39
	ENTER,	ESC,	BKSP,	TAB,	' ',	0,	0,	0,	'+',	'#',	//  40- 49
	0,	0,	0,	'^',	',',	'.',	'-',	0,	F1,	F2,	//  50- 59
	F3,	F4,	F5,	F6,	F7,	F8,	F9,	F10,	F11,	F12,	//  60- 69
	0,	0,	0,	INSERT,	HOME,	PUP,	DEL,	END,	PDOWN,	RIGHT,	//  70- 79
	LEFT,	DOWN,	UP,	0,	0,	0,	0,	0,	0,	0,	//  80- 89
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	//  90- 99
	'<',	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 100-109
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 110-119
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	// 120-129
	},
	// US Layout (QWERTY)
	{
	0,	0,	0,	0,	'a',	'b',	'c',	'd',	'e',	'f',	//   0-  9
	'g',	'h',	'i',	'j',	'k',	'l',	'm',	'n',	'o',	'p',	//  10- 19
	'q',	'r',	's',	't',	'u',	'v',	'w',	'x',	'y',	'z',	//  20- 29
	'1',	'2',	'3',	'4',	'5',	'6',	'7',	'8',	'9',	'0',	//  30- 39
	ENTER,	ESC,	BKSP,	TAB,	' ',	'-',	'=',	'[',	']',	'\\',	//  40- 49
	0,	';',	'\'',	0,	',',	'.',	'/',	0,	F1,	F2,	//  50- 59
	F3,	F4,	F5,	F6,	F7,	F8,	F9,	F10,	F11,	F12,	//  60- 69
	0,	0,	0,	INSERT,	HOME,	PUP,	DEL,	END,	PDOWN,	RIGHT,	//  70- 79
	LEFT,	DOWN,	UP,	0,	0,	0,	0,	0,	0,	0,	//  80- 89
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	//  90- 99
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 100-109
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 110-119
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	// 120-129
	},
	// FR Layout (AZERTY)
	{
	0,	0,	0,	0,	'q',	'b',	'c',	'd',	'e',	'f',	//   0-  9
	'g',	'h',	'i',	'j',	'k',	'l',	',',	'n',	'o',	'p',	//  10- 19
	'a',	'r',	's',	't',	'u',	'v',	'z',	'x',	'y',	'w',	//  20- 29
	'&',	0,	'"',	'\'',	'(',	'-',	0,	'_',	0,	0,	//  30- 39
	ENTER,	ESC,	BKSP,	TAB,	' ',	')',	'=',	'^',	'$',	0,	//  40- 49
	'*',	'm',	0,	0,	';',	':',	'!',	0,	F1,	F2,	//  50- 59
	F3,	F4,	F5,	F6,	F7,	F8,	F9,	F10,	F11,	F12,	//  60- 69
	0,	0,	0,	INSERT,	HOME,	PUP,	DEL,	END,	PDOWN,	RIGHT,	//  70- 79
	LEFT,	DOWN,	UP,	0,	'/',	'*',	'-',	'+',	ENTER,	'1',	//  80- 89
	'2',	'3',	'4',	'5',	'6',	'7',	'8',	'9',	'0',	'.',	//  90- 99
	'<',	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 100-109
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 110-119
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	// 120-129
	}
};


//-------------------------------------------------
// table to convert
// usb_keycode in mmbasic_keycode
//
// shifted keys (with shift-button aktiv)
//-------------------------------------------------

const uint8_t keySCodes[KEY_MAX_LAYOUT][KEY_MAX_BUTTONS]=	{
	// DE Layout (QWERTZ)
	{                                                                        
	0,	0,	0,	0,	'A',	'B',	'C',	'D',	'E',	'F',	//   0-  9
	'G',	'H',	'I',	'J',	'K',	'L',	'M',	'N',	'O',	'P',	//  10- 19
	'Q',	'R',	'S',	'T',	'U',	'V',	'W',	'X',	'Z',	'Y',	//  20- 29
	'!',	'"',	0,	'$',	'%',	'&',	'/',	'(',	')',	'=',	//  30- 39
	ENTER,	ESC,	BKSP,	TAB,	' ',	'?',	0,	0,	'*',	'\'',	//  40- 49
	0,	0,	0,	0,	';',	':',	'_',	0,	F1,	F2,	//  50- 59
	F3,	F4,	F5,	F6,	F7,	F8,	F9,	F10,	F11,	F12,	//  60- 69
	0,	0,	0,	INSERT,	HOME,	PUP,	DEL,	END,	PDOWN,	RIGHT,	//  70- 79
	LEFT,	DOWN,	UP,	0,	0,	0,	0,	0,	0,	0,	//  80- 89
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	//  90- 99
	'>',	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 100-109
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 110-119
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	// 120-129
	},
	// US Layout (QWERTY)
	{                                                                        
	0,	0,	0,	0,	'A',	'B',	'C',	'D',	'E',	'F',	//   0-  9
	'G',	'H',	'I',	'J',	'K',	'L',	'M',	'N',	'O',	'P',	//  10- 19
	'Q',	'R',	'S',	'T',	'U',	'V',	'W',	'X',	'Y',	'Z',	//  20- 29
	'!',	'@',	'#',	'$',	'%',	'^',	'&',	'*',	'(',	')',	//  30- 39
	ENTER,	ESC,	BKSP,	TAB,	' ',	'_',	'+',	'{',	'}',	'|',	//  40- 49
	0,	':',	'"',	'~',	'<',	'>',	'?',	0,	F1,	F2,	//  50- 59
	F3,	F4,	F5,	F6,	F7,	F8,	F9,	F10,	F11,	F12,	//  60- 69
	0,	0,	0,	INSERT,	HOME,	PUP,	DEL,	END,	PDOWN,	RIGHT,	//  70- 79
	LEFT,	DOWN,	UP,	0,	0,	0,	0,	0,	0,	0,	//  80- 89
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	//  90- 99
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 100-109
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 110-119
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	// 120-129
	},
	// FR Layout (AZERTY)
	{                                                                        
	0,	0,	0,	0,	'Q',	'B',	'C',	'D',	'E',	'F',	//   0-  9
	'G',	'H',	'I',	'J',	'K',	'L',	'?',	'N',	'O',	'P',	//  10- 19
	'A',	'R',	'S',	'T',	'U',	'V',	'Z',	'X',	'Y',	'W',	//  20- 29
	'1',	'2',	'3',	'4',	'5',	'6',	'7',	'8',	'9',	'0',	//  30- 39
	ENTER,	ESC,	BKSP,	TAB,	' ',	0,	'+',	0,	0,	0,	//  40- 49
	0,	'M',	'%',	0,	'.',	'/',	0,	0,	F1,	F2,	//  50- 59
	F3,	F4,	F5,	F6,	F7,	F8,	F9,	F10,	F11,	F12,	//  60- 69
	0,	0,	0,	INSERT,	HOME,	PUP,	DEL,	END,	PDOWN,	RIGHT,	//  70- 79
	LEFT,	DOWN,	UP,	0,	0,	0,	0,	0,	0,	0,	//  80- 89
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	//  90- 99
	'>',	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 100-109
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	// 110-119
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0	// 120-129
	}
};



//--------------------------------------------------------------
// return key-value : -1 = no key
//                    >0 = mmbasic_keycode
//
// shift_status     :     0 = no shift
//                     bit0 = left-shift
//                     bit1 = right-shift
//                     bit2 = left-ctrl
//                     bit3 = left-alt
//                     bit4 = right-alt_gr
//                     bit5 = right-ctrl
//                     bit6 = left-gui (microsoft key)
//                     bit7 = right-gui (microsoft key)
//--------------------------------------------------------------
int Keyboard_getChar(int *shift_status)
{
  int ret_value=-1;
  uint8_t key_count=0,akt_shift=0;
  uint8_t usbkey_code=0, mmkeycode=0;
  static uint8_t akt_mode=0;
  static uint8_t old_count=0;

  *shift_status=0;

  // check usb-keyboard status
  // and get first or second key-code and shift-status
  if(USB_HID_HOST_STATUS==USB_HID_KEYBOARD_CONNECTED) {
	// get shift status
    akt_shift=UB_USB_HID_HOST_GetShift();
    *shift_status=akt_shift;
    // check how many keys are pressed
    key_count=UB_USB_HID_HOST_GetKeyAnz();
    if(key_count>0) {
      // one or more keys pressed
      // get key-code from fist key
      usbkey_code=USB_KEY_DATA.akt_key1;
      if(key_count==2) {
        // get kex-code from second key
        usbkey_code=USB_KEY_DATA.akt_key2;        
        if(old_count!=2) {
          // fast typing
          old_count=2;
          akt_mode=0;
        }
      }
      else old_count=1;
    }
    else {
      // no key is pressed
      usbkey_code=0;
      akt_mode=0;
      old_count=0;
      KeyDown=0;
    }
  }
  else {
    // usb keyboard not ready
    *shift_status=0;
    usbkey_code=0;
    KeyDown=0;
    return -1;
  }

  // convert usb-keycode in mmbasic-keycode
  if((usbkey_code>0) && (usbkey_code<KEY_MAX_BUTTONS) && (KBD_Layout<3)) {
    // check if 2nd function is used (SHIFT+Button) 
    if((akt_shift&(SHIFTBIT_LSHIFT|SHIFTBIT_RSHIFT))!=0) {
      // shift is pressed
      mmkeycode=keySCodes[KBD_Layout][usbkey_code];
    }
    else {
      // shift is not pressed     
      mmkeycode=keyCodes[KBD_Layout][usbkey_code];

      // check if 3rd function is used (ALT_GR+Button)
      if((akt_shift&SHIFTBIT_RALT)!=0) {
        if(KBD_Layout==0) { // Layout = QWERTZ
          if(usbkey_code==36) mmkeycode='{';
          if(usbkey_code==37) mmkeycode='[';
          if(usbkey_code==38) mmkeycode=']';
          if(usbkey_code==39) mmkeycode='}';
          if(usbkey_code==45) mmkeycode='\\';
          if(usbkey_code==20) mmkeycode='@';
          if(usbkey_code==48) mmkeycode='~';
          if(usbkey_code==100) mmkeycode='|';
        }
        else if(KBD_Layout==1) { // Layout = QWERTY
          // not used in us-layout
        }
        else if(KBD_Layout==2) { // Layout = AZERTY
          if(usbkey_code==31) mmkeycode='~';
          if(usbkey_code==32) mmkeycode='#';
          if(usbkey_code==33) mmkeycode='{';
          if(usbkey_code==34) mmkeycode='[';
          if(usbkey_code==35) mmkeycode='|';
          if(usbkey_code==36) mmkeycode='\'';
          if(usbkey_code==37) mmkeycode='\\';
          if(usbkey_code==38) mmkeycode='^';
          if(usbkey_code==39) mmkeycode='@';
          if(usbkey_code==45) mmkeycode=']';
          if(usbkey_code==46) mmkeycode='}';
        }
      }

      // check if 4th function is used (CTRL+Button)
      if(((akt_shift&SHIFTBIT_LSTRG)!=0) || ((akt_shift&SHIFTBIT_RSTRG)!=0)) {
    	  if(usbkey_code==6) mmkeycode=0x03; // CTRL+'c' => BreakKey
      }
    }
  }
  else {
    mmkeycode=0; 
  }

  // set return value to mmbasic_keycode
  // and keydown variable for basic-program
  if(mmkeycode>0) {
    ret_value=mmkeycode;
    KeyDown=mmkeycode;
  }
  else {
    ret_value=-1;
    KeyDown=0;
  }

  // insert key delay- and repeat-time
  if(akt_mode==0) {
    if(key_count>0) {
      // keydown for the first time
      akt_mode=1;
      // reset delay timer
      mKeyDelayTimer=0;
    }
  }
  else if(akt_mode==1) {
    // wait for the delay time
    if(mKeyDelayTimer>=KEY_DELAY_TIME) {
      akt_mode=2;
      // reset delay timer
      mKeyDelayTimer=0;
    }
    else ret_value=-1; // while delay-time -> set key to "not pressed"
  }
  else {
    // wait for repeat time
    if(mKeyDelayTimer>=KEY_REPEAT_TIME) {
      // reset delay timer
      mKeyDelayTimer=0;
    }
    else ret_value=-1; // while repeat-time -> set key to "not pressed"
  }

  // debug to readout the usb-keycode with basic program
  // KeyDown=usbkey_code;

  // debug to readout usb-shift-code with basic program
  // KeyDown=akt_shift;

  return ret_value;
}
