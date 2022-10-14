	TITLE  STACKLEX <stack.as>

*
* JPC:B03
*   87/12/08: PD/JT Integration de STACK de Henri Kudelski
*     la bug etait : 10 SUB ML
*		     20 STACK 13
*		     30 COPY TOTO  (n'importe quel fichier)
*		     40 END SUB
*     Un ML renvoyait un curseur non clignotant, puis un
*     ML total...
*

	REL(5) =STACKd
	REL(5) =STACKp
=STACKe
	GOSBVL =EXPEXC
	GOSBVL =RNDAHX
	GOC    ARGOK
 argerr GOVLNG =ARGERR
 ARGOK	LCHEX  1001
	GOSBVL =RANGE
	GOC    argerr
	A=A-1  A
	D0=(5) =MAXCMD
	DAT0=A 1
	D0=(5) =IOBFEN
	C=DAT0 A
	D0=C
	LCHEX  003000
 CMD1	DAT0=C 6
	D0=D0+ 6
	A=A-1  A
	GONC   CMD1
	AD0EX
	D0=(5) =RFNBFR
	LC(2)  5
*
* Change les pointeurs
* - RFNBFR
* - RAWBFR
* - CLCSTK
* - SYSEN
* - OUTBS
* - AVMEMS
*
 CMD2	DAT0=A A
	D0=D0+ 5
	C=C-1  B
	GONC   CMD2
	GOVLNG =NXTSTM

	END
