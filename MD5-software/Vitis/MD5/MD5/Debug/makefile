################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/subdir.mk
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
ELFSIZE += \
MD5.elf.size \


# All Target
all: MD5.elf secondary-outputs

# Tool invocations
MD5.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: MicroBlaze gcc linker'
	mb-gcc -Wl,-T -Wl,../src/lscript.ld -LC:/Xilinx/Projects/MD5/mb_design_wrapper/export/mb_design_wrapper/sw/mb_design_wrapper/standalone_domain/bsplib/lib -mlittle-endian -mxl-barrel-shift -mno-xl-soft-div -mcpu=v11.0 -mno-xl-soft-mul -Wl,--no-relax -Wl,--gc-sections -o "MD5.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

MD5.elf.size: MD5.elf
	@echo 'Invoking: MicroBlaze Print Size'
	mb-size MD5.elf  |tee "MD5.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) MD5.elf
	-@echo ' '

secondary-outputs: $(ELFSIZE)

.PHONY: all clean dependents

-include ../makefile.targets
