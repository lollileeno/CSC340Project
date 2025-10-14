%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>



int line = 1;
int column = 1;

void print_error(const char* msg, const char* token) {
    printf("Error at line %d, column %d: %s \"%s\"\n", line, column, msg, token);
}
%}

digit [0-9]
number {digit}+
identifier [a-zA-Z0-9_]{1,8}

%%

{number} { printf("NUMBER %s\n", yytext);
column += yyleng;
}
{identifier} { 

if(yytext[0] == '_'  || isdigit(yytext[0]) ){
    printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", line, column, yytext);
exit(1);}

else if (yytext[yyleng-1] == '_'){
printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", line, column, yytext);
exit(1);}

else
printf("IDENT %s\n", yytext);

column += yyleng;

}
. {  print_error("unrecognized symbol", yytext);
    exit(1);
    }



%%
int main(int argc, char **argv) {
      if (argc < 2) {
        fprintf(stderr, "You need to have: %s input.c or input.txt\n", argv[0]);
        return 1;
    }
    FILE *in = fopen(argv[1], "r");
    if (!in) { perror("NO Input file"); return 1; }
    yyin = in;
    yylex();
     fclose(in);
    return 0;
}

int yywrap() {
    return 1;
}
