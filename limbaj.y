%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token ID TIP NR CONST FCT EFCT IF ELSEIF ENDIF WHILE EWHILE FOR EFOR DOWHILE BGNGLO ENDGLO BGNFCT ENDFCT MAIN ENDMAIN OPLOGIC

%left '-'
%left '+'
%left '/'
%left '*'

%start progr
%%
progr: bloc1 bloc2 bloc3 {printf("program corect sintactic\n");}
     ;


// declaratii globale = bloc1
bloc1 : BGNGLO declaratii_globale ENDGLO
     | /*epsilon*/
     ;

declaratii_globale :  declaratie ';'
          | declaratii_globale declaratie ';'
          ;

declaratie : TIP nume
          | TIP ID '(' lista_param ')'
          | TIP ID '(' ')'
          | CONST TIP cons
          ;

cons : cons ',' ID '=' NR            
     | ID '=' NR 
     ;
     
nume : ID
	| nume ',' ID
	;

lista_param : param
          | lista_param ','  param 
          ;

param : TIP ID
     ; 


// declaratii functii = bloc2

bloc2 : BGNFCT functii ENDFCT
     | /*epsilon*/
     ;

functii : functii declaratie_functie
          |declaratie_functie
          ;

declaratie_functie : FCT ID '(' lista_tip_parametrii ')' EFCT

lista_tip_parametrii : lista_tip_parametrii ',' TIP 
                    | TIP    
                    |  /*epsilon*/
                    ;

/* main = bloc3 */
bloc3 : MAIN list ENDMAIN  
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     ;

/* instructiune */
statement: | ID '(' lista_apel ')'
          | ID '=' expresie
          | IF '(' conditie ')' statement ENDIF
          | IF '(' conditie ')' statement ELSEIF statement ENDIF
          | WHILE '(' conditie ')' statement EWHILE
          | DOWHILE statement EWHILE '(' conditie ')'
          | FOR /* to do */ EFOR 
          ;

conditie : // to do
          ; 
expresie : expresie '+' expresie
          | expresie '-' expresie
          | expresie '*' expresie
          | expresie '/' expresie
          | '(' expresie ')'
          | ID
          | NR
          ;

lista_apel : NR
          | lista_apel ',' NR
          ;
%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 
