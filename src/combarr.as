	TITLE  COMBARR <combarr.as>
*
*   ../../..: Laurent Istria codage
*   ../../..: Guy Toublanc reconception
* JPC:A05
*   87/01/24: PD/JT intégration dans JPC Rom
* JPC:A06
*   87/04/17: PD/JT correction du bug S=S+COMB(n,0)
*

************************************************************
* ARR
************************************************************

	NIBHEX 8822
=ARRe
	ST=0   0
	GOTO   START

************************************************************
* COMP
************************************************************

	NIBHEX 8822
=COMBe
	ST=1   0

 START	GOSUB  POP
	GOSBVL =STAB2
*
* Correction du bug le <870417.2215>
*   D1=D1+ 16 doit être fait même si P=0
*
	D1=D1+ 16
*
* Fin de la corrrection
*
	?B=0   W
	GOYES  C1
*
* Suppression de la ligne suivante le <870417.2215>
*	D1=D1+ 16
*
	GOSUB  POP
	GOSBVL =STAB1
	GOSBVL =RCCD2
	P=     2
	GOSBVL =TST15
	GONC   P6
	?ST=0  0
	GOYES  P6
 C1	C=0    W
	P=     1
	C=P    14
	GOTO   FNRTN
 P6	P=     6
	GOSBVL =TST15
	GOC    CONT
	GOTO   ERR
 CONT	?ST=0  0
	GOYES  ar
	C=C-1  S
	GOSBVL =AD2-15
	GOSBVL =RCCD2
	P=     1
	GOSBVL =TST15
	GONC   ar
	GOSBVL =EXAB2
 ar	AD0EX
	D0=(5) (=FUNCD0)
	DAT0=A A
	A=0    W
	B=0    W
	P=     14
	B=B+1  P
	GOSBVL =STSCR
 LOOP
	GOSBVL =RCLW1
	GOSBVL =RCCD1
	GOSBVL =MP2-15
	GOSBVL =RCCD2
	?ST=0  0
	GOYES  NODIV
	GOSBVL =DV2-15
 NODIV	GOSBVL =STSCR
	GOSBVL =EXAB2
	GOSBVL =SUBONE
	?B=0   W
	GOYES  OUT
	GOSBVL =EXAB2
	GOSBVL =EXAB1
	GOSBVL =SUBONE
	GOSBVL =EXAB1
	GOTO   LOOP
 OUT	GOSBVL =RCLW1
	D0=(5) (=FUNCD0)
	C=DAT0 A
	D0=C
	GOSBVL =uRES12
 FNRTN	GOVLNG =FNRTN4
 POP	GOSBVL =POP1R
	?A#0   S
	GOYES  ERR
	LCHEX  011
	?A>C   X
	GOYES  ERR
	GOSBVL =SPLITA
	GOSBVL =CLRFRC
	RTNC

 ERR	GOVLNG =ARGERR

	END
