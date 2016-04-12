;-------------------------------------------------------------------------
; Resets interrupts back to OS expected values
;-------------------------------------------------------------------------
; Interrupts
pIntStatus	.equ	5000h
mpIntStatus	.equ	0F00000h
pIntMask	.equ	5004h
mpIntMask	.equ	0F00004h
pIntAck		.equ	5008h
mpIntAck	.equ	0F00008h
pIntLachEnable	.equ	500Ch
mpIntLachEnable	.equ	0F0000Ch
pIntXor		.equ	5010h
mpIntXor	.equ	0F00010h
pIntStatusMasked	.equ	5014h
mpIntStatusMasked	.equ	0F00014h

intOnKey	.equ	1
intOnKeyB	.equ	0
intTimer1	.equ	2
intTimer1B	.equ	1
intTimer2	.equ	4
intTimer2B	.equ	2
intTimer3	.equ	8
intTimer3B	.equ	3
intOsTimer	.equ	10h
intOsTimerB	.equ	4
intKbd		.equ	400h
intKbdB		.equ	10
intLcd		.equ	800h
intLcdB		.equ	11
intRtc		.equ	1000h
intRtcB		.equ	12

	.assume adl=1

;------ ResetInterrupts --------------------------------------------------------
_int_reset:
	ld	hl,_ir
	ld	de,0F00004h
	ld	bc,16
	ldir
	ret
_ir:	dw	1 | 10h | 1000h | 2000h, 0
	dw	0FFFFh, 0FFFFh
	dw	1 | 8 | 10h, 0
	dw	0, 0

	end