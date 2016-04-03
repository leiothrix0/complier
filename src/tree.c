#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "common.h"
ASTNode
newNode(char *name, int lineno, int num, ...) {
    ASTNode new0;
    NEW0(new0);
    new0->IsToken = FALSE;
    new0->name = ToStr(name);
    new0->lineno = lineno;
    va_list valist;
    va_start(valist, num);
    int i;
    new0->son = newList();
    for (i = 0; i < num; ++i) {
        ASTNode p = va_arg(valist, ASTNode);
        if (p != NULL) addLast(new0->son, p);
    }
    va_end(valist);

    return new0;
}
    
void printAST(ASTNode root, int k) {
    printf("%*s%s", k*2, "", root->name);
    if (root->IsToken) {
        if (strcmp(root->name, "INT") == 0) {
            printf(": %d", root->ival);
        } else if (strcmp(root->name, "FLOAT") == 0) {
            printf(": %f", root->fval);
        } else if (strcmp(root->name, "ID") == 0 || strcmp(root->name, "TYPE") == 0) {
            printf(": %s", root->IDname);
        }
    } else printf(" (%d)", root->lineno);
    puts("");
    if (root->son != NULL) {
        ListItr itr = newListItr(root->son, 0);
        while (hasNext(itr)) {
            ASTNode p = (ASTNode) nextItem(itr);
            if (p != NULL) printAST(p, k + 1);
        }
    }
}
