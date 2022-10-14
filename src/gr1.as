	TITLE	Graphique, Ordres HPGL type 1 <gr1.as>

************************************************************
*
* les ordres HPGL sont classes en deux categories : le
* groupe 1 et le groupe 2.
*
* Les ordres du groupe 1 sont ceux qui n'impliquent pas de
* trace directement. Ainsi, SP selectionne une plume mais
* ne modifie pas le graphique en cours.
* Dans le cas precis du driver "RASTER", ces ordres ont la
* caracteristique d'agir uniquement sur le buffer. On
* retrouve donc la notion de "non-trace".
*
* Ce groupe est subdivise en deux sous-groupes :
*  - les "ordres d'envoi d'information" renvoient au module
*    maitre des informations sur le "plotter virtuel". Ce
*    sont OE, OA, et OP.
*    Pour le driver "RASTER", ces ordres se contentent de
*    lire l'information dans le buffer.
*  - les "ordres de selection" configurent le "plotter
*    virtuel".
*    Pour le driver "RASTER", ce sont les ordres qui ne font
*    qu'ecrire dans le buffer.
*    Ce sont IP, IW, SP, PU, PD, SI, DI, LT etc...
*
************************************************************

 HDEF	EQU    20	hauteur par defaut des caracteres
 LDEF	EQU    12	largeur par defaut des caracteres
 LTLEN	EQU    16	Longueur du motif
 TLEN	EQU    4	Longueur des marques XT et YT

	STITLE Ordres de lecture (Output ...)
************************************************************
* OP (Output P1 & P2)
*
* But: Renvoyer au module maitre les coordonnes des deux
*   points particuliers P1 et P2.
* Entree: -
* Sortie:
*   - R1(P) = P1
*   - R2(P) = P2
* Abime: A(9-0), C(A), D(A), D1, R1, R2
* Appelle: BUFC
* Niveaux: 1
* Historique:
*   86/08/22: reprogrammation
************************************************************

=OP000	LC(2)  =oP1	C(B) := champ P1 du buffer
	GOSUB  =RBUFC	D1 := ^ champ P1
	A=DAT1 10	A(9-0) := P1
	R1=A		R1(P) := P1
	D1=D1+ 10	D1 := ^ champ P2
	A=DAT1 10	A(9-0) := P2
	R2=A		R2(P) := P2
	RTN

************************************************************
* OA (OUtput Actual pen position)
*
* But: renvoyer la position actuelle de la plume (meme en
*   dehors de la fenetre de trace).
* Entree: -
* Sortie:
*   - R1(P) = position courante de la plume
*   - R0(S) = etat de la plume (= 0 : levee, # 0 : baisee)
*   - R0(A) = numero de la plume (entre 0 et 7)
* Abime: A(9-0), C(A), D(A), D1, R0, R1
* Appelle: BUFC
* Niveaux: 1
* Historique:
*   86/08/22: reprogrammation
************************************************************

=OA000	LC(2)  =oP	C(B) := champ P
	GOSUB  =RBUFC	D1 := ^ champ P
	A=DAT1 10	A(9-0) := 
	R1=A		R1(P) := posit. courante de la plume

	LC(2)  =oPEN	C(B) := ^ caract. de la plume
	GOSUB  =RBUFC	D1 := ^ champ PEN
	A=DAT1 P	A(0) := plume courante + etat
	LC(1)  %1000
	C=C&A  P	C(0) := si plume levee alors 0
	CSRC		C(S) := etat de la plume

	C=0    A
	LC(1)  %0111
	C=C&A  P	C(0) := numero de la plume courante
	R0=C
	RTN

************************************************************
* OE (Output Error)
*
* But: renvoyer le code de la derniere erreur. Pour le
*   driver raster, cette instruction est une NOP.
* Entree: -
* Sortie:
*   - R0(A) = 0
* Abime: C(A), R0
* Niveaux: 0
* Historique:
*   86/08/22: reprogrammation
************************************************************

=OE000	C=0    A	Une erreur ? Ou ca ?
	R0=C   A
	RTN

	STITLE Ordres d'écriture (Input ..., Select...)
 ip	EQU    1	Flag utilise dans IP/IW

************************************************************
* DF (DeFault)
*
* But: mettre les informations dans le buffer a un etat
*   connu.
* Entree: -
* Sortie: -
* Abime: A(W), C(W), D(A), D0, D1
* Appelle: BUFC
* Niveaux: 1
* Detail: le buffer est initialise comme suit :
*   P1 & P2 : 5 quartets x 4 =20 (0, 0)&(npixls-1, taille-1)
*   W1 & W2 : 5 quartets x 4 =20 (0, 0)&(npixls-1, taille-1)
*   position courante : 5 x 2=10 (0, 0)
*   plume selectionnee	     = 1 (1)
*   type de trace	     = 1 (1)
*   longueur du motif	     = 5 (16)
*   CR point		5 x 2=10 (0, 0)
*   theta pour DI	     = 5 (0.0000)
*   hauteur, largeur des car =10 (20,12)
*   longueur des marques XT  = 5 (4)
* Historique:
*   86/08/22: reprogrammation
*   87/01/25: ajout de CR point, hauteur, largeur
*   87/02/23: ajout de oTLEN
************************************************************

=DF000	C=0    B	Premier champ = ^ debut du buffer
	GOSUB  =RBUFC	D1 := ^ debut du buffer
	D0=(5) =GRAFIL
	A=DAT0 A	A(A) := ^ debut de la zone graphique
	D0=A		D0 := ^ debut de la zone graphique
	D0=D0- 5	D0 := ^ taille

	A=0    W	A(9-0) := (0, 0)

	C=DAT0 A	C(A) := taille
	C=C-1  A	C(A) := P2y (= taille-1)
	GOSUB  =cslc5	C(9-5) := P2y
	LC(5)  =npixls
	C=C-1  A	C(A) := P2x (= npixls-1)

	DAT1=A 10	P1 (0, 0)
	D1=D1+ 10
	DAT1=C 10	P2 (npixls-1, taille-1)
	D1=D1+ 10

	DAT1=A 10	W1 (0, 0)
	D1=D1+ 10
	DAT1=C 10	W2 (npixls-1, taille-1)
	D1=D1+ 10

	DAT1=A 10	position courante = (0, 0)
	D1=D1+ 10

	ACEX   A
	LCHEX  1
	DAT1=C 1	Pen
	D1=D1+ 1

	C=0    A
	C=C-1  A
	DAT1=C 1	Line type (F : defaut)
	D1=D1+ 1
	LC(5)  LTLEN	Longueur du motif
	DAT1=C A
	D1=D1+ 5

	C=0    W
	DAT1=C 10	CR := (0, 0)
	D1=D1+ 10

	DAT1=C A	theta := 0
	D1=D1+ 5

	C=0    A
	LC(2)  HDEF	hauteur := 20
	DAT1=C A
	D1=D1+ 5

	C=0    A
	LC(1)  LDEF	largeur := 12
	DAT1=C A
	D1=D1+ 5

	C=0    A
	LC(1)  TLEN	longueur des marques := 2
	DAT1=C A
	D1=D1+ 5
	RTN

************************************************************
* TL (Tick Len)
*
* But: Selectionner la longueur des marques XT et YT.
* Entree:
*   - R0(A) = longueur en unites graphiques
* Sortie: -
* Abime:
* Appelle: 
* Niveaux: 
* Note: en interne, la longueur stockee est la moitie de la
*   longueur passee en parametre.
* Historique:
*   87/02/23: conception & codage
*   87/03/26: debogage
************************************************************

=TL000
	LC(2)  =oTLEN
	GOSUBL =RBUFC
* Changement le 87/03/26 de C=R1 en C=R0
	C=R0
	C=C+1  A
* Changement le 87/03/26 de C=R1 en C=R0
	C=R0		C(A) := longueur passee en parametre
	GONC   TL010	il y a un parametre
	C=0    A
	LC(1)  TLEN
 TL010
	DAT1=C A
	RTN

************************************************************
* IP (Input P1 & P2), IW (Input W1 & W2)
*
* But: Placer les points P1 & P2 (W1 & W2) dans la zone de
*   trace.
* Entree:
*   - R1(P) = P1 (W1)
*   - R2(P) = P2 (W2)
* Sortie: -
* Abime: A(W), C(W), R0-R3, D1, ST(ip)
* Appelle: cslc5, csrc5, TSTA>C TSTC>A, TSTA<C, TSTC<A, BUFC
* Niveaux: 1
* Detail:
*   Les valeurs de P1 & P2 (W1 & W2) sont prises telles que
*   P1 (W1) soit le coin en bas a gauche, et que P2 (W2)
*   soit le coin en haut a droite. Au besoin, ces points
*   sont corriges.
*   Un test est egalement fait, de sorte que P1 et P2 (W1 et
*   W2) soient bien dans la zone de trace.
* Algorithme: dans ce qui suit Qix est soit Pix, soit Wix
*   si Q1x > Q2x alors echanger (Q1x, Q2x) ;
*   si Q1y > Q2y alors echanger (Q1y, Q2y) ;
*   si Q1x < 0 alors Q1x := 0 ;
*   si Q1y < 0 alors Q1y := 0 ;
*   si Q2x > npixls-1 alors Q2x := npixls-1 ;
*   si Q2y > taille-1 alors Q2y := taille-1 ;
*   stocker Q1x, Q1y, Q2x, Q2y
* Historique:
*   86/08/22: reprogrammation
************************************************************

=IP000	ST=1   ip	Il faut introduire P1 et P2
	GOTO   IW005

=IW000	ST=0   ip	Il faut introduire W1 et W2

 IW005
*
* Si Q1x > Q2x alors echanger (Q1x, Q2x) ;
*
	A=R1		A(A) := Q1x
	C=R2		C(A) := Q2x
	GOSUB  =TSTA>C	si Q1x <= Q2x
	GONC   IW010	  alors IW010
	A=R1		A(A) := Q1x
	AR2EX		A(A) := Q2x, R2 := Q1x
	R1=A		R1 := Q2x
*
* Si Q1y > Q2y alors echanger (Q1y, Q2y) ;
*
 IW010	C=R1		C(9-5) := Q1y (ou peut-etre Q2y...)
	GOSUB  =csrc5	C(A) := Q1y
	R0=C		R0 := Q1y
	A=C    A	A(A) := Q1y
	C=R2		C(9-5) := Q2y
	GOSUB  =csrc5	C(A) := Q2y
	R3=C		R3 := Q2y
	GOSUB  =TSTA>C	si Q1y <= Q2y
	GONC   IW020	  alors IW020
	A=R3		A(A) := Q2y
	AR0EX		A(A) := Q1y ; R0 := Q2y
	R3=A		R3 = Q1y
*
* A present :
*   R1 = Q1x ; R2 = Q2x
*   R0 = Q1y ; R3 = Q2y
*
* si Q1x < 0 alors Q1x := 0 ;
*
 IW020	C=R1		C(A) := Q1x (Qix min)
	C=C+C  A	si Q1x >= 0
	GONC   IW030	  alors IW030
	C=0    A
	R1=C		R1 := 0
*
* si Q1y < 0 alors Q1y := 0 ;
*
 IW030	C=R0		C(A) := Q1y (Qiy min)
	C=C+C  A	si Q1y >= 0
	GONC   IW040	  alors IW040
	C=0    A
	R0=C		R0 := 0
*
* si Q2x > npixls - 1 alors Q2x := npixls - 1 ;
*
 IW040	A=R2		A(A) := Q2x
	LC(5)  =npixls
	GOSUB  =TSTA<C	si Q2x < npixls
	GOC    IW050	  alors IW050
	LC(5)  (=npixls)-1
	R2=A		R2 := npixls - 1
*
* si Q2y > taille - 1 alors Q2y := taille - 1 ;
*
 IW050	D1=(5) =GRAFIL
	C=DAT1 A	C(A) := ^ debut de la zone graphique
	D1=C		D1 := ^ debut de la zone graphique
	D1=D1- 5	D1 := ^ taille
	C=DAT1 A	C(A) := taille
	A=R3		A(A) := Q2y
	GOSUB  =TSTA<C	si Q2y < taille
	GOC    IW060	  alors IW060
	C=DAT1 A	C(A) := taille
	C=C-1  A	C(A) := taille - 1
	R3=C		R3 := taille - 1
*
* stocker Q1x, Q1y, Q2x, Q2y
*
 IW060	LC(2)  =oP1
	?ST=1  ip	est-ce P1 et P2 ?
	GOYES  IW070
	LC(2)  =oW1	non. C'est W1 et W2
 IW070	GOSUB  =RBUFC	D1 := ^ champ Q1x du buffer
	C=R1		C(A) := Q1x
	DAT1=C A
	D1=D1+ 5
	C=R0		C(A) := Q1y
	DAT1=C A
	D1=D1+ 5
	C=R2		C(A) := Q2x
	DAT1=C A
	D1=D1+ 5
	C=R3		C(A) := Q2y
	DAT1=C A
	RTN

************************************************************
* SP (Select Pen)
*
* But: Selectionner une plume
* Entree:
*   - R0(A) := plume
* Sortie: -
* Abime: A(W), B(0), C(W), D(A), D1
* Appelle: BUFC
* Niveaux: 1
* Detail:
*   A moins d'une indication contraire, SP ne change pas
*   l'etat (baisse / leve) de la plume.
*   D'autre part, il faut noter que cette instruction n'est
*   la que pour ne pas provoquer d'erreur.
* Historique:
*   86/08/22: reprogrammation
************************************************************

=SP000	LC(2)  =oPEN	C(B) := champ PEN
	GOSUB  =RBUFC
	C=0    A
	LC(1)  %0111	LC(5) %0111
	A=R0		A(A) := plume demandee
	A=A&C  A	A(A) := plume mod 8
	B=A    P	B(0) := plume mod 8
	A=DAT1 P	A(0) := ancienne plume
	C=-C-1 P	LC(1) %1000 fait 1 quartet de plus !
	A=A&C  P	bit de poids fort = 0 si levee
	A=A+B  P	ancien etat + nouvelle plume
	DAT1=A P	Et hop !
	RTN

************************************************************
* PD (Pen Down)
*
* But: baisser la plume, c'est a dire autoriser le tracage.
*   Si le point courant est dans les limites de trace,
*   tracer un point.
* Entree: -
* Sortie: -
* Abime: A(0), C(A), D(A), D1
* Appelle: BUFC
* Niveaux: 1
* Historique:
*   86/08/22: reprogrammation
************************************************************

=PD000	LC(2)  =oPEN
	GOSUB  =RBUFC
	A=DAT1 P	A(0) := plume + etat courants
	LC(1)  %1000
	A=A!C  P	Bit de poids fort = 1
	DAT1=A P
*
* Si le point courant est dans les limites de trace, tracer
* juste un point.
*
	LC(2)  =oP
	GOSUB  =RBUFC
	A=DAT1 A	A(A) := x courant
	D1=D1+ 5
	C=DAT1 A	C(A) := y courant
	GOSUBL =SETCUR	Point courant pour le trace
	GOSUBL =TSTPT
	RTNC		RTN if point hors limites
*
* Tracer le point :
*
	A=0    A	dx := 0
	C=0    A	dy := 0
	GOLONG =RTRACE

************************************************************
* PU (Pen Up)
*
* But: lever la plume, c'est a dire interdire le tracage.
* Entree: -
* Sortie: -
* Abime: A(0), C(A), D(A), D1
* Appelle: BUFC
* Niveaux: 1
* Historique:
*   86/08/22: reprogrammation
************************************************************

=PU000	LC(2)  =oPEN
	GOSUB  =RBUFC
	A=DAT1 P	A(0) := plume + etat courants
	LC(1)  %0111
	A=A&C  P	Bit de poids fort = 0
	DAT1=A P
	RTN

************************************************************
* DI000
*
* But: selectionne la direction pour les traces de lettres.
* Entree:
*   - R0(W) = theta (12 digits form)
* Sortie: -
* Abime: A(W), C(W), D1, R0
* Appelle: BUFC
* Niveaux: 1
* Note: theta est exprime en radians, et est compris entre 0
*   et 2PI.
* Historique:
*   87/01/25: conception & codage
************************************************************

=DI000
	A=R0
	P=     0
	LCHEX  0655360000000004
	SETDEC
	GOSBVL =MP2-12
	GOSBVL =uRES12
	SETHEX
	P=     0
	A=C    W
	GOSBVL =FLTDH
	R0=A
	LC(2)  =oTHETA
	GOSUB  =RBUFC
	A=R0
	DAT1=A A
*
* Actualisation de CR point
*
	LC(2)  =oP
	GOSUB  =RBUFC
	A=DAT1 10
	LC(2)  =oCR
	GOSUB  =RBUFC
	DAT1=A 10
	RTN

************************************************************
* SI000
*
* But: 
* Entree:
*   - R1(A) = hauteur des car. en pixels (valeur entiere)
*   - R2(A) = largeur (idem)
* Sortie: -
* Abime: A(W), C(W), D1, R0
* Appelle: BUFC
* Niveaux: 1
* Historique:
*   87/01/25: conception & codage
************************************************************
=SI000
	LC(2)  =oHCAR
	GOSUB  =RBUFC
	C=R1
	DAT1=C A
	D1=D1+ 5
	C=R2
	DAT1=C A
	RTN

************************************************************
* LT000
*
* But: Selectionner le type de trace.
* Entree:
*   - R0(A) = motif desire
*      -1 (#FFFFF) pour ligne droite
*      0 pour LT 2
*      1 pour LT 3
*      etc.
*   - R1(A) = longueur du motif (ici en GU)
*      (-1 si aucun parametre)
* Sortie: -
* Abime: A(W), C(W), D1, R0
* Appelle: BUFC
* Niveaux: 1
* Historique:
*   86/11/19: conception & codage
************************************************************

=LT000	LC(2)  =oLT
	GOSUB  =RBUFC
	A=R0
	DAT1=A P
	D1=D1+ 1

	C=R1
	C=C+1  A	aucun parametre : #FFFFF
	C=R1
	GONC   LT010	il y a un parametre
	LC(5)  LTLEN	Longueur du motif par defaut
 LT010
	DAT1=C A
	RTN

	STITLE Ordre DU (Dump graphics)
************************************************************
* DU (DUmp graphics)
*
* But: imprimer le contenu de la memoire graphique sur le
*   peripherique designe par l'instruction PLOTTER IS ...
* Entree: -
* Sortie: -
* Abime: A-D, D0, D1, ST, STMTR0, STMTR1, FUNCD0, FUNCD1
* Appelle: POLL, PRASCI (HPIL)
* Niveaux: 5
* Historique:
*   86/08/22: reprogrammation
************************************************************

=DU000	GOSBVL =OBCOLL
	D0=(5) =IS-PLT
	C=DAT0 7
	D0=(4) 2+=STMTR1
	DAT0=C 7
	D0=(4) =MLFFLG
	LCHEX  3F	Type 3 = plotter
	DAT0=C B
	GOSBVL =POLL
	CON(2) =pPRTCL
	GOC    DU10
	?XM=0
	GOYES  DU20
	LC(4)  (=graid)~(=ePLTRC) Plotter not reachable
 DU10	GOVLNG =BSERR
* Poll pPRTCL has been handled by HPIL. (1+STMTR0) is the
* address of PRASCI
 DU20	D1=(5) =GRAFIL
	A=DAT1 A	A = adresse du graphique
	D1=(2) =STMTR1
	DAT1=A A	S-R1-0 := ^ GRAPHILE
	D1=D1+ 5	S-R1-1
	D0=A		D0 ^ Debut du fichier GRAPHILE
	D0=D0- 5	
	A=DAT0 A	A(B)=Nb de lignes a imprimer
	DAT1=A A	STMTR1[0-4]=^graphile
	  *		STMTR1[5-9]=compteur
	GOSUB  DU60
	CON(1) 4	4 octets
	CON(2) 27
	NIBASC '*1S'	graphique en faible densite
 DU30	GOSUB  DU60
	CON(1) 6
	CON(2) 27
*--- !!! attention : npixls est hard-coded ici !!! ---
	NIBASC '*b80W'
* Now, we must copy the string, with nibble permutation
	D1=(5) =STMTR1
	C=DAT1 A	pointeur dans GRAPHILE
	D1=C		address of line to copy
	LC(2)  (=npixls)/8  80 bytes to copy
	B=C    B	counter
	D0=(5) =OUTBS
	C=DAT0 A
	D0=C		start of output buffer
	GOTO   DU34	Carry is not predictable
 DU32	C=DAT1 B
	P=C    0
	CPEX   1
	C=P    0
	DAT0=C B
	D0=D0+ 2
	D1=D1+ 2
 DU34	B=B-1  B
	GONC   DU32
	P=     0
* the line is copied, ready to be printed
	CD1EX		C := final value D1 during the loop
	D1=(5) =STMTR1
	DAT1=C A	next line to be processed
	D0=(5) =OUTBS
	C=DAT0 A
	D=C    A	start address of the string
	C=0    A
	LC(2)  (=npixls)/8
	A=C    A	length of the string (in bytes)
	GOSUB  DU80	send to the printer
	D0=(5) 5+=STMTR1
	A=DAT0 A	line count
	A=A-1  A
	DAT0=A A
	?A=0   A
	GOYES  DU40
	GOTO   DU30	because "jump or value too large"
 DU40	GOSUB  DU60
	CON(1) 4
	CON(2) 27
	NIBASC '*rB'	Fin de l'envoi du graphique
* End. Clean up the loop
	D1=(5) 1+=STMTR0
	C=DAT1 A
	D0=C
	D0=D0- 5
	C=DAT0 A	REL(5) =PREND at F107A, HPIL rom
	AD0EX
	C=C+A  A	@ PREND
	DAT1=C A
	GONC   DU80	B.E.T., with return to GRAPHLEX

* DU60 : Envoi d'une sequence constante 
* GOSUB DU60
* CON(1) nb_d'octets_a_envoyer
* NIBASC ... 
 DU60	C=RSTK
	D1=C		D1 ^ buffer dans le code
	D=C    A
	D=D+1  A	D = string address (in the code)
	A=0    A
	A=DAT1 1	A(A) = character count
	GOSUB  DU80
	CD1EX		^ retour = ^ dernier caract. envoye
	RSTK=C
	RTN
 DU80	D1=(5) 1+=STMTR0
	C=DAT1 A
	RSTK=C
	RTN

	END
