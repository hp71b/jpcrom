	TITLE  EDITLEX (copie, puis édition) <edit.as>

*
* 86/11/10: JPB Conception
* JPC:A03
*   86/11/10: PD/JT Intégration dans JPC Rom
* JPC:...
*   ../../..: PD Correction du bug lorsque EDIT LEX:TAPE
*

 SAVE19 EQU    =TRFMBF	Zone de 19 quartets pour
	 *		sauver le nom du fichier
	 *		destination

	REL(5) =EDITp

=EDITe
	LC(5)  =lFILSV	Reserve 50 quartets
	P=     1	pour la SAVSTK
	GOSBVL =SALLOC	(= zone de sauvegarde)
	GOC    jp	INSUFFICENT MEMORY
 CPY010 D=0    W	Peripherique initialise
	LCASC  '  '	Caracteres 9 et 10
	R0=C		du nom du fichier effaces
	A=DAT0 B	Lit token suivant

**************************************************
* COPY TO  /  COPY <spec> TO ...
**************************************************
	LC(2)  =tTO
	?A#C   B	Token <> TO ?
	GOYES  CPY030
	D0=D0+ 2	Saute TO token
	?ST=1  =sDEST	Destination ?
	GOYES  CPY040	Analyse N2:P2

**************************************************
*
* COPY	TO  ...
* Pas de fichier source specifie
* Prend le fichier et spEcificateur courant
*
**************************************************
 CPY020 GOSUB  deffil	N1:P1 <-- courant
	GONC   CPY065	B.E.T.

**************************************************
*
* EDIT avec/sans parametres  /	EDIT <spec> EOL
*
*    Si Source
*      EDIT workfile
*    Sinon	 (CPY045)
*      N2:P2 <-- 0
*      Si N1 pas en memoire
*	  Recopier N1  (CPY080)
*      EDIT N1	 (edit80)
*
**************************************************
	*
 CPY030 LCHEX  F0	Token <> EOL ?
	?A<C   B
	GOYES  CPY040	oui
	?ST=1  =sDEST	Destination ?
	GOYES  CPY045

	*
	* EDIT workfile
	*
	GOVLNG =EDITWF

**************************************************
* COPY ... CARD
**************************************************
 CPY040 LC(2)  =tCARD	CARD token ?
	?A#C   B
	GOYES  CPY060	non
	LC(1)  =dCARD
	D=C    P	Peripherique= :CARD
 CPY050 D0=D0+ 2	Saute token
	A=0    W	Pas de nom
	GONC   CPY070	B.E.T.

 CPY055 GOTO   EDIT79

 CPY060 GOSUB  tkysck	KEYS token ?
	GONC   CPY065	oui
	GOSBVL =FSPECx	Analyse specificateur
 jp	GOC    CPY055	ILLEGAL FILESPEC

 CPY065
*****************************************
*****************************************
** BOGUE DE L'O.S.
**
**
	D1=(5) SAVE19
	?A=0   W
	GOYES  CPY066
	DAT1=A W	FUNCR0 = nom
 CPY066 D1=D1+ 16
	LCHEX  F00	No device specified
	DAT1=C X	FUNCR1 = device
	C=D    W
	CSLC   W
	C=D    S
	C=C+C  S
	GOC    CPY067	External ?
	DAT1=C X	No : save
 CPY067
**
**
*****************************************
*****************************************
	DSLC		Specificateur en D[A] et
 CPY070 GOSBVL =SVINFO	nom en A[W]&R0 sauves.
	?ST=1  =sDEST	Destination ?
	GOYES  CPY071	alors analyse terminee
	ST=1   =sDEST	Sinon il reste
	GOTO   CPY010	... TO N2:P2 a examiner
 CPY071 GOTO   CPY80+

**************************************************
*
* EDIT	N1:P1
*
* Entree:  sDEST=1  ;  D[W]=0
**************************************************
	*
 CPY045 D0=D0+ 2
	A=0    W	Pas de fichier objet precise
	GOSBVL =SVINFO	N2:P2 <-- 0
	ST=0   =sDEST
	GOSBVL =RDINFO	A[W] <-- N1 ; D[A] <-- P1
	DSRC		D[S]= specificateur
	C=D    W
	R3=C
	GOSBVL =FINDF+	N1 en memoire ?
	GONC   edit80	oui
	?ST=0  6	N1= 0 ou P1= externe ?
	GOYES  CPY080
	C=R3		Cree le fichier N1
	D=C    W	en respectant P1
	R2=A
	C=0    A
	LC(2)  (=oFLENh)+(=oBSsod)
	GOSBVL =CRETF+
 EDIT79 GOC    EDT085
	A=R1
	D1=A
	C=R2
	DAT1=C =lFNAMh
	D1=D1+ =lFNAMh
	LC(4)  =fBASIC
	DAT1=C =lFTYPh
	D1=D1+ (=lFTYPh)+(=lTIMEh)+(=lDATEh)+(=lFLAGh)
	D1=D1+ =lFLENh
	C=0    W
	DAT1=C 10
	D1=D1+ 10
	LC(2)  =tEOL
	DAT1=C B
	D1=A

	*
	* Edite le fichier pointe par D1
	*
 edit80 GOSBVL =EDIT80
	GOVLNG =NXTSTM	FIN

 EDT085 GOTO   CPYERX

**************************************************
*
* COPY N1:P1 TO N2:P2  et  EDITE N2:P2
*
* 1) Recopie N1:P1 dans N2:P2
* 2) Puis edite N2
*
* Entree: suppose P2= periph. interne
**************************************************
	*
 CPY080

*****************************************
*****************************************
**
** BOGUE DANS L'O.S.
**
** L'adresse du fichier apres COPYu (dans R1) n'est
** pas valide si le fichier est du type LEX.
**
** Cette adresse est abimee par LEXBF+, appelee
** depuis HPILROM (hCOPYx, #F5C04).
**
** (Pierre David)
**

**
** Il faut sauver le nom du fichier destination
** (Fait juste apres CPY065)
**
*****************************************
*****************************************
	GOSBVL =COPYu
	GOC    CPYERX	erreur
*****************************************
*****************************************
**
** Il faut chercher le fichier dont le nom
** a ete sauve precedemment.
**
	D1=(5) SAVE19
	A=DAT1 W
	D1=D1+ 16
	C=DAT1 X
	D=C    A
	DSRC
	GOSBVL =FINDF
	GONC   edit80	File Found
	
	GOVLNG =CORUPT
**
**
*****************************************
*****************************************
*	 C=R1		 R1 ^ fichier copie
*	 D1=C		 D1 <-- R1
*	 GONC	edit80	 B.E.T.

	* Teste si P2= Peripherique interne
	*     oui -> CPY080
	*     non -> ILLEGAL FILESPEC
	* EntrEe: D[A] = :P2
	*
 CPY80+ DSRC		D[S]= type de P2
	D=D+1  S	P2 indefini ?
	GOC    CPY080	MAIN par defaut
	D=D+D  S	externe ?
	GONC   CPY080	non
	LC(4)  =eFSPEC	ILLEGAL FILE SPECIFIER
 CPYERX GOVLNG =BSERR	Basic Error

 deffil GOSBVL =CURDVC	Trouve peripherique
	GOSBVL =FLDEVX	courant
	D1=(5) =CURRST
	C=DAT1 A
	D1=C		D1 @ sommet fichier courant
	A=DAT1 W	A[W] <-- nom du fichier
	LCASC  '  '
	R0=C		cf. CPY010
	RTNCC

 tkysck A=DAT0 B
	LC(2)  =tKEYS
	?A#C   B
	RTNYES
	D0=D0+ 2	Saute token
	LCASC  '    syek'
	D=0    S
	A=C    W
	RTN

	END
