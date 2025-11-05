%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include "tiny.tab.h"   

int line = 1;
int column = 1;

void print_error(const char* msg, const char* token) {
    printf("Error at line %d, column %d: %s \"%s\"\n", line, column, msg, token);
}
%}

digit       [0-9]
number      {digit}+
identifier  [A-Za-z0-9_]{1,8}

%%

"--".*                  {}

[ \t\r]+                { column += yyleng; }
\n                      { line++; column = 1; }


program                 { column += yyleng; return PROGRAM; }
beginprogram            { column += yyleng; return BEGIN_PROGRAM; }
endprogram              { column += yyleng; return END_PROGRAM; }
integer                 { column += yyleng; return INTEGER; }
array                   { column += yyleng; return ARRAY; }
of                      { column += yyleng; return OF; }
if                      { column += yyleng; return IF; }
then                    { column += yyleng; return THEN; }
endif                   { column += yyleng; return ENDIF; }
else                    { column += yyleng; return ELSE; }
while                   { column += yyleng; return WHILE; }
loop                    { column += yyleng; return LOOP; }
endloop                 { column += yyleng; return ENDLOOP; }
read                    { column += yyleng; return READ; }
write                   { column += yyleng; return WRITE; }
and                     { column += yyleng; return AND; }
or                      { column += yyleng; return OR; }
not                     { column += yyleng; return NOT; }
true                    { column += yyleng; return TRUE; }
false                   { column += yyleng; return FALSE; }

/* Operators and punctuation */
":="                    { column += yyleng; return ASSIGN; }
"<>"                    { column += yyleng; return NEQ; }
"<="                    { column += yyleng; return LTE; }
">="                    { column += yyleng; return GTE; }
"<"                     { column += yyleng; return LT; }
">"                     { column += yyleng; return GT; }
"="                     { column += yyleng; return EQ; }
"+"                     { column += yyleng; return ADD; }
"-"                     { column += yyleng; return SUB; }
"*"                     { column += yyleng; return MULT; }
"/"                     { column += yyleng; return DIV; }
";"                     { column += yyleng; return SEMICOLON; }
":"                     { column += yyleng; return COLON; }
","                     { column += yyleng; return COMMA; }
"("                     { column += yyleng; return L_PAREN; }
")"                     { column += yyleng; return R_PAREN; }


{number} {
    yylval.ival = atoi(yytext);
    column += yyleng;
    return NUMBER;
}

{identifier} {
    if (yytext[0] == '_' || isdigit(yytext[0])) {
        print_error("identifier must begin with a letter", yytext);
        exit(1);
    } else if (yytext[yyleng-1] == '_') {
        print_error("identifier cannot end with an underscore", yytext);
        exit(1);
    } else {
        yylval.sval = strdup(yytext);
        column += yyleng;
        return IDENT;
    }
}


. {
    print_error("unrecognized symbol", yytext);
    exit(1);
}
%%

int yywrap(void) { return 1; }
