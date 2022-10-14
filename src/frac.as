	TITLE  FRAC$ <frac.as>
	
*
*    ../../..: Guy Toublanc Conception
* JPC:A05
*   87/02/22: PD/JT Intégration dans JPC Rom
*
 
************************************************************
* FRAC$
************************************************************

	NIBHEX 8812	mini : 1 param. maxi 2
	  *		param. numeriques
 
=FRACe
	AD0EX		sauvegarde D0
	D0=(5) (=FUNCD0)
	DAT0=A A
	C=C-1  S	decremente le nombre
	C=C-1  S	de parametres
	C=0    W
	R2=C		D-1 = 0 -> R2
	P=     1
	C=P    14
	R1=C		Do = 1 -> R1
	R0=C		N-1 = 1 -> R0
	ST=0   0	repere parametre precision
	GOC    POPN	1 seul parametre alors POPN
	GOSBVL =POP1R	pope et teste n (precision
	  *		ou nombre d'iterations)
	D1=D1+ 16	actualise D1
	?A=0   S	parametre precision ?
	GOYES  A0S	oui alors on conserve le
	  *		repere precision (S0=0)
	ST=1   0	repere iteration
 A0S	A=0    S
	?A=0   X	1 seul digit ?
	GOYES  aslc2	oui alors shift 2 fois
	ASLC		non alors shift 3 fois
 aslc2	ASLC
	ASLC		ici A(B) = n
	C=A    B	C(W) = 10^n
	C=-C   X	C(W) = 10^(-n)
 
 POPN	GOSBVL =POP1R	pope et teste N
	?C#0   B	C(B) = n ?
	GOYES  PARAM	oui alors precision donnee
	  *		ou nombre d'iterations
	  *		demande
	LCHEX  499
	C=C-A  X	C(X) = 499 - exposant de N
	LCHEX  990	C(W) = 10^(-10)
	GONC   PARAM	exposant de N > 0 alors
	  *		C(W) = precision
	C=C+A  X	exposant < 0 alors prec.
	  *		flottante 10^(-10 + expos.
	  *		de N )
 
 PARAM	C=A    S	recupere le signe de N
	DAT1=C W	sauve le signe de N et le
	  *		parametre precision ou
	  *		iterations sur la math
	  *		stack
	A=0    S	A(W) = ABS(N)
	GOSUB  STO	sauvegarde dans la scratch
	  *		math stack
	GOSUB  stscr	sauvegarde de ABS(Ho) =
	  *		ABS(N)
	GOSUB  clrfrc	A(W) = IP(ABS(N))
	R3=A		IP(ABS(N)) = ABS(No) -> R3
 
 LOOP	?ST=0  0	option precision ?
	GOYES  PREC	oui saut au test precision
	A=DAT1 B	A(B) = - parametre
	  *		iterations
	A=A+1  B	incrementation
	GOC    out	derniere iteration
	  *		alors resultat
	DAT1=A B	sauve le nombre
	  *		d'iterations restantes
	GONC   ITER	saute le test precision
 PREC	GOSUB  A-1S	A(W) = -IP(ABS(N))
	  *		    ou -ABS(Ni/Di)
	  *		X = ABS(N)
	  *		A(W) = ABS(N)
	  *		X = ABS(N) - ABS(Ni/Di)
	  *		  = delta
	  *		A(W) = ABS(delta)
	C=DAT1 W	C(W) = precision et signe
	  *		de N
	C=0    S	C(W) = precision
	P=     3	pour TEST12A
	GOSBVL =TST12A	ABS(delta) <= precision ?
	GOC    out	oui alors resultat
 ITER	GOSUB  AR3	Ni -> scratch math stack
	GOSBVL =RCLW2	X = ABS(Hi)
	GOSUB  clrfrc	A(W) = IP(ABS(Hi))
 out	GOC    OUT	FP(Hi) = 0 alors resultat
	GOSUB  A-1S	A(W) = FP(ABS(Hi))
	GOSBVL =SPLITA	A(W) -> X
	GOSBVL =1/X15	X = 1/FP(ABS(Hi))
	  *		  = ABS(Hi+1)
	GOSUB  ROUND	ABS(Hi+1) arrondi a 12
	  *		digits -> A(W)
	GOSBVL =RCSCR	fait la place pour Hi+1
	GOSUB  STOfrc	ABS(Hi+1) -> scr. math st.
	  *		puis A(W) = IP(ABS(Hi+1))
	  *			  = ai+1
	C=R3		C(W) = ABS(Ni)
	GOSUB  mp2-12	A(W) = ai+1 * ABS(Ni)
	C=R0		C(W) = ABS(Ni-1)
	GOSUB  AD	A(W) = ABS(Ni+1)
	  *		  = ai+1*ABS(Ni)+ABS(Ni-1)
	AR3EX		R3 = ABS(Ni+1)
	  *		A(W) = ABS(Ni)
	R0=A		RO = Ni remplace Ni-1
	GOSBVL =RCLW1	X = ABS(Hi+1)
	GOSUB  clrfrc	A(W) = ai+1
	C=R1		C(W) = Di
	GOSUB  mp2-12	A(W) = ai+1 * Di
	C=R2		C(W) = Di-1
	GOSUB  AD	A(W) = Di+1 = ai+1*Di+Di-1
	AR1EX		R1= Di+1   A(W) = Di
	R2=A		R2 = Di remplace Di-1
	GOSUB  AR3	X = ABS(Ni+1) -> scr.mstack
	A=B    M	A(W) = ABS(Ni+1)
	C=R1		C(W) = Di+1
	GOSBVL =DV2-12	X = ABS(Ni+1) / Di+1
	GOSUB  ROUND	A(W) = ABS(Ni+1)/Di+1
	  *		arrondi a 12 digits
	  *		scrmstk -> ABS(Ni+1) -> R3
	GOTO   LOOP
 
 OUT	A=R3		A(W) = ABS(Ni+1)
	C=DAT1 W	C(S) = signe de N
	A=C    S	A(W) = Ni+1
	R3=A		R3 = Ni+1
	D0=(5) =FUNCD0	recuperation de D0
	C=DAT0 A
	D0=C
	C=R1		C(W) = Di+1
	P=     14
	C=C-1  P
	C=C-1  W	si Di+1 = 1 alors carry
	P=     0	necessaire pour STR$00
	ST=0   1	les blancs sont supprimes
	GONC   DIF1	Di+1 # 1 alors resultat
	  *		avec Di+1
	GOSUB  A2STR	Ni+1 ou N en chaine
	GOTO   expr	et fin
 
 DIF1	A=R1		A(W) = Di+1
	GOSUB  REVST	Di+1 sur la math stack ->
	  *		chaine alpha inversee
	  *		-> en-tete enlevee
	C=R1		C(A) = D1 (fin de chaine)
	RSTK=C		sauve D1 sur pile retours
	LCASC  '/'	C(B) = /
	D1=D1- 2	prepare la pile a recevoir
	  *		/
	DAT1=C B	/ sur la pile
	A=R3		A(W) = Ni+1
	D1=D1- 16	prepare la pile a recevoir
	  *		Ni+1
	GOSUB  REVST	Ni+1 -> pile -> chaine
	  *		alpha -> chaine inversee
	  *		-> entete enlevee
	C=RSTK		on recupere D1 (fin de
	  *		chaine
	R1=C		R1(A) = D1 (fin de chaine)
	  *		necessaire pour ADHEAD
	GOSBVL =ADHEAD	ajoute l'entete
	GOSBVL =REV$	renverse la chaine
 expr	GOVLNG =EXPR	resultat et retour au BASIC
 
 REVST	GOSUB  A2STR	converti A(W)
	GOSBVL =REV$	chaine inversee
	P=     0	necessaire pour XXHEAD
	GOVLNG =XXHEAD	en-tete enlevee
 
 STOfrc GOSUB  STO	A(W) -> scr. math st.
 clrfrc GOSBVL =CLRFRC	X = IP(X)
 A=B	A=B    M	X -> A(W)
	RTN
 
 mp2-12 GOSBVL =MP2-12	X = A(W) * C(W)
	GOTO   A=B	X -> A(W) et retour
 
 AR3	A=R3		A(W) = ABS(Ni)
 STO	GOSBVL =SPLITA	A(W) -> X
 stscr	GOVLNG =STSCR	X -> scr. math st.
 
 ROUND	GOSBVL =uRES12	X 15 digits -> C(W) arrondi
	  *		a 12 digits
	A=C    W
	GOSBVL =RCSCR	scr.mstack -> ABS(Ni) -> Y
	C=D    M	Y -> C(W)
	R3=C		ABS(Ni) -> R3
	RTN
 
 A-1S	A=A-1  S	positif -> negatif
	GOSBVL =RCLW2	X = 2e niveau scr.mstack
	A=B    M	X -> A(W)
 AD	GOSBVL =AD2-12	X = A(W) + C(W)
	A=0    S	valeur absolue
	GOTO   A=B	X -> A(W) et retour
 
 A2STR	DAT1=A W	nombre sur la pile
	AD1EX		sauve D1
	D1=(5) (=DSPFMT)
	C=DAT1 S	C(S) = format courant
	R4=C		sauve dans R4(S)
	C=0   A		impose le ..
	DAT1=C 1	.. format STD
	AD1EX		restaure D1
	GOSBVL =STR$SB	fait la conversion
	AD1EX		sauve D1
	D1=(5) =DSPFMT
	C=R4
	DAT1=C S	restaure le format courant
	AD1EX		restaure D1
	RTN
 
	END
