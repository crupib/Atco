################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../mmbasic/Commands.c \
../mmbasic/Custom.c \
../mmbasic/Functions.c \
../mmbasic/MMBasic.c \
../mmbasic/Operators.c 

OBJS += \
./mmbasic/Commands.o \
./mmbasic/Custom.o \
./mmbasic/Functions.o \
./mmbasic/MMBasic.o \
./mmbasic/Operators.o 

C_DEPS += \
./mmbasic/Commands.d \
./mmbasic/Custom.d \
./mmbasic/Functions.d \
./mmbasic/MMBasic.d \
./mmbasic/Operators.d 


# Each subdirectory must supply rules for building sources it contributes
mmbasic/%.o: ../mmbasic/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: MCU GCC Compiler'
	@echo %cd%
	arm-none-eabi-gcc -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16 -DSTM32F746G_DISCO -DSTM32F746NGHx -DSTM32F7 -DSTM32 -DDEBUG -DUSE_HAL_DRIVER -DSTM32F746xx -DUSE_USB_FS -DUSE_USB_HS -DUSER_UB -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/core" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/CMSIS/device" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc/Legacy" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/HAL_Driver/Inc" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/fatfs" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmbasic" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/mmsource" -I"F:/Data_Temp_Ordner/eclipse_prj_v130/F746_Show_MMBasic/usb" -O0 -g3 -Wall -fmessage-length=0 -ffunction-sections -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


