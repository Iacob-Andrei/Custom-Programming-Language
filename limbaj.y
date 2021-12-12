%{
#include <stdio.h>
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
%}
%token ID TIP BGIN END NR CONST

%left '-'
%left '+'
%left '/'
%left '*'

%start progr
%%
progr: declaratii bloc {printf("program corect sintactic\n");}
     ;

declaratii :  declaratie ';'
	   | declaratii declaratie ';'
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
      
/* bloc */
bloc : BGIN list END  
     ;
     
/* lista instructiuni */
list :  statement ';' 
     | list statement ';'
     ;

/* instructiune */
statement: | ID '(' lista_apel ')'
           | ID '=' expresie
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
