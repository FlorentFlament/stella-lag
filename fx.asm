fx_init SUBROUTINE
        lda #$08
        sta AUDC0
        lda #$04
        sta AUDF0
	rts

fx_vblank SUBROUTINE
        lda framecnt
        and #$20
        bne .white
.black:
        lda #$00
        jmp .color_chosen
.white:
        lda #$ff
.color_chosen:        
        sta COLUBK
        sta AUDV0
	rts

fx_kernel SUBROUTINE
	rts

fx_overscan SUBROUTINE
	inc framecnt		; Increment frame counter
	rts
