	TITLE  SCANLEX <scan.as>

*
* Premiere version : 01/05/86
*   JPC:A01 -> JPC:A05
*   Jean-Jacques Moreau
*   Ecriture du Lex
* Deuxieme version :
* JPC:A06
*   87/05/02: PD/JT Retrait de TYPE (conflit avec MATHROM)
*

*
* Bogue restante :
*   ENTRY$("MEMORY") <==> ENTRY$("MEM")
*   ENTRY$("TO345678901234567") <==> ENTRY$("TO")
*   ENTRY$("CR") <==> ENTRY$("CREATE")
*
 Find	P=C    15	Argcount to P
	A=0    A
	?P=    1	Find 1st keyword?
	GOYES  Find1
	GOSBVL =RNDAHX
	GONC   Argerr	2nd parm<0?
	D1=D1+ 16
	A=A-1  A	Find n-th keyword
	GOC    Argerr	2nd parm=0?
 Find1	R1=A		Save counter in R1
	P=     0
	GOSBVL =REVPOP	Pop& reverse string on stack
	CD1EX
	D1=C		D1@ 1st string char.
	C=C+A  A
	D=C    A	D(A)=(FORSTK)
	GOSBVL =CSLW5
	CD0EX
	D0=C
	R3=C		Save D0& D1 in R3
	ST=1   0	Charaterization required
	GOSBVL =NTOKEN	Sets A(?-0)=TOKEN
	  *		B(A)=execaddress (if there is one)
 Findx	?ST=1  11	Variable?
	GOYES  Argerr
	?A#0   A	GO?
	GOYES  Find2	No
 Argerr GOVLNG =ARGERR	Rather than IVAERR

 Find2	AR1EX		Counter to A(A)
	A=A-1  A
	AR1EX
	RTNC		Return if nth keyword has been found
	GOSBVL =RESPTR	Restore input pointer for RESCAN
	ST=1   0	Characterization required
	A=C    A	Lexbuf pt for token to be replaced
	GOSBVL =RESCAN	Find keyword
	GOTO   Findx


	 NIBHEX 8412	Argcount [1,2]
=TOKENe	 GOSUB	Find	 Find TOKEN
	 ST=0	4

*
*
* Tokens are as follow
*   FN	  :	Tk , 0Tk00
*   STMT  :	Tk , 0Tk00
*   XFN	  : TkIdB3 , 0TkId
*   FFN	  : TkIdB4 , 0TkId
*   XSTMT : TkIdEF , 0Tkid
*   WORD  : TkIdEF , 0TkId
*
*

	 LC(2)	=tXWORD
	 ?A=C	B
	 GOYES	Schi++	 Go if XFN, XWORD or XSTMT
	 LC(2)	=tXFN
	 ?A=C	B
	 GOYES	Schi++
	 C=C+1	B
	 ?A=C	B
	 GOYES	Schif+	 Sets ST4 prior to go to Schi++
	 ASL	A	 Here if mainframe keyword
	 A=0	M
	 ASL	A
	 GONC	Schift	 (B.E.T.)
 Schif+	 ST=1	4	 Indicate FFN
 Schi++	 ASR	W
	 ASR	A
 Schift	 R0=A
	 A=0	M
	 A=0	XS
	 C=0	A
	 LC(3)	1000
	 GOSBVL =A-MULT	 A(A)=Id*1000
	 C=R0
	 CSR	A
	 C=0	M
	 CSR	A	 C(A)=Tk
	 A=A+C	A
 Fnrtn	 GOSBVL =HDFLT	 A(A)=Result (Cf MSG$)
	 B=A	W	 Save result in B(W)
	 GOSBVL =D1C=R3	 Restores D1 from R3, sets C(A)=PC
	 A=B	W	 Result in C(W)
	 ACEX	W	 PC in A(A)
	 ?ST=0	4	 FFN?
	 GOYES	Pos
	 P=	9	 Yes, change sign
	 CPEX	15
 Pos	 GOVLNG =FNRTN2


	 NIBHEX 8412	Argcount [1,2]
=ENTRYe	 GOSUB	Find	 Find execaddress for keyword
	 GOSBVL =D1C=R3
	 D0=C		 Restore D0& D1 from R3
	 A=B	A	 Move execaddress to A(A)
	 C=0	W
	 P=	4
	 CPEX	15	 4+1 nibs to convert in ASCII
	 D=C	W	 Save counter in D(W)
	 GOSBVL =HEXASC
	 D=D+1	S
	 D=D+D	S
	 DSLC
	 C=D	A	 Compute output string length
	 GOSBVL =STRHDR	 Prepare header for string in B(W)
	 P=C	0
	 P=P-1		 String length-1 to P
	 A=B	W
	 DAT1=A WP	 Write string
	 D1=D1- 16	 Move to header
	 P=	0
	 GOSBVL =REV$	 Reverse string
	 GOVLNG =EXPR

	 END
