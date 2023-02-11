%option noyywrap
%x IFILE

%{
#include <stdio.h>
#include <stdlib.h>

typedef struct buffer_stack_t {
    struct buffer_stack_t   *prev;
    YY_BUFFER_STATE         buffer_state;
    FILE                    *file;
    char                    *file_name;
    int                     lineno;
} buffer_stack_t;

buffer_stack_t  *top;
%}

%%
^[ \t]*#[ \t]*include[ \t]*<    { BEGIN IFILE; }

<IFILE>[^>]+   {
                    {
                        int c;
                        while ((c = input()) && c != '\n');
                    }
                    if (!push_file(yytext))
                        yyterminate();
                    BEGIN INITIAL;
                }

<IFILE>.    {
                fprintf(stderr, "bad include at line %d\n", top->lineno);
                yyterminate();
            }

<<EOF>> { if (!pop_file()) yyterminate(); }

^.  { fprintf(yyout, "%8s: %3d: %s", top->file_name, top->lineno, yytext); } 
^\n { fprintf(yyout, "%8s: %3d: %s", top->file_name, top->lineno++, yytext); }
.   { ECHO; }
\n  { ECHO; ++top->lineno;}
%%

int push_file(char *file_name);
int pop_file(void);

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: nic file_name\n");
        return 1;
    }
    if (!push_file(argv[1]))
        return 1;
    yylex();
    return 0;
}

int push_file(char *file_name)
{
    buffer_stack_t *new_buffer_stack = (buffer_stack_t *)malloc(sizeof(buffer_stack_t));
    if (!new_buffer_stack) {
        perror("malloc()");
        return 0;
    }
    FILE *file = fopen(file_name, "r");
    if (!file) {
        perror(file_name);
        return 0;
    }
    new_buffer_stack->prev = top;
    new_buffer_stack->buffer_state = yy_create_buffer(file, YY_BUF_SIZE);
    new_buffer_stack->file = file;
    new_buffer_stack->file_name = file_name;
    new_buffer_stack->lineno = 1;
    top = new_buffer_stack;
    yy_switch_to_buffer(top->buffer_state);
    return 1;
}

int pop_file(void)
{
    if (!top)
        return 0;
    buffer_stack_t *temp = top;
    top = top->prev;
    free(temp);
    if (top == NULL)
        return 0;
    yy_switch_to_buffer(top->buffer_state);
    return 1;
}