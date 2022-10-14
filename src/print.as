	TITLE  PRINTLEX <print.as>

*
* 86/10/23: PD LF [ <par> ]
*		  PREND a la fin de PR-BAS/PR-RTN
*		  ordre de l'envoi dans PL
*		  ESC$ [ ( <str> ) ]
* JPC:A03
*   86/11/05: PD    Corrige le bug de ESC$(<str>)
* JPC:A06
*   87/05/01: PD/JT Renommage (pCR pFF pLF et PageLen)
*   87/05/01: PD/JT Changement de la séquence de BOLD
*

**************************************************
* PRINT
* But: Cette routine imprime la chaine pointee par
* la premiere adresse de la pile de retours.
* Le retour peut s'effectuer de deux manieres:
* - PR-BAS: retour a Basic
* - PR-RTN: retour a la routine appelante.
*
* Principe:
* Le poll pPRTIS est envoye, pour etre intercepte
* par l'HPIL. Celui-ci renvoie l'adresse de la
* routine PRASC qui se chargera de l'impression.
*
* Schema de l'appel:
*	GOSUB  PR-BAS (ou PR-RTN)
*	CON(1) n
*	CON(2) C1
*	 :
*	CON(2) Cn
* NB: utilise R0, R2, R3
**************************************************
 
 PR-BAS ST=0   4	Le retour se fera selon
	GOTO   print	l'etat du flag 4 (4 parce
 PR-RTN ST=1   4	les autres etaient deja
 print	P=     0	utilises...)
	SETHEX
	GOSBVL =POLL
	CON(2) =pPRTIS	Envoi du Poll
	?XM=0		A-t-il ete intercepte ?
	GOYES  noerr	Oui: pas d'erreur
	LC(2)  =eDVCNF	Non: "Unite non trouvee"
	GOVLNG =MFERR
 noerr
*************************
* Modification du <861023.2238>
*
* Clean-up de la boucle apres l'envoi des ordres
*
* Calcul de l'adresse de la routine PREND
*
	D1=A		D1 := ^ code de PRASCI
	D1=D1- 5	D1 := ^ (REL(5) =PREND)
	C=DAT1 A	C(A) := REL(5)
	B=C    A	B(A) := REL(5)
	CD1EX		C(A) := ^ #F107A
	C=C+B  A	C(A) := ^ code de PREND
	R0=C
*
* Fin de la modification
*************************
	C=RSTK		Adresse de la table
	D1=C		dans D1
	C=C+1  A	C: ^ premier caractere
	D=C    A	D=ad. du premier caractere
	GOSUB  ici1	Pour avoir la position du
 ici1	C=RSTK		pointeur programme.
	B=C    A
	LC(5)  (ret1)-(ici1)
	C=C+B  A	C=adresse de retour
	RSTK=C		empilee
 
* Apres le poll pPRTIS, si celui-ci est intercepte
* par l'HPIL, nous avons l'adresse de la routine
* qui se chargera de l'impression dans A(A).
*
* Le seul moyen, a ma connaissance, pour faire un
* GOTO a une adresse variable est d'empiler cette
* adresse  dans la pile de retour,  puis de faire
* un RTN.
 
	C=A    A
	RSTK=C
	A=0    A
	A=DAT1 1	A(A)= nb de caracteres.
	RTN		<=> GOTO A(A)
 ret1
*************************
* Modification du <861023.2240>
*
* Clean-up effectif :
*
	GOSUB  ici2
 ici2	C=RSTK
	A=C    A
	LC(5)  (ret2)-(ici2)
	C=C+A  A
	RSTK=C		RSTK := ^ ret2
	C=R0
	RSTK=C		RSTK := ^ PREND
	CD1EX
	R0=C
	RTN		GOVLNG =PREND
 ret2
	P=     0	(P may be non 0 en sortie de PREND)
	?ST=0  4
	GOYES  nxtstm	Retour a l'appelant
	C=R0
	RSTK=C
	RTN
 nxtstm GOVLNG =NXTSTM	sinon retour a Basic
*
* Fin de la modification
*************************
 
 
**************************************************
* onoff?
* But: tester le token suivant:
* Sortie: Cy=1 si tON, Cy=0 sinon
**************************************************
 onoff? A=DAT0 S
	?A=0   S
	RTNYES	       Retour avec Carry=1
	RTN	       Avec Cy=0
 

**************************************************
*		     BELL			 *
**************************************************

	REL(5) =BELLd
	REL(5) =BELLp
=BELLe	GOSUB  PR-BAS
	CON(1) 1       1 seul caractere
	CON(2) 7       code 7

**************************************************
*		   BOLD ON|OFF			 *
**************************************************
	REL(5) =ONOFFd
	REL(5) =ONOFFp
=BOLDe	GOSUB  onoff?	ON ou OFF ?
	GOC    boldon	-> ON
	GOSUB  PR-BAS	-> OFF
	CON(1) 5	5 caracteres
	CON(2) 27
	NIBASC '(s0B'	BOLD OFF
 boldon GOSUB  PR-BAS
	CON(1) 5
	CON(2) 27
	NIBASC '(s1B'	BOLD ON
 
**************************************************
*		      CR			 *
**************************************************
	REL(5) =CRd
	REL(5) =CRp
=PCRe	GOSUB  cr	CR est aussi utilise dans
	GOTO   nxtstm	LF et FF
 
**************************************************
* cr
* But: envoyer un retour-chariot, et remettre la
* position de la tete d'ecriture a 0.
* Note: la position de la tete d'ecriture est
* gardee en memoire par le HP71. Elle est utilisee
* par TAB.
**************************************************
 cr	D1=(5) =PPOS	Printer POSition
	C=0    B
	DAT1=C B	PPOS=0 (TAB=0)
	GOSUB  PR-RTN	Impression avec retour...
	CON(1) 1
	CON(2) 13
	RTN
 
**************************************************
*		     ESC$			 *
**************************************************
*	 NIBHEX 00	 Fonction sans parametre
	NIBHEX 4
	NIBHEX 01	0 mini, 1 maxi
=ESCe	?C#0   S
	GOYES  ESC20
	CD1EX		D1=pointeur de pile math.
	R1=C		dans R1 pour ADHEAD
	D1=C
	D1=D1- 2
	P=     0
	LC(2)  27	ESC
	DAT1=C B
 ESC10	GOSBVL =D=AVMS	requis par Basic
	ST=0   0	Pas de retour
	GOVLNG =ADHEAD	Ajout de l'en-tete

 ESC20	CD0EX
	RSTK=C
	GOSBVL =POP1S
	CD1EX		D1 := ^ fin de premiere chaine

	D0=C		Start of source

	D1=C
	D1=D1- 2	Start of dest

	R2=C		R2 := ^ fin 1ere chaine (TF1, Ah Ah)
	C=C+A  A	C(A) := ^ debut de chaine
	B=A    A	B(A) := block length
	R1=C		R1 := ^ debut de chaine
	GOSBVL =MOVEU0

	C=R2
	D1=C
	D1=D1- 2	Top of Math-Stack
	C=R1
	D0=C
	D0=D0- 2
	LC(2)  27
	DAT0=C B

	C=RSTK
	D0=C
	GONC   ESC10	B.E.T.
	
	
 
**************************************************
*		      FF			 *
**************************************************
	REL(5) =FFd
	REL(5) =FFp
=PFFe	GOSUB  cr	On remet d'abord PPOS a 0
	GOSUB  PR-BAS	et on envoie...
	CON(1) 1	...un caractere...
	CON(2) 12	...de code 12

 Argerr GOTO   argerr
 
**************************************************
*		   LF [num]			 *
**************************************************
	REL(5) =PLFd
	REL(5) =PLFp
=PLFe
	A=DAT0 B
	GOSBVL =EOLXCK
*************************
* Modification du <861023.2000>
*
*
	A=0    A
	GONC   lf05
	A=A+1  A
	GONC   noexpr	B.E.T.

 lf05	GOSBVL =EXPEX-
	GOSBVL =RNDAHX
	GONC   Argerr

 noexpr R1=A
	GOSUB  cr
	GOTO   lf20
 lf10	R1=A
	GOSUB  PR-RTN
	CON(1) 1
	CON(2) 10
 lf20	A=R1
	A=A-1  A
	GONC   lf10
	GOTO   nxtstM
*
* Fin de la modification
***************************

 ARgerr GOTO   argerr
 
**************************************************
*		  MODE <num>			 *
**************************************************
	REL(5) =NUMd
	REL(5) =NUMp	Un param. num. obligatoire
=MODEe	GOSUB  evalex	evaluation de ce parametre
	C=0    W
	C=A    WP	Ici, on a P=0
	?A#C   W	nb > 9 ?
	GOYES  ARgerr
	SETHEX
	LCASC  '0'	Conversion en Ascii
	A=A+C  B
	GOSBVL =ASLW4	Decalage a gauche de 7
	GOSBVL =ASLW3	quartets
	LCHEX  53006B261B5    ESC '&k_S'
 
* A ce niveau, il est bien important de voir ce
* que l'on a dans les registres:
*
* C(W)= x x x x x 5 3 0 0 6 B 2 6 1 B 5
* A(W)= 0 0 0 0 0 0 0 3 n 0 0 0 0 0 0 0 (MODE n)
*
* L'addition de A et C nous donne bien evidemment
* la bonne sequence d'echappement.
*
* C va alors etre transfere en memoire (AVMEMS),
* afin d'etre envoye a PRASC
 
	C=C+A  W
	GOSBVL =D0=AVS	D0 recoit AVMEMS
	DAT0=C 11	La table est creee a cet
	CD0EX		endroit, pointe par D0.
	RSTK=C		On simule un GOSUB.
	GOTO   PR-BAS
 
**************************************************
*		  PERF ON|OFF			 *
**************************************************
	REL(5) =ONOFFd
	REL(5) =ONOFFp
=PERFe	GOSUB  onoff?
	A=0    A
	LCASC  'L'	Fin de sequence
	GONC   perfoff
	A=A+1  A	1=perf on
 perfoff GOSUB	escseq
	GOTO   nxtstm	retour a Basic
 
**************************************************
* evalex, trad
* But:
*  - evalex: evaluer la chaine de tokens pointee
*    par D0, et...
*  - trad: depiler le sommet de la pile-maths,
*    convertir le nombre en decimal, et verifier
*    qu'il est inferieur a 128.
**************************************************
 evalex SETHEX		recquis par EXPEX-
	GOSBVL =EXPEX-	Evaluation...
 trad	GOSBVL =RJUST	Traduction en entier dec.
	SETHEX		apres RJUST
	GOC    argerr	Inf
	C=0    W
	LCHEX  999	C=00...00999
	?A<C   W
	RTNYES		Retour autorise si < 999
 argerr GOVLNG =ARGERR	sinon: "invalid argument"
 
**************************************************
* escseq
* But: Envoyer une sequence du type: ESC & l ### $
* ou ### est dans A(A), et $ dans C(B)
*
* Note:
* Beaucoup de sequences d'echappement sont de la
* forme ESC & l # $, oK:
*   # est un nombre entier
*   $ est un caractere (f/F, p/P, l/L ou d/D)
* Il est a noter que les zeros de tete dans # ne
* sont pas pris en compte. Cette caracteristique
* est tres interessante...
*
* Principe:
*  - La table est construite a partir de AVMEMS:
*    Les caracteres ESC, & et l sont d'abord
*    places, puis on calcule # sur 3 chiffres
*    (octets), et enfin, on place le caractere $
*    a la fin. Il est a noter que cette	 sequence
*    d'echappement est de longueur fixe.
*  - La table est suivie en mEmoire d'un code RTN
*    (#01). Le retour de PR-RTN se fera la, d'oK
*    retour final a la routine appelante...
*    Simple, non ?
**************************************************
 escseq D=C    B	Sauvegarde du caractere
	B=A    A	et du nombre
	D0=(5) =STMTR0
	LCHEX  6C261B7	7 caracteres,dont: ESC & l
	DAT0=C 7
	D0=D0+ 7
	BSRC
	BSRC		B(0-0)=premier nombre
	LCASC  '0'	C(B)=#30
	P=     2	3 boucles au total
 boucle A=B    A	A(A)=0000x
	B=0    A	B=xx0000...0000
	A=A+C  B	A(B)=3x
	DAT0=A B
	D0=D0+ 2
	BSLC		B=x0000...0000x
	P=P-1
	GONC   boucle	Boucle si P>=0
************************
* Je m'avais goure...
*
	P=     0
*
************************
	C=D    B	caractere final
	DAT0=C B
	D0=D0+ 2
	LCHEX  10	code de RTN
	DAT0=C B
	CD0EX		} C=D0
	D0=C		}
	RSTK=C		RSTK := ^ RTN dans la table

	D0=D0- 15	D0=debut de la table
	CD0EX
	RSTK=C		puis l'adresse de la table
	GOTO   PR-RTN	Envoi...
 
**************************************************
*	    PL [ <num> [ , <num> ] ]		 *
**************************************************
	REL(5) =PAGELENd
	REL(5) =PAGELENp
=PAGELENe
	A=DAT0 B	A(B)=token suivant
	GOSBVL =EOLXCK	Fin de ligne ?
	GONC   parametres
	GOSUB  PR-BAS	Oui: chaine par defaut
	CON(1) 11	11 caracteres
	CON(2) 27
	NIBASC '&l72p66f'
	NIBASC '1L'
 parametres
*************************
* Deux cas :
*  PL 72
*  -> ESC &l72P
*     Sommet M.S. : 72
*  PL 72,66
*  -> ESC &l72P ESC &l66L
*     Sommet M.S. : 66
*************************
	GOSUB  evalex	Evaluation des parametres
* D1 = ^ 72 (66)
	R1=A		R1 := dernier parametre
	D1=D1+ 16	Depilement
	AD1EX
*************************
* Modification du <861023.2257>
*
* Inversion de l'ordre d'envoi des deux parametres
*
	D0=(5) =FORSTK
	C=DAT0 A
	ST=1   9
	?A>=C  A	Un seul parametre ?
	GOYES  unique	Oui: longueur de la page
	ST=0   9	pas qu'un seul parametre
	D1=A
	GOSBVL =POP1R
	GOSUB  trad	A = premier parametre
	AD1EX
 unique
	AD1EX
	LCASC  'P'
	GOSUB  escseq
	?ST=1  9
	GOYES  nxtstM
	A=R1
	LCASC  'F'
	GOSUB  escseq

 nxtstM GOTO   nxtstm	Retour a Basic
*
* Fin de la modification
*************************
 
**************************************************
*	       UNDERLINE ON|OFF			 *
**************************************************
	REL(5) =UNDERd
	REL(5) =UNDERp
=UNDERLINEe
	GOSUB  onoff?
	GOC    UNDon
	GOSUB  PR-BAS	Sequence d'echappement
	CON(1) 4	difficile a parametrer
	CON(2) 27
	NIBASC '&d@'
 UNDon	GOSUB  PR-BAS
	CON(1) 4
	CON(2) 27
	NIBASC '&dD'
 
**************************************************
*		  WRAP ON|OFF			 *
**************************************************
	REL(5) =ONOFFd
	REL(5) =ONOFFp
=WRAPe	GOSUB  onoff?
	GOC    wrapon
	GOSUB  PR-BAS
	CON(1) 5
	CON(2) 27
	NIBASC '&s1C'
 wrapon GOSUB  PR-BAS
	CON(1) 5
	CON(2) 27
	NIBASC '&s0C'
 
	END		Ouf !!!
