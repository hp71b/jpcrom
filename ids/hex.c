/*
 * Imprime un "Saturn Hex Code Listing"
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define	NCAR	64

void Imprimer () ;

char tab [NCAR] ;

void Imprimer (long adr, char *tab, int n)
{
    static int saut = 0 ;
    int i ;

    if (saut % 4 == 0 && saut != 0)
	putchar ('\n') ;
    saut++ ;

    printf ("%05lX -", adr) ;

    for (i = 0 ; i < n ; i++)
    {
	if (i % 8 == 0)
	    putchar (' ') ;
	putchar (tab [i]) ;
    }

    putchar ('\n') ;
}

int main (int argc, char *argv [])
{
    int i ;
    int c ;
    int n ;
    long adr ;

    for (i = 0; i < 4; i++)
	(void) getchar () ;

    n = 0 ;
    adr = 0 ;
    while ((c = getchar ()) != EOF)
    {
	tab [n++] = c ;

	if (n == NCAR)
	{
	    Imprimer (adr, tab, n) ;
	    n = 0 ;
	    adr += NCAR ;
	}
    }

    if (n != 0)
	Imprimer (adr, tab, n) ;

    exit (0) ;
}
