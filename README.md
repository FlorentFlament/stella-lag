# Code to illustrate lag between image and sound on the Stella emulator

* Compile `main.bin` with `make`
* Run the code with `stella main.bin` or `make run`

The code changes the background color at the same time it changes the
audio. When the screen is white, the TIA plays white noise; when the
screen is black, no sound should be heard.

Here's the relevant code:

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

When running `main.bin` in Stella 6.3 (stella 6.0.2 as well), I can
experience a lag between the picture and the sound (Rough estimate
about 50-100 ms). When running the same binary on the real hardware I
don't see/hear any lag.

As I don't notice any lag when playing a video on my machine, I don't
think my OS (Linux Ubuntu 20.04) introduces it. It feels like it comes
from the Stella emulator (Even though I selected "Ultra Quality,
minimal lag", in the Audio Mode options).
