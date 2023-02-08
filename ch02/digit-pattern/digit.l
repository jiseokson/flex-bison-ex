%{
#include <stdio.h>
%}

%%
[-\+]?([0-9]*\.?[0-9]+|[0-9]+\.)([eE](-|\+)?[0-9]+)?    {printf("%s: ok", yytext);}
.+                                                      {printf("bad input");}
%%
