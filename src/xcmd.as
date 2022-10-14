	TITLE	Editeur, exécution des commandes <xcmd.as>

 JPCPRV	EQU	1

*
* JPC:D03
*   89/08/07: PD Correction des valeurs par défaut de J
*

************************************************************
* Variables locales
************************************************************

*
* "tmp" démarre juste après les variables globales de XEDIT.
* Attention de ne pas avoir une zone de 1 quartet comme
* dernier endroit de cette zone, car cela génerait les
* D0=(2)...
* 
 tmp	EQU	=XEDTMP	début de la zone temporaire

*
* "stmt" démarre en STMTR0. Cette zone est à utiliser avec
* beaucoup de précautions car beaucoup de routines
* l'utilisent en totalité ou en partie.
*
 stmt	EQU	=STMTR0	début de la zone TRES temporaire

*
* L / P (disponible : 20 quartets)
*
 cour	EQU	00+tmp	5 q : no de la courante
 remain	EQU	05+tmp	5 q : reste encore .. lignes
 optn	EQU	10+tmp	1 q : option 'N' active

*
* I / T (disponible : 20 quartets)
*
 insert	EQU	00+tmp	1 q : 0 si 'T', 1 si 'I'
 stradr	EQU	01+tmp	5 q : adresse de la chaîne
 strlen	EQU	06+tmp	5 q : longueur de la chaîne
 curlin	EQU	11+tmp	5 q : adresse de la ligne
=lastky	EQU	16+tmp	1 q : 1 si [v] ou [g][v]

*
* S (disponible : 20 quartets)
*
 ldeb	EQU	00+tmp	5 q : no ligne courante
 lfin	EQU	05+tmp	5 q : no ligne de fin
 debadr	EQU	10+tmp	5 q : adresse ligne courante
 offset	EQU	15+tmp	5 q : dernière occurrence

*
* R (disponible : 10 quartets)
*
*ldeb	EQU	...	5 q : no ligne courante
*lfin	EQU	...	5 q : no ligne de fin
 dern	EQU	00+stmt	5 q : dernière ligne ok
 remp	EQU	05+stmt	10 q : chaîne de remplact
 savlin	EQU	15+stmt	10 q : ^ ligne ds le fichier

*
* H (disponible : 20 quartets)
*
 curcmd	EQU	00+tmp	1 q : numéro de la commande courante

*
* J (disponible : 20 quartets)
*
*cour	EQU	...	5 q : adresse ligne courante
*remain	EQU	...	5 q : encore ... lignes
 prem	EQU	10+tmp	5 q : numéro de la première ligne
 Jsave	EQU	00+stmt	15 q : sauvegarde pendant '?'

*
* D (disponible : 20 quartets)
*
*ldeb	EQU	00+tmp	5 q : no ligne courante
*lfin	EQU	05+tmp	5 q : no ligne de fin
=EXTFIL	EQU	10+tmp	5 q : adresse fichier exterieur
 findeb	EQU	15+tmp	5 q : adfin - addeb pendant MVFILE
 nblig	EQU	00+stmt	5 q : lfin - ldeb + 1
 addeb	EQU	05+stmt	5 q : adresse ldeb
 adfin	EQU	10+stmt	5 q : adresse lfin

*
* C / M (disponible : 20 quartets)
*
*ldeb	EQU	00+tmp	5 q : no ligne courante
*lfin	EQU	05+tmp	5 q : no ligne de fin
*EXTFIL	EQU	10+tmp	5 q : adresse fichier exterieur
*findeb	EQU	15+tmp	5 q : adfin - addeb pendant MVFILE
*nblig	EQU	00+stmt	5 q : lfin - ldeb + 1
*addeb	EQU	05+stmt	5 q : adresse ldeb
*adfin	EQU	10+stmt	5 q : adresse lfin
 copie	EQU	15+stmt	1 q : 1 si copie ou 0 si move
 curadr	EQU	16+stmt	5 q : adresse de la ligne courante

 Csave	EQU	15+tmp	2 q : sauvegarde temporaire

	STITLE	Utilitaires

************************************************************
* svR1R2
*
* But: Sauver R1 et R2 dans ldeb et lfin. Utile dans les
*   commandes S, R, D et C/M
* Entrée:
*   - R1(A) = numéro de la ligne de début
*   - R2(A) = numéro de la ligne de fin
* Sortie:
*   - ldeb = numéro de la ligne de début
*   - lfin = numéro de la ligne de fin
* Abime: C, D0
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/13: PD/JT séparation de S, R, D et C/M
************************************************************

 svR1R2	D0=(5)	ldeb
	C=R1
	DAT0=C	A	ldeb := R1
	D0=D0+	(lfin)-(ldeb)
	C=R2
	DAT0=C	A	lfin := R2
	RTN

************************************************************
* getdbf
*
* But: Dans les commandes D et C/M internes, chercher les
*   adresses de début et de fin à partir de celles stockées
*   dans ldeb et lfin et les placer dans addeb et adfin, en
*   calculant la différence dans findeb.
* Entrée:
*   - ldeb = numéro de la ligne de début
*   - lfin = numéro de la ligne de fin
* Sortie:
*   - addeb = adresse de la ligne de début
*   - adfin = adresse de la ligne de fin
*   - findeb = adfin - addeb
*   - nblig = lfin - ldeb + 1
* Abime: A-D, R0-R3, D0, D1, TMP5
* Appelle: seek
* Niveaux: 5
* Historique:
*   88/11/12: PD/JT séparation de D
*   88/11/13: PD/JT ajout du calcul de nblig
************************************************************

 getdbf	D0=(5)	ldeb
	C=DAT0	A	C(A) := numéro de ligne
	GOSUBL	=seek	C(A) := ^ début de la ligne
	CD0EX		C(A) := ^ début de la ligne
	D0=(5)	addeb
	DAT0=C	A	addeb := ^ début de ldeb

	D0=(4)	lfin
	C=DAT0	A	C(A) := numéro de ligne
	C=C+1	A
	GOSUBL	=seek	C(A) := ^ début de la ligne
	CD0EX		C(A) := ^ début de la ligne
	D0=(5)	adfin
	DAT0=C	A	adfin := ^ fin de la zone

*
* On prépare la mise à jour du buffer qui aura lieu tout à
* la fin. MVFILE abimant addeb et adfin, on doit s'en
* détacher le plus vite possible. Seul "adfin - addeb" est
* nécessaire pour "dellin". On calcule donc cette valeur
* et on la met en lieu sûr.
*
	D0=D0-	5	D0=(5)	addeb
	A=DAT0	A	A(A) := addeb
	C=C-A	A	C(A) := adfin - addeb
	D0=(4)	findeb
	DAT0=C	A	findeb := adfin - addeb

*
* Calculer le nombre de lignes traitées et le placer
* dans nblig.
*
	D0=(4)	ldeb
	C=DAT0	A	C(A) := ldeb
	D0=D0+	(lfin)-(ldeb)
	A=DAT0	A	A(A) := lfin
	C=A-C	A	C(A) := lfin - ldeb
	C=C+1	A	C(A) := lfin - ldeb + 1
	D0=(4)	nblig
	DAT0=C	A

	RTN


************************************************************
* ck1prm
*
* But: vérifier la cohérence pour une syntaxe admettant 0 ou
*   1 paramètre.
* Entrée:
*   - R0 = nombre de paramètres
*   - R1 = ldebut éventuellement
* Sortie:
*   - C(A) = R1 = ldebut ou courante, vérifiée
* Abime: A, C, D0
* Niveaux: 0
* Detail:
*   selon nombre de paramètres
*     0 : renvoyer courante
*     1 : selon ldebut
*           0 : renvoyer 1
*           < dernière + 1 : renvoyer ldebut
*           sinon : dernière + 1
*         fin selon
*     2 : "Invalid Parm"
*   fin selon
* Historique:
*   88/05/23: PD/JT conception & codage
************************************************************

 ck1prm A=R0		A(A) := nb de paramètres
	A=A-1	A
	GOC	ck1p50	0 paramètres
	A=A-1	A
	GONC	Invprm	2 paramètres : "Invalid Parm"
* 1 paramètre
	D0=(5)	=DERN
	A=DAT0	A	A(A) := dernière
	C=R1		C(A) := ldebut
	?C=0	A
	GOYES	ck1p10	ldebut = 0
	?C<=A	A
	RTNYES		ldebut <= dernière
	C=A	A	C(A) := dernière
 ck1p10	C=C+1	A
	R1=C		ldebut := 1 ou (dernière + 1)
	RTN

* 0 paramètre
 ck1p50	D0=(5)	=COUR
	C=DAT0	A
	R1=C		ldebut := courante
	RTN

 Invprm	GOTO	invprm

************************************************************
* setcou
*
* But: positionne la ligne courante
* Entrée:
*   - C(A) = nouvelle valeur de ligne courante
* Sortie:
*   - COUR remis à jour
* Abime: A, C, D0
* Niveaux: 0
* Detail:
*   selon C(A)
*     0 : courante := 1
*     <= dernière + 1 : courante := C(A)
*     sinon : courante := dernière + 1
*   fin selon
* Historique:
*   88/05/22: PD/JT conception & codage
************************************************************

 setcou	D0=(5)	=DERN
	?C#0	A
	GOYES	sc10
	C=C+1	A
	GONC	sc90	B.E.T. courante := 1
 sc10	A=DAT0	A
	A=A+1	A	A(A) := dernière + 1
	?C<=A	A
	GOYES	sc90	ok, courante := C(A)
	C=A	A	C(A) := dernière + 1
 sc90	D0=(2)	=COUR
	DAT0=C	A	courante := C(A)
	RTN

************************************************************
* set.db
*
* But: mettre les paramètres par defaut à (., <ligne début>)
* Entrée:
*   - R0 = nombre de paramètres
*   - R1 = ldebut (si R0 >= 1)
*   - R2 = lfin (si R0 = 2)
* Sortie:
*   - R1 = ldebut
*   - R2 = lfin
* Abime: A, B(A), C, D0
* Appelle: defaut
* Niveaux: 1
* Note: le cas ou l'intervalle est inexistant est testé dans
*   cette routine. L'appelant n'a donc pas besoin de s'en
*   préoccuper.
* Historique:
*   88/11/12: PD/JT séparation de D et R
************************************************************

 set.db	C=R0
	?C#0	A	aucun paramètre fourni ?
	GOYES	sdb010	alors "default to R1"
	D0=(5)	=COUR	sinon "default to ."
	A=DAT0	A	ldebut := courante
	C=A	A	lfin := courante
	GONC	sdb020
 sdb010	A=R1		ldebut := ldebut
	C=A	A	lfin := ldebut
 sdb020	GOSUB	defaut
	RTNNC		ok, pas d'erreur
	GOTO	notfnd	intervalle inexistant

************************************************************
* set.+$
*
* But: mettre les paramètres par defaut à (.+1,$)
* Entrée:
*   - R0 = nombre de paramètres
*   - R1 = ldebut (si R0 >= 1)
*   - R2 = lfin (si R0 = 2)
* Sortie:
*   - Cy = 1 : intervalle inexistant
*   - Cy = 0 : intervalle existant
*	R1 = ldebut ou ldebut + 1
*	R2 = lfin
* Abime: A, B(A), C, D0
* Appelle: defaut (tombe dedans)
* Niveaux: 0
* Historique:
*   88/05/23: PD/JT conception & codage
*   88/07/09: PD/JT ajout de set.+$
*   88/10/29: PD/JT retrait de set.+$
************************************************************

 set.+$	D0=(5)	=COUR
	A=DAT0	A
	A=A+1	A	.+1
	D0=(2)	=DERN
	C=DAT0	A
	C=C+1	A	$+1

	?A<=C	A
	GOYES	defaut
	A=C	A
*
* Attention ! Le code continue !
*

************************************************************
* defaut
*
* But: vérifie les arguments et positionne les paramètres
*   par défaut aux valeurs désirées.
* Entrée:
*   - R0 = nombre de paramètres
*   - R1 = premier paramètre (ldebut)
*   - R2 = deuxième paramètre (lfin)
*   - A(A) = valeur de ldebut par defaut
*   - C(A) = valeur de lfin par defaut
* Sortie:
*   - Cy = 1 : intervalle inexistant
*   - Cy = 0 : intervalle existant
*	R1 = ldebut
*	R2 = lfin
* Abime: A, B(A), C, D0
* Niveaux: 0
* Detail des vérifications :
*    si ldebut = 0 alors erreur
*    si ldebut > lfin alors erreur
*    lfin := min (lfin, dernière)
*    si ldebut > dernière alors INTERVALLE INEXISTANT
*    INTERVALLE EXISTANT
* Historique:
*   88/05/18: PD/JT conception & codage
*   88/05/23: PD/JT travailler cohérence de (.,$)
************************************************************

*
* Attention ! Le code vient d'en haut !
*
 defaut	B=A	A	B(A) := ldebut par defaut

	A=R0		C(A) := nombre de paramètres
	A=A-1	A
	GOC	deft10	nb paramètres = 0
	A=A-1	A
	GONC	deft50	nb paramètres = 2
* nb paramètres = 1
	R2=C		R2 := lfin par défaut
	GOC	deft50	B.E.T.
* nb paramètres = 0
 deft10	R2=C		R2 := lfin par défaut
	A=B	A	A(A) := ldebut par défaut
	R1=A		R1 := ldebut par défaut
* nb paramètres = 2
*
* vérifications
*    si ldebut = 0 alors erreur
*    si ldebut > lfin alors erreur
*    lfin := min (lfin, dernière)
*    si ldebut > dernière + 1 alors erreur
*    si ldebut <= dernière alors INTERVALLE EXISTANT
*    INTERVALLE INEXISTANT (ldebut == dernière + 1)
*
 deft50	A=R1		ldebut
	?A=0	A
	GOYES	invprm	"Invalid Parm"
	C=R2		lfin
	?A>C	A
	GOYES	invprm	"Invalid Parm"
	D0=(5)	=DERN
	A=DAT0	A	A(A) := dernière
	?C<=A	A	si lfin <= dernière
	GOYES	deft60	alors deft60
	R2=A		sinon lfin := dernière
 deft60	C=R1		C(A) := ldebut
	A=A+1	A	A(A) := dernière + 1
	?C>A	A
	GOYES	invprm	"Invalid Parm"
	?C=A	A
	RTNYES		Cy = 1, intervalle inexistant
	RTN		Cy = 0, intervalle existant

 invprm	LC(4)	=eILPAR	"Invalid Parm"
	GOLONG	=xederr
	
************************************************************
* valide, valid?
*
* But: valider ce qui a été pris (dans la ligne) par la cmd
*   "valide" sort éventuellement en erreur, alors que
*   "valid?" retourne à l'appelant, la Carry indiquant
*   si une erreur a été trouvée.
* Entrée:
*   - D1 = ^ position dans la ligne
*   - D(A) := nb de caractères restant
* Sortie:
*   - PCMD, LCMD mis à jour
*   valid?
*     Cy = 1 : erreur (C(4-0) = numéro d'erreur)
*     cy = 0 : ok
* Abime: A(B), C(A), D(A), D1, S0
* Appelle: skip, lookah, getchr
* Niveaux: 2 (skip)
* Note: cette routine vérifie qu'il n'y a plus rien sur la
*   ligne de commande.
* Historique:
*   88/05/15: PD/JT conception & codage
*   88/10/29: PD/JT ajout de A(B) dans les "abimes"
*   88/11/11: PD/JT ajout de "valid?" pour D et X
************************************************************

 valid?	ST=1	0
	GOTO	val000
 valide	ST=0	0
 val000	GOSUBL	=skip
	GOSUBL	=lookah
	GOC	valok	EOL trouvé
	GOSUBL	=getchr	EOL non trouvé. Est-ce ';' ?
	LCASC	';'
	?A#C	B
	GOYES	val100	non : "Invalid Cmd"

 valok	CD1EX
	D1=(5)	=PCMD
	DAT1=C	A	PCMD := D1
	D1=(2)	=LCMD
	C=D	A
	DAT1=C	A	LCMD := D(A)
	RTNCC

 val100	LC(4)	(=id)~(=teICMD)
	?ST=1	0	reporter simplement l'erreur ?
	RTNYES		oui : Cy = 1
	GONC	erreur	B.E.T. "Invalid Cmd"

************************************************************
* noquer
*
* But: vérifier que "query" = 0
* Entrée:
*   - R3 = query (0 ou 1)
* Sortie: -
* Abime: C(W)
* Niveaux: 0
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

 noquer	C=R3
	?C=0	S
	RTNYES

 invcmd	LC(4)	(=id)~(=teICMD)	"Invalid Cmd"
 erreur	GOLONG	=xederr

************************************************************
* quer?
*
* But: mettre l'information "mode interactif demandé" dans
*   variable globale QUERY.
* Entrée:
*   - R3(S) = valeur laissée par la décomposition
* Sortie:
*   - QUERY = R3(S)
* Abime: C, D0
* Appelle: -
* Niveaux: 0
* Historique:
*   88/10/30: PD/JT isolement de "S"
************************************************************

 quer?	C=R3
	D0=(5)	=QUERY
	DAT0=C	S
	RTN

************************************************************
* clrrpt
*
* But: effacer toute trace de répétition de touche
* Entrée: -
* Sortie: -
* Abime: C(A), D0
* Niveaux: 0
* Historique:
*   88/05/15: PD/JT pompe dans KA, lui-meme dans CHEDIT
************************************************************

 clrrpt	D0=(5)	=KEYPTR
	C=0	A
	C=DAT0	XS
	?C#0	XS
	RTNYES		retour si buffer vide
	D0=(4)	(=KEYBUF)+2*14
	DAT0=C	B
	RTN

************************************************************
* abCn
*
* But: analyser les arguments des commandes L, P et J
* Entrée:
*   - A(A) = dernière ligne par défaut
*   - R0 = nombre de lignes introduites
*	R1 : ldebut
*	R2 : lfin
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - S0 = 1 si le nombre de lignes fourni par l'utilisateur
*	ne comprend pas la ligne de début (utilisé par J)
* Sortie:
*   - R1 = ldébut
*   - R3 = nombres de lignes valides (déjà testé, évent. 0)
* Abime: A(W), B(A), C(A), D0, R3 (D1 et D(A) réactualisés)
* Appelle: nombre, skip, ASLW5, ASRW5
* Niveaux: 2
* Note: la première ligne par défaut est la courante ('.')
*   dans les deux cas (J et L/P).
* Historique:
*   88/10/29: PD/JT séparation de L
************************************************************

 abCn	GOSBVL	=ASLW5	A(9-5) := lfin si il n'y en a pas
	GOSUBL	=nombre
	GOC	abCn50	nombre non reconnu
*
* ... <cmd> <nombre> ...
* le nombre est dans A(A)
*
	?ST=0	0	cas standard ?
	GOYES	abCn05	oui
	A=A+1	A
 abCn05	R3=A		R3 := nombre de lignes
	GOSUBL	=skip	Passer éventuellement le nombre
*
* R0 = nombre de paramètres
*
	A=R0		A(A) := nb de paramètres
	A=A-1	A
	GOC	abCn10	0 paramètre
	A=A-1	A
	GOC	abCn20	1 paramètre
	GOTO	invcmd	"Invalid Cmd"

* nb de paramètres = 0
 abCn10	D0=(5)	=COUR
	A=DAT0	A	"."
	R1=A
 abCn20	A=R1		A(A) := ldebut
	C=R3		C(A) := compte de lignes
	A=A+C	A
	A=A-1	A	A(A) := numéro de la dernière ligne
	D0=(2)	=DERN
	C=DAT0	A	C(A)  dernière
	?A<=C	A
	RTNYES
	GOTO	invprm	"Invalid Parm"

* pas de nombre de lignes fourni après 'L', 'P' ou 'J'
 abCn50	GOSBVL	=ASRW5	A(A) := lfin
	C=A	A	C(A) :;= lfin
	D0=(5)	=COUR
	A=DAT0	A	A(A) := ldebut ('.')
	GOSUB	defaut
*
* Cas Cy = 1 : intervalle inexistant. Typiquement, après les
* paramètres par défaut, on a : ($+1,$)
*
	A=R1
	C=R2
	C=C-A	A
	C=C+1	A
	R3=C		R3 := nb de lignes (évent. 0)
*
* R1 = ligne de début
* R3 = nombre de lignes à afficher (déjà testé)
*
	RTN

	STITLE	Commande nulle

************************************************************
* cmNULL
*
* But: ne rien faire (ahhhhhhhhhhh)
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 = ldebut
*	R2 = lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Appelle: noquer, valide, ck1prm, setcou
* Niveaux: N/A
* Historique:
*   88/05/14: PD/JT conception & codage
*   88/05/23: PD/JT simplification et utilisation de ck1prm
************************************************************

=cmNULL	GOSUB	noquer	interdit les "?"
	GOSUB	valide	interdit tout après ce qui est lu
	GOSUB	ck1prm	force ldebut à COUR si besoin est
	GOSUB	setcou
	GOLONG	=BOUCLE

	STITLE	Commandes Exit / Quit

************************************************************
* cmEXIT
*
* But: sortir de l'éditeur
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 = ldebut
*	R2 = lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par NXTSTM
* Abime: tout
* Appelle: noquer, valide, I/ODAL, clrrpt, NOSCRL, setfl1
* Niveaux: N/A
* Historique:
*   88/05/15: PD/JT conception & codage
*   88/10/23: PD/JT ajout du traitement du flag 1
*   88/11/12: PD/JT traitement du flag 1 par setfl1
************************************************************

 invCmd	GOTO	invcmd

=cmEXIT	GOSUB	noquer	Interdit le '?'
	GOSUB	valide	Interdit des paramètres après
	C=R0		nblignes
	?C#0	A	Paramêtres avant ?
	GOYES	invCmd	oui : "Invalid Cmd"
*
* Collapser le buffer
*
=EXIT	D0=(5)	=BUFID
	C=0	A
	C=DAT0	X	C(X) := buffer id
	?C=0	A
	GOYES	E050	Y-avait pas d'buffer
	GOSBVL	=I/ODAL
 E050
*
* Mettre le flag 1 à son ancienne valeur
*
	D0=(5)	=FLAG1
	C=DAT0	P	C(0) := ancienne valeur
	GOSUBL	=setfl1
*
* Effacer la répétition, autoriser le prompt. Tout baigne...
*
	GOSUB	clrrpt
	GOSBVL	=NOSCRL
	ST=0	14
	GOVLNG	=NXTSTM

	STITLE	Commande List / Print

************************************************************
* cmLIST
*
* But: lister un certain nombre de lignes à l'ecran
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 = ldebut
*	R2 = lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: noquer, lookah, getchr, valide, seek, CKINFO,
*   Num2D1, SENDWD, SNDWD+, SENDEL, CK"ON", POPBUF, setcou
* Niveaux: N/A
* Historique:
*   88/05/18: PD/JT conception & codage
************************************************************

=cmPRNT	LC(2)	(=PRINTt)*16+#F
	GOTO	L000

=cmLIST	LC(2)	(=DISPt)*16+#F
 L000	D0=(5)	=MLFFLG
	DAT0=C	B	MLFFLG := type (DISP ou PRINT)
*
* N'accepte pas '?'
*
	GOSUB	noquer
*
* Analyse une ligne de la forme :
*   [<ligne> [, <ligne>]] L [<nombre>]
*
	D0=(5)	=DERN
	A=DAT0	A	A(A) := ligne de fin par défaut
	ST=0	0	cas standard
	GOSUB	abCn
*
* R1 = ligne de début
* R3 = nombre de lignes (éventuellement 0)
*
	A=R3		A(A) := nb de lignes
	D0=(5)	remain
	DAT0=A	A	remain := compteur
	A=R1
	D0=(2)	cour
	DAT0=A	A	cour := ldebut
*
* Y-a-t-il un 'N' à la fin ?
*
	D0=(2)	optn
	C=0	S
	DAT0=C	S	Par défaut : non
	GOSUBL	=lookah
	GOC	L070	pas de 'N'
	LCASC	'N'
	?A=C	B
	GOYES	L060	il y a un 'N'
	LCASC	'n'
	?A#C	B
	GOYES	L070	il n'y a pas de 'N'
 L060	GOSUBL	=getchr
	DAT0=C	P	optn := #E
*
* On est arrivé au bout. Valider la commande complète :
*
 L070	GOSUB	valide

*
* Est-on dans le cas "R3 = 0" ?
*
	C=R3		C(A) := nombre de lignes à lister
	?C#0	A
	GOYES	L080
	GOTO	L999	nul : sortie...
 L080	C=R1		C(A) := ldebut
	GOSUBL	=seek	D0 := ^ ligne
	GOSBVL	=CKINFO	prépare HPIL

*
* Boucle d'affichage des lignes
*
* cour = numéro de la ligne courante
* optn = 0 si option 'N' non active
* remain = nombre de lignes encore à lister
* D0 = ^ ligne en cours
*
 L100	D1=(5)	optn
	A=DAT1	S	A(S) := 1 si 'N' active
	?A=0	S
	GOYES	L150
*
* Affichage du numéro de ligne (option 'N')
*
	D1=(2)	cour
	A=DAT1	A	A(A) := nombre à afficher
	D1=(5)	=AVMEMS
	C=DAT1	A
	D1=C
	D=C	A	D(A) := ^ début du buffer
	GOSUBL	=Num2D1	Extrait de KA
	LCASC	':'
	DAT1=C	B
	C=0	A
	CSLC	W	C(A) := nombre de chiffres à envoyer
	C=C+1	A	pour rattraper le "-1"
	C=C+1	A	pour inclure ":"
	A=C	A	A(A) := longueur
	C=D	A	C(A) := ^ début du buffer
	D1=C		D1 := ^ début du buffer
	ST=1	=InhEOL	inhibit EOL pour le cas où
	GOSBVL	=SENDWD
*
* Affichage de la ligne
*
 L150	GOSUBL	=LIFlen
	B=C	A	B(A) := longueur en octets
	D0=D0+	4	D0 := ^ partie données
	CD0EX
	D0=C		D0 gardé pour plus tard !!!
	ST=1	=InhEOL	inhibit EOL pour le cas où
	GOSBVL	=SNDWD+
	GOSBVL	=SENDEL	EOL
*
* Passage à la ligne suivante
*
	D0=D0-	4	D0 était sauvé pendant SENDxxx
	GOSUBL	=LIFlen
	CD0EX
	C=A+C	A	C(A) := ^ nouvelle ligne
	D0=C

	D1=(5)	cour
	C=DAT1	A
	C=C+1	A
	DAT1=C	A	ldebut++
	D1=(2)	remain
	A=DAT1	A
	A=A-1	A
	DAT1=A	A

*
* L'utilisateur nous demande-t-il d'arrêter ?
*
	GOSBVL	=CK"ON"	N'abime ni C(A) ni A(A)
	GONC	L190	[ATTN] hit
*
* Non : on continue donc.
*
	?A=0	A
	GOYES	L200
	GOTO	L100	et on repart pour un tour...
*
* Fin du listage. Arrêt prématuré.
*
 L190	A=C	A
	GOSBVL	=POPBUF	Enlever la touche [ATTN]
	C=A	A

*
* Fin normal du listage.
*
 L200	GOSUB	setcou	COUR := C(A) (qui valait ldebut++)

 L999	GOLONG	=BOUCLE

	STITLE	Commandes Insert / Text

************************************************************
* cmINS
*
* But: insérer une ou plusieurs lignes dans le texte
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 = ldebut
*	R2 = lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: setfl1, noquer, ck1prm, valide, seek, edtlin,
*   TBLJMC, OBCOLL, MEMCKL, SWPBYT, LIFlen, rpllin, addlin,
*   RPLLIN, syncbf
* Niveaux: N/A
* Algorithme:
*   si I
*     alors mettre le flag 1 à 1
*   fin si
*   vérifier les paramètres
*   mettre à 1 notre bit dans la Reserved-Ram
*   tant que l'utilisateur n'a pas frappé [ATTN]
*     faire
*	éditer la ligne courante
*	selon la réponse de l'utilisateur
*	  [ATTN] : rien
*	  [ENDLINE] : insérer ou ajouter la ligne
*	  touche de curseur : déplacer la ligne courante
*   fin tant que
*   Mettre le flag 1 à 0
* Historique:
*   88/05/23: PD/JT conception & codage
*   88/10/23: PD/JT ajout du flag dans la reserved-ram
*   89/06/17: PD/JT test du flag "read-only"
************************************************************

=cmINS
*
* Positionner le flag 1 (1 comme "unsert" (french-joke))
*
	LC(1)	1
	GOSUBL	=setfl1
*
* C(0) n'est pas modifié. Il vaut donc toujours 1
*
	GOTO	T000	On y va !

=cmTEXT	C=0	A
 T000	D0=(5)	insert
	DAT0=C	P	insert := 0 ou 1

	GOSUB	noquer	Interdit le '?'
	GOSUB	ck1prm	N'autorise qu'un seul paramètre
	GOSUB	valide
	C=R1		C(A) := ldebut
	D0=(5)	=COUR
	DAT0=C	A	COUR := paramètre

	D0=(2)	=lastky
	LC(1)	1
	DAT0=C	P	lastky = [v] ou [g][v]

 T100
*
* afficher et éditer la ligne courante
*
	D0=(5)	=COUR
	C=DAT0	A	C(A) := courante
	GOSUBL	=seek	D0 := ^ longueur LIF de la ligne
	D1=(5)	curlin
	CD0EX
	DAT1=C	A	curlin := ^ ligne courante
	D0=C
	D1=(5)	insert
	C=DAT1	S	C(S) := mode ('T' ou 'I')
*
* Mettre le bit de la reserved-ram pour signaler que nous
* sommes en input.
*
	D1=(5)	=RESJPC	ram-reservée JPC
	A=DAT1	P
	LC(1)	=INEDIT
	A=A!C	P
	DAT1=A	P

	GOSUBL	=edtlin
*
* Enlever le bit de la reserved-ram
*
	RSTK=C		préserver C(0)
	B=A	A	B(A) := LEN si [ENDLINE]
	D0=(5)	=RESJPC
	A=DAT0	P
	LC(1)	`=INEDIT
	A=A&C	P
	DAT0=A	P

	A=B	A	A(A) := LEN si [ENDLINE]
	C=RSTK		C(0) := code retour
*
* Selon le code retour de edtlin
*
	GOSBVL	=TBLJMC	n'abime que C(A)
	REL(3)	T900	[ATTN] ou [f][OFF]
	REL(3)	T400	[ENDLINE]
	REL(3)	T100	curseur

****************************************
* Remettre le flag 1 à 0 et brancher en erreur.
****************************************

 Terr	CSL	W	C(5-1) := no d'erreur, C(0) := 0
	GOSUBL	=setfl1	Mettre le flag 1 à 0
	CSR	W	C(A) := no d'erreur
	GOLONG	=xederr

****************************************
* [ENDLINE]
*
* D1 = ^ premier caractère
* D(A) = A(A) = longueur de la chaîne
*
 T400	CD1EX
	D1=(5)	stradr
	DAT1=C	A	stradr := ^ premier caractère
	D1=(2)	strlen
	DAT1=A	A	strlen := longueur en octets
*
* Ajout du 12/11/88 : test de l'accessibilite du fichier.
* Changement du 17/06/89 : test du flag "read-only"
*
	D1=(5)	=RDONLY
	C=DAT1	S
	GOSUBL	=WRITE?
	GONC	Terr	C(A) = eFACCS, eFPROT ou eFOPEN
*
* Fin de l'ajout du 12/11/88
*
	GOSBVL	=OBCOLL
	D1=(5)	strlen
	A=DAT1	A
	A=A+1	A
	A=A+1	A
	A=A+A	A	A(A) := mémoire necessaire
	C=A	A	C(A) := mémoire demandée
	GOSBVL	=MEMCKL
	GOC	Terr	C(A) = eMEM

	D0=(5)	stradr
	C=DAT0	A
	D1=C		D1 := ^ premier caractère
	D0=(2)	strlen
	C=DAT0	A
	B=C	A	B(A) := longueur en octets

	C=C+1	A
	CSRB
	C=C+C	A	C(A) := longueur avec padding LIF
	C=C+1	A
	C=C+1	A	C(A) := longueur + LEN(longueur LIF)
	C=C+C	A

	D0=(5)	=AVMEMS
	A=DAT0	A
	C=A+C	A	C(A) := ^ fin de la chaîne
	DAT0=C	A	AVMEMS réactualisé
	D0=A		D0 := ^ output buffer

	A=B	A	A(A) :=longueur en octets
	GOSBVL	=SWPBYT
	DAT0=A	4	longueur LIF
	D0=D0+	4
	GONC	T420	B.E.T.

 T410	C=DAT1	B
	DAT0=C	B
	D1=D1-	2
	D0=D0+	2
 T420	B=B-1	A
	GONC	T410
*
* OUTBS contient une ligne prête
*
	D1=(5)	=AVMEMS
	C=DAT1	A
	D1=(2)	=OUTBS
	A=DAT1	A
	C=C-A	A	C(A) := longueur nouvelle ligne
	D=C	A	D(A) := longueur nouvelle ligne

	D1=(5)	=COUR
	C=DAT1	A
	B=C	A	B(A) := numéro de la ligne remplacée

	D0=(5)	insert
	C=DAT0	S
	?C#0	S
	GOYES	T460	Insertion
*
* remplacement
*
 T450	D1=(2)	=DERN
	A=DAT1	A
	?C>A	A
	GOYES	T460	Insertion pour [Eof]

	D0=(5)	curlin
	C=DAT0	A
	D0=C
	GOSUBL	=LIFlen	epargne B(A) et D(A)
	C=D	A	C(A) := longueur nouvelle
	C=C-A	A	C(A) := nouvelle - ancienne
	A=C	A	A(A) := différence de longueur

	GOSUBL	=rpllin	attention : ce n'est pas RPLLIN !!!

	GOSUBL	=LIFlen
	R3=A		R3 := longueur de la vieille ligne
	CD0EX
	A=A+C	A	A(A) := ^ juste après
	GOTO	T490

 TerR	GOTO	Terr	Rallonge

*
* insertion
*
 T460	C=D	A
	A=C	A	A(A) := longueur de ce qu'on rajoute

	C=0	A
	C=C+1	A	C(A) := 1 ligne ajoutée
	GOSUBL	=addlin
*
* Ajout d'une nouvelle ligne dans le fichier
*
	D0=(5)	curlin
	C=0	A
	R3=C		R3 := 0 pour insertion
	A=DAT0	A	A(A) := ^ juste devant l'insertion

 T490	D0=(5)	=FILADR
	C=DAT0	A	C(A) := ^ file header
*
* A(A) = ^ dernier nibble + 1 de la vieille ligne
* C(A) = ^ file header
* R3(A) = longueur de la vieille ligne en nibs
*
    if JPCPRV
	GOSBVL	=RPLLIN
    else
	GOSBVL	=MGOSUB
	CON(5)	=RPLLIN
    endif
	GOC	TerR	C(A) = eMEM

	GOSUBL	=syncbf	synchronise l'adresse du buffer
	
	D0=(5)	=COUR
	C=DAT0	A
	C=C+1	A
	DAT0=C	A
	GOTO	T100

* [ATTN] ou [f][OFF]
 T900
*
* Remettre le flag 1 à 0. Si on était en mode 'T',
* c'est une no-op. Mais ca enlève un test et ca diminue
* la taille du code (il n'y a pas de petit profit...).
*
	C=0	A
	GOSUBL	=setfl1

	GOLONG	=BOUCLE

	STITLE	Commande Search

************************************************************
* cmSRCH
*
* But: chercher une chaîne dans le fichier
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 : ldebut
*	R2 : lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: quer?, set.+$, GETSRC, getchr, valide, seek,
*   SRCADR, query, TBLJMC, ENDPOS, setcou
* Niveaux: N/A
* Algorithme:
*   compiler la chaîne à chercher
*   tant que non trouvé
*     faire
*       parcourir le fichier pour trouver une occurrence
*       si non trouvée
*         alors sortir en erreur
*       fin si
*       si mode # "?"    (query)
*         alors
*           positionner la ligne courante
*           retour à la boucle de l'éditeur
*       fin si
*       demander confirmation
*       si confirmation = 'ok'
*         alors 
*           positionner la ligne courante
*           retour à la boucle de l'éditeur
*       fin si
*   fin tant que
* Historique:
*   88/07/02: PD/JT conception & codage
*   88/11/13: PD/JT utilisation de svR1R2
************************************************************

 notfnd	LC(4)	(=id)~(=eNFND)	"Not Found"
 erreuR	GOLONG	=xederr

=cmSRCH	GOSUB	quer?	QUERY := R3(S)

	GOSUB	set.+$
	GOC	notfnd

*
* Sauver R1 et R2 dans ldeb et lfin
*
	GOSUB	svR1R2

	GOSUBL	=GETSRC	analyse, compile chaîne de recherche
	GOC	erreuR	Erreur

	GOSUBL	=getchr	passer le delimiteur éventuel
*
* L'état de la Carry nous importe peu, car on est soit
* sur le "/" (et alors Cy = 0 en sortie), soit sur le EOL
* et à ce moment, il ne restera plus de caractère à lire.
* Et la commande sera donc finie de toutes manières.
*
	GOSUB	valide

	D1=(5)	=FUNCR0	FUNCR0 := R0
	C=R0
	DAT1=C	W

	D0=(5)	ldeb
	C=DAT0	A
	GOSUBL	=seek	D0 := ^ première ligne

	D1=(5)	=FUNCR0
	C=DAT1	W
	R0=C

	CD0EX		debadr := ^ ligne début
	D0=(5)	debadr
	DAT0=C	A
	D0=(2)	offset	offset := 0
	C=0	A
	DAT0=C	A
*
* while non trouvée
*   faire
*     ...
*
 S100	D1=(5)	offset	B(A) := offset
	C=DAT1	A
	B=C	A
	D1=(2)	debadr	D0 := ^ début ligne LIF
	C=DAT1	A
	D0=C
	D1=(2)	ldeb	A(A) := ligne début
	A=DAT1	A
	D1=(2)	lfin	C(A) := ligne fin
	C=DAT1	A
*
* A(A) = ligne de début
* C(A) = ligne de fin
* D0 = ^ ligne LIF
* B(A) = offset
* R0(7-0) = caractéristique du buffer
*
	GOSUBL	=SRCADR	search line in file
*
* A(A) = no ligne		( -> ldeb)
* D1 = ^ longueur LIF		( -> curlin)
* C(A) = longueur occurrence	( -> poubelle...)
* D0 = ^ occurrence
*

*
* Libération des registres A et D1.
* Attention ! Le registre D0 est toujours utilisé
*
	B=A	A	B(A) := sauvegarde de A(A)
	AD1EX		A(A) := ^ longueur LIF
	D1=(5)	debadr	debadr := ^ longueur LIF
	DAT1=A	A
	D1=(2)	ldeb	ldeb := no ligne
	A=B	A
	DAT1=A	A	on a libere A(A) et D1
*
* si non trouvée
*   alors sortir en erreur
*
	GONC	Serr	match not found
*
* fin si
* si mode # "?"		(query)
*   alors
*     positionner la ligne courante
*     retour à la boucle
*
	D1=(4)	=QUERY
	A=DAT1	S
	?A=0	S
	GOYES	S900	match found
*
* fin si
* demander confirmation
*
	D1=(4)	debadr	C(A) := ^ longueur LIF
	C=0	W
	C=DAT1	A
	AD0EX		A(A) := ^ occurrence
	D0=C		D0 := ^ longueur LIF (debadr)
	C=A-C	A	C(A) := offset en quartets
	CSRB		C(A) := offset en octets
	C=C-1	A	C(A) := offset - longueur LIF + 1
	D1=(2)	offset
	DAT1=C	A

	D1=(2)	ldeb
	A=DAT1	A
*
* A(A) = no ligne	(<- ldeb)
* C(A) = no colonne	(<- offset)
* D0 = ^ début de ligne	(<- debadr)
*
	GOSUBL	=query
	GOSBVL	=TBLJMC
	REL(3)	S950	[Q]	exit (ou [ATTN])
	REL(3)	S900	[Y]	match found
	REL(3)	S100	[N]	continue

*
* Match not found
*
 Serr	GOSUBL	=ENDPOS
	GOTO	notfnd
*
* Match found !
* ldeb = numéro de la ligne trouvée
*
 S900	D1=(5)	ldeb
	C=DAT1	A	C(A) := numéro ligne trouvée
	GOSUB	setcou
 S950	GOSUBL	=ENDPOS	on a fini avec le buffer
	GOLONG	=BOUCLE

	STITLE	Commande Replace

************************************************************
* cmREPL
*
* But: remplacer un motif par un autre dans le fichier
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 : ldebut
*	R2 : lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: quer?, defaut, getchr, GETSRC, valide, CALCab,
*   SRCLIN, LIFlen, MEMCKL, MOVE*M, REPLIN, FMTLIF, RPLLIN,
*   syncbf, rpllin, UPDTR0, ENDPOS, setcou
* Niveaux: N/A
* Algorithme:
*   compiler la chaîne à chercher
*   tant que ligne < lfin
*     faire
*	parcourir le fichier pour trouver une occurrence
*	copier la ligne dans OUTBS
*	[
*	  répéter
*	    si mode = "?" alors poser la question
*	    si réponse = "Y" ou pas de "?"
*	      alors
*	        remplacer dans OUTBS
*	    fin si
*	    chercher une autre occurrence sur la même ligne
*	  jusqu'à ce qu'il n'y ait plus d'occurrence
*	]
*       si ligne modifiée alors remplacer dans le fichier
*   fin tant que
* Historique:
*   88/10/07: PD/JT conception & codage
*   88/11/12: PD/JT ajout du test d'accessibilité
*   88/11/12: PD/JT séparation de set.db
*   88/11/13: PD/JT utilisation de svR1R2
*   89/06/17: PD/JT test du flag "read-only"
************************************************************

 Notfnd	LC(4)	(=id)~(=eNFND)	"Not Found"
 ErreuR	GOLONG	=xederr

=cmREPL	GOSUB	quer?	QUERY := R3(S) ('?' ou pas)
*
* set.. ou "setR1R1"
*
	GOSUBL	set.db	(., <ldebut>)
*
* R1 et R2 contiennent maintenant les bonnes bornes.
*
	GOSUBL	svR1R2	alors les sauver dans ldeb et lfin

	GOSUBL	=GETSRC	analyse et compile le motif
	GOC	ErreuR	Erreur
	GOSUBL	=DELIM	délimite la chaîne de remplacement
	GONC	R030	pas d'erreur
*
* Génère une erreur, mais libère auparavant le buffer
* utilisé pour stocker la chaîne générique.
*
 Rerr	D=C	A	D(A) : =numéro d'erreur
	GOSUBL	=ENDPOS	n'abime pas D(A)
	C=D	A	restaure dans C(A) le No d'erreur
	GOLONG	=xederr

 R030	D0=(5)	remp
	DAT0=C	A	remp+0 := nb de caractères
	D0=D0+	5
	DAT0=A	A	remp+5 := ^ chaîne de remplacement
	GOSUBL	=getchr	passer le delimiteur
*
* Lorsque "valide" détecte une erreur, il faut libérer le
* buffer utilisé pour stocker la chaîne générique.
*
	GOSUB	valid?
	GOC	Rerr	Libérer le buffer

*
* Tester l'accessibilité du fichier. Teste s'il est en Ram,
* si tel est le cas, que le fichier n'est pas sécurisé.
* Changement du 17/06/89 : test du flag "read-only"
*
	D1=(5)	=RDONLY
	C=DAT1	S
	GOSUBL	=WRITE?
	GONC	Rerr	C(A) = eFACCS, eFPROT ou eFOPEN

	D0=(5)	dern	dernière ligne modifiée
	C=0	A
	DAT0=C	A	dernière ligne modifiée := 0
*
* Calculer les coefficients a et b pour le remplacement
* Ces coefficients sont calculés une fois pour toutes et
* permettent de connaître la longueur de la chaîne
* remplacée en fonction de la longueur de la chaîne
* originale. Ils sont placés en haut de TRFMBF.
*
	D0=(4)	remp
	C=DAT0	10
	R3=C		R3 = motif de remplacement
	GOSUBL	=CALCab	Voila, c'est fait !

*
* Boucle de remplacement.
* Assertions :
* ldeb = no dernière ligne où on a trouvé quelque chose
* lfin = no ligne limite
* dern = no dernière ligne modifiée
* remp = 10 q. pour conserver R3 entre les appels à REPLIN
*
 R100	D0=(5)	ldeb
	A=DAT0	A
	D0=D0+	(lfin)-(ldeb)
	C=DAT0	A
	?A>C	A
	GOYES	r900	On est arrivé au bout
*
* Recherche
* R0(7-0) = caractéristiques du buffer
* A(A) = ligne de début
* C(A) = ligne de fin
*
	GOSUBL	=SRCLIN
	GOC	R110	trouvé !
 r900	GOTO	R900	terminé. On ferme...
*
* A(A) = numéro de la ligne trouvée
* C(A) = longueur de l'occurrence trouvée (en octets)
* D0 = ^ occurrence trouvée
* D1 = ^ début ligne (longueur LIF) contenant l'occurrence
*
 R110	RSTK=C		RSTK := LEN(occurrence)
	CD0EX		C(A) := ^ occurrence

	D0=(5)	savlin	savlin := (no ligne, ^ ligne)
	DAT0=A	A	savlin + 0 := no ligne trouvée
	D0=D0+	5
	AD1EX		A(A) := ^ début ligne LIF
	DAT0=A	A	savlin + 5 := ^ début ligne LIF

	C=C-A	A	C(A) := offset de l'occurrence
	RSTK=C		RSTK := offset occurrence
*
* RSTK(1) = LEN (occurrence)
* RSTK(0) = offset occurrence dans la ligne
* savlin + 0 = no ligne trouvée
* savlin + 5 = ^ ligne trouvée
* A(A) = ^ ligne trouvée
*
* Maintenant, amener la ligne dans OUTBS
*
	D0=A		D0 := ^ début ligne LIF (longueur)
	GOSUBL	=LIFlen	C(A) := line length in bytes
	C=C+1	A
	C=C+1	A	C(A) := LEN + 2
	C=C+C	A	C(A) := longueur en quartets
*
* C(A) := amount to check
*
	GOSBVL	=MEMCKL
	GONC	R120	pas d'erreur
	GOTO	Rerr	"Insufficient Memory"
*
* B(A) = length in nibs
* D0 = ^ début ligne LIF
*
 R120	AD0EX		A(A) := ^ début ligne LIF
	D0=(5)	=OUTBS
	C=DAT0	A	C(A) := ^ début OUTBS
*
* A(A) = source address (^ ligne LIF)
* C(A) = dest address (OUTBS)
* B(A) = length in nibs (longueur LIF)
*
	GOSBVL	=MOVE*M
* En sortie, A, B et C sont inchangés
	C=C+B	A
	D0=(5)	=AVMEMS
	DAT0=C	A	AVMEMS := ^ fin du buffer
*
* RSTK(1) = LEN (occurrence)
* RSTK(0) = offset occurrence
* savlin + 0 = no ligne trouvée
* savlin + 5 = ^ ligne trouvée
* Préparer les registres pour REPLIN
*
	D1=(5)	remp
	C=DAT1	10
	R3=C		R3 := motif de remplacement

	D1=(4)	=OUTBS
	A=DAT1	A	A(A) := OUTBS
	C=RSTK		C(A) := offset de l'occurrence
	C=C+A	A	C(A) := ^ occurrence
	D0=C		D0 := ^ occurrence

	C=RSTK		C(A) := LEN (occurrence)

	D1=(4)	savlin
	A=DAT1	A	A(A) := no de la ligne trouvée

*
* (OUTBS..AVMEMS) = chaîne à traiter
* R3 = motif de remplacement
* D0 = ^ occurrence trouvée
* C(A) = longueur de l'occurrence
* coeffa et coeffb calculés par CALCab
* A(A) = no de la ligne en cours
*
	GOSUBL	=REPLIN
	GONC	R150	pas eû d'erreur
 rerr	GOTO	Rerr	on libère le buffer
 r200	GOTO	R200	rallonge
*
* C(0) = code de retour
* savlin + 0 = no de la ligne trouvée
* savlin + 5 = ^ début de la ligne dans le fichier
* (OUTBS..AVMEMS) = la ligne remplacée
*
 R150	D1=(5)	=TMP3
	DAT1=C	P	TMP3(0) := code de retour
	SB=0
	CSRB
	?SB=0		réécriture nécessaire ?
	GOYES	r200	non
*
* Réécriture nécessaire
* TMP3(0) = code de retour
* savlin + 0 = no de la ligne trouvée
* savlin + 5 = ^ début de la ligne dans le fichier
* (OUTBS..AVMEMS) = la ligne remplacée
*

*
* RPLLIN abimant R0, il faut le sauvegarder momentanément
*
	D0=(5)	=FUNCR0
	C=R0
	DAT0=C	8	sauvegarder R0(7-0)
*
* La ligne dans OUTBS a été modifiée. Il faut remettre une
* longueur LIF et un padding éventuel :
*
	ST=1	0	ajuster AVMEMS si besoin est
	GOSUBL	=FMTLIF	formatte la ligne en (OUTBS..AVMEMS)
	GOC	rerr
*
* Préparation de l'appel à RPLLIN
*
	D1=(5)	5+savlin
	C=DAT1	A
	D0=C		D0  := ^ ancienne ligne
	GOSUBL	=LIFlen
	R3=A		R3 := length of old line in nibs
	C=A	A
	RSTK=C		RSTK := "	"	"
	CD0EX
	A=A+C	A	A(A) := ^ last nib + 1 of old line

	D0=(5)	=FILADR
	C=DAT0	A	C(A) := ^ file header
*
* (OUTBS..AVMEMS) = ligne à remplacer
* A(A) = ^ address of last nibble + 1 of old line
* C(A) = ^ address of file header
* R3(A) = length of old line in nibs
*
    if JPCPRV
	GOSBVL	=RPLLIN
    else
	GOSBVL	=MGOSUB	EDIT peut être derrière le fichier
	CON(5)	=RPLLIN
    endif
	GOC	rerr	Il y a eû erreur. On libère le buf
*
* RSTK = longueur vieille ligne
* B(A) = longueur de la nouvelle ligne
* output buffer collapsed
*
* Avant tout, récuperer l'adresse du buffer dans lequel
* est stocké le tableau des pointeurs sur les lignes.
*
	GOSUBL	=syncbf	ne touche pas à B(A)
*
* Ensuite, actualiser ce fameux tableau.
*
	C=RSTK		C(A) := ancienne longueur
	A=B	A	A(A) := nouvelle longueur
	A=A-C	A	A(A) := (nouvelle - anciene)

	D0=(5)	savlin	savlin + 0 = numéro de la ligne
	C=DAT0	A
	B=C	A	B(A) := numéro de la ligne remplacée
*
* Réactualisation du tableau de pointeurs :
* B(A) = numéro de la ligne remplacée
* A(A) = longueur nouvelle - longueur ancienne
*
	GOSUBL	=rpllin	attention : Ce n'est pas RPLLIN !!!
*
* On a fini RPLLIN. On peut à présent restaurer R0
*
	D0=(5)	=FUNCR0
	C=DAT0	8	restaurer R0(7-0)
	R0=C

	GOSUBL	=UPDTR0	mettre à jour R0(7-3) après le move
	GONC	R180	pas d'erreur
	GOLONG	=xederr	System Error
*
* On a modifié la ligne. C'est donc potentiellement la
* ligne courante finale.
*
 R180	D0=(5)	savlin
	C=DAT0	A	C(A) := numéro de cette ligne
	D0=(4)	dern
	DAT0=C	A	dern := dernière ligne modifiée
*
* Le remplacement est fini.
*
 R200
*
* Il faut maintenant décider si on continue ou si on arrête.
*
	D1=(5)	=TMP3
	C=0	B	C(B) := 0
	C=DAT1	P	C(B) := code de retour (0-1 ou 2-3)
	CSRB		C(0) := code de retour (0 ou 1)
	?C=0	P
	GOYES	R900	[Q]
*
* On continue.
*
	D0=(5)	savlin
	C=DAT0	A	C(A) := ligne qu'on vient de traiter
	C=C+1	A
	D0=(4)	ldeb
	DAT0=C	A	ldeb := dernière ligne traitée + 1
	GOTO	R100

 R900	GOSUBL	=ENDPOS
*
* Si on n'a rien trouvé ou rien modifié, alors "Not Found"
* Tout ca se résume par "dern # 0 ?"
*
	D0=(5)	dern
	C=DAT0	A
	?C=0	A
	GOYES	NotFnd	"Not Found"
*
* Tout c'est donc bien passé. Reste à changer la notion
* de "ligne courante" :
*
	GOSUBL	setcou
*
* Et voilà. Simple, non ?
*
	GOLONG	=BOUCLE

 NotFnd	GOTO	Notfnd

	STITLE	Commande Help

************************************************************
* cmHELP
*
* But: afficher une aide
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 : ldebut
*	R2 : lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: noquer, lookah, getchr, valide, poscmd, dspmsg,
*   KEYWT, dspmsg, RPTKY, FINDA
* Niveaux: N/A
* Historique:
*   88/10/23: PD/JT conception & codage
*   88/10/29: PD/JT ajout de la repetition
*   88/10/29: PD/JT ajout du paramètre de Help
************************************************************

=cmHELP	GOSUBL	noquer
	GOSUBL	=lookah
	GOC	H500	"help" tout seul (tous les sujets)
	LC(2)	';'
	?A=C	B
	GOYES	H500
*
* Help avec un sujet
* A(B) = le sujet (à vérifier)
*
	GOSUBL	=getchr
	B=A	B	B(B) := caractère lu
	GOSUBL	valide	n'abime pas B(B)
	A=B	B	A(B) := caractère lu
*
* A(B) = le sujet
*
	GOSUBL	=poscmd
	GONC	NotFnd	"Not Found"
*
* Commande trouvée :
* C(A) = D(A) = index de la commande.
*
	LC(4)	(=id)~(=teHL00)
	C=C+D	A	C(A) := numéro du message

	GOSUBL	=dspmsg
	GOSUBL	=KEYWT

	GOLONG	=BOUCLE

*
* L'utilisateur a demandé une aide générale. On va
* donc afficher les messages teHL00 à teHL11.
*
 H500	GOSUBL	valide
	D0=(5)	curcmd
	C=0	S
	DAT0=C	S	curcmd := 0

 H520	LC(5)	(=id)~(=teHL00)
	A=0	A
	D0=(5)	curcmd
	A=DAT0	P
	C=C+A	A	C(A) := teHL00 + curcmd
	GOSUBL	=dspmsg	afficher le message

*
* Attente de l'appui sur une touche
*
* if (key already pressed)	/* repeat */
*   then get key
*   else wait key
* fi
*
	GOSBVL	=RPTKY	Y-a-t-il une touche en répétition ?
	GONC	H525	Non : il faut utiliser KEYWAIT$
	A=B	A	Oui : A(A) = touche
	GOC	H530	B.E.T.
 H525	GOSUBL	=KEYWT	Attendre. A(A) = B(A) = touche
 H530
*
* A(B) = touche pressée
*
	D0=(5)	curcmd
	C=DAT0	P
	B=C	A	B(0) := curcmd

	GOSBVL	=FINDA	n'abime ni B(A)
	CON(2)	#32	[^]
	REL(3)	Hup
	CON(2)	#33	[v]
	REL(3)	Hdown
	CON(2)	#32+112	[g][^]
	REL(3)	Htop
	CON(2)	#33+112	[g][v]
	REL(3)	Hbot
	NIBHEX	00
*
* Touche normale. Retour à la ligne de commande
*
	GOLONG	=BOUCLE

 Hup	?B=0	P
	GOYES	H600
	B=B-1	P
	GONC	H600
 Hdown	LC(1)	=NCMDED
	?B>=C	P
	GOYES	H600
	B=B+1	P
	GONC	H600	B.E.T.
 Htop	B=0	P
	GOTO	H600
 Hbot	LC(1)	=NCMDED
	B=C	P
*
* B(0) = nouvelle commande courante
*
 H600	A=B	P	A(0) := nouvelle comamnde courante
	D0=(5)	curcmd
	DAT0=A	P
	GOTO	H520

	STITLE	Commande Join

************************************************************
* cmJOIN
*
* But: joindre deux (ou plus) lignes
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 : ldebut
*	R2 : lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: quer?, abCn, WRITE?, valide, seek, LIFlen,
*   MEMCKL, MOVE*M, FMTLIF, query, TBLJMC, RPLLIN, dellin,
*   setcou
* Niveaux: N/A
* Historique:
*   88/10/23: PD/JT documentation
*   88/10/29: PD/JT conception & codage
*   89/06/17: PD/JT test du flag "read-only"
*   89/08/07: PD/JT valeur "fin" par défaut si 1 argument
************************************************************

=cmJOIN	GOSUBL	quer?	QUERY := R3(S)
*
* Analyse une commande de la forme :
*	[<ligne> [, <ligne>]] J [<nombre>]
*

*
* Correction du 89/08/07 : s'il y a un argument, alors
* la valeur par défaut de "fin" = "début" + 1
*
	A=R0
	?A=0	A
	GOYES	J050
	A=R1		A(A) := ldebut
	GONC	J060	B.E.T.
*
* Fin de la correction du 89/08/07.
*
 J050	D0=(5)	=COUR
	A=DAT0	A	A(A) = .
 J060	A=A+1	A	lfin = .+1 par défaut, ou ldebut+1
	ST=1	0	cas non standard
	GOSUBL	abCn
*
* R1 = ligne de début
* R3 = nombre de lignes à joindre (déjà testé)
*
	GOSUBL	valide

*
* Test de l'accessibilité
* Changement du 17/06/89 : test du flag "read-only"
*
	D1=(5)	=RDONLY
	C=DAT1	S
	GOSUBL	=WRITE?
	GONC	Jerr	C(A) = eFACCS, eFPROT ou eFOPEN

	D0=(5)	remain
	C=R3
	DAT0=C	A	remain := nombre de lignes restantes
	D0=(2)	prem
	C=R1
	DAT0=C	A	prem := numéro de la ligne de début
*
* C(A) := numéro de la ligne à chercher
*
	GOSUBL	=seek	abime tous les registres et TMP5
*
* D0 = ^ début de la ligne
*
	CD0EX		C(A) := ^ première ligne
	R0=C		R0(A3 := ^ première ligne
	R1=C		R1(A) := ^ ligne courante

	D0=(5)	remain
	C=DAT0	A
	R3=C		R3(A) := nombre de lignes restantes
*
* Préparer le buffer
*
	D0=(5)	=OUTBS
	A=DAT0	A
	C=0	A
	LC(1)	4
	A=A+C	A
	D0=D0+	5	D0=(5)	=AVMEMS
	DAT0=A	A

*
* Invariant de boucle
*   (OUTBS...OUTBS+3) = place pour la longueur LIF
*   (OUTBS+4..AVMEMS) = lignes déjà écrites
*   R3 = nombre de lignes restant à joindre
*   R1 = ^ ligne à joindre
*   prem = numéro de la première ligne
*   R0 = ^ première ligne
*
 J500	C=R3
	C=C-1	A
	GONC	J510
	GOTO	J600	sortie de la boucle
 J510	R3=C
*
* A-t-on assez de place ?
*
	C=R1
	D0=C
	GOSUBL	=LIFlen	C(A) := longueur en octets
	C=C+C	A	C(A) := ... en quartets (sans long)
	GOSBVL	=MEMCKL
	GONC	J520	Pas d'erreur

* C(A) = "Insufficient Memory"
 Jerr	GOLONG	=xederr

 J520
*
* D0 = ^ début ligne LIF
*
* Préparer les paramètres pour MOVE*M
* source = ^ ligne courante
* longueur = 2*LEN (ligne courante)
* dest = AVMEMS
*
	GOSUBL	=LIFlen	C(A) := longueur en octets
	R2=A		sauvegarder la longueur totale
	C=C+C	A	C(A) := longueur en nibs
	B=C	A	B(A) := block length

	D0=D0+	4	sauter la longueur LIF
	AD0EX		A(A) := source address

	D0=(5)	=AVMEMS
	C=DAT0	A	C(A) := dest address
*
* A(A) = source address
* B(A) = length of block in nibs
* C(A) = dest address
*
	GOSBVL	=MOVE*M	abime D0 et D1
*
* Ajouter un espace et mettre à jour AVMEMS
*
	C=C+B	A	C(A) := nouveau AVMEMS
	D0=C		*(AVMEMS)++ = ' '
	LCASC	' '
	DAT0=C	B
	D0=D0+	2
	CD0EX
	D0=(5)	=AVMEMS
	A=DAT0	A	A(A) := ancien AVMEMS
	R2=A		R2(A) := ancien AVMEMS
	DAT0=C	A	AVMEMS := nouveau AVMEMS
*
* Mode interactif ?
*
	D0=(5)	=QUERY
	C=DAT0	S
	?C=0	S
	GOYES	J580	Non
*
* Première jointure ?
*
	C=R3
	C=C+1	A
	D0=(4)	remain
	A=DAT0	A
	?A=C	A	première jointure ?
	GOYES	J580	oui : alors mode normal
*
* Il faut poser la question, et éventuellement revenir
* en arrière si la réponse est négative.
*
	C=R1		il faut sauver R1 car query l'abime
	D0=(5)	Jsave
	DAT0=C	A	Jsave+0 := R1(A)

	ST=0	0	ne pas modifier AVMEMS
	GOSUBL	=FMTLIF	Mettre une longueur LIF plausible
	GOC	JerR	"Line Too Long"
* calculer le numéro de colonne
	A=R2		ancien R2 (fin de la ligne précéd.)
	C=0	W
	D0=(5)	=OUTBS
	C=DAT0	A	C(A) := ^ début de la ligne (LIF)
	D0=C		D0 := ^ début ligne
	C=A-C	A	C(A) := long. jusqu'avant la ligne
	CSRB
	C=C-1	A	enlever la longueur LIF
	C=C-1	A	C(A) := no de colonne
* calculer le no de ligne
	D1=(5)	prem
	A=DAT1	A	A(A) := no première ligne

	GOSUBL	=query

	D1=(5)	Jsave
	A=DAT1	A
	R1=A		R1 := ancienne valeur sauvegardée

	GOSBVL	=TBLJMC
	REL(3)	J590	[ATTN] ou [Q] ou [f][OFF]
	REL(3)	J580	[Y]
	REL(3)	J590	[N]

 J580
*
* Mettre à jour le pointeur dans le fichier
*
	C=R1		C(A) := ^ ligne courante
	D0=C
	GOSUBL	=LIFlen	A(A) := longueur totale
	CD0EX		C(A) := ^ ligne courante
	C=C+A	A	C(A) := ^ ligne suivante
	R1=C
	GOTO	J500

 JerR	GOTO	Jerr
*
* [ATTN] ou [Q] : il faut enlever la dernière ligne
* jointe, réactualiser le nombre de lignes et
* remplacer dans le fichier.
* - R0 = ^ première ligne dans le fichier
* - R1 = ^ début de la ligne refusée dans le fichier
* - R2 = ^ fin de la dernière ligne acceptée dans OUTBS
* - R3 = nombre de lignes restant à traiter
* - remain = nombre de lignes initial
* - prem = numéro de la première ligne
*
 J590	C=R2		remettre AVMEMS à la valeur avant
	D0=(5)	=AVMEMS
	DAT0=C	A	AVMEMS := valeur avant

	D0=(4)	remain	D0 := ^ nombre de lignes initial
	A=DAT0	A	A(A) := nombre de lignes initial
	C=R3
	A=A-C	A
	A=A-1	A
	DAT0=A	A	remain = initial - traitées
*
* Attention ! Le code continue !
*

*
* Fin de la boucle de recopie des lignes
*
 J600
*
* (OUTBS...OUTBS+3) = place pour la longueur LIF
* (OUTBS+4..AVMEMS) = somme des lignes jointes
* R0 = ^ première ligne dans le fichier
* R1 = ^ ligne juste après la dernière dans le fichier
* prem = numéro de la première ligne
* remain = nombre initial de lignes à joindre
*
* Enlever le dernier espace ajouté
*
	D0=(5)	=AVMEMS
	C=DAT0	A
	C=C-1	A
	C=C-1	A
	DAT0=C	A	AVMEMS -= 2
*
* Mettre en place la longueur LIF
*
	ST=1	0	ajuster AVMEMS si besoin est
	GOSUBL	=FMTLIF
	GOC	JerR	"Line Too Long"
*****************************************
* Maintenant, les choses sont en place. Les anciennes lignes
* sont toujours dans le fichier, et la nouvelle ligne est
* en (OUTBS..AVMEMS) bien formattée.
* R0 = ^ première ligne dans le fichier
* R1 = ^ première ligne après la dernière jointe
* R2 = ?
* R3 = 0
* prem = numéro de la première ligne
* remain = nb de lignes jointes (non comprise la première)
* (OUTBS..AVMEMS) = nouvelle ligne
*****************************************
*
* I - Suppression des (remain) lignes jointes dans le
* tableau de pointeurs.
*   Suppression des lignes (prem+1, prem+1+remain-1)
*   On a enlevé (R1-R0)-LIFlen(OUTBS) nibs
*
	D0=(5)	=OUTBS
	C=DAT0	A
	D0=C
	GOSUBL	=LIFlen	A(A) := longueur en nibs
	B=A	A	B(A) := LIFlen(OUTBS)
	A=R1		A(A) := ^ fin
	C=R0		C(A) := ^ ligne début
	A=A-C	A	A(A) := tout ce qu'on a lu
	A=A-B	A	A(A) := longueur de ce qu'on enlevé

	D0=(5)	prem
	C=DAT0	A
	B=C	A
	B=B+1	A	B(A) := no de l'ancienne prem. ligne

	D0=(5)	remain
	C=DAT0	A	C(A) := nombre de lignes enlevées
	C=C-1	A

	GOSUBL	=dellin

*
* II - Remplacement physique de la ligne dans le fichier
*
	A=R1		A(A) := ^ ligne suivante
	C=R0		C(A) := ^ première ligne
	C=A-C	A	C(A) := length of old line
	R3=C		R3(A) := length of old line
	D0=(5)	=FILADR
	C=DAT0	A	C(A) := ^ file header
*
* A(A) = ^ last nibble + 1 of old line
* C(A) = ^ file header
* R3(A) = length of old line (in nibs)
* (OUTBS..AVMEMS) = new line
*
    if JPCPRV
	GOSBVL	=RPLLIN
    else
	GOSBVL	=MGOSUB
	CON(5)	=RPLLIN
    endif
*
* On ne peut ici avoir que deux erreurs :
*   "Illegal Access" : déjà testé par WRITE?
*   "Insufficient Memory" : on ne fait que tasser
* Donc on ne peut avoir d'erreur...
* Le branchement "GOC	Jerr" est inutile

	GOSUBL	=syncbf

*
* Ligne courante := la nouvelle ligne
*
	D0=(5)	prem
	C=DAT0	A
	GOSUBL	setcou
	GOLONG	=BOUCLE

	STITLE	Commande Delete

************************************************************
* cmDEL
*
* But: effacer une ou plusieurs ligne dans le fichier
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 : ldebut
*	R2 : lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: noquer, set.db, GETFIL, dspmsg, KEYWT, valid?,
*   FINDA, seek, syncbf, dellin, OBCOLL, RPLLIN, MVFIL,
*   setcou, getdbf, svR1R2, extsek
* Niveaux: N/A
* Algorithme:
*   analyser la ligne de commande
*   tester l'accessibilité aux fichiers
*   demander confirmation si plus d'une ligne
*   si destruction interne
*     alors détruire
*     sinon
*       chercher la fin du fichier externe
*	déplacer le bloc dans le fichier externe
*	DERN += nombre de lignes détruites
*   fin si
*   mise à jour du buffer (en modifiant DERN)
* Historique:
*   88/10/31: PD/JT conception & codage
*   88/11/12: PD/JT amélioration du traitement d'erreur
*   88/11/12: PD/JT séparation de set.db
*   88/11/12: PD/JT séparation de getdbf
*   88/11/13: PD/JT séparation de svR1R2
*   88/11/13: PD/JT séparation de extsek
*   88/11/13: PD/JT utilisation de YNQ
*   89/06/17: PD/JT test du flag "read-only"
************************************************************

=cmDEL
***************************************
* Analyse de la ligne de commande
***************************************
	GOSUBL	noquer	interdit le "?"

*
* Mettre des paramètres par défaut et tester la validité
*
	GOSUBL	set.db	(., <ligne de début>)
*
* Sauver les paramètres de D :
* R1 = ldebut
* R2 = lfin
*
	GOSUBL	svR1R2
*
* Deux cas possibles pour le fichier :
*			existe  n'existe pas
*   D <fichier>		erreur	  creation
*   D <fichier> +      chercher   creation
*
	ST=1	=sDELET	cas 'D' (et pas 'C'/'M')
	ST=0	=sXCHG	cas 'D' (et pas 'X')
	GOSUBL	=GETFIL	analyse et cherche le fichier
	GOC	ERREuR	beep !
*
* Flag sCREAT = 1 si le fichier a dû être crée
*

*
* Valider ce qui a été reconnu.
*
	GOSUBL	valid?	analyse de la ligne terminée
	GOC	Derr	Erreur ! Il faut revenir en arrière

*
* Tester l'accès au(x) fichier(s)
* Changement du 17/06/89 : test du flag "read-only"
*
	D1=(5)	=RDONLY
	C=DAT1	S
	GOSUBL	=WRITE?
	GONC	Derr	C(A) = eFACCS, eFPROT ou eFOPEN

	D1=(5)	=EXTFIL
	C=DAT1	A
	?C=0	A
	GOYES	D060	Pas de fichier extérieur
	GOSUBL	=CHKWRT
	GOSUBL	=WRITE?
	GONC	Derr	C(A) = eFACCS, eFPROT ou eFOPEN

	GOC	D060	B.E.T. (pas d'erreur)

*
* Commande non reconnue. Il faut donc revenir en arrière et
* détruire éventuellement le fichier.
*
 Derr	GOSUBL	=PURGE	n'abime pas C(A)
 ERREuR	GOLONG	=xederr

***************************************
* Demander confirmation
***************************************

 D060	D0=(5)	ldeb
	A=DAT0	A	A(A) := ldeb
	D0=D0+	5	D0=(5)	lfin
	C=DAT0	A	C(A) := lfin
	?A=C	A
	GOYES	D100	détruire sans confirmation
*
* Poser la question à l'utilisateur
*
	LC(4)	(=id)~(=teDELE)	"Ok to Delete? Y/N:"
	GOSUBL	=dspmsg
	GOSUBL	=KEYWT
*
* Cherche la signification de la touche. Eventuellement,
* autorise la traduction par un traducteur de message.
*
	GOSUBL	=YNQ
*
* C(0) = 0 si non reconnu, 1 si Y, 2 si N, 3 si Q
*
	GOSBVL	=TBLJMC
	REL(3)	D070	non reconnu
	REL(3)	D100	[Y]
	REL(3)	D070	[N]
	REL(3)	D070	[Q]
*
* Ouf ! L'utilisateur s'est aperçu de sa méprise...
* Il faut effacer le fichier si on l'a créé spécialement
* pour l'occasion.
*
 D070	GOSUBL	=PURGE
	GOLONG	=BOUCLE	pas de destruction

*
* Suppression acceptée par l'utilisateur
*

***************************************
* Determination des adresses
***************************************

 D100
*
* Calcule addeb, adfin; findeb et nblig à partir de
* ldeb et lfin.
* ldeb = numéro de la première ligne à détruire
* lfin = numéro de la dernière ligne à détruire
*
	GOSUBL	getdbf
*
* addeb = ^ début de la zone à détruire (début de ldeb)
* adfin = ^ fin de la zone à détruire	(fin de lfin)
* findeb = adfin - addeb
* nblig = lfin - ldeb + 1
*

*
* A partir de maintenant, deux solutions :
* - destruction interne (ou destruction simple)
* - destruction externe (move dans un fichier externe)
*
	D0=(5)	=EXTFIL	destruction externe ?
	C=DAT0	A
	?C#0	A	y-a-t-il un fichier ?
	GOYES	D500	oui : destruction externe

***************************************
* Cas I : Destruction simple
***************************************

	GOSBVL	=OBCOLL	met (OUTBS..AVMEMS) à 0

	D0=(5)	adfin
	A=DAT0	A	A(A) := ad. last nib of old line + 1
	D0=D0-	5	D0=(5)	addeb
	C=DAT0	A	C(A) := ^ début
	C=A-C	A	C(A) := longueur
	R3=C

	D0=(5)	=FILADR
	C=DAT0	A	C(A) := ^ file header

*
* A(A) = address of last nibble + 1 of old line
* C(A) = address of file header
* R3(A) = length of old line in nibs
*
    if JPCPRV
	GOSBVL	=RPLLIN
    else
	GOSBVL	=MGOSUB
	CON(5)	=RPLLIN
    endif
*
* Il ne peut pas y avoir d'erreur. L'accès au fichier a
* été déjà testé, et on détruit, donc on tasse : il ne
* peut pas y avoir "Insufficient Memory".
* Il n'y a donc pas de "GOC erreur"
*
	GOTO	D900

***************************************
* Cas II : Destruction externe
***************************************

 D500
*
* Chercher la fin du fichier externe
* (adresse de destination)
*
	LC(5)	-1	chercher la dernière ligne
	D0=(5)	=EXTFIL
	A=DAT0	A	A(A) := ^ file header
	GOSUBL	=extsek
*
* D0 = ^ fin du fichier
* A(A) = numéro de la dernière ligne du fichier + 1
*
	CD0EX		C(A) := ^ fin du fichier
	R0=C		R0(A) := dstadr
*
* Debut et fin de la partie à remplacer
*
	D0=(5)	addeb
	C=DAT0	A
	R1=C		R1(A) := orgdeb
	D0=D0+	5	D0=(5)	adfin
	C=DAT0	A
	R2=C		R2(A) := orgfin

	D0=(5)	=FILADR
	A=DAT0	A	A(A) := header origine

	D0=(4)	=EXTFIL
	C=DAT0	A	C(A) := header destination

	ST=1	=sMOVE
*
* A(A) = ^ header origine (notre fichier)
* R1(A) = ^ début partie à déplacer
* R2(A) = ^ fin partie à déplacer
* C(A) = ^ header destination (fichier externe)
* R0(A) = ^ emplacement d'insertion
* sMOVE=1 pour copie avec destruction
*
	GOSUBL	=MVFILE
	GONC	D600
*
* S'il y a eû erreur, aucun des deux fichiers n'a bougé
*
	GOTO	Derr	Purger le fichier externe si besoin
*
* A(A) = nouvelle valeur de FILADR
* Réactualiser FILADR et tester s'il faut modifier
* le buffer (en fait, simplement DERN est modifié)
*
 D600	D0=(5)	=FILADR
	C=DAT0	A	C(A) := ancien FILADR
	DAT0=A	A	FILADR := nouvelle valeur
	D0=(4)	=EXTFIL
	A=DAT0	A	A(A) := ancien EXTFIL
	?A#C	A	fichiers différents ?
	GOYES	D900	oui : sortie
*
* Non : modifier DERN
*
	D0=(4)	nblig
	C=DAT0	A	C(A) := lfin - ldeb + 1
	D0=(4)	=DERN
	A=DAT0	A	A(A) := dernière
	A=A+C	A
	DAT0=A	A	DERN += lfin - ldeb + 1

***************************************
* Mise à jour du buffer et Sortie
***************************************

 D900

*
* Synchroniser le buffer avant de travailler dessus.
*
	GOSUBL	=syncbf

*
* Paramêtres à mettre en place pour "dellin" :
* - nombre de lignes			(lfin - ldeb + 1)
* - longueur de ce qui a été enlevé	(adfin - addeb)
* - numéro de l'ancienne première ligne	(ldeb)
*
	D0=(5)	findeb
	A=DAT0	A	A(A) := long. de ce qui a été enlevé

	D0=(4)	ldeb
	C=DAT0	A
	B=C	A	B(A) := ldeb

	D0=(4)	nblig
	C=DAT0	A	C(A) := nombre de lignes
*
* A(A) = longueur de ce qui a été enlevé
* B(A) = numéro de l'ancienne première ligne
* C(A) = nombre de lignes
*
	GOSUBL	=dellin	actualise DERN

*
* Actualise le numéro de la ligne courante.
*
	D0=(5)	ldeb
	C=DAT0	A
	GOSUBL	setcou	"." := ldeb

	GOLONG	=BOUCLE

	STITLE	Commande Exchange File

************************************************************
* cmXCHG
*
* But: changer le fichier en cours d'édition
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 = ldebut
*	R2 = lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: noquer, GETFIL, valid?, PURGE, inibuf, setcou
* Niveaux: N/A
* Historique:
*   88/11/11: PD/JT conception & codage
*   88/11/13: PD/JT utilisation de svR1R2
*   89/06/17: PD/JT mise à jour du flag "read-only"
************************************************************
 
 InvCmd	GOLONG	invcmd
 InvPrm	GOLONG	invprm

=cmXCHG	GOSUBL	noquer
	C=R0		nb lignes
	?C#0	A
	GOYES	InvCmd	"Invalid Cmd"
*
* Analyser les paramètres de la commande. En particulier,
* regarder s'il y a un nom de fichier suivi éventuellement
* d'un '+'.
*
	ST=1	=sDELET	cas D ou X (et pas C/M)
	ST=1	=sXCHG	cas X (et pas D)
	GOSUBL	=GETFIL	analyse et cherche le fichier
	GOC	ErReuR	ça s'est mal passé
*
* Le nom de fichier est obligatoire. Vérification :
*
	D0=(5)	=EXTFIL
	C=DAT0	A
	?C=0	A
	GOYES	InvPrm	"Invalid Param"
*
* Tout a été testé. Valider ce qui a été reconnu
*
	GOSUBL	valid?
	GONC	X050	Pas d'erreur

*
* Commande invalide. Il faut revenir en arrière et détruire
* le fichier s'il vient d'être créé.
*
	GOSUBL	=PURGE	n'abime pas C(A)
 ErReuR	GOLONG	=xederr
 
*
* Le fichier est la. Reste a mettre les bons pointeurs aux
* bons endroits.
*
 X050	D1=(5)	=EXTFIL
	C=DAT1	A
	D1=(4)	=FILADR
	DAT1=C	A	FILADR := EXTFIL
*
* Regarder si on peut modifier le fichier extérieur.
*
	GOSUBL	=CHKWRT
	D1=(5)	=RDONLY
	DAT1=C	S
*
* Initialiser le tableau de pointeurs
*
	GOSUBL	=inibuf

	C=0	A
	GOSUBL	setcou	courante := 1
*
* Et retour a la boucle principale.
*
	GOLONG	=BOUCLE

	STITLE	Commandes Copy / Move

************************************************************
* cmMOVE, cmCOPY
*
* But: déplacer ou copier une partie d'un fichier avant la
*   ligne courante.
* Entrée:
*   - D(A) = LEN(param)
*   - D1 = ^ param
*   - R0 = nb de lignes introduites
*	R1 = ldebut
*	R2 = lfin
*	R3(S) = 1 si '?' avant la commande
* Sortie: par BOUCLE
* Abime: tout
* Appelle: noquer, GETFIL, valide, set.db, getdbf, svR1R2,
*   CHKWRT, WRITE?
* Niveaux: N/A
* Algorithme:
*   tester si l'utilisateur a demande un fichier externe
*   si interne
*     alors
*	valider les paramètres (., <ldebut>)
*	chercher les deux adresses dans le fichier courant
*     sinon
*	valider les paramètres (1, Inf)
*	chercher les deux adresses dans le fichier externe
*   fin si
*   déplacer le bloc
*   si cas "copie" ou (externe et fichiers differents)
*     alors
*	addlin (ligne début = courante, nblignes = nblig)
*	courante += nblig
*     sinon
*	si courante < ldeb
*	  alors
*	    addlin (début = ldeb, nblignes = nblig)
*	    dellin (début = courante+nblig,nblignes = nblig)
*	    courante += nblig
*	  sinon si courante > lfin
*	    addlin (début = courante, nblignes = nblig)
*	    dellin (début = ldeb, nblignes = nblig)
*	  sinon
*	    courante := lfin + 1
*	  fin si
*       fin si
*   fin si
* Historique:
*   88/11/12: PD/JT conception & codage
*   89/06/17: PD/JT test du flag "read-only"
************************************************************

=cmMOVE	C=0	A	C(0) := 0 (move)
	GOTO	C000

=cmCOPY	LC(1)	1	C(0) := 1 (copie)

*
* C(0) = 1 (copie) ou 0 (move)
*
 C000	D0=(5)	Csave
	DAT0=C	P
*
* Interdire C/M avec '?'
*
	GOSUBL	noquer
*
* Sauvegarder R0, R1 et R2 car GETFIL les abime.
*
	D0=D0+	1	Csave + 1
	C=R0		C(A) = 0..2
	DAT0=C	P	Csave1 + 1 := nb de lignes
	GOSUBL	svR1R2
*
* Chercher si l'utilisateur a demande un C/M externe
*
	ST=0	=sDELET	cas 'C' ou 'M'
	GOSUBL	=GETFIL	Abime STMTxx et FUNCxx
	GOC	Erreur

*
* Interdire tout ce qui peut suivre.
*
	GOSUBL	valide

	D0=(5)	=COUR
	C=DAT0	A
	GOSUBL	=seek	D0 := adresse de la ligne courante
	CD0EX
	D0=(5)	curadr
	DAT0=C	A	curadr := ^ ligne courante

*
* Tester les acces aux fichiers.
* On en profite pour restaurer "copie" qui etait sauvegarde
* en Csave.
*
	D0=(4)	Csave
	C=DAT0	S
	D0=(4)	copie
	DAT0=C	S	copie := valeur sauvegardée
	?C#0	S
	GOYES	C050	Copy
*
* Move. Tester les deux acces.
* Changement du 17/06/89 : test du flag "read-only"
*
	D1=(5)	=RDONLY
	C=DAT1	S
	GOSUBL	=WRITE?
	GONC	Erreur	C(A) = eFACCS, eFPROT ou eFOPEN

	D1=(5)	=EXTFIL
	C=DAT1	A
	?C=0	A
	GOYES	C070	Pas de fichier extérieur
	GOSUBL	=CHKWRT
	GOSUBL	=WRITE?
	GOC	C070	Pas d'erreur
*
* Attention ! Le code continue !
*
 Erreur	GOLONG	=xederr

 C050
*
* Changement du 17/06/89 : test du flag "read-only"
*
	D1=(5)	=RDONLY
	C=DAT1	S
	GOSUBL	=WRITE?
	GONC	Erreur	C(A) = eFACCS, eFPROT ou eFOPEN
*
* Restaurer R0, R1 et R2. D0 n'a pas été modifie par WRITE?
*
 C070	D0=(5)	(Csave)+1
	C=0	A
	C=DAT0	P	R0(A) := Csave1 + 1
	R0=C

	D0=(4)	ldeb
	C=DAT0	A	R1(A) := ldeb
	R1=C
	D0=D0+	(lfin)-(ldeb)
	C=DAT0	A	R2(A) := lfin
	R2=C
*
* Differentier C/M interne et externe
*
	D0=(5)	=EXTFIL
	C=DAT0	A	C(A) := adresse du fichier externe
	?C=0	A
	GOYES	C100	C/M interne
	GOTO	C200	C/M externe

****************************************
* C/M interne
****************************************

 C100
*
* Determine les numéros de lignes par defaut.
*
	GOSUBL	set.db	(., <ligne de début>)
*
* Sauvegarde R1 et R2 en lieu sur
*
	GOSUBL	svR1R2
*
* Calcule addeb, adfin, findeb et nblig à partir de
* ldeb et lfin.
* ldeb = numéro de la première ligne à détruire
* lfin = numéro de la dernière ligne à détruire
*
	GOSUBL	getdbf
	GOTO	C300	Tout est en place pour MVFILE

****************************************
* C/M externe
****************************************

 C200
*
* Tester la validite des paramètres
* Paramêtres par defaut : (1, #FFFFF)
*
	C=R0
	C=C-1	A
	GOC	C210	nb paramètres = 0
	C=C-1	A
	GONC	C220	nb paramètres = 2
* nb paramètres = 1
	GOC	C215	nb parmaêtres = 1
* nb paramètres = 0
 C210	C=0	A
	C=C+1	A	C(A) := 1
	R1=C		ldebut := 1
 C215	LC(5)	-1
	R2=C		lfin := Inf par defaut
*
* R1 = ldebut
* R2 = lfin
*
 C220
*
* Tests :
*   si ldebut = 0 alors erreur
*   si ldebut > lfin alors erreur
*
	A=R1		A(A) := ldebut
	?A=0	A
	GOYES	invPrm	"Invalid Parm"
	C=R2		C(A) := lfin
	?A<=C	A
	GOYES	C250
 invPrm	GOLONG	invprm

 c990	GOTO	C990
*
* R1 = ldebut
* R2 = lfin
*
 C250	GOSUBL	svR1R2	sauver (R1, R2) en (ldeb, lfin)

	C=R1		C(A) := ldeb
	D0=(5)	=EXTFIL
	A=DAT0	A	A(A) := ^ file header
	GOSUBL	=extsek	A(A) = numéro trouve, D0 = ^ ligne
	D1=(5)	addeb
	CD0EX
	DAT1=C	A	addeb := ^ ligne trouvée
	D0=C
	D1=(4)	ldeb
	DAT1=A	A	ldeb := numéro trouve

	D1=D1+	(lfin)-(ldeb)
	C=DAT1	A	C(A) := lfin
	B=C	A	B(A) := lfin
	B=B+1	A
	GOC	C260	branch if lfin = #FFFFF
	C=C+1	A	C(A) := lfin + 1
 C260
	B=A	A	B(A) := ldeb
	D1=(5)	=EXTFIL
	A=DAT1	A	A(A) := ^ file header
*
* A(A) = ^ file header
* B(A) = ldeb
* D0 = ^ ligne de début
* C(A) = lfin + 1 ou bien #FFFFF
*
	GOSUBL	=extsk+	A(A) = numéro trouve, D0 = ^ ligne
	D1=(5)	adfin
	CD0EX
	DAT1=C	A	adfin := ^ ligne trouvée
	D1=(4)	lfin
	DAT1=A	A	lfin := numéro trouve
*
* A(A) = lfin (artificiellement augmente de 1)
* C(A) = adfin
* D1=(5) lfin
*

*
* Reste à calculer adfin - addeb et lfin - ldeb + 1
*
	B=C	A	B(A) := adfin
	D1=D1-	(lfin)-(ldeb)
	C=DAT1	A	C(A) := ldeb
	?C=0	A
	GOYES	c990	retour
	C=A-C	A	C(A) := lfin - ldeb
	D1=(4)	nblig
	DAT1=C	A	nblig := lfin - ldeb

	A=B	A	A(A) := adfin
	D1=(4)	addeb
	C=DAT1	A	C(A) := addeb
	C=A-C	A	C(A) := adfin - addeb
	D1=(4)	findeb
	DAT1=C	A
*
* Ca y est !
* - ldeb = numéro de ligne de début (vérifié ds le fichier)
* - lfin = numéro de ligne de fin (vérifie dans le fichier)
* - addeb = ^ ligne de début dans le fichier externe
* - adfin = ^ ligne de fin dans le fichier externe
* - findeb = adfin - addeb
* - nblig = lfin - ldeb + 1
*
* Le code peut maintenant continuer dans le tronc commun.
*

****************************************
* C/M : Partie commune (déplacer le bloc)
****************************************

 C300
*
* addeb = ^ début de la zone à détruire (début de ldeb)
* adfin = ^ fin de la zone à détruire	(fin de lfin)
* findeb = adfin - addeb
* nblig = nombre de lignes traitées
* curadr = adresse de la ligne courante
* FILADR = adresse du fichier courant
* EXTFIL = 0 ou adresse du fichier externe
*

	ST=0	=sMOVE	cas "copie" par défaut
	D0=(5)	copie
	C=DAT0	S	C(S) := 1 si "copie", 0 si "move"
	?C#0	S	cas "copie" ?
	GOYES	C310	oui
	ST=1	=sMOVE	non : alors cas "move"

 C310	D0=(4)	addeb
	C=DAT0	A	C(A) := addeb
	R1=C		R1 := ^ début partie à déplacer
	D0=D0+	5	D0=(5) adfin
	C=DAT0	A	C(A) := adfin
	R2=C		R2 := ^ début partie à déplacer
	D0=(4)	curadr
	C=DAT0	A	C(A) := ^ ligne courante
	R0=C		R0 := ^ destination address
	D0=(4)	=FILADR
	C=DAT0	A	A(A) := ^ header destination
	D0=(4)	=EXTFIL
	A=DAT0	A	C(A) := 0 ou ^ header origine
	?A#0	A	C/M externe ?
	GOYES	C320	non : A(A) est donc valide.
	A=C	A	A(A) := ^ header origine
 C320
*
* A(A) = ^ header origine
* C(A) = ^ header destination
* R0(A) = dstadr
* R1(A) = orgdeb
* R2(A) = orgfin
*
	GOSUBL	=MVFILE
	GONC	C330	Pas d'erreur
	GOLONG	=xederr

 C330
*
* Réactualiser les adresses des deux fichiers qui ont pu
* être modifiées. Note : l'adresse EXTFIL pouvait être
* nulle avant l'appel, mais est maintenant au moins égale
* à FILADR.
*
	D0=(5)	=FILADR
	DAT0=C	A	FILADR réactualisé (destination)
	D0=(4)	=EXTFIL
	DAT0=A	A	EXTFIL réactualisé (origine)
*
* Le buffer a très certainement été déplacé durant
* l'opération. Remettre son adresse à jour :
*
	GOSUBL	=syncbf
*
* Les déplacements sont faits. Il faut donc mettre à jour
* le buffer, et c'est très très compliqué !
*
	D0=(5)	copie
	C=DAT0	S
	?C#0	S
	GOYES	C400	"copie"

	D0=(4)	=FILADR
	C=DAT0	A	C(A) := ^ fichier courant
	D0=(4)	=EXTFIL
	A=DAT0	A	A(A) := ^ fichier externe
	?A=C	A
	GOYES	C500	M interne

****************************************
* C interne/externe ou M externe
****************************************

 C400
*
* Ajouter (lfin - ldeb + 1) lignes juste avant la ligne
* "courante".
*
	D0=(5)	=COUR
	C=DAT0	A
	B=C	A	B(A) := no nouvelle première ligne

	D0=(4)	nblig
	C=DAT0	A	C(A) := lfin - ldeb + 1

	D0=(4)	findeb
	A=DAT0	A	A(A) := lg de ce qui est rajouté

	GOSUBL	=addlin
*
* actualiser courante.
*
	D0=(5)	nblig
	A=DAT0	A	A(A) := nblig
	D0=(4)	=COUR
	C=DAT0	A	C(A) := courante
	C=C+A	A	C(A) := nouvelle valeur de courante
	GOTO	C900

****************************************
* M interne
****************************************

 C500	D0=(5)	=COUR
	A=DAT0	A	A(A) := courante
	D0=(4)	ldeb
	C=DAT0	A	C(A) := ldeb
	?A>=C	A	courante >= ldeb
	GOYES	C520
*
* courante avant le bloc (courante < ldeb)
*
	D0=(5)	ldeb
	C=DAT0	A
	B=C	A	B(A) := ligne début
	D0=(4)	findeb
	A=DAT0	A	A(A) := long de ce qui a été rajouté
	D0=(4)	nblig
	C=DAT0	A	C(A) := nb lignes
*
* A(A) = longueur de ce qui a été rajouté (adfin - addeb)
* B(A) = no de la nouvelle première ligne (ldeb)
* C(A) = nombre de lignes		  (nblig)
*
	GOSUBL	=addlin

	D0=(5)	=COUR
	C=DAT0	A
	B=C	A
	D0=(5)	nblig
	C=DAT0	A	C(A) := nblignes
	B=B+C	A	B(A) := courante + nb lignes
	D0=(4)	findeb
	A=DAT0	A	A(A) := long de ce qui a été enlevé
*
* A(A) = longueur de ce qui a été enlevé  (adfin - addeb)
* B(A) = no de l'ancienne première ligne  (ldeb)
* C(A) = nombre de lignes		  (nblig)
*
	GOSUBL	=dellin

	D0=(5)	nblig
	A=DAT0	A	A(A) := nblignes
	D0=(4)	=COUR
	C=DAT0	A	C(A) := courante
	C=C+A	A	C(A) := courante + nblignes
	GOTO	C900

 C520	D0=D0+	(lfin)-(ldeb)
	C=DAT0	A	C(A) := lfin
	?A<=C	A	courante <= lfin
	GOYES	C540
*
* courante après le bloc (courante > lfin)
*
	D0=(5)	=COUR
	C=DAT0	A
	B=C	A	B(A) := ligne début
	D0=(4)	findeb
	A=DAT0	A	A(A) := long de ce qui a été rajouté
	D0=(4)	nblig
	C=DAT0	A	C(A) := nb lignes
*
* A(A) = longueur de ce qui a été rajouté (adfin - addeb)
* B(A) = no de la nouvelle première ligne (courante)
* C(A) = nombre de lignes		  (nblig)
*
	GOSUBL	=addlin

	D0=(5)	ldeb
	C=DAT0	A
	B=C	A	B(A) := ldeb
	D0=(5)	nblig
	C=DAT0	A	C(A) := nblignes
	D0=(4)	findeb
	A=DAT0	A	A(A) := long de ce qui a été enlevé
*
* A(A) = longueur de ce qui a été enlevé  (adfin - addeb)
* B(A) = no de l'ancienne première ligne  (ldeb)
* C(A) = nombre de lignes		  (nblig)
*
	GOSUBL	=dellin

	D0=(5)	=COUR
	C=DAT0	A

	GOTO	C900

 C540
*
* courante dans le bloc (ldeb <= courante <= lfin)
*
	D0=(5)	lfin
	C=DAT0	A
	C=C+1	A
*
* Attention ! Le code continue !
*

 C900
*
* C(A) = nouvelle valeur de "courante"
*
	GOSUBL	setcou	pour vérification
 C990	GOLONG	=BOUCLE

	END
