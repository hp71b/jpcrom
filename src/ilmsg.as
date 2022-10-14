	TITLE  Messages HP-IL <ilmsg.as>
*
* JPC:B00
*   ../../..: PD/JT Intégration dans JPC Rom
*

=LEX3
	CON(2) #FF	       Id
	CON(2) 0	       Lowest token
	CON(2) 0	       Highest Token
 
	REL(5) =LEX4	       Next Lex Chain (keywait.as)
 
	NIBHEX F
	REL(4) 1+TxTbSt	       Text Table offset
	REL(4) MSGTBL	       Message Table offset
	REL(5) POLHND	       Poll handlier
 TxTbSt
	NIBHEX 1FF	       End of Text Table
 
 flag	EQU    0	       Ce flag est arme si
	 *		       l'on rencontre le lex
	 *		       HPILROM avant le lex
	 *		       ILMSGLEX.
 
 POLHND LC(2)  =pCONFG	       On charge le POLL de
	 *		       configuration dans
	 *		       C(B) pour
	 *		       comparaison.
	?B=C   B
	GOYES  POLLe
 
	RTNSXM		       Retour au systeme,
	 *		       signifier que l'on
	 *		       a intercepte le POLL.
 
 POLLe	GOSBVL =LXFND	       Cette routine place
	 *		       le pointeur D1 sur la
	 *		       premiere entree du
	 *		       "LEX BUFFER" (BFC).
	 *		       A(A) contient
	 *		       l'offset a la fin du
	 *		       Buffer.
	GOC    POLL00	       Si Carry est arme:
	 *		       tout est ok.
	GOVLNG =CORUPT	       Autrement, le systeme
	 *		       n'a pas trouve le
	 *		       buffer on renvoie le
	 *		       message:
	 *		       "System error"
 
 POLL00 C=D    A	       Sauvegarde de D(A)
	 *		       dans R0. En effet, le
	 *		       Poll pCONFG est un 
	 *		       Fast Poll et l'on
	 *		       doit preserver cette
	 *		       partie du registre D
	 *		       pour un retour sans 
	R0=C		       interception.
	CD1EX		       ) Calcul de l'adresse
	A=A+C  A	       ) de fin du buffer et
	D1=C		       ) mise en place de
	B=A    A	       ) celle-ci dans B(A)
	 *		       ) pour comparaison.
	LCHEX  0000FF	       On charge dans D(0-5)
	D=C    W	       le code Id~Tk~Tk du
	 *		       lex "ILMSGLEX" pour
	 *		       comparaison.
	LCHEX  2601FF	       On charge dans A(0-5)
	A=C    W	       le code Id~Tk~Tk du
	 *		       lex "HPILROM" pour
	 *		       comparaison.
	ST=0   flag
	P=     5	       WP = 0-5
 
 POLL10 C=DAT1 6	       On charge dans C
	 *		       l'entree Id~Tk~Tk
	 *		       locale.
	?C#D   WP	       Est-ce ILMSGLEX ?
	GOYES  POLL15	       Si non => POLL15
	?ST=0  flag	       A-t-on deja rencontre
	 *		       HPILROM ?
	GOYES  rtn	       Si non, ILMSGLEX se
	 *		       trouve en premiere
	 *		       position => retour
	GONC   POLL50	       Autrement : inversion
	 *		       des deux entrees.
 
 POLL15 ?ST=1  flag	       Ce test est fait dans
	 *		       le cas ou nous sommes
	 *		       en presence de
	 *		       plusieurs HPILROM
	 *		       (module double
	 *		       boucle)
	GOYES  POLL17	       Ce n'est pas le
	 *		       premier : => POLL17
	?C=A   WP	       Est-ce HPILROM ?
	GOYES  POLL20	       branchement => POLL20
 
 POLL17 D1=D1+ 11	       On incremente D1 de
	 *		       11 quartets afin de
	 *		       pointer l'entree
	 *		       suivante.
	 *		       (IDTKTKAAAAA)
	CD1EX		       ) Est-on a la fin du
	?C=B  A		       ) Buffer ?
	GOYES  rtn	       Oui: retour au
	 *		       systeme
	D1=C		       Autrement
	GONC   POLL10	       on continue.
 
 POLL20 CD1EX		       Sauvegarde de
	 *		       l'adresse de HPILROM
	RSTK=C		       dans RSTK.
	ST=1   flag	       On arme ST0
	D1=C
	GOC    POLL17
 
 POLL50 A=DAT1 11	       Inversion des deux
	C=RSTK		       entrees
	D0=C
	C=DAT0 11
	DAT1=C 11
	DAT0=A 11
 
 rtn	C=R0		       Remise en place de
	D=C    A	       D(A) et
	RTNSXM		       retour au systeme.
 
 MSGTBL CON(2) 00
	CON(2) 70
 
 M000	CON(2) (M001)-(M000)
	CON(2) 0	'HPIL '
	CON(1) 4
	NIBASC 'HPIL '
	CON(1) 12
 
 M001	CON(2) (M003)-(M001)
	CON(2) 1	'ASSIGN IO Needed'
	CON(1) 5
	NIBASC 'ASSIGN'
	CON(1) 13
	CON(2) 68
	CON(1) 12
 
 M003	CON(2) (M004)-(M003)
	CON(2) 3	'Excess Chars'
	CON(1) 14
	CON(2) 78
	CON(1) 12
 
 M004	CON(2) (M005)-(M004)
	CON(2) 4	'Missing Parm'
	CON(1) 14
	CON(2) 82
	CON(1) 12
 
 M005	CON(2) (M006)-(M005)
	CON(2) 5	'Invalid Parm'
	CON(1) 14
	CON(2) 81
	CON(1) 12
 
 M006	CON(2) (M007)-(M006)
	CON(2) 6	'Invalid Expr'
	CON(1) 14
	CON(2) 80
	CON(1) 12
 
 M007	CON(2) (M016)-(M007)
	CON(2) 7	'Syntax'
	CON(1) 14
	CON(2) 75
	CON(1) 12
 
 M016	CON(2) (M017)-(M016)
	CON(2) 16	'File Protect'
	CON(1) 14
	CON(2) 61
	CON(1) 12
 
 M017	CON(2) (M018)-(M017)
	CON(2) 17      'End of Medium'
	CON(1) 5
	NIBASC 'End of'
	CON(1) 13
	CON(2) 67
	CON(1) 12
 
 M018	CON(2) (M019)-(M018)
	CON(2) 18	'Not LIF Format'
	CON(1) 7
	NIBASC 'Not LIF '
	CON(1) 5
	NIBASC 'Format'
	CON(1) 12
 
 M019	CON(2) (M020)-(M019)
	CON(2) 19	'Disk Drive Error'
	CON(1) 7
	NIBASC 'Disk Dri'
	CON(1) 7
	NIBASC 've Error'
	CON(1) 12
 
 M020	CON(2) (M021)-(M020)
	CON(2) 20	'No Medium'
	CON(1) 1
	NIBASC 'No'
	CON(1) 13
	CON(2) 67
	CON(1) 12
 
 M021	CON(2) (M022)-(M021)
	CON(2) 21	'Low Battery'
	CON(1) 14
	CON(2) 22
	CON(1) 12
 
 M022	CON(2) (M023)-(M022)
	CON(2) 22	'File Not Found'
	CON(1) 14
	CON(2) 57
	CON(1) 12
 
 M023	CON(2) (M024)-(M023)
	CON(2) 23	'New Medium'
	CON(1) 2
	NIBASC 'New'
	CON(1) 13
	CON(2) 67
	CON(1) 12
 
 M024	CON(2) (M025)-(M024)
	CON(2) 24	'Blank Medium'
	CON(1) 4
	NIBASC 'Blank'
	CON(1) 13
	CON(2) 67
	CON(1) 12
 
 M025	CON(2) (M026)-(M025)
	CON(2) 25	'Wrong Dir # records'
	CON(1) 7
	NIBASC 'Wrong di'
	CON(1) 7
	NIBASC 'r # reco'
	CON(1) 2
	NIBASC 'rds'
	CON(1) 12
 
 M026	CON(2) (M028)-(M026)
	CON(2) 26	'Checksum'
	CON(1) 7
	NIBASC 'Checksum'
	CON(1) 12
 
 M028	CON(2) (M029)-(M028)
	CON(2) 28	'Size of File'
	CON(1) 7
	NIBASC 'Size of '
	CON(1) 14
	CON(2) 234
	CON(1) 12
 
 M029	CON(2) (M030)-(M029)
	CON(2) 29	'Write protected'
	CON(1) 14
	CON(2) 66
	CON(1) 12
 
 M030	CON(2) (M031)-(M030)
	CON(2) 30	'File Exists'
	CON(1) 14
	CON(2) 59
	CON(1) 12
 
 M031	CON(2) (M032)-(M031)
	CON(2) 31	'Directory Full'
	CON(1) 7
	NIBASC 'Director'
	CON(1) 5
	NIBASC 'y Full'
	CON(1) 12
 
 M032	CON(2) (M034)-(M032)
	CON(2) 32	'Device Not Found'
	CON(1) 14
	CON(2) 64
	CON(1) 12
 
 M034	CON(2) (M035)-(M034)
	CON(2) 34	'Device Not Ready'
	CON(1) 13
	CON(2) 66
	CON(1) 7
	NIBASC 'Not Read'
	CON(1) 0
	NIBASC 'y'
	CON(1) 12
 
 M035	CON(2) (M036)-(M035)
	CON(2) 35	'Loop Broken'
	CON(1) 13
	CON(2) 69
	CON(1) 5
	NIBASC 'Broken'
	CON(1) 12
 
 M036	CON(2) (M037)-(M036)
	CON(2) 36	'Too Many Frames'
	CON(1) 14
	CON(2) 239
	CON(1) 4
	NIBASC 'Many '
	CON(1) 13
	CON(2) 70
	CON(1) 12
 
 M037	CON(2) (M038)-(M037)
	CON(2) 37	'Frames Lost'
	CON(1) 13
	CON(2) 70
	CON(1) 4
	NIBASC ' Lost'
	CON(1) 12
 
 M038	CON(2) (M039)-(M038)
	CON(2) 38	'Frames Altered'
	CON(1) 13
	CON(2) 70
	CON(1) 7
	NIBASC ' Altered'
	CON(1) 12
 
 M039	CON(2) (M040)-(M039)
	CON(2) 39	'Unexpected Message'
	CON(1) 7
	NIBASC 'Unexpect'
	CON(1) 2
	NIBASC 'ed '
	CON(1) 13
	CON(2) 65
	CON(1) 12
 
 M040	CON(2) (M041)-(M040)
	CON(2) 40	'Too Many Frames'
	CON(1) 13
	CON(2) 36
	CON(1) 12
 
 M041	CON(2) (M042)-(M041)
	CON(2) 41	'Invalid Mode'
	CON(1) 14
	CON(2) 236
	CON(1) 3
	NIBASC 'Mode'
	CON(1) 12
 
 M042	CON(2) (M043)-(M042)
	CON(2) 42	'Message Altered'
	CON(1) 13
	CON(2) 65	
	CON(1) 6
	NIBASC 'Altered'
	CON(1) 12
 
 M043	CON(2) (M044)-(M043)
	CON(2) 43	'Loop Timeout'
	CON(1) 13
	CON(2) 69
	CON(1) 6
	NIBASC 'Timeout'
	CON(1) 12
 
 M044	CON(2) (M045)-(M044)
	CON(2) 44	'Bad Addresses'
	CON(1) 7
	NIBASC 'Bad Addr'
	CON(1) 4
	NIBASC 'esses'
	CON(1) 12
 
 M045	CON(2) (M047)-(M045)
	CON(2) 45	'Self Test Failed'
	CON(1) 7
	NIBASC 'Self Tes'
	CON(1) 7
	NIBASC 't Failed'
	CON(1) 12
 
 M047	CON(2) (M052)-(M047)
	CON(2) 47	'Device Type'
	CON(1) 13
	CON(2) 66
	CON(1) 3
	NIBASC 'Type'
	CON(1) 12
 
 M052	CON(2) (M053)-(M052)
	CON(2) 52	'Aborted'
	CON(1) 6
	NIBASC 'Aborted'
	CON(1) 12
 
 M053	CON(2) (M054)-(M053)
	CON(2) 53	'Invalid Device Spec'
	CON(1) 14
	CON(2) 236
	CON(1) 13
	CON(2) 66
	CON(1) 3
	NIBASC 'Spec'
	CON(1) 12
 
 M054	CON(2) (M056)-(M054)
	CON(2) 54	'Data Type'
	CON(1) 14
	CON(2) 31
	CON(1) 12
 
 M056	CON(2) (M057)-(M056)
	CON(2) 56	'Invalid Arg'
	CON(1) 14
	CON(2) 11
	CON(1) 12
 
 M057	CON(2) (M059)-(M057)
	CON(2) 57	'No Loop'
	CON(1) 2
	NIBASC 'No '
	CON(1) 13
	CON(2) 69
	CON(1) 12
 
 M059	CON(2) (M060)-(M059)
	CON(2) 59	'Insufficient Memory'
	CON(1) 14
	CON(2) 24
	CON(1) 12
 
 M060	CON(2) (M065)-(M060)
	CON(2) 60	'RESTORE IO Needed'
	CON(1) 6
	NIBASC 'RESTORE'
	CON(1) 13
	CON(2) 68
	CON(1) 12
 
 M065	CON(2) (M066)-(M065)
	CON(2) 65	'Message '
	CON(1) 7
	NIBASC 'Message '
	CON(1) 12
 
 M066	CON(2) (M067)-(M066)
	CON(2) 66	'Device '
	CON(1) 6
	NIBASC 'Device '
	CON(1) 12
 
 M067	CON(2) (M068)-(M067)
	CON(2) 67	' Medium'
	CON(1) 6
	NIBASC ' Medium'
	CON(1) 12
 
 M068	CON(2) (M069)-(M068)
	CON(2) 68	' IO Needed'
	CON(1) 7
	NIBASC ' IO Need'
	CON(1) 1
	NIBASC 'ed'
	CON(1) 12
 
 M069	CON(2) (M070)-(M069)
	CON(2) 69	'Loop '
	CON(1) 4
	NIBASC 'Loop '
	CON(1) 12
 
 M070	CON(2) (MFIN)-(M070)
	CON(2) 70	' Frames'
	CON(1) 5
	NIBASC 'Frames'
	CON(1) 12
 
 MFIN	NIBHEX FF
 
	END
