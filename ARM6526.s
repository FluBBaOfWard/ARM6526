//
//  ARM6526.s
//  MOS 6526 "CIA" chip emulator for ARM32.
//
//  Created by Fredrik Ahlström on 2006-12-01.
//  Copyright © 2006-2023 Fredrik Ahlström. All rights reserved.
//

#ifdef __arm__

#include "ARM6526.i"

	.global m6526Init
	.global m6526Reset
	.global m6526RunXCycles
	.global m6526CountFrames
	.global m6526Read
	.global m6526Write

	.syntax unified
	.arm

#ifdef GBA
	.section .ewram, "ax", %progbits	;@ For the GBA
#else
	.section .text						;@ For anything else
#endif
	.align 2

;@----------------------------------------------------------------------------
m6526Init:					;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	adr r1,dummyFunc
	str r1,[r0,#ciaPortAReadFunc]
	str r1,[r0,#ciaPortBReadFunc]
	str r1,[r0,#ciaPortAWriteFunc]
	str r1,[r0,#ciaPortBWriteFunc]
	str r1,[r0,#ciaIrqFunc]
;@----------------------------------------------------------------------------
m6526Reset:					;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	mov r1,#0
	mov r2,#m6526StateSize/4	;@ 36/4=9
	bl memset_					;@ Clear variables

	mov r1,#0x01				;@ TimerA enabled?
	strb r1,[r0,#ciaIrqCtrl]
	strb r1,[r0,#ciaTodRunning]	;@ Running?

	mov r1,#-1
	str r1,[r0,#ciaTimerACount]
	str r1,[r0,#ciaTimerBCount]

	ldmfd sp!,{lr}
	bx lr
dummyFunc:
	mov r0,#0xFF
	bx lr

;@----------------------------------------------------------------------------
memCopy:
;@----------------------------------------------------------------------------
	ldr r3,=memcpy
;@----------------------------------------------------------------------------
thumbCallR3:
;@----------------------------------------------------------------------------
	bx r3
;@----------------------------------------------------------------------------
m6526SaveState:		;@ In r0=destination, r1=CIA chip. Out r0=state size.
	.type m6526SaveState STT_FUNC
;@----------------------------------------------------------------------------
	add r1,r1,#m6526StateStart
	mov r2,#m6526StateSize
	stmfd sp!,{r2,lr}
	bl memCopy

	ldmfd sp!,{r0,lr}
	bx lr
;@----------------------------------------------------------------------------
m6526LoadState:		;@ In r0=CIA chip, r1=source. Out r0=state size.
	.type m6526LoadState STT_FUNC
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	add r0,r0,#m6526StateStart
	mov r2,#m6526StateSize
	bl memCopy

	ldmfd sp!,{lr}
;@----------------------------------------------------------------------------
m6526GetStateSize:	;@ Out r0=state size.
	.type m6526GetStateSize STT_FUNC
;@----------------------------------------------------------------------------
	mov r0,#m6526StateSize
	bx lr

;@----------------------------------------------------------------------------
m6526Read:					;@ r2 = CIA chip, r12 = adr.
;@----------------------------------------------------------------------------
	and r1,addy,#0xF
	ldr pc,[pc,r1,lsl#2]
;@---------------------------
	.long 0
// ciaReadTbl
	.long ciaPortA_R			;@ 0x0
	.long ciaPortB_R			;@ 0x1
	.long ciaRegisterR			;@ 0x2 Data Direction A
	.long ciaRegisterR			;@ 0x3 Data Direction B
	.long ciaTimerA_L_R			;@ 0x4
	.long ciaTimerA_H_R			;@ 0x5
	.long ciaTimerB_L_R			;@ 0x6
	.long ciaTimerB_H_R			;@ 0x7
	.long ciaTOD_F_R			;@ 0x8
	.long ciaRegisterR			;@ 0x9 TOD Seconds
	.long ciaRegisterR			;@ 0xA TOD Minutes
	.long ciaTOD_H_R			;@ 0xB
	.long ciaRegisterR			;@ 0xC Serial IO
	.long ciaIRQCtrlR			;@ 0xD
	.long ciaRegisterR			;@ 0xE Ctrl Timer A
	.long ciaRegisterR			;@ 0xF Ctrl Timer B
ciaRegisterR:
	ldrb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
ciaPortA_R:					;@ 0x0 Data Port A Read
;@----------------------------------------------------------------------------
	ldr pc,[r2,#ciaPortAReadFunc]
;@----------------------------------------------------------------------------
ciaPortB_R:					;@ 0x1 Data Port B Read
;@----------------------------------------------------------------------------
	ldr pc,[r2,#ciaPortBReadFunc]
;@----------------------------------------------------------------------------
ciaTimerA_L_R:				;@ 0x4 Timer A Low Read
;@----------------------------------------------------------------------------
	ldrb r0,[r2,#ciaTimerACount]
	bx lr
;@----------------------------------------------------------------------------
ciaTimerA_H_R:				;@ 0x5
;@----------------------------------------------------------------------------
	ldrb r0,[r2,#ciaTimerACount+1]
	bx lr
;@----------------------------------------------------------------------------
ciaTimerB_L_R:				;@ 0x6
;@----------------------------------------------------------------------------
	ldrb r0,[r2,#ciaTimerBCount]
	bx lr
;@----------------------------------------------------------------------------
ciaTimerB_H_R:				;@ 0x7
;@----------------------------------------------------------------------------
	ldrb r0,[r2,#ciaTimerBCount+1]
	bx lr
;@----------------------------------------------------------------------------
ciaTOD_F_R:					;@ 0x8
;@----------------------------------------------------------------------------
	mov r0,#1
	strb r0,[r2,#ciaTodRunning]	;@ Running
	ldrb r0,[r2,#ciaTodFrame]	;@ Frame
	mov r0,r0,lsr#4
	bx lr
;@----------------------------------------------------------------------------
ciaTOD_H_R:					;@ 0xB
;@----------------------------------------------------------------------------
	mov r0,#0
	strb r0,[r2,#ciaTodRunning]	;@ Not Running
	ldrb r0,[r2,#ciaTodHour]	;@ Hour
	bx lr
;@----------------------------------------------------------------------------
ciaIRQCtrlR:				;@ 0xD
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}
	mov r0,#0
	mov lr,pc
	ldr pc,[r2,#ciaIrqFunc]		;@ Clear IRQ pin
	ldmfd sp!,{lr}

	ldrb r0,[r2,#ciaIrq]
	ldrb r1,[r2,#ciaIrqCtrl]
	ands r1,r1,r0
	orrne r0,r0,#0x80
	mov r1,#0
	strb r1,[r2,#ciaIrq]
	bx lr

;@----------------------------------------------------------------------------
m6526Write:					;@ r0 = value, r2 = CIA chip, r12 = adr.
;@----------------------------------------------------------------------------
	and r1,addy,#0xF
	ldr pc,[pc,r1,lsl#2]
	.long 0
// ciaWriteTbl
	.long ciaPortA_W			;@ 0x0
	.long ciaPortB_W			;@ 0x1
	.long ciaRegisterW			;@ 0x2 Data Direction A
	.long ciaRegisterW			;@ 0x3 Data Direction B
	.long ciaRegisterW			;@ 0x4 Timer A Low
	.long ciaTimerA_H_W			;@ 0x5
	.long ciaRegisterW			;@ 0x6 Timer B Low
	.long ciaTimerB_H_W			;@ 0x7
	.long ciaTOD_F_W			;@ 0x8
	.long ciaRegisterW			;@ 0x9 TOD Seconds
	.long ciaRegisterW			;@ 0xA TOD Minutes
	.long ciaTOD_H_W			;@ 0xB
	.long ciaRegisterW			;@ 0xC Serial IO
	.long ciaIRQCtrlW			;@ 0xD
	.long ciaCtrlTA_W			;@ 0xE
	.long ciaCtrlTB_W			;@ 0xF
ciaRegisterW:
	strb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
ciaPortA_W:					;@ 0x0
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaDataPortA]
	ldr pc,[r2,#ciaPortAWriteFunc]
;@----------------------------------------------------------------------------
ciaPortB_W:					;@ 0x1
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaDataPortB]
	ldr pc,[r2,#ciaPortBWriteFunc]
;@----------------------------------------------------------------------------
ciaTimerA_H_W:				;@ 0x5
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaTimerAH]
	ldr r1,[r2,#ciaTimerACount]
	tst r1,#0x80000000
	bmi ciaReloadTA
	bx lr
;@----------------------------------------------------------------------------
ciaTimerB_H_W:				;@ 0x7
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaTimerBH]
	ldr r1,[r2,#ciaTimerBCount]
	tst r1,#0x80000000
	bmi ciaReloadTB
	bx lr
;@----------------------------------------------------------------------------
ciaTOD_F_W:					;@ 0x8
;@----------------------------------------------------------------------------
	mov r0,r0,lsl#4
	strb r0,[r2,#ciaTodFrame]	;@ Frame
	mov r0,#1
	strb r0,[r2,#ciaTodRunning]	;@ Running
	bx lr
;@----------------------------------------------------------------------------
ciaTOD_H_W:					;@ 0xB
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaTodHour]	;@ Hour
	mov r0,#0
	strb r0,[r2,#ciaTodRunning]	;@ Not Running
	bx lr
;@----------------------------------------------------------------------------
ciaIRQCtrlW:				;@ 0xD
;@----------------------------------------------------------------------------
	ldrb r1,[r2,#ciaIrqCtrl]
	tst r0,#0x80
	and r0,r0,#0x1F
	biceq r1,r1,r0
	orrne r1,r1,r0
	strb r1,[r2,#ciaIrqCtrl]

	ldrb r0,[r2,#ciaIrq]
	and r0,r0,r1
	ldr pc,[r2,#ciaIrqFunc]		;@ Update IRQ pin
;@----------------------------------------------------------------------------
ciaCtrlTA_W:				;@ 0xE
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaCtrlTA]

//	tst r0,#0x01				;@ Timer enable?
//	ldreqb r1,[r2,#ciaIrq]
//	biceq r1,r1,#0x01
//	streqb r1,[r2,#ciaIrq]

	tst r0,#0x10				;@ Force load?
	bxeq lr
ciaReloadTA:
	ldrh r0,[r2,#ciaTimerAL]
	str r0,[r2,#ciaTimerACount]
	bx lr
;@----------------------------------------------------------------------------
ciaCtrlTB_W:				;@ 0xF
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaCtrlTB]

	tst r0,#0x10				;@ Force load?
	bxeq lr
ciaReloadTB:
	ldrh r0,[r2,#ciaTimerBL]
	str r0,[r2,#ciaTimerBCount]
	bx lr

;@----------------------------------------------------------------------------
m6526CountFrames:			;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	ldrb r1,[r0,#ciaTodFrame]	;@ Frame
	add r1,r1,#1
	and r2,r1,#0xF
	cmp r2,#5					;@ 5 or 6 depending on bit 7 byte 0xE.
	andhi r1,r1,#0xF0
	addhi r1,r1,#0x10
	cmp r1,#0x9F
	movhi r1,#0
	strb r1,[r0,#ciaTodFrame]	;@ Frame

	bxls lr						;@ Continue if higher
;@----------------------------------------------------------------------------
countSeconds:				;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	ldrb r1,[r0,#ciaTodSecond]	;@ Second
	add r1,r1,#1
	and r2,r1,#0xF
	cmp r2,#0x9
	andhi r1,r1,#0xF0
	addhi r1,r1,#0x10
	cmp r1,#0x59
	movhi r1,#0
	strb r1,[r0,#ciaTodSecond]	;@ Second

	bxls lr						;@ Continue if higher
;@----------------------------------------------------------------------------
countMinutes:				;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	ldrb r1,[r0,#ciaTodMinute]	;@ Minute
	add r1,r1,#1
	and r2,r1,#0xF
	cmp r2,#9
	andhi r1,r1,#0xF0
	addhi r1,r1,#0x10
	cmp r1,#0x59
	movhi r1,#0
	strb r1,[r0,#ciaTodMinute]	;@ Minute

	bxls lr						;@ Continue if higher
;@----------------------------------------------------------------------------
countHours:					;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	ldrb r1,[r0,#ciaTodHour]	;@ Hour
	add r1,r1,#1
	and r2,r1,#0xF
	cmp r2,#9
	andhi r1,r1,#0xF0
	addhi r1,r1,#0x10
	and r2,r1,#0x3F
	cmp r2,#0x12
	bichi r1,r1,#0x3F
	eorhi r1,r1,#0x80
	strb r1,[r0,#ciaTodHour]	;@ Hour

	bx lr
;@----------------------------------------------------------------------------
m6526RunXCycles:			;@ r2 = CIA chip.
;@----------------------------------------------------------------------------
	mov r0,#0					;@ Timer underflow
	ldrb r1,[r2,#ciaCtrlTA]
	tst r1,#0x01				;@ Timer A active?
	beq doTimerB
//	tst r1,#0x20				;@ Count 02 clock or CNT signals?
//	bne doTimerB
	ldr r12,[r2,#ciaTimerACount]
	subs r12,r12,#63			;@ Cycles per scanline
	bcs noTimerA
	orr r0,r0,#1				;@ Set timer A underflow

	tst r1,#0x08				;@ Contigous/oneshoot?
	ldrheq r1,[r2,#ciaTimerAL]
	addeq r12,r12,r1
	movne r12,#-1
noTimerA:
	str r12,[r2,#ciaTimerACount]

doTimerB:
	ldrb r1,[r2,#ciaCtrlTB]
	tst r1,#0x01				;@ Timer B active?
	beq checkTimerIRQ
	tst r1,#0x60				;@ Count 02 clock or something else?
	bne checkTimerIRQ
	ldr r12,[r2,#ciaTimerBCount]
	subs r12,r12,#63			;@ Cycles per scanline
	bcs noTimerB
	orr r0,r0,#2				;@ Set timer B underflow

	tst r1,#0x08				;@ Contigous/oneshoot?
	ldrheq r1,[r2,#ciaTimerBL]
	addeq r12,r12,r1
	movne r12,#-1
noTimerB:
	str r12,[r2,#ciaTimerBCount]
checkTimerIRQ:
	cmp r0,#0
	bxeq lr

	ldrb r1,[r2,#ciaIrq]
	orr r0,r0,r1
	strb r0,[r2,#ciaIrq]
	ldrb r1,[r2,#ciaIrqCtrl]
	ands r0,r0,r1
	ldrne pc,[r2,#ciaIrqFunc]		;@ Set IRQ pin?
	bx lr
;@----------------------------------------------------------------------------

	.end
#endif // #ifdef __arm__
