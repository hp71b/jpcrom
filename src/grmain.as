	TITLE	Graphique, Module Raster <grmain.as>

 JPCPRV	EQU	1

=GRAFIL EQU    =STMTD0
=RBUF	EQU    =STMTD1

=gRAST	EQU    2	Id de Raster

=npixls EQU    640

=oP1	EQU    0
=oW1	EQU    20
=oP	EQU    40
=oPEN	EQU    50
=oLT	EQU    51
=oLTLEN EQU    52
=oCR	EQU    57
=oTHETA EQU    67
=oHCAR	EQU    72
=oLCAR	EQU    77
=oTLEN	EQU    82

=bDRVRs EQU    90

=PLUMEX EQU    =FUNCD0
=PLUMEY EQU    =FUNCD1

	STITLE Outils
************************************************************
* OUTILS
************************************************************

************************************************************
* FINDGR
*
* But: trouver l'adresse de GRAPHILE, et la mettre ds GRAFIL
* Entree: -
* Sortie:
*   - Cy = 1 : GRAPHILE est trouve
*      A(A) = (GRAFIL) = ^ GRAPHILE (debut du graphique)
*      C(A) = D1 = ^ en-tete de GRAPHILE
*   - Cy = 0 : GRAPHILE n'est pas trouve
*      C(3-0) = numero d'erreur (File Not Found)
* Abime: A-D, D1, S6, S8
* Appelle: FINDF
* Niveaux: 3
* Detail: GRAPHILE n'est cherche qu'en :MAIN. FINDGR ne
*   declenche pas d'erreur automatiquement.
* Historique:
*   86/08/22: reprogrammation
************************************************************

=FINDGR LCASC  'ELIHPARG'
	A=C    W	A(W) := "GRAPHILE"
	D=0    S	D(S) := chercher en :MAIN uniquement
	GOSBVL =FINDF
*
* En sortie de FINDF, Cy = 1 signifie que le fichier n'est
* pas trouve. Alors, C(3-0) = le numero de l'erreur (File
* Not Found).
*
	GOC    FNDG10	pour avoir RTNCC, interface homogene
*
* Le fichier est trouve. Mettons l'adresse du debut de la
* partie "donnees" a l'adresse GRAFIL.
*
	AD1EX		A(A) := ^ en-tete de GRAPHILE
	D1=A
	C=0    A	} C(A) := 37+5
	LC(2)  37+5	}
	A=A+C  A	A(A) := ^ debut du graphique
	CD1EX		C(A) := ^ en-tete de GRAPHILE
	D1=(5) =GRAFIL
	DAT1=A A	(GRAFIL) := ^ debut du graphique
	D1=C		D1 := ^ en-tete de GRAPHILE
	RTNSC		GRAPHILE est trouve
 FNDG10 RTNCC

************************************************************
* INIBUF
*
* But: Trouver l'adresse du buffer, et la mettre dans BUFFER
* Entree: -
* Sortie:
*   - Cy = 1 : bDRIVR est trouve
*      C(A) = D1 = (BUFFER) = ^ bDRIVR
*   - Cy = 0 : bDRIVR n'est pas trouve
* Abime: A, C(A), C(S), D1
* Appelle: IOFND0
* Niveaux: 1
* Historique:
*   86/08/22: reprogrammation
************************************************************

=INIBUF LC(3)  =bDRIVR
	GOSBVL =IOFND0
	RTNNC		bDRIVR n'a pas ete trouve
*
* Le buffer bDRIVR a ete trouve, la carry vaut 1
*
	CD1EX		C(A) := ^ bDRIVR
	D1=(5) =RBUF
	DAT1=C A	(BUFFER) := ^ bDRIVR
	D1=C		D1 := ^ bDRIVR
	RTNSC		Le "SC" n'est pas necessaire

	STITLE Routines de traitement des polls
************************************************************
* GRAPOL
*
* But: traiter les polls interceptes par le driver RASTER.
* Entree:
*   - B(B) = numero du poll
* Sortie: depend de chaque poll
* Abime: 
* Appelle: 
* Niveaux: 
* Detail: 
* algorithme:
* Historique:
*   86/08/22: reprogrammation
*   89/06/18: integration ds JPC Rom et unification des poll
************************************************************

=GRAPOL LC(2)  =pCONFG
	?B=C   B
	GOYES  hCONFG
	LC(2)  =pGRAPH
	?B=C   B
	GOYES  hGRPH0
	RTNSXM

 hGRPH0 GOTO   hGRAPH

************************************************************
* hCONFG
*
* But: traiter le poll pCONFG, restaurer le buffer de la
*   destruction automatique a la configuration.
* Entree: -
* Sortie: -
* Abime: A, C, D1
* Appelle: I/ORES
* Niveaux: 2
* Historique:
*   86/08/22: reprogrammation
*   89/18/06: unification des polls du maitre et de raster
************************************************************

 hCONFG LC(3)  =bDRIVR
	GOSBVL =I/ORES	Preserver le buffer a la config.
	LC(3)  =bMAIN
	GOSBVL =I/ORES
	RTNSXM

	STITLE Traitement du poll graphique
************************************************************
* hGRAPH
*
* But: traiter les requetes du poll graphique
* Entree:
*   - A(B) = numero de la requete
*   - D(W) = parametre de la requete :
*	prINIT : D(W) = nom du graphique
*	prEND, prDBUT et prFIN : D(B) = numero du graphique
* Sortie:
*   - depend de chaque poll
* Historique:
*   86/08/22: reprogrammation pour n'avoir qu'un seul poll
************************************************************

 hGRAPH A=A-1  B	A(B) = numero de la requete
	GOC    INIT	prINIT
	A=A-1  B
	GOC    END0	prEND
	A=A-1  B
	GOC    DBUT0	prDBUT
	LC(2)  =gRAST	prFIN
	?C=D   B
	GOYES  FIN
	RTNSXM		Cy = 0, le poll n'est pas intercepte
 FIN	XM=0
	RTNCC

 END0	GOTO   END
 DBUT0	GOTO   DBUT

************************************************************
* INIT
*
* But: traiter la requete prINIT venant du module maitre,
*   creer le fichier GRAPHILE, allouer le buffer bDRIVR et
*   mettre les valeurs par defaut.
* Entree:
*   - D(W) = nom du graphique demande, cadre a gauche avec
*     des octets nuls, en majuscule.
*   - S-R1-0 = argument fourni a GINIT. Nul si pas d'arg.
* Sortie:
*   - D(B) = numero du graphique (gRAST)
* Abime: A-D, D0, D1, R0, R1, S-R0-0, S-R0-1, ST, SCRTCH
* Appelle: I/OALL, FINDGR, PRGFMF, AMPY, CRETF+, WIPOUT,
*   INIBUF DF000, I/ODAL
* Niveaux: 6 (PRGFMF)
* Algorithme:
*   1: si type # "RASTER" alors retour ;
*   2: allouer le buffer bDRIVR ;
*   2.1: si pas assez de place, alors retour avec erreur ;
*   3: si GRAPHILE existe alors le purger ;
*   4: si l'argument est nul alors retour avec erreur ;
*   5: creer GRAPHILE ;
*   5.1: si erreur alors retour avec erreur ;
*   6: initialiser GRAPHILE ;
*   7: initialiser le buffer ;
*   8: retour a l'appelant avec gRAST
*   retour avec erreur: desallouer le buffer ;
* Historique:
*   86/08/22: reprogrammation
************************************************************

 INIT
*
* 1: si type # "RASTER" alors retour ;
*
	C=0    W
	LCASC  'RASTER' Type "RASTER"
	?C=D   W
	GOYES  INIT10
	RTNSXM		retour
*
* 2: allouer le buffer bDRIVR ;
*
 INIT10 C=0    A
	LC(3)  =bDRVRs	C(A) := taille du buffer bDRIVR
	B=C    A	B(A) := taille du buffer bDRIVR
	LC(3)  =bDRIVR	C(A) := identificateur du buffer
	GOSBVL =I/OALL
	GOC    INIT20
*
* 2.1: si pas assez de place alors retour avec erreur ;
*
	XM=0		Poll intercepte
	RTNSC		Cy = 1	==>  erreur
*
* 3: si GRAPHILE existe alors le purger ;
*
 INIT20 GOSUB  =FINDGR	Chercher GRAPHILE sans detection
	  *		d'erreur
	GONC   INIT30	GRAPHILE n'existe pas
    if JPCPRV
	GOSBVL	=PRGFMF
    else
	GOSBVL =MGOSUB
	CON(5) =PRGFMF
    endif
*
* 4: si l'argument est nul alors retour avec erreur ;
*
 INIT30 D0=(5) =S-R1-0	Arg fourni a GINIT <type> [, <arg>]
	A=DAT0 A	A(A) := argument
	?A#0   A
	GOYES  INIT35
*
* L'argument est nul, il faut sortir avec une erreur et
* desallouer le buffer.
*
	C=0    A
	LC(2)  =eIVARG	"Invalid Arg"
*
* Retour avec erreur ;
*
 INITer RSTK=C		RSTK := numero d'erreur
	LC(3)  =bDRIVR
	GOSBVL =I/ODAL	Desallocation du buffer
	C=RSTK		C(A) := numero d'erreur
	XM=0
	RTNSC		Retour avec erreur
*
* 5: creer GRAPHILE ;
*
 INIT35	 *		A(A) = argument
	C=0    A
	LC(2)  (=npixls)/4     640 points = 160 quartets
	GOSUB  =AMPY
	C=0    A
	LC(2)  37+5
	C=C+A  A	Longueur totale du fichier
	D=0    S	Creer GRAPHILE en :MAIN
	GOSBVL =CRETF+
*
* 5.1: si erreur alors retour avec erreur ;
*
	GOC    INITer	erreur lors de la creation
*
* 6: initialiser GRAPHILE
*
	C=R1		C(A) := ^ debut du fichier
	D1=C		D1 := ^ debut du fichier
	LCASC  'ELIHPARG'
	DAT1=C W	nom du ichier := GRAPHILE
	D1=D1+ 16	D1 := ^ type du fichier
	C=0    M
	LC(4)  =fGRAPH
	DAT1=C 6	Type + Flags + Copy Code
	D1=D1+ 16
	D1=D1+ 5	D1 := ^ nombres de lignes
	D0=(5) =S-R1-0
	A=DAT0 A	A(A) := argument
	DAT1=A A	nombres de lignes := argument
	D1=D1+ 5	D1 := ^ debut de la zone graphique
	C=0    A
	LC(2)  (=npixls)/4
	GOSUB  =AMPY
	GOSBVL =WIPOUT	fichier initialise avec des '0'
*
* 7: initialiser le buffer
*
	D0=(5) =GRAFIL
	LC(5)  5+=S-R1-0
	DAT0=C A
	GOSUB  =INIBUF
	GOSUB  =DF000	initialisation automatique du buffer
*
* 8: retour a l'appelant avec gRAST
*
	LC(2)  =gRAST
	D=C    A	D(B) := gRAST
	XM=0		poll intercepte
	RTNCC		... sans erreur

************************************************************
* END
*
* But: traiter la fin d'une session graphique, purger
*   GRAPHILE et desallouer le buffer.
* Entree:
*   - D(B) = numero du graphique
* Sortie:
*   - Cy = 0 : pas d'erreur
*   - Cy = 1 : erreur, C(A) = numero d'erreur
* Abime: A-D, D0, D1, D0, R1, S-R0-0, S-R0-1, ST
* Appelle: I/ODAL, FINDGR, PRGFMF
* Niveaux: 6 (PRGFMF)
* Historique:
*   86/08/22: reprogrammation
************************************************************

 END	LC(2)  =gRAST
	?C=D   B
	GOYES  END10
	RTNSXM		C'est pas moi !
 END10	LC(3)  =bDRIVR
	GOSBVL =I/ODAL
	GOSUB  =FINDGR
	GONC   END20	Non trouve, donc pas a purger
    if JPCPRV
	GOSBVL =PRGFMF
    else
	GOSBVL =MGOSUB
	CON(5) =PRGFMF
    endif
 END20	XM=0
	RTN

************************************************************
* DBUT
*
* But: si le type de graphique demande est bien gRAST,
*   initialise le driver.
* Entree:
*   - D(B) = type du graphique
* Sortie:
*   - D(A) = adresse du driver (GRAPHx)
* Abime: 
* Appelle: FINDGR, INIBUF
* Niveaux: 
* Detail:
*   Le mecanisme des polls est trop lent pour assurer la
*   communication efficace entre le module maitre et le
*   driver. Ce poll est donc envoye pour debuter une
*   sequence d'ordres HPGL.
* Historique:
*   86/08/22: reprogrammation
************************************************************

 DBUT	LC(2)  =gRAST
	?C=D   B
	GOYES  GRPH10
	RTNSXM
*
* Le driver, c'est nous. Alors, on s'initialise...
*
 GRPH10 GOSUB  =FINDGR	Ca commence par cherhcer GRAPHILE
	GOC    GRPH20
*
* GRAPHILE n'est pas trouve. Panique !
*
	LC(4)  (=graid)~(=eGHILE)	"GRAPHILE not found"
 GRPHer XM=0		poll intercepte, mais...
	RTNSC		... erreur
 GRPH20 GOSUB  =INIBUF	et le buffer, maintenant ?
	LC(4)  (=graid)~(=eSVRER)	"Severe error"
	GONC   GRPHer
*
* Tout est Ok. Il faut renvoyer l'adresse du driver
*
	GOSUB  GRPH30
 GRPH30 C=RSTK
	D=C    A	D(A) := ^ GRPH30
	LC(5)  (GRAPHx)-(GRPH30)
	D=D+C  A	D(A) := ^ GRAPHx
	XM=0		poll intercepte...
	RTNCC		... sans erreur


************************************************************
* GRAPHx
*
* But: c'est le driver HPGL pour les graphiques de type
*   "RASTER". C'est la routine appelee par le module maitre
*   pour chaque ordre HPGL.
* Entree:
*   - A(B) = ordre HPGL
* Abime: C(A), D0
* Appelle: FINDA
* Niveaux: 1
* Detail:
*   GRAPHx est le point d'entree dans le module "RASTER"
*   pour envoyer des ordres HPGL. C'est en fait un
*   aiguillage vers chacune des routines de traitement des
*   ordres HPGL.
* Historique:
*   86/08/22: reprogrammation
************************************************************

 GRAPHx GOSBVL =FINDA
	CON(2) =nOP	Output P1 & P2
	REL(3) =OP000
	CON(2) =nOA	Output Actual position
	REL(3) =OA000
	CON(2) =nOE	Output Error
	REL(3) =OE000
	CON(2) =nIW	Input Window
	REL(3) =IW000
	CON(2) =nIP	Input P1 & P2
	REL(3) =IP000
	CON(2) =nSP	Select Pen
	REL(3) =SP000
	CON(2) =nDF	DeFault
	REL(3) =DF000
	CON(2) =nTL	Tick Len
	REL(3) =TL000
	CON(2) =nPA	Plot Absolute
	REL(3) =PA000
	CON(2) =nPD	Pen Down
	REL(3) =PD000
	CON(2) =nPU	Pen Up
	REL(3) =PU000
	CON(2) =nDI	DIrection
	REL(3) =DI000
	CON(2) =nSI	character SIze
	REL(3) SI010
	CON(2) =nSL	character SLant
	REL(3) SL000
	CON(2) =nLB	LaBel
	REL(3) LB010
	CON(2) =nCP	Character Plot
	REL(3) CP010
	CON(2) =nXT	X Tick
	REL(3) =XT000
	CON(2) =nYT	Y Tick
	REL(3) =YT000
	CON(2) =nLT	Line Type
	REL(3) =LT000
	CON(2) =nDU	Dump graphics
	REL(3) =DU000
	NIBHEX 00
	LC(4)  (=graid)~(=eSVRER)	"Severe Error"
	GOVLNG =BSERR

 SI010	GOLONG =SI000
 LB010	GOLONG =LB000
 CP010	GOLONG =CP000
 SL000	RTN

	END
