	 TITLE	KRISTAL <kris.as>
 
 
*
*   86/10/15
*   86/10/26: PD/JT Supporte l'adressage etendu
* JPC:B00
*   87/05/07: PD/MM Retrait de err pour une routine supporté
*

 GETLPs	 EQU	#1D15
 PUTC	 EQU	#6B1C
 GET	 EQU	#6751

************************************************************
* NLOOP
************************************************************

	 NIBHEX 801
=NLOOPe	 GOSUBL =JUMPER	 cherche la boite
	 CON(5) GETLPs	 a lettre hpil
	 GOC	err	 erreur?
	 LC(4)	#0100	 demande le
	 GOSUB	SEND	 nbre de periph
	 A=0	A
	 B=C	W
	 A=C	B	 AAD
	 GOSUB	MPY
	 A=A+C	A	 AEP
	 GOSUB	MPY
	 GOSUB	MPY0
	 A=A+C	A	 AES
	 GONC	SRQ1	 B.E.T.
 
************************************************************
* PPOLL
************************************************************

	 NIBHEX 801
=PPOLLe	 GOSUB	SIDY	 envoie IDY 0
	 A=C	B	 resultat du ppoll
	 GONC	SRQ1	 B.E.T.
 
************************************************************
* SRQ
************************************************************

	 NIBHEX 801
=SRQe	 GOSUB	SIDY	 envoie IDY 0
	 CSR	A
	 CSR	A
	 A=C	P	 (P=0)
	 LC(1)	1
	 A=A&C	P	 isole bit SRQ
 SRQ1	 GOSBVL =HDFLT	 conv flottant
	 D0=(5) =FUNCD0
	 C=DAT0 A
	 CD0EX		 restaure D0
	 C=A	W	 resultat
	 GOVLNG =FNRTN1	 fin

 err	 GOTO	=erreur
 
 SIDY	 GOSUBL =JUMPER	 cherche la boite
	 CON(5) GETLPs	 au lettre hpil
	 GOC	err	 erreur?
	 LC(4)	#1E00
 SEND	 GOSUBL =JUMPER	 envoie la commande
	 CON(5) PUTC	 au processeur d'e/s
	 GOC	err	 erreur?
	 GOSUBL =JUMPER	 recoit la
	 CON(5) GET	 reponse
	 GOC	err	 erreur?
	 A=0	A	 initialise A pour
	 RTNCC		 la suite
 
 MPY	 BSR	W
	 BSR	W
	 C=0	A
	 C=B	B
 MPY0	 C=C+C	A	 2
	 D=C	A
	 D=D+D	A	 4
	 C=C+D	A	 6
	 CSL	A	 96
	 C=C+D	A	 100
	 RTN
 
************************************************************
* SLEEP
************************************************************

	 REL(5) =SLEEPd
	 REL(5) =SLEEPp
=SLEEPe	 CD0EX		 sauve D0
	 R0=C		 et D1 en
	 CD1EX		 R0 et R1
	 R1=C
	 GOSBVL =SLEEP	 en sommeil leger
	 GOSBVL =CKSREQ	 traite les SRQ
	 C=R1
	 D1=C		 restaure D1
	 C=R0		 et
	 D0=C		 D0
	 GOVLNG =NXTSTM
 
	 END
