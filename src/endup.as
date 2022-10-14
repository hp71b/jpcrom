	TITLE	ENDUPLEX <endup.as>
*
*   86/07/24: JJM
* JPC:B03
*   87/12/08: PD/JT Correction du bug détecté par Tapani
*	Tarvainen (ST=0 avant ADHEAD)
*
 
=bENDUP	EQU    #0083E
 
	REL(5)	=ENDUPd
	REL(5)	=ENDUPp
=ENDUPe GOSBVL	=EXPEXC
	LC(3)	=bENDUP
	GOSUB	end007
 nxtstm GOVLNG	=NXTSTM
 
	REL(5)	=EXECUTEd
	REL(5)	=EXECUTEp
=EXECUTEe
	GOSBVL	=EXPEXC
	LC(3)	=bIEXKY
	GOSUB	end007
	GONC	nxtstm
	LC(3)	=bIEXKY
	GOSBVL	=I/OFND
	CD1EX
	GOVLNG	=LINEP+
 
 
 end007 R2=C
	GOSBVL	=XXHEAD
	LCHEX	0D
	D1=D1-	2
	DAT1=C	B
	ST=1	0
	GOSUB	adhead
	GOSBVL	=REVPOP
	CD1EX
	R0=C
	C=C+A	A
	GOSBVL	=AVE=C
	C=0	A
	C=C+1	A
	C=C+1	A
	?A>C	A
	GOYES	end010
	C=R2
	GOSBVL	=I/ODAL
	RTNCC
 
 end010 B=A	A
	C=0	A
	LC(2)	95*2+2
	?A<=C	A
	GOYES	end040
	LC(2)	=eSTROV
	GOVLNG	=MFERR
 end040 R1=A
	C=R2
	GOSBVL	=I/OALL
	GOC	end050
 memerr GOVLNG	=MEMERR
 end050 A=R0
	D0=A
	C=R1
	GOSBVL	=MOVEU3
	RTNSC
 
 
	NIBHEX	00
=STARTUPe
	LC(3)	=bSTART
	GONC	run	B.E.T.
 
	NIBHEX	00
=ENDUP$e
	LC(3)	=bENDUP
 run	AD1EX
	R1=A
	GOSBVL	=I/OFND
	CD1EX
	CD0EX
	B=C	A
	GOSBVL	=D=AVMS
	A=R1
	D1=A
	GONC	bf2s20	Pas de buffer
 bf2s10 A=DAT0	B
	LCHEX	0D
	?A=C	B
	GOYES	bf2s20
	C=A	B
	GOSBVL	=STKCHR
	D0=D0+	2
	GONC	bf2s10	B.E.T.
 
 bf2s20 C=B	A
	D0=C
*
* Le ST=0 ci-dessous corrige un bug détecté par Tapani
* Tarvainen
*
* DESTROY ALL
* DIM S$
* DIM S$[LEN(STARTUP$)]	  (ou ENDUP$)
*  ==> Data Type
*
	ST=0	0	Sans retour (jump to EXPR)
*
* Fin de la correction : dans DIM, il y avait rtn
*
 adhead GOVLNG =ADHEAD	Avec ou sans retour

	END
