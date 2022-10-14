	TITLE  ROMANLEX <roman.as>
*
* Premiere ecriture par Francois Legrand
* JPC:B03
*   87/12/13: PD/JT Suppression appel a IOCND0 non supporte
*   87/12/13: PD/JT Structuration du code
*   87/12/13: PD/JT Simplification et compactage du code
* JPC:C01
*   88/02/06: PD/JT Correction du bug a l'allumage
*

*
* CHRid est l'id du jeu de caractere dans le cas ou
* le buffer ne contient qu'une adresse (et non un
* jeu de caractere complet).
*
 CHRid	EQU    1

 noroom LC(2) =eMEM	Insufficient memory
 mferr	GOVLNG =BSERR

****************************************************
* ROMon
*
* But : activer le jeu ROMAN extension
* Entree : -
* Sortie : par NXTSTM
* Algorithme :
*   chercher le buffer
*   si il n'existe pas
*     alors
*       le creer
*     sinon
*	si sa longueur est # 7
*         alors
*           etendre le buffer de 7 quartets
*           deplacer le jeu existant
*       fin si
*   fin si
*   initialiser les 7 quartets
*   sortir par NXTSTM
* Historique :
*   86/../.. : FL	conception & tricotage
*   87/12/13 : PD & JT	reecriture
****************************************************

 ROMon
*
* chercher le buffer
*
	GOSUB  cbuff	C(X) := buffer id
	GOSBVL =IOFND0	D1 = ^ buffer, A(A) = long
	GOC    on10	Buffer present
*
* si le buffer n'existe pas
*   alors
*     le creer
*
	GOSUB  cbuff	Longueur := 7
	GOSBVL =I/OALL
	GONC   mferr    Probleme !
	GOC    on50	B.E.T. fin
*
*   sinon
*     si sa longueur est # 7
*       alors
*
 on10   GOSUB  long=7	Longueur = 7 ?
	GOC    on50	Rien a faire si longueur = 7
*
*         etendre le buffer de 7 quartets
*
	GOSUB  cbuff
	GOSBVL =I/OEXP  agrandir le buffer
	GONC   noroom	Probleme ! Sortir
*
*         deplacer le jeu existant
*
	CDEX   A        ouvrir un espace vide
	CD1EX           en debut du buffer
	D1=D1+ 7
	GOSBVL =MOVED2
	D1=D1- 7	D1 := ^ debut des donnees
 on50
*
*     fin si
* fin si
* initialiser les 7 quartets
*
	GOSUB  =DAT1BF	etablir les 7 premiers
	D1=D1+ 5        nibbles du buffer afin
	LC(2)  CHRid    d'etablir le jeu de
	DAT1=C B        carateres etendus
	D1=D1- 12
	LC(1)  1        une adresse a actualiser
	DAT1=C 1
 nxtstm GOVLNG =NXTSTM


****************************************************
* ROMANe
*
* But : executer l'ordre ROMAN
* Syntaxe : ROMAN ON | OFF
* Historique :
*   86/../.. : FL	conception & codage
*   87/12/13 : PD & JT	eclaircissement
****************************************************

	REL(5) =ROMANd
	REL(5) =ROMANp

=ROMANe A=DAT0 B        A(B):= tON ou tOFF
	LC(2)  =tON
	?A=C   B
	GOYES  ROMon	ROMAN ON

*
* Attention ! Le code continue
*

****************************************************
* ROMoff
*
* But : activer le jeu ROMAN extension
* Entree : -
* Sortie : par NXTSTM
* Algorithme :
*   chercher le buffer
*   si il existe
*     alors
*	si sa longueur > 7
*         alors
*           deplacer le jeu existant
*	    contracter le buffer de 7 quartets
*	  sinon
*	    si il a le bon CHRid
*             alors
*               detruire le buffer
*	    fin si
*       fin si
*   fin si
*   sortir par NXTSTM
* Historique :
*   86/../.. : FL	conception & tricotage
*   87/12/13 : PD & JT	reecriture
****************************************************

*
* Attention ! Le code continue
*

 ROMoff
*
* chercher le buffer
*
	GOSUB  cbuff	C(X) := buffer id
	GOSBVL =IOFND0	D1 = ^ buffer, A(A) = long
*
* si il existe
*
	GONC   off50	buffer non trouve 
*
*   alors
*     si sa longueur > 7
*
	GOSUB  long=7
	?A<=C  A	?A>7
	GOYES  off20
*
*       alors
*         deplacer le jeu existant
*
	A=A-C  A	A(A) := longueur a deplacer
	B=A    A	B(A) := block length
	AD1EX
	D1=A		D1 := ^ destination
	A=A+C  A	A(A) := D1+7
	D0=A		D0 := ^ source
	GOSBVL =MOVEU0
*
*         contracter le buffer de 7 quartets
*
	GOSUB  cbuff
	GOSBVL =I/OCON
	D0=D0- 1	D0 := ^ # update addr.
	C=0    A
	DAT0=C 1
	GOTO   off50
*
*       sinon
*         si il a le bon CHRid
*
 off20	GOSUB  chrid?
	GOC    off50
*
*	    alors
*	      detruire le buffer
*
	GOSUB  cbuff	C(X) := buffer id
	GOSBVL =I/ODAL
*
*	  fin si
*     fin si
* fin si
*
 off50	GOTO   nxtstm

****************************************************
* CHKBUF
*
* But : cherche si le buffer est bien a nous
* Entree :
*   - C(X) = id du buffer
* Sortie :
*   - Cy = 0 : buffer est a nous
*   - Cy = 1 : buffer n'est pas a nous
* Abime : A(A), C(A), C(S), D1
* Appelle : IOFND0, long=7, chrid (tombe dedans)
* Niveaux : 1
* Note :
*   "Buffer a nous" signifie :
*   - qu'il existe
*   - que sa longueur = 7
*   - et que l'Id contenu ds le buffer est le notre
* Historique :
*   86/../.. : FL	conception & codage
*   87/12/13 : PD & JT	eclaircissement
*   88/02/16 : PD & JT	ajout de documentation
*   88/02/16 : PD & JT	fixer le bug a l'extinction
****************************************************

 chkno	RTNSC		Echec

=CHKBUF	GOSBVL =IOFND0	D1 := ^ adresse du buffer
	GONC   chkno	Non trouve
* A(A) = longueur du buffer
* D1 = ^ apres le buffer header
	GOSUB  long=7
* Correction du 6 fevrier 1988
        GONC   chkno	Non : Cy = 0
*
* Attention ! Le code continue !
*

****************************************************
* chrid?
*
* But : teste le no du jeu etendu dans le buffer
* Entree :
*   - D1 = ^ debut des donnees du buffer (IOFND0)
* Sortie :
*   - Cy = 1 si different
*   - Cy = 0 si ok
* Abime : A(B), C(B)
* Niveaux : 0
* Historique :
*   86/../.. : FL	conception & codage
*   87/12/13 : PD & JT	eclaircissement
****************************************************

*
* Attention ! Le code continue
*
 chrid? D1=D1+ 5        pointe le numero du buffer
	A=DAT1 B        le charge dans A[B]
	D1=D1- 5        D1 a sa valeur initiale
	LC(2)  CHRid    C[B] = buffer a chercher
	?A#C   B        teste l'egalite
	RTNYES		Cy := 1 si #
	RTN		Cy := 0 si =

****************************************************
* cbuff
*
* But : charger l'Id du buffer dans C(X) et la
*   longueur dans B(A), pour preparer I/OEXP
* Entree : -
* Sortie :
*   - C(X) = id du buffer bCHARS
*   - B(A) = 7
* Abime : C(A), B(A)
* Niveaux : 0
* Historique :
*   86/../.. : FL	conception & codage
*   87/12/13 : PD & JT	eclaircissement
****************************************************

 cbuff  C=0    A
	LC(1)  7
	B=C    A        B(A) := longueur (7)
	LC(3)  =bCHARS  C(X) := id du buffer
	RTN

****************************************************
* long=7
*
* But : tester si A(A) = 7
* Entree :
*   - A(A) = valeur a tester
* Sortie :
*   - Cy = 1 : A(A) = 7
*     Cy = 0 : A(A) # 7
*   - C(A) = 7
* Abime : C(A)
* Niveaux : 0
* Historique :
*   87/12/13 : PD & JT	conception & codage
****************************************************

 long=7	C=0    A
	LC(1)  7
	?A=C   A
	RTNYES		Cy = 1 si A=7
	RTN

****************************************************
* DAT1BF
*
* But : stocker l'adresse de la table contenant le
*   jeu de caracteres Roman Extension.
* Entree :
*   - D1 = ^ endroit ou sera stocke le resultat
* Sortie :
*   - Mem(D1) = adresse de la table
* Abime : C, Mem(D1)
* Appelle : c=adr
* Niveaux : 1
* Historique :
*   86/../.. : FL	conception & codage
*   87/12/13 : PD & JT	eclaircissement
****************************************************

=DAT1BF GOSUB  stocke
	CON(3) (fin)-(debut)
 debut
	NIBHEX F0204FF80F00	CHR$(128)
	NIBHEX 3151DF028F00	CHR$(129)
	NIBHEX 3151DD028D00	CHR$(130)
	NIBHEX F1515D028D00	CHR$(131)
	NIBHEX F151110F0100	CHR$(132)
	NIBHEX F15F190D0F00	CHR$(133)
	NIBHEX E050EF020D00	CHR$(134)
	NIBHEX 07E43CE40700	CHR$(135)
	NIBHEX F151A98A8E00	CHR$(136)
	NIBHEX F140F10F0100	CHR$(137)
	NIBHEX F0808F050100	CHR$(138)
	NIBHEX 7080710F0100	CHR$(139)
	NIBHEX F0501F050100	CHR$(140)
	NIBHEX F0909F868B00	CHR$(141)
	NIBHEX 3151DF888F00	CHR$(142)
	NIBHEX 3151D1008F00	CHR$(143)
	NIBHEX F090600F0800	CHR$(144)
	NIBHEX F09060018F00	CHR$(145)
	NIBHEX F090EC8A8B00	CHR$(146)
	NIBHEX F090E88A8F00	CHR$(147)
	NIBHEX F09066058F00	CHR$(148)
	NIBHEX F020FF020D00	CHR$(149)
	NIBHEX 3151D30C0300	CHR$(150)
	NIBHEX F1519F8A0500	CHR$(151)
	NIBHEX F09F92040F00	CHR$(152)
	NIBHEX F1511F020F00	CHR$(153)
	NIBHEX 3151DF8A0500	CHR$(154)
	NIBHEX F1511F090900	CHR$(155)
	NIBHEX F150998A8E00	CHR$(156)
	NIBHEX F090998A8E00	CHR$(157)
	NIBHEX F1D0798A8E00	CHR$(158)
	NIBHEX F080F98A8E00	CHR$(159)
	NIBHEX 000000000000	CHR$(160)
	NIBHEX 875161418700	CHR$(161)
	NIBHEX 876151618700	CHR$(162)
	NIBHEX C75565454500	CHR$(163)
	NIBHEX C76555654500	CHR$(164)
	NIBHEX C75545554500	CHR$(165)
	NIBHEX 0064D7640000	CHR$(166)
	NIBHEX 0054C7540000	CHR$(167)
	NIBHEX 000020100000	CHR$(168)
	NIBHEX 001020000000	CHR$(169)
	NIBHEX 002010200000	CHR$(170)
	NIBHEX 001000100000	CHR$(171)
	NIBHEX 002010201000	CHR$(172)
	NIBHEX C3142404C300	CHR$(173)
	NIBHEX C3241424C300	CHR$(174)
	NIBHEX 45E755142400	CHR$(175)
	NIBHEX 101010101000	CHR$(176)
	NIBHEX 000000000000	CHR$(177)
	NIBHEX 000000000000	CHR$(178)
	NIBHEX 205020000000	CHR$(179)
	NIBHEX E3141C142200	CHR$(180)
	NIBHEX 83444C444400	CHR$(181)
	NIBHEX C7A01122D700	CHR$(182)
	NIBHEX 87A090A01700	CHR$(183)
	NIBHEX 0000D7000000	CHR$(184)
	NIBHEX 038454040200	CHR$(185)
	NIBHEX D5222222D500	CHR$(186)
	NIBHEX 84E794142400	CHR$(187)
	NIBHEX 92A2C7A29200	CHR$(188)
	NIBHEX 02E455932000	CHR$(189)
	NIBHEX 0284E3902000	CHR$(190)
	NIBHEX 8344EF444400	CHR$(191)
	NIBHEX 026555658700	CHR$(192)
	NIBHEX 836555658100	CHR$(193)
	NIBHEX 836454648300	CHR$(194)
	NIBHEX 832414248700	CHR$(195)
	NIBHEX 024565558700	CHR$(196)
	NIBHEX 834565558100	CHR$(197)
	NIBHEX 834464548300	CHR$(198)
	NIBHEX C3042414C700	CHR$(199)
	NIBHEX 024555658700	CHR$(200)
	NIBHEX 835565458100	CHR$(201)
	NIBHEX 835464448300	CHR$(202)
	NIBHEX C3142404C700	CHR$(203)
	NIBHEX 025545558700	CHR$(204)
	NIBHEX 835545558100	CHR$(205)
	NIBHEX 835444548300	CHR$(206)
	NIBHEX C3140414C700	CHR$(207)
	NIBHEX 877151718700	CHR$(208)
	NIBHEX 00A497240000	CHR$(209)
	NIBHEX CB26A564D300	CHR$(210)
	NIBHEX E790F7949400	CHR$(211)
	NIBHEX 027555758700	CHR$(212)
	NIBHEX 0084A7140000	CHR$(213)
	NIBHEX 8B4645C4A300	CHR$(214)
	NIBHEX 424587458400	CHR$(215)
	NIBHEX 875141518700	CHR$(216)
	NIBHEX 0094A7040000	CHR$(217)
	NIBHEX C3342434C300	CHR$(218)
	NIBHEX E3140414E300	CHR$(219)
	NIBHEX C74565554500	CHR$(220)
	NIBHEX 0054C7140000	CHR$(221)
	NIBHEX EF1094946300	CHR$(222)
	NIBHEX 876858688700	CHR$(223)
	NIBHEX 874161518700	CHR$(224)
	NIBHEX 876151619700	CHR$(225)
	NIBHEX 026555659700	CHR$(226)
	NIBHEX 80F79414E300	CHR$(227)
	NIBHEX 0384A4F72000	CHR$(228)
	NIBHEX 0044E7540000	CHR$(229)
	NIBHEX 0054E7440000	CHR$(230)
	NIBHEX 874868588700	CHR$(231)
	NIBHEX 875868488700	CHR$(232)
	NIBHEX 836454649300	CHR$(233)
	NIBHEX 03A494A41300	CHR$(234)
	NIBHEX 855565554300	CHR$(235)
	NIBHEX 845565550200	CHR$(236)
	NIBHEX E3042414E300	CHR$(237)
	NIBHEX 609007906000	CHR$(238)
	NIBHEX C11A0A1AC700	CHR$(239)
	NIBHEX 18FF5A428100	CHR$(240)
	NIBHEX FF4444448300	CHR$(241)
	NIBHEX 000000000000	CHR$(242)
	NIBHEX 000000000000	CHR$(243)
	NIBHEX 000000000000	CHR$(244)
	NIBHEX 000000000000	CHR$(245)
	NIBHEX 808080808080	CHR$(246)
	NIBHEX 22F18645AF00	CHR$(247)
	NIBHEX 22F18CCAAB00	CHR$(248)
	NIBHEX 84555555E500	CHR$(249)
	NIBHEX E4151515E400	CHR$(250)
	NIBHEX 8041A2412200	CHR$(251)
	NIBHEX E7E7E7E7E700	CHR$(252)
	NIBHEX 2241A2418000	CHR$(253)
	NIBHEX 4444F5444400	CHR$(254)
	NIBHEX 000000000000	CHR$(255)
 fin

 stocke	C=RSTK		recupere l'adresse de la
	DAT1=C A	table et la stocke
	RTNCC

	END
