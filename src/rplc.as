	TITLE  RPLC$ <rplc.as>

*
* JPC:B03
*   87/12/08: PD/JT Interface unique pour RPLC$ et REPLACE$
*

*
*   Interface unique pour RPLC$ et REPLACE$
*     si 3 parametres : RPLC$
*     si 4 parametres & dernier = num : RPLC$
*     si 4 parametres & dernier = alpha : REPLACE$
*   L'interface est place dans le fichier replace.as
*

 RegExp EQU    0
 TopLvl EQU    7
 Match	EQU    9
 Anchor EQU    11
 First	EQU    5
 Close	EQU    6
 Ins	EQU    4
 BackS	EQU    7


* Remplace dans S$, O$ par R$
* R$=R1$[&'\&'[&R2$]]

* OUTBS	    : Debut de R1$
* FUNCR0+25 : Fin de R1$ - Debut de R2$
* FUNCR0    : Fin de R2$ - Debut de O$
* AVMEMS    : Fin de O$
* FUNCR0+5  : Debut de S$
* FUNCR0+30 : Pointeur actif
* FUNCR0+20 : Fin de S$

=RPLC	CD0EX		Sauvegarde D0
	D0=(5) =FUNCD1
	DAT0=C A
	P=C    15	La valeur par defaut du
	?P=    3	4eme parametre est zero
	GOYES  REP04
	GOSBVL =POP1R
	D1=D1+ 16
	GOSBVL =FLTDH
	A=A-1  A	 -> Option Base 0
	GONC   REP05
 REP04	A=0    A	Considere 0 comme 1
 REP05	CLRST
	P=     0
	D0=(5) (=FUNCR0)+15
	DAT0=A A
	A=A-1  A
	GOC    REP10
	ST=1   First

 REP10	GOSBVL =REVPOP	Analyse R$
	CD1EX
	D1=C		D1 @ debut de R$
	C=C+A  A
	D=C    A	D(A) @ fin de R$
	GOSBVL =D0=AVS	A(A)=AVMEMS
 REP15	D0=(5) (=FUNCR0)+25
	DAT0=A A	R1$='' - R2$=R$
	D0=A
 REP20	CD1EX
	D1=C
	?C>=D  A	Fin de R$?
	GOYES  REP100	Oui; analyse terminee
	A=DAT1 B	Lit un charactere
	D1=D1+ 2
	LCASC  '\'
	?A=C   B	Est-ce 1 '\'?
	GOYES  REP30	Oui
	LCASC  '&'
	?A=C   B	Est-ce 1 '&'?
	GOYES  REP50	Oui
 REP22	DAT0=A B	Stocke ce caractere
	D0=D0+ 2
	ST=0   Close	Si l'on est arrive ici,
*			c'est que 2 '\' ne se
*			suivent pas
	GONC   REP20	(B.E.T.)


 REP30	?ST=1  BackS	Deja 1 '\' de trouve?
	GOYES  REP40	Oui
	ST=1   BackS	C'est le 1er
	ST=1   Close	Peut-etre y-en-a-t-il 2
 REP35	GONC   REP20	(B.E.T.) cote-a-cote

 REP40	ST=0   BackS	Alors on sort du mode '\'
	?ST=1  Close	A-t-on trouve '\\'?
	GOYES  REP22	Oui; on en garde 1 seul
	GONC   REP35	(B.E.T.) Non


 REP50	?ST=0  BackS	Hors mode '\'?
	GOYES  REP22	Oui; '&' n'a aucune action
	?ST=1  Ins	'\&' deja trouve?
	GOYES  REP22	Oui; alors rien a faire
	ST=0   BackS	Sort du mode '\'
	ST=1   Ins	Indique '\&' trouve
	AD0EX		On a trouve la fin de R1$
	GOTO   REP15



 REP100 AD0EX		On a trouve la fin de R2$
	D0=(5) =AVMEMS
	DAT0=A A
	?ST=1  Ins
	GOYES  REP102
	D0=(5) (=FUNCR0)+25  Si POS(R$,'\&')=0 alors
	DAT0=A A	R1$=R$ - R2=''
 REP102 GOSBVL =REVPOP	Analyse O$
	B=A    A
	CD1EX
	A=A+C  A
	R0=A
	A=DAT0 A
	ACEX   A
	GOSBVL =MOVE*M	Deplace O$ derriere R2$
	R1=C
	D0=(5) =AVMEMS	Actualise AVMEMS
	C=C+B  A
	DAT0=C A
	C=B    A
	R3=C

	D0=(5) =FUNCR0	Debut de O$ ->
	C=R1
	DAT0=C A
	D1=C		Analyse O$ - On ne peut
	A=R3		avoir  LEN(O$)=0 ou O$='\'
	C=C+A  A	Cf IDS 1
	R2=C
	D0=C
	?A=0   A
	GOYES  REPNOM
	D0=D0- 2
	A=DAT0 B
	LCASC  '\'
	?A#C   B
	GOYES  REP120
	D0=D0- 2
	AD1EX
	D1=A
	CD0EX
	?A<C   A
	GOYES  REP110
 REPNOM A=R0
	D1=A
	D0=(5) =FUNCD1
	A=DAT0 A
	D0=A
	GOVLNG =EXPR

 REP110 D0=C
	A=DAT0 B
	LCASC  '\'
	?A=C   B
	GOYES  REP120
	C=R2
	C=C-1  A
	C=C-1  A
	R2=C

 REP120 D0=(5) =AVMEMS	Actualise si O$=O1$&'\'
	A=R2
	DAT0=A A
	C=0    A	Calcule (AVMEMS)+21 pr SCAN
	LC(2)  21
	A=A+C  A
	AR0EX
	D1=A
	GOSBVL =REVPOP	Etudie enfin S$
	D0=(5) (=FUNCR0)+5 Debut de S$
	CD1EX
	D1=C
	DAT0=C A
	D0=D0+ 15	Fin de S$
	A=A+C  A
	DAT0=A A
	D0=D0- 5
	A=DAT0 A

	ST=0   Anchor
 
	D0=D0+ 15	Debut de la recherche
	C=C+A  A
	GOC    REPIVA	(Ne devrait pas arriver)
	C=C+A  A
	DAT0=C A
	GONC   REP500
 REPIVA GOVLNG =ARGERR



*
*
* Boucle principale
*   Remplace O$ ds S$ par R$=R1$&R2$
*
*


 REP500 D0=(5) =FUNCR0
	A=DAT0 A
	B=A    A	       B(A)= debut du motif (O$)
	D0=(2) (=FUNCR0)+20
	A=DAT0 A
	R3=A	       R3= fin de la cible (S$)
	D0=D0+ 10
	C=DAT0 A
	D=C    A	       D(A)= debut de la cible
	?C>=A  A	       Remplacement termine?
	GOYES  REP540	Oui

	?ST=1  Anchor
	GOYES  REP540
 
	D0=(2) (=FUNCR0)+5
	A=DAT0 A
	D1=A	       D1 @ memoire libre
	D0=(5) =AVMEMS
	A=DAT0 A
	R2=A	       R2 = fin du motif
	GOSUB  SCAN	Recherche du motif
	GONC   REP550	Trouve
 REP540 GOSBVL =OBCOLL
	D=C    A	       D(A)=AVMEMS
	D0=(5) (=FUNCR0)+20
	C=DAT0 A
	R1=C	       R1 @ fin de S$
	D0=D0- 15
	C=DAT0 A
	D1=C	       D1 @ debut de S$
	ST=1   0	       Revient ici apres ADHEAD
	GOSBVL =ADHEAD	Ajoute un en-tete a S$
	GOSBVL =REV$	L'inverse
	D0=(5) =FUNCD1
	A=DAT0 A
	D0=A	       Remets D0 en place
	GOVLNG =EXPR	Retourne S$


 REP550 ?ST=1  Ins	Si l'on insere, il ne faut
	GOYES  REP600	pas detruire le motif
	C=D    A
	B=C    A
	D0=(5) (=FUNCR0)+5
	A=DAT0 A
	B=B-A  A
	C=R1
	C=C-D  A
	A=A+C  A
	DAT0=A A	       Actualise le pt actif
	C=D    A
	A=R1
	ACEX   A
	D=C    A
	ACEX   A
	GOSBVL =MOVEDM	Ecrase le motif

 REP600 D0=(5) =OUTBS
	A=DAT0 A
	D0=(5) (=FUNCR0)+25
	C=DAT0 A
	GOSUB  RPEDIT	Insere R1$
	C=R1
	D=C    A
	D0=(5) (=FUNCR0)+30
	DAT0=C A
	D0=D0- 5
	A=DAT0 A
	D0=(5) =FUNCR0
	C=DAT0 A
	GOSUB  RPEDIT	Insere R2$
	GOTO   REP500	Boucle



*
* Insere une chaine ds une autre
*  A(A)=Debut du texte a inserer
*  C(A)=Fin du texte a inserer
*  D(A)=Position de l'insertion
*

 RPEDIT R2=A		Sauvegarde A et C
	R3=C
	C=C-A  A	       Longueur de l'insertion
 Memckl B=C    A
	C=B    A
	A=C    A
	C=0    A
	LC(2)  =LEEWAY
	C=A+C  A
	GOC    Memerr
	D1=(5) (=FUNCR0)+5
	A=DAT1 A
	GOSBVL =CHKmem
	GONC   RPE10
 Memerr GOTO   memerr

 RPE10	C=B    A	Recupere la longueur
	D0=(5) (=FUNCR0)+5
	A=DAT0 A	       B(A) @ debut de la chaine
	B=A    A	       ou a lieu l'insertion
	A=A-C  A	       Actualise sa nvelle pst
	DAT0=A A
	C=B    A
	C=C-D  A
	C=-C   A
	BCEX   A
	GOSBVL =MOVEUM	Fait de la place
	AD0EX
	CD1EX
	B=A    A
	B=B-C  A
	C=R3
	GOSBVL =MOVEDM	Puis insere la chaine
	RTN




*
*
* Routine HP
* Ecrite (sans doute) par SW ou FH
* Consulter les IDS Vol. 1
*
*

 SCAN	ST=0   Anchor
	ST=0   RegExp
	GOSUB  PATCHR
	LCASC  '\'
	?C#A   B
	GOYES  L190j
 L125.1 D0=D0+ 2
	A=DAT0 B
	LCASC  '$'
	?C#A   B
	GOYES  L140
	D0=D0+ 2
	AD0EX
	C=R2
	?C#A   B
	GOYES  L140
	C=R3
	?ST=0  Anchor
	GOYES  L125.2
	?D#C   A
	RTNYES
 L125.2 D=C    A
 MATCH+ R1=C
	RTNCC

 L130	GOSUB  PATCH+
	LCASC  '\'
 L190j	?C#A   B
	GOYES  L190
 L140	A=B    A
	D0=A
	D0=D0+ 2
	A=DAT0 B
	LCASC  '\'
	?C=A   B
	GOYES  L240j
 L150	B=B+1  A
	B=B+1  A
 L160	GOSUB  RETOGL
 L170	?ST=0  RegExp
	GOYES  L190.2
	?ST=1  Anchor
	GOYES  L190
	GOSUB  PATCHR
	LCASC  '^'
	?C#A   B
	GOYES  L190.1
	?ST=1  First
	RTNYES
	ST=1   Anchor
	B=B+1  A
	B=B+1  A
	GONC   L125.1	(B.E.T.)

 L190	?ST=0  RegExp
	GOYES  L190.2
	GOSUB  PATCHR
 L190.1 LCASC  '.'
	?C=A   B
	GOYES  L240
	LCASC  '$'
	?C=A   B
	GOYES  L240
	LCASC  '@'
 L240j	?C=A   B
	GOYES  L240
 L190.2 GOSUB  PATCHR
	LCASC  '\'
	?C=A   B
	GOYES  L240
 L200	C=R2
	?B<C   A
	GOYES  L210
	C=D    A
	GOTO   MATCH+

 L210	C=R3
	?D>=C  A
	RTNYES
	C=D    A
	D0=C
	C=DAT0 B
	?C=A   B
	GOYES  L240
	?ST=1  Anchor
	RTNYES
	D=D+1  A
	D=D+1  A
	GOTO   L210

 L240	ST=1   TopLvl
	GOSUB  SCANSB
	GOC    RTNCC
	?ST=1  Anchor
	RTNYES
	D=D+1  A
	D=D+1  A
	C=R3
	?D>=C  A
	RTNYES
	GONC   L190	(B.E.T.)
 RTNCC	RTNCC


 memerr GOVLNG =MEMERR
 SCANSB CD1EX
	D1=C
	A=R0
	?C<A   A
	GOYES  memerr
	D1=D1- 5
	C=R1
	DAT1=C A
	D1=D1- 5
	C=B    A
	DAT1=C A
	D1=D1- 5
	C=D    A
	DAT1=C A
	?ST=1  TopLvl
	GOYES  SCNSB1
	C=R1
	D=C    A
	D=D-1  A
	D=D-1  A
 SCNSB1 ST=0   TopLvl
	D1=D1- 5
	C=RSTK
	DAT1=C A
	D1=D1- 1
	C=ST
	DAT1=C P
 L340	C=R3
	R1=C
 L350
 L360	C=R2
	?B<C   A
	GOYES  L370
	C=D    A
	R1=C
	GOTO   L640

 PATCH+ B=B+1  A
	B=B+1  A
 PATCHR A=B    A
	D0=A
	A=DAT0 B
	RTNCC

 RETOGL ?ST=1  RegExp
	GOYES  RETOG0
	ST=1   RegExp
	RTN
 RETOG0 ST=0   RegExp
	RTNCC


 L370	GOSUB  PATCHR
	LCASC  '\'
	?C#A   B
	GOYES  L405
 L380	GOSUB  PATCH+
 L390	C=R2
	?B<C   A
	GOYES  L400
	D=D-1  A
	D=D-1  A
	GOTO   EXIT

 L400	LCASC  '\'
	?C=A   B
	GOYES  L405
	GOSUB  RETOGL
 L405	?ST=0  RegExp
	GOYES  L440
 L410	LCASC  '.'
	?C#A   B
	GOYES  L420
 L475	C=R1
	?D<C   A
	GOYES  L450
	GOTO   L500

 L420	LCASC  '@'
	?C#A   B
	GOYES  L430
	GOTO   L550.1
 L430	LCASC  '$'
	?C#A   B
	GOYES  L440
	C=R1
	?D<C   A
	GOYES  L500
	GOTO   EXIT

 L440	C=D    A
	D0=C
	C=DAT0 B
	?C=A   B
	GOYES  L450
 L500	ST=0   Match
	GOTO   SCNRTN

 L450	B=B+1  A
	B=B+1  A
	C=R2
	?B<C   A
	GOYES  L460
 EXIT	C=D    A
	C=C+1  A
	C=C+1  A
	R1=C
 L640	ST=1   Match
	GOTO   SCNRTN

 L460	D=D+1  A
	D=D+1  A
	C=R1
	?D>=C  A
	GOYES  L480
	GOTO   L350

 L480	GOSUB  PATCHR
	B=B+1  A
	B=B+1  A
	?ST=0  RegExp
	GOYES  L490NR
	LCASC  '@'
	?C#A   B
	GOYES  L480.2
	C=R2
	?B>=C  A
	GOYES  L640
	GONC   L480	(B.E.T.)

 L480.2 LCASC  '$'
	?C#A   B
	GOYES  L500
	C=R2
	?B>=C  A
	GOYES  L640
	GONC   L500	(B.E.T.)

 L490NR LCASC  '\'
	?C#A   B
	GOYES  L500
	ST=1   RegExp
	GONC   L480	(B.E.T.)

 L520	D=D+1  A
	D=D+1  A
	C=R1
	?D>=C  A
	GOYES  L500j
 L550.1 B=B+1  A
	B=B+1  A
 L530	C=R2
	?B>=C  A
	GOYES  L640
 L540	?ST=0  RegExp
	GOYES  L580
 L550	GOSUB  PATCHR
	LCASC  '@'
	?C#A   B
	GOYES  L560
	GONC   L550.1	(B.E.T.)

 L560	LCASC  '.'
	?C=A   B
	GOYES  L520
 L570	LCASC  '$'
	?C#A   B
	GOYES  L580.1
	C=R2
	C=C-1  A
	C=C-1  A
	?B<C   A
	GOYES  L580.1
	GOTO   L640

 L580	GOSUB  PATCHR
 L580.1 LCASC  '\'
	?C=A   B
	GOYES  L610
 L590	C=R1
	D0=C
	D0=D0- 2
	C=DAT0 B
	?C=A   B
	GOYES  L610
 L600	C=R1
	C=C-1  A
	C=C-1  A
	R1=C
	?D<C   A
	GOYES  L580
 L500j	GOTO   L500

 L610
 L620	GOSUB  SCANSB
	GONC   L600
	GOTO   L640


 SCNRTN C=ST
	C=DAT1 P
	ST=C
	D1=D1+ 1
	C=DAT1 A
	RSTK=C
	D1=D1+ 5
	C=DAT1 A
	D=C    A
	D1=D1+ 5
	C=DAT1 A
	B=C    A
	D1=D1+ 5
	C=DAT1 A
	D1=D1+ 5
	?ST=1  Match
	RTNYES
	R1=C
	RTNCC

	END
