%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdbool.h>

extern FILE* yyin;
extern char* yytext;
extern int yylineno;

#define STRING_BUFFER 50
#define FILE_MEMORY 500
#define ERROR_BUFFER 100
#define ARRAY_SIZE 100

enum nodetype{
     OP = 1,
     IDENTIF = 2,
     NUMAR = 3,
     VECTOREL = 4,
     OTHERS = 5
};

struct AST
{
     struct AST* left;
     struct AST* right;
     enum nodetype node_type;
     char* name;
};

struct Var_info
{
     char name[STRING_BUFFER];
     char type[STRING_BUFFER]; 
     int val;
     int scope; // 0 -global , 1 - local
     char str_val[STRING_BUFFER];
     int if_const;

     int array_size;
     int* array;
     int* has_elements;

    // int id_line;
};

struct Func_info
{
     char func_name[STRING_BUFFER];
     char list_of_types[STRING_BUFFER];
     char func_return_type[STRING_BUFFER];
     unsigned int nr_of_args;
};

struct Var_info table_of_variables[ARRAY_SIZE];
struct Func_info table_of_functons[ARRAY_SIZE];
int var_counter = 0;
int func_counter = 0;
char error_msg[ERROR_BUFFER];

void print_error()
{
     printf("Eroare: %s\n", error_msg);
}

char *trim(char *content)
{
     while (isspace((unsigned char)*content))
          content++;
     char *finish;
     if (*content == 0)
          return content;

     finish = content + strlen(content) - 1;
     while (finish > content && isspace((unsigned char)*finish))
          finish--;
     finish[1] = '\0';
     return content;
}

int check_id(char *nume)
{
     for (int i = 0; i < var_counter; i++)
     {
          if (strcmp(table_of_variables[i].name, nume) == 0)
               return 1; // there already exists a variable with that name
     }
     return 0;
}

int check_constant(char *nume)
{
     // check existence before returning value
     if (!check_id(nume))
     {
          sprintf(error_msg, "Variabila %s nu exista pentru a verifica daca e constanta sau nu. ", nume);
          print_error();
          return -1;
     }
     for (int i = 0; i < var_counter; i++)
     {
          if (strcmp(table_of_variables[i].name, nume) == 0)
          {
               if (table_of_variables[i].if_const == 1)
                    return 1;
          }
     }
     return 0; // nu are tipul constant
}

int assign_value_if_null()
{
     table_of_variables[var_counter].val = 0;
     strcpy(table_of_variables[var_counter].str_val, "NULL");
     return 0;
}

int declarare_char(char *id, char *contents, int scope)
{
     if (check_id(id))
     {
          sprintf(error_msg, "Variabila %s a fost deja declarta anterior.", id);
          print_error();
          return -1;
     }
     strcpy(table_of_variables[var_counter].name, trim(id));

     // declare scope
     table_of_variables[var_counter].scope = 1; // main

     // if const
     // TO DO? CHAR poate fi constanta?
     table_of_variables[var_counter].if_const = 0;

     if ((table_of_variables[var_counter].if_const == 1) && (strcmp(trim(contents), "empty") == 0))
     {
          sprintf(error_msg, "Constanta %s a fost declarata fara valoare\n", id);
          print_error();
          return -1;
     }

     strcpy(table_of_variables[var_counter].type, "char");

     // asssigning value
     table_of_variables[var_counter].val = 1; // value for the string was defined. it exists

     sprintf(table_of_variables[var_counter].str_val, "%s", contents);

     if (strcmp(trim(contents), "empty") == 0)
     {
          table_of_variables[var_counter].val = 0; // the string wasn't actually defined
     }
     var_counter++;
     return 0;
}

int declarare_global_integers(char *type_var, char *id, int check_const, int actual_value)
{
     if (check_id(id))
     {
          sprintf(error_msg, "Variabila %s a fost deja declarta anterior.", id);
          print_error();
          return -1;
     }
     
     if ((actual_value == 9999999))
     {
          sprintf(error_msg, "Constanta %s a fost declarata fara valoare", id);
          print_error();
          return -1;
     }
     strcpy(table_of_variables[var_counter].name, trim(id));

     // declare scope
     table_of_variables[var_counter].scope = 0; // global

     // if const
     table_of_variables[var_counter].if_const = check_const;

     if (strcmp(trim(type_var), "int") == 0)
     {
          strcpy(table_of_variables[var_counter].type, trim(type_var)); // 0 means int
     }
     else
     {
          sprintf(error_msg, "Trying to assign a non-in in a \"declare_integer\" function %s", id);
          print_error();
          return -1;
     }

     // asssigning value
     table_of_variables[var_counter].val = actual_value;
     sprintf(table_of_variables[var_counter].str_val, "%d", actual_value);

     var_counter++;
     return 0;
}

int declarare_main(char *type_var, char *id, int check_const, int actual_value)
{
     if (check_id(id))
     {
          sprintf(error_msg, "Variabila %s a fost deja declarta anterior.", id);
          print_error();
          return -1;
     }
     
     if ((actual_value == 9999999))
     {
          sprintf(error_msg, "Constanta %s a fost declarata fara valoare\n", id);
          print_error();
          return -1;
     }
     strcpy(table_of_variables[var_counter].name, trim(id));

     // declare scope
     table_of_variables[var_counter].scope = 1; // main

     // if const
     table_of_variables[var_counter].if_const = check_const;

     strcpy(table_of_variables[var_counter].type, trim(type_var));

     // asssigning value
     table_of_variables[var_counter].val = actual_value;
     sprintf(table_of_variables[var_counter].str_val, "%d", actual_value);

     if (actual_value == -9999999)
     {
          assign_value_if_null();
     }
     var_counter++;
     return 0;
}

int check_function(char *nume_functie, char *type, char *lista_tipuri_argumente)
{
     for (int i = 0; i < func_counter; i++)
     {
          if (strcmp(table_of_functons[i].func_name, nume_functie) == 0)
          {
               if ((strcmp(table_of_functons[i].func_return_type, trim(type)) == 0) &&
                    (strcmp(table_of_functons[i].list_of_types, trim(lista_tipuri_argumente)) == 0))
               {
                    sprintf(error_msg, "Functia %s deja exista. ", nume_functie);
                    print_error();
                    return 1;
               }
          }
     }
     return 0;
}

int check_run_function(char *nume_functie, char *lista_tipuri_argumente)
{
     for (int i = 0; i < func_counter; i++)
     {    
          if (strcmp(table_of_functons[i].func_name, nume_functie) == 0)
          {
               if ((strcmp(table_of_functons[i].list_of_types, lista_tipuri_argumente) == 0))
               {
                    return 0;
               }
               sprintf(error_msg, "Functia %s are alti parametrii.\n", nume_functie);
               print_error();
               return 1;
          }
     }
     sprintf(error_msg, "Functia %s nu exista.\n", nume_functie);
     print_error();
     return 1;
}

int declarare_functie(char *name, char *return_type, char *lista_tipurilor)
{
     if(check_function(name, return_type, lista_tipurilor))
     {
          sprintf(error_msg, "Functia %s deja exista.", name);
          print_error();
          return -1;
     }
     strcpy(table_of_functons[func_counter].func_name, name);
     strcpy(table_of_functons[func_counter].func_return_type, return_type);
     strcpy(table_of_functons[func_counter].list_of_types, lista_tipurilor);
     func_counter++;
}

int get_id_value(char *nume)
{
     for (int i = 0; i < var_counter; i++)
     {
          if (strcmp(table_of_variables[i].name, nume) == 0)
               if( strcmp( table_of_variables[i].str_val , "NULL") != 0 )
                    return table_of_variables[i].val;
     }
     return 9999999;
}

char *get_id_type(char *nume)
{
     for (int i = 0; i < var_counter; i++)
     {
          if (strcmp(table_of_variables[i].name, nume) == 0)
               return table_of_variables[i].type;
     }
     return (char *)"no type";
}

int assign_expression(char *name, int value)
{
    // check if constant
     if (check_constant(name))
     {
          sprintf(error_msg, "Impossible to assign a value to a constant variable: %s", name);
          print_error();
          return -1;
     }

     for (int i = 0; i < var_counter; i++)
     {
          if (strcmp(table_of_variables[i].name, name) == 0)
          {
               if (table_of_variables[i].if_const != 1)
               {
                    sprintf(table_of_variables[i].str_val , "%d", value);
                    table_of_variables[i].val = value;
                    return 1;
               }
               return 0;
          }
     }
     return 0;
}

char* return_type_function( char *nume_functie, char *lista_tipuri_argumente )
{
     for (int i = 0; i < func_counter; i++)
     {
          if (strcmp(table_of_functons[i].func_name, nume_functie) == 0)
          {
               if ((strcmp(table_of_functons[i].list_of_types, lista_tipuri_argumente) == 0))
               {
                    return table_of_functons[i].func_return_type;
               }
          }
     }
     sprintf(error_msg, "Functia %s nu exista. ", nume_functie);
     print_error();
     return "eroare";
}

int check_if_type_concide( char *var_name , char *func_name, char *lista_tip_parametrii  )
{
     if( check_constant(var_name) == 1 )
     {
          sprintf(error_msg, "Variabila %s este constanta. \n", var_name);
          print_error();
          return 0;
     } 

     if( check_run_function(func_name,lista_tip_parametrii) == 1 )
     {
          sprintf(error_msg, "Functia %s este inexistenta. \n", var_name);
          print_error();
          return 0;
     }
     
     if( strcmp( get_id_type(var_name) , return_type_function(func_name , lista_tip_parametrii) ) != 0 )
     {
          sprintf(error_msg, "Tipuri diferite!. \n");
          print_error();
          return 0;
     }

     printf("ok\n");
     return 1;
}

int declarare_vector(char *tip, char *nume, int dimensiune_maxima, int scope)
{

     if (check_id(nume))
     {
          sprintf(error_msg, "O variabila cu acelasi nume %s a fost deja declarta anterior.", nume);
          print_error();
          exit(0);
     }

     strcpy(table_of_variables[var_counter].name, trim(nume));

     table_of_variables[var_counter].has_elements = 0;
     table_of_variables[var_counter].array_size = dimensiune_maxima;

     if (strcmp(trim(tip), "int") == 0)
     {
          table_of_variables[var_counter].array = (int*)malloc(dimensiune_maxima * sizeof(int));
          for (int j = 0; j < dimensiune_maxima; j++)
          {
               table_of_variables[var_counter].array[j] = 0;
          }
          
     }
     else if (strcmp(trim(tip), "float") == 0)
     {
          sprintf(error_msg, "Imposibila crearea unui vector de %s, folositi int", tip);
          print_error();
          exit(0);
     }
     else if (strcmp(trim(tip), "char") == 0)
     {
          sprintf(error_msg, "Imposibila crearea unui vector de %s, folositi int", tip);
          print_error();
          exit(0);
     }
     strcpy(table_of_variables[var_counter].type, "int");

     table_of_variables[var_counter].scope = scope;
     table_of_variables[var_counter].if_const = 0;
     var_counter++;
}

struct AST* buildAST( char* nume , struct AST* left , struct AST* right, enum nodetype type )
{
     struct AST* newnode = (struct AST*)malloc(sizeof(struct AST));

     newnode->name = strdup(nume);
     newnode->left = left;
     newnode->right = right;
     newnode->node_type = type;

     return newnode;
} 

int evalAST( struct AST* tree )
{
     if( tree->left == NULL && tree->right == NULL )        // sunt pe o frunza
     {
          if( tree->node_type == 2 )    // identificator
          {
               int val = get_id_value( tree->name );

               char tip[10];
               bzero( tip , 10 );
               strcpy( tip , get_id_type( tree->name ) );

               if( strcmp( tip , "char" ) == 0 )
               {
                    sprintf(error_msg, "Variabila %s este de tip char. NU poate fi folosita intr-o expresie la linia %d!", tree->name, yylineno);
                    print_error();
                    exit(0);
               }

               if( val == 9999999 )
               {
                    sprintf(error_msg, "Variabila %s nu are valoare.", tree->name);
                    print_error();
                    exit(0);
               }
               else
               {
                    return val;
               }
          }
          else if( tree->node_type == 3 )  // NUMAR
          {
               int val = atoi(tree->name);
               return val;
          }
          else      // OTHERS
          {
               return 0;
          }
     }
     else
     {
          int rezultat_stanga = evalAST( tree->left );
          int rezultat_dreapta = evalAST( tree->right );

          if( strcmp( tree->name , "+" ) == 0 )
          {
               return rezultat_dreapta + rezultat_stanga ;
          }
          else if( strcmp( tree->name , "-" ) == 0 ) 
          {
               return rezultat_stanga - rezultat_dreapta ;
          }
          else if( strcmp( tree->name , "*" ) == 0 ) 
          {
               return rezultat_stanga * rezultat_dreapta ;
          }
          else if( strcmp( tree->name , "/" ) == 0 ) 
          {
               if( rezultat_dreapta != 0 ) 
                    return rezultat_stanga - rezultat_dreapta ;
               else
               {
                    sprintf(error_msg, "NU se poate face impartire la 0!");
                    print_error();
                    exit(0);
               }
          }
     }
}

%}


%union
{
     char* str;
     int intnr;
     struct AST* tree;
}

%token CONST ARRAY PRINT
%token FCT EFCT CLASS ENDCLASS 
%token IF ELSEIF ENDIF WHILE EWHILE FOR EFOR TO DO
%token BGNGLO ENDGLO BGNFCT ENDFCT MAIN ENDMAIN 
%token OPLOGIC OPREL 

%token <str> ID TIP STRING CHAR
%token <intnr> NR
%type  <str> lista_tip_parametrii parametrii lista_apel
%type  <tree> expresie

%left '-'
%left '+'
%left '/'
%left '*'
%left OPLOGIC
%left OPREL

%start progr
%%
progr: bloc1 bloc2 bloc3 {printf("\nProgram corect sintactic!\n\n");}
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
     : TIP ID ';'                        { if( declarare_global_integers( $1, $2 , 0 , 0 ) == -1 ) exit(0); }
     | TIP ID '=' expresie ';'           { int rez = evalAST($4); if( declarare_global_integers( $1, $2 , 0 , rez ) == -1 ) exit(0); }
     | CONST TIP ID '=' expresie ';'     { int rez = evalAST($5); if( declarare_global_integers( $2, $3 , 1 , rez ) == -1 ) exit(0); }
     | CONST TIP ID ';'                  { if( declarare_global_integers( $2, $3 , 1 , 9999999 ) == -1 ) exit(0); }
     | CHAR ID ';'                       { if( declarare_char( $2 , "empty", 0) == -1 ) exit(0); }
     | CHAR ID '=' STRING ';'            { if( declarare_char( $2 , $4, 0) == -1 ) exit(0); }        
     | ARRAY TIP ID '[' NR ']' ';'       //{ declarare_vector( $2 , $3 , $5 , 0 ); }     char* tip , char* nume, int dimensiune_maxima, int scope
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

declarare_class : CLASS ID bloc_class ENDCLASS

bloc_class     : bloc_class declaratie_metoda
               | declaratie_metoda
               | bloc_class declaratie_class
               | declaratie_class
               ;

declaratie_class
     : TIP ID ';'
     | TIP ID '=' expresie ';'
     | CONST TIP ID '=' expresie ';'
     | CHAR ID ';'
     | CHAR ID '=' STRING ';'
     | ARRAY TIP ID '[' NR ']' ';'
     ;

declaratie_metoda   : FCT TIP ID lista_tip_parametrii EFCT 
                    | FCT CHAR ID lista_tip_parametrii EFCT
                    ;

declaratie_functie : FCT TIP ID lista_tip_parametrii EFCT        { if( declarare_functie( $3, $2, $4) == -1 ) exit(0); }  
                    | FCT CHAR ID lista_tip_parametrii EFCT      { if( declarare_functie( $3, $2, $4) == -1 ) exit(0); }
                    ;

lista_tip_parametrii
     : '('  ')'                     { $$ = malloc(5); strcpy( $$ , "null"); }
     | '(' parametrii ')'           { $$ = malloc(50); strcpy( $$ , $2); }
     ;

parametrii
     : TIP                          { $$ = $1; }
     | parametrii ',' TIP           { $$ = $1; strcat( $$ , "," ); strcat( $$ , $3 ); }
     | CHAR                         { $$ = $1; }
     | parametrii ',' CHAR          { $$ = $1; strcat( $$ , "," ); strcat( $$ , $3 ); }
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
     | print_function
     | list print_function
     ;

print_function
     : PRINT '(' STRING ',' expresie ')' ';'      { printf("%s%d\n", $3 , evalAST($5) ); }
     ;

declarari_main
     : TIP ID ';'                       { if( declarare_main($1 , $2 , 0 , -9999999) == -1 ) exit(0); }
     | TIP ID '=' expresie ';'          { int rez = evalAST($4); if( declarare_main($1 , $2 , 0 , rez) == -1 ) exit(0); }
     | CONST TIP ID '=' expresie ';'    { int rez = evalAST($5); if( declarare_main($2 , $3 , 1 , rez) == -1 ) exit(0); } 
     | CONST TIP ID ';'                 { if( declarare_main($2 , $3 , 1 , 9999999) == -1 ) exit(0);}     
     | CHAR ID ';'                      { if( declarare_char( $2 , "empty", 1) == -1 ) exit(0); }
     | CHAR ID '=' STRING ';'           { if( declarare_char( $2 , $4, 1 ) == -1 ) exit(0); }         
     | ARRAY TIP ID '[' NR ']' ';'      { declarare_vector( $2 , $3 , $5 , 1 ); }    
     ;


/* instructiune */
statement
     : ID '(' lista_apel ')' ';'                      { if( check_run_function( $1, $3 ) == 1 ) exit(0); }
     | ID '(' ')' ';'                                 { if( check_run_function( $1, "null" ) == 1 ) exit(0); }
     | ID '=' expresie ';'                            { char temp[100]; bzero(temp, 100); strcpy(temp,$1);
                                                       if( strcmp("char",get_id_type(temp)) == 0 ) 
                                                       {  
                                                            sprintf(error_msg, "NU se pot face asignari la variabile de tip char, linia %d.", yylineno);
                                                            print_error();
                                                            exit(0);
                                                       }
                                                       int rez = evalAST( $3 );
                                                       if( assign_expression( $1 , rez)  != 1 ) exit(0); 
                                                       }
     | ID '=' ID '(' lista_apel ')' ';'               { if( check_if_type_concide( $1 , $3 , $5 ) == 0 ) exit(0); }
     | ID '=' ID '(' ')' ';'                          { if( check_if_type_concide( $1 , $3 , "null" ) == 0 ) exit(0); }
     | ID '[' NR ']' '=' expresie ';'                 //{ int rez = evalAST( $6 );
                                                       //if( assign_expression_to_array_el( $1 , $3 , rez )  != 1 ) exit(0); }
     | ID '[' NR ']' '=' ID '(' lista_apel ')' ';'    { if( check_if_type_concide( $1 , $6 , $8 ) == 0 ) exit(0); }
     | ID '[' NR ']' '=' ID '(' ')' ';'               { if( check_if_type_concide( $1 , $6 , "null" ) == 0 ) exit(0); }
     ;
     
apel_instr_control
     : IF '(' conditie ')' list ENDIF
     | IF '(' conditie ')' list ELSEIF list ENDIF
     | WHILE '(' conditie ')' list EWHILE
     | DO list EWHILE '(' conditie ')'
     | FOR ID '=' NR TO ID DO list EFOR                        { if(check_id($2) == 0 ) exit(0);  if(check_id($6) == 0 ) exit(0);}
     | FOR ID '=' NR TO NR DO list EFOR                        { if(check_id($2) == 0 ) exit(0); }
     | FOR ID '=' ID TO ID DO list EFOR                        { if(check_id($2) == 0 ) exit(0); if(check_id($4) == 0 ) exit(0); if(check_id($6) == 0 ) exit(0);}
     | FOR ID '=' ID TO NR DO list EFOR                        { if(check_id($2) == 0 ) exit(0); if(check_id($4) == 0 ) exit(0);}
     ;


conditie  : '(' expresie ')'
          | conditie OPREL conditie
          ;

expresie :  expresie '+' expresie       { $$ = buildAST( "+" , $1 , $3 , OP ); }
          | expresie '-' expresie       { $$ = buildAST( "-" , $1 , $3 , OP ); }
          | expresie '*' expresie       { $$ = buildAST( "*" , $1 , $3 , OP ); }
          | expresie '/' expresie       { $$ = buildAST( "/" , $1 , $3 , OP ); }
          | '(' expresie ')'            { $$ = $2; }
          | ID                          { $$ = buildAST( $1 , NULL , NULL , IDENTIF ); }
          | NR                          { 
                                             char nume[100];
                                             bzero(nume, 100);
                                             sprintf( nume , "%d" , $1 );
                                             $$ = buildAST( nume , NULL , NULL , NUMAR ); 
                                        }
          | ID '[' NR ']'               //{ 
                                        //      int value = get_array_value($1,$3); 
                                        //      char nume[100];
                                        //      bzero(nume, 100);
                                        //      sprintf( nume , "%d" , value );
                                        //      $$ = buildAST( nume , NULL , NULL , NUMAR );
                                        // }
          ;

lista_apel
     : NR                               { strcpy($$,"int");  }
     | lista_apel ',' NR                { strcat($$,",int"); }
     | ID                               { char temp[100]; bzero(temp,100); strcpy(temp, $1); strcpy($$, get_id_type(temp)); if( strcmp( $$ , "no type" ) == 0 )  { printf("EROARE identificator %s inexistent la linia !\n", temp, yylineno); exit(0); } }
     | lista_apel ',' ID                { strcat($$,","); strcat($$, get_id_type($3)); if( strstr( $$ , "no type" ) != NULL ) { printf("EROARE identificator %s inexistent la linia %d\n", $3, yylineno); exit(0); } }
     ;

%%
int yyerror(char * s)
{
     printf("eroare: %s la linia:%d\n\n",s,yylineno);
     exit(0);
}

void print_variables()
{
     FILE *fPtr;
     fPtr = fopen("symbol_table.txt", "w");
     if (fPtr == NULL)
     {
          printf("Unable to create file.\n");
          exit(EXIT_FAILURE);
     }
     printf("------------------------------------------------------");
     printf("\nVariabilele declarate:\n");

     for (int i = 0; i < var_counter; i++)
     {
          char buffer[FILE_MEMORY];
          bzero(buffer, FILE_MEMORY);

          sprintf(buffer, "name: %s, type: %s, const: %d, val: %s, scope: %d\n",
                    table_of_variables[i].name, table_of_variables[i].type,
                    table_of_variables[i].if_const, table_of_variables[i].str_val, table_of_variables[i].scope);
          printf("%s",buffer);
          fputs(buffer, fPtr);
     }
     printf("------------------------------------------------------");
     fclose(fPtr);
     printf("\n\n");
}

void print_functions()
{
     FILE *fPtr;
     fPtr = fopen("symbol_table_functions.txt", "w");
     if (fPtr == NULL)
     {
          printf("Unable to create file.\n");
          exit(EXIT_FAILURE);
     }

     printf("------------------------------------------------------");
     printf("\nFunctiile declarate sunt:\n");

     for (int i = 0; i < func_counter; i++)
     {
          char buffer[FILE_MEMORY];
          bzero(buffer, FILE_MEMORY);

          sprintf(buffer, "name: %s, return_type: %s, parameter types: %s\n",
                    table_of_functons[i].func_name, table_of_functons[i].func_return_type,
                    table_of_functons[i].list_of_types);

          printf("%s", buffer);
          fputs(buffer, fPtr);
     }
     printf("------------------------------------------------------");
     fclose(fPtr);
     printf("\n\n");
}

void print_all()
{
     print_variables();
     print_functions();
}

int main(int argc, char** argv)
{
     yyin=fopen(argv[1],"r");
     yyparse();
     print_all();
} 
