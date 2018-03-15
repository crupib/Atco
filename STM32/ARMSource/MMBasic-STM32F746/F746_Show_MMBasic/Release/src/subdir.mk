################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/lib3d.c \
../src/main.c \
../src/stm32_ub_fatfs.c \
../src/stm32_ub_font.c \
../src/stm32_ub_i2c1.c \
../src/stm32_ub_i2c3.c \
../src/stm32_ub_jpg.c \
../src/stm32_ub_lcd_480x272.c \
../src/stm32_ub_led.c \
../src/stm32_ub_mpu6050.c \
../src/stm32_ub_qflash.c \
../src/stm32_ub_sdram.c \
../src/stm32_ub_spi.c \
../src/stm32_ub_system.c \
../src/stm32_ub_touch_480x272.c \
../src/stm32_ub_uart.c \
../src/stm32_ub_usb_hid_host.c \
../src/stm32_ub_usb_msc_host.c \
../src/stm32f7_keyboard.c \
../src/stm32f7_random.c \
../src/stm32f7xx_it.c \
../src/stmF7_gfx.c \
../src/syscalls.c \
../src/system_stm32f7xx.c \
../src/wm8994.c 

OBJS += \
./src/lib3d.o \
./src/main.o \
./src/stm32_ub_fatfs.o \
./src/stm32_ub_font.o \
./src/stm32_ub_i2c1.o \
./src/stm32_ub_i2c3.o \
./src/stm32_ub_jpg.o \
./src/stm32_ub_lcd_480x272.o \
./src/stm32_ub_led.o \
./src/stm32_ub_mpu6050.o \
./src/stm32_ub_qflash.o \
./src/stm32_ub_sdram.o \
./src/stm32_ub_spi.o \
./src/stm32_ub_system.o \
./src/stm32_ub_touch_480x272.o \
./src/stm32_ub_uart.o \
./src/stm32_ub_usb_hid_host.o \
./src/stm32_ub_usb_msc_host.o \
./src/stm32f7_keyboard.o \
./src/stm32f7_random.o \
./src/stm32f7xx_it.o \
./src/stmF7_gfx.o \
./src/syscalls.o \
./src/system_stm32f7xx.o \
./src/wm8994.o 

C_DEPS += \
./src/lib3d.d \
./src/main.d \
./src/stm32_ub_fatfs.d \
./src/stm32_ub_font.d \
./src/stm32_ub_i2c1.d \
./src/stm32_ub_i2c3.d \
./src/stm32_ub_jpg.d \
./src/stm32_ub_lcd_480x272.d \
./src/stm32_ub_led.d \
./src/stm32_ub_mpu6050.d \
./src/stm32_ub_qflash.d \
./src/stm32_ub_sdram.d \
./src/stm32_ub_spi.d \
./src/stm32_ub_system.d \
./src/stm32_ub_touch_480x272.d \
./src/stm32_ub_uart.d \
./src/stm32_ub_usb_hid_host.d \
./src/stm32_ub_usb_msc_host.d \
./src/stm32f7_keyboard.d \
./src/stm32f7_random.d \
./src/stm32f7xx_it.d \
./src/stmF7_gfx.d \
./src/syscalls.d \
./src/system_stm32f7xx.d \
./src/wm8994.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo %cd%
	arm-none-eabi-gcc -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16 -DSTM32F746G_DISCO -DSTM32F746NGHx -DSTM32F7 -DSTM32 -DUSE_HAL_DRIVER -DSTM32F746xx -DUSE_USB_FS -DUSE_USB_HS -DUSER_UB -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/core" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/device" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc/Legacy" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/fatfs" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmbasic" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmsource" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/usb" -O3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


