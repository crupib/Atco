//--------------------------------------------------------------
// File     : stm32_ub_led.h
//--------------------------------------------------------------

//--------------------------------------------------------------
#ifndef __STM32F7_UB_LED_H
#define __STM32F7_UB_LED_H

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_system.h"






//--------------------------------------------------------------
// Liste aller LEDs
// (keine Nummer doppelt und von 0 beginnend)
//--------------------------------------------------------------
typedef enum 
{
  LED_GREEN = 0,  // LED auf dem STM32F746-Discovery
}LED_NAME_t;


//--------------------------------------------------------------
// Status einer LED
//--------------------------------------------------------------
typedef enum {
  LED_OFF = 0,  // LED AUS
  LED_ON        // LED EIN
}LED_STATUS_t;


//--------------------------------------------------------------
// Struktur einer LED
//--------------------------------------------------------------
typedef struct {
  LED_NAME_t LED_NAME;    // Name
  GPIO_TypeDef* LED_PORT; // Port
  const uint16_t LED_PIN; // Pin
  LED_STATUS_t LED_INIT;  // Init
}LED_t;


//--------------------------------------------------------------
// Globale Funktionen
//--------------------------------------------------------------
void UB_Led_Init(void);
void UB_Led_Off(LED_NAME_t led_name);
void UB_Led_On(LED_NAME_t led_name);
void UB_Led_Toggle(LED_NAME_t led_name);
void UB_Led_Switch(LED_NAME_t led_name, LED_STATUS_t wert);



//--------------------------------------------------------------
#endif // __STM32F7_UB_LED_H
