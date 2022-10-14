	TITLE	Editeur, décomposition des cmd <xdec.as>

*
* Variables temporaires
*
 tmp	EQU	(=SCRTCH)-1

 val	EQU	(tmp)-5		5 q dans expr
 signe	EQU	(tmp)-6		1 q dans expr

 sauve	EQU	=STMTR0		20 q pendant recherche
 debut	EQU	(=STMTR0)+20	5 q pendant "expr"

************************************************************
* skip
*
* But: sauter les blancs
* Entree:
*   - D1 = ^ chaîne
*   - D(A) = nb de caractères
* Sortie: -
* Abime: A(B), C(B)
* Appelle: lookah, getchr
* Niveaux: 1
* Historique:
*   88/05/14: PD/JT conception & codage
*   88/05/15: PD/JT isolement dans un module séparé
************************************************************

=skip	LCASC	' '
 skip10	GOSUB	=lookah
	RTNC		Plus de caractère
	?A#C	B
	RTNYES
	GOSUB	=getchr
	GONC	skip10	B.E.T.

************************************************************
* lookah, getchr
*
* But: lire un caractère, et passer au suivant (getchr)
* Entree:
*   - D1 = ^ chaîne
*   - D(A) = nb de caractères
* Sortie:
*   - Cy = 1 : fin de la chaîne
*   - Cy = 0, A(B) = caractère lu
* Abime: A(B)
* Appelle: -
* Niveaux: 0
* Historique:
*   88/05/14: PD/JT conception & codage
*   88/05/15: PD/JT isolement dans un module séparé
************************************************************

=getchr	?D=0	A
	RTNYES
	D=D-1	A
	A=DAT1	B
	D1=D1-	2
	RTN		Cy = 0

=lookah	?D=0	A
	RTNYES
	A=DAT1	B
	RTN		Cy = 0

************************************************************
* xeddec
*
* But: décomposer une ligne de commande
* Entree:
*   - LCMD, PCMD positonnés
* Sortie:
*   - Cy = 1 : rien trouvé
*   - Cy = 0 : trouve une commande (éventuellement nulle)
*     A(B) = cmd (en majuscule, 0xff si pas de commande)
*     D(A) = longueur de PARAM
*     D1 = adresse de PARAM
*     R0 = nblignes (0, 1 ou 2)
*      R1 = ldebut
*      R2 = lfin
*     R3 = query (1 si '?' reconnu avant la commande)
* Attention: PCMD et LCMD ne sont pas bien positionnés en
*   sortie. Pour cela, il faut que chaque commande appelle
*   setCMD pour stocker D1 et D(A) dans CMD.
* Abime: A, C, D, D1
* Appelle: skip, getchr, lookah, linenb, nbli++, expr
* Niveaux: 3
* Historique:
*   88/05/15: PD/JT conception & codage
*   88/10/16: PD/JT retrait de la "," obligatoire dans HP-UX
************************************************************

=xeddec	D1=(5)	=MODE71
	C=DAT1	S	C(S) := mode71 pour tout à l'heure
*
* Positionne D(A) et D1 pour utilisation de getchr et lookah
*
	D1=(2)	=LCMD
	C=DAT1	A
	D=C	A	D(A) := longueur
	D1=(2)	=PCMD
	C=DAT1	A
	D1=C		D1 := ^ caractère à lire
*
* Y-a-t'il quelque chose dans la ligne de commande ?
*
	GOSUB	=skip
	GOSUB	=lookah
	RTNC		Cy = 1 : rien trouvé
*
* Il y a quelque chose.
*
	C=0	A
	R0=C		nblignes := 0
*
* Mode HP-71 ou HP-UX ?
*
	?C=0	S	Si si, ça tient dans C(S) !
	GOYES	dec100	Mode HP-UX

************************************************************
* Mode HP-71
************************************************************
*
* [ldebut [[,] lfin]] [?] [cmd] [param]
* ^
*
	GOSUB	linenb
	GOC	dec050	ldebut non reconnu
*
* [ldebut [[,] lfin]] [?] [cmd] [param]
*        ^
*
	R1=A		R1 := ldebut
	GOSUB	nbli++	nblignes++

	GOSUB	=skip
	GOSUB	=lookah
	GOC	dec050	EOL
	LC(2)	','
	?A#C	B
	GOYES	dec020	virgule non reconnue

	GOSUB	=getchr	passer la virgule
*
* [ldebut [[,] lfin]] [?] [cmd] [param]
*             ^
*
	GOSUB	linenb
	GONC	dec030	lfin reconnu
	LC(4)	=eMSPAR	"5,"
	GOTO	erreur

 dec020	GOSUB	linenb
	GOC	dec050	lfin non reconnu
*
* [ldebut [[,] lfin]] [?] [cmd] [param]
*                   ^
*
 dec030	R2=A		R2 := lfin
	GOSUB	nbli++	nblignes++
 dec050	GOTO	dec200

************************************************************
* Mode HP-UX
************************************************************

 dec100
*
* [ldebut [[,] lfin]] [?] [cmd] [param]
* ^
*

*
* ajout du 88/10/07 :
* ligne de départ de la recherche = courante
	D0=(5)	=COUR
	A=DAT0	A
	D0=(5)	debut	debut := COUR
	DAT0=A	A
* fin de l'ajout
*
	GOSUB	expr
	GOC	dec200	ldebut non reconnu
	R1=A		ldebut
	GOSUB	nbli++	nblignes++
*
* ajout du 88/10/07 :
* ligne de départ de la recherche = ldebut
	A=R1
	D0=(5)	debut	debut := R1
	DAT0=A	A
* fin de l'ajout

*
* [ldebut [[,] lfin]] [?] [cmd] [param]
*        ^
*
	GOSUB	=lookah
	GOC	dec200
	LCASC	','
	?A#C	B
	GOYES	dec120	virgule non reconnue
	GOSUB	=getchr
*
* [ldebut [[,] lfin]] [?] [cmd] [param]
*             ^
*
	GOSUB	expr
	GONC	dec130
	LC(4)	=eMSPAR	Missing parameter
	GOTO	erreur

 dec120	GOSUB	expr
	GOC	dec200	nombre non reconnu
*
* [ldebut [[,] lfin]] [?] [cmd] [param]
*                    ^
*
 dec130	R2=A		lfin
	GOSUB	nbli++	nblignes++
*
* Attention ! le code continue !
*

************************************************************
* Partie commune HP-71/HP-UX
************************************************************

 dec200	GOSUB	=skip
*
* [?] [cmd] [param]
* ^
*
	C=0	S	query := 0

	GOSUB	=lookah
	GOC	dec300	EOL
	LCASC	'?'
	?A#C	B
	GOYES	dec300
	GOSUB	=getchr	pligne++
	C=C+1	S	query := 1
 dec300 R3=C		query := 0 ou 1
*
* [?] [cmd] [param]
*    ^
*
	GOSUB	=skip
	GOSUB	=lookah
	GOC	dec320	EOL
*
* Fin de commande (';')
*
	LCASC	';'
	?A#C	B
	GOYES	dec350
 dec320	A=0	B
	A=A-1	B	cmd := 0xff
	GOC	dec900	fin de decomp (B.E.T.)
*
* cas général
*
 dec350	GOSUB	=getchr	A(B) := cmd (caractère existe)
	B=A	B	protéger A(B)
	GOSUB	=skip
	A=C	A
	ABEX	A	A(A) := cmd ; B(A) := len(param)
	GOSBVL	=CONVUC	A(B) := cmd en majuscule

************************************************************
* fin de decomp
************************************************************

 dec900	RTNCC		Un seul point de retour: c'est beau

************************************************************
* linenb
*
* But: lire un numéro de ligne
* Entree:
*   - D1 = ^ chaîne
*   - D(A) = nb de caractères
* Sortie:
*   - Cy = 1 : non reconnu
*   - Cy = 0, A(A) = nombre reconnu
* Abime: A(A), C(A)
* Appelle: skip, getchr, lookah, DRANGE, nombre (tombe deds)
* Niveaux: 1
* Historique:
*   88/05/14: PD/JT conception & codage
*   88/05/15: PD/JT isolement dans un module séparé
************************************************************

 linenb	GOSUB	=skip
	GOSUB	=lookah
	LCASC	'.'
	?A#C	B
	GOYES	lnb010
	GOSUB	=getchr
	D0=(5)	=COUR	return courante ;
	A=DAT0	A
	RTN		Cy = 0
 lnb010	LCASC	'#'
	?A#C	B
	GOYES	lnb020
	GOSUB	=getchr
	D0=(5)	=DERN	return derniere ;
	A=DAT0	A
	RTN		Cy = 0
 lnb020

*
* Attention ! le code continue !
*

************************************************************
* nombre
*
* But: lire un nombre
* Entree:
*   - D1 = ^ chaîne
*   - D(A) = nb de caractères
* Sortie:
*   - Cy = 1 : nombre non reconnu
*   - Cy = 0, A(A) = nombre reconnu
* Abime: A(A), B(A), C(A) (D(A) et D1 réactualisés)
* Appelle: skip, getchr, lookah, DRANGE
* Niveaux: 1
* Historique:
*   88/05/14: PD/JT conception & codage
*   88/10/29: PD/JT ajout du test de EOL
*   88/10/29: PD/JT documentation
************************************************************

*
* Attention ! Le code vient d'en haut...
*
=nombre	GOSUB	=lookah
	RTNC		Non, il n'y a rien...
	GOSBVL	=DRANGE
	RTNC		Non, il n'y a rien...
	B=0	A
 nbr010	GOSUB	=lookah
	GOC	nbr090	EOL
	GOSBVL	=DRANGE
	GOC	nbr090	not in [0..9]
	GOSUB	=getchr

	C=B	A	Vérification que B < 65536
	P=	4
	C=0	P
	P=	0
	?B#C	A
	GOYES	ivarg

	C=0	A	Ok, on peut encore multiplier par 10
	LCASC	'0'
	C=A-C	B	C(A) := ATH(A(B))
	B=B+B	A
	A=B	A	A(A) := 2b
	B=B+B	A
	B=B+B	A	B(A) := 8b
	B=A+B	A	B(A) := 10b
	B=B+C	A	B(A) := 10b + C(A)
	GONC	nbr010	B.E.T.
 ivarg	LC(4)	=eIVARG
	GOTO	erreur
 nbr090	A=B	A
	RTNCC		Cy = 0

************************************************************
* expr
*
* But: analyser une expression à la syntaxe HP-UX
* Entree:
*   - D1 = ^ chaîne
*   - D(A) = nb de caractères
*   - debut = numéro de la ligne de debut de recherche
* Sortie:
*   - Cy = 1 : non reconnu
*   - Cy = 0, A(A) = nombre reconnu
* Abime: val, signe, A(A), C(S), C(A), D0, D1
* Appelle: skip, expelm, lookah, getchr
* Niveaux: 
* Historique:
*   88/05/24: PD/JT conception & codage
*   88/10/07: PD/JT ajout de "debut" dans la recherche
************************************************************

 expr	GOSUB	expelm
	RTNC		nombre non reconnu
 expr00	D0=(5)	val
	DAT0=A	A	val := A(A)
	GOSUB	=skip
	GOSUB	=lookah
	GOC	expr99	sortir enfin
	C=0	S
	LCASC	'+'
	?A=C	B
	GOYES	expr10	C(S) := #0 pour '+'
	C=C-1	S	C(S) := #F pour '-'
	LCASC	'-'
	?A#C	B
	GOYES	expr99	sortir si ni '+', ni '-'
 expr10	D0=(5)	signe
	DAT0=C	S	signe := 0 si '+', #F si '-'
	GOSUB	=getchr	passer l'opérateur
	GOSUB	expelm
	GONC	expr20	ok...
	LC(4)	=eSYNTX	"5-"
	GOTO	erreur
 expr20	D0=(5)	signe
	C=DAT0	S
	D0=(2)	val
	C=DAT0	A
	?C=0	S
	GOYES	expr30	'+'
	ACEX	A
	A=A-C	A	'-'
	GONC	expr00	si tout va bien
	GOC	Ivarg	B.E.T.
 expr30	A=A+C	A
	GONC	expr00	si tout va bien
 Ivarg	GOTO	ivarg	B.E.T.

 expr99	D0=(5)	val
	A=DAT0	A
	RTNCC		Ok, ca a marché....

************************************************************
* expelm
*
* But: analyser un élément d'expression à la syntaxe HP-UX
* Entree:
*   - D1 = ^ chaîne
*   - D(A) = nb de caractères
*   - debut = numéro de la première ligne de la recherche
* Sortie:
*   - Cy = 1 : non reconnu
*   - Cy = 0, A(A) = nombre reconnu
* Abime: 
* Appelle: skip, lookah, GETSRC, getchr
* Niveaux: 
* Historique:
*   88/05/24: PD/JT conception & codage
*   88/10/07: PD/JT ajout de "debut" dans la recherche
*   88/10/15: PD/JT modification pour nouveau GETSRC
************************************************************

 expelm	GOSUB	=skip
	GOSUB	=lookah
	LCASC	'.'
	?A#C	B
	GOYES	exl010
	GOSUB	=getchr
	D0=(5)	=COUR	return courante ;
	A=DAT0	A
	RTN		Cy = 0
 exl010	LCASC	'$'
	?A#C	B
	GOYES	exl020
	GOSUB	=getchr
	D0=(5)	=DERN	return dernière ;
	A=DAT0	A
	RTN		Cy = 0
 exl020	LCASC	'/'
	?A=C	B
	GOYES	exl030
	GOTO	=nombre	"default"

 exl030
*
* Recherche : /.../
*
	P=	4	sauver 5 niveaux
	GOSBVL	=R<RSTK

	D0=(5)	sauve	qui peut !
	C=R0		R0(A)
	DAT0=C	A
	D0=D0+	5	R1(A)
	C=R1
	DAT0=C	A

	GOSUBL	=GETSRC	compiler la chaîne de recherche
	GOC	erreur
	GOSUB	=getchr	passer le délimiteur (88/10/15)
*
* R0(7-0) = caractéristiques du buffer
* D1 et D(A) réactualisés
*
	D0=(5)	(sauve)+10
	CD1EX
	DAT0=C	A
	D0=D0+	5
	C=D	A
	DAT0=C	A

	D0=(5)	debut
	A=DAT0	A
	A=A+1	A	A(A) := debut + 1
	D0=(5)	=DERN
	C=DAT0	A	C(A) := dernière
	?A>C	A
	GOYES	exl035
	GOSUBL	=SRCLIN
	GOC	exl040	match found

 exl035	A=0	A
	A=A+1	A	A(A) := 1
	D0=(5)	debut
	C=DAT0	A	C(A) := début
	?A>C	A
	GOYES	notfnd
	GOSUBL	=SRCLIN
	GOC	exl040	match found

 notfnd	LC(4)	(=id)~(=eNFND)	"Not Found"
 erreur	GOTO	=xederr	aie aie aie...

*
* Match found
*   A(A) = ligne trouvée
*
 exl040	R1=A		Sauvegarde de A(A)
	GOSUBL	=ENDPOS	Achever le buffer (arghhh)
	A=R1		Restauration de A(A)

	C=0	W	on en profite pour nettoyer
	D0=(5)	sauve	R0(A)
	C=DAT0	A
	R0=C
	D0=D0+	5	R1(A)
	C=DAT0	A
	R1=C
	D0=D0+	5	D1
	C=DAT0	A
	D1=C
	D0=D0+	5	D(A)
	C=DAT0	A
	D=C	A

	P=	4	restaurer 5 niveaux
	GOSBVL	=RSTK<R

	RTNCC		on a trouvé !

************************************************************
* nbli++
*
* But: incrémenter R0
* Entree:
*   - R0
* Sortie:
*   - R0 := R0+1
* Abime: C(W)
* Niveaux: 0
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

 nbli++	CR0EX
	C=C+1	A
	CR0EX
	RTN

	STITLE	Routines de support

************************************************************
* GETFIL
*
* But: lire un nom de fichier, chercher ce fichier ou le
*   créer selon les flags.
* Entree:
*   - D1 = ^ chaîne
*   - D(A) = nb de caractères
*   - sDELET = 0 : cas C/M
*   - sDELET = 1 : cas D ou X
*	- sXCHG = 1 : cas X
*	- sXCHG = 0 : cas D
* Sortie:
*   - Cy = 1 : erreur
*	C(3-0) = numéro d'erreur
*   - Cy = 0 : pas d'erreur
*	EXTFIL = adresse du header du fichier
*	sCREAT = 1 : fichier cree
* Abime: A-D, R0-R3, D0, D1, S0-S9, STMTxx, FUNCxx
* Appelle: ADHEAD, FILXQ$, FINDF+, CRETF+
* Niveaux: 6 (CRETF+)
* Algorithme:
*   création d'une chaîne sur la M.S. contenant le nom
*     (la chaîne s'arrete sur '+', ';' ou EOL)
*   si DELET = 1
*     alors
*       si XCHG = 1
*         alors plus := true
*         sinon plus := (caractère lu == '+')
*       fin si
*   fin si
*   FILXQ$
*   FINDF+
*   si il existe
*     alors
*       si DELET=1 et not plus
*         alors erreur (File Exists)
*       fin si
*     sinon
*       si DELET=0
*         alors erreur (File Not Found)
*         sinon CRETF+
*       fin si
*   fin si
*   vérifier que le type est TEXT
*   retourner l'adresse dans EXTFIL
* Historique:
*   88/10/31: PD/JT conception & codage
*   88/11/11: PD/JT modification pour la commande 'X'
************************************************************

=sDELET	EQU	09	flag D (par opposition à C/M)
=sXCHG	EQU	10	cas D ou X ? (apres : '+' reconnu)
=sCREAT	EQU	11	fichier créé par nos soins

 sPLUS	EQU	=sXCHG	flag plus utilisé apres son test

=GETFIL	ST=0	=sCREAT	fichier non encore créé
	D0=(5)	=EXTFIL	par défaut, EXTFIL := 0
	C=0	A
	DAT0=C	A

	D0=(5)	=AVMEMS
	C=DAT0	A
	B=C	A	B(A) := AVMEMS
	D0=D0+	5	D0=(5)	=AVMEME
	C=DAT0	A
	D0=C		D0 := ^ début de la M.S.
	R1=C		pour ADHEAD tout à l'heure

 GF010	GOSUB	=lookah
	GOC	GF100	EOL
	LCASC	' ;+'	ensemble (espace, ';', '+')
	P=	3*2-1
	GOSBVL	=MEMBER	n'abime que C(WP)
	GONC	GF100	byte in set
*
* Mettre le caractère dans la M.S. (pointée par D0)
*
	GOSUB	=getchr	passer le caractère
* Ce qui suit est très fortement inspiré de STKCHR (#18505)
	D0=D0-	2
	CD0EX
	?C<B	A
	GOYES	GF090	Memerr
	CD0EX
	DAT0=A	B
	GONC	GF010	B.E.T.

 GF090	LC(4)	=eMEM
	RTNSC		Beeeeeeep !

 rtncc	RTNCC
*
* Fin de la chaîne. Si la longueur est nulle, alors sortir
* sans avoir rien reconnu.
*
 GF100	CD0EX		C(A) := ^ haut de la M.S.
	A=R1		A(A) := ^ bas de la M.S.
	?A=C	A
	GOYES	rtncc	sortie sans erreur
	D0=C		sauvegarde temporaire dans D0
*
* Le nom du fichier a été reconnu et est dans la M.S.
*
	GOSUB	=skip
*
* Reconnaître le '+' seulement si 'D' (et pas C/M ou X)
* si sDELET = 1
*   alors
*     si sXCHG = 1
*       alors plus := true
*       sinon plus := '+' reconnu ? true : false
*     fin si
* fin si
*
	?ST=0	=sDELET	cas 'D' ?
	GOYES	GF150	non
	?ST=1	=sXCHG	cas 'X' ?
	GOYES	GF150	oui, donc plus := true (deja vrai)
*
* On sait que XCHG = 0. Donc sPLUS = 0
* l'instruction "ST=0	sPLUS" est inutile"
*
	GOSUB	=lookah
	LCASC	'+'
	?A#C	B	caractère suivant = '+' ?
	GOYES	GF150	non
*
* '+' reconnu
*
	GOSUB	=getchr	passer le '+'
	GOSUB	=skip
	ST=1	sPLUS	plus := true
*
* Sauver les meubles !!! (D1 et D(A))
*
 GF150	CD1EX
	D1=(5)	=STMTR0
	DAT1=C	A	STMTR0+00 := D1
	D1=D1+	5
	C=D	A
	DAT1=C	A	STMTR0+05 := D(A)

*
* D0 = ^ haut de la M.S.
* R1 = ^ bas de la M.S.
* sDELET = 1 si commande 'D', 0 si commande 'C' ou 'M'
* sPLUS = 1 si commande 'D' et '+' reconnu
* STMTR0(4-0) = sauvegarde de D1
* STMTR0(9-5) = sauvegarde de D(A)
*

*
* Construire le M.S. header et chercher le fichier
*
	CD0EX
	D1=C		D1 = ^ haut de la M.S.
	D0=(5)	=AVMEMS
	C=DAT0	A
	D=C	A	D(A) := AVMEMS
	ST=1	0	rtn desired
*
* D1 = ^ top of M.S.
* R1 = ^ bottom of M.S.
* D(A) = AVMEMS
* S0=1
*
	GOSBVL	=ADHEAD	D1 = ^ string header

	GOSBVL	=FILXQ$
	GOC	GF160	pas d'erreur

 ivfspc	LC(4)	=eFSPEC	
	RTNSC

 GF160
*
* Spécificateur valide.
* A(W) = file name ou 0
* D(S) = F if no device specified
*	 0 if :MAIN
*	 1 if :PORT
*	 7 if :CARD
* La vérification du spécificateur sera faite par FINDF+
* Maintenant, il faut chercher le fichier.
* A(W) = le nom
* D(S) et D(B) = device specifier
*

*
* Sauvegarde de A(W) et D(S)-D(B)
* dans STMTR0(10-25) et STMTR0(28-26)
*
	D0=(5)	10+=STMTR0
	DAT0=A	W
	D0=D0+	16
	C=D	W
	CSLC		C(2-0) = D(S) + D(B)
	DAT0=C	3

*
* Chercher le fichier
*
	GOSBVL	=FINDF+
	GOC	GF300	fichier n'existe pas
*
* Le fichier existe
*
* D1 = ^ header du fichier
*
 GF200	?ST=0	=sDELET	pour les commandes 'C' et 'M'
	GOYES	GF205	le fichier doit exister
	?ST=0	sPLUS	si D et pas +, il doit pas exister
	GOYES	fexist	pas plus => erreur
 GF205	GOTO	GF900	rallonge

 fexist	LC(4)	=eFEXST	"File Exists"
	RTNSC
 fnfnd	LC(4)	=eFnFND	"File Not Found"
	RTNSC

*
* Le fichier n'existe pas
*
 GF300	?ST=0	=sDELET	commande 'C' ou 'M' ?
	GOYES	fnfnd	oui : "File Not Found"
*
* Le fichier n'existe pas, mais il faut le créer pour la
* commande 'D'
*
	D0=(5)	16+10+=STMTR0
	C=DAT0	3
	CSRC
	D=C	W	D(W) := comme apres FILXQ$

	C=0	A
	LC(2)	37+4	header + EOF mark
	GOSBVL	=MEMCKL
	RTNC		Not Enough Memory

	C=B	A	C(A) := amount to check (MEMCKL)
*
* C(A) = taille du buffer en nibs
* D = conditions de sortie de FILXQ$
*
	GOSBVL	=CRETF+	Théoriq., le Lex ne doit pas bouger
	RTNC		erreur !

	ST=1	=sCREAT	fichier cree !
*
* R1 = ^ début du nouveau fichier
* manque le nom et le type
*
	C=R1
	D1=(5)	10+=STMTR0
	A=DAT1	W
	D1=C
	DAT1=A	W	nom du fichier
	D1=D1+	16
	LCHEX	400001	text + copy code
	DAT1=C	6
	D1=D1+	16
	D1=D1+	5
	C=0	A
	C=C-1	A	C(3-0) := #FFFF
	DAT1=C	4	EOF mark

	C=R1		C(A) := ^ début du fichier
	D1=C		D1 := ^ début du fichier

*
* D1 = ^ header du fichier trouvé ou créé
* STMTR0(9-0) = sauvegarde de D1 et D(A)
*
 GF900
	CD1EX
	D1=(5)	=EXTFIL
	DAT1=C	A
*
* Vérifier que le fichier est bien TEXT
*
	D1=C
	GOSUBL	=CHKTXT
	RTNC		C(A) = eFTYPE
*
* Restaurer les meubles (D1 et D(A))
*
 GF910	D0=(5)	=STMTR0
	C=DAT0	A
	D1=C
	D0=D0+	5
	C=DAT0	A
	D=C	A
	RTNCC		sortie sans erreur

	END
