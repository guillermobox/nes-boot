.segment "CODE"
; this code will be run on reset and irq
	LDA #$42

.segment "VECTORS"
	.byte $00,$80 ; this is nmi
	.byte $00,$80 ; this is reset
	.byte $00,$80 ; this is irq
