	TITLE  REPLACE$ <replace.as>
*
* JPC:B03
*   87/12/08: PD/JT Interface unique pour RPLC$ et REPLACE$:
*


*
* Interface unique pour RPLC$ et REPLACE$ :
*
*     - si 3 parametres : RPLC$
*     - si 4 parametres & dernier = num : RPLC$
*     - si 4 parametres & dernier = alpha : REPLACE$
*

 Egale	?B=0   A
	RTNYES
	D0=D0- 2
	D1=D1- 2
	A=DAT1 B
	C=R0
	?C#0   XS
	GOYES  NJok
	?A=C   B
	GOYES  Jok
 NJok	C=DAT0 B
	?A#C   B
	RTNYES
 Jok	B=B-1  A
	B=B-1  A
	GONC   Egale

 C=R495 C=R4
	GOVLNG =CSRC5
 Argerr GOVLNG =ARGERR

	CON(1) 8+4	dernier numerique ou alpha
	NIBHEX 444	3 strings
	NIBHEX 34	3 mini, 4 maxi
=REPLACEe
	P=C    15	P := nb d'arguments
	?P=    4
	GOYES  r4arg
 rplc	P=     0
	GOLONG =RPLC	RPLC de JJM

 r4arg	P=     0
	A=DAT1 S	A(S) := stack signature
	A=A+1  S
	GONC   rplc	dernier argument : numerique => RPLC
*
* On a donc 4 parametres dont le dernier est alphanumerique
* C'est une chaine avec un joker ==> REPLACE$ de Martinet
*
	P=C    15
	?P#    4
	GOYES  NJ
	GOSBVL =POP1S
	?A=0   A
	GOYES  NJ
	LC(5)  2
	?A>C   A
	GOYES  Argerr
	C=P    2
	C=DAT1 B
	R0=C
	D1=D1+ 2
	GONC   REPC

 Test	C=R3
	?C#0   A
	GOYES  Test2
	?A=0   A
	GOYES  Exp1
	GOTO   Exp
 Test2	?A=0   A
	GOYES  Exp
	RTN

 Exp1	GOSUB  C=R495
	D1=C
 Exp	D1=D1- 16
	C=RSTK
	GOTO   Expr

 A=AVMS CD1EX
	D1=(5) =AVMEMS
	A=DAT1 A
	D1=C
	RTN

 NJ	P=P+1
	C=P    2
	R0=C

 REPC	GOSBVL =POP1S
	CD1EX
	D1=C
	GOSBVL =CSLC5
	R4=C
	CD1EX
	C=C+A  A
	D1=C

	GOSBVL =POP1S
	CD1EX
	C=C+A  A
	D1=C
	R3=A

	GOSBVL =POP1S
	GOSUB  Test
	CD1EX
	R2=C
	C=C+A  A
	D=C    A
	C=0    A
	R1=C
	C=R0
	A=C    X
	CD0EX
	CSL    W
	CSL    W
	CSL    W
	C=A    X
	R0=C
	D0=(5) =F-R0-0
	C=D    A
	DAT0=C A

 TestAB A=R3
	C=R2
	B=C    A
	C=D    A
	C=C-B  A
	?C<A   A
	GOYES  Stk1
	C=D    A
	D0=C 
	C=R2
	D1=C
	D1=D1- 16
	C=R3
	B=C    A
	GOSUB  Egale
	?B#0   A
	GOYES  Stk1
	GOSUB  C=R495
	D1=C
	D1=D1- 14
	C=DAT1 A
	D1=D1- 2
	CD1EX
	A=R1
	C=C-A  A
	CD1EX
	A=C    A
	GOSUB  C=R495
	C=C+A  A
	CD0EX
	B=A    A
	GOSUB  A=AVMS
	GOSUB  Stk
	C=R3
	D=D-C  A
	GONC   StkC

 Stk1	GOSUB  A=AVMS
	C=D    A
	D0=C
	C=R1
	B=C    A
	GOSUB  C=R495
	C=C-B  A
	D1=C
	D1=D1- 16
	LC(5)  2
	B=C    A
	GOSUB  Stk
	CD0EX
	D=C    A
 StkC	C=R2
	?C=D   A
	GOYES  Fin
	GOTO   TestAB

 Stk	CD1EX
	C=C-B  A
	?A>C   A
	GOYES  Memerr
	C=C+B  A
	D1=C
 Boucle ?B=0   A
	RTNYES
	D0=D0- 2
	D1=D1- 2
	C=DAT0 B
	DAT1=C B
	C=R1
	C=C+1  A
	C=C+1  A
	R1=C
	B=B-1  A
	B=B-1  A
	GONC   Boucle

 Memerr GOVLNG =MEMERR

 Fin	D1=(5) =F-R0-0
	C=DAT1 A
	D1=C
	GOSUB  C=R495
	A=C A
	LC(5)  16
	A=A-C  A
	C=R1
	GOSBVL =MOVEDD
	D1=D1- 16
	C=R0
	CSR    W
	CSR    W
	CSR    W
	D0=C
	C=R1
	CSL    W
	CSL    W
	LCHEX  F
	DAT1=C 7
 Expr	GOVLNG =EXPR

	END
