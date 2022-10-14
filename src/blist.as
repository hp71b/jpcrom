	TITLE  BASICLEX <basic.as>

*
* JPC:A01
*   86/10/21: PD/JT intégration dans JPC Rom
* JPC:B03
*   88/01/24: PD/JT réécriture et intégration
*   

 INDVAL EQU    00+=TRFMBF  5 q : valeur indentation
 CURIND EQU    05+=TRFMBF  5 q : indentation cour.
 OUTYPE EQU    10+=TRFMBF  1 q : 0: fichier, 1: std
 OUTADR EQU    11+=TRFMBF  5 q : adresse ds fichier
 OUTHDR EQU    16+=TRFMBF  5 q : header du fichier

 LDEB	EQU    21+=TRFMBF  5 q : ligne de début
 LFIN	EQU    26+=TRFMBF  5 q : ligne de fin

 INFILE EQU    31+=TRFMBF  5 q : adresse ds fichier
 INEND	EQU    36+=TRFMBF  5 q : fin du fichier

 INDARM EQU    41+=TRFMBF  1 q : 0:std, 1:DATA, 2:!

 INDCOU EQU    42+=TRFMBF  2 q : valeur courante
 INDLIG EQU    44+=TRFMBF  2 q : en début de ligne

 SAUTAV EQU    46+=TRFMBF  1 q : sauter ligne avant
 SAUTAP EQU    47+=TRFMBF  1 q : sauter ligne après

 TMP	EQU    48+=TRFMBF  au moins 2 q.

 inDATA EQU    1	pour INDARM
 inREM	EQU    2	pour INDARM

 clRIEN EQU    0
 clNDDF EQU    1
 clSUB	EQU    2
 clDEF1 EQU    3
 clDEF2 EQU    4
 clDATA EQU    5
 clLBL	EQU    6
 clREM	EQU    7
 clIF	EQU    8

	STITLE	PBLIST / DBLIST

****************************************************
* PBLIST / DBLIST
*
* But : produire un listing structuré sur
*   l'imprimante ou dans un fichier.
* Detail :
*   initialiser les variables globales
*   initialiser les options par défaut
*
*   tant que non fin de ligne tokenisée
*     faire
*	selon token
*	  tCOMMA :
*	    LDEB, LFIN := numéros de ligne
*	    tester la validité
*	  tTO :
*	    évaluer le spécificateur de fichier
*	    chercher le fichier
*	    si il existe
*	      alors "File Exists"
*	    fin si
*	    stocker les paramètres pour création
*	  tXWORD :
*	    INDVAL := évaluer l'expression
*	  autre :
*	    évaluer le fichier
*	    chercher le fichier
*	    si il n'existe pas
*	      alors "File Not Found"
*	    fin si
*	    vérifier type et protections
*	    INFILE := ^ fichier
*	fin selon
*   fin tantque
*   créer le fichier de sortie si nécessaire
*   pour toutes les lignes du fichier
*     décompiler et lister
* Historique :
*   86/05/.. : JPB     conception & codage
*   88/01/10 : PD & JT ajout indentation & fichier
****************************************************

	REL(5) =PBLISTd
	REL(5) =PBLISTp
=PBLISTe
	LC(2)  (=PRINTt)*16+#F
	GOTO   LIST05

 bserr	GOVLNG =BSERR

	REL(5) =DBLISTd
	REL(5) =DBLISTp
=DBLISTe
	LC(2)  (=DISPt)*16+#F
*
* Initialiser la sortie standard
*
 LIST05 D1=(5) =MLFFLG	Destination du xBLIST
	DAT1=C B
*
* Initialisation des variables globales
*   INDVAL = 0 (pas d'indentation)		5 q
*   CURIND = 0 (indentation courante = 0)	5 q
*   OUTYPE = 0 (sortie std et pas fichier)	1 q
*
	D1=(5) INDVAL
	C=0    W
	DAT1=C 11
*
* LDEB = ligne de début
* LFIN = ligne de fin
*
	D1=(2) LDEB
	C=C+1  A
	DAT1=C A	LDEB := 0001 par défaut
	D1=D1+ (LFIN)-(LDEB)
	LCHEX  9999
	DAT1=C A	LFIN := 0999 par défaut

	D1=(2) INDARM	INDARM, INDCOU, INDLIG,
	C=0    W	... SAUTAV et SAUTAP
	DAT1=C 7	... := 0
*
* Chercher l'adresse du fichier courant
*
	D1=(4) =CURRST
	C=DAT1 A
	D1=(4) INFILE
	DAT1=C A	INFILE := ^ début fichier

 loop	A=DAT0 B	A(B) := token courant
	GOSBVL =EOLXCK
	GONC   loop10
	GOTO   endlop	Sortie si EOL trouvé

 loop10 GOSBVL =FINDA
	CON(2) =tCOMMA	<line#>
	REL(3) LIST10
	CON(2) =tXWORD	INDENT <exp num>
	REL(3) LIST20
	CON(2) =tTO	TO <filespec>
	REL(3) LIST30
	NIBHEX 00
*
* <filespec>
*
	GOSBVL =FSPECx	spécificateur valide ?
	GOC    bserR	non
	GOSBVL =FINDF+	trouve le fichier
	GOC    bserR	non trouvé
	CD1EX		C(A) := ^ file start
	D1=(5) INFILE
	DAT1=C A	INFILE := ^ file start
	GOTO   loop

 bserR	GOTO   bserr
*
* <line#> [ , <line#> ]
*
 LIST10 D1=(5) LDEB
	GOSUB  getli#
	DAT1=A A	<line# 1>
	D1=D1+ (LFIN)-(LDEB)
	DAT1=A A	<line# 2>
	GOSUB  getli#
	GOC    loop	pas de <line# 2>
	DAT1=A A
	D1=D1- (LFIN)-(LDEB)
	C=DAT1 A	C(A) := <line# 1>
	?C<=A  A	1 <= 2
	GOYES  loop	oui : ok
 invarg GOVLNG =IVAERR	non (ah bon ?)

*
* INDENT <exp num>
*
 LIST20 D0=D0+ 6	sauter tXWORD id tINDENT
	GOSBVL =EXPEXC
	GOSBVL =RNDAHX
	GONC   invarg	négatif
	D1=(5) INDVAL
	DAT1=A A
	GOTO   loop

*
* TO <filespec>
*
 LIST30 D0=D0+ 2
	GOSBVL =FSPECx	spécificateur valide ?
	GOC    Bserr	non
*
* Cy = 0 : mainframe recognisable file specifier found
* A(W) = file name
* D(S) = #F  if device not specified
* D(B) = détails sur le port
*
	D1=(5) =STMTR0	sauvegardes
	C=D    W	Sauvegarde de D(W) (pour CRETF+)
	DAT1=C W
	D1=D1+ 16
	DAT1=A W	Sauvegarde du nom du fichier

	GOSBVL =FINDF+	Find file
*
* A(W) = B(W) = file name
* Cy = 0 : file found
* Cy = 1 : file not found
*
	GOC    LIST32	fichier non trouvé : ok
	LC(4)  =eFEXST	"File Exists" / Beeeeeep !
 Bserr	GOTO   bserr

 LIST32 D1=(5) OUTYPE
	LC(1)  1
	DAT1=C P	Sortie := fichier
	GOTO   loop

 endlop
*
* Vérification du type et des protections du
* fichier à lister.
*
	D0=(5) INFILE
	C=DAT0 A
	D1=C
	D1=D1+ (=oFTYPh)-1
	A=DAT1 A
	ASR    A	A(A) := file type
	D1=D1- (=oFTYPh)-1
	GOSBVL =BASCHA	BASIC ?
	GOC    bsErr	Non : "Invalid File Type"
	GOSBVL =GETPR1	PRIVATE ?
	GOC    bsErr	Oui : "File Protect"
* D1 = ^ file type

*
* Préparer les pointeurs
*
	D1=D1+ (=oFLENh)-(=oFTYPh)
	CD1EX
	D1=C
	A=DAT1 A	A(A) := REL(5) FiLeNd
	C=C+A  A
	D0=(2) INEND
	DAT0=C A
	D=C    A	D(A) := ^ fin fichier
	D0=(2) LDEB
	A=DAT0 A	A(A) := <line1 #>
	B=A    A
	D1=D1+ (=oBSsod)-(=lEOL)
	CD1EX
	D1=C
	D1=D1+ =lEOL	D0 = ^ line # (1ère ligne)
	A=0    A	La doc ne l'indique pas
	GOSBVL =FINDL0	Supporté !
	GOC    lst10
	?ST=0  0	Il existe un numéro de ligne
	GOYES  lst10	plus grand que <line1 #>
	GOTO   nxtstm

 bsErr	GOTO   bserr

 lst10	D0=(5) INFILE
	CD1EX
	DAT0=C A	INFILE := ^ line# courant
*
* Création du fichier à partir des éléments stockés
* dans STMTR0/1 pendant "TO <filespec>" si
* nécessaire.
*
	D0=(2) OUTYPE
	A=DAT0 S
	?A=0   S
	GOYES  nocret
	D1=(5) =STMTR0
	C=DAT1 W
	D=C    W	Restaurer pour CRETF+
	C=0    A
	LC(2)  37+4	header + EOF-mark
	GOSBVL =CRETF+	Le Lex ne doit pas bouger
	GOC    bsErr	Problème à la création
	C=R1		C(A) := adresse du header
	D1=(5) OUTHDR	Header du fichier de sortie
	DAT1=C A
	D1=(5) =STMTR1
	A=DAT1 W
	D1=C
	DAT1=A W	Nom du fichier
	D1=D1+ 16	D1 = ^ file type
	LCHEX  400001	text + copy code
	DAT1=C 6
	D1=D1+ 16
	D1=D1+ 5
* EOF-Mark
	C=0    A
	C=C-1  A
	DAT1=C 4	D1 := ^ fin du fichier

	CD1EX
	D1=(5) OUTADR
	DAT1=C A
 nocret

****************************************************
* lst100
*
* But : début de la boucle principale de D/PBLIST
*   c'est à dire tests de sortie
* Entrée : -
* Sortie :
*   si sortie nécessaire
*     alors sortie par NXTSTM
*     sinon D1 = ^ <line #>
*   fin si
* Detail :
*   test 1 : EOF ?
*   test 2 : no ligne > no dernière ligne à lister
*   test 3 : [ATTN] ?
* Appelle : CK"ON", NXTSTM
* Historique :
*   88/01/10 : PD & JT conception & codage
****************************************************

 lst100
* 1 : atteint EOF ?
	D0=(5) INFILE
	A=DAT0 A	A(A) := ^ line#
	D0=(2) INEND
	C=DAT0 A	C(A) := ^ FiLeNd
	?A>=C  A
	GOYES  nxtstm
* 2 : atteint ligne > ligne fin ?
	D1=A		D1 := ^ line#
	A=0    A
	A=DAT1 4	A(A) := line#
	D0=(2) LFIN
	C=DAT0 A
	?A>C   A
	GOYES  nxtstm
* 3 : [ATTN] ?
	CD1EX
	GOSBVL =CK"ON"
	D1=C
	GOC    lst110	Ok on a passé tous les tests
 nxtstm GOVLNG =NXTSTM

****************************************************
* lst110
*
* But : analyse du premier statement et
*   decompilation de la ligne.
* Entrée :
*   - D1 = ^ <line #>
* Sortie :
*   - (OUTBS..AVMEMS) = ligne decompile
*     et indentation faite
* Appelle : gettok, LDCM10
****************************************************

*
* Ok, on peut y aller
* D1 = ^ line#
*
 lst110
	D1=D1+ 2	D1 := ^ Stlen - 2
	GOSUB  gettok

	B=A    B	B(B) := classe reconnue
*
* Analyse du premier statement pour voir s'il faut :
*   - indenter avant
*   - sauter une ligne avant
*   - marquer un SUB
*

*
* Indentation avant ?
*
	C=R1		C(A) := indentation avant
	?C=0   A
	GOYES  lst120
* il faut indenter
	D0=(5) INDCOU	Indentation courante
	A=DAT0 B
	A=A-C  B
	GONC   lst118	Ok, indentation valide
	A=0    B	Indentation := 0
 lst118 DAT0=A B	Nouvelle indentation
*
* Cas autre que DATA ?
*
* Si token = DATA
*   alors
*     on est à l'interieur, on ne fait rien
*   sinon
*     si on était avant à l'interieur de DATA
*	alors
*	  on n'est plus dans des DATA (INDARM := 0)
*	  sauter une ligne avant (SAUTAV := 1)
*	sinon
*	  cas le plus fréquent, on ne fait rien
*     fin si
* fin si
*
 lst120 A=B    A	A(B) := classe du token
	LC(2)  clDATA
	?A=C   B
	GOYES  lst122	cas "DATA"

	D0=(5) INDARM
	A=DAT0 1	A(0) = 0, inDATA ou inREM

	LC(1)  inDATA	On avait DATA avant ?
	?A#C   P
	GOYES  lst122	Non : on ne fait rien (ah..)

	C=0    A	A(0) := 0 (no inDATA)
	DAT0=C 1	INDARM := 0

	D0=(2) SAUTAV
	C=C+1  A	C(0) := 1
	DAT0=C 1

*
* Si (INDARM = inREM) && (classe # clREM)
*   alors
*     INDARM := 0
* fin si
*
 lst122
	D0=(2) INDARM
	A=DAT0 P
	LC(1)  inREM
	?A#C   P
	GOYES  lst125	INDARM # inREM
	LC(2)  clREM
	?C=B   B
	GOYES  lst125	classe = clREM
	C=0    A
	DAT0=C P	INDARM := 0

****************************************************
* Y-a-t'il des cas particuliers à traiter ?
****************************************************

 lst125 A=B    A	A(B) := classe du token
	GOSBVL =FINDA
	CON(2) clSUB	SUB
	REL(3) l1SUB
	CON(2) clDEF1	DEF mono-ligne
	REL(3) l1DEF1
	CON(2) clDEF2	DEF multi-ligne
	REL(3) l1DEF2
	CON(2) clDATA	DATA
	REL(3) l1DATA
	CON(2) clLBL	<label>
	REL(3) l1LBL
	NIBHEX 00
	GOTO   lst130	Pas de traitement spécial

 l1SUB	D1=(5) INDCOU	Indentation := 0
	C=0    B
	DAT1=C B
* sauter une ligne
	GOSUB  sautln
* une ligne de '-'
	D1=(5) =OUTBS	Début de la ligne
	C=DAT1 A
	D1=C		D1 := ^ début ligne

	LCASC  '--------'
	A=C    W	A(W) := pattern
	C=0    A
	LC(2)  8*8*2	64 '-'
	GOSBVL =STUFF	Remplissage de 64 '-'
	CD1EX		C(A) := adresse de fin
	D1=(5) =AVMEMS
	DAT1=C A	AVMEMS := fin
	GOSUB  print

	GOTO   l1skip	et terminer en sautant

 l1DEF1 A=DAT1 B	A(B) := tEOL ?
	LC(2)  =tEOL
	?A#C   B
	GOYES  lst130	DEF + autre chose
	D1=(5) SAUTAP	Sauter après
	LC(1)  1
	DAT1=C 1	Sauter une ligne après
	GONC   l1skip	B.E.T.

 l1DATA D1=(5) INDARM	DATA ou REM ?
	A=DAT1 1
	LC(1)  inDATA
	DAT1=C 1	INDARM := inDATA
	?A#C   P
	GOYES  l1skip	Premier DATA
	GOTO   lst130	pas de saut

 l1DEF2
 l1LBL
 l1skip
	D1=(5) SAUTAV
	LC(1)  1	1 est différent de 0
	DAT1=C P	Sauter une ligne
	GOTO   lst130

*
* Sauter une ligne ?
*
 lst130 D0=(5) SAUTAV	Sauter avant ?
	A=DAT0 S
	?A=0   S	Sauter la ligne ?
	GOYES  lst140	Non

	GOSUB  sautln	Sauter une ligne

*
* Figer l'indentation courante
*
 lst140 D0=(5) INDCOU	Indentation courante
	A=0    W
	A=DAT0 B

	D0=(2) INDVAL	Valeur de l'indentation
	C=0    W
	C=DAT0 A	

	GOSBVL =MPY	A,B,C := Ind. en octets

	C=C+C  A	Indentation en quartets
	D0=(2) TMP
	DAT0=C A	TMP := déplacement en q.
*
* On voudrait C(A) quartets en plus. On peut ?
*
	GOSBVL =MEMCKL	Memory Check with Leeway
	GONC   lst145	Oui : on continue
	GOTO   bserr	Non : Insufficient Memory
*
* B(A) := déplacement en quartets
*
 lst145 D0=(4) =OUTBS
	C=DAT0 A	C(A) := OUTBS original
	RSTK=C		RSTK := OUTBS original

	D1=C		D1 := start of area
	LCASC  '        '
	A=C    W	A(W) := pattern à stuffer
	C=B    A	C(A) := longueur en quartets
	GOSBVL =STUFF
	CD1EX		C(A) := pseudo OUTBS
*
* Laisser de la place pour le no de ligne
*
	D0=C		D0 := ^ pseudo OUTBS
	LCASC  '   '
	DAT0=C 6

*
* Remettre D1 sur la ligne (<line #>)
*
	D1=(5) INFILE
	C=DAT1 A
	D1=C		D1 := ^ <line #>

	A=0    A
	A=DAT1 4	A(A) := no de ligne
	LCHEX  01000
	?A>=C  A
	GOYES  lst160
	CSR    A	C(A) := 100
	?A>=C  A
	GOYES  lst151	1 blanc
	CSR    A	C(A) := 10
	?A>=C  A
	GOYES  lst152	2 blancs
	D0=D0+ 2
 lst152 D0=D0+ 2
 lst151 D0=D0+ 2
 lst160 CD0EX
	D0=(5) =OUTBS
	DAT0=C A
*
* D1 = ^ line#
* OUTBS décalé pour LDCM10
*
	GOSBVL =LDCM10	Comme pour LIST
*
* R0 = ^ past tEOL
* B(A) = longueur en octets
* OUTBS collapsed
*
	C=RSTK		C(A) := OUTBS original
*
* Decaler le numéro de ligne et le remettre
* avant l'indentation
*
	D=C    A	D(A) := OUTBS original
	D1=(5) TMP	juste avant no ligne
	A=DAT1 A
	A=A+C  A	A(A) := ^ no ligne
	D0=A		D0 := ^ no ligne
	D1=C		D1 := ^ OUTBS original
	A=DAT0 8	Lire no de ligne
	LCASC  '    '
	DAT0=C 8
	DAT1=A 8	Nouveau no ligne
	C=D    A	C(A) := OUTBS original
*
* Placer AVMEMS à la bonne valeur
*
	D1=(5) =OUTBS	OUTBS modifié
	A=DAT1 A
	DAT1=C A	OUTBS original
	A=A+B  A
	A=A+B  A
	D1=D1+ 5	=AVMEMS
	DAT1=A A	nouveau AVMEMS
*
* Traitement du premier token à nouveau
* - !
* - indentation "après"
*
	D0=(5) INFILE
	A=DAT0 A
	D1=A		D1 := ^ <line #>
	D1=D1+ 2
	GOSUB  gettok	A nouveau le 1er token
	B=A    B	B(A) := classe du token
*
* Cas particulier du IF ?
*
	LC(2)  clIF
	?A#C   B
	GOYES  lst165	Non : on continue
	GOTO   lst700	Ignorer le reste de la ligne

 lst165 C=R2		C(A) := indentation "après"
	?C=0   A
	GOYES  lst170	Pas d'indentation

	D0=(2) INDCOU
	A=DAT0 B	A(B) := indentation courante
	A=A+C  B
	DAT0=A B
*
* "!" ?
*
 lst170 LC(2)  clREM
	?B#C   B
	GOYES  lst190	Rentrer dans la boucle
* Sauver D1 pour être remis après
	CD1EX
	RSTK=C		RSTK := D1
* D1 := ^ no ligne dans la chaîne decompilée
	D1=(5) =OUTBS
	C=DAT1 A
	D1=C		D1 := ^ no ligne
* Mettre d'office 4 blancs
	LCASC  '    '
	DAT1=C 4*2
* Mettre un '-' ?
	D1=D1+ 3*2	D1 := ^ ('-' éventuel)
	D0=(2) INDARM
	A=DAT0 P	A(0) := 0, inDATA ou inREM
	LC(1)  inREM
	DAT0=C P	INDARM := inREM
	?A=C   P	Déjà une REM ?
	GOYES  lst180	Oui : ne rien faire
	LCASC  '-'	Non : ajouter un '-'
	DAT1=C B
 lst180 LCASC  '!'
 lst182 A=DAT1 B
	?A=C   B
	GOYES  lst185
	D1=D1+ 2
	GONC   lst182	B.E.T.
 lst185 D1=D1+ 2+2	D1 := ^ début du commentaire
	AD1EX		A(A) := start of source
	D1=A
	D1=D1- 2+2	D1 := start of dest
	GOSBVL =MOVEUA	AVMEMS := end of source

	D0=(5) =AVMEMS
	CD1EX		C(A) := end of dest
	DAT0=C A
	C=RSTK		restaurer D1
	D1=C

 lst190

****************************************************
* Début de la boucle "dans la ligne"
*
* But : explorer les statements entre le deuxième et
*   le dernier de la ligne courante.
* Entrée :
*   - D1 = ^ Stlen - 2 du deuxième Statement
* Sortie :
*   - D1 = ^ tEOL de la ligne courante
* Historique :
*   88/01/24 : PD & JT conception & codage
****************************************************

*
* Ce lst530 est une ruse (voir en fin de boucle)
*
 lst530
 lst500 GOSUB  gettok
	B=A    B	B(A) := classe du token
	GOC    lst900

	LC(2)  clIF	IF standard ?
	?A=C   B
	GOYES  lst700	Ignorer le reste de la ligne
*
* Calculer la nouvelle indentation
*
	D0=(5) INDCOU
	C=DAT0 B	C(A) := indentation courante

	A=R1		indentation avant (<= 0)
	C=C-A  B
	GONC   lst510	Pas < 0
	C=0    B
 lst510 A=R2		indentation après (>= 0)
	C=C+A  B
	DAT0=C B
*
* Cas particuliers ?
*
	LC(2)  clSUB
	?B#C   B
	GOYES  lst520
*
* SUB
*
	DAT0=A B	indentation := R2
	GONC   lst530	B.E.T.
 lst520 LC(2)  clNDDF
	?B#C   B
	GOYES  lst530
*
* END DEF
*
	A=DAT1 B	A(B) = tEOL ?
	LC(2)  =tEOL
	?A#C   B
	GOYES  lst530
	LC(1)  1
	D0=(2) SAUTAP
	DAT0=C 1	Sauter après := vrai

*
* Le lst530 qui suit a été déplacé en début de la
* boucle pour éviter le GOYES -> GOTO intempestif.
* lst530
	GOTO   lst500

 lst700 D1=(5) INFILE
	A=DAT1 A	A(A) := ^ <line #>
	D1=A
	GOSBVL =NXTLIN	D1 := ^ past tEOL
	GONC   lst910	B.E.T.
*
* Attention : le code continue en sequence !!!
*

****************************************************
* Fin de la boucle "dans la ligne"
*
* But : recupérer le pointeur dans le flot tokenisé
*   pour la ligne suivante, et itérer
* Entrée :
*   - D1 = ^ tEOL de la ligne courante
* Sortie :
*   - INFILE = ^ <line #> de la ligne suivante
* Historique :
*   88/01/24 : PD & JT conception & codage
****************************************************

 lst900 D1=D1+ 2	D1 := ^ <line #> ligne suiv.
 lst910 CD1EX		C(A) := ^ <line #>
	D1=(5) INFILE
	DAT1=C A	Nouvelle ligne
*
* Prépare la ligne suivante
*
* Reporter le "saut après" sur "saut avant" et
* effacer "saut après"
	D1=(5) SAUTAP
	A=DAT1 S
	C=0    S
	DAT1=C S
	D1=(2) SAUTAV
	DAT1=A S

	GOSUB  print

	GOTO   lst100

****************************************************
* SOUS-PROGRAMMES
****************************************************

****************************************************
* sautln
*
* But : imprimer une ligne vide
* Entrée : -
* Sortie : -
* Abime : A-D, R3
* Appelle : OBCOLL, print (tombe dedans)
* Niveaux : 
* Historique :
*   88/01/24 : PD & JT conception & codage
****************************************************

 sautln GOSBVL =OBCOLL
*
* Attention : le code continue !!!
*

****************************************************
* print
*
* But : imprimer la ligne comprise entre OUTBS et
*   AVMEMS sur le DISPLAY, le PRINTER ou dans un
*   fichier selon la valeur de OUTYPE.
* Entrée :
*   - (OUTBS..AVMEMS) = la ligne
* Sortie : -
* Abime : A-D, R3
* Appelle : CKINFO, SNDWD+, SENDEL, SWPBYT, RPLLIN,
*   MOVED2
* Niveaux : 
* Detail : l'exécution de sautln continue en direct
* Historique :
*   88/01/24 : PD & JT isolement dans un sub
****************************************************

 print	D0=(5) OUTYPE
	A=DAT0 S	0 : std, 1 : fichier
	?A#0   S
	GOYES  prnt50
*
* Impression sur DISPLAY ou PRINTER
*
	GOSBVL =CKINFO	Prepare HPIL pour l'envoi

	D0=(4) =AVMEMS
	A=DAT0 A
	D0=D0- 5	OUTBS
	C=DAT0 A	C(A) := ^ chaîne
	A=A-C  A	A(A) := longueur en quartets
	B=0    W
	B=A    A
	BSRB		B(A) := longueur en octets

	ST=1   =InhEOL	Inhibit EOL pour le cas où

	GOSBVL =SNDWD+	Envoi proprement dit

	GOVLNG =SENDEL	EOL

*
* Impression dans un fichier
*
 prnt50 D0=(4) =AVMEMS
* Insertion de la longueur LIF
	A=DAT0 A	A(A) := end of source
	D1=A
	D1=D1+ 4	D1 := end of dest
	D0=D0- 5	D0=(5) OUTBS
	C=DAT0 A	C(A) := start of source
	GOSBVL =MOVED2
* Calculer le padding LIF
	D0=(5) =AVMEMS
	A=0    W
	A=DAT0 A
	D0=D0- 5	OUTBS
	C=DAT0 A
	A=A-C  A	Longueur en quartets
	ASRB		Longueur en octets
	B=A    A	Sauvegarde
	GOSBVL =SWPBYT
	C=DAT0 A	C(A) := (OUTBS)
	D1=C		D1 := ^ LIF length
	DAT1=A 4
	SB=0
	BSRB
	A=0    A	Longueur à ajouter
	?SB=0
	GOYES  prnt60	Longueur paire
	A=A+1  A	1 octet à ajouter
 prnt60 C=0    A
	LC(1)  4
	A=A+A  A
	A=A+C  A	Longueur totale à ajouter
	D0=D0+ 5	AVMEMS
	C=DAT0 A
	C=C+A  A
	DAT0=C A	AVMEMS + 4 ou 6
* Insertion dans le fichier
	C=0    A
	R3=C		R3 := longueur vieille ligne
	D0=(5) OUTHDR
	C=DAT0 A	C(A) := ^ file header
	D0=(2) OUTADR
	A=DAT0 A	A(A) := ^ end of old line
	GOSBVL =RPLLIN	Ne peut pas bouger
	GOC    bSerr
* A(A) = end+1 of replaced line in file
	D0=(5) OUTADR
	DAT0=A A

	RTN

 bSerr	GOTO   bserr

****************************************************
* getli#
*
* But : évaluer un numéro de ligne optionnel
* Entrée :
*   - D0 = ^ tCOMMA precedant <line #>
* Sortie :
*   Cy = 1 : pas de <line #>
*   Cy = 0 :
*     - A(A) = numéro de ligne en BCD
*     - D0 réactualisé
* Niveaux : 0
* Utilise : C(B), A(A)
* Historique :
*   86/05/.. : JPB     conception & codage
*   88/01/10 : PD & JT modifications & documentation
****************************************************

 getli# A=DAT0 B
	LC(2)  =tCOMMA
	?A#C   B
	RTNYES
	D0=D0+ 2
	A=0    A
	A=DAT0 4
	D0=D0+ 4
	RTN		Cy = 0 à cause de D0=D0+ 4

****************************************************
* gettok
*
* But : classer le token pointé par D1
* Entrée :
*   - D1 = ^ Stlen - 2 du token à classer
* Sortie :
*   Cy = 1 : EOL trouvée
*   Cy = 0 : EOL non trouvée
*     - D1 = ^ Statement terminator
*     - A(B) = classe du token
*   R1 = indentation avant
*   R2 = indentation après
* Niveaux : 1
* Utilise : 
* Appelle : FINDA
* Historique :
*   88/01/23 : PD & JT & JJD conception & codage
****************************************************

 gettok C=0    W
	R1=C
	R2=C

	A=DAT1 B
	LC(2)  =tEOL
	?A=C   B
	RTNYES

	D1=D1+ 2	D1 := ^ Stlen
	C=0    A
	C=DAT1 B	C(A) := Stlen
	AD1EX
	C=C+A  A	C(A) := ^ Stlen - 2 suivant
	D1=A		D1 := ^ Stlen du courant
	RSTK=C		RSTK := ^ tEOL ou t@ ou ...

	D1=D1+ 2	D1 = ^ token courant
	A=DAT1 B

	GOSBVL =FINDA
	CON(2) =tXWORD	XWORD
	REL(3) gtXWRD
	CON(2) =tFOR	FOR
	REL(3) gtFOR
	CON(2) =tNEXT	NEXT
	REL(3) gtNEXT
	CON(2) =tSUB	SUB
	REL(3) gtSUB
	CON(2) =tDEF	DEF FN
	REL(3) gtDEF
	CON(2) =tDATA	DATA
	REL(3) gtDATA
	CON(2) =tLBLST	'...':
	REL(3) gtLBL
	CON(2) =tEND	END
	REL(3) gtND
	CON(2) =tENDDF	END DEF
	REL(3) gtNDDF
	CON(2) =tENDSB	END SUB
	REL(3) gtNDSB
	CON(2) =t!	!
	REL(3) gtREM
	CON(2) =tIF	IF mono-ligne (standard)
	REL(3) gtIF
	NIBHEX 00

 gtrien GOTO   gtRIEN

 gtXWRD D1=D1+ 2
	A=DAT1 B
	LC(2)  =id
	?A#C   B
	GOYES  gtrien

	D1=D1+ 2	D1 := ^ toooooken
	A=DAT1 B	A(B) := token

	GOSBVL =FINDA
	CON(2) =tWHILE	WHILE
	REL(3) gtWHIL
	CON(2) =tLOOP	LOOP
	REL(3) gtLOOP
	CON(2) =tREPEAT REPEAT
	REL(3) gtREPT
	CON(2) =tUNTIL	UNTIL
	REL(3) gtUNTL
	CON(2) =tIF2	IF jpcrom
	REL(3) gtIF2
	CON(2) =tELSE2	ELSE jpcrom
	REL(3) gtELS2
	CON(2) =tSELECT SELECT
	REL(3) gtSEL
	CON(2) =tCASE	CASE
	REL(3) gtCASE
	CON(2) =tEND2	END IF/LOOP/SELECT/WHILE
	REL(3) gtENDj
	NIBHEX 00
	GOTO   gtRIEN

****************************************************
* indentation avant :  0
* indentation après : +1
*
* FOR, WHILE, LOOP, REPEAT, IF
****************************************************

 gtFOR
 gtIF2
 gtLOOP
 gtREPT
 gtWHIL C=0    A
	C=C+1  A
	R2=C		indentation après := 1
	GOTO   gtRIEN	Classe : normale

****************************************************
* indentation avant : -1
* indentation après : +1
*
* ELSE, CASE
****************************************************

 gtCASE
 gtELS2 C=0    A
	C=C+1  A
	R1=C		indentation avant := 1
	R2=C		indentation après := 1
	GOTO   gtRIEN	Classe : normale

****************************************************
* indentation avant :  0
* indentation après : +2
*
* SELECT
****************************************************

 gtSEL	C=0    A
	LC(1)  2
	R2=C		indentation après := 2
	GOTO   gtRIEN	Classe : normale


 gtENDj D1=D1+ 2	D1 = ^ q de reconnaissance
	A=DAT1 B	A(B) = token suivant
	GOSBVL =EOLXCK
	GOC    gtND	END WHILE
*
* A(0) = quartet de reconnaissance
*
	LC(1)  =qENDS
	?A=C   P
	GOYES  gtNDSL	END SELECT
*
* END LOOP / IF
* Attention : le code continue !!!
*

****************************************************
* indentation avant : -1
* indentation après :  0
*
* UNTIL, NEXT, END LOOP, END WHILE,
* END IF, END, END SUB
****************************************************

 gtND
 gtNDSB
 gtNEXT
 gtUNTL C=0    A
	C=C+1  A
	R1=C		indentation avant := 1
	GOTO   gtRIEN	Classe : normale

****************************************************
* indentation avant : -2
* indentation après :  0
*
* END SELECT
****************************************************

 gtNDSL C=0    A
	LC(1)  2
	R1=C		indentation avant := 2
	GOTO   gtRIEN	Classe : normale

****************************************************
* indentation avant : -1
* indentation après :  0
*
* Cas particulier

* END DEF
****************************************************

 gtNDDF C=0    A
	C=C+1  A
	R1=C		indentation avant := 1

	LC(2)  clNDDF	Classe END DEF
	A=C    B
	GOTO   gtok99

****************************************************
* indentation avant :  0 (en fait : cas particulier)
* indentation après : +1
*
* Cas particulier
*
* SUB
****************************************************

 gtSUB	C=0    A
	C=C+1  A
	R2=C		indentation après := 1

	LC(2)  clSUB	Classe SUB
	A=C    B
	GOTO   gtok99

 gtDEF	D1=D1+ 7
	A=DAT1 B	A(B) := 0 si multi-ligne
	?A=0   B
	GOYES  gtDEF2	Multiligne
*
* Attention : le code continue
* DEF FN mono-ligne

****************************************************
* indentation avant :  0
* indentation après :  0
*
* Cas particulier
*
* DEF mono-ligne
****************************************************

 gtDEF1 LC(2)  clDEF1	DEF mono-ligne
	A=C    B
	GOTO   gtok99

****************************************************
* indentation avant :  0
* indentation après :  1
*
* Cas particulier
*
* DEF multi-ligne
****************************************************

 gtDEF2 C=0    A
	C=C+1  A
	R2=C		Indentation après := 1

	LC(2)  clDEF2	DEF multi-ligne
	A=C    B
	GOTO   gtok99

****************************************************
* indentation avant :  0
* indentation après :  0
*
* Cas particulier
*
* DATA
****************************************************

 gtDATA LC(2)  clDATA	DATA
	A=C    B
	GOTO   gtok99

****************************************************
* indentation avant :  0
* indentation après :  0
*
* Cas particulier
*
* '...':
****************************************************

 gtLBL	LC(2)  clLBL	label
	A=C    B
	GOTO   gtok99

****************************************************
* indentation avant :  0
* indentation après :  0
*
* Cas particulier
*
* !
****************************************************

 gtREM	LC(2)  clREM	!
	A=C    B
	GOTO   gtok99

****************************************************
* indentation avant :  0
* indentation après :  0
*
* Cas particulier
*
* IF mono-ligne (standard)
****************************************************

 gtIF	LC(2)  clIF	IF standard
	A=C    B
	GOTO   gtok99

 gtRIEN A=0    B
 gtok99 C=RSTK
	D1=C
	RTNCC

	STITLE	RENUMREM

****************************************************
* RENUMREM
*
* But : renuméroter un programme Basic en tenant
*   compte des remarques.
* Note : RENUMREM 100 , 10 , 200 , 500
*		  -v-	-v-  -v-   -v-
* registres ->	   R0	R1   @R2    R3
* Historique :
*   86/05/.. : JPB     conception & codage
****************************************************

	REL(5) =RENUMREMd
	REL(5) =RENUMREMp
=RENUMREMe
	CD0EX
	R0=C
	GOSUB  CHKPSF
	GOSUB  GETSTe
	GOSBVL =PRSC00

 REN005 ST=1   1
	ST=1   2
	GOSBVL =RENSUB
	GOC    REN010
	D1=(5) =PCADDR
	C=R2
	DAT1=C A
	GOSUB  UPDCRL
	LC(2)  =eSTMNF	"Statement Not Found"
	GOTO   mferr

 REN010 A=R0
	D0=A
	GOSUB  LINE#1
	R2=A
	C=0    A
	C=C+1  A
	CSL    A
	R0=C
	R1=C
	CSL    A
	CSL    A
	CSL    A
	R3=C
	GOSUB  GETLN#
	GOC    REN100
	R0=A
	GOSUB  GETLN#
	GOC    REN100
	R1=A
	GOSUB  GETLN#
	GOC    REN100
	C=A    A
	AD0EX
	R2=A
	GOSBVL =FINDL
	?ST=0  0
	GOYES  REN020
	GOTO   nxtstm

 REN020 CD1EX
	CR2EX
	D0=C
	GOSUB  GETLN#
	GOC    REN100
	SETDEC
	P=     3
	A=A+1  WP
	P=     0
	SETHEX
	GOC    REN100
	C=A    A
	GOSBVL =FINDL
	A=0    A
	A=DAT1 4
	?ST=1  0
	GOYES  REN100
	R3=A

 REN100 GOSUB  LINE#1
	CD1EX
	A=R2
	?A=C   A
	GOYES  REN105
	D0=A
	D0=D0- 4
	GOSBVL =CPL#10
	C=0    A
	C=DAT1 4
	A=R0
	?A>C   A
	GOYES  REN105
	GOLONG invarg

 REN105 D1=(5) =CURREN
	C=DAT1 A
	D=C    A
	C=R2
	D1=C
	C=0    A
	C=DAT1 4
	D0=C
	C=R0
	RSTK=C

 REN110 C=R2
	D1=C
	A=R1
	B=A    A

 REN120 CD1EX
	?C>=D  A
	GOYES  ren170
	D1=C
	A=0    A
	A=DAT1 4
	C=R3
	?A>=C  A
	GOYES  ren170
	A=R0
	?A<C   A
	GOYES  REN140

 REN130 SETHEX
	CD0EX
	R0=C
	C=0    A
	C=C+1  A
	R1=C
	GONC   REN110
 ren170 GOTO   REN170

**************************************************
*   ORGANIGRAMME DE REN140 à REN155:
*   --------------------------------
*
* Entrée: RSTK = Anc [Next REM Line#]
*	  R0   = Nv  [Next BASIC Line#]
*	  B[B] = Inc [IncrEment]
*
*     -----------
*     |ECRIRE Nv|
*     -----------REN140
*	  |
*     -----------
*    <LIGNE REM ?>-----non-------
*     -----------		|
*	  |oui			|
*     ------------		|
*     |ECRIRE Anc|		|
*     ------------REN145	|
*	  |			|
*     -----------	  ----------
*     |Anc=Anc+1|	  |Anc=Nv+1|
*     -----------	  ----------
*	  |			|
*     ---------			|
*    < Anc>NV ?>--non--		|
*     ---------	      |		|
*	  |<---------------------
*    -----------      |
*    |Nv=Nv+Inc|REN   |
*    -----------150   |
*	  |<-----------
*	  |
*     #########
*     #REN 155#
*     ######### FIN
**************************************************

*
* ECRIRE Nv
*
 REN140 DAT1=A 4	LINE# = Nv
	D1=D1+ 6
	A=DAT1 B	A[B] = token
	D1=D1- 6
	LC(2)  =t!
	?A=C   B	Ligne REM ?
	GOYES  REN145	oui
	LC(2)  =tREM
	?A=C   B	Ligne REM ?
	GOYES  REN145	oui
	A=R0		non: Anc = Nv+1
	C=RSTK
	C=A    A
	SETDEC
	C=C+1  A
	RSTK=C
	GOTO   REN150
*
* ECRIRE Anc
*
 REN145 C=RSTK		C=Anc
	DAT1=C 4	Line# = Anc
	SETDEC
	C=C+1  A	Anc = Anc+1
	RSTK=C		Sauvegarde Anc
*
* On est toujours en DEC
*
	A=R0		A=Nv
	P=     3
	?C<=A  WP	Anc <= Nv ?
	GOYES  REN155	oui alors FIN
*
* Entrée: A=Nv ; B=Inc ; DEC
*
 REN150 A=A+B  A	Nv = Nv+Inc
	R0=A		Sauve Nv
*
* FIN: on remet tout en ordre pour REN160
*
 REN155 SETHEX
	P=     0
	D1=D1+ 4	D1 @ tLEN
	C=0    A

 REN160 C=DAT1 B
	AD1EX
	A=A+C  A
	D1=A
	A=DAT1 B
	D1=D1+ 2
	?A#0   P
	GOYES  REN160
	GOTO   REN120

 REN170 C=RSTK
	ST=1   1
	ST=0   2
	GOSBVL =RENSUB
	GOLONG nxtstm

 GETLN# A=DAT0 B
	D0=D0+ 2
	LC(2)  =tCOMMA
	?A#C   B
	RTNYES
	A=0    A
	A=DAT0 4
	D0=D0+ 4
	RTNCC

 LINE#1 D1=(5) =CURREN
	C=DAT1 A
	D=C    A
	D1=D1- 15
	A=DAT1 A
	C=0    A
	LC(2)  =oFLSTr
	A=A+C  A
	D1=A
	RTN

 CHKPSF GOSUB  GETSTe
	GOSBVL =GETPRO
	GOC    mferr
	?SB=0
	RTNYES
	GONC   mferr

 GETSTe GOSBVL =GETSTC
	RTNNC
 mferr	GOVLNG =MFERR

 UPDCRL D1=(5) =CURRST
	C=DAT1 A
	D1=C
	D1=D1+ (=oFTYPh)-1
	A=DAT1 A
	ASR    A
	LC(5)  =fBASIC
	?A#C   A
	GOYES  UPDCR1
	GOSBVL =D0=PCA
	GOSBVL =CPL#10
	C=DAT1 A
	GONC   UPDCR3
 UPDCR1 C=0    A
 UPDCR3 D0=(5) =CURRL
	DAT0=C 4
	RTNCC

	END
