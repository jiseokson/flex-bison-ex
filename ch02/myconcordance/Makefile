all: concordance.l symbol.c symbol.h
	@flex concordance.l
	@gcc *.c -o conc

clean:
	@rm -f conc
