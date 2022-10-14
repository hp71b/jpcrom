	TITLE  Polls <pol.as>

 JPCPRV	EQU	1

*
*   86/08/17
* JPC:A03
*   86/10/21: PD    Rajouté =VERi (i=1..3) faciliter VER$
* JPC:A04
*   86/12/11: PD    Ignorer le bit de poids fort dans MARGIN
*   86/12/17: PD/JT Ajout du poll de FINPUT
* JPC:A05
*   87/01/24: PD/JT Modification de MARGIN
* JPC:A06
*   87/04/18: PD/JT Cablage de KSPEED
*   87/04/18: PD/JT MARGIN = 1 bit + 1 buffer
* JPC:B00
*   87/05/12:	    Allocation par HP
* JPC:B01
*   87/06/20: PD/JT Integration de SYSEDIT
* JPC:B02
*   87/08/02: PD/JT Correction de "10 LOOP !    20 END LOOP"
* JPC:B03
*   87/08/01: PD    Si version = x00, alors JPC:x dans VER$
*   87/08/29: PD/JT Correction de 10SELECT 1 !  20END SELECT
*   87/08/29: PD/JT Correction de 10SELECT 1 15CASE 1 !
*			20END SELECT
*   87/08/29: PD/JT Copy code du fichier cree dans SYSEDIT
*   87/12/06: PD/JT Reconnaissance du type de fichier ADRS
*   87/12/09: PD    Modif. de CALC pour reconnaitre CHEDIT
*   87/12/13: PD/JT Integration de ROMANLEX
*   87/12/13: PD/JT Suppression de CHARLEX
*   87/12/19: PD/JT Detection de [ENDLN][ENDLN] ds FINPUT
*   88/01/24: PD/JT/JJD Integration de EXT Files
*   88/01/31: PD/JJD Correction de JPC:C
* JPC:C01
*   88/02/06: PD/JT Version C01
* JPC:C02
*   88/02/12: PD/JT Version C02
* JPC:D
*   88/04/24: PD/JT Version D envoyee a CMT
* JPC:D01
*   88/12/18: PD/JT Version D01
* JPC:D02
*   89/06/18: PD/JT Version D02
*   89/06/18: PD/JT Modif ASSFIELD (avec XEDIT, plus EDTEXT)
*   89/06/18: PD/JT Integration du module graphique
* JPC:D03
*   89/08/07: PD    Version D03
* JPC:E
*   89/10/06: PD    Version E
* JPC:E01
*   89/10/21: PD/JT Version E01
* JPC:E02
*   90/06/24: PD/JT Version E02
*

=VER1	EQU    ('E'-'A')
=VER2	EQU    0
=VER3	EQU    2

	STITLE	Aiguillage général

=POLHND LC(2)  =pKYDF
	?B=C   B
	GOYES  hKYDEF
	C=C+1  B	LC(2)  =pWTKY
	?B=C   B
	GOYES  hWTKY_1
	LC(2)  =pCONFG
	?B=C   B
	GOYES  hCONFG_1
	C=C+1  B	LC(2)  =pPWROF
	?B=C   B
	GOYES  hPWROF_1
	LC(2)  =pCLDST
	?B=C   B
	GOYES  hCLDST_1
	LC(2)  =pFTYPE
	?B=C   B
	GOYES  hFTYPE_1
	LC(2)  =pEDIT
	?B=C   B
	GOYES  hEDIT_1
	LC(2)  =pMRGE2
	?B=C   B
	GOYES  hMRGE2_1
	?B=0   B
	GOYES  hVER$_1
	RTNSXM

 hWTKY_1
	GOTO   hWTKY
 hCONFG_1
	GOTO   hCONFG
 hPWROF_1
	GOLONG hPWROF
 hCLDST_1
	GOLONG hCLDST
 hFTYPE_1
	GOLONG hFTYPE
 hEDIT_1
	GOLONG hEDIT
 hMRGE2_1
	GOLONG hMRGE2
 hVER$_1
	GOLONG hVER$

	STITLE	pKYDF

 MNEMF	EQU    8
 MODF	EQU    15
 COMF	EQU    24
	 *
**************************************************
* Auteur: Stephane Barizien 03/85 - Interception
*	  de pKYDF et champs assembleur.
* 1ere modification: M.MARTINET et P.DAVID 10/85 -
*      transformation en FIELD ON | OFF.
* 2eme modification: M.MARTINET 12/85 - mise en 
*      place de la bascule touche CALC et suppres-
*      sion token FIELD ON | OFF.
* 3eme modification: J.Taillandier et P.David 
*      08/86, reunion de JPC-LEX
* 4eme modification: J.Taillandier et P.David
*      Utilisation avec XEDIT
**************************************************

 hASF1	GOTO   hASF

 hKYDEF A=R0		A(A) = code logique
	LC(2)  32
	?A=C   B
	GOYES  hASF1
	LC(2)  =kcVIEW
	?A=C   B
	GOYES  hCURS_1
	LC(2)  =kcLFT
	?A=C   B
	GOYES  hCALC_1
	LC(2)  =kcCALC
	?A=C   B
	GOYES  hASF1
*
* Debut du poll de FINPUT
*
*
* Bits d'etat du display driver du HP71.
*
 BitsOK EQU    1
 NoChFC EQU    11

 EscSt0 EQU    0
 EscSt1 EQU    1

************************************************************
* hKDYDF
*
* But: traiter le poll pKYDF (definition de touche)
* Entree:
*   - R0(A) = code logique de la touche
* Sortie:
*   2 cas possibles :
*     non interception
*      - on n'est pas dans SINPUT
*      - la touche n'est ni [->], ni [g][->]
*      - la touche est [->], mais on l'autorise (pas arrive
*	 au bout de l'affichage)
*      - la touche est [g][->], mais c'est un cas special
*     interception et action (sans definition)
*      - la touche est [RUN]
*      - la touche est [->], et on est arrive a la fin de
*	 l'affichage
*      - la touche est [g][->], c'est nous qui manipulons le
*	 curseur pour l'amener a la fin de l'affichage.
* Abime: A-C, D0, D1, ST, INENDL
* Niveaux: 0
* Historique:
*   86/11/16: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
*   86/12/02: P.D. & J.T. ajout de [RUN]
*   87/12/19: P.D. & J.T. ajout de [ENDLINE][ENDLINE]
*   88/04/16: P.D. & J.T. indic remplace par INENDL
************************************************************

	D0=(5) =INSINP
	A=DAT0 1

	LC(1)  =INSMSK
	A=A&C  P
	?A=0   P
	GOYES  RTnsxm
	A=R0
	C=0    A
*
* Ajout du 19 decembre 1987
* Detection de deux appuis successifs sur [ENDLINE]
*
	LC(2)  =kcEOL
	D0=(5) =INENDL	1 si ENDLN deja pressee sur
	?A=C   A	dernier champ
	GOYES  hKD003	Touche = [ENDLINE]
	A=0    S	0 : on n'a pas presse ENDLN
	DAT0=A S
*
* Fin de la modification
*
	LC(2)  =kcRT
	?A=C   A
	GOYES  hKD002
	LC(2)  =kcFRT
	?A=C   A
	GOYES  hKD000
	LC(2)  =kcRUN
	?A=C   A
	GOYES  hKD001
 RTnsxm RTNSXM

 hKD002 GOTO   hKD010	Touche [->]
 hKD000 GOTO   hKD050	Touche [g][->]
 hKD001 GOTO   hKD100
 hKD003 GOTO   hKD150	Touche [ENDLINE]

 hCURS_1
	GOTO   hCURS
 hCALC_1
	GOTO   hCALC

 hASF
*
* Est-on sous editeur ?
* Test modifie le 88/10/23 par PD/JT pour XEDIT
*
	D0=(5)  =RESJPC
	A=DAT0  P
	LC(1)   =INEDIT
	A=A&C   P
	?A=0    P
	GOYES   rtn

******************
* Modification du 89/06/18 : on ne teste plus le flag 59
* pour regarder si on est sous EDTEXT, mais on regarde le
* bit INEDIT dans la ram reservée pour voir si on est sous
* X/TEDIT
*	D0=(5) 14+=FLGREG ) Est-on sous editeur
*	C=DAT0 S	de
*	C=C+C  S	textes ?
*	GONC   rtn	Non: retour.
******************

*
* R0(A) = touche pressée
*
	A=R0
* A[A] = touche pressee
	LC(2)  =kcCALC	Est-ce
	?A#C   B	la touche [f][CALC] ?
	GOYES  FXQ	Non: execution suite prgm.
* Touche [f][CALC] : inversion de l'etat du bit ASF
	D0=(4) =RESJPC
	A=DAT0 P
	LC(1)  =ASFMSK
	B=A    A
	C=C&A  A	C(0) := ASMMSK ou 0
	?C=0   P
	GOYES  asf10	Il faut le mettre a 1
* Il faut mettre le bit a 0
	LC(1)  `=ASFMSK
	A=A&C  P	A(0) := bit ASF a 0
	GONC   asf20	B.E.T.
* Il faut mettre le bit a 1
 asf10	LC(1)  =ASFMSK
	A=A!C  P	A(0) := bit ASF a 1
 asf20	DAT0=A P
	ST=0   0	Touche inhibee, pas de definition
	GOTO   rtnxm0	et fin d'execution

 rtn	RTNSXM		
 FXQ	D0=(4) =RESJPC	Execution du programme
	A=DAT0 1	Est-on en mode field on ?
	LC(1)  =ASFMSK
	A=A&C  P
	?A=0   P
	GOYES  rtn	Non: fin de programme
	D0=(4) =DSPBFS	Oui: continu
	LC(3)  (=DSPBFE)-(=DSPBFS)-1
	B=C    X
 SP05	A=DAT0 B
	?A=0   B
	GOYES  SP08
	LCASC  ' '
	?A#C   B
	GOYES  SP06
	D0=D0+ 2
	B=B-1  X
	GONC   SP05
 rtn1	RTNSXM
 SP06	LCASC  '*'	Y a-t-il des remarques ?
	?A=C   B
	GOYES  rtn	Oui: fin de programme
 SP08	D0=(4) =CURSOR	 Verification
	A=DAT0 B	position du curseur
	LC(2)  (MNEMF)-1 en fonction 
	?A<=C  B	des 
	GOYES  SP10	differents
	LC(2)  (MODF)-1 champs:	     
	?A<=C  B	MNEMF: mnemo-field
	GOYES  SP10	MODF : modification-field
	LC(2)  (COMF)-1 COMF : comment-field
	?A>C   B
	GOYES  rtn1
 SP10	C=C-A  A	Redefinition
	C=C+1  A	de la touche
	D0=(4) =DEFADR	 espace
	DAT0=C B	avec
	D0=D0+ 2	le
	LCHEX  4	bon 
	DAT0=C 1	nombre
	GOSUB  SKPTBL	de
	NIBASC '        '  CARCTERES BLANCS
	NIBASC ' '
 SKPTBL C=RSTK		Sortie de table
	D0=D0+ 1
	DAT0=C A
	ST=1   0	ST[0]=1 => definit. touche
 rtnxm0 XM=0		ST[0]=0 => touche inhibee
	RTNCC		Puis interception du Poll.

*=================================================*
 BUF	EQU    (=FUNCR0)-2

 CURSrtn
	RTNSXM

 hCURS	C=D    A	SFLAG? abime D(A), qu'il faut
	B=C    A	sauver si poll n'est pas intercepte
	LC(2)  =flUSER
	GOSBVL =SFLAG?	Tester le flag "User".
	C=B    A
	D=C    A
	GONC   CURSrtn	Si desarme, retour

	D1=(5) BUF	Zone de 22 caracteres a afficher
	C=0    A	C(A)=Longueur de la zone 
	LC(2)  2*22
	GOSBVL =WIPOUT	a remplir avec le code 0

	D1=(5) =CURSOR
	C=0    W	On ne gardera que C(B) pour HXDCW.
	C=DAT1 B	C(B)=position du curseur.
	GOSBVL =HXDCW	Apres l'appel: Mode DEC et res ds A:
	  *		A(W)=00...095 si le curseur est en
	  *		96ème poosition
	A=A+1  B	Curseur devient [1..96]
	SETHEX		Mode HEX pour conversion dec-ASCII.

	D1=(5) BUF
	LCASC  '0'
	ASRC		A: 60...09 (quartet de poids fort)
	?A=0   P	S'il est nul, on ne l'affiche pas
	GOYES  CURS40	(P=0 apres WIPOUT)

	A=A+C  B	Conversion DEC-ASCII.
	DAT1=A B
	D1=D1+ 2	Poids faible en deuxieme dans BUF.
	A=0    B

 CURS40 ASLC		A(W)= 00.....06
	A=A+C  B	Conversion
	DAT1=A B

	D1=(5) BUF
	GOSBVL =VIEWD1	Affichage du buffer pointe par D1.

	XM=0		Poll intercepte
	ST=0   0	Action (et non redefinition).
	RTN

************************************************************
* [<-] en mode CALC (CALCLEX)
************************************************************

 hCALC	D0=(5) (=SYSFLG)+11
	A=DAT0 A
	A=A+A  A	Carry=1 si mode CALC
	GONC   CLCrtn	Retour sinon
*
* C'est la touche [<-]
* On est en mode CALC
*

*
* Il reste a analyser l'appelant. Si c'est une routine de
* CHEDIT (#14CAF), alors c'est le mode "cmd stack" de CALC
* qui nous a appele. Sinon, c'est le mode CALC normal.
*
	C=RSTK
	GOSBVL =CSLC5
	C=RSTK
	GOSBVL =CSLC5
	C=RSTK
	B=C    A
	RSTK=C
	GOSBVL =CSRC5
	RSTK=C
	GOSBVL =CSRC5
	RSTK=C
	LC(5)  #14CAF	Ouh ! Que c'est affreux !
	?B=C   A
	GOYES  CLCrtn	C'est le mode "cmd stack" de CALC
*
* C'est le mode CALC normal.
* Il ne reste plus qu'a changer la touche :
*
	C=R0		C[A]=Key-Code
	C=C-1  B	C[A]=Code de [f] [BACK]
	P=     5
	LC(2)  =k#BKSP	C[9-5]=Code physique
	R0=C		Ni vu, ni connu, on change !
	P=     0
 CLCrtn RTNSXM		Fin...

************************************************************
* POLLS DE TOUCHES DE FINPUT
************************************************************

*
* Polls de touche de FINPUT
*
* Touche [->]
************************************************************
* hKD010
*
* But: traiter le deplacement a droite (touche [->]) dans
*   SINPUT.
* Entree: -
* Sortie:
*   - interception de la touche signifie que nous
*     n'autorisons pas le deplacement a droite.
* Abime: A-C, D0, D1, ST
* Niveaux: 0
* Historique:
*   86/11/16: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
************************************************************

 hKD010
*
* Recherche s'il existe un caractere non protege dans le
* reste du display buffer
*
* for i := CURSOR + 1 to 96 do
*   if dspmask[i] = unprotected then exit ;
*
	D0=(5) =CURSOR
	A=0    W
	A=DAT0 B	A(A) := (CURSOR)
	A=A+1  A	A(A) := next char.
	B=A    A	B(A) := next char.
	ASRB
	ASRB		A(B) := (next char) / 4
	LC(5)  (=DSPMSK)+23
	C=C-A  A
	D0=C		D0 := ^ dspmsk [next char]
*
* Il est bien evident que la boucle reelle ne sera pas une
* boucle caractere par caractere. La boucle va traiter un
* quartet de DSPMSK a la fois, c'est a dire quatre
* caracteres. Il y a donc un cas particulier a tester au
* prealable : le cas ou il n'y a pas exactement un multiple
* de 4.
*
	A=B    A	A(A) := next char.
	LC(2)  95
	C=C-A  B	C(B) := nb de char. restant
	GOC    Rtnsxm	curseur a la fin
	A=C    B
	B=A    B	B(B) := sauvegarde du nb de char.
	LC(2)  %0011
	A=A&C  B	A(B) := X = nb de char mod 4
	?A=C   B
	GOYES  reste
	P=     %0001
	A=A-1  B
	GOC    msk
	P=     %0011
	A=A-1  B
	GOC    msk
	P=     %0111
 msk	C=P    15
	P=     0
	A=DAT0 S
	A=A&C  S
	?A#C   S
	GOYES  Rtnsxm
*
* Maintenant, le cas particulier a ete teste, il ne reste
* qu'a tester que tous les autres quartets de DSPMSK ont
* comme valeur #F.
*
	D0=D0- 1
 reste
	BSRB
	BSRB		B(B) := (nb de car.) / 4
	GONC   rst20	B.E.T.
 rst10	C=DAT0 S
	C=C+1  S
	GONC   Rtnsxm
	D0=D0- 1
 rst20	B=B-1  B
	GONC   rst10

************************************************************
* RIEN
*
* But: ne rien faire (ahhhhhhhhhhh)
* Entree: -
* Sortie: Par RTNSXM, a CHEDIT, en declarant qu'on a agit
*   et qu'il n'y a pas besoin que le systeme continue.
* Historique:
*   86/12/02: P.D. & J.T. conception & codge
************************************************************
 RIEN	ST=0   0	inhiber la touche
	XM=0
	RTN

 Rtnsxm RTNSXM

* Touche [g][->]
************************************************************
* hKD050
*
* But: traiter la touche [g][->] quand on est dans SINPUT.
* Entree: -
* Sortie: -
*   La touche est interceptee, c'est nous qu'on a traite
*   l'appui sur la touche, et c'est pas HP. Na !
* Detail:
*   2 cas :
*     - Le dernier caractere du display buffer est protege.
*	Dans ce cas, [g][->] nous amene sur le dernier
*	caractere du dernier champ non protege.
*     - le dernier caractere du display n'est pas protege.
*	Alors, [g][->] nous amene apres le dernier
*	caractere introduit si c'est possible (c'est a dire
*	que le display buffer n'est pas plein).
* Historique:
*   86/11/21: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
*   86/11/29: P.D. & J.T. gestion de la video HPIL
************************************************************

 hKD050
*
* Modification du 86/11/29 :
*
* Ce poll est destine a court-circuiter le display-driver
* (de m...) du HP71. Quand la touche [g][->] est detectee,
* c'est nous qui choisissons la position d'arrivee du
* curseur. Le probleme est de faire comprendre ca au module
* HPIL.
*
* Ce driver se comporte d'une maniere plus propre que celui
* interne au HP71. Il sait jusqu'ou ne pas aller quand la
* sequence ESC CTRL C lui arrive. Il n'y a donc pas besoin
* de l'empecher d'agir. Mais ceci suppose de l'activer
* explicitement. Il n'est plus appele par le driver du HP71
* mais par nous.
*

*
* Comme dans le display-driver du HP71, nous appelons
* d'abord l'HPIL :
*
	gosub  =ILFART

*
* Puis, nous gerons le LCD.
*
* Recherche dans DSPMSK pour avoir la position du premier
* caractere non protege a partir de la fin.
*
* j := 0 ;
* i := 95 ;
* while (i >= 0) and
*	((dspmsk[i] = protected) or (display [i] = 0))
* do
*   begin
*     if dspmsk[i] # protected then j := i ;
*     i := i-1 ;
*   end ;
* if i<0 then exit poll ;
* if j#0 then curseur := j
*	 else curseur := i ;
*
	LC(2)  95
	B=C    B	B(B) := i
	D1=(5) (=DSPBFE)-2     caractere courant
	A=0    W	A(S) := 0 : masque courant := 0
	  *		A(B) := 0 : j := 0
	D0=(5) (=DSPMSK)
	GOTO   hKD070

*
* Dans la boucle, les assertions suivantes sont vraies :
*
*   A(S) = masque courant (mis a jour a la fin)
*   A(B) = j
*   B(B) = i
*   C(S) = DSPMSK [IP(i/4)]
*   D0 = ^ DSPMSK [IP(i/4)]
*   D1 = ^ DSPBFS [i]
*
 hKD060 
*
* Obtention d'un nouveau DSPMSK si necessaire, ainsi qu'une
* regeneration du masque courant.
*
	?A#0   S
	GOYES  hKD062
	A=A+1  S
	C=DAT0 S
	D0=D0+ 1
 hKD062
*
* Test de la protection
*
	B=C    S	On abime B(S)
	B=B&A  S	B(S) := si dspmsk[i] = protected
	  *			  alors #0
	  *			  sinon 0
	?B#0   S
	GOYES  hKD065	Pas la peine de continuer pour la
	  *		position i si le caractere est
	  *		protege.

*
* La position i n'est pas protegee.
*
	C=DAT1 B
	?C#0   B	il y a un caractere
	GOYES  hKD080

	A=B    B	j := i ;

 hKD065 D1=D1- 2
	A=A+A  S	masque mis a jour
 hKD070
	B=B-1  B
	GONC   hKD060
*
* On est sorti de la boucle sans avoir rien trouve. Tout le
* display est donc protege, ou aucun caractere n'a encore
* ete introduit.
*
	RTNSXM

*
* On est sorti du WHILE.
*
 hKD080
*
* if j#0 then j := i ;
*
	?A#0   B
	GOYES  hKD090

	A=B    B	j := i
*
* curseur := j
*
 hKD090
	D0=(5) =CURSOR
	A=A+1  B	Programmation heuristique !
	DAT0=A B
*
* Calcul de FIRSTC (premier caractere a afficher sur la
* fenetre de 22 caracteres du HP71) :
*
* FIRSTC := CURSOR - WINDLN si c'est possible
*
	D0=(2) =WINDLN
	C=DAT0 B
	C=A-C  B	C(B) := CURSOR - WINDLN
	GONC   FST#0
	C=0    B
 FST#0	D0=(2) =FIRSTC
	DAT0=C B

*
* Les instructions suivantes (modifications sur ST) sont
* des ordres donnes au display driver :
*
	D0=(2) (=DSPSTA)+3
	C=DAT0 X
	ST=C

	ST=0   NoChFC	On a change FIRSTC
	ST=0   BitsOK	Il faut reconstruire le display
	C=ST
	DAT0=C X	Dans les 12 bits du display driver

	GOTO   RIEN	interception

************************************************************
* ILFART
*
* But: Envoyer le curseur a l'extreme droite sur la video
*   HPIL courante.
* Entree: -
* Sortie:
* Abime: A-D, D0, D1, R3, ST
* Appelle: BDISPJ (HPIL display driver), R<RSTK, RSTK<R
* Niveaux: 0 (5 sauves par R<RSTK)
* Detail: D est sauvegarde dans R3
* Historique:
*   86/11/29: P.D. & J.T. conception & codage
************************************************************

=ILFART
	d0=(5) =DSPCHX
	a=dat0 a
	?a=0   a
	rtnyes

	c=d    a
	r3=c

	p=     4	Sauvegarde 5 niveaux de pile
	gosbvl =R<RSTK

	d0=(5) =ESCSTA
	lc(1)  EscSt1
	dat0=c 1

	lc(2)  3	CTRL C
	gosub  ILSEND
	p=     0

	d0=(5) =ESCSTA
	lc(1)  EscSt0
	dat0=c 1

	p=     4	Restaure les niveaux de pile
	gosbvl =RSTK<R

	c=r3
	d=c    a
	rtn

************************************************************
* ILSEND
*
* But: appeler directement le display-driver du module HPIL.
* Entree:
*   - C(B) = caractere a afficher
* Sortie: -
* Abime: A-D, D0, D1, ST
* Appelle: BDISPJ (#F3637 dans l'HPIL:1B)
* Niveaux: 5
* Detail:
*   le controle est rendu a la routine appelante directement
* Historique:
*   86/11/29: P.D. & J.T. conception & codage
************************************************************

 ILSEND a=c    b	DATA BYTE
	d0=(5) =DSPCHX
	c=dat0 a
	rstk=c
	rtn		GOVLNG =BDSIPJ dans l'HPIL

************************************************************
* hKD100
*
* But: traiter la touche [RUN] quand on est dans SINPUT.
* Entree: -
* Sortie: -
*   La touche est interceptee, pour inhiber la definition
*   eventuelle de la touche [RUN]. Chez moi, j'ai toujours
*   un DEF KEY '#46', 'RUN '; 
*   Pas vous ?
* Appelle: kRUN (tombe dedans)
* Historique:
*   86/12/02: P.D. & J.T. conception & codge
************************************************************

 hKD100 d1=(5) (=DEFADR)+2
	c=0    s
	dat1=c s
	d1=d1+ 1
	gosub  hKD110
	con(2) 15	RUN
 hKD110 c=rstk
	dat1=c a
	st=1   0
	xm=0
	rtn

************************************************************
* hKD150
*
* But: traiter la touche [ENDLINE] quand on est dans SINPUT.
* Entree:
*   - D0 = INENDL
* Sortie: -
* Detail :
*   si INENDL = 1
*     alors sortir par RUN
*     sinon si champ = dernier
*	      alors INENDL := 1
*	    fin si
*   fin si
* Appelle: hKD100 (tombe dedans)
* Historique:
*   87/12/19: P.D. & J.T. conception & codge
************************************************************

 hKD150 A=DAT0 S	A(S) := 1 si deja appuye [ENDLINE]
	?A#0   S	Deja appuye sur [ENDLINE] ?
	GOYES  hKD100	Oui
*
* Non : Il faut verifier le champ courant, et mettre
* eventuellement l'indicateur a 1
*
	D1=(5) =CHPCOU	champ courant (1..CHPMAX)
	A=DAT1 A	A(A) := no du champ courant
	D1=(4) =CHPMAX
	C=DAT1 A	C(A) := nb de champs
	A=0    S
	?A#C   A	Dernier champ ?
	GOYES  hKD160
	A=A+1  S	A(S) := 1 si dernier champ
 hKD160 DAT0=A S	INENDL := (A==C) ? 1 : 0
	RTNSXM

	STITLE pWTKY

**************************************************
* hWTKY
*
* But: traite le poll d'attente de touche.
* Historique:
*   87/04/18: P.D. & J.T. conception & codage
**************************************************

*
* <870418.1600> P.D. & J.T.
*    Codage en dur de la valeur de KSPEED
*
 KSPEEDrtn
	RTNSXM

 hWTKY
	D1=(5) =MARGEr
	A=DAT1 P	A(P) = quartet
	LC(1)  =MARGEm
	A=A&C  P	A := bit MARGIN
	?A=0   P
	GOYES  hWTK10	fini pour MARGIN
*
* il y a une valeur pour MARGIN. Il faut aller la
* chercher.
*
	LC(3)  =bMARGE
	GOSBVL =I/OFND
	GONC   hWTK10	pas trouve le buffer: fini
	A=DAT1 B	A(B) := valeur
*
* Test de la position du curseur
*
	D1=(5) =CURSOR	D1 := ^ CURSOR
	C=DAT1 B	C(B) = curseur (0 a 95)
	?C#A   B
	GOYES  hWTK10	Fini pour MARGIN
*
* La position est bonne, il faut emettre un
* sonorous signal...
*
	C=D    A	sauvegarde de D(A)
	R3=C		R3 := D(A)
	GOSBVL =CHIRP	BEEEEEEEEEEP !
	C=R3
	D=C    A	D(A) est restaure

 hWTK10
*
* La s'arrete le code de MARGIN. Mais, il faut
* maintenant traiter la repetition automatique du
* curseur. (17 aout 1986)
*

 fTMOUT EQU    3	EQU locale au module MN&ED

**************************************************
* Routine KEYR
* Cette routine scrute le clavier: elle attend que
* l'on appuie sur une touche, puis place le code
* de la touche sur laquelle on a appuye dans R0(B)
* KEYR boucle indefiniment sur elle-meme si l'on
* n'appuie sur aucune touche.
**************************************************
 KEYR
	 P=	4	 Sauvegarde en RAM les 5
	 *		 derniers adresses placees
	 *		 dans la pile de 
	 GOSBVL =R<RSTK	 Retour (RSTK)
	 GOSUB	rptky	 L'action d'une touche
	 *		 doit-elle se repeter ?
	 GOC	DEFKY	 Oui; on retourne le code
	 *		 de cette touche a la
	 *		 routine qui a emis le pol
************
* modification de JT (entree non supportee)
*	 GOSBVL =USRSTA
	 GOSUB	usrsta
* fin de modification
************
	 GOSBVL =BLDDSP
	 GOSBVL =SETTMO	 Autorise la mise
	 *		 hors-tension du 71 au bout
	 *		 de 10' si pendant ce temps 
	 *		 Aucune touche n'a ete
	 *		 pressee

**************************************************
* Debut de la boucle infinie
* Elle est du type:
*    0 0 DO 
*	 TRY-TO-SLEEP
*	 KEY? IF LEAVE THEN
*	 TIMED-OUT IF LEAVE THEN
*    LOOP
**************************************************
 KEYR10	 GOSBVL =SLEEP	 Place le 71 dans un etat
	 *		 de faible consommation
	 *		 d'energie. Ne retourne 
	 *		 Que lorsqu'une touche a
	 *		 ete enfoncee ou lorsqu'une
	 *		 alarme vient a terme
	 GOC	KEYR80	 Nous sommes dans ce
	 *		 dernier cas si carry est
	 *		 arme
	 GOSBVL =POPBUF	 et dans le 1er si elle
	 *		 est desarmee
 DEFKY	 C=B	A	 Place le code de la
	 *		 touche en C(B)
 DEFKY+	 R0=C		 puis en R0
	 P=	4	 Restaurons les 5 adresses
	 *		 precedemment conservees en
	 *		 RAM
	 GOSBVL =RSTK<R
	 XM=0		 et indiquons que le
	 *		 pol-process doit se
	 *		 terminer
	 RTNCC

 KEYR80	 GOSUB	USRREQ	 Verifie qu'aucun
	 *		 peripherique n'a besoin
	 *		 d'aide
	 GOSBVL =ALMSRV	 Verifie qu'aucune alarme
	 *		 n'est a terme
* 10' sans activite ne se sont-elles pas ecoulees ?
	 ?ST=0	fTMOUT
	 GOYES	KEYR10	 Non; essayons de nouveau
	 *		 de nous endormir
	 LC(2)	=k#OFF	 Oui; faisons comme si
	 *		 quelqu'un avait appuye sur
	 *		 la touche OFF (f ON)
	 GONC	DEFKY+	 (B.E.T.)

**************************************************
* Routine utilisee par KEYR et RPTKY
**************************************************
USRREQ	 GOSUB	usrsta
	 GOVLNG =CKSREQ

**************************************************
* RPTKY est une routine HP. Je n'en ai modifie que
* le debut. Seule la partie modifiee sera
* commentee. Referez-vous aux IDS 3 pour la partie
* non commentee.
*
* Algorithme simplifie:
*  Si une touche commence seulement a repeter son 
*	     son action (flRPTD abaisse)
*    alors on attend un temps T avant que cette
*	     cette action ne se repete
*    puis on arme flRPTD
*  Si la touche a deja repete son action
*    on n'attend pas avant de repeter son action
*  Si l'on appuie sur une nouvelle touche
*    alors on desarme flRPTD
**************************************************
 rptky
	 LC(2)	=flRPTD
	 GOSBVL =SFLAG?	 L'action de la touche
	 *		 s'est-elle deja repetee ?
	 LCHEX	700000
	 GOC	RPTK10	 Oui; on n'attends pas
	 *		 avant de repeter de
	 *		 nouveau celle-ci
	 LC(2)	75
 RPTK10	 GOSUB	WRTTM1	 La routine ci-dessous est
	 *		 commentee dans les IDS 3
	 LC(2)	=flRPTD
	 GOSBVL =SFLAGS
 RPTK20	 P=	8
	 GOSBVL =DEBNCE
	 D1=(5) (=KEYBUF)+2*14
	 A=0	A
	 A=DAT1 B
	 A=A-1	A
	 C=0	A
	 LC(2)	14
	 GOSBVL =IDIVA
	 P=	0
	 LC(5)	=KCOL0
	 C=C-B	A
	 D1=C
	 C=DAT1 XS
	 LCHEX	3
	 A=A&C	P
 RPTK30	 A=A-1	P
	 GOC	RPTK40
	 C=C+C	XS
	 GOTO	RPTK30
 RPTK40	 C=C+C	XS
	 GOC	RPTK45
 RPTKCC	 LC(2)	=flRPTD
	 GOSBVL =SFLAGC
 TMRRST	 C=0	W
	 C=C+1	XS
	 GOTO	WRTTM1
 RPTK45	 D0=(5) (=TIMER1)+5
	 D1=(5) =KEYPTR
	 A=DAT0 P
	 LCHEX	7
	 ?A=C	P
	 GOYES	RPTK47
	 GOSUB	TMRRST
	 D0=(5) (=KEYBUF)+2*14
	 A=DAT1 XS
	 ?A#0	XS
	 GOYES	RPTKCC
	 A=DAT0 B
	 B=0	A
	 B=A	B
	 RTNSC
 RPTK47	 A=DAT1 XS
	 ?A#0	XS
	 GOYES	RPTKCC
	 GOSUB	USRREQ
	 GOTO	RPTK20

 WRTTM1
	 D0=(5) =TIMER1
	 P=	5
	 DAT0=C 6
	 A=DAT0 6
	 ?A=C	WP
	 GOYES	WRTTMX
	 DAT0=C 6
 WRTTMX	 P=	0
	 RTNCC

************
* modification de JT
* entree non supportee passee en ss-prgm local
*	 GOVLNG =USRSTA
usrsta	 D0=(5) =DSPSTA
	 CSTEX
	 C=DAT0	 X
	 CSTEX
	 P=	 0
	 RTNCC
* fin de modification
************

	 STITLE pCONFG

**************************************************
* hCONFG
*
* But: traite le poll de configuration, et marque
*   le buffer =bMARGE.
* Historique:
*   87/04/18: P.D. & J.T. conception & codage
*
* But: traiter le poll de configuration pour FINPUT
* Detail:
*   Ce poll est la pour traiter le cas (peu frequent) ou
*   l'utilisateur fait INIT quand il est sous FINPUT. Si
*   l'on ne fait rien, les touches de curseur ([g][->] et
*   [->]), ainsi que la touche [RUN] sont toujours
*   interceptees. Lorsqu'une configuration intervient, on
*   est sur que FINPUT n'est pas activee. On peut donc
*   mettre le flag a 0 sans autre precaution.
* Historique:
*   86/12/02: P.D. & J.T. conception & codage
*   86/12/02: P.D.	  ajout de documentation
*   86/12/17: P.D. & J.T. integration dans JPCLEX
*   88/02/06: P.D. & J.T. correction effacement du bit
*
* But: traite le poll de configuration et marque
*   le buffer =bENDUP
* Historique:
*   87/04/18: J.T. & P.D. ajout de documentation
*
* But: traite le poll de configuration et place le
*   jeu de caracteres secondaires
* Historique:
*   87/04/18: J.T. & P.D. ajout de documentation
**************************************************

 hCONFG
    if JPCPRV
	GOSUB  hCFG10
	NIBHEX 3	juste pour emm... les désassembleurs
 hCFG10 C=RSTK
	GOSBVL =ISRAM?
	GONC   hCFG20	Ok, il est en Rom
	RTNSC		On trappe pCONFG
 hCFG20
    endif
*
* Restauration du buffer de MARGIN
*
	LC(3)  =bMARGE
	GOSUB  i/ores
*
* Effacer le bit FINPUT
*
	lc(1)  `=INSMSK
	d0=(5) =INSINP
	a=dat0 p
	a=a&c  p
*
* Correction du 88/02/06 : avant, on ecrivait le
* registre C (qui contenait #E) dans la ram
* a chaque configuration. Le probleme a ete detecte
* car EDTEXT fonctionnait directement en mode
* tabulations assembleur apres le Memory Lost.
*
	dat0=a p	Avant : dat0=c p
*
* Restauration du buffer de ENDUP
*
	LC(3)  =bENDUP
	GOSUB  i/ores 
*
* ROMAN reconnait le buffer bCHARS ?
*
	LC(3)  =bCHARs	id pendant la configuration
	GOSUBL =CHKBUF	verifier le buffer (roman.as)
	GOC    romxit	non trouve
	GOSUBL =DAT1BF	DAT1 := ^ buf ds le code (roman.as)
	LC(3)  =bCHARS
	GOSUB  i/ores

 romxit RTNSXM

 i/ores GOVLNG =I/ORES

**********************************************************

out 
	C=R0		Ces lignes font partie
	 *		d'un point de sortie.
	 *		Cette place
	D=C    A	est inhabituelle, mais
	 *		evite un GOTO
	 *		supplementaire.
savebf	LC(3)  =bENDUP	 Trouve ce buffer, s'il
	 *		existe, et empeche sa
	 *		destruction.
	GOSUB  i/ores 
rtncc	A=0    A	Il est indispensable de
	 *		desarmer Carry, que le
	 *		poll ait
	A=A+1  A	ou non ete intercepte.
	RTNSXM		Rend la main a l'appelant.


 hPWROF
	LC(3)  =bENDUP	 Il n'y a rien a faire si
	 *		le buffer n'existe pas.
	GOSBVL =I/OFND
	GONC   rtncc
	C=D    A	Le poll intercepte etant
	 *		un poll rapide, il faut
	 *		imperativement
	R0=C		preserver D(A).
	LC(2)  =flPWDN	 Les 3 lignes suivantes
	GOSBVL =SFLAG?	 peuvent etre supprimees si
	GONC   out	l'on desire que le HP71
	 *		execute le buffer meme en
	 *		mode programme. Mieux vaut
	 *		les garder, en vue d'une 
	 *		utilisation future par HP,
	 *		a moins que ce ne soit
	 *		indispensable.
	LC(2)  =flTNOF	 La demoniaque bete
	 *		s'etait-elle endormie ?
	GOSBVL =SFLAG?
	GOC    out	Alors il ne faut pas la
	 *		deranger.
	LC(2)  =flTNOF	 Amenera TITAN a se
	 *		rendormir apres un cours
	 *		passage par 
	GOSBVL =SFLAGS	 MAINLP.
	CD1EX		D1 est inchange depuis
	 *		GOSBVL I/OFND. Il pointe
	 *		sur la 
	 *		chaine dans le buffer.
	GOVLNG =LINEP+	 Le buffer est copie,
	 *		"tokenize", puis execute.

	STITLE	pFTYPE

************************************************************
* hFTYPE
*
* But: reconnaitre le type de fichier ADRS ou D-LEX
* Entree:
*   - A(A) = type du fichier a reconnaitre
* Sortie
*   Si le type est reconnu
*     D1 pointe sur la table
*     A(S) est l'entree dans la table  (1 ou 2)
*     XM = 0
*     Cy = 0
*   Si le type n'est pas reconnu
*     XM = 1
* Historique:
*   86/07/31: PD ajout de documentation
*   87/12/06: PD & JT integration de D-LEX dans le poll
*   88/01/24: PD & JT & JJD recodage a partir de Buitenhuis
*   89/06/18: PD & JT integration du module graphique
************************************************************

*fGRAPH EQU    #0E222	Graphic 71

 f41:CA EQU    #0E020
 f41:XM EQU    #0E030	XM
 f41:WA EQU    #0E040	Wall
 f41:KE EQU    #0E050	Key
 f41:ST EQU    #0E060	Status
 f41:ML EQU    #0E070	MLDL
 f41:PR EQU    #0E080	Programme
 f75:T	EQU    #0E052	Text
 f75:A	EQU    #0E053	Appt
 f75:G	EQU    #0E058	Rom I/O
 f75:B	EQU    #0E088	Basic
 f75:L	EQU    #0E089	Lex
 f75:W	EQU    #0E08A	VisiCalc
 f75:R	EQU    #0E08B	Rom PMS
 f41:BU EQU    #0E0B0
 fFORTH EQU    #0E218	Forth 71
 fROM	EQU    #0E21C	Rom (ROMCOPY)
 APTfil EQU    #0E220
 fOBJ	EQU    #0E22C
 fSYM	EQU    #0E22E

***********************************************************
*     Normal  Sec  Pri	S+P
*
* TEXT	0001 E0D1 ---- ----
* CA-41 E020 ---- ---- ----
* XM-41 E030 ---- ---- ----
* WA-41 E040 ---- ---- ----
* KE-41 E050 ---- ---- ----
* T-75	E052 ---- ---- ----
* A-75	E053 ---- ---- ----
* G-75	E058 ---- ---- ----
* ST-41 E060 ---- ---- ----
* ML-41 E070 ---- ---- ----
* PR-41 E080 ---- ---- ----
* B-75	E088 ---- ---- ----
* L-75	E089 ---- ---- ----
* W-75	E08A ---- ---- ----
* R-75	E08B ---- ---- ----
* BU-41 E0B0 ---- ---- ----
* SDATA E0D0 ---- ---- ----
* DATA	E0F0 E0F1 ---- ----
* BIN	E204 E205 E206 E207
* LEX	E208 E209 E20A E20B
* KEY	E20C E20D ---- ----
* BASIC E214 E215 E216 E217
* FORTH E218 E219 ---- ----
* ROM	E21C E21D E21E E21F
**APPT	E220 E221 ---- ----
* GRAPH E222 E223 ---- ----
* ADRS	E224 E225 ---- ----
* OBJ	E22C E22D ---- ----
* SYM	E22E E22F ---- ----
*
* Note :
*   41:DA = SDATA
*   41:AS = 75:I = TEXT
***********************************************************

 hFTYPE GOSUB  ftype1

*
*	NIBHEX ...	Create, Copy, Exec
*	CON(2) .	Data offset + Subheader
*	NIBASC '.....'	5 caracteres
*	CON(1) .	Nombre de type
*	CON(4) ....	type 1
*	CON(4) ....	type 2
*	 etc...
*

* 41:WA			(Wall 41)
	NIBHEX 880
	CON(2) 5
	NIBASC '41:WA'
	CON(1) 1
	CON(4) f41:WA
* 41:KE			(Keys 41)
	NIBHEX 880
	CON(2) 5
	NIBASC '41:KE'
	CON(1) 1
	CON(4) f41:KE
* 41:ST			(Status 41)
	NIBHEX 880
	CON(2) 5
	NIBASC '41:ST'
	CON(1) 1
	CON(4) f41:ST
* 41:ML			(MLDL 41)
	NIBHEX 220
	CON(2) 5
	NIBASC '41:ML'
	CON(1) 1
	CON(4) f41:ML
* 41:PR			(Programme 41)
	NIBHEX 880
	CON(2) 5
	NIBASC '41:PR'
	CON(1) 1
	CON(4) f41:PR
* 41:CA			(??? 41)
	NIBHEX 880
	CON(2) 5
	NIBASC '41:CA'
	CON(1) 1
	CON(4) f41:CA
* 41:XM			(Extended Memory 41)
	NIBHEX 880
	CON(2) 5
	NIBASC '41:XM'
	CON(1) 1
	CON(4) f41:XM
* 41:BU			(??? 41)
	NIBHEX 880
	CON(2) 5
	NIBASC '41:BU'
	CON(1) 1
	CON(4) f41:BU

* 75:L			(Lex 75)
	NIBHEX 880
	CON(2) 5
	NIBASC '75:L '
	CON(1) 1
	CON(4) f75:L
* 75:B			(Basic 75)
	NIBHEX 880
	CON(2) 5
	NIBASC '75:B '
	CON(1) 1
	CON(4) f75:B
* 75:A			(Appt 75)
	NIBHEX 880
	CON(2) 5
	NIBASC '75:A '
	CON(1) 1
	CON(4) f75:A
* 75:T			(Text 75)
	NIBHEX 880
	CON(2) 5
	NIBASC '75:T '
	CON(1) 1
	CON(4) f75:T
* 75:W			(Worksheet Visicalc 75)
	NIBHEX 880
	CON(2) 5
	NIBASC '75:W '
	CON(1) 1
	CON(4) f75:W
* 75:R			(Rom PMS 75)
	NIBHEX 880
	CON(2) 5
	NIBASC '75:R '
	CON(1) 1
	CON(4) f75:R
* 75:G			(Donnees Rom IO 75)
	NIBHEX 880
	CON(2) 5
	NIBASC '75:G '
	CON(1) 1
	CON(4) f75:G

* FORTH			(Forth 71)
	NIBHEX 000
	CON(2) 5
	NIBASC 'FORTH'
	CON(1) 2
	CON(4) fFORTH
	CON(4) 1+fFORTH
* OBJ			(OBJ de DEVROM 71)
	NIBHEX 000
	CON(2) 5
	NIBASC 'OBJ  '
	CON(1) 2
	CON(4) fOBJ
	CON(4) 1+fOBJ
* SYM			(SYM de DEVROM 71)
	NIBHEX 000
	CON(2) 5
	NIBASC 'SYM  '
	CON(1) 2
	CON(4) fSYM
	CON(4) 1+fSYM
* ROM			(ROM de ROMCOPY 71)
	NIBHEX 000
	CON(2) 5
	NIBASC 'ROM  '
	CON(1) 4
	CON(4) fROM
	CON(4) 1+fROM
	CON(4) 2+fROM
	CON(4) 3+fROM
* ADRS			(ADRS de KA 71)
	NIBHEX 000	Create = Copy = Mainframe ; Exec=0
	CON(2) 5+24	Data offset, subheader de 24 q
	NIBASC 'ADRS '	5 caracteres, ajuste avec des esp
	CON(1) 2	2 types (ADRS et ADRS secure)
	CON(4) =fADRS	ADRS normal
	CON(4) 1+=fADRS ADRS secure
* D-LEX			(LEX ON / OFF 71)
	NIBHEX 000
	CON(2) 5	Data offset dans subheader
	NIBASC 'D-LEX'
	CON(1) 1	1 seul type
	CON(4) =fDLEX
* GRAPH			(Graphique 71)
	NIBHEX 000	Create=Copy=mainframe ; Execute=0
	CON(2) 5+5	Data offset, subheader de 5 quartets
	NIBASC 'GRAPH'
	CON(1) 2
	CON(4) =fGRAPH
	CON(4) 1+=fGRAPH
	NIBHEX FF	Fin de la table

 ftype1 C=RSTK
	D1=C		D1 := ^ table
	GOSBVL =FTBSCH	Niveaux : 0

*
* Cy = 0 : pas trouve
* Cy = 1 : trouve
*	   B(A) = ^ entree
*	   B(S) = index dans l'entree
*
	GONC   rtnsxm

	C=B    A
	D1=C		D1 := ^ entree dans la table
	A=B    S	A(S) := index dans la table
	XM=0		Le poll est intercepte
	RTNCC		Cy := 0, pas d'erreur
 
 rtnsxm RTNSXM

	STITLE	pCLDST

************************************************************
* COLD START
************************************************************

 PgmRun EQU   #0000D

 hCLDST C=D    A	Save D(A) in BASIC RTN stack
	A=C    A
	GOSBVL =PSHUPD
	C=RSTK		Save return addr to '=FPOLL'
	A=C    A
	GOSBVL =PSHUPD
	C=RSTK		Save return addr to '=CLDST'
	A=C    A
	GOSBVL =PSHUPD
	ST=1   PgmRun	Indicate program running
	GOSBVL =CALBIN	CALL CONFIG
	CON(2) (CLD020)-(CLD010)   Statement length
 CLD010 CON(2) =tCALL	 CALL statement
	CON(2) =tLITRL	 Sub name :
	NIBASC 'ML'	  ML
	CON(2) =tPRMEN	 End of parm list
	CON(2) =tEOL	 End of line; return to binary
 CLD020 GOSBVL =POPUPD	Restore addr of '=COLDST'
	C=D    A
	RSTK=C
	GOSBVL =POPUPD	Restore addr of '=FPOLL'
	C=D    A
	RSTK=C
	GOSBVL =POPUPD	Restore D(A)
	C=0    A	Clear carry
	C=C+1  A
	RTNSXM		Indicate not handle; thus poll
	  *		processing will
	  *		Continue to all LEX files

	STITLE	pVER$

****************************************************
* hVER$
*
* But : renvoyer la chaine "JPC:x" ou "JPC:xyy"
* Entree :
*   - R3 = ^ M.S.
*   - R2 = AVMEMS
* Sortie :
*   - la chaine est sur la M.S.
*   - R3 reactualise
* Abime : A, C, D1
* Niveaux : 0
* Appelle : -
* Detail :
*   La version est definie par les trois EQU :
*     - =VER1 (0 pour A, 1 pour B, etc.)
*     - =VER2 & =VER3 : no de version
*   Si VER2 et VER3 sont nuls, seul VER1 est affiche
* Historique :
*   88/01/31: documentation
****************************************************

 hVER$	C=R3
	D1=C
	A=R2
	D1=D1- (VER$en)-(VER$st)-2
	CD1EX
	?A>C   A
	GOYES  hVER$1
	D1=C
	R3=C
 VER$st CON(1) 3	    LC
       IF     (=VER2)!(=VER3)  l'un ou l'autre non nul
	CON(1) 15	    LC(16) ' JPC:xyz'
	CON(2) (=VER3)+\0\
	CON(2) (=VER2)+\0\
       ELSE		    pas de VER2 & VER3
	CON(1) 11	    LC(12)
       ENDIF
	CON(2) (=VER1)+\A\
	NIBASC \:CPJ \
 VER$en DAT1=C (VER$en)-(VER$st)-2
 hVER$1
	RTNSXM

	STITLE	pEDIT
*
* EDIT F1
*   F1		 LEX  2326 01/01/00 00:00
* MERGE F2
*

 LEX?	LC(5)  =fLEX
	?A=C   A
	RTNYES
	RTN

 hEDIT
	GOSUB  LEX?
	GOC    hEDT20
	RTNSXM
 hEDT20 RTNCC


	STITLE	pMRGE2

*
* P = 0
* D1 = ^ en-tete de F2
* A(A) = type de F2
* CURRST = ^ en-tete de F1
*
 hMRGE2
	GOSUB  LEX?	F2 = LEX ?
	GOC    hMRG20	  oui
	RTNSXM		  non
*
* F2 est bien du type LEX
*
 hMRG20 D1=D1+ 16
	D1=D1+ 4	D1 := ^ protection de F1
	A=DAT1 P
	D1=D1- 4
	D1=D1- 16
	LC(1)  2
	A=A&C  P
	?A#0   P
	GOYES  fprot
*
* F2 n'est pas prive
*
	D0=(5) =CURRST	CURRST = adresse de F1
	C=DAT0 A
	D0=C		D0 := ^ F1
	D0=D0+ 16	D0 := type de F1
	A=0    A
	A=DAT0 4	A(A) := type de F1
	GOSUB  LEX?
	GOC    hMRG30
	RTNSXM		F1 n'est pas un LEX
*
* F1 est bien du type LEX
*
 hMRG30 D0=D0+ 4	D0 := ^ protection de F1
	A=DAT0 S
	?A=0   S
	GOYES  hMRG35
 fprot	LC(4)  =eFPROT	File protect 
	GOTO   bserr
*
* F1 n'est ni prive, ni securise
*
 hMRG35 AD1EX		R1 := D1 (^ en-tete de F2)
	R1=A		 :
	D0=D0+ 12	D0 := ^ FILEND de F1
	CD0EX		R0 := D0 (^ FILEND de F1)
	R0=C
	GOSBVL =PSHUPD	adr. de F2 a reactualiser
	A=R1		A(A) := ^ en-tete de F2
	C=0    A
	LC(2)  32	Offset de FILEND
	A=C+A  A
	D1=A		D1 := ^ FILEND de F2
	A=DAT1 A	Taille de F2
	LC(2)  5
	A=A-C  A	Taille de F2 - 5
	B=A    A
	R2=A		
*
* D1 = ^ FILEND de F2
* B(A) = A(A) = Longueur exacte de ce qu'on ajoute
* R0 = ^ FILEND de F1
* R1 = ^ en-tete de F2
* R2 = Longueur exacte de ce qu'on rajoute
*
	A=R0		D0 := ^ FILEND de F1
	D0=A		 :
	C=R2		RSTK := taille a ajouter
	RSTK=C		 :
	C=A    A	RSTK := ^ FILEND de F1
	RSTK=C		 :
	A=DAT0 A	A(A) := taille de F1
	CD0EX		C(A) := ^ FILEND de F1
	D0=C		 :
	C=C+A  A	C(A) := ^ fichier apres F1
	D0=D0- 16	D0 := ^ en-tete de F1
	D0=D0- 16	 :
	AD0EX		A(A) := ^ en-tete de F1
	ACEX   A
	R3=A		Sauvegarde de la fin de F1
*
* A(A) = ^ fin du fichier F1
* B(A) = longueur a deplacer
* C(A) = ^ en-tete de F1
*
    if JPCPRV
	GOSBVL =MVMEM+
    else
	GOSBVL =MGOSUB
	CON(5) =MVMEM+
    endif
	GONC   hMRG50
 bserr	GOVLNG =BSERR
*
* A ce stade, un trou a ete cree a la fin de F1
* pour y loger F2. Le travail suivant consiste
* a y amener F2.
* Note pour la comprehension generale : le 
* fichier F1 n'a pas bouge. Seul F2, peut-etre...
* C'est la raison pour laquelle seule l'adresse
* de F2 a ete placee dans la pile des GOSUBs.
*
 hMRG50 C=RSTK		C(A) := ^ FILEND de F1
	R0=C		R0 := ^ FILEND de F1
	C=RSTK		C(A) := taille de F2
	R2=C		R2 := taille de F2
	GOSBVL =POPUPD	l'adresse de F2
	C=D    A
	R1=C		R1 := ^ FILEND de F2
*
* R0 = ^ FILEND de F1
* R1 = ^ FILEND de F2
* R3 = ^ debut du trou (^ fin de F1)
*	
* Deplacement du fichier a merger.
*
	C=R3
	D1=C		D1 := Start of dest.
	C=0    A
	LC(2)  37
	A=R1
	A=A+C  A
	D0=A		D0 := Start of source (F2)
	C=R2		Block length (long. de F2)
	GOSBVL =MOVEU3
*
* Une partie du fichier F2 a ete maintenant amenee
* dans le trou laisse a la fin de F1. Il ne reste
* plus qu'a actualiser le chainage des lex, et ce
* sera termine
*
	C=R0		C(A) := ^ FILEND de F1
	D0=C
	D0=D0+ 11	D0 := ^ Lex Chain
	GONC   hMRG70	B.E.T.
*
* La boucle suivante parcourt la "lex-chain"
* jusqu'a trouver une entree nulle, signifiant
* ainsi la fin de la recherche. Le dernier lex
* de F1 est trouve.
*
 hMRG60 CD0EX		C(A) := ^ Lex-Chain
	C=C+A  A
	D0=C
	D0=D0+ 6	D0 := Next-Lex du suivant
 hMRG70 A=DAT0 A
	?A#0   A
	GOYES  hMRG60
*
* La boucle est terminee, D0 pointe sur le
* "Next-Lex offset" du dernier lex de F1
*
	AD0EX		A(A) := ^ next-lex
	D0=A
	C=R3		Adresse de la fin de F1
	C=C-A  A	Offset dernier Lex-Chain
	DAT0=C A	Actualisation
*
* Retour a l'appelant, avec la saine sensation
* du travail bien fait. Aleluiah !
*
	XM=0
	RTNCC

	END
