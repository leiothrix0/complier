%{
#include <stdio.h>
#include <string.h>
#include "common.h"
#define YYSTYPE ASTNode
ASTNode ast;
ASTNode newNode(char*, int, int, ...);
char* ToStr(char*);
extern bool errorStatus;
int yylex();
void yyerror(char*);
extern int yylineno;
%}

%locations 
%token TYPE STRUCT RETURN IF WHILE
%token ID INT FLOAT
%token SEMI COMMA 
%token LC RC
%start Program

%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT UMINUS
%left  DOT LB RB LP RP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%%
Program: ExtDefList	{ 
		$$ = newNode(str(Program), (@$).first_line, 1, $1);
		ast = $$;
		if (errorStatus == 10) errorStatus = 0;
	}
	;
ExtDefList: { $$ = NULL; } 
	| ExtDef ExtDefList { $$ = newNode(str(ExtDefList), (@$).first_line, 2, $1, $2); }
	;
ExtDef: Specifier ExtDecList SEMI {	$$ = newNode(str(ExtDef), (@$).first_line, 3, $1, $2, $3); }
	| Specifier SEMI { $$ = newNode(str(ExtDef), (@$).first_line, 2, $1, $2); }
	| Specifier FunDec CompSt { $$ = newNode(str(ExtDef), (@$).first_line, 3, $1, $2, $3); }
	| error SEMI { errorStatus = 2; }
	;
ExtDecList: VarDec { $$ = newNode(str(ExtDecList), (@$).first_line, 1, $1); }
	| VarDec COMMA ExtDecList { $$ = newNode(str(ExtDecList), (@$).first_line, 3, $1, $2, $3); }
	;


Specifier: TYPE { $$ = newNode(str(Specifier), (@$).first_line, 1, $1); }
	| StructSpecifier { $$ = newNode(str(Specifier), (@$).first_line, 1, $1); }
	;
StructSpecifier: STRUCT OptTag LC DefList RC { $$ = newNode(str(StructSpecifier), (@$).first_line, 5, $1, $2, $3, $4, $5); }
	| STRUCT Tag { $$ = newNode(str(StructSpecifier), (@$).first_line, 2, $1, $2); }
	| error RC { errorStatus = 2; } 
	;
OptTag: { $$ = NULL; }
	| ID { $$ = newNode(str(OptTag), (@$).first_line, 1, $1); }
	;
Tag: ID { $$ = newNode(str(Tag), (@$).first_line, 1, $1); }


VarDec: ID { $$ = newNode(str(VarDec), (@$).first_line, 1, $1); }
	| VarDec LB INT RB { $$ = newNode(str(VarDec), (@$).first_line, 4, $1, $2, $3, $4); }
	| error RB { errorStatus = 2; }
	;
FunDec: ID LP VarList RP { $$ = newNode(str(FunDec), (@$).first_line, 4, $1, $2, $3, $4); }
	| ID LP RP { $$ = newNode(str(FunDec), (@$).first_line, 3, $1, $2, $3); }
	| error RP { errorStatus = 2; }
	;
VarList: ParamDec COMMA VarList { $$ = newNode(str(VarList), (@$).first_line, 3, $1, $2, $3); }
	| ParamDec { $$ = newNode(str(VarList), (@$).first_line, 1, $1); }
	;
ParamDec: Specifier VarDec { $$ = newNode(str(ParamDec), (@$).first_line, 2, $1, $2); };


CompSt: LC DefList StmtList RC { $$ = newNode(str(CompSt), (@$).first_line, 4, $1, $2, $3, $4); }
	| error RC { errorStatus = 2; }
	;
StmtList: { $$ = NULL; }
	| Stmt StmtList { $$ = newNode(str(StmtList), (@$).first_line, 2, $1, $2); }
	;
Stmt: Exp SEMI { $$ = newNode(str(Stmt), (@$).first_line, 2, $1, $2); }
	| CompSt { $$ = newNode(str(Stmt), (@$).first_line, 1, $1); }
	| RETURN Exp SEMI { $$ = newNode(str(Stmt), (@$).first_line, 3, $1, $2, $3); }
	| IF LP Exp RP Stmt %prec LOWER_THAN_ELSE { $$ = newNode(str(Stmt), (@$).first_line, 5, $1, $2, $3, $4, $5); }
	| IF LP Exp RP Stmt ELSE Stmt { $$ = newNode(str(Stmt), (@$).first_line,  7, $1, $2, $3, $4, $5, $6, $7); }
	| WHILE LP Exp RP Stmt { $$ = newNode(str(Stmt), (@$).first_line, 5, $1, $2, $3, $4, $5); }
	| error SEMI { errorStatus = 2; }
	;


DefList: { $$ = NULL; }
	| Def DefList { $$ = newNode(str(DefList), (@$).first_line, 2, $1, $2); }
	;
Def: Specifier DecList SEMI { $$ = newNode(str(Def), (@$).first_line, 3, $1, $2, $3); }
	| error SEMI { errorStatus = 2; }
	;
DecList: Dec { $$ = newNode(str(DecList), (@$).first_line, 1, $1); }
	| Dec COMMA DecList { $$ = newNode(str(DecList), (@$).first_line, 3, $1, $2, $3); }
	;
Dec: VarDec { $$ = newNode(str(Dec), (@$).first_line, 1, $1); }
	| VarDec ASSIGNOP Exp { $$ = newNode(str(Dec), (@$).first_line, 3, $1, $2, $3); }
	;


Exp: Exp ASSIGNOP Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp AND Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp OR Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp RELOP Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp PLUS Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp MINUS Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp STAR Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp DIV Exp { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| LP Exp RP { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| MINUS Exp %prec UMINUS { $$ = newNode(str(Exp), (@$).first_line, 2, $1, $2); }
	| NOT Exp { $$ = newNode(str(Exp), (@$).first_line, 2, $1, $2); }
	| ID LP Args RP { $$ = newNode(str(Exp), (@$).first_line, 4, $1, $2, $3, $4); }
	| ID LP RP { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| Exp LB Exp RB { $$ = newNode(str(Exp), (@$).first_line, 4, $1, $2, $3, $4); }
	| Exp DOT ID { $$ = newNode(str(Exp), (@$).first_line, 3, $1, $2, $3); }
	| ID { $$ = newNode(str(Exp), (@$).first_line, 1, $1); }
	| INT { $$ = newNode(str(Exp), (@$).first_line, 1, $1); }
	| FLOAT { $$ = newNode(str(Exp), (@$).first_line, 1, $1); }
	| error RP { errorStatus = 2; }
	;
Args: Exp COMMA Args { $$ = newNode(str(Args), (@$).first_line, 3, $1, $2, $3); }
	| Exp { $$ = newNode(str(Args), (@$).first_line, 1, $1); }
	;

%%
void yyerror(char *msg) {
	printf("Error type 2 at Line %d: %s.\n", yylineno, msg);
}
