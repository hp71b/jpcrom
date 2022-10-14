	TITLE  DIRLEX <dir.as>
*
* JPC:C02
*   88/02/12: PD/JJD Intégration dans JPC Rom
*

*****************************************************
* DEFINITIONS
*****************************************************

* Les adresses en Ram. Utilisees lors du parcours
* des "file chain" internes (celles qu'a propos
* desquelles qu'elles sont dans la memoire)...
*
CURCHN  EQU     0+=TRFMBF  5q: ad. dans la file chain
DOMAIN  EQU     5+=TRFMBF  1q: :PORT, ALL, :MAIN...

OUTYPE  EQU     6+=TRFMBF  1q: 0 : std, 1 : fichier
OUTADR  EQU     7+=TRFMBF  5q: adresse ds le fichier
OUTHDR  EQU    13+=TRFMBF  5q: adresse du header
CNFINF  EQU    18+=TRFMBF 16q: infos Config table pour
*                               ROMFND
DEVSPx  EQU     =STMTD1      : Addr dev (massmem)

* 
* espaces utilise temporairement pendant l'analyse
* de la cahine tokenisee :
*
FLSPxA  EQU     5+=STMTD0 16q: Nom du fichier 1
FLSPxD  EQU    21+=STMTD0 16q: Dev specifications
FLSPxR  EQU    26+=STMTD0  5q: Suite du nom pour HPIL

FLSPyD  EQU    11+=TRFMBF 16q: Dev specifications
FLSPyA  EQU    27+=TRFMBF 16q: Nom du fichier 2
*
* Valeurs utilisees temporairement par DOMAIN
* pendant l'etude de la chaine tokenisee
* et avant le traitement de la redirection.
*
dALL    EQU     #E
dFILE   EQU     1
dRIEN   EQU     0

 BLDCAT EQU     #6300
 ENDTAP EQU     #44D9
 FiNDF+ EQU     #46A6
 GETDR! EQU     #47D7
 GETDR+ EQU     #47F9
 GETERR EQU     #6791
 GETMBX EQU     #3B62
 NXTENT EQU     #4A1E
 ROMID  EQU     #FE
 SEEKRD EQU     #62D8
 START  EQU     #07E8
 UTLEND EQU     #07CC
 LEXPIL EQU     #FF

*****************************************************
* EXECUTION...
*****************************************************

        REL(5)  =DDIRd
        REL(5)  =DDIRp
=DDIRe  LC(2)   (=DISPt)*16+#F
        GONC    dir

        REL(5)  =PDIRd
        REL(5)  =PDIRp
=PDIRe  LC(2)   (=PRINTt)*16+#F
*
* On ecrit un octet Ha partir de MLFFLG, c'est dire
* qu'un quartet est ecrit en STMTR0
*
dir     D1=(5)  =MLFFLG
        DAT1=C  B

*
* selon token
*   ALL :
*      DOMAIN := #E
*   fichier :
*      FPSECx
*      selon resultat :
*         <filespec>
*         <filespec>:<port ou main>
*         :<external device>
*      fin selon
* fin selon
*


* Initialisations
*   - sortie standard
*   - file chain par defaut (MAIN file chain)
*
        C=0     W       "W" pour plus de securite
        D1=(4)  OUTYPE
        DAT1=C  S       OUTYPE := Sortie standard

        D1=(4)  =MAINST debut de la MAIN file chain
        C=DAT1  A
        D1=(4)  CURCHN
        DAT1=C  A       DEBCHN := MAINST

        D1=(2)  DOMAIN
        DAT1=C  S       DOMAIN := dRIEN
*
* Module d'analyse de la chaine tokenisee
*   - execute les specifications de fichiers et les
*     memorise
*   - initialise les redirections
*

        A=DAT0  B       A(B) := token suivant

        GOSBVL  =EOLXCK
        GONC    DIR005
        GOTO    CAT10   Fin de ligne trouvee

DIR005  LC(2)   =tTO
        ?A=C    B
        GOYES   DIR060  DIR TO ...

        LC(2)   =tALL
        ?A#C    B
        GOYES   DIR010
* DIR ALL [ TO ... ]
        LC(1)   dALL    DOMAIN := ALL
        DAT1=C  1
        D0=D0+  2       On passe tALL
        GONC    DIR050  B.E.T. (vers la redirection)
*
bserR   GOVLNG  =BSERR  "beeeeeep"
*
* DIR <filespec>
DIR010
        LC(1)   dFILE
        DAT1=C  1       DOMAIN := <filespec>
        GOSBVL  =FSPECx
        GOC     bserR
*
* A(W) = file name (A(W) = 0 si pas de fichier)
* D(S) = F        No device specified
*        1       Port
*                D(B) = port number
*                D(B) = FF si ":PORT"
*        7       Card ou Pcard
*        8       HPIL       D(X) = device address
*       >8       Other
*        
        D1=(5)  FLSPxA

        DAT1=A  W       File name
        D1=D1+  16      FLSPxD
        C=D     W
        DAT1=C  W       Port information (D(W))
        D1=D1+  5
        C=R0
        DAT1=C  A
*
****************************************************
* La redirection
* Ce qui suit est emprunte a BLIST
*****************************************************
*
* DIR ... TO <filespec>
* D0 pointe sur le premier token de <filespec>
*
DIR050  A=DAT0  B       A(B) := tTO ou autre chose
        LC(2)   =tTO
        ?A=C    B
        GOYES   DIR060  tTO : ok, il y a redirection
        GOTO    DIR100  Pas de TO : pas redirection

DIR060  D0=D0+  2       On passe tTO
        GOSBVL  =FSPECx specificateur valide ?
        GOC     Bserr   non
*
* Cy = 0 : mainframe recognisable file specifier found
* A(W) = file name
* D(S) = #F  if device not specified
* D(B) = details sur le port
*
        D1=(5)  FLSPyD  sauvegardes
        C=D     W       Sauvegarde de D(W) (pour CRETF+)
        DAT1=C  W
        D1=D1+  16      FLSPyA
        DAT1=A  W       Sauvegarde du nom du fichier


        GOSBVL  =FINDF+ Find file
*
* A(W) = B(W) = file name
* Cy = 0 : file found
* Cy = 1 : file not found
*
        GOC     LIST32  fichier non trouve : ok
        LC(4)   =eFEXST "File Exists" / Beeeeeep !
Bserr   GOTO    bserR

LIST32  D1=(5)  OUTYPE
        LC(1)   1
        DAT1=C  P       Sortie := fichier
*
* Creation du fichier a partir des elements stockes
* dans FLSPyA/D pendant "TO <filespec>" si
* necessaire.
*
        D1=(2)  FLSPyD
        C=DAT1  W
        D=C     W       Restaurer pour CRETF+
        C=0     A
        LC(2)   37+4    header + EOF-mark
        GOSBVL  =CRETF+ Le Lex ne doit pas bouger
        GOC     Bserr   Probleme a la creation
        C=R1    C(A)    := adresse du header
        D1=(5)  OUTHDR  Header du fichier de sortie
        DAT1=C  A
        D1=(2)  FLSPyA
        A=DAT1  W
        D1=C
        DAT1=A  W       Nom du fichier
        D1=D1+  16      D1 = ^ file type
        LCHEX   400001  text + copy code
        DAT1=C  6
        D1=D1+  16
        D1=D1+  5
* EOF-Mark
        C=0     A
        C=C-1   A
        DAT1=C  4       D1 := ^ fin du fichier

        CD1EX
        D1=(5)  OUTADR
        DAT1=C  A


*****************************************************
* La chaine tokenisee a ete analysee
*****************************************************

DIR100
        D1=(5)  DOMAIN
        A=DAT1  1
        ?A=0    P       ?A=dRIEN
        GOYES   DIR120  DIR  [TO X]

        LC(1)   dALL
        ?A=C    P
        GOYES   DIR120  DIR ALL [TO X]

        A=0     B
        DAT1=A  P       Il faut arreter en fin de port

* Le reste : on a trouve un <filespec>
        D0=(5)  FLSPxR  R0[3:0] apres FSPECx
        C=DAT0  A
        R0=C
        D0=D0-  5
        C=DAT0  W
        D=C     W       D(W) comme apres FSPECx
        D0=D0-  16      FLSPxA
        A=DAT0  W       A(W) comme apres FSPECx
        LC(1)   8
        CSRC
        ?C=D    S
        GOYES   xCATEXT
CAT37   GOSBVL  =FINDF+
        GONC    xCAT11  Fichier trouve on y va.
* Fichier introuvable et non succeptible d'etre trouve 
        ?ST=1   6
        GOYES   bserr
* Il faut verifier : :MAIN : PORT et <file>:TAPE
        ?C=0    S       DIR on CARD/PCRD?
        GOYES   bserr
* Memoire peripherique ou fichier non precise
        C=D     S
        C=C-1   S
        GOC     CAT65   DIR:MAIN?
        C=C-1   S
        GOC     CAT70   DIR :PORT
* On ne doit jamais arriver ici
        GOTO    bserr

xCATEXT GOTO    CATEXT
DIR120  GOTO    CAT10

CAT70   D=D+1   B       Derniere extention ?
        GONC    CAT82   Non -> proch. ext. 
        D0=(5)  DOMAIN  Oui
        DAT0=C  S       Actualiser No PORT
        GOSUB   romchk  Recherche PORT suivant
        GONC    CAT90   PORT trouve
CATE34  GOTO    dvcnfe  Plus de PORT

CAT82   GOSUB   romf-1  Recherche le PORT 
        GOC     CATE34  PORT introuvable
xCAT11  GOTO    CAT83


*
CAT80   GOTO    CATEND
CAT65   GOTO    CAT10

rtncc   RTNCC
nxtstm  GOVLNG  =NXTSTM

* Fichier non trouve -> erreur
bserr   GOVLNG  =BSERR

* On vient de terminer une liste (MAIN ou PORT)
* Selon l'option (DOMAIN)
*  - 0  on arrete la
*  - N  on passe au port suivant

CATAL?  D1=(5)  DOMAIN  Les options qu'on a demande
        C=DAT1  S
        ?C=0    S       Parcourt d'un seul PORT ?
        GOYES   CATEND  Oui c'est fini
        C=C+1   S       Non -> PORT suivant
        GOC     CAT85
        DAT1=C  S       Conserver le Num du PORT
        GOSUB   romchk  Recherche du PORT suivant
        GOTO    CAT87

CATEND  GOSBVL  =NOSCRL replace le curseur basic
        GOLONG  nxtstm  Passons a autre chose

*
CAT85   GOSUB   romfnd  recherche PORT suivant
*

CAT87   GOC     CAT80   Plus de port finir
CAT90   A=DAT1  B
        ?A=0    B       PORT vide ?
        GOYES   CAT85   Oui -> PORT suivant
* D1 = ^ premier fichier dans le port
CAT83   CD1EX
CAT11   D1=(5)  CURCHN  Conserver addr fichier
        DAT1=C  A

****************************************************
* D0 va pointer sur l'entete du fichier
* SI le nom est vide (= PORT vide)
*   ALORS faut-il poursuivre sur port suivant ?
*   SINON placer l'adresse du fichier dans CURCHN
*         et construire la ligne

CAT10   D1=(5)  CURCHN  lire adresse debut chaine
        A=DAT1  A
        D0=A
        C=DAT0  B
        ?C=0    B       SI pas de fichier 
        GOYES   CATAL?  continuons ?
        D1=(2)  CURCHN  Conserver adresse fichier...
CAT17   DAT1=A  A       ... dans CURCHN
        D1=A    D1      = ^ entete fichier
        ST=0    0       Ne pas deplacer buf vers stack
        GOSBVL  =CAT$20 Construit buffer information
*
* D0 = ^ FF qui termine le buffer
* Preparer OUTBS et AVMEMS pour print

        GOSBVL  =OBCOLL
        D1=(5)  =AVMEMS
        C=DAT1  A
        D0=D0-  2
        AD0EX
        DAT1=A  A
        D1=D1-  5
        DAT1=C  A

        D1=(5)  CNFINF  Il faut preserver R1
        C=R1            pour recherche PORT
        DAT1=C  W

        GOSUBL  print

        D1=(5)  CNFINF  Restaure R1
        C=DAT1  W
        R1=C

        GOSUB   CK=ATn  Demande d'arret ?
        GONC    xCATEND Oui -> finir
        D1=(5)  CURCHN  Non. Encore un fichier ?
        A=DAT1  A       A = ^ dernier fichier vu
        C=0     A
        LC(2)   =oFLENh Offset pour REL(5) longueur 
        A=A+C   A
        D0=A    D0      = ^ longueur fichier
        A=DAT0  A
        CD0EX
        A=A+C   A       Addr prochain fichier
*
* Est-ce la fin de cette liste ?
        D0=A
        C=DAT0  B
        ?C#0    B       SI encore un fichier 
        GOYES   CAT17   alors poursuivre
        GOTO    CATAL?
xCATEND GOTO    CATEND
*
* 
*
CK=ATn  CD0EX
        D0=(5)  =ATNFLG
        C=DAT0  S
        D0=C
        C=C-1   S
        RTN
************************************************************
romchk  P=      0
        LC(2)   ROMID
        GOSBVL  =CNFFND
        ?A=0    X
        RTNYES
        D1=D1+  1
        B=A     X
*
* Read device# (Port Extender#) and Port# and size info.
* Move to Address field
* Read 3 High Nib address & Device Type
* Increment & Move Device Type to D(S)
* Set D1,C(A) to first file in chain
*
ROMF10  C=DAT1  8       Read Device#, Port#
        D=C     W       Save in D(B)
        D1=D1+  3       Move to Address field
        C=DAT1  3       Read 3 nib Address
        D1=D1+  3       Move to Device Type
        C=DAT1  S       Read Device Type
        C=C+1   S       Incremente Device Type
        D=C     S       Save in D(S)
        D1=D1+  4       Move to next entry
        CSL     A
        CSL     A       Move address to C(4)
        LCHEX   8       Low addr of file ptr
        AD1EX           Table ptr in A(A)
        D1=C            File ptr in D1,C(A)
*
* Compute first file start
* Save Configuration Table information
* Point to first file
*
        ASL     W       Shift over Pos in Table
        ASL     W
        ASL     W
        A=B     X       Save table length
        R1=A            Save pos'n in CNF table, len
        RTNCC

*
romf-1  D=D-1   B       Assumes D(B) was incremented to ck
        C=D     A       for no ports specified - Save D(B)
        R3=C
        GOSUB   romchk  Look for ROMs
        RTNC            No ROMs found
        GONC    ROMF-3
ROMF-2  GOSUB   romfnd  Find next ROM
        RTNC            No more ROMs
ROMF-3  C=R3            Restore original Port#
        ?C#D    B       no Match ?
        GOYES   ROMF-2  Continue
        RTNCC           Port found
*
romfnd  GOVLNG  =ROMFND
dvcnfe  LC(2)   =eDVCNF
        GOVLNG  =MFERR
*
*
Errorx  GOTO    errorx
*

*****************************************************
* DIR :TAPE
*****************************************************
DIR800
CATEXT
        C=D     A
        D1=(5)  =STMTD1
        DAT1=C  A
        ?A=0    A       Fichier prEcise ?
        GOYES   tapall  Non faire tout le disque
        GOSUBL  =JUMPER Oui recherchons la pos. du fichier
        CON(5)  FiNDF+
        GOC     Errorx  Pas trouve

* D1 ^ file type
* B[3:0] is directory pointer for file
* B[3:1] is reccord number
* B[0] is entry within reccord
        GOTO    CATsu

tapall
        GOSUBL  =JUMPER
        CON(5)  START
        GONC    dir..
ERRorx  GOTO    errorx
dir..   GOSUBL  =JUMPER
        CON(5)  GETDR!
        GOC     ERRorx
CATsu   C=D     W
        GOSUB   csrc5
        CSL     A
        CSRB
        C=C-1   A
        GOSUB   csrc10
        C=B     A
        GOSUB   cslc10
        R2=C
        R3=C
        GOSBVL  =R<RST2
        GOSUBL  =JUMPER
        CON(5)  GETMBX
        GOSUB   GDIRS+
        GOSUB   CTA+C
        C=P     14
        C=0     S
        GONC    CATs1
        C=C+1   S
CATs1   GOSUB   TSAV2C
        GOSBVL  =RST2<R
        GOSUBL  =JUMPER
        CON(5)  GETMBX
        GOSUB   TRES2C
        P=C     14
        ?C#0    S
        GOYES   ErrorX
        ?C=0    A
        GOYES   CTAsx
        C=R3
        GOSUB   csrc5
        GOSUB   c=1lc5
        R3=C
        GOSUB   LC40*2
        B=C     A
        D1=(5)  =AVMEMS
        A=DAT1  A
        D1=D1+  (=AVMEME)-(=AVMEMS)
        C=DAT1  A
        C=C-B   A
        ?A<=C   A
        GOYES   MEMOK
        GOVLNG  =MEMERR
CTAsx   GOTO    CTAex
ErrorX  GOTO    errorx
xCTA21  GOTO    CTA21
MEMOK   DAT1=C  A
CTA20   GOSUB   CK=ATn
        GONC    xCTA21
        GOSUBL  =JUMPER
        CON(5)  UTLEND

* On va construire la ligne de DIR sur la MSTK
* (merci Monsieur NZ !)
* au moyen des infos SCRTCH[63:0]

        GOSUBL  =JUMPER
        CON(5)  BLDCAT
        C=R3
        D1=(5)  CNFINF
        DAT1=C  W

        GOSUB   DSPcat  Sortie 

        D1=(5)  CNFINF
        C=DAT1  W
        R3=C

        D1=(5)  =STMTD1 On va causer avec le disque
        C=DAT1  A
        D=C     A
        GOSUBL  =JUMPER
        CON(5)  START
*                       dev est le disque
        GOC     ErrorX
        C=R3
        R2=C            On risque de le perdre (toto:1)
        GOSUB   CTA+
        GOC     ErrorX
        ?C#0    A
        GOYES   CTA20
        GONC    CTAex
*
* Recherche dans le DIR le fichier suivant non puged
CTA+
*       C=R2
        ?C=0    A       Fin du directory ?
        GOYES   CTA+x
* Le DIR n'est pas fini
CTA+0   ?C=0    S       Le disque est-il au bon reccord
        GOYES   CTA+2   Oui pas de repositionnement
* Il faut lire le nouveau reccord
*
        GOSUB   csrc10
        GOSUBL  =JUMPER
        CON(5)  NXTENT
        GOSUBL  =JUMPER
        CON(5)  SEEKRD
        RTNC
* 
* Maintenent le disque est sur le bon record
*
CTA+1   C=R2
CTA+2   ?C=0    A       Fin du directory ?
        GOYES   CTA++
* 
        C=C-1   A       Pourquoi -1 ?
        GOSUB   csrc5
        GOSUB   c+1rc5
        GOSUBL  =JUMPER
        CON(5)  NXTENT
        GOSUB   GDIRSB
        RTNC
CTA+C   ?C=0    WP      TYPE purged ?
        GOYES   CTA+1   Cherche le suivant
        C=C+1   WP
        GONC    CTA+!
CTA++   C=R3
        C=0     A
        C=0     S
        C=C-1   S
        R3=C
        C=0     A
CTA+x   RTNCC
CTA+!   C=R2
        R3=C
        C=C+1   A
        RTNCC

CTAex   A=0     A       Oui on sort proprement
        D1=(5)  =NEEDSC
        DAT1=A  1
        ?C=0    A
        GOYES   CTA39
CTA21   D1=(5)  =AVMEME
        A=DAT1  A
        GOSUB   LC40*2
        A=A+C   A
        DAT1=A  A
CTA39   GOSUBL  =JUMPER
        CON(5)  ENDTAP
        GOLONG  nxtstm
ErrorXx GOTO    ErrorX
*
GDIRSB  A=C     A
        GOSUB   cslc10
        C=0     S
        R2=C
        ASRC
        GOSUBL  =JUMPER
        CON(5)  GETDR+
        RTNC
GDIRS+  D1=(5)  (=SCRTCH)+20
        C=DAT1  4
        P=      3
        RTNCC
*

c+1rc5  C=C+1   A
csrc5   GOVLNG  =CSRC5
c=1lc5  C=0     A
        C=C+1   A
cslc5   GOVLNG  =CSLC5
csrc10  GOVLNG  =CSRC10
cslc10  GOVLNG  =CSLC10
*
outela  GOVLNG  =OUTELA
crlfsd  GOVLNG  =CRLFSD
crlfnd  GOVLNG  =CRLFND
finda   GOVLNG  =FINDA
r<rst4  P=      4
r<rstk  GOVLNG  =R<RSTK
rst4<r  P=      4
rstk<r  GOVLNG  =RSTK<R
TSAV2C  CD0EX
        RSTK=C
        CD0EX
        D0=(5)  =FUNCR1
        DAT0=C  W
TSAV0x  CD0EX
        C=RSTK
        CD0EX
        RTN
TRES2C  CD0EX
        RSTK=C
        D0=(5)  =FUNCR1
        C=DAT0  W
        GOTO    TSAV0x
*
LC40*2  P=      0
        C=0     A
        LC(2)   40*2
        RTNCC
DSPcat
        GOSBVL  =OBCOLL
        D1=(5)  =AVMEME
        A=DAT1  A
        C=0     A
        LC(2)   80
        B=C     A
        D1=D1-  10      =OUTBS
        C=DAT1  A
        C=C+B   A
        D1=D1+  5
        DAT1=C  A
        C=C-B   A
        GOSBVL  =MOVE*M
        GOTO    print

*

*

*
errorx  ?P=     0
        GOYES   error1
        ?P=     1
        GOYES   error1
        ?P=     2
        GOYES   error1
        ?P#     4
        GOYES   error0
        GOSUBL  =JUMPER
        CON(5)  GETMBX
        ?ST=0   12
        GOYES   noabrt
        RSTK=C
        CD0EX
        D0=(5)  =ATNFLG
        C=DAT0  S
        D0=C
        C=RSTK
        ?C=0    S
        GOYES   noabrt
        C=C+1   S
        GONC    error-
noabrt  GOSUBL  =JUMPER
        CON(5)  GETERR
        GONC    error-
        ?P#     4
        GOYES   error1
error-  P=      4
error0  C=P     0
        P=      3
error1  C=P     1
        P=      2
        LC(2)   #FF
        P=      0
        GOLONG  bserr


****************************************************
* print
*
* But : imprimer la ligne comprise entre OUTBS et
*   AVMEMS sur le DISPLAY, le PRINTER ou dans un
*   fichier selon la valeur de OUTYPE.
* Entree :
*   - (OUTBS..AVMEMS) = la ligne
* Sortie : -
* Abime : A-D, R3
* Appelle : CKINFO, SNDWD+, SENDEL, SWPBYT, RPLLIN,
*   MOVED2
* Niveaux : 
* Detail : l'execution de sautln continue en direct
* Historique :
*   88/01/24 : PD & JT isolement dans un sub
*   88/01/29 : PD & JJD & JT pompage depuis BLIST
****************************************************

print   D0=(5)  OUTYPE
        A=DAT0  S       0 : std, 1 : fichier
        ?A#0    S
        GOYES   prnt50
*
* Impression sur DISPLAY ou PRINTER
*
        D0=(5)  =MLFFLG
        LC(1)   #F
        DAT0=C  P
        GOSBVL  =CKINFO Prepare HPIL pour l'envoi

        D1=(5)  =AVMEMS
        A=DAT1  A
        D1=D1-  5       OUTBS
        C=DAT1  A       C(A) := ^ chaine
        A=A-C   A       A(A) := longueur en quartets
        B=0     W
        B=A     A
        BSRB    B(A)    := longueur en octets

        ST=1    =InhEOL Inhibit EOL pour le cas ou

        GOSBVL  =SNDWD+ Envoi proprement dit

        GOVLNG  =SENDEL EOL

*
* Impression dans un fichier
*
prnt50  D0=(5)  =AVMEMS
* Insertion de la longueur LIF
        A=DAT0  A       A(A) := end of source
        D1=A
        D1=D1+  4       D1 := end of dest
        D0=D0-  5       D0=(5) OUTBS
        C=DAT0  A       C(A) := start of source
        GOSBVL  =MOVED2
* Calculer le padding LIF
        D0=(5)  =AVMEMS
        A=0     W
        A=DAT0  A
        D0=D0-  5       OUTBS
        C=DAT0  A
        A=A-C   A       Longueur en quartets
        ASRB            Longueur en octets
        B=A     A       Sauvegarde
        GOSBVL  =SWPBYT
        C=DAT0  A       C(A) := (OUTBS)
        D1=C    D1      := ^ LIF length
        DAT1=A  4
        SB=0
        BSRB
        A=0     A       Longueur a ajouter
        ?SB=0
        GOYES   prnt60  Longueur paire
        A=A+1   A       1 octet a ajouter
prnt60  C=0     A
        LC(1)   4
        A=A+A   A
        A=A+C   A       Longueur totale a ajouter
        D0=D0+  5       AVMEMS
        C=DAT0  A
        C=C+A   A
        DAT0=C  A       AVMEMS + 4 ou 6
* Insertion dans le fichier
        C=0     A
        R3=C    R3      := longueur vieille ligne
        D0=(5)  OUTHDR
        C=DAT0  A       C(A) := ^ file header
        D0=(2)  OUTADR
        A=DAT0  A       A(A) := ^ end of old line
        GOSBVL  =RPLLIN Ne peut pas bouger
        GOC     bSerr
* A(A) = end+1 of replaced line in file
        D0=(5)  OUTADR
        DAT0=A  A
        RTN

bSerr   GOLONG  bserr

	END
