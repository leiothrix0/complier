#ifndef _COMMON_H_
#define _COMMON_H_
#include "util.h"

typedef struct astnode {
    union {
        int ival;
        float fval;
        char *IDname;
    };
    List son;
    bool IsToken;
    char  *name;
    int lineno;
} *ASTNode;

void printAST(ASTNode, int);
ASTNode newNode(char*, int, int, ...);

#endif
