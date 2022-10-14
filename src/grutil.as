	TITLE  Graphique, Utilitaires <grutil.as>

************************************************************
* TSTA>C, TSTC>A, TSTA<C, TSTC<A
*
* But: comparer le champ A des deux registres A et C
* Entrée:
*   - A(A) et C(A) : valeurs signées à comparer
* Sortie:
*   - Cy = 1 : test vérifié
*   - Cy = 0 : test faux
* Abime: A(A), C(A)
* Niveaux: 0
* Detail: 
*   Les valeurs signées sur cinq quartets ont le format :
*     valeur positive :	  0  (valeur normale)
*     valeur négative :	  1  (valeur en complément à 2)
*			  ^	^
*			  |	|
*			  |	19 bits de poids faible
*			  bit de poid fort
* Historique:
*   86/09/02: PD conception & codage
************************************************************

=TSTA<C
=TSTC>A ACEX   A	en fait, TSTC>A <=> TSTA>C
	 *		avec A <-> C
=TSTA>C
=TSTC<A C=C+C  A	?C<0
	GOC    TST030	GOYES TST030
	A=A+A  A	?A<0
	GOC    TST020	GOYES TST020
 TST010 ?A>C   A
	RTNYES
 TST020 RTNCC
 TST030 A=A+A  A	?A<0
	GOC    TST010	GOYES TST010
	RTNSC

************************************************************
* csrc5, csrc4, cslc5, cslc4
*
* But: opérer des rotations circulaires sur C(W)
* Entrée:
*   - C(W)
* Sortie:
*   - C(W)
* Abime: C(W)
* Niveaux: 0
* Historique:
*   86/09/02: conception & codage
************************************************************

=csrc5	CSRC
=csrc4	CSRC
	CSRC
	CSRC
	CSRC
	RTN
=cslc5	CSLC
=cslc4	CSLC
	CSLC
	CSLC
	CSLC
	RTN

************************************************************
* RBUFC
*
* But: calculer l'adresse du champ C(B) dans le buffer.
* Entrée:
*   - C(B) = champ à chercher
*   - (BUFFER) = ^ bDRIVR
* Sortie:
*   - D1 = C = ^ champ demandé dans le buffer
*   - D(A) = C(B) en entrée
*   - Cy = 0
* Abime: C(A), D(A), D1
* Niveaux: 0
* Historique:
*   86/22/08: reprogrammation
************************************************************

=RBUFC	D1=(5) =RBUF
	D=0    A	} D(A) := C(B)
	D=C    B	}
	C=DAT1 A	C(A) := ^ bDRIVR
	C=C+D  A	C(A) := ^ bDRIVR.champ
	D1=C		D1 := ^ bDRIVR.champ
	RTN

************************************************************
* AMPY
*
* But: multiplier les champs A des deux registres A et C.
* Entrée:
*   - A(A), C(A) = les deux nombres à multiplier
* Sortie:
*   - A(W), B(W), C(W) = résultat
*   - Cy = 0
* Abime: A-C
* Appelle: MPY (tombe dedans)
* Niveaux: 0
* Detail: cette routine n'est qu'une interface pour MPY,
*   évitant d'avoir à cadrer les objets dans le registre
*   entier.
* Historique:
*   86/22/08: PD reprogrammation
************************************************************

=AMPY	B=0    W	B est utilisé par MPY, on peut
	B=C    A	l'utiliser
	C=B    W	C(W) := 00000000000.....
	B=A    A
	A=B    W	A(W) := 00000000000.....
	GOVLNG =MPY

************************************************************
* INTERV
*
* But: tester si un nombre est dans un certain intervalle.
* Entrée:
*   - C(A) = a
*   - R0(A) = borne inf
*   - R3(A) = borne sup
* Sortie:
*   - Cy = 0 : a est dans [W1a..W2a]
*   - Cy = 1 : a n'est pas dans [W1a..W2a]
* Abime: A(A), C(A), D(A)
* Appelle: TST
* Niveaux: 1
* Historique:
*   86/10/16: PD reprogrammation
************************************************************

=INTERV D=C    A	Sauve a dans D(A)
	A=R0
	GOSUB  =TSTA>C	?a<W1a
	RTNC		RTNYES
	C=D    A
	A=R3
	GOTO   =TSTC>A	Cy := (a>W2a)

	END
