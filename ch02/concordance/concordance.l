%option noyywrap nodefault yylineno case-insensitive

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NHASH 9997

typedef struct symbol_t {
    char *name;
    struct ref_t *reflist;
} symbol_t;

typedef struct ref_t {
    struct ret_t *next;
    char *file_name;
    int flags;
    int lineno;
} ref_t;

struct symbol_t symbol_table[NHASH];
char *cur_file_name;

symbol_t *lookup(char *);
void add_ref(char *, int, char *, int);
%}

%%
a |
an |
and |
are |
as |
at |
be |
but |
for |
in |
is |
it |
of |
on |
or |
that |
the |
this |
to

[a-z]+(\'[st])? { add_ref(cur_file_name, yylineno, yytext, 0); }
.|\n
%%

int main(int argc, char **argv)
{
    if (argc == 1) {
        cur_file_name = "(stdin)";
        yylineno = 1;
        yylex();
    } else {
        for (int i = 1; i < argc; ++i) {
            FILE *file = fopen(argv[i], "r");
            if (!file) {
                perror(argv[i]);
                return 1;
            }
            cur_file_name = argv[i];
            yyrestart(file);
            yylineno = 1;
            yylex();
            fclose(file);
        }
    }
    print_refs();
    return 0;
}

static unsigned int symbol_hash(char *symbol)
{
    unsigned int hash, c;
    while (c = *symbol++) hash = hash * 9 ^ c;
    return hash;
}

symbol_t *lookup(char *symbol)
{
    symbol_t *symbol_p = &symbol_table[symbol_hash(symbol) % NHASH];
    int count = NHASH;

    while (count--) {
        if (!symbol_p->name) {
            symbol_p->name = strdup(symbol);
            symbol_p->reflist = NULL;
            return symbol_p;
        }
        if (!strcmp(symbol_p->name, symbol))
            return symbol_p;
        if (++symbol_p >= symbol_table + NHASH)
            symbol_p = symbol_table;
    }
    fprintf(stderr, "symbol table overflow\n");
    yyterminate();
}

void add_ref(char *file_name, int lineno, char *symbol, int flags)
{
    symbol_t *symbol_p = lookup(symbol);
    if (symbol_p->reflist
        && symbol_p->reflist->lineno == lineno
        && symbol_p->reflist->file_name == file_name) return;

    ref_t *new_ref = (ref_t *)malloc(sizeof(ref_t));
    if (!new_ref) {
        perror("malloc()");
        yyterminate();
    }
    new_ref->next = symbol_p->reflist;
    new_ref->file_name = file_name;
    new_ref->lineno = lineno;
    new_ref->flags = flags;
    symbol_p->reflist = new_ref;
}

static int symbol_compare(const void *xa, const void *xb)
{
    const symbol_t *a = (const symbol_t *)xa;
    const symbol_t *b = (const symbol_t *)xb;

    if (!a->name) {
        if (!b->name) return 0;
        return 1;
    }
    if (!b->name)
        return -1;
    return strcmp(a->name, b->name);
}

void print_refs(void)
{
    qsort(symbol_table, NHASH, sizeof(symbol_t), symbol_compare);
    for (
    symbol_t *symbol_p = symbol_table;
    symbol_p->name && symbol_p < symbol_table + NHASH;
    ++symbol_p) {
        char *prev_file_name = NULL;
        ref_t *cur = symbol_p->reflist;
        ref_t *prev = NULL;
        ref_t *next;

        while (cur) {
            next = cur->next;
            cur->next = prev;
            prev = cur;
            cur = next;
        }

        printf("%s\n", symbol_p->name);
        for (ref_t *i = prev; i; i = i->next) {
            if (i->file_name == prev_file_name) {
                printf(" %d", i->lineno);
            } else {
                printf("    %s: %d", i->file_name, i->lineno);
                prev_file_name = i->file_name;
            }
        }
        putchar('\n');
    }
}
