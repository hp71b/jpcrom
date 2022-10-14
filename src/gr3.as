	TITLE	Graphique, Tracé de lettre <gr3.as>

******************************
* NOTE :		     *
*			     *
* =LDCSPC est utilise par LB *
******************************
*
* Hauteur et largeur de la matrice dans laquelle sont
* definies les lettres :
* Note: la matrice reelle est 8x4. Pour chaque lettre, LB se
* deplace en premier de 1 dans la direction 0 degres.
*
 HMAT	EQU    10
 LMAT	EQU    6

*
* Zone de sauvegarde de le chaine parametre pour LB
*   SAVSTR + 0 = SAVSTR.adr
*   SAVSTR + 5 = SAVSTR.len
*   total : 10 quartets
*
 SAVSTR EQU    (=FUNCR0)+22
*
* Zone de sauvegarde des parametres passes a CP
*   CPPAR + 0 = CPPAR.espaces
*   CPPAR + 5 = CPPAR.lignes
*   total : 10 quartets
*
 CPPAR	EQU    (=FUNCR0)+22
*
* Zone de sauvegarde du buffer provisoire
*   TMPBUF + 0 = TMPBUF.id
*   TMPBUF + 3 = TMPBUF.adr
*   total : 8 quartets
*
 TMPBUF EQU    (=FUNCR0)+14
*
* Coordonnees du coin inferieur gauche de la lettre en cours
* de trace.
*   (COINX, COINY)
*   total : 10 quartets
*
 COINX	EQU    (=FUNCR0)
 COINY	EQU    (=FUNCR0)+5
*
* Coordonnes (en format 4 chiffres hexadecimaux apres la
* virgule) du point courant. Concorde avec PLUMEX et PLUMEY,
* avec davantage de precision.
*   (CX, CY)
*   total : 32 quartets
*
 CX	EQU    (=STMTR0)
 CY	EQU    (=STMTR1)
*
* Zone poubelle de 4 quartets
*
 TMP	EQU    (=FUNCR0)+10
*
* Directions relatives
*
 D0	EQU    0
 D45	EQU    1
 D90	EQU    2
 D135	EQU    3
 D180	EQU    4
 D225	EQU    5
 D270	EQU    6
 D315	EQU    7

*
* Flag d'erreur. Positionne par GETxy. Teste par CMPAR.
*
 erreur EQU    11
*
* Flag utilise par LB dans le trace des lettres
*
 saute	EQU    10

************************************************************
* LB000
*
* But: tracer des jolies lettres
* Entree:
*   - R1 = ^ chaine sur la M.S. (non encore poppee)
* Sortie: -
* Abime: A-D, R0-R3, STMT et FUNC scratch, LDCSPC
* Appelle: DEBLET, POP1S, RSAUTE, RTRACE, FINLET
* Niveaux: 
* Historique:
*   87/01/25: conception & codage
*   87/02/23: extraction et isolement de DEBLET et FINLET
*   87/02/24: centrage de chaque lettre en largeur
************************************************************
=LB000
*
* Traiter la chaine sur la M.S.
*
	C=R1
	D1=C
	GOSBVL =POP1S
	CD1EX
	C=C+A  A	C(A) := ^ debut str
	D0=(5) SAVSTR
	DAT0=C A	SAVSTR.adr := ^ debut chaine
	C=0    W
	C=A    A
	CSRB		C(A) := LEN(str)
	D0=D0+ 5	D0=(5) SAVSTR.len
	DAT0=C A	SAVSTR.len := LEN(str)

*
* Installer tout pour le trace :
*
	GOSUB  DEBLET
*
* On y va !
*
	GOTO   endwhile
*
* En debut de boucle :
*   PLUMEX, PLUMEY = position courante de la plume
*     (pret a tracer la prochaine lettre)
*   C(A) = nb de caracteres restant a tracer
*   D0=(5) SAVSTR.adr
*
 while
	C=C-1  A
	DAT0=C A
	D0=D0- 5	D0=(5) SAVSTR.adr
	C=DAT0 A
	C=C-1  A
	C=C-1  A
	DAT0=C A
	D1=C		D1 := ^ car

	GOSUB  FIGER	ne modifie pas D1
*
* Selon la caractere lu :
*
	A=DAT1 B	A(B) := A$[I,I]
	LC(2)  32
	?A>=C  B
	GOYES  ascii
*
* Code de controle [0..31]
*
	GOSBVL =FINDA
	CON(2) 13
	REL(3) CR00
	CON(2) 10
	REL(3) LF00
	CON(2) 08
	REL(3) BS00
	NIBHEX 00
	GOTO   endwhile
*
* Retour chariot :
*   place la position courante de la plume (PLUMEX, PLUMEY)
*   a la position CRpoint.
*
 CR00
	LC(2)  =oCR
	GOSUBL =RBUFC
	A=DAT1 A
	D1=D1+ 5
	C=DAT1 A
	GOSUBL =SETCUR
	GOTO   endwhile

*
* Line Feed :
*   descend d'un caractere, c'est a dire deplace la position
*   courante de la plume dans la direction 270 degres de
*   HMAT unites.
*
 LF00
	C=0    A
	LC(1)  HMAT	HMAT unites vers le bas
	P=     D270
	GOSUB  GETxyP
	GOSUBL =RSAUTE
*
* Reactualiser le CR point
*
	LC(2)  =oCR
	GOSUBL =RBUFC
	GOSUBL =GETCUR
	DAT1=A A	CRx := x courant
	D1=D1+ 5
	DAT1=C A	CRy := y courant
	GOTO   endwhile
*
* Back Space :
*   revient en arriere d'un caractere, c'est a dire deplace
*   la position courante de la plume dans la direction 180
*   degres de LMAT unites.
*
 BS00
	C=0    A
	LC(1)  LMAT	LMAT unites vers la gauche
	P=     D180
	GOSUB  GETxyP
	GOSUBL =RSAUTE
	GOTO   endwhile
*
* Caracteres ASCII :
*   verifier si le rectangle de trace est a l'interieur
*   des limites.
*   si oui alors
*     repeter
*	tracer le trait
*     jusqu'a ce que FINCAR
*   positionner la position courante de la plume (PLUMEX,
*   PLUMEY) au coin inferieur gauche de la prochaine lettre
*
 ascii
*
* A(B) = caractere
*
	D1=(5) TMP
	DAT1=A B	TMP := caractere lu
*
* On ne changera jamais D1, donc on le charge une fois pour
* toutes :
*
	LC(2)  =oW1
	GOSUBL =RBUFC
*
* Parcours des 4 points
*
	GOSUB  =CMPAR
* Cy = 1 si hors limite
* Cy = 0 si ok
	GOC    exit	en remettant coin inferieur gauche

	C=0    A
	LC(1)  (LMAT)-1
	P=     D0
	GOSUB  GETxyP
	GOSUBL =RSAUTE
	GOSUB  =CMPAR
	GOC    exit	en remettant coin inferieur gauche

	C=0    A
	LC(1)  (HMAT)-2
	P=     D90
	GOSUB  GETxyP
	GOSUBL =RSAUTE
	GOSUB  =CMPAR
	GOC    exit	en remettant coin inferieur gauche

	C=0    A
	LC(1)  (LMAT)-1
	P=     D180
	GOSUB  GETxyP
	GOSUBL =RSAUTE
	GOSUB  =CMPAR
	GONC   ok

 exit
	GOTO   finlet

*
* La lettre est tracable. Il faut maintenant revenir au
* point initial (coin inferieur gauche), puis decaler de 1
* pour centrer la lettre en largeur avant de commencer
* a tracer
*
 ok
	GOSUB  PTINIT	retour au point initial
	C=0    A
	LC(1)  1	decalage de 1 dans la direction
	  *		0 degres pour centrer la lettre en
	  *		largeur
	P=     D0
	GOSUB  GETxyP
	GOSUBL =RSAUTE
	GOSUB  =LB100
=LB100
	C=RSTK
	A=C    A
*
* A(A) := ^ =gd00
*
	LC(5)  (=CTABLE)-(=LB100)
	C=C+A  A
	RSTK=C
*
* RSTK = adresse de la table des pointeurs
*
	D1=(5) TMP
	A=0    A
	A=DAT1 B	A(B) = caractere
	C=0    A
	LC(2)  32
	A=A-C  A	A(A) = c - 32
	A=A+A  A
	A=A+A  A	A(A) = offset dans table des pteurs
	C=RSTK
	C=C+A  A	C(A) = ^ pointeur relatif

	D1=C
	A=0    A
	A=DAT1 4
	C=C+A  A	C(A) := ^ debut caractere

	D1=(5) =LDCSPC
	DAT1=C A
*
* L'adresse des vecteurs du caractere est stockee en LDCSPC
*
* repeat
*
 LB110
	D1=(5) =LDCSPC
	C=DAT1 A
	D1=C
	A=DAT1 B	A(B) = vecteur
*
* Format du vecteur :
*   Poids fort
*     Fin : 1 bit
*     Direction : 3 bits (0 a 7)
*     Sauter / tracer : 1 bit
*     Nombre d'unites : 3 bits (0 a 7)
*   Poids faible
*

*
* Tester le sauter / tracer
* Isoler la distance (nb d'unites)
*
	ST=0   saute
	C=0    W
	C=A    P	C(W) = 000000000000000(poids faible)
	C=C+C  P
	GONC   LB120
	ST=1   saute
 LB120
	CSRB		C(A) = nombre d'unites (3 bits)
	RSTK=C
*
* Isoler la direction
*
	C=0    A
	C=A    B
	C=C+C  B
	CSRB
	P=C    1	P = direction
	C=RSTK		C(A) := n

	GOSUB  GETxyP

	?ST=1  saute
	GOYES  LB130
	GOSUBL =RTRACE
	GOTO   LB140
 LB130	GOSUBL =RSAUTE
 LB140
*
* Et on boucle
*
	D1=(5) =LDCSPC
	C=DAT1 A
	D0=C
	A=DAT0 B
	D0=D0+ 2
	CD0EX
	DAT1=C A
	A=A+A  B
	GONC   LB110

 finlet
	GOSUB  PTINIT	retour au point initial
*
* Ramener la position de la plume sur la lettre suivante.
*
	C=0    A
	LC(1)  LMAT
	P=     D0
	GOSUB  GETxyP
	GOSUBL =RSAUTE
*
* fin de la boucle sur les caracteres
*   decrementer le nombre de caracteres restant a traiter
*   et sortir le cas echeant.
*
 endwhile
	D0=(5) (SAVSTR)+5
	C=DAT0 A
	?C=0   A
	GOYES  ew10
	GOTO   while
 ew10

*
* Attention :
*   le code continue !
*

************************************************************
* FINLET
*
* But: terminer le trace des lettres.
* Entree:
*   - PLUMEX, PLUMEY = position courante de la plume
*   - TMPBUF = id du buffer utilise
* Sortie:
* Abime: 
* Niveaux: 
* Appelle: BUFC, GETCUR, I/ODAL
* Detail:
*   - enregistrer la position courante de la plume
*   - desallouer le buffer
* Historique:
*   87/02/23: extraction de LB000
************************************************************

 FINLET
*
* Mettre la position courante de la plume dans le buffer
* (oPx) a la valeur contenue dans (PLUMEX, PLUMEY).
*
	LC(2)  =oP
	GOSUBL =RBUFC
	GOSUBL =GETCUR
	DAT1=A A	Px := x courant
	D1=D1+ 5
	DAT1=C A	Py := y courant
*
* Desallouer le buffer et fin.
*
	D0=(5) TMPBUF	D0 := TMPBUF.id
	C=DAT0 X	C(X) := id du buffer temporaire
	GOVLNG =I/ODAL

************************************************************
* FIGER
*
* But: Fixer le point courant (PLUMEX, PLUMEY) pour que ce
*   soit le nouveau "debut de lettre".
* Entree:
*   (PLUMEX, PLUMEY) = point courant
* Sortie:
*   (COINX, COINY) = point courant
*   (CX, CY) = point courant
* Abime: A(W), C(W), D0
* Niveaux: 1
* Appelle: GETCUR
* Historique:
*   87/01/31: conception & codage
************************************************************

 FIGER
	A=0    W
	C=0    W
	GOSUBL =GETCUR	A(A) := (PLUMEX) ; C(A) := (PLUMEY)
*
* (COINX, COINY) := point courant
*
	D0=(5) COINX
	DAT0=A A
	D0=D0+ 5
	DAT0=C A
*
* (CX, CY) := point courant
*
	D0=(2) CX
	ASL    W
	ASL    W
	ASL    W
	ASL    W
	DAT0=A W
	D0=D0+ 16
	CSL    W
	CSL    W
	CSL    W
	CSL    W
	DAT0=C W
	RTN

************************************************************
* GETxyP, GETxyC
*
* But: Obtenir les deplacements dx et dy dans une direction
*   donnee et pour un nombre d'unites donne, et actualiser
*   les coordonnes courantes en pleine precision.
* Entree:
*   - C(A) = nombre d'unites
*   GETxyP :
*   - P = direction (0 pour 0 degres, 1 pour 45 degres...)
*   GETxyC :
*   - C = direction (0 pour 0 degres, 1 pour 45 degres...)
* Sortie:
*   - (CX, Cy) = coordonnes actualisees)
*   - A(A) = dx pour appel a RTRACE
*   - C(A) = dy pour appel a RTRACE
* Abime: P, A-D, D0
* Niveaux: 1
* Appelle: GETCUR, ROUNDC, MPY
* Historique:
*   87/01/31: conception & codage
************************************************************

 GETxyP
	C=P    15
 GETxyC
	ST=0   erreur
	P=     0
	D=0    W
	D=C    A	Sauvegarde dans D(W)
	D0=(5) (TMPBUF)+3  D0=(5) TMPBUF.adr
	C=DAT0 A
	D0=C		D0 := ^ BUF
	GOTO   Gxy20
 Gxy10
	D0=D0+ 16
	D0=D0+ 16
 Gxy20
	C=C-1  S
	GONC   Gxy10
*
* D0 = ^ alpha (d) (d=direction)
* D(0) = n (nombre d'unites)
*
* Il faut calculer DX, DY les deplacements en pleine
* precision.
* DX = n * alpha (d) ( <=> D(A) * (^D0))
*
	C=D    W	C(W) := n
	A=DAT0 W
	D0=D0+ 16
	GOSBVL =MPY	A(W) = B(W) = C(W) = DX
	CDEX   W	D(W) := DX ; C(W) := n
	A=DAT0 W
	GOSBVL =MPY
*
* A(W) = B(W) = C(W) = DY
* D(W) = DX
*
	D0=(5) CY
	C=DAT0 W	C(W) := Point courant Y
	A=A+C  W	A(W) := Y + DY
	DAT0=A W
	D0=D0- 16
	C=DAT0 W	C(W) := point courant X
	C=C+D  W	C(W) := X + DX
	DAT0=C W
*
* Si jamais un x ou y est negatif, on le met a 0, et on n'en
* parle plus...
*
	B=C    S	B(S) := bit de poids fort de x
	B=B+B  S
	GONC   GET010
	C=0    W
	ST=1   erreur
 GET010
	B=A    S	B(S) := bit de poids fort de y
	B=B+B  S
	GONC   GET020
	A=0    W
	ST=1   erreur
 GET020
*
* Arrondir x (C(W)) et y (A(W))
*
	GOSUB  =ROUNDC
	ACEX   W	A(A) := x
	GOSUB  =ROUNDC
*
* A(A) = x
* C(A) = y
*
	B=A    A	B(A) := x
	D=C    A	D(A) := y
	GOSUBL =GETCUR
	A=B-A  A
	D=D-C  A
	CDEX   A
*
* A(A) = dx ( <=> n * alpha (d))
* C(A) = dy ( <=> n * beta (d))
*

	RTN

************************************************************
* ROUNDC
*
* But: Transformer C(W) (nombre hexadecimal avec 4 chiffres
*   apres la virgule) en un nombre entier, avec arrondi.
* Entree:
*   - C(W) = nombre en pleine precision
* Sortie:
*   - C(A) = nombre entier arrondi
* Abime: C(W)
* Niveaux: 0
* Historique:
*   87/01/31: conception & codage
************************************************************

 =ROUNDC
	CSR    W
	CSR    W
	CSR    W
	CSRB
	CSRB
	CSRB
	SB=0
	CSRB
	?SB=0
	RTNYES
	C=C+1  A
	RTN

************************************************************
* PTINIT
*
* But: remettre les points courant (PLUMEX, PLUMEY) et (CX,
*   CY) au point inferieur gauche.
* Entree:
*   - (COINX, COINY) = point initial (coin inferieur gauche)
* Sortie:
*   - (PLUMEX, PLUMEY) = point initial sur 5 quartets
*   - (CX, CY) = point initial sur 16 quartets
* Abime: A, C, D0
* Niveaux: 1
* Appelle: SETCUR, FIGER (tombe dedans)
* Historique:
*   87/01/31: conception & codage
************************************************************

 PTINIT
	D0=(5) COINX
	A=DAT0 A
	D0=D0+ 5
	C=DAT0 A
	GOSUBL =SETCUR
	GOTO   FIGER	et on REmet (COINX, COINY) (astuce!)

************************************************************
* CMPAR
*
* But: tester si le point courant (PLUMEX, PLUMEY) est dans
*   la fenetre de trace (W1, W2)
* Entree:
*   - (PLUMEX, PLUMEY) = point a tester
*   - D1 = ^ W1x dans le buffer
* Sortie:
*   - Cy = 0 : point dans la fenetre de trace. Ok
*	D1 non modifie
*   - Cy = 1 : point hors de la fenetre. Beuark
*	D1 modifie
* Abime: 
* Niveaux: 
* Historique:
*   87/01/31: conception & codage
************************************************************

=CMPAR
*
* Si il y a eu erreur lors du GETxyP alors sortir
*
	?ST=1  erreur
	RTNYES
*
* Si x < W1x alors sortir
*
	GOSUBL =GETCUR	A(A) := x ; C(A) := y
	B=A    A	B(A) := x
	A=DAT1 A	A(A) := W1x
	?B<A   A
	RTNYES
*
* Si x > W2x alors sortir
*
	D1=D1+ 10	D1 = ^ W2x
	A=DAT1 A
	?B>A   A
	RTNYES
*
* Si y > W2y alors sortir
*
	D1=D1+ 5	D1 = ^ W2y
	A=DAT1 A
	?C>A   A
	RTNYES
*
* Si y < W1y alors sortir
*
	D1=D1- 10
	A=DAT1 A
	?C<A   A
	RTNYES
*
* Retour avec Cy = 0
*
	D1=D1- 5	Cy := 0
	RTN		RTN E.T. (private joooooooke)

************************************************************
* DIVMUL
*
* But: A (entier) / B (entier) * C (flottant) => flottant
* Entree:
*   - A(A) = entier
*   - B(A) = entier
*   - C(W) = flottant, 4 chiffres hexa apres la virgule
* Sortie:
*   - C(W) = flottant
* Abime: A-D, P
* Appelle: IDIV, MPY, ROUNDC
* Niveaux: 1
* Note:
*   appelee par LB (au debut) pour satisfaire aux exigences
*   de la precision.
*   A = l ou h
*   B = HMAT ou LMAT
*   C = cos ou sin
* Historique:
*   87/02/22: conception & codage
************************************************************

 DIVMUL
	D=C    W	cos ou sin

	C=0    W
	C=B    A	C(W) := diviseur entier

	B=A    A
	A=0    W
	A=B    A	A(W) := dividende entier
	ASL    W
	ASL    W
	ASL    W
	ASL    W	A(W) := dividende flottant

	GOSBVL =IDIV	A(W) := quotient flottant
	P=     0

	C=D    W	C(W) := multiplicateur flottant
	GOSBVL =MPY
	GOLONG =ROUNDC

************************************************************
* DEBLET
*
* But: mettre en place tout le necessaire pour tracer des
*   lettres.
* Entree: -
* Sortie: -
* Appelle: IOFSCR, I/OALL, SINCOS, DIVMUL, PUSH, BUFC,
*   SETCUR
* Niveaux: 
* Abime: A-D, R0-R3, TMPBUF, PLUMEX, PLUMEY
* Detail:
*   - chercher un buffer pour stocker les 2 tableaux a et b
*   - calculer sin(theta) et cos(theta)
*   - remplir les tableaux a et b
*   - mettre le point courant dans (PLUMEX, PLUMEY)
* Historique:
*   87/02/23: extraction du code de LB000
************************************************************

 DEBLET
	GOSBVL =IOFSCR	Cy = 0 : C(X) = buffer ID
	GONC   DEB10
*
* Ca n'est pas l'erreur normale. A revoir
*
 memerr GOVLNG =MEMERR
 DEB10
	D1=(5) TMPBUF
	DAT1=C X
	BCEX   A
	LC(5)  16*16
	BCEX   A
	GOSBVL =I/OALL
	GONC   memerr
	CD1EX
	D1=(5) (TMPBUF)+3
	DAT1=C A
	D1=C
*
* Calculer les 8 constantes
*
	CD1EX
	D0=C		D0 := a(0)
	LC(2)  =oTHETA
	GOSUBL =RBUFC
	A=DAT1 A
	D1=D1+ 10	D1=(5) oLCAR
	GOSUBL =SINCOS
	R3=A		R3(W) := sin(theta)
	R1=C		R1(W) := cos(theta)
*
* l/LMAT cos(theta)
*
	A=DAT1 A	A(A) := l
	C=0    A
	LC(1)  LMAT
	B=C    A	B(A) := LMAT
	C=R1		C(W) := cos(theta)
	GOSUB  DIVMUL	C(W) := A*B/C
	?ST=1  =cosx>0
	GOYES  DEB20
	C=-C   W
 DEB20
	R0=C		R0 := l/LMAT cos(theta)
*
* h/HMAT cos(theta)
*
	D1=D1- 5	D1=(5) oHCAR
	A=DAT1 A	A(A) := h
	C=0    A
	LC(1)  HMAT
	B=C    A	B(A) := HMAT
	C=R1		C(W) := cos(theta)
	GOSUB  DIVMUL	C(W) := A*B/C
	?ST=1  =cosx>0
	GOYES  DEB30
	C=-C   W
 DEB30
	R1=C		R1 := h/HMAT cos(theta)
*
* h/HMAT sin (theta)
*
	A=DAT1 A	A(A) := h
	C=0    A
	LC(1)  HMAT
	B=C    A	B(A) := HMAT
	C=R3		C(W) := sin(theta)
	GOSUB  DIVMUL	C(W3 := A*B/C
	?ST=1  =sinx>0
	GOYES  DEB40
	C=-C   W
 DEB40
	R2=C		R2 := h/HMAT sin(theta)
*
* l/LMAT sin (theta)
*
	D1=D1+ 5
	A=DAT1 A	A(A) := l
	C=0    A
	LC(1)  LMAT
	B=C    A	B(A) := LMAT
	C=R3		C(W) := sin(theta)
	GOSUB  DIVMUL	C(W) := A*B/C
	?ST=1  =sinx>0
	GOYES  DEB50
	C=-C   W
 DEB50
	R3=C		R3 := l/LMAT cos(theta)
*
* R0 := 1x = l/LMAT cos (theta)
* R1 := 1y = h/HMAT cos (theta)
* R2 := 0x = h/HMAT sin (theta)
* R3 := 0y = l/LMAT sin (theta)
*

*
* Remplir les tableaux a et b
*
	D1=(5) 3+TMPBUF
	C=DAT1 A
	D1=C
* 0 degres
	C=R0
	GOSUB  PUSH	l/LMAT cos(t)
	C=R3
	GOSUB  PUSH	l/LMAT sin(t)
* 45 degres
	C=R0
	A=R2
	C=C-A  W
	GOSUB  PUSH	l/LMAT cos(t) - h/HMAT sin(t)
	C=R3
	A=R1
	C=C+A  W
	GOSUB  PUSH	l/LMAT sin(t) + h/HMAT cos(t)
* 90 degres
	C=R2
	C=-C   W
	GOSUB  PUSH	- h/HMAT sin(t)
	C=R1
	GOSUB  PUSH	h/HMAT cos(t)
* 135 degres
	C=R0
	A=R2
	C=A+C  W
	C=-C   W
	GOSUB  PUSH	- l/LMAT cos(t) - h/HMAT sin(t)
	C=R1
	A=R3
	C=C-A  W
	GOSUB  PUSH	- l/LMAT sin(t) + h/HMAT cos(t)
* 180 degres
	C=R0
	C=-C   W
	GOSUB  PUSH	- l/LMAT cos(t)
	C=R3
	C=-C   W
	GOSUB  PUSH	- l/LMAT sin(t)
* 225 degres
	C=R2
	A=R0
	C=C-A  W
	GOSUB  PUSH	- l/LMAT cos(t) + h/HMAT sin(t)
	C=R3
	A=R1
	C=C+A  W
	C=-C   W
	GOSUB  PUSH	- l/LMAT sin(t) - h/HMAT cos(t)
* 270 degres
	C=R2
	GOSUB  PUSH	h/HMAT sin(t)
	C=R1
	C=-C   W
	GOSUB  PUSH	- h/HMAT cos(t)
* 315 degres
	C=R0
	A=R2
	C=C+A  W
	GOSUB  PUSH	l/LMAT cos(t) + h/HMAT sin(t)
	C=R3
	A=R1
	C=C-A  W
	GOSUB  PUSH	l/LMAT sin(t) - h/HMAT cos(t)
*
* mettre le point courant :
*
	LC(2)  =oP
	GOSUBL =RBUFC
	A=DAT1 A	A(A) := Px
	D1=D1+ 5
	C=DAT1 A	C(A) := Py
	GOLONG =SETCUR

 PUSH
	DAT1=C W
	D1=D1+ 16
	RTN

************************************************************
* CP000
*
* But: deplacer la plume d'un certain nombre (non forcement
*   entier) d'espaces et de lignes.
* Entree:
*   - R1(A) = nb d'espaces
*   - R2(A) = nb de lignes
* Sortie:-
* Detail:
*   Cette fonction est appelee par LABEL pour assurer les
*   differents types de LORG. Les parametres envoyes sont
*   CP h, v 
*     h = 0, -L/2 / -L (L = longueur de la chaine)
*     v = 0 / -0.5 / -1
*   Pour cette raison, les arguments sont des nombres
*   entiers positifs.
*   i.e. : h = 0, L, 2*L
*	   v = 0, 1, 2
* Historique:
*   87/02/23: conception & codage
************************************************************

=CP000
*
* CPPAR.espace = 0 /  L	  / 2*L
*		 0 / -L/2 / -L
*   il faut diviser par 2, puis multiplier par LCAR, et
*   envoyer dans la direction 180 degres.
* CPPAR.ligne  = 0 /  1	  /  2
*		 0 / -0.5 / -1
*   il faut diviser par 2, puis multiplier par HCAR, et
*   envoyer dans la direction 270 degres.
*
	D1=(5) CPPAR	 D1=(5) CPPAR.espace
	C=R1
	DAT1=C A	 CPPAR.espace := R1(A)
	D1=D1+ 5	 D1=(5) CPPAR.ligne
	C=R2
	DAT1=C A	 CPPAR.ligne := R2(A)
*
* preparer les lettres :
*
	GOSUB  DEBLET
	GOSUB  FIGER
*
* on y va :
*

*
* espaces
*
	D1=(5) CPPAR
	A=0    W
	A=DAT1 A
	C=0    W
	LC(2)  LMAT
	GOSBVL =MPY
	CSRB
	P=     D180
	GOSUB  GETxyP
	GOSUBL =RSAUTE
*
* lignes
*
	D1=(5) (CPPAR)+5
	A=0    W
	A=DAT1 A
	C=0    W
	LC(2)  HMAT
	GOSBVL =MPY
	CSRB
	P=     D270
	GOSUB  GETxyP
	GOSUBL =RSAUTE
*
* on a termine :
*
	GOTO   FINLET

	END
