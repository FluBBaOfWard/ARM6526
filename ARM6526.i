//
//  ARM6526.i
//  MOS 6526 "CIA" chip emulator for ARM32.
//
//  Created by Fredrik Ahlström on 2006-12-01.
//  Copyright © 2006-2024 Fredrik Ahlström. All rights reserved.
//

#if !__ASSEMBLER__
	#error This header file is only for use in assembly files!
#endif

				;@ r0,r1,r2=temp regs
	addy		.req r12		;@ Keep this at r12 (scratch for APCS)

	.struct 0					;@ Changes section so make sure it is set before real code.
m6526Start:
m6526StateStart:
ciaDataPortA:	.byte 0			;@ 0x0 Data Port A
ciaDataPortB:	.byte 0			;@ 0x1 Data Port B
ciaDataDirA:	.byte 0			;@ 0x2 Data Direction Port A
ciaDataDirB:	.byte 0			;@ 0x3 Data Direction Port B
ciaTimerA:						;@ Timer A Latch
ciaTimerAL:		.byte 0			;@ 0x4 Timer A Low
ciaTimerAH:		.byte 0			;@ 0x5 Timer A High
ciaTimerB:						;@ Timer B Latch
ciaTimerBL:		.byte 0			;@ 0x6 Timer B Low
ciaTimerBH:		.byte 0			;@ 0x7 Timer B High
ciaTOD:
ciaTOD0:		.byte 0			;@ 0x8 Time of Day, tenth of Seconds
ciaTOD1:		.byte 0			;@ 0x9 Time of Day, Seconds
ciaTOD2:		.byte 0			;@ 0xA Time of Day, Minutes
ciaTOD3:		.byte 0			;@ 0xB Time of Day, Hours
ciaSIOPort:		.byte 0			;@ 0xC Serial IO Port
ciaIrqCtrl:		.byte 0			;@ 0xD Interrrupt Control & Status
ciaCtrlTA:		.byte 0			;@ 0xE Control Timer A
ciaCtrlTB:		.byte 0			;@ 0xF Control Timer B

ciaTimerACount:	.long 0			;@ The Live counter of Timer A
ciaTimerBCount:	.long 0			;@ The Live counter of Timer B

ciaTodFrame:	.byte 0x00
ciaTodSecond:	.byte 0x00
ciaTodMinute:	.byte 0x00
ciaTodHour:		.byte 0x00
ciaTodAFrame:	.byte 0x00
ciaTodASecond:	.byte 0x00
ciaTodAMinute:	.byte 0x00
ciaTodAHour:	.byte 0x00
ciaTodRunning:	.byte 0x00
ciaIrq:			.byte 0			;@ Interrrupt Pins
ciaPadding0:	.byte 0,0
m6526StateEnd:

ciaPortAReadFunc:	.long 0
ciaPortBReadFunc:	.long 0
ciaPortAWriteFunc:	.long 0
ciaPortBWriteFunc:	.long 0
ciaIrqFunc:			.long 0

m6526End:

m6526Size = m6526End-m6526Start
m6526StateSize = m6526StateEnd-m6526StateStart

;@----------------------------------------------------------------------------
