#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

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

// these variables are modified with the "-d" option
int bslash = BSLASH ;
int leftb = LEFTB ;
int rightb = RIGHTB ;

enum state {
    S_NEWLINE,			// beginning of a new line
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
    "X" , "Y" , "Z" , "[" ,	"\\textbackslash{}", "]" , "{\\^{ }}", "\\_" ,
    // 96-111, 0x6?
    "`" , "a" , "b" , "c" ,	"d" , "e" , "f" , "g" ,
    "h" , "i" , "j" , "k" ,	"l" , "m" , "n" , "o" ,
    // 112-127, 0x7?
    "p" , "q" , "r" , "s" ,	"t" , "u" , "v" , "w" ,
    "x" , "y" , "z" , "\\{",	"|", "\\}", "\\~{ }", NULL,

    // 128-143, 0x8?
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    // 144-159, 0x9?
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL,	NULL, NULL, NULL, NULL,
    // 160-175, 0xa?
    " ",  "À" , "Â" , "È" ,	"Ê" , "Ë" , "Î" , "Ï" ,
    "\\'{ }", "\\`{ }", "\\^{ }", "\\\"{ }",	"\\~{ }", "Ù" , "Û" , "₤",
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

// alternative charset introduced by {m sequence
char *other_utf8 [256] = {
    [0xa1] = "$\\uparrow$",
    [0xa2] = "$\\leftarrow$",
    [0xa3] = "$\\downarrow$",
    [0xa4] = "$\\rightarrow$",
} ;

int alternate_charset = 0 ;

void
usage (char *argv0)
{
    fprintf (stderr, "usage: %s [-d]\n", argv0) ;
    exit (1) ;
}

void
putlatex (int c)
{
    char *p ;

    if (alternate_charset)
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

// check if we enter a section where explicit pf formatting should be done
int
is_pf_explicit (const char *directive)
{
    const char *direct [] = {
	".operation",
    } ;
    for (int i = 0 ; i < NTAB(direct) ; i++)
	if (strcmp (directive, direct [i]) == 0)
	    return 1 ;
    return 0 ;
}

int font_must_be_closed = 0 ;	// \textsubscript, \textsuperscript, \underline

int
fixedfont (int f)
{
    return strchr("cl", f) != NULL ;
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

    switch (f)
    {
	case '^' :		// superscript
	    font_must_be_closed = 1 ;
	    alternate_charset = 0 ;
	    printf ("%ctextsuperscript%c", bslash, leftb) ;
	    break ;
	case 'v' :		// subscript
	    font_must_be_closed = 1 ;
	    alternate_charset = 0 ;
	    printf ("%ctextsubscript%c", bslash, leftb) ;
	    break ;
	case '-' :		// end superscript or subscript
	    alternate_charset = 0 ;
	    break ;
	case '_' :		// underline
	    font_must_be_closed = 1 ;
	    alternate_charset = 0 ;
	    printf ("%cunderline%c", bslash, leftb) ;
	    break ;
	case 'm' :
	    alternate_charset = 1 ;
	    break ;
	case '1' :
	case '2' :
	case '3' :
	case '4' :
	    f = f - '1' + 'A' ;	// translate {1 to {A
	    // fall through
	default :
	    printf ("%c%c%cF%c%c%c", leftb, rightb, bslash, f, leftb, rightb) ;
	    alternate_charset = 0 ;
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

void
verbatim_start (void)
{
    if (! in_verbatim)
    {
	printf ("%cbegin{jverb}", bslash) ;
	in_verbatim = 1 ;
    }
}

void
verbatim_end (int num_empty)
{
    if (in_verbatim)
    {
	printf ("%cend{jverb}\n", bslash) ;
	printf ("%cpar\n", bslash) ;
	in_verbatim = 0 ;
	font_start (curfont) ;	// font may have been modified in the jverb env
    }
    for (int i = 0 ; i < num_empty ; i++)
	putchar ('\n') ;
}

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
	    case 'd' :
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
			verbatim_end (num_empty) ;
			state = S_DIRECTIVE ;
			putlatex (c) ;
			idxdirect = 0 ;
			directive [idxdirect++] = c ;
			num_empty = 0 ;
			break ;
		    case '\\' :
			verbatim_end (num_empty) ;
			state = S_PARAGRAPH ;
			num_empty = 0 ;
			break ;
		    case '^' :
			verbatim_end (num_empty) ;
			state = S_CENTER ;
			printf ("%cbegin{center}\n", bslash) ;
			num_empty = 0 ;
			break ;
		    case '{' :
		    case '}' :
			oldbrace = c ;
			state = S_FONT ;
			break ;
		    case '\n' :		// at least one empty line
			// don't change state, just count empty lines
			if (in_verbatim)
			{
			    verbatim_end (0) ;
			    num_empty = 0 ;
			} else {
			    putchar (c) ;
			}
			num_empty++ ;
			break ;
		    case EOF :
			verbatim_end (num_empty) ;
			term = 1 ;
			break ;
		    default :
			state = S_NONE ;
			if (num_empty >= 1 && fixedfont (curfont))
			    verbatim_start () ;
			putlatex (c) ;
		}
		break ;
	    case S_DIRECTIVE :	// line to output as is
		switch (c)
		{
		    case EOF :
			term = 1 ;
			break ;
		    case '\n' :
			putchar (c) ;
			state = S_NEWLINE ;
			directive [idxdirect] = '\0' ;
			pf_explicit = is_pf_explicit (directive) ;
			break ;
		    default :
			putchar (c) ;
			directive [idxdirect++] = c ;
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
			printf ("\n%cend{center}\n", bslash) ;
			state = S_NEWLINE ;
			break ;
		    case EOF :
			printf ("\n%cend{center}\n", bslash) ;
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
