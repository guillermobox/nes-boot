APU_WA1 = $4000
APU_WA2 = $4004
APU_TRI = $4008
APU_NOI = $400C
APU_STATUS = $4015
APU_FRAME  = $4017
PPUCONTROL = $2000
PPUMASK    = $2001
PPUSTATUS  = $2002
PPUADDR    = $2006
PPUDATA    = $2007

INPUT_1 = $4016
INPUT_2 = $4017

frame = $00
pages = $01
input = $03

.segment "CODE"
nmi:
	bit PPUSTATUS
	bpl nmi

	; vblank starts here
	inc frame
	lda #$00
	sta input

	; latch input
	lda #$01
	sta INPUT_1
	; de-latch input
	lda #$00
	sta INPUT_1

	ldx #$08
next_input:
	lda INPUT_1
	lsr a
	rol input
	dex
	bne next_input

; controled read

; show controler byte
	lda #$22
	sta PPUADDR
	lda #$2c
	sta PPUADDR
	lda input
	lsr
	lsr
	lsr
	lsr
	sta PPUDATA
	lda input
	and #$0F
	sta PPUDATA

	lda #$0e
	sta PPUMASK

	lda #$21
	sta PPUADDR
	lda #$2c
	sta PPUADDR

	ldx #$00
nextletter:
	lda msg,x
	beq textdone
	sec
	sbc #$41
	clc
	adc #$0A
	CMP #$e9
	bne printletter
	lda #$24
printletter:
	sta PPUDATA
	inx
	jmp nextletter
textdone:

	lda #$20
	sta PPUADDR
	lda #$00
	sta PPUADDR
	brk

reset:
	; reset cpu state to a well known state
	sei        ; ignore IRQs
	cld        ; disable decimal mode
	ldx #$ff
	txs        ; Set up stack
	inx        ; now X = 0
	stx $2000  ; disable NMI
	stx $2001  ; disable rendering
	stx $4010  ; disable DMC IRQs

    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that @vblankwait1
    ; does not exit immediately.
	bit PPUSTATUS

@vblankwait1:
	bit PPUSTATUS
	bpl @vblankwait1

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS.  Conveniently, X is still 0.
	txa
@clrmem:
	sta $000,x
	sta $100,x
	sta $200,x
	sta $300,x
	sta $400,x
	sta $500,x
	sta $600,x
	sta $700,x
	inx
	bne @clrmem

init_apu:
        ; Init $4000-4013
	ldy #$13
@loop:  lda audioregs,y
	sta $4000,y
	dey
	bpl @loop

	; We have to skip over $4014 (OAMDMA)
	lda #$0f
	sta $4015
	lda #$40
	sta $4017

	; beep
	lda #<179
	sta $4002
	lda #>179
	and #$07
	ora #%10100000
	sta $4003
	lda #%10011111
	sta $4000


@vblankwait2:
	bit PPUSTATUS
	bpl @vblankwait2

	lda #$02
	sta pages

	lda #$20
	sta PPUADDR
secondpage:
	lda #$00
	sta PPUADDR

	; clear nametable
	ldy #$1e
row:
	dey
	ldx #$20
back:
	dex
	lda #$24
	sta PPUDATA
	txa
	bne back
	tya
	bne row

	lda #$28
	sta PPUADDR
	dec pages
	bne secondpage
	lda #$00
	sta PPUADDR

	; clear attribute table
	lda #$23
	sta PPUADDR
	lda #$c0
	sta PPUADDR

	ldx #$40
wback:
	dex
	lda #$00
	sta PPUDATA
	txa
	bne wback

	; set palette
	lda #$3f
	sta PPUADDR
	lda #$00
	sta PPUADDR
	lda #$21 ; background color
	sta PPUDATA
	lda #$30 ; font color
	sta PPUDATA

	lda #$20
	sta PPUADDR
	lda #$00
	sta PPUADDR
	brk

msg:       .asciiz "nintendo"
audioregs:
        .byte $30,$08,$00,$00
        .byte $30,$08,$00,$00
        .byte $80,$00,$00,$00
        .byte $30,$00,$00,$00
        .byte $00,$00,$00,$00

.segment "VECTORS"
	.addr nmi
	.addr reset
	.addr nmi
