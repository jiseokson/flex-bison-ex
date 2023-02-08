%option noyywrap

%{
#include <string.h>

int lines = 0;
int words = 0;
int chars = 0;
%}

%%
\n              {++chars; ++lines;}
[^ \t\n\r\f\v]+ {++words; chars += strlen(yytext);}
.               {++chars;}
%%

int main(int argc, char **argv)
{
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    yylex();
    printf("%8d %8d %8d", lines, words, chars);
    if (argc > 1)
        printf(" %s", argv[1]);
    putchar('\n');
}
