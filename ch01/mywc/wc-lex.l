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

int main(int ac, char **av)
{
    yylex();
    printf("%8d%8d%8d\n", lines, words, chars);
    return 0;
}
