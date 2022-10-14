	TITLE  JPCROM, fichier maître

 JPCPRV	EQU	1

*
* Version A00 :
*   15 Août 1986 -> 15 Août 1986
*     Réunion de tous les tokens disponibles alors
* Version A01 :
*   xx Septembre 1986 -> xx Septembre 1986
*     Ajout des fonctions qui n'étaient pas disponibles
*     alors. Ex : FIND, SHRINK
*     Ajout de nouveaux Lex : CLLEX
* Version A03 :
*   xx Novembre 1986 -> xx Novembre 1986
*     Intégration de nouvelles versions de Lex	: PPOLL,
*	ENDUP, HMSLEX (à revoir), PRINTLEX, DIVILEX
*     Intégration de EDIT de J.P. Bondu
*     Suppression de LABEL$ et MNEMO
* Version A04 :
*   11 Décembre 1986 -> fin Decembre 1986
*     Correction de la bogue de LEAVE (LEAVE non accepté à
*	la parse)
*     Limitation du paramètre de MARGIN
*     TI57LCD enlevé de la version courante
*     Ajout de RWLEX, SAISYLEX
* Version A05 :
*   24 Janvier 1987 -> 3 Mars 1987
*     Correction des bogues de FIND par JT
*     Nouvelle version de COMB et ARR par G. Toublanc
*     Débogage de FINPUT (FINP:2 -> FINP:3)
*     Ajout de FKEY (87/02/18) par PD et changt token EDIT
*     Ajout de FRAC$ (87/02/22) par PD et JT
*     Ajout de PKLEX (87/03/03) par PD & JT
*     Ajout de STRUC2 (87/03/03) par PD & JT
* Version A06 : (puis :B00)
*   17 Avril 1987 -> 15 mai 1987
*     Réécriture complète de DATELEX par PD & JT
*     Ajout de DATESTR$ par PD & JT
*     Correction de la bogue S=S+COMB(n,0) par PD & JT
*     Modifie MARGIN pour utiliser 1 bit & 1 buffer
*     Enlevé KSPEED (le mot-clef seulement)
*     Réécriture de SWAP (bug subsiste) (87/04/18) PD & JT
*     Ajout de MAPLEX (87/04/20) par PD & JT
*     POSI avec les paramètres de type alpha par PD & JT
*     FF -> PFF
*     LF -> PLF
*     CR -> PCR
*     PL -> PAGELEN
*     FPRM -> FPRIM
*     NPRM -> NPRIM
*     Modification de la séquence de BOLD par PD & JT
*     Correction de FINPUT ([CONT] ou [CALC]) (87/05/07) PD
*     Ajout de ILMSGLEX en 3ème Lex (87/05/07) par PD
*     Allocation de ressources HP (Corvallis / Don Ouchida)
*     4 bits dans la Reserved Ram (#2F991)
*     2 buffers (83D, 83E)
*     1 return type (9)
*     1 system flag (-53)
* Version B01 :
*   15 mai 1987 -> 1 aout 1987
*     Intégration de SYSEDIT
* Version B02 :
*   1 aout 1987 -> 14 aout 1987
*     Correction de SYSEDIT (REL->Ligne, GOVLNG/GOSBVL->adr)
*     Correction de WHILE : 10 WHILE 1 ! / 20 END WHILE
*	(ou LOOP ou REPEAT)
*     Distribution à Benski et Kudelski
* Version B03 : (puis :C) (25381 octets)
*   15 août 1987 -> 31 janvier 1988
*     C'est plus beau quand VER$ = JPC:C et non pas JPC:C00!
*     C'est mieux quand on peut éditer le fichier de SYSEDIT
*     Correction de SELECT 1 !	END SELECT
*     Correction de SELECT 1   CASE 0 !	 END SELECT
*     JPCLEX est mort, vive JPCROM !	(le 6 décembre 1987)
*     BLIST -> DBLIST
*     SWAP -> VARSWAP
*     INV$ supprimé
*     Syntaxe dans DESLEX: INVERSE[x1,x2] PAINT ([etat],x,y)
*     Paramètre supplémentaire de SPACE$
*     FILESIZE de Henri Kudelski débogué et intégré
*     Intégration de KA
*     Ajout d'un fichier def.as de définitions globales
*     Integration de ADLEX
*     DISABLE et ENABLE renommés en LEX <file> ON / OFF
*     Ajout de "obsolete" et du message associe
*     Interface unique pour RPLC$ et REPLACE$
*     Correction du bug détecté par Tapani Tarvainen
*	(DIM S$[LEN(STARTUP$)])
*     [<-] est normal en mode CALC + Cmd Stack (pas BackSp)
*     Ajout de KEYWAIT
*     Réécriture de ROMANLEX et intégration
*     Séparation de la parse et de la décompilation
*     Réécriture de D/PBLIST et intégration
*     Intégration de EXT files de Buitenhuis (réécrit)
*     Correction de PBLIST TOTO
*     Correction de JPC:C au lieu de JPC:C00
* Version C01 : (25383 octets)
*   6 février 1988 -> 6 février 1988
*     Correction de ROMAN : disparition du buffer à la mise
*	sous tension
*     bug dans pCONFG : PEEK$(reserved,1)->"E" après config
* Version C02 : (26525 octets)
*   12 février 1988 -> 12 février 1988
*     Integration de DIRLEX
*     Correction de POSI("",0) qui renvoyait 1 (signalé par
*	Joe Horn)
*     Inversion de RSI et PC=(A) dans SYSEDIT & OPCODE$
*     Remis le jeu de caractères Roman de la version C
*     Correction de DBLIST 1000 INDENT 4 (la parse plantait)
* Version C03 : (puis :D) (26559 octets)
*   13 février 1988 -> 24 avril 1988
*     Modification du message de copyright pour inclure 1988
*     Correction de FIND (Kudelski, Benski et JJD)
*     PDIR n'est plus decompilé en KA (Kudelski et Benski)
*     DOW(29.021996 ou 29.021992) ne plante plus (Istria)
*     Initialisation du nb d'appuis successifs sur [ENDLN]
*	dans KA (Kudelski)
*     Envoi à CMT
* Version D01 : (26624 octets)
*   4 novembre 1988 -> 17 juin 1989
*     Correction de la longueur de l'entrée "obsolete" dans
*	la text-table
*     Correction du bug CASE >... (Istria et Jean Horville)
*     Correction du bug LEAVE ! (etc) (Joseph A. Dickerson)
*     Ajout du paramètre optionnel de LEAVE
*     Changement de syntaxe de PEEK$, POKE, OPCODE$,
*	NEXTOP$, SYSEDIT
* Version D02 : (44138 octets)
*   18 juin 1989 -> 18 juin 1989
*     Intégration de XEDIT et des fonctions associées
*     Réécriture de FIND (faisant partie de XEDIT)
*     Mise en commun de =fkey dans KA pour FKEY et XEDIT
*     Mise en commun de =Num2D1 dans KA pour XEDIT
*     Tab assembleur plus valides sous EDTEXT mais XEDIT
*     Intégration du "module graphique"
*     Protection par "private" et JPCPRV
* Version D03 : (puis :E) (44161 octets)
*   7 août 1989 -> 6 octobre 1989
*     Correction de lfin par défaut dans la cmd J de XEDIT
* Version E01 : (44098 octets privatisé)
*   21 octobre 1989 -> 21 octobre 1989
*     Correction de GENRPLC$ (Jean Reibel) (désalloc. buf.)
* Version E02 : (44102 octets privatisé)
*   24 juin 1990 -> 24 juin 1990
*     Correction de SYSEDIT de Markov (REL(n) en arrière avec n < 5)
*

*
* Ordre de chaînage des Lex
*	jpcrom
*	pklex	(LEX2)
*	ilmsg	(LEX3)
*	keywait	(LEX4)
*	graph	(LEX5)
*

=tLEXOFF EQU   09
=tLEXON	 EQU   10

=tEND2	 EQU   66
=tWHILE	 EQU   67
=tREPEAT EQU   68
=tUNTIL	 EQU   69
=tLEAVE	 EQU   70

=tLOOP	 EQU   96
=tSELECT EQU   97
=tCASE	 EQU   98
=tIF2	 EQU   99
=tELSE2	 EQU   100

=tINDENT EQU   109

=debut_du_lex

	NIBASC 'JPCROM  '

    if JPCPRV
	NIBHEX FF00
    else
	NIBHEX 802E
    endif

	CON(2) 0
	CON(4) #0000	Heure / Minute
	CON(6) #000000	Jour / Mois / Annee
	REL(5) =FiLeNd

=id	       EQU    #E1
=lowest_token  EQU    1
=highest_token EQU    117

	CON(2) =id
	CON(2) =lowest_token
	CON(2) =highest_token
	REL(5) =LEX2	PKLEX

	NIBHEX 0
	CON(3) (A)-(TxTbSt)
	CON(3) (B)-(TxTbSt)
	CON(3) (C)-(TxTbSt)
	CON(3) (D)-(TxTbSt)
	CON(3) (E)-(TxTbSt)
	CON(3) (F)-(TxTbSt)
	CON(3) (G)-(TxTbSt)
	CON(3) (H)-(TxTbSt)
	CON(3) (I)-(TxTbSt)
	CON(3) (TxTbEn)-(TxTbSt)
	CON(3) (K)-(TxTbSt)
	CON(3) (L)-(TxTbSt)
	CON(3) (M)-(TxTbSt)
	CON(3) (N)-(TxTbSt)
	CON(3) (O)-(TxTbSt)
	CON(3) (P)-(TxTbSt)
	CON(3) (TxTbEn)-(TxTbSt)
	CON(3) (R)-(TxTbSt)
	CON(3) (S)-(TxTbSt)
	CON(3) (T)-(TxTbSt)
	CON(3) (U)-(TxTbSt)
	CON(3) (V)-(TxTbSt)
	CON(3) (W)-(TxTbSt)
	CON(3) (X)-(TxTbSt)
	CON(3) (TxTbEn)-(TxTbSt)
	CON(3) (TxTbEn)-(TxTbSt)
	NIBHEX 0

	REL(4) 1+TxTbSt
	REL(4) =MSGTBL
	REL(5) =POLHND

	STITLE * * * M A I N   T A B L E * * *

	CON(3) (TxTk01)-(TxTbSt)
	REL(5) =ADBUFe
	CON(1) #F

	CON(3) (TxTk02)-(TxTbSt)
	REL(5) =ASCe
	CON(1) #F

	CON(3) (TxTk03)-(TxTbSt)
	REL(5) =ATHe
	CON(1) #F

	CON(3) (TxTk04)-(TxTbSt)
	REL(5) =HTAe
	CON(1) #F

	CON(3) (TxTk05)-(TxTbSt)
	REL(5) =REDe
	CON(1) #F

	CON(3) (TxTk06)-(TxTbSt)
	REL(5) =REPLACEe
	CON(1) #F

	CON(3) (TxTk07)-(TxTbSt)
	REL(5) =FILESIZEe
	CON(1) #F

	CON(3) (TxTk08)-(TxTbSt)
	REL(5) =ATTNe
	CON(1) #D

	CON(3) (TxTk09)-(TxTbSt)
	REL(5) =LEXOFFe
	CON(1) #D

	CON(3) (TxTk10)-(TxTbSt)
	REL(5) =LEXONe
	CON(1) #D

	CON(3) (TxTk11)-(TxTbSt)
	REL(5) =FKEYe
	CON(1) #D

	CON(3) (TxTk12)-(TxTbSt)
	REL(5) =CONTRASTe
	CON(1) #F

	CON(3) (TxTk13)-(TxTbSt)
	REL(5) =INVERSEe
	CON(1) #D

	CON(3) (TxTk14)-(TxTbSt)
	REL(5) =obsolete
	CON(1) 0

	CON(3) (TxTk15)-(TxTbSt)
	REL(5) =PAINTe
	CON(1) #F

	CON(3) (TxTk16)-(TxTbSt)
	REL(5) =ENDUP$e
	CON(1) #F

	CON(3) (TxTk17)-(TxTbSt)
	REL(5) =ENDUPe
	CON(1) #D

	CON(3) (TxTk18)-(TxTbSt)
	REL(5) =STARTUPe
	CON(1) #F

	CON(3) (TxTk19)-(TxTbSt)
	REL(5) =EXECUTEe
	CON(1) #D

	CON(3) (TxTk20)-(TxTbSt)
	REL(5) =ARRe
	CON(1) #F

	CON(3) (TxTk21)-(TxTbSt)
	REL(5) =COMBe
	CON(1) #F

	CON(3) (TxTk22)-(TxTbSt)
	REL(5) =HMS+e
	CON(1) #F

	CON(3) (TxTk23)-(TxTbSt)
	REL(5) =HMS-e
	CON(1) #F

	CON(3) (TxTk24)-(TxTbSt)
	REL(5) =HMSe
	CON(1) #F

	CON(3) (TxTk25)-(TxTbSt)
	REL(5) =HRe
	CON(1) #F

	CON(3) (TxTk26)-(TxTbSt)
	REL(5) =EDITe
	CON(1) #5	Non programmable

	CON(3) (TxTk27)-(TxTbSt)
	REL(5) =STACKe
	CON(1) #D

	CON(3) (TxTk28)-(TxTbSt)
	REL(5) =obsolete
	CON(1) 0

	CON(3) (TxTk29)-(TxTbSt)
	REL(5) =MARGINe
	CON(1) #D

	CON(3) (TxTk30)-(TxTbSt)
	REL(5) =NEXTOPe
	CON(1) #F

	CON(3) (TxTk31)-(TxTbSt)
	REL(5) =OPCODEe
	CON(1) #F

	CON(3) (TxTk32)-(TxTbSt)
	REL(5) =SYSEDITe
	CON(1) #D

	CON(3) (TxTk33)-(TxTbSt)
	REL(5) =MENUe
	CON(1) #F

	CON(3) (TxTk34)-(TxTbSt)
	REL(5) =CENTERe
	CON(1) #F

	CON(3) (TxTk35)-(TxTbSt)
	REL(5) =CESUREe
	CON(1) #F

	CON(3) (TxTk36)-(TxTbSt)
	REL(5) =FORMATe
	CON(1) #F

	CON(3) (TxTk37)-(TxTbSt)
	REL(5) =REDUCEe
	CON(1) #F

	CON(3) (TxTk38)-(TxTbSt)
	REL(5) =SPACEe
	CON(1) #F

	CON(3) (TxTk39)-(TxTbSt)
	REL(5) =BELLe
	CON(1) #D

	CON(3) (TxTk40)-(TxTbSt)
	REL(5) =BOLDe
	CON(1) #D

	CON(3) (TxTk41)-(TxTbSt)
	REL(5) =PCRe
	CON(1) #D

	CON(3) (TxTk42)-(TxTbSt)
	REL(5) =ESCe
	CON(1) #F

	CON(3) (TxTk43)-(TxTbSt)
	REL(5) =PFFe
	CON(1) #D

	CON(3) (TxTk44)-(TxTbSt)
	REL(5) =PLFe
	CON(1) #D

	CON(3) (TxTk45)-(TxTbSt)
	REL(5) =MODEe
	CON(1) #D

	CON(3) (TxTk46)-(TxTbSt)
	REL(5) =PERFe
	CON(1) #D

	CON(3) (TxTk47)-(TxTbSt)
	REL(5) =PAGELENe
	CON(1) #D

	CON(3) (TxTk48)-(TxTbSt)
	REL(5) =UNDERLINEe
	CON(1) #D

	CON(3) (TxTk49)-(TxTbSt)
	REL(5) =WRAPe
	CON(1) #D

	CON(3) (TxTk50)-(TxTbSt)
	REL(5) =DATESe
	CON(1) #F

	CON(3) (TxTk51)-(TxTbSt)
	REL(5) =DATEAe
	CON(1) #F

	CON(3) (TxTk52)-(TxTbSt)
	REL(5) =DDAYSe
	CON(1) #F

	CON(3) (TxTk53)-(TxTbSt)
	REL(5) =DMYe
	CON(1) #D

	CON(3) (TxTk54)-(TxTbSt)
	REL(5) =DOW$e
	CON(1) #F

	CON(3) (TxTk55)-(TxTbSt)
	REL(5) =DOWe
	CON(1) #F

	CON(3) (TxTk56)-(TxTbSt)
	REL(5) =MDYe
	CON(1) #D

	CON(3) (TxTk57)-(TxTbSt)
	REL(5) =MAXDe
	CON(1) #F

	CON(3) (TxTk58)-(TxTbSt)
	REL(5) =MAXMe
	CON(1) #F

	CON(3) (TxTk59)-(TxTbSt)
	REL(5) =MEMDe
	CON(1) #F

	CON(3) (TxTk60)-(TxTbSt)
	REL(5) =MEMMe
	CON(1) #F

	CON(3) (TxTk61)-(TxTbSt)
	REL(5) =EXITe
	CON(1) 12

	CON(3) (TxTk62)-(TxTbSt)
	REL(5) =NLOOPe
	CON(1) #F

	CON(3) (TxTk63)-(TxTbSt)
	REL(5) =PPOLLe
	CON(1) #F

	CON(3) (TxTk64)-(TxTbSt)
	REL(5) =SLEEPe
	CON(1) #D

	CON(3) (TxTk65)-(TxTbSt)
	REL(5) =SRQe
	CON(1) #F

	CON(3) (TxTk66)-(TxTbSt)
	REL(5) =END2e
	CON(1) #D

	CON(3) (TxTk67)-(TxTbSt)
	REL(5) =WHILEe
	CON(1) #D

	CON(3) (TxTk68)-(TxTbSt)
	REL(5) =REPEATe
	CON(1) #D

	CON(3) (TxTk69)-(TxTbSt)
	REL(5) =UNTILe
	CON(1) #D

	CON(3) (TxTk70)-(TxTbSt)
	REL(5) =LEAVEe
	CON(1) #D

	CON(3) (TxTk71)-(TxTbSt)
	REL(5) =SWAPe
	CON(1) #D

	CON(3) (TxTk72)-(TxTbSt)
	REL(5) =ENTRYe
	CON(1) #F

	CON(3) (TxTk73)-(TxTbSt)
	REL(5) =TOKENe
	CON(1) #F

	CON(3) (TxTk74)-(TxTbSt)
	REL(5) =obsolete
	CON(1) 0

	CON(3) (TxTk75)-(TxTbSt)
	REL(5) =FINDe
	CON(1) #1

	CON(3) (TxTk76)-(TxTbSt)
	REL(5) =MAP$e
	CON(1) #F

	CON(3) (TxTk77)-(TxTbSt)
	REL(5) =MAPe
	CON(1) #D

	CON(3) (TxTk78)-(TxTbSt)
	REL(5) =GLINEe
	CON(1) #D

	CON(3) (TxTk79)-(TxTbSt)
	REL(5) =GPSETe
	CON(1) #D

	CON(3) (TxTk80)-(TxTbSt)
	REL(5) =REPLACEe
	CON(1) #F

	CON(3) (TxTk81)-(TxTbSt)
	REL(5) =SHRINKe
	CON(1) #D

	CON(3) (TxTk82)-(TxTbSt)
	REL(5) =FPRIMe
	CON(1) #F

	CON(3) (TxTk83)-(TxTbSt)
	REL(5) =NPRIMe
	CON(1) #F

	CON(3) (TxTk84)-(TxTbSt)
	REL(5) =PGCDe
	CON(1) #F

	CON(3) (TxTk85)-(TxTbSt)
	REL(5) =PHIe
	CON(1) #F

	CON(3) (TxTk86)-(TxTbSt)
	REL(5) =PPCMe
	CON(1) #F

	CON(3) (TxTk87)-(TxTbSt)
	REL(5) =PRIMe
	CON(1) #F

	CON(3) (TxTk88)-(TxTbSt)
	REL(5) =FRACe
	CON(1) #F

	CON(3) (TxTk89)-(TxTbSt)
	REL(5) =POSIe
	CON(1) #F

	CON(3) (TxTk90)-(TxTbSt)
	REL(5) =DBLISTe
	CON(1) #D

	CON(3) (TxTk91)-(TxTbSt)
	REL(5) =PBLISTe
	CON(1) #D

	CON(3) (TxTk92)-(TxTbSt)
	REL(5) =RENUMREMe
	CON(1) #D

	CON(3) (TxTk93)-(TxTbSt)
	REL(5) =FINPUTe
	CON(1) #D

	CON(3) (TxTk94)-(TxTbSt)
	REL(5) =RRECe
	CON(1) #F

	CON(3) (TxTk95)-(TxTbSt)
	REL(5) =WRECe
	CON(1) #D

	CON(3) (TxTk96)-(TxTbSt)
	REL(5) =LOOPe
	CON(1) #D
 
	CON(3) (TxTk97)-(TxTbSt)
	REL(5) =SELECTe
	CON(1) #D
 
	CON(3) (TxTk98)-(TxTbSt)
	REL(5) =CASEe
	CON(1) #D
 
	CON(3) (TxTk99)-(TxTbSt)
	REL(5) =IF2e
	CON(1) #9
 
	CON(3) (TxTk100)-(TxTbSt)
	REL(5) =ELSE2e
	CON(1) #D
 
	CON(3) (TxTk101)-(TxTbSt)
	REL(5) =KAe
	CON(1) #D
 
	CON(3) (TxTk102)-(TxTbSt)
	REL(5) =ADCREATEe
	CON(1) #D

	CON(3) (TxTk103)-(TxTbSt)
	REL(5) =ADDELETEe
	CON(1) #D

	CON(3) (TxTk104)-(TxTbSt)
	REL(5) =ADFINDe
	CON(1) #F

	CON(3) (TxTk105)-(TxTbSt)
	REL(5) =ADGETe
	CON(1) #D

	CON(3) (TxTk106)-(TxTbSt)
	REL(5) =ADPUTe
	CON(1) #D

	CON(3) (TxTk107)-(TxTbSt)
	REL(5) =ADSIZEe
	CON(1) #F

	CON(3) (TxTk108)-(TxTbSt)
	REL(5) =ROMANe
	CON(1) #D

	CON(3) (TxTk109)-(TxTbSt)
	CON(5) 0
	CON(1) #0	Mot non accessible (INDENT)

	CON(3) (TxTk110)-(TxTbSt)
	REL(5) =DDIRe
	CON(1) #D

	CON(3) (TxTk111)-(TxTbSt)
	REL(5) =PDIRe
	CON(1) #D

	CON(3) (TxTk112)-(TxTbSt)
	REL(5) =FILEPOSe
	CON(1) #F

	CON(3) (TxTk113)-(TxTbSt)
	REL(5) =GENLENe
	CON(1) #F

	CON(3) (TxTk114)-(TxTbSt)
	REL(5) =GENPOSe
	CON(1) #F

	CON(3) (TxTk115)-(TxTbSt)
	REL(5) =GENRPLCe
	CON(1) #F

	CON(3) (TxTk116)-(TxTbSt)
	REL(5) =TEDITe
	CON(1) #D

	CON(3) (TxTk117)-(TxTbSt)
	REL(5) =XEDITe
	CON(1) #D

	STITLE * * * T E X T   T A B L E * * *

 TxTbSt

 A
 TxTk01 CON(1) 11
	NIBASC 'ADBUF$'
	CON(2) 1

 TxTk102 CON(1) 15
	NIBASC 'ADCREATE'
	CON(2) 102

 TxTk103 CON(1) 15
	NIBASC 'ADDELETE'
	CON(2) 103

 TxTk104 CON(1) 11
	NIBASC 'ADFIND'
	CON(2) 104

 TxTk105 CON(1) 9
	NIBASC 'ADGET'
	CON(2) 105

 TxTk106 CON(1) 9
	NIBASC 'ADPUT'
	CON(2) 106

 TxTk107 CON(1) 11
	NIBASC 'ADSIZE'
	CON(2) 107

 TxTk20 CON(1) 5
	NIBASC 'ARR'
	CON(2) 20

 TxTk02 CON(1) 7
	NIBASC 'ASC$'
	CON(2) 2

 TxTk03 CON(1) 7
	NIBASC 'ATH$'
	CON(2) 3

 TxTk08 CON(1) 7
	NIBASC 'ATTN'
	CON(2) 8

 B
 TxTk39 CON(1) 7
	NIBASC 'BELL'
	CON(2) 39

 TxTk40 CON(1) 7
	NIBASC 'BOLD'
	CON(2) 40

 C
 TxTk98 CON(1) 7
	NIBASC 'CASE'
	CON(2) =tCASE

 TxTk34 CON(1) 13
	NIBASC 'CENTER$'
	CON(2) 34

 TxTk35 CON(1) 11
	NIBASC 'CESURE'
	CON(2) 35

 TxTk21 CON(1) 7
	NIBASC 'COMB'
	CON(2) 21

 TxTk12 CON(1) 15
	NIBASC 'CONTRAST'
	CON(2) 12

 D
 TxTk51 CON(1) 13
	NIBASC 'DATEADD'
	CON(2) 51

 TxTk50 CON(1) 15
	NIBASC 'DATESTR$'
	CON(2) 50

 TxTk90 CON(1) 11
	NIBASC 'DBLIST'
	CON(2) 90

 TxTk52 CON(1) 9
	NIBASC 'DDAYS'
	CON(2) 52

 TxTk110 CON(1) 7
	NIBASC 'DDIR'
	CON(2) 110

 TxTk53 CON(1) 5
	NIBASC 'DMY'
	CON(2) 53

 TxTk54 CON(1) 7
	NIBASC 'DOW$'
	CON(2) 54

 TxTk55 CON(1) 5
	NIBASC 'DOW'
	CON(2) 55

 E
 TxTk26 CON(1) 7
	NIBASC 'EDIT'
	CON(2) 26

 TxTk100 CON(1) 7
	NIBASC 'ELSE'
	CON(2) =tELSE2

 TxTk16 CON(1) 11
	NIBASC 'ENDUP$'
	CON(2) 16

 TxTk17 CON(1) 9
	NIBASC 'ENDUP'
	CON(2) 17

 TxTk66 CON(1) 5
	NIBASC 'END'
	CON(2) 66

 TxTk72 CON(1) 11
	NIBASC 'ENTRY$'
	CON(2) 72

 TxTk42 CON(1) 7
	NIBASC 'ESC$'
	CON(2) 42

 TxTk19 CON(1) 13
	NIBASC 'EXECUTE'
	CON(2) 19

 TxTk61 CON(1) 7
	NIBASC 'EXIT'
	CON(2) 61

 F
 TxTk112 CON(1) 13
	NIBASC 'FILEPOS'
	CON(2) 112

 TxTk07 CON(1) 15
	NIBASC 'FILESIZE'
	CON(2) 7

 TxTk75 CON(1) 7
	NIBASC 'FIND'
	CON(2) 75

 TxTk93 CON(1) 11
	NIBASC 'FINPUT'
	CON(2) 93

 TxTk11 CON(1) 7
	NIBASC 'FKEY'
	CON(2) 11

 TxTk36 CON(1) 13
	NIBASC 'FORMAT$'
	CON(2) 36

 TxTk82 CON(1) 9
	NIBASC 'FPRIM'
	CON(2) 82

 TxTk88 CON(1) 9
	NIBASC 'FRAC$'
	CON(2) 88

 G
 TxTk113 CON(1) 11
	NIBASC 'GENLEN'
	CON(2) 113

 TxTk114 CON(1) 11
	NIBASC 'GENPOS'
	CON(2) 114

 TxTk115 CON(1) 15
	NIBASC 'GENRPLC$'
	CON(2) 115

 TxTk78 CON(1) 9
	NIBASC 'GLINE'
	CON(2) 78

 TxTk79 CON(1) 9
	NIBASC 'GPSET'
	CON(2) 79

 H
 TxTk22 CON(1) 11
	NIBASC 'HMSADD'
	CON(2) 22

 TxTk23 CON(1) 11
	NIBASC 'HMSSUB'
	CON(2) 23

 TxTk24 CON(1) 5
	NIBASC 'HMS'
	CON(2) 24

 TxTk25 CON(1) 3
	NIBASC 'HR'
	CON(2) 25

 TxTk04 CON(1) 7
	NIBASC 'HTA$'
	CON(2) 4

 I
 TxTk99 CON(1) 3
	NIBASC 'IF'
	CON(2) =tIF2

 TxTk109 CON(1) 11
	NIBASC 'INDENT'
	CON(2) =tINDENT

 TxTk13 CON(1) 13
	NIBASC 'INVERSE'
	CON(2) 13

* TxTk14 CON(1) 7
*	 NIBASC 'INV$'
*	 CON(2) 14

 J

 K
 TxTk101 CON(1) 3
	NIBASC 'KA'
	CON(2) 101

 L
 TxTk70 CON(1) 9
	NIBASC 'LEAVE'
	CON(2) 70

 TxTk09
 TxTk10 CON(1) 5
	NIBASC 'LEX'
	CON(2) 09

 TxTk96 CON(1) 7
	NIBASC 'LOOP'
	CON(2) =tLOOP

M
 TxTk76 CON(1) 7
	NIBASC 'MAP$'
	CON(2) 76

 TxTk77 CON(1) 5
	NIBASC 'MAP'
	CON(2) 77

 TxTk29 CON(1) 11
	NIBASC 'MARGIN'
	CON(2) 29

 TxTk57 CON(1) 7
	NIBASC 'MAXD'
	CON(2) 57

 TxTk58 CON(1) 7
	NIBASC 'MAXM'
	CON(2) 58

 TxTk56 CON(1) 5
	NIBASC 'MDY'
	CON(2) 56

 TxTk59 CON(1) 7
	NIBASC 'MEMD'
	CON(2) 59

 TxTk60 CON(1) 7
	NIBASC 'MEMM'
	CON(2) 60

 TxTk33 CON(1) 7
	NIBASC 'MENU'
	CON(2) 33

 TxTk45 CON(1) 7
	NIBASC 'MODE'
	CON(2) 45

 N
 TxTk30 CON(1) 13
	NIBASC 'NEXTOP$'
	CON(2) 30

 TxTk62 CON(1) 9
	NIBASC 'NLOOP'
	CON(2) 62

 TxTk83 CON(1) 9
	NIBASC 'NPRIM'
	CON(2) 83

 O
 TxTk31 CON(1) 13
	NIBASC 'OPCODE$'
	CON(2) 31
 P
 TxTk47 CON(1) 13
	NIBASC 'PAGELEN'
	CON(2) 47

 TxTk15 CON(1) 9
	NIBASC 'PAINT'
	CON(2) 15

 TxTk63 CON(1) 13
	NIBASC 'PARPOLL'
	CON(2) 63

 TxTk91 CON(1) 11
	NIBASC 'PBLIST'
	CON(2) 91

 TxTk41 CON(1) 5
	NIBASC 'PCR'
	CON(2) 41

 TxTk111 CON(1) 7
	NIBASC 'PDIR'
	CON(2) 111

 TxTk46 CON(1) 7
	NIBASC 'PERF'
	CON(2) 46

 TxTk43 CON(1) 5
	NIBASC 'PFF'
	CON(2) 43

 TxTk84 CON(1) 7
	NIBASC 'PGCD'
	CON(2) 84

 TxTk85 CON(1) 5
	NIBASC 'PHI'
	CON(2) 85

 TxTk44 CON(1) 5
	NIBASC 'PLF'
	CON(2) 44

 TxTk89 CON(1) 7
	NIBASC 'POSI'
	CON(2) 89

 TxTk86 CON(1) 7
	NIBASC 'PPCM'
	CON(2) 86

 TxTk87 CON(1) 7
	NIBASC 'PRIM'
	CON(2) 87

 Q
 R
 TxTk05 CON(1) 7
	NIBASC 'RED$'
	CON(2) 5

 TxTk37 CON(1) 13
	NIBASC 'REDUCE$'
	CON(2) 37

 TxTk92 CON(1) 15
	NIBASC 'RENUMREM'
	CON(2) 92

 TxTk68 CON(1) 11
	NIBASC 'REPEAT'
	CON(2) 68

 TxTk80
 TxTk06 CON(1) 15
	NIBASC 'REPLACE$'
	CON(2) 6

 TxTk108 CON(1) 9
	NIBASC 'ROMAN'
	CON(2) 108

 TxTk94 CON(1) 9
	NIBASC 'RREC$'
	CON(2) 94

 S
 TxTk97 CON(1) 11
	NIBASC 'SELECT'
	CON(2) =tSELECT

 TxTk81 CON(1) 11
	NIBASC 'SHRINK'
	CON(2) 81

 TxTk64 CON(1) 9
	NIBASC 'SLEEP'
	CON(2) 64

 TxTk38 CON(1) 11
	NIBASC 'SPACE$'
	CON(2) 38

 TxTk65 CON(1) 5
	NIBASC 'SRQ'
	CON(2) 65

 TxTk27 CON(1) 9
	NIBASC 'STACK'
	CON(2) 27

 TxTk18 CON(1) 15
	NIBASC 'STARTUP$'
	CON(2) 18

 TxTk32 CON(1) 13
	NIBASC 'SYSEDIT'
	CON(2) 32

 T
 TxTk116 CON(1) 9
	NIBASC 'TEDIT'
	CON(2) 116

 TxTk73 CON(1) 9
	NIBASC 'TOKEN'
	CON(2) 73

* TxTk74 CON(1) 7
*	 NIBASC 'TYPE'
*	 CON(2) 74

 U
 TxTk48 CON(1) 15
	NIBASC 'UNDERLIN'
	CON(2) 48

 TxTk69 CON(1) 9
	NIBASC 'UNTIL'
	CON(2) 69

 V
 TxTk71 CON(1) 13
	NIBASC 'VARSWAP'
	CON(2) 71

 W
 TxTk67 CON(1) 9
	NIBASC 'WHILE'
	CON(2) 67

 TxTk49 CON(1) 7
	NIBASC 'WRAP'
	CON(2) 49

 TxTk95 CON(1) 7
	NIBASC 'WREC'
	CON(2) 95

 X
 TxTk117 CON(1) 9
	NIBASC 'XEDIT'
	CON(2) 117

 Y
 Z

 TxTk14
 TxTk28
 TxTk74
	CON(1) 15
	NIBASC 'obsolete'
	CON(2) 00

 TxTbEn
	NIBHEX 1FF	Ouf !

*
* Le seul keyword implémenté dans ce fichier...
*
	REL(5) =obsoleted
	CON(5) 0	Pas de parse !
=obsolete
	LC(4)  (=id)~(=eOBSOL)
	GOVLNG =BSERR

	END
