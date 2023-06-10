#ifdef __arm__

#include "ARM6526.i"

	.global m6526Init
	.global m6526Reset

	.global m6526RunXCycles
	.global m6526CountFrames

	.syntax unified
	.arm

	.section .text
	.align 2
;@----------------------------------------------------------------------------
m6526Init:					;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	adr r1,dummyFunc
	str r1,[r0,#ciaPortAFunc]
	str r1,[r0,#ciaPortBFunc]
	str r1,[r0,#ciaIrqFunc]
;@----------------------------------------------------------------------------
m6526Reset:					;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	stmfd sp!,{lr}

	mov r1,#0
	mov r2,#m6526StateSize/4	;@ 36/4=9
	bl memset_					;@ Clear variables

	ldmfd sp!,{lr}
dummyFunc:
	bx lr

;@----------------------------------------------------------------------------
m6526Read:					;@ r2 = CIA chip, r12 = adr.
;@----------------------------------------------------------------------------
	and r1,r12,#0xF
	ldr pc,[pc,r1,lsl#2]
;@---------------------------
	.long 0
// ciaReadTbl
	.long ciaPortA_R			;@ 0x0
	.long ciaPortB_R			;@ 0x1
	.long ciaRegisterR			;@ 0x2
	.long ciaRegisterR			;@ 0x3
	.long ciaTimerA_L_R			;@ 0x4
	.long ciaTimerA_H_R			;@ 0x5
	.long ciaTimerB_L_R			;@ 0x6
	.long ciaTimerB_H_R			;@ 0x7
	.long ciaTOD_F_R			;@ 0x8
	.long ciaTOD_S_R			;@ 0x9
	.long ciaTOD_M_R			;@ 0xA
	.long ciaTOD_H_R			;@ 0xB
	.long ciaRegisterR			;@ 0xC
	.long ciaIRQCtrlR			;@ 0xD
	.long ciaRegisterR			;@ 0xE
	.long ciaRegisterR			;@ 0xF
ciaRegisterR:
	ldrb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
m6526Write:					;@ r0 = value, r2 = CIA chip, r12 = adr.
;@----------------------------------------------------------------------------
	and r1,r12,#0xF
	ldr pc,[pc,r1,lsl#2]
;@---------------------------
	.long 0
// ciaWriteTbl
	.long ciaPortA_W			;@ 0x0
	.long ciaPortB_W			;@ 0x1
	.long ciaRegisterW			;@ 0x2
	.long ciaRegisterW			;@ 0x3
	.long ciaRegisterW			;@ 0x4
	.long ciaTimerA_H_W			;@ 0x5
	.long ciaRegisterW			;@ 0x6
	.long ciaTimerB_H_W			;@ 0x7
	.long ciaTOD_F_W			;@ 0x8
	.long ciaTOD_S_W			;@ 0x9
	.long ciaTOD_M_W			;@ 0xA
	.long ciaTOD_H_W			;@ 0xB
	.long ciaRegisterW			;@ 0xC
	.long ciaIRQCtrlW			;@ 0xD
	.long ciaCtrlA_W			;@ 0xE
	.long ciaCtrlB_W			;@ 0xF
ciaRegisterW:
	strb r0,[r2,r1]
	bx lr
;@----------------------------------------------------------------------------
ciaPortA_W:					;@ 0x0
;@----------------------------------------------------------------------------
	strb r0,[r2,r1]
	ldr pc,[r0,#ciaPortAFunc]
	b SetC64GfxBases
;@----------------------------------------------------------------------------
ciaPortB_W:					;@ 0x1
;@----------------------------------------------------------------------------
	strb r0,[r2,r1]
	ldr pc,[r0,#ciaPortBFunc]
;@----------------------------------------------------------------------------
ciaTimerA_H_W:				;@ 0x5
;@----------------------------------------------------------------------------
	strb r0,[r10,#ciaTimerAH]
	ldr r1,[r10,#ciaTimerACount]
	tst r1,#0x80000000
	bmi ciaReloadTA
	bx lr
;@----------------------------------------------------------------------------
ciaTimerB_H_W:				;@ 0x7
;@----------------------------------------------------------------------------
	strb r0,[r10,#ciaTimerBH]
	ldr r1,[r10,#ciaTimerBCount]
	tst r1,#0x80000000
	bmi ciaReloadTB
	bx lr
;@----------------------------------------------------------------------------
ciaTOD_F_W:				;@ 0x8
;@----------------------------------------------------------------------------
	mov r0,r0,lsl#4
	strb r0,[r2,#0]				;@ Frame
	mov r0,#1
	strb r0,[r2,#8]				;@ Running
	bx lr
;@----------------------------------------------------------------------------
ciaTOD_H_W:					;@ 0xB
;@----------------------------------------------------------------------------
	strb r0,[r2,#3]				;@ Hour
	mov r0,#0
	strb r0,[r2,#8]				;@ Running
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
//	b ciaIRQCheck
	bx lr
;@----------------------------------------------------------------------------
ciaCtrlA_W:					;@ 0xE
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaCtrlTA]

//	tst r0,#0x01				;@ Timer enable?
//	ldreqb r1,[r2,#ciaIrq]
//	biceq r1,r1,#0x01
//	streqb r1,[r2,#ciaIrq]

	tst r0,#0x10				;@ Force load?
	bxeq lr
ciaReloadTA:
	ldrb r0,[r2,#ciaTimerAL]
	ldrb r1,[r2,#ciaTimerAH]
	orr r0,r0,r1,lsl#8
	str r0,[r2,#ciaTimerACount]
	bx lr
;@----------------------------------------------------------------------------
ciaCtrlB_W:					;@ 0xF
;@----------------------------------------------------------------------------
	strb r0,[r2,#ciaCtrlTB]

	tst r0,#0x10				;@ Force load?
	bxeq lr
ciaReloadTB:
	ldrb r0,[r2,#ciaTimerBL]
	ldrb r1,[r2,#ciaTimerBH]
	orr r0,r0,r1,lsl#8
	str r0,[r2,#ciaTimerBCount]
	bx lr

;@----------------------------------------------------------------------------
ciaPortA_R:					;@ 0x0 Data Port A
;@----------------------------------------------------------------------------
	ldr r0,=joy0state
	ldrb r0,[r0]
//	ldrb r0,[r2,#ciaDataDirA]
	eor r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
ciaPortB_R:					;@ 0x1 Data Port B
;@----------------------------------------------------------------------------
	ldrb r2,[r2,#ciaDataPortA]
	eor r2,r2,#0xFF
	ldr r12,=Keyboard_M
	mov r0,#0xFF
ciaPortBLoop:
	movs r2,r2,lsr#1
	ldrbcs r1,[r12]
	andcs r0,r0,r1
	add r12,r12,#1
	bne ciaPortBLoop
	ldr r1,=joy0state
	ldrb r1,[r1]
	eor r1,r1,#0xFF
	and r0,r0,r1

	bx lr
;@----------------------------------------------------------------------------
ciaTimerA_L_R:				;@ 0x4
;@----------------------------------------------------------------------------
	ldrb r0,[r2,#ciaTimerACount]
	bx lr
;@----------------------------------------------------------------------------
ciaTimerA_H_R:				;@ 0x5
;@----------------------------------------------------------------------------
	ldr r0,[r2,#ciaTimerACount]
	mov r0,r0,lsr#8
	and r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
ciaTimerB_L_R:				;@ 0x6
;@----------------------------------------------------------------------------
	ldrb r0,[r2,#ciaTimerBCount]
	bx lr
;@----------------------------------------------------------------------------
ciaTimerB_H_R:				;@ 0x7
;@----------------------------------------------------------------------------
	ldr r0,[r2,#ciaTimerBCount]
	mov r0,r0,lsr#8
	and r0,r0,#0xFF
	bx lr
;@----------------------------------------------------------------------------
ciaIRQCtrlR:				;@ 0xD
;@----------------------------------------------------------------------------
	ldrb r0,[r2,#ciaIrqCtrl]
	ldrb r1,[r2,#ciaIrq]
	ands r0,r0,r1
	orrne r0,r0,#0x80
	mov r1,#0
	strb r1,[r10,#ciaIrq]
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
	bhi countSeconds

	bx lr
;@----------------------------------------------------------------------------
countSeconds:				;@ r0 = CIA chip.
;@----------------------------------------------------------------------------
	ldrb r1,[r0,#ciaTodSecond]	;@ Second
	add r1,r1,#1
	and r2,r1,#0xF
	cmp r2,#9
	andhi r1,r1,#0xF0
	addhi r1,r1,#0x10
	cmp r1,#0x59
	movhi r1,#0
	strb r1,[r0,#ciaTodSecond]	;@ Second
	bhi countMinutes

	bx lr
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
	bhi countHours

	bx lr
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
	bichi r1,r1,#0x32
	eorhi r1,r1,#0x80
	strb r1,[r0,#ciaTodHour]	;@ Hour

	bx lr
;@----------------------------------------------------------------------------
	.end
#endif // #ifdef __arm__
