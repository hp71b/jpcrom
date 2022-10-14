	TITLE  DATELEX <date.as>
*
* Première version :
*   Laurent Istria
*   Parue dans JPC 28, Octobre 1985
*   Création du Lex
*   Mots-clefs DDAYS, DMY, DOW$, DOW, et MDY
*   JPC:A01 à JPC:A05
* Deuxième version :
*   François Legrand
*   Parue dans JPC 35, Avril 1986
*   Ajout de DATE+
*   Retrait des commentaires
* Troisième version :
*   Janick Taillandier & Pierre David
*   16 au 18 Avril 1987
*   Reconception complète du Lex
*   Suppression du conflit  de DATE+ par renommage
*     en DATEADD
*   Vérification de la date  corrigée (117.041987)
*   Changement de la signification du  flag flDATE
*     (1 = DMY, 0 = MDY)
*   Ecriture des commentaires
*   Création de la table de messages pour DOW$
*   Ajout du type de paramètre alphanumérique
*     pour les dates ("aaaa/mm/jj"  ou "aa/mm/jj")
*   Ajout de  la fonction de  conversion  DATESTR$
*   DOW et DOW$ peuvent	 ne pas avoir de paramètre
*   Amélioration de  la	 vérification  des  dates,
*     et correction  de	 jj.991582,  jj.00aaaa, et
*     mm.00aaaa)
*   JPC:A06
*   Flag -53 alloué par HP
* Quatrième version (JPC:C03)
*    Laurent Istria
*    29 février années bissextiles aaax quand
*      x n'est pas multiple de 4 (0, 4 ou 8) ->
*      Invalid Arg
*

=flDATE EQU    -53	Flag système pour la date
 sDMY	EQU    0	Flag temporaire
 sDOW$	EQU    1	1 si DOW$, 0 si DOW

	STITLE Utilitaires

**************************************************
* getdat
*
* But: obtenir une date sous un format utilisable
*   à partir d'un objet sur la Math Stack
* Entrée:
*  - D1 = ^ M.S.
* Sortie:
*  - A, B et C = numéro du jour depuis le jour 0
*  - D1 reactualise
*  - ST(sDMY) = 1 si mode DMY, 0 si mode MDY
* Abime: A-D, R0, R1, FUNCD1, ST(0), ST(8)
* Niveaux: 3
* Appelle: POP1R, POP1S, conv2, chk/, verdat
* Algorithme:
*
*   DECODAGE :
*
*   si type numérique
*     alors
*	x := IP(arg) ;
*	y := IP(FP(arg)*100) ;
*	A := IP(FP(arg*100)*10000) ;
*	si DMY
*	  alors
*	    D := x ;
*	    B := y ;
*	  sinon
*	    D := y ;
*	    B := x ;
*	fin si ;
*     sinon	 (type alphanumérique)
*	p := 3 ;
*	si arg$(p)="/"
*	  alors
*	    x := arg$(1,2) ;
*	    si x < 60
*	      alors A := 2000 + x ;
*	      sinon A := 1900 + x ;
*	    fin si ;
*	  sinon
*	    p := 5 ;
*	    A := arg$(1,4) ;
*	fin si ;
*	si arg$(p) # "/" alors erreur ; fin si ;
*	B := arg$(p+1,p+2) ;
*	p := p+3 ;
*	si arg$(p) # "/" alors erreur ; fin si ;
*	D := arg$(p+1,p+2) ;
*	si il reste des caractères alors erreur ;
*   fin si ;
*
*   VERIFICATION :
*
*     voir verdat
*
* Modifications:
*   Ajout du paramètre alphanumérique
*   Essayez 117.041987 avec l'ancienne version !
*   Séparation du décodage et de la vérification
*   Ajout des commentaires
* Historique: 
*   85/10/  : L.I.
*   87/04/16: J.T. & P.D. reconception & recodage
**************************************************

 getdat
*
* Lecture de flDATE pour avoir le mode DMY ou MDY
*
	LC(2)  =flDATE	C(B) = flag number
	GOSBVL =SFLAG?
*
* En sortie de SFLAG?
*   Cy = flag testé (1 si DMY, 0 si MDY)
*   HEX mode
*   P=0
*
	ST=1   sDMY	Mode DMY par défaut
	GOC    getd10	DMY, on ne change rien
	ST=0   sDMY	pour les ricains !
 getd10
*
* Test du type
*
	A=DAT1 S	Signature de l'élément
	A=A+1  S	Chaîne = F ==> Cy := 1
	GOC    getstr
 getnum
	GOSBVL =POP1R
	D1=D1+ 16	On passe le réel
*
* En sortie de POP1R :
*   A = 12 digits form
*   DEC mode
*
	P=     0	Après POP1R, P = ?
	SETHEX
*
* Test du signe
*
	?A#0   S	signe différent de "+"
	GOYES  Ivarg
*
* Test de l'exposant du nombre lu. Il doit valoir
* 0 ou 1. Le registre A a donc la forme suivante :
* (exemple dans le cas DMY)
*
* A(W) = 0jmmaaaa.....000
* A(W) = 0jjmmaaaa....001
*
	C=0    X
	?A=C   X
	GOYES  getn20
	C=C+1  X
	?A#C   X
	GOYES  Ivarg
	ASL    W
*
* On a dans A :
* A(W) = jjmmaaaa........  ou encore
* A(W) = mmjjaaaa........  si MDY
*
 getn20
	ASLC
	ASLC
	C=A    B	  C(B) := jj (si DMY)
* A(W) = mmaaaa........jj  si DMY
* A(W) = jjaaaa........mm  si MDY
	ASLC
	ASLC
*
* Si DMY
*   A(B) = mm
*   C(B) = jj
* Si MDY
*   A(B) = jj
*   C(B) = mm
* dans tous les cas, A(W) = aaaa........yyxx
*

*
* Si MDY alors ACEX B
*
	?ST=1  sDMY
	GOYES  getn30
	ACEX   B
 getn30
*
* quelque soit le mode, on a maintenant :
* A(B) = mm
* C(B) = jj
*
	D=C    B	D(B) := jj
	B=A    B	B(B) := mm
*
* Reste à isoler la date dans A(A) :
*
	A=0    A
	ASLC
	ASLC
	ASLC
	ASLC		A(A) := 0aaaa
*
* Nous avons donc maintenant :
*   A(A) = 0aaaa
*   B(B) = mm
*   D(B) = jj
*
	GOTO   verdat

 Ivarg	GOTO   ivarg

 getstr
	GOSBVL =POP1S
	CD1EX
	C=C+A  A	C(A) := ^ item suivant
	D1=(5) =FUNCD1	Sauvegarde de D1
	DAT1=C A
	D1=C		D1 := ^ debut de la chaîne
	P=     5
	A=0    P
	P=     0
	ASRB		A(A) := longueur en octets
	C=0    A
	ST=1   8	8 caractères pour la date
	LC(1)  8
	?A=C   A
	GOYES  gets10
	ST=0   8	10 caractères pour la date
	LC(1)  10
	?A#C   A
	GOYES  Ivarg
 gets10
	GOSUB  conv2	convertit 2 caractères
* C(B) = l'année (ou le siecle)
	?ST=1  8
	GOYES  gets20
*
* L'année est sur 4 chiffres, il faut lire les
* deux derniers.
*
	A=0    W
	A=C    B
	ASL    A
	ASL    A
	R0=A		R0 := 0000000000000aa00
	GOSUB  conv2
	A=R0
	A=C    B	A(W) := 0000000000000aaaa
	GOTO   gets50
*
* L'année est sur 2 chiffres.
*   si <60 alors 20aa
*	   sinon 19aa
*
 gets20
	A=0    W
	A=C    B
	C=0    A
	LCHEX  60
	?A<C   B
	GOYES  gets30
	LCHEX  19
	GONC   gets40
 gets30 LCHEX  20
 gets40 CSL    A
	CSL    A
	A=A+C  A	A(W) := 000000000000aaaa
 gets50 R0=A
	GOSUB  chk/
	GOSUB  conv2	C(B) := mm
	R1=C
	GOSUB  chk/
	GOSUB  conv2
	D=C    B	D(B) := jj
*
* restauration de D1
*
	D1=(5) =FUNCD1
	C=DAT1 A
	D1=C
*
* restauration du mois et de l'année
*
	C=R1		C(B) := mm
	B=C    B	B(B) := mm
	A=R0		A(A) := 0aaaa
*
* Attention. Le code continue !!!
*

**************************************************
* verdat
*
* But: vérifier la validité d'une date
* Entrée:
*  - A(A) = 0aaaa
*  - B(B) = mm
*  - D(B) = jj
* Sortie:
*  - A, B et C = numéro du jour depuis le jour 0
*  - HEX
*  - P=0
* Abime: A-D
* Niveaux: 2
* Appelle: YMDDAY
* Algorithme:
*   erreur si j=0 ;
*   erreur si m=0 ;
*   erreur si a<1582 ;
*   erreur si m>12 ;
*   si a>1582
*     alors
*	si m#2
*	  alors
*	    jmax := dernier jour du mois ;
*	    erreur si j>jmax ;
*	    (date valide)
*	  sinon
*	    erreur si j>29 ;
*	    si j=29
*	      alors
*		erreur si a non divisible par 4 ;
*		si a divisible par 100
*		  alors
*		    erreur si non divis. par 400;
*		fin si ;
*	    fin si ;
*	fin si ;
*     sinon (année = 1582)
*	erreur si m<10 ;
*	erreur si m=10 et j<15 ;
*	jmax := dernier jour du mois ;
*	erreur si j>jmax ;
*	(date valide)
*   fin si ;
* Modifications:
*   séparation logique du reste du sous programme
*   éclaircissement de l'algorithme
*   tests corrects pour 01.991582 (DMY)
*   tests corrects pour j = 0 ou m = 0
* Historique: 
*   87/04/18: J.T. & P.D. conception & codage
*   88/04/16: J.T. & P.D. & L.I. 29.021996
**************************************************

 verdat
*
* erreur si mois = 0 ;
*
	?B=0   B
	GOYES  erreur
*
* erreur si jour = 0 ;
*
	?D=0   B
	GOYES  erreur
*
* erreur si mois > 12 ;
*
	LCHEX  12
	?B>C   B
	GOYES  erreur
*
* erreur si année < 1582 ;
*
	LCHEX  01582
	?A<C   A
	GOYES  erreur
*
* si année > 1582
*
	?A=C   A
	GOYES  verd50	année = 1582
*
*   alors
*     si mois # 2
*	alors vérification normale
*
	LCHEX  02	Fevrier
	?C#B   B
	GOYES  verd71	mois normal
*
*	sinon (mois = fevrier)
*	  erreur si jour > 29 ;
*
	LCHEX  29
	?D>C   B
	GOYES  erreur
*
*	  si jour # 29
*	    alors ok
*
	?D=C   B
	GOYES  verd19
	GOTO   verd99	Ok, jour dans [1..28]
 verd71	GOTO   verd70
 verd19
*
*	    sinon
*	      erreur si a non divisible par 4 ;
*

*
* Le segment de code suivant était faux. On testait
* la divisibilité de aaaa (en BCD) par des décalages
* on ne testait donc que la divisibilité du chiffre
* de poids faible.
* Maintenant, on traduit de BCD en Hexa pour faire
* ces décalages
* Bug reporté par Laurent Istria
*

*
* Pb : traduire a4a3a2a1 en hexa et tester la
* divisibilité par 4 avec un seul registre.
* Assertion 1 : a4a3 est inutile
* Assertion 2 :
* ((((a2+a2)mod 16+a2)mod..mod 16+a1)mod 16)mod 4 =
*     (10a2 + a1) mod 4
* On peut donc tout calculer sur un seul quartet
* pour tester la divisibilité par 4.
* Cette assertion a été vérifiée par le programme
* Basic suivant :
* 110 FOR A2=0 TO 9
* 120   FOR A1=0 TO 9
* 130     R1=0
* 140     FOR I=1 TO 10
* 150       R1=MOD(R1+A2,16)
* 160     NEXT I
* 170     R1=MOD(R1+A1,16)
* 180     R1=MOD(R1,4)		! redondant...
* 190	  R2=MOD(10*A2+A1,4)
* 200     IF R1#R2 THEN BEEP
* 210   NEXT A1
* 220 NEXT A2
*
	ASRC		A(0) := a2
	C=A    P	1
	C=C+A  P	2
	C=C+A  P	3
	C=C+A  P	4
	C=C+A  P	5
	C=C+A  P	6
	C=C+A  P	7
	C=C+A  P	8
	C=C+A  P	9
	C=C+A  P	10
	ASLC		A(0) := a1, A(A) = 0aaaa
	C=C+A  P	C(P) := (10a2 + a1) mod 16

	SB=0
	CSRB
	CSRB
	?SB=0
	GOYES  verd20
 erreur GOTO   ivarg
*
*	      erreur si a non divisible par 400 ;
*
 verd20
	?A#0   B
	GOYES  verd99	Ok, non divisible par 100

	C=A    A
	CSR    A
	CSR    A	C(B) := siècle
	SB=0		inutile ?
	CSRB
	CSRB
	?SB=0
	GOYES  verd99	Ok, divisible par 400
	GONC   erreur	B.E.T.
*
*	  fin si ;
*
 verd50
*
* (année 1582)
*     erreur si mois < octobre
*
	LCHEX 10	Octobre
	?B<C  B
	GOYES erreur
*
*     erreur si mois = 10 et jour < 15 ;
*
	?B#C  B
	GOYES verd70	mois normal
	LCHEX 15
	?D<C  B
	GOYES erreur
*
* Attention ! le code continue !
*

*
* (mois normal)
*
 verd70
*
* jmax := dernier jour du mois
*
	C=B    B
	R0=C		Sauvegarde du mois
	LCHEX  07
	?B<=C  B
	GOYES  verd80
	SETDEC
	B=B+1  B
	SETHEX
 verd80
	LCHEX  01
	B=B&C  B	B := bit de poids faible
	LCHEX  30
	C=C+B  B	C(B) := jmax
*
* erreur si jour > jmax ;
*
	?D>C   B
	GOYES  erreur
	C=R0		sauvegarde du mois
	B=C    B

 verd99
*
* Ok, c'est bon
*
	C=A    A
	A=0    W
	A=C    A
	C=B    B
	B=0    W
	B=C    B
	C=D    B
	D=0    W
	D=C    B
	GOVLNG =YMDDAY

**************************************************
* conv2
*
* But: convertir deux caractères en deux chiffres
*   BCD.
* Entrée:
*  - D1 = ^ M.S.
* Sortie:
*  - C(B) = valeur lue et convertie
*  - D1 actualise
* Abime: A, B(B), C
* Niveaux: 2
* Appelle: conv1, DRANGE
* Historique: 
*   87/04/17: J.T. & P.D. conception & codage
**************************************************

 conv2
	GOSUB  conv1	poids fort
	B=A    B
	GOSUB  conv1
	C=B    B
	CSL    B
	C=A+C  B
	RTN

 conv1	D1=D1- 2
	A=DAT1 B
	GOSBVL =DRANGE
	GOC    ivarg	byte not in range
	LCASC  '0'
	A=A-C  B	A(B) = 0d  (d = 1..9)
	RTN

**************************************************
* chk/
*
* But: vérifier que le caractère courant est bien
*   un slash.
* Entrée:
*  - D1 = ^ M.S.
* Sortie:
*  - si le caractère était bien un "/", D1 est
*    réactualisé
*  - sinon erreur
* Abime: A(B), C(B)
* Niveaux: 0
* Historique: 
*   87/04/17: J.T. & P.D. conception & codage
**************************************************

 chk/
	D1=D1- 2
	A=DAT1 B
	LCASC  '/'
	?A=C   B
	RTNYES
 ivarg	GOVLNG =ARGERR

**************************************************
* send2
*
* But: fonction inverse de conv2 : envoie 2
*   chiffres BCD sur la M.S. en ASCII
* Entrée:
*   - D1 = ^ M.S.
*   - D(A) = AVMEMS
*   - A(B) = les deux chiffres en BCD
* Sortie:
*   - D1 reactualise
* Abime: C(B)
* Niveaux: 2
* Appelle: STKCHR
* Historique:
*   87/04/17: J.T. & P.D. conception & codage
**************************************************

 send2
	ASRC
	GOSUB  send1
	ASLC
 send1
	LCASC  '0'
	C=A    P
 stkchr GOVLNG =STKCHR

	STITLE Les mots-clefs

**************************************************
* DATESTR$
*
* But: renvoyer la date alphanumérique au format
*   HP71 ("aaaa/mm/jj") à partir de la date au
*   format numérique jj.mmaaaa ou mm.jjaaaaa
* Note: La date renvoyée par DATE$ est de la forme
*   "aa/mm/jj". La date renvoyée par DATESTR$ est
*   de la forme "aaaa/mm/jj". DATESTR$(DATE$)
*   convertit donc une date "aa" en date "aaaa".
* Syntaxe: DATESTR$ ( <date> )
* Historique:
*   87/04/17: P.D. & J.T. conception & codage
**************************************************

	CON(1) 8+4	alpha ou num   1er  param.
	NIBHEX 11	2 paramètres obligatoires
=DATESe
	GOSUB  getdat
*
* A, B, C = date au format interne
*
	GOSBVL =DAYYMD
	SETHEX
	P=     0
*
* A(3-0) = aaaa
* B(B) = mm
* D(B) = jj
*
	R0=A		R0 := année
	C=B    B
	R2=C		R2 := mois
	C=D    B
	R3=C		R3 := jour

	GOSBVL =D=AVMS	ne modifie pas A(W)
	R1=C		R1 := ^ bottom of M.S.

	ASR    A
	ASR    A	A(B) := siecle
	GOSUB  send2
	A=R0		A(B) := année
	GOSUB  send2
	LCASC  '/'
	GOSUB  stkchr
	A=R2		A(B) := mois
	GOSUB  send2
	LCASC  '/'
	GOSUB  stkchr
	A=R3		A(B) := jour
	GOSUB  send2
	ST=0   0	No return desired
	GOVLNG =ADHEAD

**************************************************
* DATEADD
*
* But: renvoyer la date correspondant à : date + n
* Syntaxe: DATEADD ( <date> , <n> )
* Modifications:
*   Ajout du paramètre de type alpha
*   Ajout des commentaires
*   Clarification du code
*   Extension des dates jusqu'au 31/12/9999
* Historique:
*   86/03/  : F.D.
*   87/04/17: P.D. & J.T. reconception & recodage
**************************************************

	CON(1) 8	num	       2eme param.
	CON(1) 8+4	alpha ou num   1er  param.
	NIBHEX 22	2 paramètres obligatoires
=DATEAe
	GOSBVL =RNDAHX
*
* Ce n'est pourtant pas si dur d'utiliser les
* registres dans leur totalité.
*
	C=0    W
	C=A    A
	GOC    DTAD10
*
* Paramètre négatif
*
	C=-C   A
	C=-C   W	paramètre negatif sur 16 q.
 DTAD10
	D1=D1+ 16
	R3=C		R3 := n
	GOSUB  getdat
	C=R3
	C=A+C  W	C(W) := date + n
*
* Attention ! le code continue
*

**************************************************
* rtndat
*
* But: convertir une date en format interne (nb de
*   jours depuis le 1er janvier 0) en réel au
*   format jj.mmaaaa (ou mm.jjaaaa), et retourner
*   à Basic.
* Entrée:
*  - C(W) = date au format interne
*  - ST(sDMY) indique le format (DMY ou MDY)
* Sortie: par FNRTN1
* Appelle: DAYYMD
* Historique:
*   87/04/17: P.D. & J.T. conception & codage
**************************************************

 rtndat
	GOSBVL =DAYYMD
*
* A = aaaa
* B = mm
* D = jj
*
	?ST=1  sDMY
	GOYES  DTAD20
	C=B    B	C := mm
	DCEX   B	D := mm ; C := jj
	B=C    B	B := jj
 DTAD20
*
* Le nombre que l'on devra retourner doit être de
* la forme :
*   0ddbbaaaa0000001  ou
*   0dbbaaaa00000000  si dd<10
* (dd = D(B), bb = B(B), aaaa = A(3-0))
*
	C=A    A
	A=0    W
	P=     4
	A=C    WP
	P=     0
*
* A(W) = 000000000000aaaa
*
	ASRC
	ASRC
	ASRC
	ASRC
*
* A(W) = aaaa000000000000
*
	A=B    B
	ASRC
	ASRC
*
* A(W) = bbaaaa0000000000
*
	LCHEX  10
	DCEX   B	D := 10 ; C(B) := dd
	A=C    B	A(W) := bbaaaa00000000dd
	?C<D   B	dd < 10
	GOYES  rtnd10	un seul shift, Cy := 1
* deux shifts, Cy := 0
	ASRC
 rtnd10 ASRC
	ASR    W
*
* A(W) = 0dbbaaaa00000000
* A(W) = 0ddbbaaaa0000000
*
	GOC    rtnd20
	A=A+1  X
 rtnd20 C=A    W
	GOTO   fnrtn1

**************************************************
* DDDAYS
*
* But: renvoyer date1-date2
* Syntaxe: DDAYS ( <date1> , <date2> )
* Modifications:
*   Ajout des paramètres de type alpha
*   Ajout des commentaires
* Historique:
*   85/10/  : L.I.
*   87/04/17: P.D. & J.T. reconception & recodage
**************************************************

	CON(1) 8+4	alpha ou num
	CON(1) 8+4	alpha ou num
	NIBHEX 22	2 paramètres obligatoires
=DDAYSe
	GOSUB  getdat
	R3=A		R3 := date2
	GOSUB  getdat
	C=R3
*
* A(W) = date1
* C(W) = date2
*
	D=0    S	signe := "+"
	?A>=C  W	date1 >= date2
	GOYES  DDAY10	oui : ok
* signe "-"
	ACEX   W	non : on échange
	SETDEC
	D=-D-1 S	et signe := "-"
	SETHEX
 DDAY10
	C=A-C  W	C(W) := date1 - date2
	GOSBVL =HXDCW	full word hex-dec conv.
	GOSBVL =FLOAT
*
* A(W) = résultat, mode = DEC
*
	C=A    W
	C=D    S	C(S) := signe
	GOTO   fnrtn1

**************************************************
* DOW$
*
* But: renvoyer le nom du jour
* Syntaxe: DOW$ ( [ <date> ] )
* Modifications:
*   Ajout du paramètre de type alpha
*   Paramètre optionnel = date d'aujourd'hui
*   Ajout des commentaires
*   Nom des jours en messages
* Historique:
*   85/10/  : L.I.
*   87/04/17: P.D. & J.T. reconception & recodage
**************************************************

	CON(1) 8+4	alpha ou num
	NIBHEX 01	1 paramètre optionnel
=DOW$e
	ST=1   sDOW$
	GOTO   DOW00

**************************************************
* DOW
*
* But: renvoyer le numéro du jour
* Syntaxe: DOW ( [ <date> ] )
* Modifications:
*   Ajout du paramètre de type alpha
*   Parametre optionnel = date d'aujourd'hui
*   Ajout des commentaires
* Historique:
*   85/10/  : L.I.
*   87/04/17: P.D. & J.T. reconception & recodage
**************************************************

	CON(1) 8+4	alpha ou num
	NIBHEX 01	1 paramètre optionnel
=DOWe
	ST=0   sDOW$
 DOW00
*
* Algorithme :
* si nb paramètre = 1
*   alors décoder la date
*   sinon obtenir la date d'aujourd'hui
* fin si ;
* jour := (date - 1) mod 7
*
	?C#0   S
	GOYES  DOW10
*
* Sauvegarde temporaire de D0 et D1
*
	CD1EX
	RSTK=C
	CD0EX
	RSTK=C
	CSTEX
	R3=C

	GOSBVL =CMPT	C = R1 := current time
*
* Restauration de D0 et D1 après le monstre CMPT
*
	C=R3
	CSTEX
	C=RSTK
	D0=C
	C=RSTK
	D1=C
*
* Et on reprend le cours de nos investigations...
*
	C=R1
	CSR    W
	CSR    W
	CSRB		C / 512 (in seconds)
	GOSBVL =TODT	A = day number
	P=     0
	GOTO   DOW20
 DOW10
	GOSUB  getdat
 DOW20
	A=A-1  W
	C=0    W
	LC(1)  7
	GOSBVL =IDIV	C := a-1 mod 7
	P=     0
*
* C(0) = numéro du jour (0:dimanche ... 6:samedi)
*
	?ST=1  sDOW$
	GOYES  DOW30
*
* Sortie numérique
*
	CSRC
	CSRC		C(14) := a-1 mod 7
 fnrtn1 GOVLNG =FNRTN1
*
* Sortie alphanumérique
*
 DOW30
	A=C    A	A(A) := numéro du jour
	LC(5)  (=id)~(=eSUN)
	C=C+A  A	C(A) := numéro du message
	R0=C
*
* Pompé dans les IDS I, page 17-60, d'apres MSG$
*
	GOSBVL =R3=D10	Sauver D1 et D0
	GOSBVL =FPOLL
	CON(2) =pTRANS
	GOSBVL =D0=AVS	D0 := (AVMEMS)
	C=R0
	GOSBVL =TBMSG$
	GOVLNG =ERRM$f	Et c'est supporté !!!
*
* Fin du pompage...
*

**************************************************
* DMY
*
* But: passer en mode jj.mmaaaa
* Syntaxe: DMY
* Modifications:
*   Utilisation de routines supportées
* Historique:
*   85/10/  : L.I.
*   87/04/17: P.D. & J.T. reconception & recodage
**************************************************

	REL(5) =DMYd
	REL(5) =DMYp
=DMYe
	LC(2)  =flDATE
	GOSBVL =SFLAGS	Set system flag
	GONC   nxtstm	B.E.T.

**************************************************
* MDY
*
* But: passer en mode mm.jjaaaa
* Syntaxe: MDY
* Modifications:
*   Utilisation de routines supportées
* Historique:
*   85/10/  : L.I.
*   87/04/17: P.D. & J.T. reconception & recodage
**************************************************

	REL(5) =MDYd
	REL(5) =MDYp
=MDYe
	LC(2)  =flDATE
	GOSBVL =SFLAGC	Clear system flag
 nxtstm GOVLNG =NXTSTM

	END
