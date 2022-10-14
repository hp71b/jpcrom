	TITLE  POSILEX <posi.as>

*
* Premiere version :
*   Jean-Pierre Bondu
*   Parue dans JPC 37
*   Creation du Lex
*   Les deux parametres sont numeriques
*   Integration dans JPCLEX le 86/10/26 a 12:41
* Deuxieme version :
*   Pierre David & Janick Taillandier
*   87/01/05
*   Nouveaux parametres numeriques ou alphanumeriques
*   Reecriture du debut et de POPARG
*   Reagencement de POPARG (plus au milieu du Lex)
* JPC:C02
*   88/02/12: PD/JJD/JT POSI("",0..5) renvoyait 1
*
	CON(1) 8+4	Numerique ou alphanumerique
	CON(1) 8+4	Numerique ou alphanumerique
	CON(1) 4	Alphanumerique
	NIBHEX 23	2 ou 3 arguments
=POSIe
	A=0    A
	A=A-1  B	A(A) = 255 par defaut
	P=C    15	C[S]= nombre d'arguments
	?P=    2	2 arguments?
	GOYES  PRM2	oui
*
* Il y a trois arguments
*
	GOSUB  POPARG
*
* Il y a deux arguments
*
 PRM2	R0=A
	GOSUB  POPARG	A[A]= 2eme argument
	C=R0		C[A]= 1er    "
	?A>C   B
	GOYES  FD1
*
* Echange les valeurs
*
	ACEX   B

 FD1	ASL    A	en entree :
	 *		A[B]=MAX(A,C) ; C[B]=MIN
	ASL    A	A[3-2]= borne sup
	A=C    B	A[B]  = borne inf
	B=A    A	B[3-0]= intervalle
	GOSBVL =POP1S	A[A]= long, D1 @ dernier
	 *		caractere
*
* Bug fix du 88/02/12 (22.44)
*   PD/JJD/JT
*   La boucle ci-dessous est effectuee au moins
*   une fois, meme si la longueur est nulle.
*
*   POSI("",0..5) renvoyait 1 et pas 0
*
	?A=0   A
	GOYES  EXIT
*
* Fin de la correction
*
	D1=D1- 2
	CD1EX
	D1=C
	C=C+A  A	C[A] @ 1er caractere
	GOSBVL =CSLC5
	CD1EX		C[A] @ dernier caractere
	D=C    W	D[9-0]= nb de controle :
	 *		adr sup [9-5], adr inf
	 *		[4-0]
	C=C+A  A	on commence la recherche
	 *		a partir du 1er caractere
	 *		(adr sup)
	CD1EX		D1= pointeur de chaine
	 *		(adr sup en entree)

 SEARCH A=DAT1 B	A[B]= octet de la chaine
	C=B    A	C[A]= intervalle de
	 *		recherche
	GOSBVL =RANGE	caractere dans
	 *		l'intervalle ?
	GONC   FOUND	oui
	D1=D1- 2	octet suivant
	CD1EX
	D1=C
	?C>D   A	pointeur > adr inf ?
	GOYES  SEARCH	oui: on continue la
	 *		recherche
	A=0    A	pas trouve: on retourne 0
	C=D    W
	GOSBVL =CSRC5
	D1=C		D1= adr inf= adr de base
	 *		de la Math Stack
	GONC   ENDFCT	fin (B.E.T. je pense)

 FOUND	A=0    W	trouve: on va calculer la
	 *		position du pointeur dans
	 *		la chaine
	AD1EX		A[A]= pointeur
	C=D    W
	GOSBVL =CSRC5	C[A]= adr du 1er caractere
	D1=C
	A=A-C  A
	A=-A   A	A[A]= adr sup - pointeur
	ASRB		A[A]= A[A]/2   (nb
	 *		quartets -> nb octets)
	A=A+1  A	position [0...] ->
	 *		position [1...]

*
* A(A) = resultat en hexa
*
 EXIT
 ENDFCT GOSBVL =HDFLT	position : A[A] hex ->
	 *		decimal flottant en A[W]
	C=A    W
	D1=D1+ 2
	GOVLNG =FNRTN1	renvoie C[W] au BASIC

**************************************************
* POPARG
*
* But: depiler quelque chose sur la M.S. (alpha ou
*   num) et renvoyer la valeur dans A(B)
* Entree:
*   - D1 = ^ M.S.
* Sortie:
*   - A(B) = valeur lue
* Appelle:
* Niveaux: 
* Utilise: 
* Note: Si une chaine est depilee, seul le premier
*   caractere est pris en compte.
* Historique:
*   86/11/  : JPB conception & codage
*   87/01/05: PD & JT reconception, recodage & doc
**************************************************

 POPARG
*
* Test si numerique ou alphanumerique
*
	A=DAT1 S	A(S) := signature
	A=A+1  S
	GOC    popstr
*
* C'est un nombre
*
 popnum
	GOSBVL =RNDAHX	A[A]= nombre hexa
	GONC   ivaerr	erreur si negatif
	D1=D1+ 16	pointe l'argument suivant
	 *		de la Math Stack
	C=0    A
	C=A    B
	?C=A   A	A(4-2) = 0 ?
	RTNYES		oui. Ok.
 ivaerr GOVLNG =IVAERR	non
*
* C'est une chaine
*
 popstr
	GOSBVL =POP1S
	CD1EX
	C=C+A  A
	D1=C
	?A=0   A
	RTNYES		chaine nulle : A(B) = 0
*
* Chaine non nulle : on prend le premier caractere
*
	D1=D1- 2
	A=DAT1 B	A(B) = 1er caractere
	D1=D1+ 2
	RTN

	END
