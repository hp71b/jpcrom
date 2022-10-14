	TITLE  DESLEX <des.as>

*
* JPC:A00
*   86/08/15: PD/JT Intégration ds JPCLEX de la version JJM
* JPC:B03
*   87/12/06: PD/JT Réécriture de PAINT et INVERSE
*   87/12/06: PD/JT Retrait de INV$
*

*
* Attention ! Les zones de l'écran sont regroupées en 3
* parties. De gauche à droite :
*
*	DD3	DD2	DD1
*

*
* Nombre de colonnes dans chaque partie du Display Chip
*
 N1	EQU    ((=DD1END)-(=DD1ST)+1)/2
 N2	EQU    ((=DD2END)-(=DD2ST)+1)/2
 N3	EQU    ((=DD3END)-(=DD3ST)+1)/2

 sMODIF EQU    0	Flag utilisé dans PAINT

	STITLE	INVERSE

************************************************************
* INVERSE
*
* But : inverser tout ou partie de l'affichage
* Syntaxe :
*   - INVERSE
*	inverse la totalité de l'affichage
*   - INVERSE <x1> , <x2>
*	inverse la partie de l'affichage comprise
*	entre les abscisses x1 et x2
*	(0<=x1<=x2<=131)
* Historique :
*   85/04/.. : JJM     conception & codage
*   87/12/06 : PD & JT reconception & recodage
************************************************************

	REL(5) =INVERSEd
	REL(5) =INVERSEp
=INVERSEe
	A=DAT0 B	A(B) := token suivant
	GOSBVL =EOLXCK	Fin de ligne ?
*
* Paramètres par défaut :
* A(A) := debut
* C(A) := fin
*
	A=0    A	Debut := 0
	C=0    A
	LC(2)  131	Fin := 131
	GOC    nopar	il n'y a pas de paramètres
*
* Evaluation des paramètres
*
	GOSBVL =EXPEXC	Evaluation sur la M.S.
	C=0    A
	LC(2)  131
	GOSUB  eval
	R1=A		R1 := fin
	C=0    A
	LC(2)  131
	GOSUB  eval	A(A) := début
	C=R1		C(A) := fin
*
* A(A) = début
* C(A) = fin
*
 nopar	?C<A   A	fin < debut ?
	GOYES  argerr	beeeeeeep

*
* Calculer le nombre de colonnes à inverser :
*
	C=C-A  A	C(A) := nb de colonnes
	D=C    A	D(A) := nb de colonnes
*
* Calculer l'adresse de la colonne de début
*
	GOSUB  colonne	D0 := ^ colonne de début

*
* for i := D downto 0 do
*   begin
*     inverser colonne D0 (2 quartets)
*     case D0 in
*	DD3END : D0 := DD2ST ;
*	DD2END : D0 := DD1ST ;
*	else : D0 += 2 ;
*     esac
*   end
*   

 inv010 A=DAT0 B
	A=-A-1 B	Inversion bit a bit
	DAT0=A B

	AD0EX
	LC(5)  (=DD3END)-2
	?A=C   A
	GOYES  inv020
	LC(5)  (=DD2END)-2
	?A=C   A
	GOYES  inv030
* cas autre
	D0=A
	D0=D0+ 2
	GONC   inv040

 inv020 D0=(5) =DD2ST
	GOC    inv040	B.E.T.

 inv030 D0=(5) =DD1ST

 inv040 D=D-1  A
	GONC   inv010	Boucle tant que D>0

	GOVLNG =NXTSTM	Une belle histoire se termine...

************************************************************
* eval
*
* But : évalue le paramètre au sommet de la M.S. et vérifie
*   qu'il est bien dans l'intervalle autorisé.
* Entrée :
*   - D1 = ^ M.S.
*   - C(A) = valeur limite à comparer (131 ou 7)
* Sortie :
*   - A(A) = valeur (0..131)
*   - D1 réactualisé
* Abime : A, B(S), B(A), C(A), D(A), R0
* Niveaux : 4
* Appelle : RNDAHX
* Historique :
*   87/12/06: PD & JT conception et codage
************************************************************

 eval	R0=C
	GOSBVL =RNDAHX	A(A) := nombre en hexa
	GONC   argerr	Négatif
	D1=D1+ 16	Actualise la M.S.
	C=R0
	?A<=C  A
	RTNYES
 argerr GOVLNG =ARGERR

************************************************************
* colonne
*
* But : calculer l'adresse de la colonne correspondant à X
*   donné.
* Entrée :
*   - A(A) = X (entre 0 et 131)
* Sortie :
*   - D0 = adresse de la colonne
* Abime : A(A), C(A), D0
* Niveaux : 0
* Historique :
*   87/12/06: PD & JT conception & codage
************************************************************

 colonne
	C=0    A
	LC(2)  (N3)
	?A<C   A	Dans DD3
	GOYES  col3
	LC(2)  (N3)+(N2)
	?A<C   A	Dans DD2
	GOYES  col2
 col1	LC(2)  (N3)+(N2)
	A=A-C  A	Nb de colonnes depuis DD3ST
	LC(5)  =DD1ST
	GONC   col9	B.E.T.
 col2	LC(2)  (N3)
	A=A-C  A
	LC(5)  =DD2ST
	GONC   col9	B.E.T.
 col3	LC(5)  =DD3ST
 col9	A=A+A  A	nb de colonnes * 2
	A=A+C  A	A(A) := adresse de début
	D0=A
	RTN

	STITLE	PAINT

************************************************************
* PAINT
*
* But : tester ou forcer la valeur d'un point
* Syntaxe :
*   - PAINT ( <etat> , <x> , <y> )
*	force la valeur du point (x,y) à état.
*	renvoie l'ancienne valeur du point.
*   - PAINT ( <x> , <y> )
*	renvoie la valeur du point (x,y).
* Historique :
*   85/04/.. : JJM     conception & codage
*   87/12/06 : PD & JT reconception & recodage
************************************************************

	NIBHEX 88823
=PAINTe
*
* Sauver D0 d'abord !
*
	CD0EX
	RSTK=C
*
* Y a-t-il trois ou deux paramètres ?
*
	ST=0   sMODIF	Pas de modif. par défaut (2 param)
	P=C    15	P = nb de paramètres (2 ou 3)
	?P=    2	Pas de modification
	GOYES  pain10
	ST=1   sMODIF	Modifier l'état du point
*
* Lecture de y, puis de x, et éventuellement de l'état
*
 pain10 P=     0
	C=0    A
	LC(2)  7
	GOSUB  eval
	R2=A		R2 := y (0..7)
	C=0    A
	LC(2)  131
	GOSUB  eval
	R1=A		R1 := x (0..131)
*
* Premier paramètre présent ?
*
	?ST=0  sMODIF
	GOYES  pain20	Non.
	GOSBVL =RNDAHX	A(A) := nouvelle valeur du point
	D1=D1+ 16
	R0=A		R0 := nouvelle valeur du point
*
* R0 = nouvelle valeur
* R1 = x
* R2 = y
*
 pain20
*
* calculer le masque (la position du bit) en fonction de y
*
	A=R2		A(A) := y
	LC(2)  1	A vos marques ! Prêts ?
	GOTO   pain40	Partez !
 pain30 C=C+C  B
 pain40 A=A-1  A
	GONC   pain30
	R2=C		R2(B) := masque binaire
*
* calculer l'adresse de depart
*
	A=R1		A(A) := x
	GOSUB  colonne	D0 := ^ octet où il y a le point
	A=DAT0 B
	R3=A		R3(B) := ancienne valeur
*
* R0 = nouvelle valeur
* R1 = x
* R2 = masque
* R3 = ancienne valeur
*

*
* Modification nécessaire ?
*
	?ST=0  sMODIF
	GOYES  pain70	Non. Il faut simplement récupérer R3
	C=R0		C=0 ou #0 (nouvelle valeur)
	?C=0   A	Mettre à 0 ?
	GOYES  pain50	oui
*
* Mettre à 1 : v := v OU masque
*
	C=R2
	A=A!C  B	A(B) := v OU masque
	GOTO   pain60
*
* Mettre à 0 : v := v AND NOT masque
*
 pain50
	C=R2		C(B) := masque
	C=-C-1 B	NOT masque
	A=A&C  B	A(B) := v AND NOT masque
 pain60 DAT0=A B	Modification réalisée

*
* Renvoyer l'ancienne valeur
*
 pain70 A=R3		A(B) := ancienne valeur
	C=R2		C(B) := masque
	A=A&C  B	A(B) := 0 ou #0
	C=0    W
	?A=0   B
	GOYES  pain80
*
* Charger un 1
*
	P=     14
	LC(1)  1
	P=     0
 pain80
	A=C    W	Sauvegarder C(W) dans A(W)
	C=RSTK
	D0=C		Restaurer D0 (PC)
	C=A    W

	GOVLNG =FNRTN1

	STITLE	CONTRAST

************************************************************
* CONTRAST
*
* But : renvoie la valeur du contraste
* Syntaxe :
*   - CONSTRAST
*	renvoie la valeur du contraste
* Historique :
*   85/04/.. : JJM     conception & codage
************************************************************

	NIBHEX 00
=CONTRASTe
	CD0EX
	R0=C
	D0=(5) =DCONTR	Adresse du contraste
	A=0    A
	A=DAT0 1	A(0) := contraste
	GOSBVL =HDFLT	Conversion en décimal
	AR0EX		R0 := résultat ; A := PC
	C=R0		C(W) := résultat
	GOVLNG =FNRTN2

	END
