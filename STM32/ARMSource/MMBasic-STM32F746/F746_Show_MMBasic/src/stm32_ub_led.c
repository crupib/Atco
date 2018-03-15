//--------------------------------------------------------------
// File     : stm32_ub_led.c
// Datum    : 12.07.2015
// Version  : 1.0
// Autor    : UB
// EMail    : mc-4u(@)t-online.de
// Web      : www.mikrocontroller-4u.de
// CPU      : STM32F746
// IDE      : OpenSTM32
// GCC      : 4.9 2015q2
// Module   : CubeHAL
// Funktion : LED Funktionen
//--------------------------------------------------------------

//--------------------------------------------------------------
// Includes
//--------------------------------------------------------------
#include "stm32_ub_led.h"


//--------------------------------------------------------------
// Definition aller LEDs
// Reihenfolge wie bei LED_NAME_t
//
// Init : [LED_OFF,LED_ON]
//--------------------------------------------------------------
LED_t LED[] = {
  // Name    ,PORT , PIN      , Init
  {LED_GREEN ,GPIOI,GPIO_PIN_1,LED_OFF}   // PI1=Gruene LED auf dem Discovery-Board
};
static int LED_ANZ = sizeof(LED)/sizeof(LED[0]);  // Anzahl der Eintraege




//--------------------------------------------------------------
// Init aller LEDs
//--------------------------------------------------------------
void UB_Led_Init(void)
{
  GPIO_InitTypeDef GPIO_InitStruct;
  LED_NAME_t led_name;
  
  for(led_name=0;led_name<LED_ANZ;led_name++) {
    // Clock Enable
    UB_System_ClockEnable(LED[led_name].LED_PORT);

    // Config als Digital-Ausgang
    GPIO_InitStruct.Pin = LED[led_name].LED_PIN;
    GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_LOW;
    HAL_GPIO_Init(LED[led_name].LED_PORT, &GPIO_InitStruct);

    // Default Wert einstellen
    if(LED[led_name].LED_INIT==LED_OFF) {
      UB_Led_Off(led_name);
    }
    else {
      UB_Led_On(led_name);
    }
  }
}


//--------------------------------------------------------------
// LED ausschalten
//--------------------------------------------------------------
void UB_Led_Off(LED_NAME_t led_name)
{
  LED[led_name].LED_PORT->BSRR = (uint32_t)LED[led_name].LED_PIN << 16;
}

//--------------------------------------------------------------
// LED einschalten
//--------------------------------------------------------------
void UB_Led_On(LED_NAME_t led_name)
{
  LED[led_name].LED_PORT->BSRR = LED[led_name].LED_PIN;
} 

//--------------------------------------------------------------
// LED toggeln
//--------------------------------------------------------------
void UB_Led_Toggle(LED_NAME_t led_name)
{
  LED[led_name].LED_PORT->ODR ^= LED[led_name].LED_PIN;
}

//--------------------------------------------------------------
// LED ein- oder ausschalten
//--------------------------------------------------------------
void UB_Led_Switch(LED_NAME_t led_name, LED_STATUS_t wert)
{
  if(wert==LED_OFF) {
    UB_Led_Off(led_name);
  }
  else {
    UB_Led_On(led_name);
  }
}
