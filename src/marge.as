	TITLE  MARGIN <marge.as>

*
* JPC:A04
*   86/12/11: PD/JT test de validité du paramètre
* JPC:A06
*   87/04/18: PD/JT Réécriture
*   87/04/18: PD/JT Utilisation d'un bit et d'un buffer
*   87/04/18: PD/JT Modification de la syntaxe
*

**************************************************
* MARGIN
*
* But: faire sonner le HP-71 lorsque le curseur
*   arrive dans la position passee en parametre.
* Modifications=
*   Test du validite du parametre
*   Utilisation d'un bit et d'un buffer
*   Modification de la syntaxe
* Historique:
*   84/	 /  : M.M.	  conception
*   86/12/11: P.D.	  test de validite param.
*   87/04/18: P.D. & J.T. reconception & recodage
**************************************************

	REL(5) =MARGINd
	REL(5) =MARGINp
=MARGINe
*
* Y a t-il un parametre ?
*
	A=DAT0 B	A(B) := token suivant
	GOSBVL =EOLXCK	tEOL ?
	GOC    MARG20	tEOL atteint ==> MARGIN 0
*
* Il y a un parametre, il faut l'evaluer
*
	GOSBVL =EXPEX-	Evalue l'expression
	GOSBVL =RNDAHX	A(A) := parametre en hexa
	GONC   ivarg	erreur si parametre < 0
	LC(2)  96
	?A>C   B	parametre > 96 ?
	GOYES  ivarg	oui : erreur
*
* C(B) = 96
* A(B) = 0 <= parametre <= 96
*
	A=A-1  A
	GOC    MARG20	MARGIN 0
*
* Le parametre etait dans [1..96], on l'amene
* entre 0 et 95, on cree un buffer et on l'y met,
* puis on met le flag dans la Reserved Ram
*
	R0=A		R0 := parametre

	C=0    A
	LC(1)  2	2 quartets suffisent
	B=C    A
	LC(3)  =bMARGE
	GOSBVL =I/OALL

	A=R0
	DAT1=A B	buffer := parametre
*
* Reste a valider MARGIN en mettant a 1 le bit
*
	D0=(5) =MARGEr
	A=DAT0 P
	LC(1)  =MARGEm	masque
	A=A!C  P	bit := 1
	DAT0=A P
	GOTO   nxtstm

 MARG20
*
* Efface notre bit dans la Reserved Ram
*
	D0=(5) =MARGEr
	A=DAT0 P
	LC(1)  `=MARGEm
	A=A&C  P	Clear our bit
	DAT0=A P
*
* Desalloue le buffer
*
	LC(3)  =bMARGE
	GOSBVL =I/ODAL
*
* Retour a Basic
*
 nxtstm GOVLNG =NXTSTM	Fin d'execution ....

 ivarg	GOVLNG =ARGERR

	END
