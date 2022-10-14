	TITLE  MENULEX	<menu.as>

 PARM	GOSBVL =RNDAHX	Convertir Reel sur MATSTK
	GONC   INVPAR	en Hex A(A)
	C=0    A
	C=C-1  B	C(B)= FF
	?C>=A  A	Restriction a 255
	RTNYES

 INVPAR GOVLNG =IVAERR

 Read	D0=(5) =PRGMEN	Limite de recherche
	C=DAT0 A	pour les DATA
	D=C    A	Copie PRGMEN to D(A)
	D0=(4) =DATPTR
	C=DAT0 A	Lit DATPTR
	?C#0   A	DATPTR=0?
	GOYES  R10	Non, alors OK. DATA
	D0=(4) =PRGMST	Oui, alors utilise PRGMST
	C=DAT0 A
 R10	D0=C
 R11	A=DAT0 B	Lit le token
	LCASC  ','
	?A=C   B	Est-ce une virgule?
	GOYES  R20	Oui, alors les data suivent
	D0=D0-	4
	?A#0	P
	GOYES  R15	Non, alors pas	de ligne#
	D0=D0+	4
 R15	LCHEX  C6
	GOSBVL =TKSCN+	trouve le data statement
	GOC    R20
	GOSUB  popbuf
	LC(2)  =eNODAT	Error: No data
 MFERRj GOVLNG =MFERR	
 R20	D0=D0+	2
	CD0EX
	D0=C
	R2=C		Sauve l'adresse du debut de DATA
	LCASC  ','
	B=C    B
	LC(2)  13
 R60 
	A=DAT0	B
	?A=B	B
	GOYES	R80	Oui. Fin de la DATA
	D0=D0+	2 
	?A#C	B	Est-ce une fin de ligne?
	GOYES	R60	Non. Cherche encore

 R80	C=R0		Rapel des pointeurs
	C=C-1  B	Decremente le pointeur.
	R0=C		Sauve le pointeur.
	?C#0   B	Est-ce la DATA cherchee?
	GOYES  R11	Non. Alors DATA suivante.

 R83	R1=A		Sauve le terminator.
	D1=(5) =FUNCR0	D1 pointe la sauvegarde.
	D0=(5) =DSPMSK
	GOSUB  dsp
	GOSBVL =CURSFL	Curseur a gauche.
	A=R1		Rappel le terminator.
	C=R2		Rappel l'adresse de la DATA
	D1=C		D1 pointe la DATA
	GOSBVL =DSPBUF	Affiche la DATA
	GOVLNG =-LINE	efface le fin de ligne
 dsp	C=DAT1 W
	DAT0=C W
	D1=D1+ 16
	D0=D0+ 16
	P=     7
	C=DAT1 WP
	DAT0=C WP
	P=     0
	RTN
 popbuf GOSBVL =CRLFND
 popb	GOVLNG =POPBUF
 
* Debut de l'execution de MENU
 
	NIBHEX 8812	2 chaines num. 1 option.

=MENUe	GOSUB  PARM	Lit et convertit le 1er parm.
	D1=D1+ 16	
	R3=A		Sauve le parametre
	A=0    A
	A=A+1  A
	C=C-1  S
	C=C-1  S
	GOC    m10
	GOSUB  PARM	Lire le 2eme parametre.
	D1=D1+ 16
	AR3EX

 m10	C=R3
	CSL    A
	CSL    A
	C=A    B
	AD0EX
	GOSBVL =ASLW5
	AD1EX
	GOSBVL =ASLW5
	R4=A
	R0=C
	R3=C
	GOSUB	pop
	NIBHEX	02
	NIBHEX	FF
 pop	C=RSTK
	D1=C
	GOSBVL =BF2DSP
	D0=(5) =FUNCR0	D0 pointe la sauvegarde
	D1=(5) =DSPMSK
	GOSUB  dsp
*********************
* Modification pour supporter MENU (Pierre David)
*
*mAFF	GOSBVL =PRSCKB	Lecture des pointeurs BASIC
*
 PgmRun EQU    13
 mAFF	?ST=1  PgmRun
	GOYES  mAFF10
	LC(2)  =flSUSP
	GOSBVL =SFLAG?
	GOC    mAFF10
	GOSBVL =GETSTC
	GONC   mAFF10
	GOVLNG =MFERR
	
 mAFF10
*
* Fin de la modification
*********************
	GOSUB  Read

 menuF	GOSUB  popb	Attend une touche.
	GOSBVL =SCRLLR

 menuR	GOSBVL =FINDA	CASE OF de la touche
	CON(2) =k#ATTN
	REL(3) quit
	CON(2) =k#DOWN
	REL(3) menuD
	CON(2) =k#UP
	REL(3) menuU
	CON(2) =k#TOP
	REL(3) menuT
	CON(2) =k#BOT
	REL(3) menuB
	CON(2) =k#EOL
	REL(3) menuE
	CON(2) 0
	GONC   menuF
 
 menuU	C=R3
	C=C-1  B
	?C#0   B
	GOYES  m+

 menuT	C=R3
	C=0   B
	C=C+1 B
 m+	R0=C
	R3=C
	GOTO mAFF
 
 menuD	C=R3
	A=C	A
	ASR	A
	ASR	A
	C=C+1	B
	?C<A	B
	GOYES	m+

 menuB	C=R3
	A=C  A
	ASR  A
	ASR  A
	C=A   B
	GONC m+
 
 menuE
	GOSUB  popbuf
	GOSBVL =CRLFND
	A=0  A
	C=R3
	A=C B
	GOSBVL =HDFLT  convertion flottant
	SETHEX
	C=A   W
	A=R4
	GOSBVL =ASRW5
	D1=A
	GOSBVL =ASRW5

	GOVLNG =FNRTN2
 quit
	D0=(5) =PCADDR
	A=DAT0 A
	D0=A
	GOSBVL =EOLSCN
	GOVLNG =RUNRT1
