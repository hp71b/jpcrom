	title FINPUT, compilation du format <fcomp.as>
*
* La boucle suivante est la boucle de compilation de P$
*
* FOR I = 1 TO nombre-d'elements(P$)
*   appliquer l'automate ;
*   D$(I) := M$(I) ;
* NEXT I
*
 
 i	equ    (=FUNCR0)+00  5 quartets
 cptp$	equ    (=FUNCR0)+05  5 quartets
 addsp$ equ    (=FUNCR0)+10  5 quartets
 addsu$ equ    (=FUNCR0)+15  5 quartets
 cptm$	equ    (=FUNCR0)+20  2 quartets
 addsm$ equ    (=FUNCR0)+22  5 quartets
 mask	equ    (=FUNCR0)+27  1 quartet
 admask equ    (=FUNCR0)+28  5 quartets
 cptmsk equ    (=FUNCR0)+33  2 quartets
 mult	equ    (=FUNCR0)+35  2 quartets
 lastUP equ    (=FUNCR0)+37  1 quartet
* il reste 1 quartet a (=FUNCR0)+41
 credit equ    (=TRFMBF)+58  2 quartets
* Il ne reste plus rien en TRFMBF !

*
* Les variables k et p utilisees dans "bitmap" sont en
* vark : (=FUNCR0)+38 sur 2 quartets
* varp : (=FUNCR0)+40 sur 1 quartet
*

	d1=(5) =n
	c=dat1 a
	d1=(2) i
*
* la boucle "compiler" attend dans
*   D1 = l'adresse de la variable i
*   C(A) = la valeur de cette variable
*

 compiler
	dat1=c a	i := c(a)

*		     '0'..'9'
*		       ----
*		      |c   |
*		      |	   |
*	  '0'..'9'    v	   |
*	 ---------->	2 
*	|		
*      b|		|	      '0'..'9'
*	|		|'P'|'U'	----
*	|	       e|	       |c   |
*	|		|	       |    |
*   a	    'P'|'U'	v  b  '0'..'9' v    |
*  ---> 1 ----------->	3 ----------->	 4
*	     d	     ->|| ^		 |
*		    |  || |   'P'|'U'  e |
*		   d -- |  --------------
*		 'P'|'U'|
*			|l
*			/ fin de P$
*			|
* 
* 
* Actions de l'automate :
* 
* a: Initialisation de l'automate
* 
*   cptp$  := LEN (GETP$I) ;
*   addsp$ := GETFST (GETPS$I) ;
*   mask   := 2^3 ;
*   cptmsk := 96 ;
*   credit := min (MAXLEN(I$), 96) ;
*   admask := GETB$I + (12*2 + 4 - 1) quartets ;
*   (admask) := 0 ;
*   addsu$ := GETU$I + 4 quartets ;
*   l	   := LEN(GETM$I) ;
*   si l>96 alors "String Overflow" finsi ;
*   cptm$  := l ;
*   addsm$ := GETFST (GETM$I) ;
* 
* b: Initialisation explicite du multiplicateur
* 
*   mult   := carlu - '0' ;
* 
* c: Calcul du multiplicateur
* 
*   si mult>10 alors "Invalid format" finsi ;
*   mult := (mult * 10) + (carlu - '0') ;
* 
* d: Initialisation implicite du multiplicateur
* 
*   mult := 1 ;
*   executer e ;
* 
* e: Protection
* 
*   p := si carlu='P' alors 1 sinon 0 ;
*   lastUP := p ;
*   bitmap (mult, p) ;
* 
* l: Sortie de l'automate
* 
*   bitmap (cptmsk, lastUP) ;
*   U$(I) := REV$(U$(I)) ;
* 
* 
* bitmap (n, p)
*   si n=0 alors retour ;
*   pour k := n jusque 1
*     faire
*	si cptmsk = 0 alors "Invalid format" ; finsi
*	cptmsk-- ;
*	si credit = 0 alors p := 1 ; finsi
*	si p
*	  alors (admask) := (admask) ou mask ;
*	  sinon
*	    si cptm$>0 alors (addsu$++) := (addsm$) ; finsi;
*	    credit-- ;
*	finsi
*	addsm$++ ;
*	si cptm$>0 alors cptm$-- ; finsi
*	mask := mask >> 2 ;
*	si mask=0
*	  alors
*	    mask := 2^3 ;
*	    admask-- ;
*	    (admask) := 0 ;
*	finsi
*   finpour
*

	stitle Transition vers l'etat 1
*
* Action a : initialisation de l'automate
*
* cptp$ := LEN (GETP$I) ;
*
	d1=(5) i
	c=dat1 A
	gosub  =GETP$I	Commentaire
	d1=(5) cptp$
	c=0    A
	c=dat0 4
	dat1=c A
*
* addsp$ := GETFST (GETP$I) ;
*
	gosub  =GETFST	D0 est toujours comme apres GETP$I
	d1=(2) addsp$
	dat1=c A
*
* mask := 2^3 ;
*
	lc(1)  8  2^3 (ou encore 8, ou plutot %1000)
	d1=(2) mask
	dat1=c P
*
* cptmsk := 96 ;
*
	c=0    a	Pour l'instruction suivante...
	lc(2)  96
	d1=(2) cptmsk
	dat1=c B
*
* credit := MIN (MAXLEN(I$), 96) ;
*
	d0=(5) (=DOPEI$)+9 D0 := ^ MAXLEN(I$)
	a=0    a
	a=dat0 4	A(A) := MAXLEN(I$)
	?c>a   a
	goyes  actiona-05  on ne change rien
	a=c    a
 actiona-05
	d1=(2) credit
	dat1=a b	credit := MIN(MAXLEN(I$), 96) ;
*
* admask := GETB$I + (12*2 + 4 - 1) quartets ;
*
	d0=(5) i
	c=dat0 A
	gosub  =GETB$I
	a=c    A
	c=0    A
	lc(2)  12*2+4-1
	c=c+a  A
	d1=(2) admask
	dat1=c A
*
* (admask) := 0 ;
*
  * Bug fix <861129.1115>
	d0=c
	c=0    s
	dat0=c s
*
* addsu$ := GETU$I + 4 quartets ;
*
	d0=(5) i
	c=dat0 A
	gosub  =GETU$I
	c=c+1  A
	c=c+1  A
	c=c+1  A
	c=c+1  A
	d1=(2) addsu$
	dat1=c A
*
* l := LEN (GETM$I) ;
*
	d0=(5) i
	c=dat0 A
	gosub  =GETM$I
	a=0    A
	a=dat0 4
	c=0    A
	lc(2)  96
	?a<=c  A
	goyes  actiona-10

	lc(2)  =eSTROV
	govlng =MFERR

 actiona-10
*
* cptm$ := l ;
*
	d1=(2) cptm$
	dat1=a B
*
* addsm$ := GETFST (GETM$I) ;
*
	gosub  =GETFST
	d1=(2) addsm$
	dat1=c A

	stitle Etat 1

 etat1	gosub  getchr
	rel(3) erreur	EOL
	rel(3) t1-3	P | U
	rel(3) t1-2	0..9

 t1-3	gosub  actiond
	goto   etat3

 t1-2	gosub  actionb
*	goto   etat2
*
* ATTENTION : LE CODE CONTINUE
*

	stitle Etat 2

 etat2	gosub  getchr
	rel(3) erreur	EOL
	rel(3) t2-3	P | U
	rel(3) t2-2	0..9

 t2-2	gosub  actionc
	goto   etat2

 t2-3	gosub  actione
*	goto   etat3
*
* ATTENTION : LE CODE CONTINUE
*

	stitle Etat 3

 etat3	gosub  getchr
	rel(3) actionl	EOL
	rel(3) t3-3	P | U
	rel(3) t3-4	0..9

 t3-3	gosub  actiond
	goto   etat3

 t3-4	gosub  actionb
*	goto   etat4
*
* ATTENTION : LE CODE CONTINUE
*

	stitle Etat 4

 etat4	gosub  getchr
	rel(3) erreur	EOL
	rel(3) t4-3	P | U
	rel(3) t4-4	0..9

 t4-3	gosub  actione
	goto   etat3

 t4-4	gosub  actionc
	goto   etat4


	stitle Traitement du flot d'entree

************************************************************
* getchr
*
* But: lit un caractere et branche sur erreur s'il n'est pas
*   reconnu, puis le classe en trois categories et opere un
*   branchement a une adresse fournie par le module appelant
* Entree:
*   - RSTK = adresse de la table de debranchements
*   - addsp$ pointe sur deux quartets plus haut que le
*     caractere a lire.
*   - cptp$ = nombre de caracteres restant a lire (1..n)
* Sortie:
*   - A(B) = caractere lu
*   - P = 0 
*   - cptp$ et addsp$ ajustes
* Abime: C(A)
* Appelle: CONVUC, DRANGE, TBLJMC
* Niveaux: 2 (CONVUC)
* Detail:
*   Les trois classes de lexemes sont :
*   - Fin de ligne
*   - P / U
*   - 0..9
*   Donc, l'appel doit etre de la forme :
*      GOSUB  getchr
*      REL(3) transition si fin de ligne
*      REL(3) transition si P ou U
*      REL(3) transition si 0..9
* Historique:
*   86/08/31: J.T. & P.D. conception & codage
************************************************************

 getchr d1=(5) cptp$
	c=dat1 A
	c=c-1  A
	dat1=c A
	goc    saut0	Fin de Ligne

	d1=(2) addsp$
	c=dat1 A
	c=c-1  A
	c=c-1  A
	dat1=c A
	d1=c
	a=dat1 B
	gosbvl =CONVUC
	lcasc  \P\
	?a=c   B
	goyes  saut1
	lcasc  \U\
	?a=c   B
	goyes  saut1
	gosbvl =DRANGE
	gonc   saut2

 erreur lc(4)  (=id)~(=eIFMT)  "Invalid Format"
	govlng =BSERR

 saut2	c=0    A
	c=c+1  A
	gonc   st	B.E.T.
 saut1	c=0    A
 st	c=c+1  A
	gonc   saut
 saut0	c=0    A
 saut	govlng =TBLJMC

	stitle Action b

************************************************************
* actionb
************************************************************

 actionb
	lcasc  \0\
	a=a-c  B
	d1=(5) mult
	dat1=a B
	rtn

	stitle Action c

************************************************************
* actionc
************************************************************

 actionc
*
* si mult>10 alors "invalid format" finsi ;
*
	b=a    B
	d1=(5) mult
	a=dat1 B
	lc(2)  10
	?a>c   B
	goyes  erreur
*
* mult := (mult*10) ...
*
	a=a+a  B
	c=a    B
	c=c+c  B       c(a) := mult * 4
	c=c+c  B       c(a) := mult * 8
	a=a+c  B       a(a) := mult * 10
*
*	       ...  + (carlu-'0') ;
*
	lcasc  \0\
	b=b-c  B
	a=a+b  B
	dat1=a b
	rtn

	stitle Action d
************************************************************
* actiond
************************************************************

 actiond
*
* mult := 1 ;
*
	c=0    B
	c=c+1  B
	d1=(5) mult
	dat1=c B
*	goto   actione	   (en fait: gosub ; rtn)
*
* ATTENTION : LE CODE CONTINUE !
*

	stitle Action e
************************************************************
* actione
************************************************************

 actione
*
* p := si carlu = 'P' alors 1 sinon 0 ;
*
	lcasc  \U\
	c=c-a  B
	?c=0   B
	goyes  actione-010
	c=0    B
	c=c+1  B
 actione-010
*
* lastUP := p ;
*
	d1=(5) lastUP
	dat1=c 1
*
* bitmap (mult, p) ;
*
	a=c    A
	d1=(2) mult
	c=dat1 B
	goto   bitmap  (en fait gosub ; rtn)

Erreur	goto   erreur

	stitle Bitmap

************************************************************
* bitmap
*
* But: voir algorithme en debut de fichier
* Entree:
*   - A(0) = p
*   - C(B) = n
* Abime: A(A), C(A), D0, D1
* Niveaux: 0
* Historique:
*   86/08/31: J.T. & P.D. conception & codage
*   86/11/29: J.T. & P.D. ajout du credit
************************************************************

 vark	equ    (=FUNCR0)+38
 varp	equ    (=FUNCR0)+40

 bitmap
*
* si n=0 alors retour ; finsi
*
	?c=0   B
	rtnyes
*
* pour k := n jusque 1
*
	d1=(5) varp
	dat1=a 1
	d1=(2) vark

 bm010	dat1=c B
*
*   faire
*     si cptmsk=0 alors "invalid format" ; finsi
*
	d1=(5) cptmsk
	c=dat1 b
	?c=0   B
	goyes  Erreur
*
*     cptmsk-- ;
*
	c=c-1  B
	dat1=c B
*
*     si credit = 0 alors p := 1 ;
*
	d1=(5) credit
	c=dat1 b	C(B) := credit en "Unprotected"
	d1=(5) varp
	?c#0   b
	goyes  bm015
	a=0    p
	a=a+1  p
	dat1=a 1
*
*     finsi
*
 bm015
*
*     si p
*
	a=dat1 1
	?a=0   P
	goyes  bm020
*
*	alors (admask) := (admask) ou mask ;
*
	d1=(5) mask
	c=dat1 S
	d1=(2) admask
	c=dat1 a
	d1=c
	a=dat1 S
	a=a!c  S
	dat1=a S
	goto   bm035
*
*	sinon 
*	  si cptm$>0
*
 bm020	d1=(5) cptm$
	c=dat1 B
	?c=0   B
	goyes  bm030
*
*	    alors (addsu$++) := (addsm$)
*
	d1=(2) addsm$
	c=dat1 A
	d1=c
	d1=d1- 2
	a=dat1 B	(addsm$)
	d1=(5) addsu$
	c=dat1 A
	d0=c
	c=c+1  A
	c=c+1  A
	dat1=c A	addsu$++
	dat0=a B

*
*	  finsi ;
*
 bm030
*
*	  credit-- ;
*
	d1=(5) credit
	c=dat1 b
	c=c-1  b
	dat1=c b
*
*     finsi
*
 bm035
*
*     addsm$++ ;
*
	d1=(5) addsm$
	c=dat1 A
	c=c-1  A
	c=c-1  A
	dat1=c A
*
*     si cptm$>0 alors cptm$-- ; finsi
*
	d1=(2) cptm$
	c=dat1 B
	c=c-1  B
	goc    bm040
	dat1=c B
 bm040
*
*     mask := mask >> 2 ;
*
	d1=(2) mask
	c=0    A
	c=dat1 1
	csrb		C(0) := mask
*
*     si mask = 0
*	alors
*	  mask := 2^3 ;
*
	?c#0   P
	goyes  bm050
	lc(1)  (%10)^3	C(0) = mask := 2^3
*
*	  admask-- ;
*
	d1=(2) admask
	a=dat1 A
	a=a-1  A
	dat1=a A
*
*	  (admask) := 0 ;
*
	d1=A
	a=0    S
	dat1=a S
*
*     finsi
*
 bm050	d1=(5) mask
	dat1=c 1
*
*   finpour
*
	d1=(2) vark
	c=dat1 B
	c=c-1  B
	?c=0   B
	rtnyes
	goto   bm010

	stitle Action l

************************************************************
* actionl
************************************************************

 actionl
*
*   bitmap (cptmsk, lastUP) ;
*
	d1=(5) lastUP
	a=dat1 1
	d1=(5) cptmsk
	c=dat1 B
	gosub  bitmap
*
* U$(I) := REV$(U$(I)) ;
*
*
* len(U$(I)) := ( addsu$ - GETU$I - 4) / 2
*
	d1=(5) i
	c=dat1 A
	gosub  =GETU$I
	d1=(2) addsu$
	a=dat1 a
	d1=a
	c=a-c  A	 adddu$ - GETU$I
	c=c-1  A
	c=c-1  A
	c=c-1  A
	c=c-1  A
	a=0    M
	a=c    A	 a(a) := 2 * LEN(U$(I)) ;
	asrb		 a(a) := LEN(U$(I)) ;
	dat0=a 4
	d0=d0+ 4
*
* U$(I) := REV$(U$(I)) ;
*
	b=0    W
	b=a    A
	sb=0
	bsrb
	cd0ex
	c=b+c  A
	c=b+c  A
	d0=c
	d1=c
	?sb=0
	goyes  pair
	gonc   impair
 rptrev d1=d1- 2
	a=dat0 B
	c=dat1 B
	dat1=a B
	dat0=c B
 impair d0=d0+ 2
 pair	b=b-1  A
	gonc   rptrev

	d1=(5) i
	c=dat1 a
	d1=(5) =DOPED$
	d0=(5) =DOPEM$
	gosubl =ELMCPY	D$(I) := M$(I)

	d1=(5) i
	c=dat1 a
	c=c-1  a
	?c=0   a
	goyes  compfin
	goto   compiler

 compfin
*
* Le code continue dans le fichier boucle.as
*
	end
