boot.nes: prg.bin chr.bin assemble
	./assemble -p prg.bin -c chr.bin -o boot.nes

prg.bin:
	truncate -s 32768 prg.bin

chr.bin:
	truncate -s 16384 chr.bin
