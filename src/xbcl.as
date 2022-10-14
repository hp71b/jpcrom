	TITLE	Editeur, boucle principale <xbcl.as>

*
* Variables utilisées par les fonctions et par XEDIT
* Tout le reste de TRFMBF est donc disponible
*
=MODE71	EQU	00+=TRFMBF	1q si mode = HP-71
=QUERY	EQU	01+=TRFMBF	1q si mode = "?" pour S/R
=FCNTMP	EQU	02+=TRFMBF	58 quartets pour le scratch

*
* Variables utilisées par XEDIT seulement.
*
=BUFID	EQU	02+=TRFMBF	3q
=BUFADR	EQU	05+=TRFMBF	5q

=FILADR	EQU	10+=TRFMBF	5q
=COUR	EQU	15+=TRFMBF	5q no de ligne courante
=DERN	EQU	20+=TRFMBF	5q no de la dernière ligne
=PCMD	EQU	25+=TRFMBF	5q pteur dans la cmd
=LCMD	EQU	30+=TRFMBF	5q longueur de la cmd
=FLAG1	EQU	35+=TRFMBF	1q état du flag 1 à l'entrée
=RDONLY	EQU	36+=TRFMBF	1q fichier read-only

*
* Tout le reste (à savoir 23 quartets) est disponible
* pour des variables temporaires dans XEDIT
*
=XEDTMP	EQU	37+=TRFMBF	23q : variables temporaires

*
* En particulier, la fonction GENRPLC$ et la commande R
* utilisent 10 quartets pour stocker les coefficients "a" et
* "b" utilisés lors du remplacement. Voir la documentation
* CALCab.
* Cette zone peut être utilisée par toute routine
* n'utilisant pas REPLIN ou REPLFIL.
*
=coeffa	EQU	(=SCRTCH)-10
=coeffb	EQU	(=coeffa)+5

*
* Diverses zones de scratch
*
=TMP5	EQU	=LDCSPC
=TMP3	EQU	=STSAVE
=TMP1	EQU	(=SCRTCH)-1


*
* Constantes globales :
*
=FL1MSK	EQU	%0010	flag 1 = 1 dans les flags 3-0
=NCMDED	EQU	13	nombres de commandes (0-13)

************************************************************
* poparg
*
* But : dépiler un nombre de la M.S. et le vérifier
* Entree :
*   - D1 = ^ top of M.S.
* Sortie :
*   - A(A) = C(A) = nombre dépilé (0 < nb <= 255)
* Abime: A, B(S), B(A), C(A), D(A)
* Appelle: RNDAHX
* Niveaux: 4 (RNDAHX)
* Historique:
*   88/05/13: PD/JT conception & codage
************************************************************

 poparg	GOSBVL	=RNDAHX
	GONC	ivarg	L < 0
	?A=0	A
	GOYES	ivarg
	C=0	A
	C=A	B
	?A=C	A
	RTNYES
 ivarg	GOVLNG	=IVAERR

************************************************************
* nxtexp
*
* But: évaluer la prochaîne expression
* Entree:
*   - D0 = ^ chaîne tokenisée (sur tCOMMA ou tEOL)
* Sortie:
*   - Cy = 1 si tEOL reconnu
*   - Cy = 0 et expression sur la M.S. (A(W) = top 16 nibs)
* Abime: tous les registres, FUNCtion scratch
* Appelle: EOLXCK, EXPEXC
* Niveaux: 4 (EXPEXC)
* Historique:
*   88/05/13: PD/JT conception & codage
************************************************************

 nxtexp	A=DAT0	B
	D0=D0+	2
	GOSBVL	=EOLXCK
	RTNC		tEOL trouvé
	GOVLNG	=EXPEXC	Cy = 0 en sortie

************************************************************
* XEDITe, TEDITe
*
* But: éditeur de texte
* Entree:
*   - le nom du fichier
*   - une chaîne de commande optionnelle
* Abime: tout
* Appelle: ????????
* Niveaux: 7 niveaux sont autorisés pour les statements
* Historique:
*   88/05/13: PD/JT conception & codage
*   89/06/17: PD/JT retrait des paramètres largeur/hauteur
************************************************************

	REL(5)	=TEDITd
	REL(5)	=TEDITp
=TEDITe ST=1	0	Mode HP-71 := true
	GOTO	XED000

	REL(5)	=XEDITd
	REL(5)	=XEDITp
=XEDITe	ST=0	0	Mode HP-71 := false
 XED000	D1=(5)	=TRFMBF
	LC(5)	60	60 quartets
	GOSBVL	=WIPOUT	TRFMBF rempli avec des 0

	?ST=0	0	mode HP-71 ?
	GOYES	XED010	non : on saute
	LC(1)	1
	D1=(5)	=MODE71
	DAT1=C	P	MODE71 := 1
 XED010
*
* Analyse du fichier
*
	GOSUBL	=FILE1	Evalue la spécification

*
* Analyse de la chaîne de commande
*
	GOSUB	nxtexp	Expression suivante
	GOC	XED050	tEOL trouvé
	GOSBVL	=POP1S
	CD1EX
	D1=(5)	=AVMEME
	DAT1=C	A	AVMEME := ^ bas de la M.S.
	C=C+A	A	C(A) := ^ début de la chaîne
	C=C-1	A
	C=C-1	A
	D1=(4)	=PCMD
	DAT1=C	A	PCMD := ^ premier caractère
	C=0	W
	C=A	A
	CSRB		C(A) := longueur en octets
	D1=(2)	=LCMD
	DAT1=C	A	LCMD := longueur en octets
*
* Recherche du fichier, et copie éventuelle
*
 XED050
	ST=1	1	Copie éventuelle
	ST=1	2	Création éventuelle
	GOSUBL	=FILE2
*
* Le fichier est trouvé. On a son adresse dans C(A)
*
	GOSUBL	=CHKWRT	Modifiable ?
	D1=(5)	=RDONLY
	DAT1=C	S	RDONLY := 0 (write) 1..3 (read-only)

	D1=(4)	=FILADR	Adresse de l'en-tete
	DAT1=C	A	FILADR := adresse de l'en-tete

	D1=C		D1 := ^ file header

	GOSUBL	=CHKTXT	Est-ce un fichier TEXT ?
	GONC	XED080	Oui

 bserr	GOVLNG	=BSERR

 XED080
*
* inibuf initialise le tableau de pointeurs dans le texte.
* Cette routine commence par désallouer le buffer dont le
* numéro est dans BUFID. Cela ne nous gêne pas car nous
* avons fait un WIPOUT sur toutes les variables au début.
*
	GOSUBL	=inibuf

	C=0	A
	C=C+1	A
	D1=(5)	=COUR	courante := 1
	DAT1=C	A

*
* Mettre à 0 le flag 1 et sauvegarder son ancien état.
*
	D1=(4)	=FLGREG
	A=DAT1	P
	B=A	P	B(0) := ancienne valeur du flag 1
	LC(1)	`=FL1MSK
	A=A&C	P	A(0) := flags 0-3 sans le 1
	DAT1=A	P

	LC(1)	=FL1MSK
	C=C&B	P	C(0) := flag 1 seulement
	D1=(4)	=FLAG1
	DAT1=C	P

	GOTO	=BOUCLE


************************************************************
* viewln
*
* But: affiche la ligne en cours ou "[Eof]" tant que la
*   touche [ENDLINE] est appuyée.
* Entree:
*   - COUR = numéro de la ligne courante
*   - DERN = numéro de la derniere ligne
* Sortie: -
* Abime: A-D, R0-R3, D0, D1, STMTR0, AVMEMS, TMP5
* Appelle: OBCOLL, Num2D1, AVS2DS, seek, dsplin, CRLFND,
*   dspmsg, KYDN?
* Niveaux: 6 (CRLFND)
* Historique:
*   88/11/13: PD/JT conception & codage
************************************************************

 viewln
*
* "<numero>:<ligne>" ou "[Eof]" ?
*
	D0=(5)	=DERN
	A=DAT0	A	A(A) := dernière
	D0=(2)	=COUR
	C=DAT0	A	C(A) := courante
	?C>A	A
	GOYES	nul800	attendre le relachement de [ENDLINE]
*
* Afficher le numéro de ligne suivi d'un ":"
*
	GOSBVL	=OBCOLL	C(A) := OUTBS
	D1=C		D1 := ^ AVMEMS

	D0=(5)	=COUR
	A=DAT0	A	A(A) := courante

	GOSUBL	=Num2D1	place A(A) en FUNCR0
	LCASC	':'
	DAT1=C	B
	D1=D1+	2	*D1++ := ':'
	A=0	B
	A=A-1	B	A(A):= #FF
	DAT1=A	B	*D1 := #FF

	GOSBVL	=AVS2DS
*
* Chercher la ligne courante et l'afficher
*
	D0=(5)	=COUR
	C=DAT0	A	C(A) := courante
	GOSUBL	=seek	D0 := ^ longueur LIF
	GOSUBL	=dsplin
	GOSBVL	=CRLFND
	GOTO	nul900

 nul800	LC(4)	(=id)~(=teEOF)
	GOSUB	=dspmsg

*
* Attend le relachement de toutes les touches.
*
 nul900	GOSBVL	=KYDN?
	GONC	nul900
	RTN

************************************************************
* BOUCLE
*
* But: la boucle principale de l'éditeur
* Entree:
*   - PCMD = pointeur sur le premier caractère de la ligne
*   - LCMD = longueur de cette ligne de commande
* Historique:
*   88/05/14: PD/JT conception & codage
*   88/05/15: PD/JT séparation de "xeddec" et "prompt"
*   88/11/06: PD/JT aiguillage selon le message "teVCMD"
*   88/11/13: PD/JT ajout de wiewln
************************************************************

 cmNULL	GOLONG	=cmNULL	Rallonge

=BOUCLE	ST=0	10
 BCL000
*
* Décomposition de la commande
*
	GOSUBL	=xeddec
	GONC	BCL200	Commande non nulle
*
* Commande nulle. Si on vient d'afficher notre prompt,
* c'est le cas spécial de l'utilisateur qui appuie sur
* [ENDLINE] pour avoir la ligne courante à l'affichage.
*
	?ST=0	10	Ce n'est pas le cas
	GOYES	BCL100	donc affichage du prompt
*
* C'est le cas. Afficher la ligne tant que [ENDLINE]
* est appuyée.
*
	GOSUB	viewln

*
* Afficher un prompt
*
 BCL100	GOSUBL	=prompt
	ST=1	10
	GOTO	BCL000

 BCL200	LC(2)	-1	commande nulle ?
	?A=C	B
	GOYES	cmNULL
*
* Une commande a été fournie. La chercher dans le message
* listant les commandes valides.
*
	D0=(5)	=FUNCR0
	C=D	A
	DAT0=C	A	FUNCR0 + 0 := D(A)
	D0=D0+	5
	CD1EX
	DAT0=C	A	FUNCR0 + 5 := D1
	D0=D0+	5
	C=R0
	DAT0=C	A	FUNCR0 + 10 := R0
	D0=D0+	5
	C=R1
	DAT0=C	A	FUNCR0 + 15 := R1

	GOSUBL	=poscmd
	GONC	invcmd	"Invalid Cmd"
*
* La commande a été reconnue et acceptée
* Ce qui suit est un "hack" basé sur le fait qu'il y a
* moins de 16 commandes dans l'éditeur. Tout tient donc
* sur un seul quartet.
*
	P=C	0	P := numéro de la commande

	D0=(5)	=FUNCR0
	C=DAT0	A
	D=C	A
	D0=D0+	5
	C=DAT0	A
	D1=C	A
	D0=D0+	5
	C=DAT0	A
	R0=C	A
	D0=D0+	5
	C=DAT0	A
	R1=C	A

*
* Exeéution des commandes
*
	GOSBVL	=TBLJMP	switch (P)
	REL(3)	cmCOPY	C
	REL(3)	cmDEL	D
	REL(3)	=cmEXIT	E
	REL(3)	cmHELP	H
	REL(3)	=cmINS	I
	REL(3)	cmJOIN	J
	REL(3)	=cmLIST	L
	REL(3)	cmMOVE	M
	REL(3)	=cmPRNT	P
	REL(3)	=cmEXIT	Q
	REL(3)	cmREPL	R
	REL(3)	=cmSRCH	S
	REL(3)	=cmTEXT	T
	REL(3)	cmXCHG	X
*
* On ne sait jamais. L'information vient ici d'un message,
* qui peut être traduit. C'est donc potentiellement un
* risque. Il vaut mieux assurer un comportement stable
* plutôt que de risquer un "Memory Lost".
*
	REL(3)	invcmd
	REL(3)	invcmd

 invcmd	LC(4)	(=id)~(=teICMD)	Invalid Command
	GOTO	=xederr
*
* Quelques rallonges...
*
 cmREPL	GOLONG	=cmREPL
 cmXCHG	GOLONG	=cmXCHG
 cmCOPY	GOLONG	=cmCOPY
 cmMOVE	GOLONG	=cmMOVE
 cmDEL	GOLONG	=cmDEL
 cmJOIN	GOLONG	=cmJOIN
 cmHELP	GOLONG	=cmHELP

************************************************************
* xederr, dspmsg
*
* But: afficher une erreur et repartir à la boucle (erreur)
*   ou revenir à l'appelant (dspmsg)
* Entree:
*   - C(3-0) = numéro d'erreur
* Sortie:
*   - par BOUCLE (erreur)
*   - par RTN (dspmsg)
* Abime: A-D, D0, D1, R0
* Appelle: MFWRN
* Niveaux: 2 (dspmsg) ou 3 (erreur)
* Note: Un traitement spécial est effectué pour eMEM car
*   MFWRN ne revient pas si C(3-0) = eMEM. Nous remplacons
*   donc eMEM par eXMEM qui est notre "Insufficient Mem" à
*   nous mêmes que d'abord que.
* Historique:
*   88/05/14: PD/JT conception & codage
*   88/07/10: PD/JT séparation de dspmsg
*   88/11/13: PD/JT traitement de eMEM
************************************************************

=xederr	GOSUB	mem?
	P=	%1010
*
* 1	BEEP
*  0	store ERRN
*   1	display message only (no "WRN Lxxx:")
*    0	DELAY respecté
*
	GOSBVL	=MFWRN
	C=0	A
	D1=(5)	=LCMD
	DAT1=C	A	LCMD := 0
	GOTO	=BOUCLE

=dspmsg	GOSUB	mem?
	P=	%0111
*
* 0	no BEEP
*  1	do not store ERRN
*   1	display message only (no "WRN Lxxx:")
*    1	no DELAY
*
	GOVLNG	=MFWRN


************************************************************
* mem?
*
* But: MFWRN ne revenant pas s'il y a une erreur eMEM, il
*   faut tester spécialement ce cas et remplacer eMEM par
*   notre message d'erreur.
* Entree:
*   - C(4-0) = message d'erreur
* Sortie:
*   - C(4-0) = message d'erreur modifié si eMEM
*   - P = 0
* Abime: A(A), C(A), P
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/13: PD/JT conception & codage
************************************************************

 mem?	A=0	A
	P=	3
	A=C	WP
	P=	0
	C=0	A
	LC(2)	=eMEM
	ACEX	A
	?A#C	A
	RTNYES
	LC(4)	(=id)~(=eXMEM)	notre erreur à nous
	RTN

	END
