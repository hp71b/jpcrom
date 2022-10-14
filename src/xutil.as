	TITLE	Editeur, utilitaires <xutil.as>

 JPCPRV	EQU	1

*
* Ce module contient les utilitaires propres à l'éditeur
* et ses fonctions.
* Les utilitaires pris dans JPC Rom sont dans jpcutil.as
*

************************************************************
* KEYWT
*
* But: attendre une pression de touche de l'utilisateur. Les
*   touches de curseur horizontal sont autorisées pour le
*   déroulement de l'affichage.
* Entree: -
* Sortie:
*   - A(B) := B(B) := code physique (IDS2, p. 12-13)
*   - Cy = 1
* Abime: A-D, D0, D1, P, 32 nibs at SCRTCH (CKSREQ)
* Appelle: SCRLLR, CKSREQ, POPBUF, ATNCLR
* Niveaux: 6
* Detail: Cette routine n'est pas l'équivalent exact
*   de keywt dans KA car celle de KA détecte kOFF et
*   branche directement à l'extinction de KA.
* Historique:
*   86/08/01: ajout de documentation
*   88/05/23: PD/JT pompage dans KA pour T/XEDIT
************************************************************
 
=KEYWT	GOSBVL =SCRLLR	Voir KEYWAIT$ (JPC No 20), sauf que
	GONC   kwt10	  là, eh bien les touches de
	GOSBVL =CKSREQ	  déroulement del'affichage sont
	GOTO   =KEYWT	  supportées.
 kwt10	GOSBVL =POPBUF
	GOSBVL =ATNCLR	Abime A(A)
	A=B    A	Pour compatibilité avec FINDA
	RTN

************************************************************
* posmsg, poscmd
*
* But: réaliser POS(MSG$(C), A)
* Entree:
*   - A(B) = caractère à chercher
*   - posmsg seulement :
*	 C(A) = numéro de message
* Sortie:
*   - Cy = 0 : non trouvé
*   - Cy = 1 : trouvé
*	C(A) = D(A) = 0.."LEN(MSG$(..)-1)"
* Abime: A-D, D0, D1, R0, R1, R2 si message insert, OUTBS
* Appelle: CONVUC, FPOLL, D0=AVS, TBMSG$
* Note: la routine "poscmd" est reservee à l'editeur de
*   textes. Le numéro du message à chercher est codé en dur.
* Note: La documentation de TBMSG$ est archi-fausse:
*   Il faudrait lire :
*	** Exit:
*       **     D0 = ^ start of string
*	**     C(A) = B(A) = ^ end of string (final FF)
*   Merci HP !
* Niveaux: 3
* Historique:
*   88/10/29: PD/JT conception & codage
************************************************************

=poscmd	GOSBVL	=CONVUC	A(B) := commande en majuscule
	LC(4)	(=id)~(=teVCMD)
=posmsg	R0=C		R0(3-0) := numéro du message
	R1=A		R1(B) := caractère à chercher
*
* Y-a-t-il un traducteur pour ce message ?
*
	GOSBVL	=FPOLL	abime A(A)-D(A), D0, D1
	CON(2)	=pTRANS	abime A-D, D0, D1, P
*
* R0(3-0) = nouveau numéro de message s'il y a eû traduction
* R1(B) = caractère à chercher
*
	GOSBVL	=D0=AVS	D0 := (AVMEMS)
	C=R0		C(A) := numéro de message
	GOSBVL	=TBMSG$
*
* D0 = ^ début de la chaine
* C(A) = ^ fin
* R1(B) = caractère à chercher
* Modifie pour tenir compte des erreurs de la documentation
* de TBMSG$.
*
	A=R1		A(B) := caractère à chercher
	B=C	A	B(A) := ^ fin du message
	D=0	A
	GOTO	posm20
*
* Invariant de boucle :
*   A(B) = caractère à chercher
*   D0 = ^ caractère du message à tester
*   D(A) = indice du caractère à tester (0..LEN-1)
*   B(A) = ^ terminateur de la table
*
 posm10	C=DAT0	B
	?A=C	B
	GOYES	posm50	trouvé !
	D0=D0+	2
	D=D+1	A
 posm20	CD0EX
	D0=C
	?C<B	A	Peut-on continuer ?
	GOYES	posm10	oui.
	RTNC		pas trouvé (Cy = 0)

 posm50	C=D	A	C(A) := index
	RTN		trouvé (Cy = 1)

************************************************************
* PURGE
*
* But: détruire le fichier que l'on vient de créer par les
*   commandes D ou X.
* Entree:
*   - EXTFIL = adresse du header du fichier créé
* Sortie: -
* Abime: A, B, C(15-5), D, R0-R2, D0, D1, SCRTCH(4-0)
* Appelle: MVMEM+
* Niveaux: 5 (MVMEM+ plus un pour sauver C(A))
* Note: le fichier doit faire exactement 37+4 quartets.
* Historique:
*   88/11/11: PD/JT conception & codage
************************************************************

=PURGE	D0=(5)	=EXTFIL	Destruction "interne" ?
	A=DAT0	A
	?A=0	A	Pas de fichier externe
	RTNYES		alors retour
	?ST=0	=sCREAT
	RTNYES		Le fichier existait déjà

	RSTK=C		RSTK := C(A)
*
* Purger le fichier.
*
	LC(5)	-(37+4)	taille du fichier créé
	A=A-C	A	A(A) := end of file
	B=C	A	B(A) := offset (dest - source)
	C=A	A	C(A) := end of file
*
* Le fichier ayant été créé par nos soins, il l'a été
* forcément après notre Lex. En conséquence, notre Lex
* ne peut bouger.
*
	GOSBVL	=MVMEM+
*
* Il ne peut pas y avoir d'erreur (Cy = 1) car
* - le fichier est supprimé (donc suffisamment de mémoire)
* - le fichier est créé (donc pas en Rom)
*
	C=RSTK
	RTN

************************************************************
* setfl1
*
* But: mettre le flag 1 (le vrai flag 1, celui de
*   l'utilisateur) à l'état indiqué par C(0).
* Entree:
*   - C(0) = 0 ou #0
* Sortie:
*   - P = 0
* Abime: A(S), C(S), D0, P
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/12: PD/JT conception & codage
************************************************************

=setfl1	D0=(5)	=FLGREG	D0 := ^ flags utilisateurs
	A=DAT0	S	A(S) := flags 0 à 3
	P=	15
	LC(1)	=FL1MSK	C(S) := FL1MSK
	P=	0

	?C=0	P	Mettre le flag à 0 ?
	GOYES	setf20	oui
	A=A!C	S	non : mettre le flag à 1
	GOTO	setf30
 setf20	C=-C-1	S	C(S) := not FL1MSK
	A=A&C	S

 setf30	DAT0=A	S	flags 0 à 3 := nouveaux flags
	RTN

************************************************************
* extsek, extsk+
*
* But: chercher des lignes dans un fichier externe.
* Entree:
*   - A(A) = adresse du fichier externe
*   - C(A) = numéro de ligne cible
*   - extsk+ seulement :
*	- B(A) = numéro d'une ligne <= C dans le fichier
*	- D0 = adresse de cette ligne
* Sortie:
*   - A(A) = numéro de ligne trouvé (<= C en entree)
*   - D0 = ^ ligne trouvée (longueur LIF)
* Abime: A-D, D0
* Appelle: -
* Niveaux: 1 (utilisé pour sauvegarde dans RSTK)
* Historique:
*   88/11/13: PD/JT extraction de D et généralisation
*   88/11/27: PD/JT modification de l'interface
************************************************************

=extsek	D0=A		D0 := ^ header du fichier externe
	D0=D0+	16	D0 := ^ file type
	D0=D0+	16	D0 := ^ REL(5) FiLeNd
	D0=D0+	5	D0 := ^ début des données
	B=0	A
	B=B+1	A	B(A) := 1 (pointe première ligne)
*
* A(A) = ^ file header
* B(A) = numéro d'une ligne référence
* D0 = ^ début de cette ligne
* C(A) = numéro de la ligne à trouver
*
=extsk+	D=C	A	D(A) := numéro de ligne à chercher
	CD0EX		C(A) := ^ ligne référence
	RSTK=C		RSTK := ^ ligne référence
*
* A(A) = ^ file header
* B(A) = numéro de la ligne référence
* D(A) = numéro de la ligne à chercher
* RSTK = ^ ligne référence
*
	D0=A		D0 := ^ header
	A=B	A	A(A) := numéro de la ligne référence
	D0=D0+	16
	D0=D0+	16	D0 := ^ REL(5) FiLeNd
	CD0EX		C(A) := ^ REL(5) FiLeNd
	D0=C
	B=C	A	B(A) := ^ REL(5)
	C=DAT0	A	C(A) := REL(5)
	B=B+C	A	B(A) := ^ FiLeNd
*
* A(A) = numéro de la ligne référence
* B(A) = ^ FiLeNd
* D(A) = numéro de la ligne à chercher
* RSTK = ^ ligne référence
*
	C=RSTK
	D0=C		D0 := ^ ligne référence

	C=A	A	C(A) := numéro ligne référence

*
* pour i := (ligne référence) jusque (ligne à chercher)
*   faire
*     si D0 >= FiLeNd ou *D0 = #FFFF
*       alors sortir de la boucle "pour"
*     fin si
*     passer à la ligne suivante
* fin pour
* renvoyer i
*

*
* Affectation des registres pendant la boucle :
* - B(A) = ^ FiLeNd
* - C(A) = numéro de la ligne courante (i)
* - D(A) = numéro de la ligne à chercher
* - D0 = ^ ligne courante (longueur LIF)
*
	GOTO	ske200	aller directement au test sur i

 ske100	RSTK=C		RSTK := i
	CD0EX		C(A) := ^ ligne courante
	D0=C		D0 := ^ ligne courante
	?C>=B	A	at EOF ?
	GOYES	ske300	oui : D0 = ^ fin du fichier

	A=DAT0	4
* SWPBYT (#17A24) recopié pour éviter un GOSBVL
	C=A	A
	ASL	A
	ASL	A
	CSR	A
	CSR	A	C(4) := 0 (entre autres)
	A=C	B	A(A) := longueur LIF
* fin du pompage
	P=	3
	C=A	WP	on sait que C(4) = 0
	A=C	A
	A=A+1	WP	Cy = 1 si C(A) = FFFF
	P=	0
	GOC	ske300	D0 = ^ FFFF
* conversion en nombre de quartets à sauter
	ASRB
	A=A+1	A
	A=A+A	A
	A=A+A	A	A(A) := nb de quartets à sauter

	CD0EX
	C=C+A	A
	D0=C		D0 := ^ ligne suivante

*
* D0 = ^ ligne suivante
* RSTK = numéro de la ligne précédente
* B(A) = ^ FiLeNd
* D(A) = numéro de ligne à chercher
*
	C=RSTK
	C=C+1	A	i++

 ske200	?C>=D	A	i >= ligne à chercher ?
	GOYES	ske310	oui : on arrête
	GONC	ske100

*
* Sortie sur EOF
* RSTK  = i
* D0 = ^ EOF
*
 ske300	C=RSTK		C(A) := i
 ske310	A=C	A	A(A) := i
	RTN

************************************************************
* YNQ
*
* But: prendre un code physique de touche, et tester si la
*   touche est une de celles autorisées par le message
*   =teKEYS, ce qui permet de traduire les reponses
*   autorisées à une demande "Yes/No/Quit".
* Entree:
*   - A(B) = code physique de la touche (renvoyé par KEYWT)
* Sortie:
*   - C(0) = 0 : non reconnu
*	     1 : [Y]
*	     2 : [N]
*	     3 : [Q]
* Abime: A-C, R0-R1, S0-S2, D0, D1, OUTBS
* Appelle: KEYNAM, posmsg
* Niveaux: 4 (posmsg)
* Historique:
*   88/11/13: PD/JT conception & codage
************************************************************

=YNQ	GOSBVL	=KEYNAM	Conversion en nom de touche
*
* A(WP) = ASCII for keycode
* P = word thru pointer length of text
*
	?P#	1	# 1 caractère ?
	GOYES	YNQ500	non reconnu
	P=	0
	GOSBVL	=CONVUC	Conversion en majuscules
	LC(4)	(=id)~(=teKEYS)
	GOSUB	=posmsg
	GONC	YNQ500	non trouvé
	A=0	A
	A=A+1	A
	A=A+1	A	A(A) := 2
	?C>A	A
	GOYES	YNQ500	Non reconnu ! Message erroné !
	C=C+1	A	renvoyer numéro dans (1..3)
	RTN
 
 YNQ500	C=0	A	C(0) := 0
	P=	0
	RTN

************************************************************
* CHKTXT
*
* But: vérifier que le fichier pointé par D1 est du type
*   TEXT.
* Entrée:
*   - D1 = ^ file header
* Sortie:
*   - Cy = 0 : pas d'erreur
*	D1 inchangé
*   - Cy = 1 : ce n'est pas un TEXT
*	C(3-0) = eFTYPE
* Abime: A(A), A(S), C
* Appelle: -
* Niveaux: 0
* Historique:
*   88/11/27: PD/JT conception & codage
*   89/06/11: PD/JT reconception & recodage
************************************************************

=CHKTXT	D1=D1+	16	D1 := ^ file type
	A=0	A
	A=DAT1	4	A(A) := file type
	C=0	A
	C=C+1	A	C(A) := fTEXT
	?A=C	A
	GOYES	CKTXT1	Ok
*
* Invalid File Type
*
	LC(4)	=eFTYPE
	RTNSC		Cy = 1

 CKTXT1	D1=D1-	16	remet D1 à l'original
	RTNCC		Cy = 0

************************************************************
* FILE1
*
* But: analyser une description de fichier et mémoriser
*   certaines informations pour FILE2 dans STMTR0/R1
* Entree:
*   - D0 = ^ chaîne tokenisée
* Sortie:
*   - STMTR0 = D(W) à la sortie de FSPECx
*   - STMTR1 = nom du fichier
*   - D0 = réactualisé
* Abime: A-D, R0-R3, D0, D1, STMTD0, STMTR1, FUNCxx
* Appelle: FSPECx
* Niveaux: 6 (FSPECx)
* Note:
*   - en cas d'erreur, sortie par BSERR
* Historique:
*   89/06/17: PD/JT mise en commun
************************************************************

=FILE1
*
* Sauvegarde d'un niveau de RSTK
*
	D1=(5)	=S-R0-0
	C=RSTK
	DAT1=C	A	S-R0-0 := sauvegarde d'un niveau
*
* Evaluation de la spécification
*
	GOSBVL	=FSPECx	6 niveaux pour lui tout seul !
*
* Restauration d'un niveau de RSTK
*
	D1=(5)	=S-R0-0
	C=DAT1	A	C(A) := niveau sauvé au dessus
	RSTK=C
*
* L'évaluation s'est-elle bien passée ?
*
	GOC	bserr	Cy = 1 <=> erreur dans l'analyse
	?A=0	W	A = 0 <=> pas de nom de fichier
	GOYES	fspece
*
* Mémoriser les informations renvoyées par FSPECx
*
	D1=(5)	=STMTR0
	C=D	W	Sauvegarde de D(W) pour CRETF+
	DAT1=C	W
	D1=D1+	16	D1=(5) STMTR1
	DAT1=A	W	Sauvegarde du nom du fichier
	RTN

 fspece	C=0	A
	LC(2)	=eFSPEC
 bserr	GOVLNG	=BSERR

************************************************************
* FILE2
*
* But: à partir des descriptions laissées par FILE1 dans
*   STMTR0/R1, chercher et créer éventuellement le fichier.
* Entree:
*   - STMTR0 = D(W) à la sortie de FSPECx
*   - STMTR1 = nom du fichier
*   - S1 = 1 si le fichier doit être copié en mémoire
*   - S2 = 1 si le fichier doit être créé
* Sortie:
*   - C(A) = adresse du fichier
* Abime: A-D, D0, D1, R0-R3, S0-S9, S12, STMTR0
* Appelle: SALLOC, SVINF+, SVINFO, PSHUPD, COPYu, POPUPD,
*   FINDF, CRETF+
* Niveaux: 7 (S1=1/COPYu), 6 (S2=1/CRETF+) ou 3 (Sx=0/FINDF)
* Historique:
*   89/06/17: PD/JT mise en commun
*   89/06/17: PD/JT utilisation des flags S1 et S2
************************************************************

=FILE2
*
* Analyse du résultat renvoyé par FSPECx
*
	D1=(5)	=STMTR0
	C=DAT1	W
	D=C	W	Restaurer pour CRETF+
	D1=D1+	16	D1=(5) =STMTR1
	A=DAT1	W	Comme en sortie de FSPECx
	C=0	S
	?C=D	S
	GOYES	FL2-20	:MAIN
	C=C+1	S
	?C=D	S
	GOYES	FL2-20	:PORT
	C=0	S
	C=C-1	S
	?C=D	S
	GOYES	FL2-20	no device specified
*
* C'est un spécificateur externe
*
	?ST=1	1	fichier doit être copié en mémoire ?
	GOYES	FL2-10	oui

	C=0	A
	LC(2)	=eFSPEC
	RTNSC		Cy = 1 : erreur

*
* Recopie en mémoire du fichier
*
 FL2-10	R1=A
	LC(2)	50
	GOSBVL	=SALLOC
* Abime : A, B(A), C(A), D1
	A=R1
	ST=0	3	Source
	GOSBVL	=SVINF+
* Abime : A, C, D, R0, D1, S3, S4
	A=0	W
	D=0	A
	ST=1	3
	GOSBVL	=SVINFO
*
* Le fichier est copié derrière le dernier, mais une
* reconfiguration peut intervenir, la mémoire serait alors
* déplacée. Il faut donc utiliser MGOSUB, mais également
* sauvegarder l'adresse de l'appelant
*
    if JPCPRV
	GOSBVL	=COPYu
	GOC	Bserr	Erreur lors de la copie
    else
	C=RSTK		C(A) := adresse de l'appelant
	A=C	A
	GOSBVL	=PSHUPD

	GOSBVL	=MGOSUB
	CON(5)	=COPYu	copie
* Abime : A-D, D0, D1, R0-R2, S0-S9, S12, STMTR0
	GOC	Bserr	Erreur lors de la copie

	GOSBVL	=POPUPD
	C=D	A	C(A) := adresse dépilée
	RSTK=C
    endif

	C=R1		C(A) = ^ début du fichier
	GOTO	FL2-40

 Bserr	GOTO	bserr	Rallonge

*
* C'est un spécificateur interne
*
 FL2-20	D1=(5)	=STMTR0
	C=D	W
	DAT1=C	W
	D1=D1+	16
	DAT1=A	W
	GOSBVL	=FINDF
* Abime : A-D, S6, S8, R1-R3
	CD1EX
	GONC	FL2-40	C(A) := ^ début du fichier
*
* Le fichier n'existe pas
*
	?ST=1	2	Faut-il le créer ?
	GOYES	FL2-30	Oui !
*
* Le fichier n'existe pas et il ne faut pas le créer.
* Renvoyer un erreur
*
	CD1EX		C(A) := numéro d'erreur
	RTNSC		Cy = 1 => il y a eû erreur
*
* Il faut le créer
*
 FL2-30	D1=(5)	=STMTR0
	C=DAT1	W
	D=C	W
	C=0	A
	LC(2)	37+4
	GOSBVL	=CRETF+	Théoriq., le Lex ne doit pas bouger
* Abime : A-D, D0, D1, R0-R1, S0-S7
	GOC	Bserr
	C=R1
	D1=(5)	=STMTR1
	A=DAT1	W
	D1=C
	DAT1=A	W	Nom du fichier
	D1=D1+	16	D1 := ^ file type
	LCHEX	400001	text + copy code
	DAT1=C	6
	D1=D1+	16
	D1=D1+	5
	C=0	A	EOF mark
	C=C-1	A
	DAT1=C	4
	C=R1		C(A) = ^ début du fichier
*
* Le fichier est trouvé. On a son adresse dans C(A)
*
 FL2-40	RTNCC		Cy = 0 : pas d'erreur

************************************************************
* CHKWRT
*
* But: vérifier si le fichier spécifié est modifiable ou non
* Entree:
*   - C(A) = adresse (du header) du fichier à tester
* Sortie:
*   - C(S) = 0 : fichier modifiable
*   - C(S) = 1 : fichier en Rom (eFACCS)
*   - C(S) = 2 : fichier SECURE (eFPROT)
*   - C(S) = 3 : fichier ouvert (eFOPEN)
*   - C(A) = adresse du fichier
* Abime: A, B(A), C, D1
* Appelle: ISRAM?, GETPR1, CHKOPN
* Niveaux: 2
* Historique:
*   89/06/17: PD/JT conception & codage
************************************************************

=CHKWRT
*
* Vérifier si le fichier est en Rom
*
	GOSBVL	=ISRAM?	Abime A, B(A), C, D1
	C=B	A	C(A) := ^ header sauvé par ISRAM?
	GONC	CKWrom
*
* Vérifier si le fichier est protégé (SECURE)
*
	D1=C		D1 := ^ file header
	GOSBVL	=GETPR1
	C=B	A	C(A) := B(A) non modifié par GETPR1
* SB = 1 si le fichier est SECURE
	?SB=0		Fichier non sécurisé
	GOYES	CKW010
	GONC	CKWsec	B.E.T.
 CKW010
*
* Vérifier si le fichier est déjà ouvert
*
	GOSUB	CHKOPN
	GONC	CKWok	Ok, il n'est pas déjà ouvert

 CKWopn	P=P+1
 CKWsec	P=P+1
 CKWrom	P=P+1
 CKWok	C=P	15
	P=	0
	RTN

************************************************************
* WRITE?
*
* But: renvoyer un numéro d'erreur connaissant le code
*   délivré par CHKWRT
* Entree:
*   - C(S) = 0 : fichier modifiable
*   - C(S) = 1 : fichier en Rom (eFACCS)
*   - C(S) = 2 : fichier SECURE (eFPROT)
*   - C(S) = 3 : fichier ouvert (eFOPEN)
* Sortie:
*   - Cy = 1 : pas d'erreur
*   - Cy = 0 : erreur
*	C(A) = numéro d'erreur
* Abime: C(S), C(A)
* Appelle: -
* Niveaux: 0
* Historique:
*   89/06/17: PD/JT conception & codage
************************************************************

=WRITE?	C=C-1	S
	RTNC		pas d'erreur

	C=0	A
	C=C-1	S
	GOC	WRTrom
	C=C-1	S
	GOC	WRTsec
 WRTopn	LC(2)	=eFOPEN
	RTNCC
 WRTsec	LC(2)	=eFPROT
	RTNCC
 WRTrom	LC(2)	=eFACCS
	RTNCC

************************************************************
* CHKOPN
*
* But: vérifier si le fichier spécifié est déjà ouvert
*   ou non.
* Entree:
*   - C(A) = adresse du fichier à tester
* Sortie:
*   -C(A) = adresse du fichier
*   - Cy = 0 : le fichier n'est pas déjà ouvert
*   - Cy = 1 : le fichier est déjà ouvert
* Abime: A, B(A), C, D1
* Appelle: I/OFND
* Niveaux: 1
* Historique:
*   89/06/17: PD/JT mise en commun
************************************************************

 CHKOPN	B=C	A	Sauver l'adresse dans B(A)
*
* Chercherle buffer contenant le FIB
*
	LC(3)	=bFIB
	GOSBVL	=I/OFND	Abime A, C(A), C(S), D1
*
* Le FIB existe forcément
* D1 = ^ past buffer header
*

*
* Préparation de la valeur à tester.
* Les quartets 6-5 contiennent F0
* Les quartets 4-0 contiennent l'adress du début des données
*
	LCHEX	F000025	C(6-5) := F0 (fichier en Ram)
	C=C+B	A	C(4-0) := adresse des données
*
* Code extrait de OPENF- (#11B54 dans Rom du HP-71).
* Merci HP !
*
	P=	6
 CHKO10	A=DAT1	B
	?A=0	B
	GOYES	CHKO90	On n'a pas trouvé ! C'est donc ok
	D1=D1+	(=oFBEGb)-(=oFIL#b)
	D1=D1+	(=oDBEGb)-(=oFBEGb)
	A=DAT1	7
	?A=C	WP
	GOYES	CHKO80	On a trouvé ! Beeep ! "File Open"
	D1=D1+	(=oRECLb)-(=oDBEGb)
	D1=D1+	(=oRLENb)-(=oRECLb)
	D1=D1+	(=lFIB)-(=oRLENb)
	GONC	CHKO10	B.E.T.

 CHKO80	P=	0
*
* B(A) = adresse du fichier
*
	C=B	A	On remet les choses en place
	RTNSC		Cy = 1

 CHKO90	P=	0
*
* B(A) = adresse du fichier
*
	C=B	A	On remet les choses en place
	RTNCC

	END
