	TITLE  DESAL <desal.as>
*
* JPC:A05
*   87/02/22: (PD) ajout d'un paramètre à ATH$ et HTA$
*

*
* numéro du flag utilisé pour le deuxième paramètre
*   1 : dans l'ordre normal
*   0 : inverse (pour utiliser avec PEEK$)
*   défaut = 0
*
 flag	EQU    0

************************************************************
* HTA$
************************************************************

	NIBHEX 8	2eme paramètre numérique
	NIBHEX 4	1er paramètre alphanumérique
	NIBHEX 12
=HTAe
*
* modification du 87/02/22
*
	GOSUB  PARM?
*
* fin de la modification
*
	GOSBVL =POP1S
*
* A(A) = longueur de la chaîne en quartets
* D1 = ^ M.S.
*
	C=0    W
	C=A    A	C(A) = longueur en quartets
	SB=0
	CSRB
	CSRB		C(A) := long. en octets / 2
	?SB=0
	GOYES  HTA05
	GONC   Argerr	B.E.T.

 HTA05
	D=C    A	D(A3 := nb de boucles

	CD0EX		Sauvegarde du compteur
	 *		programme (PC)
	RSTK=C		dans RSTK
	CD1EX		Addition de la longueur de
	C=C+A  A	la chaîne à D1
	D0=C		et on place D0 et 
	D1=C		D1 sur la fin de la chaîne

	C=D    A
	C=C+C  A	Multiplication par 2 pour
	CSL    W	reconstitution de l'entete
	CSL    W	de la nouvelle
	LC(1)  15	chaîne 
	R1=C		et sauvegarde dans le
	 *		registre R1

 Boucle D=D-1  A	On commence la boucle par
	 *		decrementer D 
	GOC    HTAFIN	S'il ne reste plus de
	 *		caracteres on branche en
	 *		HTAFIN.
	D0=D0- 4	Autrement on decremente D0
	 *		de 4 pour
	A=DAT0 4	lire la valeur HEXA
*
* modification du 87/02/22
*
	?ST=0  flag
	GOYES  HTA30
	GOSBVL =SWPBYT
 HTA30
*
* fin de la modification
*
	P=     1	P= #-1 chr à convertir
	GOSUB  CONVAH	Voir encart
	D1=D1- 2	On decremente D1 pour
	DAT1=A B	placer le caractere ASCII
	GONC   Boucle	Branchement inconditionnel

 HTAFIN C=RSTK		Fin: restitution du
	D0=C		compteur programme
	 *		sauvegarde dans RSTK plus
	 *		haut
	D1=D1- 16	Decrementation de D1 pour
	 *		placer
	C=R1		l'entete de la nouvelle
	 *		chaîne sur la Math Stack et
	GOVLNG =FNRTN4	Retour à BASIC

 Argerr GOVLNG =ARGERR

**************************************************
* CONVAH : CONvertit de l'Ascii en Hexa
*
* Objet: convertir une expression ASCII en HEXA
*
* Entrée: 
*    P= Nb. de CHR. à convertir moins 1 (de 0 à 7)
*    HEX
*    A: valeurs HEXA correspondant au CHR. ASCII
*	Ex:    313445  <-
*			 |
*	     -> E 4 1	 |   avec P= 2 en entrée.
*	    |		 |
* Sortie:    ------------
*    P=0
*    HEX
*    Carry=0
*    A(W) = B(W) = valeur HEXA
*
* Utilise: A(W), B(W), C(S), C(A), P
*
* Niveaux de pile des retours: 2
**************************************************

 CONVAH C=P    15	Sauvegarde du nombre de
	 *		caracteres dans C(S)
	P=     0
 BCL1	GOSBVL =DRANGE	A(B) ? compris entre 30 et
	 *		39
	GONC   CVH10	Si oui: CVH10
	GOSBVL =CONVUC	Convertit A(B) en
	 *		majuscule
	LCASC  'FA'	Bornes test pour l'appel
	 *		de RANGE
	GOSBVL =RANGE	Verifie si A(B) est entre
	 *		A et F
	GOC    Argerr	Si non: ERREUR
	LC(1)  9	On aditionne 9 au quartet
	 *		de poids
	A=A+C  P	faible de A(B)
 CVH10	BSL    W	Sauvegarde
	B=A    P	dans B(0)
	ASR    W	On passe
	ASR    W	au caractere suivant
	C=C-1  S	C(S) = compteur
	GONC   BCL1	B.E.T.
	A=B    W	A = B pour la sortie de
	 *		routine 
	RTNCC		Retour avec Carry = 0

************************************************************
* ADBUF$
************************************************************

	NIBHEX 411	La fonction n'admet qu'un
	 *		seul paramètre alphanumérique
=ADBUFe GOSBVL =REVPOP	Teste le paramètre de la
	 *		fonction et renvoie la
	 *		longueur
	 *		de la chaîne alpha en
	 *		quartets dans A(A). La
	 *		chaîne est 
	 *		renversée sur la Math
	 *		Stack.
	C=0    A	) On charge 6
	LC(1)  6	) dans C(A) pour
	 *		) tester si la longueur de
	?A#C   A	la chaîne est bonne.
	GOYES  Argerr	Si elle est mauvaise:
	 *		ERREUR.
	A=DAT1 6	On charge la longueur de
	 *		la chaîne dans A(5-0)
	D1=D1+ 6	D1 ^ maintenant la fin de
	 *		la chaîne. 
	CD1EX		Sauvegarde de D1
	RSTK=C		dans RSTK.
	P=     2	P= nombre de caracteres de
	 *		A(W) à convertir en HEXA.
	GOSUB  CONVAH	Conversion !
	C=A    A	C(X) = valeur HEXA de la
	 *		chaîne introduite.
	GOSBVL =IOFND0	Recherche du Buffer.
	GONC   FIN	Si Carry=0 : le buffer
	 *		n'existe pas: FIN
	D1=D1- 7	On reajuste l'adresse pour
	 *		pointer le debut du buffer.
	AD1EX		On charge l'adresse du
	 *		buffer dans A(A)
	P=     4	Preparation (comme pour
	 *		CONVAH) pour l'appel de
	 *		HEXASC.
	C=0    S	) La routine HEXASC
	 *		) demande que le nombre
	CPEX   15	) de quartets à convertir
	 *		) soit dans C(S).
	 *		) (de 0 à 7)
	GOSBVL =HEXASC	Convertion de l'adresse en
	 *		ASCII.

 FIN	C=RSTK		) Restitution
	D1=C		) de D1.
	GONC   Adh	Si l'on vient de "GONC	
	 *		FIN" on branche en Adh.
	D1=D1- 10	Autrement on place le
	 *		paramètre de retour sur 
	DAT1=A 10	la Math Stack.
 Adh	R1=C		Indispensable avant
	 *		l'appel de la routine
	 *		ADHEAD.
	ST=1   0	On veut un retour apres
	 *		l'appel de ADHEAD.
	GOSBVL =D=AVMS	D(A) = AVMEMS
	GOSBVL =ADHEAD	Construction de l'en-tete
	 *		de la nouvelle chaîne.
	GOSBVL =REV$	On renberse le tout
	GOVLNG =EXPR	et retour à BASIC.

************************************************************
* ASC$
************************************************************

	NIBHEX 411	Un paramètre alpha.
=ASCe
	CD1EX		)
	D1=C		) Sauvegarde de D1
	RSTK=C		) dans RSTK. (opcode=1oct)
	GOSBVL =POP1S
	B=0    M	) Division de la longueur
	B=A    A	) de la chaîne par
	BSRB		) 2. B=compteur de CHR.
	LCASC  '.'
	ST=C		ST(B)='.'
	LCASC  '~ '
	D=C    A	D(3-0)='~ '

 BOUCLE B=B-1  A	Reste-t-il des CHR ?
	GOC    SORTIE	Si non: SORTIE.
	A=DAT1 B	A(B)=CHR à tester.
	C=D    A	C(3-0)='~ '
	GOSBVL =RANGE	31<CHR<127 ?
	GONC   pD1	Si oui: B.E.T.
	C=ST		Autrement C(B)='.'
	DAT1=C B	Le CHR devient '.'
 pD1	D1=D1+ 2	Ajuste Carry.
	GONC   BOUCLE	B.E.T.

 SORTIE C=RSTK		Restitution de 
	D1=C		D1.
	GOVLNG =EXPR	et retour à BASIC.

************************************************************
* PARM?
*
* But: tester la presence du deuxieme paramètre dans ATH$ et
*   HTA$, et positionner le flag ST(flag) en consequence.
* Entrée:
*   - C(S) = nb de paramètres
*   - D1 = ^ M.S.
* Sortie:
*   - ST(flag) = 0 : paramètre = 0 ou pas de paramètre
*   - ST(flag) = 1 : paramètre # 0
*   - D1 reactualise si necessaire
* Abime: A(W), B(X), C(S)
* Appelle: POP1R
* Niveaux: 2
* Historique:
*   87/02/22: P.D. conception & codage
************************************************************

 PARM?
	ST=0   flag	flag = 0 par defaut
	C=C-1  S
	C=C-1  S
	RTNC		un seul paramètre
	GOSBVL =POP1R	A(W) := 12 digits form
	SETHEX
	D1=D1+ 16	D1 := ^ premier paramètre
	?A=0   W
	RTNYES
	ST=1   flag
	RTN

************************************************************
* ATH$
************************************************************

	NIBHEX 8	2eme paramètre numérique
	NIBHEX 4	1er paramètre alphanumérique
	NIBHEX 12	min = 1; max = 2
=ATHe
*
* modification du 87/02/22
*
	GOSUB  PARM?
*
* fin de la modification
*
	GOSBVL =POP1S
	CD0EX		Sauvegarde de la valeur de
	RSTK=C		D0 dans RSTK pour rendre
	 *		le pointeur D0 disponible
	CD1EX		On place
	D1=C		le pointeur D0 à la
	D0=C		valeur de D1
	GOSBVL =D=AVMS	D(A) = AVMEMS
	D1=D1- 16	D1 pointe maintenant le
	 *		debut du paramètre de ATH$
	CD1EX		Calcul de la longueur
	C=C-A  A	de la future chaîne
	 *		comparaison avec AVMEMS
	?C<D   A	pour savoir s'il y a
	GOYES  Memerr	suffisamment de place en
	 *		mémoire. Si non: "In.
	 *		Memory"
	D1=C		D1 ^ maintenant le futur
	 *		paramètre
	RSTK=C		Sauvegarde dans RSTK
	C=A    A	Multiplication de la
	 *		longueur
	C=C+C  A	de la chaîne par 2 (N+N)
	CSL    W	et construction de
	 *		l'en-tête
	CSL    W	de la
	LC(1)  15	future chaîne
	DAT1=C W	et mise en place sur la
	 *		Math Stack
	D1=D1+ 16	D1 pointe maintenant la
	 *		fin de la future chaîne
	C=0    W	Mise à 0 pour permettre
	 *		des décalages et des
	 *		opérations
	 *		dans C(S)
	C=A    A	Division de la longueur de
	 *		la chaîne par 2
	CSRB		pour initialiser le 
	D=C    A	compteur de boucle D(A)
	C=C-1  S	C(S)= 15

 ATH10	D=D-1  A	Reste-t-il encore des
	 *		caractères à tester ?
	GOC    Fin	Non: branchement au label
	 *		"Fin"
	A=DAT0 B	A(B) = caractère ASCII à
	 *		transformer en HEXA
	C=-C   S	Au retour de la routine
	 *		HEXASC C(S) = 15 . A
	 *		l'appel de 
	GOSBVL =HEXASC	cette routine C(S) = Nb.
	 *		de quartets à transformer:
	 *		#-1
*
* modification du 87/02/22
*
	?ST=0  flag
	GOYES  ATH20
	GOSBVL =SWPBYT
 ATH20
*
* fin de la modification
*
	DAT1=A 4	On place le résultat de la
	 *		transformation sur la M.S.
	D0=D0+ 2	Incrémentation des 
	D1=D1+ 4	compteurs D0 et D1
	GONC   ATH10	Branchement inconditionnel
	 *		(B.E.T.)

 Memerr GOVLNG =MEMERR

 Fin	C=RSTK		Restitution
	D1=C		des compteurs
	C=RSTK		D0 et
	D0=C		D1
	GOVLNG =EXPR	et retour à BASIC.

************************************************************
* RED$
************************************************************

	NIBHEX 411
=REDe	GOSUB  CNTBL	Suppression des blancs en
	 *		début de chaîne.
	GOSUB  ENTETE	Construction de l'en-tête
	 *		de la chaîne avant inversion.
	GOSUB  CNTBL	Suppression des blancs en
	 *		fin de chaîne.
	GOC    FiN	On branche en: FiN

 CNTBL	GOSBVL =REVPOP	"Pop" et renverse la chaîne.
	B=0    M	) Division de la longueur
	 *		) de la chaîne
	B=A    A	) par 2 pour avoir un
	 *		) compteur de
	BSRB		) caractères dans B(A).
	LCASC  ' '	On charge le CHR$(32) dans
	 *		C(B).
 BLCOUT B=B-1  A	Reste-t-il encore des
	 *		caractères dans la chaîne ?
	GOC    CHNULL	Si non: on branche en
	 *		chaîne nulle !
	A=DAT1 B	) Le caractère suivant
	 *		) est-il
	?A#C   B	) différent de CHR$(32) ?
	RTNYES		Si oui: fin de routine.
	D1=D1+ 2	Autrement on incrémente D1
	 *		pour pointer de CHR$
	 *		suivant.
	GONC   BLCOUT	B.E.T.

 ENTETE A=B    A	Longueur de la	   ) En
	 *		chaîne restante -1 )octets
	A=A+1  A	long. de la chaîne ) "
	A=A+A  A	Longueur de la chaîne en
	 *		quartets.
	ASL    W	A = .....lllll0 ) avec
	 *				) lllll =
	ASL    W	A = ....lllll00 ) longueur
	 *				) de la
	A=A-1  P	A = ....lllll0F ) chaîne.
	D1=D1- 16	Decrémentation de D1 pour
	DAT1=A W	placer l'en-tête de la
	 *		nouvelle chaîne
	RTN		Retour 

 CHNULL C=RSTK		Suppresssion d'un niveau
	 *		de sous-programme si l'on
	 *		vient de CNTBL.
 FiN	GOSUB  ENTETE	Construction de l'en-tête
	 *		de la nouvelle chaîne.
	GOVLNG =EXPR	Retour à BASIC.

	END
