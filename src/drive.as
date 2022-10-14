	 TITLE	DRIVELEX <drive.as>
 
*
* 85/03/30
* 86/07/18
* JPC:A03
*   86/10/26: PD/JT changement du test "Driver Lex File"
* JPC:B03
*   87/12/06: PD/JT renommé DISABLE en LEX <file> OFF
*   87/12/06: PD/JT renommé ENABLE en LEX <file> ON
*

************************************************************
* LEX <file> OFF (ex DISABLE)
************************************************************

	 REL(5) =LEXOFFd
	 REL(5) =LEXp
=LEXOFFe
	 GOSUB	POSD1
	 C=0	A
	 C=C-1	B
	 ?A=C	A
	 GOYES	Nxtstm
	 LC(5)	=fLEX
	 ?A#C	A
	 GOYES	Eftype
	 C=0	A
	 C=C-1	B
	 GOC	Config
 
************************************************************
* LEX <file> ON (ex ENABLE)
************************************************************

	 REL(5) =LEXONd
	 CON(5) 0	Pas de parse !!!
=LEXONe
	 GOSUB	POSD1
	 LC(5)	=fLEX
	 ?A=C	A
	 GOYES	Nxtstm
	 B=C	A
	 C=0	A
	 C=C-1	B
	 ?A#C	A
	 GOYES	Eftype
	 C=B	A
 Config	 DAT1=C 4
	 GOSBVL =LEXBF+
 Nxtstm	 GOVLNG =NXTSTM
 
 Eftype	 LC(2)	=eFTYPE
	 GOC	Mferr
 
 
 POSD1	 GOSBVL =FILXQ^
	 GOC	POSD2
	 LC(2)	=eFnFND
	 GONC	Mferr	  (B.E.T.)
 
 POSD2	 GOSBVL =FINDF
	 GOC	EfNfnd
	 C=0	S
	 C=C+1	S
	 ?D>C	S
	 GOYES	Efaccs
****************
* Modification du <861026.1405>
*
* Verification du "Driver Lex File"
* par test entre l'adresse du début du fichier
* demandé et l'adresse du début du Lex
* Pierre David & Janick Taillandier
*

* D1 = ^ debut du fichier demande

	 GOSUB	ici
 ici	 C=RSTK
	 A=C	A
	 LC(5)	(ici)-(=debut_du_lex)	Aaaaaaaaaaaaaah !
	 A=A-C	A      A(A) := ^ debut du LEX
	 CD1EX
	 D1=C
	 ?A=C	A
	 GOYES	Edrive
	 D1=D1+ 16
	 A=0	A
	 A=DAT1 4
	 RTN
 
 EfNfnd	 LC(2)	=eFnFND
 Mferr	 GOVLNG =MFERR
 
 Edrive	 LC(4)	(=id)~(=eDRIVE)
	 GOVLNG =BSERR
 
 Efaccs	 LC(2)	=eFACCS
	 GOC	Mferr
 
	 END
