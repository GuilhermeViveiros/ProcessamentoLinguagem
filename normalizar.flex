%{
//escape 
//Serve para declarar variaveis ou bibliotecas
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include "Noticia.h"

GTree *noticias;
Noticia x;

%}

%x ARTIGO
%x TAG
%x DATE
%x ID
%x CATEGORY
%x TITLE
%x TEXT

%%


\<pub\> {ECHO; x = initNoticia(); BEGIN ARTIGO;}

<ARTIGO>\</pub\> {ECHO; BEGIN INITIAL;}
<ARTIGO>\n{3,} {printf("\n\n");}//tira todas as linhas em branco desnecessárias
<ARTIGO>(.|\n) {ECHO;}//imprime tudo o resto
<ARTIGO>#TAG: {ECHO; BEGIN TAG;}
<ARTIGO>#DATE: {ECHO; BEGIN DATE;}

<TAG>tag:\{[A-Z a-z]* {ECHO;addTag(x,yytext+5);}
<TAG>#ID: {ECHO; BEGIN ID;}

<ID>post-[0-9]+ {ECHO;addId(x,yytext);}
<ID>\n {ECHO;BEGIN CATEGORY;}


<CATEGORY>.* {ECHO; addCategory(x,yytext);}
<CATEGORY>\n\n {ECHO; BEGIN TITLE;}

<TITLE>.* {ECHO; addTitle(x,yytext);BEGIN ARTIGO;}


<DATE>.* {ECHO; addDate(x,yytext+8);}
<DATE>\n\n {ECHO;printf("TEXTO\n");BEGIN TEXT;}

<TEXT>\^$ {ECHO;printf("1 found\n");}
<TEXT>(.*)\n\n {ECHO;printf("2 found\n");}
<TEXT>\n{3,} {BEGIN ARTIGO;}




(.*) {;}//tudo o que não tiver entre pub é removido
(\n{3,}) {printf("\n\n");}//linhas em branco extra são removidas
%%


int yywrap(){
    return 1;
}

gint compareIds (gconstpointer name1, gconstpointer name2)
{
    printf("strcmp: %d\n", strcmp (name1, name2));
    return (strcmp (name1 , name2));
}

int main(int argc, char *argv[]){
    
    noticias = g_tree_new((GCompareFunc) compareIds);
    Noticia x = initNoticia();
    char* id = "dasdasdsa";
    addId(x,id);
    addTag(x,"coisas");
    addTag(x,"ola");
    g_tree_insert(noticias, id, x);
    gpointer ptr = g_tree_lookup(noticias, (gconstpointer) id);
    Noticia n = (Noticia) ptr;

    printf("%d\n", (int) g_tree_nnodes (noticias) );
    printf("Noticia x:");
    printAll(x);
    printf("Noticia n:");
    printAll(n);

    printf("Inicio da filtragem\n");

    yylex(); //invocar a função de conhecimento que ele vai gerar para janeiro e os outros

    printf("Fim da filtragem\n");

    
    return 0;
}
