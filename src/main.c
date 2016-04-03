#include <stdio.h>
#include <string.h>
#include "common.h"
#include "util.h"
#define DEBUG
int yyparse();
extern ASTNode ast;
int yyrestart(FILE*);
extern int errorStatus;
void printAST(ASTNode, int);
int main(int argc, char *argv[]) {
    if (argc < 1) return 1;
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror(argv[1]);
        return 1;
    }
    yyrestart(f);
    yyparse();
    if (errorStatus == 0) printAST(ast, 0);
    return 0;
}
