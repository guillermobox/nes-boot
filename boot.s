PPUCONTROL = $2000
PPUMASK    = $2001
PPUSTATUS  = $2002
PPUADDR    = $2006
PPUDATA    = $2007

frame = $00
pages = $01

.segment "CODE"
nmi:
	bit PPUSTATUS
	bpl nmi

	; vblank starts here
	inc frame

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

    ; Other things you can do between vblank waits are set up audio
    ; or set up other mapper registers.

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

.segment "VECTORS"
	.addr nmi
	.addr reset
	.addr nmi
