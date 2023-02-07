all: wc-lex.l
	@flex wc-lex.l
	@gcc -lfl lex.yy.c -o mywc

clean:
	@rm -rf lex.yy.c mywc
