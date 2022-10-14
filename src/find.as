	TITLE  FIND <find.as>

*
* Historique :
* 86/01/.. (JJM)
* - Première version
* - Conception & codage
* 86/12/.. (JT)
* - Deuxième version
* - Débogage
* - Suppression du message dans la version autonome
* - Positionnement du curseur
* 87/01/24 (PD/JT)
* - Intégration de la version de JT dans JPC Rom
* 88/04/15 (JT)
* - Commencement sur le blanc après le no de ligne
* - Correction de l'algorithme de recherche
* 89/06/11 (PD/JT)
* - Réécriture totale avec caractères génériques
* 89/06/17 (PD/JT)
* - Intégration dans JPC Rom
*

*
* Mémoire utilisée
*
* On sait que S-R0-2 est utilisé par LDCEXT
*
* LDEB   (5q) = numéro ligne de début
* CURADR (5q) = remplace LDEB par adresse courante
* LFIN   (5q) = numéro ligne de fin
* FILEND (5q) = adresse de la fin du fichier
* BUFFER (8q) = BUFID et BUFADR
* BUFID  (3q) = Id buffer (chaîne génér.)
* BUFADR (5q) = adresse buffer (chaîne génér.)
* TMP5   (5q) = utilisé par FND800
*
* Attention : BUFID et BUFADR doivent être une
* seule zone BUFFER placée dans cet ordre car on
* la remplit en bloc (DAT0=C 8)
*

 tmp10	EQU    =S-R0-0	10 quartets
 tmp27	EQU    =S-R0-3	27 quartets

 tmp	EQU    =FCNTMP	transform buffer

 LDEB	EQU    00+tmp	5 q : numéro ligne début
 CURADR EQU    00+tmp	5 q : adr. ligne courante
 LFIN	EQU    05+tmp	5 q : numéro ligne fin
 FILEND EQU    10+tmp	5 q : adr. fin fichier
 BUFFER	EQU    15+tmp	8 q : BUFID + BUFADR
 BUFID	EQU    15+tmp	3 q : id buffer
 BUFADR EQU    18+tmp	5 q : adr. buffer
 TMP5   EQU    23+tmp	5 q : voir FND800


 ESC	EQU    27

**************************************************
* bufdal
*
* But : désallouer le buffer alloué par COMPUX
* Entrée :
*   - BUFID = id du buffer
* Sortie : -
* Appelle : I/ODAL
* Niveaux : 2 (I/ODAL)
* Abime : A-C, D0, D1
* Historique :
*   89/06/11 : PD & JT conception & codage
**************************************************

 bufdal	D1=(5) BUFID
	C=DAT1 X	C(X) := buffer id
	GOVLNG =I/ODAL	P=0 en sortie (on espère!)

**************************************************
* FINDe
*
* But: chercher une ligne dans un fichier BASIC
* Syntaxe: FIND <chaine> [,<debut> [, <fin>]]
* Entrée:
*   - D0 = PC
* Sortie: par NXTSTM
* Abime:
* Niveaux:
* Appelle:
* Algorithme:
*   - vérifier le fichier (type, protection)
*   - chercher des numéros de ligne par défaut
*   - évaluer la chaîne et la déposer sur la M.S.
*   - compiler la chaîne (pour expr. génériques)
*   - évaluer les numéros de ligne
* Historique:
*   89/06/09: P.D. reconception & recodage
**************************************************

 mferr	GOVLNG =MFERR

*
* Il n'y a pas de routine de decompilation, car
* FIND n'est pas programmable.
*
	REL(5) =FINDp
=FINDe
	CD0EX
	RSTK=C		RSTK := D0
*
* Protection et type du fichier
*
	GOSBVL =GETPRO	Cy = 1 : fichier PRIVATE
	GOC    mferr	fichier privé
	GOSBVL =GETSTC	Cy = 1 : fichier pas BASIC
	GOC    mferr	fichier pas BASIC

	C=RSTK
	D0=C		D0 := PC
*
*  Tokenisation de FIND :
*
*  ... <exp> tCOMMA <line1> tCOMMA <line2> tEOL
*      ^
*      D0
*
	GOSBVL =EXPEXC	Evalue la chaîne
*
*  ... <exp> tCOMMA <line1> tCOMMA <line2> tEOL
*	     ^
*	     D0
*
	CD1EX
	RSTK=C		RSTK := top of M.S.
*
* Numéros de ligne par défaut = (CURRL+1, 9999)
*
	D1=(5) =CURRL
	A=0    A
	A=DAT1 4	A(A) := no ligne courante
	A=A+1  A	A(A) := première ligne
	D1=(4) LFIN
	LCHEX  9999	C(A) := #09999
	DAT1=C A	LFIN := 9999
	D1=D1- (LFIN)-(LDEB)
	DAT1=A A	LDEB := CURRL + 1

*
* Numéros de ligne introduits par l'utilisateur
*
	GOSUB  getli#	line1 ?
	GOC    FND050	FIND exp tEOL
	DAT1=A A	LDEB := line1
	D1=D1+ (LFIN)-(LDEB)
	GOSUB  getli#
	GOC    FND050	FIND exp tCOMMA line1 tEOL
* FIND exp tCOMMA line1 tCOMMA line2 tEOL
	DAT1=A A	LFIN := line2

 FND050 C=RSTK
	D1=C		D1 := ^ M.S.
*
* LDEB et LFIN sont maintenant positionnés.
*

*
* Il faut maintenant compiler la chaîne qui est
* sur la M.S.
*
	GOSBVL =POP1S	A(A) := long. en quartets
* Positionnement sur le premier caractère
	CD1EX
	C=C+A  A
	D1=C
	D1=D1- 2	D1 := ^ premier caractère
* Calcul du la longueur en octets
	C=0    M
	C=A    A
	CSRB
	A=C    A	A(A) := longueur en octets
* Compilation du motif
	GOSUBL =COMPUX
	GONC   FND060	Compilation réussie
	GOTO   buferr	libérer le buffer et BSERR
 FND060
*
* R0(7-3) = D1 = ^ début du buffer (les données)
* R0(2-0) = B(X) = buffer ID
*
	D0=(5) BUFFER
	C=R0		C(7-0) := caractéristique
	DAT0=C 8
*
* La chaîne sur la M.S. ne nous sert plus, on
* peut donc oublier la M.S.
*
	GOSBVL =COLLAP

*
* Recherche de l'adresse de la ligne courante
* ainsi que de l'adresse de la fin du fichier.
*
	D1=(5) LDEB	numéro première ligne
	C=DAT1 A
	GOSBVL =FINDL
*
* D(A) = ^ end of current file
* Cy = 1 : ligne trouvée (D1 = ^ line #)
* Cy = 0 :
*   programme vide : S0 = S1 = 1
*   aucune ligne > ligne demandée : S0 = 1
*   ligne trouvée > ligne demandée : S0 = S1 = 0
*	D1 = ^ line # juste après ligne demandée
*

* sauvegarde de l'adresse de la fin du fichier
	C=D    A
	D0=(5) FILEND
	DAT0=C A

* tests de validité sur la ligne trouvée
	GOC    FND080	ligne trouvée

	?ST=1  1	programme vide
	GOYES  notfnd	Not Found
	?ST=1  0	pas ligne > ligne demandée
	GOYES  notfnd
*
* D1 = ^ line # de la ligne courante
* (éventuellement après la ligne demandée)
* D0=(5) FILEND
*
 FND080	CD1EX		C(A) := ^ line #
	D0=(2) CURADR
	DAT0=C A	CURADR := ^ line #

**************************************************
* Les préparatifs sont finis, on peut commencer
* la boucle.
*************************************************

**************************************************
* FND200
*
* But : début de la boucle principale de FIND
*   c'est à dire tests de sortie
* Entrée : -
* Sortie :
*   si sortie nécessaire
*     alors sortie par NXTSTM
*     sinon D1 = ^ <line #>
*   fin si
* Détail :
*   test 1 : EOF ?
*   test 2 : no ligne > no derniere ligne a lister
*   test 3 : [ATTN] ?
* Appelle : CK"ON", NXTSTM
* Historique :
*   88/01/10 : PD & JT conception & codage
*   89/06/11 : PD & JT emprunt à D/PBLIST
**************************************************

 FND200
* 1 : atteint EOF ?
	D0=(5) CURADR
	A=DAT0 A	A(A) := ^ line#
	D0=(2) FILEND
	C=DAT0 A	C(A) := ^ FiLeNd
	?A>=C  A
	GOYES  notfnd
* 2 : atteint ligne > ligne fin ?
	D1=A		D1 := ^ line#
	A=0    A
	A=DAT1 4	A(A) := line#
	D0=(2) LFIN
	C=DAT0 A
	?A>C   A
	GOYES  notfnd
* 3 : [ATTN] ?
	CD1EX
	GOSBVL =CK"ON"
	D1=C
	GOC    FND210	on a passé tous les tests

*
* Libérer le buffer et sortir
* C(A) = numéro d'erreur
*
 notfnd	LC(4)  (=id)~(=eNFND)
 buferr	RSTK=C		RSTK := numéro d'erreur
	GOSUB  bufdal
	C=RSTK		C(A) := numéro d'erreur
	GOVLNG =BSERR

**************************************************
* FND210
*
* But : décompilation de la ligne et recherche
* Entrée :
*   - D1 = ^ <line #>
* Sortie :
*   - (OUTBS..AVMEMS) = ligne décompilée
* Appelle : LDCEXT, POSADR, NXTLIN
**************************************************

*
* Ok, on peut y aller
* D1 = ^ line#
*
 FND210
*
* On utilise LDCEXT car on veut libérer le buffer
* en cas d'erreur (qui peut seulement être memerr)
* C'est un appel non terminal.
*
	GOSBVL =LDCEXT
	GONC   FND220	Normal exit
	LC(4)  =eMEM
	GOC    buferr	B.E.T.
*
* D0 = ^ past ascii stream
* OUTBS = ^ start of ASCII stream
* LDCSPC = ^ blanc juste après le numéro de ligne
* A(A) = past tEOL of line decompiled
*
 FND220
*
* Sauver D0 dans TMP5 pour l'affichage final
* éventuel si on a trouvé.
*
	A=0    M	A(5-5) := 0 (plus tard)
	AD0EX		A(A) := ^ end of line
	D1=(5) TMP5
	DAT1=A A	TMP5 := ^ end of line

	D1=(2) BUFFER
	C=DAT1 8
	R0=C		R0 := caract. du buffer

	D1=(4) =LDCSPC
	C=DAT1 A	C(A) := ^ blanc
	C=C+1  A
	C=C+1  A	C(A) := ^ premier car.

* On a A(5-5) = 0, donc on peut faire le ASRB
	A=A-C  A	A(A) := long. en quartets
	ASRB		A(A) := long. en octets

	D0=C		D0 := ^ chaîne à chercher
	R1=C		R1 := ^ vrai début
*
* D0 = ^ chaîne à chercher
* A(A) = longueur (octets) de la chaîne à chercher
* R0(7-0) = caractéristique du buffer
* R1(A) = ^ vrai début de la chaîne à chercher
*
	GOSUBL =POSADR
*
* Cy = 1 : ligne trouvée
*   - D0 = ^ occurrence dans la chaîne objet
*   - C(A) = longueur de l'occurrence trouvée
* Cy = 0 : match not found ou erreur
*
	GOC    FND800	ligne trouvée
*
* Passage à la ligne suivante
*
	D1=(5) CURADR
	C=DAT1 A	A(A) := ^ line #
	D1=C		D1 := ^ line #
	GOSBVL =NXTLIN	D1 := ^ past tEOL
	CD1EX
	D1=(5) CURADR
	DAT1=C A	nouvelle ligne
	GOTO   FND200

**************************************************
* FND800
*
* But : l'occurrence est trouvée
* Entrée :
*   - (OUTBS..AVMEMS) = chaîne décompilée
*   - D0 = ^ occurrence dans la chaîne objet
*   - C(A) = longueur de l'occurrence
* Sortie :
*   - par NXTSTM
* Historique :
*   89/06/11 : PD & JT conception & codage
**************************************************

 FND800
*
* Mémorisation du numéro de ligne courante
*
	D1=(5) CURADR
	A=DAT1 A
	D1=A		D1 := ^ line #
	A=DAT1 4	A(3-0) := line #
	D1=(5) =CURRL
	DAT1=A 4
*
* Calcul du nombre de déplacements vers la droite
*
	C=0    M	C(5-5) := 0
	D1=(4) =OUTBS
	A=DAT1 A	A(A) := ^ début ligne
	CD0EX		C(A) := ^ occurrence
	C=C-A  A	C(A) := nb de quartets
	CSRB		C(A) := nb d'octets
	R3=C		R3(A) := déplacement
*
* Affichage de la ligne
*
	GOSUB  FND825
	CON(2) ESC	Curseur Eteint
	CON(2) '<'
	CON(2) '>'	Prompt Basic
	CON(2) ESC	Curseur Allumé
	CON(2) '>'
	NIBHEX FF	fin de séquence
 FND825	C=RSTK
	D1=C		D1 := ^ ESC < > ESC >
	GOSBVL =BF2DSP	Affiche le prompt

	D0=(5) TMP5
	C=DAT0 A	C(A) := ^ end of line
	D0=(4) =OUTBS
	A=DAT0 A	A(A) := ^ start of line
	C=C-A  A	C(A) := long. de la ligne
	B=0    M	B(5-5) := 0
	B=C    A	B(A) := long. en quartets
	BSRB		C(A) := long. en octets
*
* B(A) = longueur de la ligne décompilée
* OUTBS = ^ début de la ligne
*
	GOSBVL =DSPCNO	Affiche OUTBS
*
* Positionnement du curseur sur l'occurrence
*
	C=R3		C(A) := déplacement
	GOSBVL =CURSRT	cursor far left + C right

*
* Désallocation du buffer
*
	GOSUB  bufdal
	GOVLNG =MAIN30	retour à Basic

*
* GETLI# EST UNE ROUTINE EMPRUNTEE A D/PBLIST
*

**************************************************
* getli#
*
* But : evaluer un numero de ligne optionnel
* Entrée :
*   - D0 = ^ tCOMMA precedant <line #>
* Sortie :
*   Cy = 1 : pas de <line #>
*   Cy = 0 :
*     - A(A) = numero de ligne en BCD
*     - D0 reactualise
* Niveaux : 0
* Utilise : C(B), A(A)
* Historique :
*   86/05/..: JPB     conception & codage
*   88/01/10: PD & JT modification & documentation
**************************************************

 getli# A=DAT0 B
	LC(2)  =tCOMMA
	?A#C   B
	RTNYES
	D0=D0+ 2
	A=0    A
	A=DAT0 4
	D0=D0+ 4
	RTN		Cy = 0 a cause de D0=D0+ 4

	END
