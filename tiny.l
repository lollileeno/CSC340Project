%{
#include <stdio.h>
#include <string.h>

int line = 1;
int column = 1;

void print_error(const char* msg, const char* token) {
    printf("Error at line %d, column %d: %s \"%s\"\n", line, column, msg, token);
%}

%%

. {  print_error("unrecognized symbol", yytext);
    exit(1);
    }

%%

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