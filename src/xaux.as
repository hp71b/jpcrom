	TITLE	Editeur, fonctions auxiliaires <xaux.as>

*
* Pour que les fonctions comprennent les chaînes génériques
* du HP-71 ou les chaînes génériques HP-UX :
*
 mode-hp-71	equ	0	HP-UX
*mode-hp-71	equ	1	HP-71

	if mode-hp-71
 COMPxx	EQU	=COMP71
	else
 COMPxx	EQU	=COMPUX
	endif


*
* Flags utilisés
*
 genpos	EQU	0	flag pour différencier GENPOS/GENLEN
 decrem	EQU	1	flag pour différencier popn/arg0
 sBASIC	EQU	10	1 si fichier BASIC, 0 si TEXT

*
* Variables temporaires
*
 tmp	EQU	=FCNTMP	début des 58 quartets de temporaires

 SAUVD0	EQU	00+tmp	5 q : sauver D0
 SAUVD1	EQU	05+tmp	5 q : sauver D1

*
* Utilisé par GENPOS/LEN et GENRPLC$ pour mémoriser le
* paramètre de position optionnel
*
 posit	EQU	10+tmp	5 q: paramètre optionnel

*
* Utilisé par GENRPLC$ pour sauver un niveau de pile de
* retour.
*
 stack1	EQU	15+tmp

*
* Utilisé par FILEPOS, FILEPLC pour mémoriser les
* paramètres.
*
 ldeb	EQU	10+tmp	5 q: ligne de début
 lfin	EQU	15+tmp	5 q: ligne de fin
 ncol	EQU	20+tmp	5 q: numero de la première colonne
 filadr	EQU	25+tmp	5 q: adresse du fichier trouve
 filend	EQU	30+tmp	5 q: adresse de FiLeNd
 curlin	EQU	35+tmp	5 q: adresse de la ligne courante

************************************************************
* GENPOSe, GENLENe
*
* But: étendre POS aux chaînes génériques, en donnant
*   l'emplacement (GENPOS) et la longueur (GENLEN) de
*   l'occurrence trouvée.
* Syntaxes:
*   - GENPOS (<string>, <pattern> [, <position> ] )
*   - GENLEN (<string>, <pattern> [, <position> ] )
* Detail:
*   - GENPOS peut retourner deux résultats :
*	0 : rien trouvé
*	>0: position de départ
*   - GENLEN peut retourner aussi deux résultats :
*	0 : rien trouvé
*	>=0 : longueur trouvée
*	Mais attention : la
*	valeur retournée ne permet pas de différencier.
*	En effet, il faudrait retourner -1 en cas de "rien
*	trouvé". Mais ce n'est pas l'option qui a été prise,
*	de manière à être homogène avec GENPOS et POS.
* Historique:
*   88/06/05: PD/JT conception & codage
*   88/07/02: PD/JT renommage de GENPOS et ajout de GENLEN
*   88/10/09: PD/JT adaptation au nouveau POSADR
*   88/10/15: PD/JT correction du bug SETHEX après HDFLT
************************************************************

	NIBHEX	84423
=GENLENe
	ST=0	genpos
	GOTO	XPOS00

	NIBHEX	84423
=GENPOSe
	ST=1	genpos

 XPOS00	GOSUB	SAVED0	Sauvegarde de D0

	A=C	S	A(S) := nombre de paramètres
	LC(1)	2
	CSRC		C(S) := 2
	A=0	A	position par défaut
	?A=C	S
	GOYES	XPOS10	2 arguments
	GOSUB	arg0	A(A) := position (0..max)
 XPOS10	A=A+A	A	en quartets
	D0=(5)	posit
	DAT0=A	A	posit := position initiale (0..n)

	GOSBVL	=POP1S
	CD1EX
	C=C+A	A
* Sauvegarde du sommet de M.S.
	D1=C
	GOSUB	SAVED1	sauvegarde D1 dans SAUVD1
	D1=D1-	2	D1 := ^ premier caractère
* Calcul de la longueur en octets
	C=0	M
	C=A	A
	CSRB
	A=C	A	A(A) := longueur en octets
* Compilation du motif
	GOSUBL	COMPxx

	GONC	XPOS30	Compilation correcte
	GOVLNG	=BSERR

 XPOS30
* Inversion de la chaîne à explorer
	GOSUB	RESTD1	D1 := valeur sauvegardée plus haut
	GOSBVL	=REVPOP
	B=A	A	B(A) := LEN(chaîne) en quartets
* Sauvegarde du haut et du bas de pile
	CD1EX		C(A) := ^ début chaîne
	R1=C		pour POSADR
	D0=(5)	posit
	A=DAT0	A	position de départ (en octets)
	A=A+C	A	A(A) := ^ chaîne à chercher
	D0=A		D0 := ^ chaîne pour POSADD

	D1=(5)	=AVMEME
	DAT1=C	A
	C=C+B	A	C(A) := ^ bas de la M.S.
	D1=C
	GOSUB	SAVED1	SAUVD1 := bas de la M.S.
* Calcul de la longueur en octets
	D1=(5)	posit
	C=DAT1	A	C(A) := nb de quartets à sauter
	B=B-C	A	B(A) := longueur de ce qu'il reste
	GONC	XPOS40	ok, il en reste
	B=0	A
 XPOS40	A=0	M
	A=B	A
	ASRB		A(A) := longueur en octets (reste)
*
* R0(7-0) = caractéristiques du buffer
* R1(A) = ^ début de la chaîne
* D0 = ^ début de la partie à chercher
* A(A) = longueur en octets
*
	GOSUBL	=POSADR
	A=0	A	A(A) := 0 si not found
	GONC	XPOS90	Pas trouvé. On renvoie 0.
*
* On a trouvé. Est-ce GENPOS ou GENLEN ?
*
	?ST=0	genpos
	GOYES	XPOS60	C(A) = valeur trouvée
* C'est GENPOS. Il faut calculer la position dans la chaîne
	D0=D0+	2
	AD0EX		A(A) := ^ occurrence trouvée
	D1=(5)	=AVMEME
	C=0	M	pour la division par 2
	C=DAT1	A	C(A) := ^ premier caractère
	C=A-C	A
	CSRB		C(A) := position du premier car.

 XPOS60	A=C	A	A(A) := résultat de POSADR

*
* A(A) = résultat (0 si pas trouvé, ou si longueur = 0)
* SAUVD0 = sauvegarde de D0
* SAUVD1 = bas de la M.S.
*
 XPOS90	GOSBVL	=HDFLT	A(W) := 12 digits
*
* Correction du 88/10/15 : le buffer n'était jamais
* trouvé, d'où jamais désalloué. La mémoire disponible
* diminuait donc après chaque GENPOS/GENLEN.
*
	SETHEX		Correction du 88/10/15.
* A(W) = résultat en flottant 12 digits
	R1=A
	GOSUBL	=ENDPOS	achève le buffer (arggggh !)

	GOSUB	RESTD0	D0 := PC
	GOSUB	RESTD1

	C=R1		C(W) := résultats
	GOVLNG	=FNRTN1

************************************************************
* GENRPLCe
*
* But: remplacer une chaîne par une autre dans une chaîne.
* Syntaxe:
*   - GENRPLC$(<chaîne>,<source>,<remplacement> [,<pos>])
* Historique:
*   88/10/08: PD/JT conception & codage
*   89/10/21: PD/JT déplacement de RPL900
************************************************************

	NIBHEX	844434
=GENRPLCe
* Sauver D0 et un niveau de pile de retours
	GOSUB	SAVED0	Sauvegarde de D0

	C=RSTK
	D0=(5)	stack1	sauver un niveau de pile de retours
	DAT0=C	A

* Mettre les modes à "HP-UX" et à "non interactif"
	D0=(5)	=QUERY
	A=0	S
	DAT0=A	S	QUERY := 0 (pas interactif)
	if mode-hp-71
	A=A+1	S
	endif
	D0=(5)	=MODE71
	DAT0=A	S	MODE71 := 0 (autrement dit : HP-UX)
* Paramètre "position"
	A=C	S	A(S) := nombre de paramètres
	LC(1)	3
	CSRC		C(S) := 3
	A=0	A	position par défaut
	?A=C	S
	GOYES	RPL010	3 paramètres
	GOSUB	arg0	position (0..max)
 RPL010	D0=(5)	posit
	DAT0=A	A	posit := position initiale
* dépile C$
	D1=D1+	16	passer le header de C$
	GOSBVL	=AVE=D1	AVMEME := fin de la mémoire
	D1=D1-	16
	GOSUB	pop$	dépile C$
	D1=D1-	2	D1 := ^ premier caractère
	CD1EX		C(A) := ^ début de C$
	D1=C
	D1=D1+	2	pour revenir à l'etat initial
	GOSBVL	=CSLC5	C(9-5) := ^ début de C$
	C=A	A	C(4-0) := LEN(C$)
	R3=C		pour plus tard
* dépiler et compiler B$
	GOSUB	pop$
	GOSUB	SAVED1	SAUVD1 := D1 (header de A$)
	D1=D1-	2	D1 := ^ premier caractère

	GOSUBL	COMPxx

	GONC	RPL020	pas d'erreur
	GOVLNG	=BSERR
 RPL020
* dépiler A$ et le mettre en OUTBS
	GOSBVL	=OBCOLL
	GOSUB	RESTD1	D1 := ^ header de A$
	GOSUB	pop$	A(A) := LEN(A$)
	B=A	A	B(A) := LEN(A$) pour POSADR
	GOSUB	SAVED1	SAUVD1 := M.S. dépilée complètement

	D0=(5)	=OUTBS
	C=DAT0	A
	D0=C
	D0=D0+	4	D0 := ^ destination
	GONC	RPL040	B.E.T.

 RPL030	D1=D1-	2
	C=DAT1	B
	DAT0=C	B
	D0=D0+	2
 RPL040	A=A-1	A
	GONC	RPL030

	CD0EX
	D0=(5)	=AVMEMS
	DAT0=C	A	AVMEMS := fin de la zone rentrée
*
* Tout est prêt pour la première recherche
* - R0(7-2) = caractéristique du buffer (contenant B$)
* - R3(9-5) = ^ premier caractère de C$
* - R3(4-0) = longueur de C$ (en octets)
* - SAUVD0 = sauvegarde de D0
* - SAUVD1 = ^ zone où sera rangé le résultat final
* - (OUTBS..AVMEMS) = A$
*
	D0=(5)	posit
	C=DAT0	A	C(A) := position (en octets)
	C=C+C	A	C(A) := position en quartets
	D1=(5)	=OUTBS
	A=DAT1	A
	A=A+1	A
	A=A+1	A
	A=A+1	A
	A=A+1	A	A(A) := OUTBS + 4
	R1=A		R1 := ^ vrai début de la zone
	A=A+C	A	A(A) := début de la zone à chercher
	D0=A		D0 := ^ début zone à chercher
	A=B	A	A(A) := LEN(A$)
	GOSUBL	=POSADR
	GONC	RPL900	pas trouvé, on remet A$
*
* Trouvé : D0 = ^ occurrence dans la chaîne objet
* C(A) := longueur de l'occurrence trouvée (en octets)
*
	RSTK=C		C(A) := longueur en caractères
	GOSUBL	=CALCab	n'abime pas D0
	C=RSTK		C(A) := longueur en caractères
	GOSUBL	=REPLIN
*
* Correction du 89/10/21 : bug reporté par Jean Reibel.
* GENRPLC$ ne désallouait pas le buffer si la chaîne
* n'était pas trouvée : RPL900 était situé après ENDPOS !
*
 RPL900
	GOSUBL	=ENDPOS	abime A-C, D0, D1
*
* On ignore le code de retour puisque nous n'étions pas en
* mode interactif
*
* On remet (OUTBS..AVMEMS) sur la M.S.
*
* Calcul de la place nécessaire
*
	C=0	M
	D0=(5)	=AVMEMS
	C=DAT0	A	C(A) := AVMEMS
	D0=D0-	5	D0=(5) =OUTBS
	A=DAT0	A	A(A) := OUTBS
	C=C-A	A	C(A) := AVMEMS - OUTBS
	CSRB
	C=C-1	A
	C=C-1	A	C(A) := LEN(GENRPLC$(...))
	RSTK=C
	D0=(5)	SAUVD1
	A=DAT0	A	A(A) := nouveau AVMEME
	R1=A		pour ADHEAD (start of stack item)
	D0=(5)	=AVMEME
	DAT0=A	A	AVMEME := nouveau AVMEME
	C=C+C	A	absolute memory to check
	GOSBVL	=MEMCKL	abime A, B, C, D1
	GONC	RPL910
	GOVLNG	=BSERR	Insufficient Memory
 RPL910	C=RSTK		C(A) := taille en quartets
	D0=(5)	=OUTBS
	A=DAT0	A
	D0=A		D0 := ^ premier caractère
	D0=D0+	4	Cy := 0
	A=R1		A(A) := start of stack item
	D1=A
	GONC	RPL930	B.E.T.
 RPL920	D1=D1-	2
	A=DAT0	B
	DAT1=A	B
	D0=D0+	2
 RPL930	C=C-1	A
	GONC	RPL920

* Remettre AVMEMS à la bonne valeur
* Mélange de D=AVMS et OBCOLL
	D0=(5)	=OUTBS
	C=DAT0	A	C(A) := nouveau AVMEMS
	D=C	A	pour ADHEAD
	D0=D0+	5	D0=(5) AVMEMS
	DAT0=C	A	AVMEMS := OUTBS

* Restaurer le niveau de pile de retours et D0
	D0=(5)	stack1
	C=DAT0	A
	RSTK=C

	GOSUB	RESTD0
*
* D(A) = AVMEMS
* R1 = ^ start of stack item
* D1 = ^ end of stack item
*
	ST=0	0	pas de return
	GOVLNG	=ADHEAD

************************************************************
* pop$
*
* But: depiler un argument alphanumerique et renvoyer ses
*   caracteristiques.
* Entree:
*   - D1 = ^ sommet de pile
* Sortie:
*   - A(A) = longueur en caractères
*   - C(A) = longueur en quartets
*   - D1 reactualise (^ premier caractère de la chaîne)
* Abime: A(W), D1
* Appelle: POP1S
* Niveaux: 1
* Historique:
*   88/10/08: PD/JT conception & codage
************************************************************

 pop$	GOSBVL	=POP1S
	CD1EX
	C=C+A	A
	D1=C		D1 := ^ premier caractère
	C=A	A	C(A) := taille en nibs
	A=0	W
	A=C	A
	ASRB		A(A) := taille en caractères
	RTN

************************************************************
* popn, arg0
*
* But: dépiler un argument numérique (popn, arg0) et le
*   décrémenter (arg0). Si le résultat est négatif, le
*   ramener à 0 (popn, arg0).
* Entree:
*   - D1 = ^ sommet de pile
* Sortie:
*   - A(A) = argument dépilé
*   - D1 réactualisé
* Abime: A, B(S), B(A), C(A), D(A), S0
* Appelle: RNDAHX
* Niveaux: 4
* Historique:
*   88/10/08: PD/JT isolé du code de GENPOS
*   88/11/27: PD/JT ajout de popn et du flag 0
************************************************************

 popn	ST=0	decrem
	GOTO	arg05
 arg0	ST=1	decrem
 arg05	GOSBVL	=RNDAHX
	GOC	arg10	positif
	D1=D1+	16
	A=0	A
	RTN
 arg10	D1=D1+	16
	?ST=0	decrem	Décrémenter ?
	RTNYES		non
	?A=0	A
	RTNYES
	A=A-1	A
	RTN

************************************************************
* FILEPOSe
*
* But: chercher une chaîne générique dans le fichier.
* Syntaxe:
*   - FILEPOS (<fichier>,<motif> [,<début>[,<fin>[,<col>]]])
* Note:
*   - les numéros de ligne commencent à 0 (comme dans EDLEX)
*   - le numéro de fin n'est pas borné à 9999 comme dans
*	cette stupdité de SEARCH...
* Historique:
*   88/10/15: PD/JT conception de la syntaxe
*   88/11/27: PD/JT début du codage
*   88/11/27: PD/JT suspension du codage
*   89/06/11: PD/JT reprise du codage
*   89/06/16: PD/JT fin du codage
*   89/06/17: PD/JT <col> commence maintenant à 1 et pas à 0
************************************************************

	CON(1)	8	Numérique		(colonne)
	CON(1)	8	Numérique		(fin)
	CON(1)	8	Numérique		(début)
	CON(1)	4	Chaîne			(motif)
	CON(1)	8+4	Numérique ou Chaîne	(fichier)
	NIBHEX	25
=FILEPOSe
	GOSUB	SAVED0	Sauvegarde de D0

*
* Mise en place des valeurs par défaut des paramètres
*
	C=0	A
	D0=(5)	ldeb
	DAT0=C	A	ldeb := 0
	D0=D0+	(lfin)-(ldeb)
	C=C-1	A
	DAT0=C	A	lfin := FFFFF
	D0=D0+	(ncol)-(lfin)
	C=C+1	A
	DAT0=C	A	ncol := 0

*
* Aiguillage selon le nombre de paramètres
*
	A=C	S	A(S) := nb de paramètres
	ASLC		A(0) := nb de paramètres
	LC(1)	5
	?A>C	P	nb de paramètres > 5 ?
	GOYES	FLP100	Erreur

	C=A	P	C(0) := nb de paramètres
	GOSBVL	=TBLJMC
	REL(3)	FLP100	0 : Erreur
	REL(3)	FLP100	1 : Erreur
	REL(3)	FLP120	2 : ok
	REL(3)	FLP130	3 : ok
	REL(3)	FLP140	4 : ok
	REL(3)	FLP150	5 : ok

*
* 0 ou 1 ou 6 ou ... ou 15 paramètres. Le cas est
* invraisemblable, mais un bidouilleur a pu modifier le
* code tokenisé dans son Basic. Il convient donc de se
* protéger.
*
 FLP100	GOVLNG	=ARGERR	"Invalid Arg"

*
* On profite du fait que D0=(5) ncol quand on arrive ici.
*
 FLP150	GOSUB	arg0
*	D0=(2)	ncol	Retiré le 16 juin 1989
	DAT0=A	A
 FLP140	GOSUB	popn
	D0=(2)	lfin
	DAT0=A	A
 FLP130	GOSUB	popn
	D0=(2)	ldeb
	DAT0=A	A

 FLP120
*
* On va passer la chaîne à chercher, et procéder tout de
* suite à la recherche du fichier. D1 va être sauvegardé en
* AVMEME ce qui sera utile pendant la compilation.
*
	GOSBVL	=AVE=D1	AVMEME := D1 (D1 inchangé)

	GOSUB	pop$	dépiler motif (il reste ds la pile)
*
* D1 = ^ M.S. header du fichier. Le fichier est repéré par
* un numéro de canal ou un nom de fichier ?
*
	A=DAT1	P	lit le quartet au sommet de la M.S.
	LC(1)	9
	?A>C	P	autre chose qu'un bête réel ?
	GOYES	FLP300

****************************************
* Accès par numéro de canal
****************************************

	GOSBVL	=RNDAHX	A(A) := numéro de canal
	GOC	FLP220	positif => pas d'erreur
 FLP210	GOSBVL	=ARGERR	"Invalid Arg"

 FLP220	?A=0	A
	GOYES	FLP210	"Invalid Arg"
	C=0	A
	C=A	B
	?A#C	A
	GOYES	FLP210	> 255 => "Invalid Arg"
*
* A(B) = numéro de canal (1..255)
*
	D1=D1+	16
*
* Tout est dépilé. Sauvegarder la valeur actuelle du
* pointeur de M.S. dans SAUVD1.
*
	GOSUB	SAVED1
*
* A(B) = numéro de canal
*

*
* Nous allons utiliser FIBADR. Or, FIBADR stocke une valeur
* dans STMTD1. Cela nous embête car nous sommes dans une
* fonction. Donc, nous allons sauvegarder STMTD1 en lieu
* sûr, puis nous allons le restaurer à la fin. Merci HP...
*
	D1=(2)	=STMTD1
	C=DAT1	A
	D1=(2)	=FUNCR0
	DAT1=C	A

	GOSBVL	=FIBADR
*
* D1 = A(A) = ^ FIB entry
*
	D0=(5)	=FUNCR0	Ouh ! Que ce n'est pas beau !
	C=DAT0	A
	D0=(2)	=STMTD1
	DAT0=C	A
*
* D1 = A(A) = ^ entrée FIB
*
	D1=D1+	=oDEVCb
	C=DAT1	S	C(S) := device type
	C=C+C	S	Cy = 1 si C(S) >= 8
	GONC	FLP230	pas d'erreur

	LC(4)	=eFACCS	"Illegal Access"
	GOVLNG	=BSERR

 FLP230	D1=D1+	(=oFBEGb)-(=oDEVCb)
	A=DAT1	A	A(A) := read file address
*
* A(A) = ^ file header
*
	GOTO	FLP400	continuer les tests

****************************************
* Accès par nom de fichier
****************************************

 FLP300	GOSBVL	=FILXQ$
	GOC	FLP310	Pas d'erreur
	LC(4)	=eFSPEC	"Invalid File Specifier"
 FLP305	GOTO	bserr
 FLP310
*
* Tout est dépilé. Sauvegarder la valeur actuelle du
* pointeur de M.S. dans SAUVD1.
*
	GOSUB	SAVED1

	GOSBVL	=FINDF+
	GOC	FLP305	C(A) = numéro d'erreur
* D1 = ^ file header
	AD1EX		A(A) := ^ file header
*
* Pas d'erreur. Le fichier a été trouvé, il est en Ram (ou
* Rom) et A(A) = ^ file header.
*

****************************************
* Fichier reconnu
****************************************

*
* A(A) = ^ file header
*
 FLP400
*
* Stocker l'adresse du file header en lieu sûr
*
	D1=(5)	filadr
	DAT1=A	A	filadr := adresse du fichier
	B=A	A	B(A) := ^ file header
	D1=A		D1 := ^ file header
*
* Vérifier le type du fichier.
*
	GOSUBL	=CHKTXT	vérifie TEXT
	GOC	bserr	ce n'est pas un TEXT
*
* Calculer l'adresse de la fin du fichier et la mémoriser
*
	GOSUB	=GETEND	A(A) := ^ FiLeNd
	D1=(5)	filend
	DAT1=A	A
*
* Maintenant que l'on connaît le type du fichier, on peut
* vérifier les paramètres.
*
	GOSUB	CHKLIG	voila, c'est fait...
*
* Initialise la recherche en cherchant l'adresse de la
* première ligne.
*
	GOSUB	INISRC
*
* Toutes les vérifications ont été faites. Reste à compiler
* la chaîne, et toute la préparation sera finie.
*
	D1=(5)	=AVMEME
	C=DAT1	A
	D1=C		D1 := ^ string header de <motif>

	GOSUB	pop$
	D1=D1-	2
*
* D1 = ^ chaîne à compiler (premier caractère)
* A(A) = longueur en caractères
*
	GOSUBL	COMPxx

	GONC	FLP450	Compilation correcte
 bserr	GOVLNG	=BSERR

 FLP450
*
* La chaîne est compilée et sa description est dans R0.
* Les numéros de lignes sont dans ldeb et lfin.
* La colonne de début de recherche est dans ncol.
* L'adresse de la première ligne (ldeb) est dans curlin.
* L'adresse du header du fichier est dans filadr.
* L'adresse de la fin du fichier est dans filend.
*
	P=	1	sauver 2 niveaux de pile
	GOSBVL	=R<RSTK

	D0=(5)	ncol
	C=DAT0	A
	B=C	A	B(A) := nb de colonne en caractères
	B=B+B	A	B(A) := offset initial en quartets

*
* Recherche du motif dans le fichier
* - ldeb, lfin, filadr, curlin positionnés
* - B(A) = offset dans la première en quartets
*  
	GOSUB	SRCFIL
*
* Cy = 1 : match found
*	A(A) = numéro de la ligne trouvée
* Cy = 0 : match not found
*

* Mémoriser la Cy dans A(S)
	A=0	S
	GONC	FLP600
	A=A+1	S
 FLP600
* Restaurer les niveaux de retour sauvés avant l'appel
	P=	1
	GOSBVL	=RSTK<R	n'abime pas A(A)
* A-t-on trouvé ?
	?A=0	S	? Cy = 0
	GOYES	FLP800	Pas trouvé ! (<==> GONC)
*
* On a trouvé
* A(A) = numéro de la ligne trouvée
*
	GOSBVL	=HDFLT	A(W) := 12 digits form
	SETHEX		C'est plus prudent (pour I/ODAL)
	GOTO	FLP900

 FLP800
*
* Pas trouvé. Renvoyer -1
*
	C=0	W
	LCHEX	91
	CSRC	
	CSRC		C(W) := 9100000000000000 (i.e. -1)
	A=C	W

*
* Sortie.
* Valeur à retourner (12 digits form) dans A(W)
* La caractéristique du buffer(voir COMPUX) est dans R0
*
 FLP900
*
* Désallouer le buffer qui nous a bien servi
*
	R1=A		R1 := résultat
	GOSUBL	=ENDPOS
*
* Restaurer D0 et D1
*
	GOSUB	RESTD0
	GOSUB	RESTD1
*
* Et retour à Basic
*
	C=R1		C(W) := résultat en 12 digits
	GOVLNG	=FNRTN1

	STITLE	Utilitaires

************************************************************
* CHKPRO
*
* But: vérifier que le fichier pointé par D1 n'est pas
*   sécurisé.
* Entrée:
*   - D1 = ^ file header
* Sortie:
*   - D1 inchangé
* Abime: A(A), A(S), C
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/27: PD/JT conception & codage
*   89/06/11: PD/JT reconception & recodage
************************************************************

 CHKPRO	LC(1)	%0001	SECURE
	D1=D1+	16
	D1=D1+	4
	A=DAT1	P
	D1=D1-	4
	D1=D1-	16
	A=A&C	P	A(P) := 0 (ok) ou #0 (erreur)
	?A=0	P
	RTNYES
*
* Illegal Access
*
	LC(4)	=eFACCS
	GOTO	bserr

************************************************************
* SAVED0, SAVED1
*
* But: sauver le pointeur D0 (SAVED0) ou D1 (SAVED1) dans
*   SAUVD0 ou SAUVD1 selon le cas.
* Entree:
*   - Dx = valeur à sauver
* Sortie:
*   - Dx inchangé
*   - SAUVDx = valeur de Dx
* Abime: Dx
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/27: PD/JT conception & codage
************************************************************

 SAVED0	CD0EX
	D0=(5)	SAUVD0
	DAT0=C	A
	CD0EX
	RTN

 SAVED1	CD1EX
	D1=(5)	SAUVD1
	DAT1=C	A
	CD1EX
	RTN

************************************************************
* RESTD0, RESTD1
*
* But: restaurer le pointeur D0 (RESTD0) ou D1 (RESTD1).
* Entree:
*   - SAUVDx = valeur à restaurer
* Sortie:
*   - Dx = valeur de SAUVDx
* Abime: C(A), Dx
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/27: PD/JT conception & codage
************************************************************

 RESTD0	D0=(5)	SAUVD0
	C=DAT0	A
	D0=C
	RTN

 RESTD1	D1=(5)	SAUVD1
	C=DAT1	A
	D1=C
	RTN

************************************************************
* CHKLIG
*
* But: vérifier la cohérence des numéros de lignes.
* Entree:
*   - ldeb = numéro de la ligne de début
*   - lfin = numéro de la ligne de fin
* Sortie: -
* Abime: 
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/27: PD/JT conception & codage
*   89/06/11: PD/JT simplification
************************************************************

 CHKLIG	D0=(5)	ldeb
	A=DAT0	A	A(A) := ldeb
	D0=D0+	(lfin)-(ldeb)
	C=DAT0	A	C(A) := lfin
	?A<=C	A
	RTNYES
*
* Invalid Arg
*
	GOVLNG	=ARGERR

************************************************************
* INISRC
*
* But: initialise la recherche en cherchant l'adresse de la
*   première ligne.
* Entrée:
*   - ldeb = numéro de record de début
*   - lfin = numéro de record de fin
*   - filadr = ^ du header du fichier.
* Sortie:
*   - curlin = adresse de la première ligne
* Abime: A-D, D0, D1
* Appelle: extsek
* Niveaux: 2 (extsek)
* Historique:
*   88/11/27: PD/JT conception & codage
*   89/06/11: PD/JT simpification
*   89/06/16: PD/JT adaptation "no record" / "no ligne"
************************************************************

 INISRC
	D1=(5)	filadr
	A=DAT1	A	A(A) := ^ file header
	D1=(4)	ldeb
	C=DAT1	A	C(A) := numéro de la première ligne
	C=C+1	A	conversion en "no de ligne"
	GOSUBL	=extsek
*
* A(A) = numéro de ligne trouvée
* D0 = adresse de cette ligne
*
	D1=(5)	curlin
	CD0EX		C(A) := ^ ligne
	DAT1=C	A
	RTN

************************************************************
* SRCFIL
*
* But: chercher une chaîne générique dans le fichier
*   texte spécifié par les lignes de début, fin, header
*   et offset dans la première ligne.
* Entrée:
*   - ldeb = numéro de la ligne de début
*   - lfin = numéro de la ligne de fin
*   - filadr = ^ du header du fichier.
*   - curlin = adresse de la ligne de début (longueur LIF)
*   - B(A) = offset dans la première ligne (en quartets)
* Sortie:
*   - Cy = 1 : match found
*	A(A) = numéro de la ligne trouvée
*	C(A) = longueur de l'occurrence trouvée
*	D0 = ^ occurrence trouvée
*	D1 = ^ ligne (long. LIF) contenant l'occurrence
*	curlin = D1
*   - Cy = 0 : match not found
*       C(A) = numéro d'erreur (eNFND)
* Abime: A-D, R0(12-8), R1, D0, D1
* Appelle: LIFlen, POSADR
* Niveaux: 4 (POSADR)
* Note :
*   - Cette fonction est très voisine de SRCADR, mais est
*     adaptée à un fichier dont on ne connaît pas le
*     numéro de la dernière ligne, autrementi, il faut
*     tester la fin du fichier à chaque ligne parcourue.
* Historique:
*   89/06/11: PD/JT conception d'après SRCADR
*   89/06/16: PD/JT test de l'offset
************************************************************

 SRCF80	GOTO	SRCF90	rallonge en cas d'erreur

 SRCFIL
	D1=(5)	curlin
	C=DAT1	A
	D0=C

 SRCF10
*
* Invariant de boucle
*   ldeb = no ligne courante
*   lfin = no ligne fin
*   D0 = adresse ligne courante
*   B(A) = offset = offset dans la ligne courante
*

*
* Première chose à tester : est-on à la fin du fichier ?
*
	D1=(5)	filend
	A=DAT1	A	A(A) := ^ file end
	CD0EX
	D0=C		C(A) := ^ ligne courante
	?C>=A	A
	GOYES	SRCF80	Fin de la recherche
	A=0	A
	A=DAT0	4	A(A) := longueur LIF non formattée
	LC(5)	#FFFF
	?A=C	A
	GOYES	SRCF80	Fin de la recherche
*
* Préparation de la recherche dans la ligne courante
*
	CD0EX		curlin := D0
	D0=(5)	curlin
	DAT0=C	A
	D0=C		pour LIFlen

	GOSUBL	=LIFlen
	A=0	M	A(5-5) := 0
	A=B	A	A(A) := offset en quartets
	ASRB		A(A) := offset en octets
	C=C-A	A	C(A) := longueur de ce qu'il reste
	A=C	A	A(A) := longueur de la chaîne
*
* Si A < 0, l'offset était trop grand. Il faut donc passer
* à la ligne suivante.
*
	GOC	SRCF15	On saute la recherche

	D0=D0+	4	pour POSADR
	CD0EX
	R1=C		R1 := ^ vrai début
	C=C+B	A
	D0=C		D0 := ^ début de partie à chercher
*
*   D0 = ^ chaîne
*   A(A) = longueur de la chaîne
*   R0 = buffer
*   R1(A) = ^ vrai début
*
	GOSUBL	=POSADR
	GOC	SRCF20	trouvé !

*
* Pas trouvé. Il faut passer à la ligne suivante.
*
 SRCF15
	B=0	A	offset := 0

	D0=(5)	curlin
	C=DAT0	A
	D0=C		D0 := ^ ligne courante
	GOSUBL	=LIFlen
	CD0EX
	C=C+A	A
	D0=C		D0 := ^ ligne suivante

	D1=(5)	lfin
	A=DAT1	A	A(A) := lfin
	D1=(2)	ldeb
	C=DAT1	A	C(A) := ldeb
	C=C+1	A
	DAT1=C	A	++ldeb
	?C>A	A	ldeb > lfin ?
	GOYES	SRCF90	oui : on arrête, sans avoir trouvé
	GOTO	SRCF10	non : on peut continuer

*
* Arrivé à l'occurrence
*
 SRCF20	B=C	A	B(A) := longueur de l'occurrence
	D1=(5)	ldeb	A(A) := ^ no de ligne
	A=DAT1	A
	D1=(2)	curlin	D1 := ^ début ligne LIF
	C=DAT1	A
	D1=C
	C=B	A	C(A) := longueur de l'occurrence
	RTNSC		match found

*
* Pas trouvé d'occurrence
*
 SRCF90
	LC(4)	(=id)~(=eNFND)	"Not Found"
	RTNCC

************************************************************
* GETEND
*
* But: calculer l'adresse de la fin du fichier.
* Entrée:
*   - D1 = ^ header du fichier
* Sortie:
*   - D1 inchangé
*   - A(A) = adresse de la fin du fichier
* Abime: A(A), C(A)
* Appelle: -
* Niveaux: 0
* Historique:
*   89/06/11: PD/JT conception & codage
************************************************************

=GETEND
	D1=D1+	16
	D1=D1+	16	D1 := ^ REL(5) FiLeNd
	A=DAT1	A	A(A) := REL(5) FiLeNd
	CD1EX
	D1=C
	A=A+C	A	C(A) := ^ FiLeNd
	D1=D1-	16
	D1=D1-	16
	RTN

	END
