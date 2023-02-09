%option noyywrap
%x IFILE

%{
#include <stdio.h>
#include <stdlib.h>

struct buf_stack {
    struct bufstack *prev;
    YY_BUFFER_STATE buf_state;
    int lineno;
    char *file_name;
    FILE *f;
};

struct buf_stack *cur_buf_stack;

char *cur_file_name;

int new_file(char *file_name);
int pop_file(void);
%}

%%
^#[ \t]*include[ \t]*<  { BEGIN IFILE; }

<IFILE>[^>]+            {
                            {
                                // read all characters after file name
                                int c;
                                while (c = input() && c != '\n');
                            }
                            ++yylineno;
                            printf("file name: \'%s\'\n", yytext); // for debug
                            if (!new_file(yytext))
                                yyterminate();
                            BEGIN INITIAL;
                        }

<IFILE>.|\n             {
                            fprintf(stderr, "%4d: bad include line\n", yylineno);
                            yyterminate();
                        }

<<EOF>>                 { if (!pop_file()) yyterminate(); }

^.  { fprintf(yyout, "%4d %s", yylineno, yytext); }
^\n { fprintf(yyout, "%4d %s", yylineno++, yytext); }
.   { ECHO; }
\n  { ECHO; ++yylineno; }
%%

int main(int argc, char **argv)
{
    if (argc < 2) {
        fprintf(stderr, "need filename\n");
        return 1;
    }
    if (new_file(argv[1]))
        yylex();
}

int new_file(char *file_name)
{
    FILE *f = fopen(file_name, "r");
    struct buf_stack *new_buf_stack = (struct buf_stack *)malloc(sizeof(struct buf_stack));

    if (!f) {
        perror(file_name);
        return 0;
    }
    if (!new_buf_stack) {
        perror("malloc()");
        return 0;
    }

    if (cur_buf_stack)
        cur_buf_stack->lineno = yylineno;
    new_buf_stack->prev = cur_buf_stack;
    new_buf_stack->buf_state = yy_create_buffer(f, YY_BUF_SIZE);
    new_buf_stack->f = f;
    new_buf_stack->file_name = file_name;
    cur_buf_stack = new_buf_stack;
    yy_switch_to_buffer(cur_buf_stack->buf_state);
    yylineno = 1;
    cur_file_name = file_name;
    return 1;
}

int pop_file(void)
{
    struct buf_stack *prev_buf_stack = cur_buf_stack->prev;
    if (!cur_buf_stack)
        return 0;
    fclose(cur_buf_stack->f);
    yy_delete_buffer(cur_buf_stack->buf_state);
    free(cur_buf_stack);
    if (!prev_buf_stack)
        return 0;
    cur_buf_stack = prev_buf_stack;
    yy_switch_to_buffer(cur_buf_stack->buf_state);
    yylineno = cur_buf_stack->lineno;
    cur_file_name = cur_buf_stack->file_name;
    return 1;
}
