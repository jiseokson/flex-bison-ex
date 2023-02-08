%option noyywrap

%{
#include <stdio.h>

int lc = 0;
int wc = 0;
int cc = 0;
%}

%%
\n              {++cc; ++lc;}
[^ \t\n\r\f\v]+ {++wc; cc += strlen(yytext);}
.               {++cc;}
%%

int main(int argc, char **argv)
{
    if (argc == 1) {
        yylex();
        printf("%8d %8d %8d\n", lc, wc, cc);
        return 0;
    }

    int tlc = 0;
    int twc = 0;
    int tcc = 0;
    for (int i = 1; i < argc; ++i) {
        FILE *file = fopen(argv[i], "r");
        if (!file) {
            perror(argv[i]);
            return 1;
        }
        yyrestart(file);
        yylex();
        fclose(file);
        printf("%8d %8d %8d %s\n", lc, wc, cc, argv[i]);
        tlc += lc; lc = 0;
        twc += wc; wc = 0;
        tcc += cc; cc = 0;
    }
    if (argc > 2)
        printf("%8d %8d %8d total\n", tlc, twc, tcc);
    return 0;
}
