################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include usb/subdir.mk
-include startup/subdir.mk
-include src/subdir.mk
-include mmsource/subdir.mk
-include mmbasic/subdir.mk
-include inc/pic/subdir.mk
-include inc/font/subdir.mk
-include fatfs/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 

# All Target
all: F746_Show_MMBasic.elf

dependents:
	-cd F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/Debug && $(MAKE) clean all

# Tool invocations
F746_Show_MMBasic.elf: $(OBJS) $(USER_OBJS) F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/Debug/libstm32f746g-disco_hal_lib.a
	@echo 'Building target: $@'
	@echo 'Invoking: MCU GCC Linker'
	arm-none-eabi-gcc -mcpu=cortex-m7 -mthumb -mfloat-abi=hard -mfpu=fpv5-sp-d16 -L"F:\Data_Temp_Ordner\eclipse_prj_v130\stm32f746g-disco_hal_lib\Debug" -T"F:\Data_Temp_Ordner\eclipse_prj_v130\F746_Show_MMBasic\LinkerScript.ld" -Wl,-Map=output.map -Wl,--gc-sections -lm -o "F746_Show_MMBasic.elf" @"objects.list" $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

# Other Targets
clean:
	-$(RM) *
	-@echo ' '

post-build:
	-@echo 'Generating binary and Printing size information:'
	arm-none-eabi-objcopy -O binary "F746_Show_MMBasic.elf" "F746_Show_MMBasic.bin"
	arm-none-eabi-size "F746_Show_MMBasic.elf"
	-@echo ' '

.PHONY: all clean dependents
.SECONDARY: post-build
F:/Data_Temp_Ordner/eclipse_prj_v130/stm32f746g-disco_hal_lib/Debug/libstm32f746g-disco_hal_lib.a:

-include ../makefile.targets
