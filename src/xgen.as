	TITLE	Editeur, chaînes génériques <xgen.as>

*
* Ce module n'a pas l'air de consommer de mémoire (sauf pour
* stocker le buffer bien sur).
* En revanche, la consommation de registres est
* impressionnante.
*

*
* Définitions pour les tokens compilés
*
 CHAR	EQU	0	a character (valeur cablee)
 EOL	EQU	1	end of line
 ANY	EQU	2	any character
 CCL	EQU	3	character class
 NCCL	EQU	4	not in character class
 END	EQU	5	end of compiled stream
 BOL	EQU	6	begin of line
 CLOS	EQU	7	closure
*
* et maintenant leur taille
*
 BOLS	EQU	1	BOL
 EOLS	EQU	1	EOL
 ANYS	EQU	1	ANY
 CCLS	EQU	1+256	CCL c0 c1 ... c255
 NCCLS	EQU	1+256	NCCL c0 c1 ... c255
 CHARS	EQU	1+2	CHAR c
 CLOSS	EQU	1	CLOS <token>

*
* Définitions pour les caractères HP-UX
*
 XBOL	EQU	'^'	begin of line
 XEOL	EQU	'$'	end of line
 XANY	EQU	'.'	any character
 XBCCL	EQU	'['	begin of character class
 XECCL	EQU	']'	end of character class
 XNCCL	EQU	'^'	not in character class
 XICCL	EQU	'-'	interval in character class
 XCLOS	EQU	'*'	closure
 XREP	EQU	'&'	remplacement
 XESC	EQU	'\'	escape
*
* Définitions pour les caractères HP-71
*
 SBOL	EQU	'^'	begin of line
 SEOL	EQU	'$'	end of line
 SANY	EQU	'.'	any character
 SREPT	EQU	'@'	repetition (.*)
 SREP	EQU	'&'	remplacement
 STOGL	EQU	'\'	toggle

*
* Notes sur les closures et leur utilisation :
* - Les closures sont codées sous forme d'un tableau de 256
*   quartets (on pourrait le compresser à 256 bits).
* - il y a donc un nombre maximum de 14 closures.
* - pour les utiliser, il faut une pile, contenant à chaque
*   fois 20 quartets.
* - on place cette pile en début de buffer, ce qui laisse
*   toujours 14 closures.
*
 STKSIZ	EQU	14*20	14 closures * 20 quartets

************************************************************
* COMPUX
*
* But: compiler une chaîne générique
* Entree:
*   - D1 = ^ M.S. sur la chaîne à compiler
*   - A(A) = longueur en octets
* Sortie:
*   - Cy = 1 : erreur
*	C(4-0) = numéro d'erreur pour BSERR
*   - Cy = 0 : pas d'erreur
*	R0(7-3) = D1 = ^ début du buffer (sur les donnees)
*	R0(2-0) = B(X) = buffer ID
* Abime: A-D, D0, D1, R0-R2
* Appelle: getbuf, addchr, marque, lookah, getchr,
*   FINDA, I/OCON, WIPOUT, gettab, MOVED2
* Niveaux: 4 (getbuf)
* Detail:
*   créer le buffer
*   tant que non fin de chaîne
*     faire
*       mémoriser le début du pattern précédent
*       selon caractère lu
*         '\' : ajouter_normal (caractère suivant)
*         '.' : ajouter (ANY)
*         '^' : si début de ligne
*                 alors ajouter (BOL)
*                 sinon ajouter_normal ('^')
*               fin si
*         '$' : si fin de ligne
*                 alors ajouter (EOL)
*                 sinon ajouter_normal ('$')
*               fin si
*         '[' : ajouter CCL ou NCCL selon caractère suivant
*               analyser ce qui suit et créer tableau
*         '*' : décaler le pattern précédent
*               insérer la closure avant
*         sinon : ajouter_normal (caractère lu)
*       fin selon
*   fin tant que
* Historique:
*   88/06/05: PD/JT conception & codage
*   88/10/29: PD/JT suppression du buffer en cas d'erreur
************************************************************

=COMPUX	GOSUB	getbuf
	RTNC		si erreur
*
* B(A) = taille du buffer
* D(A) = taille de la chaîne
* D1 = ^ chaîne
* D0 = ^ buffer
* R0(2-0) = bufid
* R0(7-3) = ^ buffer
*
	C=0	A
	R1=C		marque := 0
*
* D(A) = nb de caractères restant dans la chaîne
* B(A) = taille du buffer
* D1 = ^ chaîne
* D0 = ^ buffer
* R1 = ^ token précédent
*
 cux-10	GOSUBL	=getchr
	GOC	cmpend	Fin de chaîne
	GOSBVL	=FINDA
	CON(2)	XESC
	REL(3)	cuESC
	CON(2)	XANY
	REL(3)	cuANY
	CON(2)	XBOL
	REL(3)	cuBOL
	CON(2)	XEOL
	REL(3)	cuEOL
	CON(2)	XBCCL
	REL(3)	cuCCL
	CON(2)	XCLOS
	REL(3)	cuCLOS
	NIBHEX	00

	GOSUB	marque	marque lasttoken
	GOSUB	addchr
	RTNC		if error
	GOTO	cux-10

************************************************************
* Sortie de la compilation
************************************************************
 System	GOTO	system
 norooM	GOTO	noroom

 cmpend
*
* Marqueur de fin
*
	B=B-1	X
	GOC	norooM
	LC(1)	END
	DAT0=C	P
*
* Réduire la taille du buffer
*
	C=R0		C(X) = buffer id
	GOSBVL	=I/OCON	
	GONC	System	buffer not found !
*
* Maintenant, il faut renvoyer les paramètres du buffer
*
	C=R0
	B=C	X	B(A) := buffer id
* Cy = 0 : pas d'erreur
* D1 = ^ début du buffer (sur les donnees) (après I/OCON)
* B(X) = buffer ID
	RTNCC

 cuESC	GOSUBL	=getchr
	GOC	InvPat	"\" et fin de ligne
	GOSUB	marque
	GOSUB	addchr
	RTNC		if error
	GOTO	cux-10	et retour à la boucle

 InvPat	GOTO	invpat

 cuANY	GOSUB	marque
	LC(3)	ANYS
	B=B-C	X
	GOC	Noroom
	LC(1)	ANY
	DAT0=C	P
	D0=D0+	1
	GOTO	cux-10	et retour à la boucle

 cuBOL	A=R1
	GOSUB	marque
	?A=0	A	Début de ligne ?
	GOYES	cuBL10	oui
	LCASC	'^'
	A=C	B
	GOSUB	addchr	'^' normal
	RTNC		if error
	GOTO	cux-10	et retour à la boucle
 cuBL10	LC(3)	BOLS	'^' générique
	B=B-C	X
	GOC	Noroom
	LC(1)	BOL
	DAT0=C	P
	D0=D0+	1
	GOTO	cux-10	et retour à la boucle

 Noroom	GOTO	noroom

 cuEOL	GOSUB	marque
	GOSUBL	=lookah
	GOC	cuEL10	fin de ligne
	LCASC	'$'
	A=C	B
	GOSUB	addchr	'$' normal
	RTNC		if error
	GOTO	cux-10	et retour à la boucle
 cuEL10	LC(3)	EOLS	'$' générique
	B=B-C	X
	GOC	Noroom
	LC(1)	EOL
	DAT0=C	P
	D0=D0+	1
	GOTO	cux-10	et retour à la boucle

 Invpat	GOTO	invpat

 cuCCL	GOSUB	marque
	LC(3)	CCLS
	B=B-C	X
	GOC	Noroom
	GOSUBL	=lookah
	GOC	Invpat	"[" et fin de ligne
	LC(1)	CCL
	CSRC		C(S) := CCL
	LCASC	'^'
	?A#C	B
	GOYES	cuCL10
	LC(1)	NCCL
	CSRC
	GOSUBL	=getchr
 cuCL10	DAT0=C	S
	D0=D0+	1
*
* tab [0..255] := 0
*
	CD0EX
	D0=C
	CD1EX		D1 := D0
	R2=C		R2 := D1
	LC(5)	(CCLS)-1
	GOSBVL	=WIPOUT
	C=R2
	D1=C

 cuCL50	GOSUBL	=getchr
	GOC	Invpat	"]" manquant
	LC(2)	XECCL	']'
	?A=C	B
	GOYES	cuCL90
	LC(2)	XESC	'\'
	?A#C	B
	GOYES	cuCL60
	GOSUBL	=getchr
	GOC	Invpat	"[...\" et fin de ligne
 cuCL60	ASL	A
	ASL	A	A(3-2) = caractère
	GOSUBL	=lookah
	GOC	cuCL70	fin de ligne (anormal)
	LC(2)	XICCL	'-'
	?A=C	B
	GOYES	cuCL80
* caractère simple
 cuCL70	ASR	A
	ASR	A	A(B) := caractère
	GOSUB	gettab	D0 := ^ caractère dans le tableau
	A=C	A	A(A) := ancienne adresse
	LC(1)	1
	DAT0=C	P	tab [caractère] := true
	D0=A		D0 := ^ tab [0]
	GOTO	cuCL50	et un tour de boucle de plus !

 cuCL90	AD0EX
	LC(5)	(CCLS)-1
	A=A+C	A
	D0=A
	GOTO	cux-10	et retour à la boucle

 invPat	GOTO	invpat
* ..-..
 cuCL80	GOSUBL	=getchr	passer le '-'
	GOSUBL	=getchr
	GOC	invPat	"[...-" et fin de ligne
	LC(2)	XESC
	?A#C	B
	GOYES	cuCL82
	GOSUBL	=getchr
	GOC	invPat	"[...-\" et fin de ligne
 cuCL82	C=A	B	C(B) := upper
	ASR	A
	ASR	A	A(B) := lower
	C=C-A	B	range
	R2=C		R2 := range
	GOC	invPat	lower > upper
	GOSUB	gettab	D0 := ^ tab [lower]
	CR2EX		R2 := ^ tab [0] ; C(B) := range
	A=C	B	compteur dans A(B)
	LC(1)	1
 cuCL84	DAT0=C	P
	D0=D0+	1
	A=A-1	B
	GONC	cuCL84
	C=R2		C(A) := ^ tab [0]
	D0=C
	GOTO	cuCL50

 noRoom	GOTO	noroom

 cuCLOS	B=B-1	X
	GOC	noRoom
	A=R1		last token
	?A=0	A
	GOYES	invPat	"*"
	AD0EX		A(A) := courant; D0 := ^ last
	R2=A		R2 := courant
	A=DAT0	P	A(0) := last token
	LC(1)	BOL
	?A=C	P
	GOYES	invpat	"^*"
	LC(1)	CLOS
	?A=C	P
	GOYES	invpat	"...**"

	AD1EX		A(A) := D1
	AR2EX		A(A) := end of dest; R2 := D1
	D1=A
	R1=A		on remettra last token après
	D1=D1+	1	D1 := ^ end of dest
	CD0EX
*
* C(A) = start of source
* A(A) = end of source
* D1 = end of destination
* R1 = end of source
* R2 = ancien D1
*
	GOSBVL	=MOVED2

	A=R2		A(A) := ancien D1
	D1=A		D1 est restauré
	LC(1)	CLOS
	DAT0=C	P

	AD0EX		A(A) := ^ last token
	AR1EX
* R1 := ^ last token ; A(A) := end of source
	D0=A
	D0=D0+	1

	GOTO	cux-10

 invpat	GOSUB	=ENDPOS
	LC(4)	(=id)~(=teIPAT)
	RTNSC		

************************************************************
* COMP71
*
* But: compiler une chaîne générique
* Entree:
*   - D1 = ^ M.S. sur la chaîne à compiler
*   - A(A) = longueur en octets
* Sortie:
*   - Cy = 1 : erreur
*	C(4-0) = numéro d'erreur pour BSERR
*   - Cy = 0 : pas d'erreur
*	R0(7-3) = D1 = ^ début du buffer (sur les données)
*	R0(2-0) = B(X) = buffer ID
* Abime: A-D, D0, D1, R0-R2
* Appelle: getbuf, addchr, lookah, getchr, FINDA, I/OCON
* Niveaux: 4 (getbuf)
* Detail:
*   créer le buffer
*   état := 0
*   tant que non fin de chaîne
*     faire
*	lire le caractère
*	si caractère lu = '\'
*	  alors
*	    selon état
*	      0 : état = 1
*	      1 : ajouter_normal ('\')
*		  état = 0
*	      2 : état = 3
*	      3 : ajouter_normal ('\')
*		  état = 2
*	    fin selon
*	  sinon
*	    selon état
*	      0 : ajouter_normal (caractère lu)
*	      1 : état = 2
*		  traiter_spécial (caractère lu)
*	      2 : ajouter_normal (caractère lu)
*	      3 : état = 0
*		  ajouter__normal (caractère lu)
*	fin si
*   fin tant que
*
* traiter_spécial (caractère)
*   selon caractère lu
*     '.' : ajouter (ANY)
*     '^' : si début de ligne
*             alors ajouter (BOL)
*             sinon ajouter_normal ('^')
*           fin si
*     '$' : si fin de ligne
*             alors ajouter (EOL)
*             sinon ajouter_normal ('$')
*           fin si
*     '@' : ajouter (CLOSURE)
*           ajouter (ANY)
*   fin selon
* Historique:
*   88/06/26: PD/JT conception & codage d'après COMPUX
*   88/10/29: PD/JT suppression du buffer en cas d'erreur
************************************************************

=COMP71	GOSUB	getbuf
	RTNC		si erreur
*
* B(A) = taille du buffer
* D(A) = taille de la chaîne
* D1 = ^ chaîne
* D0 = ^ buffer
* R0(2-0) = bufid
* R0(7-3) = ^ buffer
*
	LC(1)	0
	R1=C		état := 0
*
* D(A) = nb de caractères restant dans la chaîne
* B(A) = taille du buffer
* D1 = ^ chaîne
* D0 = ^ buffer
* R1(0) = ^ état de l'automate cablé
*
 c71-10	GOSUBL	=getchr
	GOC	Cmpend	Fin de chaîne
	LC(2)	STOGL
	?A#C	B	A(B) = caractère lu
	GOYES	c71nor	caractère normal (ou générique)
	C=R1
	GOSBVL	=TBLJMC
	REL(3)	c7b0	back-slash
	REL(3)	c7b1
	REL(3)	c7b2
	REL(3)	c7b3
 Cmpend	GOTO	cmpend	rallonge
 c71nor	C=R1
	GOSBVL	=TBLJMC
	REL(3)	c7n0	normal
	REL(3)	c7n1
	REL(3)	c7n2
	REL(3)	c7n3

 c7b0	LC(1)	1
	R1=C		état := 1
	GOTO	c71-10
 c7b1	LC(1)	0
	GOTO	c7b30
 c7b2	LC(1)	3
	R1=C		état := 3
	GOTO	c71-10
 c7b3	LC(1)	2
 c7b30	R1=C		état := 0
*
* Attention ! le code continue !!!
*
 c7n0	GOSUB	addchr	ajouter_normal (caractère lu)
	RTNC
	GOTO	c71-10
 c7n1	LC(1)	2
	R1=C
 c7n2	GOSBVL	=FINDA	routine "traite_speéial"
	CON(2)	SANY
	REL(3)	c7ANY
	CON(2)	SBOL
	REL(3)	c7BOL
	CON(2)	SEOL
	REL(3)	c7EOL
	CON(2)	SREPT
	REL(3)	c7REPT
	NIBHEX	00
	GOSUB	addchr
	RTNC		if error
	GOTO	c71-10

 c7n3	GOSUB	addchr	ajouter_normal (caractère lu)
	RTNC
	LC(1)	0
	R1=C		état := 0
	GOTO	c71-10

 c7ANY	LC(3)	ANYS
	B=B-C	X
	GOC	NoRoom
	LC(1)	ANY
	DAT0=C	P
	D0=D0+	1
	GOTO	c71-10
 c7BOL	A=R0
	ASR	W
	ASR	W
	ASR	W	A(A) := ^ début buffer
	LC(5)	STKSIZ
	C=C+A	A	C(A) := ^ début motif (après pile)
	AD0EX		A(A) := ^ position courante
	?A=C	A
	GOYES	c7BL10	en début de buffer
	AD0EX
	LCASC	'^'
	A=C	B
	GOSUB	addchr	'^' normal
	RTNC		si erreur
	GOTO	c71-10
 c7BL10	AD0EX
	LC(3)	BOLS	'^' générique
	B=B-C	X
	GOC	NoRoom
	LC(1)	BOL
	DAT0=C	P
	D0=D0+	1
	GOTO	c71-10
 NoRoom	GOTO	noroom
 c7EOL	GOSUBL	=lookah
	GOC	c7EL10	fin de ligne
	LCASC	'$'
	A=C	B
	GOSUB	addchr	'$' normal
	RTNC		si erreur
	GOTO	c71-10
 c7EL10	LC(3)	EOLS
	B=B-C	X
	GOC	NoRoom
	LC(1)	EOL
	DAT0=C	P
	D0=D0+	1
	GOTO	c71-10
 c7REPT	LC(3)	(CLOSS)+(ANYS)
	B=B-C	X
	GOC	NoRoom
	LC(1)	CLOS
	DAT0=C	P
	D0=D0+	1
	LC(1)	ANY
	DAT0=C	P
	D0=D0+	1
	GOTO	c71-10

 system	LC(4)	=eSYSER
	RTNSC

************************************************************
* getbuf
*
* But: allouer un buffer de taille maximum pour la chaîne à
*   compiler.
* Entree:
*   - AVMEMS et AVMEME positionnés
* Sortie:
*   - D1 n'est pas modifié
*   - D(A) = A(A) en entrée
*   - D0 = ^ buffer (après la pile)
*   - R0(2-0) = buffid
*   - R0(7-3) = ^ début du buffer (partie donnees)
*   - B(A) = taille du buffer
* Abime: A(15-5), B-D, D0, R0
* Appelle: IOFSCR, I/OALL
* Niveaux: 3 (I/OALL)
* Detail: le buffer est alloué au maximum de la place
*   mémoire disponible. STKSIZ quartets sont réservés pour
*   stocker la pile. La taille renvoyée et le pointeur
*   D0 tiennent compte de la pile. En revanche, le pointeur
*   dans R0 est le vrai début du buffer
* Historique:
*   88/06/05: PD/JT conception & codage
************************************************************

 getbuf	ASL	W
	ASL	W
	ASL	W
	ASL	W
	ASL	W
	AD1EX
	R0=A		R0 := sauvegarde de A et D1
*
* Trouver un id scratch disponible
*
	GOSBVL	=IOFSCR	A, C(A), D1, 1 niveau
	GOC	system	No available buffer
*
* C(X) = buffer id
*
	B=C	A	B(A) := buffer id
	D1=(5)	=AVMEME
	A=DAT1	A
	D1=D1-	(=AVMEME)-(=AVMEMS)
	C=DAT1	A
	A=A-C	A	A(A) := MEM en quartets
	C=0	A
	LC(2)	(=LEEWAY)+7
	A=A-C	A	A(A) := place restante après LEEWAY
	GOC	errmem
	LC(5)	#FFF	4095 nibs pour le buffer
	?A<=C	A
	GOYES	getb10
	A=C	A	C(A) := 4095 nibs
* B(A) = id du buffer
* A(A) = taille demandée
 getb10	LC(5)	STKSIZ
	?A<C	A
	GOYES	errmem
	C=A	A	C(A) := taille demandée
	BCEX	A	B(A) = taille demandée, C(A) = bufid
	GOSBVL	=I/OALL	A-D, D1, D0, 2 niveaux
	GONC	errmem
*
* D1 = ^ past buffer header
* B(A) = bufsize
* C(6-0) = header (C(1-3) = buffer id)
*
	AD1EX
	D0=A		D0 := ^ buffer
	ASL	W
	ASL	W
	ASL	W	A(7-3) = ^ buffer, A(2-0) = 000
	CSR	A	C(X) = buffid
	A=A+C	X	A(7-3) = ^ buffer, A(2-0) = buffid
	AR0EX
	D1=A		D1 := ancien D1 restauré
	ASR	W
	ASR	W
	ASR	W
	ASR	W
	ASR	W	A(A) := ancien D1 restauré
	C=B	A
	D=C	A	D(A) := taille du buffer
	C=0	A
	LC(1)	7	pour le header
	D=D-C	A
*
* D1 et A(A) ne sont pas modifiés
* D0 = ^ buffer
* R0(2-0) = buffid
* R0(7-3) = ^ buffer
* D(A) = taille du buffer
*
	C=D	A	C(A) := taille du buffer
	ACEX	A	A(A) := taille ; C(A) := LEN chaîne
	D=C	A	D(A) := longueur de la chaîne
	B=A	A	B(A) := taille du buffer

	LC(5)	STKSIZ
	B=B-C	A	B(A) := taille (- la pile)
	AD0EX
	A=A+C	A
	D0=A		D0 := ^ après la pile
*
* B(A) = taille restante dans le buffer
* D(A) = taille de la chaîne
* D1 = ^ chaîne
* D0 = ^ buffer
* R0(2-0) = bufid
* R0(7-3) = ^ buffer
*
	RTNCC

 errmem	LC(4)	=eMEM
	RTNSC

************************************************************
* marque
*
* But: marque la position courante dans la chaîne compilée
*   comme "last token"
* Entree:
*   - D0 = ^ buffer
* Sortie:
*   - R1 = ^ last token
* Abime: R1
* Niveaux: 0
* Historique:
*   88/06/05: PD/JT conception & codage
************************************************************

 marque	CD0EX
	R1=C
	CD0EX
	RTN

************************************************************
* addchr
*
* But: ajoute un caractère au buffer, c'est à dire le token
*   CHAR suivi du caractère.
* Entree:
*   - A(B) = caractère à écrire
*   - B(A) = place restante dans le buffer
*   - D0 = ^ buffer
* Sortie:
*   - Cy = 1 : erreur
*	C(3-0) = error number
*   - Cy = 0 : ça s'est bien passé
*	D0 réactualisé
* Abime: C(A)
* Niveaux: 0
* Historique:
*   88/06/05: PD/JT conception & codage
************************************************************

 addchr	LC(3)	CHARS	size of pattern
	B=B-C	X
	GOC	noroom
	LC(1)	CHAR
	DAT0=C	P
	D0=D0+	1
	DAT0=A	B
	D0=D0+	2	Cy = 0
	RTN

 noroom	GOSUB	=ENDPOS
	LC(4)	(=id)~(=teICMP)	"No Room for Pattern"
	RTNSC		Cy = 1 : erreur

************************************************************
* gettab
*
* But: obtenir l'adresse du caractère A(B) dans le tableau
*   pointé par D0.
* Entree:
*   - A(B) = numéro du caractère
*   - D0 = ^ premier caractère dans le tableau
* Sortie:
*   - D0 = ^ tab [caractère]
*   - C(A) = ancienne adresse (^ tab [0])
* Abime: C(A), A(4-2)
* Niveaux: 0
* Historique:
*   88/06/05: PD/JT conception & codage
************************************************************

 gettab	C=0	A
	C=A	B
	A=C	A
	CD0EX
	D0=C
	C=C+A	A
	CD0EX
	RTN

************************************************************
* POSADR
*
* But: chercher une chaîne générique dans une chaîne objet.
* Entree:
*   - D0 = ^ chaîne à chercher
*   - A(A) = longueur de la chaîne à chercher
*   - R0(7-0) = caractéristiques du buffer (cf. COMPUX/71)
*   - R1(A) = ^ vrai début de la chaîne à chercher
* Sortie:
*   Cy = 1 : match found
*     - D0 = ^ occurrence dans la chaîne objet
*     - C(A) = longueur de l'occurrence trouvée (en octets)
*   Cy = 0 : match not found ou erreur
* Abime: A-D, R0(12-8), R1, R2, D0, D1
* Appelle: amatch
* Niveaux: 3
* Notes:
*   - La chaîne objet doit être dans le "bon" sens, c'est
*     dire celui des fichiers, et pas celui de la M.S. Cela
*     oblige à inverser la chaîne à chercher si elle est sur
*     la M.S.
*   - R1(A) contient l'adresse du "vrai" début de la chaîne.
*     D0 contient l'adresse à partir de laquelle POSADR
*     cherche. Ceci est utile en cas de recherche ne
*     commençant pas au début (ex: substitution globale,
*     paramètre de GENPOS, etc.)
* Remarque: R0(7-0) n'est pas abimé
* Historique:
*   88/06/05: PD/JT conception & codage (de quatre lignes)
*   88/06/26: PD/JT conception & codage (du début du reste)
*   88/07/02: PD/JT débogage et ajout de recherche multiple
*   88/10/07: PD/JT débogage
*   88/10/07: PD/JT retrait du compte dans R1(A) pour amatch
*   88/10/08: PD/JT débogage du cas '^'
*   88/10/09: PD/JT renvoie maintenant la longueur en octets
*   88/10/16: PD/JT séparation de UPDTR0
*   88/10/16: PD/JT suppression du point d'entrée POSID
************************************************************

=POSADR	C=R0
	GOSBVL	=CSRC3
	D1=C		D1 := ^ buffer
*
* D1 = ^ buffer (début des données)
* D0 = ^ chaîne
* A(A) = longueur de la chaîne en octets
* 
	AD1EX		sauvegarde de A dans D1
	A=C	A	A(A) := longueur de la chaîne
	C=R1		C(A) := ^ vrai début
	GOSBVL	=CSRC5	C(15-11) := ^ vrai début
	LC(5)	STKSIZ
	C=A+C	A	C(A) := ^ début du pattern
	AD1EX		restauration de A(A)
	GOSBVL	=CSLC5
	R1=C		R1(9-5):=pattern; R1(A):=^vrai début

	CD0EX		C(A) := ^ chaîne à examiner
	D1=C		D1 := ^ chaîne
	C=A	A
	D=C	A	D(A) := nb de caractères

*
* Si le premier caractère est normal, on rentre dans une
* boucle spéciale pour éviter la grosse machinerie de
* "amatch", et en particulier sa récursivité.
*
	C=R1
	GOSBVL	=CSRC5	C(A) := pattern
	D0=C
	A=DAT0	P	A(0) := type du premier pattern
	?A=0	P
	GOYES	Poschr	boucle spéciale
*
* Si le premier caractère est "^", on ne teste qu'une
* fois sur le début de ligne.
*

	LC(1)	BOL
	?A#C	P
	GOYES	pos10
	GOTO	posbol	boucle spéciale pour '^'

 Poschr	GOTO	poschr
*
* Tant pis, il faut y aller. On a signé, c'est...
*

*
* Invariant de boucle :
*   R1(9-5) = pattern; R1(A) = ^ vrai début
*   D(A) = nb de caractères dans la chaîne à chercher
*   D1 = ^ premier caractère à chercher
*
 pos10	C=R1
	CSRC		C(A) := ^ début pattern
	CSRC
	CSRC
	CSRC
	CSRC
	D0=C		D0 := ^ début pattern

	CD1EX
	D1=C
	CSLC		CSLC5
	CSLC
	CSLC
	CSLC
	CSLC
	C=D	A
	R2=C		sauvegarde de D et D1
	GOSUB	amatch
	GOC	pos20	match found

	C=R2		restauration de D et D1
	D=C	A
	CSR	W	CSR 5
	CSR	W
	CSR	W
	CSR	W
	CSR	W
	D1=C

	D1=D1+	2
	D=D-1	A
	GONC	pos10
 RtnCC	RTNCC		no match

 pos20
*
* D1 = ^ fin de l'occurrence dans la chaîne objet
* R2(9-5) = ^ début de l'occurence
*
	C=R2
	GOSBVL	=CSRC5
*
* D1 = ^ fin de l'occurrence dans la chaîne objet
* C(A) = ^ début de l'occurrence
*
 pos30	D0=C		D0 := ^ début de l'occurrence
	A=0	M	pour la division par 2
	AD1EX		A(A) := ^ fin occurrence
	A=A-C	A	C(A) := 2*LEN(occurrence)
	ASRB
	C=A	A	C(A) := LEN(occurrence)
*
* D0 = ^ occurrence dans la chaîne objet
* C(A) = longueur de l'occurrence trouvée (en octets)
*
	RTNSC		match found

*
* Boucle spéciale sur le caractère
*
 poschr	C=R1		C(9-5) := ^ début pattern
	CSRC		CSRC 5
	CSRC	
	CSRC	
	CSRC	
	CSRC	
	D0=C		D0 := ^ début pattern

	D0=D0+	1
	A=DAT0	B	A(B) := premier caractère du motif
	D0=D0+	2
*
* Boucle très rapide
*   D1 = ^ premier caractère à chercher
*   D(A) = nb de caractères dans la chaîne à chercher
*   D0 = ^ patern "après" le premier caractère
*
 posc10	?D=0	A
	GOYES	RtnCC	no match
	C=DAT1	B
	D=D-1	A
	D1=D1+	2
	?A#C	B
	GOYES	posc10

	CD1EX
	D1=C
	CSL	W	CSL 5
	CSL	W
	CSL	W
	CSL	W
	CSL	W
	C=D	A
	R2=C		R2 := D1 et D(A)
	GOSUB	amatch
	GOC	posc20	match found

	C=R2		restauration de D1 et D(A)
	D=C	A
	CSR	W	CSR 5
	CSR	W
	CSR	W
	CSR	W
	CSR	W
	D1=C
	GOTO	poschr

 posc20	C=R2		C(9-5) := ^ deuxième caractère
	GOSBVL	=CSRC5
	C=C-1	A
	C=C-1	A	C(A) := ^ début de l'occurrence
	GOTO	pos30

*
* Portion de code spéciale pour ne tester qu'une seule
* fois le "^" de début de ligne
*
 posbol	C=R1		C(A) := ^ vrai début
	AD1EX
	D1=A
	?A#C	A
	GOYES	Rtncc

	D0=D0+	1	passer le BOL

	CD1EX
	D1=C
	CSL	W	CSL 5
	CSL	W
	CSL	W
	CSL	W
	CSL	W
	C=D	A
	R2=C
	GOSUB	amatch
	GOC	Pos20
 Rtncc	RTNCC		no match

 Pos20	GOTO	pos20

************************************************************
* amatch
*
* But: reconnaître une chaîne de caractères
* Entree:
*   - D0 = ^ motif courant
*   - D1 = ^ caractère courant, D(A) = nb de car. restant
* Sortie:
*   - Cy = 0 : match not found
*   - Cy = 1 : match found
*   - D0 inchangé
*   - D1 et D(A) actualisés si besoin
* Abime: A-D, R0(12-8), D0, D1
* Appelle: omatch, nxtpat
* Niveaux: 2
* Algorithme:
*   tant que pas arrivé à la fin du pattern
*     si closure
*	alors
*	  chercher la dernière possibilité (avec omatch)
*	  revenir en arriere jusqu'à ce que
*		"amatch (reste) = TRUE"
*	  si trouvé alors
*	    alors return TRUE
*	    sinon return FALSE
*	  fin si
*	sinon si omatch = FALSE alors return FALSE
*     fin si
*   fin tant que
* Historique:
*   88/06/26: PD/JT conception & codage
*   88/07/02: PD/JT ajout des closures
*   88/10/07: PD/JT retrait du compte dans R1(A) pour '^'
*   88/10/14: PD/JT bug GENLEN("AB","A.*B") corrigée
************************************************************

 amatch	C=R0		Initialisation de "^ courant"
	CSRC		CSRC3
	CSRC
	CSRC
	A=C	A	A(A) := ^ début de la pile
	CSRC		CSRC5
	CSRC
	CSRC
	CSRC
	CSRC
	C=A	A
	CSLC		CSRC8
	CSLC
	CSLC
	CSLC
	CSLC
	CSLC
	CSLC
	CSLC
	R0=C		R0(12-8) := ^ courant

 amarec	A=DAT0	P
	LC(1)	END
	?A=C	P
	GOYES	return	match found
	LC(1)	CLOS
	?A=C	P
	GOYES	amaclo	"closure"
	GOSUB	omatch
	GONC	return	no match possible
	GOSUB	nxtpat	D0 := ^ motif suivant
	GOTO	amarec

*
* Closure trouvée. Les ennuis commencent...
*
 amaclo	D0=D0+	CLOSS	passer la closure
	C=D	A
	B=C	A	B(A) := pos. initiale pour closure
 acl010	GOSUBL	=lookah
	GOC	acl100	on a fini la closure
	GOSUB	omatch
	GOC	acl010	tant qu'on trouve
*
* On est arrivé au maximum. Faut revenir en arrière sur D1
* while D<=B
*   do
*     if amatch (reste) return TRUE
*
 acl100	GOSUB	nxtpat	D0 est bien positionné

 acl150	GOTO	call	appel recursif...
 aclret	GOC	return	retour si amatch = TRUE
	D1=D1-	2
	D=D+1	A
	C=D	A
	?C<=B	A
	GOYES	acl150
*
* on est arrivé au bout sans trouver, alors :
*
	GOTO	return	et on a Cy = 0

*
* Appels et retours récursifs...
*
 return	A=0	S	sauvegarde de la carry
	GONC	ret010
	A=A+1	S

 ret010 C=R0
	CSRC		CSRC3
	CSRC
	CSRC
	A=C	A	A(A) := ^ début
	CSRC		CSRC5
	CSRC
	CSRC
	CSRC
	CSRC		C(A) := ^ courant
	?A=C	A
	GOYES	ret090
	CD1EX
* D1 := ^ courant ; C(A) := ancienne valeur de D1

*
* Correction du 88/10/14 : lorsqu'on a trouvé un
* match, il ne faut surtout pas restaurer D1, D etc.
* mais au contraire les préserver car ce sont eux qui
* donneront la longueur du match.
*
	?A=0	S	retour sans avoir trouvé
	GOYES	ret020
	D1=D1-	10	dépilage sans restauration
	D1=D1-	10
* C(A) = ancienne valeur de D1 (celle qu'il faut renvoyer)
	GONC	ret050	B.E.T.
*
* Fin de la correction du 88/10/14
*
 ret020	D1=D1-	5	D0
	C=DAT1	A
	D0=C

	D1=D1-	5	B
	C=DAT1	A
	B=C	A

	D1=D1-	5	D
	C=DAT1	A
	D=C	A

	D1=D1-	5	D1
	C=DAT1	A
*
* Ce label est un ajout du 88/10/14, faisant pendant
* à ce qui se trouve au dessus de ret020.
*
 ret050
*
* C(A) = valeur de D1 à renvoyer
* D1 = nouveau pointeur de pile réajusté
*
	CD1EX		C(A) := ^ courant réactualisé

	GOSBVL	=CSLC8	C(12-8) := pointeur de pile
	R0=C		restauration du pointeur de pile
	GOSUB	ret090	positionne la Cy
	GOTO	aclret	retour de l'appel "récursif"

 ret090	?A#0	S
	RTNYES		Cy = 1
	RTN		Cy = 0

 call	C=R0		12-8 = ^ courant ; 7-2 = ^ début
	GOSBVL	=CSRC8	C(A) := ^ courant
	CD1EX		D1 := ^ pile ; C(A) := ancien D1
	DAT1=C	5
	D1=D1+	5

	CDEX	A	D
	DAT1=C	A
	D1=D1+	5
	CDEX	A

	CBEX	A	B
	DAT1=C	A
	D1=D1+	5
	CBEX	A

	CD0EX	A	D0
	DAT1=C	A
	D1=D1+	5
	CD0EX	A

	CD1EX		C(A) := ^ courant
	GOSBVL	=CSLC8
	R0=C
	GOTO	amarec

************************************************************
* omatch
*
* But: chercher le motif courant dans la chaîne
* Entree:
*   - D0 = ^ motif courant
*   - D1 = ^ caractère courant, D(A) = nb de car. restant
* Sortie:
*   - Cy = 0 : match not found
*   - Cy = 1 : match found
*   - D0 inchangé
*   - D1 et D(A) actualisés si besoin
* Abime: A(A), C(W)
* Appelle: lookah, rhcteg, TBLJMC, gettab
* Niveaux: 1
* Detail: cf. "Software tools in Pascal"
* Historique:
*   88/06/26: PD/JT conception & codage
*   88/10/07: PD/JT retrait du compte dans R1(A) pour amatch
************************************************************

 omatch	C=DAT0	S	C(S) := motif
	C=C-1	S
	GONC	oma10
*
* Déstructuration complète du code pour gagner le plus de
* cycles possibles
*
 omCHAR
* GOSUBL =lookah
	?D=0	A
	GOYES	rtncc
	A=DAT1	B
* fin de GOSUBL =lookah
	D0=D0+	1
	C=DAT0	B	C(B) := caractère trouvé
	D0=D0-	1
	?A#C	B	A(B) = caractère lu par lookah
	GOYES	rtncc	match not found
* GOSUB =rhcteg	on avance
	D1=D1+	2
	D=D-1	A
* fin de GOSUB =rhcteg
	RTNSC		match found

 oma10	C=C-1	S
	GOC	omEOL
	C=C-1	S
	GOC	omANY
	C=C-1	S
	GOC	omCCL
	C=C-1	S
	GOC	omNCCL
	C=C-1	S
	GOC	omEND
 rtncc	RTNCC		CLOS ou BOL : match not found

 omEND	RTNSC		tout ma[rt]ch !

*
* omBOL : enlève le 88/10/07 car le cas '^' est traité à
* part dans POSADR.
*

 omEOL	GOLONG	=lookah	Cy = match

 omANY	GOSUB	=rhcteg
	GOC	rtncc
	RTNSC		match found
 omCCL
 omNCCL	GOSUBL	=lookah
	GOC	rtncc
	D0=D0+	1
	GOSUB	gettab	D0 := ^ élément
	C=DAT0	S	C(S) := tab [caractère]
	D0=C
	D0=D0-	1	D0 := ^ CCL ou NCCL
	A=DAT0	P	A(0) := CCL ou NCCL
	LC(1)	CCL
	?A=C	P
	GOYES	omCC10
	C=C-1	S	si NCCL : C(S) := not tab [carlu]
 omCC10	?C=0	S
	GOYES	rtncc	no match
	GOSUB	=rhcteg
	RTNSC		match found

************************************************************
* nxtpat
*
* But: positionner D0 sur le motif suivant
* Entree:
*   - D0 := ^ motif courant
* Sortie:
*   - D0 := ^ motif suivant
* Abime: A(A), C(A), D0
* Appelle: -
* Niveaux: 1
* Detail: cf. "Software tools in Pascal", c'est la nouvelle
*   fonction "patsize"
* Historique:
*   88/06/26: PD/JT conception & codage
************************************************************

 nxtpat	A=DAT0	S
	?A#0	S
	GOYES	ps05
	D0=D0+	CHARS
	RTN

 ps05	GOSUB	ps10
	CON(3)	CHARS	inutile
	CON(3)	EOLS
	CON(3)	ANYS
	CON(3)	CCLS
	CON(3)	NCCLS
	CON(3)	0	END
	CON(3)	0	BOL
	CON(3)	CLOSS
 ps10	A=0	A
	A=DAT0	P	A(A) := motif courant
	C=A	A
	A=A+C	A
	A=A+C	A	A(A) := 3*motif
	C=RSTK		C(A) := ^ début de la table
	C=C+A	A
	CD0EX
	A=DAT0	3
	C=A+C	A
	D0=C
	RTN

************************************************************
* rhcteg
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
*   88/06/26: PD/JT conception & pompage (getchr et lookah)
************************************************************

=rhcteg	?D=0	A
	RTNYES
	D=D-1	A
	A=DAT1	B
	D1=D1+	2
	RTN		Cy = 0

************************************************************
* UPDTR0
*
* But: mettre à jour l'adresse du buffer contenue dans
*   R0(7-3) à partir de son ID contenu dans R0(2-0).
* Entree:
*   - R0(2-0) = ID du buffer
* Sortie:
*   - Cy = 1 : erreur
*	- C(3-0) = numéro d'erreur (System Error)
*   - Cy = 0 : pas d'erreur
*	- R0(7-0) = caractéristique complète du buffer
*	- D1 = ^ past buffer header
* Abime: A, C, D1
* Appelle: I/OFND0
* Niveaux: 1
* Historique:
*   88/10/16: PD/JT séparation de POSADR
************************************************************

 sysTem	GOTO	system

=UPDTR0	C=R0		C(X) := buffer id
	GOSBVL	=IOFND0
	GONC	sysTem	"System Error" + Cy = 1
*
* C(X) = ID
* D1 = ^ past buffer header
*
	C=R0		actualisation de R0(7-2)
	GOSBVL	=CSRC3
	CD1EX
	D1=C
	GOSBVL	=CSLC3
	R0=C
	RTNCC		pas d'erreur

************************************************************
* ENDPOS
*
* But: terminer une recherche générique, c'est à dire
*   effacer le buffer.
* Entree:
*   - R0(7-2) = caractéristique du buffer
* Sortie: -
* Abime: A-C, D1, D0
* Appelle: I/ODAL
* Niveaux: 2
* Historique:
*   88/07/02: PD/JT conception & codage
************************************************************

=ENDPOS	C=R0
	GOVLNG	=I/ODAL

	STITLE	Remplacement des lignes

************************************************************
* CALCab
*
* But: calculer les coefficients a et b permettant de
*   connaître la longueur de la chaîne remplacée. La routine
*   REPLIN les utilise.
* Entree:
*   - R3 = motif de remplacement (dans le sens Math Stack)
*   - MODE71 = 1 si mode HP-71, 0 si mode HP-UX
* Sortie:
*   - les zones "coeffa" et "coeffb" sont remplies.
* Abime: A(S), A(A), B(A), C(S), C(A), D(A), D1
* Niveaux: 1 (utilisation de RSTK)
* Note : Le registre R3 se décompose en
*   - R3(9-5) = adresse du prochain caractère à lire
*   - R3(4-0) = nombre de caractères dans la chaîne
* Detail : les coefficients a et b sont respectivement le
*   nombre de caractères constants (normaux) et le nombre de
*   caractères '&' dans la chaîne.
*   Dans ces conditions, si "n" est la longueur de
*   l'occurrence trouvée, f(n) = a + bn est la longueur de
*   la chaîne après remplacement.
* Historique:
*   88/10/08: PD/JT conception
************************************************************

=CALCab	C=R3
	D=C	A	D(A) := longueur du motif
	GOSBVL	=CSRC5	C(A) := ^ premier caractère du motif
	D1=(5)	=MODE71
	C=DAT1	S	C(S) := 0 si mode HP-UX
	D1=C		D1 := ^ premier caractère du motif

	A=0	S	A(S) := pas de "\"
	B=0	A	a := 0 (caractère normal)
	C=0	A	b := 0 (caractère '&')
	RSTK=C

	?C#0	S	mode HP-71 ?
	GOYES	CALC50	oui
*
* Mode HP-UX
*
 CALC10	GOSUBL	=getchr
	GOC	calc99	on est arrivé au bout

	?A#0	S	selon état
	GOYES	CALC25	"\" avant ce caractère
* pas de "\"
	LC(2)	XESC	"\"
	?A=C	B
	GOYES	CALC20	état := 1 ; next one
	LC(2)	XREP	"&"
	?A#C	B
	GOYES	CALC30	caractère normal
* caractère '&' générique
	C=RSTK
	C=C+1	A	b++
	RSTK=C
	GONC	CALC10	next one (B.E.T.)
 CALC20	A=A+1	S	état := 1
	GONC	CALC10	B.E.T.
* Caractère normal
 CALC25	A=0	S	état := 0
 CALC30	B=B+1	A	a++
	GOTO	CALC10

 calc99	GOTO	CALC99

*
* Mode HP-71
*
 CALC50	GOSUBL	=getchr
	GOC	CALC99	on a fini
*
* Automate d'états fini :
* - état = 0 : normal
* - état = 1 : précédent caractère etait un "\"
* - état = 2 : caractères génériques OFF
* - état = 3 : état 2 + précédent caractère était un "\"
*
	LC(2)	STOGL	pour économiser des quartets

	C=A	S	C(S) := état de l'automate
	C=C-1	S
	GOC	CALC60
	C=C-1	S
	GOC	CALC61
	C=C-1	S
	GOC	CALC62
 CALC63	?A=C	B
	GOYES	CAL630
	A=0	S	état := 0
	GOC	CALC70	B.E.T.
 CAL630	A=A-1	S	état := 2
	GONC	CALC70	B.E.T.

 CALC60	?A#C	B
	GOYES	CALC70	a++ (B.E.T.)
	A=A+1	S	état := 1
	GONC	CALC50	B.E.T.
 
 CALC61	?A=C	B
	GOYES	CAL610	"\"
	LC(2)	SREP	"&"
	?A=C	B
	GOYES	CAL615	"&"
	A=A+1	S	état := 2
	GONC	CALC70	a++ (B.E.T.)
 CAL610	A=0	S
	GOC	CALC70	a++ (B.E.T.)
 CAL615	C=RSTK
	C=C+1	A
	RSTK=C
	GONC	CALC50	B.E.T.

 CALC62	?A=C	B
	GOYES	CAL620	"\"
	LC(2)	SREP	"&"
	?A#C	B
	GOYES	CALC70	a++
	GONC	CAL615	spaghetti... mais c'est un B.E.T.
 CAL620	A=A+1	S	état := 3
	GONC	CALC50	B.E.T.

 CALC70	B=B+1	A	a++
	GOTO	CALC50

*
* Etat final
* Stockage des coefficients
*
 CALC99	D1=(5)	=coeffa
	C=B	A
	DAT1=C	A	coeffa := B(A)
	D1=D1+	5	coeffb
	C=RSTK
	DAT1=C	A	coeffb := RSTK
	RTN

************************************************************
* REPLIN
*
* But: remplacer un motif par un autre dans une chaîne ou
*   il y a déjà une occurrence du motif.
* Entree:
*   - R0(7-0) = caractéristique du buffer (chaîne compilee)
*   - (OUTBS..AVMEMS) = chaîne à traiter
*   - AVMEME indique la fin de la mémoire disponible
*   - R3 = motif de remplacement (dans le sens Math Stack)
*   - D0 = ^ occurrence trouvée
*   - C(A) = longueur de l'occurrence
*   - coeffa et coeffb calculés par CALCab
*   - QUERY = 1 si recherche interactive ("?"), 0 sinon
*   - A(A) = numéro de la ligne en cours (si QUERY = 1)
*   - MODE71 = 1 si chaînes génériques HP-71, 0 si HP-UX
* Sortie:
*   - Cy = 0 : ok
*     suivant C(0) :
*	0 : quit sans modification
*	1 : quit avec quelque chose déjà modifié
*	2 : ok sans modification
*	3 : ok avec quelque chose de modifié
*     (OUTBS..AVMEMS) = zone où est stockée la ligne finale
*   - Cy = 1 : erreur
*     C(3-0) = numéro d'erreur
* Abime: A-D, R0(12-8), R1-R2, R3(10), R4(15-11), R4(9-5),
*   D0, D1
* Appelle: query, POSADR
* Niveaux: 4 (POSADR) ou 5 (query)
* Note : Le registre R3 se décompose en
*   - R3(9-5) = adresse du prochain caractère à lire
*   - R3(4-0) = nombre de caractères dans la chaîne
* Algorithme:
*   répéter
*     procéder au remplacement
*     si mode = "?"
*	alors
*	  demander confirmation
*	  selon réponse
*	    Q : sortir avec le code "QUIT"
*	    N : annuler le remplacement
*	    Y :
*	  fin selon
*     fin si
*     rechercher l'occurrence suivante
*   jusqu'à ce qu'il n'y ait plus d'occurrence
* Historique:
*   88/10/08: PD/JT conception
*   88/10/14: PD/JT correction du cas "match nul"
*   88/10/15: PD/JT correction du cas "R/^.//"
************************************************************

 Errmem	LC(4)	=eMEM	Insufficient Memory
 errrtn	RTNSC		Cy = 1 => erreur

=REPLIN
*
* Sauvegarder la valeur de A(A) dans R4(9-5). On utilise R4,
* les temps sont vraiment durs...
*
	GOSBVL	=ASLW5
	R4=A		R4(9-5) = no de la ligne en cours
*
* Mettre à 0 l'indicateur de modifications
*
	A=R3
	P=	10
	A=0	P
	R3=A
	P=	0
*
* Boucle tant qu'il y a des occurrences. En fait, c'est
* une boucle "repeat..until". Voir à ce propos (différences
* entre les boucles WHILE et REPEAT) l'excellent article de
* notre excellent camarade Janick Taillandier dans
* l'excellent JPC 31.
*
 RPL100
*
* Assertions :
* - D0 =  ^ occurrence trouvée dans la chaîne à traiter
* - C(A) = longueur de l'occurrence (en caractères)
* - R0(7-0) = caractéristique du buffer
* - R3 = motif de remplacement (dans le sens Math Stack)
* - R4(9-5) = numéro de la ligne courante (si mode = "?")
*
* Procéder au remplacement :
*
* n = longueur de l'occurrence trouvée (dans RSTK)
* Calcul de f(n) = a + b*n
*
	RSTK=C		RSTK := n (longueur de l'occurrence)
	A=0	W
	A=C	A	A(W) := n
	D1=(5)	=coeffb
	C=0	W
	C=DAT1	A	C(W) := b
	GOSBVL	=MPY	résultat dans A, B et C
	A=0	W	vérification du résultat
	A=C	A
	?A#C	A	<= 1048575 ?
	GOYES	Errmem	non : Not Enough Memory
* A(A) = B(A) = C(A) := b*n
	D1=D1-	5	D1=(5) coeffa
	A=DAT1	A
	A=A+C	A	A(A) := f(n)    (a + b*n)
	GOC	Errmem	Overflow
*
* Assertions :
* - RSTK = n
* - A(A) = f(n)
*
	C=RSTK		C(A) := n
	B=A	A
	B=B-C	A	B(A) := f(n) - n
	GOSBVL	=ASLW5	A(9-5) := f(n)
	A=C	A	A(4-0) := n
	R1=A		R1(9-5) := f(n); R1(A) := n

	D1=(5)	=AVMEMS
	A=DAT1	A	A(A) := AVMEMS
	C=A	A
	C=C+B	A	C(A) := AVMEMS + f(n) - n
	C=C+B	A	C(A) := AVMEMS + 2*(f(n) - n)
	?C>A	A
	GOYES	RPL120
	C=A	A	C(A) := MAX (...)
 RPL120	GOSBVL	=CSLC5	C(9-5) := MAX (...)
	CD0EX		C(A) := D0
	R2=C

*
* Assertions :
*   R1(9-5) = f(n)	(longueur du remplacement)
*   R1(4-0) = n		(longueur de l'occurrence)
*   R2(9-5) = MAX (AVMEMS, AVMEMS + 2*(f(n) - n))
*   R2(4-0) = D0	(début de l'occurrence)
*

*
* Le décalage se produit en plusieurs étapes :
* - copier l'occurrence à l'adresse
*   MAX (AVMEMS, AVMEMS + f(n) - n)
* - copier ce qu'il y a entre la fin de l'occurrence et
*   AVMEMS à l'adresse (début de l'occurrence + f(n))
* - remplacer l'occurrence par le motif
* - mettre à jour AVMEMS
*

*
* Il y a suffisamment de mémoire : on demande 2*f(n) ?
*
	C=R1
	GOSBVL	=CSRC5	C(A) := f(n)
	C=C+C	A	C(A) := 2*f(n)
	P=	1	P#0 pour ne pas avoir de LEEWAY
	GOSBVL	=MEMCKL	Memory Check without LEEWAY
* P=0 en sortie de MEMCKL
	RTNC		Bip ! "Insufficient Memory"

*
* Préparation des paramètres pour MOVE*M :
* - A(A) = source address = D0
* - C(A) = destination address = MAX (AVMEMS, AVMEMS+f(n)-n)
* - B(A) = longueur en nibs = 2*n
*
	C=R1
	B=C	A
	B=B+B	A	B(A) := 2*n
	C=R2
	A=C	A	A(A) := D0
	GOSBVL	=CSRC5	C(A) := MAX (...)
	GOSBVL	=MOVE*M

*
* Préparation des paramètres pour MOVE*M :
* - A(A) = source address = D0 + 2*n
* - C(A) = destination address = D0 + 2*f(n)
* - B(A) = longueur en nibs = AVMEMS - (D0 + 2*n)
*
	C=R1		C(A) := n
	A=R2		A(A) := D0
	C=C+C	A
	A=C+A	A	A(A) := D0 + 2*n

	D0=(5)	=AVMEMS
	C=DAT0	A
	C=C-A	A
	B=C	A	B(A) := AVMEMS - (D0 + 2*n)

	GOSBVL	=CSRC5	C(A) := f(n)
	D=C	A
	C=R2
	C=C+D	A
	C=C+D	A	C(A) := D0 + 2*f(n)
*
* On pourrait peut-être gagner quelques cycles si le
* déplacement avait lieu à la même adresse, mais les
* routines appelées par MOVE*M détectent presque
* immédiatement ce cas. Il n'y a donc pas lieu de
* s'en inquiéter. Nous n'évitons donc pas ce MOVE*M.
* Tant pis pour jt (qui se serait bien passé d'un MOVE).
*
	GOSBVL	=MOVE*M
*
* remplacement de la chaîne à l'adresse D0 par la
* chaîne à l'adresse R3, le motif original étant à
* l'adresse MAX (AVMEMS, AVMEMS + f(n) - n)
*   
	C=R2
	D0=C		D0 := ^ espace à remplir

	D1=(5)	=MODE71	1 si mode HP-71 ou 0 si mode HP-UX
	A=DAT1	S	A(S) := 1 si mode HP-71

	C=R3
	D=C	A	D(A) := nombre de caractères
	GOSBVL	=CSRC5
	D1=C		D1 := ^ premier caractère dans M.S.

	?A#0	S	mode HP-71 ?
	GOYES	RPL300
*
* Mode HP-UX
*
 RPL200
*	A=0	S	A était déjà égal à 0

 RPL290
*
* Le label RPL290 est là pour éviter des GOTO qui branchent
* à des GOTO.
*
 RPL210	GOSUBL	=getchr
	GOC	rpl500

	?A#0	S	précédent caractère = "\"
	GOYES	RPL240
	LC(2)	XESC
	?A=C	B
	GOYES	RPL220
	LC(2)	XREP	"&"
	?A=C	B
	GOYES	RPL270	rplc
	GONC	RPL280	caractère normal (B.E.T.)
 RPL220	A=A+1	S	état := 1
	GONC	RPL290	next one

 RPL240	A=A-1	S	état := 0
	GONC	RPL280	B.E.T.

 RPL270	GOSUB	rplc
	GOTO	RPL290
 RPL280	DAT0=A	B	ajoute un caractère
	D0=D0+	2
	GONC	RPL210	B.E.T.

 rpl500	GOTO	RPL500

*
* Mode HP-71
*
 RPL300	A=0	S

 RPL390
*
* L'étiquette RPL390 est là pour éviter les GOTO qui
* branchent à des GOTO.
*
 RPL310	GOSUBL	=getchr
	GOC	RPL500

	LC(2)	STOGL
	C=A	S	C(S) := état
	C=C-1	S
	GOC	RPL320
	C=C-1	S
	GOC	RPL321
	C=C-1	S
	GOC	RPL322

 RPL323	?A=C	B
	GOYES	RP3230
	A=0	S	état := 0
	GONC	RPL380	ajouter normal (B.E.T.)
 RP3230	A=A-1	S	état := 2
	GONC	RPL380	ajouter normal (B.E.T.)
 
 RPL320	?A#C	B
	GOYES	RPL380	ajouter normal
	A=A+1	S
	GONC	RPL390	B.E.T.

 RPL321	?A=C	B
	GOYES	RP3210	"\"
	LC(2)	SREP	"&"
	?A=C	B
	GOYES	RP3215	"&"
	A=A+1	S	état := 2
	GONC	RPL380	ajoute normal
 RP3210	A=A-1	S	état := 0
	GONC	RPL380	ajoute normal (B.E.T.)
 RP3215	A=A+1	S	état := 2
	GONC	RPL370	rplc (B.E.T.)

 RPL322	?A=C	B
	GOYES	RP3220	"\"
	LC(2)	SREP	"&"
	?A=C	B
	GOYES	RPL370	rplc
	GONC	RPL380	ajoute normal (B.E.T.)
 RP3220	A=A+1	S	état := 3
	GONC	RPL390	B.E.T.

 RPL370	GOSUB	rplc
 rpl390	GOTO	RPL390
 RPL380	DAT0=A	B	ajoute un caractère
	D0=D0+	2
	GONC	rpl390	B.E.T.

 RPL500
*
* Après tout ça, il faut actualiser AVMEMS
*
	C=R1
	A=C	A	A(A) := n
	GOSBVL	=CSRC5	C(A) := f(n)
	C=C-A	A
	C=C+C	A	C(A) := 2*(f(n) - n)
	D1=(5)	=AVMEMS
	A=DAT1	A
	A=A+C	A
	DAT1=A	A	AVMEMS += 2*(f(n) - n)
*
* Faut-il poser une question ?
*
	D1=(5)	=QUERY	mode interactif ("?")
	C=DAT1	S
	?C#0	S	Mode interactif ?
	GOYES	RPL600	oui : on pose la question
	GOTO	RPL800	non : reponse [Y] par défaut
*
* Mode interactif :
*
* Pour poser la question, il faut qu'il y ait une longueur
* LIF en début de la chaîne. Il faut donc mettre
* (AVMEMS-OUTBS) en longueur LIF. AVMEMS a été actualisé,
* entre RPL120 et RPL200.
*
 RPL600	A=0	M
	D0=(5)	=AVMEMS
	A=DAT0	A
	D0=D0- 	(=AVMEMS)-(=OUTBS)
	C=DAT0	A
	D1=C		D1 := ^ début ligne LIF (longueur)
	A=A-C	A	A(A) := longueur en quartets + 4
	ASRB		A(A) := longueur en octets + 2
	A=A-1	A
	A=A-1	A
	GOSBVL	=SWPBYT
	DAT1=A	4	longueur LIF

*
* Poser la question, mais sauver d'abord R1 car "query"
* l'abime.
* La sauvegarde de R1 est faite en poussant R2 et R3 vers la
* gauche.
*
	A=R1
	C=R2
	D=C	A	D(A) := D0 (cf plus bas)
	GOSBVL	=CSLC5
	C=A	A
	R2=C

	GOSBVL	=ASRW5
	C=R3
	GOSBVL	=CSLC5
	C=A	A
	R3=C
*
* Mise en place des paramètres de query
*
	C=0	W
	C=D	A	C(W) := ^ début occurrence
	A=DAT0	A	A(A) := ^ OUTBS
	D0=A		D0 := ^ début ligne
	C=C-A	A	C(A) := delta en nibs + long LIF
	CSRB
	C=C-1	A	C(A) := no colonne (1..max)
	A=R4
	GOSBVL	=ASRW5	A(A) := no ligne
*
* A(A) := no ligne
* C(A) := no colonne
* D0 := ^ début ligne (longueur LIF)
*
	GOSUBL	=query
	D=C	P	D(0) := code de retour de query
*
* Remettre les registres dans l'ordre (restaurer R1)
*
	C=R3
	A=C	A	A(A) := MAX...
	GOSBVL	=CSRC5
	R3=C
	GOSBVL	=ASLW5

	C=R2
	A=C	A	A(A) := D0
	GOSBVL	=CSRC5
	R2=C
	R1=A
*
* Voyons maintenant ce que l'utilisateur a demandé.
*
	C=D	P	C(0) := code de retour de query
	GOSBVL	=TBLJMC
	REL(3)	RPL700	exit
	REL(3)	RPL800	yes
	REL(3)	RPL710	no

 RPL700
*
* Code de retour = 0 ou 1. C'est exactement la valeur
* contenue dans R3(10)
*
	C=R3
	CPEX	10	P := code de retour, C(10) := 0
	CPEX	0	P := ???, C(0) := code de retour
	P=	0	P := 0
	?C=0	P
	GOYES	RPL705	on peut sortir tout de suite
	RSTK=C		RSTK := code de retour
	GOSUB	undo	on remet les choses en place
	C=RSTK		RSTK := code de retour
 RPL705	RTNCC

*
* mode interactif et réponse = [N]
* Il faut donc remettre les choses en place.
*
 RPL710	GOSUB	undo	voilà. Les choses sont remises...
*
* Valeur à ajouter à D0 : +1
*
	C=0	A
	C=C+1	A
	GONC	RPL900	B.E.T.

*
* Deux cas :
*   - mode interactif et réponse = [Y]
*   - mode non interactif (réponse implicite = [Y])
* Il y a donc eû modification. R3(10) := 1
*
 RPL800	C=R3
	P=	10
	LC(1)	1
	P=	0
	R3=C		R3(10) := 1
*
* Mettre dans C(A) le nombre de caractères à ajouter
* à D0 pour continuer d'explorer la ligne.
*
	C=R1		nb de caractères à ajouter à D0
	GOSBVL	=CSRC5	C(A) := f(n) (en caractères)
*
* C(A) := taille du bloc que l'on vient de passer c'est à
* dire la valeur de l'incrément de D0 pour la recherche
* suivante.
*

 RPL900
*
* C(A) = taille du bloc que l'on vient de passer c'est à
* dire la valeur de l'incrément de D0 pour la recherche
* suivante. Attention : la taille du bloc est en
* caractères !
*
* Rechercher maintenant une nouvelle occurrence
*
	A=R2		A(A) := D0
	A=A+C	A
	A=A+C	A	A(A) := nouveau D0
	D0=A		D0 := ^ chaîne à chercher

*
* Vérifier si la nouvelle position de D0 est plausible
* c'est à dire pas derrière AVMEMS)
* Assertions :
* A(A) = D0 = nouvelle position de début de recherche
* Stocker dans R4(15-11) la valeur actuelle de D0 pour
* comparaison après POSADR, et ceci afin de détecter
* deux "null match" de suite.
*
	C=R4
	GOSBVL	=CSLC5
	C=A	A
	GOSBVL	=CSRC5
	R4=C
 RPL920
*
* Est-on arrivé au bout de la chaîne ?
*
	D1=(5)	=AVMEMS
	C=DAT1	A	C(A) := AVMEMS
	?A>C	A
	GOYES	RPL999	oui : Fini !
*
* Cas standard : il reste assez de place pour une
* nouvelle recherche.
*
	D1=D1-	5	D1=(5)	=OUTBS
	C=DAT1	A
	CD1EX		C(A) := ^ OUTBS, D1 := OUTBS
	D1=D1+	4
	CD1EX		A(A) := OUTBS + 4 ; D1=(5) OUTBS
*
* 88/10/15 : correction du bug :
*   GENRPLC$(A$,"^.","")
*   Le vrai début doit être trafiqué, car on ne doit
*   plus trouver de match en début de chaîne. Avant,
*   on trouvait un match à chaque tour sur l'exemple
*   ci-dessus.
*
	C=C-1	A	C'est de l'escroquerie !
	R1=C		R1 := ^ vrai début de la chaîne

	C=0	W
	D1=D1+	5	D1=(5) =AVMEMS
	C=DAT1	A
	C=C-A	A
	CSRB		C(A) := longueur de ce qu'il reste
	A=C	A	A(A) := longueur en caractères

	GOSUBL	=POSADR
*
* Si pas d'occurrence, sortir. La Cy n'a pas été modifiée.
*
	GONC	RPL999	Pas d'occurrence : fini
*
* C(A) = LEN (occurrence trouvée)
* D0 = position de l'occurrence trouvée
*
	?C#0	A
	GOYES	rpl100	ok, on peut remplacer
	CD0EX		D0 := LEN(occurrence), C(A) := D0
*
* Restauration de l'ancien D0 qui était dans R4(15-11).
*
	A=R4
	ASLC
	ASLC
	ASLC
	ASLC
	ASLC		A(A) := ancien D0
	?A=C	A
	GOYES	RPL950	stop ! match nul. 1 partout...
	CD0EX		on remet les choses en place
 rpl100	GOTO	RPL100	et on y va pour le remplacement

*
* Cas spécial : on tombe sur une occurrence de longueur
* nulle derrière une occurrence déjà trouvée. On
* l'ignore donc.
*
 RPL950	A=A+1	A
	A=A+1	A
	D0=A		D0 := A(A) := nouveau D0
	GONC	RPL920	B.E.T.

 RPL999
*
* La valeur de retour est 2 ou 3. C'est R3(10) + 2
*
	C=R3
	CPEX	10	P := code de retour, C(10) := 0
	CPEX	0	P := ???, C(0) := code de retour
	P=	0	P := 0
	C=C+1	P
	C=C+1	P
	RTNCC		Cy := 0 ; C(0) := 2 ou 3

************************************************************
* rplc
*
* But: copie le texte qui a été sauvegardé derrière la
*   chaîne normale à l'endroit pointé par D0.
* Entree:
*   - D0 = destination address
*   - R1(4-0) = longueur du motif original (en octets)
*   - R2(9-5) = source address
* Sortie:
*   - D0 est réactualisé
* Abime: A, B(A), C(A), D(A), D0
* Appelle: MOVE*M, ASRW5, CSRC5, CSLC5
* Niveaux: 2 (MOVE*M)
* Note: D1 est sauvegarde lors de l'appel
* Historique:
*   88/10/08: PD/JT conception & codage
*   88/10/09: PD/JT débogage
************************************************************

 rplc	CD1EX
	GOSBVL	=CSLC5	C(9-5) := D1
*
* Pour MOVE*M
* A(A) = source address
* B(A) = length in nibs
* C(A) = destination address
*
	A=R1
	B=A	A
	B=B+B	A	B(A) := length in nibs
	A=R2
	GOSBVL	=ASRW5	A(A) := source address
	CD0EX		C(A) := destination address
	GOSBVL	=MOVE*M
	C=C+B	A	C(A) := destination + length
	D0=C		D0 est réactualisé
	GOSBVL	=CSRC5	restauration de D1
	D1=C
	RTN

************************************************************
* undo
*
* But: remet le texte comme il était avant la dernière
*   modification.
* Entree:
*   - R1(4-0) = longueur du motif original (en octets)
*   - R1(9-5) = longueur du motif remplacé (en octets)
*   - R2(4-0) = destination
*   - R2(9-5) = source
* Sortie:
*   - AVMEMS est réactualisé
* Abime: A, B(A), C, D(A), D0, D1
* Appelle: MOVE*M, CSRC5, ASRW5
* Niveaux: 2 (MOVE*M)
* Historique:
*   88/10/16: PD/JT conception & codage
************************************************************

 undo	C=R1
	D=C	A	D(A) := n
	D=D+D	A	D(A) := 2*n
	GOSBVL	=CSRC5	C(A) := f(n)
	C=C+C	A	C(A) := 2*f(n)
	A=R2		A(A) := D0
	A=A+C	A	A(A) := D0 + 2*f(n) (source addr)

	D0=(5)	=AVMEMS
	C=DAT0	A	C(A) := AVMEMS
	C=C-A	A	C(A) := AVMEMS - (D0 + 2*f(n))
	B=C	A	B(A) := length of block

	C=R2		C(A) := D0
	C=C+D	A	C(A) := D0 + 2*n
*
* A(A) = source address = D0 + 2*f(n)
* B(A) = length of bloc in nibs = AVMEMS - (D0 + 2*f(n))
* C(A) = dest address = D0 + 2*n
*
	GOSBVL	=MOVE*M

	C=R1
	B=C	A	B(A) := n
	B=B+B	A	B(A) := 2*n

	A=R2
	C=A	A	C(A) := D0

	GOSBVL	=ASRW5	A(A) := MAX...
*
* A(A) = source address = MAX...
* B(A) = length of bloc in nibs = 2*n
* C(A) = dest address = D0
*
	GOSBVL	=MOVE*M

*
* AVMEMS += 2*(n - f(n))
*
	D0=(5)	=AVMEMS
	C=R1
	A=C	A	A(A) := n
	GOSBVL	=CSRC5	C(A) := f(n)
	A=A-C	A	A(A) := n - f(n)
	C=DAT0	A	C(A) := AVMEMS
	C=C+A	A
	C=C+A	A
	DAT0=C	A	AVMEMS += 2*(n - f(n))
	RTN

	END
