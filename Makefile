.PHONY: clean all

all: boot.nes

clean:
	rm -f prg.bin *.nes *.o assemble

boot.nes: prg.bin chr.bin assemble
	./assemble -p prg.bin -c chr.bin -o boot.nes

prg.bin: boot.s boot.cfg
	cl65 --config boot.cfg boot.s -o prg.bin
