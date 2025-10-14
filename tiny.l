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

"--".*                 {  }

[ \t\r]+               { column += yyleng;  }

\n                     { line++; column = 1; }   

program                { printf("PROGRAM\n"); column += yyleng; }
beginprogram           { printf("BEGIN_PROGRAM\n"); column += yyleng; }
endprogram             { printf("END_PROGRAM\n"); column += yyleng; }
integer                { printf("INTEGER\n"); column += yyleng; }
array                  { printf("ARRAY\n"); column += yyleng; }
of                     { printf("OF\n"); column += yyleng; }
if                     { printf("IF\n"); column += yyleng; }
then                   { printf("THEN\n"); column += yyleng; }
endif                  { printf("ENDIF\n"); column += yyleng; }
else                   { printf("ELSE\n"); column += yyleng; }
while                  { printf("WHILE\n"); column += yyleng; }
loop                   { printf("LOOP\n"); column += yyleng; }
endloop                { printf("ENDLOOP\n"); column += yyleng; }
read                   { printf("READ\n"); column += yyleng; }
write                  { printf("WRITE\n"); column += yyleng; }
and                    { printf("AND\n"); column += yyleng; }
or                     { printf("OR\n"); column += yyleng; }
not                    { printf("NOT\n"); column += yyleng; }
true                   { printf("TRUE\n"); column += yyleng; }
false                  { printf("FALSE\n"); column += yyleng; }

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
