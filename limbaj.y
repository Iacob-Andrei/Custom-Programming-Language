%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token ID IDFUNC IDCLASS TIP NR CONST FCT EFCT IF ELSEIF ENDIF WHILE EWHILE FOR EFOR TO DO BGNGLO ENDGLO BGNFCT ENDFCT MAIN ENDMAIN OPLOGIC OPREL

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

declaratii_globale :  declaratie ';'
          | declaratii_globale declaratie ';'
          ;

declaratie : TIP nume
          | CONST TIP cons
          ;

cons : cons ',' ID '=' NR            
     | ID '=' NR 
     ;
     
nume : ID '=' NR
	| nume ',' ID
     | nume ',' ID '=' NR
     | ID
	;

// declaratii functii = bloc2

// declarari class

bloc2 : BGNFCT functii ENDFCT
     | /*epsilon*/
     ;

functii : functii declaratie_functie
          |declaratie_functie
          ;

declaratie_functie : FCT IDFUNC '(' lista_tip_parametrii ')' bloc_functie EFCT

lista_tip_parametrii : lista_tip_parametrii ',' TIP 
                    | TIP    
                    |  /*epsilon*/
                    ;

bloc_functie   : list 
               ;

/* main = bloc3 */
bloc3 : MAIN list ENDMAIN  
     ;
     
/* lista instructiuni */
list :  statement ';'
     | list statement ';'
     | apel_instr_control
     | list apel_instr_control
     ;

/* instructiune */
statement: | IDFUNC '(' lista_apel ')' 
          | ID '=' expresie 
          | ID '=' IDFUNC '(' lista_tip_parametrii ')'
          ;
     
apel_instr_control: IF '(' conditie ')' list ENDIF
               | IF '(' conditie ')' ENDIF
               | IF '(' conditie ')' list ELSEIF list ENDIF
               | IF '(' conditie ')' list ELSEIF ENDIF
               | WHILE '(' conditie ')' list EWHILE
               | WHILE '(' conditie ')' EWHILE
               | DO list EWHILE '(' conditie ')'
               | DO EWHILE '(' conditie ')'
               | FOR ID '=' NR TO ID DO list EFOR
               | FOR ID '=' NR TO ID DO EFOR
               | FOR ID '=' NR TO ID NR list EFOR
               | FOR ID '=' NR TO ID NR EFOR
               | FOR ID '=' ID TO ID DO list EFOR
               | FOR ID '=' ID TO ID DO EFOR
               | FOR ID '=' ID TO ID NR list EFOR
               | FOR ID '=' ID TO ID NR EFOR
               ;


conditie  : '$' '(' expresie ')'
          | conditie OPREL conditie
          ;

expresie :  expresie '+' expresie
          | expresie '-' expresie
          | expresie '*' expresie
          | expresie '/' expresie
          | '(' expresie ')'
          | ID
          | NR
          ;

lista_apel : NR
          | lista_apel ',' NR
          | ID
          | lista_apel ',' ID
          | /*epsilon*/
          ;

%%
int yyerror(char * s){
printf("eroare: %s la linia:%d\n",s,yylineno);
}

int main(int argc, char** argv){
yyin=fopen(argv[1],"r");
yyparse();
} 
