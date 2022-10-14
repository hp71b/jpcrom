	TITLE	Graphique, Tracé de droites <grtrace.as>

************************************************************
*
* Le but de ce fichier est d'implementer une routine de
* trace generalise. C'est a dire d'avoir une seule fonction
* quelle que soit la droite a tracer, et ses parametres.
*
************************************************************

	STITLE Routine de saut
************************************************************
* SKIP
*
* But: Passer un segment de droite sans le tracer.
* Entree:
*   - C(A) = r
*   - A(A) = t ((avec 4 decimales hexadecimales)
* Sortie: -
* Note :
*   r >= 0
*   0 <= t <= 2pi
* Abime: 
* Appelle: SINCOS, FLMULT
* Niveaux: 3
* Detail: 
* Algorithme: 
* Historique:
*   86/11/19: conception & codage
************************************************************

=SKIP	B=C    A	B(A) := r
	C=0    W
	C=B    A	C(W) := r
	R3=C		R3 := r
	GOSUB  =SINCOS
	R0=A		R0 := |sin t|
	A=R3
	GOSUB  =FLMULT	C(W) := A(W) := r |cos t|
*
* x := x +/- r |cos t|
*
	D0=(5) =PLUMEX
	C=DAT0 A
	?ST=0  =cosx>0
	GOYES  SKIP10
	C=C+A  A
	GOTO   SKIP20
 SKIP10 C=C-A  A
 SKIP20 DAT0=C A

	C=R3		C(W) := r
	A=R0		A(W) := |sin t|
	GOSUB  =FLMULT	C(W) := A(W) := r |sin t|
*
* y := y +/- r |sin t|
*
	D0=D0+ 5
	C=DAT0 A
	?ST=0  =sinx>0
	GOYES  SKIP30
	C=C+A  A
	GOTO   SKIP40
 SKIP30 C=C-A  A
 SKIP40 DAT0=C A
	
	RTN

************************************************************
* RSAUTE
*
* But: Passer un segment de droite sans le tracer.
* Entree:
*   - A(A) = dx (avec 4 decimales hexadecimales)
*   - C(A) = dy (avec 4 decimales hexadecimales)
* Sortie: -
* Note :
* Abime: 
* Appelle: GETCUR, SETCUR
* Niveaux: 1
* Historique:
*   87/01/31: conception & codage
************************************************************

=RSAUTE
	B=A    A
	D=C    A
	GOSUB  =GETCUR
	A=A+B  A
	C=C+D  A
	GOTO   =SETCUR

************************************************************
* ABS
*
* But: C(A) := ABS(C(A))
* Entree: C(A)
* Sortie: C(A)
* Utilise: C(A), D(A)
************************************************************
 ABS
	D=C    A
	D=D+D  A
	RTNNC
	C=-C   A
	RTN

	STITLE Calculs trigonométriques

 permut EQU    1
=sinx>0 EQU    2
=cosx>0 EQU    3

 vertcl EQU    4
 dy<0	EQU    5

************************************************************
* SINCOS
*
* But: extraire le sinus et le cosinus d'un angle x exprime
*   en radians, avec 4 decimales hexa de precision. L'angle
*   doit etre compris entre 0 et 2PI.
* Entree:
*   - A(A) = x (sur cinq chiffres, avec 4 decimales hexa)
* Sortie:
*   - A(A) = sin x (A(15-5)=0)
*   - C(A) = cos x (C(15-5)=0)
* Abime: A-D, R0-R2, S1-S3
* Appelle: FLMULT, FLIDIV
* Niveaux: 2
* Detail: 
*   Le cercle trigonometrique est divise en 8 regions :
*	region I    : x e [0, pi/4]
*	region II   : x e [pi/4, pi/2]
*	   :		    :
*	region VIII : x e [3pi/2, 2pi]
*   Selon la region :
*     x e I    : sin x = sin y	   avec y = x
*		 cos x = cos y
*     x e II   : sin x = cos y	   avec y = pi/2 - x
*		 cos x = sin y
*     x e III  : sin x = cos y	   avec y = x - pi/2
*		 cos x = -sin y
*     x e IV   : sin x = sin y	   avec y = pi - x
*		 cos x = -cos y
*     x e V    : sin x = -sin y	   avec y = x - pi
*		 cos x = -cos y
*     x e VI   : sin x = -cos y	   avec y = 3pi/2 - x
*		 cos x = -sin y
*     x e VII  : sin x = -cos y	   avec y = x - 3pi/2
*		 cos x = sin y
*     x e VIII : sin x = -sin y	   avec y = 2pi - x
*		 cos x = cos y
* Algorithme: 
*  permut := 0 ; sinx>0 = 1 ; cosx>0 = 1 ;
*  selon la region :
*   I	: y:=x ;
*   II	: y:=pi/2-x ; permut:=1;
*   III : y:=x-pi/2 ; permut:=1;	    cosx>0:=0;
*   IV	: y:=pi-x   ;			    cosx>0:=0;
*   V	: y:=x-pi   ;		 sinx>0:=0; cosx>0:=0;
*   VI	: y:=3pi/2-x; permut:=1; sinx>0:=0; cosx>0:=0;
*   VII : y:=x-3pi/2; permut:=1; sinx>0:=0;
*   VIII: y:=2pi-x  ;		 sinx>0:=0;
*  u = y - y^3/6+x^5/120 ;	      { sin y }
*  v = 1 - y^2/2-x^4/24-x^6/720 ;     { cos y }
*  si permut alors |sin x| := v ;
*		   |cos x| := u ;
*	     sinon |sin x| := u ;
*		   |cos x| := v ;
*  *Les valeurs calculees sont des valeurs sans signe. Si
*  *on veut retablir le signe, les flags sinx>0 et cosx>0
*  *indiquent avec precision le signe. L'appelant devra
*  *faire :
*  *	 si non sinx>0 alors sin x := - sin x ;
*  *	 si non cosx>0 alors cos x := - cos x ;
* Historique:
*   86/08/22: conception & codage
************************************************************

=SINCOS ST=0   permut
	ST=1   =sinx>0
	ST=1   =cosx>0
*
* selon la region de x (c'est a dire A(A))
*
	GOSUB  =LCPI/4	C(A) := pi/4
	B=C    A	B(A) := pi/4 (constante)
	?A>=C  A
	GOYES  SC010
* reg. I
	C=A    A	--> y := x ;
	GOTO   SC100
 SC010	C=C+B  A	C(A) := pi/2
	?A>=C  A
	GOYES  SC020
* reg. II
	C=C-A  A	--> y := pi/2-x ;
	ST=1   permut	--> permut := 1 ;
	GOTO   SC100
 SC020	C=C+B  A	C(A) := 3pi/4
	?A>=C  A
	GOYES  SC030
* reg. III
	C=C-B  A	C(A) := pi/2
	C=A-C  A	--> y := x-pi/2 ;
	ST=1   permut	--> permut := 1 ;
	ST=0   =cosx>0	--> cosx>0 := 0 ;
	GOTO   SC100
 SC030	C=C+B  A	C(A) := pi
	?A>=C  A
	GOYES  SC040
* reg. IV
	C=C-A  A	--> y := pi-x ;
	ST=0   =cosx>0	--> cosx>0 := 0 ;
	GOTO   SC100
 SC040	C=C+B  A	C(A) := 5pi/4
	?A>=C  A
	GOYES  SC050
* reg. V
	C=C-B  A	C(A) := pi
	C=A-C  A	--> y := x-pi ;
	ST=0   =sinx>0	--> sinx>0 := 0 ;
	ST=0   =cosx>0	--> cosx>0 := 0 ;
	GOTO   SC100
 SC050	C=C+B  A	C(A) := 3pi/2
	?A>=C  A
	GOYES  SC060
* reg. VI
	C=C-A  A	--> y := 3pi/2-x ;
	ST=1   permut	--> permut := 1 ;
	ST=0   =sinx>0	--> sinx>0 := 0 ;
	ST=0   =cosx>0	--> cosx>0 := 0 ;
	GOTO   SC100
 SC060	C=C+B  A	C(A) := 7pi/4
	?A>=C  A
	GOYES  SC070
* reg. VII
	C=C-B  A	C(A) := 3pi/2
	C=A-C  A	--> y := x-3pi/2 ;
	ST=1   permut	--> permut := 1 ;
	ST=0   =sinx>0	--> sinx>0 := 0 ;
	GOTO   SC100
 SC070	C=C+B  A	C(A) := 2pi
* reg. VIII
	C=C-A  A	--> y := 2pi-x ;
	ST=0   =sinx>0	--> sinx>0 := 0 ;

*
* y est dans C(A)
* les flags "permut", "sin/cosx>0" sont positionnes
*
 SC100	
*
* Les lignes qui suivent calculent sin y et cos y
*
* sin y := x(120-x^2(20-x^2))/120
*   (developpement limite a l'ordre 2)
*
	B=C    A	B(A) := yyyyy
	C=0    W	C(W) := 0
	C=B    A	C(W) := 00000000000yyyyy
	R0=C		R0(W) := y
* R0(W) := y
	A=C    W
	GOSUB  =FLMULT	A=C := y^2
	R1=C
* R1(W) := y^2
	LCHEX  140000	C(W) := 20
	C=C-A  W	C(W) := 20 - y^2
	ACEX   W	C(W) = le plus petit (y^2)
	GOSUB  =FLMULT
	LCHEX  780000	C(W) := 120
	C=C-A  W	C(W) := 120 - y^2(20-y^2)
	A=R0		A(W) := y
	ACEX   W	C(W) = le plus petit (y)
	GOSUB  =FLMULT
	C=0    W
	LC(2)  120
	GOSUB  =FLIDIV
	R2=A
*
* R2(W) := sin y
*
* Calcul du cosinus
*   cos y := (720-x^2(360-x^2(30-x^2)))/720
*   (developpement limite a l'ordre 3)
*
	A=R1		A(W) := y^2
	LCHEX  1E0000	C(W) := 30.0000
	C=C-A  W	C(W) := 30-y^2
	ACEX   W	C(W) := le plus petit (y^2)
	GOSUB  =FLMULT	A(W) = C(W) := y^2(30-y^2)
	LCHEX  1680000	C(W) := 360.0000
	C=C-A  W	C(W) := 360-y^2(30-y^2)
	A=R1		A(W) := y^2
	ACEX   W	C(W) := le plus petit (y^2)
	GOSUB  =FLMULT
	LCHEX  2D00000	C(W) := 720.0000
	C=C-A  W	C(W) := 720-y^2(360-y^2(30-y^2))
	A=C    W
	C=0    W
	LC(3)  720
	GOSUB  =FLIDIV
	C=R2
*
* C(W) := sin y
* A(W) := cos y
*
	?ST=1  permut
	RTNYES
	ACEX   W
	RTN
*****************
* A(W) := sin x *
* C(W) := cos x *
*****************


************************************************************
* FLMULT
*
* But: faire la multiplication de deux nombres en format
*   "pseudo-flottant", c'est a dire au format :
*     - partie entiere sur les quartets 15 a 4
*     - partie fractionnaire sur les quartets 3 a 0
*   Cette fonction convient pour les multiplications de :
*     - flottant par flottant avec resultat flottant
*     - flottant par entier avec resultat entier
* Entree:
*   - A(W) = multiplicande
*   - C(W) = multiplicateur
* Sortie:
*   - A(W) = C(W) = resultat de la multiplication
* Abime: A-C
* Appelle: MPY
* Niveaux: 1
* Detail:
*   La multiplication est faite en double precision, puis
*   le resultat est divise par #10000 afin de retourner un
*   nombre dans le bon format. Enfin, un arrondi est fait
*   si la partie fractionnaire du nombre est superieure a
*   .5 en decimal
* Note: Plus C(W) est petit, plus MPY est rapide.
* Historique:
*   86/08/26: conception & codage
************************************************************

=FLMULT GOSBVL =MPY
	CSR    W
	CSR    W
	CSR    W
	C=C+C  P	Cy := Chiffre de poids fort >=8
	CSR    W
	GONC   FLMT10
	C=C+1  W	arrondi a la decimale superieure
 FLMT10 A=C    W
	RTN
	
************************************************************
* FLIDIV
*
* But: fait la division des deux operandes, et arrondit le
*   resultat a l'entier le plus proche.
* Entree:
*   - A(W) = dividande
*   - C(W) = diviseur
* Sortie:
*   - A(W) = A/C
*   - P=0
* Abime: A-D
* Appelle: IDIV
* Niveaux: 1
* Historique:
*   86/08/26: conception & codage
************************************************************

=FLIDIV D=C    W	D(W) := diviseur
	GOSBVL =IDIV	A(W) := A div C ; C(W) := A mod C
	P=     0
	DSRB		D(W) := diviseur / 2
	?C<D   W
	RTNYES		arrondi = 0 si ((A mod C)<(C div 2))
	A=A+1  W
	RTN


=LCPI/4 C=0    W
	LC(4)  51472  PI/4 = IP(0.785398163398*65536)
	RTN

	STITLE Environnement du traçage
************************************************************
* SETCUR
*
* But: placer le point courant dans l'espace de trace. Ce
*   point courant sera utilise par la routine TRACER.
* Entree:
*   - A(A) = X
*   - C(A) = Y
* Sortie:
*   - D0 := PLUMEY
* Abime: D0
* Niveaux: -
* Detail:
*   Le point courant est place aux endroits PLUMEX et
*   PLUMEY (FUNCD0 et FUNCD1). La routine de trace
*   generalisee s'en servira, et reactualisera cette
*   position courante.
* Historique:
*   86/08/26: conception & codage
************************************************************

=SETCUR D0=(5) =PLUMEX
	DAT0=A A	(PLUMEX) := X
	D0=D0+ 5	D0=(5) PLUMEY
	DAT0=C A	(PLUMEY) := Y
	RTN 

************************************************************
* GETCUR
*
* But: obtenir les coordonnees du point courant dans
*   l'espace de trace.
* Entree: -
* Sortie:
*   - A(A) = x
*   - C(A) = y
*   - D0 = PLUMEY
* Abime: D0
* Niveaux: -
* Historique:
*   86/08/28: conception & codage
************************************************************

=GETCUR D0=(5) =PLUMEX
	A=DAT0 A	x := (PLUMEX)
	D0=D0+ 5	D0=(5) PLUMEY
	C=DAT0 A	y := (PLUMEY)
	RTN
	
************************************************************
* asrw4
*
* But: decaler A(W) de quatre quartets
* Entree:
*   - A(W)
* Sortie:
*   - A(W)
* Abime: A(W)
* Niveaux: 0
* Historique:
*   86/08/26: conception & codage & documentation
************************************************************

=asrw4	ASR    W	decalage de 1 quartet
	ASR    W	decalage de 2 quartets
	ASR    W	decalage de 3 quartets
	ASR    W	decalage de 4 quartets
	RTN		et retour. Avez-vous tout compris ?

	STITLE Routine de tracé
************************************************************
* PTRACE, RTRACE
*
* But: PTRACE
*   tracer un segment de droite a partir de la position
*   courante de la plume (PLUMEX, PLUMEY), de longueur r et
*   d'inclinaison t (coordonnees polaires).
* But: RTRACE
*   tracer un segment de droite a partir de la position
*   courante de la plume (PLUMEX, PLUMEY), suivant un 
*   vecteur (dx, dy)
* Entree:
*   PTRACE
*     - C(A) = r
*     - A(A) = t (avec 4 decimales hexadecimales)
*   RTRACE
*     - A(A) = dx
*     - C(A) = dy
* Sortie: -
* Note:
*   r >= 0
*   0 <= t <= 2pi
*   aucun point ne doit etre en dehors des limites de trace
* Abime: 
* Appelle: SINCOS, FLMULT
* Niveaux: 3
* Detail: 
* Algorithme: 
* Historique:
*   86/08/26: installation de l'interface
*   87/01/25: modification pour supporter RTRACE
************************************************************

=PTRACE B=C    A	}
	C=0    W	} C(15-5) := 0
	C=B    A	}
	R3=C		R3 := r
	GOSUB  =SINCOS	A(W) := |sin t| ; C(W) := |cos t|
	D=C    W	D(W) := |cos t|
	C=R3		C(W) := r ; A(W) = |sin t|
	GOSUB  =FLMULT	A(W) = C(W) := r |sin t| = |dy|
*
* A(W) = R2(W) = |dy|
* D(W) = |cos t|
* R3(W) = r
* les flags sinx>0 et cosx>0 indiquent le signe
* 
	?ST=1  =sinx>0
	GOYES  PT10
	A=-A   A	dy := - |dy|
 PT10
	R2=A		R2(W) := dy

	C=D    W	C(W) := |cos t|
	A=R3		A(W) := r
	GOSUB  =FLMULT	A(W) = C(W) := r |cos t| = |dx|
*
* R2(A) = dy (signe)
* R3(W) = r
* les flags sinx>0 et cosx>0 indiquent le signe
*
	?ST=1  =cosx>0
	GOYES  PT20
	A=-A   A	dx := - |dx|
 PT20
	C=R2
=RTRACE
	R1=A		R1 = A(A) = dx
	R2=C		R2 = C(A) = dy

	?C#0   A
	GOYES  TRC005
 horizontale
*
* dy = 0
*
	GOSUB  =GETCUR	A(A) := x1 ; C(A) := y1
	R2=C		R2(A) := y1
	B=A    A	B(A) := x1
	C=R1		C(A) := dx
	C=C+C  A
	C=R1		C(A) := dx
	GONC   hor10	dx >= 0
	A=A+C  A	A(A) := x1 + dx
	C=-C   A	C(A) := - dx
 hor10	R3=C		R3 := |dx| (longueur du segment)
	AR1EX		R1(A) := x de depart
	 *		A(A) := dx
	A=A+B  A	A(A) := x1 + dx
	D0=D0- 5
	DAT0=A A	PLUMEX := x1 + dx
*
* R1 = x1 ou x1 + dx
* R2 = y1
* R3 = |dx|
* PLUMEX = x1 + dx
*
	GOTO   seghrz
*
*
 TRC005
	?A#0   A
	GOYES  oblique
 verticale
*
* dx = 0
*
	GOSUB  =GETCUR	A(A) := x1 ; C(A) := y1
*
* D0 := PLUMEY
* A(A) = x1
* C(A) = y1
* R1(A) = dx (= 0)
* R2(A) = dy
*
	R1=A		R1 := x1
	B=C    A	B(A) := y1
	C=R2		C(A) := dy
	C=C+C  A
	C=R2		C(A) := dy
	A=B    A	A(A) := y1
	GONC   ver10	dy >= 0
	A=A+C  A	A(A) := y1 + dy
	C=-C   A	C(A) := - dy
 ver10	R3=C		R3 := |dy| = longueur du segment
	AR2EX		R2(A) := y de depart
	 *		A(A) := dy
	A=A+B  A	A(A) := y1 + dy
	DAT0=A A	PLUMEY := y1 + dy
*
* PLUMEY = y1 + dy
* R1 = x1
* R2 = y1 ou y1 + dy
* R3 = |dy|
*
	GOTO   segvrt

************************************************************
* oblique
*
* But: tracer une ligne oblique a partir de (PLUMEX, PLUMEY)
*   jusqu'a (PLUMEX + dx, PLUMEY + dy).
* Entree:
*   - PLUMEX, PLUMEY : position courante de la plume
*   - R1(A) = dx (en complement a 2)
*   - R2(A) = dy (en complement a 2)
* Sortie:
*   - PLUMEX, PLUMEY actualises pour tenir compte de la lgn
* Abime: 
* Appelle: 
* Niveaux: 
* Detail: 
* Algorithme: 
* Historique:
*   86/08/26: reprogrammation de l'interface
************************************************************

 oblique
	GOSUB  =GETCUR
	R0=A		R0 := x1
	R3=C		R3 := y1
*
* Calculons une fois pour toutes les coordonnees du point de
* destination de la plume, lesquelles ne seront plus jamais
* utilisees dans cet appel.
*
	B=A    A	B(A) := x1
	A=R2		A(A) := dy
	C=A+C  A	C(A) := y1 + dy
	DAT0=C A	PLUMEY := y1 + dy
	D0=D0- 5
	A=R1		A(A) := dx
	A=A+B  A	A(A) := x1 + dx
	DAT0=A A	PLUMEX := x1 + dx
*
* R0 = x
* R1 = dx
* R2 = dy
* R3 = y
*
	C=R0
	CR1EX
	R0=C
	C=R3
	CR2EX
	R3=C
*
* Etat des registres :
* R0 = dx
* R1 = x
* R2 = y
* R3 = dy
*

*
* si dx <0
*   alors
*     x := x + dx
*     y := y + dy
*     dx := - dx
*     dy := - dy
* fin si
* ST(vertcl) := 0
* si |dx|<|dy|
*   alors ST(vertcl) := 1
* fin si
* ST(dy<0) := 0
* si dy < 0
*   alors ST(dy<0) := 1
* fin si
* si ST(vertcl) = 0
*   alors
*     PUSH dans R0 : dx
*     PUSH dans R0 : |dy|
*   sinon
*     PUSH dans R0 : |dy|
*     PUSH dans R0 : dx
* fin si
*
	C=R0		C(A) := dx
	C=C+C  A
	GONC   obl10

	C=R1		C(A) := x
	A=R0		A(A) := dx
	C=C+A  A	C(A) := x + dx
	R1=C		x := x + dx
	A=-A   A	A(A) := -dx
	R0=A		dx := -dx

	C=R2		C(A) := y
	A=R3		A(A) := dy
	C=C+A  A	C(A) := y + dy
	R2=C		y := y + dy
	A=-A   A	A(A) := -dy
	R3=A		dy := -dy

 obl10
	ST=0   vertcl
	C=R0		C(A) := dx
	GOSUB  ABS
	B=C    A	B(A) := |dx|
	C=R3		C(A) := dy
	GOSUB  ABS	C(A) := |dy|
	?B>=C  A
	GOYES  obl20
	ST=1   vertcl
 obl20
	ST=0   dy<0
	A=R3		A(A) := dy
	A=A+A  A
	GONC   obl30
	ST=1   dy<0
 obl30
	?ST=1  vertcl
	GOYES  obl40
	A=R0		A(A) := dx
	ASL    W
	ASL    W
	ASL    W
	ASL    W
	ASL    W
	A=A+C  A	A(9-5) := dx ; A(4-0) := |dy|
	GONC   obl50	B.E.T.
 obl40
	GOSUBL =cslc5
	C=0    A
	A=R0
	ACEX   W
	A=C    A
 obl50
	R0=A
	D=0    A
*
* Stop ! Qu'y-at-il dans les registres ?
*
* - R0 : combine : (dx, |dy|)	(ou |dy|, dx)
* - R1 : x
* - R2 : y
* - D(A) : sigma des residus (=0 au depart)
* - ST(dy<0) = si dy<0 alors 1
*		       sinon 0
* - ST(vertcl) = si angle>pi/4 alors 1
*			       sinon 0
*

*
* BOUCLE DE TRACE D'UNE LIGNE OBLIQUE :
*
* Algorithme :
*
*
 TRC100
	A=R0		A(W) := (dx, dy)    (ou dy, dx)
*
* Modification du 87/02/21
*
	C=0    W
	LCHEX  100000
	A=A+C  W	A(9-5) ++
	A=A+1  A	A(A) ++
*
* fin de la modification
*
	C=0    W
	C=A    A	C(A) := 00000000000yyyyy  (dy)
	B=A    W
	B=0    A
	P=     9
	A=0    W
	A=B    WP	A(A) := 000000xxxxx00000
	P=     0
	ASRC		A(A) := 0000000xxxxx0000 (dx*#10000)

*
* il faut faire :
*   dx / dy   (R0(A) / R0(9-5))
*
	GOSBVL =IDIV	A := A/C; C = B := A mod C ; P := 15
*
* traitement des residus
*
	C=A    A	C(A) := residus atomique
	R3=A		R3 := dx /dy
	P=     4
	C=0    P
	P=     0
	D=D+C  A	sigma des residus
	C=D    A
	A=C    A
	LC(5)  #8000
	B=0    A	nombre de pixels a ajouter a la long
	GOSUBL =TSTA>C
	GONC   TRC110	Go if (sigma des residus)<=#10000/2
	D=D-C  A	(sigma des residus)-1
	  *		(sigma e [0.. 1.5])
	B=B+1  A	longueur de la ligne - 1
 TRC110 C=R3
	GOSUBL =csrc4
	C=C+B  A	length + 0/1
	C=C-1  A	1 -> 0, 2 -> 1...n -> n-1
	GONC   TRC120
	C=0    A	0 vaut toujours 0 !
 TRC120 R3=C
	?ST=1  vertcl	ligne verticale ?
	GOYES  TRC140	oui. Tracons-la
	GOSUB  seghrz	Non, tracons une ligne horizontale
	A=R3
	A=A+1  A
	R3=A
	C=R1		}
	C=C+A  A	} x := x + length
	R1=C		}
	C=R2		 }
	B=0    A	 }     (
	B=B+1  A	 }     (
	?ST=0  dy<0	 }     ( D := sign ? -1 : +1
	GOYES  TRC130	 }     (
	B=-B   A	 }     (
 TRC130 C=C+B  A	 } y := y + (sign ? -1 : +1)
	R2=C		 }
	GOTO   TRC170

 TRC140 ?ST=0  dy<0	vertical line
	GOYES  TRC150
	A=R2
	A=A-C  A
	R2=A
 TRC150 GOSUB  segvrt	vertical line
	A=R3
	A=A+1  A
	R3=A
	C=R2		}
	?ST=0  dy<0	}      (
	GOYES  TRC160	}      ( D := sign ? -1 : +length
	A=0    A	}      (
	A=A-1  A	}      (
 TRC160 C=C+A  A	} y := y + (sign ? -1 : +length)
	R2=C		}
	C=R1		 }
	C=C+1  A	 } x := x + 1
	R1=C		 }

 TRC170 C=R0		}
	A=R3
	GOSUBL =csrc5
	C=C-A  A	}
	GOSUBL =cslc5	} dx := dx - length (or dy)
	C=C-1  A	} dy := dy - 1	    (or dx)
	R0=C		}
*
* modification du 87/02/21
*   il y avait un ?C=0 A / RTNYES auparavant
*
	RTNC
*
* fin de la modification
*
	GOTO   TRC100	Loop if dy>=0	    (or dx)


************************************************************
* segvrt
*
* But: tracer un segment de droite vertical a partir du
*   point de coordonnees (x, y), et de longueur dy.
* Entree:
*   - R1(A) = x
*   - R2(A) = y
*   - R3(A) = dy
* Sortie:
*   - 
* Abime: A-C, D0
* Appelle: 
* Niveaux: 
* Detail: 
* Algorithme: 
* Historique:
*   86/08/27: reprogrammation
************************************************************

 segvrt GOSUB  getadr	D0 ^ point de coordonnees (R1,R2)
	A=R1		x
	LC(1)  3 
	A=A&C  A	A = x mod 4
	B=A    A
	GOSUB  drwnib	C(S) = masque pour le bit A(0)(B(0))
	C=0    A
	LC(2)  (=npixls)/4 nb de quartets a passer entre 2 p
	A=R3		dy
	B=A    A	B := loop counter
	GOTO   sgv20	Cy est indeterminee a cet endroit
 sgv10	A=DAT0 S
	A=A!C  S
	DAT0=A S
 sgv20	AD0EX
	A=A-C  A
	D0=A		D0 := D0 - (npixls)/4
	B=B-1  A
	GONC   sgv10
	RTN



************************************************************
* seghrz
*
* But: trace un segment de droite horizontal a partir du
*   point de coordonnees (x, y), de longueur dy.
* Entree:
*   - R1(A) = x
*   - R2(A) = y
*   - R3(A) = dx (0 pour un seul point, n-1 pour n points)
* Sortie:
*   - 
* Abime: 
* Appelle: drwnib, getadr
* Niveaux: 
* Algorithme: 
*   si dx + x mod 4 <= 3
*     alors
*	draw (x mod 4, x mod 4 + dx) ; retour ;
*   si x mod 4 # 0
*     alors
*	draw (x mod 4, 3) ;
*   si dx >= ((4 - (x mod 4)) mod 4) + 3
*     alors		   { il y a au moins un #F }
*	repeter ((dx - ((4 - (x mod 4)) mod 4) + 1)/4  fois
*	  draw (0, 3) ;
*   si (x + dx) mod 4 # 3
*     alors
*	draw (0, (x + dx) mod 4) ;
*   retour ;
*
*   nb: (4 - (x mod 4)) mod 4  signifie : si x mod 4 = 0
*					   alors 0
*					   sinon 4-(x mod 4)
* Historique:
*   86/08/27: reprogrammation
************************************************************

 seghrz GOSUB  getadr	D0 = adresse du point de depart
	  *		(x,y)=(R1,R2)
	A=R1		x
	C=0    A
	LC(1)  3	%0011
	A=C&A  A	A(A) = x mod 4
	B=A    A	B(A) = x mod 4
	C=R3		C(A) = dx
	A=A+C  A	A(A) = dx + x mod 4
	C=0    A
	LC(1)  3	C(A) = 3
	?A<=C  A
	GOYES  drwnib	line between x and x+dx, that's all
	?B=0   A	?(x mod 4) = 0
	GOYES  sgh10
	A=C    A	A(A) = 00003
	GOSUB  drwnib	trait entre B(0) et A(0)=3
	D0=D0+ 1
 sgh10
* now, the line is on more than 1 nibble
* we must compute the number of #F to draw
* D0 points to the nibble to be filled
* B(A) = x mod 4
	C=0    A
	LC(1)  4	C(A) = 4
	B=C-B  A	B(A) = 4 - (x mod 4)
	C=C-1  A	C(A) = 3
	B=B&C  A	B(A) = (4 - (x mod 4)) mod 4
	C=C+B  A	C(A) = ((4 - (x mod 4)) mod 4) + 3
	A=R3		A(A) = dx
	?A<C   A	if dx < ((4 - (x mod 4)) mod 4) + 3
	GOYES  sgh45

	C=B    A	C(A) = (4 - (x mod 4)) mod 4
	C=A-C  A	A(A) = dx - ((4 - x mod 4) mod 4)
	C=C+1  A	A(A) = dx - ((4 - x mod 4) mod 4)+1
	P=     5	  }
	C=0    P	  }
	P=     0	  } C(A)=(dx-((4-x mod 4)mod 4)+1)/4
	CSRB		  }
	CSRB		  }
	C=0    S	}
	C=C-1  S	} C(S)=F
	GOC    sgh40	B.E.T.	(C(S)-1)
 sgh30	DAT0=C S
	D0=D0+ 1
 sgh40	C=C-1  A	decrements dx/4
	GONC   sgh30

* there still one or zero nibble to fill
 sgh45	C=R3		dx
	A=R1		x
	A=C+A  A	x+dx = final x = xf
	C=0    A
	LC(1)  3	C(A) = %0011
	A=C&A  A	A(A) = xf mod 4
	?C=A   A	?(xf mod 4)=3
	RTNYES		rtn if there was #F (already filled)
	B=0    A
* falls into drwnib

************************************************************
* drwnib
*
* But: positionne tous les bits compris entre le bit numero
*   B(0) et le bit numero A(0) a 1 dans le quartet pointe
*   par D0.
* Entree:
*   - B(0) = no du bit de poids fort (3>=B(0)>= A(0)>= 0)
*   - A(0) = no du bit de poids faible (3>=B(0)>= A(0)>=0)
*   - D0 = ^ quartet a modifier
*   - P = 0
* Sortie:
*   - C(S) = masque correspondant au quartet a tracer
*   - D0, A(A), B(A) inchanges
* Abime: A(S), C(S), C(0)
* Niveaux: 0
* Algorithme: 
*   mettre a 1 le bit numero A(0) du quartet A(S)
*   armer tous les bits entre B(0) et A(0) du quartet A(S)
*   appliquer le masque ainsi obtenu
* Historique:
*   86/08/27: reprogrammation
************************************************************

 drwnib A=0    S
	A=A+1  S	A(S) := 1
	LC(1)  3	C(0) := 3
	C=C-A  P	C(0) := nb de decalages pour amener
	  *		le bit de poids faible
	GONC   dnib20	B.E.T.		  (A(0) -> in 0..3)
*
* boucle pour amener le bit de A(S) en bonne position
* (peut ne pas etre executee)
*
 dnib10 A=A+A  S	  } for C(P) downto 1 do
 dnib20 C=C-1  P	  }   shift A(S) left
	GONC   dnib10	  }
*
* Fin de la boucle, le bit A(0) est a 1 dans A(S)
*
	C=0    S	masque final := 0
	C=B    P
	C=A-C  P	length of mask = counter for next
	  *		loop (in 0..3)
*
* boucle pour mettre tous les bits a 1 de B(0) jusqu'a A(0)
* (executee au moins une fois)
*
 dnib30 C=C+A  S	  } for C(P):=B-A downto 0 do
	A=A+A  S	  }   mask := mask + A(S)
	C=C-1  P	  }   shift A(S) left
	GONC   dnib30	  }
*
* fin de la boucle, C(S) := masque a appliquer
*
	A=DAT0 S
	A=C!A  S	Rajoute les bits calcules ici
	DAT0=A S	
	RTN		C(S) = masque construit

************************************************************
* getadr
*
* But: trouver l'adresse du quartet correspondant au point
*   de coordonnees (x, y).
* Entree:
*   - R1(A) = x
*   - R2(A) = y
*   - (GRAFIL) = ^ GRAPHILE
* Sortie:
*   - D0, C = ^ quartet trouve
* Abime: A-C, D0
* Niveaux: 0
* Detail: D0 := GRAPHILE + (ymax-y-1) * ((npixls)/4) + x
* Historique:
*   86/08/27: reprogrammation
************************************************************

 getadr D0=(5) =GRAFIL
	A=DAT0 A	A(A) ^ GRAPHILE (debut des donnees)
	D0=A
	D0=D0- 5
	A=DAT0 A	Ymax
	C=R2		Y (in 0..Ymax-1)
	A=A-C  A	Ymax-Y (2's compl. arith. is not
	A=A-1  A	used, coord. are valid)
	C=0    A
	LC(2)  (=npixls)/4
	GOSUBL =AMPY
	D0=D0+ 5	GRAPHILE (Partie donnee)
	CD0EX
	C=C+A  A	GRAPHILE + (Ymax-Y-1)*((npixls)/4)
	A=R1		X
	P=     5	  }
	A=0    P	  }
	P=     0	  }	   [X/4]
	ASRB		  }
	ASRB		  }
	C=C+A  A	Adresse de x
	D0=C
	RTN
