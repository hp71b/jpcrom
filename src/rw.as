	TITLE	RWLEX <rw.as>

 Attn	EQU    12
 CHKMAS EQU    #425C
 DEVPAR EQU    #1BF0
 GETERR EQU    #6791
 GETMBX EQU    #3B62
 GETPIL EQU    #6E0B
 READR# EQU    #44FF
 WRITE# EQU    #453F
 eABORT EQU    4
 eNODEF EQU    3
 ePIL	EQU    2
 eTAPE	EQU    1
 reclen EQU    512
 sSTK	EQU    7

**************************************************
* W R E C
**************************************************

 ERReur GOTO   erreur

	REL(5) =WRECd
	REL(5) =WRECp
 
=WRECe	GOSBVL =EXPEX-	) Depose les 2 premiers
	D0=D0+ 2	) parametres
	GOSBVL =EXPEXC	) de l'ordre
	D0=D0+ 2	) WREC sur la M.S.
	CD1EX
	RSTK=C
	ST=0   sSTK
	GOSUBL =JUMPER
	CON(5) GETPIL
	GOC    ERReur
	C=RSTK
	D1=C		D1 M.S.
	GOSUBL =JUMPER
	CON(5) GETMBX
	GOSUB  VERT10	Verification de la presence
	 *		de la memoire de masse sur
	 *		la boucle.
	A=R0		) Mise en place de D1 sur 
	D1=A		) le deuxieme parametre de
	 *		) l'ordre WREC 
	C=D    A	Sauvegarde de l'adresse de
	RSTK=C		la memoire de masse dans
	 *		la pile de retour
	A=DAT1 B
	LC(2)  15
	?A#C   B
	GOYES  rndahx
	GOSBVL =ADDRCK	Verification de la validite
	 *		de l'adresse (2e param.)
	C=B    A
	GOC    EXEC00
 rndahx GOSBVL =RNDAHX
	GONC   ivarg
	D1=D1+ 16
	C=A    A
 EXEC00 RSTK=C		) adresse dans la pile de
	 *		) retour
	GOSBVL =REVPOP	Renversement de la chaine 
	 *		sur la Mathstack.
	C=0    A	) La longueur de la chaine
	LC(3)  reclen	) est-elle de 256 octets ?
	?A#C   A
	GOYES  ivarg	Si non => ERREUR
	C=RSTK		) Restitution de l'adresse
	A=C    A	) de l'enregist. dans A(A)
	C=RSTK		) Mise en place de
	 *		) l'adresse de la memoire
	D=C    A	) de masse dans D(X).
	 *
	GOSUBL =JUMPER	    *******************
	CON(5) WRITE#	    * E C R I T U R E *
	 *		    *******************
	GOC    erreur	Au retour de la
	 *		routine, si Cy=1,
	 *		nous sommes en presence
	 *		d'une erreur.
	GOSBVL =COLLAP	Remise en place de MTHSTK
	GOVLNG =NXTSTM	BASIC continu
 
 ivarg	GOVLNG =ARGERR
 
**************************************************
* La routine VERTAP verifie si le parametre 
* pointe par D1 correspond bien a une memoire
* de masse d'identificateur appareil 16.
**************************************************
 
 Dvnfnd P=     ePIL	Classe d'erreur 32 a 47
	C=0    A	Erreur 32.
	GOC    erreur	B.E.T.
 
 VERTAP GOSUBL =JUMPER
	CON(5) DEVPAR	Routine d'analyse du
	 *		specificateur d' appareil
	 *		de la fonction. En sortie
	 *		D1 ^ Math Stack - 16 pour
	 *		un parametre numerique.
	GOC    erreur	Si carry: ERREUR
 VERT10 ?D=0   X	D[X] contient l'adresse du
	 *		peripherique. Si D[X] = 0,
	GOYES  Dvnfnd	le peripherique n'est pas  
	 *		present. On renvoie
	 *		"Device Not Found"
	CD1EX		) Sauvegarde de D1 dans R0
	 *		) pour le retour
	R0=C		) a BASIC (fin).
	GOSUBL =JUMPER	Verification de l'AID du
	CON(5) CHKMAS	peripherique (16).
	RTNNC		Cy=0 : OK, Cy=1 : ERREUR
 
**************************************************
* Traitement des erreurs HPIL. P indique la 
* classe d'erreur (memoire de masse... etc.) et
* C[0] le numero de l'erreur. Le retour a la 
* main loop se fait via BSERR.
**************************************************
 
=erreur
 erreur
	?P=    eTAPE
	GOYES  ERROR1
	?P=    ePIL
	GOYES  ERROR1
	?P#    eABORT
	GOYES  ERROR0
	GOSUBL =JUMPER
	CON(5) GETMBX
	GOSUB  atnchk
	GOC    ERROR0
	GOSUBL =JUMPER
	CON(5) GETERR
	GONC   ERROR-
	?P#    eABORT
	GOYES  ERROR1
 ERROR- P=     eABORT
 ERROR0 C=P    0
	P=     eNODEF
 ERROR1 C=P    1
	P=     2
	LCHEX  FF
	A=C    A
	P=     0
	GOVLNG =BSERR	Envoyez l'erreur !
 
 Erreur GOC    erreur	Ralonge
 
**************************************************
* R R E C $
**************************************************
 
	NIBHEX CC22	Alpha ou un numerique pour
	 *		les deux parametres.
=RRECe	CD0EX		) Sauvegarde de D0 dans
	RSTK=C		) la pile de retour
	GOSUB  r<rstk	Sauvegarde de 5 niveaux
	GOSUB  VERTAP	Verification mem. de masse
	A=R0		R0 = MS-16
	D1=A
	D1=D1+ 16
	C=D    A	) D[X] = device address
	RSTK=C		) RSTK = D[X]
	A=DAT1 B	L'adresse est-elle
	LC(2)  15	donnee sous forme de
	?A#C   B	chaine ?
	GOYES  rndah2	Non => RNDAHX
	GOSBVL =ADDRCK	Verification validite
	GOC    EXEC10
 rndah2 GOSBVL =RNDAHX
	GONC   Ivarg
	D1=D1+ 16
	B=A    A
 EXEC10 AD1EX
	C=0    A
	LC(3)  (reclen)+16  ( 210H = 528D
	 *		   (Soit la longueur de
	 *		  ( l'enregistrement plus
	 *		 ( 16 quartets d'en-tete)
	A=A-C  A	A[A] = MS-528
	GOSBVL =D=AVMS
	C=A    A	C[A] = AVMEMS
	?C<D   A	Y a-t-il assez de mem. ?
	GOYES  memerr	Non: Erreur 
	R1=C		Sauvegarde de MS-528
	D1=C		D1 = Math Stack - 512
	D1=D1+ 16
	A=B    A	A[A] = # enreg. a lire
	C=RSTK		) Restitution de
	D=C    A	) dev. add. dans D[X]
	 *
	GOSUBL =JUMPER	    *****************
	CON(5) READR#	   * L E C T U R E *
	 *		   *****************
	GOC    Erreur
	A=R1		A[A] = MS-528
	D1=A
	C=0    W	) construction e l'en-tete
	 *		) de la chaine avant le 
	 *		) retour a BASIC
	LCHEX  2000F	) C(W)= 000000000002000F
	DAT1=C W	O.K.
	AD1EX
	R1=A
	P=     4	) Restitution de 5 niveaux
	GOSBVL =RSTK<R	) de pile
	C=RSTK		) puis de
	D0=C		) D0  (4 niveaux & PC)
	C=R1		Restitution pointeur
	D1=C		D1 = MS+528
	GOSBVL =REV$
	GOVLNG =EXPR
 
 Ivarg	GOTO   ivarg
 
 memerr GOVLNG =MEMERR
 
**************************************************
* ROUTINE R<RSTK
* Cette routine sauvegarde 5 niveaux de pile
**************************************************
 
 r<rstk P=     4
	GOVLNG =R<RSTK	I N D I S P E N S A B L E !
	 *		Pour l'execution d'une
	 *		fonction faisant appel a
	 *		des routines HPIL
 
**************************************************
* ROUTINE ATNCHK
* Cette routine a ete pompee dans les IDS V, elle
* n'est pas supportee. Elle permet la sortie
* de l'erreur Aborted lorsque l'on arrete l'execu-
* tion des routines HPIL en appuyant deux fois sur
* la touche ATTN.
**************************************************
 
 atnchk ?ST=0  Attn
	GOYES  ATNCHc
	RSTK=C
	CD0EX
	D0=(5) =ATNFLG
	C=DAT0 S
	D0=C
	C=RSTK
	?C=0   S
	GOYES  ATNCHc
	C=C+1  S
	GOC    ATNCHc
	P=     eABORT
	RTNSC
 
 ATNCHc RTNCC
 
	END
