%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdbool.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}

%union
{
     char* str;
     int intnr;
}

%token CONST ARRAY
%token FCT EFCT CLASS ENDCLASS 
%token IF ELSEIF ENDIF WHILE EWHILE FOR EFOR TO DO
%token BGNGLO ENDGLO BGNFCT ENDFCT MAIN ENDMAIN 
%token OPLOGIC OPREL 

%token <str> ID TIP
%token <intnr> NR
%type  <str> lista_tip_parametrii parametrii lista_apel
%type  <intnr> expresie

%left '-'
%left '+'
%left '/'
%left '*'
%left OPLOGIC
%left OPREL

%start progr
%%
progr: bloc1 bloc2 bloc3 {printf("program corect sintactic\n");}
     ;


// declaratii globale = bloc1
bloc1 : BGNGLO declaratii_globale ENDGLO
     | /*epsilon*/
     ;

declaratii_globale 
     : declaratie 
     | declaratii_globale declaratie 
     ;

declaratie 
     : TIP ID ';'                        //{ declarare_global( $1, $2 , 0 , 0  ); }
     | TIP ID '=' expresie ';'           //{ declarere_global( $1, $2 , 0 , $4 ); }
     | CONST TIP ID '=' expresie ';'     //{ declarare_global( $2, $3 , 1 , $5 ); }
     | CONST TIP ID ';'                  //{ declarare_global( $1, $2 , 1 , 9999999 );}     // caz de eroare
     ;


// declaratii functii = bloc2

// declarari class

bloc2 : BGNFCT declarari_bloc_2 ENDFCT
     | /*epsilon*/
     ;

declarari_bloc_2
     : declarari_bloc_2 declaratie_functie
     | declarari_bloc_2 declarare_class
     | declarare_class
     | declaratie_functie
     ;

declarare_class : CLASS ID  bloc_class ENDCLASS

bloc_class     : bloc_class declaratie_functie
               | bloc_class declaratie
               | declaratie_functie
               | declaratie 
               ;

declaratie_functie : FCT ID lista_tip_parametrii bloc_functie EFCT      //{declarare_functie( $2, $3);}

lista_tip_parametrii
     : '('  ')'                     { $$ = malloc(5); strcpy( $$ , "null"); }
     | '(' parametrii ')'           { strcpy( $$ , $2); }
     ;

parametrii
     : TIP                         { $$ = $1; }
     | parametrii ',' TIP          { $$ = $1; strcat( $$ , "," ); strcat( $$ , $3 ); }
     ;

bloc_functie   : list 
               ;

/* main = bloc3 */
bloc3 : MAIN list ENDMAIN  
     ;
     

/* lista instructiuni */
list : statement 
     | list statement 
     | apel_instr_control
     | list apel_instr_control
     | declarari_main
     | list declarari_main
     ;

declarari_main
     : TIP ID ';'                       //{ declarare_main($1 , $2 , 0 , -9999999); }
     | TIP ID '=' expresie ';'          //{ declarare_main($1 , $2 , 0 , $4); }
     | CONST TIP ID '=' expresie ';'    //{ declarare_main($1 , $2 , 1 , $5); } 
     | CONST TIP ID ';'                 //{ declarare_main($1 , $2 , 1 , -9999999); }     //caz eroare
     | ARRAY TIP ID '[' NR ']' ';'      //{ declarare_main_array( $2 , $3 , $5 ); }       char* char* int
     ;


/* instructiune */
statement
     : ID '(' lista_apel ')' ';'                      //{ check_function( $1, $3 ); }
     | ID '(' ')' ';'                                 //{ check_function( $1, "null" ); }
     | ID '=' expresie ';'                            //{ if(!check_constant($1)) assign_expression( $1 , $3); }
     | ID '=' ID  lista_apel ';'                      //{ check_constant($1); check_function($3,$4);}
     ;
     
apel_instr_control
     : IF '(' conditie ')' list ENDIF
     | IF '(' conditie ')' list ELSEIF list ENDIF
     | WHILE '(' conditie ')' list EWHILE
     | DO list EWHILE '(' conditie ')'
     | FOR ID '=' NR TO ID DO list EFOR                        //{check_id($2); check_id($6);}
     | FOR ID '=' NR TO NR DO list EFOR                        //{check_id($2);}
     | FOR ID '=' ID TO ID DO list EFOR                        //{check_id($2); check_id($4); check_id($6);}
     | FOR ID '=' ID TO NR DO list EFOR                        //{check_id($2); check_id($4);}
     ;


conditie  : '(' expresie ')'
          | conditie OPREL conditie
          ;

expresie :  expresie '+' expresie       //{ $$ = $1 + $3; }
          | expresie '-' expresie       //{ $$ = $1 - $3; }
          | expresie '*' expresie       //{ $$ = $1 * $3; }
          | expresie '/' expresie       //{ if($3 == 0) printf("eroare.."); else $$ = $1 / $3;}
          | '(' expresie ')'            { $$ = $2; }
          | ID                          { $$ = 5; } //get_id_value($1);    // check if integer
          | NR                          { $$ = $1;}
          | ID '(' ')'                  { $$ = 0; } //check function
          | ID '(' lista_apel ')'       { $$ = 0; } //check function
          ;

lista_apel
     : NR                               { strcpy($$,"int");  }
     | lista_apel ',' NR                { strcat($$,",int"); }
     | ID                               //{ strcpy($$, get_id_type($1)); }
     | lista_apel ',' ID                //{ strcat($$,","); strcat($$, get_id_type($1)); }
     ;

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 
