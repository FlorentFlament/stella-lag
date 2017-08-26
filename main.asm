;;;-----------------------------------------------------------------------------
;;; Header

	PROCESSOR 6502
	INCLUDE "vcs.h"		; Provides RIOT & TIA memory map
	INCLUDE "macro.h"		; This file includes some helper macros


;;;-----------------------------------------------------------------------------
;;; RAM segment

	SEG.U ram
	ORG $0080
framecnt	DS.B	1
seed	DS.B	1
tmp	DS.B	1
buffer	DS.B	5


;;;-----------------------------------------------------------------------------
;;; Code segment

	SEG code
	ORG $F000
init	CLEAN_START		; Initializes Registers & Memory
	jsr fx_init

main_loop:
	VERTICAL_SYNC		; 4 scanlines Vertical Sync signal

	; 34 VBlank lines (76 cycles/line)
	lda #39			; (/ (* 34.0 76) 64) = 40.375
	sta TIM64T
	jsr fx_vblank
	jsr wait_timint

	; 248 Kernel lines
	lda #19			; (/ (* 248.0 76) 1024) = 18.40
	sta T1024T
	jsr fx_kernel		; scanline 33 - cycle 23
	jsr wait_timint		; scanline 289 - cycle 30

	; 26 Overscan lines
	lda #22			; (/ (* 26.0 76) 64) = 30.875
	sta TIM64T
	jsr fx_overscan
	jsr wait_timint

	jmp main_loop		; scanline 308 - cycle 15


; X register must contain the number of scanlines to skip
; X register will have value 0 on exit
wait_timint:
	lda TIMINT
	beq wait_timint
	rts

; A must contain the previous value of the xor_shift
; A contains the new xor_shift value on return
; Note: tmp is overwritten
xor_shift:
	sta tmp
	asl
	eor tmp
	sta tmp
	lsr
	eor tmp
	sta tmp
	asl
	asl
	eor tmp
	rts

; Uses first element of buffer as last xor_shift value
; Fills the buffer with new pseudo-random values
; Note: Uses X register
fill_buffer:
	ldx #5
	lda buffer
.next:
	jsr xor_shift
	sta buffer,X
	dex
	bpl .next
	rts

fx_init:
	lda #1
	sta seed
	rts

fx_vblank:
	lda seed
	sta buffer
	jsr fill_buffer
	rts

fx_kernel:
	ldy #31 ; stripes
.next_line:
	lda buffer
	sta WSYNC
	sta COLUBK
	lda buffer+1
	sta COLUPF
	lda buffer+2
	sta PF0
	lda buffer+3
	sta PF1
	lda buffer+4
	sta PF2
	jsr fill_buffer
	REPEAT 3
	sta WSYNC
	REPEND
	dey
	bne .next_line

	lda #0
	sta WSYNC
	sta COLUBK
	sta COLUPF
	rts

fx_overscan:
	inc framecnt		; Increment frame counter
	lda framecnt
	and #$0f
	bne .endos
	inc seed
.endos
	rts


;;;-----------------------------------------------------------------------------
;;; Reset Vector

	SEG reset
	ORG $FFFC
	DC.W init
	DC.W init
