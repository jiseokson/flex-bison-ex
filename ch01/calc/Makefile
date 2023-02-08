all: lexergen.l parsergen.y
	@bison -d parsergen.y
	@flex lexergen.l
	@gcc -lfl *.c -o calc

clean:
	@rm -rf calc