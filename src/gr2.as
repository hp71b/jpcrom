	TITLE	Graphique, Tracé de droite <gr2.as>

 SAUV10 EQU    =FUNCR0	10 quartets pour XT qet YT

*
* flag permut :
*   1 si les deux points ont ete permutes de telle maniere
*   que x1 <= x2.
*
 permut EQU    0

*
* Zones memoires necessaires pour le trace avec LT :
*

*
* Coordonnees (en format 4 chiffres hexadecimaux apres la
* virgule) du point courant. Concorde avec PLUMEX et PLUMEY,
* avec plus de precision.
* Chaque valeur est stockee sur 8 quartets
 X	EQU    (=STMTR0)+00
 Y	EQU    (=STMTR0)+08
*
* Valeurs des projections des deplacements unite sur l'axe
* des x et des y. Chaque valeur est stockee sur 8 quartets.
*
 Ux	EQU    (=STMTR0)+16
 Uy	EQU    (=STMTR0)+24
*
* Valeurs limite du trace. Sur 5 quartets chacun
*
 x2	EQU    (=FUNCR0)+00
 y2	EQU    (=FUNCR0)+05
*
* Adresse dans la table des Line_Type
*
 LTADR	EQU    (=FUNCR0)+10
*
* Numeros de flags :
*   flagdx : on s'arrete lorsque X=Alim (ou Y=Alim)
*
 flagdx EQU    6
*
*   sgn : dx (ou dy) > 0
*      (sgn = 1 <==> nb positif)
*
 sgn	EQU    7
*
*   fini : lorsqu'il faut sortir de la boucle
*
 fini	EQU    8
*
*   saut : sauter (tracer) le segment de droite
*
 saut	EQU    9

************************************************************
* XT000, YT000
*
* But: tracer une marque verticale (XT) ou horizontale (YT)
*   a la position courante de la plume.
* Entree: -
* Sortie: -
* Historique:
*   87/02/10: conception & codage
************************************************************

=XT000
	LC(2)  =oTLEN
	GOSUBL =RBUFC
	A=0    W	dx := 0
	C=0    W
	C=DAT1 A
	CSRB		en longueur reelle
	GOTO   XYT00
=YT000
	LC(2)  =oTLEN
	GOSUBL =RBUFC
	A=0    W	dx := 0
	C=0    W
	C=DAT1 A
	CSRB		en longueur reelle
	ACEX   A	dx := TL ; dy := 0
*
* A(A) := dx
* C(A) := dy
*
 XYT00
*
* Sauver les dx et dy
*
	D0=(5) SAUV10
	DAT0=A A	SAUV10.dx := dx
	D0=D0+ 5
	DAT0=C A	SAUV10.dy := dy
*
* Obtenir le point courant
*
	LC(2)  =oP
	GOSUBL =RBUFC
	A=DAT1 A	A(A) := x courant
	D1=D1+ 5
	C=DAT1 A	C(A) := y courant
	D=C    A	D(A) := y courant
*
* Placer  le point courant a (x + dx, y + dy)
*
	D0=D0- 5	D0 := ^ SAUV10.dx
	C=DAT0 A	C(A) := dx
	C=-C   A	C(A) := -dx
	A=A+C  A	A(A) := x - dx
	D0=D0+ 5	D0 := ^ SAUV10.dy
	C=DAT0 A	C(A) := dy
	C=-C   A	C(A) := -dy
	C=C+D  A	C(A) := y - dy
	GOSUBL =SETCUR	A(A) = x' ; C(A) = y'
*
* Tester si le nouveau point courant est dans les limites de
* trace
*
	GOSUB  =TSTPT
	RTNC		RTN if point hors limites
	GOSUBL =GETCUR	A(A) := x' ; C(A) := y'
	D0=(5) SAUV10
	D=C    A	D(A) := x'
	C=DAT0 A	C(A) := dx
	C=C+C  A	C(A) := 2dx
	A=A+C  A	A(A) := x' + 2dx (x+dx)
	D0=D0+ 5
	C=DAT0 A	C(A) := dy
	C=C+C  A	C(A) := 2dy
	C=C+D  A	C(A) := y' + 2dy (y+dy)
	GOSUB  =TSTPT
	RTNC		RTN if point hors limites
	C=DAT0 A	C(A) := dy
	C=C+C  A	C(A) := 2dy
	D0=D0- 5
	A=DAT0 A	A(A) := dx
	A=A+A  A	A(A) := 2dx
	GOLONG =RTRACE

************************************************************
* TSTPT
*
* But: Tester si le point de coordonnes (x,y) est dans la
*   fenetre de trace (W1,W2).
* Entree:
*   - A(A) = x
*   - C(A3 = y
* Sortie:
*   - Cy = 1 : point hors limites
*   - Cy = 0 : point dans les limites
* Appelle: TST..., BUFC
* Niveaux: 1
* Abime: A-D, D1
* Historique:
*   87/02/10: conception & codage
************************************************************

=TSTPT
	B=C    A	B n'est pas abime par BUFC
	LC(2)  =oW1
	GOSUBL =RBUFC
	C=B    A
	D=C    A	D(A) := y
*
* Sauvegarde de x
*
	B=A    A	B(A) := x
* x < W1x
	C=DAT1 A	C(A) := W1x
	GOSUBL =TSTA<C	x < W1x
	RTNC		RTN if x < W1x
* x > W2x
	A=B    A	A(A) := x
	D1=D1+ 10	D1 := ^ W2x
	C=DAT1 A
	GOSUBL =TSTA>C	x > W2x
	RTNC		RTN if x > W2x
* y < W1y
	C=D    A	C(A) := y
	D1=D1- 5	D1 := ^ W1y
	A=DAT1 A
	GOSUBL =TSTC<A	y < W1y
	RTNC
* y > W2y
	C=D    A	C(A) := y
	D1=D1+ 10	D1 := ^ W2y
	A=DAT1 A	A(A) := W2y
	GOSUBL =TSTC>A	y > W2y
	RTNC
*
* Ca baigne !
*
	RTN

************************************************************
* PA000
*
* But: tracer un segment de droite.
* Entree:
*   - R1(P) = point de destination
* Sortie: -
* Appelle: ou la la !
* Abime: Tous les registres, toute la ram autorisee
* Historique:
*   86/05/--: conception & codage
*   86/09/--: reprogrammation
*   87/02/10: ajout de l'en-tete
************************************************************

=PA000
	LC(2)  =oCR	mise a jour du CR point
	GOSUBL =RBUFC
	CD1EX
	D0=C

	LC(2)  =oP
	GOSUBL =RBUFC
	A=DAT1 10	A = position courante
	C=R1		C = position future
	DAT0=C 10	pour le CR
	DAT1=C 10	place aux jeunes !
	R2=A		R2 = vieille position
*
* Il faudrait peut-etre voir l'etat de la plume, avant de se
* mettre a tracer...
*
	LC(2)  =oPEN
	GOSUBL =RBUFC
	C=DAT1 S	C(S) = plume
	C=C+C  S	Cy=1 <=> plume baissee (trace)
	RTNNC		retour si la plume etait baissee
*
* debut des tests sur la fenetre active
*
	LC(2)  =oW1
	GOSUBL =RBUFC
	C=DAT1 10	C = W1
	R0=C		R0 = W1
	D1=D1+ 10
	C=DAT1 10	C = W2
	R3=C		R3 = W2
* R0 = W1
* R1 = P
* R2 = P' (les vieilles coordonnees)
* R3 = W2
	C=R1		P (nouvelle position)
	GOSUBL =csrc5
	A=C    A	A(A) = y
	C=R2		P' (vieille position)
	GOSUBL =csrc5	C(A) = y'
	?A#C   A	y = y'
	GOYES  PA010	ce n'est pas une ligne horizontale
************************************************************
* ligne horizontale (y=y')
************************************************************
	GOSUBL HRZVRT	limite le trait sur les x
*
* Si trace impossible, on ne va pas insister...
*
	RTNNC
*
* R1 = plus petite limite (Q1)
* R2 = plus grande limite
*
	GOSUBL RiSRC5
	GOSUBL TSTIN	y est dans la fenetre ?
*
* Cy = 1 <==> y n'est pas dans la fenetre
*
	RTNC
*
* y est bien dans la fenetre de trace
*
	A=R1		A(A) := y
	GOSUBL RiSLC5
*
* R1 = x1
* R2 = x2
* A(A) = y
*
	C=R1
	R0=C		R0 := x1
	R1=A		R1 := y
	R3=A		R3 := y
	GOTO   tracer_la_ligne

********
* Ce n'est pas une ligne horizontale
********
 PA010	C=R1		x (nouveau)
	A=R2		x' (vieux)
	?A#C   A	x = x'
	GOYES  PA020	ligne oblique

************************************************************
* ligne verticale (x=x')
************************************************************
	GOSUBL TSTIN
* Cy = 1 <==> x n'est pas dans la fenetre
	RTNC
* x est bien dans la fenetre de trace
	GOSUBL RiSRC5
	GOSUBL HRZVRT	limite le trait sur les y
*
* Si trace impossible, on ne va pas insister...
*
	RTNNC
* Ri=xxxxx......yyyyy	R1 = a (grand), R2 = a' (petit)
	C=R2
	R3=C		R3 := y2
	GOSUBL =cslc5	C(A) := x
	R0=C		R0 := x
	R2=C		R2 := x
*
* R0 = x
* R1 = y1
* R2 = x
* R3 = y2
*
	GOTO   tracer_la_ligne

************************************************************
* ligne oblique
************************************************************
 PA020	GOSUBL minmax	R1 := Q1; R2 := Q2
	GOSUBL TSTIN	verifie que les x sont valides
	RTNC
*
* Sauvegarde de Q1 et Q2 dans FUNCR0 et FUNCR1
* et de ST(permut) dans ST(permut+1)
*
	D1=(5) =FUNCR0
	C=R1
	DAT1=C W
	D1=D1+ 16
	C=R2
	DAT1=C W

	ST=0   (permut)+1
	?ST=0  permut
	GOYES  PA021
	ST=1   (permut)+1
 PA021
*
* teste si les y sont dans la zone de trace
*
	GOSUBL RiSRC5
	GOSUBL minmax	 R1 := Q1; R2 := Q2 !!!! pour y
	GOSUBL TSTIN	 Les y sont dans la zone ?
	RTNC		 Non
	GOSUBL RiSLC5	 restaure W1 & W2
*
* Restauration de Q1 et Q2 sauvegardes dans FUNCR0 et FUNCR1
* et de ST(permut) sauvegarde dans ST(permut+1)
*
	C=DAT1 W
	R2=C
	D1=D1- 16
	C=DAT1 W
	R1=C

	ST=0   permut
	?ST=0  (permut)+1
	GOYES  PA023
	ST=1   permut
 PA023
*
* Maintenant :
* R1 = Q1 ; R2 = Q2
* R0 = W1 ; R3 = W2
* x et y sont valides, mais ils peuvent encore etre en
* dehors des limites de trace.
* En fait, on sait a present que :
* x2>=W1x, x1<=W2x, y2>=W1y et y1<=W2y
*
	A=R1		A(A) := x1
	C=R0		C(A) := W1x
	GOSUBL =TSTC>A
	GONC   PA210
*
* La droite definie par Q1 et Q2 coupe la verticale x=W1x
*
	C=R0
	GOSUBL coupe	y1 = ordonnee du point d'intersec-
	GOSUBL =cslc5	tion avec x=W1x
	A=R0		A(A) := W1x
	C=0    A
	C=C+A  A	C := (y'1, W1x)
	R1=C

 PA210	A=R2		x2
	C=R3		W2x
	GOSUBL =TSTA>C	?x2<=W2x
	GONC   PA220	GOYES PA220
*
* Intersection avec la droite x=W2x
*
	C=R3
	GOSUBL coupe
	GOSUBL =cslc5
	A=R3
	C=0    A
	C=C+A  A
	R2=C   A
*
* A present, teste les y
*
PA220	GOSUBL swpreg
	A=R1
	C=R2
	GOSUBL =TSTA>C	?y1>y2
	GOC    PA250	GOYES PA250

	A=R1
	C=R0
	GOSUBL =TSTC>A	?y1>=W1y
	GONC   PA230	GOYES PA230
	C=R0
	GOSUBL coupe
	GOSUBL =cslc5
	A=R0
	C=0    A
	C=C+A  A
	R1=C   A
PA230	A=R2
	C=R3
	GOSUBL =TSTA>C	?y2<=W2y
	GONC   PA300	GOYES PA300
	C=R3
	GOSUBL coupe
	GOSUBL =cslc5
	A=R3
	C=0    A
	C=C+A  A
	R2=C   A
	GOTO   PA300

PA250	A=R2		Ici, nous avons y1>y2
	C=R0
	GOSUBL =TSTC>A	?y2>=W1y
	GONC   PA260	GOYES PA260
	C=R0
	GOSUBL coupe
	GOSUBL =cslc5
	A=R0
	C=0    A
	C=C+A  A
	R2=C   A
PA260	A=R1
	C=R3
	GOSUBL =TSTA>C	?y1<=W2y
	GONC   PA300	GOYES PA300
	C=R3
	GOSUBL coupe
	GOSUBL =cslc5
	A=R3
	C=0    A
	C=C+A  A
	R1=C   A

********
* Filtre final
********
PA300	C=R1		C(A) := y1
	GOSUBL =INTERV	Test y1 is in [W1y..W2y]
	RTNC		... non...
	C=R2		C(A) := y2
	GOSUBL =INTERV
	RTNC
	GOSUBL swpreg	Ri=......yyyyyxxxxx
	C=R1
	GOSUBL =INTERV	Test x1 is in [W1x..W2x]
	RTNC
	C=R2
	GOSUBL =INTERV
	RTNC
*
* A present, la ligne est limitee. Elle sera tracee entre
* les points Q1 (dans R1) et Q2 (dans R2).
* Nous savons egalement que x1<=x2 (x1 peut egaler x2, car
* les calculs ont provoque une perte de precision).
* Nous devons donc tracer une ligne oblique, definie par :
*   (x1, y1) = point de depart
*   (x2, y2) = point d'arrivee
*
* R1=Q1
* R2=Q2
*
	C=R1
	R0=C		R0 := x1
	GOSUBL =csrc5
	R1=C		R1 := y1

	C=R2
	GOSUBL =csrc5
	R3=C		R3 := y2

************************************************************
* tracer_la_ligne
*
* But: reunir les trois cas de ligne (horizontale, verticale
*   et oblique). Traiter le LINETYPE.
* Entree:
*   - R0(A) = x1  (point de depart)
*   - R1(A) = y1
*   - R2(A) = x2  (point d'arrivee)
*   - R3(A) = y2
* Sortie:
*   - par RTRACE
* Detail: x1<=x2
* Historique:
*   86/10/15: conception & codage
*   87/02/11: reprogrammation
************************************************************

 tracer_la_ligne
	A=R0
	C=R1
	GOSUBL =SETCUR
*
* Selection du type de trace
*
	LC(2)  =oLT
	GOSUBL =RBUFC
	A=DAT1 1
*
* A(0) = F ==> ligne pleine
* A(0) = 0 ==> seulement les points extremes
* A(0) = 1 a 6 ==> selon le motif
*
	A=A+1  P
	GOC    ligne_pleine
	A=A-1  P
	A=A-1  P
	GOC    extremes LT 0 : seulement les extremites
	LC(1)  5
	?A<=C  P	LT 1 a 6
	GOYES  line_type
*
* Ligne pleine
*
 ligne_pleine
	A=R2
	C=R0
	A=A-C  A	A(A) := dx (x2-x1)
	C=R1
	B=C    A
	C=R3
	C=C-B  A	C(A) := dy (y2-y1)
	GOLONG =RTRACE
*
* LT = 0 ; tracer seulement les points extremes
*
 extremes
	D1=(5) SAUV10
	C=R2
	DAT1=C A	SAUV10 + 0 := x2
	D1=D1+ 5
	C=R3
	DAT1=C A	SAUV10 + 5 := y2
	GOSUB  extr10
	D1=(5) SAUV10
	A=DAT1 A
	D1=D1+ 5
	C=DAT1 A
	GOSUBL =SETCUR
 extr10
	A=0    A	dx := 0
	C=0    A	dy := 0
	GOLONG =RTRACE
	
*
* Cette partie traite les cas de LINETYPE compris entre 1
* et 6, c'est a dire les LINETYPE reguliers
*
 line_type
*
* si ST(permut) alors permuter (x1, y1) et (x2, y2)
*
	?ST=0  permut
	GOYES  lin002
	A=R0
	C=R1
	AR2EX
	CR3EX
	R0=A
	R1=C
 lin002
	A=R0		A(A) := x1
	C=R1		C(A) := y1
	GOSUBL =SETCUR

	D0=(5) x2
	A=R2		A(A) := x2
	DAT0=A A	x2
	D0=D0+ 5	D0=(5) y2
	A=R3		A(A) := y2
	DAT0=A A	y2
*
* dx := x2 - x1
*
	C=R2		C(A) := x2
	A=R0		A(A) := x1
	C=C-A  A	C(A) := dx
	R0=C		R0 := dx (sur 5 quartets)
*
* dy := y2 - y1
*
	C=R3		C(A) := y2
	A=R1		A(A) := y1
	C=C-A  A	C(A) := dy
	R1=C		R1 := dy (sur 5 quartets)
*
* rendre LTLEN accessible :
*
	LC(2)  =oLTLEN
	GOSUBL =RBUFC	D1 := ^ LTLEN

	D0=(5) Ux
*
* si dx = 0
*
	C=R0
	?C#0   A	?dx#0
	GOYES  lin010
*
*   alors
*     si dy = 0 alors exit fin si
*
	C=R1		C(A) := dy
	?C=0   A
	RTNYES		exit PA if dx = dy = 0
*
*     flagdx := faux
*
	ST=0   flagdx
*
*     Ux := 0
*
	C=0    W
	DAT0=C 8
	D0=D0+ 8
*
*     Uy := r * signe (dy)
*     s := signe (dy)
*
	C=0    W
	C=DAT1 A	C(A) := LTLEN
	CSL    W
	CSL    W
	CSL    W	C(A) := LTLEN / 16 * 65536
	A=R1		A(A) := dy
	ST=1   sgn
	A=A+A  A
	GONC   lin005	dy > 0

	C=-C   W	C(A) := - (LTLEN * 4096)
	ST=0   sgn

 lin005
	DAT0=C 8	Ux := C(W) (en fait, W/2)
	GOTO   lin050

*
*   sinon
*
 lin010
*
*     memorisation des signes de dx et dy dans Uy
*
	D0=D0+ 8	D0 := ^ Uy
	A=0    W	A(S) := signe +
	SETDEC
	A=A-1  P	A(P) := signe -
	SETHEX

	C=R0		C(A) := dx
	GOSUB  valabs	C(A) := |dx| ; Uy+0 := signe(dx)
	R0=C		R0 := |dx|
	C=R1		C(A) := dy
	GOSUB  valabs	C(A) := |dy| ; Uy+1 := signe(dy)
	R1=C		R1 := |dy|
*
*     t := 1 / SQRT (1 + (dy/dx)^2) * r / 16 * 65536
*     Ux := t * signe (dx)
*     Uy := t * signe (dy) * |dy/dx|
*
	A=R0		A(A) := |dx|
	GOSBVL =HDFLT
	R0=A		R0 := |dx| en 12 digits
	A=R1		A(A) := |dy|
	GOSBVL =HDFLT
	R1=A		R1 := |dy| en 12 digits
	C=R0		C(W) := |dx|
	GOSBVL =DV2-12	X := |dy|/|dx|
	GOSBVL =STSCR	PUSH |dy|/|dx|

	C=B    W	}
	D=C    W	} Y := X
	C=A    W	}
	GOSBVL =MP2-15	(dy/dx)^2

	GOSBVL =ADDONE	X := 1 + (dy/dx)^2
	GOSBVL =SQR15	X := SQRT(1 + (dy/dx)^2)
	GOSBVL =1/X15	X := 1 / SQRT(1 + (dy/dx)^2)

	GOSBVL =STSCR
	A=DAT1 A	A(A) := LTLEN
	GOSBVL =HDFLT
	GOSBVl =SPLITA	X := r
	GOSBVL =RCSCR	Y := 1 / SQRT(1 + (dy/dx)^2)
	GOSBVL =MP2-15	X := r / SQRT(1 + (dy/dx)^2)
	C=0    W
	P=     11
	LCHEX  4096
	P=     0
	D=C    W
* D(W) = 0409600000000000
	C=0    W
	LC(1)  3	Y := 4096
	GOSBVL =MP2-15	X := t * 65536

	GOSBVL =STSCR	PUSH t * 65536

	D0=(5) Uy	D0 := ^ signe de dx
	GOSUB  D15HEX
	D0=D0- 8	D0 := ^ Ux
	DAT0=C 8	Ux := t * 65536 * signe(dx)

	SETDEC
	GOSBVL =RCSCR	Y := t * 65536
	GOSBVL =XYEX	X := t * 65536
	GOSBVL =RCSCR	Y := |dy|/|dx|
	GOSBVL =MP2-15	X := t * 65536 * |dy|/|dx|
	D0=(5) (Uy)+1	D0 := ^ signe (dy)
	GOSUB  D15HEX
	D0=D0- 1	D0=(5) Uy
	A=DAT0 S	A(S) := signe (dx)
	DAT0=C 8	Uy := t*65536*|dx|/|dy|*signe(dy)
*
*     s := signe (dx)
*
	ST=1   sgn
	A=A-1  S	Cy := si + alors 1 sinon 0
	GOC    lin020
	ST=0   sgn
 lin020
*
*     flagdx := vrai
*
	ST=1   flagdx


*
* fin si
*
 lin050
*
* preparatifs du trace
*

*
* stocker X et Y en pleine precision :
*
	GOSUBL =GETCUR	A(A) := x1 ; C(A) := y1
	D0=(5) X	X en pleine precision (8 quartets)
	GOSUB  STOXY
	D0=D0+ 8	D0=(5) Y
	A=C    A	A(A) := y1
	GOSUB  STOXY

	ST=0   fini
	GOSUB  GTLTAD
*
* boucle
*
 lin100
*
* recuperer Ux, Uy, X, Y
*
	D0=(5) X
	GOSUB  RCLXY
	R0=C
	GOSUB  RCLXY
	R1=C
	GOSUB  RCLXY
	R2=C
	GOSUB  RCLXY
	R3=C
*
* lire l dans la table des LT :
*
	D1=(5) LTADR	D1 := ^ adr. ds la table des LT
	C=DAT1 A
	D1=C
	C=0    W
	C=DAT1 P	C(W) := l
*
* X := X + l*Ux
*
	D0=(2) X
	A=R2		A(W) := Ux
	GOSBVL =MPY	C(W) := l*Ux
	A=R0		A(W) := X
	C=A+C  W	C(W) := X + l*Ux
	R0=C
	DAT0=C 8	X := X + l*Ux
*
* Y := Y + l*Ux
*
	C=0    W
	C=DAT1 P	C(W) := l

	D0=D0+ 8
	A=R3		A(W) := Uy
	GOSBVL =MPY	C(W) := l*Uy
	A=R1		A(W) := Y
	C=A+C  W	C(W) := Y + l*Uy
	R1=C
	DAT0=C 8	Y := Y + l*Uy

*
* arrondi des X et Y pour la suite du calcul :
*
	C=R0		C(W) := X
	GOSUBL =ROUNDC	C(A) := X
	R0=C		R0 := X arrondi
	C=R1		C(W) := Y
	GOSUBL =ROUNDC	C(A) := Y
	R1=C		R1 := Y arrondi

	?ST=0  flagdx
	GOYES  lin150

	D1=(5) x2
	?ST=0  sgn	si s<0
	GOYES  lin110

	C=R0		C(A) := X
	A=DAT1 A	A(A) := x2
	GOSUBL =TSTC<A	?X<x2
	GOC    lin200	GOYES lin200
	GONC   lin190	B.E.T. fini
 lin110
	C=R0		C(A) := X
	A=DAT1 A	A(A) := x2
	GOSUBL =TSTC>A	?X>x2
	GOC    lin200	GOYES lin200
	GONC   lin190	B.E.T. fini

 lin150
	D1=(5) y2
	?ST=0  sgn	si s<0
	GOYES  lin160

	C=R1		C(A) := Y
	A=DAT1 A	A(A) := y2
	GOSUBL =TSTC<A	?Y<y2
	GOC    lin200	GOYES lin200
	GONC   lin190	B.E.T. fini
 lin160
	C=R1		C(A) := Y
	A=DAT1 A	A(A) := y2
	GOSUBL =TSTC>A	?Y>y2
	GOC    lin200	GOYES lin200
*
* attention : le code continue !
*

 lin190
	D1=(5) x2
	A=DAT1 A	A(A) := x2
	R0=A
	D1=D1+ 5
	A=DAT1 A	A(A) := y2
	R1=A
	ST=1   fini
 lin200
*
* Tout est ok, on peut tracer ou sauter :
*
	GOSUBL =GETCUR	A(A) := x ; C(A) :=; y
	B=C    A	B(A) := y
	C=R0		C(A) := X
	C=C-A  A	C(A) := X - x
	R0=C		R0 := Dx
	C=R1		C(A) := Y
	C=C-B  A	C(A) := Y - y
	R1=C		R1 := Dy

*
* saut ?
*
	A=R0		A(A) := Dx
	C=R1		C(A) := Dy

	?ST=0  saut
	GOYES  lin250

	GOSUBL =RSAUTE
	ST=0   saut
	GOTO   lin300

 lin250
	GOSUBL =RTRACE
	ST=1   saut

 lin300
*
* element suivant dans la table des LT
*
	D1=(5) LTADR
	C=DAT1 A
	C=C+1  A
	DAT1=C A
	D1=C
	C=DAT1 S
	?C#0   S
	GOYES  lin310
	GOSUB  GTLTAD
 lin310
*
* jusqu'a fini
*
	?ST=1  fini
	RTNYES
	GOTO   lin100

************************************************************
* RCLXY
*
* But: rappeler une valeur sur 8 chiffres, et la transformer
*   en valeur signee sur 16 chiffres.
* Entree:
*   - D0 = ^ valeur signee sur 8 chiffres
*   - P = 0
* Sortie:
*   - C(W) = valeur signee sur 16 chiffres
*   - D0 = valeur en entree + 8
*   - P = 0
* Abime: A, C, P
* Niveaux: 0
* Historique:
*   87/02/21: conception & codage
************************************************************

 RCLXY
	C=0    W
	C=DAT0 8
	D0=D0+ 8
	P=     7
	A=C    WP
	A=A+A  WP
	P=     0
	RTNNC		Ok, positif
	P=     7
	C=-C   WP
	P=     0
	C=-C   W	signee sur 16 chiffres
	RTN

************************************************************
* STOXY
*
* But: stocker une valeur entiere (hexa) en valeur flottante
*   hexa (4 chiffres hexa apres la virgule) sur 8 chiffres.
* Entree:
*   - A(A) = valeur entiere (signee)
*   - D0 = endroit ou doit etre stockee la valeur
* Sortie:
*   - A(W) = valeur stockee
* Abime: A, B
* Niveaux: 0
* Historique:
*   87/02/21: conception & codage
************************************************************

 STOXY
	B=A    A	B(A) := vvvvv
	A=0    W
	A=B    A	A(W) := 00000000000vvvvv
	ASL    W
	ASL    W
	ASL    W
	ASL    W	A(W) := 0000000vvvvv0000
	B=B+B  A
	GONC   STOXY1
	A=-A   W	A(W) := - A(W) si v < 0
 STOXY1 DAT0=A 8
	RTN

************************************************************
* D15HEX
*
* But: convertir un nombre 15 digits en nombre hexa sur 16
*   quartets.
* Entree:
*   - X (registres A et B) = 15 digits
*   - D0 = ^ signe (stocke par valabs)
* Sortie:
*   - C(W) = nombre signe sur 16 quartets
*   - mode = HEX
*   - P = 0
* Abime: A-D, R3, XM, ST(7-11)
* Niveaux: 3 (uRES12)
* Appelle: uRES12, RJUST, DCHXW
* Note:
*   L'argument est traduit en pleine precision, ce qui
*   permet d'avoir des nombres superieurs a 16*65536. FLTDH
*   ne permettait pas ca.
* Historique:
*   87/02/20: conception & codage
*   87/02/21: ajout de documentation
************************************************************

 D15HEX
	XM=0
	GOSBVL =uRES12	C(W) := resultat 12 digits
	A=C    W	A(W) := resultat 12 digits
	GOSBVL =RJUST	A(W) := resultat entier dec
	C=A    W	C(W) := resultat entier dec
	GOSBVL =DCHXW	A,B,C(W) := resultat entier hex
* P=0, mode = HEX
	A=DAT0 S
	A=A-1  S	Cy := si + alors 1 sinon 0
	RTNC		nb positif
	C=-C   W	C(W) := nb signe
	RTN

************************************************************
* valabs
*
* But: stocker le signe de C(A), et renvoyer |C(A)|
* Entree:
*   - P=0
*   - C(A) = valeur a tester (en complement a deux
*   - D0 = ^ endroit ou sauver le signe de C(A)
*   - A(S) = 0 (signe +)
*   - A(0) = 9 (signe -)
* Sortie:
*   - C(A) = |C(A)| en entree
*   - D0 = D0 en entree + 1
* Abime: B(A), C(A), D0
* Niveaux: 0
* Historique:
*   87/02/18: conception & codage
*   87/02/21: ajout de documentation
************************************************************

 valabs
	B=C    A
	B=B+B  A
	GOC    vala10	GO if dx (ou dy) <0
	DAT0=A S
	D0=D0+ 1
	RTN
 vala10 DAT0=A P
	C=-C   A	R0 := |dx|
	D0=D0+ 1
	RTN

************************************************************
* GTLTAD (GeT LineType ADdress)
*
* But: stocker dans LTADR l'adresse du premier element de la
*   table des LineType pour la valeur de LT donnee.
* Entree:
*   - (oLT) = type de trace (1 a 6) dans le buffer bRAST
* Sortie:
*   - LTADR = adresse du LineType dans la table
*   - ST(saut) = faux
* Abime: A(A), C(A), D1
* Niveaux: 0
* Historique:
*   87/02/13: conception & codage
************************************************************

 GTLTAD
	LC(2)  =oLT
	GOSUBL =RBUFC
	A=0    A
	A=DAT1 P	A(P) = 1 a 6
	GOSUB  gt10
	REL(2) lt1
	REL(2) lt2
	REL(2) lt3
	REL(2) lt4
	REL(2) lt5
	REL(2) lt6

 lt1	CON(1) 1	trace  1
	CON(1) 15	saute 15 
	CON(1) 0
 lt2	CON(1) 8	trace  8  
	CON(1) 8	saute  8  
	CON(1) 0
 lt3	CON(1) 12	trace 12
	CON(1) 4	saute  4
	CON(1) 0
 lt4	CON(1) 11	trace 11
	CON(1) 2	saute  2
	CON(1) 1	trace  1
	CON(1) 2	saute  2
	CON(1) 0
 lt5	CON(1) 10	trace 10
	CON(1) 2	saute  2
	CON(1) 2	trace  2
	CON(1) 2	saute  2
	CON(1) 0
 lt6	CON(1) 6	trace  6
	CON(1) 2	saute  2
	CON(1) 2	trace  2
	CON(1) 2	saute  2
	CON(1) 2	trace  2
	CON(1) 2	saute  2
	CON(1) 0

 gt10
	C=RSTK		C(A) := ^ REL(2) lt1
	A=A-1  A	A(A) := i-1	 (0 a 5)
	A=A+A  A	A(A) := 2*(i-1)
	A=A+C  A	A(A) := ^ REL(2) lti
	D1=A		D1 := ^ REL(2) lti
	C=0    A
	C=DAT1 B	C(A) := REL(2) lti
	A=A+C  A	A(A) := ^ lti

	D1=(5) LTADR
	DAT1=A A	LTADR := ^ T(0)
	ST=0   saut
	RTN

	STITLE Utilitaires de PA

 signe	EQU    1
************************************************************
* coupe
*
* But: chercher l'intersection entre une ligne horizontale
*   ou verticale, et la ligne definie par les points Q1 et
*   Q2.
* Entree: les registres contiennent la coordonnee a (resp.
*   b) dans Ri(4:0) (resp. Ri(9:5)).
*   - C(A) = W1a ou W2a (l'equation de la droite est a=Wia)
*   - R0 = W1
*   - R1 = Q1
*   - R2 = Q2
*   - R3 = W2
* Sortie:
*   - coordonnee "b" en C(A)
*   - Tous les Ri sont inchanges
* Abime: A-D
* Appelle: csrc5, AMPY, MPYSGN, IDIV
* Niveaux: 2
* Detail: s'il s'agit d'une ligne verticale, la coordonnee
*   "a" est "x", "b" est "y". La droite vertcale a comme
*   equation : x=Wix.
*   Le point cherche est defini uniquement par sa
*   coordonnee "b".
* Historique:
*   86/10/15: reprogrammation
************************************************************

 coupe	ST=0   signe
	A=R2		A(A) := a2
	C=A-C  A	C(A) := a2-Wia
	GOSUB  MPYSGN
	A=C    A	A(A) := ABS(a2-Wia)
	C=R1
	GOSUBL =csrc5	C(A) := b1
	B=C    A
	C=R2
	GOSUBL =csrc5	C(A) := b2
	C=C-B  A	C(A) := b2-b1
	GOSUB  MPYSGN	C(A) := ABS(b2-b1)
	  *		ST(signe) := SIGN(b2-b1)
	GOSUBL =AMPY
	?ST=1  signe
	GOYES  cp10
	C=-C   W
 cp10	D=C    W	D(W) := -(a2-Wia)(b2-b1)
	ST=0   signe	pour MPYSGN (signe du multiplicande)
	C=R2		C(A) := a1
	A=R1		A(A) := a2
	C=C-A  A	C(A) := a2-a1
	GOSUB  MPYSGN	C(A) := ABS(a2-a1)
	  *		ST(signe) := SIGN(a2-a1)
	ACEX   A	C(W) := ...b2a2	  A(A) := ABS(a2-a1)
	GOSUBL =csrc5	C(A) := b2
	GOSUB  MPYSGN	C(A) := ABS(b2)
	  *		ST(signe) := SIGN(b2(a2-a1))
	GOSUBL =AMPY	C(W) = A(W) = B(W) := ABS(b2(a2-a1))
	?ST=0  signe
	GOYES  cp20
	C=-C   W
 cp20	C=C+D  W	C(W) := dividende
	A=C    W
	C=C+C  W
	ST=0   signe
	GONC   cp30
	A=-A   W
	ST=1   signe
 cp30	C=R1		C(A) := a1
	B=C    A	B(A) := a1
	C=R2		C(A) := a2
	C=C-B  A	C(A3 := a2-a1
	GOSUB  MPYSGN	C(A) := ABS(diviseur)
	  *		ST(signe) := SIGN(quotient)
	?C=0   A
	GOYES  cp50	C(A) := Inf
	B=C    A
	C=0    W
	C=B    A	C(W) = C(A) = ABS(divisor)
	GOSBVL =IDIV	A := A/C ; C = B := A mod C ; P := F
	P=     0	car P=15 en sortie de IDIV
	C=0    W
	LC(4)  32767	+Inf
	?A>C   W
	GOYES  cp50	C(A) := Inf
	C=A    A	Champ A, car <32767
 cp40	?ST=0  signe
	RTNYES		Ok
	C=-C   A
	RTN		Ok, mais negatif
 cp50	LC(5)  32767	Inf
	GOTO   cp40	plus ou moins...

************************************************************
* MPYSGN
*
* But: trouver le signe d'une multiplication non signee.
* Entree:
*   - ST(signe) = signe du multiplicande (0 : >=0)
*   - C(A) = multiplcateur
* Sortie:
*   - ST(signe) = signe du resultat
*   - C(A) = ABS (multiplicateur)
* Abime: C(5:0), B(A), ST(signe)
* Niveaux: 0
* Historique:
*   86/10/16: reprogrammation
************************************************************

 MPYSGN B=C    A	B(A) : registre de travail
	B=B+B  A	Cy := signe du multiplicateur
	RTNNC		Retour si >=0 (signe identique)
	C=-C   A	C(A) := ABS(C)
	?ST=1  signe	multiplicande etait negatif ?
	GOYES  MPSG10
	ST=1   signe
	RTN
 MPSG10 ST=0   signe
	RTN

************************************************************
* minmax
*
* But: permute eventuellement duex points, de telle sorte
*   que le premier (R1) soit celui qui a la plus faible
*   coordonnee.
* Entree: (le champ contient la coordonnee a tester)
*   - R0 = W1
*   - R1 = P (nouvelle position)
*   - R2 = P' (vieille position)
*   - R3 = W2
* Sortie:
*   - A = R1 = Q1
*   - C = R2 = Q2
*   - R0 et R3 non modifies
*   - ST(permut) = 1 si les deux points ont ete permutes
* Abime: A(W), C(W)
* Appelle: TSTA>C
* Niveaux: 1
* Historique:
*   86/10/15: reprogrammation
*   87/02/21: ajout de ST(permut)
************************************************************

 minmax A=R1		P
	C=R2		P'
	ST=1   permut	par defaut, permutation (R1=P)
	GOSUBL =TSTA>C	?P>P'
	A=R1		} la carry n'est pas changee
	C=R2		}
	RTNNC		RTNYES
	ACEX   W
	R1=A		min
	R2=C		max
	ST=0   permut	pas de permutation
	RTN

************************************************************
* HRZVRT
*
* But: dans le cas de lignes horizontales ou verticales,
*   limite les coordonnees de trace.
* Entree:
*   - R0(A) = W1
*   - R1(A) = P (nouvelle position)
*   - R2(A) = P' (vieille position)
*   - R3(A) = W2
* Sortie:
*   - R1(A) = plus petite limite (Q1)
*   - R2(A) = plus grande limite (Q2)
*   - ST(permut) = 1 si les deux points ont ete permutes
*   - Cy = 1 si trace possible
*     Cy = 0 si trace impossible
* Abime: A-C, R1, R2, ST(permut)
* Appelle: minmax, TSTA>C
* Niveaux: 2 (minmax)
* Algorithme: 
*   - permute (si necessaire) les deux points de telle
*     maniere que p soit le plus grand, et q le plus petit
*   - si p > W2 alors p := max (p, W1)
*   - si q < W1 alors q := min (q, W2)
* Detail:
*   si a1>W2a alors RTNCC (trace impossible)
*   si a1<=W1a alors 1 := W1
*   si a2<W1a alors RTNCC (trace impossible)
*   si a2>=W2a alors 2 := W2
*   RTNSC   (trace possible)
* Historique:
*   86/10/09: reprogrammation
*   87/02/21: ajout de documentation
*   87/05/08: documentation de Cy en sortie, + "detail"
************************************************************

 HRZVRT GOSUB  minmax
*
* R1 = A = le plus petit a = Q1
* R2 = C = le plus grand a = Q2
*
	D=C    W
	B=A    W
	C=R3		C := W2
* ?a1>W2a -> GOYES 50
	GOSUBL =TSTA>C
	GOC    HV50
	A=R1
	C=R0
* ?a1>W1a -> GOYES 20
	GOSUBL =TSTA>C
	GOC    HV20
	A=R1
	C=R0
	A=C    A
	R1=A
 HV20	C=D    W
	A=R0
* ?a2<W1a -> GOYES 50
	GOSUBL =TSTA>C
	GOC    HV50
	A=R3
	C=D    A
* ?a2<W2a -> RTNYES
	GOSUBL =TSTA>C
	RTNC
	A=R3
	C=D    W
	C=A    A
	R2=C
 HV40	RTNSC		Cy = 1
 HV50	RTNCC		Cy = 0

************************************************************
* TSTIN
*
* But: tester si la coordonnee (soit x, soit y) est dans la
*   zone de trace. Cette routine est utilisee par les
*   programmes de trace de droites horizontale et verticale.
* Entree:
*   - R0(A) = W1a
*   - R1(A) = a1
*   - R2(A) = a2
*   - R3(A) = W2a
* Sortie:
*   - Cy = 0 : a est dans [W1a..W2a]
*   - Cy = 1 : a est dans [-Inf..W1a[ U ]W2a..Inf[
* Abime: A, C
* Appelle: TSTA>C, TSTA<C
* Niveaux: 1
* Detail: Cy := ((a1<=W2a) AND (a2>=W1a))
* Historique:
*   86/10/15: reprogrammation
************************************************************

 TSTIN	A=R1		A(A) := a1
	C=R3		C(A) := W2a
	GOSUBL =TSTA>C	?a1>W2a
	RTNC		RTNYES
	A=R2		A(A) := a2
	C=R0		C(A) := W1a
	GOLONG =TSTA<C	Cy := (a2<W1a)

************************************************************
* RiSLC5, RiSRC5
*
* But: operer une rotation de 5 quartets dans les registres
*   R0 a R3.
* Entree:
*   - Ri
* Sortie:
*   - Ri
* Abime: C(W)
* Appelle: cslc5, csrc5
* Niveaux: 1
* Historique:
*   86/10/15: reprogrammation
************************************************************

 RiSLC5 C=R0
	GOSUBL =cslc5
	R0=C
	C=R1
	GOSUBL =cslc5
	R1=C
	C=R2
	GOSUBL =cslc5
	R2=C
	C=R3
	GOSUBL =cslc5
	R3=C
	RTN
 RiSRC5 C=R0
	GOSUBL =csrc5
	R0=C
	C=R1
	GOSUBL =csrc5
	R1=C
	C=R2
	GOSUBL =csrc5
	R2=C
	C=R3
	GOSUBL =csrc5
	R3=C
	RTN

************************************************************
* swpreg
*
* But: les registres Ri contiennent des couples de
*   coordonnees. Cette routine les permute.
* Entree:
*   - Ri
* Sortie:
*   - Ri
* Abime: A(W), C(W)
* Appelle: csrc5, cslc5
* Niveaux: 2
* Historique:
*   86/10/15: reprogrammation
************************************************************

 swpreg C=R0
	GOSUB  swp10
	R0=C
	C=R1
	GOSUB  swp10
	R1=C
	C=R2
	GOSUB  swp10
	R2=C
	C=R3
	GOSUB  swp10
	R3=C
	RTN
 swp10	A=C    A
	GOSUBL =csrc5
	ACEX   W
	GOSUBL =cslc5
	C=0    A
	C=C+A  A
	RTN

	END
