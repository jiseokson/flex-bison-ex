#include "symbol.h"

unsigned int symbol_hash(char *name)
{
    unsigned int hash = 0, c;
    while (c = *name++)
        hash = hash * 9 ^ c;
    return hash % NHASH;
}

symbol_t *new_symbol(char *name)
{
    symbol_t *symbol = (symbol_t *)malloc(sizeof(symbol_t));
    if (!symbol) {
        perror("malloc()");
        exit(1);
    }
    symbol->next = NULL;
    symbol->name = strdup(name);
    symbol->ref_list = NULL;
    return symbol;
}

symbol_t *lookup_symbol(char *name)
{
    unsigned int hash = symbol_hash(name);
    symbol_t *symbol = symbol_table[hash];
    if (!symbol) {
        return symbol_table[hash] = new_symbol(name);
    } else {
        symbol_t *prev;
        while (symbol) {
            if (!strcmp(symbol->name, name))
                return symbol;
            prev = symbol;
            symbol = symbol->next;
        }
        prev->next = new_symbol(name);
        return prev->next;
    }
}

void add_ref(char *name, int lineno, int colno, char *file_name)
{
    symbol_t *symbol = lookup_symbol(name);
    ref_t *new_ref = (ref_t *)malloc(sizeof(ref_t));
    if (!new_ref) {
        perror("malloc()");
        exit(1);
    }
    new_ref->next = symbol->ref_list;
    new_ref->file_name = cur_file_name;
    new_ref->lineno = yylineno;
    new_ref->colno = colno;
    symbol->ref_list = new_ref;
}

void print_refs(ref_t *ref_list)
{
    ref_t *cur = ref_list;
    ref_t *prev = NULL, *next = NULL;
    while (cur) {
        next = cur->next;
        cur->next = prev;
        prev = cur;
        cur = next;
    }
    for (ref_t *ref = prev; ref; ref = ref->next) {
        printf("    %s:%d:%d\n", ref->file_name, ref->lineno, ref->colno);
    }
}

void print_symbols(void)
{
    for (symbol_t **symbol = symbol_table;
    symbol < symbol_table + NHASH;
    ++symbol) {
        if (!symbol) continue;
        while (*symbol) {
            printf("%s\n", (*symbol)->name);
            print_refs((*symbol)->ref_list);
            *symbol = (*symbol)->next;
        }
    }
}
