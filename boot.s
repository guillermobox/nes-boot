PPUSTATUS=$2002

.segment "CODE"
; this code will be run on reset and irq
nmi:
	jmp $FE

	bit PPUSTATUS  ; clear the VBL flag if it was set at reset time
vwait1:
	bit PPUSTATUS
	bpl vwait1     ; at this point, about 27384 cycles have passed
vwait2:
	bit PPUSTATUS
	bpl vwait2     ; at this point, about 57165 cycles have passed



.segment "VECTORS"
	.byte $00,$80 ; this is nmi
	.byte $03,$80 ; this is reset
	.byte $00,$80 ; this is irq
