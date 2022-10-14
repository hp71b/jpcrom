	TITLE  ADLEX <ad.as>

 JPCPRV	EQU	1

*
*   86/08/01: PD    Création
* JPC:B03
*   87/12/06: PD/JT Intégration dans JPC Rom
*   88/01/09: PD/JT Ajout du champ "Addr4"
*

*
* Syntaxes :
*
* ADCREATE <fichier> [, <passwd>]
* ADDELETE <fichier>, <No> [, <passwd>]
* ADFIND (<fichier>, <chaîne> [, <passwd>])
* ADGET <fichier>, <array>, <No> [, <passwd>]
* ADPUT <fichier>, <array> [, <passwd>]
* ADSIZE (<fichier> [, <passwd>])
*

************************************************************
* EQUIVALENCES
************************************************************

 point	EQU    0
 slash	EQU    1
 trouve EQU    9
 chpinf EQU    10
 sFIND	EQU    0
 sPRBLM EQU    8
 CHPMAX EQU    7	Modifié le 88/01/09


	STITLE	Utilitaires

************************************************************
* UTILITAIRES
************************************************************

************************************************************
* actufc
*
* But: actualiser le nombre de fiches et la fiche courante
*   après une suppression ou une insertion de fiche.
* Entrée:
*   - D1 = ^ début du fichier
*   - A(A) = n (numéro de la fiche en cause)
*   - B(A) = k (1 ou -1, compte à ajouter au nb de fiches)
* Abime: A(A), B(A), C(A), D1
* Niveaux: 0
* Détail:
*   Dans les deux cas (insertion ou suprression)
*     c est le numéro de la fiche courante
*     n est le numéro de la fiche ou il y a eû modification
*     k est le nombre à rajouter au nombre de fiches
*     la formule est la suivante
*	nb de fiches := nb de fiches + k
*	si n<=c alors c := c + k
*   Mais attention : c et n ne sont pas dans la même unite:
*   c varie de 0 à nb-1, alors que n varie entre 1 et nb.
*   Il faut donc faire un ajustement.
* Historique:
*   86/08/07: PD conception & codage
************************************************************
 
 actufc AD1EX		A(A) := ^ fichier; D1 := n
	C=0    A
	LC(2)  37+16
	A=A+C  A	A(A) := ^ nb de fiches
	AD1EX		D1 := ^ nb de fiches; A(A) := n
*
* Actualisation du nombre de fiches
*
* assertion: C(A) = 000xx
	C=DAT1 4	C(A) := nb de fiches
	C=C+B  A	nb fiches := nb fiches + k
	DAT1=C 4
*
* Actualisation du numéro de la fiche courante
*
	D1=D1+ 4	D1 := ^ fiche courante
	C=0    A
	C=DAT1 4	C(A) := c
*
* Ici, pour l'ajustement des unites de c et n, il faut
* n := n-1
*
	A=A-1  A	n := n-1
	?A>C   A	? n > c
	RTNYES		c reste inchange
	C=C+B  A
	DAT1=C 4
	RTN


************************************************************
* ROUTINE DE POSITIONNEMENT DANS LE FICHIER
************************************************************


************************************************************
* seekNo
*
* But: obtenir l'adresse d'une fiche à partir de son numéro.
* Entrée:
*   - STMTD1 = ^ début du fichier (le nom)
*   - STMTD0 = numéro à atteindre (numéro # 0)
* Sortie:
*   - D1 := ^ fiche (avec les 4 quartets)
* Abime:
*   - A(A), B(A), C(A), D1
* Niveaux: 0
* Historique:
*   86/07/31: PD ajout de documentation
*   86/08/06: PD interface modifiée pour ADLEX
************************************************************

 seekNo D1=(5) =STMTD0
	C=DAT1 A	C(A) := numéro à atteindre
	B=C    A	B(A) := numéro à atteindre
*
* Positionner D1 sur le nombre de fiches dans le fichier
*
	D1=D1+ 5
	A=DAT1 A	A(A) := ^ début du fichier
	C=0    A
	LC(2)  37+16
	A=A+C  A
	D1=A		D1 := ^ nombre de fiches
*
* Verifier la cohérence du numéro demandé
*
	C=0    A
	C=DAT1 4
	D1=D1+ 8	D1 := ^ première fiche (avec 4 q.)
	?B<=C	A	numéro demandé <= nombre de fiches ?
	GOYES  seek20	Ok, tout va bien
*
* L'erreur "End of File" sera la sanction implacable
*
	C=0    A
	LC(2)  =eEOFIL
	GOTO   bserr
*
* Le numéro de fiche demandé est cohérent. On y va:
*
 seek10 C=0    A
	C=DAT1 4	C(A) := longyeur de la fiche en q.
	AD1EX		A(A) := adresse de la fiche
	A=A+C  A	A(A) := adresse de la fiche suivante
	D1=A		D1 := ^ fiche suivante
 seek20 B=B-1  A
	?B#0   A
	GOYES  seek10
	RTN


************************************************************
* ROUTINES DE RECHERCHE D'UNE FICHE PAR SON NOM
************************************************************


************************************************************
* uprc$
*
* But: convertir une chaîne en majuscules
* Entrée:
*   - D1 = ^ chaîne sur la Math-Stack
*   - C(A) = longueur en octets
*   - P = 0
*   - mode Hex
* Sortie:
*   - Cy = 1
*   - A(B) = dernier caractère transféré
* Abime: A(A), B(A), C(A)
* Appelle: CNVUCR
* Niveaux: 1
* Historique:
*   86/08/01: PD ajout de documentation
************************************************************

 uprc$	B=C    A	B(A) = long. de la chaîne en octets
	GOTO   uprc20	On commence par décrémenter D1
 uprc10 GOSBVL =CNVUCR
	DAT1=A B
 uprc20 D1=D1- 2
	B=B-1  A
	GONC   uprc10
	RTN		A(B) contient le dernier caractère

************************************************************
* find/
*
* But: chercher dans une chaîne si il y a un "/"
* Entrée:
*   - FUNCD0 et FUNCD1 sont conformes à leur déf. (prpstr)
* Sortie:
*   - Cy = 1, le "/" est trouvé, D1 pointe dessus
*   - Cy = 0. Le "/" n'est pas trouvé
* Abime: A(A), B(A), C(A), D1
* Niveaux: 0
* Historique:
*   86/08/01: PD ajout de documentation
************************************************************

 find/	D1=(5) =FUNCD0	devant le premier caractère
	A=DAT1 A	A(A) := longueur en octets
	D1=D1+ 5	D1=(5) FUNCD1
	C=DAT1 A
	D1=C		D1 := ^ dans la chaîne
	B=A    A	Compteur de boucle
	LCASC  '/'
	GONC   find20	B.E.T.
* On commence par décrémenter D1
 find10 A=DAT1 B
	?A=C   B
	RTNYES		Trouvé ==> RTNSC
 find20 D1=D1- 2
	B=B-1  A
	GONC   find10
	RTNCC		On est arrivé au bout ==> non trouvé


************************************************************
* tststr
*
* But: tester la chaîne sur la Math-Stack avec un champ de
*   la fiche pointée par D0.
* Entrée:
*   - FUNCD0 et FUNCD1 correspondent à leur déf. (prpstr).
*   - D0 pointe sur la longueur du champ à comparer.
*   - ST(slash) = 1 si la recherche doit s'arrêter au "/".
* Sortie:
*   - ST(trouve) = 1 si les deux chaînes sont identiques
*	moyennant les options demandées.
*   - ST(chpinf) = 1 si le champ pointé par D0 est inférieur
*	à la chaîne sur la Math-Stack.
* Abime: A(A), B(A), C(A), D(A), D0, D1, ST(trouve)
* Appelle: CONVUC
* Niveaux: 1
* Historique:
*   86/08/01: PD ajout de documentation
************************************************************

 tststr D1=(5) =FUNCD0	Longueur de la chaîne sur la M.S.
	C=DAT1 A
	D=C    A	D(A) := LEN(chaîne sur la M.S.)
	A=DAT0 B
	B=0    A
	B=A    B	B(A) := LEN(champ pointé par D0)
	D0=D0+ 2	D0 := ^ premier caractère du champ
	D1=D1+ 5
	C=DAT1 A
	D1=C		D1 := ^ premier car. de la chaîne
	ST=0   trouve
	GONC   tst20	B.E.T.
* Boucle tant que les chaînes sont identiques
 tst10	A=DAT0 B	Caractère du champ
	D0=D0+ 2
	D1=D1- 2
	?ST=0  slash
	GOYES  tst15	Il n'y a pas de "/" dans la chaîne
	LCASC  '/'	Il faut arrêter la comparaison au /
	?A=C   B
	GOYES  chp<ms	"tot/" < "toto"
 tst15	GOSBVL =CONVUC	UPRC$
	C=DAT1 B	Caractère de la chaîne
	?A#C   B	On teste enfin les deux chaînes !
	GOYES  tst50
 tst20	D=D-1  B	Fin de la M.S.
	GOC    tst30	   "	"
	B=B-1  B	Fin du champ
	GONC   tst10
* Il en reste encore sur la M.S., mais plus dans le champ
 chp<ms ST=1   chpinf
	RTN
 tst30	?ST=0  slash
	GOYES  tst35
* On est arrive au bout de la M.S., sans avoir vu de "/"
* dans le champ. Il doit donc rester encore au moins un
* caractère dans ce champ.
	A=DAT0 B
	LCASC  '/'
	?A=C   B	Est-ce un "/"
	GOYES  chp=ms	Oui: victoire !
* Non: alors, de toutes manières, le test suivant est faux.
 tst35	?B#0   B
	GOYES  chp>ms
 chp=ms ST=1   trouve
	RTN
 tst50	?A<=C  B
	GOYES  chp<ms
 chp>ms ST=0   chpinf
	RTN


************************************************************
* strsrh, fchsrh
*
* But: Chercher une fiche dans le fichier. Le nom est à
*   extraire de la Math-Stack (strsrh), ou est déjà
*   analysé (fchsrh)
* Entrée:
*   - F-R0-0 = adresse de la première fiche
*   - F-R0-1 = nombre de fiches
*   strsrh :
*     - D1 = ^ chaîne
*   fchsrh :
*     - les flags de recherche sont positionnés
*     - la chaîne est convertie en majuscules
*     - FUNCD0 = nombres de caractères de la chaîne
*     - FUNCD1 = adresse de la chaîne
* Sortie:
*   - ST(trouve) = 1 si la chaîne a été trouvée
*   - ST(point) = 1 si la chaîne était abregée
*   - F-R0-0 = adresse de la fiche trouvée
*   - F-R0-2 = numéro de la fiche trouvée
* Abime: A-D, D0, D1, ST
* Appelle: tststr. uprc$ et find/ (strsrh seulement)
* Niveaux: 2
* Historique:
*   86/08/03: PD codage
*   86/08/12: PD ajout du point d'entrée fchsrh
************************************************************

 strsrh GOSBVL =POP1S
*
* Avant tout, est-ce une chaîne nulle ?
*
	?A#0   A
	GOYES  stsh05
	C=RSTK
	GOTO   fnrtn	On se rappelle que A(A) = 0
*
* Non, c'est bien une chaîne cohérente. On peut y aller.
*
 stsh05 CD1EX
	C=C+A  A
	D1=C		D1 := chaîne sur la M.S. (1er car)
	D0=(5) =FUNCD1
	DAT0=C A	Adresse de la chaîne
	D0=D0- 5	D0=(5) FUNCD0
	C=0    M
	C=A    A
	CSRB		C(A) := long de la chaîne en octets
	DAT0=C A
*
* La chaîne est maintenant bien reconnue, sa longueur et son
* adresse sont stockées. Il faut déterminer les flags de
* recherche :
*
	GOSUB  uprc$	A(B) := dernier car. de la chaîne
	CLRST		Tous les flags de recherche = 0
	LCASC  '.'
	?A#C   B
	GOYES  stsh10
* Le dernier caractère est un point: abréviation
	ST=1   point
	D0=(5) =FUNCD0
	C=DAT0 A
	C=C-1  A
	DAT0=C A
	GONC   stsh20	B.E.T.
*
* la chaîne n'a pas de point comme dernier caractère.
* Cherchons donc un "/" :
* S'il est trouvé, ça veut dire que la recherche
* s'effectuera sur le nom ET le prenom.
* La comparaison ne s'arrêtera donc pas dès que l'on
* trouvera un "/" dans le champ. Dans ce cas, l'indicateur
* "slash" vaut 1.
*
 stsh10 GOSUB  find/
	GOC    stsh20	/ non trouvé: On s'arrête donc au /
	ST=1   slash	Le "/" a priorité dans la recherche
*
* Les options de recherche sont connues. On peut y aller.
*
 fchsrh
 stsh20
*
* On prépare le test du nombre de fiches
*
	D1=(5) =F-R0-1	Nombre de fiches
	A=DAT1 A	A(A) := nombre de fiches
	C=0    A
	D1=D1+ 5	D1=(5) =F-R0-2
	DAT1=C A	F-R0-2 := 0
*
* La recherche n'a pas de sens si le fichier est vide
*
	?A=0   A	Yatil des fiches dans le fichier ?
	RTNYES		Non
	C=C+1  A	La fiche pointée est la première
	DAT1=C A	F-R0-2 := 1

*
* Il y a des fiches dans le fichier, la recherche peut
* commencer.
* Boucle de recherche :
*
 stsh30 D1=(2) =F-R0-0	Car D1 = F-R0-2 à cet endroit-là
	C=DAT1 A	Adresse de la fiche courante
	D0=C
	D0=D0+ 4	D0 := ^ champ (et non sur les 4 q.)
*
* Test de la nouvelle fiche
*
	GOSUB  tststr	Tester le champ pointé par D0
*
* Exploitation des résultats
*
	?ST=1  trouve
	RTNYES		Ollrayite
	?ST=0  chpinf	le fichier est trié. Si on a dépassé
	RTNYES		  la fiche, on peut s'arrêter
*
* Passage à la fiche suivante
*
	D1=(5) =F-R0-0
	C=DAT1 A	Adresse de la fiche courante
	D0=C		D0 := ^ fiche courante
	A=0    A
	A=DAT0 4	A(A) := long. en q. de la fiche
	C=C+A  A	C(A) := adresse de la fiche suivante
	DAT1=C A	F-R0-0 := ^ fiche suivante (avec lg)
*
* Apres avoir incrémenté l'adresse de la fiche,
* réactualisons le numéro de la fiche courante.
*
	D1=D1+ 5	D1 := F-R0-1 = nb de fiches
	A=DAT1 A
	D1=D1+ 5	D1 := F-R0-2 = no de la courante
	C=DAT1 A
	C=C+1  A
	DAT1=C A	F-R0-2 est incrémenté
	?C<=A  A
	GOYES  stsh30
	RTN


************************************************************
* GESTION DES ELEMENTS DE TABLEAUX ALPHANUMERIQUES
************************************************************


************************************************************
* fstelm
*
* But: renvoyer l'adresse de l'élément courant du tableau
* Entrée:
*   - S-R0-0 = ^ élément courant
* Sortie:
*   - D1 = C(A) = ^ élément courant
* Abime: D1, C(A)
* Niveaux: 0
* Detail: Je sais, c'est pas très difficile à faire...
* Historique:
*   86/08/08: PD conception & codage
************************************************************

 fstelm D1=(5) =S-R0-0
	C=DAT1 A
	D1=C
	RTN		Et 14 lignes d'en-tête pour ca !

************************************************************
* endelm
*
* But: positionner D1 après C octets.
* Entrée:
*   - D1 := ^ longueur de l'élément
*   - C(A) := nombre d'octets à passer
* Sortie:
*   - D1 = C(A) = ^ fin de l'élément (élément suivant)
* Abime: C(A), D1
* Niveaux: 0
* Detail:
*   Les éléments de tableau alphanumérique sont codés avec
*   une longueur sur 4 quartets (longueur en octets), puis
*   avec la chaîne proprement dite. Celle-ci est stockée à
*   l'envers, c'est à dire que le dernier caractère est
*   accessible en premier.
* Historique:
*   86/08/08: PD conception & codage
************************************************************

 endelm C=C+1  A
	C=C+1  A	2 octets de longueur
	C=C+C  A	traduction en quartets
	AD1EX
	A=A+C  A	A(A) := adr de la fin de l'élément
	C=A    A	C(A) := adr de la fin de l'élément
	AD1EX		D1 := adresse de la fin de l'élément
	RTN

************************************************************
* nxtelm
*
* But: calculer l'adresse du prochain élément d'un tableau
*   alphanumérique.
* Entrée:
*   - S-R0-0 = ^ élément courant du tableau alpha
*   - S-R0-1 = longueur maximum des éléments du tableau
* Sortie:
*   - S-R0-0 = D1 = C(A) = ^ élément suivant
* Abime: C(A), D(A), D1
* Appelle: fstelm, endelm
* Niveaux: 1
* Detail:
*   Cette routine ne doit pas abimer D0, A(B), C(S)
*   Cette routine est une fonction à effet de bord. En
*   effet, les appels successifs font pointer S-R0-0 sur
*   l'élément suivant à chaque fois. Ceci convient bien
*   pour un accès séquentiel aux éléments du tableau.
* Historique:
*   86/08/08: PD conception & codage
************************************************************

 nxtelm
*
* Préparation des paramètres pour "endelm", afin de
* connaître l'adresse de l'élément suivant du tableau :
*
	D1=(5) =S-R0-1
	C=DAT1 A	C(A) := longueur max d'un élément
	D=C    A
	D1=D1- 5	D1=(5) S-R0-0
	C=DAT1 A	C(A) := adresse de l'élément courant
	D1=C		D1 := ^ élément courant
	CDEX   A	D(A) := ^ courant; C(A) := long max
*
* appel à "endelm"
*
	GOSUB  endelm	C(A) = D1 := ^ élément suivant
*
* mise en forme des résultats de nxtelm
*
	D1=(5) =S-R0-0
	DAT1=C A	S-R0-0 := ^ élément suivant
	D1=C		D1 := ^ élément suivant
	RTN

*
* Renvoie l'erreur "Data Type"
*
 datatp C=0    A
	LC(2)  =eDATTY	Data type
	GOTO   bserr

************************************************************
* getary
*
* But: analyser le spécificateur du tableau, trouver
*   l'adresse du registre de la variable, et effectuer les
*   tests nécessaires.
* Entrée:
*   - D0 = ^ début du spécificateur de tableau.
* Sortie:
*   - D0 = ^ passée la spécification du tableau.
*   - A(A) = longueur maximum d'un élément.
*   - S-R0-0 = ^ premier élément du tableau.
*   - S-R0-1 = longueur maximum des éléments.
* Abime: A(A), B(A), C(W), D(A), D0
* Appelle: ADDRSS
* Niveaux: 2
* Detail: Le test sur la longueur des éléments n'est pas
*   effectué ici, puisque, d'une part, ce test n'est pas à
*   effectuer pour ADPUT, et d'autre part, l'adresse de la
*   fiche n'est pas encore connue quand ADGET appelle cette
*   routine. En fait, les tests effectués sont les tests
*   sur le type de la variable (tableau alphanumérique),
*   et sur le nombre d'éléments du tableau.
* Historique:
*   86/08/07: PD conception & codage
*   86/08/12: PD correction du bug des tableaux indirects
************************************************************

 getary D0=D0+ 2	D0 := ^ après tCOMMA
	GOSBVL =ADDRSS
* A la sortie de ADDRSS,
* Si la Cy = 1, la variable n'est pas trouvée
* Si la Cy = 0, la variable est trouvée, et :
*   D0 = B(A) = adresse du registre de la variable
*   A(A) = ^ passée la tokenisation de la variable
	GOC    datatp
* Il faut d'abord sauver le pointeur dans la chaîne
* tokenisée en lieu sûr.
	CD0EX		C(A) := ^ registre de la variable
	D0=(5) =S-R0-0
	DAT0=A A	S-R0-0 := ^ chaîne tokenisée
	CD0EX		D0 := ^ registre de la variable
*
* Tests du type de la variable trouvée
*
* Correction de la bogue des tableaux indirects. Il y a une
* une boucle de parcours de la chaîne des registres de
* variables indirectes. On sort de cette boucle dès qu'un
* registre indique que ce n'est plus un tableau indirect.
*
* Le quartet 1 d'un registre de variable indique le nombre
* de dimensions de la variable (0 pour une variable
* scalaire, 1 pour un vecteur, et 2 pour une matrice).
* Dans le cas particulier d'un tableau indirect, ce quartet
* vaut E.
*
* D0 := ^ registre de la variable
*
	LCHEX  E	E = type du tableau indirect
 gtar10 D0=D0+ 1	D0 := ^ dimension
	A=DAT0 P	A(B) := type de la variable
	?A#C   P	Tableau indirect ?
	GOYES  gtar20	Non : on regarde le type de la chose
*
* La variable est un tableau indirect. Il faut donc examiner
* ce qui est pointé par ce registre, pour continuer la
* recherche.
*
	D0=D0+ 1	D0 := ^ "pointer"
	A=DAT0 A	A(A) := ^ reg. de la var. suivante
	D0=A		D0 := ^ reg. de la var. suivante
	GONC   gtar10	B.E.T.
*
* On est donc arrivé au bout de ce chaînage des registres de
* variables. Il faut donc vérifier maintenant ce sur quoi
* nous sommes arrivés.
*
 gtar20 D0=D0- 1	D0 := ^ deux premiers quartets
	A=DAT0 B	A(B) := type de la variable
	LCHEX  1F	Tableau alphanumérique
	?A#C   B
	GOYES  datatp	"Data Type" !!!
*
* Le registre de la variable est trouvé. Il s'agit bien d'un
* tableau alphanumérique. Testons maintenant le nombre
* d'éléments de ce tableau.
*
	D0=D0+ 7	D0 := ^ dimension du tableau
	A=0    A
	A=DAT0 4	A(A) := dimension du tableau
*
* A(A) est la dimension du tableau. Calculons le nombre
* d'éléments avec l'option base.
*
	D0=D0- 5	D0 := ^ option base
	C=DAT0 S	C(S) := 0 ou 1 suivant l'option base
	?C#0   S
	GOYES  gtar30	option base = 1, A(A) est exact
	A=A+1  A	en option base 0, un élément de plus
*
* Et vient enfin le test du nombre d'éléments :
*
 gtar30 C=0    A
	LC(1)  CHPMAX	No max du champ (nb d'éléments-1)
	?C<A   A
	GOYES  gtar40
* Je sais, le message n'est pas très bon.
	C=0    A
	LC(2)  =eILVAR	Invalid Var
	GOTO   bserr
*
* Le tableau comporte au moins CHPMAX éléments. Il est
* accepté.
*
 gtar40
*
* longueur maximum des éléments du tableau :
*
	D0=D0+ 1	D0 := ^ max len
	C=0    A
	C=DAT0 4	C(A) := max len
	B=C    A	B(A) := max len
*
* Adresse du premier élément du tableau :
*
	D0=D0+ 8	D0 := ^ relative pointer
	C=DAT0 A	C(A) := relative pointer
	AD0EX		A(A) := adresse du relative pointer
	A=A-C  A	A(A) := ^ premier élément du tableau
	D0=(5) =S-R0-0
	C=DAT0 A	C(A) := ancien D0
	DAT0=A A	S-R0-0 := pointer
*
* Sauvegarde de la longueur maximum des éléments :
*
	D0=D0+ 5	D0=(5) S-R0-1
	A=B    A	A(A) := max len
	DAT0=A A	S-R0-1 := max len
	D0=C
	RTN


************************************************************
* EVALUATIONS D'EXPRESSIONS
************************************************************

************************************************************
* evalNo
*
* But: évaluer un numéro de fiche
* Entrée:
*   - D0 = ^ tCOMMA dans la ligne tokenisée
* Sortie:
*   - D0 = ^ le token suivant l'expression numérique
*   - C(A) = STMTD0 = numéro de la fiche à opérer
* Abime: tout ce qui est abimable par les fonctions
* Appelle: EXPEX-, RNDAHX
* Niveaux: 5 (EXPEX-)
* Historique:
*   86/08/06: PD conception & codage
************************************************************

 evalNo D0=D0+ 2
	GOSBVL =EXPEX-
	GOSBVL =RNDAHX
	GONC   evNoer	Entier négatif
	?A=0   A
	GOYES  evNoer
	C=A    A
	D1=(5) =STMTD0
	DAT1=C A
	RTN
 evNoer LC(4)  =eIVARG
	GOTO   bserr

************************************************************
* evalpw
*
* But: évaluer le reste de l'ordre, et rendre le passwd,
*   ou 0 s'il n'y en a pas.
* Entrée:
*   - D0 pointe sur l'expression
* Sortie:
*   (sortie par getpwd)
* Abime: tout ce qui est abimable par les fonctions
* Appelle: EXPEX-, getpwd
* Niveaux: 5
* Historique:
*   86/08/06: PD conception & codage
************************************************************

 evalpw A=DAT0 B
	D0=D0+ 2
	GOSBVL =EOLXCK
	GOC    gtpw00	    Il n'y a pas de passwd ==> 0
*
* Il y a un passwd, et il faut donc évaluer l'expression.
*
	GOSBVL =EXPEX-

*     !!! Le code continue dans getpwd !!!

************************************************************
* getpwd
*
* But: récupérer le passwd qui est dans la Math-Stack,
*   et le stocker dans FUNCR0.
* Entrée:
*   - D1 pointe sur le string-header de la chaîne
* Sortie:
*   - D1 pointe passée la chaîne
*   - C(W) = FUNCR0 = passwd, cadré avec des octets nuls
* Abime: A-C, D1
* Appelle: POP1S
* Niveaux: 2
* Historique:
*   86/08/02: PD codage
************************************************************

 getpwd GOSBVL =POP1S	A(A) = longueur en quartets
	CD1EX
	D1=C
	C=C+A  A	C(A) := ^ début de la chaîne
	D1=C		D1 := ^ début de la chaîne (1er car)
	B=C    A	B(A) := ^ début de la chaîne
	C=0    W
* L'adresse finale de D1 est calculée. Tests sur la longueur
	?A=0   A
	GOYES  gtpw00	Tout est Ok, D1 est bien positionné
	A=A-1  A
	C=A    A	C(W) := 00000000000lllll
	ASR    A	Si A=0, c'est que longueur <= 8 car.
	?A=0   A
	GOYES  gtpw10
	C=0    A
	LCHEX  F	Troncature à 8 caractères
 gtpw10 AD1EX
	A=A-C  A	D1 := ^ premier caractère du passwd
	D1=A
	D1=D1- 1	Pour ajustement précis
	P=C    0
	C=0    A	C(W) := 0 (C(15-5) non modifié)
	C=DAT1 WP	C(W) := passwd, cadré avec des 0
	P=     0
	A=B    A
	D1=A
	GONC   gtpw01
 gtpw00 C=0    W
 gtpw01 AD1EX
	D1=(5) =FUNCR0
	DAT1=C W
	AD1EX
	RTN

************************************************************
* ckaccs
*
* But: vérifier que le fichier est bien accessible, c'est à
*   dire que le type est bien ADRS, et que le passwd est
*   le bon.
* Entrée:
*   - D1 ^ début du fichier
*   - FUNCR0 contient le passwd donné par l'utilisateur
* Sortie:
*   Accès légal:
*     Cy = 1
*     D1 pointe sur le passwd dans le fichier
*   Accès illégal:
*     Cy = 0
*     C(3-0) = numéro d'erreur
* Abime: A-D, D1, R0-R2
* Appelle: LOCADR
* Niveaux: 3
* Détail:
*   vérifier le type (eFTYPE)
*   vérifier la présence en RAM (eFACCS)
*   selon passwd fichier
*     nul: ok
*     non nul: si passwd fichier # passwd utilisateur
*		  alors erreur (eFPROT)
*		  sinon ok
*	       finsi
*   finselon
* Historique:
*   86/08/02: PD codage
*   86/08/06: PD remplacé le test de ram par GOSUB ckram
*   86/08/09: PD remplacé le GOSUB ckram par un test direct
************************************************************

 ckaccs D1=D1+ 16	D1 := ^ type du fichier
	A=0    A
	A=DAT1 4	A(A) := type du fichier
	LC(5)  =fADRS
	?A=C   A
	GOYES  ckac10	Type reconnu
	C=0    A
	LC(2)  =eFTYPE	Invalid File Type
	RTNCC
*
* le type est reconnu. Vérifions maintenant que le fichier
* n'est pas en EEPROM ou en ROM :
*
 ckac10 CD1EX		C(A) := ^ type du fichier
	GOSBVL =LOCADR	A(A) = R2 = D1 := ancien C(A)
	GONC   ckac20	Ok
 ckacer C=0    A
	LC(2)  =eFACCS	"Illegal Access"
	RTNCC		Retour avec erreur si ROM ou EEPROM
 ckac20 ?D=0   S
	GOYES  ckac30	D=0 ==> MAIN ==> RAM ==> Ok
	D=D-1  S
	?D#0   S	D=1 ==> PORT & RAM ==> Ok
	GOYES  ckacer	ce n'était pas le cas.	Erreur.
*
* Le fichier est bien en RAM. Il ne reste plus qu'à vérifier
* le passwd, et ce sera fini...
*
 ckac30 D1=D1+ 16
	D1=D1+ 5	D1 := ^ passwd fichier
	AD1EX		A(A) := ^ passwd fichier
	D1=(5) =FUNCR0
	C=DAT1 W	C(W) := passwd utilisateur
	D1=A		D1 := ^ passwd fichier
	A=DAT1 W	A(A) := passwd fichier
	?A=0   W
	RTNYES
	?A=C   W
	RTNYES
	C=0    A
	LC(2)  =eFPROT
	RTN		Cy = 0 car le test était faux

	STITLE	Mots-clefs

************************************************************
* ADSIZE
*
* But: retourner le nombre de fiches du fichier indiqué.
* Entrée:
*   - le nom du fichier (alphanumérique)
*   - le passwd optionnel (alphanumérique)
* Sortie: (numérique)
*   - Si il n'y a pas d'erreur: le nombre de fiches
*   - Si il y a erreur: le numéro de l'erreur en négatif
* Abime: tout ce qui est abimable par les fonctions
* Appelle: fnentr, fnfile, D1MSTK et AVE=D1.
* Niveaux: 4 niveaux sont autorisés pour les fonctions
* Detail: la syntaxe est ADSIZE (<fichier> [, <passwd>])
* Historique:
*   86/08/02: PD réecriture
************************************************************

************************************************************
* fnrtn
*
* But: sortir proprement d'une fonction
* Entrée:
*   - AVMEME contient le pointeur de Math-Stack actualisé de
*     telle manière que le dernier paramètre soit passé.
*   - A(A) = résultat de la fonction en hexadécimal .
*   - D0 est dans la pile de sauvegarde de RSTK
* Sortie: Pas de sortie, fnrtn va directement à EXPR
* Historique:
*   86/08/09: PD Ajout de documentation
************************************************************

	NIBHEX 4412	1er et 2eme param. alpha.
=ADSIZEe
	LC(1)  1	un seul paramètre obligatoire
	GOSUB  fnentr
*
* Chercher le fichier
*
	GOSUB  fnfile	D1 := ^ passwd dans le fichier
*
* Le fichier est trouvé, et on y a accès
*
	D1=D1+ 16	D1 := ^ nb de fiches
	A=0    A
	A=DAT1 4	A(A) := nb de fiches en hexa
*
* Retour à Basic avec conversion du nombre hexa dans A(A)
*
 fnrtn	GOSUB  d1mstk
	GOSBVL =HDFLT	A(W) := nb de fiches en décimal
*
* Négation du résultat si il y a eû problème
*
	?ST=0  sPRBLM
	GOYES  frtn10
	A=-A-1 S
*
* On restaure l'environnement
*
 frtn10 SETHEX
	D1=D1- 16
	DAT1=A W	Ecriture du nombre sur la Math-Stack
	GOSBVL =RSTK<R	Restauration d'1 niveau de pile (D0)
	C=RSTK
	CD0EX
	GOVLNG =EXPR

************************************************************
* fnentr
*
* But: entrer dans une fonction, sauvegarder D0 et installer
*   le passwd en lieu sûr (FUNCR0).
* Entrée:
*   C(0) = nombre de paramètres si il n'y a pas de passwd
*   C(S) = nombre de paramètres de la fonction
*   D1 = ^ math-stack
*   D0 = program counter
* Sortie:
*   D0 = FUNCR0
*   D1 pointe passe le passwd, et sauvegardé dans AVMEME
*   FUNCR0 contient le passwd
* Abime: A, B, C, D1, D0
* Appelle: R<RSTK, getpwd
* Niveaux: 1
* Historique:
*   86/08/03: PD codage
************************************************************

 fnentr A=C    W	On sauvegarde tout de suite les prm
	C=RSTK		L'appelant de fnentr
	R0=C		R0 := adresse de l'appelant
	CD0EX
	RSTK=C
	GOSBVL =R<RSTK
	C=R0		C(A) := adresse de l'appelant
	RSTK=C		On a remis l'adresse de l'appelant
*
* traitement du passord. Si le A(S) = A(0), alors il n'y a
* pas de passwd, et il faut l'initialiser à 0. Sinon, on lit
* dans la math-stack.
*
	C=A    S	C(S) := nb de paramètres transmis
	ASRC		A(S) := nb de paramètres obligatoire
	?A=C   S
	GOYES  fnen10	Pas de passwd ==> passwd := 0
	GOTO   getpwd	Il faut récuperer le passwd dans MS
 fnen10 GOTO   gtpw00

************************************************************
* fnfile
*
* But: analyser le nom du fichier, et trouver son adresse.
* Entrée:
*   - D1 pointe sur la chaîne représentant le fichier
* Sortie:
*   Si il n'y a pas eû d'erreur, D1 pointe sur la passwd
*     dans le fichier.
*   Si il y a eû erreur, le contrôle est donné à fnerr,
*     avec le numéro de l'erreur dans C(A)
* Abime: tout (FILXQ$)
* Appelle: AVE=D1, D1MSTK, R<RSTK, RSTK<R, FILXQ$, FINDF+,
*   ckaccs
* Niveaux: 4 + 1 sauvegarde
* Historique:
*   86/08/03: PD codage
************************************************************

************************************************************
* fnerr
*
* But: prendre en charge l'exécution quand il y a eû erreur
* Entrée:
*   - C(3-0) = numéro de l'erreur
*   - PC est sauvegardé dans la pile de retours auxiliaire
*   - D1 pointe passés tous les paramètres
* Sortie:
*   - sPRBLM = 1
*   - A(A) contient ABS(résultat)
*   le contrôle est renvoyé à fnrtn pour le retour à Basic
* Abime: A(A), C(A), sPRBLM
* Niveaux: 0
* Historique:
*   86/08/03: PD codage
************************************************************

 fnfile GOSUB  ave=d1
*
* on a sauvegardé D1 pour le cas où il y aurait une erreur
* dans FILXQ$. On sauvegarde maintenant un niveau de pile,
* car FILXQ$ ne nous en laisse pas beaucoup.
*
	GOSBVL =R<RSTK	Sauvegarder l'adresse de l'appelant
*
* analyse (dans le contexte d'une fonction) de la syntaxe
* du nom de fichier.
*
	GOSBVL =FILXQ$	A(W) := nom; D(S) := type
	GOC    fnfl10	Mainfrm-recognizable filespec. found
*
* Il y a eû erreur (j'en etait sûr !). Le code d'erreur va
* être placé, négatif, sur la Math-Stack. Pour cela, il faut
* que D1 ait la bonne valeur.
*
	GOSUB  d1mstk	On restaure D1
	GOSBVL =POP1S
	CD1EX
	C=C+A  A
	D1=C		D1 := début de la chaîne (fin MS)
	GOSUB  ave=d1
	LC(4)  =eFSPEC
*
* fnfler: enlève un niveau de pile de sauvegarde, et
* branche sur la routine d'erreur de fonction.
*
 fnfler A=C    A
	GOSUB  rstk<r
	C=RSTK
	C=A    A
*
* fnerr: on attend dans C(3-0) le numéro de l'erreur
*
 fnerr	ST=1   sPRBLM
	CSL    A
	CSR    A	C(4) := 0; C(0-3) := numéro d'erreur
	A=C    A
	GOTO   fnrtn
*
* Le nom du fichier est valide. Reste à trouver ce fichier
*
 fnfl10 GOSUB  ave=d1
	GOSBVL =FINDF+
	GOC    fnfler
*
* le fichier est trouvé, D1 pointe sur le début du fichier
*
	GOSUB  ckaccs	Vérifie l'accès (type, passwd)
	GONC   fnfler	L'accès au fichier est impossible
*
* L'accès au fichier est correct.
*
	ST=0   sPRBLM
	GOSUB  rstk<r
	RTN

 rstk<r GOVLNG =RSTK<R

 ave=d1 GOVLNG =AVE=D1
 d1mstk GOVLNG =D1MSTK


************************************************************
* ADFIND
*
* But: trouver la fiche dont le nom est donné.
* Entrée:
*   - Le nom du fichier (alphanumérique)
*   - le nom à chercher (alphanumérique)
*   - le passwd optionnel (alphanumérique)
* Sortie: (numérique)
*   Si il y a erreur: le numéro de l'erreur en négatif
*   Si la fiche n'est pas trouvée: 0
*   Si la fiche est trouvée: le numéro de la fiche
* Abime: tout ce qui est abimable par les fonctions
* Appelle: 
* Niveaux: 4 niveaux sont valables pour les fonctions
* Detail: la syntaxe est ADFIND (<fichier>,<nom>[,<passwd>])
* Historique:
*   86/08/03: PD codage
************************************************************

	NIBHEX 44423
=ADFINDe 
	LC(1)  2
	GOSUB  fnentr	Entrée dans la fonction
*
* Sauvegarde de D1 (c'est l'adresse du nom à chercher)
*
	CD1EX
	D1=(5) =FUNCR1
	DAT1=C A	FUNCR1 := D1
	D1=C
*
* On passe le nom pour trouver le fichier
*
	GOSBVL =POP1S
	CD1EX
	C=C+A  A
	D1=C
*
* Passage aux choses sérieuses: il faut trouver le fichier
*
	GOSUB  fnfile	D1 := ^ passwd dans le fichier
*
* Le fichier est trouvé, et accessible. Stockons quelques
* valeurs relativement importantes :
*
	D1=D1+ 16	D1 := ^ nb de fiches
	C=0    A
	C=DAT1 4
	D1=D1+ 8	D1 := ^ première fiche (avec la lg)
	AD1EX
	D1=(5) =FUNCR0
	DAT1=A A	F-R0-0 := adresse première fiche
	D1=D1+ 5	D1=(5) F-R0-1
	DAT1=C A	F-R0-1 := nombre de fiches
*
* Il ne reste plus qu'à faire la recherche
* Mais tout d'abord, il faut récupérer D1 :
*
	D1=D1+ (=FUNCR1)-(=F-R0-1)
	C=DAT1 A
	D1=C		D1 := ^ chaîne à chercher
*
* Recherche:
*
	GOSUB  strsrh	F-R0-2 := numéro de la fiche trouvée
*
* Résultats:
*
	D0=(5) =F-R0-2
	A=DAT0 A	A(A) := numéro de la fiche
	?ST=1  trouve
	GOYES  FND10
	?ST=1  point
	GOYES  FND10
	A=0    A
 FND10	GOTO   fnrtn	Retour à Basic


************************************************************
* getfil, file?
*
* But: analyser le spécificateur de fichier, trouver
*   l'adresse de ce fichier, et la mettre en lieu sûr.
* Différences: getfil est équivalent à file?, avec la
*   caracteristique supplémentaire que l'indicateur sFIND
*   est mis à 0 systématiquement. Autrement dit, getfil est
*   utilisable par ADPUT, ADGET, ADDELETE alors que ADCREATE
*   appelle getfi- en mettant l'indicateur sFIND à 1 pour
*   savoir si le fichier existe déjà.
* Entrée:
*   - D0 = ^ début du spécificateur de fichier.
* Sortie:
*   - D0 = ^ passée la spécification du fichier.
*   - file? seulement:
*	B(A) # 0 si le fichier existe
*	STMTR0 = nom du fichier (A en sortie de FSPECx)
*	STMTR1 = device information (D en sortie de FSPECx)
*   - getfil seulement:
*	D1 = ^ début du fichier
*	STMTD1 = ^ début du fichier
* Abime: A-D, D1, R0-R3, STMTR1, STMTD0, S0, S1, S2, S7
*   D0 (getfil), STMTR0 (file?)
* Appelle: FSPECx, FINDF
* Niveaux: 7 (FSPECx)
* Detail: 
*   Sorties possibles sur erreur:
*     Invalid Filespec (FSPECx)
*     File Not Found   (FINDF)
* Historique:
*   86/08/06: PD conception & codage
************************************************************

 file?	ST=1   sFIND	On veut seulement résultat booléen
	GOTO   gtfl10	  du type "fichier existe ou non"
 getfil ST=0   sFIND	Analyse complète du nom du fichier
 gtfl10 GOSBVL =FSPECx	Analyse de la spécification
	GOC    bserr	Cy = 1 <==>  erreur dans l'analyse
	?A=0   W	A = 0  <==>  pas de nom de fichier
	GOYES  fspece
*
* Le nom du fichier est correct. Voyons si le périphérique
* demandé l'est, lui:
*
 gtfl20 C=0    S
	?C=D   S	?D=0
	GOYES  gtfl30	oui: ":MAIN"
	C=C+1  S
	?C=D   S	?D=1
	GOYES  gtfl30	":PORT"
	C=0    S
	C=C-1  S
	?C=D   S	?D=#F
	GOYES  gtfl30	aucun périphérique demandé
*
* Le spécificateur de fichier indique qu'il est externe.
*
* fspece : Le nom du fichier n'a pas été donné. Seule la
* spécification du périphérique l'a été (par ex. :TAPE).
* "Invalid Filespec" sera le verdict implacable.
*
 fspece C=0    A
	LC(2)  =eFSPEC
 bserr	GOVLNG =BSERR
*
* Le nom du fichier est correct. Cherchons donc ce fichier
* dans les "file-chain" spécifiées par D(S) et D(X). Mais
* sauvons d'abord le nom dans un endroit sûr :
*
 gtfl30 ?ST=0  sFIND	getfil n'a pas besoin de toutes ces
	GOYES  gtfl40	  informations
	D1=(5) =STMTR0
	DAT1=A W	STMTR0 := nom du fichier
	D1=D1+ 16	D1=(5) STMTR1
	C=D    W
	DAT1=C W	STMTR1 := Device info (D(S) et D(X))
*
* Le nom du fichier est sauvegardé, on peut chercher le
* le fichier.
*
 gtfl40 GOSBVL =FINDF	Recherche du fichier
	B=0    A
	GOC   gtfl50	Cy = 1 <==> fichier non trouvé
	B=B+1  A	Fichier trouvé
*
* B(A) == si fichier trouvé alors #0
*			    sinon =0
*
 gtfl50 ?ST=1  sFIND
	RTNYES		C'est terminé pour "file?"
*
* getfil continue: il faut maintenant sortir en erreur si le
* fichier n'existe pas.
*
	?B#0   A	Le fichier existe-t-il ?
	GOYES  gtfl60
	GONC   bserr	C(A) := le numéro d'erreur
*
* le fichier existe. Il ne reste plus qu'à sauvegarder son
* adresse pour que le code appelant ne soit pas obligé de le
* faire.
*
 gtfl60 CD1EX
	D1=(5) =STMTD1
	DAT1=C A	STMTD0 := ^ début du fichier
	CD1EX
	RTN

 Bserr	GOTO   bserr

************************************************************
* ADCREATE
*
* But: créeer un fichier de type ADRS
* Entrée:
*   - le nom du fichier
*   - le passwd (optionnel)
* Abime: tout ce qui est abimable par un statement
* Appelle: file?, CRETF+, evalpw
* Niveaux: 7 niveaux sont autorisés pour les statements
* Detail: la syntaxe est ADCREATE <fichier> [, <passwd>]
* Historique:
*   86/08/05: PD réécriture du poll pCRT=8 en ADCREATE
*   86/08/06: PD modifié évaluation passwd car D0 bougeait
************************************************************

	REL(5) =ADCREATEd
	REL(5) =ADCREATEp
=ADCREATEe
	GOSUB  file?	Le fichier existe-t-il ?
	?B=0   A
	GOYES  CRT10
	C=0    A
	LC(2)  =eFEXST
	GOTO   bserr
*
* Le fichier n'existe pas encore, il n'y a qu'à le créer...
* Mais auparavant, peut-être faudrait-il chercher le passwd,
* s'il existe :
*
***********************
* NOTE:
*   Le passwd est évalué ici, et non plus à la fin (après la
* création du fichier. La raison en est que si le Lex ne
* bouge pas, il n'en est pas de même pour la chaîne
* tokenisée. En effet si cette chaîne est dans le buffer
* d'exécution, elle est après l'espace des fichiers. Une
* création décale cette chaîne.
* C'est donc la raison pour laquelle l'évaluation du passwd
* est placée ici.
***********************
 CRT10	GOSUB  evalpw	FUNCR0 := passwd (ou 0 si yapa)
*
* Maintenant, il faut réunir toutes les conditions d'entrée
* de CRETF+. A savoir: D(W) = device information, A(W) = nom
* du fichier, et C(A) = taille du fichier:
*
	D1=(5) =STMTR1	D1 := ^ device information
	C=DAT1 W
	D=C    W
* Taille du fichier à créer :
	C=0    A
	LC(2)  37+16+2*4 C(A) := taille fichier ADRS vide
* Et la creation :
	GOSBVL =CRETF+	Théoriquement, on ne doit pas bouger
	GOC    Bserr
*
* Le fichier est créé, il ne reste plus qu'à l'initialiser
* avec les bonnes choses...
*
	C=R1		C(A) := ^ début du fichier
	D1=C
* Initialisation du nom :
	D0=(5) =STMTR0	D1 := ^ sauvegarde du nom
	A=DAT0 W
	DAT1=A W	nom du fichier := nom sauvegarde
* initialisation du type :
	D1=D1+ 16
	LC(4)  =fADRS
	DAT1=C 4	type du fichier := ADRS
* Initialisation du mot de passe
	D1=D1+ 16
	D1=D1+ 5
	D0=(2) =FUNCR0	car D0 valait STMTR0 avant
	C=DAT0 W
	DAT1=C W
* Initialisation du nombre de fiches et de la fiche courante
	D1=D1+ 16
	C=0    W
	DAT1=C 8	nb fiches := 0; fiche courante := 0
	GOVLNG =NXTSTM

 BserR	GOTO   bserr

************************************************************
* ADDELETE
*
* But: detruire une fiche donnée par son numéro.
* Entrée:
*   - le nom du fichier
*   - le numéro de la fiche
*   - le passwd (optionnel)
* Abime: tout ce qui est abimable par les fonctions
* Appelle: getfil, evalNo, evalpw, seekC, RPLLIN
* Niveaux: 7 niveaux sont autorisés pour les statements
* Detail: la syntaxe est ADDELETE <fichier>,<No> [,<passwd>]
* Historique:
*   86/08/06: PD conception & codage
************************************************************

	REL(5) =ADDELETEd
	REL(5) =ADDELETEp
=ADDELETEe
*
* Evaluation des paramètres
*
	GOSUB  getfil	STMTD1 := ^ début du fichier
	GOSUB  evalNo	STMTD0 := No de la fiche
	GOSUB  evalpw	FUNCR0 := passwd
*
* On teste l'accessibilite du fichier
*
	D1=(5) =STMTD1
	C=DAT1 A
	D1=C		D1 := ^ début du fichier
	GOSUB  ckaccs
	GONC   BserR	Cy = 0	<==>  Acces non légal
*
* Ok, on y va:
*
	GOSUB  seekNo	D1 := adresse de la fiche
* Longueur de la fiche :
	C=0    A
	C=DAT1 4	C(A) := longueur de la fiche
	R3=C		R3 := longueur de la fiche
* Adresse du dernier quartet + 1 de la vieille ligne :
	AD1EX		A := adresse de la fiche
	A=A+C  A	A(A) := adresse du dernier quartet+1
* Mise en place de la ligne de remplacement
	GOSBVL =OBCOLL	(OUTBS)=(AVMEMS) (nulle car insert.)
* Adresse du début du fichier :
	D1=(5) =STMTD1
	C=DAT1 A	C(A) := adresse du début du fichier
*
* Et le remplacement proprement dit :
*
    if JPCPRV
	GOSBVL =RPLLIN
    else
	GOSBVL =MGOSUB
	CON(5) =RPLLIN
    endif
	GOC    BserR	eMEM ou eILACS
*
* Réactualisation du nombre de fiches et de la courante
*
	D1=(5) =STMTD0
	A=DAT1 A	n (fiche supprimée)
	D1=D1+ 5
	C=DAT1 A
	D1=C		adresse du fichier
	B=0    A
	B=B-1  A	k := -1 (constante à ajouter)
	GOSUB  actufc	Actualisation du compte de fiches
*
* Retour à Basic si tout s'est bien passé.
*
	GOVLNG =NXTSTM

 strovf C=0    A
	LC(2)  =eSTROV	"String Overflow"
 BSerr	GOTO   bserr

************************************************************
* ADGET
*
* But: remplir le tableau alphanumérique avec la fiche dont
*   le numéro est donné.
* Entrée:
*   - le nom du fichier
*   - le nom du tableau alphanumérique
*   - le numéro de la fiche
*   - le passwd (optionnel)
* Abime: tout ce qui est abimable par les fonctions
* Appelle: getfil, getary, evalNo, evalpw, seekNo, ckaccs,
*   fstelm, nxtelm, endelm
* Niveaux: 7 niveaux sont autorisés pour les statements
* Détail: la syntaxe ADGET <fichier>,<array>,<No>[,<passwd>]
* Historique:
*   86/08/07: PD conception & codage
************************************************************

	REL(5) =ADGETd
	REL(5) =ADGETp
=ADGETe
*
* Récupération et validation des paramètres
*
	GOSUB  getfil	STMTD1 := ^ début du fichier
	GOSUB  getary	S-R0-0 := ^ 1er élém. S-R0-1:=maxlen
	GOSUB  evalNo	STMTD0 := numéro de la fiche
	GOSUB  evalpw	FUNCR0 := mot de passe
*
* Vérification de l'accès
*
	D1=(5) =STMTD1
	C=DAT1 A
	D1=C		D1 := ^ début du fichier
	GOSUB  ckaccs	Vérification de l'accès
	GONC   BSerr	Accès illégal
*
* Accès à la fiche dont le numéro est donné :
*
	GOSUB  seekNo	D1 := ^ fiche (avec les 4 quartets)
	CD1EX		C(A) := ^ fiche
	D=C    A	D(A) := ^ fiche (boucle d'après)
	D0=C
	D0=D0+ 4	D0 := ^ premier champ
	D1=(5) =S-R0-1
	A=DAT1 A	A(A) := lg max des éléments du tab.

************************************************************
* Quelques petites assertions :
* S-R0-0 = ^ premier élément du tableau alphanumerique
* S-R0-1 = longueur maximum des éléments du tableau
* STMTD0 = numéro de la fiche (plus necessaire)	
* STMTD1 = ^ début du fichier (plus necessaire)
* FUNCR0 = passwd	      (plus necessaire)
************************************************************

*
* Maintenant, il faut vérifier que chaque champ rentre bien
* dans le tableau avant de commencer à remplir quoi que ce
* soit. Dans l'absolu, il suffirait que le maximum des
* longueurs  soit inférieur à la longueur maximum des
* élément. Mais en fait, la longueur de chaque champ est
* testée par rapport à la longueur maximum des éléments,
* individuellement.
*

* Préparation du compteur de boucle :
	LC(1)  CHPMAX	Compteur de boucle
	CSRC		C(S) := compteur de boucle
*
* Pour la boucle de vérification de la longueur :
*   A(A) = longueur maximum des éléments du tableau
*   C(S) = Compteur de boucle
*   D0 := ^ longueur du champ courant
* Note: D(A) contient l'adresse début la fiche (avec long.)
* Note: D1 et A(A) ne sont pas modifiés par la boucle
*
 GET10	C=0    A	Pas pour comparer, pour plus tard
	C=DAT0 B	C(B) = longueur du champ courant
	?C>A   B	String Overflow ?
	GOYES  strovf
*
* Le champ rentre bien dans un élément du tableau. Calculons
* à présent l'adresse de la longueur du champ suivant :
*
	C=C+1  A	Un octet de plus pour la lg du champ
	C=C+C  A	Conversion en quartets
	AD0EX		A(A) := adresse du champ courant
	A=A+C  A	A(A) := adresse du champ suivant
	AD0EX		D0 := adresse du champ suivant
	C=C-1  S
	GONC   GET10
*
* La longueur des champs de la fiche est correcte. On peut
* donc commencer à remplir le tableau. Préparons la boucle :
*

* Préparation de l'adresse de la fiche
	C=D    A	C(A) := adr de la fiche (avec long.)
	D0=C		D0 := adresse de la fiche
	D0=D0+ 4	D0 := ^ premier champ
* Preparation de l'adresse de l'élément du tableau :
	GOSUB  fstelm	D1 := ^ T$(0)/T$(1) suivant la base
* Compteur de boucle :
	LC(1)  CHPMAX
	CSRC		C(S) := compteur de boucle
*
* Pour la boucle externe :
*   C(S) = compteur de boucle
*   D0 = adresse de la longueur du champ de la fiche
*   D1 = adresse de la longueur de l'élément du tableau
*
 GET20
*
* En premier lieu, mettre la longueur de T$(I) à la longueur
* du champ en cours de recopie :
*
	A=0    A
	A=DAT0 B	A(A) = A(B) = nb d'octets du champ
	DAT1=A 4	LEN(T$(I)) := A(B)
	C=A    A
* Préparation du pointeur dans le tableau
*   D1 = ^ élément
*   C(A) = longueur en octets de la chaîne
	GOSUB  endelm	D1 := ^ fin de la chaîne
*
	GOTO   GET40
*
* Pour la boucle interne :
*   C(B) = compteur de boucle
*   D0 = adresse du prochain caractère dans la fiche
*   D1 = adresse du prochain caractère dans le tableau
*
 GET30	C=DAT0 B
	DAT1=C B
 GET40	D0=D0+ 2
	D1=D1- 2
	A=A-1  B
	GONC   GET30
*
* En sortie de boucle interne :
*   A(B) = FF
*   D0 = adresse de la longueur du champ suivant
*   D1 = ? dans T$(I)
*
	GOSUB  nxtelm
	C=C-1  S
	GONC   GET20
*
* En sortie de boucle externe :
*   A(B) = FF
*   D(S) = F
*   D0 = adresse de la longueur de la fiche suivante
*
* C'est fini !
* Retour à Basic
*
	GOVLNG =NXTSTM

 BSErr	GOTO   bserr
 Chpovf	GOTO   chpovf

************************************************************
* ADPUT
*
* But: insérer une fiche (le tableau alphanumérique) dans le
*   fichier d'adresses nommé.
* Entrée:
*   - le nom du fichier
*   - le nom du tableau alphanumérique
*   - le passwd (optionnel)
* Abime: tout ce qui est abimable par les fonctions
* Appelle: getfil, evalpw
* Niveaux: 7 niveaux sont autorisés pour les statements
* Detail: la syntaxe est : ADPUT<fichier>,<array>[,<passwd>]
* Historique:
*   86/08/12: PD conception & codage
************************************************************

	REL(5) =ADPUTd
	REL(5) =ADPUTp
=ADPUTe
*
* Récupération des paramètres
*
	GOSUB  getfil	STMTD1 := ^ début du fichier
	GOSUB  getary	S-R0-0 := ^1er élém.; S-R0-1:=maxlen
	GOSUB  evalpw	FUNCR0 := mot de passe
*
* Vérification de l'accès
*
	D1=(5) =STMTD1
	C=DAT1 A
	D1=C		D1 := ^ début du fichier
	GOSUB  ckaccs	Vérification de l'acces
	GONC   BSErr
*
* Transfert des éléments du tableau dans OUTBS, et
* vérification en même temps que la longueur de chaque
* élément ne dépasse pas 89 (c'est à dire 96 - 1 (retour
* chariot) - 6 (intitulés de chp))
*
	D0=(5) =S-R0-3
	C=0    A
	DAT0=C 1	Numéro du champ := 0
* Mise à 0 du buffer
	GOSBVL =OBCOLL
	D0=C		D0 := ^ buffer
	D0=D0+ 4	D0 := ^ champ "Nom/Prenom"
	CD0EX		C(A) := ^ fin du buffer
	D0=(5) =AVMEMS
	DAT0=C A
	ST=0   slash
*
* Boucle externe de recopie :
*   AVMEMS pointe sur le dernier champ recopié
*   S-R0-3 contient le champ en cours de recopié
*   S-R0-0 pointe sur T$(I)
*
* Premier travail : récupérer la longueur de T$(I)
 PUT010 GOSUB  fstelm	D1 := ^ l'élément du tableau
	A=0    A
	A=DAT1 4	A(A) := LEN(T$(I))
* On vérifie maintenant que ça rentre bien dans un champ de
* fichier ADRS :
	C=0    A
	LC(2)  89	C(A) := 89
	?A>C   A
	GOYES  Chpovf
* Reste-t-il assez de mémoire pour recopier le champ ?
	C=A    A	C(A) := lg de la chaîne en octets
	C=C+1  A	+ 1 pour la longueur
	C=C+C  A	C(A) := longueur en quartets
	GOSBVL =MEMCKL
	GOC    BSErr	"Insufficient Memory"
*
* Il y a assez de place pour recopier le champ.
* Allons-y :
*
	GOSUB  fstelm	D1 := ^ longueur de T$(I)
	D0=(5) =AVMEMS
	C=DAT0 A
	D0=C		D0 := ^ premier champ non occupé
	C=0    A
	C=DAT1 4	C(A) := LEN(T$(I))
	DAT0=C B	LEN(champ(I)) := LEN(T$(I))
	D=C    A	D(A) := compteur de boucle
	GOSUB  endelm	D1 := ^ premier caractère de T$(I)
	LCASC  '/'
	GOTO   PUT030
*
* Dans la boucle interne de recopie, 
*   D1 := ^ T$(I)[J+1,J+1]
*   D0 := ^ champ(i)[J,J]
*   D(A) := compteur de boucle
*   C(A) := '/'
*
 PUT020 D1=D1- 2
	A=DAT1 B
	DAT0=A B
	?ST=1  slash	Doit-on rechercher un '/' ?
	GOYES  PUT030	Non
	?A#C   B	Oui. Est-ce un '/' ?
	GOYES  PUT030	Non
	ST=1   slash	Oui. Le '/' a été vu.
 PUT030 D0=D0+ 2
	D=D-1  A
	GONC   PUT020
*
* A la fin de la boucle interne de recopie, 
*   ST(slash) = 0 si aucun '/' n'a été trouvé (ceci ne peut
*		  arriver que sur le premier champ)
*   D0 = ^ passe le dernier caractère du champ
*   D1 = ^ dernier caractère de T$(I)
*   C(B) = '/' (utile dans 3 lignes)
*
	?ST=1  slash	Doit-on rajouter un '/' ?
	GOYES  PUT040	Non
* aucun '/' n'a été vu (ne peut arriver que ds le 1er champ)
	DAT0=C B	caractère suivant de la fiche := '/'
	D0=D0+ 2
 PUT040 D1=(5) =AVMEMS
	CD0EX
	A=DAT1 A	A(A) := ^ longueur du champ recopié
	DAT1=C A	Sauvegarde de la fin du buffer

	?ST=1  slash	Doit-on incrémenter la lg du champ ?
	GOYES  PUT050	Non.
	D0=A
	A=DAT0 B	A(B) := longueur du champ
	LC(2)  89
	?A=C   B	Juste, juste à 1 pres ?
	GOYES  chpovf
	A=A+1  B
	DAT0=A B
	ST=1   slash	Le '/' a été vu (cestnousquonlamis)
*					It is a french joke
 PUT050 GOSUB  nxtelm
	D0=(5) =S-R0-3	Numéro du champ courant
	A=DAT0 1
	A=A+1  P
	DAT0=A 1
	LC(1)  CHPMAX
	?A>C   P
	GOYES  PUT100
	GOTO   PUT010
*
* "String Overflow" pour "field overflow"
*
 chpovf C=0    A
	LC(2)  =eSTROV
	GOTO   bserr
*
* Fin de la boucle externe de recopie
*   S-R0-3 := CHMPMAX + 1
*   OUTBS et AVMEMS Ok, le buffer est correct
*   
 PUT100
*
* Calcul de la longueur de la fiche
*
	D0=(5) =AVMEMS
	A=DAT0 A	A(A) := ^ fin de la fiche
	D0=D0- 5	D0=(5) =OUTBS
	C=DAT0 A	C(A) := ^ début de la fiche
	D0=C		D0 := ^ début de la fiche
	A=A-C  A	A(A) := taille de la fiche en q.
	DAT0=A 4	LEN(fiche) := A(A)
*
* recopie du champ "nom" au sommet de la Math-Stack
*
****************
* Le code qui suit est la recopie de la routine fch>ms qui 
* figure dans le code de KA
****************
*
	D0=D0+ 4	Adresse du premier champ (le nom)
	A=0    A
	A=DAT0 B	A(A) := nb de caractères à recopier
	D1=(5) =FUNCD0
	DAT1=A A	Longueur de la chaîne sur la M.S.
	B=A    A	B(A) := nombre de boucles
	GOSBVL =COLLAP	Cy := 0; Utilise C(A), D1
	D1=(5) =FUNCD1
	DAT1=C A
	D1=C
	GOSBVL =D=AVMS	Ne modifie pas Cy; Utilise C(A) D(A)
	GONC   PUT120	B.E.T.
 PUT110 D0=D0+ 2
	A=DAT0 B
	GOSBVL =CONVUC	UPRC$ pour la recherche
	C=A    B
	GOSBVL =STKCHR
 PUT120 B=B-1  A
	GONC   PUT110
	CLRST		Flags de recherche = avec /, sans .
*
* Préparation des arguments pour fchsrh
*
	D1=(5) =STMTD1	adresse du fichier
	A=DAT1 A
	C=0    A
	LC(2)  37+16
	A=A+C  A	A(A) := adresse du nb de fiches
	D0=A   A	D0 := ^ nb de fiches
	LC(2)  8
	A=A+C  A	A(A) := adresse de la 1ère fiche
	C=DAT0 4	C(A) := nombre de fiches
	D1=(2) =F-R0-0
	DAT1=A A	F-R0-0 := adresse de la 1ère fiche
	D1=D1+ 5	D1=(5) =F-R0-1
	DAT1=C A	F-R0-1 := nombre de fiches
*
* Recherche de la fiche dans le fichier
*
	GOSUB  fchsrh
*
* Expolitation des résultats, préparation des paramètres de
* RPLLIN :
*
	C=0    A	Longueur de la ligne à remplacer = 0
	R3=C		  car insertion
	D0=(5) =STMTD1	adresse début du fichier (en-tête)
	C=DAT0 A	C(A) := ^ en-tête du fichier
	D0=(2) =F-R0-0	adresse de la ligne trouvée
	A=DAT0 A	A(A) := ^ ligne juste après
*
* R3 = 0
* A(A) := ^ ligne suivante
* C(A) := ^en-tête du fichier
*
    if JPCPRV
	GOSBVL =RPLLIN
    else
	GOSBVL =MGOSUB
	CON(5) =RPLLIN
    endif
	GOC    BSERr
*
* Actualisation des pointeurs du fichier
*
	D0=(5) =STMTD1	adresse du début du fichier
	C=DAT0 A
	D1=C		D1 := ^ fichier
	D0=(2) =F-R0-2
	A=DAT0 A	A(A) := No de la fiche devant
	   *		laquelle il y a eû insertion
	B=0    A
	B=B+1  A	k := 1
	GOSUBL actufc
*
* Retour à Basic
*
	GOVLNG =NXTSTM

 BSERr	GOTO   bserr

	END
