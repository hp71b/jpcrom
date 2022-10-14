	TITLE  FORMALEX <format.as>

 flag	EQU    0
 boucle EQU    1
 caract EQU    2
 defaut EQU    0	pour SPACE$

**************************************************
 reduire
	SETHEX		HEX pour POP1S
	GOSBVL =POP1S
	CD0EX		C=pointeur programme
	GOSBVL =CSLC5	C=.......D0......
	CD1EX		C=.......D0 D1	 
	C=C+A  A	C=.......D0 (D1+long)
	R1=C		R1=...[D0][D1+A]
	D0=C		D0=^debut de la chaine
	D1=C		D1= idem
	D=0    A	D[A]=Nb d'emplacements (espaces de
	  *		la chaine reduite)
	ST=1   flag	Il faut enlever les blancs suivant
	ST=0   boucle	aucun passage dans la boucle
	ST=0   caract	Caractere non blanc non rencontre
	LCASC  ' '	C=' '
	B=C    B	B[B]=32 (espace)
 Enleve A=A-1  A	Longueur en quartets
	GOC    Fin	Saut si longueur nulle
	ST=1   boucle	au moins un passage dans la boucle
	A=A-1  A	quartets...
	D0=D0- 2	caractere suivant
	C=DAT0 B	Il est recopie dans C
	?C#B   B	est-ce un espace ?
	GOYES  noblan	non
	?ST=1  flag	Sinon, est-ce le premier d'une serie
	GOYES  Enleve	non, alors on le neglige
	D=D+1  A	oui: un emplacement supplementaire
	ST=1   flag	C'est le premier d'une serie
	GONC   ajoute	B.E.T.
 noblan ST=0   flag	Premier d'une serie: aucun sens,
	  *		puisque non blanc
	ST=1   caract	Au moins un caractere non blanc
	  *		dans la chaine
 ajoute D1=D1- 2	On range le caractere C[B] dans la
	DAT1=C B	chaine reduite	
	GONC   Enleve	B.E.T.

 Fin	?ST=0  flag
	GOYES  nonnul
	?ST=0  boucle
	GOYES  nonnul
	?ST=0  caract
	GOYES  nonnul
	D1=D1+ 2	Si le dernier caractere etait un
	  *		blanc, on l'enleve,
	D=D-1  A	ainsi que du nombre d'emplacements
 nonnul RTN
**************************************************

************************************************************
* SPACE$
************************************************************

	CON(1) 8	SPACE$(50)
	CON(1) 4+8	SPACE$(0,80), SPACE$("AREUH", 50)
	NIBHEX 12
=SPACEe
	ST=1   defaut	Cas par defaut : SPACE$(<n>)
	P=C    15	P := nb de parametres
	?P=    1
	GOYES  SPC010	Un seul parametre
	ST=0   defaut	Deux parametres, pas de defaut
*
* Valeur de la repetition
*
 SPC010 GOSBVL =RNDAHX	Repetitions
	GOC    SPC020	> 0
	A=0    A
 SPC020 R0=A		R0 := repetition
	D1=D1+ 16	D1 := ^ apres la repetition
*
* valeur par defaut ou chaine ou nombre
*
	?ST=0  defaut
	GOYES  SPC030	Regarder le parametre
	LCASC  ' '	espace par defaut
	GONC   SPC040
*
* Regarder le parametre
*
 SPC030 A=DAT1 S
	A=A+1  S
	GOC    SPC050	String
*
* C'est un nombre
*
	GOSBVL =RNDAHX
	C=A    B
	D1=D1+ 16	On passe le nombre
*
* C(B) = le caractere a repeter
*
 SPC040 D1=D1- 2
	DAT1=C B
	D1=D1+ 2	Chaine sur la M.S.
	A=0    A
	A=A+1  A	A(A) = 1 = longueur en octets
	GONC   SPC060	B.E.T.
*
* C'est une chaine
*
 SPC050 GOSBVL =POP1S
	CD1EX
	C=C+A  A
	D1=C		D1 := ^ debut de la chaine

	C=A    A
	A=0    W
	A=C    A
	ASRB		A(A) := longueur en octets

*
* A(A) = longueur de la chaine en octets
* D1 = ^ new top of stack
*     00000
*	|
*	|chaine
*	|------
*  D1-> |
*	|
*     FFFFF
*
 SPC060 R2=A		R2 := taille de la chaine

	CD1EX
	D1=C
	R1=C		Pour ADHEAD
	GOSBVL =D=AVMS

	CD0EX
	RSTK=C		Sauvegarde pour les boucles

	C=R0		B(A) := nombre de repetitions
	B=C    A
	GOTO   SPC100
*
* Boucle externe
*
 SPC070 A=R2		A(A) := taille de la chaine a copier
	C=R1
	D0=C		D0 := ^ 1er car. de chaine a copier
	GOTO   SPC090
*
* Boucle interne
*
 SPC080 D0=D0- 2
	C=DAT0 B
	GOSBVL =STKCHR
 SPC090 A=A-1  A
	GONC   SPC080

 SPC100 B=B-1  A	Nb de repetitions
	GONC   SPC070	Boucler tant que R0 > 0

	C=RSTK
	D0=C

	GOC    ret2	B.E.T.

************************************************************
* REDUCE$
************************************************************

	NIBHEX 411
=REDUCEe
	GOSUB  reduire	
 retour C=R1		C=....D0...
	GOSBVL =CSRC5	C=.......D0
	CD0EX		D0=pgm counter
 ret2	ST=0   0	ADHEAD ne rend pas la main
	GOSBVL =D=AVMS	
	GOVLNG =ADHEAD

 argerr GOVLNG =ARGERR

************************************************************
* CENTER$
************************************************************

	NIBHEX 8422
=CENTERe
	GOSUB  Argnum	Pop, test et convertit en HEXA le
	  *		parametre numerique.
	GOSBVL =REVPOP	"Pop", test et renverse la chaine
	  *		alphanumerique. En sortie de routine
	  *		D1 pointe apres l'en-tete de la
	  *		chaine.
	CD1EX
	D1=C
	C=C+A  A	C(A) = l'adresse de fin de chaine
	  *		(utilise plus loin par la routine
	  *		ADHEAD).
	R1=C		Sauvegarde dans R1 pour ADHEAD.
	GOSBVL =D=AVMS	D(A) = AVMEMS. L'operation
	  *		est faite maintenant car la routine
	  *		utilise C(A).
	C=R0		C(A) = parametre numerique.
	C=C+C  A	C(A) = parametre en quartets.
	GOC    argerr	En cas de depassement, l'argument
	  *		etait superieur a la
	  *		longueur maxi. d'une chaine: ERREUR
	?A=0   A	longueur nulle ?
	GOYES  FIN	Si oui: FIN.
	?C<=A  A	lg chaine >= longueur demandee ?
	GOYES  FIN	Si oui: on renvoit la chaine.
	C=C-A  A	Calcul du nombre de blancs:
	  *		C(A) = 4 fois le nb. de blc.
	A=0    M	) Division de C(A)
	A=C    A	) par 4
	ASRB		) et restitution dans A(A)
	ASRB		) en octets.
	
	LCASC  ' '
	GONC   test
 bsp	GOSBVL =STKCHR
 test	A=A-1  A
	GONC   bsp

 FIN	ST=1   0	Obligatoire pour un retour de ADHEAD
	GOSBVL =ADHEAD	En-tete de la nouvelle chaine.
	GOSBVL =REV$	On renverse a nouveau avant le
	GOVLNG =EXPR	retour a BASIC.

 Argnum GOSBVL =RNDAHX	A(A)=nombre hexa
	GONC   argerr	Argument Error si <0
	?A=0   A	Parametre nul
	GOYES  argerr	... alors Arg. Error
	D1=D1+ 16	POPer le parametre
	R0=A		et le mettre dans R0
	RTN

 memerr GOVLNG =MEMERR

************************************************************
* FORMAT$
************************************************************

	NIBHEX 8422
=FORMATe
	GOSUB  Argnum	A[A],R0[A]=nombre hexa
	GOSUB  reduire
	C=R1		C=......(^debut de la chaine)
	A=R0		A=parametre
	C=C-A  A
	GOC    memerr
	C=C-A  A	C=^fin de la chaine formattee
	GOC    memerr
	R2=C		R2=^fin de la chaine formattee
	A=C    A	Pour transfert ensuite dans D0
	D0=C		}
	D0=D0+ 16	}  +16 pour l'en-tete de la chaine
	GOC    memerr	} 
	CD0EX		}
	D0=(5) =AVMEMS
	AD0EX
	?C<=A  A	a-t-on depasse AVMEMS ?
	GOYES  memerr	non: pas d'erreur
	C=R1		C=^debut de la chaine
	A=0    W	}
	A=C    A	} A=00....000 ^debut
	CD1EX		C=^fin de la chaine reduite
	D1=C		D1= idem
	A=A-C  A	A=longueur reduite
	ASRB		... en octets
	C=R0		C=longueur formattee
	?A>C   A	erreur si long(red) > long(format)
	GOYES  strovf
	?A=C   A	Retour si chaine deja formattee...
	GOYES  retouR
	A=A+1  A	long(chaine reduite)
	?D=0   A	Peut-on mettre des blancs ?
	GOYES  retouR	non: la chaine reduite est renvoyee
	A=A-C  A
	A=-A   A
	C=D    A
	R3=C		R3= nb total d'emplacements
	GOSBVL =IDIVA	A/C
	P=     0	P=15 apres IDIVA
	  *		A: Quotient    B:C: Reste
	  *		Il faut mettre C fois	 A+1 blancs
	  *		et (le reste)  fois    A   blancs
	R0=C		R0 <- C
	B=A    A
	B=B+1  A
	GOSUB  rajout
	A=R0		A=longueur de la chaine formattee
	C=R3		C=nb total d'emplacements
	C=C-A  A	C=(le reste)
	B=B-1  A	(un espace en moins par boucle)
	GOSUB  rajout
	C=R2
	D1=C		pointeur de pile-math
 retouR GOTO   retour

 strovf LC(2)  37	String Overflow
	GOVLNG =MFERR

*************************************************
 rajout D=C    A	D=compteur.
	LCASC  ' '	C=' '
	GOTO   bool
 bb	A=DAT1 B	Recopier le dernier caractere de la
	D1=D1+ 2	chaine reduite
	DAT0=A B	dans la chaine formattee
	D0=D0+ 2
	?C#A   B	est-ce un espace ?
	GOYES  bb	non: on continue
	A=B    A	Boucle interne sur A
	GONC   b2	Elle est executee A fois
 recopie
	DAT0=C B	Un esp de plus ds la ch. formattee
	D0=D0+ 2
 b2	A=A-1  A
	GONC   recopie	On continue tant que A>=0
	D=D-1  A	Un emplacement de moins
 bool	?D#0   A	Est-ce le dernier emplacement ?
	GOYES  bb	Non, on continue
	RTN		Oui: retour a l'envoyeur

************************************************************
* CESURE
************************************************************

	NIBHEX 8422
=CESUREe
	GOSUB  Argnum	Retourne un HEXA dans A(A) et R0(A)
	B=A    A	Sauvegarde de la cesure dans B(A).
	GOSBVL =POP1S	on est bien en presence d'une chaine
	  *		et retourne sa longueur dans A(A).
	C=A    A	Division de A(A) par 2.
	A=0    M
	A=C    A
	ASRB
	CD1EX		C(A) ^ Debut de	 la chaine.
	D1=C
	C=C+A  A
	C=C+A  A
	D=C    A	D(A) = l'adresse de debut de chaine
	?A<B   A	La longueur de la chaine < cesure ?
	GOYES  FinC	Oui, on renvoie la chaine
	C=C-B  A	On place D1 sur le premier caractere
	C=C-B  A	concerne par la cesure
	D1=C
	LCASC  ');:,.!? '  les caracteres de comparaison
	ST=C		On met ST(0) a 0: flag
 Boucle A=DAT1 B	A(B)=caractere a comparer.
	?A=C   B	Est-ce un espace ?
	GOYES  TestP	Oui: on va en TestP pour comparaison
	  *		avec les autres caracteres de C(W)
	ST=1   flag	On a rencontre au moins un caractere
	  *		different d'un espace
 AutreB B=B-1  A	Decrement de la cesure
	GOC    Nobl	Reste-t-il encore des caracteres
	D1=D1+ 2	Oui, D1 sur le caractere suivant
	GONC   Boucle	B.E.T.
 Nobl	A=R0		A(A) = cesure 
	GOC    FinC	B.E.T.
 TestP	A=R0		A(A) = Valeur de la cesure
	?A=B   A	La position de l'espace est-elle
	  *		egale a la cesure ?
	GOYES  NotstP	Oui, on retourne chercher l'espace
	  *		suivant en decrementant la cesure
*
* Prend moinsde place que la routine interne MEMBER
*
	P=     7	Autrement test: P= compteur
	D1=D1- 2	D1 ^ le caractere suivant l'espace
	A=DAT1 B	A(B) = caractere a tester
 Bcl2	CSR    W	Decalage du registre C
	CSR    W
	?A=C   B	Le caractere est-il egal ?
	GOYES  Suite	Oui: on branche en "Suite"
	P=P-1		Decrementation du compteur
	GONC   Bcl2	reste des caracteres a tester dans C
	GOC    Decr	Il n'en reste plus
 NotstP ?ST=1  flag	A-t-on deja rencontre un caractere
	  *		different d'espace
	GOYES  AutreB	Oui: on ne decremente pas la cesure
	  *		(elle pointe ce caractere !)
	A=A-1  A	On decrement la cesure de 1
	R0=A		On replace la cesure dans R0
	GONC   AutreB	B.E.T. 
 Suite	C=R0		La position du blanc = cesure ?
	?B=C   A
	GOYES  Decr	Oui: on branche en fin de programme
	  *		directement
	B=B+1  A	Autrement on ajuste le resultat pour
	B=B+1  A	englober le caractere de ponctuation
 Decr	A=B    A	Passage de B(A) dans A(A) pour
	  *		l'appel de la routine FLTDH
	A=A-1  A	Decrement de A(A) pour etre juste
 FinC	C=D    A
	D1=C		D1 pointe le debut de la chaine.
	D1=D1- 16	D1-16 nous sommes pret a placer le
	  *		parametre numerique
	GOSBVL =HDFLT	Transformation de A(A) en un nombre
	  *		decimal dans A(W).
	C=A    W
	GOVLNG =FNRTN4	Retour a BASIC.

	END
