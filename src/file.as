	TITLE	FILESIZE <file.as>
*
* 87/09/05
*   Henri Kudelski (PPC Lausanne)
*   Création de la version 1A
* JPC:B03
*   87/12/06: PD/JT Correction du bug 5+FILESIZE(...)
*   87/12/06: PD/JT Correction du bug  sur :TAPE
*   87/12/06: PD/JT Integration dans JPC Rom
*

*
* Syntaxe :
*   FILESIZE ( <filespec> )
*     <filespec> avec ou sans HPIL
*

*
* Point d'entrée HP-IL
* A ne pas confondre avec FINDF+ du système
*
 FINDF+ EQU    #046A6	trouve un fichier sur :TAPE

 ave=d1 GOVLNG =AVE=D1

************************************************************
* FILESIZE
************************************************************

	NIBHEX 411	argument alpha
=FILESIZEe
*
* Pile des retours :
*   - D0 sauve dans la pile
*   - 5 niveaux de RSTK sauvés (à cause de l'HPIL)
*
	CD0EX
	RSTK=C		RSTK := D0
	P=     4	sauve 5 niveaux du stack en RAM
	GOSBVL =R<RSTK	pour l'HPIL
	GOSUB  ave=d1	AVMEME := D1 pour pFSPCx HPIL
	GOSBVL =FILXQ$	nom du fichier valide ?
*
* En sortie de FILXQ$, P vaut 0
* Cy = 1 : syntaxe valide pour mainframe
*	   D1 = après la chaîne sur la M.S.
*	   AVMEME obsolete
* Cy = 0 : non reconnaissable
*	   AVMEME = inchangé (donc ^ M.S. avant l'appel)
*	   S7 = 1
*
	GONC   FTAPe	Syntaxe non valide. HPIL ?
*
* Fichier supposé être en Ram. Existe-t-il ?
*
	GOSUB  ave=d1	Sauver D1 pour la suite
	GOSBVL =FINDF	cherche le fichier en Ram
	GOC    NULLE	pas trouvé, renvoie 0
*
* Fichier trouvé en Ram
*
	D1=D1+ 16
	D1=D1+ 16	D1 := ^ REL(5) FiLeNd
	A=0    W	calcule la taille du fichier 
	A=DAT1 A	Champ REL(5) FiLeNd
	C=0    W
	LC(2)  33	taille de l'entête
	GONC   FIN03	B.E.T.
*
* Nom du fichier valide pour HPIL ?
*
 FTAPe	GOTO   FTAPE	ralonge pour FTAPE

 FIN01	LC(2)  38
* 38 =  taille de l'en-tête en nibbles avec le 'file chain'
*
* C(W) = taille de l'en-tête en quartets + 1 pour arrondir
* au quartet supuérieur.
* A(W) = taille du fichier en quartets egalement
*
 FIN03	C=A+C  W
	CSRB		C(W) := taille en octets

*
* C(W) = résultat en octets
*
 FIN	GOSBVL =HXDCW	transforme en décimal
	GOSBVL =FLOAT	A(W) := 12 digits
*
* FIN02 est utilisé pour le cas "résultat nul"
*
 FIN02	SETHEX		Pour RSTK<R
	P=     4
	GOSBVL =RSTK<R	Utilise B, C et D0
*
* On commence à rapatrier les résultats
*
	C=RSTK
	CD0EX		Restaure D0 (PC)

	GOSBVL =D1MSTK	Restaure D1 (non décrementé)

	C=A    W	Résultat dans C(W)

	GOVLNG =FNRTN1

 NULLE	A=0    W	renvoie 0
	GOTO   FIN02

*
* Fichier valide pour l'HPIL ?
*
 FTAPE	LCASC  '  '	Rallonge a deux blancs
	R0=C		pour les caractères 9 et 10 du nom
*
* S7 = 1 (string expression on stack)
* AVMEME = top of stack
* D0 = ?
*
	GOSBVL =POLL	envoie un poll
	CON(2) =pFSPCx	vérifie si le nom valide pour HP-IL
	GOC    BSerr	nom, erreur
*
* A(W) = file name (R0 la suite)
* A(W) = 0 si pas de file name
* D(S), D(X) = device
* D0 = ?
* S7 = 1
* D1 = ^ après le file spec on stack (new top of stack) ????
*
	?XM=0
	GOYES  TAPEOK	fichier valide pour l'HPIL

	LC(4)  =eFSPEC	pas de HPIL, --> invalid filespec
 BSerr	GOVLNG =BSERR

*
* Routine d'erreur lorsque on revient de FINDF+
*
 ERRTAP ?P#    1	SI P=1 et C[0]=6, alors renvoie 0
	  *		(err: file not found)
	GOYES  ERR008	p#1, exécute la routine erreur
	A=C    B
	ASL    B	A[1]=C[0]
	LC(1)  6	si A[1]=C[1], alors renvoie 0
	?A=C   P
	GOYES  NULLE
 ERR008 GOLONG =erreur	cette routine vient du module HPIL

*
* Fichier valide pour l'HPIL
*
 TAPEOK
*
* Sauvegarde de A pour POP1S et récupération de l'adresse
* du bas de la M.S.
*
* Apparemment, pFSPCx ne renvoie pas D1 a la bonne valeur.
* Il faut donc la recalculer "à la main" par un POP1S bien
* senti. Merci N.Z.
*
	R1=A
	GOSBVL =D1MSTK
	GOSBVL =POP1S
	CD1EX
	C=C+A  A	C(A) := ^ new top of stack
	D1=C
	GOSUB  ave=d1	Pour la sortie du résultat
	A=R1

	GOSUBL =JUMPER
	CON(5) FINDF+	Cherche le fichier sur le tape
	GOC    ERRTAP	erreur, si err= File not found
	  *		renvoie 0 sinon provoque
	  *		l'erreur specifiee par P et C[0]
	D=C    A	sauve le nb record du fichier ds D
	A=0    A
	A=DAT1 B	lit le type du fichier dans A (les 2
	ASL    A	octets sont inverses.)
	ASL    A
	D1=D1+ 2
	A=DAT1 B
	GOSBVL =FTYPF#	Cherche le copy code dans la table
	  *		des types de fichiers
	P=     0
	CD0EX		adresse du début de la table dans C
	D1=(2) #39	positionne D1 sur les bytes d'implém
	A=0    W
	A=DAT1 8	4 bytes dans A (manuel HPIL Anx D)
	C=0    W
	C=DAT0 P	lit le copy code
	C=C-1  P	copy code=0 ?
	GOC    FORMA	oui
	C=C-1  P	copy code=1 ?
	GOC    FORMB	oui
	C=C-1  P	copy code=2 ?
	GOC    FORMC	oui
*
* Copy code > 2
*
 FORMD	C=D    A	le copy code>2, renvoie la longueur
	A=0    W	du fichier sous la
	A=C    A	forme nbr de record * 256 + 19
	ASL    A
	ASL    W
*
	LC(5)  19
	C=C+A  W	entier supérieur
 fin	GOTO   FIN	C(W) = la taille en octets

*
* Copy code = 2
*
 FORMC	ASL    A	fichier SDATA
	A=0    M	On aura dans A: '00000000000xxxx0'
	ASL    A
	D1=D1+ 2	inverse les 2 bytes de longueur
	A=DAT1 B	Calcul la lg de la manière suivante:
	ASL    W	Nb de ligne du fichier*16 -> Nb de q
	*		donne dans A la taille en nibbles
*
* Copy code = 0
*
*	Routine pour fichier BASIC,LEX,BIN,KEYS et FORTHRAM
 FORMA	GOTO   FIN01

*
* Copy code = 1 (fichier DATA)
*
 FORMB	P=     3	nb de ligne * longueur d'une ligne
	C=A    WP	--> taille du fichier en  bytes
	ASR    W
	ASR    W
	ASR    W
	ASR    A
	P=     0
	GOSBVL =MPY	A=A*C
	C=0    W
	LC(2)  23	rajoute 4 bytes pour les deux
	C=A+C  W	pointeurs des fichiers DATA.
	GONC   fin	C(W) = taille en octets + en-tête

	END
