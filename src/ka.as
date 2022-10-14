	TITLE  KA <ka.as>

 JPCPRV	EQU	1
 
************************************************************
* Rev. A : 85/09/00 -> 85/12/05
************************************************************
* Rev. B : 86/07/26 -> 86/07/30
*   Nouveaux ID/Token/Type de fichier alloués par HP
*   Password de longueur supérieure à 8 se comporte comme le
*     password standard
*   L'affichage ne reste plus lors du retour à Basic
*   Le fichier par défaut est ADRS (et non plus ADRESSES)
*   Les messages ont été traduits en anglais (et les champs
*     élargis à 5 caractères)
*   Lors de l'affichage de "Not Found", DELAY est respecté
*   La répétition automatique est supportée
*   Extinction automatique au bout de 10 minutes
*   Le type ADRS comporte maintenant un "subheader" de 24
*     quartets
*   Il n'y a plus de problème pour l'édition de la dernière
*     fiche
*   La structure interne du fichier n'est plus LIF
*   La touche CAT est étendue pour les fichiers en IRAM
*   Les fichiers en ROM ou EEPROM ne sont plus édités
*   L'interface "Pocket Secretary" est définie et implantée
*   KA :<device> n'est plus accepté (c'était une bogue)
*   Le prompt du password est remplacé par: "KA password ? "
************************************************************
* JPC:C  : 87/12/06 -> 88/01/31
*   Intégration dans JPCROM
*   Ajout du champ "Addr4"
*   Utilisation du poll de FINPUT
* JPC:C03 : 88/04/16 -> 88/04/16
*   Utilisation de INENDL pour s'intégrer au poll de FINPUT
************************************************************
 
************************************************************
* EQUIVALENCES
************************************************************
 
 point	EQU    0
 slash	EQU    1
 trouve EQU    9
 chpinf EQU    10
 CHPMAX EQU    7	Modifié le 88/01/09


************************************************************
* seekC, seekA
*
* But: obtenir l'adresse d'une fiche à partir de son numéro.
* Entree:
*   seekC
*     - dans les deux cas, la "statement scratch" doit être
*	valide, c'est à dire que STMTD0, STMTD1, S-R1-2
*	doivent être conformes à leur définition.
*     - C(A) = numéro de la fiche à atteindre
*   SeekA:
*     - STMTD0 pointe sur la fiche courante
*     - A(A) = nombre de fiches à sauter
* Sortie:
*   - D0 = C(A) = adresse de la fiche (après la longueur)
*   - STMTD0 indéfini pour seekC
* Abime:
*   - A(A), B(A), C(A), D0, (STMTD0 pour seekC)
* Niveaux: 0
* Historique:
*   86/07/31: ajout de documentation
************************************************************
 
 seekC	D0=(5) =S-R1-2	No de la fiche pointée par STMTD0
	A=DAT0 A
	?C>=A  A	No demandé >= No déjà pointé ?
	GOYES  seek10	Oui: on part de la position actuelle
	D0=(2) =STMTD1	Non: on repart du début.
	A=DAT0 A	Adresse du fichier (partie données)
	AD0EX
	D0=D0+ 12	Première fiche (après la long.)
	AD0EX		A(A) := ^ première fiche
	D0=D0- 5	D0=(5) STMTD0
	DAT0=A A	Nouvelle adresse de la fiche
	A=0    A	Première fiche du fichier
*
* A(A) = le No de la fiche dont l'adresse est dans STMTD0
* C(A) = le No de la fiche à atteindre
* STMTD0 = l'adresse de la fiche courante
*
 seek10 ACEX   A	A=No à atteindre. C=No déjà acquis.
	A=A-C  A	Nb de boucles
*
* Dans A(A): nombres de fiches à sauter
* Dans STMTD0: l'adresse de la fiche à partir de laquelle la
*   recherche a lieu.
*
 seekA	B=A    A	B(A) := Nb de fiches à sauter
	D0=(5) =STMTD0
	C=DAT0 A	C(A) := adresse de la fiche courante
	D0=C		D0 sera le pointeur dans le fichier
	D0=D0- 4	D0 := ^ longueur de la fiche
	GONC   seek30	B.E.T.
*
* for B(A) := B(A) downto 1 do D0 := D0 + LEN(fiche) end ;
*
 seek20 C=0    A
	C=DAT0 4	Longueur de la fiche, en quartets
	AD0EX
	C=C+A  A
	D0=C		D0=début de la fiche
 seek30 B=B-1  A
	GONC   seek20
 
	D0=D0+ 4	Début des données
	CD0EX
	D0=C		Pour avoir la réponse dans D0 et C
	RTN
 
************************************************************
* afch05, afch20
*
* But: obtenir l'adresse du champ C(S) d'une fiche
* Entree:
*   - C(S) = numéro du champ (0..CHPMAX)
*   afch05: STMTD0 = adresse de la fiche courante
*   afch20: D0 = adr. du premier champ (sur la lg du champ)
* Sortie:
*   - D0 = adr. du premier caractère du champ (après la lg)
*   - C(B) = longueur en octets de ce champ
* Abime: D0, C(A), C(S), A(A)
* Niveaux: 0
* Historique:
*   86/08/01: ajout de documentation
************************************************************

************************************************************
* affchp
*
* But: afficher le champ dont le numéro est dans S-R1-3.
* Entree:
*   - S-R1-3 (1 q) = numéro du champ à afficher (0..CHPMAX)
*   - STMTD0 = adresse de la fiche courante (après la long.)
* Sortie:
*   - P = 0; Cy = 0 (conditions de DSPCNA)
* Abime: P, A-D, D0, D1, R0(10-5), R1, R2
* Appelle: afch05, tombe dans DSPCNA
* Niveaux: 3
* Historique:
*   86/08/01: ajout de documentation
************************************************************
*
 afch05 D0=(5) =STMTD0	Adresse de la fiche courante
	C=DAT0 A
	D0=C		D0 := Adresse de la fiche courante
	GOTO   afch20
*
* for C(S) := C(S) downto 0 do D0 := D0 + 2*LEN(champ) end;
*
 afch10 C=C+C  A	Taille du champ en quartets
	AD0EX
	A=A+C  A	Adresse de la long. du champ suivant
	D0=A		D0 := ^ champ suivant (sur la lg)
*
* D0 := adresse du champ courant (sur la longueur)
* C(S) := nombre de champs à sauter - 1
*
 afch20 C=0    A
	C=DAT0 B	C(A) := Long. du champ en octets
	D0=D0+ 2	D0 := ^ premier car. du chp courant
	C=C-1  S
	GONC   afch10
	RTN		C(B) = long. du champ à afficher
*
*
 affchp D0=(5) =S-R1-3	Afficher le champ S-R1-3
	C=DAT0 S	C(S) := numéro du champ à afficher
	GOSUB  afch05	D0 := adr du premier car. du champ
	AD0EX
	D1=A		D1 := adr du premier car. du champ
	A=C    A	A(B) := nombre d'octets à afficher
*
* dspcna : nombre d'octets dans A(B) (au lieu de A(A))
* dspcnc : nombre d'octets dans C(B) (au lieu de C(A))
*
 dspcna C=A    B
 dspcnc A=0    A
	A=C    B
	GOVLNG =DSPCNA
 
 
************************************************************
* chpedt
*
* But: placer D0 sur le champ édité (dans le buffer
*   d'édition)
* Entree:
*   - STMTR1 (1 quartet) : numéro du champ à afficher
* Sortie:
*   - D0 = adresse du premier caractère du champ
*   - C(A) = longueur du champ en octets (C(4-2)=0)
* Abime: A(A), C(S), C(A), D(A), D0
* Appelle: LDCSET, tombe dans afch20
* Niveaux: 2
* Detail: les No de champ en cours d'édition sont en STMTR1
* Historique:
*   86/08/01: ajout de documentation
************************************************************

 chpedt D0=(5) =STMTR1	Numéro du champ à éditer
	C=DAT0 A
	CSRC		C(S) = numéro du champ
	GOSUB  ldcset	D0 := (OUTBS)
	D0=D0+ 4	Début (longueur) du premier champ
	GOTO   afch20	Adresse du champ de la fiche D0
 
************************************************************
* valide
*
* But: valider le champ dans le display buffer et le stocker
*   dans la fiche en cours d'édition dans OUTBS.
* Entree:
*   - STMTR1 = no champ en cours d'édition
*   - AVMEMS, OUTBS = buffer d'entrée
* Sortie:
*   - AVMEMS réactualisé
* Abime: A(A), C(S), C(A), D(A), D0
* Appelle: prpstr, find/, chpedt, MEMCKL, MOVE*M
* Niveaux: 6
* Detail: code utilisé par edtEND et edtRUN
* Historique:
*   88/01/09: isolement dans un sub
************************************************************
 
 valide
	P=     3
	GOSBVL =R<RSTK
	GOSUB  prpstr	envoi de la chaine entrée sur la MS
	D0=(5) =STMTR1
	C=DAT0 A	C(A) = No du champ
	?C#0   A
	GOYES  val095
* Le champ "Nom/Prénom" doit contenir un "/",
* de gré ou de force
	GOSUB  find/	Recherche du "/"
	GOC    val095	Trouvé
	D0=(5) =FUNCD0	Non trouvé, il faut le rajouter
	C=DAT0 A
	C=C+1  A
	DAT0=C A	1 caractère de plus
	C=C+C  A	Longueur en quartets = déplacement
	D0=D0+ 5	D0=(5) FUNCD1
	A=DAT0 A	Adresse de la chaîne sur la M.S.
	A=A-C  A	Adresse de la fin de la chaîne
	D1=A		D1 := ^ premier car après la chaîne
	LCASC  '/'
	DAT1=C B	Et hop !
*
* Remplacement de l'ancien champ par celui qui vient d'être
* édité opération en plusieurs étapes :
*
* 1: vérification qu'il reste suffisamment de place
 val095 GOSUB  chpedt	D0 ^ chp à remplacer
	D1=(5) =STMTR0
	DAT1=C B	Longueur de l'ancien champ
	D1=D1+ 2
	AD0EX
	DAT1=A A	Adresse du champ en question
	D1=(2) =FUNCD0
	A=DAT1 A	Taille chaîne sur la M.S. en octets
	C=A-C  A	Nouveau - Ancien
	GOC    val100	Nouveau < Ancien
	?C=0   A	Nouveau=Ancien : on ne modifie rien.
	GOYES  val150
	C=C+C  A	Taille supplémentaire (en octets)
	GOSBVL =MEMCKL	Memory Check With Leeway
	GONC   val100
	GOVLNG =BSERR	Insufficient Memory
* 2: calcul des blocs à déplacer, et déplacement
 val100 D1=(5) 2+=STMTR0
	C=DAT1 A	Adresse du champ
	D0=(5) =FUNCD0
	A=DAT0 A	Lg de la nouvelle ligne en octets
	A=A+A  A	  "		        "  quartets
	C=C+A  A	Dest address
	RSTK=C
	A=DAT1 A	Adresse du champ
	D1=D1- 2	STMTR0
	C=0    A
	C=DAT1 B	Lg de l'ancienne ligne en octets
	C=C+C  A	 "		       "  quartets
	A=A+C  A	Source address
	D1=(5) =AVMEMS
	C=DAT1 A
	C=C-A  A	Block length
* A(A)=source add ; C(A)=Block Length ; RSTK=dest addr
	B=C    A
	C=RSTK
	GOSUB  move*m
* A(A)=source ; C(A)=dest ; B(A)=length
*
* 3: ajustement des pointeurs
	C=C-A  A	dest-source
	D1=(5) =AVMEMS
	A=DAT1 A
	C=C+A  A
	DAT1=C A	Réactualisation de AVMEMS
* 4: déplacement du champ édité depuis la Math-Stack
*    jusqu'au buffer
 val150 D1=(4) 2+=STMTR0 Adresse du champ (cf. val100)
	C=DAT1 A
	D0=C
	D0=D0- 2	Adresse de la longueur du champ
	D1=(2) =FUNCD0	Longueur de la chaîne sur la M.S.
	C=DAT1 A
	DAT0=C B
	B=C    B	B(B)=Nb de caractères à transférer
	D1=D1+ 5
	C=DAT1 A
	D1=C
	GONC   val170	B.E.T.
 val160 D1=D1- 2	boucle de transfert
	C=DAT1 B
	D0=D0+ 2
	DAT0=C B
 val170 B=B-1  B
	GONC   val160
	P=     3
	GOSBVL =RSTK<R	Ne pas enlever le GOSBVL / RTN sans
	RTN		avoir etudié la question...

************************************************************
* prpstr
*
* But: préparer une chaîne sortie de CHEDIT pour traitement
* Entree:
*   - La chaîne est dans le "display buffer"
* Sortie:
*   - la chaîne est sur la Math-Stack
*   - C(A) = FUNCD0 = longueur de la chaîne en octets
*   - D1 = FUNCD1 = adresse du premier caractère (plus 2)
* Abime: A-D, ST, D0, D1, R1, P
* Appelle: FINLIN, COLLAP, DSP$00, POP1S
* Niveaux: 5 (FINLIN)
* Detail:
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 prpstr GOSUB  finlin	CR-LF
	ST=1   0	Pour retour après DSP$00
	GOSBVL =COLLAP	pointeur de MTHSTK
	D1=C		^ Math-Stack
	GOSBVL =DSP$00	Construit la chaîne sur la M.S.
	GOSBVL =POP1S	A(A)=longueur en quartets, y compris
	CD1EX		  le CR de la fin laissé par DSP$00.
	C=C+A  A	C(A) := ^ premier car. de la chaîne
	D0=(5) =FUNCD1
	DAT0=C A	FUNCD1=Adresse du premier car. (+2)
	D1=C
	A=A-1  A
	A=A-1  A	A(A) := longueur en quartets
	C=0    M
	C=A    A
	CSRB		C(A) := longueur en octets
	D0=D0- 5
	DAT0=C A	FUNCD0 = lg de la chaîne en octets.
	RTN
 
************************************************************
* uprc$
*
* But: convertir une chaîne en majuscules
* Entree:
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
*   86/08/01: ajout de documentation
************************************************************
 
 uprc$	B=C    A	B(A) = longueur chaîne en octets
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
* Entree:
*   - FUNCD0 et FUNCD1 sont conformes à leur déf. (prpstr)
* Sortie:
*   - Cy = 1, le "/" est trouvé, D1 pointe dessus
*   - Cy = 0. Le "/" n'est pas trouvé
* Abime: A(A), B(A), C(A), D1
* Niveaux: 0
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 find/	D1=(5) =FUNCD0	devant le premier car. de la chaîne
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
* SD1sve, SD1res
*
* But: sauvegarder et restaurer STMTD1 dans S-R1-1 (édition)
* Abime: C(A), D1
* Niveaux: 0
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 SD1sve D1=(5) =STMTD1
	C=DAT1 A
	D1=D1- 16	S-R1-1
	DAT1=C A
	RTN
 SD1res D1=(5) =S-R1-1
	C=DAT1 A
	D1=D1+ 16	STMTD1
	DAT1=C A
	RTN
 
************************************************************
* fkey
*
* But: mettre une touche en premier dans le key-buffer
* Entree:
*   - R3(B) = code physique de la touche (IDS2, page 12-13)
* Abime: A(A), B(A), C(A), D0
* Niveaux: 0
* Detail: INTON et INTOFF sont utilisés ici
* Historique:
*   86/08/01: ajout de documentation
*   89/06/17: utilisation dans XEDIT
************************************************************
 
=fkey	C=0    A	Entrée: R3(B)=physical key-code
	LC(2)  28	Nb de quartets du KEYBUF à déplacer
	B=C    A	> Nb de quartets à déplacer
	LC(5)  =KEYBUF
	A=C    A	> Adresse origine
	C=C+1  A
	C=C+1  A	> Adresse destination
	INTOFF
	GOSUB  move*m	Déplacer 14 entrées du KEYBUF
	C=R3		La touche à insérer
	D0=(5) =KEYBUF
	DAT0=C B	Insertion effectivement réalisée
	D0=D0- 1	D0=(5) KEYPTR
	C=DAT0 S
	C=C+1  S	Une touche de plus si
	GOC    fkey10	c'est possible
	DAT0=C S
 fkey10 INTON
	RTN
 
************************************************************
* pass
*
* But: traiter l'introduction du passwd (en entrée, ou KEY)
* Entree:
*   - STMTD1 surle début du fichier (après le passwd)
* Sortie:
*   - D0 = ^ passwd dans le fichier
*   - P = 0
*   si Cy = 0
*	D(W) = passwd, cadre avec des 0
*   si Cy = 1
*	D(W) = 0 : rien n'a été rentré
*	D(W) # 0 : introduction non valide (ex: [f][OFF])
* Abime: tous les registres, S-R1-0
* Appelle: chedit, FINLIN, prpstr, DSPCNA
* Niveaux: 5
* Detail: l'introduction du passwd ne sort pas sur la vidéo.
*   Ceci est réalisé en annulant DSPCHX pendant
*   l'introduction. Si le délai de 10 mn intervient, on sort
*   simplement avec une erreur comme si on avait appuyé sur
*   [f] [OFF].
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 pass	D0=(5) =DSPCHX
	C=DAT0 A	Adresse d'affichage périphérique
	A=0    A	On met 0 à la place
	DAT0=A A
	D0=(4) =S-R1-0	On sauvegarde l'ancien dans S-R1-0
	DAT0=C A
	GOSUB  pass10	juste en dessous. Si, si !
 pass05 NIBASC 'KA '
	NIBASC 'password'
	NIBASC ' ? '
 pass10 C=RSTK		C(A) := adresse du message
	D1=C		D1 := adresse du message
	LC(2)  ((pass10)-(pass05))/2   C(B) := lg du msg
	GOSUB  dspcnc
	GOSUB  chedit	Introduction du password.
	D=0    A
	D=D-1  A	D(A) # 0
	?A#0   A	A(A) = terminateur de la ligne
	GOYES  pass30	C'est un terminateur normal
* Non: c'est une touche à exécution immédiate
*
 pass20 GOSUB  finlin	La ligne est terminée
*
* pass21: remet DSPCHX en place, et laissé dans D0 l'adresse
*   du password dans le fichier.
* En outre, Cy = 1 à la fin
*
 pass21 D0=(5) =S-R1-0	Sauvegarde de DSPCHX
	C=DAT0 A
	D0=(4) =DSPCHX
	DAT0=C A	Ouf ! On peut revoir ce qu'on fait !
	D0=(4) =STMTD1	Adresse du nb max. de fiches
	C=DAT0 A
	D0=C
	D0=D0- 16	D0 := ^ password
	RTNSC		Pour retour avec erreur...
*
* pass30: verification de la syntaxe du password
*
 pass30 LC(2)  13
	?A#C   B
	GOYES  pass20	Pas [ENDLINE]: erreur (avec f[OFF])
* Mise à niveau de la chaîne
	GOSUB  prpstr	A(A)=lg en quartets, C(A) en octets,
	 *		D1 pointe sur la chaîne
* Vérification de la longueur
*
	D=C    A	D(A) := lg en octets de la chaîne
	?D=0   A
	GOYES  pass21	Lg nulle : aucune introduction
	C=0    A
	LC(2)  8
	?D<=C  A	Lg >= 8  <==> Lg = 8
	GOYES  pass40
	A=C    A	Troncature à 16 quartets
	A=A+A  A	A(A) := 16
*
* La longueur en quartets est dans A(A)
* et 2 <= A(A) <= 16, et A(A) = 2k pour k dans Z
* D1 := ^ la chaîne
*
* introduction dans D(W)
*
 pass40 C=A    A
	C=C-1  A
	P=C    0	P = longueur en quartets - 1
	AD1EX		A(A) := adr de la chaîne
	A=A-C  A	A(A) := adr de la FIN de la chaîne
	A=A-1  A	... à un chouillas près !
	D1=A
	C=0    W	Pour le cadrage avec des 0
	C=DAT1 WP	Recopie de ce qu'il faut juste
	P=     0	P = 0 en sortie
	D=C    W	D(W) := password
	GOSUB  pass21	pass21 retourne avec Cy = 1
	RTNCC		!!! Attention. Ne pas simplifier !!!
 
************************************************************
* Num2D1
*
* But: traduire un nombre en décimal et transférer sa
*   représentation alpha dans le buffer pointé par D1
* Entree:
*   - Nombre en hexa dans A(A)
*   - D1 pointe sur le premier caractère à renvoyer
*   - P = 0
* Sortie:
*   - D1 pointe après le dernier caractère envoyé
*   - mode = hex
*   - P = 0
*   - Cy = 1
* Abime: A(A), B(A), C(A), D1
* Appelle: HEXDEC
* Niveaux: 1
* Historique:
*   86/07/31: supprimer la boucle infinie quand A(A) = 0
*   86/08/01: ajout de documentation
*   89/06/17: utilisation dans XEDIT
************************************************************
 
=Num2D1 ?A=0   A	Nb dans A(A), P=0
	GOYES  num15
	GOSBVL =HEXDEC	Résultat dans A,B,C
	SETHEX		Le mode est laissé DEC après HEXDEC
* Boucle de comptage du nombre de chiffres
	P=     7	Max=1048575, bien qu'on y arrive
 num10	P=P-1		rarement
	?A=0   P
	GOYES  num10
* num15: P = nombre de chiffres à envoyer - 1
 num15	C=P    15	C(S) := nb de chiffres à afficher-1
* préparation de A(W) pour la boucle d'envoi
 num20	ASRC
	P=P-1
	?P#    #F
	GOYES  num20
	P=     0
* Fin de la boucle, A(W) := C1 C2 ... Cn 0 ... 0
	LCASC  '0'	Pour ajouter à tous les Ci
	P=C    15	P := nombre de chiffres à envoyer
* Boucle d'envoi des chiffres
 num30	ASLC		A(W) := Ci+1 ... Cn 0 ... 0 Ci
	A=A+C  B	A(B) := représentation Ascii
	DAT1=A B	envoi dans le buffer
	D1=D1+ 2
	A=0    A	Pour le chiffre suivant
	P=P-1
	GONC   num30
	P=     0	En sortie: A(W)=0, P=0, Cy=1
	RTN
 
************************************************************
* keywt
*
* But: attendre une pression de touche de l'utilisateur. Les
*   touches de curseur horizontal sont autorisées pour le
*   déroulement de l'affichage.
* Entree: -
* Sortie:
*   - A(B), B(B) := code physique touche (IDS2, p. 12-13)
*   - Cy = 1
* Abime: A-D, D0, D1, P, 32 nibs at SCRTCH (CKSREQ)
* Appelle: SCRLLR, CKSREQ, POPBUF, ATNCLR
* Niveaux: 6
* Detail: L'extinction automatique au bout de 10 minutes se
*   traduit par l'absence de retour. Cette routine va
*   directement à l'extinction de KA.
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 keywt	GOSBVL =SCRLLR	Voir KEYWAIT$ (JPC No 20), sauf que
	GONC   kwt10	  là, les touches de déroulement de
	GOSBVL =CKSREQ	  l'affichage sont supportées.
	GOTO   keywt
 kwt10	GOSBVL =POPBUF
	GOSUB  atnclr	Abime A(A)
	A=B    A	Pour compatibilité avec FINDA
	LC(2)  =k#OFF
	?A#C   B
	RTNYES		Retour à l'appelant
	GOLONG OFF	Aller directement s'éteindre
 
************************************************************
* tststr
*
* But: tester la chaîne sur la Math-Stack avec un champ de
*   la fiche pointée par D0.
* Entree:
*   - FUNCD0 et FUNCD1 : voir prpstr
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
*   86/08/01: ajout de documentation
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
* On est arrivé au bout de la M.S., sans avoir vu de "/"
* dans le champ. Il doit donc rester encore au moins un
* caractère dans ce champ.
	A=DAT0 B
	LCASC  '/'
	?A=C   B	Est-ce un "/" ?
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
* search
*
* But: chercher une fiche dans le fichier par son nom
* Entree:
*   - STMTD0, STMTD1, S-R1-2 correspondent à leur définition
*   - ST(point) = 1 pour une recherche abrégée
*   - ST(slash) = 1 pour une recherche sur le prénom
* Sortie:
*   - ST(trouve) = 1 si la recherche est fructueuse
*   - C = (STMTD0) = adresse de la fiche trouvée
*   - D1 = STMTD0
* Abime: A(A), B(A), C(A), D(A), ST(trouve, chpinf), STMTD0,
*   S-R1-2
* Appelle: tststr, seekC, seekA
* Niveaux: 1+1 (RSTK=C)
* Detail: Si le nom est supérieur à celui de la dernière
*   fiche, D1 est placé après cette fiche (c'est à dire sur
*   une fiche qui n'existe pas).
*   Du fait des contextes dans lesquels est appelée cette
*   fonction, STMTD0 et S-R1-2 sont modifiés.
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 search D0=(5) =STMTD0
	C=DAT0 A
	D0=C		D0 := ^ fiche courante
	GOSUB  tststr	? Chaîne = fiche courante
	?ST=1  trouve
	RTNYES		Oui, tout est Ok
	C=0    A	Non, il faut parcourir le fichier
	?ST=0  chpinf
	GOYES  srh10	On reprend à la première fiche
	D0=(5) =S-R1-2	On continue à partir de la courante
	C=DAT0 A
* C(A) = numéro de la fiche en cours
 srh10	RSTK=C		svg du numéro de la fiche en cours
* Obtention de la fiche suivante
	GOSUB  seekC	D0 := C := adresse de cette fiche
	D1=(5) =STMTD0
	DAT1=C A	Nouvelle adresse de fiche courante
	C=RSTK		Numéro de cette fiche
	D1=D1- 6	D1=(5) S-R1-2
	DAT1=C A
* Test de la nouvelle fiche
	GOSUB  tststr	Tester le champ pointé par D0
	?ST=1  trouve
	RTNYES		Ollrayite
	?ST=0  chpinf	le fichier est trié. Si on a depassé
	RTNYES		  la fiche, on peut s'arrêter
* Passage à la fiche suivante
	D1=(5) =STMTD1	Adresse du fichier
	A=DAT1 A
	D1=A		D1 ^ nb max de fiches
	A=0    A
	A=DAT1 4	A(A)=Nb max de fiches (1..m)
	D1=(5) =S-R1-2
	C=DAT1 A	No de la fiche courante.
	C=C+1  A	Numéro de la fiche suivante
	?C<A   A	Est-on encore dans le fichier ?
	GOYES  srh10	Oui: continuer à explorer
	?ST=1  point	Non. Etait-ce une recherche abrégée?
	RTNYES		Oui: Sortir ici, la dernière fiche
	DAT1=C A	Non. On se positionne sur la
	A=0    A	dernière qui n'est pas encore créée.
	A=A+1  A
	GOSUB  seekA	On saute la dernière fiche
	D1=(5) =STMTD0
	DAT1=C A	STMTD0 = C = adr après la dernière
	RTN		  fiche
 
 atnclr GOVLNG =ATNCLR
 finda	GOVLNG =FINDA
 ldcset GOVLNG =LDCSET
 move*m GOVLNG =MOVE*M
 
************************************************************
* editfc
*
* But: Editer complètement une fiche
* Entree:
*   - D0 = adresse de la fiche (avec la longueur)
*   - C(A) = longueur de la fiche en quartets
* Sortie:
*   - ST(slash, point) est positionné pour la recherche
*   - FUNCD0 et FUNCD1 représentent le nom
* Abime: tout sauf STMTD0, STMTD1 et S-R1-2
* Appelle: OBCOLL, MEMCKL, MOVE*M, ESCSEQ, CURSFL, finlin,
*   attn, prpstr, find/, chpedt, ldcset, COLLAP, D=AVMS,
*   CONVUC STKCHR.
* Niveaux: Tous sauf un pour l'appelant
* Historique:
*   86/07/26: traduction des noms de champ en anglais
*   86/08/01: ajout de documentation
************************************************************
 
* Y a t-il assez de place ?
 editfc RSTK=C		C = Nb de quartets (fiche)
	GOSBVL =OBCOLL	AVMEMS=OUTBS (Utilise C(A) D1)
	C=RSTK
	GOSBVL =MEMCKL	Utilise (A,B,C)(A) D1. A(A)=(AVMEMS)
	GONC   edt005
	GOVLNG =BSERR	Insufficient memory
* Déplacement de la fiche dans le buffer
 edt005 C=A    A	C=Dest address (AVMEMS)
	AD0EX		A=source address
	GOSUB  move*m
	C=C+B  A	Dest addr + length in nibs
	D1=(5) =AVMEMS
	DAT1=C A
	C=0    A	No du chp
	D0=(5) =STMTR1
	DAT0=C A
* affichage de l'intitulé du champ
 edt010 D0=(5) =STMTR1	On ne sait pas d'où on vient
	C=DAT0 A	C(A)=No du champ à afficher
	GOSUB  edt020
	NIBASC 'Name :'
	NIBASC 'Phone:'
	NIBASC 'Addr1:'
	NIBASC 'Addr2:'
	NIBASC 'Addr3:'
	NIBASC 'Addr4:'
	NIBASC 'Note :'
	NIBASC 'Crit.:'
* C(A) = numéro du champ a afficher
 edt020 C=C+C  A
	A=C    A
	A=A+A  A
	A=A+A  A
	A=A+C  A
	A=A+C  A	Numéro du champ * 12
	C=RSTK
	C=C+A  A	Adresse du champ
	D1=C
	LC(2)  6	6 caractères a envoyer
	GOSUB  dspcnc
	LC(2)  '>'	Curseur on
	GOSBVL =ESCSEQ
* affichage du contenu du champ pour édition
	GOSUB  chpedt	En sortie, D0 pointe le bon champ
	AD0EX
	D1=A
	GOSUB  dspcnc	Affichage du champ pointé par FUNCD0
	GOSBVL =CURSFL
* édition de la ligne
 edt040
	D0=(5) =INSINP	Prévient le poll de FINPUT
	A=DAT0 P	que c'est nous qu'on travaille
	LC(1)  =INSMSK
	A=A!C  P
	DAT0=A P
	D0=(4) =STMTR1	Numéro du champ courant
	C=DAT0 A
	D0=(4) =CHPCOU
	DAT0=C A

	GOSUB  chedit

	B=A    A	Prévient le poll de FINPUT que
	D0=(5) =INSINP	c'est nous qu'on travaille plus !
	A=DAT0 P
	LC(1)  `=INSMSK
	A=A&C  P
	DAT0=A P
	A=B    A

	?A=0   A
	GOYES  edt040
	GOSUB  finda
	CON(2) 13
	REL(3) edtEND	[ENDLINE]
	CON(2) 14
	REL(3) edtATN	[ATTN]
	CON(2) 15
	REL(3) edtRUN	[RUN]
	CON(2) 18
	REL(3) edtUP	[^]
	CON(2) 19
	REL(3) edtDWN	[v]
	CON(2) 20
	REL(3) edtTOP	[g][^]
	CON(2) 21
	REL(3) edtBOT	[g][v]
	CON(2) 24
	REL(3) edtOFF	[f][OFF]
	NIBHEX 00
	GOTO   edt040	Aucune de celles-ci: aucune action
 
**************
* [f][OFF]
**************
 edtOFF GOLONG OFF
 
**************
* [g][^]
**************
 edtTOP GOSUB  finlin
 edttop P=     0
 setchp D0=(5) =STMTR1
	C=0    A
	CPEX   0	C(0)=P ; P=0
	DAT0=C A
	GOTO   edt010
 
**************
* [g][v]
**************
 edtBOT GOSUB  finlin
 edtbot P=     CHPMAX
	GOTO   setchp
 
**************
* [^]
**************
 edtUP	GOSUB  finlin
	D0=(5) =STMTR1
	C=DAT0 A
	P=C    0
	P=P-1
	GOC    edttop
	GONC   setchp	B.E.T.
 
**************
* [v]
**************
 edtDWN GOSUB  finlin
 edtdwn LC(1)  CHPMAX
	A=C    A
	D0=(5) =STMTR1
	C=DAT0 A
	?A=C   P	Ici, P vaut 0
	GOYES  edtbot
	P=C    0
	P=P+1
	GONC   setchp	B.E.T.
 
**************
* [ATTN]
**************
 edtATN GOSUB  attn
	GONC   edat10
	GOTO   edt040
 edat10 C=RSTK		Pas très utile, mais plus propre !
	GOTO   BS:
 
**************
* [ENDLINE]
**************
 edtEND GOSUB  valide	Valide ligne et stocke dans fiche
	GOTO   edtdwn	Champ suivant

**************
* [RUN]
**************
 edtRUN GOSUB  valide	Valide ligne et stocke dans fiche
* calcul de l'adresse de la fin de la fiche
	C=0    A
	LC(1)  1+CHPMAX
	A=C    A	A = numéro champ courant (= CHPMAX)
	D0=(5) =STMTR1
	DAT0=A A	Champ (fictif) suivant
	GOSUB  chpedt	D0 ^ champ (fictif) suivant
	D0=D0- 2
	AD0EX		A(A) := adresse fin de la fiche
* calcul de la taille de la fiche
	GOSUB  ldcset	D0 := C(A) := début de la fiche
	C=A-C  A	Longueur en quartets de la fiche
	DAT0=C 4	On met la longueur en quartets
	D1=(5) =AVMEMS	en tête de la fiche
	DAT1=A A	Nouveau AVMEMS := adresse de la fin
	AD0EX		de la fiche
* Maintenant, les pointeurs OUTBS et AVMEMS sont bien
* positionnés. Dans A, il faut l'adresse du début de la
* fiche (y compris la longueur)
*
* recopie du champ "nom" au sommet de la Math-Stack
*  !!! l'exécution continue dans fch>ms !!!
 
 
************************************************************
* fch>ms
*
* But: recopier le champ "nom" d'une fiche sur la Math-Stack
* Entree:
*   - A(A) = ^ début de la fiche (avec les 4 quartets)
*   - OUTBS = ^ début de la fiche
*   - AVMEMS = ^ fin de la fiche
* Sortie:
*   - ST(slash, point) sont mis a 0
*   - FUNCD0 et FUNCD1 correspondent à leur définition
* Abime: A(A), B(A), C(A), D(A), D0, D1, FUNCD0, FUNCD1
* Appelle: COLLAP, D=AVMS, CONVUC, STKCHR
* Niveaux: 1
* Detail: attention, le / n'est pas ajouté en fin de chaîne
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 fch>ms D0=A		D0 ^ début de la fiche
	D0=D0+ 4	Adresse du premier champ (le nom)
	A=0    A
	A=DAT0 B	A(A)=nombre de caractères du champ
	D1=(5) =FUNCD0
	DAT1=A A	Longueur de la chaîne sur la M.S.
	B=A    A	Nombre de boucles
	GOSBVL =COLLAP	Cy=0; Utilise C(A) D1;
	D1=(5) =FUNCD1
*******
* Ici, il me semble y avoir une bogue. Ce devrait plutôt
* être DAT1=C, sauf erreur de ma part. Je n'y touche pas car
* apparemment, ça marche. Ce qui tendrait à prouver que le
* COLLAP est inutile. Plus tard, peut-être...
*
	C=DAT1 A	Adresse de la chaîne sur la M.S.
*
*******
	D1=C
	GOSBVL =D=AVMS	Ne modifie pas Cy; Utilise C(A) D(A)
	GONC   edt200	B.E.T.
 edt190 D0=D0+ 2	Pointeur dans la fiche
	A=DAT0 B	caractère du champ "nom"
	GOSBVL =CONVUC	UPRC$
	C=A    B
	GOSBVL =STKCHR
 edt200 B=B-1  A
	GONC   edt190
	CLRST		Flags recherche = 0 (avec /, sans .)
	RTN
 
************************************************************
* chedit
*
* But: faciliter l'accès à CHEDIT
* Entree: -
* Sortie:
*   - P = 0
*   - code de retour de CHEDIT est dans A(A) et B(A)
*   - si A(A) = 0, la touche était à exécution immédiate
* Abime: Tout, y compris S-R1-1, et return stack de sauveg.
* Appelle: R<RSTK, CHEDIT, RSTK<R
* Niveaux: plein !
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 chedit GOSUB  SD1sve	Sauvegarde de STMTD1 en S-R1-1
	P=     4
	GOSBVL =R<RSTK
	GOSBVL =CHEDIT
	GOC    ched10	
	A=0    A	Touche à exécution immédiate
 ched10 P=     4
	GOSBVL =RSTK<R
	B=A    A
	GOSUB  atnclr	Abime A(A)
	A=B    A
	GOTO   SD1res	chedit s'achève dans SD1res
 
************************************************************
* attn
*
* But: décide ce que l'appelant doit faire avec [ATTN] sous
*   CHEDIT, et gère l'affichage.
* Entree:
*   - la ligne éditée est dans le "display buffer"
* Sortie:
*   Cy = 0 ==> ATTN doit arrêter l'édition en cours
*   Cy = 1 ==> la ligne est effacée, on continue
* Abime: A(A), B(A), C(A), D(A), D0, D1, R1, ST(0)
* Appelle: D1=AVE, DSP$00, POP1S, FINLIN
* Niveaux: 5 (FINLIN)
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 attn	GOSBVL =D1=AVE	D1 := sommet de la Math-Stack
	ST=1   0	Pour DSP$00
	GOSBVL =DSP$00
	GOSBVL =POP1S
*******
* Je ne sais pas ce que ces deux instructions font là.
* Elles ne semblent pas apparemment utilisées.
*	LC(2)  ' '
*	B=C    A
*******
	A=A-1  A	A(A) = longueur en quartets
	A=A-1  A
	?A#0   A
	GOYES  attn10
 finlin GOVLNG =FINLIN	retour avec Cy=0, P=0
 attn10 GOSBVL =CURSFL
	GOSBVL =-LINE	(-LINE)
	RTNSC		Cy=1, on a effacé la ligne.
 
************************************************************
* clrrpt
*
* But: effacer toute trace de repétition de touche
* Entree: -
* Sortie: -
* Abime: C(A), D0
* Niveaux: 0
* Detail: pompée dans le code de CHEDIT
* Historique:
*   86/07/26: écriture (enfin... pompage)
*   86/08/01: ajout de documentation
************************************************************
 
 clrrpt D0=(5) =KEYPTR
	C=0    A
	C=DAT0 XS
	?C#0   XS
	RTNYES		retour si le buffer est vide
	D0=(4) (=KEYBUF)+2*14
	DAT0=C B
	RTN
 
************************************************************
* KAe
*
* But: point d'entrée de KA depuis le Basic
* Historique:
*   86/08/01: ajout de documentation
*   86/08/03: supprimer la bogue KA :<device specifier>
************************************************************
 
	REL(5) =KAd
	REL(5) =KAp
 
=KAe	A=DAT0 B
	GOSBVL =EOLXCK
	GONC   KA20	KA <spec. de fichier>
	GOSUB  KA10
	CON(2) #C4
	NIBASC 'ADRS'
	CON(2) #F0
 KA10	C=RSTK		KA tEOL
	D0=C
* D0 pointe sur le spécificateur de fichier
 KA20	GOSBVL =FSPECx
	GONC   KA30
 bserr	GOVLNG =BSERR
**************
* Ajoute le 86/08/03 pour corriger la bogue: KA :MAIN
* par exemple.
*
 KA30	?A#0   W
	GOYES  KA35	Un nom était donné
	C=0    A	Il y a forcément quelque chose qui
	LC(2)  =eFSPEC	suit KA, car on l'a testé plus haut
	GONC   bserr	(EOLXCK)
*
* fin de l'ajout
**************
 KA35	C=0    S	Nom de fichier légal
	?C=D   S
	GOYES  KA40	:MAIN
	C=C+1  S
	?C=D   S
	GOYES  KA40	:PORT
	C=0    S
	C=C-1  S
	?C=D   S
	GOYES  KA40
* Le spécificateur de fichier indique qu'il est externe 
	R1=A
	LC(5)  50
	GOSBVL =SALLOC
	A=R1
	ST=0   3	Source
	GOSBVL =SVINF+
	A=0    W
	D=0    A
	ST=1   3
	GOSBVL =SVINFO
    if JPCPRV
	GOSBVL =COPYu
    else
	GOSBVL =MGOSUB	Fichier copié derrière le dernier
	CON(5) =COPYu	mais une config. peut intervenir.
    endif
	GOC    bserr
	C=R1
	GOTO   KA60
* Le spécificateur de fichier indique la RAM
 KA40	D1=(5) =STMTR0
	C=D    W
	DAT1=C W
	D1=D1+ 16
	DAT1=A W
	GOSBVL =FINDF
	CD1EX
	GONC   KA60
* Le fichier n'existe pas, il faut le créer
	D1=(5) =STMTR0
	C=DAT1 W
	D=C    W
	C=0    A
	LC(2)  37+16+2*4
	GOSBVL =CRETF+	Théoriquement, le Lex KA ne doit pas
	GOC    Bserr	bouger...
	C=R1
	D1=(5) =STMTR1
	A=DAT1 W
	D1=C
	DAT1=A W	Nom du fichier
	D1=D1+ 16
	LC(4)  =fADRS
	DAT1=C 4
	A=0    W
	D1=D1+ 16
	D1=D1+ 5
	DAT1=A W
	D1=D1+ 16
	DAT1=A 8
	C=R1
 
* KA60:On attend dans C(A) l'adresse du début du fichier.
 
* Le fichier est trouvé, il faut vérifier qu'il est en RAM
 KA60	GOSBVL =LOCADR	Cy=0 non testée, l'adr. est valide
	?D=0   S	MAIN, RAM
	GOYES  KA65
	D=D-1  S
	?D=0   S	PORT, RAM
	GOYES  KA65
	C=0    A	PORT, ROM or EEPROM
	LC(2)  60	Illegal access, fichier pas en RAM
	GOTO   Bserr
* Le fichier est en RAM, on peut commencer KA
 KA65	D1=D1+ 16	Après LOCADR, D1=R2=A= C à l'entrée
	A=0    A
	C=0    A
	A=DAT1 4
	LC(4)  =fADRS
	?A=C   A
	GOYES  KA70
	LC(4)  63	Invalid file type
 Bserr	GOTO   bserr
 KA70	D1=D1+ 16
	D1=D1+ 5
	A=DAT1 W	Password
	D1=D1+ 16	D1 ^ Nb max de fiches
	D0=(5) =STMTD1	Adresse du début du fichier.
	CD1EX
	DAT0=C A	STMTD1= ok =^ Nb max de fiches
	D1=C
	D1=D1+ 12
	CD1EX		^ début de la première fiche
	D0=D0- 5	STMTD0
	DAT0=C A	début de la ligne pointée par D0
	D0=D0- 6	No de la ligne courante (S-R1-2)
	C=0    A
	DAT0=C A	S-R1-2 = 0
 
 
* STMTD1: adresse du fichier (^ nb max de fiches)
* STMTD0: adresse de la ligne courante (après les 4 q.)
* S-R1-2: No de la fiche correspondant à la ligne STMTD0
* S-R1-3: No du champ (0 à 7)

	D1=(5) =CHPMAX
	C=0    A
	LC(1)  CHPMAX
	DAT1=C A	Pour le poll de FINPUT
 
	?A=0   W	Il n'y a pas de password ?
	GOYES  BP:	Oui: Ok
	GOSUB  pass
	GONC   KA80
 exitka GOLONG EXIT
 KA80	C=DAT0 W
	?C#D   W
	GOYES  exitka
* Maintenant, le password est bon.
 
*********************
* Boucle Principale
*********************
 
 BP:	GOSUB  NoFich
	GONC   BP10	Fichier non vide
*
* Le fichier est vide
*
 FV10	GOSUB  FV50
 FV20	NIBASC 'Empty fi'
	NIBASC 'le'
 FV50	C=RSTK
	D1=C
	LC(2)  ((FV50)-(FV20))/2
	GOSUBL dspcnc
	GOSUBL finlin
 FV70	GOSUBL keywt
	GOSUBL finda
	CON(2) #2B	EXIT
	REL(3) EXIT
	CON(2) #40
	REL(3) KEY
	CON(2) #4B
	REL(3) INPUT 
	CON(2) #63
	REL(3) OFF
	NIBHEX 00
	GOTO   FV70
*
* Fin de la boucle de fichier vide
*
 BP10	?C<=A  A	Fiche courante <= Max ?
	GOYES  BP20	On ne change rien
	P=     4
	C=C+1  P
	P=     0
	GOC    BP18	saut si C[4:4]=0, cad il valait #F
	A=0    A	On ne comprend pas, on remet à 1...
	A=A+1  A
 BP18	C=A    A	Fiche courante = Nb max
	DAT1=C 4
 BP20	RSTK=C
	GOSUBL seekC
	D1=(5) =STMTD0
	DAT1=C A
	C=RSTK
	D1=D1- 6	S-R1-2
	DAT1=C A
	D1=D1+ 5	S-R1-3 = No du champ
	A=0    S
	DAT1=A S	S-R1-3: chp à afficher
 
*********************
* Boucle Secondaire
*********************
 
 BS:	GOSUB  NoFich
	GONC   BS05	Fichier non vide
	GOTO   FV10
 BS05	GOSUBL affchp	Affichage du champ S-R1-3
	GOSUBL finlin
 BS10	GOSBVL =RPTKY
	GOC    BS30	Go if repeated key
 BS20	GOSUBL keywt
 BS30	GOSUBL finda
	CON(2) #32
	REL(3) HAUT
	CON(2) #33
	REL(3) BAS
	CON(2) #24
	REL(3) ANCIEN
	CON(2) #25
	REL(3) NOUVEL
	CON(2) #A2
	REL(3) gHAUT
	CON(2) #A3
	REL(3) gBAS
	CON(2) #94
	REL(3) PREM
	CON(2) #95
	REL(3) DERN
	CON(2) #55
	REL(3) EDIT 
	CON(2) #4B
	REL(3) INPUT
	CON(2) #5B
	REL(3) DELETE
	CON(2) #56
	REL(3) CAT
	CON(2) #2B
	REL(3) EXIT
	CON(2) #40
	REL(3) KEY
	CON(2) #63
	REL(3) OFF
	NIBHEX 00
*
* Action par défaut
*
	GOSUB  clrrpt
	R3=A		Sauver A(B) (Code physique) en R3
	GOSBVL =KEYNAM	Conversion en "Nom de Touche"
	?P#    1	# 1 caractère ?
	GOYES  BS20
	P=     0
*
* Est-ce un chiffre entre 0 et 7 ?
*
	LC(4)  256*((CHPMAX)+'0')+'0'
	GOSBVL =RANGE
	GOC    BS40
	GOTO   ChampA	A(B) in ['0'..' ']
*
* Est-ce une lettre ?
*
 BS40	LC(4)  256*'Z'+'A'
	GOSBVL =RANGE
	GONC   BS50	Cy=0 si A(B) in ['A'..'Z']
	GOTO   BS20
*
* C'est une lettre
*
 BS50	GOSUBL =fkey	Touche R3(B) sauvegardée plus haut
* Affichage du message d'invite
	GOSUB  RECH20
 RECH19 NIBASC 'Search: '
 RECH20 C=RSTK
	D1=C
	LC(2)  ((RECH20)-(RECH19))/2
	GOSUBL dspcnc
* édition du nom à rechercher
 RECH25 GOSUBL chedit
	?A=0   A
	GOYES  RECH25
* selon le terminateur
	GOSUBL finda
	CON(2) 14
	REL(3) RECATN	[ATTN]
	CON(2) 13
	REL(3) RECEND	[ENDLINE]
	CON(2) 24
	REL(3) RECOFF	[f][OFF]
	NIBHEX 00
	GOTO   RECH25
 
**************
* [f][OFF]
**************
 RECOFF GOLONG OFF
 
**************
* [ATTN]
**************
 RECATN GOSUBL attn	Doit-on arrêter là ?
	GOC    RECH25	Non, on réédite la ligne
 bs	GOTO   BS:	Si, on revient à l'édition du champ
 
**************
* [ENDLINE]
**************
 RECEND GOSUBL prpstr	Transfère la ligne éditée sur la MS
	?C=0   A
	GOYES  bs	Si longueur nulle, retour à boucle
* détermination des options de recherche
	GOSUBL uprc$	Conversion de ce nom en majuscule
	CLRST		Flags de recherche = 0
	LCASC  '.'
	?A#C   B	Le dernier caractère est-il "." ?
	GOYES  RECE10	
	ST=1   point	Oui: Flag de recherche = 1
	D0=(5) =FUNCD0	On limite la comparaison à la
	C=DAT0 A	sous-chaîne délimitée par le
	C=C-1  A	point.
	DAT0=C A
	GONC   RECE20	B.E.T.
 
 RECE10 GOSUBL find/
	GOC    RECE20	On a trouvé le "/" => S1=0
	ST=1   slash	On n'a pas trouvé le "/"
* les options de recherche sont connues.
* sauvegarde des STMTxx pour le cas où la fiche ne serait
* pas trouvée.
 RECE20 D0=(5) =STMTD0	Adresse de la fiche courante.
	C=DAT0 A
	D0=D0- 6	S-R1-2
	A=DAT0 A	No de la fiche correspondante
	D0=D0- 5
	DAT0=C A	S-R1-1 := STMTD0
	D0=D0- 5
	DAT0=A A	S-R1-0 := S-R1-2
* recherche
	GOSUBL search
	?ST=1  trouve
	GOYES  RECE90	Trouve !
	?ST=1  point
	GOYES  RECE90
* Non trouvé
* restauration des STMTxx, et affichage de l'erreur
	D0=(5) =S-R1-0
	A=DAT0 A
	D0=D0+ 5
	C=DAT0 A
	D0=D0+ 5
	DAT0=A A
	D0=D0+ 6
	DAT0=C A
	GOSUB  RECE30
 RECE29 NIBASC 'Not foun'
	NIBASC 'd...'
 RECE30 C=RSTK
	D1=C
	LC(2)  ((RECE30)-(RECE29))/2
	GOSUBL dspcnc
*	GOSUBL finlin			removed 86/07/26
	GOSBVL =CHIRP
	GOSBVL =CRLFSD	Pour avoir un affichage avec DELAY
	GOTO   BS:
*
* La fiche a été trouvée (ou comme si, s'il y avait un ".")
*
 RECE90 D1=(5) =S-R1-2	No de la fiche trouvée
	C=DAT1 A
	D1=(5) =STMTD1
	A=DAT1 A
	D1=A
	D1=D1+ 4	D1 ^ fiche courante
	DAT1=C 4
	GOTO   BP:
 
 
************************************************************
* EXIT
*
* But: sortir (proprement) de KA
* Entree: -
* Sortie: Il n'y a pas de sortie
* Historique:
*   86/07/26: ajout de NOSCRL pour effacer l'affichage
*   86/07/30: ajout de l'interface avec "Pocket Secretary"
*   86/08/01: ajout de documentation
************************************************************
 
 EXIT	GOSUB  clrrpt
	GOSBVL =NOSCRL	Comme si on n'avait rien affiché !
	ST=0   14	NoCont
	GOVLNG =NXTSTM
 
************************************************************
* KEY
*
* But: entrer le password
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 KEY	GOSUB  clrrpt
	GOSUBL pass
	GONC   KEY10	Password valide
	?D#0   B
	GOYES  KEY20	Rien n'a été introduit
	D=0    W
 KEY10	C=D    W	Mémorisation du password
	DAT0=C W
 KEY20	GOTO   BP:
 
************************************************************
* HAUT, BAS
*
************************************************************
 
 HAUT	D1=(5) =S-R1-3
	C=DAT1 S
	C=C-1  S
	GONC   Champ
 gHAUT	C=0    S
 Champ	D1=(5) =S-R1-3
	DAT1=C S
	GOTO   BS:
 BAS	D1=(5) =S-R1-3
	A=DAT1 S
	LC(1)  CHPMAX
	CSRC
	?A>=C  S
	GOYES  Champ	Ecriture de CHPMAX
	A=A+1  S	=> Cy=0
	C=A    S
	GONC   Champ	B.E.T.
 gBAS	LC(1)  CHPMAX
 gBAS10 CSRC
	GOTO   Champ
 ChampA C=A    A
	GOTO   gBAS10
 
************************************************************
* NoFich
*
* But: renvoyer des informations sur le fichier
* Entree:
*   - STMTD1 contient l'adresse du nb max de fiches
* Sortie:
*   - A(A) = nombre de fiches (0..m-1)
*   - C(A) = numéro de la fiche courante (0..m-1)
*   - Cy = 1 <==> fichier vide
* Abime: A(A), C(A), D1
* Niveaux: 0
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 NoFich D1=(5) =STMTD1	Adr. du fichier (^ nb max de fiches)
	C=DAT1 A
	D1=C		D1 ^ Max
	A=0    A
	A=DAT1 4	A=Max (1..Max)
	D1=D1+ 4	D1 ^ Fiche courante
	A=A-1  A	Adapter au No de la fiche (0..Max-1)
	C=0    A
	C=DAT1 4	C=Fiche courante
	RTN		A = Max ; Cy = 1 Fichier vide
 
 DERN	GOSUB  NoFich
 FicheA C=A    A
	GOTO   FicheC
 PREM	GOSUB  NoFich
 Fiche0 C=0    A
 FicheC DAT1=C 4
	GOTO   BP:
 ANCIEN GOSUB  NoFich
	C=C-1  A
	GONC   FicheC
	GOC    Fiche0	B.E.T.
 NOUVEL GOSUB  NoFich
	?C>=A  A
	GOYES  FicheA
	C=C+1  A
	GONC   FicheC	B.E.T.
 
************************************************************
* DELETE
*
* But: supprimer la fiche courante du fichier
* Historique:
*   86/07/26: Traduction du message en anglais
*   86/07/26: Changement de la touche [O] en [Y]
*   86/08/01: ajout de documentation
************************************************************
 
 DELETE GOSUB  clrrpt
* affichage du message de confirmation
	GOSUB  DEL10
 DEL05	NIBASC 'Delete: '
	NIBASC 'Y/N ?'
 DEL10	C=RSTK
	D1=C
	LC(2)  ((DEL10)-(DEL05))/2
	GOSUBL dspcnc
	GOSUBL finlin
* attente d'une pression de touche
	GOSUBL keywt
	LC(2)  #06	Touche [Y] (Oui) (avant #09 for [O])
	?C=A   B
	GOYES  DEL15
	GOTO   BS:
* suppression
 DEL15	GOSUB  delete
	GOTO   ANCIEN	On affiche la fiche précédente
 
************************************************************
* delete
*
* But: détruire la fiche courante du fichier
* Entree:
*   - STMTD0, STMTD1, S-
* Sortie:
*   - ATTENTION: les pointeurs STMTD0, S-R1-2 sont invalides
* Abime: A-D, R0-R3, D0, D1
* Appelle: PSHUPD, OBCOLL, Entete, RPLLIN, POPUPD, NoFich
* Niveaux: 4
* Detail: l'adresse de retour à l'appelant est sauvegardée
*   dans la pile des GOSUBs, pour ajustement d'adresse.
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 delete C=RSTK		Adresse de retour à l'appelant
	A=C    A
	GOSUBL pshupd	sauvegardée dans la pile des GOSUBs
	GOSBVL =OBCOLL
	D0=(5) =STMTD0	adresse de la fiche courante
	C=DAT0 A
	D0=C
	D0=D0- 4	D0 := ^ lg de la fiche
	C=0    A
	C=DAT0 4	C(A) := lg de la fiche en quartets
	R3=C		R3(A) := lg de la fiche en quartets
	AD0EX		A(A)=Adresse de la lg de la ligne
	A=A+C  A	^ dernier q + 1 de la ligne courante
	B=A    A	Sauvegarde temporaire ds B(A)
	GOSUB  Entete	C=adresse de l'en-tête du fichier.
	A=B    A
    if JPCPRV
	GOSBVL =RPLLIN
    else
	GOSBVL =MGOSUB
	CON(5) =RPLLIN
    endif
* la fiche est effacée. Cy est sauvegardée dans C(S)
	C=0    S
	GONC   del10
	C=C+1  S
* restauration de l'adresse de retour à l'appelant
 del10	R0=C		Sauvegarde de Cy et no d'erreur C(A)
	GOSUBL popupd
	C=D    A	C(A) := adresse de retour
	RSTK=C
* vérification du bon fonctionnement de RPLLIN
	C=R0		C(S) := cy; C(A) = numéro d'erreur
	?C#0   S
	GOYES  BserR
	GOSUB  NoFich
	D1=D1- 4
	DAT1=A 4	Une fiche en moins.
	RTN
 BserR	GOVLNG =BSERR
 
************************************************************
* CAT
*
* But: afficher une ligne d'état sur le fichier courant
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 CAT	GOSUB  clrrpt
	GOSUBL SD1sve
	D1=(5) (=FUNCR0)-2
	C=0    A
	LC(2)  44
	GOSBVL =WIPOUT
	D1=(2) (=FUNCR0)-2
	D0=(5) =S-R1-1
	C=DAT0 A
	D0=C
	A=0    A
	A=DAT0 4	A(A)=Nb max de fiches, en Hexa.
	GOSUBL =Num2D1
   ******************************
   * modification intervenue le 86/07/28
   * pour supprimer la fote d'auretaugrafe
   * 1 cardS
   ************************
   *	   LCASC  ' ,sdrac '
   *	   DAT1=C W
   *	   D1=D1+ 16
   ************************
	LCASC  'drac '
	DAT1=C 10
	D1=D1+ 10
	A=0    A
	A=DAT0 4	A := Nombre maximum de fiches
	A=A-1  A
	?A=0   A
	GOYES  cat05
	LCASC  's'
	DAT1=C B
	D1=D1+ 2
 cat05	LCASC  ' ,'
	DAT1=C 4
	D1=D1+ 4
   * fin de la modification
   ******************************
	AD0EX
	C=0    A
	LC(2)  16+5
	C=A-C  A
	D0=C
	C=DAT0 A	"address-file length field"
	D0=A		On remet le pointeur sur "Nb max"
	ACEX   A	A := offset to next file
	C=0    A
	LC(2)  5+24	5 : "next file" ; 24 : subheader
	C=A-C  A	C := place exacte occupée
	A=0    A
	A=DAT0 4	A := nombre max de fiches (1..max)
	ACEX   A	A=taille du fichier, C=nb de fiches
	GOSBVL =IDIVA	A := taille moy. d'une fiche (en q)
	P=     0
	R0=A		R0 := taille moy. d'une fiche (en q)
	CD1EX
	R3=C		R3 := sauvegarde de D1
	D0=(5) =STMTD0
	C=DAT0 A	C := adresse de la fiche courante
	GOSBVL =LOCADR	Dans quel système de fichier est-on?
	GOSBVL =FLADDR	A(A) := first nib; C(A) := last nib
	C=C-A  A	nombre de nibs libres
	A=C    A
	C=R3		ancien D1
	D1=C
	C=R0		C := taille moy. d'une fiche (en q)
	?A=0   A	A=0 ==> boucle infinie dans IDIVA
	GOYES  cat10
* A = Place memoire; C = Taille moyenne d'une fiche
	GOSBVL =IDIVA
	P=     0
	?A=0   A
	GOYES  cat10
	A=A-1  A
 cat10	GOSUBL =Num2D1
	LCASC  'liava '
	DAT1=C 12
	D1=(2) (=FUNCR0)-2
	GOSBVL =VIEWD1
	GOSUBL SD1res
	GOTO   BS10	On ne réaffiche pas inutilement
 
************************************************************
* INPUT
*
* But: introduire une nouvelle fiche
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 INPUT	GOSUB  clrrpt
* préparation du masque de fiche vide
	GOSUB  INP10
 INP05	BSS    4	Longueur ligne  (sans signification)
	CON(2) 1
	CON(2) '/'
	BSS    2*(CHPMAX)
 INP10	C=RSTK
	D0=C
	C=0    A
	LC(2)  (INP10)-(INP05) En quartets...
* édition de la fiche
	GOSUBL editfc
* placement de la fiche à insérer
 INP20	GOSUBL NoFich	A=Nb max de fiches (0..max-1)
	GOC    INP25	Cy=1 <=> Le fichier est vide
*	CLRST		Pour la recherche avec /, sans .
	GOSUBL search
* insertion de la fiche
 INP25	C=0    A
	R3=C		Taille de la ligne (0 car insertion)
	GOSUB  Entete	C(A)=En-tête
	D0=D0- 5	D0=(5) STMTD0
	A=DAT0 A	Adresse de la ligne juste après...
	D0=A
	D0=D0- 4	D0 ^ début de la ligne juste après
	AD0EX		A      "		"
* R3=0 ; A(A)=^ ligne suivante ; C(A)=^ en-tête du fichier
    if JPCPRV
	GOSBVL =RPLLIN
    else
	GOSBVL =MGOSUB
	CON(5) =RPLLIN
    endif
	GONC   INP30
	GOTO   BserR
* réactualisation des pointeurs
 INP30	GOSUBL NoFich
	D1=D1- 4
	A=A+1  A
	A=A+1  A
	DAT1=A 4
	GOTO   RECE90	Réactualisation No de fiche cour.
 
 popupd GOVLNG =POPUPD
 pshupd GOVLNG =PSHUPD
 
************************************************************
* EDIT
*
* But: éditer la fiche courante
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 EDIT	GOSUBL clrrpt	supprimer la répétition de touches
* édition de la fiche courante
	D1=(5) =STMTD0	adresse de la fiche courante
	C=DAT1 A
	D0=C		D0 := ^ fiche courante (après la lg)
	D0=D0- 4	D0 := ^ fiche courante (sur la lg)
	C=0    A
	C=DAT0 4	C(A) := LEN(fiche courante) (en q)
	GOSUBL editfc
* occupe-t-elle la même place dans le fichier
* c'est à dire que le nom a changé
	D0=(5) =STMTD0	adresse de la fiche courante
	C=DAT0 A
	D0=C		D0 := ^ fiche courante
	GOSUBL tststr	Est-ce le même nom que l'originale ?
	?ST=1  trouve
	GOYES  EDIT50	Oui: il suffit de replacer la fiche
* la fiche se déplace.
* Supprimer l'ancienne, ajouter la nouvelle
	D0=(5) =AVMEMS
	D1=(5) =STMTR1
	C=DAT0 A	C := (AVMEMS)
	D0=D0- 5	D0 := ^ OUTBS
	A=DAT0 A	A := (OUTBS)
	DAT1=A A	STMTR1 := (OUTBS)
	C=C-A  A	C := (AVMEMS) - (OUTBS)
	D1=D1+ 5
	DAT1=C A	S-R1-1 := lg de la fiche en quartets
	GOSUB  delete
	GOSUB  stable	} ajoute le 86/07/28
* préparer l'insertion de la nouvelle fiche, c'est à dire la
* ramener juste dans OUTBS
	GOSBVL =OBCOLL
	D1=(5) 5+=STMTR1
	A=DAT1 A
	B=A    A	Taille en quartets
	D1=D1- 5
	A=DAT1 A	A(A)=ancien OUTBS
	GOSUBL move*m
	A=C    A	A=Sauver le nouvel OUTBS (fch>ms)
	C=C+B  A
	D0=(5) =AVMEMS
	DAT0=C A
	GOSUBL fch>ms
	GOTO   INP20
* Remplacement de la fiche seulement
 EDIT50 D0=(5) =STMTD0
	C=DAT0 A
	D0=C
	D0=D0- 4
	C=0    A
	C=DAT0 4	C(A)=longueur en quartets
	R3=C
	AD0EX
	C=C+A  A	C(A)=adresse de la ligne suivante
	D1=C		Sauvegarde ds D1
	GOSUB  Entete	C(A)=Adresse de l'en-tête du fichier
	AD1EX
* R3(A)=taille de la vieille ligne en quartets;
* C(A)=adresse de l'en-tête du fichier
* A(A)=adresse de la ligne suivante
    if JPCPRV
	GOSBVL =RPLLIN
    else
	GOSBVL =MGOSUB
	CON(5) =RPLLIN
    endif
	GONC   EDIT60
	GOTO   BserR
 EDIT60 GOLONG BP:
 
************************************************************
* Entete
*
* But: renvoyer l'adresse du début du fichier
* Entree:
*   - STMTD1 pointe le nombre de fiches dans le fichier
* Sortie:
*   - C = adresse du début du fichier (premier octet du nom)
* Abime: A(A), C(A), D0
* Niveaux: 0
* Historique:
*   86/08/01: ajout de documentation
************************************************************
 
 Entete D0=(5) =STMTD1
	A=DAT0 A
	C=0    A
	LC(2)  37+16
	C=A-C  A
	RTN
 
************************************************************
* OFF
*
* But: si la touche [f][OFF] est appuyée, ou si le délai de
*   10 minutes a expiré, éteindre le HP71.
* Entree: -
* Sortie:
*   Tous les niveaux de la "return stack" sont abimes
*   Le contrôle est rendu à la boucle principale
* Detail: l'extinction implique :
*   keywt en mode consultation (BP: and FV loops)
*   keywt en confirmation de DELETE
*   chedit en mode RECHERCHE (RECH25)
*   chedit en modes EDIT/INPUT (edt040)
*   --> OFF
*   chedit in password processing at KA entry
*   --> EXIT
*   chedit en mode introduction de pasword
*   --> retour à l'appelant avec password invalide
* Historique:
*   86/07/26: codage
*   86/07/27: ajout de documentation
************************************************************
 
* sauvegarde des adresses du fichier (STMTD0 et STMTD1)
 OFF	D0=(5) =STMTD0
	A=DAT0 A
	GOSUB  pshupd
	D0=(5) =STMTD1
	A=DAT0 A
	GOSUB  pshupd
* extinction. Comme y disent : bonne nuit.
	GOSBVL =MGOSUB
	CON(5) =DSLEEP
* réveil. Comme y disent : bonjour !
* restauration des adresses du fichier
	GOSUB  popupd
	C=D    A
	D0=(5) =STMTD1
	DAT0=C A
	GOSUB  popupd
	C=D    A
	D0=(5) =STMTD0
	DAT0=C A
* retour à la boucle principale
	GOLONG BP:
 
************************************************************
* stable
*
* But: mettre le fichier et ses pointeurs dans un état
*   stable, c'est à dire faire tout pointer sur la première
*   fiche.
* Entree:
*   - STMTD1 pointe sur le nb de fiches (c'est un minimum)
* Sortie:
*   - STMTD0 pointe sur la première fiche
*   - S-R1-2 contient le numéro de la première fiche (0)
*   - C(A) = 0
* Abime: A(A), C(A), STMTD1, S-R1-2
* Niveaux: 0
* Historique:
*   86/07/28: conçue pour corriger le bug lors de l'édition
*   86/08/01: ajout de documentation
************************************************************
 
 stable D0=(5) =STMTD1	adresse du début du fichier
	A=DAT0 A
	C=0    A
	LC(1)  12	offset de la première ligne par
	A=A+C  A	rapport au password
	D0=D0- 5	D0=(5) STMTD0
	DAT0=A A	adr ligne courante = première ligne
	D0=(2) =S-R1-2	D0 := ^ numéro de la ligne courante
	C=0    A
	DAT0=C A	ligne courante := 0
	RTN

	END
