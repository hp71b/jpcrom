	TITLE  SWAPLEX <swap.as>
*
* 86/02/15:
*   Jean-Jacques Moreau
*   Conception & codage
* JPC:A01
*   ../../..: PD/JT Intégration dans JPC Rom
* JPC:A06
*   87/04/18: PD/JT Refonte du Lex
*   87/04/18: PD/JT Resolution des problemes :
*		DESTROY B @ A=1 @ SWAP A,B
*		SWAP A(1),B(1)
*		SWAP A,B$ (une parse correcte suffit)
*   87/04/18: PD/JT Ajout des sous chaines : SWAP A$[1,2],B$
*   87/04/18: PD/JT Bugs restantes : utilisation de var
*		(alpha ?) non creees.
*

*
* 5 quartets pour stocker l'adresse de :
*
 X	EQU    =LEXPTR	x dans la Math-Stack
 Y	EQU    =LDCSPC	y dans la Math-Stack

**************************************************
* SWAP
*
* But: echanger le contenu de deux variables,
*   pourvu que leur type soit compatible.
* Historique:
*   86/04/  : J.J.M.	  conception & codage
*   87/04/18: P.D. & J.T. reconception & recodage
**************************************************

	REL(5) =SWAPd
	REL(5) =SWAPp
=SWAPe
*
* Supposons que le contenu de v1 soit x, et le
* contenu de v2 soit y.
* SWAP v1,v2 se resume a la sequence suivante :
*
* Evaluer l'expression (EXPEX-)
*   Ceci amene x au sommet de la Math-Stack
* Preparer le stockage (DEST)
*   Stocke dans Statement Scratch les elements
*   necessaires pour un stockage dans v1.
* Sauvegarder Statement Scratch
*   Le prochain DEST abimera les elements
*   caracteristiques de v1. Il faut donc les
*   sauvegarder.
* Evaluation de v2 (EXPEXC)
*   Amene y au sommet de la Math-Stack, sans
*   perturber x.
* Preparer le stockage (DEST)
*   Stocke les elements caracteristiques de v2
*   dans Statement Scratch, d'ou la sauvegarde
*   de tout a l'heure.
* Rappeler les elements caracteristiques de v1, et
* Sauvegarder les elements de v2
*   La creation d'une variable abime le sommet de
*   la Math-Stack. Il faut donc faire v1 := y
*   avant v2 := x
* Amener D1 sur y
*   D1 est place au sommet de la Math-Stack.
* Stocker y dans v1 (STORE)
*   Avec les elements caracteristiques de v2
*   prepares par le precedent DEST.
* Restaurer v2
*   Rappel de la Statement Scratch que nous
*   avions sauvegardee avant. Ce sont les
*   elements caracteristiques de v2.
* Amener D1 sur x
*   On fait comme si x etait au sommet de la
*   Math-Stack.
* Stocker x dans v2 (STORE)
*
* Voila, c'est aussi simple que cela !
*

*
* Evaluation de v1
*
	GOSBVL =SVTRC	preparer la TRACE
	GOSBVL =EXPEX-	evalue v1
*
* Preparer le stockage
* Sauvegarde de Statement Scratch
*
	LC(5)  X
	GOSUB  ENDEXP
*
* Evaluation de v2
*
	D0=D0+ 2	passer tCOMMA
	GOSBVL =SVTRC	preparer la TRACE
	GOSBVL =EXPEXC	Evalue var1
*
* Preparer le stockage
* Restaure les elements caracteristiques de v1
* sauve les elements de v2
*
	LC(5)  Y
	GOSUB  ENDEXP	variable := v1
*
* Amener D1 sur y
* Stocker y dans v1
*
	D1=(5) Y
	GOSUB  AFFECT
*
* Restaurer v2
*
	GOSUB  SWAPST
*
* Amene D1 sur x
* Stocker x dans v2
*
	D1=(5) X
	GOSUB  AFFECT
*
* Et fin !
*
	GOVLNG =NXTSTM

**************************************************
* AFFECT
*
* But: realiser l'affectation v := c
* Entree:
*   - Statement Scratch = sortie de DEST
*   - D1 = ^ sauvegarde de l'adresse du contenu.
* Sortie: -
* Abime: tout (cf STORE)
* Niveaux: 5 (STORE)
* Historique:
*   87/04/18: P.D. & J.T. conception & codage
**************************************************

 AFFECT
	C=DAT1 A
	D1=C		D1 := ^ contenu dans la MS
*
* Stockage proprement dit
*
	GOSBVL =AVE=D1	!!! Tres important !!!
	A=DAT1 W
	GOVLNG =STORE

**************************************************
* ENDEXP
*
* But: faire les actions suivant un EXPEXC, c'est
*   a dire sauvegarder l'adresse du contenu de la
*   variable (dans la math-Stack), puis faire un
*   DEST et sauvegarder les elements
*   caracteristiques de la variable.
* Entree:
*   - C(A) = adresse de la sauvegarde du contenu
*   - B(W), D1 et Function : sortie de EXPEXC
* Sortie:
* Abime: A, C, D1
* Niveaux: 2
* Appelle: DEST, SWAPST
* Note: n'abime pas D0
* Histirique:
*   87/04/18: P.D. & J.T. conception & codage
**************************************************

 ENDEXP
*
* Sauve l'adresse dans la Math-Stack du contenu de
* la variable evaluee.
*
	CD1EX
	DAT1=C A
	D1=C		Restaure D1
*
* Preparer le stockage
*
	GOSBVL =DEST
*
* Sauvegarde de Statement Scratch
*
	CD0EX
	RSTK=C		RSTK := D0
	GOSUB  SWAPST
	C=RSTK
	D0=C		restaurer D0
	RTN

**************************************************
* SWAPST
*
* But: echanger les 32 quartets situes a parir de
*   STMTR0 avec TRFMBF.
* Entree: -
* Sortie: -
* Niveaux: 0
* Utilise: D0, D1, C(W), A(W)
* Historique:
*   87/04/18: P.D. & J.T. conception & codage
**************************************************

 SWAPST
	D0=(5) =STMTR0
	D1=(5) =TRFMBF
	A=DAT0 W
	C=DAT1 W
	DAT0=C W
	DAT1=A W
	D0=D0+ 16
	D1=D1+ 16
	A=DAT0 W
	C=DAT1 W
	DAT0=C W
	DAT1=A W
	RTN

	END
