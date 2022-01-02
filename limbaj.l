%{
#include <stdio.h>
#include "y.tab.h"
%}
%option noyywrap
%%

">"|"<"|"<="|">="|"!="|"=="          {return OPREL;} 
"&"|"||"|"!"                         {return OPLOGIC;}

"int"|"float"                        {yylval.str = strdup(yytext); return TIP;}
"char"                               {yylval.str = strdup(yytext); return CHAR;}
"const"                              {return CONST;}
"array"                              {return ARRAY;}
"print"                              {return PRINT;}

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

"def class"                          {return CLASS;}
"end_defclass"                       {return ENDCLASS;}

[_a-zA-Z][_a-zA-Z0-9]*               {yylval.str = strdup(yytext); return ID;}
\"[ _a-zA-Z0-9=]+\"                  {yylval.str = strdup(yytext); yylval.str++; yylval.str[strlen(yylval.str)-1] = 0; return STRING;}

[-]?[0-9]+[.]?[0-9]?[0-9]?           {yylval.intnr = atoi(yytext); return NR;}
[ \t] ;
\n                                   {yylineno++;}
.                                    {return yytext[0];}

