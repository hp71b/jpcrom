	TITLE	Editeur, édition d'une ligne <xdsp.as>

*
* Correction du 88/07/09
* - Les deux commandes "T;E" posaient un probleme car le
*   texte entré écrasait le ";E". D'où un "Invalid Cmd"
*   la plupart du temps. Ceci a été resolu en protégeant la
*   Math Stack après la lecture d'une commande, et en ne
*   collapsant plus à la lecture d'une ligne.
*

 curadr	EQU	=LDCSPC
 insert	EQU	=STSAVE

************************************************************
* prompt
*
* But: afficher un prompt
* Entrée:
*   - COUR = ligne courante
*   - DERN = dernière ligne du fichier
* Sortie:
*   - Math-Stack = chaîne entrée au clavier
* Abime: 
* Appelle:
* Niveaux: 
* Historique:
*   88/05/15: PD/JT conception & codage
*   88/07/09: PD/JT protection de la M.S. après [ENDLINE]
************************************************************

=prompt	GOSUB	cmdoff
*
* Affichage du message
*
 prmt00	GOSUB	cmdst?
	GOC	prmt55	Affichage de la command stack
*
* Message normal
*
	D1=(5)	=COUR
	C=DAT1	A	C(A) := courante
	D1=(2)	=DERN
	A=DAT1	A	A(A) := dernière
	?C>A	A	courante > dernière
	GOYES	prmt10
*
* Insertion :
*   C(14) = 1111 (1 = output in R2, 111 = hex-dec)
*   C(13) = 4	(R2(4..0))
*   R2 = COUR
*
	R2=C		R2 := COUR
	P=	13
	LCHEX	F4
	P=	0
	LC(4)	(=id)~(=tePLIN)	"Line #, Cmd:"
	GONC	prmt50	B.E.T.
 prmt10 LC(4)	(=id)~(=tePEOF)	"Eof, Cmd:"
 prmt50	R0=C		R0 := C
	GOSBVL	=R3=D10	pompé dans les IDS I,
	GOSBVL	=FPOLL	page 17-60, d'après MSG$
	CON(2)	=pTRANS
	GOSBVL	=D0=AVS
	C=R0
	P=	12	On veut pas "title search"
*
* Le GOSBVL ci-dessous marche dans les HP-71B
* versions 1BBBB, 2CCCC et 2CDCC. Comme il est peu
* vraisemblable qu'il y en ait de nouvelles...
*
	GOSBVL	#099AD	=TBMSTX !!!!!!!!
	GOSBVL	=AVS2DS	Display AVMEMS until FF
	GOTO	prmt60
*
* Affichage de la pile de commande
*
 prmt55	GOSUB	dspcmd

*
* Edition
*
 prmt60	GOSUB	chedit
	GOSBVL	=FINDA
	CON(2)	13	[ENDLINE]
	REL(3)	prEND
	CON(2)	14	[ATTN]
	REL(3)	prATTN
	CON(2)	16	[f][CONT]
	REL(3)	prCONT
	CON(2)	18	[^]
	REL(3)	prUP
	CON(2)	19	[v]
	REL(3)	prDOWN
	CON(2)	20	[g][^]
	REL(3)	prTOP
	CON(2)	21	[g][v]
	REL(3)	prBOT
	CON(2)	24	[f][OFF]
	REL(3)	prOFF
	CON(2)	25	[g][CMDS]
	REL(3)	prCMDS
	NIBHEX	00
	GOTO	prmt60	Ah bon ?

************************************************************
* [ATTN]
************************************************************

 prATTN	GOSUB	finlin
	GOTO	=prompt	et enlève la pile de commandes

************************************************************
* [CONT]
************************************************************

 prCONT	GOSUB	status
	GOTO	prmt60

 finlin	P=	4
	GOSBVL	=R<RSTK
	GOSBVL	=FINLIN	4 niveaux, utilise A-D, D0, D1
	P=	4
	GOSBVL	=RSTK<R
	RTN

************************************************************
* [^], [v], [g][^], [g][v]
************************************************************

 prUP	GOSUB	[up]
	GOTO	prmt00
 prDOWN	GOSUB	[down]
	GOTO	prmt00
 prTOP	GOSUB	[top]
	GOTO	prmt00
 prBOT	GOSUB	[bot]
	GOTO	prmt00

************************************************************
* [f][OFF]
************************************************************

 prOFF	GOSUB	finlin
	GOLONG	=EXIT	commande "exit" en cours de route

************************************************************
* [g][CMDS]
************************************************************

 prCMDS	GOSUB	gcmds	comme si touche [g][CMDS]
	GOTO	prmt00

************************************************************
* [ENDLINE]
************************************************************

 prEND
*
* Lire la chaîne sur la M.S.
*
	GOSBVL	=COLLAP	nettoyer la M.S. au préalable
	GOSUB	getstr
*
* Placer LCMD et PCMD
*
	D0=(5)	=PCMD
	CD1EX
	DAT0=C	A	PCMD := ^ premier caractère dans MS
	D0=(2)	=LCMD
	DAT0=A	A	LCMD := longueur de la chaîne
	RTN

************************************************************
* chedit
*
* But: appeler CHEDIT
* Entrée: -
* Sortie:
*   - P = 0
*   - code de retour de CHEDIT dans A(A) et B(A)
*   - si A(A) = 0, la touche était à exécution immédiate
* Abime: tout y compris S-R1-1 et la return stack de sauveg.
* Appelle: R<RSTK, CHEDIT, RSTK<R, ATNCLR
* Niveaux: plein !
* Historique:
*   88/05/14: PD/JT pompage de KA
************************************************************

 chedit	P=	4
	GOSBVL	=R<RSTK
 ched10 GOSBVL	=CHEDIT
	GONC	ched10	Immediate execute key
	P=	4
	GOSBVL	=RSTK<R
	B=A	A
	GOSBVL	=ATNCLR	abime A(A)
	A=B	A
	RTN

************************************************************
* getstr
*
* But: lire une chaîne du display buffer et la poser sur MS
* Entrée:
*   - display buffer = ligne
* Sortie:
*   - D1 = ^ premier caractère
*   - D(A) = A(A) = longueur en caractères
*   - AVMEME = protège la M.S.
* Abime: A-D, ST, D0, D1, R1, P
* Appelle: D1MSTK, DSP$00, POP1S, FINLIN, MAKEBF
* Niveaux: 5 (FINLIN)
* Historique:
*   88/05/15: PD/JT conception & codage
*   88/07/09: PD/JT remplace COLLAP par D1MSTK (eviter T;E)
************************************************************

 getstr	GOSBVL	=MAKEBF
	GOSBVL	=FINLIN
	GOSBVL	=D1MSTK	positionner D1 sur M.S.
	ST=1	0	on veut revenir de DSP$00
	GOSBVL	=DSP$00
	GOSBVL	=POP1S
	CD1EX
	D1=(5)	=AVMEME	comprend le CR pose par DSP$00
	DAT1=C	A	sauvegarde la M.S.
	C=C+A	A	C(A) := ^ début de la chaîne
	D1=C		D1 := ^ début de la chaîne
	D1=D1-	2	D1 := ^ premier caractère
	C=0	M
	C=A	A
	CSRB
	C=C-1	A	non compris le CR final
	A=C	A
	D=C	A	D(A) = A(A) = C(A) := nb de car.
	RTN

************************************************************
* cmdtog
*
* But: inverser le mode "pile de commande"
* Entrée: -
* Sortie: -
* Abime: A(A), B(A), D(A), C(S), C(5-0), D0
* Appelle: SFLAGT
* Niveaux: 3
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

 cmdtog	D0=(5)	=CMDPTR
	C=0	S
	DAT0=C	S
	LC(2)	=flCMDS
	GOVLNG	=SFLAGT	toggle CMDS flag

************************************************************
* cmdoff
*
* But: enlever le mode "pile de commande"
* Entrée: -
* Sortie: -
* Abime: A(A), B(A), D(A), C(S), C(5-0)
* Appelle: SFLAGC
* Niveaux: 2
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

 cmdoff	LC(2)	=flCMDS
	GOVLNG	=SFLAGC

************************************************************
* cmdst?
*
* But: tester le mode "pile de commande"
* Entrée: -
* Sortie:
*   - Cy = état du flag
* Abime: A(A), D(A), C(S), C(5-0)
* Appelle: SFLAG?
* Niveaux: 1
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

 cmdst?	LC(2)	=flCMDS
	GOVLNG	=SFLAG?

************************************************************
* dspcmd
*
* But: afficher une ligne de la pile de commande
* Entrée:
*   - flag flCMDS à 1 si la pile de commande est active
*   - CMDPTR = niveau courant dans la pile
*   - MAXCMD = niveau maximum
* Sortie:
*   - la chaîne est affichée si besoin est
* Abime: A-D, D0, D1, R0-R2, STMTR0
* Appelle: cmdst?, DSPCHC, ESCSEQ, CMDS20
* Niveaux: 5 (ESCSEQ)
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

 dspcmd
*
* Oui : effacer l'affichage
*
	GOSBVL	=CURSFL
	LCASC	'K'
	GOSBVL	=ESCSEQ
*
* afficher la CMDPTR-ième entrée
*
	GOVLNG	=CMDS20

************************************************************
* [up], [down], [top], [bot]
*
* But: gérer les touches de curseur vertical
* Entrée:
*   - le flag flCMDS indique si on est en mode commandes
*     CMDPTR = niveau courant
*     MAXCMD = niveau maximum
*   - sinon
*     COUR = ligne courante
*     DERN = dernière ligne
* Sortie:
*   - mise à jour de la variable adéquate faite
*   - Cy = 1 si mode "cmd stk" actif
* Abime: 
* Appelle: 
* Niveaux: 
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

 [up]	GOSUB	curini
	C=C-1	A	C(A)--
	?C#0	A
	GOYES	up00
	C=C+1	A	on annulle la modification
 up00	GOTO	curend
 [down]	GOSUB	curini
	?C>=A	A
	GOYES   curend	sans modification
	C=C+1	A	C(A)++
	GOTO	curend
 [top]	GOSUB	curini
	C=0	A
	C=C+1	A	C(A) := 1
	GOTO	curend
 [bot]	GOSUB	curini
	?A=0	A	cas particulier : fichier vide
	RTNYES		... on sort
	C=A	A	C(A) := max

 curend	?B#0	S
	GOYES	cendst	terminé pour cmd stk
	DAT0=C	A
	RTN		Cy = 0 si pas cmdstk
 cendst	C=C-B	A
	C=-C	A	C(A) remis entre 0 et MAXCMD
	DAT0=C	P
	RTNSC		Cy = 1 si cmdstk

 curini	GOSUB	cmdst?
	GOC	cinist	initialisé pour cmd stk
	GOSUB	finlin
	B=0	S
	D0=(5)	=DERN
	A=DAT0	A	A(A) := max
	A=A+1	A	A(A) := max pour [Eof]
	D0=(2)	=COUR
	C=DAT0	A	C(A) := courante
	RTN
 cinist	B=0	S
	B=B+1	S	B(S) = flag == cmdstk
	D0=(5)	=MAXCMD
	A=0	A
	A=DAT0	P
	A=A+1	A	A(A) := MAXCMD + 1
	B=A	A	B(A) := MAXCMD + 1
	D0=(4)	=CMDPTR
	C=0	A
	C=DAT0	P
	C=C-B	A
	C=-C	A	C(A) := 1 si sommet, MAXCMD+1 en bas
	RTN

************************************************************
* dsplin
*
* But: afficher la ligne pointée par D0.
* Entrée:
*   - D0 = ^ longueur LIF de la ligne à envoyer
* Sortie:
* Abime: A-D, R0-R2, D0, D1, STMTR0
* Appelle: LIFlen, DSPCNA (tombe dedans)
* Niveaux: 4
* Historique:
*   88/05/23: PD/JT conception & codage
************************************************************

=dsplin	GOSUBL	=LIFlen
	A=C	A	A(A) := longueur en octets
	CD0EX
	D1=C
	D1=D1+	4	D1 := ^ début des données
	GOVLNG	=DSPCNA

************************************************************
* edtlin
*
* But: éditer une ligne
* Entrée:
*   - COUR = ligne courante
*   - DERN = dernière ligne du fichier
*   - D0 = adresse de la ligne courante
*   - C(S) = 1 si mode 'I', 0 si mode 'T'
* Sortie:
*   - C(0) = code de retour :
*        0 : [f][OFF] ou [ATTN]
*        1 : [ENDLINE]
*	     - D1 = ^ premier caractère
*	     - D(A) = A(A) = longueur en caractères
*	     - AVMEME = protege la M.S.
*        2 : touche de curseur
* Abime: 
* Appelle:
* Niveaux: 
* Detail:
*   si pile de commande active
*     alors dspcmd
*     sinon
*	si courante > dernière
*	  alors
*	    si Insert
*	      alors
*               [Eof]
*               keywait
*             sinon
*               si lastkey = [v] ou [g][v]
*                 alors [Eof]
*               fin si
*	    fin si
*	  sinon
*	    si Insert
*	      alors
*		dsplin
*		CR/LF
*		keywait
*	      sinon
*		cursor on
*		dsplin
*		cursor far left
*	    fin si
*	fin si
*   fin si
* Historique:
*   88/05/23: PD/JT conception & codage
*   88/06/05: PD/JT commente, [Eof] plus en mode T, lastkey
************************************************************

=edtlin	CD0EX
	D0=(5)	curadr
	DAT0=C	A	curadr := ^ ligne courante
	D0=(4)	insert
	DAT0=C	S	insert := (mode == 'I')
	GOSUB	cmdoff	enlever la pile de commande

	D0=(5)	=lastky
	C=DAT0	S
	C=0	P
	DAT0=C	P	lastkey := 0
	GOTO	edt010

 edt000	C=0	S	lastkey := 0
 edt010	B=C	S	B(S) := lastkey
*
* Pile de commande ?
*
	GOSUB	cmdst?	Pile de commande active ?
	GONC	edt020	Non : affichage normal
	GOSUB	dspcmd	Oui : affichage de la pile
	GOTO	edt100	attente d'une touche
*
* Affichage normal : <ligne courante> ou [Eof] ?
*
 edt020	D0=(5)	insert
	C=DAT0	S
	D0=(5)	curadr
	C=DAT0	A
	D0=C		D0 := ^ ligne

	D1=(5)	=COUR
	C=DAT1	A	C(A) := courante
	D1=(2)	=DERN
	A=DAT1	A	A(A) := dernière
	?C<=A	A	si courante <= dernière
	GOYES	edt050	alors message normal

*
* Mode I ou T
*
	?C#0	S
	GOYES	edt040	mode I, [Eof], keywait
* Mode T
	?B=0	S
	GOYES	edt100	Rien de spécial, on continue
*
* [Eof], mode T
*
	GOSUB	dspeof
	GOTO	edt100
*
* [Eof], mode I
*
 edt040	GOSUB	dspeof
	GOTO	edt055	pour la partie commune

 edt050	?C=0	S
	GOYES	edt060	<line>, mode T
*
* <line>, mode I
*
	GOSUB	=dsplin
	GOSBVL	=CRLFND	CR/LF no delay
 edt055	GOSUB	=KEYWT
	R3=A
	GOSUBL	=fkey
	LCASC	'A'
	GOSBVL	=ESCSEQ
	LCASC	'K'
	GOSBVL	=ESCSEQ
	GOTO	edt100	c'est fini
*
* <line>, mode T
*
 edt060	CD0EX
	R0=C		R0 préservé par ESCSEQ
	LCASC	'>'
	GOSBVL	=ESCSEQ	Cursor on
	C=R0
	D0=C		D0 := ^ ligne
	GOSUB	=dsplin
	GOSBVL	=CURSFL

 edt100	GOSUB	chedit

	GOSBVL	=FINDA
	CON(2)	13	[ENDLINE]
	REL(3)	edEND
	CON(2)	14	[ATTN]
	REL(3)	edATTN
	CON(2)	16	[f][CONT]
	REL(3)	edCONT
	CON(2)	18	[^]
	REL(3)	edUP
	CON(2)	19	[v]
	REL(3)	edDOWN
	CON(2)	20	[g][^]
	REL(3)	edTOP
	CON(2)	21	[g][v]
	REL(3)	edBOT
	CON(2)	24	[f][OFF]
	REL(3)	edOFF
	CON(2)	25	[g][CMDS]
	REL(3)	edCMDS
	NIBHEX	00
	GOTO	edt100	Ah bon ?

************************************************************
* [ATTN], [f][OFF]
************************************************************

 edATTN
 edOFF	GOSUB	finlin
	LC(1)	0	[ATTN] ou [f][OFF]
	RTN

************************************************************
* [f][CONT]
************************************************************

 edCONT	GOSUB	status
	GOTO	edt100

************************************************************
* touches de curseur : [v], [^], [g][^] et [g][v]
************************************************************

 edUP	GOSUB	[up]
	GOTO	edt510
 edDOWN	GOSUB	[down]
	GOTO	edt500
 edTOP	GOSUB	[top]
	GOTO	edt510
 edBOT	GOSUB	[bot]

 edt500	LC(1)	1
	CSRC	W	lastkey := 1
	GOTO	edt520
 edt510	C=0	S

 edt520	LC(1)	2
	GONC	edt600	pas de pile de commande
	GOTO	edt000	on ne sort pas si "pile de commande"

************************************************************
* [g][CMDS]
************************************************************

 edCMDS GOSUB	gcmds
	GOTO	edt000

************************************************************
* [ENDLINE]
************************************************************

 edEND
*
* Lire la chaîne sur la M.S.
*
	GOSUB	getstr
*
* Renvoyer les bonnes choses là où il faut...
*
	LC(1)	1	touche [ENDLINE]
	C=0	S

 edt600	D0=(5)	=lastky	donc on sort
	DAT0=C	S	en mettant lastkey
	RTN

************************************************************
* status
*
* But: afficher une ligne d'état tant qu'une touche est
*   appuyée.
* Appelle: WIPOUT, Num2D1, VIEWD1
* Niveaux: 2
* Historique:
*   88/05/24: PD/JT conception & codage
*   88/11/20: PD/JT ajout du nombre total de lignes
************************************************************

 status	D1=(5)	(=FUNCR0)-2
	C=0	A
	LC(2)	44
	GOSBVL	=WIPOUT
*
* Recopie du nom du fichier :
* Au plus 8 caractères, on arrête des qu'on trouve un " "
*
	D1=(2)	(=FUNCR0)-2
	D0=(5)	=FILADR
	C=DAT0	A
	D0=C
	LCASC	' '
	P=	9
 stat10	A=DAT0	B
	?A=C	B
	GOYES	stat20
	DAT1=A	B
	D1=D1+	2
	D0=D0+	2
	P=P-1
	GONC	stat10

*
* Mettre ", " comme séparateur
*
 stat20	P=	0
	LCASC	' ,'
	DAT1=C	4
	D1=D1+	4
	D0=(5)	=DERN
	C=DAT0	A	C(A) := dernière
	?C=0	A	Aucune ligne ?
	GOYES	stat50	Oui : cas particulier
*
* Mettre le numéro de la ligne courante
*
	D=C	A	D(A) := dernière pour plus tard
	D0=(2)	=COUR
	A=DAT0	A	A(A) := courante
	GOSUBL	=Num2D1
*
* Mettre "/" et le nombre de lignes
*
	LCASC	'/'
	DAT1=C	B
	D1=D1+	2	*D1++ = '/'
	C=D	A	C(A) := dernière
	A=C	A	A(A) := dernière
	GOSUBL	=Num2D1
	GOTO	stat90

*
* Cas particulier : "0/0"
*
 stat50	LCASC	'0/0'	c'est symétrique !
	DAT1=C	6

 stat90	D1=(2)	(=FUNCR0)-2
	GOVLNG	=VIEWD1

************************************************************
* gcmds
*
* But: réaliser les actions requises par l'appui sur la
*   touche [g][CMDS].
* Entrée:
* Sortie:
* Abime: 
* Appelle: cmdtog, cmdst?, CURSFL, ESCSEQ, finlin
* Niveaux: ouh la la...
* Historique:
*   88/05/23: PD/JT conception & codage
************************************************************

 gcmds	GOSUB	cmdtog
	GOSUB	cmdst?	Nouveau mode = "actif" ?
	GONC	gcmd10	Non : il faut donc désactiver
* Il faut l'activer
	GOSBVL	=CURSFL
	LCASC	'<'
	GOSUB	escseq	Cursor off
	LCASC	'\'
	GOSBVL	=DSPCHC
	LCASC	'>'
 escseq	GOVLNG	=ESCSEQ	Cursor on
* Il faut la désactiver
 gcmd10	GOTO	finlin

************************************************************
* dspeof
*
* But: afficher "[Eof]"
* Entrée: -
* Sortie: -
* Abime: A-D, D0, D1, R0, P
* Appelle: MFWRN
* Niveaux: 2
* Historique:
*   88/06/05: PD/JT isolement de edtlin
************************************************************

 dspeof LC(4)	(=id)~(=teEOF)	"[Eof]"
	P=	%0111	No "WRN Lxxx:", no ERRN, no BEEP
	GOVLNG	=MFWRN

************************************************************
* query
*
* But: afficher le résultat de la recherche ou du
*   remplacement et demander la validation de l'utilisateur.
* Entrée:
*   - A(A) = no ligne
*   - C(A) = no colonne
*   - D0 = ^ début de ligne (longueur LIF)
* Sortie:
*   - suivant C(0) :
*	0 : [Q] ou [ATTN] ou [f][OFF]
*       1 : [Y]
*       2 : [N]
* Abime: A-D, R1, D0, D1, toute la function scratch
* Appelle: DSPCNA, CRLFND, BLDBIT, LIFlen, Num2D1, KEYWT,
*   FINDA, dspmsg, R<RSTK, RSTK<R, YNQ
* Niveaux: voir note 1
* Note 1:
*   KEYWT consomme beaucoup de niveaux. Ceci conduisait à un
*   "Memory Lost" en cas d'attente prolongée (1 à 2 mn).
*   D'où une sauvegarde par R<RSTK et RSTK<R. Le nombre de
*   niveaux exactement utilisé par "query" est difficilement
*   évaluable.
* Note 2:
*   Les longues lignes ne sont pas traitées par "query" de
*   manière satisfaisante. Pour résoudre le probleme, il
*   faudrait utiliser l'algorithme suivant :
*     zone := largeur de la zone à afficher (zone substituée
*		ou occurrence complète) ;
*     len := longueur (ligne) ;
*     si len > 95
*	alors
*	  l := 95
*	  selon colonne et zone
*	    si colonne + zone < 95 alors i := 0 ;
*	    si colonne + 95 > len alors i := len - 95 ;
*	    sinon i := colonne - (95/2) ;
*	  fin selon
*	sinon
*	  l := len
*	  i := 0
*     fin si
*     afficher ligne [i, i+l] ;
*     FIRSTC := colonne - i ;
* Historique:
*   88/07/09: PD/JT conception & codage
*   88/10/16: PD/JT ajout de RSTK<R et R<RSTK
*   88/11/13: PD/JT utilisation de YNQ
************************************************************

 dspzon	EQU	=FUNCR0	zone d'affichage pour au moins 20 c.
 BitsOK	EQU	1

=query	D=C	A	D(A) := no colonne
	CD0EX
	D1=C		D1 := ^ début ligne

	P=	6	ajout du 88/10/16
	GOSBVL	=R<RSTK	abime B(A), C(A), C(S), D0

	CD1EX		C(A) := ^ début ligne
	GOSBVL	=CSLC5
	C=D	A
	GOSBVL	=CSLC2
	R1=C		R1(11-7) := ^ligne ; R1(6-2) := col
*
* L'affichage est construit en deux passes :
* La première de 20 caractères :
*    <ligne> : <colonne> \ <blancs...>
*
	D1=(5)	dspzon
	LCASC	'        '
	DAT1=C	W
	D1=D1+	16
	DAT1=C	W
	D1=D1+	16
	DAT1=C	2*20-16-16

	D1=(5)	dspzon	début de la zone
	GOSUBL	=Num2D1
	LCASC	':'
	DAT1=C	B
	D1=D1+	2
	C=D	A
	A=C	A	A(A) := no de colonne
	GOSUBL	=Num2D1
	LCASC	'\'
	DAT1=C	B

	AD1EX
	LC(5)	dspzon
	C=A-C	A	C(A) := nb de quartets utilisés
	CSRB
	A=R1
	A=C	B
	R1=A		R1(1-0) = position

	LC(2)	20-1	nb de caractères à afficher - 1
	CSRC	W
	CSRC	W	C(15-14) := nb de caractères - 1
	C=0	A	C(A) := Display starting position
	D=C	W
	LC(5)	dspzon	adresse du buffer
	GOSBVL	=BLDBIT
*
* Deuxième passe de deux caractères :
*    "/?"
*
	D1=(5)	dspzon
	LCASC	'?/'
	DAT1=C	4
	LC(2)	2-1	nb de caractères à afficher - 1
	CSRC	W
	CSRC	W	C(15-14) := nb de caractères - 1
	C=0	A
	LC(2)	20	C(A) := Display starting position
	D=C	W
	LC(5)	dspzon	adresse du buffer
	GOSBVL	=BLDBIT
*
* Protection de l'affichage
*   WINDST = position de départ (après le "\")
*   WINDLN = distance entre le "\" et le "/"
*
	D1=(5)	=WINDST
	A=R1		A(A) := position du "\" en octets
	A=A+1	B
	DAT1=A	B

	D1=(2)	=WINDLN
	LC(2)	19
	C=C-A	B
	DAT1=C	B
*
* Affichage de la ligne
* R1(11-7) = ^ ligne
* R1(6-2) = no colonne
* R1(1-0) = window start
* R0 n'a pas été modifié par BLDBIT
*
	D1=(5)	=FUNCR0	sauvegarde de R0 pendant DSPCNA
	C=R0
	DAT1=C	W

	C=R1		C(11-7) := ^ ligne LIF
	GOSBVL	=CSRC7
	D0=C		D0 := ^ longueur LIF
	GOSUBL	=LIFlen
	A=C	A	A(A) := taille en octets
	D0=D0+	4
	CD0EX
	D1=C		compatible avec DSPCNA
*
* D1 = ^ chaîne
* A(A) = nombre de caractères
*
	GOSBVL	=DSPCNA	3 ou 4 niveaux de retours
	GOSBVL	=CRLFND	5 niveaux de retours

*
* Ce qui suit est inspiré de SCROLL (voir IDS I, page 17-61)
*
	C=R1		C(6-2) := no de colonne
	GOSBVL	=CSRC2
	C=C-1	A	Parce que.
	GONC	que050
	C=0	A
 que050	B=C	A
	D0=(4)	=WINDLN	A(A) := WINDLN
	A=0	A
	A=DAT0	B
	C=0	A	C(A) := 95
	LC(2)	95
	C=C-A	A	C(A) := 95 - WINDLN
	?B>C	A
	GOYES	que060
	C=B	A	C(A) := min (B(A), 95 - WINDLN)
 que060	D0=(2)	=FIRSTC
	DAT0=C	B

	D0=D0-	(=FIRSTC)-((=DSPSTA)+3)
	C=DAT0	A
	CSTEX
	ST=0	BitsOK
	CSTEX
	DAT0=C	A
*
* Fn du pompage sur SCROLL
*
 que100	GOSUBL	=KEYWT
	GOSBVL	=FINDA
	CON(2)	#2B	[ATTN]
	REL(3)	quequi
	CON(2)	#2B+56	[f][OFF]
	REL(3)	quequi
	NIBHEX	00
*
* A(B) = code physique de la touche
*
	GOSUBL	=YNQ
	GOSBVL	=TBLJMC
	REL(3)	que?	non reconnu
	REL(3)	queyes	[Y]
	REL(3)	queno	[N]
	REL(3)	quequi	[Q]

 que?	GOSUB	wind=0
	LC(4)	(=id)~(=teCONF)	"Y/N/Q ?"
	GOSUBL	=dspmsg
	GOTO	que100

 queno	LC(1)	2	code de retour := 2
	GOTO	queat0
 queyes	LC(1)	1	code de retour := 1
	GOTO	queat0
 quequi	C=0	A	code de retour := 0
 queat0	B=0	A
	B=C	P	B(A) := code de retour
	GOSUB	wind=0	n'abime pas B(A)
*
* Restaurer la pile de retours
*
	A=B	A	A(A) := code de retour
	P=	6	ajout du 88/10/16
	GOSBVL	=RSTK<R	abime B(A), C(A), C(S), D0
	C=A	A	C(A) := code de retour
*
* et sortir
*
	RTN

************************************************************
* wind=0
*
* But: remettre WINDST et WINDLN à leur valeurs par défaut.
* Entrée:
*   - FUNCR0 = zone de sauvegarde pour R0
* Sortie:
*   - WINDST = 0
*   - WINDLN = 21
*   - R0 restauré à partir de FUNCR0
* Abime: C, D0, R0
* Appelle: -
* Niveaux: 0
* Historique:
*   88/10/22: PD/JT séparation de query et documentation
************************************************************

 wind=0
*
* Remettre WINDST et WINDLN à leur état initial
*
	D0=(5)	=WINDST	WINDST := 0
	C=0	B
	DAT0=C	B
	D0=(2)	=WINDLN	WINDLN := 21
	LC(2)	21
	DAT0=C	B
*
* Restaurer R0 sauvé dans FUNCR0
*
	D0=(4)	=FUNCR0
	C=DAT0	W
	R0=C
*
* et sortir
*
	RTN

	END
