	TITLE  Routines de décompilation <decomp.as>
 
*
* JPC:A05
*   87/02/18: PD    Intégration de FKEY
*   87/03/03: PD/JT Intégration de POKE
*   87/03/03: PD/JT Intégration de STRUC2
* JPC:A06
*   87/04/18: PD/JT Refonte de SWAP
*   87/04/20: PD/JT Intégration de MAPLEX
*   87/05/01: PD/JT Changement de noms (FF -> PFF)
* JPC:B01
*   87/06/20: PD/JT Intégration de SYSEDIT
* JPC:B03
*   87/12/06: PD/JT Réécriture de INVERSE
*   87/12/06: PD/JT Intégration de KA
*   87/12/06: PD/JT Intégration de ADLEX
*   87/12/06: PD/JT DISABLE & ENABLE renommés en LEX
*   87/12/08: PD/JT Ajouté la décompile de "obsolete"
*   87/12/13: PD/JT Intégration de ROMANLEX
*   87/12/13: PD/JT Séparation de la parse
*   88/01/24: PD/JT Ajout de la parse de D/PBLIST
* JPC:C02
*   88/02/12: PD/JJD Ajout de la parse de D/PDIR
* JPC:D01
*   88/12/18: PD/JT Changement de la syntaxe de LEAVE
* JPC:D02
*   89/06/18: PD/JT Ajout de X/TEDIT
*   89/06/18: PD/JT Changement de syntaxe de FIND
*   89/06/18: PD/JT Changement de =decomp en =CRd, =FFd
*   89/06/18: PD/JT Intégration du module graphique
*

* MAP statement decompile routine
 
=MAPd	LCASC  '#'
	?A=C   B	#<channel>?
	GOYES  MAPd10	yes, DROPDC can handle it
	GOSBVL =FILDC*	decompile filespec
 MAPd10 GOVLNG =DROPDC	decompile expr list
 
*
* END WHILE / IF / LOOP / SELECT decompile
*
=END2d
	A=DAT1 B
	GOSUB  eolxck
	GOC    ENDWd	 trouve tEOL (ou equival)
	C=A    A	 C(0) := quartet lu
	D1=D1+ 1
	GOSBVL =TBLJMC
	REL(3) ENDLd
	REL(3) ENDSd
	REL(3) ENDId
 ENDId
	LCASC  'FI'
	P=     2*2-1
	GOTO   ENDd10
 ENDLd
	LCASC  'POOL'
	P=     2*4-1
	GOTO   ENDd10
 ENDSd
	LCASC  'TCELES'
	P=     2*6-1
	GOTO   ENDd10
 ENDWd
	LCASC  'ELIHW'
	P=     2*5-1
 ENDd10
 OUTASCII
	GOSUB  outnbc
	A=DAT1 B
*
* ATTENTION : le code continue !!!
*
=BELLd
=CRd
=ELSE2d
=FFd
=LOOPd
=REPEATd
=REPTd
=SLEEPd
	GOVLNG =OUTELA

**************************************************
* UNDERd
* But: decompiler UNDERLINE ON|OFF
**************************************************
=UNDERd LCASC  ' E'
	D0=D0- 2	Retour sur l'espace
	GOSBVL =OUT2TC	Affichage de "E"
	A=DAT1 B	Token suivant (ON/OFF)

**************************************************
* ONOFFd
* But: decompiler une alternative ON|OFF
**************************************************
=ATTNd
=ONOFFd
=ROMANd
	GOVLNG =TRACDC	Decompilation du token


**************************************************
* PLd, NUMd
* But: decompiler un ordre suivi d'une suite
* d'expressions numeriques.
**************************************************

=BOXd
=CSIZEd
=DMYd
=DRAWd
=ENDUPd
=ENDUPd
=EXECUTEd
=FKEYd
=FRAMEd
=GDUMPd
=GENDd
=GINITd
=GLINEd
=GPSETd
=IDRAWd
=IMOVEd
=INVERSEd
=LABELd
=LDIRd
=LEAVEd
=LINETYPEd
=LORGd
=MARGINd
=MDYd
=MOVEd
=NUMd
=PAGELENd
=PENDOWNd
=PENUPd
=PENd
=PLFd
=POKEd
=SELECTd
=STACKd
=SWAPd
=SYSEDITd
=TICLENd
=UNTILd
=WHILEd
=XAXISd
=YAXISd
	GOVLNG =DROPDC	Aucun param.: autorise

************************************************************
* EXITd
*
* EXIT <var>
************************************************************

=EXITd	GOSBVL =VARDC
	GOVLNG =OUTEL1

************************************************************
* LEXONd / LEXOFFd
*
* LEX <file> ON|OFF
************************************************************

=LEXONd
	GOSBVL =FILDC*	Decompile <filespec>
	LCASC  'NO '
	P=     2*3-1
	GOTO   OUTASCII
=LEXOFFd
	GOSBVL =FILDC*	Decompile <filespec>
	LCASC  'FFO '
	P=     2*4-1
	GOTO   OUTASCII

=KAd
=RENUMREMd
=SHRINKd
	GOVLNG =LISTDC

PACKd	EQU    #7B4A

**************************************************
* WRECd
*
* WREC <exp alpha> , <exp alpha> , <device>
**************************************************

=WRECd	GOSBVL =EXPRDC
	LCASC  ','
	GOSBVL =OUTBY+
	GOSBVL =EXPRDC
	LCASC  ','
	GOSBVL =OUTBY+
	GOSUBL =JUMPER
	CON(5) PACKd
	RTN

=PLOTTERd
	GOSUBL =JUMPER
        CON(5) #7B3E    PRNTSd
        RTN

************************************************************
* FINPUTd
*
* FINPUT <var alpha> , <exp ou var alpha> ,
*		[<exp ou var alpha> ,] <var num>
************************************************************

 virgud LCASC  ','
	GOVLNG =OUTBY+

=FINPUTd
	GOSUB  exprdc
	GOSUB  virgud
	GOSUB  exprdc
	GOSUB  virgud
	D1=D1+ 1
	GOSUB  exprdc
	GOSBVL =EOLXC*
	GOSUB  virgud
	GOSUB  exprdc
	GOVLNG =OUTEL1

 exprdc GOVLNG =EXPRDC

************************************************************
* STRUC2
*
************************************************************

=IF2d
	GOSUB  exprdc
	LCASC  'NEHT '
	P=     2*5-1
	GOTO   ENDd10

 eolxck GOVLNG =EOLXCK

=CASEd
	GOSUB  eolxck
	GONC   CSd10
	LCASC  'ESLE'
	P=     4*2-1
	GOTO   ENDd10
 CSd10
	A=DAT1 X
	LC(2)  =tRELOP
	?A#C   B
	GOYES  CSd20
*
* <relop> trouve. Il faut le sortir en ASCII
*
	GOSBVL =ARITH
	GOSUB  outnbc
	D1=D1+ 3
	GONC   CSd30	B.E.T.
*
* <relop> n'existe pas. Il faut decompiler une
* expression, puis voir ce qu'il y a apres...
*
 CSd20
	GOSUB  exprdc
	LC(2)  =tTO
	?A#C   B
	GOYES  CSd40	c'est donc tCOMMA ou EOL
*
* TO : on s'attend donc maintenant a une exp.
*
	LCASC  ' OT '
	P=     4*2-1
	GOSUB  outnbc

	D1=D1+ 2
 CSd30
	A=DAT1 B
	GOSUB  exprdc
 CSd40
	GOSBVL =EOLXC*
*
* Si on est revenu, c'est qu'il y a une tCOMMA
*
	LCASC  ','	on l'envoie...
	P=     2*1-1	... dans le flot
	GOSUB  outnbc	... de sortie
	D1=D1+ 2	on l'oublie...
	GOTO   CSd10	... et on continue

 outnbc GOVLNG =OUTNBC

************************************************************
* ADLEX
*
* Historique:
*   86/08/05: conception & codage
************************************************************

 fichid GOVLNG =FILDC*
 arrayd GOVLNG =VARDC

=ADCREATEd
=TEDITd
=XEDITd
	GOSUB  fichid

 passwd GOSBVL =EOLXC*
	GOSUB  virgud
	GOSUB  exprdc
	GOVLNG =OUTEL1

=ADDELETEd
	GOSUB  fichid
	GOSUB  virgud
	GOSUB  exprdc
	GOTO   passwd

=ADGETd GOSUB  fichid
	GOSUB  virgud
	GOSUB  arrayd
	GOSUB  virgud
	GOSUB  exprdc
	GOTO   passwd

=ADPUTd GOSUB  fichid
	GOSUB  virgud
	GOSUB  arrayd
	GOTO   passwd

************************************************************
* obsoleted
*
* But : decompiler un token obsolete
* Principe : positionner D1 a la fin de la chaine tokenisee
************************************************************

=obsoleted
	D1=D1- 6+2	D1 := ^ Stlen
	C=0    A
	C=DAT1 B	C(A) := lg de la chaine tokenisee
	AD1EX
	A=A+C  A
	D1=A
	A=DAT1 B	Pour OUTELA
	GOVLNG =OUTELA

****************************************************
* DBLISTd, PBLISTd
*
* But : decompiler DBLIST, PBLIST, RENUMREM
* Historique :
*   86/05/.. : JPB     conception & codage
*   88/01/10 : PD & JT nouvelle syntaxe
****************************************************

=DBLISTd
=PBLISTd
	ST=0   8	Premiere fois : pas de ','
*
* Boucle de decompilation des elements
* A l'entree, D1 pointe sur le token a decompiler.
* Les alternatives sont :
*   <file spec>
*   [ , <line #> ]    (S8=1 si affichage ',')
*   TO <file spec>
*   INDENT <exp num>
*
 LSTD00 GOSBVL =EOLXC*	No return if end of statem.
	GOSBVL =FINDA
	CON(2) =tCOMMA	<line#>		(LSTDC+)
	REL(3) LSTD10
	CON(2) =tTO	TO <file>
	REL(3) LSTD20
	CON(2) =tXWORD	INDENT <exp num>
	REL(3) LSTD30
	NIBHEX 00
*
* <file spec>
*
	GOSBVL =FILDC*
 LSTD05 ST=1   8
	GOTO   LSTD00

*
* [ , ] <line#>
*
 LSTD10 ?ST=0  8	Besoin de sortir ',' ?
	GOYES  LSTD12	Non
	LCASC  ','	Affichage de ','
	GOSBVL =OUTBYT
 LSTD12 D1=D1+ 2	Passer tCOMMA
	GOSBVL =LIN#DC	Envoyer <line#>
	GOTO   LSTD05

*
* TO <file spec>
*
 LSTD20 GOSUB  OUTSPC
	LCASC  ' OT'
	P=     3*2-1
	GOSBVL =OUTNBC
	D1=D1+ 2
	GOSBVL =FILDC*
	GOTO   LSTD05

*
* INDENT <exp num>
*
 LSTD30 GOSUB  OUTSPC
	LCASC  ' TNEDNI'
	P=     7*2-1
	GOSBVL =OUTNBC
	D1=D1+ 6
	GOSBVL =EXPRDC
	GOTO   LSTD05

****************************************************
* OUTSPC
*
* But : afficher un espace si TO ou INDENT ne
*   suivent pas directement D/PBLIST.
* Entree :
*   - S8 = 0 si directemenbt derriere D/PBLIST
* Sortie :
*   - un blanc dans le flot ASCII
* Appelle : OUTBYT
* Utilise : A(B), C(B), D0
* Niveaux : 1
* Historique :
*   88/01/10: PD & JT conception & codage
****************************************************

 OUTSPC ?ST=0  8
	RTNYES
	LCASC  ' '
	GOVLNG =OUTBYT

****************************************************
* PDIR / DDIR
****************************************************

=DDIRd
=PDIRd  GOSBVL  =EOLXC*
        LC(2)   =tTO
        ?A=C    B
        GOYES   DIRd10
        LC(2)   =tALL
        ?A=C    B
        GOYES   DIRd30
        GOSBVL  =FILDC* PDIR <filespec> ...
        GOSBVL  =BLNKCK
        GOSBVL  =EOLXC*
DIRd10  ST=1    9       ... TO ...
        GOSBVL  =GTEXT1
        GOSBVL  =FILDC* ... <filespec> ...
        GOVLNG  =OUTEL1 ... et on a fini !

DIRd30  ST=1    9       PDIR ALL ...
        GOSBVL  =GTEXT1
        GOTO    =PDIRd  Peut-etre y-a-t'il un TO ?

	END
