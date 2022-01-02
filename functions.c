#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#define STRING_BUFFER 50
#define FILE_MEMORY 500
#define ERROR_BUFFER 100
#define ARRAY_SIZE 100

struct Var_info
{
    char name[STRING_BUFFER];
    char type[STRING_BUFFER]; 
    int val;
    int scope; // 0 -global , 1 - local
    char str_val[STRING_BUFFER];
    int if_const;
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
    printf("Eroare: %s", error_msg);
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

void print_variables()
{
    char temp[STRING_BUFFER];
    bzero(temp, STRING_BUFFER);
    for (int i = 0; i < var_counter; i++)
    {
        char buffer[FILE_MEMORY];
        bzero(buffer, FILE_MEMORY);
        sprintf(buffer, "name: %s, type: %s, const: %d, val: %s\n, scope: %d\n",
                table_of_variables[i].name, table_of_variables[i].type,
                table_of_variables[i].if_const, table_of_variables[i].str_val, table_of_variables[i].scope);
        strcpy(temp, buffer);
        bzero(buffer, FILE_MEMORY);
    }
    printf("%s", temp);
    FILE *f = fopen("symbol_table.txt", "w");
    if (f != NULL)
    {
        fprintf(f, "%s", temp);
        fclose(f);
        f = NULL;
    }
    bzero(temp, STRING_BUFFER);
}

void print_functions()
{
    char temp[STRING_BUFFER];
    bzero(temp, STRING_BUFFER);
    for (int i = 0; i < func_counter; i++)
    {
        char buffer[FILE_MEMORY];
        bzero(buffer, FILE_MEMORY);
        sprintf(buffer, "name: %s, return_type: %s, parameter types: %s\n",
                table_of_functons[i].func_name, table_of_functons[i].func_return_type,
                table_of_functons[i].list_of_types);
        strcpy(temp, buffer);
        bzero(buffer, FILE_MEMORY);
    }
    printf("%s", temp);
    FILE *f = fopen("symbol_table_functions.txt", "w");
    if (f != NULL)
    {
        fprintf(f, "%s", temp);
        fclose(f);
        f = NULL;
    }
    bzero(temp, STRING_BUFFER);
}

void print_all()
{
    print_variables();
    print_functions();
}

int declare_local();

// returns 1 if theres no function of that sort
// TO DO

int check_id(char *nume)
{
    for (int i = 0; i < var_counter; i++)
    {
        if (strcmp(table_of_variables[i].name, nume) == 0)
            return 1; // there already exists a variable with that name
    }
    return 0;
}

// id tip lista_param
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
                return -1;
            }
        }
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
// returns 1 if there was possible to assign an expression
int assign_expression(char *name, char *value)
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
                strcpy(table_of_variables[i].str_val, value);
                table_of_variables[i].val = atoi(value);
                return 1;
            }
            return 0;
        }
    }
    return 0;
}

// returns the type of the variable if it exists, in other case -1
int get_id_value(char *nume)
{
    for (int i = 0; i < var_counter; i++)
    {
        if (strcmp(table_of_variables[i].name, nume) == 0)
            return table_of_variables[i].val;
    }
    return -1;
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

int assign_value_if_null()
{
    table_of_variables[var_counter].val = 0;
    strcpy(table_of_variables[var_counter].str_val, "NULL");
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
    // TO DO
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

    if (actual_value == 0) // ??
    {
        assign_value_if_null();
    }
    var_counter++;
    return 0;
}

void declarare_functie(char *name, char *return_type, char *lista_tipurilor)
{
    check_function(name, return_type, lista_tipurilor); // error -> if exists -> perror
    strcpy(table_of_functons[func_counter].func_name, name);
    func_counter++;
}

int main()
{

}
