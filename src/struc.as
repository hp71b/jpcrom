	TITLE  STRUC2 <struc.as>
*
* JPC:A05
*   87/03/03: PD/JT Integration dans JPCLEX
*   87/03/04: PD/JT Correction de bug TRACE
* JPC:A06
*   87/05/12:	    Allocation du return type 9 par HP
* JPC:B02
*   87/08/02: PD/JT Correction de "10LOOP !  20END LOOP"
* JPC:B03
*   87/08/29: PD/JT Correction de "10SELECT 1! 20END SELECT"
*   87/08/29: PD/JT Correction de "10SELECT 1  15CASE 0 !
*			20END SELECT"
* JPC:D01
*   88/12/18: PD/JT Correction de "10SELECT .4
*			20CASE >.2@BEEP"
*   88/12/18: PD/JT Correction de "LEAVE !", "WHILE 0 !"
*   88/12/18: PD/JT Correction de "IF..!", "ELSE!"
*   88/12/18: PD/JT Ajout du parametre de LEAVE
*

=STRUCt EQU    9	Type de retour dans la GOSUB stack
*
* quartets de reconnaissance de :
*
=qENDL	EQU    0	END LOOP
=qENDS	EQU    1	END SELECT
=qENDI	EQU    2	END IF

 SAUVD0 EQU    =STMTD0
 CSETYP EQU    =S-R1-3	Type de l'objet (SELECT)

 chEW	EQU    0	cherche END WHILE
 chEL	EQU    1	ch. END LOOP
 chU	EQU    2	ch. UNTIL
 chEI	EQU    3	ch. END IF
 chES	EQU    4	ch. END SELECT
 chE|EI EQU    5	ch. ELSE ou END IF
 chC|ES EQU    6	ch. CASE ou END SELECT
 chEI-E EQU    7	ch. END IF, saute ELSE
 chES-C EQU    8	ch. END SELECT, saute CASE
 chL/EW EQU    9	LEAVE cherche END WHILE
 chL/EL EQU    10	LEAVE cherche END LOOP
 chL/U	EQU    11	LEAVE cherche UNTIL

* Predicats de test
 Pred<	EQU    %0001
 Pred=	EQU    %0010
 Pred>	EQU    %0100
 Pred?	EQU    %1000

	STITLE Exécution

**************************************************
* SELECT
*
* But: executer l'ordre SELECT
* Hstorique:
*   87/03/01: conception & codage
*   87/08/29: correction SELECT 1 !
*   87/08/29: correction SELECT 1 / CASE 0 ! / END
**************************************************

*
* tokenisation des structures SELECT / END SELECT
*
* tXWORD id tSELECT <exp. alpha ou num.>
*    tXWORD id tCASE tRELOP specifier <exp>
*    tXWORD id tCASE <exp>
*    tXWORD id tCASE <exp> tTO <exp>
*    tXWORD id tCASE		       (CASE ELSE)
* tXWORD id tEND2 qENDS
*

	REL(5) =SELECTd
	REL(5) =SELECTp
=SELECTe
	D0=D0- 6+2
	GOSUB  stoadr	SAUVD0 := ^ Stlen
	D0=D0+ 6+2
	GOSBVL =EXPEX-	Evaluer le SELECT
*
* A(W) := top 16 nib. of MS
*
	LCHEX  9	Legal BCD digit
	?A<=C  P
	GOYES  SL020	Real number
	LCHEX  0E	Complex number signature
	?A=C   B
	GOYES  SL020	Complex number
*
* Nous sommes dans le cas "string" ou autre...
*
 SL010
	GOSBVL =POP1S	Erreur si "autre..."
	GOSUB  stoMS	Proteger la chaine
	D0=(5) =STMTR0
	CD1EX		C(A) := ^ dernier caract.
	C=C+A  A	C(A) := ^ premier caract.
	DAT0=C A	S-R0-0 := ^ chaine
	D0=D0+ 5
	DAT0=A A	S-R0-1 := len en quartets
	C=0    S	Type := alpha
	GONC   SL030	B.E.T.
*
* Cas reel ou complexe
*
 SL020
	GOSUB  stoMS
	C=0    S
	C=C+1  S
*
* C(S) = type (0 = alpha / 1 = numerique)
* AVMEME = pointeur de M.S.
*
 SL030
	D0=(5) CSETYP
	DAT0=C S	CSETYP := type (alpha/num)

*
* Debut de la boucle de recherche de CASE ou
* END SELECT
*
 SL100
	GOSUB  recadr
	GOSUB  eol
	P=     chC|ES
	GOSUB  cherche
	GOSUB  stoadr	SAUVD0 := adresse trouvee
	D0=D0+ 6	D0 := ^ tCASE ou tEND2
	LC(2)  =tEND2
	A=DAT0 B
	?A=C   B
	GOYES  sl900	END SELECT seulement

	D0=D0+ 2	D0 := ^ apres tCASE

	A=DAT0 B
	GOSUB  eolxck
	GONC   SL150	Il y a quelque chose.
 sl900	GOTO   SL900	CASE ELSE
*
* D0 = ^ debut de ce qu'il y a a analyser
*
 SL150
*
* Il y a quelque chose a analyser
*
	LC(2)  =tRELOP
	?A#C   B
	GOYES  SL200	<exp> ou <exp> TO <exp>
*
* tRELOP specifier <exp>
*
	D1=(5) =S-R0-3
	D0=D0+ 2
	C=DAT0 S	C(S) :=specifier
	DAT1=C S	S-R0-3 := predicat
	D0=D0+ 1
	GOSUB  evalMS
	CD0EX
	D0=(5) =S-R0-3
	C=DAT0 S
	D0=C
	P=C    15
	GOSUB  compar
	GONC   SL300
	GOC    SL900	B.E.T.
*
* <exp>
* <exp> TO <exp>
*
 SL200
	GOSUB  evalMS
	A=DAT0 B
	LC(2)  =tTO
	?A=C   B
	GOYES  SL250
*
* <exp>
*
	P=     Pred=
	GOSUB  compar
	GONC   SL300
	GOC    SL900	B.E.T.
*
* <exp> TO <exp>
*
 SL250
	P=     (Pred>)+(Pred=)
	GOSUB  compar
	GONC   SL290
	D0=D0+ 2	On passe tTO
	GOSUB  evalMS
	P=     (Pred<)+(Pred=)
	GOSUB  compar
	GONC   SL300
	GOC    SL900	B.E.T.
 SL290
	D0=D0+ 2	On passe tTO
	GOSUB  evalMS	Evaluation de <exp2> sans
	  *		prendre le resultat
*
* Fin de l'evaluation. Si on est arrive jusqu'ici,
* toutes les conditions etaient fausses, 
*
 SL300
	A=DAT0 B
	LC(2)  =tCOMMA
	?A#C   B
	GOYES  sl100	c'est donc tEOL
	D0=D0+ 2	on passe la tCOMMA, et
	A=DAT0 B	on recommence
	GOTO   SL150
 sl100	GOTO   SL100
*
* Sortie et branchement. On a trouve :
* - une clause vraie, ou
* - CASE ELSE, ou
* - END SELECT
* Dans tous les cas, SAUVD0 = adresse de debut de
* la ligne (Stlen).
*
 SL900
	GOSUB  recadr
	GOTO   goeol

**************************************************
* compar
*
* But: comparer les deux objets au sommet de la
*   M.S. (pointe par D1).  Traite les
*   verifications de type (numerique / alpha).
* Entree:
*   - P = predicat de comparaison
*   - D1 = ^ objet2
*   - l'objet1 est sous l'objet2 sur la M.S.
*   - si CSETYP = 1 : type(objet1) = num
*   - si CSETYP = 0 : type(objet1) = alpha, et
*	S-R0-0 = adresse debut de objet1
*	S-R0-1 = longueur en quartets
* Sortie:
*   - Cy = 1 : vrai
*   - Cy = 0 : faux
* Abime: A-D, D1, R0-R3
* Appelle: uTEST, FPOLL, STRTST
* Niveaux: 4 (FPOLL + pCMPLX)
* Note: D0 est sauvegarde dans STMTD1
* Historique:
*   87/03/01: conception & codage
*   88/12/18: correction de la documentation
*   88/12/18: ajout du SETDEC avant uTEST
**************************************************

 s1=2	EQU    0
 s1>2	EQU    1

 compar
*
* Sauvegarde P dans C(S)
*
	C=P    15	C(S) := Predicat
	P=     0	Propre et net...
*
* Sauvegarde de D0
*
	CD0EX
	D0=(5) =STMTD1
	DAT0=C A

	D0=(5) CSETYP	Type de l'objet
	A=DAT0 S	A(S) := type de objet1
*
* CSETYP = 1 si objet = num
* CSETYP = 0 si objet = str
*
	A=A-1  S	Cy := 1 si (obj1 = str)
	GOC    cmpstr
*
* Comparaison numerique
*
 cmpnum
	R1=C		R1(S) := predicat
	GOSBVL =MPOP2N
*
* R0   = I(objet1)
* A(W) = R(objet1)
* R2   = I(objet2)
* C(W) = R(objet2)
*
	SETHEX
	GOC    cmpcmp	compare complex
	CR1EX
	P=C    15	P = predicat
	CR1EX
*
* Ajout du 18 decembre 1988 :
* Comme la documentation de HP ne l'indique pas,
* il faut un SETDEC avant l'appel de uTEST.
* Merci HP !
*
	SETDEC
	GOSBVL =uTEST
	SETHEX
	P=     0
	GOTO   cmpfin	et puis voila...

*
* Comparaison de complexes
*
 cmpcmp
*
* Pour le moment... on ne supporte pas les
* complexes.
*
	GOVLNG =CNFLCT	Conflict !!!
*
* Comparaison alphanumerique
*
 cmpstr
	D=C    S	D(S) := predicat de comp.
	GOSBVL =POP1S
	CD1EX		C(A) := ^ fin objet2
	C=C+A  A	C(A) := ^ debut objet2
	D1=C		D1 := ^ 2eme chaine
	D0=(5) =S-R0-1	D0 := ^ longueur objet1
	C=DAT0 A	C(A) := longueur objet1
	ST=0   s1>2	len1 < len2
	ST=0   s1=2	len1 # len2
	A=0    S
	?C=0   A	len1 = 0 ?
	GOYES  cmps00
	?A=0   A	len2 = 0 ?
	GOYES  add>	obj1 > ""
	?C#A   A
	GOYES  cmps10
	ST=1   s1=2	len1 = len2
	GONC   cmps20	B.E.T.
*
* Longueur de obj1 = 0
*
 cmps00
	?A=0   A
	GOYES  add=
	GONC   add<	B.E.T. (len1 < len2)

 cmps10 ?C<A   A	?len1 < len2
	GOYES  cmps20
	ST=1   s1>2	len1 > len2
	C=A    A
*
* C(A) = longueur min
* ST(s1>2) = 1 si (len1 > len2)
* ST(s1=2) = 1 si (len1 = len2)
* D0 = ^ obj1
* D1 = ^ obj2
*
 cmps20
	D0=D0- 5	D0=(5) =S-R0-0
	A=DAT0 A
	D0=A		D0 := ^ objet1
	GOSBVL =STRTST
	P=     0
	A=0    S	A(S):= predicat de sortie
	GOC    cmps50	Strings not equal
*
* Les chaines sont egales jusqu'au minimum des
* longueurs.
*
	?ST=0  s1=2
	GOYES  cmps30
 add=
	LC(1)  Pred=
	CSRC
	A=A!C  S
	GOTO   cmps90	goto Bilan

 cmps30 ?ST=1  s1>2
	GOYES  add>
 add<
	LC(1)  Pred<
	CSRC
	A=A!C  S
	GOTO   cmps90
*
* Les chaines ne sont pas egales.
*
 cmps50
	A=DAT0 B	A(B) := premier de objet1
	C=DAT1 B	C(B) := premier de objet2
	?A<C   B	obj1 < obj2
	GOYES  add<
 add>
	LC(1)  Pred>
	CSRC
	A=A!C  S

*
* Bilan :
*   A(S) = predicat en sortie
*   D(S) = predicat en entree
* 
 cmps90
	C=D    S
	A=A&C  S
	?A#0   S
	GOYES  cmpfin	Cy := 1
 cmpfin
*
* Restauration de D0 sans perturber la Cy
*
	D0=(5) =STMTD1
	C=DAT0 A
	D0=C
	RTN

**************************************************
* CASE
*
* But: executer l'ordre CASE
* Hstorique:
*   87/03/01: conception & codage
**************************************************

	REL(5) =CASEd
	REL(5) =CASEp
=CASEe
	D0=D0- 8
	GOSUB  eol
	P=     chES-C
	GOSUB  cherche
	GOTO   goeol

**************************************************
* LEAVE
*
* But: executer l'ordre LEAVE
* Hstorique:
*   87/03/01: conception & codage
*   88/12/18: correction de "10 LEAVE !"
*   88/12/18: ajout du parametre optionnel
**************************************************

 LVerr	GOVLNG =ARGERR

	REL(5) =LEAVEd
	REL(5) =LEAVEp
=LEAVEe
	D0=D0- 6+2	ajoute le 18 decembre 1988
	GOSUB  stoadr
	D0=D0+ 6+2
*
* Emprunt a PLF
*
	A=DAT0 B
	GOSBVL =EOLXCK
	A=0    A	A(A) := 0 par defaut
	GOC    LV020	Il n'y a pas d'expression
*
* Fin de l'emprunt a PLF
*
	GOSBVL =EXPEX-
	GOSBVL =RNDAHX
	GONC   LVerr
	A=A-1  A
	GOC    LVerr	"Invalid Arg" si = 0
 LV020	D1=(5) =STMTD1

 LV100	DAT1=A A	STMTD1 := nb de niveaux

	GOSBVL =POPUPD
	GOC    struce	Pile vide
	LC(1)  =STRUCt
	CSRC		C(S) := type de retour
	?D#C   S
	GOYES  struce
*
* Le type est reconnu. Quel est le token qu'il faut
* chercher ?
*
	C=D    A	C(A) := ^ apres le token
	D0=C
	D0=D0+ 4	D0 := ^ token
	A=DAT0 B
	GOSBVL =FINDA
	CON(2) =tWHILE
	REL(3) LV210
	CON(2) =tLOOP
	REL(3) LV220
	CON(2) =tREPEAT
	REL(3) LV230
	NIBHEX 00
 struce GOTO   STRUCe	"Structure Mismatch"

*
* REPEAT / UNTIL
*
 LV230	P=P+1
*
* LOOP / END LOOP
*
 LV220	P=P+1
*
* WHILE / END WHILE
*
 LV210
	C=P    0	C(0) := chX
	P=     0
	D=C    P	D(0) := chX
	LC(1)  (chL/EW)
	C=C+D  P	C(0) := chL/EW + P
	P=C    0	P := chL/EW, chL/EL, chL/U
	GOSUB  recadr
*
* D0 = ^ Stlen du statement courant
*
	GOSUB  eol	""
*
* D0 = ^ eol du statement courant
*
	GOSUB  cherche	Chercher la fin de struct.
*
* D0 = ^ Stlen du statement reconnu
*
	GOSUB  stoadr

	D1=(5) =STMTD1	nb de niveaux restant
	A=DAT1 A
	A=A-1  A
	GONC    LV100

*
* SAUVD0 = ^ Stlen du debut de la ligne courante
*
	GOSUB  recadr
	GOTO   goeol

**************************************************
* ENDe
*
* But: traiter les ordres END WHILE, END LOOP,
*   END SELECT et END IF
* Entree:
*   - D0 = ^ quartet de reconnaissance
* Sortie:
*   - voir chaque branche
* Utilise: voir chaque branche
* Abime: voir chaque branche
* Niveaux: voir chaque branche
* Historique:
*   87/02/27: reconception
**************************************************

	REL(5) =END2d
	REL(5) =END2p
=END2e
	A=DAT0 B	token suivant / quartet
	GOSUB  eolxck
	GOC    ENDWe	tEOL ==> END WHILE
*
* A(0) = quartet de reconnaissance
*
	LC(1)  =qENDL
	?A=C   P
	GOYES  ENDLe	END LOOP
	GONC   nxtstm	B.E.T.	END SELECT/IF

**************************************************
* ENDWe
*
* But: proceder a l'execution de END WHILE
* Historique:
*   87/02/27: reconception
*   87/08/02: correction de "10 WHILE 1 !"
**************************************************

 ENDWe
	LC(2)  =tWHILE
	GOSUB  pop
	GOSUB  eval	Cy := 0 si e=0
	GONC   nxtstm

	GOSUB  recadr	D0 := adresse depilee
	GOSUB  push
	GOTO   go

 nxtstm GOVLNG =NXTSTM

**************************************************
* ENDLe
*
* But: proceder a l'execution de END LOOP
* Historique:
*   87/02/27: reconception
*   87/08/02: correction de "10 LOOP !"
**************************************************

 ENDLe
	LC(2)  =tLOOP
	GOSUB  pop
	GOSUB  push
	GOTO   go

**************************************************
* WHILEe
*
* Executer le statement WHILE
* Entree:
*   - D0 = ^ expression a analyser
* Sortie:
*   par go ou NXTSTM
* Historique:
*   87/02/28: reconception & codage
*   88/12/18: correction de "10 WHILE 0 !"
**************************************************

*
* Tokenisation d'une boucle WHILE / END WHILE :
*
* tXWORD id tWHILE <exp>
*    <corps de la boucle>
* tWORD id tEND2
*
	REL(5) =WHILEd
	REL(5) =WHILEp
=WHILEe
	GOSUB  stoadr
	GOSUB  eval
	GONC   WHL10
*
* expression # 0 (vrai) : on continue en sequence
*
	GOSUB  recadr	D0 := ^ debut expression
	GOSUB  push
	GOTO   nxtstm
*
* expression = 0 (faux) : on cherche END WHILE
* (D0 = ^ apres la fin de l'expression)
*
 WHL10
	P=     chEW	chercher END WHILE
	GOSUB  recadr	ajoute le 18 decembre 1988
	D0=D0- 6+2	""
	GOSUB  eol	""
	GOSUB  cherche
	GOTO   goeol

**************************************************
* LOOP / REPEAT
*
* But: executer les ordres REPEAT et LOOP
* Entree:
* Sortie: par NXTSTM
* Appelle: push
* Historique:
*   87/02/28: conception & codage
**************************************************

*
* Tokenisation d'une boucle LOOP / END LOOP
*
* tWORD id tLOOP
*   <corps de la boucle>
* tXWORD id tEND2 qENDL
*

*
* Tokenisation d'une boucle REPEAT / UNTIL
*
* tXWORD id tREPEAT
*    <corps de la boucle>
* tXWORD id tUNTIL <exp>
*
	REL(5) =REPEATd
	REL(5) =REPEATp
=LOOPe
=REPEATe
	GOSUB  push
	GOTO   nxtstm

**************************************************
* UNTILe
*
* But: executer l'ordre UNTIL
* Entree:
*   - D0 = ^ debut de l'expression
* Sortie:
*   - par go ou nxtstm
* Appelle: pop, push, eval, recadr, eval
* Historique:
*   87/02/28: conception & codage
*   87/08/02: correction de "10 REPEAT !"
**************************************************

	REL(5) =UNTILd
	REL(5) =UNTILp
=UNTILe
*
* Sauver D0 pour eval
*
	CD0EX
	D0=(5) =STMTD1
	DAT0=C A	STMTD1 := ^ debut de l'exp
*
* Depiler l'adresse de retour et verifier REPEAT
*
	LC(2)  =tREPEAT
	GOSUB  pop
*
* Evaluer l'expression
*
	D0=(5) =STMTD1
	C=DAT0 A
	D0=C
	GOSUB  eval
	GOC    Nxtstm
*
* On boucle :
*
	GOSUB  recadr	D0 := ^ fin du REPEAT
	GOSUB  push
	GOTO   go	GOTO "fin du REPEAT"

 Nxtstm GOTO   nxtstm

**************************************************
* IF2
*
* But: executer l'ordre IF
* Hstorique:
*   87/03/01: conception & codage
*   88/12/18: correction de "10 IF X=0 THEN !"
**************************************************

*
* Tokenisation d'une structure IF / END IF
*
* tXWORD id tIF2 <exp>
*   <alternant si vrai>
* tXWORD id tELSE2
*   <alternant si faux>
* tXWORD id tEND2 qENDI
*
* ou encore :
*
* tXWORD id tIF2 <exp>
*   <alternant si vrai>
* tXWORD id tEND2 qENDI
*
	REL(5) =IF2d
	REL(5) =IF2p
=IF2e
	GOSUB  stoadr	ajoute le 18 decembre 1988
	GOSUB  eval
	GOC    Nxtstm
	P=     chE|EI
	GOSUB  recadr	ajoute le 18 decembre 1988
	D0=D0- 6+2	""
	GOSUB  eol	""
	GOSUB  cherche
	GOTO   goeol

**************************************************
* ELSE2
*
* But: executer l'ordre ELSE
* Hstorique:
*   87/03/01: conception & codage
*   88/12/18: correction de "10 ELSE !"
**************************************************

	REL(5) =ELSE2d
	REL(5) =ELSE2p
=ELSE2e
	P=     chEI
	D0=D0- 6+2	ajoute le 18 decembre 1988
	GOSUB  eol	""
	GOSUB  cherche
	GOTO   goeol

**************************************************
* STRUCe
*
* But: generer une erreur et retourner a Basic
* Entree: -
* Sortie: par BSERR
* Historique:
*   87/02/28: conception & codage
**************************************************

 STRUCe
	P=     0
	LC(4)  (=id)~(=eSTRUC)
	GOVLNG =BSERR

 eolxck GOVLNG =EOLXCK

**************************************************
* go, goeol
*
* But: revenir a Basic, en faisant un GOTO sur
*   le statement suivant D0 (go), ou sur le token
*   suivant la ligne dont la longueur est pointee
*   par D0 (goeol).
* Entree:
*   go :
*   - SAUVD0 = ^ fin du (tXWORD id tXXX) courant
*   goeol:
*   - D0 = ^ Stlen du debut de la ligne courante
* Sortie: par RUNRT1
* Algorithme:
*   si execution au clavier
*     alors
*	si adresse de destination n'est pas dans
*	   dans bSTMT
*	  alors "Structure Mismatch"
*	fin si
*   fin si
*   si trace
*     alors trace
*   fin si
*   RUNRT1
* Historique:
*   87/02/27: conception & codage
*   87/03/02: integration de goeol
*   87/03/04: correction du bug "trace"
*   87/08/02: modification de go, bug "10 LOOP !"
**************************************************

 go	GOSUB  recadr
	D0=D0- 6+2	6 : token, 2 : Stlen

 goeol	GOSUB  eol

*
* D(A) := D0
*
	CD0EX
	D0=C
	D=C    A
*
* si execution au clavier :
*
	?ST=1  =PgmRun
	GOYES  go10
	LC(3)  =bSTMT	Statement buffer (clavier)
	GOSBVL =IOFND0	D1 := ^ statement buffer
*
* Le buffer existe toujours. Du moins, on espere !
*
	CD1EX		C(A) := ^ buffer
	?D<C   A	dest < debut buffer ?
	GOYES  STRUCe
	C=C+A  A	C(A) := ^ fin buffer
	?D>C   A	dest > fin buffer ?
	GOYES  STRUCe
*
* trace ?
*
 go10
	?ST=0  =Trace
	GOYES  runrt1
*
* le mode TRACE est actif
*

*
* Ce qui suit est pompe dans trflck (#0FE18)
* (avec modificatio)
*
	?ST=0  =PgmRun
	GOYES  runrt1
	D1=(5) =TRACEM
	P=     0
	LCHEX  2
	A=DAT1 B
	A=A&C  P
	A=A-1  P
*
* Jusqu'au 4 mars 1987, l'absence de cette
* instruction declenchait abusivement le mode
* TRACE FLOW lors de l'execution d'une fonction de
* STRUCLEX
*
	GOC    runrt1
*
* Elle est toute petite, hein ?
*
	D1=(5) =CURRST
	C=DAT1 A
	D1=C
	D1=D1+ (=oFTYPh)-1
	A=DAT1 A
	ASR    A
	LC(5)  =fBASIC
	?A#C   A
	GOYES  runrt1
*
* code Taillandier inspire par les dieux d'HP
*
	CD0EX
	R2=C
	D0=C
*
* Est-on a la fin du fichier ?
*
	D1=(5) =CURREN
	A=DAT1 A	A(A) := CURREN
	C=C+1  A
	C=C+1  A	C(A) := ^ apres le tEOL
	?C>=A  A
	GOYES  runrt1
*
* On n'est pas hors du fichier. On peut tracer en
* toute quietude : le numero de ligne est valide.
*
	GOSBVL =TRFROM	partie FROM de trace
	C=R2
	D0=C
	GOSBVL =TRTO+	partie TO de trace
	A=R2
	D0=A		restaure D0 et fin
 runrt1 GOVLNG =RUNRT1

**************************************************
* eval
*
* But: evaluer l'expression pointee par D0, et
*   renvoyer le resultat sous forme booleenne (Cy)
* Entree:
*   - D0 = ^ expression tokenisee
* Sortie:
*   - P = 0
*   - D0 = ^ apres l'expression tokenisee
*   - Cy = 0 : expression = 0
*   - Cy # 0 : expression # 0
* Appelle: EXPEX-, MPOP1N
* Niveaux: 5 (EXPEX-)
* Abime: A-D, D0, D1, R0-R4, FUNCtion scratch
* Historique:
*   87/02/27: ajout de documentation
*   87/02/27: clarification du code
**************************************************

 eval	GOSBVL =EXPEX-	vide la M.S.
	GOSBVL =MPOP1N	depile le nombre (C ou R)
	SETHEX
	A=0    S	ne prend pas le signe (-0)
	GONC   eval10	nombre reel
*
* nombre complexe
*
	?A#0   W
	RTNYES
	A=R0
	A=0    S
 eval10 ?A#0   W
	RTNYES
	RTN

**************************************************
* push
*
* But: mettre D0 dans la pile des GOSUB.
* Entree:
*   - D0 = valeur a empiler
* Sortie:
*   - D0 = valeur en entree
* Appelle: PSHGSB
* Niveaux: 4 (PSHGSB)
* Abime: A-D, D1
* Historique:
*   87/02/27: conception & codage
**************************************************

 push
	LC(1)  =STRUCt	C(0) := type de l'adresse
	CSRC		C(S) := return type
	D0=D0- 6	D0 := ^ token
	AD0EX		A(A) := adresse du token
	GOSBVL =PSHGSB
	CSRC		C(A) := adresse empilee
	D0=C		D0 := ^ adresse du token
	D0=D0+ 6	D0 := adresse en entree
	RTN

**************************************************
* pop
*
* But: depile une adresse sur la GOSUB stack,
*   verifie le type de l'adresse (tSTRUC), pointe
*   D0 a cette adresse et verifie que le token
*   pointe est le meme que C(B).
* Entree:
*   - C(B) = token a verifier (2 q. seulement)
* Sortie:
*   - D0 = ^ adresse depilee (passe le token)
* Appelle: POPUPD
* Niveaux: 2 (POPUPD)
* Utilise: A-D, D0, D1, R0
* Detail:
*   si type de l'adresse # tSTRUC
*     alors "Structure Mismatch"
*   si token pointe n'est pas bon
*     alors "Structure Mismatch"
* Historique:
*   87/02/27: conception & codage
**************************************************

 pop
	R0=C		R0(B) := token a verifier
	GOSBVL =POPUPD
	GOC    STRUce	pile vide
	LC(1)  =STRUCt	type de retour
	CSRC		C(S) := STRUCt
	?D#C   S	ce qui est depile ne nous
	GOYES  STRUce	  appartient pas...
*
* le type est reconnu, c'est a nous. Est-ce qu'on
* pointe sur la bonne structure ?
*
	C=D    A
	D0=C		D0 := ^ adresse de retour
	A=0    W
	A=DAT0 6	A(W) := token lu
	D0=D0+ 6	D0 := ^ apres le token

	GOSUB  stoadr	SAUVD0 := D0 + 6

	C=R0		C(B) := token
	B=C    B	B(B) := token
	C=0    W
	C=B    B	C(W) := token
	CSL    W
	CSL    W
	CSL    W
	CSL    W	C(5-4) := token
	LC(4)  (=id)~(=tXWORD)
	?A=C   W
	RTNYES		Tokens identiques : OK
 STRUce GOTO   STRUCe

**************************************************
* recadr
*
* But: restaurer dans D0 l'adresse sauvee par pop.
* Entree: -
* Sortie:
*   - D0 = adresse sauvee par pop
* Niveaux: 0
* Abime: C(A), D0
* Historique:
*   87/02/28: conception & codage
**************************************************

 recadr
	D0=(5) SAUVD0
	C=DAT0 A
	D0=C
	RTN

**************************************************
* stoadr
*
* But: sauver D0 dans SAUVD0
* Entree:
*   - D0 = valeur a sauver
* Sortie:
*   - D0 inchange
* Niveaux: 0
* Abime: C(A)
* Historique:
*   87/02/28: conception & codage
**************************************************

 stoadr
	CD0EX
	D0=(5) SAUVD0
	DAT0=C A
	D0=C
	RTN

**************************************************
* stoMS
*
* But: sauver D1 dans LDCSPC
* Entree:
*   - D1 = valeur a sauver
* Sortie:
*   - D0 inchange
* Niveaux: 0
* Abime: C(A)
* Historique:
*   87/03/01: conception & pompage sur stoadr
**************************************************

 stoMS
	CD1EX
	D1=(5) =LDCSPC
	DAT1=C A
	D1=C
	RTN

**************************************************
* evalMS
*
* But: Evaluer l'expression pointee par D0, et la
*   ranger dans la pile a l'adresse contenue dans
*   LDCSPC.
* Entree:
*   - D0 = ^ debut de l'exp. tokenisee
*   - LDCSPC = ^ M.S.
* Sortie:
*   - D0 = ^ apres l'expression (token non util.)
*   - D1 = ^ M.S.
*   - A(W) = 16 quartets au sommet de la M.S.
* Niveaux: 5
* Abime: A-D, R0-R4, ST, D0, D1, FUNC scratch
* Historique:
*   87/03/01: conception & codage
*   87/03/02: modification pour integration EXPEXC
**************************************************

 evalMS
	D1=(5) =LDCSPC
	C=DAT1 A
	D1=(4) =MTHSTK
	DAT1=C A
	GOVLNG =EXPEXC

**************************************************
* eol
*
* But: calculer l'adresse de la fin du statement
*   courant (adresse de tEOL ou t@) connaissant
*   l'adresse du debut de la ligne (^ Stlen).
* Entree:
*   - D0 = ^ longueur de la ligne (Stlen)
* Sortie:
*   - D0 = ^ t@ ou tEOL ou...
* Abime: A(A), C(A), D0
* Historique:
*   87/03/01: extraction de "goeol"
**************************************************

 eol
	A=0    A
	A=DAT0 B	A(B) := longueur
	CD0EX		C(A) := ^ longueur
	C=C+A  A	C(A) := ^ fin de la ligne
	D0=C
	RTN

 STRuce GOTO   STRUCe

**************************************************
* cherche
*
* But: chercher pour l'objet specifie par P
* Entree:
*   - P = quartet de recherche
*      chEW   : chercher END WHILE
*      chEL   : END LOOP
*      chU    : UNTIL
*      chEI   : END IF
*      chES   : END SELECT
*      chE|EI : ELSE ou END IF
*      chC|ES : CASE ou END SELECT
*      chEI-E : END IF, autorise ELSE
*      chES-C : END SELECT, autorise CASE
*      chL/EW : END WHILE, autorise (*)
*      chL/EL : END LOOP, autorise (*)
*      chL/U  : UNTIL, autorise (*)
*      (*) = CASE, ELSE, END SELECT, END IF
*   - D0 = tEOL ou t@ du statement courant
* Sortie:
*   si l'objet a ete trouve
*   - D0 = ^ Stlen du statement reconnu
* Abime: A-D, D0, D1, P, SAUVD0
* Niveaux: 
* Appelle: chpush, chpop, FINDA, TBLJMC, stoadr,
*   recadr, TKSCN7
* Historique:
*   87/03/01: conception & codage
**************************************************

*
* Version recursive :
*
* SUB cherche (P)
*   T1$ = premier token a chercher (selon P)
*   T2$ = deuxieme token a chercher (si il y a)
*   LOOP
*     TKSCN7
*     SELECT XWORD
*	CASE "LOOP","WHILE","REPEAT","SELECT","IF"
*	  P= "ch" & (token final correspondant)
*	  CALL cherche (P)
*	CASE T1$, T2$
*	  LEAVE
*	CASE "END WHILE/LOOP/SELECT/IF","UNTIL",
*	       "CASE","ELSE"
*	  "Structure Mismatch"
*     END SELECT
*   END LOOP
* END SUB
*

*
* Version derecursivee :
*
* cherche:
* initialiser la pile
* cher:
*   T1$ = premier token a chercher (selon P)
*   T2$ = deuxieme token a chercher (si il y a)
*   TKNSCN7
*   LOOP
*     SELECT XWORD
*	CASE "LOOP","WHILE","REPEAT","SELECT","IF"
*	  PUSH P
*	  Avancer sur la fin de la ligne
*	  P= "ch" & (token final correspondant)
*	  GOTO cher (Arghhhhhhh !)
*	CASE T1$, T2$
*	  IF pile_vide THEN GOTO sortie
*	  Avancer sur la fin de la ligne
*	  POP P
*	  GOTO cher (Arghhhhhhh !)
*	CASE "END WHILE/LOOP/SELECT/IF","UNTIL",
*	     "CASE","ELSE"
*	  "Structure Mismatch"
*     END SELECT
*   END LOOP
* Sortie:
*

*
* Zones memoires utilisees :
*
* AVMEME : pour voir si on ne depasse pas les
* limites de la memoire du HP-71.
* OUTBS : bas de la pile
* AVMEMS : sommet de la pile
*
 SP	EQU    =AVMEMS
 BP	EQU    =OUTBS
 Pvar	EQU    =S-R0-3

 cherche
	C=P    15	C(S) := chX
	P=     0
	GOSBVL =OBCOLL	initialiser la pile
* OBCOLL n'a pas modifie D0
	P=C    15	P := chX
 cher
	C=P    0	C(0) := quartet de rech.
	P=     0	Ouf !
	D1=(5) Pvar
	DAT1=C P	Pvar := quartet de rech.
 che010
*
* adresse de la fin d'analyse :
*
	D1=(5) =PRGMEN
	C=DAT1 A	C(A) := PRGMEN par defaut
	?ST=1  =PgmRun
	GOYES  che020
*
* On cherche dans le buffer bSTMT
*
	LC(3)  =bSTMT
	GOSBVL =IOFND0
	CD1EX
	C=C+A  A
 che020
	D=C    A
*
* On cherche le token tXWORD :
*
	LC(2)  =tXWORD
	GOSBVL =TKSCN7
*
* Cy = 0 : non trouve : "Structure Mismatch"
* Cy = 1 : trouve. Les ennuis commencent...
*
	GONC   STRuce	"Structure Mismatch"
*
* Sauvegarde de l'adresse de tXWORD
*
	GOSUB  stoadr	SAUVD0 := ^ tXWORD
*
* Dans SAUVD0, nous avons :
*
* Stlen tXWORD id tTOKEN
*	^
*	SAUVD0
*
	D0=D0+ 2	D0 := ^ id
*
* tXWORD id tTOKEN
*	 ^
*	 D0
*
	A=DAT0 B	A(B) := id trouve
	LC(2)  =id	C(B) := NOTRE id
	?A=C   B
	GOYES  che022
	GOTO   che900	EOL(D0-2) ; GOTO cher10
 che022
*
* C'est notre id
*
	D0=D0+ 2	D0 := ^ TOKEN
*
* tXWORD id tTOKEN
*	    ^
*	    D0
*
	A=DAT0 B	A(B) := token
*
* Est-ce un token de structure ?
* (WHILE, LOOP, REPEAT, SELECT, IF, END, UNTIL,
*  CASE et ELSE)
*
	LC(2)  =tEND2
	?A=C   B
	GOYES  che025
*
* On pourrait aller directement au TBLJMC, mais ca
* nuit a la lisibilite et a la maintenabilite.
* Vive la programmation structuree !
*
	NIBHEX 3	LC
	CON(1) 2*8-1	  (15)
	CON(2) =tWHILE
	CON(2) =tLOOP
	CON(2) =tREPEAT
	CON(2) =tSELECT
	CON(2) =tIF2
	CON(2) =tUNTIL
	CON(2) =tCASE
	CON(2) =tELSE2
	P=     2*8-1
	GOSBVL =MEMBER
	GOC    che900	Byte not in set
 che025
*
* Est-ce un debut de structure ?
*
	GOSBVL =FINDA
	CON(2) =tWHILE
	REL(3) che200
	CON(2) =tLOOP
	REL(3) che210
	CON(2) =tREPEAT
	REL(3) che220
	CON(2) =tIF2
	REL(3) che230
	CON(2) =tSELECT
	REL(3) che240
	CON(2) 00
*
* Non. Va-t-on trouver ce qu'on cherche ?
*
	D1=(5) Pvar
	C=DAT1 P
 che099
	GOSBVL =TBLJMC
	REL(3) che100
	REL(3) che110
	REL(3) che120
	REL(3) che130
	REL(3) che140
	REL(3) che150
	REL(3) che160
	REL(3) che170
	REL(3) che180
	REL(3) che190
	REL(3) che1a0
	REL(3) che1b0
*
* "WHILE", "LOOP", "UNTIL", "IF", "SELECT"
*
 che240 P=     chES-C	END SELECT, sans CASE
	GOTO   che200
 che230 P=     chEI-E	END IF, sans ELSE
	GOTO   che200
 che220 P=P+1
 che210 P=P+1
 che200
*
* P = nouveau quartet de recherche
*
	C=P    15	C(S) := nouveau quartet
	P=     0
	GOSUB  chpush	empiler le courant

	D1=(5) Pvar
	DAT1=C S

*
* ATTENTION : le code continue !!!
*
 che900
	GOSUB  recadr
	D0=D0- 2
	GOSUB  eol
	GOTO   che010

*
* chercher END WHILE
*
 che100
	GOSUB  recadr
	D0=D0+ 6	D0 := ^ q. de reconnais.
*
* tXWORD id tEND qENDx tEOL ou encore
* tXWORD id tEND tEOL
*		 ^
*		 D0
*
	A=DAT0 B
	GOSUB  eolxck
	GONC   Struce	"Structure Mismatch"
	GOTO   che300	B.E.T. a fin
*
* chercher UNTIL
*
 che120
	LC(2)  =tUNTIL
	GOSUB  che400
	GOC    che299	Trouve
 Struce GOTO   STRUCe	Non trouve
*
* chercher ELSE ou END IF
*
 che150
	LC(2)  =tELSE2
	GOSUB  che400
	GOC    che299	Trouve
	P=     =qENDI	Non. Chercher END IF
	GOTO   che110	B.E.T.
*
* chercher CASE ou END SELECT
*
 che299 GOTO   che300

 che160
	LC(2)  =tCASE
	GOSUB  che400
	GOC    che299	Trouve
	P=     =qENDS	Non. Chercher END SELECT
	GONC   che110	B.E.T.

* chercher END WHILE, mais pas CASE, ELSE,
* END SELECT, END IF
*
 che1b0 P=P+1
 che1a0 P=P+1
 che190
	C=P    15
	P=     0
	D=C    S	D(S) := chEW, chEL ou chU
	A=DAT0 B
	LC(4)  (=tCASE)~(=tELSE2)
	P=     2*2-1
	GOSBVL =MEMBER
	GONC   che175	Trouve : on recommence
	LC(2)  =tEND2
	?A#C   B
	GOYES  che195
*
* tEND2 trouve : est-ce END SELECT ou END IF ?
*
	D0=D0+ 2
	A=DAT0 P
	LC(1)  =qENDS
	?A=C   P
	GOYES  che175	Trouve, on recommence
	LC(1)  =qENDI
	?A=C   P
	GOYES  che175	Trouve, on recommence
 che195
	C=D    S
	CSLC		C(0) := quartet de rech.
	GOTO   che099	ch. END WHILE/LOOP/UNTIL
*
* chercher END SELECT, mais pas CASE
*
 che180
	LC(2)  =tCASE
	GOSUB  che400
	GOC    che175	On repart pour une rech.
	P=     =qENDS
	GONC   che110	B.E.T.

 che175
	GOSUB  recadr
	D0=D0- 2
	GOSUB  eol
	GOTO   che010	C'est reparti comme en 14
*
* chercher END IF, mais pas ELSE
*
 che170
	LC(2)  =tELSE2
	GOSUB  che400
	GOC    che175	On repart pour une rech.

*
* ATTENTION : le code continue !!!
*

*
* chercher END IF
*
 che130
	P=P+1
*
* chercher END SELECT
*
 che140
	P=P+1
*
* chercher END LOOP
*
 che110
*
* tXWORD id tEND qENDx tEOL ou encore
* tXWORD id tEND tEOL
*
	C=P    15	C(S) := qENDx
	P=     0
	GOSUB  recadr
	D0=D0+ 6	D0 := ^ qENDx ou tEOL
	A=DAT0 B
	GOSUB  eolxck
	GOC    STruce	tEOL... ==> END WHILE
*
* A(B) = token lu
*
	CSLC		C(0) = qENDx
	?A#C   P
	GOYES  STruce
*
* ATTENTION : le code continue !!!
*

*
* Si la pile est vide
*   alors
*     sortir
*   sinon
*     eol
*     chpop
*     goto che010
* fin si
*
 che300
	GOSUB  recadr
	D0=D0- 2	D0 := ^ Stlen
	GOSUB  chpop
	RTNC		Sortie sur pile vide
	GOSUB  eol
	GOTO   che010

 STruce GOTO   STRUCe

*
* Est-ce le token C(B) ?
*
 che400
	A=DAT0 B
	?A=C   B
	RTNYES		Cy := 1
	RTN		Cy := 0

**************************************************
* chpush
*
* But: empiler les tokens courants (T1$, et T2$)
*   sur la pile de recherche.
* Entree:
*   - P = 0
*   - Pvar = recherche courante
*   - AVMEME = limite sup. de la memoire dispon.
*   - SP = sommet de la pile de recherche
* Sortie:
*   - si pas assez de place : memerr
*   - SP reactualise
* Abime: A(A), C(A), D1
* Appelle: D1=AVE
* Niveaux: 1
* Historique:
*   87/03/01: conception & codage
**************************************************

 chpush
	D1=(5) SP
	A=DAT1 A	A(A) := SP
	A=A+1  A	A(A) := SP + 1
	DAT1=A A	Sp := SP + 1
	GOSBVL =D1=AVE	C(A) := (AVMEME)
	?A>=C  A
	GOYES  memerr
	D1=(5) Pvar
	C=DAT1 P	C(0) := Pvar
	D1=A		D1 := SP + 1
	D1=D1- 1
	DAT1=C P	empiler Pvar
	RTN

 memerr
	GOVLNG =MEMERR

**************************************************
* chpop
*
* But: depiler les tokens au sommet de la pile de
*    recherche, et les mettre dans les tokens
*    courants.
* Entree:
*   - P = 0
*   - BP = bas de la pile
*   - SP = sommet de la pile de recherche
* Sortie:
*   - Cy = 0 : pile non vide
*      - SP reactualise
*      - Pvar, C(0) = recherche courante
*   - Cy = 1 : la pile etait vide
* Abime: A(A), C(A), D1
* Niveaux: 0
* Historique:
*   87/03/01: conception & codage
**************************************************

 chpop
	D1=(5) BP
	C=DAT1 A	C(A) := bas de la pile
	D1=D1+ 5	D1=(5) SP
	A=DAT1 A	A(A) := sommet de la pile
	?A=C   A	pile vide ?
	RTNYES		oui : Cy := 1
	A=A-1  A
	DAT1=A A	nouveau SP
	D1=A		D1 = SP
	C=DAT1 P	C(0) := valeur depilee
	D1=(5) Pvar
	DAT1=C P	Pvar := valeur depilee
	RTN		Cy = 0 (A=A-1)

	END
