%{

/*
    UNIVERSIDAD NACIONAL AUTÓNOMA DE MÉXICO
    FACULTAD DE INGENIERÍA
    
    ELABORÓ: GUZMÁN VILLANUEVA JULIO CÉSAR


    OBJETIVO
    Elaborar un analizador léxico que reconozca los componentes léxicos pertenecientes a las clases abajo descritas.
   
        |CLASE| DESCRIPCION                             |
        |0    | Identificadores                         |
        |1    | Constantes enteras decimales            |
        |2    | Cadenas (delimitadas con @)             |
        |3    | Palabras reservadas (iniciadas con #)   |
        |4    | Simbolos especiales                     |
        |5    | Constante enteras octales				|
        |7    | Constantes enteras hexadecimales		|
        |8    | Operadores relacionales					|
*/

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define MAXIMA_LONGITUD_DE_CAMPO 300

FILE *archivo_tokens;
FILE *tabla_simbolos;
FILE *tabla_palabras_reservadas;
FILE *tabla_cadenas;
FILE *tabla_operadores_relacionales;

int linea = 1;
int indice_de_tabla_simbolos = -1;
int indice_de_tabla_palabras_reservadas = -1;
int indice_de_tabla_cadenas = -1;
int indice_de_tabla_operadores_relacionales = -1;

// Archivos
void creaArchivos();
void  crea_archivo_tokens();
void crea_tabla_simbolos();
void crea_tabla_palabras_reservadas();
void crea_tabla_cadenas();
void crea_tabla_operadores_relacionales();
void cierraArchivos();

// Manejo de tablas
void insert(FILE *file, char* filename , char* campo1, char* campo2, char* campo3, int esToken);  //Uso para tablas de 2 o 3 campos
char* select_campo1(/* FROM */ FILE *file, char* filename , /* WHERE CAMPO2 = */ char* campo2 );  //Uso para tablas de 2 o 3 campos

//Manejo de cadenas
void removeSubstring(char *s,const char *toremove);

// Manejo de clases
void identificador(char identificador[]);
void constante_entera_decimal(char constante_entera_decimal[]);
void cadena(char cadena[]);
void palabra_reservada(char palabra_reservada[]);
void simbolo_especial(char simbolo_especial[]);
void constante_entera_octal(char constante_entera_octal[]);
void constante_entera_hexadecimal(char constante_entera_hexadecimal[]);
void operador_relacional(char operador_relacional[]);
void error_lexico(char error_lexico[]);

%}
salto_de_linea                 [\n]
delimitador                    [\t]|[" "]*
digito                         [0-9]
cero                           [0]
digito_uno_al_nueve            [1-9]
digito_uno_al_siete            [1-7]
letra_minuscula                [a-z]
letra_mayuscula                [A-Z]
letra                          {letra_minuscula}|{letra_mayuscula}
guion_bajo                     [_]
arroba                         [@]
no_es_arroba_ni_salto_de_linea [^@]|\\n
cadena                         {arroba}{no_es_arroba_ni_salto_de_linea}*{arroba}
identificador                  ({letra}|{guion_bajo})({letra_minuscula}|{digito}|{guion_bajo})*
constante_entera_decimal       {cero}|({digito_uno_al_nueve}({digito_uno_al_nueve}|{cero})*)
palabra_reservada              [#]("define"|"ifdef"|"if"|"elif"|"else"|"endif"|"undef"|"indef")
simbolo_especial               [;,()!]
constante_entera_octal         {cero}({digito_uno_al_siete}|{cero})+
constante_entera_hexadecimal   {cero}([x]|[X])({digito_uno_al_nueve}|[a-f]|[A-F]|{cero})+
operador_relacional            \<|"<="|\>|">="|"=="|"!="
%%
{salto_de_linea}                    linea++;
{delimitador}
{identificador}                     identificador(yytext);
{constante_entera_decimal}          constante_entera_decimal(yytext);
{cadena}                            cadena(yytext);
{palabra_reservada}                 palabra_reservada(yytext);
{simbolo_especial}                  simbolo_especial(yytext);
{constante_entera_octal}            constante_entera_octal(yytext);
{constante_entera_hexadecimal}      constante_entera_hexadecimal(yytext);
{operador_relacional}               operador_relacional(yytext);
.                                   error_lexico(yytext);
%%
main(int argc, char *argv[])
{
     //Crea archivos
     creaArchivos();

     //Leer archivo de entrada
     yyin = fopen(argv[1],"r");

     //Abrir archivos en modo lectura y escritura

     //Corre el analizador lexico de flex yylex
     yylex();

     //Cierra archivos
     cierraArchivos();
     
     //Imprime tabla de simbolos
     printf("==================================================\n");
     printf("\t\tTabla de simbolos\n");
     printf("==================================================\n");
        system("cat tabla_simbolos.txt");
     printf("==================================================\n");
    
     //Imprime tabla de cadenas
     printf("==================================================\n");
     printf("\t\tTabla de cadenas\n");
     printf("==================================================\n");
        system("cat tabla_cadenas.txt");
     printf("==================================================\n");
     
     //Imprime tokens
     printf("==================================================\n");
     printf("\t\tTokens\n");
     printf("==================================================\n");
        system("cat tokens.txt");
     printf("==================================================\n");
     
}

void creaArchivos()
{
    //Crea archivo de salida
        crea_archivo_tokens();

    //Crea tabla de simbolos
        crea_tabla_simbolos();

    //Crea tabla de palabras reservadas
        crea_tabla_palabras_reservadas();
        
    //Crea tabla de cadenas
        crea_tabla_cadenas();
        
    //Crea tabla de operadores relacionales
        crea_tabla_operadores_relacionales();    
}

void crea_archivo_tokens()
{
    archivo_tokens = fopen("tokens.txt","w");
}

void crea_tabla_simbolos()
{
    tabla_simbolos = fopen("tabla_simbolos.txt","w");
}

void crea_tabla_palabras_reservadas()
{
    tabla_palabras_reservadas = fopen("tabla_palabras_reservadas.txt","w");
    
    //Inserta a la tabla tuplas predefinidas
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "0","define","", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "1","ifdef", "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "2","if",    "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "3","elif",  "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "4","else",  "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "5","endif", "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "6","undef", "", 0);
    insert(tabla_palabras_reservadas, "tabla_palabras_reservadas.txt", "7","ifndef","", 0);
}

void crea_tabla_cadenas()
{
    tabla_cadenas = fopen("tabla_cadenas.txt","w");
}

void crea_tabla_operadores_relacionales()
{
    tabla_operadores_relacionales = fopen("tabla_operadores_relacionales.txt","w");
    
    //Inserta a la tabla tuplas predefinidas
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "0","<", "", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "1","<=","", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "2",">", "", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "3",">=","", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "4","==","", 0);
    insert(tabla_operadores_relacionales, "tabla_operadores_relacionales.txt", "5","!=","", 0);
}

void cierraArchivos()
{
    fclose(archivo_tokens);
    fclose(tabla_simbolos);
    fclose(tabla_palabras_reservadas);
    fclose(tabla_cadenas);
    fclose(tabla_operadores_relacionales);
}

// Manejo de tablas
void insert(FILE *file, char* filename , char* campo1, char* campo2, char* campo3, int esToken)
{
    // Si no existe en la tabla se inserta
    if(esToken == 1 || select_campo1( file, filename, campo2) == NULL )
    {
        char *registro = (char *)malloc(sizeof(campo1) + sizeof(campo2) + sizeof(campo3));
        strcpy( registro, campo1);
        strcat( registro, "\t");
        strcat( registro, campo2);
        strcat( registro, "\t");
        strcat( registro, campo3);
        strcat( registro, "\n");
        fprintf( file, "%s", registro);
    }
}



char* select_campo1(/* FROM */ FILE *file, char* filename , /* WHERE CAMPO2 = */ char* campo2 )
{
    
    // Cerrar archivo
    fclose( file );
    
    // Abrir archivo en modo lectura
    file = fopen( filename , "r" );
    
    
    // Declaracion de variables para guardar los campos
    int numero;
    char *_campo1 = (char *) malloc(MAXIMA_LONGITUD_DE_CAMPO);
    char *_campo2 = (char *) malloc(MAXIMA_LONGITUD_DE_CAMPO);
    char *_campo3 = (char *) malloc(MAXIMA_LONGITUD_DE_CAMPO);

    // Ciclo while
    while( fscanf( file, "%200[^\t\n]\t%200[^\t\n]", _campo1, _campo2) >= 1) 
                                                                             // Guarda campo1 y campo2 en _campo1 y _campo2
    {
        //Para hacer al ultimo campo opcional
        fgets( _campo3 , MAXIMA_LONGITUD_DE_CAMPO, file );                   // Se encarga del resto de la linea
        sscanf(_campo3, "\t%200[^\t]", _campo3);                             // Le quita el tabulador y guarda el campo3 en _campo3
        /*
            printf("ENTRO AL WHILE\n");
            printf("_campo1 = %s\n", _campo1);
            printf("_campo2 = %s\n", _campo2);
            printf("_campo3 = %s\n", _campo3);
        */
        if( strcmp( campo2, _campo2 ) == 0 )
        {
            return _campo1;
        }
    }
    if(feof(file))
    {            
         // puts("EOF");
         // printf("No se encontró en la tabla el campo buscado");
         
    }
    else
    {
         puts("CAN NOT READ TABLE");
    }
    
    
    // Cerrar arvhivo 
    fclose(file);
    
    // Abrir archivo en modo escritura
    file = fopen(filename, "a+");

    return NULL;
    
}

// Manejo de cadenas
void removeSubstring(char *s,const char *toremove)
{
  while( s=strstr(s,toremove) )
    memmove(s,s+strlen(toremove),1+strlen(s+strlen(toremove)));
}

// Manejo de clases

void identificador(char identificador[])
{
    // Si no se encuentra la el identificador en la tabla de simbolos: se agrega cadena a la tabla de simbolos
    if( select_campo1( tabla_simbolos , "tabla_simbolos.txt" , identificador ) == NULL)
    {
        char string_de_indice_de_tabla_simbolos[20];
        indice_de_tabla_simbolos++;
        sprintf( string_de_indice_de_tabla_simbolos, "%d", indice_de_tabla_simbolos);
        insert( tabla_simbolos, "tabla_simbolos.txt" , string_de_indice_de_tabla_simbolos, identificador, "", 0);
    }

    // Se crea el token con la clase 0 y la posición en la tabla de simbolos
    char *posicion = select_campo1( tabla_simbolos , "tabla_simbolos.txt" , identificador );
    insert( archivo_tokens , "tokens.txt", "0", posicion, "", 1);   

}

void constante_entera_decimal(char constante_entera_decimal[])
{
    // Se crea el token con clase 1 y valor en decimal
    insert(archivo_tokens, "tokens.txt" , "1", constante_entera_decimal, "", 1);
}

void cadena(char cadena[])
{

    removeSubstring( cadena , "\n" );
    // Si no se encuentra la cadena en la tabla de cadenas: se agrega cadena a la tabla de cadenas
    if( select_campo1( tabla_cadenas , "tabla_cadenas.txt" , cadena ) == NULL)
    {
        char string_de_indice_de_tabla_cadenas[20];
        indice_de_tabla_cadenas++;
        sprintf( string_de_indice_de_tabla_cadenas, "%d", indice_de_tabla_cadenas);
        insert( tabla_cadenas, "tabla_cadenas.txt" , string_de_indice_de_tabla_cadenas, cadena, "", 0);
    }

    // Se crea token con clase 2 y posicion en la tabla de cadenas
    char *posicion = select_campo1( tabla_cadenas , "tabla_cadenas.txt" , cadena ); 
    insert( archivo_tokens , "tokens.txt", "2", posicion, "", 1);
    
}

void palabra_reservada(char palabra_reservada[])
{
    // Guardar subcadena seguida del simbolo #
    sscanf(palabra_reservada, "#%s", palabra_reservada);
    
    // Si no se encuentra la cadena en la tabla de palabras reservada: se agrega cadena a la tabla de palabras reservadas
    if( select_campo1( tabla_palabras_reservadas , "tabla_palabras_reservadas.txt" , palabra_reservada ) == NULL)
    {
        char string_de_indice_de_tabla_palabras_reservadas[20];
        indice_de_tabla_palabras_reservadas++;
        sprintf( string_de_indice_de_tabla_palabras_reservadas, "%d", indice_de_tabla_palabras_reservadas);
        insert( tabla_palabras_reservadas, "tabla_palabras_reservadas.txt" , string_de_indice_de_tabla_palabras_reservadas, palabra_reservada, "", 0);
    }

    // Se crea token con clase 2 y posicion en la tabla de cadenas
    char *posicion = select_campo1( tabla_palabras_reservadas , "tabla_palabras_reservadas.txt" , palabra_reservada );
    insert( archivo_tokens , "tokens.txt", "3", posicion, "", 1);
    
}

void simbolo_especial(char simbolo_especial[])
{
    // Se crea token con clase 4 Y el simbolo especial en codigo ASCII
    char ascii_simbolo_especial[20];
    sprintf(ascii_simbolo_especial , "%d", simbolo_especial[0]);
    insert(archivo_tokens, "tokens.txt" , "4", ascii_simbolo_especial, "", 1);
    //insert(archivo_tokens, "tokens.txt" , "4", simbolo_especial, "", 1);
}

void constante_entera_octal(char constante_entera_octal[])
{
    // Se crea el token con clase 5 y valor en decimal
    int value;
    char string_value[20];
    sscanf( constante_entera_octal, "%o", &value);
    sprintf( string_value, "%d", value);
    insert( archivo_tokens , "tokens.txt", "5", string_value , "", 1);
}

void constante_entera_hexadecimal(char constante_entera_hexadecimal[])
{
    // Se crea el token con clase 7 y valor en decimal
    int value;
    char string_value[20];
    sscanf( constante_entera_hexadecimal, "0%[xX]%x", string_value , &value);
    sprintf( string_value, "%d", value);
    insert( archivo_tokens , "tokens.txt", "7", string_value , "", 1);

}

void operador_relacional(char operador_relacional[])
{
    // Se crea el token con clase 8 y la posición en la tabla de operadores relacionales
    char *posicion = select_campo1( tabla_operadores_relacionales, "tabla_operadores_relacionales.txt" , operador_relacional );
    insert(archivo_tokens, "tokens.txt" , "8", posicion, "", 1);
}

void error_lexico(char error_lexico[])
{
    printf("Error léxico en la linea %d\n Se encontró: %s\n", linea, yytext);
}