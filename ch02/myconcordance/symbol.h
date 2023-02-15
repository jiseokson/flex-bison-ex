#ifndef SYMBOL_H
#define SYMBOL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NHASH 9997

typedef struct ref_t {
    struct ref_t *next;
    int lineno;
    int colno;
    char *file_name;
} ref_t;

typedef struct symbol_t {
    struct symbol_t *next;
    char *name;
    struct ref_t *ref_list;
} symbol_t;

extern symbol_t *symbol_table[NHASH];
extern char *cur_file_name;
extern int yylineno, colno;

unsigned int symbol_hash(char *name);
symbol_t *new_symbol(char *name);
symbol_t *lookup_symbol(char *name);

void add_ref(char *name, int lineno, int colno, char *file_name);

void print_symbols(void);
void print_refs(ref_t *ref_list);

#endif
