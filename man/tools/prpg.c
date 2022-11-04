#include <stdio.h>

#define PRINT			/* pour imprimer sur l'imprimante */

typedef unsigned char uchar ;

#define LARGEUR	70		/* mm de large */
#define REPFONT	"pg"
#define HAUTEUR	140		/* mm de haut */
#define MARGE	28		/* marge gauche È ... mm du bord */
#define NLIGNES	43		/* lignes par page */

#define	TAILLE	40		/* nb de lignes de texte par page */

#define NCOPYR	7
#define COPYRIGHT	"\n\n^{cPPC Paris\n\n^{kB.P. 604 - 75028 Paris \
Cedex 01 - France\n\n^(c) PPC Paris, 1988, 1989\n"

/*
 * formatter le fichier
 * lire chaque page et la ranger en memoire
 * pour toutes les feuilles
 *   faire
 *     imprimer deux pages
 * fin pour
 */

int npages = 0 ;		/* nombre de pages */
uchar *file, *prog ;
uchar tab [65536] ;		/* le tableau */
uchar *tabpt [200] ;		/* pointeurs sur les debuts des pages */

uchar *ptab, **ptabpt ;

int tpage, tpara, first ;
uchar aux [10240], *paux ;		/* un paragraphe */

#define ERRUSA	1
#define	ERRPIP	2
#define	ERRCLO	3
#define	ERRRD	4

main (argc, argv)
int argc ;
uchar *argv [] ;
{
    FILE *fp ;
    uchar cmd [1024] ;

    if (argc != 2) error (ERRUSA, "") ;

    prog = argv [0] ;
    file = argv [1] ;

    sprintf (cmd, "pf -l%d -f%s %s\n", LARGEUR, REPFONT, file) ;
    if ((fp = popen (cmd, "r")) == NULL)
	error (ERRPIP, "pf") ;
    lire_texte (fp) ;
    if (pclose (fp)) error (ERRCLO, "pipe through pf") ;

    copyright () ;

#if defined (PRINT)
    sprintf (cmd, "pf -l%d -f%s -e|imp -l%d -f%s -h%d -n%d -c2 -m%d\n",
	     LARGEUR, REPFONT,
	     LARGEUR, REPFONT, HAUTEUR, NLIGNES, MARGE) ;
    if ((fp = popen (cmd, "w")) == NULL)
	error (ERRPIP, "pf|imp") ;

    envoi_texte (fp) ;

    if (pclose (fp)) error (ERRCLO, "pipe through pf|imp") ;
#else
    fp = stdout ;
    envoi_texte (fp) ;
#endif

    exit (0) ;
}

error (code, msg)
int code ;
uchar *msg ;
{
    uchar tmp [200] ;
    int perr = 0 ;

    switch (code)
    {
	case ERRUSA :
	    sprintf (tmp, "usage : %s <file>", prog) ;
	    break ;
	case ERRPIP :
	    sprintf (tmp, "cannot pipe through %s\n", msg) ;
	    break ;
	case ERRCLO :
	    sprintf (tmp, "cannot close %s\n", msg) ;
	    break ;
	case ERRRD :
	    sprintf (tmp, "cannot read %s\n", msg) ;
	    break ;
	default :
	    sprintf (tmp, "internal error (%x)", code) ;
	    break ;
    }

    if (perr)
    {
	uchar ligne [200] ;
	sprintf (ligne, "%s: %s", prog, tmp) ;
	perror (ligne) ;
    }
    else printf (stderr, "%s: %s\n", prog, tmp) ;
    exit (1) ;
}

lire_texte (fp)
FILE *fp ;
{
    register c ;
    register etat = 0 ;

    ptabpt = tabpt ;
    ptab = *ptabpt++ = tab ;
    paux = aux ;
    tpara = tpage = 0 ;
    first = 1 ;
    npages = 0 ;

    while ((c = getc (fp)) != EOF)
    {
	if (etat)
	{
	    etat = 0 ;
	    if (c != '\n') stocker_car (c) ;
	    else
	    {
		if (tpage + tpara + 1 > TAILLE)	/* page terminee ? */
		    end_page () ;
		insert_paragraphe () ;		/* admettre le paragraphe */
	    }
	}
	else
	{
	    if (c == '\n')
	    {
		tpara++ ;
		etat = 1 ;
	    }
	    stocker_car (c) ;		/* cas general */
	}
    }

    if (ferror (fp)) error (ERRRD, "pipe trhough pf") ;

    /* recopier le dernier morceau */

    if (etat)
    {
	if (tpage + tpara + 1 > TAILLE)	/* page terminee ? */
	    end_page () ;
	insert_paragraphe () ;		/* admettre le paragraphe */
    }
}

stocker_car (car)
int car ;
{
    *paux++ = (uchar) car ;
}

end_page ()
{
    int i ;

    for (i=tpage; i<TAILLE; i++)
	*ptab++ = '\n' ;
    *ptabpt++ = ptab ;		/* debut nouveau paragraphe */

    tpage = 0 ;
    first = 1 ;
    npages++ ;			/* une page de plus */
}

insert_paragraphe ()
{
    uchar *p ;

    if (!first)
    {
	*ptab++ = '\n' ;
	tpage++ ;
    }
    p = aux ;
    while (p < paux) *ptab++ = *p++ ;

    first = 0 ;
    tpage += tpara ;
    tpara = 0 ;
    paux = aux ;
}

copyright ()
{
    int n, mod, max ;
    uchar *p ;

    n = npages * TAILLE + tpage + NCOPYR ;

    mod = 4 * TAILLE ;
    max = (((n-1) / mod) + 1) * mod ;

    n -= NCOPYR ;
    for (; n<max-NCOPYR; n++)
    {
	if (n % TAILLE == 0)
	{
	    *ptabpt++ = ptab ;
	    npages++ ;
	}
	*ptab++ = '\n' ;
    }

    first = 1 ;				/* pas de saut intempestif */

    p = (uchar *) COPYRIGHT ;
    while (*p)
	stocker_car (*p++) ;
    tpara = NCOPYR ;
    insert_paragraphe () ;

    *ptabpt++ = ptab ;
    npages++ ;
}

envoi_texte (fp)
FILE *fp ;
{
    int i, j ;

    i = 1 ; j = npages ;

    while (i < j)
    {
	if (i % 2)		/* i impair */
	{
	    envoi_page (fp, j) ;	/* page paire */
	    envoi_page (fp, i) ;	/* page impaire */
	}
	else
	{
	    envoi_page (fp, i) ;	/* page paire */
	    envoi_page (fp, j) ;	/* page impaire */
	}
	i++ ; j-- ;
    }
}

envoi_page (fp, n)
FILE *fp ;
int n ;
{
    uchar *p, *max ;

    max = tabpt [n] ;		/* borne sup */
    p = tabpt [n-1] ;		/* borne inf */

    while (p < max)
    {
	putc (*p, fp) ;
	p++ ;
    }

    putc ('\n', fp) ;
    putc ('\n', fp) ;
    if (n != 1 && n != npages)
	fprintf (fp, "^}%d", n) ;
    putc ('\n', fp) ;
}
