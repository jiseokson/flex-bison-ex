%{
#include <stdio.h>
#include <stdlib.h>
#include "parsergen.tab.h"
%}

%%
"+"     {return ADD;}
"-"     {return SUB;}
"*"     {return MUL;}
"/"     {return DIV;}
"|"     {return ABS;}
"("     {return OPAREN;}
")"     {return CPAREN;}
[0-9]+  {yylval = atoi(yytext); return NUMBER;}
\n      {return EOL;}
[ \t]   {}
"//".*  {}
.       {printf("type: none, value: %s\n", yytext);}
%%
