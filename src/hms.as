	TITLE	HMSLEX <hms.as>

************************************************************
* HR
************************************************************

	NIBHEX 811
=HRe	ST=0   0
	GONC   ST1
 
************************************************************
* HMS
************************************************************

	NIBHEX 811
=HMSe	ST=1   0
 
 ST1	ST=0   1
	ST=1   2
 
 A0W	A=0    W
	B=0    W
	GOSBVL =STAB1
 
 POPN	GOSBVL =ARGPRP
	?ST=1  2
	GOYES  CONV
	A=-A-1 S
	ST=1   2
 
 CONV	GOSUB  stab2
	GOSUB  rccd1
	GOSBVL =STAB1
	GOSUB  exab2
	A=A+1  A
	A=A+1  A
	?ST=1  0
	GOYES  six
	GOSUB  stab2
 six	GOSUB SIX
	?ST=0  0
	GOYES  exa
	GOSUB  stab2
 exa	GOSUB  exab2
	?ST=1  0
	GOYES  si
	GOSUB  SIX
 si	GOSUB  SIX
	GOSBVL =RCCD2
	GOSUB  ad2-15
	A=A-1  A
	A=A-1  A
	GOSUB  rccd1
	?ST=1  1
	RTNYES
 
	GOSBVL =uRES12
	?ST=1  0
	GOYES  RNDTST
 
 OUT	GOVLNG =FNRTN4
 
 RNDTST R0=C
	R4=C
	A=R0
	A=0    S
	C=0    W
	P=     14
	LCHEX  6
	C=C-1  X
	R1=C
	A=A+1  X
	A=A+1  X
	A=A+1  X
	A=A+1  X
	GOSUB  IP
	GONC   FP
	GOSUB  DV/100
	GOC    NOFP
	GOSUB  TEST
 NOFP	GOSUB  DV/100
	GOC    FP
	GOSUB  TEST
	R0=A
 FP	C=R0
	A=R4
	C=A    S
	GOTO   OUT
 
************************************************************
* HMSSUB
************************************************************

	NIBHEX 8822
=HMS-e	ST=0   2
	GONC   ST
 
************************************************************
* HMSADD
************************************************************

	NIBHEX 88888888882A
=HMS+e	ST=1   2
 
 ST	ST=1   1
	ST=0   0
	C=C-1  S
	C=C-1  S
	R4=C
	GOSUB  A0W
 STA	GOSBVL =STAB1
	D1=D1+ 16
	GOSUB POPN
	C=R4
	C=C-1  S
	R4=C
	GONC   STA
 
	ST=1   0
	C=0    W
	R0=C
	R1=C
	ST=0   1
	GOTO   CONV
 
 SIX	C=0    W
	P=     14
	LCHEX  6
	D=C    W
	C=0    P
	?ST=0  0
	GOYES  dv
	A=A-1  A
 mp2-15 GOVLNG =MP2-15
 
 dv	A=A+1  A
	GOVLNG =DV2-15
 
 stab2	GOSBVL =STAB2
 clrfrc GOVLNG =CLRFRC
 
 exab2	GOSBVL =EXAB2
 frac15 DAT1=A W
	C=B    W
	D=C    W
	GOSUB  clrfrc
	A=-A-1 S 
	C=DAT1 W
	GOTO   ad2-15
 
 rccd1	GOSBVL =RCCD1
 ad2-15 GOVLNG =AD2-15
 
 DV/100 A=A-1  X
	A=A-1  X
	R0=A
 IP	GOSBVL =SPLITA
	GOSUB  clrfrc
 A=B	A=B    M
	RTN
 
 TEST	AR0EX
	GOSBVL =SPLITA
	GOSUB  frac15
	A=B    M
	C=R1
	?A#C   W
	GOYES  NO60
	A=0    W
	AR0EX
	GOSBVL =SPLITA
	GOSBVL =ADDONE
	A=B    M
	AR0EX
 NO60	C=R0
	GOSBVL =AD2-12
	GOTO   A=B
 
	END
