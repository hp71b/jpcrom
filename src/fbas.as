	title FINPUT, évaluation des arguments <fbas.as>
*
* Format des "dope vecteuuuurs" made in France
*
* 00-03 : nombre d'elements (1..n)
* 04-08 : pointeur vers les donnees
* 09-12 : longueur max des elements
*
=DOPEB$ EQU    (=TRFMBF)+00	 13 quartets
=DOPED$ EQU    (=TRFMBF)+13	 13 quartets
=DOPEP$ EQU    (=TRFMBF)+26	 13 quartets
=DOPEA	EQU    (=TRFMBF)+26	 27 quartets
=n	EQU    (=TRFMBF)+53	  5 quartets
*
* il reste 2 quartets a (=TRFMBF)+58 qui sont utilises lors
* de la compilation (fichier comp.as)
*

=DOPEI$ EQU    (=STMTR0)+00	 13 quartets
=DOPEM$ EQU    (=STMTR0)+13	 13 quartets
=DOPEU$ EQU    (=STMTR0)+26	 13 quartets
* il reste 3 quartets a (=STMTR0)+39
* correpondant a (=STMTD1)+02

	stitle Utilitaires
************************************************************
* ELMCPY
*
* But: copier l'element Y$(I) dans X$(I)
* Entree:
*   - C(A) = I
*   - D0 = ^ dope vecteuuuuuuuur de Y$
*   - D1 = ^ dope vecteuuuuuuuur de X$
* Sortie:
*   - A(A) = adresse de Y$(I)
*   - B(A) = (LEN(Y$(I)) + 2)*2
*   - C(A) = adresse de X$(I)
*   - P = 0
* Abime: A-D, D0, D1
* Appelle: GETx$I, MOVE*M
* Niveaux: 1
* Historique:
*   86/09/05: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  integration dans bas.as
************************************************************

=ELMCPY D=C    A	D(A) := i
	GOSUB  =GETx$I	D0 := ^ Y$(I)
	CD0EX
	CD1EX		D1 := ^ Y$(I)
	D0=C		D0 := dope-vecteuuuuur de X$
	C=D    A
	GOSUB  =GETx$I	C(A) = D0 := ^ X$(I)
*
* C(A) = D0 = ^ X$(I) = dest. address.
* D1 = ^ Y$(I)
* et il faut faire X$(I) := Y$(I)
*

*
* B(A) := (LEN(Y$(I)) + 2) * 2
*
	A=0    A
	A=DAT1 4
	A=A+1  A
	A=A+1  A
	A=A+A  A
	B=A    A

	AD1EX		A(A) := source address (Y$(I))

	GOVLNG =MOVE*M

************************************************************
* evlary
*
* But: evaluer ce qui est apres la virgule pointee par D0,
*   et selon le cas :
*   si vecteur de chaines, fabriquer le "dope vecteuuuuur"
*   si chaine simple, fabriquer un pseudo-vecteur d'un seul
*   element
*
* Entree:
*   - D0 = PC
*   - MTHSTK = sommet de la Math-Stack
* Sortie:
*   - D0 = ^ passee l'expression
*   - B(W) = dope-vecteuuuuuuuur fabrique
*   - MTHSTK actualise pour prendre en compte une eventuelle
*     longueur d'element de tableau, ou pour "oublier" le
*     "dope-vecteuuuuuur".
* Abime: A-D, R0-R4, ST, D0, D1, Function Scratch
* Appelle: EXPEXC, RCL4, RCL5, BSL4, BSL5, POP1S
* Niveaux: 5 (EXPEXC)
* Historique:
*   86/08/30: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
************************************************************

 evlary GOSBVL =EXPEXC
	B=0    W
	LCHEX  1F	tableau alpha ?
	?A#C   B	non
	GOYES  evry20	(2 avenue du Lac, en fait...)
*
* string array descriptor
*
	D1=D1+ 3	D1 := ^ maxlen
	GOSUB  RCL4
	D1=D1+ 8	D1 := ^ pointer
	GOSUB  RCL5
	D1=D1- 4	D1 := ^ dim
	GOSUB  RCL4
	D1=D1- 5	D1 := ^ option base
	C=DAT1 S
	?C#0   S
	GOYES  evry10
	P=     3
	B=B+1  WP
	P=     0
 evry10 D1=D1+ 14
	GONC   evry90	B.E.T.

*
* Attention !
* Cette erreur ne devrait jamais arriver...
*
 evry20 LCHEX  0F	Chaine alpha ?
	?A#C   B
	GOYES  datatp	Non, mais je ne sais pas comment
	  *		cela serait possible...
*
* On a trouve une expression alphanumerique sur la pile.
* Nous allons la transformer en vecteur de un element.
*
	GOSBVL =POP1S	D1 := ^ sommet de la Math-Stack
*
* La longueur de la chaine doit tenir sur 2 octets, d'ou le
* test de la longueur <20000 quartets.
*
	LC(5)  #20000
	?A>=C  A
	GOYES  strovf
*
* C'est une chaine, et elle est de bonne longueur
*
	ASRB		A(A) := longueur en octets
	D1=D1- 4	D1 := ^ longueur de V$(1)
	DAT1=A 4	LEN(V$(1)) := LEN(chaine)
	B=A    A
	GOSUB  BSL5
	CD1EX
	D1=C		C(A) = D1 := ^ math-stack
	B=C    A
	GOSUB  BSL4
	B=B+1  A

*
* terminaison de evlary. On attend dans B(W) le "dope-
* vecteuuuuur" et dans D1 l'adresse du sommet de la
* Math-Stack. Cette adresse sera sauvegardee en MTHSTK.
*
 evry90 CD1EX		Evry Cedex en fait
	D1=(5) =MTHSTK
	DAT1=C A	Sommet de la Math-Stack
*
* Verification du nombre d'elements du tableau en cours
* avec I$
*
	D1=(5) =n
	A=DAT1 A
	P=     3
	?A#B   WP
	GOYES  erdim
	P=     0
*
* On remet les choses en place
*
	D1=C		D1 := sommet de la Math-Stack
	RTN

 erdim	P=     0
	LC(4)  (=id)~(=eIDIM)  "#Dims"
	GOVLNG =BSERR

 datatp GOVLNG =RDATTY
 strovf LC(2)  =eSTROV
	GOVLNG =MFERR

************************************************************
* GETM$I, GETI$I, GETU$I, GETB$I, GETD$I, GETP$I, GETx$I
*
* But: renvoyer l'adresse de l'element I du tableau M$
*   (resp. I$, U$, B$, D$, P$).
* Entree:
*   - C(A) = I
* Sortie:
*   - C(A) = D0 = ^ long. de T$(I) (T$=M$,I$,U$,B$,D$,P$)
* Abime: A-C, D0
* Appelle: MPY
* Niveaux: 1
* Detail: La routine GETx$I permet de retrouver l'element I
*   du tableau dont le dope-vecteuuuuur est pointe par D0.
* Historique:
*   86/08/31: P.D. & J.T. conception & codage
************************************************************

=GETP$I D0=(5) =DOPEP$
	GOTO   GET010
=GETD$I D0=(5) =DOPED$
	GOTO   GET010
=GETB$I D0=(5) =DOPEB$
	GOTO   GET010
=GETU$I D0=(5) =DOPEU$
	GOTO   GET010
=GETM$I D0=(5) =DOPEM$
	GOTO   GET010
=GETI$I D0=(5) =DOPEI$

=GETx$I
 GET010 C=C-1  A
	B=C    A	!
	C=0    W	! C(15-5) := 0
	C=B    A	!
	D0=D0+ 9	D0 := ^ maxlen
	A=0    W
	A=DAT0 4	A(W) := maxlen
	A=A+1  A
	A=A+1  A	A(W) := maxlen + longueur
	GOSUB  mpy	A,B,C := offset en octets
	A=A+A  A	A(A) := offset en quartets
	D0=D0- 5	D0 := ^ pointeur
	C=DAT0 A	C(A) := ^ T$(1)
	C=C+A  A	C(A) := ^ T$(I)
	D0=C		D0: = ^ T$(I)
	RTN
	
************************************************************
* GETFST
*
* But: renvoyer l'adresse du premier caractere d'un element
*   de tableau.
* Entree:
*   - D0 = adresse de la longueur de l'element
* Sortie:
*   - C(A) = D0 = adresse du premier caractere de l'element
*     sus-cite. (cf Math-Stack, il faut faire D0=D0- 2 avant
*     utilisation)
*   - A(A) = D0 en entree
* Abime: A(A), C(A), D0
* Niveaux: 0
* Historique:
*   86/09/02: P.D. & J.T. conception & codage
************************************************************

=GETFST C=0    A
	C=DAT0 4
	C=C+1  A
	C=C+1  A
	C=C+C  A
	AD0EX
	C=A+C  A
	D0=C
	RTN

************************************************************
* BSL4, BSL5
*
* But: decaler B a gauche de 4 (resp. 5) quartets)
* Entree:
*   - B(W)
* Sortie:
*   - B(W)
* Abime: B(W)
* Niveaux: 0
* Historique:
*   86/08/31: P.D. & J.T. conception & codage
************************************************************

 BSL5	BSL    W
 BSL4	BSL    W
	BSL    W
	BSL    W
	BSL    W
	RTN

************************************************************
* RCL4, RCL5
*
* But: decale B(W) de 4 (resp. 5) quartets, et y place les 4
*   (resp. 5) quartets pointes par D1.
* Entree:
*   - B(W) = registre a decalage
*   - D1 = ^ zone a inserer dans B
* Sortie:
*   - B(W) = decale
* Abime: B(W), C(A)
* Appelle: BSL4 (resp. BSL5)
* Niveaux: 1
* Historique:
*   86/08/30: P.D. & J.T. conception & codage
************************************************************

 RCL4	GOSUB  BSL4
	C=0    A
	C=DAT1 4
	B=B+C  A
	RTN
 RCL5	GOSUB  BSL5
	C=DAT1 A
	B=C    A
	RTN

	stitle Execution routine (debut)
************************************************************
* SINPUTe
*
* But: implementer un gestionnaire de masque d'ecran
* Abime: tout ce qui est abimable par un statement
* Niveaux: tous ceux qui sont abimables par un statement
* Algorithme:
*   evaluer I$, creer le dope-vecteuuuuuuur
*   evaluer M$, creer le dope-vecteuuuuuuur
*   si P$ n'existe pas
*     alors creer un pseudo P$ : P$(i):=STR$(LEN(M$(i))&"PU"
*     sinon evaluer P$, creer le dope-vecteuuuuuuur
*   finsi
*   initialiser le tableau D$ (D$(i) := M$(i))
*   initialiser le tableau U$ (U$(i) := NULL$)
*   compiler le format dans le tableau B$ (Bit Map)
*   evaluer A
*   verifier que M$ ne contient pas de car. non affichables
*   i := 1 ;
*   repeter
*     afficher la chaine D$(i)
*    (-)
*     placer B$(i) dans DSPMSK
*     editer la ligne
*     selon la derniere touche appuyee :
*	[^]: i := si i>1 alors i-1 ;
*	[v]: i := si i<n alors i+i ;
*	[g][^]: i := 1 ;
*	[g][v]: i := n ;
*	[OFF]: sortir avec A := 0 ;
*	[ATTN]: si display = M$(i)
*		  alors sortir avec A := 0 ;
*		  sinon
*		    afficher la chaine M$(i) ;
*		    reprendre a (-) ;
*		finsi ;
*	[ENDLINE]: U$(i) := display
*		   si i=1 alors continuer dans [RUN]
*	[RUN]: U$(i) := display
*	       sortir avec A := i ;
*     fin selon
*   fin repeter
* Historique:
*   86/08/30: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
************************************************************

	REL(5) =FINPUTd
	REL(5) =FINPUTp
=FINPUTe
*
* Traitement de I$
*
	GOSBVL =ADDRSS
*
* A la sortie de ADDRSS,
* si Cy = 1, la variable n'est pas trouvee
* si Cy = 0, la variable est trouvee, et :
*   D0 = B(A) = adresse du registre de la variable
*   A(A) = ^ passee la tokenisation de la variable
*
	GONC   I$005
	LC(4)  (=id)~(=eINOVR)	   "Var Not Found"
	GOVLNG =BSERR

 I$005	CD0EX		C(A) := ^ registre de la variable
	D1=C		D1 := ^ registre de la variable
	D0=A		D0 := PC
*
* Boucle pour trouver le registre reel de la variable
*
	LCHEX  E
 I$010	D1=D1+ 1
	A=DAT1 P	A(P) := type de la variable
	?A#C   P	Tableau indirect
	GOYES  I$020
* la variable est un tableau indrect
	D1=D1+ 1	D1 := ^ "pointer"
	A=DAT1 A	A(A) := ^ reg. de la var. suivant
	D1=A		D1 := ^ reg. de la var. suivant
	GONC   I$010	B.E.T.
*
* Fin de chainage
*
 I$020	D1=D1- 1	D1 := ^ deux premiers quartets
	B=0    W
	A=DAT1 B	A(B) := type de la variable
	LCHEX  1F	Tableau alphanumerique
	?A#C   B
	GOYES  I$040
*
* Tableau (direct ou indirect)
*
	D1=D1+ 3
	GOSUB  RCL4	Maxlen
	D1=D1+ 8	D1 := ^ "pointer"
	GOSUB  RCL5	relative pointer
	AD1EX		A(A) := adresse du relative pointer
	D1=A
	A=A-B  A	A(A) := ^ premier element
	B=A    A	B(8-5) := maxlen ; B(4-0) := pointer
	D1=D1- 4	D1 := ^ dim
	GOSUB  RCL4
	D1=D1- 5	D1 := ^ option base
	C=DAT1 S
	?C#0   S
	GOYES  I$030
	P=     3
	B=B+1  WP	+ 1 en option base 0
	P=     0
 I$030	GOTO   I$100

 Datatp GOTO   datatp

 I$040	LCHEX  0F
	?A#C   B
	GOYES  I$050
*
* variable directe
*
	D1=D1+ 3	D1 := ^ maxlen
	GOSUB  RCL4
	D1=D1+ 8	D1 := ^ relative pointer
	GOSUB  RCL5	relative pointer
	AD1EX		A(A) := adresse du relative pointer
	A=A-B  A	A(A) := ^ premier element
	B=A    A	B(8-5) := maxlen ; B(4-0) := pointer
	GOTO   I$060

*
* Cette erreur ne devrait jamais arriver :
*
 I$050	LCHEX  FF
	?A#C   B
	GOYES  Datatp
*
* variable indirecte
*
	D1=D1+ 7	D1 := ^ maxlen
	GOSUB  RCL4
	D1=D1- 5	D1 := ^ absolute pointer
	GOSUB  RCL5
 I$060	BSL    W
	BSL    W
	BSL    W
	BSL    W
	B=B+1  A	Dim := 1

 I$100	C=B    W
	D1=(5) =DOPEI$
	DAT1=C 13
	P=     4
	C=0    P
	P=     0
	D1=(4) =n	Tant que =n reste en TRFMBF+53,
	DAT1=C A	  D1=(2) aurait suffi
*
* A ce stade, la variable I$ est traitee (ouf)
*
* J.T. : "YapuquaM$" (je cite)
*
	GOSBVL =COLLAP	Vide la Math-Stack
	D0=D0+ 2
	GOSUB  evlary	evaluation de M$
	D1=(5) =DOPEM$
	A=B    W
	DAT1=A 13
*
* P$ ou A ?
*
	D0=D0+ 2	On passe tCOMMA
	A=DAT0 S	A(S) := quartet de reconnaissance
	D0=D0+ 1
	?A=0   S	A ?
	GOYES  PP$010	Pseudo P$
*
* On est devant P$.
*	 
	GOSUB  evlary	evaluation de P$
	D0=D0+ 2	J.T. & P.D. bugfix <861123.1415>
	CD0EX		Sauvegarde de PC dans R3 pour la
	R3=C		compilation
	GOTO   compilerP$

 stkchr GOVLNG =STKCHR
*
* On est devant A. Il faut creer un pseudo P$ par la boucle:
*  FOR I = nombre-d'elements(M$) STEP -1
*    P$(I) = STR$(LEN(M$(I)))&"PU"
*  NEXT I
* Ce tableau P$ est construit sur la Math-Stack.
*

************************************************************
* PP$010
*
* But: creer un pseudo-P$ dans le cas ou ce tableau est
*   omis par l'utilisateur.
* Historique:
*   86/08/30: P.D. & J.T. conception & codage
*   87/01/25: P.D. & J.T. remplace S-R0-0 par TRFMBF
************************************************************

 PP$010 CD0EX		Sauvegarde de PC dans R3
	R3=C
	GOSBVL =D1MSTK
	D0=(5) =DOPEM$
	C=0    A
	C=DAT0 4	C(A) := nombre d'elements de M$
	D0=(2) =TRFMBF
*
* Debut de la boucle ci-dessus expliquee.
* D0 = TRFMBF
* TRFMBF = I
* P$(I) sera depose sur la pile (pointee par D1)
*
 PP$050
	DAT0=C A	C(A) := I
	GOSUB  =GETM$I	D0 := ^ M$(I) (sur la longueur)
	A=0    A
	A=DAT0 4	A(A) := longueur en hexa
	GOSBVL =HEXDEC	A(W) = B(W) = C(W) := long. en dec.
	SETHEX
	ASRC
	ASRC
	ASRC
	ASRC

	GOSBVL =D=AVMS	D(A) := AVMEMS
	LC(1)  4
	CSRC		C(S) := 4
*
* Boucle interne de formattage ascii de la longueur de M$(I)
* On aura, si M$="AREUH" : P$ := "00005PU"
*
 PP$070 LCASC  '0'
	C=C+A  B
	A=0    A
	GOSUB  stkchr 
	ASLC
	C=C-1  S
	GONC   PP$070

	LCASC  'P'
	GOSUB  stkchr 
	LCASC  'U'
	GOSUB  stkchr 
*
* On met la longueur de P$(I) sur la pile
*
	C=0    A
	LC(1)  7	LEN(P$(I)) := 7
	D1=D1- 4
	DAT1=C 4
*
* On passe a l'element suivant de M$  (M$(I-1))
*
	D0=(5) =TRFMBF
	C=DAT0 A
	C=C-1  A
	?C#0   A
	GOYES  PP$050
*
* Creation du "dope-vecteuuuuuur"
*
	B=0    W
	LC(1)  7
	B=C    P	B(3-0):=maxlen

	CD1EX
	D1=C
	GOSUB  BSL5
	B=C    A	B(8-5):=maxlen;B(4-0):=pointer

	D0=(5) =DOPEM$
	C=0    A
	C=DAT0 4
	GOSUB  BSL4
	B=B+C  A	B(12-9):=maxlen ;
	  *		B(8-4):=pointer ;
	  *		B(3-0):=dim
	GOSBVL =AVE=D1

************************************************************
* compilerP$
*
* But: compiler le format donne par l'utilisateur (ou
*   construit par SINPUT) en une Bit Map utilisable par le
*   display driver du HP71 (DSPMSK).
* Entree:
*   - DOPEP$ contient le dope-vecteuuuuuur de P$
* Sortie:
*   - B$ contient le tableau des Bits map.
* Abime: 
* Appelle: fichier comp.as
* Niveaux: 1
* Detail et Algorithme: voir fichier comp.as
* Historique:
*   86/11/24: P.D.	  ajout de documentation
************************************************************

 compilerP$
	D0=(5) =DOPEP$
	A=B    W
	DAT0=A 13


*
* Preparation des tableaux
* B$ (bit map) : Bit mask de DSPMSK
*     chargement : lors de la compilation (seulement lors)
*     utilisation: POKE dans DSPMASK
*     DIM B$(n)[12]
* D$ (Display) : copie des caracteres du DSPBUF
*     chargement : apres appui sur [ENDLINE]
*     utilisation: reaffichage du champ par une routine de
*      type DSPCNA, mais inversee
*     DIM D$(n)[96]
* U$ (User) : donnee saisie par l'utilisateur
*     chargement : apres appui sur [ENDLINE], par DSP$00
*     utilisation: lors de l'appui sur [RUN], chargement de
*      I$
*     DIM U$(n)[96]
*

*
* Les tableaux sont ranges entre OUTBS et AVMEMS
*
	GOSBVL =OBCOLL
*
* Tout d'abord, y-a-)t'il assez d'espace ?
*
	C=0    W
	LC(3)  (96+2+96+2+12+2)*2
	D0=(5) =n
	A=0    W
	A=DAT0 A
	GOSUB  mpy	A, B, C := taille memoire necessaire
	B=0    A
	?B#0   W
	GOYES  memerr
*
* Oui, il y a suffisamment d'espace...
*
	D0=(5) =AVMEMS
	C=DAT0 A
	C=C+A  A	C(A) := nouvel AVMEMS
	D0=D0+ 5	D0=(5) AVMEME
	A=DAT0 A	A(A) := AVMEME
	?C<A   A
	GOYES  cmp10	Ok

 memerr GOVLNG =MEMERR
 mpy	GOVLNG =MPY

 cmp10	D0=D0- 5	D0=(5) AVMEMS
	A=DAT0 A	A(A) := adresse de B$
	DAT0=C A	AVMEMS := adresse de la fin de U$
	D0=(5) =n
	D1=(5) =DOPEB$

* A(A) = ^ premier element de B$

	B=0    W
	C=0    A
	LC(2)  12	Taille d'Un element
	B=C    A
	GOSUB  BSL5
	B=A    A	B(A) := adresse de B$(1)
	GOSUB  BSL4
	C=DAT0 A	C(A) := n
	B=B+C  A
	C=B    W
	DAT1=C 13
	D1=D1+ 13

	C=0    W
	LC(2)  (12+2)*2
	ACEX   W
	D=C    A	D(A) := adresse de B$(1)
	C=0    W
	C=DAT0 A
	GOSUB  mpy
	C=C+D  A
	A=C    A
* D$
	B=0    W
	C=0    A
	LC(2)  96
	B=C    A
	GOSUB  BSL5
	B=A    A	B(A) := adresse de D$(1)
	GOSUB  BSL4
	C=DAT0 A	C(A) := n
	B=B+C  A
	C=B    W
	DAT1=C 13

	C=0    W
	LC(2)  (96+2)*2
	ACEX   W
	D=C    A	D(A) := adresse de D$(1)
	C=0    W
	C=DAT0 A
	GOSUB  mpy
	C=C+D  A
	A=C    A
* U$
	D1=(2) =DOPEU$
	B=0    W
	C=0    A
	LC(2)  96
	B=C    A
	GOSUB  BSL5
	B=A    A	B(A) := adresse de U$(1)
	GOSUB  BSL4
	C=DAT0 A	C(A) := n
	B=B+C  A
	C=B    W
	DAT1=C 13

*
* Le code continue dans le fichier comp.as
*

	END
