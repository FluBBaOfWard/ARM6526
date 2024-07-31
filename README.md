# ARM6526 V0.2.1
A MOS 6526/6526A/8521 "CIA" (Complex Interface Adapter) chip emulator for ARM32.

First you need to allocate space for the chip core state, either by using the struct from C or allocating/reserving memory using the "m6526Size"
Next call m6526Init with a pointer to that memory.
