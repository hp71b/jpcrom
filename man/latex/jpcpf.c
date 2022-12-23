#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

/*
 * Input file is encoded in HP-Roman8
 * Output file is encoded in UTF-8
 */

#define	MAXLINE	10000		// max number of char per line

#define	NTAB(t)	((int)(sizeof(t)/sizeof(t)[0]))

#define	BSLASH	1		// char to use instead of '\'
#define	BLEFT	2		// char to use instead of '{'
#define	BRIGHT	3		// char to use instead of '}'

#define	LEFTB	'{'
#define	RIGHTB	'}'

#define	THRESHOLD_SKIP	5	// threshold for vertical space

// these variables are modified with the "-d" option
int bslash = BSLASH ;
int leftb = LEFTB ;
int rightb = RIGHTB ;

enum state {
    S_NEWLINE,			// beginning of a new line
    S_NEWLFONT,			// { or } at the beginning of a new line
    S_DIRECTIVE,		// '.xxx' => directive
    S_NONE,			// line outside of a paragraph
    S_FONT,			// { or } in a line
    S_CENTER,			// center line
    S_CENTFONT,			// { or } in a centered line
    S_PARAGRAPH,		// paragraph
    S_PARAFONT,			// { or } in a paragraph
    S_BACKSLASH,		// '\' in a paragraph
} ;

int curfont = 'n' ;		// current font
int pffont = 'n' ;		// the font we should be in
int num_empty = 0 ;		// number of empty lines
int in_verbatim = 0 ;		// currently in pseudo-verbatim environment
int pf_explicit ;		// format as original pf source
int alt_charset = 0 ;		// alternate charset ('m' font)
int font_must_be_closed = 0 ;	// \textsubscript, \textsuperscript, \underline

enum state state ;
int oldbrace ;

char *roman8_utf8 [256] = {
    // 0-15, 0x0?
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    NULL, NULL, "\n", NULL,	NULL, NULL, NULL, NULL,
    // 16-31, 0x1?
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    // 32-47, 0x2?
    " ",  "!",  "\"", "\\#",	"\\$", "\\%", "\\&", "'",
    "(",  ")",  "*",  "+",	",",  "-",  ".",  "/",
    // 48-63, 0x3?
    "0" , "1" , "2" , "3" ,	"4" , "5" , "6" , "7" ,
    "8" , "9" , ":" , ";" ,	"<" , "=" , ">" , "?" ,
    // 64-79, 0x4?
    "@" , "A" , "B" , "C" ,	"D" , "E" , "F" , "G" ,
    "H" , "I" , "J" , "K" ,	"L" , "M" , "N" , "O" ,
    // 80-95, 0x5?
    "P" , "Q" , "R" , "S" ,	"T" , "U" , "V" , "W" ,
    "X" , "Y" , "Z" , "[" ,	"\\textbackslash{}", "]" , "\\textasciicircum{}", "\\_" ,
    // 96-111, 0x6?
    "`" , "a" , "b" , "c" ,	"d" , "e" , "f" , "g" ,
    "h" , "i" , "j" , "k" ,	"l" , "m" , "n" , "o" ,
    // 112-127, 0x7?
    "p" , "q" , "r" , "s" ,	"t" , "u" , "v" , "w" ,
    "x" , "y" , "z" , "\\{",	"|", "\\}", "\\textasciitilde{}", NULL,

    // 128-143, 0x8?
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    // 144-159, 0x9?
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    // 160-175, 0xa?
    " ",  "À" , "Â" , "È" ,	"Ê" , "Ë" , "Î" , "Ï" ,
    "\\'{ }", "\\`{ }", "\\textasciicircum{}", "\\\"{ }",	"\\textasciitilde{}", "Ù" , "Û" , "₤",
    // 176-191, 0xb?
    "¯" , "Ý" , "ý" , "°" ,	"Ç" , "ç" , "Ñ" , "ñ" ,
    "¡" , "¿" , "¤" , "£" ,	"¥" , "§" , "ƒ" , "¢" ,
    // 192-207, 0xc?
    "â" , "ê" , "ô" , "û" ,	"á" , "é" , "ó" , "ú" ,
    "à" , "è" , "ò" , "ù" ,	"ä" , "ë" , "ö" , "ü" ,
    // 208-223, 0xd?
    "Å" , "î" , "Ø" , "Æ" ,	"å" , "í" , "ø" , "æ" ,
    "Ä" , "ì" , "Ö" , "Ü" ,	"É" , "ï" , "ß" , "Ô" ,
    // 224-239, 0xe?
							
    "Á" , "Ã" , "ã" , "Ð" ,	"ð" , "Í" , "Ì" , "Ó" ,
    "Ò" , "Õ" , "õ" , "Š" ,	"š" , "Ú" , "Ÿ" , "ÿ" ,
    // 240-255, 0xf?
    "Þ" , "þ" , "·" , "µ" ,	"¶" , "¾" , "-" , "¼" ,
    "½" , "ª" , "º" , "«" ,	"■" , "»" , "±" , NULL ,
} ;

// alternative charset introduced by font 'm'
char *other_utf8 [256] = {
    [0xa1] = "$\\uparrow$",
    [0xa2] = "$\\leftarrow$",
    [0xa3] = "$\\downarrow$",
    [0xa4] = "$\\rightarrow$",
} ;

/******************************************************************************
 * Common function
 */

void
usage (char *argv0)
{
    fprintf (stderr, "usage: %s [-d]\n", argv0) ;
    exit (1) ;
}

/******************************************************************************
 * Output latex code corresponding to a Roman8 character
 */

void
putlatex (int c)
{
    char *p ;

    if (alt_charset)
	p = other_utf8 [c] ;
    else p = roman8_utf8 [c] ;

    if (p != NULL)
    {
	while (*p != '\0')
	{
	    switch (*p)
	    {
		case '\\' : putchar (bslash) ; break ;
		case '{' :  putchar (leftb)  ; break ;
		case '}' :  putchar (rightb) ; break ;
		default :   putchar (*p) ; break ;
	    }
	    p++ ;
	}
    }
}

/******************************************************************************
 * Find pure "pf" text
 */

// check if we enter a section where explicit pf formatting should be done
int
is_pf_explicit (const char *directive)
{
    // any text starting from these directives and ending with
    // any other directive is a pure pf source
    const char *direct [] = {
	"operation",
    } ;
    for (int i = 0 ; i < NTAB(direct) ; i++)
	if (strcmp (directive, direct [i]) == 0)
	    return 1 ;
    return 0 ;
}

/******************************************************************************
 * Vertical spacing
 */

void
vspace (void)
{
    double v ;

    if (num_empty >= 2)
    {
	v = num_empty ;
	if (v >= THRESHOLD_SKIP) 
	    v = THRESHOLD_SKIP + sqrt (v - THRESHOLD_SKIP) ;
	printf ("\n\n%cvspace%c%fex%c\n\n", bslash, leftb, v, rightb) ;
    }
    num_empty = 0 ;
}

/******************************************************************************
 * Verbatim text handling
 */

void
verbatim_start (void)
{
    if (! in_verbatim)
    {
	printf ("%cbegin%cjverb%c", bslash, leftb, rightb) ;
	in_verbatim = 1 ;
    }
}

void
verbatim_end (void)
{
    if (in_verbatim)
    {
	printf ("%cend%cjverb%c", bslash, leftb, rightb) ;
	in_verbatim = 0 ;
	// font_start (curfont) ;	// font may have been modified in the jverb env
    }
}

/******************************************************************************
 * Font handling
 */

int
is_fixedfont (int f)
{
    return strchr("cl", f) != NULL ;
}

void
font_open (const char *f)
{
    font_must_be_closed = 1 ;
    printf ("%c%s%c", bslash, f, leftb) ;
}

void
font_close_if_needed (void)
{
    if (font_must_be_closed)
    {
	putchar (rightb) ;
	font_must_be_closed = 0 ;
    }
}

void
font_start (int f)
{
    font_close_if_needed () ;

    alt_charset = 0 ;	// by default
    switch (f)
    {
	case 't' :		// title
	    font_open ("jchapter") ;
	    break ;
	case '^' :		// superscript
	    font_open ("textsuperscript") ;
	    break ;
	case 'v' :		// subscript
	    font_open ("textsubscript") ;
	    break ;
	case '-' :		// end superscript or subscript
	    // font already closed
	    break ;
	case '_' :		// underline
	    font_open ("underline") ;
	    break ;
	case 'm' :
	    alt_charset = 1 ;	// one unique exception for 'm' font
	    break ;
	case '1' :
	case '2' :
	case '3' :
	case '4' :
	    f = f - '1' + 'A' ;	// translate {1 to {A
	    // fall through
	default :
	    if (in_verbatim && ! is_fixedfont (f))
		verbatim_end () ;
	    printf ("%cF%c%c%c", bslash, f, leftb, rightb) ;
	    curfont = f ;
    }
}

void
font_end (void)
{
    font_close_if_needed () ;

    if (curfont != 'n')
	font_start ('n') ;
    curfont = 'n' ;
}

/******************************************************************************
 * Common brace handling for all states
 */

// Handle font change, whatever the current state is
void
brace_handling (int c, enum state from)
{
    switch (c)
    {
	case '{' :
	case '}' :
	    if (oldbrace == c)
	    {
		state = from ;
		// output \{ or \} (may be with substituted characters)
		printf("%c%c", bslash, (c == LEFTB ? leftb : rightb)) ;
	    }
	    else if (oldbrace == RIGHTB && c == LEFTB)
	    {
		// returning to normal font
		font_end () ;
		pffont = 'n' ;
		// don't modify state since we expect a new font
		oldbrace = c ;
	    }
	    else
	    {
		fprintf (stderr, "invalid %c%c sequence\n", oldbrace, c) ;
		state = from ;
		break ;
	    }
	    break ;
	default :
	    if (oldbrace == LEFTB)
	    {
		font_start (c) ;
		pffont = c ;
	    }
	    if (oldbrace == RIGHTB)
	    {
		font_end () ;
		pffont = 'n' ;
		ungetc (c, stdin) ;
	    }
	    state = from ;
	    break ;
    }
}

/******************************************************************************
 * main program
 */

int
main (int argc, char *argv [])
{
    int c ;
    int opt ;
    char directive [MAXLINE] ;
    int idxdirect ;
    int term = 0 ;

    // substitution characters
    bslash = BSLASH ;
    leftb = BLEFT ;
    rightb = BRIGHT ;

    while ((opt = getopt (argc, argv, "d")) != -1) {
	switch (opt)
	{
	    case 'd' :			// 'd'ebug => output '\', '{' and '}'
		bslash = '\\' ;
		leftb = '{' ;
		rightb = '}' ;
		break ;
	    default :
		usage (argv [0]) ;
	}
    }

    if (optind != argc)
	usage (argv [0]) ;

    state = S_NEWLINE ;
    num_empty = 0 ;
    in_verbatim = 0 ;
    term = 0 ;
    font_start ('n') ;
    putchar('\n') ;

    // By default, this is a pure pf text.
    // If this is a jpcrom manual page, the first directive will tell us.
    pf_explicit = 1 ;

    while (! term)
    {
	c = getchar () ;
	switch (state)
	{
	    case S_NEWLINE :	// at beginning of a new line
		switch (c)
		{
		    case '.' :
			verbatim_end () ;
			vspace () ;
			state = S_DIRECTIVE ;
			idxdirect = 0 ;
			curfont = 'n' ;
			num_empty = 0 ;
			break ;
		    case '\\' :
			verbatim_end () ;
			vspace () ;
			state = S_PARAGRAPH ;
			num_empty = 0 ;
			break ;
		    case '^' :
			verbatim_end () ;
			vspace () ;
			state = S_CENTER ;
			printf ("%cbegin%ccenter%c\n", bslash, leftb, rightb) ;
			num_empty = 0 ;
			break ;
		    case '{' :
		    case '}' :
			oldbrace = c ;
			state = S_NEWLFONT ;
			break ;
		    case '\n' :		// at least one empty line
			// don't change state, just count empty lines
			putchar ('\n') ;
			num_empty++ ;
			break ;
		    case EOF :
			verbatim_end () ;
			term = 1 ;
			break ;
		    default :
			state = S_NONE ;
			vspace () ;
			if (is_fixedfont (curfont))
			    verbatim_start () ;
			putlatex (c) ;
		}
		break ;
	    case S_NEWLFONT :	// { or } at the beginning of a line
		if (c == EOF)
		    term = 1 ;
		else brace_handling (c, S_NEWLINE) ;
		break ;
	    case S_DIRECTIVE :	// line to output as is
		switch (c)
		{
		    case EOF :
			term = 1 ;
			break ;
		    case '\n' :
			directive [idxdirect] = '\0' ;
			printf ("\n.%s\n", directive) ;
			pf_explicit = is_pf_explicit (directive) ;
			state = S_NEWLINE ;
			break ;
		    default :
			if (isalpha (c) || c == ' ')
			    directive [idxdirect++] = c ;
			else	// starting with '.', but not a directive
			{
			    // assume that ungetc is able to push > 1 char
			    for (int i = idxdirect-1 ; i >= 0 ; i--)
				ungetc (directive [i], stdin) ;
			    putlatex ('.') ;
			    state = S_NONE ;
			}
		}
		break ;
	    case S_NONE :	// line to output as is
		switch (c)
		{
		    case '{' :
		    case '}' :
			oldbrace = c ;
			state = S_FONT ;
			break ;
		    case '\n' :
			if (pf_explicit && ! in_verbatim)
			    putchar (c) ;	// 2*\n => \par
			putchar (c) ;
			state = S_NEWLINE ;
			num_empty = 0 ;
			break ;
		    case EOF :
			term = 1 ;
			break ;
		    default :
			putlatex (c) ;
		}
		break ;
	    case S_FONT :	// { or } inside a normal line
		if (c == EOF)
		    term = 1 ;
		else brace_handling (c, S_NONE) ;
		break ;
	    case S_PARAGRAPH :	// inside a paragraph
		switch (c)
		{
		    case '{' :
		    case '}' :
			oldbrace = c ;
			state = S_PARAFONT ;
			break ;
		    case '\n' :
			putchar (' ') ;
			break ;
		    case '\\' :
			state = S_BACKSLASH ;
			break ;
		    case EOF :
			term = 1 ;
			break ;
		    default :
			putlatex (c) ;
		}
		break ;
	    case S_BACKSLASH :
		switch (c)
		{
		    case '\n' :
			printf ("\n%cpar\n", bslash) ;
			state = S_NEWLINE ;
			break ;
		    case EOF :
			printf ("\n%cpar\n", bslash) ;
			term = 1 ;
			break ;
		    default :
			putlatex ('\\') ;
			ungetc (c, stdin) ;
			state = S_PARAGRAPH ;
			break ;
		}
		break ;
	    case S_PARAFONT :	// { or } in a paragraph
		if (c == EOF)
		    term = 1 ;
		else brace_handling (c, S_PARAGRAPH) ;
		break ;
	    case S_CENTER :
		switch (c)
		{
		    case '{' :
		    case '}' :
			oldbrace = c ;
			state = S_CENTFONT ;
			break ;
		    case '\n' :
			printf ("\n%cend%ccenter%c\n", bslash, leftb, rightb) ;
			state = S_NEWLINE ;
			break ;
		    case EOF :
			printf ("\n%cend%ccenter%c\n", bslash, leftb, rightb) ;
			term = 1 ;
			break ;
		    default :
			putlatex (c) ;
		}
		break ;
	    case S_CENTFONT :	// { or } in a paragraph
		if (c == EOF)
		    term = 1 ;
		else brace_handling (c, S_CENTER) ;
		break ;
	    default :
		fprintf (stderr, "invalid state %d sequence\n", state) ;
		break ;
	}
    }
}
