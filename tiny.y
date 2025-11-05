%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int line;
int yylex(void);
void yyerror(const char *s);

/* Print a production rule */
void emit_prod(const char* lhs, const char* rhs) {
    printf("%s -> %s\n", lhs, rhs);
}


void print_result(int value) {
    if (value == 1)
        printf("Result of expression = true\n");
    else if (value == 0)
        printf("Result of expression = false\n");
    else
        printf("Result of expression = %d\n", value);
}
%}


%union {
    int ival;
    char *sval;
}


%token <sval> IDENT
%token <ival> NUMBER
%token PROGRAM BEGIN_PROGRAM END_PROGRAM INTEGER ARRAY OF
%token IF THEN ENDIF ELSE WHILE LOOP ENDLOOP READ WRITE
%token AND OR NOT TRUE FALSE
%token ADD SUB MULT DIV
%token EQ NEQ LT GT LTE GTE
%token ASSIGN SEMICOLON COLON COMMA L_PAREN R_PAREN


%type <ival> expression rel condition cond_and cond_or

%left OR
%left AND
%right NOT
%left ADD SUB
%left MULT DIV
%nonassoc EQ NEQ LT GT LTE GTE

%%

program:
    PROGRAM IDENT SEMICOLON declarations BEGIN_PROGRAM statements END_PROGRAM
      { emit_prod("program","PROGRAM IDENT SEMICOLON declarations BEGIN_PROGRAM statements END_PROGRAM"); }
;

declarations:
      /* empty */ { emit_prod("declarations"," empty "); }
    | declaration SEMICOLON declarations
      { emit_prod("declarations","declaration SEMICOLON declarations"); }
;

declaration:
      IDENT COLON type
        { emit_prod("declaration","IDENT COLON type"); }
    | IDENT COLON ARRAY L_PAREN NUMBER R_PAREN OF type
        { emit_prod("declaration","IDENT COLON ARRAY L_PAREN NUMBER R_PAREN OF type"); }
;

type:
    INTEGER { emit_prod("type","INTEGER"); }
;

statements:
      /* empty */ { emit_prod("statements"," empty "); }
    | statement { emit_prod("statements","statement"); }
    | statement SEMICOLON statements { emit_prod("statements","statement SEMICOLON statements"); }
;

statement:
      assignment   { emit_prod("statement","assignment"); }
    | if_stmt      { emit_prod("statement","if_stmt"); }
    | while_stmt   { emit_prod("statement","while_stmt"); }
    | io_stmt      { emit_prod("statement","io_stmt"); }
    | error SEMICOLON { printf("Syntax error at line %d: invalid statement\n", line); yyerrok; }
;

assignment:
    IDENT ASSIGN expression
      {
        emit_prod("assignment","IDENT ASSIGN expression");
        print_result($3);
      }
;

if_stmt:
      IF condition THEN statements ENDIF
        { emit_prod("if_stmt","IF condition THEN statements ENDIF"); }
    | IF condition THEN statements ELSE statements ENDIF
        { emit_prod("if_stmt","IF condition THEN statements ELSE statements ENDIF"); }
;

while_stmt:
    WHILE condition LOOP statements ENDLOOP
      { emit_prod("while_stmt","WHILE condition LOOP statements ENDLOOP"); }
;

io_stmt:
      READ id_list  { emit_prod("io_stmt","READ id_list"); }
    | WRITE id_list { emit_prod("io_stmt","WRITE id_list"); }
;

id_list:
      IDENT { emit_prod("id_list","IDENT"); }
    | IDENT COMMA id_list { emit_prod("id_list","IDENT COMMA id_list"); }
;

condition:
      cond_or { emit_prod("condition","cond_or"); $$ = $1; }
;

cond_or:
      cond_and { emit_prod("cond_or","cond_and"); $$ = $1; }
    | cond_or OR cond_and { emit_prod("cond_or","cond_or OR cond_and"); $$ = ($1 || $3); }
;

cond_and:
      rel { emit_prod("cond_and","rel"); $$ = $1; }
    | cond_and AND rel { emit_prod("cond_and","cond_and AND rel"); $$ = ($1 && $3); }
;

rel:
      expression { emit_prod("rel","expression"); $$ = $1; }
    | expression EQ expression { emit_prod("rel","expression EQ expression"); $$ = ($1 == $3); }
    | expression NEQ expression { emit_prod("rel","expression NEQ expression"); $$ = ($1 != $3); }
    | expression LT expression { emit_prod("rel","expression LT expression"); $$ = ($1 < $3); }
    | expression GT expression { emit_prod("rel","expression GT expression"); $$ = ($1 > $3); }
    | expression LTE expression { emit_prod("rel","expression LTE expression"); $$ = ($1 <= $3); }
    | expression GTE expression { emit_prod("rel","expression GTE expression"); $$ = ($1 >= $3); }
    | NOT rel { emit_prod("rel","NOT rel"); $$ = !$2; }
    | TRUE { emit_prod("rel","TRUE"); $$ = 1; }
    | FALSE { emit_prod("rel","FALSE"); $$ = 0; }
    | L_PAREN condition R_PAREN { emit_prod("rel","L_PAREN condition R_PAREN"); $$ = $2; }
;

expression:
      expression ADD expression { emit_prod("expression","expression ADD expression"); $$ = $1 + $3; }
    | expression SUB expression { emit_prod("expression","expression SUB expression"); $$ = $1 - $3; }
    | expression MULT expression { emit_prod("expression","expression MULT expression"); $$ = $1 * $3; }
    | expression DIV expression {
          emit_prod("expression","expression DIV expression");
          if ($3 == 0) {
              printf("Runtime error: division by zero at line %d\n", line);
              $$ = 0;
          } else $$ = $1 / $3;
      }
    | L_PAREN expression R_PAREN { emit_prod("expression","L_PAREN expression R_PAREN"); $$ = $2; }
    | IDENT { emit_prod("expression","IDENT"); $$ = 0; /* variable handling not implemented */ }
    | NUMBER { emit_prod("expression","NUMBER"); $$ = $1; }
    | SUB expression %prec SUB { emit_prod("expression","SUB expression (unary)"); $$ = -$2; }
;

%%

void yyerror(const char *s) {
    printf("Syntax error at line %d: %s\n", line, s);
}

int main(void) {
    yyparse();
    return 0;
}
