%{
#include "common.h"
#include <string.h>
#define YYSTYPE ASTNode
#include "syntax.tab.h"
#define handle(token) \
do { \
	yylval = newToken();\
	yylval->name = ToStr(str(token));\
	return token;\
} while(0)
#define YY_USER_ACTION\
	yylloc.first_line = yylloc.last_line = yylineno; \
	yylloc.first_column = yycolumn; \
	yylloc.last_column = yycolumn + yyleng - 1; \
	yycolumn += yyleng;
ASTNode newToken() {
	ASTNode new0; NEW0(new0);
	new0->IsToken = TRUE;
	new0->lineno = yylloc.first_line;
	return new0;
}
int yycolumn = 1;
int errorStatus = 10;
%}

%option yylineno

SI      [Ee][-+]?[0-9]+
L 		[A-Za-z_]
%%

struct     { handle(STRUCT); }
return     { handle(RETURN); }
if         { handle(IF); }
else       { handle(ELSE); }
while      { handle(WHILE); }

int |
float      { 
	yylval = newToken();
	yylval->IDname = ToStr(yytext);
	yylval->name = "TYPE";
	return TYPE;
}
0 |
[1-9][0-9]* {
	yylval = newToken();
    yylval->ival = atoi(yytext);
	yylval->name = "INT";
    return INT;
}
0[0-7]+ {
	yylval = newToken();
    yylval->ival = strtol(yytext, NULL, 8);
	yylval->name = "INT";
    return INT;
}
0[Xx][0-9a-fA-F]+ {
	yylval = newToken();
    yylval->ival = strtol(yytext, NULL, 16);
	yylval->name = "INT";
    return INT;
}
[0-9]+{SI} |
[0-9]+\.[0-9]*{SI}? |
\.[0-9]+{SI}? {
	yylval = newToken();
    yylval->fval = atof(yytext);
	yylval->name = "FLOAT";
    return FLOAT;
}

{L}({L}|[0-9])* {
	yylval = newToken();
    yylval->IDname = ToStr(yytext);
	yylval->name = "ID";
    return ID;
}
                

";"     { handle(SEMI); }
","     { handle(COMMA); }
"="     { handle(ASSIGNOP); }
">"  |
"<"  |
">=" |
"<=" |
"==" |
"!="  	{ handle(RELOP); }
"+"     { handle(PLUS); }
"-"     { handle(MINUS); }
"*"     { handle(STAR); }
"/"     { handle(DIV); }
"&&"	{ handle(AND); }
"||" 	{ handle(OR); }
"."		{ handle(DOT); }
"!"		{ handle(NOT); }
"("		{ handle(LP); }
")"		{ handle(RP); }
"["		{ handle(LB); }
"]" 	{ handle(RB); }
"{"		{ handle(LC); }
"}"		{ handle(RC); }
 /*need more !!!*/
"//"[^\n]* 
"/*" {
	char cur = ' ', next = input();
	while (cur != '*' || next != '/') {
		cur = next;
		next = input();
		if (next < 0) break;
	}
}
[\t ] 
\n		{ yycolumn = 1; }
. { 
	printf("Error type 1 at Line %d: Mysterious character \"%s\".\n", yylineno, yytext);
	errorStatus = 1;
}

%%
