%{
#include <stdio.h>
%}

%token NUMBER
%token ADD SUB MUL DIV ABS
%token EOL

%%
calclist:
    | calclist expression EOL {printf("%d\n", $2);}
    ;

expression: factor
    | expression ADD factor {$$ = $1 + $3;}
    | expression SUB factor {$$ = $1 - $3;}
    ;

factor: term
    | factor MUL term {$$ = $1 * $3;}
    | factor DIV term {$$ = $1 / $3;}
    ;

term: NUMBER
    | ABS term {$$ = $2 >= 0 ? $2 : -$2;}
    ;
%%

int main(int argc, char **argv)
{
    yyparse();
}

int yyerror(char *s)
{
    fprintf(stderr, "error: %s\n", s);
}
