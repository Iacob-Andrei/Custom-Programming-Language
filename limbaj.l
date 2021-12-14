%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%

">"|"<"|"<="|">="|"!="|"=="          {return OPLOGIC;}

"int"|"float"|"char"|"string"|"bool" {return TIP;}
"const"                              {return CONST;}

"function"                           {return FCT;}
"end_function"                       {return EFCT;}

"if"                                 {return IF;}
"else"                               {return ELSEIF;}
"end_if"                             {return ENDIF;}

"while"                              {return WHILE;}
"end_while"                          {return EWHILE;}

"do"                                 {return DO;}

"for"                                {return FOR;}
"end_for"                            {return EFOR;}
"to"                                 {return TO;}
"begin_global"                       {return BGNGLO;}
"end_global"                         {return ENDGLO;}

"begin_fct"                          {return BGNFCT;}
"end_fct"                            {return ENDFCT;}

"main"                               {return MAIN;}
"end_main"                           {return ENDMAIN;}


@[_a-zA-Z][_a-zA-Z0-9]* {return ID;}
[0-9]+ {return NR;}
[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

