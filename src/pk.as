	TITLE  PKLEX <pg.as>
 
*
* JPC:A05
*   87/03/03: PD Integration dans JPCLEX
* JPC:B00
*   87/05/13: PD Correction de la bogue PEEK$("FFFFF",16)
* JPC:D01
*   88/12/18: PD/JT Reecriture complete
*
 
=LEX2
	CON(2)	01	Id
	CON(2)	63	Lowest Token
	CON(2)	64	Highest Token
	REL(5)	=LEX3	Next Lex Link (ilmsg.as)
	NIBHEX	F	No speed table
	REL(4)	1+TxTbSt
	CON(4)	0	No message table
	CON(5)	0	No Poll handler
*
* MAIN TABLE
*
	CON(3)	(TxEn63)-(TxTbSt)
	REL(5)	=PEEKe
	CON(1)	#F
 
	CON(3)	(TxEn64)-(TxTbSt)
	REL(5)	=POKEe
	CON(1)	#D
*
* TEXT TABLE
*
 TxTbSt
 TxEn63 CON(1)	9
	NIBASC	\PEEK$\
	CON(2)	63
 TxEn64 CON(1)	7
	NIBASC	\POKE\
	CON(2)	64
 
	NIBHEX	1FF
 
**************************************************
* POKE
*
* But : executer l'ordre POKE en ne tenant pas
*   compte des zones protegees.
* Historique :
*   18/12/88 : PD/JT reconception
**************************************************

	REL(5)	=POKEd
	REL(5)	=POKEp
=POKEe
*
* Evalue et depile le premier parametre
*
	GOSBVL	=EXPEX-	Evalue l'expression

	CD0EX		Sauver D0 car abime par
	RSTK=C		POPADR

	GOSUB	=POPADR	Depile l'expression

	D0=(5)	=STMTD0	Sauver l'adresse dans
	A=B	A	STMTD0
	DAT0=A	A

	C=RSTK
	D0=C

	D0=D0+	2	passe tCOMMA
*
* Evalue et depile la chaine hexa
*
	GOSBVL	=EXPEX-

	GOSBVL	=POP1S
 
	C=0	M
	C=A	A
	CSRB		C(A) := longueur en octets
	D=C	A	D(A) := longueur en octets
*
* STMTD0 = adresse ou ranger la chaine
* D(A) = longueur de la chaine en octets
*
	D1=(5)	=FORSTK	Fond de la M.S.
	C=DAT1	A
	D1=C	A	D1 := ^ premier caractere

	D0=(5)	=STMTD0
	C=DAT0	A
	D0=C

*
* D1 = ^ chaine a poker
* D0 = adresse ou poker
* D(A) = nb de caracteres a poker
*
	GOTO	POK100

 POK050	D1=D1-	2
	A=DAT1	B
	C=0	S
	GOSUB	ASCHEX
	A=B	A
	DAT0=A	1
	D0=D0+	1

 POK100	D=D-1	A
	GONC	POK050

	GOVLNG	=NXTSTM

**************************************************
* ASCHEX
*
* But: routine pompee dans les IDS III, car elle
*   n'est pas supportee. Merci HP !
*   L'adresse est 1C5E3 dans la version 1BBBB
* Note: elle a ete un peu modifiee, car la version
*   d'HP n'est pas optimale.
**************************************************

 ASCHEX	GOSBVL	=DRANGE
	GONC	ATH100

	GOSBVL	=CONVUC
	LCASC	'FA'
	GOSBVL	=RANGE
	GOC	Argerr
	LCHEX	37
	A=A-C	B

 ATH100	BSL	W
	B=A	P
	ASR	W
	ASR	W

	RTN

 Argerr	GOTO	argerr
 
**************************************************
* PEEK$
*
* But : executer la fonction standard PEEK$ en ne
*   tenant pas compte des protections
* Historique :
*   13/05/87 : PD    correction de PEEK$ "FFFFF"
*   18/12/88 : PD/JT reconception
**************************************************

	CON(1)	8	Num
	CON(1)	8+4	Num + String
	NIBHEX	22
=PEEKe
*
* Sauver D0 pour plus tard
*
	CD0EX
	R0=C		R0 := sauvegarde de D0
*
* Depiler le deuxieme argument, le nb de quartets
*
	GOSBVL	=RNDAHX	A(A) := deuxieme arg
	GONC	Argerr	negatif
	D1=D1+	16
	R2=A		R2 := nb de quartets
*
* Depiler le premier argument, qui est soit une
* chaine, soit un nombre indiquant une adresse.
*
	GOSUB	=POPADR	B(A) := adresse depilee
	A=B	A	A(A) := adresse depilee
	R3=A		R3 := adresse
*
* D1 est reactualise. Tout est donc depile.
*
	C=R2		C(A) := nb de quartets
	C=C+C	A	C(A) := nb de caracteres
	GOC	argerr

*
* Verifie qu'il y a assez de place sur la M.S. et
* ecrit le string-header
*
	GOSBVL	=STRHDR
*
* R1 = ^ string header on stack
* D1 = ^ past the string header (where string go)
*
	C=R2		C(A) := nb de quartets
	D=C	A	D(A) := compteur de boucle

	A=R3		A(A) := adresse depilee
	A=A+C	A	A(A) := dernier quartet
	D0=A		D0 := ^ adresse en cours

	GOTO	PEK020

 PEK010
*
* R1 = ^ string header on stack
* D1 = ^ string dans la M.S.
* D0 = ^ quartet precedent
*
	D0=D0-	1
	A=DAT0	1	A(0) := quartet
	C=0	S	nb de car. - 1 a convertir
	GOSBVL	=HEXASC

	DAT1=A	B
	D1=D1+	2

 PEK020	D=D-1	A
	GONC	PEK010

*
* Restauration de D1 et retour a Basic
*
	C=R0
	D0=C

	C=R1
	D1=C

	GOVLNG	=EXPR


**************************************************
* POPADR
*
* But: depiler un nombre ou une chaine, et
*   renvoyer ceci sous forme d'adresse, c'est a
*   dire d'un entier dans A(A).
* Entree:
*   - D1 = ^ sommet de la M.S.
* Sortie:
*   - B(A) = adresse depilee
*   - D1 reactualise
* Abime: A, B, C(A), D(A), D0, D1
* Appelle: POP1R, FLTDH, ADDRCK
* Niveaux: 3
* Historique:
*   18/12/88: PD/JT conception
**************************************************

=POPADR
	A=DAT1	S	Signature de l'element
	A=A+1	S	Chaine = F ==> Cy := 1
	GOC	POPstr

 POPnum	GOSBVL	=POP1R
	D1=D1+	16
	GOSBVL	=FLTDH
	B=A	A	resultat dans B(A)
	RTNC		Positive and in range
*
* Negative or not in range
*
 argerr	GOVLNG	=ARGERR

 POPstr	GOVLNG	=ADDRCK

	END
