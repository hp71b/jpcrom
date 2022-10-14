	title  FINPUT, boucle principale <fboucle.as>

*
* i contient le numero de la ligne en cours (1..n)
*
 i	equ    =CHPCOU	Defini dans def.as (87/12/19)
*
* <861202.2120> : merci HP !
* La variable i etait placee en FUNCR0. Comme la
* documentation d'HP ne l'indique pas, CHEDIT ABIME TOUTE
* LA FUNCTION SCRATCH, ainsi que DEUX QUARTETS DANS LA
* STATEMENT SCRATCH.
* Ceci expliquait un comportement "peu normal" de FINPUT.
*

*
* menu est un flag pour indiquer si tous le display est
* protege.
* Modification du 7 mai 1987 par P.D.
*   menu est mis dans une zone de RAM pour le proteger de
*   CHEDIT en case de retour premature.
*
 menu	equ    =STSAVE

*
* Note : (STSAVE)+1 est occupe par le poll de FINPUT
* (detection de [ENDLINE][ENDLINE])
* 19 decembre 1987
*

*
* Si, si ! Rappelez-vous. R3 contient toujours D0 !
*
* On va maintenant evaluer la variable A (dernier parametre:
* variable numerique). Les elements caracteristiques (pour
* utiliser apres DEST) vont etre places a l'endroit DOPEA.
*
	c=r3		c(a) := PC
	d0=c		d0 := PC
	gosbvl =EXPEXC
	gosbvl =AVE=D1
	d0=(5) =DOPEA

	a=b    w
	dat0=a w
	d0=d0+ 16	DOPEA +	 0 := B(W)    (16 q.)

	cd1ex
	dat0=c a
	d0=d0+ 5	DOPEA + 16 := D1       (5 q.)

	d1=(5) =F-R1-0
	c=dat1 a
	dat0=c a
	d0=d0+ 5	DOPEA + 21 := F-R1-0   (5 q.)

	d1=d1+ 15
	c=dat1 1
	dat0=c 1	DOPEA + 26 := F-R1-3   (1 q.)
*
* Voila, les elements caracteristiques de A sont sauves.
*

*
* Ajout du 87/12/19 (P.D. & J.T.)
* Indicateur (STSAVE)+1 mis a 0 pour initialiser la
* detection de [ENDLINE][ENDLINE]
*
	A=0    S
	D0=(5) =INENDL
	DAT0=A S

*
* Pour que [ATTN] se comporte bien, il faut verifier que
* les elements de M$ ne comportent pas de caracteres non
* affichables (NULL, CR, LF, ESC, BS). Rappelons que
* [ATTN] comparera le contenu du display avec M$(i).
*
	d1=(5) =n
	c=dat1 a

 ver10	r0=c
	gosubl =GETM$I	D0 := ^ longueur M$(i)
	c=0    a
	c=dat0 4
	b=c    a
	c=0    a
	lc(2)  96
	?b>c   a
	goyes  invcar	"Invalid Prompt"
	d0=d0+ 4
	gonc   ver30	B.E.T.

 invcar lc(4)  (=id)~(=eIPRMP)	"Invalid Prompt"
	govlng =BSERR
*
* Boucle interne de verification des caracteres un par un.
*
 ver20	a=dat0 b
	?a=0   b	NULL
	goyes  invcar	"Invalid Prompt"
	lc(2)  27	C(B) := ESC
	?a=c   b
	goyes  invcar	"Invalid Prompt"
	lc(2)  13	C(B) := CR
	?a=c   b
	goyes  invcar	"Invalid Prompt"
	lc(2)  10	C(B) := LF
	?a=c   b
	goyes  invcar	"Invalid Prompt"
	lc(2)  08	C(B) := BS
	?a=c   b
	goyes  invcar	"Invalid Prompt"
	d0=d0+ 2
 ver30	b=b-1  b
	gonc   ver20
*
	c=r0
	c=c-1  a
	?c#0   a
	goyes  ver10
*
* Maintenant, on prepare la boucle principale de SINPUT
*
	d1=(5) i
	c=0    a
	c=c+1  a
	dat1=c a	i := 1 (numero de la ligne courante)


	stitle Corps de la boucle
************************************************************
* BP:, BP-
*
* But: Boucle principale de SINPUT.
* Entree:
*   - BP:
*     - i (FUNCR0) = numero de la ligne courante (0..n-1)
*   - BP:
*     - i (FUNCR0) = numero de la ligne courante (0..n-1)
*     - D0 = ^ dope-vecteuuuuuuur du tableau a afficher
* Sortie:
*   - suivant les touches :
*     [^], [v], [g][^], [g][v] : passage a la ligne suivant
*	 la direction, sans changer la ligne courante.
*     [ENDLINE] : valide la ligne courante. Si l'ecran est
*	 constitue d'une seule ligne, termine SINPUT (comme
*	 (L)INPUT). Dans ce dernier cas, la variable A est
*	 mise a la valeur 1.
*     [RUN] : valide la ligne courante, et termine SINPUT.
*	 La variable A contiendra le numero de cette ligne.
*     [ATTN] :
*	 1: remet la valeur par defaut de la ligne courante.
*	 2: si la ligne courante contient deja la valeur
*	    par defaut, [ATTN] sort de SINPUT, la variable A
*	    est mise a 0. La variable/tableau I$ n'est pas
*	    modifiee par SINPUT.
* Abime: CPU
* Appelle: CHEDIT, DSPCHA, GETx$I, GETFST, CURSFL
* Niveaux: 7 (CHEDIT)
* Note: le point d'entree BP- est utilise par kATTN
* Historique:
*   86/09/03: P.D. & J.T. conception & codage
*   86/11/22: P.D. & J.T. documentation
*   86/11/22: P.D. & J.T. gestion des touches speciales
*   86/11/24: P.D.	  Modification pour ajout de BP-
************************************************************

 BP:
	d0=(5) =DOPED$
 BP-
*
* Mise a zero du masque avant d'envoyer D$(i) a l'affichage.
*
	d1=(5) =DSPMSK
	c=0    w
	dat1=c 16
	d1=d1+ 16
	dat1=c 8
*
* Affichage du tableau D$(i). Les caracteres de D$(i) sont
* ranges en sens inverse, ce qui oblige a utilise une
* boucle speciale.
*
	d1=(5) i
	c=dat1 a
*
* D0 = ^ DOPEx$
*
	gosubl =GETx$I
	c=0    a
	c=dat0 4
	d=c    a       D(A) := LEN(x$(I))
	gosubl =GETFST
	c=d    a       C(A) := LEN(x$(I))
	ad0ex
	goto   anpc10

*
* Invariant de cette boucle :
*   a(a) = pointeur dans x$(I)
*   c(a) = nombre de caracteres restant a afficher
*

*
* ancpsd = rev$("dspcna")
*
 ancpsd rstk=c	       RSTK := LEN(x$(I))
	a=a-1  a
	a=a-1  a
	c=a    a
	rstk=c	       RSTK := ^ x$(I)
	d0=a
	a=dat0 b
	gosbvl =DSPCHA
	c=rstk	       C(A) := ^ x$(I)
	a=c    a
	c=rstk	       C(A) := LEN(x$(I))
 anpc10 c=c-1  a
	gonc   ancpsd
*
* Injection de B$(i) dans DSPMSK :
*
	d=0    s	menu := 0
	d0=(5) i
	c=dat0 a
	gosubl =GETB$I
	d0=d0+ 4
	d1=(5) =DSPMSK
	c=dat0 16
	dat1=c 16

	c=c+1  w
	gonc   inj10
* les 64 premiers caracteres sont tous proteges
	d=d+1  s	menu := 1
 inj10
	d0=d0+ 16
	d1=d1+ 16
	c=dat0 8
	dat1=c 8

	p=     7
	c=c+1  wp
	p=     0
	goc    inj20
* les 32 derniers caracteres ne sont pas proteges
	d=0    s	menu := 0
 inj20
	c=d    s
	d0=(5) menu
	dat0=c s
*
* Curseur a gauche avant l'edition
*
	gosbvl =CURSFL

************************************************************
* edit
*
* But: faire l'edition de la ligne deja affichee.
* Entree:
*   - la ligne est deja affichee.
* Sortie:
*   - par les routines particulieres :
*	deplacement du curseur : kUP, kDOWN, kTOP, kBOT
*	validation et envoi : kENDLN, kRUN
*	sortie : kATTN, kOFF
* Appelle: BP10 ou BP20
* Historique:
*   86/11/23: P.D. & J.T. conception & codage
*   87/05/07: P.D.	  menu en RAM et non dans ST
************************************************************

 edit
	d0=(5) menu
	c=dat0 s
	?c#0   s	tous les car. sont proteges ?
	goyes  BP20	oui : affichage sans introduction
	   *		non : INPUT normal

************************************************************
* BP10
*
* But: realiser l'edition de la ligne deja affichee, et
*   envoyer sur les routines particulieres.
* Entree: -
* Sortie:
*   - par les routines particulieres.
* Abime: A-D, D0, D1, R0, R3, ST, INSINP (flag pour le poll)
*   DEFADR, USRSTA, 32 nibbles at scratch
* Appelle: CHEDIT, FINDA
* Niveaux: 7
* Historique:
*   86/11/23: P.D. & J.T. conception & codage
************************************************************

 BP10
*
* Previent le Poll handler que c'est nous qu'on travaille !
*
	d0=(5) =INSINP
	a=dat0 1
	lc(1)  =INSMSK
	a=a!c  p
	dat0=a 1

*
* Y-a-queq'un ?
*
	gosbvl =CHEDIT

*
* Previent le Poll handler que c'est nous qu'on travaille
* plus !
*
	lc(1)  `=INSMSK	 (Complement a un de =INSMSK)
	csrc
	d0=(5) =INSINP
	a=dat0 s
	a=a&c  s	Carry is not affected
	dat0=a s	A(B) n'est pas modifie
*
* La carry est encore dans l'etat apres CHEDIT :
*   Cy = 1 : touche speciale [ATTN], [^], etc.
*   Cy = 0 : user terminating key
*
	gonc   edit
*
* Et dans A(A) : le code de la touche
*
	gosbvl =FINDA
	con(2) 13
	rel(3) kENDLN
	con(2) 14
	rel(3) kATTN
	con(2) 15
	rel(3) kRUN
	con(2) 18
	rel(3) kUP
	con(2) 19
	rel(3) kDOWN
	con(2) 20
	rel(3) kTOP
	con(2) 21
	rel(3) kBOT
	con(2) 24
	rel(3) kOFF
	nibhex 00
*
* Aucune de celles-ci : on ne reconnait pas, on ignore.
*
	goto   edit

************************************************************
* BP20
*
* But: traiter le cas ou la ligne est entierement protegee.
*   C'est le cas particulier de MENU.
* Entree: -
* Sortie:
*   - par les routines particulieres.
* Abime: A-D, D0, D1, 32 nibbles at scratch
* Appelle: CKSREQ, SCRLLR, POPBUF, FINDA
* Niveaux: 6 (SCRLLR)
* Historique:
*   86/11/23: P.D. & J.T. conception & codage
*   86/11/29: P.D. & J.T. ajout de RPTKY pour la repetition
************************************************************

 BP20
	gosbvl =RPTKY
	goc    BP25	Go if repeated key
 BP12	gosbvl =SCRLLR
	gonc   BP15
	gosbvl =CKSREQ
	goto   BP12
 BP15	gosbvl =POPBUF
 BP25	a=b    a	A(B) := keycode
	gosbvl =FINDA
	con(2) 38
	rel(3) kENDLN
	con(2) 43
	rel(3) kATTN
	con(2) 46
	rel(3) kRUN
	con(2) 50
	rel(3) kUP
	con(2) 51
	rel(3) kDOWN
	con(2) 162
	rel(3) kTOP
	con(2) 163
	rel(3) kBOT
	con(2) 99
	rel(3) kOFF
	nibhex 00
*
* La touche n'est pas reconnue.
*
	goto   edit
	stitle Touches de déplacement [^] [v] [g][^] [g][v]
************************************************************
* kUP, kDOWN, kBOT, kDOWN
*
* But: traiter les touches de deplacement de curseur.
* Entree: -
* Sortie:
*   - par "curs"
*   - la variable i contient le numero de la nouvelle ligne.
* Abime: A-D, D0, D1, ST, i
* Appelle: finlgn, curs
* Niveaux: 5 (finlgn)
* Historique:
*   86/11/23: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
************************************************************

************************************************************
* Touche [v]
************************************************************

 kDOWN	gosub  finlgn
 kDOWN- d1=(5) i
	a=dat1 a
	a=a+1  a
	gonc   curs	B.E.T.

************************************************************
* Touche [^]
************************************************************

 kUP	gosub  finlgn
	d1=(5) i
	a=dat1 a
	a=a-1  a
*
* Le code continue dans "curs"
*

************************************************************
* curs
*
* But: gerer les deplacements dans les differentes lignes
*   d'une entree.
* Entree:
*   - A(A) = nombre de lignes
* Sortie:
*   - par BP: (Boucle Principale)
* Abime: A(A), C(A), D0
* Niveaux: 0
* Historique:
*   86/09/03: P.D. & J.T. conception & codage
*   86/11/22: P.D. & J.T. documentation
************************************************************

 curs	c=0    a
	c=c+1  a
	?c<=a  a
	goyes  curs10
	a=c    a	a(a) := 1
 curs10 d0=(5) =n
	c=dat0 a
	?c>=a  a
	goyes  curs20
	a=c    a
 curs20 dat1=a a
	goto   BP:

************************************************************
* Touche [g][^]
************************************************************

 kTOP	gosub  finlgn
	d1=(5) i
	a=0    a
	a=a+1  a
	gonc   curs20	B.E.T.

************************************************************
* Touche [g][v]
************************************************************

 kBOT	gosub  finlgn
	d1=(5) i
	d0=(5) =n
	a=dat0 a
	goto   curs20

************************************************************
* finlgn
*
* But: terminer physiquement (pour l'affichage) une ligne
*   saisie.
* Entree: -
* Sortie: -
* Abime: A-D, D0, D1, ST, R3
* Appelle: ILFART, CRLFND
* Niveaux: voir la documentation de ILFART
* Detail:
*   La routine systeme FINLIN n'est pas utilisee. Ceci est
*   du a son mode de fonctionnement : FINLIN "deprotege" le
*   dernier caractere (le 96eme) et fait un CURSFR (cursor
*   far right), ce qui a un desagreable effet sur la video.
*   Le curseur balaye les 96 caracteres.
*   Cette routine laisse le dernier caractere intact, l'HPIL
*   ne balayera donc que ce qui est necessaire.
* Historique:
*   86/11/29: P.D. & J.T. conception & codage
*   86/11/29: P.D. & J.T. documentation
************************************************************

 finlgn gosubl =ILFART	Voir le fichier pol.as
	govlng =CRLFOF
	stitle Touches de sortie [ATTN] [OFF]
************************************************************
* kATTN, kOFF
*
* But: traiter les touches de sortie de SINPUT.
* Entree: -
* Sortie:
*   - par EXIT, ou BP-
*   - la variable A contiendra 0
* Appelle: finlgn, BP- ou EXIT
* Historique:
*   86/11/23: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
************************************************************

************************************************************
* Touche [ATTN]
************************************************************

 kATTN	gosub  finlgn
	gosbvl =ATNCLR	C'est magique ! Mais ca evite au
	  *		curseur de se mal retrouver.
*
* if display = M$(i) then EXIT avec 0 ;
* DISP M$(i)
*
	d0=(5) i
	c=dat0 a
	gosubl =GETM$I	C(A) := D0 := ^ LEN(M$(i))
	a=0    a
	a=dat0 4	A(A) := LEN(M$(i))
	b=a    a	B(A) := LEN(M$(i))
	gosubl =GETFST	D0 := ^ M$(i)[1,1]

	c=0    a
	lc(2)  96
	?b<=c  a
	goyes  kATN10
	b=c    a
 kATN10
*
* B(A) = longueur en octets de ce qu'il y a a comparer
*
	d1=(5) =DSPBFS
	goto   kATN30
 kATN20 d0=d0- 2
	a=dat0 b
	c=dat1 b
	d1=d1+ 2
	?c=0   b
	goyes  kATN40	arrive au bout de DSPBUF avant M$(i)
	?c#a   b
	goyes  kATN40	DSPBUF[j,j] # M$(i)[j,j]
 kATN30 b=b-1  a
	gonc   kATN20
	c=dat1 b
	?c=0   b	arrive au bout de M$(i) avant DSPBUF
	goyes  exit
 kATN40
*
* DISP M$(i)
*
	d0=(5) =DOPEM$	on reaffiche M$ sans rien changer
	goto   BP-

************************************************************
* Touche [f][OFF]
************************************************************

 kOFF
	gosub  finlgn

 exit
	a=0    a
	goto   EXIT
	stitle Touches de validation [ENDLINE] [RUN]
************************************************************
* kENDLN, kRUN
*
* But: traiter les touches de validation d'une ligne.
* Entree: -
* Sortie:
*   - par EXIT, ou kDOWN-
*   - la variable A contiendra le numero de la ligne
*     courante pour [RUN] ou [ENDLINE] si une seule ligne.
* Appelle: VALIDE, kDOWN- ou EXIT
* Detail: si il n'y a qu'une seule ligne, SINPUT traite
*   la touche [ENDLINE] comme [RUN].
* Historique:
*   86/11/23: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
************************************************************

************************************************************
* Touche [ENDLINE]
************************************************************

 kENDLN
	gosub  VALIDE
	d0=(5) =n
	c=dat0 a
	c=c-1  a
	?c=0   a
	goyes  kRUN00
	goto   kDOWN-

************************************************************
* Touche [RUN]
************************************************************

 kRUN
	gosub  VALIDE
 kRUN00
*
* Copier le tableau U$ dans le tableau I$.
*
* Algorithme :
* for z:= n downto 1 do
*   begin
*     I$(z) := U$(z) ;
*   end ;
*	  
	d1=(5) =n
	c=dat1 a
*
* for z := n downto 0 do
*
 kRUN10
*
* Assertion :
*   C(A) = z
*
	r0=c

	d0=(5) =DOPEU$	D0 := ^ dope-vecteuuuuur source
	d1=(5) =DOPEI$	D1 := ^ dope-vecteuuuuur destination
	gosubl =ELMCPY

	c=r0
	c=c-1  a
	?c#0   a
	goyes  kRUN10
*
*   end ;
*

*
* Renvoyer le numero de la ligne courante dans la var. A
* et revenir a Basic.
*
	d1=(5) i
	a=dat1 a
	goto   EXIT
	stitle Utilitaires
************************************************************
* VALIDE
*
* But: valider une ligne, c'est a dire copier l'entree de
*   l'utilisateur dans U$(i)
* Entree:
*   - DSPBFS contient l'entree de l'utilisateur
* Sortie:
*   - U$(i) contient les seuls caracteres entres
*   - D$(i) contient le display buffer tel quel
* Abime: 
* Appelle: GETD$I, finlgn, DSP$00, POP1S, GETU$I, D1MSTK
* Niveaux: 
* Detail: 
* Algorithme: 
*   adresse de D$(i)
*   recopier DSPBFS-DSPBFE dans D$(i)
*   finlgn
*   DSP$00
*   enlever le CR de la fin
*   adresse de U$(i)
*   mettre LEN(U$(i)) a jour
*   recopier Math-Stack dans U$(i)
* Historique:
*   86/11/23: P.D. & J.T. conception & codage
************************************************************

 VALIDE
*
* adresse de D$(i)
*
	d0=(5) i
	c=dat0 a
	gosubl =GETD$I
*
* recopier DSPBFS-DSPBFE dans D$(i)
*
	d1=(5) (=DSPBFE)-2
	c=0    a
	lc(2)  96	Nb de boucles
	gonc   vld020	B.E.T.
*
* boucle pour determiner la longueur de D$(i)
*
 vld010 a=dat1 b
	?a#0   b
	goyes  vld030	sortie des qu'un caractere est
	d1=d1- 2	trouve
 vld020 c=c-1  b
	gonc   vld010
 vld030 c=c+1  b
*
* C(A) = longueur en octets de la chaine lue dans DSPBUF
*
	dat0=c 4	LEN(D$(i)) := C(B)
	d0=d0+ 4
	gonc   vld050
*
* boucle de recopie
*
 vld040 a=dat1 b
	dat0=a b
	d1=d1- 2
	d0=d0+ 2
 vld050 c=c-1  b
	gonc   vld040
*
* finlgn ; DSP$00
*
	gosub  finlgn
	gosbvl =D1MSTK
	ST=1   0	Pour retour apres DSP$00
	gosbvl =DSP$00
	gosbvl =POP1S
*
* Enlever le CR de la fin
*
	d1=d1+ 2
	a=a-1  a
	a=a-1  a	LEN(DSPBFS) := LEN(DSPBFS)-1 (octet)
	r0=a		sauver la longueur dans R0

	d0=(5) (=DOPEI$)+9 D0 := ^ lg max des elements de I$
	c=0    a
	c=dat0 4
	c=c+c  a	C(A) := LEN(DISP$) en quartets
	?a>c   a
	goyes  strovf
*
* adresse de U$(i)
*
	d0=(5) i
	c=dat0 a
	gosubl =GETU$I	D0 := ^ LEN(U$(i))
*
* mettre LEN(U$(i)) a jour
*
	c=r0		 restaurer la longueur de la chaine
	a=0    m
	a=c    a	 A(5) := 0
	asrb		 A(A) := A(B) := longueur en octets
	dat0=a 4
	d0=d0+ 4
*
* recopier Math-Stack dans U$(i)
*
* recapitulatif :
*   D0 = start of dest
*   D1 = start of source
*   A(A) = longueur en octets
*
	ad0ex
	ad1ex
	acex   a
	cd0ex
	c=c+c  a
*
* D0 = start of source
* D1 = start of dest
* C(A) = longueur en quartets
*
	govlng =MOVEU3

 strovf
	lc(2)  =eSTROV
	govlng =MFERR

************************************************************
* EXIT
*
* But: stocker la valeur de retour dans la variable A, et
*   revenir a Basic par NXTSTM.
* Entree:
*   - A(A) = valeur a renvoyer (en hexa)
*   - DOPEA = informations sauves lors de l'evaluation de A
*   - AVMEME = sauvegarde du pointeur de Math-Stack sauve
*	lors de l'evaluation de A.
* Sortie:
*   - par NXTSTM
* Abime: ouh la la !
* Appelle: DEST, STORE, NXTSTM, HDFLT, AVE=D1, ATNCLR,NOSCRL
* Niveaux: 6 (STORE)
* Historique:
*   86/11/22: P.D. & J.T. conception & codage
*   86/11/24: P.D.	  ajout de documentation
************************************************************

 EXIT
*
* Lors de l'evaluation de A, on avait sauvegarde ses
* elements caracteristiques dans DOPEA. Il est maintenant
* temps d'aller les rechercher, pour utiliser la sequence
* DEST, STORE etc. cf IDS I, page 13-13
*
	d0=(5) (=DOPEA)+26   Variable A
	d1=(5) =F-R1-3
	c=dat0 1
	dat1=c 1

	d0=d0- 5
	d1=d1- 15
	c=dat0 a
	dat1=c a

	d0=d0- 5
	c=dat0 a
	d1=c

	d0=d0- 16
	c=dat0 w
	b=c    w
*
* Maintenant que tout est restaure, on reprend la sequence
* habituelle de stockage dans une variable. cf IDS I.
*
	gosbvl =DEST	N'abime pas A(A)
	gosbvl =D1MSTK
*
* TRACE OFF
*
	d0=(5) =S-R1-2
	c=0    a
	dat0=c a

	gosbvl =HDFLT	A(W) := i en sortie (12 digits form)
	sethex
	d1=d1- 16
	dat1=a w	Math-Stack := A(W)
	gosbvl =AVE=D1
	gosbvl =STORE	variable A := i en sortie
*
* C'est fini !
*
	gosbvl =ATNCLR	On n'a jamais appuye sur [ATTN]
	gosbvl =NOSCRL	Le curseur est disponible
	govlng =NXTSTM	Au revoir...
*
*   O U F !!!!!
*
	end
