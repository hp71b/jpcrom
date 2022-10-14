	TITLE  MAXM, MAXD, MEMM, MEMD <mm.as>
*
* JPC:A06
*   87/05/07: PD/MM Elimination code avec rwlex et krislex
*

 DEVPAR EQU    #1BF0
 ENDTAP EQU    #44D9
 Flg	EQU    11
 CHKMAS EQU    #425C
 GDIRST EQU    #4843
 READR# EQU    #44FF
 ePIL	EQU    2
 memflg EQU    10

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
	 *		D[X] contient l'adresse du
	?D=0   X	peripherique. Si D[X] = 0,
	GOYES  Dvnfnd	le peripherique n'est pas  
	 *		present. On renvoie
	 *		"Device Not Found"
	CD1EX		) Sauvegarde de D1 pour
	R0=C		) le retour a BASIC (fin).
	GOSUBL =JUMPER	Verification de l'AID du
	CON(5) CHKMAS	peripherique (16).
	RTNNC		Cy=0 : OK, Cy=1 : ERREUR

**************************************************
* Traitement des erreurs HPIL. P indique la 
* classe d'erreur (memoire de masse... etc.) et
* C[0] le numero de l'erreur. Le retour a la 
* main loop se fait via BSERR.
**************************************************

 erreur
	GOTO   =erreur	Dans RWLEX

**************************************************
* M A X D
**************************************************

	NIBHEX C11	Alpha ou un numerique.
=MAXDe	CD0EX
	RSTK=C
	GOSUB  r<rstk
	GOSUB  VERTAP
	GOSUBL =JUMPER
	CON(5) GDIRST	Get DIRectory STart
	GOC    erreur	Erreur si carry
	C=D    W	D[5:8] = l. du dir. (enr.)
	GOSBVL =CSRW5	C[A] = longueur du dir.
	A=C    A	A[A] = longueur du dir.
	ASL    A	A[A] = 16 fois l. du dir.
	ASRB		A[A] = l. du dir. * 8

**************************************************
* SORTIE: commune, RETOUR A BASIC : Replace
* 4 niveaux de pile des retours, le compteur
* programme dans D0, transforme A[A] en nombre
* flottant dans A[W], replace D1 a sa place
* sur la Math-Stack puis retour a Basic via
* FNRTN4. (Rembobine le support)
**************************************************

 SORTIE GOSUB  =JUMPER	Rembobine le support
	CON(5) ENDTAP	de memoire de masse
	GOC    Erreur
	P=     4	) Restitution de 5 niveaux
	GOSBVL =RSTK<R	) de pile
	C=RSTK		) puis de
	D0=C		) D0  (4 niveaux & PC)
	GOSBVL =HDFLT	A[W] = longueur 
	C=R0		R0 = D1 (MS-16)
	D1=C		D1 = MS-16
	C=A    W	C[W] = longueur
	GOVLNG =FNRTN4	retour a BASIC

 Erreur GOTO   erreur	Ralonge

 memerr GOVLNG =MEMERR

**************************************************
* M E M M
**************************************************

	NIBHEX C11
=MEMMe	ST=0   memflg
	ST=1   Flg
	GONC   MXMC

**************************************************
* M E M D
**************************************************

	NIBHEX C11
=MEMDe	ST=1   memflg
	ST=0   Flg
	GONC   MXMC

**************************************************
* M A X M
**************************************************

	NIBHEX C11	Alpha ou un numerique
=MAXMe	CLRST		Ni memflg ni Flg
 MXMC	CD0EX
	RSTK=C
	GOSUB  r<rstk
	GOSUB  VERTAP
	A=R0		R0 = MS-16
	C=D    A	) D[X] = device address
	RSTK=C		) RSTK = D[X]
	C=0    A	
	LC(3)  #1F0	1F0 = 512-16 = 496
	A=A-C  A	A[A] = MS-512
	GOSBVL =D=AVMS
	C=A    A	C[A] = AVMEMS
	?C<D   A	Y a-t-il assez de mem. ?
	GOYES  memerr	Non: Erreur 
	R1=C		Sauvegarde de MS-512
	D1=C		D1 = Math Stack - 512
	A=0    A	A[A] = # enreg. a lire
	C=RSTK		) Restitution de
	D=C    A	) dev. add. dans D[X]
	GOSUBL =JUMPER	) Lecture de l'enreg. A[A]
	CON(5) READR#	) en commencant a D1 ^
	GOC    Erreur
	A=R1		A[A] = MS-512
	?ST=1  memflg	Est-on entre via MEMDIR ?
	GOYES  MDIRXQ
	C=0    A
	LC(2)  48
	C=C+A  A
	D1=C		^ pointe ^ l. max support
	P=     4	) Calcul de
	GOSUB  GETALR	) la longueur maximale
	GOSUB  getA*	) du support
	GOSUB  getA*	) de memoire de masse
	?ST=0  Flg	Est-on entre via MAXMEM
	GOYES  MXM10
	GOSUB  MEM00	Autrement execution de MEMM
 MXM10	ASL    A	) multiplication de A[A]
	ASL    A	) par 256 (dclg. d'1 octet)
	GOTO   SORTIE	pre retour a BASIC

 MEM00	B=A    A	B[A] = # enreg. maxi
	A=R1
 MDIRXQ D1=A		D1^ MS-512
	D1=D1+ 16	D1^ codage # Rec. Start DIR
	P=     4
	GOSUB  GETALR	=> A[A]= 00002 dir. start
	B=B-A  A	B[A] = # maxrec - vol.label
	R2=A		R2= dir. start
	D1=D1+ 8	D1^ code long. directory
	P=     4
	GOSUB  GETALR	=> A[A]= 0xxxx Dir.Len
	B=B-A  A	B[A]=maxmem apres format.
	?ST=1  Flg	Est-on entre via MEMM
	GOYES  MEM10	
	C=A    A	Sauvegarde de DirLen dans C
 MEM10	A=A-1  A	) A => R2 = compteur
	AR2EX		) A[A] = DIR START
	ABEX   A	A[A]=Maxmem apres format.
	R3=A		R3=compteur mem :tape
	?ST=1  Flg	Est-on entre via MEMM
	GOYES  MEM20	
	CSL    A	) Non: division de C[A] par
	CSRB		) 8 pour obtenir le max dir
	R3=C		) R3 compteur mem dir
 MEM20	GOSUB  GET#FL	Routine commune de comptage
	A=R3		A= resulat GET#FL
	?ST=1  Flg	Est-on entre via MEMM ?
	RTNYES		Retour de MEMM
	GOTO   SORTIE	Retour de MEMDIR

 GET#FL A=R1
	D1=A		D1^ MS-512
	A=B    A	A[A] = # enregis. a lire
	GOSUBL =JUMPER
	CON(5) READR#
	GOC    ERReur
	B=B+1  A	B[A] = prochain # enr.
	A=R1
	D1=A		D1 ^ MS - 512
	GOSUB  GET#E	Routine de comptage des 8
	 *		entrees directory d'un enr.
	A=R2		) Decrementation de R2
	A=A-1  A	) # d'enregistrements du 
	RTNC		) dir & retour si fin
	R2=A		Autrement sauvegarde
	GONC   GET#FL	B.E.T

 ERReur GOTO   erreur

 GET#E	LC(5)  #FFFF	C[3:0]=FFFF, masque de com-
	 *		paraison du rideau de fin d
	 *		de directory
	P=     8	8 = 8 entrees / enregist.
	A=0    A
 get#e	P=P-1		Compteur
	RTNC		Sortie si fin
	D1=D1+ 16
	D1=D1+ 4	D1^ type de fichier
	A=DAT1 4	A[3:0] =type de fichier
	?A=C   A	Est-ce le rideau (FFFF)
	GOYES  R3=OK	Oui: fin du s.prog.
	?A#0   A	A=0 => fichier purge !
	GOYES  R3-1
 incre	D1=D1+ 12	) On passe a l'entree
	D1=D1+ 16	) suivante
 MEM30	D1=D1+ 16	)
	GONC   get#e	B.E.T

 R3-1	?ST=1  Flg	MEMM ??
	GOYES  R3-M	Oui => R3- long fichier
	A=R3		)autrement R3
	A=A-1  A	) -1 seulement pour 
	R3=A		) MEMDIR
	GONC   incre	B.E.T.

 R3-M	D1=D1+ 12	D1^ long. du fich. en #rec.
	C=P    4	Sauveg. pointeur # dir
	RSTK=C
	P=     4	
	GOSUB  GETALR	A[A] long. # rec. du fich.
	C=RSTK
	CPEX   4	Restitution
	CR3EX		)
	C=C-A  A	) R3 = R3 - # rec 
	CR3EX		)
	D1=D1+ 8	Ajustement
	GONC   MEM30	B.E.T

 R3=OK	C=RSTK		Fin pop et retour
	RTN

**************************************************
* Cette routine sauvegarde 5 niveaux de pile
**************************************************

 r<rstk P=     4
	GOVLNG =R<RSTK	I N D I P E N S A B L E !!

**************************************************
* Routine de calcul de la longueur maxi
* du support (multiplication)
**************************************************

 getA*	R2=A
	P=     4
	GOSUB  GETALR
	C=R2
	GOSBVL =A-MULT
	RTN

**************************************************
* GETALR: GET A Left-Right. 
* Cette routine permet de charger dans le registre
* A n octets. Les octets sont decales vers la gau-
* che a chaque nouvel arrivant. 
* 
* Entree: D1^ premier octet a charger dans A
*	  P= Nombre d'octets a charger
*
* Sortie: A[2*(Pentree):0] = octets, le dernier 
*	    etant toujours dans A[B].
*	  P=0
*	  D1 ^ apres dernier octet
* 
* Utilise : C[B], A[W], P , D1
*
**************************************************

 GETALR C=DAT1 B
	D1=D1+ 2
	ASL    W
	ASL    W
	A=C    B
	P=P-1
	?P#    0
	GOYES  GETALR
	RTN

	END
