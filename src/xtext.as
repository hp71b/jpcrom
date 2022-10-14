	TITLE	Editeur, gestion du texte <xtext.as>

 JPCPRV	EQU	1

*
* Paramètres du tableau utilisé pour optimiser l'accès
* au texte.
*
 BUFENT	EQU	10	5 pour no de ligne, 5 pour adresse
 DELTA	EQU	200	une entrée toutes les 200 lignes
 TURBULENCE EQU	50
*
* Note : il faut que 0 <= DELTA + TURBULENCE <= 255
*

************************************************************
* inibuf
*
* But: initialiser le buffer d'accès au fichier
* Entrée:
*   - FILADR = adresse du début du fichier
* Sortie:
*   - BUFID = id du buffer
*   - BUFADR = adresse du buffer
*   - DERN = numéro de la dernière ligne
* Abime: A-D, R0-R3
* Appelle: I/OALL, IODAL, IOFSCR, I/OCON
* Niveaux: 3
* Historique:
*   88/05/15: PD/JT conception & codage
************************************************************

=inibuf
*
* Désallocation éventuelle du buffer
*
	D0=(5)	=BUFID
	C=0	A
	C=DAT0	X	C(A) := bufid
	?C=0	A
	GOYES	inib10
	GOSBVL	=I/ODAL	Désallouer d'abord
*
* Allocation d'un nouveau buffer
*
 inib10	GOSBVL	=IOFSCR	Find an available scratch buffer ID
	GONC	inib15	Ok
	GOVLNG	=CORUPT	No available buffer id

 memerr	GOVLNG	=MEMERR

 inib15	D0=(5)	=BUFID
	DAT0=C	X	BUFID := id trouve
*
* Calculer la mémoire disponible
*
	D1=(5)	=AVMEME
	A=DAT1	A
	D1=D1-	5	D1=(5) =AVMEMS
	C=DAT1	A
	A=A-C	A	A(A) := mémoire disponible
	C=0	A
	LC(2)	7+=LEEWAY
*
* LEEWAY = place nécessaire pour récupérer le HP-71
* 7 = header du buffer
*
	A=A-C	A	A(A) := mémoire - LEEWAY - 7
	GOC	memerr	On ne peut pas travailler...
	LC(2)	BUFENT	C(4-2) = 000
	?A<C	A
	GOYES	memerr	Pas d'entrée suffisante
	LC(3)	4095	C(4-3) = 00
	?A<C	A
	GOYES	inib20
	A=C	A	A(A) := max (A(A), 4095)
*
* A(A) = taille du buffer à créer
*
 inib20	B=A	A	B(A) := taille du buffer
	R1=A		R1 := taille du buffer
	C=DAT0	X	C(4-3) = 00
	GOSBVL	=I/OALL	Cy = 0 (no room) : impossible
* B(A) = taille du buffer créé
* D1 = ^ début des données
	D0=(5)	=BUFADR
	CD1EX
	DAT0=C	A	BUFADR := adresse du buffer
	D1=C		D1 := ^ début du buffer
*
* last := fadr := adresse de la première ligne
* badr := adresse du début du buffer
* taille := taille du buffer
* nl := DELTA
* dernière := 0
* tant que longueur_LIF (fadr) # FFFF
*   faire
*     si --nl < 0
*       alors
*         nl := DELTA
*         dernière := dernière + DELTA
*         si taille > 2*BUFENT
*           alors
*             taille := taille - BUFENT
*             *badr := (dernière, fadr - last)
*             last := fadr
*             badr++
*         fin si
*     fin si
*     fadr := adresse de la ligne suivante
* fin tant que
* dernière := dernière + (DELTA - nl)
* *badr := (0, 0)
* compresser le buffer de (taille - BUFENT) quartets
*

* R0 = dernière
* D(B) = nl (limite à 255)
* D0 = fadr
* D1 = badr
* R1 = taille (déjà mise)
* R2 = last
* B(A) = fadr limite
*
	C=0	W
	R0=C		dernière := 0
	LC(2)	(DELTA)-1
	D=C	B	nl := (DELTA)-1

	D0=(5)	=FILADR
	C=DAT0	A
	D0=C		D0 := ^ en-tête du fichier
	D0=D0+	16
	D0=D0+	16
	A=DAT0	A	A(A) := REL(5) FiLeNd
	CD0EX		C(A) := ^ REL(5)
	D0=C
	C=C+A	A	C(A) := ^ EOF
	B=C	A	B(A) := fadr limite
	D0=D0+	5	D0 := ^ première ligne
	CD0EX		C(A) := fadr
	R2=C		last := fadr
	GONC	inib50	B.E.T.

 inib89	GOTO	inib90

* C(A) := fadr
 inib50	?C>=B	A	at EOF ?
	GOYES	inib89	fin tant que
	D0=C		D0 := ^ début de la ligne
	A=DAT0	4
* SWPBYT (#17A24) recopie pour eviter un GOSBVL
	C=A	A
	ASL	A
	ASL	A
	CSR	A
	CSR	A	C(4) := 0 (entre autres)
	A=C	B	A(A) longueur LIF
* fin du pompage
	P=	3
	C=A	WP	on sait que C(4) = 0
	A=C	A
	A=A+1	WP	Cy = 1 si C(A) = FFFF
	P=	0
	GOC	inib90	fin tant que
* conversion en nombre de quartets à sauter
	ASRB
	A=A+1	A
	A=A+A	A
	A=A+A	A	A(A) := nb de quartets à sauter

	D=D-1	B	--nl
	GONC	inib80	go if nl >= 0

	R3=A		R3 := sauvegarde de A
	C=0	A
	LC(2)	(DELTA)-1
	D=C	B	nl := (DELTA)-1
	A=R0		A(A) := dernière
	A=A+C	A
	A=A+1	A
	R0=A		dernière += DELTA

	A=R1		A(A) := taille
	LC(2)	2*BUFENT
	?A<=C	A
	GOYES	inib80	go if taille <= 20

	LC(2)	BUFENT
	A=A-C	A
	R1=A		taille -= 10

	A=R0		A(A) := dernière
	DAT1=A	A	*badr := (dernière,...
	D1=D1+	5
	A=R2		A(A) := last
	CD0EX
	D0=C
	R2=C		nouveau last := fadr
	C=C-A	A	C(A) := fadr - ancien last
	DAT1=C	A	....          ...., fadr - last)
	D1=D1+	5

	A=R3		A(A) := nb de quartets à sauter

 inib80	CD0EX
	C=C+A	A	C(A) := fadr
	GOTO	inib50	fin tant que

 inib90
*
* marque de fin de buffer
*
	C=0	W
	DAT1=C	BUFENT	*badr := (0, 0)
*
* Calcul du numéro de dernière ligne
*
	LC(2)	(DELTA)-1 on sait C(4-2) = 000
	C=C-D	B	C(A) := (DELTA)-1 - nl
	A=R0		A(A) := dernière
	A=A+C	A	dernière += (DELTA)-1 - nl
	D0=(5)	=DERN
	DAT0=A	A	DERN := dernière
*
* Compresser le buffer
*
	C=R1
	B=C	A	B(A) := taille du buffer
	C=0	A
	LC(1)	BUFENT
	B=B-C	A	taille - 10
	D0=(2)	=BUFID
	C=DAT0	X
	GOVLNG	=I/OCON

************************************************************
* seek
*
* But: chercher l'adresse de la ligne de numéro C (1..dern)
* Entrée:
*   - C(A) = numéro de la ligne à chercher
* Sortie:
*   - D0 = ^ début de la ligne
* Abime: A-D, R0-R3, D0, D1, TMP5
* Appelle: inibuf
* Niveaux: 4
* Detail:
*   last := 0
*   adr := FILADR
*   p = &buffer [0]
*   tant que (*p->numéro < numéro)
*     faire
*       x = *p ->numéro - last
*       si (x>DELTA+TURBULENCE) ou (x<DELTA-TURBULENCE)
*         alors
*           re-calculer le buffer
*           recommencer au début
*       fin si
*       last := *p->numéro
*       adr += *p->adresse
*       p++
*   fin tant que
*   entrée := numéro - last
*   pour i := 1 à entrée
*     faire
*       adr = ligne suivante (adr)
*   fin pour
*   renvoyer adr
* Affectation des registres:
*   R0 = last
*   D1 = accès
*   B(A) = no
*   D(A), puis D0 = ^ dans le fichier
* Historique:
*   88/05/18: PD/JT conception & codage
*   88/06/05: PD/JT ajout intervalle pour test du recalcul
*   88/11/20: PD/JT recalcul si trop de lignes à la fin
************************************************************

=seek	B=C	A
	D1=(5)	=BUFADR
	C=DAT1	A
	D1=C		D1 := ^ buffer
	D0=(5)	=FILADR
	A=DAT0	A
	C=0	A
	LC(2)	37
	C=A+C	A	A(A) := ^ début du buffer
	D=C	A	D(A) := ^ début du fichier
	C=0	A
	C=C+1	A	last := 1
	R0=C		last := numéro de la première ligne
	GONC	sek030	B.E.T.

 sek005	D0=(5)	=TMP5
	C=B	A
	DAT0=C	A	TMP5 := numéro à trouver
	GOSUB	=inibuf	recalcul...
	D0=(5)	=TMP5
	C=DAT0	A
	GOTO	=seek

 sek010	A=R0		A(A) := last
	R0=C		R0 := nouveau last
	ACEX	A
	A=A-C	A	A(A) := accès [i].no - last
	C=0	A
	LC(2)	(DELTA)+(TURBULENCE)
	?A>C	A
	GOYES	sek005	recalcul...
* ajout du 5/06/1988
	LC(2)	(DELTA)-(TURBULENCE)
	?A<C	A
	GOYES	sek005	recalcul aussi
* fin de l'ajout du 5/06/1988

	D1=D1+	5
	C=DAT1	A	C(A) := adresse incrémentale
	D=D+C	A
	D1=D1+	5

 sek030	C=DAT1	A	C(A) := numéro
	?C=0	A
	GOYES	sek040
	?C<B	A
	GOYES	sek010
*
* Deuxième partie de la routine
*
 sek040
*
* Sauvegarde du numéro de la ligne à atteindre dans R0
*
	C=B	A	C(A) := numéro de la ligne
	CR0EX		C(A) := last (inférieur à no)
*
* R0 = numéro de la ligne à atteindre
* C(A) = last (<no)
*
	B=B-C	A	B(A) := nombre de lignes à parcourir

*
* Y-a-t-il beaucoup trop de lignes à parcourir ?
*
	C=0	A
	LC(2)	(DELTA)+(TURBULENCE)
	?B<=C	A
	GOYES	sek045	non.
*
* Il n'y a pas suffisamment d'entrées dans le buffer. Est-ce
* par manque de place, ou parce qu'on a rajouté des lignes
* à la fin ?
*
	A=B	A	Sauvegarde de B(A) pendant MEMCKL
	R1=A		R1(A) := nb de lignes à parcourir
	C=0	A
	LC(1)	BUFENT	taille d'une entrée supplémentaire
	GOSBVL	=MEMCKL	assez de place ?
	C=R0
	B=C	A	B(A) := no de la ligne à atteindre
	GONC	sek005	oui : recalcul
*
* Pas assez de place pour réinitialiser le buffer. Il faut
* donc faire avec.
*
	A=R1		A(A) := sauvegarde avant MEMCKL
	B=A	A	B(A) := nb de lignes à parcourir

 sek045	C=D	A	C(A) := ^ ligne pointée
	D0=C		D0 := ^ ligne courante
	GOTO	sek060

 sek050	A=DAT0	4	A(3-0) := longueur LIF brute
* SWPBYT (#17A24) recopié pour éviter un GOSBVL
	C=A	A
	ASL	A
	ASL	A
	CSR	A
	CSR	A	C(4) := 0 (entre autres)
	A=C	B	A(A) longueur LIF
* fin du pompage
	P=	3
	C=A	WP	on sait que C(4) = 0
	P=	0
	A=C	A
	A=A+1	A
	ASRB
	A=A+1	A
	A=A+A	A
	A=A+A	A	A(A) := nb de quartets à sauter

	CD0EX		C(A) := ^ ligne courante
	C=C+A	A	C(A) := ^ ligne suivante
	D0=C

 sek060	B=B-1	A
	GONC	sek050
	RTN

************************************************************
* LIFlen
*
* But: calculer la longueur d'une ligne LIF
* Entrée:
*   - D0 = ^ ligne LIF
* Sortie:
*   - C(A) = longueur de la ligne en octets
*   - A(A) = taille de la ligne en quartets (y compris LIF)
* Abime: A, C(A), P
* Niveaux: 0
* Historique:
*   88/05/18: PD/JT conception & codage
************************************************************

=LIFlen	A=DAT0	4	A(3-0) := longueur LIF brute
* SWPBYT (#17A24) recopié pour éviter un GOSBVL
	C=A	A
	ASL	A
	ASL	A
	CSR	A
	CSR	A	C(4) := 0 (entre autres)
	A=C	B	A(A) longueur LIF
* fin du pompage
	P=	3
	C=A	WP	on sait que C(4) = 0
	P=	0
	A=C	A
	A=A+1	A
	ASRB
	A=A+1	A
	A=A+A	A
	A=A+A	A	A(A) := nb de quartets à sauter
	RTN

************************************************************
* addlin
*
* But: ajoute une ou n lignes dans le buffer.
* Entrée:
*   - C(A) = nombre de lignes
*   - A(A) = longueur de ce qui a été rajoute
*   - B(A) = numéro de la nouvelle première ligne
* Sortie: -
* Abime: C(A), D(A), D1
* Niveaux: 0
* Note: DERN est réactualisé en conséquence
* Historique:
*   88/05/24: PD/JT conception & codage
************************************************************

=addlin	D=C	A	D(A) := nombre de lignes ajoutées

	D1=(5)	=DERN
	C=DAT1	A
	C=C+D	A
	DAT1=C	A

	D1=(2)	=BUFADR
	C=DAT1	A
	D1=C		D1 := ^ buffer
*
* Trouver l'entrée dans le buffer
*
 adln10	C=DAT1	A
	?C=0	A
	RTNYES		Ok, yarienafair
	?C>B	A
	GOYES	adln20	Trouve !
	D1=D1+	BUFENT
	GONC	adln10	B.E.T.
*
* L'entrée est trouvée. Reste à actualiser l'adresse, et le
* numéro des lignes suivantes.
*
 adln20	D1=D1+	5
	C=DAT1	A	C(A) := adresse
	C=C+A	A
	DAT1=C	A	buffer := nouvelle adresse
	D1=D1-	5	D1 := ^ numéro

 adln30	C=DAT1	A
	?C=0	A
	RTNYES		finiiiiiii !
	C=C+D	A
	DAT1=C	A
	D1=D1+	BUFENT
	GONC	adln30	B.E.T.

************************************************************
* rpllin
*
* But: remplacer une ligne dans le buffer
* Entrée:
*   - A(A) = différence de taille (nouvelle - ancienne)
*   - B(A) = numéro de la ligne remplacée
* Sortie: -
* Abime: C(A), D1
* Niveaux: 0
* Historique:
*   88/05/24: PD/JT conception & codage
************************************************************

=rpllin	D1=(5)	=BUFADR
	C=DAT1	A
	D1=C		D1 := ^ buffer
*
* Trouver l'entrée dans le buffer
*
 rpln10	C=DAT1	A
	?C=0	A
	RTNYES		Ok, yarienafair
	?C>B	A
	GOYES	rpln20	Trouve !
	D1=D1+	BUFENT
	GONC	rpln10	B.E.T.
*
* L'entrée est trouvée. Il faut actualiser l'adresse de
* l'entrée suivante.
*
 rpln20	D1=D1+	5
	C=DAT1	A
	C=C+A	A	A peut être négatif
	DAT1=C	A
	RTN

************************************************************
* dellin
*
* But: supprime une ou n lignes dans le buffer
* Entrée:
*   - C(A) = nombre de lignes
*   - A(A) = longueur de ce qui a été enlevé
*   - B(A) = numéro de l'ancienne première ligne
* Sortie:
*   - DERN est réactualisée
* Abime: A-C, D(A), D1
* Appelle: -
* Niveaux: 0
* Algorithme:
*   début := B(A)
*   delta := A(A)
*   nombre := C(A)
*   last := B(A) + C(A) - 1
*   avant := 1
*
*   DERN -= nombre
*
*   /* PHASE I : chercher la ligne de début */
*
*   p := &buffer [0]
*   tant que p->numéro < début
*     faire
*	si p->numéro == 0 alors sortir fin si
*       avant := p->numéro
*	p++
*   fin tant que
*   /* p est la première entrée >= début */
*
*   /* PHASE II : chevauchement de frontières */
*
*   tant que last >= p->numéro
*     alors
*       si p->numéro == 0 alors sortir fin si
*       p->adresse := 0
*       p->numéro := avant
*       p++
*   fin tant que
*
*   /* PHASE III : actualiser la fin du buffer */
*
*   tant que p != 0
*     faire
*	p->adr -= delta
*	p->numéro -= nombre
*	delta := 0
*	p++
*   fin tant que
* Historique:
*   88/05/24: PD/JT documentation de l'interface
*   88/10/29: PD/JT conception & codage
*   88/11/01: PD/JT déplacement de la modification de DERN
************************************************************

=dellin
*
* Sauvegarde des valeurs
* - début (B(A)) dans B(4-0)
* - delta (A(A)) dans B(9-5)
* - nombre (C(A)) dans B(14-10)
*
	D=C	A	D(A) := nombre
	GOSBVL	=CSLC5
	C=A	A
	GOSBVL	=CSLC5
	C=B	A
	B=C	W
*
* B(14-10) = nombre
* B(9-5) = delta
* B(4-0) = début
* D(A) = nombre
*

*
* DERN -= nombre
*
	D1=(5)	=DERN
	C=DAT1	A	C(A) := dernière
	C=C-D	A	C(A) := dernière - nombre
	DAT1=C	A	dernière -= nombre

*
* p = &buffer [0]
* avant := 1
*
	D1=(2)	=BUFADR
	C=DAT1	A	C(A) := & buffer [0]
	D1=C		D1 := & buffer [0]

	D=0	A	avant := 0
	D=D+1	A	avant := 1
*
* tant que p->numéro < début
*   faire
*     si p->numéro == 0 alors sortir fin si
*     avant := p->numéro
*     p++
* fin tant que
*
* Invariant de boucle :
* - D1 = ^ entrée courante dans le buffer (p)
* - B(A) = début
*
 dl100	C=DAT1	A
	?C=0	A
	RTNYES		si p->numéro == 0 alors sortir
	?C>=B	A
	GOYES	dl200
	D=C	A	avant := p->numéro
	D1=D1+	BUFENT
	GONC	dl100	B.E.T.

*
* Phase II. On rappelle que :
* - B(14-10) = nombre
* - B(9-5) = delta
* - B(4-0) = début
* - D(A) = avant
* - D1 = p
*
 dl200
*
* Calcul de last (début + nombre - 1)
*                 B(4-0)  B(14-10)
*
	C=B	W	C(14-10) := nombre
	GOSBVL	=CSLC6	C(A) := nombre
	C=C+B	A	C(A) := début + nombre
	C=C-1	A	C(A) := last
	A=C	A	A(A) := last
	GONC	dl220	B.E.T.
*
* tant que last >= p->numéro
*   alors
*     si p->numéro == 0 alors sortir fin si
*     p->adresse := 0
*     p->numéro = avant
*     p++
* fin tant que
*
* Invariant de boucle :
* - A(A) = last
* - D1 = p
*
 dl210	C=D	A	C(A) := début
	DAT1=C	A	p->numéro := début
	D1=D1+	5
	C=0	A
	DAT1=C	A	p->adresse := 0
	D1=D1+	5
 dl220	C=DAT1	A	A(A) := p->numéro
	?C=0	A
	RTNYES		si p->numéro == 0 alors sortir
	?C<=A	A
	GOYES	dl210

*
* Phase III. On rappelle que :
* - B(14-10) = nombre
* - B(9-5) = delta
* - B(4-0) = début
* - D1 = p
*
 dl300	
	A=B	W	A(14-10) := nombre; A(9-5) := delta
	GOSBVL	=ASRW5	A(9-5) := nombre ; A(A) := delta
	B=A	A	B(A) := delta
	GOSBVL	=ASRW5	A(A) := nombre
	GOTO	dl350
*
* Invariant de boucle :
* - A(A) = nombre
* - B(A) = delta
* - D1 = p
*
 dl310	C=C-A	A	C(A) := p->numéro - nombre
	DAT1=C	A	p->numéro -= nombre
	D1=D1+	5

	C=DAT1	A	C(A) := p->adresse
	C=C-B	A	C(A) := p->adresse - delta
	DAT1=C	A	p->adresse -= delta
	D1=D1+	5

	B=0	A	delta := 0

 dl350	C=DAT1	A	C(A) := p->numéro
	?C#0	A
	GOYES	dl310

	RTN

************************************************************
* syncbf
*
* But: synchronise l'adresse du buffer après un mouvement
*   mémoire.
* Entrée:
*   - BUFID = ID du buffer
* Sortie:
*   - BUFADR = nouvelle adresse du buffer
* Abime: A, C(A), C(S), D1
* Appelle: IOFND0
* Niveaux: 1
* Historique:
*   88/05/24: PD/JT conception & codage
************************************************************

=syncbf	D1=(5)	=BUFID
	C=DAT1	X
	GOSBVL	=IOFND0
	CD1EX
	D1=(5)	=BUFADR
	DAT1=C	A
	RTN

************************************************************
* SRCLIN, SRCADR
*
* But: chercher une chaîne (générique) dans le fichier texte
*   La chaîne à chercher est déjà compilée.
* Entrée:
*   - R0(7-0) = caractéristique du buffer (chaîne compilée)
*   - A(A) = numéro de la ligne de début
*   - C(A) = numéro de la ligne de fin
*   SRCLIN : rien d'autre
*   SRCADR :
*	- B(A) = offset dans la ligne (en caractères)
*	- D0 = ^ début ligne LIF (sur la longueur)
* Sortie:
*   Cy = 1 : match found
*     - A(A) = numéro de la ligne trouvée
*     - C(A) = longueur de l'occurrence trouvée (en octets)
*     - D0 = ^ occurrence trouvée
*     - D1 = ^ ligne (long. LIF) contenant l'occurrence
*   Cy = 0 : match not found
* Abime: A-D, R0(12-8), R1, D0, D1, FUNCR0
*   en plus, pour SRCLIN : R2-R3, FUNCR1, TMP5
* Note: SRCLIN appelle "seek", qui est dévoreuse de place.
* Appelle: seek, POSADR, LIFlen
* Niveaux: 5 (seek) pour SRCLIN ou 4 (POSADR) pour SRCADR
* Historique:
*   88/07/06: PD/JT séparation de la routine de recherche
*   88/07/10: PD/JT ajout de SRCADR
*   88/10/09: PD/JT adaptation au nouveau POSADR
************************************************************

 ldeb	EQU	(=FUNCR0)+00	5 quartets
 lfin	EQU	(=FUNCR0)+05	5 quartets
 curlin	EQU	(=FUNCR0)+10	5 quartets
 sauvR0	EQU	(=FUNCR0)+15	8 quartets

=SRCLIN
*
* Sauvegarde pendant seek
*
	D1=(5)	ldeb	ldeb := A(A)
	DAT1=A	A
	D1=(2)	lfin	lfin := C(A)
	DAT1=C	A
	D1=(2)	sauvR0	sauvR0 := R0
	C=R0
	DAT1=C	8

	C=A	A	C(A) := ldeb
	GOSUB	=seek

	D1=(5)	sauvR0	R0 := sauvR0
	C=DAT1	8
	R0=C	A
	B=0	A	offset := 0
	GOTO	SRC100

=SRCADR	D1=(5)	ldeb	ldeb := A(A)
	DAT1=A	A
	D1=(2)	lfin	lfin := C(A)
	DAT1=C	A

 SRC100
*
* Invariant de boucle
*   ldeb = no ligne courante
*   lfin = no ligne fin
*   D0 = adresse ligne courante
*   B(A) = offset = offset dans la ligne courante
*
	CD0EX		curlin := D0
	D0=(5)	curlin
	DAT0=C	A
	D0=C		pour LIFlen

	GOSUB	=LIFlen
	A=C	A	A(A) := longueur en octets
	A=A-B	A	A(A) := longueur de ce qu'il reste
	D0=D0+	4	pour POSADR
	CD0EX
	R1=C		R1 := ^ vrai début
	C=C+B	A
	C=C+B	A
	D0=C		D0 := ^ début partie à chercher
*
*   D0 = ^ chaîne
*   A(A) = longueur de la chaîne
*   R0 = buffer
*   R1(A) = ^ vrai début
*
	GOSUBL	=POSADR
	GOC	SRC200	trouvé !

	B=0	A	offset := 0

	D0=(5)	curlin
	C=DAT0	A
	D0=C		D0 := ^ ligne courante
	GOSUB	=LIFlen
	CD0EX
	C=C+A	A
	D0=C		D0 := ^ ligne suivante

	D1=(5)	lfin
	A=DAT1	A	A(A) := lfin
	D1=(2)	ldeb
	C=DAT1	A	C(A) := ldeb
	C=C+1	A
	DAT1=C	A	++ldeb
	?C<=A	A	ldeb <= lfin ?
	GOYES	SRC100	oui : on continue
*
* Arrivé à la fin sans avoir trouvé
*
	LC(4)	(=id)~(=eNFND)	"Not Found"
	RTNCC

*
* Arrivé à l'occurrence
*
 SRC200	B=C	A	B(A) := longueur de l'occurrence
	D1=(5)	ldeb	A(A) := ^ numéro de ligne
	A=DAT1	A
	D1=(2)	curlin	D1 := ^ début ligne LIF
	C=DAT1	A
	D1=C
	C=B	A	C(A) := longueur de l'occurrence
	RTNSC		match found

************************************************************
* DELIM
*
* But: analyse une chaîne de recherche (ou de remplacement)
*   suivant le mode (HP-UX ou HP-71). La chaîne est terminée
*   par le délimiteur (le premier caractère de la chaîne),
*   ou par la fin de la chaîne.
* Entrée:
*   - D1 = ^ premier caractère (le délimiteur)
*   - D(A) = longueur totale de la chaine
* Sortie:
*   - Cy = 0 : pas d'erreur
*	- D1 et D(A) réactualisés (avant / final ou sur EOL)
*	- A(A) = ^ début de la chaîne trouvée
*	- C(A) = nombre de caractères dans la chaîne trouvée
*   - Cy = 1 : erreur
*	- C(4-0) = numéro d'erreur
* Abime: A-D, D0, D1
* Appelle: getchr
* Niveaux: 1
* Note : en sortie, D1 pointe sur le "/", ou sur le EOL.
*   Ceci est fait pour pouvoir distinguer le cas
*   "R/toto/" du cas "R/toto". Cela est plus embêtant, car
*   l'appelant doit explicitement passer le délimiteur. Mais
*   c'est la seule manière de faire (simplement).
* Historique:
*   88/10/15: PD/JT séparation de GETSRC
*   89/08/05: PD    correction de la documentation
************************************************************

 invprm	LC(4)	=eILPAR	"Invalid Parm"
	RTNSC		Erreur

=DELIM
*
* Chercher le caractère délimiteur
*
	GOSUBL	=getchr	caractère délimiteur
	GOC	invprm	pas présent : "Invalid Parm"
	B=A	B	B(A) := caractère délimiteur
*
* En fonction du mode, analyser en tenant compte des "\"
* ou non :
*
	D0=(5)	=MODE71
	C=DAT0	S
	CD1EX
	D0=C		Sauvegarde de D1 dans D0
	D1=C
	?C=0	S	mode HP-UX
	GOYES	DELI20
*
* Mode HP-71 : on recherche bêtement le caractère B(B)
*
 DELI10	GOSUBL	=getchr
	GOC	DELI70	EOL trouve.
	?A#B	B	délimiteur ?
	GOYES	DELI10	non : on continue
	GONC	DELI60	B.E.T. délimiteur trouvé.

*
* Mode HP-UX : le caractère B(B) peut être précédé par "\"
*
 DELI20	LCASC	'\'
 DELI30	B=0	S	état := 0
 DELI40	GOSUBL	=getchr
	GOC	DELI70	EOL trouvé.
	?B#0	S	selon état
	GOYES	DELI30	état 1 : on repasse en état 0
* etat 0 : pas de '\'
	?A=B	B	caractère délimiteur ?
	GOYES	DELI60	Délimiteur trouvé
	?A#C	B	'\' ?
	GOYES	DELI40	non : on continue en état 0
	B=B+1	S	état := 1
	GONC	DELI40	B.E.T.

*
* Pour le cas ou on est arrivé sur le délimiteur,
* on revient en arrière. A charge pour l'appelant de
* passer un caractère.
*
 DELI60	D1=D1+	2	la M.S. va dans le sens inverse
	D=D+1	A
*
* Cas EOL : on laisse D1 et D(A) en l'état.
*
 DELI70	C=0	M	pour le CSRB de tout à l'heure
	CD1EX
	D1=C
*
* D0 = ^ début
* C(A) = ^ dernier caractère de la chaîne
* D1 = ^ caractère suivant (sur le "/", ou sur EOL)
* D1 et D(A) sont à préserver
*
	AD0EX
	D0=A		on garde D0 encore un peu au chaud
	C=A-C	A
	CSRB		C(A) := nombre de caractères
	AD0EX		A(A) := ^ début de la chaîne
*
* A(A) = ^ début de la chaîne trouvée
* C(A) = nombre de caractères dans la chaîne trouvée
* D1 et D(A) réactualisés
*
	RTNCC		pas d'erreur

************************************************************
* GETSRC
*
* But: analyse et compile une chaîne de recherche suivant le
*   mode (HP-UX ou HP-71). La chaîne est terminée par le
*   délimiteur (le premier caractère de la chaîne), ou par
*   la fin de la chaîne.
* Entrée:
*   - D1 = ^ premier caractère (le délimiteur)
*   - D(A) = longueur totale de la chaîne
* Sortie:
*   - Cy = 0 : pas d'erreur
*	- R0(7-0) = caractéristiques du buffer compilation
*	- D1 et D(A) réactualisés (avant "/" ou sur EOL)
*   - Cy = 1 : erreur
*       - C(4-0) = numéro d'erreur
* Abime: A-D, R0-R3, D0, D1
* Appelle: DELIM, COMPUX ou COMP71
* Niveaux: 5
* Note : l'appelant doit passer explicitement le "/" final.
* Historique:
*   88/07/09: PD/JT conception & codage
*   88/10/15: PD/JT séparation de DELIM
************************************************************

=GETSRC	GOSUB	=DELIM
	RTNC		erreur lors de la recherche du '/'
*
* A(A) = ^ début de la chaîne trouvée
* C(A) = nombre de caractères dans la chaîne trouvée
* D1 et D(A) réactualisés
*
	RSTK=C		sauvegarder le nombre de caractères
	CD1EX
	GOSBVL	=CSLC5
	C=D	A
	R3=C		R3(9-5) := D1 ; R3(A) := D(A)

	D1=A		D1 := ^ début de la chaîne trouvée
	C=RSTK
	A=C	A	A(A) := nombre de caractères
*
* A(A) = nombre de caractères
* D1 = ^ début de la chaîne trouvée
* R3(9-5,4-0) = partie restante après la chaîne trouvée
*
	D0=(5)	=MODE71
	C=DAT0	S
	?C=0	S
	GOYES	GETS80
	GOSUBL	=COMP71
	GOTO	GETS90
 GETS80	GOSUBL	=COMPUX
*
* Compilation terminée. Restauration de D1 et D(A) sans
* abimer C(A) et Carry
*
 GETS90	A=C	A	sauvegarde de C(A)
	C=R3
	D=C	A	restauration de D(A)
	GOSBVL	=CSRC5
	D1=C		restauration de D1
	C=A	A	restauration de C(A)
	RTN		sans abimer la Cy

************************************************************
* FMTLIF
*
* But: formatte une chaîne placée en (OUTBS..AVMEMS) suivant
*   les conventions LIF. La ligne est déjà placée 4 quartets
*   après OUTBS (pour laisser de la place pour la longueur).
* Entrée:
*   - OUTBS et AVMEMS positionnés
*   - S0 = 1 si l'octet de padding doit être ajouté
* Sortie:
*   - Cy = 0 : pas d'erreur
*	AVMEMS réajusté si besoin est et si S0=1.
*	D0 = ^ début de la ligne (longueur LIF) dans OUTBS
*   - Cy = 1 : ligne trop longue (> 64 Ko)
*	C(3-0) = eL2LNG
* Abime: A(A), C(W), D0
* Appelle: LIFlen
* Niveaux: 1
* Historique:
*   88/10/15: PD/JT conception & codage
*   88/10/30: PD/JT ajout du flag 0
************************************************************

=FMTLIF	D0=(5)	=AVMEMS
	C=0	M
	C=DAT0	A
	D0=D0-	5	D0 := OUTBS
	A=DAT0	A
	C=C-A	A	C(A) := longueur totale en quartets
	CSRB		C(A) := longueur en octets + 2
	C=C-1	A
	C=C-1	A
* Test de longueur < 65536
	A=0	A
	P=	3
	A=C	WP	A(A) := longueur en octets (SWPBYT)
	P=	0
	?A#C	A
	GOYES	FMTERR
* Faut-il ajouter l'octet de padding ?
	?ST=0	0
	GOYES	FMTL10	non
	SB=0
	CSRB
	?SB=0		longueur paire ?
	GOYES	FMTL10	oui. C'est très bien comme ça.
* Il faut ajouter 2 quartets à AVMEMS
	D0=D0+	5	D0 := AVMEMS
	C=DAT0	A
	C=C+1	A
	C=C+1	A
	DAT0=C	A	AVMEMS += 2
	D0=D0-	5	D0 := OUTBS
* Placer la longueur LIF (qui est dans A) en OUTBS
 FMTL10	C=DAT0	A
	D0=C		D0 := ^ début ligne (long LIF)
	GOSBVL	=SWPBYT
	DAT0=A	4
	RTNCC		Cy = 0 : pas d'erreur
 
 FMTERR	LC(4)	=eL2LNG	"Line Too Long"
	RTNSC		Cy = 1

************************************************************
* MVFILE
*
* But: déplace une partie d'un fichier dans un autre, en
*   supprimant éventuellement la partie "source"
* Entrée:
*   - A(A) = ^ header origine
*   - R1(A) = ^ début partie à déplacer
*   - R2(A) = ^ fin partie à déplacer
*   - C(A) = ^ header destination
*   - R0(A) = ^ emplacement où doit être inséré le bloc
*   - sMOVE = 1 si l'origine doit être détruite après
* Sortie:
*   - Cy = 0 : pas d'erreur
*	A(A) = ^ header origine mis-à-jour
*	C(A) = ^ header destination mis-à-jour
*   - Cy = 1 : erreur
*	C(3-0) = numéro d'erreur
*	Aucun des deux fichiers n'a bougé
* Abime: A-D, R0-R3, D0, D1, FUNCRx
* Appelle: ????? RAMROM, MOVE*M, RPLLIN, LIFlen
* Niveaux: ???????
* Algorithme:
*   Paramètres :
*     orghdr = header du fichier origine
*     orgdeb = début de l'origine
*     orgfin = fin de l'origine
*     dsthdr = header du fichier destination
*     dstadr = adresse destination courante
*     taille = orgfin - orgdeb
*
*   /* Phase I : Allouer un buffer */
*
*   allouer un buffer temporaire et stocker les paramètres
*
*   /* Phase II : Assez de place pour la destination ? */
*
*   Tester la contrainte de place suivant tableau ci-dessous
*   mem := MEM(device destination)
*
*   /* Phase III : Détection des cas particuliers */
*
*   si dstadr in [orgdeb...orgfin]
*     alors
*	si cas "copie"
*	  alors
*           dstadr := valeur originale (sans updates)
*	    insérer
*	      taille = taille quartets
*	      début = dstadr
*	    fin insérer
*	    copier
*	      début source = orgdeb
*	      fin source = dstadr
*	      début dest = dstadr
*	    fin copier
*	    copier
*	      début source = dstadr + taille
*	      fin source = orgfin après update
*	      début dest = dstadr + (dstadr - orgdeb)
*	    fin copier
*	fin si
*	désallouer le buffer
*	sortir
*   fin si
*
*   /* Phase IV : Recopie dans le fichier */
*
*   tant que orgdeb # orgfin
*
*     /* Phase IV.a : prendre le maximum */
*
*     l2 := orgdeb
*     tant que l2 # orgfin et (l2-orgdeb)+LIFlen(l2)>=mem
*	l2 += LIFlen(l2)
*     fin tant que
*
*     si orgdeb == l2
*	alors
*	  /* cas IV.b : ligne trop longue */
*
*	  l2 += LIFlen(l2)
*	  tant que orgdeb < l2
*	    x := min (mem, l2-orgdeb)
*
*	    insérer
*	      taille = x quartets
*	      début dest = dstadr
*	    fin insérer
*	    copier
*	      début source = orgdeb
*	      fin source = orgdeb + x
*	      début dest = dstadr
*	    fin copier
*	    /* le cas "copie" n'est pas possible ici */
*	    détruire
*	      début = orgdeb
*	      fin = orgdeb + x
*	    fin détruire
*	    dstadr += x
*	  fin tant que
*	sinon
*	  /* cas IV.c : on a trouvé des lignes */
*
*	  x := l2 - orgdeb
*
*	  insérer
*	    taille = x quartets
*	    début dest = dstadr
*	  fin insérer
*	  copier
*	    début source = orgdeb
*	    fin source = orgdeb + x
*	    début dest = dstadr
*	  fin copier
*	  si cas "copie"
*	    alors orgdeb += x
*	    sinon
*	      détruire
*		début = orgdeb
*		fin = orgdeb + x
*	      fin détruire
*	  fin si
*	  dstadr += x
*     fin si
*   fin tant que
*   désallouer le buffer
*   sortir
*
* Détail:
*   Contraintes de mémoire
*   - MEM = taille disponible dans le device destination
*     Le device étant :MAIN ou :PORT
*   - taille du bloc (du fichier origine) à copier
*
* 	origine	|	:PORT		|	:MAIN	   |
*  destination	|			|		   |
*  -------------+-----------------------+------------------|
* |:PORT | copy	| MEM > taille		| MEM > taille     |
* |	 |------+-----------------------+------------------|
* |	 | move	| port = | MEM > 512	|		   |
* |	 |	|--------+--------------| MEM > taille	   |
* |	 |	| port # | MEM > taille |		   |
* |-------------+-----------------------+------------------|
* |:MAIN | copy	| MEM > taille		| MEM > taille	   |
* |	 |------+-----------------------+------------------|
* |	 | move	| MEM > taille		| MEM > 512	   |
*  --------------------------------------------------------
*
* On demande au moins MEM > 512 pour pouvoir transférer
* les lignes raisonablement vite. Ceci n'arrive que lorsque
* on fait un "move" à l'intérieur de la même unite.
*
* Cette mémoire est calculée une seule fois. En cas de copie
* ou de déplacement dans des péripheriques différents, le
* transfert est fait en une seule passe, d'où il n'y a pas
* besoin de la recalculer. En cas de déplacement dans le
* même périphérique, la mémoire n'est pas modifiée par
* définition.
*
* Note: Les fichiers sont supposés inscriptibles.
*
* Historique:
*   88/11/01: PD/JT conception de l'algorithme
*   88/11/01: PD/JT début du codage
*   88/11/06: PD/JT continuation du codage
*   88/11/11: PD/JT debogage et fin du codage
*   88/11/11: PD/JT ajout du test "Illegal Access"
*   88/11/12: PD/JT retrait du test "Illegal Access"
************************************************************

*
* Données placées dans le buffer. Les valeurs définies ici
* sont les offsets par rapport au début du buffer.
*
 orghdr	EQU	00
 orgdeb	EQU	05
 orgfin	EQU	10
 dsthdr	EQU	15
 dstadr	EQU	20
 l2	EQU	25	sauvegarde pendant cas pathologique
 rstk	EQU	30	3 niveaux de pile (15 q)
 MVBUFS	EQU	45	taille du buffer

*
* Données en mémoire statique. Il s'agit ici de FUNCRx
*
 mvbid	EQU	00+=FUNCR0	3 q : id du buffer
 mvbadr	EQU	03+=FUNCR0	5 q : adresse du buffer
 taille	EQU	08+=FUNCR0	5 q : orgfin - orgdeb
 mvmem	EQU	13+=FUNCR0	5 q : MEM (device dest.)
 xxxx	EQU	18+=FUNCR0	x q : 

 mverr	RTNSC

=sMOVE	EQU	0

=MVFILE
****************************************
* Phase I : Allouer un buffer
****************************************

 mvf100
*
* Sauver temporairement A(A) et C(A) dans R3 car les
* routines de buffer les abimeraient.
*
	GOSBVL	=CSLC5	C(9-5) := C(A)	(dsthdr)
	C=A	A	C(4-0) := A(A)	(orghdr)
	R3=C		R3(9-5) := C(A) ; R3(4-0) := A(A)
*
* R3(4-0) = orghdr
* R3(9-5) = dsthdr
*
	GOSBVL	=IOFSCR	find an available scratch buffer id
	GONC	mvf110	ok
	GOVLNG	=CORUPT	No available buffer id
*
* C(X) = id disponible
*
 mvf110	D0=(5)	mvbid
	DAT0=C	X	mvbid := id trouvé
	B=C	X	B(X) := id trouvé
	C=0	A
	LC(2)	MVBUFS	C(A) := taille du buffer
	BCEX	A	B(A) := taille ; C(A) := id
*
* C(X) = buffer id
* B(A) = longueur demandée
*
	GOSBVL	=I/OALL	Cy = 0 : no room
	GONC	mverr	RTNSC
*
* Recopie des paramètres dans le buffer
* D1 = ^ past buffer header
*
	D0=(5)	mvbadr
	CD1EX
	D1=C
	DAT0=C	A	mvbadr := adresse du buffer

	D1=D1-	7
	LC(1)	(MVBUFS)/5 nb d'adresses à réactualiser
	DAT1=C	1	nb adresses := 6
	D1=D1+	7

	A=R3		A(A) := orghdr
	DAT1=A	A	orghdr
	D1=D1+	5
	A=R1
	DAT1=A	A	orgdeb
	D1=D1+	5
	A=R2
	DAT1=A	A	orgfin
	D1=D1+	5

	C=R3
	GOSBVL	=CSRC5	C(A) := dsthdr
	DAT1=C	A	dsthdr
	D1=D1+	5
	C=R0
	DAT1=C	A	dstadr

	D1=(5)	taille
	C=R2		C(A) := orgfin
	A=R1		A(A) := orgdeb
	C=C-A	A	C(A) := taille
	DAT1=C	A	taille ne doit pas être actualisée

****************************************
* Phase II : Assez de place pour la destination ?
****************************************

*
* Localiser le device du fichier origine
*
 mvf200	C=R1		C(A) := orgdeb (dans origine)
	GOSBVL	=LOCADR
*
* D(S) = 0 : main
* D(S) # 0 :	D(S) =	1 : port ram
*			2 : port rom
*			3 : port eprom
*		D(0) = extender
*		D(1) = port number
*		D(7-2) = rest of config entry
*
	C=D	W
	R3=C		R3 =: sauvegarde D(W) origine
*
* Localiser le device du fichier destination
*
	C=R0		C(A) := dstadr
	GOSBVL	=LOCADR
	GOSUB	memD	calcule la mémoire disponible
	D1=(5)	mvmem
	DAT1=C	A	mvmem := MEM (device destination)
*
* A(A) = C(A) = MEM (destination device)
* D(W) = device info of destination
* R3 = device info of origine
*
	?ST=0	=sMOVE
	GOYES	mvf230	tester MEM > TAILLE
*
* Cas "move". Est-ce la même unité ?
*
	C=R3		C(W) := device info of origine
	?D#C	S
	GOYES	mvf230	tester MEM > TAILLE
	?D#C	B
	GOYES	mvf230	tester MEM > TAILLE
*
* Tester MEM > 512
*
	LC(5)	512
	?A>=C	A	MEM > 512
	GOYES	mvf250	c'est tout bon

 mvf220	LC(4)	=eMEM	"Insufficient Memory"
 mvfer+	R0=C		R0(3-0) := numéro d'erreur
	D0=(5)	mvbid
	C=DAT0	X
	GOSBVL	=I/ODAL
	C=R0		C(3-0) := numéro d'erreur
	RTNSC		Beeeeeep !

*
* Tester MEM > taille
*
 mvf230	D0=(5)	taille
	C=DAT0	A
	?A<C	A
	GOYES	mvf220	"Insufficient Memory"

 mvf250

****************************************
* Phase III : Détection des cas particuliers
****************************************

 mvf300	D0=(5)	mvbadr
	C=DAT0	A	A(A) := ^ début du buffer
	D1=C		D1 := ^ début du buffer
	D1=D1+	orgdeb
	C=DAT1	A	C(A) := orgdeb
	B=C	A	B(A) := orgdeb
	D1=D1+	(orgfin)-(orgdeb)
	C=DAT1	A	C(A) := orgfin

	D1=D1+	(dstadr)-(orgfin)
	A=DAT1	A	A(A) := dstadr
*
* A(A) = dstadr
* B(A) = orgdeb
* C(A) = orgfin
*
	?A<B	A	dstadr < orgdeb
	GOYES	mvF400
	?A>C	A	dstadr > orgfin
	GOYES	mvF400
*
* Cas particulier. Chevauchement des zones.
*
	?ST=0	=sMOVE
	GOYES	mvf310	cas "copie"
	GOTO	mvf900	cas "move" : NOP

 mvF400	GOTO	mvf400	Rallonge

 mvf310
*
* insérer
*   taille = "taille" quartets		B(A)
*   début = dstadr			A(A)
* fin insérer
*
	D0=(5)	taille
	C=DAT0	A	C(A) := taille
	B=C	A	B(A) := taille
	D0=(2)	mvbadr
	A=DAT0	A
	D1=A		D1 := ^ orghdr
	C=DAT1	A	C(A) := orghdr
	D1=D1+	(orgfin)-(orghdr)
	D1=D1+	(dstadr)-(orgfin)	D1 := ^ dstadr
	A=DAT1	A	A(A) := dstadr
*
* R3(A) = dstadr avant update (constante dans les 3 move)
*
	R3=A		R3 := dstadr avant update
*
* A(A) = starting address to move up
* B(A) = offset (dest addr - source addr)
* C(A) = addr of header
*
    if JPCPRV
	GOSBVL	=MVMEM+
    else
	GOSBVL	=MGOSUB
	CON(5)	=MVMEM+
    endif
*
* Cy = 1 : erreur (Illegal Access ou Insufficient  Mem)
*   Impossible car ces deux conditions ont été testées
*   préalablement.
* Cy = 0 : ok
* R3 est préservé de l'update et contient toujours dstadr
*
	GOSUB	syncmv	D1 = A(A) = ^ début du buffer
*
* Tester le cas particulier du cas particulier :
* orgdeb avant = dstadr avant (ex: .,.C)
* Cette égalité est transmise après le MVMEM+ dans
* l'inégalité dstadr avant < orgdeb après.
* Pourquoi ?
* Si on avait dstadr avant > orgdeb avant, le MVMEM+
* n'aurait pas modifié orgdeb. D'où :
*   => orgdeb avant = orgdeb après
*   => dstadr avant > orgdeb après
* Ce qui est le contraire de l'inégalité en cause.
* D'autre part, si on a dstadr avant = orgdeb avant,
* orgdeb avant < orgdeb après. D'où
* dstadr avant < orgdeb après. C.Q.F.D.
*
	
*
* R3(A) = dstadr avant
* D1 = ^ orghdr après
*
	D1=D1+	(orgdeb)-(orghdr)
	A=DAT1	A	A(A) := orgdeb après
	C=R3		C(A) := dstadr avant
	?C<A	A	si dstadr avant < orgdeb après
	GOYES	mvF900	sortie
*
* copier
*   début source = orgdeb
*   fin source = dstadr avant update
*   début dest = dstadr avant update
* fin copier
*

*
* D1 = ^ orgdeb
* A(A) = orgdeb après
* C(A) = dstadr avant
*
	B=A	A	B(A) := orgdeb
	B=C-B	A	B(A) := dstadr - orgdeb
*
* A(A) = source address		(orgdeb)
* B(A) = length of block	(dstadr - orgdeb)
* C(A) = dest address		(dstadr)
*
	GOSBVL	=MOVE*M
*
* Copie du dernier bloc (celui après dstadr) :
* copie
*   début source = dstadr + taille
*   fin source = orgfin après update
*   début dest = dstadr + (dstadr - orgdeb)
* fin copie
*
	D1=(5)	taille
	A=DAT1	A	A(A) := taille
	C=R3		C(A) := dstadr
	D=C	A	D(A) := dstadr
	A=A+C	A	A(A) := dstadr + taille (source adr)

	D1=(2)	mvbadr
	C=DAT1	A
	D1=C		D1 := ^ orghdr
	D1=D1+	(orgfin)-(orghdr)	D1 := ^ orgfin
	C=DAT1	A	C(A) := orgfin
	C=C-A	A	C(A) := orgfin - (dstadr + taille)
	B=C	A	B(A) := length of block

	D1=D1-	(orgfin)-(orgdeb)	D1 := ^ orgdeb
	C=DAT1	A	C(A) := orgdeb
	CDEX	A	C(A) := dstadr ; D(A) := orgdeb
	D=C-D	A	D(A) := dstadr - orgdeb
	C=C+D	A	C(A) := dstadr + (dstadr - orgdeb)
*
* A(A) = source address		(dstadr + taille)
* B(A) = length of block	(orgfin - (dstadr + taille))
* C(A) = dest address		(dstadr + (dstadr - orgdeb))
*
	GOSBVL	=MOVE*M
*
* Sortie en beauté...
*
 mvF900	GOTO	mvf900

****************************************
* Phase IV : Recopie dans le fichier
****************************************

 mvf400	GOTO	mvf490	aller directement au test
*
* Le test de sortie de boucle se trouve à la fin de
* cette boucle (mvf490)
*
 mvf405	D1=(5)	mvmem
	C=DAT1	A	C(A) := MEM (dest)
	R0=C	A	R0(A) := MEM (dest) en quartets

	D1=(2)	mvbadr
	C=DAT1	A
	D1=C		D1 := ^ orghdr
	D1=D1+	(orgdeb)-(orghdr)
	C=DAT1	A	C(A) := orgdeb
	R1=C		R1 := orgdeb
* C(A) = l2
	D1=D1+	(orgfin)-(orgdeb)
	A=DAT1	A
	R2=A		R2 := orgfin

****************************************
* Cas IV.a : prendre le nombre maximum de lignes
****************************************
*
* tant que l2 # orgfin et (l2 - orgdeb) + LIFlen(l2) > = MEM
*   l2 += LIFlen(l2)
* fin tant que
*
	GOTO	mvf420	aller directement au test
*
* Affectation des registres durant la boucle :
*   D0 = l2
*   R0 = MEM
*   R1 = orgdeb
*   R2 = orgfin
*
 mvf410
*
* D0 = l2
* A(A) = LIFlen (l2)
*
	CD0EX		C(A) := l2
	C=C+A	A	C(A) := l2 + LIFlen (l2)

 mvf420	D0=C		D0 := l2
* D0 = l2
	A=R2		A(A) := orgfin
	?A=C	A
	GOYES	mvf430	fin tant que

	A=R1		A(A) := orgdeb
	C=C-A	A	C(A) := (l2 - orgdeb)
	D=C	A	D(A) := (l2 - orgdeb)
	GOSUB	=LIFlen	A(A) := taille totale en quartets
*
* A(A) = LIFlen (l2). Le contenu de A(A) n'est plus changé
*
	C=D	A	C(A) := (l2 - orgdeb)
	C=C+A	A	C(A) := (l2 - orgdeb) + LIFlen(l2)
	B=C	A	B(A) := place nécessaire
	C=R0		C(A) := MEM
	?B<C	A	place nécessaire < MEM ?
	GOYES	mvf410	oui : on continue

*
* fin tant que :
* D0 = l2
* si l2 # orgfin alors on a A(A) = LIFlen (l2)
* R0 = MEM
* R1 = orgdeb
* R2 = orgfin
*
 mvf430	CD0EX		C(A) := l2
	D0=C		D0 := l2
	B=C	A	B(A) := l2
	C=R1		C(A) := orgdeb
	?B#C	A	Cas pathologique ?
	GOYES	Mvf450	Non. On peut copier au moins 1 ligne

****************************************
* Cas IV.b : ligne trop longue
****************************************
*
* B(A) = D0 = l2
* A(A) = LIFlen (l2)
*   (car l2 == orgdeb et on sait que orgdeb # orgfin)
* R0 = MEM
* C(A) = R1 = orgdeb
* R2 = orgfin
*
	A=B+A	A	l2 += LIFlen (l2)
	D1=(5)	mvbadr
	C=DAT1	A	C(A) =: ^ orghdr
	D1=C
	D1=D1+	(orgfin)-(orghdr)
	D1=D1+	(l2)-(orgfin)
	DAT1=A	A	l2 dans le buffer := A(A)
	GOTO	mvf445	directement sur le test du "while"

 Mvf450	GOTO	mvf450
*
* Boucle :
* Tant que orgdeb # l2
*   x := min (mem, l2 - orgdeb)
*   inserer x dans le fichier (insfil)
* fin tant que
*
 mvf440	D1=(5)	mvmem
	C=DAT1	A	C(A) := MEM (device destination)
	B=C	A	B(A) := MEM (device destination)

	D1=(2)	mvbadr
	C=DAT1	A
	D1=C
	D1=D1+	(orgdeb)-0
	A=DAT1	A	A(A) := orgdeb
	D1=D1+	(orgfin)-(orgdeb)
	D1=D1+	(l2)-(orgfin)
	C=DAT1	A	C(A) := l2
	C=C-A	A	C(A) := l2 - orgdeb
*
* B(A) = mem
* C(A) = l2 - orgdeb
*
	?C<=B	A	(l2 - orgdeb) <= mem ?
	GOYES	mvf442	oui: min := l2 - orgdeb
	C=B	A	non: min := mem
 mvf442
*
* C(A) = x
*
	GOSUB	insfil

*
* Tester la sortie de la boucle "tant que"
* Dans le buffer, on a :
*   l2 = adresse de fin de la boucle
*   orgdeb = adresse courante
* Test de fin : orgdeb == l2
*
 mvf445	D1=(5)	mvbadr
	C=DAT1	A	C(A) := ^ début des données
	D1=C
	D1=D1+	(orgdeb)-0
	C=DAT1	A	C(A) := orgdeb
	D1=D1+	(orgfin)-(orgdeb)
	D1=D1+	(l2)-(orgfin)
	A=DAT1	A	A(A) := l2
*
* C(A) = orgdeb
* A(A) = l2
*
	?C<A	A	orgdeb < l2
	GOYES	mvf440	oui : alors on répète
*
* non : fin de la boucle.
*
	GOTO	mvf490


****************************************
* Cas IV.c : on peut copier au moins une ligne
****************************************
*
* B(A) = D0 = l2
* R0 = MEM
* C(A) = R1 = orgdeb
* R2 = orgfin
*

 mvf450	B=B-C	A	B(A) := l2 - orgdeb
	C=B	A	C(A) := x

	GOSUB	insfil

*
* Test de sortie : "orgdeb == orgfin"
*
 mvf490	D1=(5)	mvbadr
	C=DAT1	A	C(A) := ^ début du buffer
	D1=C		D1 := ^ début du buffer
	D1=D1+	(orgdeb)-(orghdr)
	C=DAT1	A	C(A) := orgdeb
	D1=D1+	(orgfin)-(orgdeb)
	A=DAT1	A	A(A) := orgfin
	?A=C	A	Est-on arrivé au bout ?
	GOYES	mvf900	oui : on sort
	GOTO	mvf405	non : on continue

****************************************
* Sortie
****************************************

 mvf900
*
* Récupérer les valeurs de xxxhdr mises-à-jour et
* supprimer le buffer.
*
	GOSUB	syncmv
*
* D1 = ^ début des données
*
	A=DAT1	A	A(A) := orghdr
	R0=A
	D1=D1+	(dsthdr)-(orghdr)
	C=DAT1	A	C(A) := dsthdr
	D=C	A
*
* R0(A) = orghdr
* D(A) = dsthdr
*
	D0=(5)	mvbid
	C=DAT0	X
	GOSBVL	=I/ODAL
	A=R0
	C=D	A
*
* A(A) = orgdhr actualisé
* C(A) = dstdhr actualisé
*
	RTNCC		Pas d'erreur

************************************************************
* syncmv
*
* But: recalculer l'adresse du buffer de "MVFILE" après un
*   mouvement de mémoire.
* Entrée:
*   - mvbid = id du buffer utilisé
* Sortie:
*   - D1 = A(A) = mvbadr = adresse du buffer
* Abime: A, C(A), C(S), D1
* Appelle: IOFND0
* Niveaux: 1
* Historique:
*   88/11/06: PD/JT conception & codage
************************************************************

 syncmv	D1=(5)	mvbid
	C=DAT1	X
	GOSBVL	=IOFND0
	GONC	synerr	"System Error"
	AD1EX		A(A) := ^ buffer (début des données)
	D1=(5)	mvbadr
	DAT1=A	A	mvbadr := ^ buffer (début données)
	D1=A		D1 := ^ buffer (début des données)
	RTN

 synerr	GOVLNG	=CORUPT	C'est grave... On arrête tout

************************************************************
* memD
*
* But: calculer l'espace disponible (en quartets) dans le
*   périphérique identifié par sa caractéristique dans D(W).
*   Si le périphérique est ":MAIN", retranche le leeway.
* Entrée:
*   - D(W) = caractéristique du périphérique
* Sortie:
*   - D(W) = caractéristique du périphérique
*   - A(A) = C(A) = taille disponible en quartets
* Abime: A, C, D1,
* Appelle: FLADDR
* Niveaux: 3
* Historique:
*   88/11/06: PD/JT conception & codage
*   88/11/11: PD/JT prise en compte du Leeway
*   88/11/11: PD/JT supprime "memdev"
************************************************************

 memD	GOSBVL	=FLADDR
*
* A(A) := address of first nibble of available memory
* C(A) := address of last nibble of available memory
*
	C=C-A	A	C(A) := MEM (device)
	A=C	A	A(A) := MEM (device)
	?D#0	S
	GOYES	mem10	pas ":MAIN"
*
* On est en ":MAIN". Il faut retrancher le Leeway.
* Toutes les routines qui nous appellent appelleront aussi
* MGOSUB qui sauvegarde 6 quartets dans la pile des GOSUB.
* Il faut donc en tenir compte pour ne pas se heurter à un
* "Insufficient Memory" de la part de MVMEM+ par exemple.
*
	C=0	A
	LC(2)	(=LEEWAY)+7
	A=A-C	A
	GOC	mem20	"Insufficient Memory"
	C=A	A
 mem10	RTNCC

 mem20	GOVLNG	=CORUPT	Il ne reste même pas le LEEWAY

************************************************************
* insfil
*
* But: déplacer C quartets de l'adresse orgdeb dans le
*   fichier repéré par orghdr vers l'adresse dstadr dans le
*   fichier repéré par dsthdr.
* Entrée:
*   - C(A) = taille du bloc à insérer (symbolisé par "x")
*   - mvbadr = adresse du buffer contenant :
*	orghdr = adresse du header origine
*	orgdeb = adresse de début de l'origine
*	.... = 5 quartets inutilisés ici
*	dsthdr = adresse du header destination
*	dsthdr = adresse de la destination
*   - mvbid = id de ce buffer
*   - sMOVE = 1 s'il faut détruire le bloc origine après
* Sortie:
*   - mvbadr réajusté si besoin est
* Abime: A-D, D0, D1, R0-R3, SCRTCH(4-0)
* Appelle: MVMEM+, MOVE*M
* Niveaux: 3 (voir la note)
* Algorithme:
*   insérer
*     taille = x quartets
*     début = dstadr (qui est réactualisé)
*   fin insérer
*   copier
*     début source = orgdeb
*     taille = x quartets
*     début dest = dstadr (avant réactualisation)
*   fin copier
*   si cas "copie"
*     alors orgdeb += x
*     sinon
*	détruire
*	  début = orgdeb
*	  taille = x
*	fin détruire
*   fin si
* Note: 3 niveaux de retour sont sauvés dans un endroit où
*   ils sont réactualisés. La routine ne consomme donc
*   quasiment pas de niveau de retour.
* Note: "orgdeb" étant le point de départ de la suppression,
*   cette adresse est remise à 0 pendant la mise à jour dans
*   le buffer. Cette routine préserve cette adresse de cette
*   "mise à jour" intempestive... La valeur de "orgdeb"
*   stockée dans le buffer est donc fiable
* Historique:
*   88/11/06: PD/JT conception & codage
*   88/11/11: PD/JT ajout de la note sur "orgdeb"
*   88/11/11: PD/JT rectification de l'update de "dstadr"
************************************************************

 insfil
*
* On place la taille du bloc à deplacer (x) dans le
* registre R3 d'où elle ne bougera plus pendant tout
* reste de la routine.
*
	R3=C		R3 := taille du bloc (x)
*
* Pour commencer, on sauve des niveaux de pile dans le
* buffer, ou ils sont mis à jour en cas de mouvement
* mémoire.
*
	D1=(5)	mvbadr
	A=DAT1	A
	C=0	A
	LC(2)	(MVBUFS)-3*5
	A=A+C	A
	D1=A		D1 := ^ place pour trois adresses

	C=RSTK
	DAT1=C	A
	D1=D1+	5
	C=RSTK
	DAT1=C	A
	D1=D1+	5
	C=RSTK
	DAT1=C	A
*
* Trois niveaux de pile sont sauvés
* R3 = taille du bloc à déplacer
*

*
* insérer
*   taille = x quartets
*   début = dstadr
* fin insérer
*
	C=R3
	B=C	A	B(A) := taille

	D1=(5)	mvbadr
	A=DAT1	A
	C=0	A
	LC(2)	dsthdr
	A=A+C	A
	D1=A		D1 := ^ dsthdr
	C=DAT1	A	C(A) := header

	D1=D1+	(dstadr)-(dsthdr)
	A=DAT1	A	A(A) := starting address
*
* A(A) = starting address	(dstadr)
* B(A) = taille			(R3)
* C(A) = header			(dsthdr)
*
    if JPCPRV
	GOSBVL	=MVMEM+
    else
	GOSBVL	=MGOSUB
	CON(5)	=MVMEM+
    endif
*
* Cy = 1 : erreur
*   eILACS	(Illegal Access)
*   eMEM	(Insufficient Memory)
*   Aucune de ces deux erreurs ne peut se produire.
* Cy = 0 : ok
*   R0 = starting address of move (A(A) à l'entrée)
*   R2 = header (C(A) à l'entrée)
*
	GOSUB	syncmv	le buffer a peut-être bougé
* D1 = ^ orghdr

*
* copier
*   début source = orgdeb
*   taille = x quartets
*   début dest = dstadr (avant update)
* fin copier
*
	D1=D1+	(orgdeb)-0
	A=DAT1	A	A(A) := orgdeb

	C=R3
	B=C	A	B(A) := x

	C=R0		C(A) := adresse destination
*
* A(A) = source			(orgdeb)
* B(A) = taille			(R3)
* C(A) = destination		(R0)
*
	GOSBVL	=MOVE*M	La mémoire ne bouge pas
*
* En sortie : on a toutes les conditions d'entrée
*
	D1=(5)	mvbadr	Common Sub-expression Elimination
	C=DAT1	A
	D1=C
	D1=D1+	(orgdeb)-0
	C=DAT1	A	C(A) := orgdeb

	?ST=1	=sMOVE
	GOYES	insf50
*
* Cas "copie"
*
	A=R3		A(A) := x
	C=C+A	A	C(A) := orgdeb + x
	DAT1=C	A	orgdeb += x
 	GOTO	insf90

*
* Cas "move" : il faut détruire ce qu'on vient de copier.
*
 insf50
*
* Note speciale : orgdeb est le début de la zone à détruire.
* Le système met "orgdeb" à 0 après la destruction, car il
* considère qu'elle n'appartient plus à rien. Cela nous
* oblige donc à la sauver. Où ? Dans RSTK. C'est le plus
* simple...
*
	RSTK=C		RSTK := orgdeb

	A=C	A	A(A) := orgdeb
	A=A+B	A	A(A) := fin du bloc à détruire
	B=-B	A	B(A) := -x
	D1=D1-	(orgdeb)-(orghdr)
	C=DAT1	A	C(A) := orghdr
*
* A(A) = starting address	(orgdeb)
* B(A) = taille			(-x)
* C(A) = header			(orghdr)
*
    if JPCPRV
	GOSBVL	=MVMEM+
    else
	GOSBVL	=MGOSUB
	CON(5)	=MVMEM+
    endif
*
* Cy = 1 : erreur (Illegal Access ou Insufficient Mem)
*    Impossible eû égard aux tests préalables
* Cy = 0 : pas d'erreur
*
	GOSUB	syncmv	ajuste mvbadr
	D1=D1+	(orgdeb)-0
	C=RSTK		C(A) := orgdeb
	DAT1=C	A	orgdeb := restaure d'après RSTK
*
* Sortie.
*
 insf90
*
* Note : dstadr est actualisé par l'insertion du début. En
* cas "move", dstadr est redescendu. Dans les deux cas, la
* valeur actuelle de dstadr est la bonne, et il n'y a pas
* besoin de la changer.
*
* Restauration de trois niveaux de pile. L'adresse du
* buffer est bien dans mvbadr. Les adresses sont dépilées
* à l'envers comme il se doit...
*
	D1=(5)	mvbadr
	A=DAT1	A
	C=0	A
	LC(2)	(MVBUFS)-5
	A=A+C	A
	D1=A		D1 := ^ dernière des trois adresses

	C=DAT1	A
	RSTK=C
	D1=D1-	5
	C=DAT1	A
	RSTK=C
	D1=D1-	5
	C=DAT1	A
	RSTK=C

	RTN

	END
