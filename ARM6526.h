//
//  ARM6526.h
//  MOS 6526 "CIA" chip emulator for ARM32.
//
//  Created by Fredrik Ahlström on 2006-12-01.
//  Copyright © 2006-2024 Fredrik Ahlström. All rights reserved.
//

#ifndef ARM6526_HEADER
#define ARM6526_HEADER

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	/// 0x0 Data Port A
	u8 dataPortA;
	/// 0x1 Data Port B
	u8 dataPortB;
	/// 0x2 Data Direction Port A
	u8 dataDirA;
	/// 0x3 Data Direction Port B
	u8 dataDirB;
	/// 0x4 Timer A Low
	u8 timerAL;
	/// 0x5 Timer A High
	u8 timerAH;
	/// 0x6 Timer B Low
	u8 timerBL;
	/// 0x7 Timer B High
	u8 timerBH;
//ciaTOD:
	/// 0x8 Time of Day, tenth of Seconds
	u8 tod0;
	/// 0x9 Time of Day, Seconds
	u8 tod1;
	/// 0xA Time of Day, Minutes
	u8 tod2;
	/// 0xB Time of Day, Hours
	u8 tod3;
	/// 0xC Serial IO Port
	u8 sIOPort;
	/// 0xD Interrrupt Control & Status
	u8 irqCtrl;
	/// 0xE Control Timer A
	u8 ctrlTA;
	/// 0xF Control Timer B
	u8 ctrlTB;

	/// The Live counter of Timer A
	u32 timerACount;
	/// The Live counter of Timer B
	u32 timerBCount;

	/// The Live counter of TOD Frame
	u8 todFrame;
	/// The Live counter of TOD Second
	u8 todSecond;
	/// The Live counter of TOD Minute
	u8 todMinute;
	/// The Live counter of TOD Hours
	u8 todHour;
	/// The TOD Alarm Frame
	u8 todAFrame;
	/// The TOD Alarm Second
	u8 todASecond;
	/// The TOD Alarm Minute
	u8 todAMinute;
	/// The TOD Alarm Hour
	u8 todAHour;
	/// The TOD running
	u8 todRunning;
	u8 ciaPadding0[3];
// m6526StateEnd

	/// The function to call when reading Data Port A
	u8 (*portAReadFunc)(void);
	/// The function to call when reading Data Port B
	u8 (*portBReadFunc)(void);
	/// The function to call when writing Data Port A
	void (*portAWriteFunc)(u8);
	/// The function to call when writing Data Port B
	void (*portBWriteFunc)(u8);
	/// The function to call when IRQ happens
	void (*irqFunc)(bool);
} M6526;


/**
 * Initializes the port and irq functions and calls reset.
 * @param  *chip: The M6526 chip to initialize.
 */
void m6526Init(const M6526 *chip);

/**
 * Initializes the state of the chip
 * @param  *chip: The M6526 chip to reset.
 */
void m6526Reset(const M6526 *chip);

/**
 * Saves the state of the M6526 chip to the destination.
 * @param  *destination: Where to save the state.
 * @param  *chip: The M6526 chip to save.
 * @return The size of the state.
 */
int m6526SaveState(void *destination, const M6526 *chip);

/**
 * Loads the state of the M6526 chip from the source.
 * @param  *chip: The M6526 chip to load a state into.
 * @param  *source: Where to load the state from.
 * @return The size of the state.
 */
int m6526LoadState(M6526 *chip, const void *source);

/**
 * Gets the state size of a M6526.
 * @return The size of the state.
 */
int m6526GetStateSize(void);

#ifdef __cplusplus
} // extern "C"
#endif

#endif // ARM6526_HEADER
