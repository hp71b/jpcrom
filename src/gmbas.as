	TITLE	Graphique, Routines Basic <gmbas.as>

************************************************************
* Definitions du buffer :
*
* - id du module appele
*   oID	  (2) : -
* - origine des labels :
*   oLORG (1) : (initialise a 1)
************************************************************

=bufsze EQU   10

=oID	EQU   0		Cable !
=oLORG	EQU   2

************************************************************
* BOXe
*
* But: executer l'ordre BOX x1, y1, x2, y2
* Historique:
*   87/02/04: conception et codage
************************************************************

	REL(5) =BOXd
	REL(5) =BOXp
=BOXe
	GOSBVL =EXPEX-
	GOSUBL GETPT
	R1=C
	GOSUBL GETPT
	R2=C
	D1=(5) =LOCAL
	C=R1
	DAT1=C 10
	D1=D1+ 10
	C=R2
	DAT1=C 10
	GOSUBL =SETUP
	GOTO   BOX10

************************************************************
* CSIZEe
*
* But: executer l'ordre CSIZE haut [, rapport [, pente]]
* Historique:
*   87/02/04: conception et codage
************************************************************

	REL(5) =CSIZEd
	REL(5) =CSIZEp
=CSIZEe
*
* Un seul parametre :
*   R3 = p1
*
*   SI p1, p1*6/10
*   SL 0
*
* Deux parametres :
*   R2 = p1
*   R3 = p2
*
*   SI p1, p1*p2
*   SL 0
*
* Trois paramatres :
*   R1 = p1
*   R2 = p2
*   R3 = p3
*
*   SI p1, p1*p2
*   SL p3
*
	GOSBVL =EXPEX-
	GOSUBL PARM?
	R3=A		R3 := dernier parametre
	GOSUBL PARM?
	GOC    CSI010
	R2=A		R2 := avant dernier parametre
	GOSUBL PARM?
	GOC    CSI020
	R1=A		R1 := premier parametre
	GOTO   CSI100

*
* Un seul parametre, dans R3
*
 CSI010
	C=R3
	R1=C		R1 := p1
	LCHEX  0600000000000999	     6/10
	R2=C		R2 := p2 (6/10)
	C=0    W
	R3=C		R3 := p3 (0)
	GOTO   CSI100
*
* Deux parametres, p1 dans R2 et p2 dans R3
*
 CSI020
	C=R2
	R1=C		R1 := p1
	C=R3
	R2=C		R2 := p2
	C=0    W
	R3=C		R3 := p3 (0)

*
* R1 = p1
* R2 = p2
* R3 = p3
*
 CSI100
	D1=(5) (=LOCAL)+10
	C=R3
	DAT1=C W	Sauvegarde de l'angle
	D1=D1- 10
*
* Premier parametre de SI
*
	A=R1
	GOSUBL HEXA
	DAT1=A A
*
* Deuxieme parametre de SI
*
	D1=D1+ 5
	A=R1
	C=R2
	GOSBVL =MP2-12
	GOSBVL =uRES12
	P=     0
	A=C    W
	GOSUBL HEXA
	DAT1=A A
*
* Parametre de SL
*
	D1=D1+ 5
	A=DAT1 W	A(W) = angle sauve tout a l'heure
	GOSUBL ANGLE
	DAT1=A W	En 12 digits form, et en RADIANS

	GOSUBL =SETUP
*
* SI p1, p1*p2
*
	D1=(5) =LOCAL
	C=DAT1 A
	R1=C
	D1=D1+ 5
	C=DAT1 A
	R2=C
	LC(2)  =nSI
	GOSUBL =GRAPHx
*
* SL p3
*
	D1=(5) (=LOCAL)+10
	C=DAT1 W
	R0=C
	LC(2)  =nSL
	GOSUBL =GRAPHx

	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* DRAWe
*
* But: executer l'ordre DRAW x, y
* Historique:
*   86/--/--: conception et codage
*   87/02/04: utilisation de GETPT
*   87/02/11: fusion de MOVE & DRAW
************************************************************

	REL(5) =DRAWd
	REL(5) =DRAWp
=DRAWe 
	LC(2)  =nPD

 DW10
	D1=(5) =LOCAL
	DAT1=C B

	GOSBVL =EXPEX-
	GOSUBL GETPT
	D1=(5) (=LOCAL)+2
	DAT1=C 10

	GOSUBL =SETUP
*
* PD ou PU
*
	D1=(5) =LOCAL
	C=DAT1 B
	GOSUBL =GRAPHx
*
* PA x, y
*
	D1=(5) (=LOCAL)+2
	C=DAT1 10
	R1=C
	LC(2)  =nPA
	GOSUBL =GRAPHx
*
* PU
*
	LC(2)  =nPU
	GOSUBL =GRAPHx

	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* FRAMEe
*
* But: executer l'ordre FRAME
* Historique:
*   87/02/04: conception et codage
************************************************************

	REL(5) =FRAMEd
	REL(5) =FRAMEp
=FRAMEe
	GOSUBL =SETUP
*
* Obtenir d'abord P1 et P2
*
	LC(2)  =nOP
	GOSUBL =GRAPHx
*
* LOCAL := (R1) et (R2)
*
	D1=(5) =LOCAL
	A=R1
	DAT1=A 10	(LOCAL)+00 := P1
	D1=D1+ 10
	A=R2
	DAT1=A 10	(LOCAL)+10 := P2
 BOX10
*
* PU
*
	LC(2)  =nPU
	GOSUBL =GRAPHx
*
* PA P1x, P1y
*
	LC(2)  =nPA
	GOSUBL =GRAPHx
*
* PD
*
	LC(2)  =nPD
	GOSUBL =GRAPHx
*
* PA P2x, P1y
*
	D1=(5) (=LOCAL)+5  D1 := ^ P1y
	C=DAT1 A
	GOSBVL =CSLC5
	D1=D1+ 5	D1 := ^ P2x
	C=DAT1 A
	R1=C
	LC(2)  =nPA
	GOSUBL =GRAPHx
*
* PA P2x, P2y
*
	D1=(5) (=LOCAL)+10 D1 := ^ P2x
	C=DAT1 10
	R1=C
	LC(2)  =nPA
	GOSUBL =GRAPHx
*
* PA P1x, P2y
*
	D1=(5) (=LOCAL)+15 D1 := ^ P2y
	C=DAT1 A
	GOSBVL =CSLC5
	D1=D1- 15
	C=DAT1 A
	R1=C
	LC(2)  =nPA
	GOSUBL =GRAPHx
*
* PA P1x, P1y
*
	D1=(5) =LOCAL
	C=DAT1 10
	R1=C
	LC(2)  =nPA
	GOSUBL =GRAPHx
*
* PU
*
	LC(2)  =nPU
	GOSUBL =GRAPHx
	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* GDUMPe
*
* But: executer l'ordre GDUMP
* Historique:
*   86/--/--: conception et codage
************************************************************

	REL(5) =GDUMPd
	REL(5) =GDUMPp
=GDUMPe GOSUBL =SETUP
	LC(2)  =nDU
	GOSUBL =GRAPHx
	GOSUBL =ENDGL
	GOVLNG =NXTSTM

 argerr GOVLNG =ARGERR

************************************************************
* GINITe
*
* But: Initialiser le graphique
* Historique:
*   86/09/08: ajout de documentation
************************************************************

	REL(5) =GINITd
	REL(5) =GINITp
=GINITe GOSBVL =EXPEX-
*
* Le paramètre optionnel est pointe par D1, s'il est la.
* Sinon, la Math-Stack contient une chaine.
*
	D0=(5) =S-R1-0
	C=0    A	Par defaut : 0 ligne graphique
	DAT0=C A
* Est-ce une chaine ?
	LCHEX  F	String "stack signature"
	?A=C   P	(P=0 apres EXPEX-)
	GOYES  GIN10
*
* Non. Le parametre optionnel est bien la. Transformons-le
* en hexa et stockons-le.
*
	GOSBVL =RNDAHX
	GONC   argerr	Argument negatif
	DAT0=A A
	D1=D1+ 16
*
* Le parametre optionnel est place dans S-R1-0
*
 GIN10	GOSBVL =POP1S
	A=A-1  A
* chaine nulle ?
	GOC    GIN20	Oui: "Invalid Graph Type"
	C=0    A
	LCHEX  F	Taille inferieure a 16 caracteres
	?A<=C  A
	GOYES  GIN40
 GIN20	LC(4)  (=graid)~(=eIVGRT)	Invalid File Type ->
	GOVLNG =BSERR	    type de graphique non reconnu
*
* La chaine fait bien entre 1 et 8 caracteres.
*
 GIN40	C=A    A
	A=0    W	Cadrage avec des 0 a gauche
	P=C    0
	A=DAT1 WP	A(W) := chaine
	P=     0
*
* Sauvegarde de la chaine en STMTR0
*
	D0=(5) =STMTR0
	DAT0=A W
*
* Allocation du buffer bMAIN
*
	LC(5)  =bufsze
	B=C    A
	LC(3)  =bMAIN
	GOSBVL =I/OALL
	GOC    GIN45
	GOVLNG =BSERR
*
* Initialisation du buffer
*
 GIN45
*
* D1 = ^ buffer
*

************************************************************
* Initialisation du buffer
*
* oLORG	    1 = (1)
************************************************************

	D1=D1+ 2	Sauter l'Id

	A=0    S
	A=A+1  S	A(S) := 1
	DAT1=A S
	D1=D1+ 1
*
* Interrogation des drivers pour en selectionner un.
* Conversion en majuscule de la chaine, et envoi du poll.
*
	D0=(5) =STMTR0
	A=DAT0 W	type du graphique
	LCHEX  DFDFDFDFDFDFDFDF	Conversion globale
	C=A&C  W	et rapide en majuscule !!!
	D=C    W	D(W) := nom
	LC(2)  =prINIT
	A=C    B
*
* D(W) := nom ; A(B) := prINIT
*
	GOSBVL =POLL
	CON(2) =pGRAPH
	GOC    GIN30	Erreur par le module appele !!!
	?XM=0
	GOYES  GIN50
*
* Il y a eu erreur, ou aucun module n'a reconnu le type
* demande. Ok. BSERR...
*
	LC(4)  (=graid)~(=eIVGRT)	"Invalid Graph Type"
 GIN30	D=C    A	I/ODAL n'abime pas D
	LC(3)  =bMAIN
	GOSBVL =I/ODAL
	C=D    A
	GOVLNG =BSERR
*
* Un driver s'est fait connaitre. Il a laisse son numero
* d'identification dans D(B).
*
 GIN50	GOSUBL =FINDBF
	C=D    B	Code du module graphique reconnu
	DAT1=C B	Sauvegarde en premiere position
	GOVLNG =NXTSTM	  dans le buffer.

************************************************************
* GENDe
*
* But: executer l'ordre GEND
* Historique:
*   86/--/--: conception et codage
************************************************************

	REL(5) =GENDd
	REL(5) =GENDp
=GENDe	GOSUBL =FINDBF
	C=DAT1 B
	D=C    B	D(B) := ID du driver
	LC(3)  =bMAIN
	GOSBVL =I/ODAL
	LC(2)  =prEND
	A=C    B
	GOSBVL =POLL
	CON(2) =pGRAPH
	GOC    GEND99
	?XM=0
	GOYES  GEND10
	LC(4)  (=graid)~(=eMODMS)	buffer found,
	  *		pGEND not handled ==> Module missing
 GEND99 GOVLNG =BSERR
 GEND10 GOVLNG =NXTSTM

************************************************************
* IDRAWe
*
* But: executer l'ordre IDRAW x,y
* Historique:
*   87/02/11: conception et codage
************************************************************

	REL(5) =IDRAWd
	REL(5) =IDRAWp
=IDRAWe
	LC(2)  =nPD

 IDW10
	D1=(5) =LOCAL
	DAT1=C B	LOCAL := ordre HPGL en premier

	GOSBVL =EXPEX-
	GOSUBL GETPT
	D1=(5) (=LOCAL)+2
	DAT1=C 10

	GOSUBL =SETUP
*
* PD ou PU
*
	D1=(5) =LOCAL
	C=DAT1 B
	GOSUBL =GRAPHx
*
* OA
*
	LC(2)  =nOA
	GOSUBL =GRAPHx
*
* x' := x + dx
* y' := y + dy
*
	D1=(5) (=LOCAL)+2
	A=R1		A(A) := x
	C=DAT1 A	C(A) := dx
	A=A+C  A	A(A) := x'
	B=A    A	B(A) := y'
	D1=D1+ 5
	A=R1
	ASR    W
	ASR    W
	ASR    W
	ASR    W
	ASR    W	A(A) := y
	C=DAT1 A	C(A) := dy
	C=A+C  A	C(A) := y'
	CSL    W
	CSL    W
	CSL    W
	CSL    W
	CSL    W
	C=B    A
	R1=C
*
* PA x',y'
*
	LC(2)  =nPA
	GOSUBL =GRAPHx
*
* PU
*
	LC(2)  =nPU
	GOSUBL =GRAPHx

	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* IMOVEe
*
* But: executer l'ordre IMOVE x,y
* Historique:
*   87/02/11: conception et codage
************************************************************

	REL(5) =IMOVEd
	REL(5) =IMOVEp
=IMOVEe
	LC(2)  =nPU
	GOTO   IDW10

************************************************************
* LABELe
*
* But: executer l'ordre LABEL str [;]
* Historique:
*   87/02/04: conception et codage
*   87/02/10: ajout du [;]
************************************************************

	REL(5) =LABELd
	REL(5) =LABELp
=LABELe
	GOSBVL =EXPEX-
	C=0    S
	A=DAT0 B
	LC(2)  =tSEMIC
	?A#C   B
	GOYES  LBL010
	C=C+1  S
 LBL010 D0=(5) =LOCAL
	DAT0=C S	(LOCAL) := si ";" alors 1 sinon 0
	D0=D0+ 1	D0 := ^ (LOCAL)+1
	CD1EX
	DAT0=C A	(LOCAL)+1 := ^ String header
*
* Preparation du graphique
*
	GOSUBL =SETUP
	P=     0
*
* Centrage de la chaine (LORG)
*
	D0=(5) 1+=LOCAL
	C=DAT0 A
	D1=C		D1 := ^ M.S.
	GOSBVL =POP1S	A(A) := 2*L

	C=A    A
	A=0    W
	A=C    A	A(W) := 2*L
	ASRB		A(W) := L

*
* constante magique :
*   LORG 1 : CP	 0,    0   ==> 0 0 : %0000 : #0
*   LORG 2 : CP	 0,   -0.5 ==> 0 1 : %0001 : #1
*   LORG 3 : CP	 0,   -1   ==> 0 2 : %0010 : #2
*   LORG 4 : CP -L/2,  0   ==> 1 0 : %0100 : #4
*   LORG 5 : CP -L/2, -0.5 ==> 1 1 : %0101 : #5
*   LORG 6 : CP -L/2, -1   ==> 1 2 : %0110 : #6
*   LORG 7 : CP -L,    0   ==> 2 0 : %1000 : #8
*   LORG 8 : CP -L,   -0.5 ==> 2 1 : %1001 : #9
*   LORG 9 : CP -L,   -1   ==> 2 2 : %1010 : #A
*
	LCHEX  A98654210
	B=C    W	B(W) := MAGICs

	LC(2)  =oLORG
	GOSUBL =MBUFC
	LC(1)  9
	D=C    A	D(A) := 9
	C=DAT1 P	C(0) := LORG
	?C=0   P
	GOYES  LBL020	P=0
	?C>D   P
	GOYES  LBL020	si par hasard LORG > 9, P=0
	P=C    0
	P=P-1

*
* P = LORG - 1
* B(8:0) = MAGICs
* 
 LBL020 
	C=P    15
	P=     0
 LBL030
	?C=0   S
	GOYES  LBL040
	BSR    W
	C=C-1  S
	GONC   LBL030	B.E.T.
*
* B(0) = MAGIC
*     2 bits de poids faible : 0, 1 ou 2 dans R2
*     2 bits de poids fort : x*A(A) dans R1
* P = 0
*
 LBL040
*
* 2 bits de poids faible
*
	C=0    A
	LC(1)  %11
	C=C&B  P	C(A) := 0 1 ou 2
	R2=C
*
* 2 bits de poids fort
*
	C=0    W
	LC(1)  %1100
	C=C&B  P
	CSRB
	CSRB		C(A) := 0, 1 ou 2
	GOSBVL =MPY
	R1=C
*
* CP R1, R2
*
	LC(2)  =nCP
	GOSUBL =GRAPHx
*
* Envoi de la chaine
*
	D0=(5) 1+=LOCAL
	C=DAT0 A
	R1=C
	LC(2)  =nLB
	GOSUBL =GRAPHx
*
* Faut-il envoyer un EOL ?
*
	D0=(5) =LOCAL
	C=DAT0 S
	?C#0   S	Il y a ";"
	GOYES  LBL070
*
* Envoi de la sequence ENDLINE
*
	GOSBVL =COLLAP
	D1=C		D1 = pointeur de M.S.
	R1=C		pour ADHEAD
	GOSBVL =D=AVMS
	D0=(5) =EOLLEN
	C=DAT0 S
	CSRB		C(S) = longueur en octets
	D0=D0+ 1
	GONC   LBL060	B.E.T.
*
* Envoi des caracteres de ENDLINE
*
 LBL050 C=DAT0 B
	GOSBVL =STKCHR
	D0=D0+ 2
 LBL060 C=C-1  S
	GONC   LBL050
*
* Fabrication du "string-header"
*
	ST=1   0	RTN desired
	GOSBVL =ADHEAD
	CD1EX
	R1=C
	LC(2)  =nLB
	GOSUBL =GRAPHx
 LBL070
	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* LDIRe
*
* But: executer l'ordre LDIR theta
* Historique:
*   87/02/02: conception et codage
************************************************************

	REL(5) =LDIRd
	REL(5) =LDIRp
=LDIRe
	GOSBVL =EXPEX-
	GOSUB  PARM?
*
* A(W) = nombre (12 digits)
*
	GOSUB  ANGLE
*
* si theta<0 ou theta > 2PI alors erreur
*
	D1=(5) =LOCAL
	DAT1=A W
	?A#0   S
	GOYES  argErr
	LCHEX  0628318530719000 2PI + epsilon
	P=     4	a>c
	GOSBVL =TST12A	?A>C
	GOC    argErr	GOYES argErr
	SETHEX
	P=     0

	GOSUBL =SETUP
*
* DI theta
*
	D1=(5) =LOCAL
	A=DAT1 W
	R0=A
	LC(2)  =nDI
	GOSUBL =GRAPHx

	GOSUBL =ENDGL

	GOVLNG =NXTSTM

 argErr GOVLNG =ARGERR

************************************************************
* LINETYPEe
*
* But: executer l'ordre LINETYPE no [, len]
* Historique:
*   86/--/--: conception et codage
*   87/02/11: reecriture
************************************************************

	REL(5) =LINETYPEd
	REL(5) =LINETYPEp
=LINETYPEe
	GOSBVL =EXPEX-

	GOSUB  PARM?
	?A#0   S	Interdiction des nombres negatifs
	GOYES  argErr
	R1=A		R1 := dernier parametre
	GOSUB  PARM?
	GOC    LP1	Un seul parametre
	?A#0   S	Interdiction des nombres negatifs
	GOYES  argErr
	R0=A		R0 := type
*
* Deux parametres :
* R1 = longueur
* R0 = type de la ligne
*
	GONC   LT100
 LP1
*
* Un seul parametre
* R1 = type de la ligne
*
	C=R1
	R0=C
	C=0    W
	P=     14
	LCHEX  91	-1
	P=     0
	R1=C

 LT100
*
* R0 = type de la ligne (>=0)
* R1 = longueur du motif (>=0, ou -1)
*
	A=R0
	GOSUBL	HEXA
*
* Transformation du parametre pour etre compatible avec le
* HP-7470.
*   0 -> pas de parametre
*   1 -> pas de parametre
*   2 -> 0
*   3 -> 1
*   :
*   8 -> 6
*   9 -> pas de parametre
*  10 -> 0
*  11 -> 1
*   :
*
	?A=0   A
	GOYES  LT110
	A=A-1  A
 LT110
	C=0    A
	LC(1)  %0111
	A=A&C  A	A(A) := (LINETYPE - 1) mod 8
	A=A-1  A	-1 pour la droite solide
	 *		0 a 6 sinon
	D1=(5) =LOCAL
	DAT1=A A
	D1=D1+ 5

	A=R1
	GOSUBL HEXA
	DAT1=A A


	GOSUBL =SETUP

	D1=(5) =LOCAL
	A=DAT1 A
	R0=A		R0 := motif (-1, 0..6)
	D1=D1+ 5
	A=DAT1 A
	R1=A
	LC(2)  =nLT
	GOSUBL =GRAPHx

	GOSUBL =ENDGL

	GOVLNG =NXTSTM

************************************************************
* LORGe
*
* But: executer l'ordre LORG n
* Historique:
*   87/23/02: conception et codage
************************************************************

	REL(5) =LORGd
	REL(5) =LORGp
=LORGe
	GOSBVL =EXPEX-
	GOSUB  PARM?
	GOSBVL =RJUST
	SETHEX
	B=A    A	B(0) := parametre de LORG
	GOSUBL =FINDBF
	A=B    A
	LC(2)  =oLORG
	GOSUBL =MBUFC
	DAT1=A 1	oLORG := parametre de LORG

	GOVLNG =NXTSTM

************************************************************
* MOVEe
*
* But: deplacer la plume sans rien tracer (MOVE x, y)
* Historique:
*   86/09/08: ajout de documentation
*   87/02/04: utilisation de GETPT
*   87/02/11: fusion de MOVE & DRAW
************************************************************

	REL(5) =MOVEd
	REL(5) =MOVEp
=MOVEe
	LC(2)  =nPU
	GOLONG DW10

************************************************************
* PENDOWNe
*
* But: executer l'ordre PENDOWN
* Historique:
*   86/--/--: conception et codage
************************************************************

	REL(5) =PENDOWNd
	REL(5) =PENDOWNp
=PENDOWNe
	GOSUBL =SETUP
	LC(2)  =nPD
	GOSUBL =GRAPHx
	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* PENUPe
*
* But: executer l'ordre PENUP
* Historique:
*   86/--/--: conception et codage
************************************************************

	REL(5) =PENUPd
	REL(5) =PENUPp
=PENUPe
	GOSUBL =SETUP
	LC(2)  =nPU
	GOSUBL =GRAPHx
	GOSUBL =ENDGL
	GOVLNG =NXTSTM

 Argerr GOLONG argerr

************************************************************
* PENe
*
* But: executer l'ordre PEN [no]
* Historique:
*   86/--/--: conception et codage
************************************************************

	REL(5) =PENd
	REL(5) =PENp
=PENe
	A=DAT0 B
	GOSBVL =EOLXCK
	GONC   PEN10
	A=0    A
	GOC    PEN20	B.E.T.
 PEN10	GOSBVL =EXPEX-
	GOSBVL =RNDAHX
	GONC   Argerr
 PEN20	R0=A		Sauvegarde de A(A) dans R0

	GOSUBL =SETUP
	LC(2)  =nSP
	GOSUBL =GRAPHx
	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* PLOTTERe
*
* But: executer l'ordre PLOTTER IS device
* Historique:
*   86/--/--: conception et pompage
************************************************************

	REL(5) =PLOTTERd
	REL(5) =PLOTTERp
=PLOTTERe
	LC(5)  #2F7A2	IS-PLT
	GOSUBL =JUMPER
	CON(5) #10D6
	RTN

************************************************************
* TICLENe
*
* But: executer l'ordre TICLEN n
* Historique:
*   87/02/23: conception et codage
*   87/03/26: version A : debogage
************************************************************

	REL(5) =TICLENd
	REL(5) =TICLENp
=TICLENe
	GOSBVL =EXPEX-
	GOSUB  PARM?
	GOSUB  HEXA
	B=A    A
	B=B+B  A
	GOC    TL10	parametre negatif
	?A#0   A
	GOYES  TL20
*
* parametre par defaut :
*
 TL10
	A=0    A
	A=A-1  A	A(A) := #FFFFF
 TL20
	D1=(5) =LOCAL
	DAT1=A A

	GOSUBL =SETUP
	D1=(5) =LOCAL
	C=DAT1 A
*
* Modifie le 87/03/26
*   pour la version A
*   avant: R0=A...
*
	R0=C
*
	LC(2)  =nTL
	GOSUBL =GRAPHx
	GOSUBL =ENDGL

	GOVLNG =NXTSTM

************************************************************
* XAXISe
*
* But: executer l'ordre XAXIS
* Historique:
*   87/02/10: conception et codage
************************************************************

	REL(5) =XAXISd
	REL(5) =XAXISp
=XAXISe
	C=0    S
	C=C+1  S
	GOTO   AXES

 XPanic GOVLNG =CORUPT

************************************************************
* YAXISe
*
* But: executer l'ordre YAXIS
* Historique:
*   87/02/10: conception et codage
************************************************************

	REL(5) =YAXISd
	REL(5) =YAXISp
=YAXISe
	C=0    S

************************************************************
* AXES
*
* But: tracer un axe horizontal ou vertical.
* Entree:
*   - C(S) # 0 : axe horizontal (XAXIS)
*   - C(S) = 0 : axe vertical (YAXIS)
* Sortie: par NXTSTM
* Historique:
*   87/10/02: conception & codage
************************************************************

 AXES
	D1=(5) =LOCAL
	DAT1=C S	(LOCAL)+0 := X/YAXIS
	GOSBVL =EXPEX-
	D0=(5) (=LOCAL)+1
	CD1EX
	DAT0=C A	(LOCAL)+1 := ^ M.S.
*
* Mise en place du graphique
*
	GOSUBL =SETUP
*
* Restauration de la M.S.
*
	D1=(5) (=LOCAL)+1
	C=DAT1 A
	D1=C
*
* Analyse des arguments.
*
	GOSUB  PARM?
	GOC    XPanic
	R3=A		R3 := dernier parametre
	GOSUB  PARM?
	GOC    XP1
	R2=A		R2 := avant-dernier parametre
	GOSUB  PARM?
	GOC    XP2
	R1=A
	GOSUB  PARM?
	GOC    XPanic
	R0=A
 XP4
*
* R0 = a-intercept
* R1 = space
* R2 = a1
* R3 = a2
*
	A=R2
	GOSUB  HEXA
	R2=A
	A=R3
	GOSUB  HEXA
	R3=A
	GOTO   AX20
 XP1
*
* R3 = a-intercept
*
	C=R3
	R2=C
	C=0    W	space := 0
	R3=C
*
* Le code continue dans XP2 !
*
 XP2
*
* R2 = a-intercept
* R3 = space
*
	D1=(5) 1+=LOCAL
	C=R2
	DAT1=C W	(LOCAL)+1 := a-intercept
	D1=D1+ 16
	C=R3
	DAT1=C W	(LOCAL)+17 := space
*
* Obtenir xmin et xmax :
*
	LC(2)  =nOP
	GOSUBL =GRAPHx
*
* R1(P) = (P1x, P1y)
* R2(P) = (P2x, P2y)
*
	D1=(5) =LOCAL
	A=R1
	C=R2
	C=DAT1 S	C(S) := si XAXIS alors 1 sinon 0
	?C#0   S
	GOYES  AX10
	CSR    W
	CSR    W
	CSR    W
	CSR    W
	CSR    W
	ASR    W
	ASR    W
	ASR    W
	ASR    W
	ASR    W
 AX10
*
* A(A) = a1
* C(A) = a2
*
	R2=A		R2 := a1
	R3=C		R3 := a2
	D1=(5) (=LOCAL)+1
	C=DAT1 W	a-intercept
	R0=C		R0 := a-intercept
	D1=D1+ 16
	C=DAT1 W
	R1=C		R1 := space
 AX20
*
* R0 = a-intercept \  Ces deux sont en
* R1 = space	   /	12 digits form
* R2 = a1	   \  Ces deux sont en
* R3 = a2	   /	hexa.
*
	D1=(5) (=LOCAL)+1
	A=R0
	GOSUB  HEXA
	DAT1=A A	a-intercept
	D1=D1+ 5
	A=R1
	GOSUB  HEXA
	DAT1=A A	space
	D1=D1+ 5
	A=R2
	DAT1=A A	a1
	D1=D1+ 5
	A=R3
	DAT1=A A	a2
*
* Voila, tout le monde est en hexa.
* LOCAL + 00 = si XAXIS alors 1 sinon 0
* LOCAL + 01 = a-intercept
* LOCAL + 06 = space
* LOCAL + 11 = a1
* LOCAL + 16 = a2
*

* PU
	LC(2)  =nPU
	GOSUBL =GRAPHx
* PA (a-intercept) a1
	D1=(5) (=LOCAL)+11    a1
	A=DAT1 A
	GOSUB  PAAXE
* PD
	LC(2)  =nPD
	GOSUBL =GRAPHx
* PA (a-intercept) a2
	D1=(5) (=LOCAL)+16    a2
	A=DAT1 A
	GOSUB  PAAXE
* PU
	LC(2)  =nPU
	GOSUBL =GRAPHx
* if space=0 then exit
	D1=(5) (=LOCAL)+06    space
	A=DAT1 A
	?A#0   A
	GOYES  rien
	GOTO   AX900
 rien
*
* amin = min(a1, a2)
* amax = max(a1, a2)
* 
	D1=(5) (=LOCAL)+11	a1
	A=DAT1 A	A(A) := a1
	D1=D1+ 5
	C=DAT1 A	C(A) := a2
	D1=D1- 5	D1 = (LOCAL)+11
	B=A    A
	B=B+B  A
	GOC    AX50	GO if a1 < 0
* a1 >= 0
	B=C    A
	B=B+B  A
	GOC    AX35	GO if a1 >= 0 & a2 < 0
* a1 >= 0 & a2 >= 0
 AX30	?A<C   A
	GOYES  AX40
* a1 > a2
 AX35	ACEX   A
 AX40	GOTO   AX100

* a1 < 0
 AX50	B=C    A
	B=B+B  A
	GONC   AX100	GO if a1 < 0 & a2 >= 0
	GOC    AX30	B.E.T.

*
* A(A) = amin
* C(A) = amax
*
 AX100
	DAT1=A A	(LOCAL)+11 := amin
	D1=D1+ 5
	DAT1=C A	(LOCAL)+16 := amax
	C=C-A  A	C(A) := amax - amin
	D1=D1- 10	D1 = (LOCAL)+6 (space)
*
* |space|
*
	A=DAT1 A
	A=A+A  A
	A=DAT1 A
	GONC   AX110
	A=-A   A
 AX110
	ACEX   A
	GOSBVL =IDIVA
	P=     0
*
* A(A) = nb de ticks - 1
*
	A=A+1  A
* Si space > 0
*   alors
*     a := amin ;
*   sinon
*     a := amax ;
* fin si
* n := nb de ticks ;
*
	B=A    A	B(A) := nb de ticks
	A=DAT1 A	space
	D1=D1+ 10
	C=DAT1 A	C(A) := amax
	D=C    A	D(A) := amax
	D1=D1- 5
	C=DAT1 A	C(A) := amin

	A=A+A  A
	GONC   AX120	C(A) := amin
	C=D    A
 AX120	DAT1=C A	(LOCAL)+11 := a
	D1=D1+ 5	D1 = ^ LOCAL + 16
	A=B    A	A(A) := n
	GOTO   AX250

*
* Au debut de la boucle,
*   D1 = ^ (LOCAL)+16 (n)
*   A(A) = n
*
 AX200
	DAT1=A A
	D1=D1- 5	D1 := ^ a
	A=DAT1 A	A(A) := a
	GOSUB  PAAXE
*
* Mettre a a jour
*
	D1=(5) (=LOCAL)+6
	C=DAT1 A	C(A) := space
	D1=D1+ 5
	A=DAT1 A	A(A) := a
	A=A+C  A
	DAT1=A A	a'
* XT ou YT
	D1=(2) =LOCAL
	A=DAT1 S
	LC(2)  =nXT
	?A#0   S
	GOYES  AX210
	LC(2)  =nYT
 AX210
	GOSUBL =GRAPHx
	D1=(5) (=LOCAL)+16	n
	A=DAT1 A
 AX250
	A=A-1  A
	GONC   AX200

 AX900
	GOSUBL =ENDGL
	GOVLNG =NXTSTM

************************************************************
* PAAXE
*
* But: faire un PA avec les coordonnees A(A) et a-intercept
*   suivant le mode XAXIS / YAXIS
* Entree:
*   - A(A) = a
*   - (LOCAL)+1 = si XAXIS alors 1 sinon 0
* Sortie: par GRAPHx
* Appelle: GRAPHx
* Niveaux: -
* Historique:
*   87/02/10: conception & codage
************************************************************

 PAAXE
	D1=(5) (=LOCAL)+1
	C=DAT1 A	C(A) := a-intercept
	D1=D1- 1
	A=DAT1 S	A(S) := si XAXIS alors 1 sinon 0
*
* A(A) = a
* C(A) = a-intercept
*

* XAXIS : x = a ; y = a-intercept
* YAXIS : x = a-intercept ; y = a
	?A#0   S
	GOYES  PAX10
	ACEX   A
 PAX10
*
* A(A) = x
* C(A) = y
*
	CSL    W	y decale 5 fois
	CSL    W
	CSL    W
	CSL    W
	CSL    W
	C=A    A	C(A) := x
	R1=C
	LC(2)  =nPA
	GOLONG =GRAPHx

************************************************************
* PARM?
*
* But: tester la presence d'un argument optionnel, et le
*   depiler si il existe.
* Entree:
*   - D1 = ^ MTHSTK
* Sortie:
*   - Argument optionnel trouve :
*      Cy = 0
*      A(W) = argument (12 digits form)
*      D1 actualise
*   - Argument optionnel non trouve :
*      Cy = 1
*      D1 non modifie
* Appelle: POP1R
* Niveaux: 2
* Abime: D0, A, B(A)
* Historique:
*   87/02/04: conception & codage
************************************************************

 PARM?
	AD1EX
	D1=A
	B=A    A	B(A) = MTHSTK
	D0=(5) =FORSTK
	A=DAT0 A	A(A) = FORSTK
	?A=B   A
	RTNYES
*
* Il y a un parametre
*
	GOSBVL =POP1R	Cy = 0 en sortie
	SETHEX
	D1=D1+ 16	Cy := 0
	RTN

************************************************************
* GETPT
*
* But: depiler deux nombres de la pile, et en faire les
*   coordonnes d'un point.
* Entree:
*   - D1 = ^ MTHSTK
* Sortie:
*   - C(9-5) = y
*   - C(4-0) = x
*   - D1 actualise
* Appelle: POP1R, HEXA
* Niveaux: 3
* Abime: A-D
* Historique:
*   87/02/04: conception & codage
************************************************************

 GETPT
       D=0    W
       C=0    S
       C=C+1  S		C(S) := 1
 GET10
       DSLC
       DSLC
       DSLC
       DSLC
       DSLC
       GOSBVL =POP1R
       D1=D1+ 16
       GOSUB  HEXA
       D=0    A
       C=A    A
       D=C    A		D(A) := A(A)
       C=C-1  S
       GONC   GET10
       C=D    W
       RTN

 ovrfl GOVLNG =ARGERR

************************************************************
* HEXA
*
* But: a partir d'un nombre en 12 digits form, renvoyer le
*   nombre equivalent en hexa.
* Entree:
*   - A(W) = 12 digits form
* Sortie:
*   - A(A) = nombre en hexa
*   - Mode = HEX
* Appelle: FLTDH
* Niveaux: 2
* Abime: A-C
* Historique:
*   87/02/04: conception & codage
************************************************************

 HEXA
	GOSBVL =FLTDH
	GOC    verif	  Cy = 1 <==> nb positif
	?XM=0
	GOYES  HEXA10
	GONC   argerR	  B.E.T.
 HEXA10
	A=-A   A
	GOSUB  verif
	A=-A   A
	RTN

 verif	LC(5)  32767
	?A<=C  A
	RTNYES
 argerR GOVLNG =ARGERR

************************************************************
* ANGLE
*
* But: convertir un angle exprime dans l'unite courante (DEG
*   ou RAD) en RADIANS sous forme 12 digits.
* Entree:
*   - A(W) = angle en unite locale (12 digits form)
* Sortie:
*   - A(W) = angle en radians (12 digits form)
*   - mode = HEX
* Appelle: SFLAG?
* Niveaux: 
* Abime: A-D, P
* Historique:
*   87/02/04: conception & codage
************************************************************

 ANGLE
	B=A    W
	LC(2)  =flRAD
	GOSBVL =SFLAG?
	A=B    W
	GOC    ANGL10
*
* Pompe sur =RAD (#0C181 dans HP-71 1BBBB)
*
	GOSBVL =SPLITA
	P=     7
	GOSBVL =GETCON
	D=C    W
	C=0    W
	C=C-1  A
	C=C-1  A
	GOSBVL =MP2-15
*
* Fin du pompage
*
	GOSBVL =uRES12
	A=C    W
 ANGL10 P=     0
	SETHEX
	RTN

	END
