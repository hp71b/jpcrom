	TITLE  Routines de parse <parse.as>
 
*
* JPC:A05
*   87/02/18: PD Integration de FKEY
*   87/03/03: PD/JT Integration de POKE
*   87/03/03: PD/JT Integration de STRUC2
* JPC:A06
*   87/04/18: PD/JT Refonte de SWAP
*   87/04/20: PD/JT Integration de MAPLEX
*   87/05/01: PD/JT Changement de noms (FF -> PFF)
* JPC:B01
*   87/06/20: PD/JT Integration de SYSEDIT
* JPC:B03
*   87/12/06: PD/JT Reecriture de INVERSE
*   87/12/06: PD/JT Integration de KA
*   87/12/06: PD/JT Integration de ADLEX
*   87/12/06: PD/JT DISABLE & ENABLE renommes en LEX
*   87/12/08: PD/JT Ajout de la decompile de "obsolete"
*   87/12/13: PD/JT Integration de ROMANLEX
*   87/12/13: PD/JT Separation de la decompilation
*   88/01/24: PD/JT Ajout de D/PBLIST
* JPC:C02
*   88/02/12: PD/JJD Ajout de D/PDIR
* JPC:D01
*   88/12/18: PD/JT Changement de syntaxe de LEAVE
*   88/12/18: PD/JT Changement de syntaxe de POKE
*   88/12/18: PD/JT Changement de syntaxe de SYSEDIT
* JPC:D02
*   89/06/18: PD/JT Ajout de X/TEDIT
*   89/06/18: PD/JT Changement de syntaxe de FIND
*   89/06/18: PD/JT Changement de =parse en =CRp, =FFp
*   89/06/18: PD/JT Intégration du module graphique
*

************************************************************
* MAP
*
* MAP #<canal> , <ch1> , <ch2> [, <exp1> [, <exp2>] ]
* MAP <file> , <ch1> , <ch2> [, <exp1> [, <exp2>] ]
************************************************************
 
=MAPp	GOSBVL =#CK	#?
	GOC    pfsp	no, try filespec
	GOSBVL =OUT1T+	output # token
	GOSUB  numck	channel no. (num expr)
	GONC   pstr1
 pfsp	GOSBVL =FSPECp	parse filespec
	GOC    badf	invalid filespec
	GOSBVL =NTOKEN	get next token
 pstr1	GOSBVL =COMCK+	comma? -> output token
	GONC   syntx	no, syntax error
	GOSBVL =STRNGP	<str1>
* the following commas are not tokenized, so that
* one call of EXPEXC will evaluate all parameters left
* DROPDC will insert commas between them by default
	GOSUB  comcK	comma?
	GONC   syntx	no, syntax error
	GOSBVL =STRNGP	<str2>
	GOSUB  comcK	comma?
	GONC   respTR	no, done
	GOSUB  numck	<num1>
	GOSUB  respTR
	GOSUB  comcK	yet another comma?
	GONC   respTR
	GOSUB  numck	<num2>
 respTR GOVLNG =RESPTR	parsing done
* local entry points for mainframe routines that are called
* often enough (at least 3 times) that this saves memory
 comcK	GOVLNG =COMCK
 numck	GOVLNG =NUMCK
* parse errors
 badf	GOVLNG =FSPECe	"Invalid Filespec"
 syntx	GOVLNG =SYNTXe	"Syntax"

************************************************************
* VARSWAP
*
* VARSWAP <var1> , <var2>
************************************************************

=SWAPp
*
* Parse de la premiere variable
*
	GOSUB  SWPp50
	ST=0   8
	GONC   SWPp10
	ST=1   8
 SWPp10
*
* Test de la virgule
*
	GOSBVL =NTOKEN
	GOSBVL =COMCK+
	GONC   syntxe
*
* Parse de la deuxieme variable
*
	GOSUB  SWPp50
	GONC   SWPp30
	?ST=0  8
	GOYES  syntxe
 SWPp20 RTNCC		Sortie : tout est ok
 SWPp30 ?ST=0  8
	GOYES  SWPp20
 syntxe GOVLNG =SYNTXe

 SWPp50 GOSUB  exppar
	GOC    syntxe
	?ST=1  0
	GOYES  syntxe
	?XM=0
	GOYES  SWPp60
	GONC   syntxe	B.E.T.
 SWPp60 GOSBVL =RESPTR
	?ST=1  3
	RTNYES		Cy := 1 si ST(3) = 1
	RTN		Cy := 0 si ST(3) = 0

************************************************************
* KA
*
* KA [ <file> ]
************************************************************
* KAp
*
* But: routines de decomparse de KA
* Syntaxe: KA [ <filespec> ]
* Historique:
*   86/08/01: PD ajout de documentation
*   87/12/06: PD & JT integration dans JPCROM
************************************************************
 
=KAp	GOSBVL =EOLCK
	GOC    Resptr
	GOSUB  Resptr
*
* Attention ! Le code continue
*

************************************************************
* SHRINK
*
* SHRINK <file>
************************************************************
 
=SHRINKp
	GOSBVL =FSPECp
	RTNNC
 Fspece GOVLNG =FSPECe
 
************************************************************
* FKEY, EXECUTE, FIND, ENDUP
*
* FKEY <exp alpha>
************************************************************

=ENDUPp
=EXECUTEp
=FKEYp
	GOVLNG =STRNGP

************************************************************
* INVERSE
*
* INVERSE [ <x> , <y> ]
************************************************************

=INVERSEp
	GOSBVL =EOLCK
	GOC    Resptr
	GOSUB  Resptr
	LC(1)  2	2 parametres a passer
	GOTO   PARSEn

************************************************************
* LINE
*
* LINE <exp x>, <exp l>, <exp p>, <exp t>, <exp e>
************************************************************
* PARSEn : parse C(0) parametres
*
* Entree :
*   - C(0) = nombre de parametres num. a parse
************************************************************

=GLINEp LC(1)  5	5 parametres a parser
 PARSEn C=C-1  P	sauvegarde du compteur dans
	R2=C		   R2
	GOSBVL =NUMCK	parser une expression num.
	GOSUB  Resptr
	C=R2		restauration du compteur
	?C=0   P	sortie si = 0
	GOYES  Resptr
	GOSBVL =COMCK	sinon, on cherche une ","
	GONC   mspare	si non trouvee, erreur
	C=R2		restauration du compteur
	GOC    PARSEn	B.E.T.
 Resptr GOVLNG =RESPTR
 mspare GOVLNG =MSPARe	"missing parameter"

************************************************************
* REPEAT, LOOP, SLEEP, DMY, MDY
*
* pas de parametre
************************************************************

=BELLp
=CRp
=DMYp
=FFp
=FRAMEp
=GDUMPp
=GENDp
=LOOPp
=MDYp
=PENDOWNp
=PENUPp
=REPEATp
=REPTp
=SLEEPp
 parse
	RTNCC		Avec Cy=0

 wrdscn GOVLNG =WRDSCN

************************************************************
* END WHILE / LOOP / SELECT / IF
*
* END WHILE | LOOP | SELECT | IF
************************************************************

=END2p	GOSUB  wrdscn
	CON(6) (=tWHILE)~(=id)~(=tXWORD)
	REL(3) ENDWp
	CON(6) (=tLOOP)~(=id)~(=tXWORD)
	REL(3) ENDLp
	CON(6) (=tSELECT)~(=id)~(=tXWORD)
	REL(3) ENDSp
	CON(6) (=tIF2)~(=id)~(=tXWORD)
	REL(3) ENDIp
	CON(2) 0
	GOTO   Rest*
*
* Tokenisation du END WHILE / LOOP / SELECT / IF :
*
* Dans la chaine tokenisee (pointee par D0), nous
* avons les 6 quartets pour le codage du END (le
* notre, pas celuyi du systeme), puis un quartet
* de reconnaissance, servant a identifier laquelle
* des 4 structures nous terminons :
*   qENDL = 0	 (necessaire)
*   qENDS = 1
*   qENDI = 2
* Si il n'y a pas de quartet de reconnaissance,
* c'est un END WHILE
*
 ENDWp	D0=D0- 6	On oublie tWHILE
	RTN		Cy := 0
 ENDSp	P=     =qENDS
	GOTO   ENDLp
 ENDIp	P=     =qENDI
 ENDLp
*
* tXWORD id tEND2 tXWORD id tLOOP/SELECT/IF
*					    ^
*					    D0
*
	D0=D0- 6	On retire le token reconnu
*
* tXWORD id tEND2 tXWORD id tLOOP/SELECT/IF
*		 ^
*		 D0
*
	C=P    0	C(0) := qEND L/S/I
	P=     0	c'est plus propre...
 outnib GOVLNG =OUTNIB


*
* CASE ELSE
*
 CS00p
	D0=D0- 6	tELSE nous interesse pas
	RTN		Cy := 0 par le D0=D0- 6

**************************************************
* CASE
*
* Syntaxes :
*   CASE ELSE :
*     tXWORD id tCASE
*   <relop> <exp>
*     tRELOP <1 quartet> texp
*   <exp> TO <exp>
*     texp tTO texp
*   <exp>
*     texp
*   CASE <clause> , <clause>
*     tXWORD id tCASE tclause tCOMMA tclause
**************************************************

 EXPTYP EQU    =F-R0-3

=CASEp
*
* EXPTYP := 0 ;
*
	CD1EX
	D1=(5) EXPTYP
	C=0    S
	DAT1=C S
	D1=C
*
* ELSE ?
*
	GOSUB  wrdscn
	CON(6) (=tELSE2)~(=id)~(=tXWORD)
	REL(3) CS00p
	CON(2) 0
*
* analyse des clauses
*
	GOSUB  resptr
 CSp10
*
* <relop> ?
*
	GOSBVL =NTOKEN
	LC(2)  =tRELOP
	?A#C   B
	GOYES  CSp20	<exp> TO <exp> ou <exp>
*
* CASE <relop> <exp>
*
	GOSBVL =OUTBYT	stocker tRELOP
	C=A    XS	C(XS) := specificateur
	CSR    X
	CSR    X	C(0) := specifier
	GOSUB  outnib	stocker le "specifier"
*
* "CASE <25 @"
*	 ^
*	 D1
* tXWORD id tCASE tRELOP q
*			   ^
*			   D0
*

	GOTO   CSp30	parse expression & fin
*
* CASE <exp1> [ TO <exp2 ]
*
 CSp20	GOSUB  resptr
	GOSUB  expck	parse et verifie exp1
*
* "CASE 32 TO 127 @"
*	     ^
*	     D1
* tXWORD id tCASE t32
*		      ^
*		      D0
*
	LC(2)  =tTO
	?A#C   B
	GOYES  CSp40
	GOSBVL =OUTBYT	On n'incremente pas D1
*
* "CASE 32 TO 127 @"
*	     ^
*	     D1
* tXWORD id tCASE t32 tTO
*			 ^
*			 D0
*
 CSp30	GOSUB  expck
 CSp40
*
* "... , ..."
*	^
*	D1
* ... t<dernier token reconnu>
*			      ^
*			      D0
*
* A(B) = token a analyser (tCOMMA ou tEOL)
* D0 = ^ flot de sortie
* D1 = ^ passe le token A(B)
*
	GOSBVL =COMCK+
	GOC    CSp10	"," trouvee, on recommence

 resptr GOVLNG =RESPTR

************************************************************
* SELECT, SYSEDIT
*
* SELECT <exp alpha ou num>
************************************************************

=SELECTp
=SYSEDITp
	GOSUB	numalp	Expression numerique ou alpha
	GOTO	resptr

**************************************************
* expck
*
* But: analyser l'expression pointee par D1, et
*   verifier que le type correspond a celui des
*   expressions precedentes.
* Entree:
*   - D0 = ^ flot de sortie
*   - D1 = ^ flot d'entree
* Sortie:
*   - A(B) = token suivant
*   - P = 0
*   - A(S) = C(S) = type de l'expression
*   - D0 = ^ flot de sortie (passee l'exp)
*   - D1 = ^ passe le 1er token non reconnu
* Appelle: EXPPAR
* Niveaux: 4 (EXPPAR)
* Abime: A-D, R0-R1, ST(0-3,7,11), FUNCD0, F-R0-3
* Detail: verification du type :
*   type := type de l'expression
*   si EXPTYP = 0
*     alors EXPTYP := type
*     sinon si EXPTYP # type alors erreur
*   fin si
* Historique:
*   87/02/28: conception & codage
**************************************************

 expck	GOSUB  exppar
	?ST=1  0	not valid expression ?
	GOYES  ivexp
	LC(1)  1	num exp. <==> 1
	?ST=1  3	not string expression ?
	GOYES  expck1
	C=C+1  A	string exp. <==> 2
*
* C(0) := type de l'expression
*
 expck1 CSRC   W	C(S) := type
	CD1EX
	D1=(5) EXPTYP
	A=DAT1 S	A(S) := (EXPTYP)
	?A=0   S
	GOYES  expck2
	D1=C		restaurer D1
	?A=C   S
	RTNYES		expressions meme type
 ivexp	GOVLNG =IVEXPe	"Invalid Expr"

 expck2
	DAT1=C S	EXPTYP := type
	D1=C
	RTN

************************************************************
* IF
*
* IF <exp num> THEN
************************************************************

=IF2p
*
* "IF A+B THEN <eol>"
*    ^
*    D1
*     
* tXWORD id tIF2
*		   ^
*		   D0
*
	GOSBVL =NUMCK
*
* "IF A+B THEN <eol>"
*	      ^
*	      D1
* tXWORD id tIFSTR tA tB t+
*			    ^
*			    D0
*
	GOSUB  resptr
*
* "IF A+B THEN <eol>"
*	 ^
*	 D1
*
	GOSUB  wrdscn
	CON(2) =tTHEN
	REL(3) THENp
	CON(2) 0
	GOTO   Rest*
*
* "IF A+B THEN <eol>"
*	      ^
*	      D1
* tXWORD id tIFSTR tA tB t+ tTHEN
*				  ^
*				  D0
*
 THENp
	D0=D0- 2	On oublie le token de THEN
*
* On fait maintenant le test decisif :
* si on trouve tEOL, t@, t!, c'est a nous !
* sinon, on repasse la main, via REST*, au IF
* interne.
* On ne peut pas utiliser EOLCK, car il accepte la
* presence de tELSE. Hum...
*
	GOSBVL =NTOKEN

	LC(2)  =tEOL
	?A=C   B
	GOYES  REsptr
	LCASC  '@'
	?A=C   B
	GOYES  REsptr
	LC(2)  '!'
	?A=C   B
	GOYES  REsptr
	GOTO   Rest*

 REsptr GOTO   resptr
*
* Tokenisation finale :
* "IF A+B THEN <eol>"
*		    ^
*		    D1
* tXWORD id tIFSTR tA tB t+ tEOL
*				 ^
*				 D0
*

************************************************************
* ELSE
*
* pas de parametre, mais traitement special
************************************************************

=ELSE2p
	CD1EX		Sauve D1
	D1=(5) =S-R0-3	"IF statement in progress"
	C=DAT1 S
	D1=C		restaure D1
	?C#0   S	"IF statement in progress"
	GOYES  Rest*
	RTN		Ok, on prend (RTNCC)
 Rest*	GOTO   rest*	C'est pas a nous

************************************************************
* UNDERLINE
*
* UNDERLINE ON | OFF
************************************************************

=UNDERp GOSBVL =CNVWUC	Conversion en majuscule
	LCASC  'E'
	?A#C   B	Est-ce "E" ?
	GOYES  syntax	Non: "Erreur de syntaxe"
	D1=D1+ 2	Oui: caractere suivant

************************************************************
* ROMAN, ATTN, WRAP
* But: analyser ON|OFF
************************************************************

=ATTNp
=ONOFFp
=ROMANp
	GOSUB  wrdscn	Token suivant
	CON(2) =tON	Est-ce ON ?
	REL(3) parse	Oui: retour
	CON(2) 1+=tON	(= tOFF)
	REL(3) parse
	NIBHEX 00	Fin de la table
* Si nous sommes arives la, c'est que le token
* n'etait ni tON, ni tOFF. Alors, on ne reconnait 
* pas l'ordre, et on repasse la main au systeme
* d'exploitation.

 rest*	GOVLNG =REST*	Reprendre l'analyse

 syntax GOVLNG =SYNTXe	"Erreur de syntaxe"

************************************************************
* PLF, MARGIN, LEAVE
*
* MARGIN [ <exp num> ]
************************************************************

=LEAVEp
=MARGINp
=PLFp	GOSBVL =EOLCK
	GOC    RESptr
	GOSUB  resptr
	GOTO   =NUMp

 RESptr GOTO   resptr

************************************************************
* PAGELEN
*
* PAGELEN [ <exp num> [ , <exp num> ] ]
************************************************************
=PAGELENp
	GOSBVL =EOLCK	Premier param. existe ?
	GOC    RESptr	Non: on revient a Basic
	GOSUB  resptr	Oui: on branche sur
	GOVLNG =DELAYp	DELAY num [, num]

************************************************************
* UNTIL, WHILE, STACK, GPSET
*
* STACK <exp num>
************************************************************

=UNTILp
=WHILEp
=STACKp
=GPSETp
=NUMp
	GOVLNG =FIXP

************************************************************
* EXIT
*
* EXIT <var num>
************************************************************

=EXITp	GOVLNG =NXTP

************************************************************
* EDIT
*
* EDIT <file>[:<device>] [ TO [<file>][:<device>] ]
************************************************************

=EDITp	GOSUB  eolck+
	GOC    RESptr
	GONC   EDP10	B.E.T.

 RNMP05 ST=1   8
 EDP10	GOSBVL =FSPECp
	GONC   RNMP25
	GOVLNG =FSPECe

 RNMP25 ?ST=0  8
	GOYES  RNMP26
	RTNCC
 RNMP26 GOSBVL =WRDSCN
	CON(2) =tTO
	REL(3) RNMP05
	CON(2) 0
	GOTO   resptR

************************************************************
* LEX
*
* LEX <file> ON | OFF
************************************************************

=LEXp	CD0EX		C(A) := ^ tokens
	D0=(5) =STSAVE	5 quartets disponibles
	DAT0=C A
	D0=C		Rien vu, rien entendu !
	GOSBVL =FSPECp
	GONC   LEXp10	Pas d'erreur (c'est Lesieur)
	GOVLNG =FSPECe	Erreur (c'est plus Lesieur)
 LEXp10 GOSBVL =WRDSCN
	CON(2) =tON
	REL(3) LEXONp
	CON(2) =tOFF
	REL(3) LEXOFFp
	NIBHEX 00
	GOVLNG =SYNTXe

 LEXONp AD0EX
	D0=(5) =STSAVE
	C=DAT0 A
	D0=C		D0 := ^ debut de t<filespec>
	D0=D0- 2	D0 := ^ token de DISABLE ie LEX OFF
	LC(2)  =tLEXON
	DAT0=C B
	D0=A		et on est revenu apres tON
 LEXOFFp
	D0=D0- 2	On oublie tON/tOFF
	RTNCC		Ok ?

************************************************************
* POKE
*
* POKE [ <exp alpha> | <exp num> ] , <exp alpha>
************************************************************

 STRCOMp
	GOSBVL =STRGCK
 comck+	GOSBVL =COMCK+
	RTNC
	GOVLNG =SYNTXe
 
 numalp	GOSUB	exppar	Parse expression
	?ST=1	0	Valid Expression ?
	GOYES	Ivexp	no
* D1 = ^ token suivant
	RTN		yes, return with Cy = 0

=POKEp	GOSUB	numalp
	GOSUB	comck+
 strngp GOVLNG =STRNGP

**************************************************
* WREC
*
* WREC <exp alpha> , <exp alpha> , <device>
**************************************************

DVCSPp	EQU    #7925

=WRECp	GOSUB  STRCOMp
	GOSBVL =GNXTCR
	GOSBVL =R3=D10
	GOSUB  exppar
	?ST=1  0
	GOYES  ivexpe
	GOSBVL =COMCK+
	GONC   Syntxe
	GOSUBL =JUMPER
	CON(5) DVCSPp
	RTNCC

 ivexpe ST=1   4
 Ivexp	GOVLNG =IVEXPe
 
 Syntxe GOVLNG =SYNTXe
 
************************************************************
* FINPUT
*
* FINPUT <varalpha>, <expalpha> [, <expalpha> ], <varnum>
************************************************************

*
* Syntaxe: SAISY I$,M$, [P$,] A
*

 ivpare GOVLNG =IVPARe

 comma	GOSUB  resptR
	GOSBVL =NTOKEN
	GOSBVL =COMCK+	check & output tCOMMA
	RTNC		Ok
	GOVLNG =MSPARe

=FINPUTp
	ST=1   9	Single string variable parse
	GOSBVL =READP5	supporte (mais oui !)
	GOSUB  comma
* M$
	GOSUB  exppar	M$
	?ST=1  3
	GOYES  ivpare
	GOSUB  comma
* P$ ou A
	CD0EX		!
	R2=C		! Quartet de reconnaissance := 0
	D0=C		!   si il n'y a pas P$
	C=0    A	!
	GOSBVL =OUTNIB	!
	GOSUB  exppar
	?ST=1  3	Valid String expression
	GOYES  SINp10
	C=R2		!
	CD0EX		! Quartet de reconnaissance := F
	A=0    S	!   si il y a P$
	A=A-1  S	!
	DAT0=A S	!
	D0=C		!
	GOSUB  comma
* A
	GOSUB  exppar
 SINp10 ?ST=1  0	No valid expression ?
	GOYES  ivvare
	?ST=0  3	Valid string expression ?
	GOYES  ivvare	Invalid var
	?XM=0		Expression = passable par reference
	GOYES  resPTR
 ivvare GOVLNG =IVVARe
 resPTR GOVLNG =RESPTR

 exppar GOVLNG =EXPPAR

************************************************************
* PARSE DE ADLEX
*
*
* Ces routines de parse ressemblent a un jeu de mecano. Les
* memes entites syntaxiques se retrouvent continuellement
* dans ces routines. Ce sont:
*
* <fichier> (nom de fichier)
* <numero>  (numero de fiche, expression numerique)
* <array>   (nom de tableau)
* <passwd>  (mot de passe, expression alphanumerique)
*
* Le ciment qui lie ces elements est la virgule. Dans
* certains cas, elle est obligatoire, dans certain cas (au
* singulier), elle ne l'est pas. Ce dernier cas correspond
* a l'element <passwd> situe toujours en derniere position,
* et facultatif.
*
* Nous aurons donc l'element <virgule> qui cherchera une
* virgule obligatoirement. La virgule facultative sera
* integree dans la parse de l'element <passwd>.
*
* Ajoutons une derniere assertion importante: tout element
* apres son analyse, laisse le pointeur D1 passe le dernier
* caractere analyse.
************************************************************

************************************************************
* routines de parse
*
* Historique:
*   86/08/05: conception & codage
************************************************************

 fichip GOSBVL =FSPECp
	RTNNC
	GOVLNG =FSPECe

 numerp GOSBVL =NUMCK
 resPtr GOVLNG =RESPTR

 arrayp GOSBVL =VARP
	RTNNC		Cy = 0 ==> string variable
	GOVLNG =IVVARe	invalid variable

 virgup GOSBVL =NTOKEN
	GOSBVL =COMCK+
	RTNC		Cy = 1 ==> tCOMMA trouve
	GOVLNG =MSPARe

=TEDITp
=XEDITp
=ADCREATEp
	GOSUB  fichip

 passwp GOSBVL =EOLCK
	GOC    resPtr
	GOSUB  resPtr
	GOSUB  virgup
	GOSBVL =STRGCK
	GOTO   resPtr

=ADDELETEp
	GOSUB  fichip
	GOSUB  virgup
	GOSUB  numerp
	GOTO   passwp

=ADGETp GOSUB  fichip
	GOSUB  virgup
	GOSUB  arrayp
	GOSUB  virgup
	GOSUB  numerp
	GOTO   passwp

=ADPUTp GOSUB  fichip
	GOSUB  virgup
	GOSUB  arrayp
	GOTO   passwp

****************************************************
* BASICLEX
****************************************************

 PRSETO EQU    (=FUNCR0)+0
 PRSEIN EQU    (=FUNCR0)+1

****************************************************
* DBLISTp, PBLISTp
*
* But : parse quelque chose de tres complique...
* Historique :
*   86/05/..: JPB     reecriture d'apres I.D.S.
*   88/01/10: PD & JT documentation
*   88/01/31: PD & JT correction de PBLIST TOTO
*   88/01/31: PD & JT correction de PBLIST INDENT 5
****************************************************

=DBLISTp
=PBLISTp
*
* Mettre a 0 les flags PRSETO et PRSEIN
* qui interdisent de mettre deux fois la meme
* option.
*
	A=0    B	Le 88/01/31 : gagne quelques
	CD0EX		quartets
	D0=(5) PRSETO
	DAT0=A B	Pas encore vu de TO/INDENT
	D0=C
*
* [<file>] [,<li#> [,<li#>]] [TO <file>][INDENT <n>]
* Autrefois inspire de LISTP (#03B92 / HP71B)
*
	GOSUB  eolckx
	GOC    rEsptr	tEOL trouve
	GOSUB  CKINDT
	GOC    LSTP60	tINDENT trouve
	GOSUB  rEsptr
*
*   <file>    ou bien encore	TO
* ^			      ^
*
	GOSBVL =FSPECp	specificateur valide ?
	GONC   LSTP12	oui
*
* si S7=1
*   alors reserved word in A
*	  (TO, ALL, KEYS, INTO, CARD)
*   sinon bad file parse
* fin si
*
	?ST=0  7	Bad file parse ?
	GOYES  LSTP20	Oui : peut-etre <line#>
*
* reserved word in A. Est-ce tTO ?
*
	D0=D0- 2	Revient sur tTO
	LC(2)  =tTO
	?A=C   B
	GOYES  LSTP40

 fspece GOVLNG =FSPECe	Illegal file spec

*
* <file>   , ...
*	 ^
*
 LSTP12 GOSBVL =COMCK	Comma ?
	GONC   LSTP30	Non : TO ou INDENT ou vraie fin

*
* <file> ,   <line> ...
*	   ^
*

 LSTP20 GOSUB  ck2li#	<line1> [ , <line2> ]
*
* ...	TO <file>
*     ^
*
 LSTP29 GOSBVL =NTOKEN	Pour avancer
 LSTP30 GOSUB  CKTO
	GOC    LSTP40
	GOSUB  CKINDT
	GOC    LSTP60
 rEsptr GOVLNG =RESPTR

*
* Traitement de TO <file>
*
 LSTP40 LC(5)  PRSETO
	GOSUB  CKSEEN
	GOSBVL =OUT1TK
	GOSBVL =FSPECp	specificateur valide ?
	GONC   LSTP29	Oui : on continue
	GOC    fspece	Non : erreur (B.E.T.)

*
* Traitement de INDENT <expression>
*
 LSTP60 LC(5)  PRSEIN
	GOSUB  CKSEEN
	GOSBVL =OUT3TK
	GOSBVL =NUMCK
	GOTO   LSTP30

****************************************************
* eolckx
*
* But : idem EOLCK, mais avec NTOKEN au lieu de
*   WRDSCN.
* Entree :
*   - D1 = ^ flot ascii
* Sortie :
*   - Cy = 1 si tEOL trouve
* Appelle : NTOKEN, FINDA
* Niveaux : 3
* Abime : A, B, C, P, D0, D1, R0, S0-3, S11
* Historique :
*   88/01/31: PD & JT recodage apres suppression
****************************************************

 eolckx GOSBVL =NTOKEN
	GOSBVL =FINDA
	CON(2) =tEOL
	REL(3) rtnsc
	CON(2) =t@
	REL(3) rtnsc
	CON(2) =t!
	REL(3) rtnsc
	CON(2) =tELSE
	REL(3) rtnsc
	NIBHEX 00
	RTNCC		Cy = 0 : non trouve
 rtnsc	RTNSC		Cy = 1 : trouve

****************************************************
* RENUMREMp
*
* But : parse RENUMREM [<l1>[,<l2>[,<l3>[,<l4>]]]]
* Historique :
*   86/05/..: JPB     reecriture d'apres I.D.S.
*   88/01/10: PD & JT documentation
****************************************************

=RENUMREMp
	GOSUB  eolck+
	GOC    resptR	EOL : sortir
	GOSUB  ck2li#
	?ST=0  9	2 <line#> trouves ?
	GOYES  rtncc	Non : sortir
	GOSBVL =COMCK	Comma ?
	GONC   resptR	Non : sortir
	GOSUB  ck2li#
 rtncc	RTNCC		Ok

 eolck+ GOSBVL =EOLCK	fin de commande ?
	RTNC		oui : Cy=1
 resptR GOVLNG =RESPTR	non : on revient

****************************************************
* CKSEEN
*
* But : verifier que le token TO ou INDENT n'a pas
*   deja ete vu durant la parse.
* Entree :
*   - C(A) = adresse du flag (PRSETO ou PRSEIN)
* Sortie :
*   - si deja vu, alors erreur
*     sinon flag mis a jour, Cy = 0
* Niveaux : 0
* Utilise : C(S)
* Historique :
*   88/01/10: PD & JT conception & codage
****************************************************

 CKSEEN CD0EX
	C=DAT0 S
	?C#0   S	Deja vu ?
	GOYES  CKS10	oui : erreur
	C=C+1  S
	DAT0=C S
	CD0EX
	RTN
 CKS10	GOVLNG =SYNTXe	"Syntax Error"

****************************************************
* CKTO, CKINDT
*
* But : tester tTO ou tINDENT
* Entree :
*   - A = token a tester
* Sortie :
*   Cy = 1 : token trouve
*   Cy = 0 : token cherche non trouve
* Niveaux : 0
* Utilise : C
* Historique :
*   88/01/10: PD & JT conception & codage
****************************************************

 CKTO	LC(2)  =tTO
	?A=C   B
	RTNYES
	RTN

 CKINDT LC(6)  (=tINDENT)~(=id)~(=tXWORD)
	P=     5
	?A=C   WP
	GOYES  CKIN10
 CKIN10 P=     0
	RTN

****************************************************
* ck2li#
*
* But : parse	"  <line#1> [ , <line#2> ]  "
* Entree :
*   - D1 = ^ blancs optionnels avant
* Sortie :
*   - S9 = 1 si les deux <line#> ont ete reconnus
* Appelle : ck1li#, COMCK, NTOKNL, OUT3TK
* Niveaux : 4 (NTOKNL)
* Utilise : A-C, P, D0, D1, R0, S0-S3, S11
* Historique :
*   86/05/..: JPB     reecriture d'apres I.D.S.
*   88/01/10: PD & JT separation & documentation
****************************************************

 ck2li# ST=0   9
	GOSUB  ck1li#	<line1>
	GOSBVL =COMCK	Comma ?
	GONC   respTr	Non : sortir
	ST=1   9	On reconnait les 2 <line#>

 ck1li# GOSBVL =NTOKNL	Idem NTOKEN, autorise line#
	LC(2)  =tLINE#
	?A#C   B
	GOYES  LSTPE	Pas <line#> : erreur
	LC(2)  =tCOMMA
	A=C    B
	GOVLNG =OUT3TK

 LSTPE	GOVLNG =IVPARe	INVALID (MISSING PARM)

**************************************************
* FINDp
*
* But: analyser et reconnaître la syntaxe de FIND
* Syntaxe: FIND <chaine> [,<debut> [, <fin>]]
* Entrée:
*   - D1 = ^ chaîne Ascii
*   - D0 = ^ tokens
*   - D(A) = AVMEME
* Sortie:
*   - Cy = 0
* Abime: A-C, D(15-5), R0-R1, R3, S0-3, S7, S11,
*   FUNCD0; D0, D1
* Niveaux: 5 (STRGCK)
* Appelle: STRGCK, COMCK+, ck2li#, RESPTR
* Historique:
*   89/06/09: PD reconception & recodage
*   89/06/18: PD/JT intégration dans JPC Rom
**************************************************

=FINDp
	GOSBVL =STRGCK
*
* A = token de ce qui suit l'expression
* D1 = ^ derrière le texte correspondant à A
*
	GOSBVL =COMCK+
	GONC   respTr   Pas de ',' : c'est fini !
	D0=D0- 2        ck2li# sortira une virgule
*
* Une virgule a été reconnue, donc il faut un ou
* deux numéros de ligne.
* C'est le rôle de ck2li#, empruntée à JPC Rom et
* plus précisément à D/PBLIST/RENUMREM
*
	GOTO	ck2li#

****************************************************
* DDIR/PDIR
****************************************************

 respTr GOVLNG  =RESPTR

=DDIRp
=PDIRp  GOSBVL  =EOLCK
        GOC     respTr  tEOL found
        GOSUB   respTr
        GOSBVL  =FSPECp
        GONC    DIRp50  filespec valide. Ya TO ?
*
* On sait a present que Cy = 1
* Si S7 = 1
*   alors reserved word has been output in A
*         (KEYS, ALL, TO, INTO, CARD)
*   sinon : bad file parse
*
        ?ST=0   7
        GOYES   DIRpER  Bad file parse
        LC(2)   =tALL
        ?A=C    B
        GOYES   DIRp50  Ok. Y-a-t'il TO apres ALL ?
        LC(2)   =tTO
        ?A=C    B
        GOYES   DIRp70  ne pas parser le TO
*
* Mot clef reserve non reconnu
*

DIRpER  GOVLNG  =FSPECe

*
* Y-a-t'il TO <filespec>    (redirection ?)
*
DIRp50  GOSBVL  =NTOKEN
        LC(2)   =tTO
        ?A=C    B
        GOYES   DIRp60  TO <filespec>
        GOTO    respTr  Parser EOL

*
* On sait qu'il y a TO
* Reste a analyser <filespec>
*
DIRp60  GOSBVL  =OUT1TK
DIRp70  GOSBVL  =FSPECp specificateur valide ?
        GOC     DIRpER  Non : erreur
        RTNCC  		oui

************************************************************
* Parse du module graphique
*
* 89/06/18 : PD/JT intégration dans JPC Rom
************************************************************

=PENp	
	GOSBVL =EOLCK
	GOC    resPTr
	GOSUB  resPTr
	GOTO   fixp

=BOXp
=SCALEp
	GOSUB  =MOVEp
	GOSUB  virgul
=DRAWp
=IDRAWp
=IMOVEp
=MOVEp
	GOSUB  fixp
	GOSUB  virgul
=LDIRp
=LORGp
=TICLENp
 fixp
	GOSBVL =NUMCK
 resPTr GOVLNG =RESPTR

 virgul GOSUB  comck
	RTNC
	GOVLNG =MSPARe
 comck	GOVLNG =COMCK	Cy=1 <=> comma (,)

=CSIZEp
	GOSUB  fixp
	GOSUB  comck
	GONC   resPTr
	GOSUB  fixp
	GOSUB  comck
	GONC   resPTr
	GOTO   fixp

=LINETYPEp
	GOSUB  fixp
	GOSUB  comck
	GONC   resPTr
	GOTO   fixp

=XAXISp
=YAXISp
	GOSUB  fixp
	GOSUB  comck
	GONC   resPTr
	GOSUB  fixp
	GOSUB  comck
	GONC   resPTr
	GOTO   =MOVEp

=GINITp
	GOSBVL =STRGCK
	LC(2)  =tCOMMA
	?A=C   B
	GOYES  fixp
 ResPTr GOTO   resPTr

=LABELp
	GOSBVL =STRGCK
	LC(2)  =tSEMIC
	?A#C   B
	GOYES  ResPTr
	GOVLNG =OUT1TK

=PLOTTERp
	GOSUBL =JUMPER
	CON(5) #7468	PRNTSp
	RTN
	END
