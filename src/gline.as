	TITLE	GPSET, GLINE <gline.as>

**************************************************
* rndahx
*
* but: evaluer le parametre au sommet de la math-
*  stack
* entree:
*  - D1 ^ sommet de la math-stack
* sortie:
*  - A(A) = valeur du parametre, en hexa
*  - D1 ^ parametre suivant
*  - mode = HEX
*  - P=0
* appelle: RNDAHX
* note: si le parametre est negatif, une erreur
*  ARGERR est generee
**************************************************

 rndahx GOSBVL =RNDAHX	A(A) := param. en hexa
	GONC   argerr	Parametre < 0
	D1=D1+ 16
	RTN
 argerr GOVLNG =ARGERR

**************************************************
* initgr
*
* but: initialiser le necessaire pour l'execution
*  des ordres PSET et LINE
* entree:
*  - D1 ^ sommet de la math-stack
* sortie:
*  - D0 = adresse de la chaine
*  - A(A) = longueur de la chaine en pixels
**************************************************

 initgr GOSBVL =EXPEX-	Evaluation des parametres
	LC(3)  'g'	Code de la variable
	B=C    X	transfere dans B(X)
	GOSBVL =ADRS50
	GOC    invvar	variable non trouvee
	D0=D0+ 11	on cherche l'adresse de la
	A=DAT0 A	chaine (ad. relative)
	CD0EX
	C=C-A  A	calcul de l'adresse reelle
	D0=C		D0 := adresse de la chaine
	A=0    A
	A=DAT0 4	A(A) := LEN(G$)
	A=A+A  A
	A=A+A  A
	A=A+A  A	longueur en pixels
	D0=D0+ 4	D0 := adresse des donnees
	RTN		dans la chaine
 invvar LC(2)  83
	GOVLNG =MFERR

	REL(5) =GPSETd
	REL(5) =GPSETp
**************************************************
* PSETe
*
* but: allumer un point, pour le programme GRAPH
**************************************************

=GPSETe GOSUB  initgr	initialise le graphique
	R0=A		sauvegarde de la longueur
	GOSUB  rndahx
	C=R0		C(A) := xmax
	?A#0   A
	GOYES  PSET10
	A=A+1  A	si x = 0 alors x := 1
	GONC   PSET20	B.E.T.
 PSET10 ?A<=C  A
	GOYES  PSET20
	A=C    A	si x > 640 alors x := 640
 PSET20 GOSUB  pset
	GOTO   LINE99	NXTSTM

**************************************************
* pset
*
* but: allumer le point A(A)
* entree :
*  - A(A) = numero du point a allumer (1..640)
*  - D0 = adresse de la variable G$
* sortie :
*  - P = 0
*  - D0 inchange
* utilise: A(W), B(A), C(A)
**************************************************

 pset	A=A-1  A	x := numero - 1
	B=A    A
	A=0    W
	A=B    A	A := 00000000000xxxxx
	ASRB
	ASRB
	ASRB		A := x div 8
	C=0    A
	LC(1)  7
	B=B&C  A	B := x mod 8
	B=C-B  A	C := 7 - (x mod 8)
	LC(2)  79
	C=C-A  A	C := offset de x en octets
	C=C+C  A	C :=   "   "   "  quartets
	AD0EX
	C=C+A  A	C := adresse reelle de x
	D0=C
	C=0    B
	C=C+1  B
	GOTO   pset20
 pset10 C=C+C  B
 pset20 B=B-1  A
	GONC   pset10
	B=C    B
	C=DAT0 B
	C=C!B  B	Allumage du point
	DAT0=C B
	D0=A		Restauration ancien D0
	RTN

	REL(5) =GLINEd
	REL(5) =GLINEp
**************************************************
* LINEe
*
* but: tracer une ligne, pour le programme GRAPH
**************************************************

=GLINEe GOSUB  initgr	initialisation du graphique
	R2=A		R2 := LEN(G$)
	CD0EX		C := adresse de G$
	R0=C		R0 := @ G$
	LC(1)  5	5 parametres a stocker
	D0=(5) =STMTR0	a partir de STMTR0
	GOTO   LINE20

 LINE10 R1=C		sauvegarde du compteur
	GOSUB  rndahx
	DAT0=A A	sauvegarde du parametre
	D0=D0+ 5
	C=R1		restauration du compteur
 LINE20 C=C-1  P
	GONC   LINE10	tant que compteur >= 0

*  0 + STMTR0 : ecart
*  5 + STMTR0 : taille
* 10 + STMTR0 : premier increment
* 15 + STMTR0 : longueur
* 20 + STMTR0 : x

	?A#0   A	x
	GOYES  LINE30
	A=A+1  A	si x = 0 alors x := 1
 LINE30 C=R0		C = adresse de G$
	D0=C		D0 = "	      "
	R1=A		R1 := valeur courante de x
	GOSUB  pset	allumer x
	D1=(5) 5*3+=STMTR0 longueur
	A=R1		A := x
	C=DAT1 A	C := longueur
	?C#0   A
	GOYES  LINE35
	C=C+1  A	si longueur = 0 alors
	DAT1=C A	     longueur := 1
 LINE35 A=C+A  A	A := point final + 1
	A=A-1  A	A := point final
	C=R2		C=LEN(G$)
	?A<=C  A
	GOYES  LINE40
	A=R1		A := x1
	C=C-A  A
	C=C+1  A	nouvelle longueur calculee
	DAT1=C A
	A=R2
 LINE40 R0=A		R0 := limite, nommons-la xf
	GOSUB  pset	allumer xf
	D1=D1- 5	D1 = 10 + STMTD0
	C=DAT1 A	C(A) := premier increment
	A=R1
	A=A+C  A
	R1=A
	C=R0		xf
	?A>=C  A	si x+premier increment>=xf
	GOYES  LINE99	   pas la peine de tracer
	D1=D1- 5	D1 = 5 + STMTR0 (taille)
	C=DAT1 A
	R2=C
	D1=D1- 5	D1 = 0 + STMTR0 (ecart)
* R0 := xf
* R1 := x
* R2 := taille
* R3 := increment dans la taille
* D1 pointe sur l'ecart
 LINE50 C=0    A	boucle externe
	C=C+1  A	le compteur de taille est
	R3=C		   initialise avec 1
 LINE60 A=R1		A := x
	GOSUB  pset
	A=R1
	A=A+1  A	x := x + 1
	R1=A
	C=R0
	?A>=C  A	si x >= x2
	GOYES  LINE99	   fini
	A=R3
	A=A+1  A	compteur taille incremente
	R3=A
	C=R2		C := taille
	?A<C   A	arrive a la fin de taille
	GOYES  LINE60
	A=R1
	C=DAT1 A	C := ecart
	A=A+C  A	on fait le grand ecart
	R1=A		nouveau x
	C=R0		xf
	?A<C   A	si x < xf
	GOYES  LINE50	   on recommence !

 LINE99 GOVLNG =NXTSTM

	END
