/*********************************************************************
 *
 *                  C Runtime Startup
 *
 *********************************************************************
 * Filename:        crt0.S
 *
 * Processor:       PIC32
 *
 * Compiler:        MPLAB XC32
 *                  MPLAB X IDE
 * Company:         Microchip Technology Inc.
 *
 * Software License Agreement
 *
 * Copyright (c) 2014, Microchip Technology Inc. and its subsidiaries ("Microchip")
 * All rights reserved.
 *
 * This software is developed by Microchip Technology Inc. and its
 * subsidiaries ("Microchip").
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1.      Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * 2.      Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * Publication is not required when this file is used in an embedded 
 * application.
 *
 * 3.      Microchip's name may not be used to endorse or promote products
 * derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY MICROCHIP "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * MICROCHIP BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWSOEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ********************************************************************/

/*
 *		カーネル対応のスタートアップモジュール（PIC32MX用）
 */

#define	TOPPERS_MACRO_ONLY
#include "kernel_impl.h"

#include "xc.h"
#include <cp0defs.h>

#if (__XC32_VERSION > 1000) && !defined(CPP_INIT)
#define CPP_INIT
#endif

#if !defined(PIC32_SRS_SET_COUNT)
#  if defined(__PIC32_SRS_SET_COUNT)
#    define PIC32_SRS_SET_COUNT __PIC32_SRS_SET_COUNT
#  else
#    warning PIC32_SRS_SET_COUNT not defined on build line
#    define PIC32_SRS_SET_COUNT 2
#  endif
#endif

#if defined(__PIC32MX) || defined(__PIC32MM) || defined(__PIC32MZ)
#define INIT_DATA 1
#endif

/* This file contains 32-bit assembly code */
	.set nomips16

	##################################################################
	# Entry point of the entire application
	##################################################################
	.section .reset,code,keep
	.align 2
	.set noreorder
//	.ent _reset
	.ent start

############################
# Begin ISA switching code #
############################

#if defined (__mips_micromips)
	.set micromips
#endif

//_reset:
start:
	jal _startup
	nop

	.align 2
//	.end _reset
//	.globl _reset
//	.size _start, .-_reset
	.end start
	.globl start
	.size start, .-start

	.section .reset.startup,code,keep
	.align 2
	.set noreorder

#if defined (__mips_micromips)
	.set micromips
#else
	.set nomicromips
#endif

############################
# End ISA switching code   #
############################

	##################################################################
	# Startup code
	##################################################################
	.align 2
	.globl _startup
	.set noreorder
	.ent _startup
_startup:
	##################################################################
	# If entered because of an NMI, jump to the NMI handler.
	##################################################################
	mfc0	k0, _CP0_STATUS
	ext		k0, k0, 19, 1			# Extract NMI bit
	beqz	k0, _no_nmi
	nop
	la		k0, _nmi_handler
	jr		k0
	nop
_no_nmi:

	##################################################################
	# Initialize Stack Pointer
	#   _stack is initialized by the linker script to point to the
	#    starting location of the stack in DRM
	##################################################################
//	la		sp, _stack
	lw		sp, _kernel_istkpt

	##################################################################
	# Initialize Global Pointer
	#   _gp is initialized by the linker script to point to "middle"
	#   of the small variables region
	##################################################################
	la		gp, _gp

	##################################################################
	# Call the "on reset" procedure
	##################################################################
	la		t0, _on_reset
	jalr	t0
	nop

	##################################################################
	# Clear uninitialized data sections
	##################################################################
_start_bss_init:
	la		t0, _bss_begin
	la		t1, _bss_end
	b		_bss_check
	nop

_bss_init:
	sw		zero, 0x0(t0)
	addu	t0, 4
_bss_check:
	bltu	t0, t1, _bss_init
	nop

#if defined(INIT_DATA) || defined(__PIC32_HAS_INIT_DATA)

	#####################################################################
	# Initialize data using the linker-generated .dinit table
	# XC32 v2.10 and later provide the data-init code in a separate file
	# packaged with the compiler rather than the DFP. Use that init
	# code instead.
	#####################################################################
	.extern __pic32_data_init
	la		t0, __pic32_data_init
	jalr	t0
	nop

#endif /* INIT_DATA */

	##################################################################
	# If there are no RAM functions, skip the next section --
	# initializing bus matrix registers.
	##################################################################
	la		t1, _ramfunc_begin
	beqz	t1, _ramfunc_done
	nop

#if defined(INIT_SSX) || defined(__PIC32_HAS_SSX)
  /* No initialization required */
#else /* Use BMX */
	##################################################################
	# Initialize bus matrix registers if RAM functions exist in the
	# application
	##################################################################
	la		t1, _bmxdkpba_address
	la		t2, BMXDKPBA
	sw		t1, 0(t2)
	la		t1, _bmxdudba_address
	la		t2, BMXDUDBA
	sw		t1, 0(t2)
	la		t1, _bmxdupba_address
	la		t2, BMXDUPBA
	sw		t1, 0(t2)
#endif /* INIT_SSX */

_ramfunc_done:

	##################################################################
	# Initialize CP0 registers
	##################################################################
	# Initialize Count register
	##################################################################
	mtc0	zero, _CP0_COUNT

	##################################################################
	# Initialize Compare register
	##################################################################
	li		t2, -1
	mtc0	t2, _CP0_COMPARE

	##################################################################
	# Ensure BEV set and Initialize EBase register
	##################################################################
	li		t0, (1<<22)
	mfc0	t2, _CP0_STATUS
	or		t2, t0, t2				# Set BEV bit 22
	mtc0	t2, _CP0_STATUS

	la		t1, _ebase_address
	ehb
	mtc0	t1, _CP0_EBASE

	##################################################################
	# Initialize IntCtl/INTCON.VS register with _vector_spacing
	##################################################################
	la		t1, _vector_spacing
	li		t2, 0					# Clear t2 and
	ins		t2, t1, 5, 5			# shift value to VS field
	mtc0	t2, _CP0_INTCTL

	##################################################################
	# Initialize CAUSE registers
	# - Enable counting of Count register <DC = 0>
	# - Use special exception vector <IV = 1>
	# - Clear pending software interrupts <IP1:IP0 = 0>
	##################################################################
	li		t1, 0x00800000
	mtc0	t1, _CP0_CAUSE

	##################################################################
	# Initialize STATUS register
	# - Access to Coprocessor 0 not allowed in user mode <CU0 = 0>
	# - User mode uses configured endianness <RE = 0>
	# - Preserve Bootstrap Exception vectors <BEV>
	# - Preserve soft reset <SR> and non-maskable interrupt <NMI>
	# - CorExtend enabled based on whether CorExtend User Defined
	#   Instructions have been implemented <CEE = Config<UDI>>
	# - Disable any pending interrupts <IM7..IM2 = 0, IM1..IM0 = 0>
	# - Disable hardware interrupts <IPL7:IPL2 = 0>
	# - Base mode is Kernel mode <UM = 0>
	# - Error level is normal <ERL = 0>
	# - Exception level is normal <EXL = 0>
	# - Interrupts are disabled <IE = 0>
	# - DSPr2 ASE is enabled for devices that support it <MX = 1>
	# - FPU64 is enabled for devices that support it <CU1=1> & <FR=1>
	##################################################################
	mfc0	t0, _CP0_CONFIG
	ext		t1, t0, 22, 1			# Extract UDI from Config register
	sll		t1, t1, 17				# Move UDI to Status.CEE location
	mfc0	t0, _CP0_STATUS
	and		t0, t0, 0x00580000		# Preserve SR, NMI, and BEV

	or		t0, t1, t0				# Include Status.CEE (from UDI)
	mtc0	t0, _CP0_STATUS

	ehb

	##################################################################
	# Call the "on bootstrap" procedure
	##################################################################
	la		t0, _on_bootstrap
	jalr	t0
	nop

	##################################################################
	# Initialize Status<BEV> for normal exception vectors
	##################################################################
	mfc0	t0, _CP0_STATUS
	and		t0, t0, 0xffbfffff		# Clear BEV
	mtc0	t0, _CP0_STATUS

	##################################################################
	# Call main. We do this via a thunk in the text section so that
	# a normal jump and link can be used, enabling the startup code
	# to work properly whether main is written in MIPS16 or MIPS32
	# code. I.e., the linker will correctly adjust the JAL to JALX if
	# necessary
	##################################################################
	and		a0, a0, 0
	and		a1, a1, 0
	la		t0, _main_entry
	jr		t0
	nop

	.end _startup

	##################################################################
	# Boot Exception Vector Handler
	# Jumps to _bootstrap_exception_handler
	##################################################################
	.section .bev_handler,code,keep
	.align 2
	.set noreorder
	.ent _bev_exception
_bev_exception:
	la		k0, _bootstrap_exception_handler
	jr		k0
	nop

	.end _bev_exception

	##################################################################
	# General Exception Vector Handler
	# Jumps to _general_exception_context
	##################################################################
	.section .gen_handler,code
	.align 2
	.set noreorder
	.ent _gen_exception
_gen_exception:
0:	la		k0, _general_exception_context
	jr		k0
	nop

	.end _gen_exception

	.section .text.main_entry,code,keep
	.align 2
	.ent _main_entry
_main_entry:

#if defined(CPP_INIT)
	.weak _init
	# call .init section to run constructors etc
	lui		a0, %hi(_init)
	addiu	sp, sp, -24
	addiu	a0, a0, %lo(_init)
	beq		a0, $0, 2f
	sw		$31, 20(sp)	 #,
	jalr	a0
	nop
2:
#endif
	and		a0, a0, 0
	and		a1, a1, 0

	##################################################################

	# Call main
	##################################################################
	la		t0, sta_ker
	jalr	t0
	nop

#if defined(CALL_EXIT)
	##################################################################
	# Call exit()
	##################################################################
	jal		exit
	nop
#endif

	##################################################################
	# Just in case, go into infinite loop
	# Call a software breakpoint only with -mdebugger compiler option
	##################################################################
	.weak __exception_handler_break
__crt0_exit:
1:
	la		v0, __exception_handler_break
	beq		v0, 0, 0f
	nop
	jalr	v0
	nop

0:	b		1b
	nop

	.globl __crt0_exit
	.end _main_entry
