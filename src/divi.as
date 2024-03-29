	TITLE  DIVILEX <divi.as>

*
* 1..n-1 emes versions :
*   Guy Toublanc
* JPC:A01:
*   ../../..: PD/JT Intégrations dans JPC Rom
* JPC:A06
*   87/04/20: PD/JT Intégration définitive dans JPC Rom
*		interruption par [ATTN] deux fois,
*		emission du message "Fonction Interrupted"
*   87/05/01: PD/JT Changement de nom (FPRiM et NPRiM)
*

*
*
	NIBHEX 811
=PHIe	GOSUB  pop1n
	R0=A
	R2=A
	C=0    W
	C+P+1
	?A=C   W
	GOYES  RESA
 HI0	GOSUB  GTES
 R0A	R0=A
	?A#C   W
	GOYES  LO0
	R1=C
	GOSUB  PHI
	GONC   RESA
 LO0	GOSUB  div
	C=R1
	?B=0   W
	GOYES  R0A
	GOSUB  PHI
	GONC   HI0
 PHI	A=R2
	C=R1
	GOSUB  div
	C=R1
	C=C-1  W
 R2A	R2=A
 dh	GOSBVL =DCHXW
	SETDEC
	A=R2
	GOSBVL =MPY
	R2=A
	RTN
 
 RESC	A=C    W
 RESA	GOSBVL =FLOAT
	C=A   W
	AD0EX
	D0=(5) =ATNFLG	 
	DAT0=A S
	D0=A
 OUT	GOVLNG =FNRTN1
 
	NIBHEX 88888888882A
=PPCMe	ST=1   2
	GONC   pgd
 
	NIBHEX 88888888882A
=PGCDe	ST=0   2
 pgd	GOSUB  DCS
	R1=A
	GOSUB  pop1n
	GONC   pgc
 LOOPG	R3=C
	GOSUB  pop1n
 pgc	GOSUB  PGC
	?D#0   S
	GOYES  LOOPG
	GONC   RESC
 PGC	C=R1
	?C#0   W
	GOYES  DIF0
	ACEX   W
 DIF0	R3=A
	R2=C
 EUCL	GOSUB  R1C
	?B=0   W
	GOYES  PGCD
	A=R1
	GONC   EUCL
 PGCD	C=R1
	?ST=0  2
	RTNYES
	A=R3
	GOSUB  div
	R0=A
	A=R2
	GOSUB  E12
	ACEX   W
	GOSUB  div
	C=R0
	?A<C   W
	GOYES  pop
	GOSUB  dh
	R1=A
	RTN
 pop	C=RSTK
 ERR	GOVLNG =ARGERR
 
 DCS	D=C    S
 pop1n	GOSBVL =POP1R
	D1=D1+ 16
	?A=0   S
	GOYES  C11
	ST=1   0
 C11	LCHEX  011
	?A>C   X
	GOYES  pop
	GOSBVL =SPLITA
	GOSBVL =CLRFRC
	GONC   pop
	A=B    M
	D=D-1  S
	GOVLNG =RJUST
 
 E12	P=     1
	C=0    W
	C=P    12
	P=     0
	RTN
 
 CONST	C=0    W
	LCHEX  2
	D=C    W
	LCHEX  10
	R4=C
	RTN
 
	NIBHEX 8812
=FPRIMe ST=1   1
	GONC   prim
 
	NIBHEX 8822
=NPRIMe ST=0   1
 prim	ST=0   0
	GOSUB  DCS
	C=0    W
	?ST=1  0
	GOYES  LIM2
	GOSUB  E12
 LIM2	R2=C
	?D=0   S
	GOYES  LIM1
	R2=A
	ST=0   0
	GOSUB  pop1n
 LIM1	C=R2
	?A<=C  W
	GOYES  N<n
	ST=1   0
 N<n	C=0    W
	LCHEX  2
	?ST=1  0
	GOYES  DESC
	?A>=C  W
	GOYES  DESC
	A=C    W
 DESC	R0=A
	A=R2
	?ST=0  0
	GOYES  ASC
	?A>=C  W
	GOYES  ASC
	R2=C
 ASC	GOSUB  CONST
	A=0    W
	R3=A
	C=R0
 LOOPF	R0=C
	A=R2
	?ST=0  0
	GOYES  CRES
	ACEX   W
 CRES	?C>A   W
	GOYES  RESN
	GOSUB  NTES
	?A#C   W
	GOYES  CONT
	?ST=1  1
	GOYES  RESU
	C=R3
	C=C+1  W
	R3=C
 CONT	C=R0
	?ST=0  0
	GOYES  INCR
	C=C-1  W
	GONC   LOOPF
 INCR	C=C+1  W
	GONC   LOOPF
 RESN	A=R3
 RESU	GOTO   RESA
 
 R1C	R1=C
 div	GOSBVL =IDIV
	RTNCC
 
	NIBHEX 8812
=PRIMe	GOSUB  DCS
	?D=0   S
	GOYES  TVAL
	C=0    W
	LCHEX  999
	?A>C   W
	GOYES  err
	C=C+1  A
	R1=C
	R0=A
	GOSUB  pop1n
	C=R1
	GOSUB  R2A
	A=R0
	A=A+C  W
 TVAL	R0=A
	?A#0   W
	GOYES  VAL
 err	GOTO   ERR
 VAL	GOSUB  GTES
	?A#C   W
	GOYES  resc
	C=0    W
 resc	GOTO   RESC
 
 GTES	GOSUB  CONST
 NTES	C=D    W
	GOSUB  TES0
	C=C+1  B
	GOSUB  TES0
	GOSUB  TES2
	GOSUB  TES2
	GOSUB  TES4
 LOOP	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES6
	GOSUB  TES2
	GOSUB  TES6
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES6
	GOSUB  TES6
	GOSUB  TES2
	GOSUB  TES6
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES6
	GOSUB  TES4
	GOSUB  TES6
	GOSUB  TES8
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES8
	GOSUB  TES6
	GOSUB  TES4
	GOSUB  TES6
	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES6
	GOSUB  TES2
	GOSUB  TES6
	GOSUB  TES6
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES6
	GOSUB  TES2
	GOSUB  TES6
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES4
	GOSUB  TES2
	GOSUB  TES10
	GOSUB  TES2
 
	?ST=0  12
	GOYES  PL10
	AD0EX
	D0=(5) =ATNFLG
	A=DAT0 S
	?A=0   S
	GOYES  D0A
	SETHEX
	A=A+1  S
	GOC    setdec
	DAT0=C S
	D0=A
	P=     0
	LC(4)  (=id)*256+(=eFNINT)
	GOVLNG =BSERR
 
 setdec SETDEC
 D0A	D0=A
 PL10	A=0    W
	P=     1
	A=A+1  P
	C=C+A  W
	A=R0
	GOSUB  R1C
	C=R1
	P=     7
	?B=0   WP
	GOYES  rnp
	?C>A   W
	GOYES  RESP
	GOTO   LOOP
 
 RESP	C=R0
 rnp	GOC    RNP
 TES10	C=C+D  WP
 TES8	C=C+D  WP
 TES6	C=C+D  WP
 TES4	C=C+D  WP
 TES2	C=C+D  WP
 TES0	R1=C
	A=R0
	P=     0
 HI	?C>=A  W
	GOYES  LO
	CSL    W
	P=P+1
	GONC   HI
 LO	A=A-C  W
	GONC   LO
	A=A+C  W
	P=P-1
	GOC    LO1
	CSR    W
	GONC   LO
 LO1	C=R1
	P=     7
	?A#0   WP
	RTNYES
	C=RSTK
	C=R1
 RNP	A=R0
	RTN
 
	END
