%option noyywrap nodefault yylineno

%{
#include "symbol.h"

symbol_t *symbol_table[NHASH];
char *cur_file_name;
int colno;
%}

%%
[a-zA-Z]+(\'[st])? { add_ref(yytext, yylineno, colno + 1, cur_file_name); colno += strlen(yytext);}
. { ++colno; }
\n { colno = 0; }
%%

int main(int argc, char **argv)
{
    if (argc == 1) {
        cur_file_name = "(stdin)";
        yylex();
    } else {
        for (int i = 1; i < argc; ++i) {
            cur_file_name = argv[i];
            FILE *file = fopen(cur_file_name, "r");
            if (!file) {
                perror(cur_file_name);
                return 1;
            }
            yyrestart(file);
            yylineno = 1;
            colno = 0;
            yylex();
        }
    }
    print_symbols();
    return 0;
}
