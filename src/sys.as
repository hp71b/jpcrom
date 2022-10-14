	TITLE  SYSEDIT <sys.as>

 JPCPRV	EQU	1

*
* JPC:B01
*   87/06/20: PD/JT Integration de SYSEDIT dans JPC Rom
* JPC:B02
*   87/08/03: PD/JT GOSBVL&GOVLNG => #<adr>, REL(n)=>L<adr>
* JPC:B03
*   87/08/29: PD/JT Copy code du fichier créé = 4
* JPC:C02
*   88/02/12: PD/JT Inversion de RSI et PC=(A)
* JPC:C03
*   88/04/16: PD/JT Utilisation de INENDL pour poll FINPUT
* JPC:D01
*   88/12/18: PD/JT Syntaxe de SYSEDIT, OPCODE$ et NEXTOP$
* JPC:E02
*   90/06/24: PD/JT Bug fix de Markov (REL(n) en arrière avec n < 5)
*

*
* Voir OPCout pour les details sur ces EQU
*
 opcode EQU    (=SCRTCH)+00   6 octets
 modifi EQU    (=SCRTCH)+12  16 octets
 branch EQU    (=SCRTCH)+44   6 octets
 adress EQU    (=SCRTCH)+56   5 octets

 sysedt EQU    10	No de flag pour retour dans OPCODE$

 EscSt0 EQU    0
 EscSt1 EQU    1

*
* Definitions pour les routines dspxxx
*
 sBLANC EQU    1	1 si un blanc rencontre
 sGUIL	EQU    2	1 si un guillemet rencontre
 sCRLF	EQU    3	1 si il faut afficher CR/LF

*
* Voir IDS 1, page 17-19
*
 sBADRC EQU    8

*
* Pour [ENDLINE] et fichier
*
 rplc#	EQU    1
 chrc/	EQU    2

************************************************************
* INIT
*
* But: analyser la chaine au sommet de la M.S. et
*   en extraire une adresse valide.
* Entree:
*   - B(A) = adresse trouvee (sortie de ADDRCK)
* Sortie:
*   - R3(A) = adresse trouvee
*   - R2(W) = 16 quartets a l'adresse trouvee
*   - D(3-0) = 4 quartets a l'adresse trouvee + 16
*   - ST(1) = 0
*   - D1 actualise
* Utilise: A, B, C, D(A), R2, R3, ST(1), D1
* Niveaux: 0
* Historique:
*   86/../..: JJD conception & codage
*   87/05/13: PD  ajout de documentation
*   87/05/20: PD & JT retrait de ADDRCK et renommage en INIT
************************************************************

 INIT	A=B    A
	R3=A		R3 = adresse trouvee
	ST=0   1
	AD0EX
	C=DAT0 W	C(W) := 16 q. pointes
	R2=C		R2 := 16 quartets pointes
	D0=D0+ 15	D0 = 15 quartets plus loin
	C=DAT0 A
	D=C    A	D(A) := 5 q. suivants
	D0=A		D0 restaure
	RTN

************************************************************
* NEXTOP$
*
* Syntaxe: NEXTOP$ ( <adr> )
* Entree: adresse en hexadecimal
* Sortie: adresse de l'instruction suivante
* Historique:
*   86/../..: JJD conception & codage
*   87/05/13: PD  ajout de documentation
*   88/12/18: PD/JT changement de syntaxe
************************************************************

	CON(1) 4+8	Parametre numerique ou alpha
	NIBHEX 11
=NEXTOPe
	GOSUBL =POPADR	modifie le 18 decembre 1988
	GOSUB  INIT
	GOSUB  GETNXT
	A=C    A
	C=0    W
	P=     4
	CPEX   15
	D=C    W
	GOSBVL =HEXASC
	D=D+1  S
	D=D+D  S
	DSLC
	C=D    A
	GOSBVL =STRHDR
	P=C    0
	P=P-1
	A=B    W
	DAT1=A WP
	D1=D1- 16
	P=     0
	GOSBVL =REV$
	GOVLNG =EXPR
  
************************************************************
* GETNXT
*
* But: trouver l'adresse de l'instruction suivante
* Entree:
*   - R2 = 16 quartets a l'adresse courante
*   - B(A) = adresse courante
* Sortie:
*   - C(A) := nouvelle adresse
*   - P = ?
* Utilise: A, C, P
* Appelle: -
* Niveaux: 0
* Historique:
*   86/../..: JJD conception & codage
*   87/05/13: PD  ajout de documentation
*   87/05/14: PD  renonce a documenter
*   87/05/14: PD  ajout de PC=(A)
************************************************************

 GETNXT
*
* Ajout de PC=(A)
*
	A=R2		A(W) := 16 quartets
	LCHEX  01808	PC=(A)
	?A#C   A
	GOYES  GETN05	pas PC=(A)
	P=     4	5 quartets de long
	C=P    15	C(S) := 4
	GOTO   GETN99	Mille excuses encore...
 GETN05
*
* Fin des lignes triviales. J'ai le sentiment
* d'avoir commis un sacrilege...
*
	C=R2		C(W) := 16 quartets
	A=C    A	A(A) := 5 quartets pointes
	P=C    0	P = 1er quartet de l'inst.
	LCHEX  9A1A2233A4221111
*
* 1er q.  C(S)
*   0	   9	    Instructions a 2 ou 4 quartets
*   1	   A	    Instructions a 3, 4, 6 ou 7 quartets
*   2	   1	    Instructions P=
*   3	   A	    Instructions LCHEX
*   4	   2	    Instructions a 3 quartets
*   5	   2	    Instructions a 3 quartets
*   6	   3	    Instructions a 4 ou 5 quartets
*   7	   3	    Instructions a 4 quartets
*   8	   A	    Instructions a 3, 4, 6 ou 7 quartets
*   9	   4	    Instructions a 3 quartets
*   A	   2	    Instructions a 3 quartets
*   B	   2	    Instructions a 3 quartets
*   C	   1	    Instructions a 2 quartets
*   D	   1	    Instructions a 2 quartets
*   E	   1	    Instructions a 2 quartets
*   F	   1	    Instructions a 2 quartets
*

*
* Si l'instruction necessite un traitement special
* le bit de poids fort est mis a 1.
* Sinon, ce bit est a 0, et les trois bits restant
* codent <len - 1>
*
	C=C+C  S	Necessite trait. special ?
	CSRB
	GONC   GETN99	Non : bit poids fort = 0
*
* L'instruction necessite un traitement special
*
	A=C    S	A(S) = q. reconnaissance
	C=0    W
	?P#    8	Instructions 8...
	GOYES  GETN10	Non
*
* Instructions 8???
* 3, 4, 6 ou 7 quartets
*
	C=P    0	C(0) = 8
	P=     4
	?C#A   B	Instruction = 80.. ?
	GOYES  GETN10
*
* Instruction de type 80...
*
	ASR    A	8 disparait
*
* reste A(A) = 0???0
*
	P=     2
*
* A(S) = quartet de reconnaissance
* P = 8, 4 ou 2
*
 GETN10 LCHEX  82401
	CAEX   A
	P=C    1
	LCHEX  20
	A=A+A  A
	GOC    GETN20
	LCHEX  10001101
	A=A+A  A
	GOC    GETN20
	LCHEX  10001340134
	A=A+A  A
	GOC    GETN20
	LCHEX  2002222223434
	A=A+A  A
	GOC    GETN20
	C=P    15
 GETN20 C=C+A  S
 GETN99 P=C    15
	A=R2
	C=B    A
	GONC   GETN30
	C+P+1
	P=     15
 GETN30 C+P+1
	RTN

************************************************************
* rsi
*
* But: traiter l'instruction RSI (opcode 808C)
* Historique:
*   87/05/15: PD  conception & codage
************************************************************

 rsi
	LCASC  'ISR'
	D0=(5) opcode
	DAT0=C 6
	C=0    A
	LC(1)  3
	GOTO   special

************************************************************
* pca
*
* But: traiter l'instruction PC=(A) (opcode 80810)
* Historique:
*   87/05/15: PD  conception & codage
************************************************************

 pca
	P=     0
	LCASC  ')A(=CP'
	D0=(5) opcode
	DAT0=C 12
	C=0    A
	LC(1)  6

 special
	R0=C
	C=0    A
	R1=C
	R2=C
	R3=C
	
	GOLONG out500

************************************************************
* OPCODE$
*
* But: Obtenir la mnemonique de l'instruction
*   pointee par l'adresse indiquee.
* Entree:
*   - OPCODE$ : l'adresse est sur la M.S.
*   - getopc :
*	- D1 = emplacement ou sera depose le resultat
*	- B(A) = adresse de l'instruction
* Sortie:
*   - l'instruction est sur la M.S.
*   - OPCODE$ : sortie par ADHEAD
*   - getopc : sortie par RTN en out999
*     R1 = ^ 1er caractere
*     D1 = ^ dernier caractere (cond. entree ADHEAD)
* Historique:
*   86/../..: JJD conception & codage
*   87/05/14: PD  ajout de documentation
*   87/05/20: PD & JT ajout du point d'entree getopc (ST10)
*   88/12/18: PD/JT changement de syntaxe
************************************************************

 getopc ST=1   sysedt
	GOTO   OPC00

 pcA	GOTO   pca

	CON(1) 8+4	Num + Alpha
	NIBHEX 11
=OPCODEe
	GOSUBL =POPADR	modifie le 18 decembre 1988
	ST=0   sysedt
 OPC00

	GOSUB  INIT
*
* B(A) = adresse
* R2 = 16 quartets pointes par B(A)
* D(3-0) = 4 quartets pointes par B(A)+16
*
	GOSUB  GETNXT
*
* D0 = PC
* D1 = ^ M.S. derriere l'adresse
*
	CD0EX		C(A) := PC
	D0=(5) =FUNCD0
	DAT0=C A	FUNCD0 := PC
	D0=D0+ 5	D0=(5) =FUNCD1
	CD1EX		C(A) := MS
	DAT0=C A	FUNCD1 := MS
	CD0EX		D0 := ^ MS
	P= 0

*
* Traitement des deux instructions speciales
*
	A=R2
	LCHEX  01808
	?A=C   A
	GOYES  rsibis
	LCHEX  C808
	P=     3
	?A#C   WP
	GOYES  opc001
	GOTO   pcA
 rsibis	GOTO   rsi
 opc001
	P=     0
*
* Fin du traitement special des deux instructions
*
	LCHEX  0041
	BCEX   W
	GOSBVL =CSLW5	C(9-5) := adresse
	R1=C		R1 (9-5) := adresse
	ST=0   4
	ST=0   7
	GOSUB  OPC10

	NIBHEX 01222222
	NIBHEX 3458679A
	NIBHEX D8000000
	NIBHEX 00000011
	NIBHEX 2005210C
	NIBHEX 06211004
	NIBHEX 21200721
	NIBHEX 30152148
	NIBHEX 20F05038
	NIBHEX E060D0A1
	NIBHEX 7080AD80
	NIBHEX 00AB9000
	NIBHEX ACA050A0
	NIBHEX B820A8F2
	NIBHEX 0021E022
	NIBHEX C41680DC
	NIBHEX 06809113
	NIBHEX 43101384
	NIBHEX 01384092
	NIBHEX 84092840
	NIBHEX 60000001
	NIBHEX 11111111
	NIBHEX 16223000
	NIBHEX 7421004C
	NIBHEX 320C4433
	NIBHEX 0E725400
	NIBHEX FB5500FB
	NIBHEX D622262D
	NIBHEX 43072BC2
	NIBHEX 08AC430B
	NIBHEX 10430CAA
	NIBHEX C20F10C2
	NIBHEX 06222220
	NIBHEX 48031000
	NIBHEX 64318085
	NIBHEX 310186A1
	NIBHEX 8187000A
	NIBHEX 98F01222
	NIBHEX 22222345
	NIBHEX 55589000
	NIBHEX 00000123
	NIBHEX 32232232
	NIBHEX 4000A331
	NIBHEX 0083320D
	NIBHEX 10030D80
	NIBHEX 04918415
	NIBHEX B1C0060E
	NIBHEX 80070302
	NIBHEX D0200000
	NIBHEX 00000000
	NIBHEX 000E024E
	NIBHEX 014E0FC0
	NIBHEX 4E0A1229
	NIBHEX 41083C20
	NIBHEX 602D2058
	NIBHEX 0F200C24
	NIBHEX 126A0835
	NIBHEX 0B0400FE
	NIBHEX 00C52813
	NIBHEX 01700614
	NIBHEX 00A14000
	NIBHEX 0000A145
	NIBHEX 32520500
	NIBHEX 832500C4
	NIBHEX 458805C4
	NIBHEX 88066588
	NIBHEX 47E48848
	NIBHEX 62404964
	NIBHEX 40415181
	NIBHEX 30131028
	NIBHEX C1024C50
	NIBHEX 08C5004C
	NIBHEX 81301310
	NIBHEX 20D1020E
	NIBHEX 1028D102
	NIBHEX 8EA122C2
	NIBHEX A8A8D400
	NIBHEX 38E088BA
	NIBHEX F4004810
	NIBHEX 18132250
	NIBHEX 52840528
	NIBHEX 40528422
	NIBHEX 28481302
	NIBHEX 44008400
	NIBHEX 28400284
	NIBHEX 80204101
	NIBHEX 81326503
	NIBHEX 28424284
	NIBHEX 03284032
	NIBHEX 84813011
	NIBHEX 00414008
	NIBHEX 14002A42
	NIBHEX 22A4

 OPC20	A=R2
	LCHEX  741
	?C<A   P
	GOYES  OPC22
	?A=0   P
	GOYES  OPC21
	C=A&C  X
	R2=C
	A=A+A  XS
	ASL    X
	ASR    A
	GOC    OPC31
	GONC   OPC23
 OPC21	A=A+1  XS
	GOC    OPC26
	A=A-1  XS
	GONC   OPC23
 OPC22	ASL    A
	D1=D1+ 2
	?C>=A  XS
	GOYES  OPC23
	D1=D1+ 16
	D1=D1+ 10
 OPC23	C=A    A
	P=C    2
	LCHEX  0665CB070665CB07
	C=C+C  A
	P=C    0
	LCASC  'BMSXPW'
	GOC    OPC25
	P=     2
	LCHEX  00
 OPC25	P=     0
	B=C    A
 OPC26	ASR    A
	ASR    A
	ASR    A
	RTNCC
 OPC30	A=R2
 OPC31	LCHEX  3131
	?C=A P
	GOYES  OPC33
	C=C-1  XS
	A=A+A  P
	GOC    OPC32
	ASL    A
 OPC32	?A#0   B
	GOYES  OPC33
	ASR    A
 OPC33	SETDEC
	C=C+A  XS
	GOC    OPC34
	C=0    B
 OPC34	SETHEX
	B=C    A
	ST=1   4
	RTNCC

 OPC10	C=RSTK
	D1=C
 OPC11	C=DAT1 B
	D1=D1+ 1
	GOSUB  TBLJMc
	GOTO   OPC11
 TBLJMc GOSBVL =TBLJMC
	REL(3) OPC40
	REL(3) OPC20
	REL(3) OPC140
	REL(3) OPC100
	REL(3) OPC50
	REL(3) OPC30
	REL(3) OPC60
	REL(3) OPC72
	REL(3) OPC71
	REL(3) OPC70
	REL(3) OPC80
	REL(3) OPC90
	REL(3) OPC110
	REL(3) OPC120

 OPC40	C=A    A
	D=C    P
	C=DAT1 W
	CSL    W
	D1=D1+ 15
 OPC41	CSRC
	A=A-1  P
	GONC   OPC41
	ASR    A
	C=0    A
 OPC42	C=DAT1 B
	D1=D1+ 2
	C=C-1  S
	RTNC
	AD1EX
	A=A+C  A
	AD1EX
	GONC   OPC42
 OPC50	LCHEX  4558
	D0=D0- 4
	DAT0=C 4
	RTNCC

 OPC60	A=R2
	C=B    S
	?ST=1 7
	GOYES  OPC62
	GOSUB  OPC170
	B=B-1  S
	B=B-1  S
	C=B    S
	CR2EX
	DSR    A
	C=D    B
	CSRC
	CSRC
 OPC61	ASL    W
	A=C    P
	CSR    W
	B=B-1  S
	GONC   OPC61
	C=R2
 OPC62	GOSUB  OPC172
	ASR    W
	C=C-1  S
	GONC   OPC62
	RTNCC
 OPC70	P=     1
 OPC71	P=P+1
 OPC72	C=D    A
 OPC73	CSR    W
	P=P-1
	GONC   OPC73
	A=C    A
	P=     0
	GOC    OPC62
 OPC80	C=R2
	A=C    A
	P=C    2
	LCHEX  5236789CDABEF014
	A=C    XS
	C=C+C  XS
	P=C    2
	LCHEX  A0C1C0A1A0C1C0A1
	D=C    A
	P=     0
	LCHEX  C42
	GONC   OPC81
	B=C    B
 OPC81	C=C-1  A
	?C#A   B
	GOYES  OPC82
	ST=1   4
 OPC82	C=A&C  XS
	P=C    2
	LCHEX  6F300FC86F180FC0
	CSL    A
	A=R1
	A=A&C  A
	GOTO   OPC116
 OPC90	C=R2
	P=C    2
	C=C+C  XS
	LCHEX  3412301234123012
	P=     1
	LCHEX  A
	GONC   OPC91
	LCHEX  C
 OPC91	P=     0
	D=C    A
	RTNCC
 OPC100 ST=1   4
	LCHEX  0C
	C=A&C  P
	A=A-C  P
	ASRC
	A=DAT1 A
	C=C+C  A
	C=C+C  A
	CSL    A
	P=     7
	D1=D1+ 3
	LCHEX  0040408
	C=C-1  XS
	GOC    OPC101
	D1=D1+ 5
	LCHEX  44008
	C=C-1  XS
	GOC    OPC101
	D1=D1+ 10
	LCHEX  4C
	C=C-1  XS
	GONC   OPC101
	D1=D1- 5
	LCHEX  44004C
 OPC101 A=C    M
 OPC102 CSL    W
	A=A-1  XS
	GONC   OPC102
	C=C+A  S
	P=C    15
	C=C+C  S
	GONC   OPC103
	ST=0   4
 OPC103 LCHEX  CDBCACCCCCBBBBAB
	DSL    A
	D=C    B
	C=A    W
	ASL    A
	?A#0   XS
	GOYES  OPC102
	P=     0
	C=DAT1 A
	?C=0   A
	GOYES  OPC118
	GOTO   OPC142
 OPC110 A=R2
	LCHEX  04100
 OPC111 ?C=A   XS
	GOYES  OPC114
	C=C+C  A
	?C#0   XS
	GOYES  OPC111
	LCHEX  42F38
	?C=A   B
	GOYES  OPC113
	?C#A   XS
	GOYES  OPC112
	GOSBVL #1CEE2	D1+21B : non supporte
	LCHEX  78A00
	GONC   OPC115
 OPC112 ?A=0   XS
	GOYES  OPC117
 OPC113 C=0    X
	?A=0   XS
	GOYES  OPC114
	CSL    A
	C=C+C  A
	C=A    XS
 OPC114 A=R1
	C=C+A  A
 OPC115 A=C    A
 OPC116 R1=A
	P=     0
	RTNCC

 OPC117 C=RSTK
 OPC118 ST=1   7
	LCHEX  0808C
	GOTO   OPC133
 OPC120 C=RSTK
	C=R1
	C=B    S
	?C#0   A
	GOYES  OPC121
	GOSUB  OPC161
	LCHEX  2F
	GOSUB  OPC171
	LCHEX  20202
 OPC121 C=C+C  P
	GOC    OPC126
	A=R2
 OPC122 C=C-1  S
	ASR    W
	C=C-1  XS
	GONC   OPC122
	B=0    A
	P=C    15
	B=A    WP
	A=A+A  P
	GONC   OPC123
	B=-B   WP
	B=-B   A
 OPC123 P=     0
	C=C+C  P
	GONC   OPC124
	A=0    A
	A=C    B
	ASR    B
	?A=B   A
	GOYES  OPC118
 OPC124 C=C+C  P
	GONC   OPC125
	?B#0   A
	GOYES  OPC125
	GOSUB  OPC130
	NIBHEX 000F9
	NIBHEX 02089
	NIBHEX 06089
 OPC125 R2=C
	P=C    4
	GOSBVL =CSRC5
	C+P+1
	C=C+B  A
	CSL    W
	CSL    W
	CR2EX
 OPC126 GOSUB  OPC130
	NIBHEX 40076
	NIBHEX 42006
	NIBHEX 46006
	NIBHEX 48007
	NIBHEX 40C16
	NIBHEX 4D106
	NIBHEX 45306
	NIBHEX 40D16
	NIBHEX 40716

 OPC130 P=C    3
	C=RSTK
	D1=C
 OPC131 P=P-1
	GOC    OPC132
	D1=D1+ 5
	GONC   OPC131
 OPC132 LCHEX  6
	B=C    S
	P=     0
	A=R2
	C=DAT1 A
 OPC133 A=0    A
	GOSUB  OPC150
	NIBASC 'RGOTNYES'
	NIBASC 'UBVLONCG'
	NIBHEX 0560

 OPC140 A=DAT1 B
	D1=D1+ 1
 OPC141 C=DAT1 6
	D1=D1+ 6
	?D>C   P
	GOYES  OPC141
	CSR    W
 OPC142 GOSUB  OPC150

	NIBHEX F370C3E3
	NIBHEX D332D235
	NIBHEX 25C48062
	NIBHEX 12B2D290
	NIBHEX 400313D0
	NIBHEX 34D3C425
	NIBHEX 35544584
	NIBHEX 44E43534
	NIBHEX B4D35434
	NIBHEX 85D49400
	NIBHEX D0C434B2
	NIBHEX 05404403
	NIBHEX 13D30534
	NIBHEX 440313B2
	NIBHEX D2135060
	NIBHEX 10A0B070
	NIBHEX D3254414
	NIBHEX 4580D370
	NIBHEX 54853500
	NIBHEX 00000000
	NIBHEX 3584F455
	NIBHEX 94E445D3
	NIBHEX 34F43514
	NIBHEX D39444E4
	NIBHEX 64649474
	NIBHEX C0F384D4
	NIBHEX 35358503
	NIBHEX 45052524
	NIBHEX D4D33203
	NIBHEX 1350D000
	NIBHEX 24553534
	NIBHEX C4258454
	NIBHEX 15F33554
	NIBHEX 4534

 OPC150 AR1EX
	A=C    A
	AR1EX
	C=RSTK
	D1=C
 OPC151 A=A-1  P
	GOC    OPC153
	D1=D1+ 16
	D1=D1+ 16
	D1=D1+ 8
	GONC   OPC151
 OPC152 GOSUB  OPC171
 OPC153 LCHEX  10
	A=C    A
	AR1EX
	?A=0   A
	GOYES  OPC160

 OPC154 C=DAT1 B
	D1=D1+ 2
	A=A+A  A
	GONC   OPC154
	AR1EX
	?C>=A  B
	GOYES  OPC152
	GOSUB  TBLJMc
	GOTO   OPC153

 OPC160 C=RSTK
	GOSUB  OPC161
	GOTO   OPCout

 OPC161 ?ST=0  4
	RTNYES
	GOSUB OPC170
	ST=0   4
	GOSUB  OPC162
	BSR A
	BSR A
 OPC162 ?B=0 B
	RTNYES
	C=B    A
	GONC   OPC171	B.E.T.
 OPC170 LCHEX  20
 OPC171 D0=D0- 2
	DAT0=C B
	RTNCC

 OPC172 LCHEX 439
	?C>=A P
	GOYES OPC173
	A=A-C P
	CSR   A
 OPC173 C=A   P
	GOTO  OPC171

 OPCout CD0EX		C(A) := ^ M.S.
	CD1EX		D1 := ^ M.S.
	D0=(5) =FUNCD1
	C=DAT0 A	C(A) := vieux pointeur M.S.
	R1=C		R1 := bottom of M.S.
*
* A nouveau, je m'excuse de profaner un code aussi
* beau tellement il est illisible. Helas, les
* necessites m'obligent a souiller ces lieux. Je
* m'en vais decrire les exactions que j'envisage :
*
* Les opcodes peuvent etre decomposes en 6 classes
* Opcode seul :
*   ex: RTN
* Opcode + Modifier :
*   ex: A=0 A
* Opcode + Modifier + Branch :
*   ex: ?A=0 A/RTNYES
* Opcode + Branch :
*   ex: ?MP=0/RTNYES
* Opcode + Modifier + Branch + Adresse :
*   ex: ?A=0 A/GOYES 12345
* Opcode + Branch + Adresse :
*   ex: ?MP=0/GOYES 12345
*
* Taille maximum des champs :
*   opcode   : 6 octets
*   modifier : 16 octets (LCHEX)
*   branch   : 6 octets
*   adresse  : 5 octets, puis 6 avec un #
*

*
* La transformation correspond au programme Basic
* suivant :
*
* 1000 SUB TRANSF(A$,R$) ! A$=donnee, R$=resultat
*    - Decomposition en 4 champs
* 1010 E=POS(A$," ")	 ! espace
* 1020 S=POS(A$,"/")	 ! slash : il y a un test
* 1030 IF E=0 AND S=0 THEN R$=A$ @ END !opc. seul
* 1040 IF S THEN X$=A$[S+1] @ A$=A$[1,S-1]
*    - X$ = test s'il y a lieu
*    - A$ = donnee sans test s'il y a lieu
* 1050 IF E THEN M$=A$[E+1] @ A$=A$[1,E-1]
*    - M$ = modifier s'iul y a lieu
*    - A$ = opcode seul (sans modifier)
* 1060 O$=A$
* 1070 E=POS(X$," ")	 ! espace dans le test
* 1080 IF E THEN D$=X$[E+1] @ X$=X$[1,E-1]
*    - D$ = adresse s'il y a lieu
*    - X$ = RTNYES ou GOYES ou chaine vide
* 1090 B$=X$
*    - Fin de la separation
*      O$ = opcode
*      M$ = modifier
*      B$ = branch if test
*      D$ = adresse if GOYES
* 1100 IF O$="LC" THEN O$="LCHEX"
* 1110 IF O$="D0=" OR O$="D1=" THEN
*	  O$=O$&"("&STR$(LEN(M$))&")" @ M$="#"&M$
*    - D0=(n) #?????
*      valeur en hexadecimal
* 1120 IF O$[1,2]="GO" THEN M$="#"&M$
*    - GONC, GOC, GOSUB, GOTO, GOSUBL, GOLONG,
*      GOSBVL ou GOVLNG toujours suivis d'une
*      adresse en hexadecimal.
* 1130 R$=O$
* 1140 IF LEN(M$) THEN R$[8]=M$
* 1150 IF LEN(B$) THEN R$=R$&"/"&B$
* 1160 IF LEN(D$) THEN R$=R$&"	#"&D$
* 1170 END SUB
*

*
* Resumons nous :
*   D0 = FUNCD1
*   D1 = M.S.
*   C(A) = vieux pointeur de M.S.
*
	D=0    W	D(W) := 0
	D=C    A	D(A) := vieux pointeur
	CD1EX		C(A) := pointeur actuel
*			D1 := vieux pointeur
	D=D-C  A	D(A) := taille en quartets
	DSRB		D(A) := taille en octets
*
* L'exploration qui va suivre a besoin de :
* D(A) = nb de caracteres restant
*

*
* Champ opcode :
*
	D0=(5) opcode
	GOSUB  getchp
	C=B    A
	R0=C
	B=0    A	lg de modifier par defaut
	LCASC  '/'
	?A=C   B
	GOYES  out100
*
* Champ modifier
*
	D0=(5) modifi
	GOSUB  getchp
 out100
	C=B    A
	R1=C
*
* Champ branch
*
	D0=(5) branch
	GOSUB  getchp
	C=B    A
	R2=C
*
* Champ adresse
*
	D0=(5) adress
	GOSUB  getchp
	C=B    A
	R3=C
*
* Le decoupage en champs est termine.
* On a :
* R0 = longueur en octets de l'adresse
* R1 = longueur en octets du branch
* R2 = longueur en octets du modifier
* R3 = longueur en octets de l'opcode
*
	D1=(5) =FUNCD1
	C=DAT1 A
	D1=C		D1 := ^ M.S.
*
* Debut de la phase d'analyse :
*
	D0=(5) opcode
	A=0    A
	C=0    A
	A=DAT0 4
	LCASC  'CL'	 LC
	?A#C   A
	GOYES  out110
*
* LC -> LCHEX
*
	LCASC  'XEHCL'	 LCHEX
	DAT0=C 10
	C=0    A
	LC(1)  5
	R0=C
	GOTO   out500

*
* D0= ou D1= ?
*
 out110
	A=R0		 A(A) := longueur de opcode
	LC(1)  3
	?A#C   P
	GOYES  out120
	A=0    W
	C=0    W
	A=DAT0 6
	LCASC  '=0D'
	?A=C   W
	GOYES  out115
	LCASC  '=1D'
	?A#C   W
	GOYES  out120
 out115
*
* D0= ou D1= -> D0=(n) #...
*
	D0=(2) (opcode)+2*3
	LCASC  '('
	DAT0=C B
	D0=D0+ 2
	A=R1		C(A) := longueur modifier
	LCASC  '0'
	C=C+A  B
	DAT0=C B
	D0=D0+ 2
	LCASC  ')'
	DAT0=C B

	A=R0
	A=A+1  A	longueur opcode + 3
	A=A+1  A
	A=A+1  A
	R0=A

 out117
*
* Insertion d'un # dans le modifier
*
	D0=(5) modifi
	A=DAT0 2*5
	LCASC  '#'
	DAT0=C B
	D0=D0+ 2
	DAT0=A 2*5

	A=R1
	A=A+1  A	longueur modifier + 1
	R1=A

	GONC   out500	B.E.T.

 out120
	D0=(5) opcode
	A=0    A
	C=0    A
	A=DAT0 4
	LCASC  'OG'
	?A=C   A
	GOYES  out117	inserer un #
	
*
* Reconstition de l'opcode a partir des 4 champs
*
 out500
*
* Sauvegarde de la longueur de l'opcode en B(S)
* et du modifier en R0.
*
	C=R0
	CSRC		C(S) := longueur opcode
	B=C    S	B(S) := longueur opcode
	C=R1
	R0=C
*
* Recuperation des pointeurs fondamentaux.
*
	GOSBVL =D=AVMS
	D1=(5) =FUNCD1
	C=DAT1 A
	D1=C
	R1=C		Pour ADHEAD

*
* Champ opcode :
*
	D0=(5) opcode
	A=0    W
	A=B    S
	ASLC		A(A) := longueur en octets
	GOSUB  wrtchp

	C=R0		C(A) := longueur modifier
	?C=0   A
	GOYES  out600	branch / adresse
*
* Tabulation du modifier
*
	BSLC		B(0) := longueur en octets
	LC(1)  7
	B=C-B  P	C(0) := nb esp. a ajouter
	LCASC  ' '
	GONC   out520
 out510 GOSUB  stkchr
 out520 B=B-1  P
	GONC   out510
*
* Ajout du modifier
*
	D0=(5) modifi
	A=R0		A(=A) := lg du modifier
	GOSUB  wrtchp
*
* Y a t-il un branch ?
*
 out600
	C=R2
	?C=0   A
	GOYES  out999	Non : sortie
	LCASC  '/'
	GOSUB  stkchr
*
* Branch
*
	D0=(5) branch
	A=R2
	GOSUB  wrtchp
*
* Y a-t-il une adresse ?
*
	C=R3
	?C=0   A
	GOYES  out999	Non : sortie
*
* Tabulation : 2 espaces et un "#"
*
	LCASC  ' '
	GOSUB  stkchr
	GOSUB  stkchr
	LCASC  '#'
	GOSUB  stkchr
*
* adresse :
*
	D0=(5) adress
	A=R3
	GOSUB  wrtchp
*
* Fin !
* Sortie de la fontion, la chaine est sur la MS
*
 out999
*
* Sortie vers Basic, ou sortie vers l'appelant (SYSEDIT) ?
*
	?ST=1  sysedt
	RTNYES		Retour a SYSEDIT
*
* Sortie vers Basic :
*
	D0=(5) =FUNCD0
	C=DAT0 A
	D0=C
	ST=0   0	No return desired
	GOVLNG =ADHEAD

************************************************************
* getchp
*
* But: placer a MEM(D0) le champ trouve sur la MS
*   et renvoyer sa longueur.
* Entree:
*   - D0 = ^ sauvegarde du champ
*   - D1 = ^ MS
*   - D(A) = longueur en octets de ce qui reste
* Sortie:
*   - B(A) = longueur trouvee
*   - MEM(D0) = champ trouve
*   - D(A) = longueur de ce qui reste
*   - A(B) = dernier caractere reconnu
* Utilise: A(B), C(B), D(A), D0, D1
* Appelle: -
* Niveaux: 0
* Detail:
*   Un champ est termine par le premier espace ou
*   slash rencontre.
* Historique:
*   87/05/15: PD  conception & codage
************************************************************

 getchp
	B=0    A
 getc10
	?D=0   A
	RTNYES
	D=D-1  A
	D1=D1- 2
	A=DAT1 B
	LCASC  ' '
	?A=C   B
	RTNYES
	LCASC  '/'
	?A=C   B
	RTNYES
	DAT0=A B
	D0=D0+ 2
	B=B+1  A
	GONC   getc10	B.E.T.

**************************************************
* wrtchp
*
* But: envoie le champ pointe par D0 sur la MS
* Entree:
*   - D0 = ^ champ
*   - D1 = ^ MS
*   - A(A) = longueur du champ
*   - D(A) = AVMEMS
* Sortie:
*   - D1 reactualise
* Utilise: A(A), C(B), D1
* Appelle: STKCHR
* Niveaux: 1
* Historique:
*   87/05/15: PD  conception & codage
**************************************************

 wrtchp
	?A=0   A
	RTNYES
	C=DAT0 B
	D0=D0+ 2
	GOSUB  stkchr
	A=A-1  A
	GONC   wrtchp	B.E.T.

 stkchr GOVLNG =STKCHR

*
* Les variables utilisees par SYSEDIT :
*
* dADR	 : adresse courante
*	   5 quartets
* dKEY	 : derniere touche prise en compte
*	   2 quartets
*	   code physique de la derniere touche lue
* dETAT	 : etat de l'automate
*	   1 quartet
*	   0 a 6
* dREJEC : rejet de la touche courante
*	   1 quartet
*	   1 si lecture clavier necessaire
* dLINE	 : ligne courante
*	   23*2 quartets + 2 (FF = marqueur fin ligne)
*	   ligne couramment envoyee a l'affichage
* dSTACK : pile
*	   1+5*......
*	   la pile des adresses de retour + le pointeur
* dLEN	 : longueur de l'instruction courante
*	   2 quartets
* dFILE	 : adresse dans le fichier de sortie
*	   5 quartets
*	   adresse ou inserer la prochaine ligne de texte
* dHEADR : adresse du header du fichier de sortie
*	   5 quartets
*	   adresse du nom du fichier (1er quartet du header)
* dMODE	 : mode desassemblage
*	   1 quartet
*	   1 si mode desassemblage, 0 sinon
*

 dFILE	EQU    =LDCSPC	     5 quartets
 dHEADR EQU    =LEXPTR	     5 quartets
 dADR	EQU    (=TRFMBF)+00  5 quartets
 dKEY	EQU    (=TRFMBF)+05  2 quartets
 dETAT	EQU    (=TRFMBF)+07  1 quartet
 dREJEC EQU    (=TRFMBF)+08  1 quartets
 dLEN	EQU    (=TRFMBF)+09  2 quartets
 dMODE	EQU    (=TRFMBF)+11  1 quartet
 dLINE	EQU    (=TRFMBF)+12 48 quartets
 dSTACK EQU    =STMTR0	7 niveaux dans la pile
 MAXLVL EQU    7

 dSC1	EQU    (=STMTR0)+1+7*5 4 quartets
 dSC2	EQU    =STSAVE	       3 quartets

************************************************************
* clrrpt
*
* But: effacer toiute trace de repetition de touche.
* Entree: -
* Sortie: -
* Abime: C(A), D(0)
* Niveaux: 0
* Detail: pompe dans le code de KA, lui meme pompe dans le
*   code de CHEDIT.
* Historique:
*   87/05/18: P.D. & J.T. reconception & repompage
************************************************************

 clrrpt D0=(5) =KEYPTR
	C=0    A
	C=DAT0 XS
	?C#0   XS
	RTNYES		retour si buffer vide
	D0=(4) (=KEYBUF)+2*14
	DAT0=C B
	RTN

************************************************************
* dspmod
*
* But: afficher une ligne suivant le mode (desassemblage ou
*   hexadecimal) courant.
* Entree:
*   - dMODE = 1 si desassemKblage, 0 si hexadecimal
* Sortie:
*   - par stddsp ou desdsp
* Historique:
*   87/05/19: conception & codage sans desdsp
************************************************************

 stddsP GOTO   stddsp

 dspmod D0=(5) dMODE
	C=DAT0 S
	?C=0   S
	GOYES  stddsP
*
* Affichage en mode desassemblage
*

************************************************************
* desdsp
*
* But: afficher l'instruction courante.
* Entree:
*   - dADR : adresse de l'instruction
* Sortie:
*   - dLINE : instruction non reduite (avec les tabulations)
*   - dLEN : longueur de l'instruction
*   - dMODE = 1 (mode desassemblage)
* Abime: Function Scratch, CPU registers, ST, Math-Stack
* Appelle: getopc
* Niveaux: 5
* Historique:
*   87/05/20: P.D. & J.T. conception & codage
************************************************************

 desdsp
*
* Initialiser la M.S.
*
	GOSBVL =COLLAP
	D1=C		D1 := ^ M.S.
*
* Lecture de l'adresse
*
	D0=(5) dADR
	A=DAT0 A
	B=A    A
*
* dLINE=OPCODE$(dADR)
*
	GOSUBL getopc

	C=0    W
	CD1EX		C(A) := ^ dernier caractere
	A=R1
	C=A-C  A	C(A) := nb de quartets de la chaine
	CSRB		C(A) := nb de car de la chaine

	D1=(5) dLINE	D1 := ^ dLINE
	A=R1
	D0=A		D0 := ^ caractere dans la M.S.
	GOTO   desd20
 desd10 D0=D0- 2
	A=DAT0 B
	DAT1=A B
	D1=D1+ 2
 desd20 C=C-1  A
	GONC   desd10
*
* FF
*
	LC(2)  -1
	DAT1=C B
*
* dLEN := OPLEN (dADR)
*
	D0=(5) dADR
	A=DAT0 A
	B=A    A	B(A) := adresse courante
	GOSUBL INIT
	GOSUBL GETNXT
	P=     0
	D0=(5) dADR
	A=DAT0 A
	D0=(2) dLEN
	C=C-A  A	C(A) := longueur de l'instruction
	DAT0=C B
*
* dMODE := 1
*
	D0=(2) dMODE
	LC(1)  1
	DAT0=C P
	GOTO   dsp

************************************************************
* stddsp, stdds-
*
* But: afficher une ligne hexadecimale.
* Entree:
*   - dADR = adresse des 16 quartets.
* Sortie:
*   - dLEN = 0
*   - dMODE = 0
* Abime: A-C, D(S)
* Appelle: HEXASC
* Niveaux: 1
* Historique:
*   87/05/18: P.D. & J.T. conception & codage
************************************************************

 stdds- ST=0   sCRLF
	GOTO   stdd10
 stddsp ST=1   sCRLF
 stdd10 D=0    S
	D=D-1  S	D(S) := F
	D1=(5) dLINE
	D0=(5) dADR
	C=DAT0 A
	D0=C
 std10	A=DAT0 1
	C=0    S	C(S) := 1-1
	GOSBVL =HEXASC
	DAT1=A B
	D0=D0+ 1
	D1=D1+ 2
 std20	D=D-1  S
	GONC   std10
*
* FF
*
	LC(2)  -1
	DAT1=C B
*
* dLEN := dMODE := 0
*
	C=0    W
	D0=(5) dLEN
	DAT0=C B
	D0=(2) dMODE
	DAT0=C S
	GOTO   dsp10

************************************************************
* dsp, dsp-
*
* But: afficher la ligne dLINE, en enlevant eventuellement
*   les espaces inutiles.
* Entree:
*   - dLINE = ^ ligne (23 caracteres maximum + 1)
*   - dADR = adresse courante
* Sortie:
* Utilise: A-D, D0, D1, ST(1,2)
* Appelle: DSPCHA
* Niveaux: 3
* Detail: dLINE est cense etre suivi d'un FF
*   dsp- n'affiche pas de CR/LF a la fin.
* Historique:
*   87/05/18: P.D. & J.T. conception & codage
************************************************************

 dsp-	ST=0   sCRLF
	GOTO   dsp10

 dsp	ST=1   sCRLF
 dsp10
*
* Afficher l'adresse suivie d'un ":"
*
	D0=(5) dADR
	A=DAT0 A
	P=     4
	C=P    15
	P=     0
	GOSBVL =HEXASC
	D1=(5) =FUNCR0
	DAT1=A 10
	C=0    A
	LC(1)  5	 5 caracteres
	A=C    A
	GOSBVL =DSPCNA
*
* ":"
*
	LCASC  ':'
	GOSBVL =DSPCHC
*
* afficher le reste de la ligne
*
	LC(5)  dLINE
	D0=(5) =FUNCD0	5 quartets
	DAT0=C A	adresse du caractere courant
	ST=0   sBLANC
	ST=0   sGUIL
 dsp20
	D0=(5) =FUNCD0
	A=DAT0 A
	D1=A		D1 := adresse du caractere courant
	A=A+1  A
	A=A+1  A
	DAT0=A A	=FUNCD0 :=  adresse du car. courant
*
* D1 = adresse du caractere courant
*
	A=DAT1 B
	A=A+1  B
	GOC    dsp70	sortie si FF
*
* REDUCE$ ?
*
	A=A-1  B
	LCASC  ' '

	?ST=1  sGUIL
	GOYES  dsp65

	?A#C   B
	GOYES  dsp50	on affiche le caractere en testant
	?ST=1  sBLANC
	GOYES  dsp20

 dsp50	ST=0   sBLANC
	?A#C   B
	GOYES  dsp60
	ST=1   sBLANC
 dsp60	LCASC  \'\
	?A#C   B
	GOYES  dsp65
	ST=1   sGUIL

 dsp65	GOSBVL =DSPCHA
	GOTO   dsp20	END LOOP
*
* CR/LF
*
 dsp70
	?ST=0  sCRLF
	RTNYES
	GOVLNG =CRLFND


************************************************************
* SYSe
*
* But: Desassembleur interactif
* Syntaxe: SYSEDIT <adresse>
* Historique:
*   87/05/18: P.D. & J.T. conception & codage
*   88/12/18: P.D. & J.T. changement de syntaxe
************************************************************

	REL(5) =SYSEDITd
	REL(5) =SYSEDITp
=SYSEDITe
*
* Lire l'adresse
*
	GOSBVL =EXPEX-
	GOSUBL =POPADR	modifie le 18 decembre 88
*
* B(A) = valid address
*
	C=B    A
	D0=(5) dADR
	DAT0=C A	Adresse
*
* Initialisation des variables communes
*
	C=0    W
	D0=(2) dETAT
	DAT0=C S
	D0=(2) dMODE
	DAT0=C S	Mode desas := 0
	D0=(2) dREJEC
	DAT0=C S	REJECT := 0
	D0=(4) dSTACK
	DAT0=C S	clear stack
	D0=(4) dHEADR
	DAT0=C A	Fichier := 0
*
* Display standard
*
	GOSUB  stddsp
 BOUCLE
	D0=(5) dREJEC
	C=DAT0 S
	A=0    S
	DAT0=A S	REJECT := 0 par defaut
	?C#0   S
	GOYES  BP20
*
* Lecture clavier
*
	GOSBVL =RPTKY
	GOC    BP20
 BP05	GOSBVL =SCRLLR
	GONC   BP10
	GOSBVL =CKSREQ
	GOTO   BP05
 BP10	GOSBVL =POPBUF
	A=B    A	A(B) := keycode
	D0=(5) dKEY
	DAT0=A B	KEY := touche lue

 BP20	D0=(5) dETAT
	C=DAT0 1	C(0) := etat
	GOSBVL =TBLJMC
	REL(3) etat0
	REL(3) etat1
	REL(3) etat2
	REL(3) etat3
	REL(3) etat4
	REL(3) Etat5
	REL(3) Etat6

 Etat5	GOLONG etat5
 Etat6	GOLONG etat6

 etat0
	D0=(5) dKEY
	A=DAT0 B
	GOSBVL =FINDA
	CON(2) =k#ATTN	[ATTN]
	REL(3) vEXIT
	CON(2) #38	[+]
	REL(3) v+1
	CON(2) #2A	[-]
	REL(3) v-1
	CON(2) #1C	[*]
	REL(3) v+16
	CON(2) #0E	[/]
	REL(3) v-16
	CON(2) #04	[R]
	REL(3) vREL
	CON(2) #0F	[A]
	REL(3) vNIBA
	CON(2) #1F	[C]
	REL(3) vCON
	CON(2) #22	[N]
	REL(3) vNIBH
	CON(2) #23	[M]
	REL(3) vMODIF
	CON(2) #1D+56	[EDIT]
	REL(3) vMODIF
	CON(2) #14	[H]
	REL(3) vHEXA
	CON(2) #1D	[Z]
	REL(3) vEDIT
	CON(2) #18	[=]
	REL(3) vGOTO
	CON(2) #24	[(]
	REL(3) vGOSUB
	CON(2) #25	[)]
	REL(3) vRTN
	CON(2) #11	[D]
	REL(3) vDESAS
	CON(2) #17	[L]
	REL(3) vLCASC
	CON(2) #12	[F]
	REL(3) vFILE
	CON(2) #26	[ENDLINE]
	REL(3) vENDLN
	CON(2) =k#OFF	[OFF]
	REL(3) vEXIT
	NIBHEX 00	fin de table
	GOTO   BOUCLE

************************************************************
* v+1, v-1, v+16, v-16
*
* But: changer l'adresse courante
* Entree:
*   - dADR = adresse courante
* Sortie:
*   - dADR = nouvelle adresse
*   - dLEN = 0
*   - dMODE = 0
* Abime: 
* Appelle: stddsp
* Niveaux: 
* Historique:
*   87/05/18: P.D. & J.T. conception & codage
************************************************************

 v+1	LC(5)  1
	GOTO   chgadr
 v-1	LC(5)  -1
	GOTO   chgadr
 v+16	LC(5)  16
	GOTO   chgadr
 v-16	LC(5)  -16
 chgadr
	D0=(5) dADR
	A=DAT0 A
	A=A+C  A
	DAT0=A A
	GOSUB  stddsp
	GOTO   BOUCLE

************************************************************
* vEXIT
*
* But: sortir de SYSEDIT
* Entree:
* Sortie: par NXTSTM
* Historique:
*   87/05/18: conception & codage
************************************************************

 vEXIT
	GOSUB  clrrpt
	GOSBVL =ATNCLR
	GOSBVL =NOSCRL
	GOVLNG =NXTSTM

************************************************************
* vREL
*
* But: Traiter la touche [R] (REL(n)) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
*   - dETAT = 1
* Historique:
*   87/05/19: conception & codage
************************************************************

 vREL	LC(1)  1
	GOTO   etat=C

************************************************************
* vNIBA
*
* But: Traiter la touche [A] (NIBASC) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
*   - dETAT = 2
* Historique:
*   87/05/19: conception & codage
************************************************************

 vNIBA	LC(1)  2
	GOTO   etat=C

************************************************************
* vCON
*
* But: Traiter la touche [C] (CON(n)) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
*   - dETAT = 3
* Historique:
*   87/05/19: conception & codage
************************************************************

 vCON	LC(1)  3
	GOTO   etat=C

************************************************************
* vNIBH
*
* But: Traiter la touche [N] (NIBHEX) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
*   - dETAT = 4
* Historique:
*   87/05/19: conception & codage
************************************************************

 vNIBH	LC(1)  4

************************************************************
* etat=C
*
* But: changer l'etat, et revenir a la boucle.
* Entree:
*   - C(0) = etat (0 .. 6)
* Sortie: par BOUCLE
*   - dETAT modifie
* Abime: D0
* Niveaux: 0
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 etat=C
	D0=(5) dETAT
	DAT0=C 1
	GOTO   BOUCLE

************************************************************
* vHEXA
*
* But: Traiter la touche [H] (hexa) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/19: conception & codage
************************************************************

 vHEXA	GOSUB  stddsp
	GOTO   BOUCLE

************************************************************
* vENDLN
*
* But: Traiter la touche [ENDLINE] a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
*   87/05/28: P.D. & J.T. ajout de la sortie sur fichier
*   87/08/03: P.D.	  GOSBVL #.. et REL(n) L.. fichier
************************************************************

 vENDLN
	D0=(5) dHEADR
	C=DAT0 A
	?C#0   A
	GOYES  vENDfl
	GOTO   vEND90

 Bserr	GOTO   bserr

 vENDfl
*
* Maximum de memoire necessite (attitude pessimiste)
*   8 + 23 caracteres pour une ligne seule
*   8 + 7 + 2 / 8 + 7 + 6 = 38 caracteres pour 2 lignes
*    (soit 17 + 2 + 1 / 21 + 2 + 1 avec les longueurs LIF
*	et le padding)
*
	C=0    A
	LC(2)  44*2	caracteres au maximum
	P=     0	Oui, on veut le leeway
	GOSBVL =MEMCKL
	GOC    Bserr	Not enough memory
*
* Impression de la ligne dLINE dans le fichier courant.
*
	GOSBVL =OBCOLL	C(A) = ^ buffer
	D0=C		D0 = ^ buffer
	R0=C		R0 = ^ 1ere ligne (pour LIFlen)
	D0=D0+ 4	D0 = ^ apres la longueur
*
* <blanc>L<adr><blanc>
*
	LCASC  ' '
	GOSUBL putc
	LCASC  'L'
	GOSUBL putc
	D1=(5) dADR
	A=DAT1 A
	P=     4
	C=P    15	C(S) := 5-1
	P=     0
	GOSBVL =HEXASC
	DAT0=A 10
	D0=D0+ 10
	LCASC  ' '
	GOSUBL putc
*
* si dLINE[1,1]="G" alors ST=1 rplc#
*
	D1=(5) dLINE
*
* D1 = ^ premier caractere de l'opcode dans dLINE
* D0 = ^ endroit ou va etre mis l'opcode
*
 vEND00 ST=0   rplc#	Il ne faut pas remplacer le # en L
	A=DAT1 6	Les trois premiers caracteres
	LCASC  'G'
	?A#C   B	Pas un GOxxx
	GOYES  vEND05
*
* premiere lettre = 'G'
*
	D1=D1+ 3*2
	A=DAT1 B
	D1=D1- 3*2
	LCASC  'B'
	?A=C   B	GOSBVL ?
	GOYES  vEND08	G..B.. ==> on ne remplace pas # en L
	LCASC  'L'
	?A=C   B	GOVLNG ?
	GOYES  vEND08	G..L.. ==> on ne remplace pas # en L
	GONC   vEND07	pas long ==> ST(rplc#) = 1
*
* Pas un GOxxx, alors peut-etre un REL(n) ?
*
 vEND05
	LCASC  'LER'
	?A#C   A	5 digits, a peu pres 6...
	GOYES  vEND08
 vEND07 ST=1   rplc#
 vEND08 ST=0   chrc/
	LCASC  '?'
	?A#C   B
	GOYES  vEND10
	ST=1   chrc/
*
* recopie (intelligente) jusqu'au / ou FF
*
 vEND10 A=DAT1 B
	D1=D1+ 2
	LCASC  '#'
	?A#C   B
	GOYES  vEND20	ce n'est pas un #
	?ST=0  rplc#
	GOYES  vEND20	on ne remplace pas le # en L
	LCASC  'L'
	A=C    B	remplacement effectif
 vEND20 ?ST=0  chrc/
	GOYES  vEND25
	LCASC  '/'
	?A=C   B
	GOYES  vEND30	il reste une ligne a traiter
 vEND25 LC(2)  -1
	?A=C   B
	GOYES  vEND50	on peut y aller
	DAT0=A B	Ecriture dans le fichier
	D0=D0+ 2
	GONC   vEND10	B.E.T.
*
* Deuxieme ligne
*
 vEND30 CD1EX		C(A) = D1
	R1=C		R1 n'est pas abime pas LIFlen
	GOSUBL LIFlen	n'abime pas D0
	CD0EX
	D0=C
	R0=C		R0 = ^ liflen de la 2eme ligne
	D0=D0+ 4
	C=R1		C(A) = ^ R de RTNYES ou G de GOYES
	D1=C
*
* <blanc><6 blancs><blanc>
*
	LCASC  ' '
	P=     8
 vEND40 GOSUBL putc
	P=P-1
	?P#    0
	GOYES  vEND40
	GOTO   vEND00	sur la premiere ligne

 bserr	GOVLNG =BSERR
*
* Fin de la derniere ligne
*
 vEND50 GOSUBL LIFlen
	CD0EX
	D0=(5) =AVMEMS
	DAT0=C A	AVMEMS := ^ end of line

	C=0    A
	R3=C		insertion dans le fichier

	D0=(5) dFILE
	A=DAT0 A	A(A) := ^ old line
	D0=(5) dHEADR
	C=DAT0 A

    if JPCPRV
	GOSBVL =RPLLIN
    else
	GOSBVL =MGOSUB
	CON(5) =RPLLIN
    endif
*
* R3 (3) = offset of move
* Cy = 0 : output buffer collapsed
*   A(A) = end+1 of replaced line in file
*   B(A) = len of replacement line in nibbles
*   C(A) = (OUTBS)
*
	GOC    bserr

	D0=(5) dFILE
	DAT0=A A
*
* Puis affichage de la nouvelle ligne
*
 vEND90 D0=(5) dLEN
	C=0    A
	C=DAT0 B
	D0=(2) dADR
	A=DAT0 A
	A=A+C  A
	DAT0=A A
*
* Affichage de la ligne suivante
*
	GOSUB  dspmod
*
* Et retour...
*
	GOTO   BOUCLE

************************************************************
* vDESAS
*
* But: Traiter la touche [D] (desassemblage) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/20: conception & codage
************************************************************

 vDESAS
	GOSUB  desdsp
 vDSout GOTO   BOUCLE

************************************************************
* vLCASC
*
* But: Traiter la touche [L] (LCASC) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/20: conception & codage
************************************************************

 vLCASC
*
* mode desassemblage ?
*
	D0=(5) dMODE
	C=DAT0 S
	?C=0   S
	GOYES  vDSout
*
* LC ?
*
	D0=(5) dADR
	A=DAT0 A
	D0=A		D0 := ^ instruction
	A=DAT0 P
	LC(1)  3
	?A#C   P
	GOYES  vDSout
*
* LC(n), n pair ?	(3x, x = impair)
*
	D0=D0+ 1
	C=0    W
	C=DAT0 P	x de 3x?????????
*
* Calcul de l'adresse du dernier caractere
*
	AD0EX
	A=A+C  A	A(A) := ^ dernier car.
	D0=A		D0 := ^ dernier caractere
*
* Test de parite de x
*
	SB=0
	CSRB
	?SB=0		x pair
	GOYES  vDSout	==> sortie
*
* Ok. On y va.
*
	C=C+1  A	C(A) := nb de caracteres
	D=C    A	Sauvegarde en D(A)

	D1=(5) dLINE
*
* LCASC	 '
*
	LCASC  \'  CSACL\
	DAT1=C 8*2
	D1=D1+ 8*2
*
* ASC$(dADR + 2)
*
	LC(5)  -2
	CDEX   A	C(A) := nb de car. ; D(A) := -2

	GOSUB  ASC$
*
*	     '
*
	LCASC  \'\
	DAT1=C B
	D1=D1+ 2
*
* FF
*
	LC(2)  -1
	DAT1=C B

	GOSUB  dsp

 vLCout GOTO   BOUCLE

************************************************************
* vGOTO
*
* But: Traiter la touche [=] (GOTO) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/21: P.D.	  conception & codage
************************************************************

 vGOTO
	GOSUB  getadr
	GOC    vGOout
	D0=(5) dADR
	C=B    A	C(A) := adresse trouvee
	DAT0=C A
	GOSUB  dspmod
 vGOout GOTO   BOUCLE

************************************************************
* vGOSUB
*
* But: Traiter la touche [(] (GOSUB) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/21: P.D.	  conception & codage
************************************************************

 vGOSUB
	GOSUB  getadr
	GOC    vGOout
	D0=(5) dSTACK
	A=DAT0 P	A(0) := pointeur de pile
	LC(1)  MAXLVL
	?A>=C  P
	GOYES  vGOout

	C=A    P	pour getstk
	A=A+1  P
	DAT0=A P	un niveau de plus

	GOSUB  getstk	D0 := ^ stack (C(0))

	D1=(5) dADR
	C=DAT1 A	C(A) := dADR
	DAT0=C A	push dADR

	C=B    A	C(A) := adresse trouvee
	DAT1=C A	dADR := adresse trouvee

	GOSUB  dspmod

	GOTO   BOUCLE

************************************************************
* vRTN
*
* But: Traiter la touche [)] (RTN) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/21: P.D.	  conception & codage
************************************************************

 vRTN
	D0=(5) dSTACK
	C=DAT0 P
	?C=0   P
	GOYES  vRTout

	C=C-1  P
	DAT0=C P	un niveau de moins

	GOSUB  getstk

	A=DAT0 A	A(A) := adresse depilee
	D1=(5) dADR
	DAT1=A A

	GOSUB  dspmod

 vRTout GOTO   BOUCLE

************************************************************
* vEDIT
*
* But: Traiter la touche [Z] (EDIT) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/21: P.D.	  conception & codage
************************************************************

 vEDIT
	GOSUB  dsp-

	GOSUB  finput	format := 5UP
	NIBHEX FFFFFFFF
	NIBHEX FFFFFFFF
	NIBHEX FFFFFF
	CON(1) %0111
	CON(1) %0000
*
* Traiter l'adresse entree :
*
	GOC    vEDout	[ATTN] ou [OFF]
	GOSUB  chkhex
	GOC    vEDIT	non valide
	D0=(5) dADR
	A=B    A	A(A) := sortie de chkhex
	DAT0=A A

 vEDout GOSUB  dspmod
	GOTO   BOUCLE

************************************************************
* vMODIF
*
* But: Traiter la touche [M] ou [EDIT] (modif.) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/21: P.D.	  conception & codage
************************************************************

 vMODIF
	GOSUB  stdds-
	GOSUB  finput	format := 6P16UP
	NIBHEX FFFFFFFF
	NIBHEX FFFFFFFF
	NIBHEX FF
	CON(1) %0011
	NIBHEX 000
	CON(1) %1100
	NIBHEX F
*
* Traiter la chaine entree :
*
	GOC    vMDout	[ATTN] ou [OFF]
	GOSUB  chkhex
	GOC    vMODIF	non valide
	D0=(5) dADR
	A=DAT0 A
	D0=A		D0 := adresse courante
	A=B    W	A(A) := sortie de chkhex
	P=     15
 vMD10	ASLC
	DAT0=A 1
	D0=D0+ 1
 vMD20	P=P-1
	GONC   vMD10
	P=     0

 vMDout GOSUB  dspmod
	GOTO   BOUCLE

************************************************************
* vFILE
*
* But: Traiter la touche [F] (file) a l'etat 0.
* Entree:
* Sortie: par BOUCLE
* Historique:
*   87/05/26: P.D. & J.T. conception & codage
*   87/08/29: P.D. & J.T. modification du copy code
************************************************************

 vFL00	C=0    A
	D1=(5) dHEADR
	DAT1=C A
	D1=C		D1 := 0
	GOTO   vFL90

 vFILE
	GOSUB  vFL10
	NIBASC 'File: '
	NIBHEX FF
 vFL10	C=RSTK
	D1=C
	GOSBVL =BF2DSP

	D1=(5) dHEADR
	C=DAT1 A
	?C=0   A
	GOYES  vFL15
*
* Affichage du nom du fichier
*
	GOSUB  flname
 vFL15	GOSUB  finput	format := 6P8UP
	NIBHEX FFFFFFFF
	NIBHEX FFFFFFFF
	NIBHEX FFFF
	CON(1) %0011
	CON(1) %0000
	CON(1) %1100
	CON(1) %1111

	GOC    vMDout	[ATTN] ou [OFF]
*
* INPUT = NULL ?
*
	?A=0   A
	GOYES  vFL00
*
* Reconstituer le string header pour FILXQ$
*
	CD1EX
	D1=C
	C=C+A  A	C(A) := ^ bas de la M.S.
	R1=C
	GOSBVL =D=AVMS
	ST=1   0	return desired (un peu mon n'veu)
	GOSBVL =ADHEAD

	GOSBVL =FILXQ$
	GONC   vFILE	Invalid File Specification
*
* Cy = 1 : mainframe recognisable file specifier found
* A(W) = file name
* D(S) = #F  if device not specified
*
	D=D+1  S
	GONC   vFILE	There is a device specifier
	D=D-1  S	On remet tout en ordre (propre, net)

	D1=(5) =FUNCR0	sauvegardes
	C=D    W	Sauvegarde de D(W) (pour CRETF+)
	DAT1=C W
	D1=D1+ 16
	DAT1=A W	Sauvegarde du nom du fichier

	GOSBVL =FINDF+	Find file
*
* A(W) = B(W) = file name
* Cy = 0 : file found
*   D1 = ^ file header
*   D(S) = device type
* Cy = 1 : file not found
*
	GONC   vFL30	File found   (D1 = ^ file header)
*
* Creation du fichier
*
	D1=(5) =FUNCR0
	C=DAT1 W
	D=C    W	Restaurer pour CRETF+
	C=0    A
	LC(2)  37+4	header + EOF-mark
	GOSBVL =CRETF+	Le Lex ne doit pas bouger
	GONC   vFL20	Ok
	GOVLNG =BSERR
 vFL20	C=R1		C(A) := adresse du header
	D1=(5) dHEADR
	DAT1=C A
	D1=(5) =FUNCR1
	A=DAT1 W
	D1=C
	DAT1=A W	Nom du fichier
	D1=D1+ 16	D1 = ^ file type
	LCHEX  400001	text + copy code
	DAT1=C 6
	D1=D1+ 16
	D1=D1+ 5
* EOF-Mark
	C=0    A
	C=C-1  A
	DAT1=C 4	D1 := ^ fin du fichier
	GOC    vFL90	B.E.T.
 vFL30
*
* Stockage de l'adresse du header
*
	CD1EX
	D1=(5) dHEADR
	DAT1=C A
	D1=C
*
* Chercher le EOF
*
	D1=D1+ 16
*
* Tester le type
*
	A=0    A
	A=DAT1 4
	A=A-1  A
	?A=0   A
	GOYES  vFL35
	LC(2)  =eFTYPE
	GOVLNG =MFERR
 vFL35	D1=D1+ 16
	CD1EX
	D1=C		D1 := ^ REL(5) FiLeNd
	A=DAT1 A
	C=C+A  A
	D=C    A	D := ^ EOF according to file-chain
	D1=D1+ 5
	CD1EX		C := ^ start of data
	ST=0   sBADRC
 vFL40	GOSUB  PRSREC
	GONC   vFL40	Bouclage si Cy = 0
* sortie de la boucle
	?ST=0  sBADRC
	GOYES  vFL90	Boucle si Ok
	LC(2)  =eEOFIL	End Of File
	GOVLNG =MFERR

 vFL90	CD1EX
	D1=(5) dFILE
	DAT1=C A
	GOSUB  dsp
	GOTO   BOUCLE

************************************************************
* etat1
*
* But: Traiter le cas de la touche [R] suivie d'un nombre.
* Entree:
*   - dKEY = touche appuyee, censee etre un nombre 1..5
* Sortie:
*   - dETAT = 0
*   - si nombre = 1..5
*     dLINE = REL(n) #aaaaa
*     dLEN = n
*     dDESAS = 0
*     sinon
*     dREJEC = 1
*   sortie par BOUCLE
* Abime: 
* Appelle: numkey, dsp
* Niveaux: 2
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 et1rjt GOSUB  reject
 et1out D0=(5) dMODE
	C=0    A
	DAT0=C 1
	GOTO   etat=C

 etat1
	GOSUB  numkey
	GONC   et1rjt
	?B=0   A
	GOYES  et1rjt
	LC(1)  5
	?B>C   P
	GOYES  et1rjt
*
* La touche est comprise entre 1 et 5
*
	D0=(5) dLEN
	C=B    A
	DAT0=C B	dLEN := valeur de la touche

	D1=(5) dLINE
	LCASC  '(LER'
	DAT1=C 4*2
	D1=D1+ 4*2
	LCASC  '0'
	C=C+B  B
	DAT1=C B
	D1=D1+ 2
	LCASC  '# )'
	DAT1=C 3*2
	D1=D1+ 3*2
*
* Calcul de l'adresse
*
	D0=(2) dADR
	A=DAT0 A	A(A) := adresse courante
	D0=A
	C=B    A	C(4-1) := 0
	P=C    0
	P=P-1
	C=DAT0 WP	les quartets de poids fort = 0
*
* Bug fix de Michael Markov
*
	B=C    A
	B=B+B  WP
	GONC   etat1b
	C=-C   WP
	C=-C   A
 etat1b
*
* Fin du bug fix de Michael Markov
*
	A=A+C  A

	P=     4
	C=P    15
	P=     0
	GOSBVL =HEXASC
	DAT1=A 10
	D1=D1+ 10
	LC(2)  -1
	DAT1=C B

	GOSUBL dsp

	GOTO   et1out

************************************************************
* etat2
*
* But: Traiter le cas de la touche [A] suivie d'un nombre.
* Entree:
*   - dKEy = touche appuyee, censee etre un nombre 1..8
* Sortie:
*   - dETAT = 0
*   - si nombre = 1..8
*     dLINE = NIBASC '....'
*     dLEN = n*2
*     dDESAS = 0
*     sinon
*     dREJEC = 1
*   sortie par BOUCLE
* Abime: 
* Appelle: numkey, dsp
* Niveaux: 2
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 et2rjt GOTO   et1rjt

 etat2
	GOSUB  numkey
	GONC   et2rjt
	?B=0   A
	GOYES  et2rjt
	LC(1)  8
	?B>C   P
	GOYES  et2rjt
*
* La touche est comprise entre 1 et 8
*
	D0=(5) dLEN
	C=B    A
	C=C+C  A
	DAT0=C B	dLEN := n*2

	D1=(5) dLINE
	LCASC  \' CSABIN\
	DAT1=C W
	D1=D1+ 16

	D0=(2) dADR
	C=DAT0 A
	D0=C		D0 := ^ caracteres

	D=0    A
	D=D+1  A
	D=D+1  A	D(A) := 2
	C=B    A	C(A) := nb de car
	GOSUB  ASC$

	LCASC  \'\
	DAT1=C B
	D1=D1+ 2
*
* FF
*
	LC(2)  -1
	DAT1=C B

	GOSUBL dsp

	GOTO   et1out

************************************************************
* etat3
*
* But: traiter (pour CON(n)) le "n" ou le [H].
* Entree:
*   - dKEY = touche pressee
* Sortie:
*   - si touche = [H]
*	dSC1 = 1
*     sinon
*	dSC1 = 0
*	dREJEC = 1
*   - dETAT = 5
* Abime: C(A), D0
* Appelle: reject
* Niveaux: 1
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 etat3
	D1=(5) dSC1
	D0=(5) dKEY
	A=DAT0 B
	LC(2)  #14	Touche [H]
	?A#C   B
	GOYES  et3rjt
	LC(1)  1	dSC1 := 1
	GONC   et3out	B.E.T.
 et3rjt GOSUB  reject
	C=0    A	dSC1 := 0
 et3out DAT1=C P
	LC(1)  5
	GOTO   etat=C

************************************************************
* etat4
*
* But: traiter (pour NIBHEX) le "n" ou le [.].
* Entree:
*   - dKEY = touche pressee
* Sortie:
*   - si touche = [.]
*	dSC1 = 10
*     sinon
*	dSC1 = 0
*	dREJEC = 1
*   - dETAT = 6
* Abime: C(A), D0
* Appelle: reject
* Niveaux: 1
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 etat4
	D1=(5) dSC1
	D0=(5) dKEY
	A=DAT0 B
	LC(2)  #36	Touche [.]
	?A#C   B
	GOYES  et4rjt
	LC(1)  10	dSC1 := 10
	GONC   et4out	B.E.T.
 et4rjt GOSUB  reject
	C=0    A	dSC1 := 0
 et4out DAT1=C P
	LC(1)  6
	GOTO   etat=C

************************************************************
* etat5
*
* But: traiter le cas general de CON().
* Entree:
*   - dKEY = touche pressee.
*   - dSC1 = 1 si mode [C][H]n, 0 si [C]n
* Sortie: -
* Abime: 
* Appelle: numkey, dsp
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 et5rjt GOTO   et1rjt

 etat5
	GOSUB  numkey
	GONC   et5rjt
	?B=0   A
	GOYES  et5rjt
	LC(1)  6
	?B>C   P
	GOYES  et5rjt
	C=C-1  P	C(0) := 5
	D0=(5) dSC1
	?B<C   P
	GOYES  et5-10
	DAT0=C P	mode hexa := vrai (vrai = 5)
 et5-10
*
* dLEN := "n"
*
	D0=(2) dLEN
	C=B    A
	DAT0=C B	dLEN := n
*
* dLINE := CON(n) #
*
* CON(
	D1=(5) dLINE
	LCASC  '(NOC'
	DAT1=C 4*2
	D1=D1+ 4*2
*     n
	LCASC  '0'
	C=C+B  B
	DAT1=C B
	D1=D1+ 2
*      ) #
	LCASC  '# )'
	DAT1=C 3*2
	D1=D1+ 3*2
*
* # ou pas # ?
*
	D0=(2) dSC1
	C=DAT0 S

	D0=(2) dADR
	C=DAT0 A
	D0=C		D0 := adresse courante

	A=0    W
	C=B    A	C(0) := 1..6
	D=C    A	D(A) := sauvegarde de la longueur
	P=C    0
	P=P-1		P = nb quartets a charger - 1
	A=0    W
	A=DAT0 WP

	?C#0   S	Mode hexa ?
	GOYES  et5-50
*
* non : on revient sur le #,
*
	D1=D1- 2
*
* Et on convertit en decimal
*
	GOSBVL =HEXDEC	A(W) := nombre en decimal
	SETHEX
	P=     15
 et5-20 ?A#0   P
	GOYES  et5-40
	P=P-1
	?P#    0
	GOYES  et5-20
 et5-40 C=0    A
	C=P    0
	C=C+1  A
	D=C    A
 et5-50 C=P    15
	P=     0
	GOSBVL =HEXASC
	C=D    A	C(A) := 1..6
	C=C+C  A	C(A) := 2..12
	P=C    0
	P=P-1
	DAT1=A WP
	P=     0
*
* Calcul de l'adresse suivante
*
	AD1EX
	A=A+C  A
	D1=A
*
* FF
*
	LC(2)  -1
	DAT1=C B
*
	GOSUBL dsp

	GOTO   et1out

************************************************************
* etat6
*
* But: traiter le cas general de NIBHEX.
* Entree:
*   - dKEY = touche pressee.
*   - dSC1 = 10 si mode [N][.]n, 0 si [N]n
* Sortie: -
* Abime: 
* Appelle: numkey, dsp
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 et6rjt GOTO   et1rjt

 etat6
	GOSUB  numkey
	GONC   et6rjt
	D0=(5) dSC1
*
* [.] ?
*
	C=0    W
	C=DAT0 P
	?C=0   P
	GOYES  et6-10	pas de [.]
*
* Il y a un [.]
* Valide entre 0 et 6
*
	LC(1)  6
	?B>C   P
	GOYES  et6rjt
	C=0    A
	LC(1)  10
	B=B+C  A	B(A) := n + 10
	GONC   et6-20	B.E.T.
*
* pas de [.]
* Valide entre 1 et 9
*
 et6-10 ?B=0   A
	GOYES  et6rjt
*
* Ok. Longueur entre 1 et 16 dans B(A).
*
 et6-20
*
* dLEN =: longueur calculee
*
	D0=(5) dLEN
	C=B    A
	D=C    A	D(A) := longueur calculee
	DAT0=C B
*
* D0 := adresse courante
*
	D0=(2) dADR
	C=DAT0 A
	D0=C
*
* NIBHEX
*
	D1=(5) dLINE
	LCASC  ' XEHBIN'
	DAT1=C 7*2
	D1=D1+ 7*2
*
* Les B(A) nibhex.
*
	GONC   et6-40	B.E.T.
 et6-30 A=DAT0 1
	C=0    S
	GOSBVL =HEXASC
	DAT1=A B
	D0=D0+ 1
	D1=D1+ 2
 et6-40 D=D-1  A
	GONC   et6-30
*
* FF
*
	LC(2)  -1
	DAT1=C B
*
* et affichage...
*
	GOSUBL dsp

	GOTO   et1out

************************************************************
* numkey
*
* But: tester si la touche dKEY est une touche numerique, et
*   renvoyer sa valeur.
* Entree:
*   - dKEY = code physique de la touche
* Sortie:
*   - Cy = 1 : touche numerique
*     B(A) = valeur (0000d, d=0..9)
*   - Cy = 0 : touche non numerique
* Abime: A(B), B(A), C(A), D0
* Appelle: FINDA
* Niveaux: 1
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 numkey
	B=0    A
	D0=(5) dKEY
	A=DAT0 B
	GOSBVL =FINDA
	CON(2) #0D	[9]
	REL(3) num9
	CON(2) #0C	[8]
	REL(3) num8
	CON(2) #0B	[7]
	REL(3) num7
	CON(2) #1B	[6]
	REL(3) num6
	CON(2) #1A	[5]
	REL(3) num5
	CON(2) #19	[4]
	REL(3) num4
	CON(2) #29	[3]
	REL(3) num3
	CON(2) #28	[2]
	REL(3) num2
	CON(2) #27	[1]
	REL(3) num1
	CON(2) #35	[0]
	REL(3) num0
	NIBHEX 00
	RTNCC		Cy := 0 : non trouvee

 num9	B=B+1  A
 num8	B=B+1  A
 num7	B=B+1  A
 num6	B=B+1  A
 num5	B=B+1  A
 num4	B=B+1  A
 num3	B=B+1  A
 num2	B=B+1  A
 num1	B=B+1  A
 num0	RTNSC		Cy := 1 : trouvee

************************************************************
* reject
*
* But: mettre a 1 la variable REJECT
* Entree: -
* Sortie:
*   - dREJEC = 1
* Abime: C(0), D0
* Niveaux: 0
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************
	
 reject
	D0=(5) dREJEC
	LC(1)  1
	DAT0=C P
	RTN

************************************************************
* ASC$
*
* But: afficher C(A) caracteres ASCII (entre 32 et 126)
*   pointes par D0.
* Entree:
*   - D0 = ^ caracteres
*   - D1 = ^ destination
*   - C(A) = compte de caracteres (et non de quartets)
*   - D(A) = increment de D0 (+2 ou -2)
* Sortie:
*   - D1 = ^ passe le dernier caractere
* Abime: A(A), B(A), C(A)
* Appelle: RANGE
* Niveaux: 1
* Historique:
*   87/05/19: P.D. & J.T. conception & codage
************************************************************

 ASC$	B=C    B	compteur en B(A)
	GOTO   ASC40
 ASC10	LC(4)  (126)~(32)
	A=DAT0 B
	DAT1=A B	par defaut, on l'ecrit
	GOSBVL =RANGE
	GONC   ASC30
	LCASC  '.'
	DAT1=C B
 ASC30	D1=D1+ 2
	CD0EX		Reactualisation de D0
	C=C+D  A
	D0=C
 ASC40	B=B-1  B
	GONC   ASC10
	RTN

************************************************************
* getadr
*
* But: extraire une adresse a partir de la ligne contenue
*   dans dLINE.
* Entree:
*   - dLINE = ligne courante
* Sortie:
*   - Cy = 1 : adresse non trouvee.
*   - Cy = 0 : adresse trouvee :
*     B(A) = adresse
* Abime: A(A), D1
* Niveaux: 0
* Historique:
*   87/05/21: P.D.	  conception & codage
************************************************************

 getadr
	D1=(5) dLINE
	LC(2)  '#'+1
 geta10 A=DAT1 B
	D1=D1+ 2	D1 := ^ caractere suivant
	A=A+1  B
	RTNC		Sortie si #FF (fin de dLINE)
	?A#C   B
	GOYES  geta10	boucle si pas de #
*
	B=0    A
	A=0    A
 geta20 A=DAT1 B
	D1=D1+ 2
	A=A+1  B
	GOC    geta90	Sortie si #FF
	A=A-1  B
	GOSBVL =DRANGE	Cy := 0 si 0..9
	LC(2)  '0'
	GONC	geta30
	LC(2)  'A'-10
 geta30 A=A-C  B	A(B) := 0..15
	BSL    A
	B=B+A  A
	GOTO   geta20

 geta90 RTNCC

************************************************************
* getstk
*
* But: 
* Entree:
*   - C(0) = niveau (0 pour le 1er niveau)
* Sortie:
*   - D0 = ^ element dans la pile
* Abime: C, P, D0
* Niveaux: 0
* Historique:
*   87/05/21: P.D.	  conception & codage
************************************************************

 getstk
	P=C    0	P = 0..6
	D0=(5) dSTACK
	D0=D0+ 1
	CD0EX		C(A) := ^ stack (0)
	P=P-1
	GOC    gets10	C(A) := ^ stack (0)
	C+P+1
	C+P+1
	C+P+1
	C+P+1
	C+P+1		C(A) := ^ stack (P)
 gets10 P=     0
	D0=C
	RTN

************************************************************
* finput
*
* But: poker la bit-map, avertir le poll de FINPUT, CHEDIT,
*   avertir le poll de FINPUT, mettre la chaine sur la M.S.
* Entree:
*   - RSTK = ^ bit map
*   - affichage ok
* Sortie:
*   - Cy = 1 :Sortie par [ATTN] ou [OFF]
*   - Cy = 0 :Sortie par [ENDLINE]
*     D1 = ^ Chaine au sommet de la M.S. (dernier caractere)
*     A(A) = longueur en quartets
*     C(A) = longueur en octets
* Abime: Tout
* Niveaux: 7 (CHEDIT)
* Detail: La bit-map est codee comme suit :
*     GOSUB  finput
*     CON(1) %xxxx	 93-94-95-96 caracteres
*	:
*     CON(1) %xxxx	 4-3-2-1 caracteres
* Historique:
*   87/05/22: P.D. & J.T. conception & codage
*   88/04/16: P.D. & J.T. initialisation de INENDL
************************************************************

 finput
	C=RSTK
	D1=C		D1 := ^ Bit-map
	D0=(5) =DSPMSK
	C=DAT1 W
	DAT0=C W
	D1=D1+ 16
	D0=D0+ 16
	C=DAT1 8
	DAT0=C 8

	D1=D1+ 8	D1 := adresse de retour
	CD1EX
	RSTK=C

	GOSBVL =CURSFL
 edit
*
* Previent le poll handler que c'est nous qu'on travaille
*
	D0=(5) =INENDL	Modification du 16 avril 1988
	A=0    S
	DAT0=A S

	D0=(5) =INSINP
	A=DAT0 1
	LC(1)  =INSMSK
	A=A!C  P
	DAT0=A 1

	P=     2
	GOSBVL =R<RSTK

 edit10
	GOSBVL =CHEDIT
	GONC   edit10	Si DEF KEY "...","...":
*
* Previent le poll handler que c'est nous qu'on travaille
* plus
*
	LC(1)  `=INSMSK
	CSRC
	D0=(5) =INSINP
	A=DAT0 S
	A=A&C  S
	DAT0=A S
*
	P=     2
	GOSBVL =RSTK<R	Ne modifie pas A(B)

	GOSBVL =FINDA
	CON(2) 13	[ENDLINE]
	REL(3) fnpEND
	CON(2) 14	[ATTN]
	REL(3) fnpATN
	CON(2) 24	[OFF]
	REL(3) fnpATN
	NIBHEX 00
	GOTO   edit

 fnpATN GOSUB  finlgn
	GOSBVL =ATNCLR
	RTNSC		Cy := 1 : [ATTN]

 fnpEND GOSUB  finlgn
	GOSBVL =D1MSTK
	ST=1   0	retour apres DSP$00
	GOSBVL =DSP$00
	GOSBVL =POP1S
	D1=D1+ 2	POPpe le CR de la fin
	A=A-1  A
	A=A-1  A	A(A) := longueur en quartets
	C=0    M
	C=A    A
	CSRB		C(A) := longueur en octets
	RTN		Cy := 0 : [ENDLINE]

 finlgn D1=(5) =DSPCHX
	A=DAT1 A
	?A=0   A
	GOYES  crlfof
	D0=(5) =ESCSTA
	LC(1)  EscSt1
	DAT0=C 1
	LC(2)  3
	A=C    B
	C=DAT1 A
	GOSUB  pc=c
	P=     0
	D0=(5) =ESCSTA
	LC(1)  EscSt0
	DAT0=C 1
 crlfof GOVLNG =CRLFOF

 pc=c	RSTK=C
	RTN

************************************************************
* chkhex
*
* But: verifier que la chaine au sommet de la M.S. ne
*   ne contient que des chiffres hexadecimaux.
* Entree:
*   - D1 = ^ dernier caractere sur la M.S.
*   - A(A) = longueur en quartets
*   - C(A) = longueur en octets
* Sortie:
*   - Cy = 1 : adresse non valide
*   - Cy = 0 : adresse non valide
*     B(W) = valeur lue (16 quartets au maximum)
* Abime: 
* Niveaux: 0
* Historique:
*   87/05/22: P.D. & J.T. conception & codage
************************************************************

 chkhex B=A    A
	AD1EX		A(A) := ^ dernier caractere
	A=A+B  A	A(A) := ^ premier caractere
	D1=A   A	D1 := ^ premier caractere
	D=C    A	D(A) := compteur de boucle
	B=0    W
	GOTO   chkh30
 chkh10 D1=D1- 2
	A=DAT1 B	A(B) := caractere
	BSL    W
	GOSBVL =DRANGE
	GONC   chkh20	Cy = 0 : byte in range
	GOSBVL =CONVUC
	LCASC  'FA'
	GOSBVL =RANGE
	RTNC		Cy = 1 : non entre 0..9 ou A..F
	LC(1)  9
	A=A+C  P
 chkh20 B=A    P
 chkh30 D=D-1  A
	GONC   chkh10
	RTNCC		Tout s'est bien passe...

************************************************************
* PRSREC
*
* Voir IDS I, page 17-35.
* Sortie:
*   - Cy = 0 : il faut continuer la boucle
*   - Cy = 1 : il faut sortir
*     sBADRC = 1 : bad record
*     sBADRC = 0 : EOF reached
*		   D1 = ^ debut de la 1ere ligne inexistante
* Historique:
*   87/05/28: P.D. & J.T. modification de l'interface
************************************************************

 PRSREC B=0    A
	D1=C
	?C>=D  A
	RTNYES		Return if EOF instead of line length
	D1=D1+ 4
	CD1EX
	?C>D   A
	GOYES  PRSR20	Bad record (len a cheval sur la fin)
	A=DAT1 4
	GOSBVL =SWPBYT
	P=     3
	B=A    WP
	C=B    A
	B=B+1  WP
	P=     0
	RTNC		Cy = 1 si FFFF
	BCEX   A
	CSRB
	C=C+1  A
	C=C+C  A
	C=C+C  A
	AD1EX
	D1=A
	C=A+C  A
	?C<=D  A
	GOYES  rtncc
 PRSR20 ST=1   sBADRC
	RTNSC		On ne peut sortir
 rtncc	RTNCC

************************************************************
* putc
*
* But: mettre un caractere dans l'Output Buffer
* Entree:
*   - D0 = ^ output buffer
*   - C(B) = caractere
* Sortie:
*   - C(B) = caractere
*   - D0 = ^ caractere suivant
* Abime: D0
* Niveaux: 0
* Historique: 
*   87/05/28: P.D. & J.T. conception & codage
************************************************************

 putc	DAT0=C B
	D0=D0+ 2
	RTN

************************************************************
* LIFlen
*
* But: calculer et stocker la longueur LIF de la ligne
*   introduite dans l'Output Buffer.
* Entree:
*   - R0 = ^ debut de la ligne (sur la longueur LIF)
*   - D0 = ^ passe le dernier caractere de la ligne
* Sortie:
*   - Longueur calculee stockee en (R0)
*   - D0 avance le cas echeant pour compter le padding
* Abime: A-C, D0, D1
* Appelle: SWPBYT
* Niveaux: 1
* Historique:
*   87/05/28: P.D. & J.T. conception & codage
************************************************************

 LIFlen C=R0		C(A) := ^ debut ligne (longueur)
	D1=C
	D1=D1+ 4
	CD1EX		C(A) := ^ debut donnees ; D1 = ^ len
	AD0EX		A(A) := fin de la ligne
	D0=A
	A=A-C  A	A(A) := longueur ligne en quartets
	ASRB		A(3-0) := long. en octets
	B=A    A	B(A) := longueur en octets
	GOSBVL =SWPBYT
	DAT1=A 4	La longueur exacte en octets
	SB=0
	BSRB		SB = 1 si longueur impaire
	?SB=0
	RTNYES
	D0=D0+ 2	Padding si longueur impaire
	RTN

************************************************************
* flname
*
* But: afficher un nom de fichier.
* Entree:
*   - C(A) = adresse du file-header
* Sortie: par CURSFL
* Historique:
*   87/05/28: P.D. & J.T. extraction de vFILE
************************************************************

 flname D0=(5) =FUNCD0
	DAT0=C A	FUNCD0 = ^ header
	D0=D0+ 5
	LC(1)  8

 flnm10 DAT0=C 1	FUNCD1 := reste a envoyer
	D0=D0- 5
	C=DAT0 A
	D1=C		D1 := ^ dans le file-name
	A=DAT1 B

	D1=D1+ 2
	CD1EX
	DAT0=C A	FUNCD0 += 2 ;

	LCASC  ' '
	?A=C   B
	GOYES  flnm20
	GOSBVL =DSPCHA
	D0=(5) =FUNCD1
	C=DAT0 1
	C=C-1  P
	?C#0   P
	GOYES  flnm10

 flnm20 GOVLNG =CURSFL

	END
