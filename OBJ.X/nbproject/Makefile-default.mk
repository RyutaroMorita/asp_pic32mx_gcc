#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile).#
Device=PIC32MX570F512L
ProjectDir="C:\cygwin64\home\morita\asp_1.9.2\OBJ.X"
ProjectName=OBJ
ConfName=default
TOOLCHAIN_pic-as=C:\Program Files\Microchip\xc8\v2.36\pic-as\bin
TOOLCHAIN_XC32=C:\Program Files\Microchip\xc32\v4.30\bin
TOOLCHAIN_AVRASM=C:\Program Files (x86)\Atmel\Studio\7.0\toolchain\avr8\avrassembler
TOOLCHAIN_ARM=C:\Program Files (x86)\GNU Tools ARM Embedded\7 2017-q4-major\bin
TOOLCHAIN_XC8=C:\Program Files\Microchip\xc8\v2.36\bin
TOOLCHAIN_AVR=C:\Program Files (x86)\Atmel\Studio\7.0\toolchain\avr8\avr8-gnu-toolchain\bin
.build-conf:  ${BUILD_SUBPROJECTS}
	${MAKE}  -f nbproject/Makefile-default.mk image

# ------------------------------------------------------------------------------------
# Rules for buildStep: build and debug
ifeq ($(TYPE_IMAGE), DEBUG_RUN)
image: C:/cygwin64/home/morita/asp_1.9.2/OBJ/asp.exe nbproject/Makefile-default.mk 
else
image: C:/cygwin64/home/morita/asp_1.9.2/OBJ/asp.exe nbproject/Makefile-default.mk 
endif

.PHONY: C:/cygwin64/home/morita/asp_1.9.2/OBJ/asp.exe
C:/cygwin64/home/morita/asp_1.9.2/OBJ/asp.exe: 
	cd ../OBJ && OMIT_OPTIMIZATION=1 make

.PHONY: C:/cygwin64/home/morita/asp_1.9.2/OBJ/asp.exe
C:/cygwin64/home/morita/asp_1.9.2/OBJ/asp.exe: 
	cd ../OBJ && make


# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	cd ../OBJ && make clean

