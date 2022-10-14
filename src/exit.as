	TITLE  EXIT <exit.as>

*
* JPC:A05
*   87/03/03: JT/PD extraction de EXIT de struc.as
*

*******************************
* Statement: EXIT loop index  *
*******************************
*
* NOTE: this version does not allow EXIT from keyboard
*
* FOR-NEXT stack structure:
*
* Low memory
*
*   5 nibs    Return address (D0)
*  16 nibs    Step value
*  16 nibs    Limit
*   2 nibs    ASCII letter or alpha-digit
*   2 nibs    00 or ASCII letter
*
* High memory
*
	REL(5) =EXITd
	REL(5) =EXITp

* the following code from INDXSN (#0897A) unsupported
* entry point

=EXITe
	ST=1   8	alpha-digit variable flag
	A=DAT0 4	read in index variable from prgm
	LCASC  'ZA'
	GOSBVL =RANGE
	P=     3
	GOC    indx02
	ST=0   8	single-character alpha digit
	B=0    A
	P=     1
 indx02 B=A    WP
	P=     3
	D1=(5) =FORSTK
	C=DAT1 A
	R0=C		save ptr to top of FOR-NEXT stack
	D1=D1+ 5
	A=DAT1 A	ptr to bottom of FOR-NEXT stack
 indx04 D1=C
	?C>=A  A	end of search?
	GOYES  indx07
	D1=D1+ 16
	D1=D1+ 16
	D1=D1+ 5
	C=DAT1 A	read variable from stack
	?B=C   WP	ok?
	GOYES  indx08
	D1=D1+ 4
	CD1EX
	GONC   indx04	B.E.T.
 indx07 P=P-1		clear carry
 indx08 P=     0

* End of INDXSN code

	GONC   efwo
	R0=C		save variable name in R0
	D1=D1+ 4	D1 @ bottom of entry
	AD1EX		collapse all preceeding entries
	D1=(5) =AVMEME	.
	DAT1=A A	.
	D1=D1+ (=FORSTK)-(=AVMEME)
	DAT1=A A	.
	 
	D1=(5) =PRGMEN	set D[A] for TKSCN7
	C=DAT1 A	.
	D=C    A	.
    
	P=     3
	?ST=1  8	alpha digit variable ?
	GOYES  exit01
	P=     1
 exit01 CPEX   15
	D0=D0- 4	for tXWORD and lex ID
 exit10 D0=D0- 4	D0 @ len byte (past token and len)
* reuse LINSKP (skip to t@ or tEOL)
	A=0    A
	A=DAT0 B	line length
	B=A    A
	AD0EX
	A=A+B  A	points to EOL or @
	D0=A
	P=     0
	LC(2)  =tNEXT	. in buffer limits ?
	GOSBVL =TKSCN7
	GOC    exit02	token found
 efwo	LC(2)  =eFwoNX
	GOVLNG =MFERR
 exit02 P=C    15
	A=R0		restore	 EXIT variable name
	D0=D0+ 2	point to current NEXT variable
	C=DAT0 WP
	?A#C   WP
	GOYES  exit10	try next NEXT
	D0=D0- 4
* reuse NXTST2 (#08A58)
	A=0    A
	A=DAT0 B	read stmt length
	CD0EX
	A=A+C  A
	D0=A
	GOVLNG =RUNRTN

	END
