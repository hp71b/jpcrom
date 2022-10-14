	TITLE	Graphique, Utilitaires <gmutil.as>

************************************************************
* FINDBF
*
* But: trouver le buffer bMAIN.
* Entree: -
* Sortie:
*   - Cy = 1
*   - (BUFFER) = D1 = C = adresse du buffer
* Abime: A, C(A), C(S), D1
* Appelle: IOFND0
* Niveaux: 1
* Detail: l'erreur "graphic not nitialised" est renvoyée si
*   le buffer n'existe pas.
* Historique:
*   86/08/19: PD documentation
************************************************************

=FINDBF LC(3)  =bMAIN
	GOSBVL =IOFND0
	CD1EX		C(A) := ^ buffer
	D1=(5) =MBUF
	DAT1=C A	BUFFER := ^ buffer
	D1=C		D1 := ^ buffer
	RTNC		Cy=1 => buffer trouvé
	LC(4)  (=graid)~(=eGNTIN) Buffer non trouvé ==>
	 *		Graphique non initialisé via GINIT.
	GOVLNG =BSERR	

************************************************************
* SETUP
*
* But: initialiser une séquence de graphique. Sélectionner
*   et préparer le driver pour une séquence d'ordres HPGL.
* Entree: -
* Sortie:
*   - (DRIVER) = adresse du driver
* Abime: A-C, D1
* Appelle: FINDBF, POLL
* Niveaux: 2
* Detail: le contrôle est donné au driver par
*   l'intermédiaire du poll graphique.
*   D'autre part, la mémoire ne doit pas bouger pendant la
*   durée de cette fonction.
* Historique:
*   86/08/19: PD documentation
*   86/08/27: PD adaptation pour un seul numéro de poll
************************************************************

=SETUP	GOSUB  =FINDBF	D1 := ^ buffer bMAIN
	C=DAT1 B	C(B) := numéro du graphique
	D=C    B
	LC(2)  =prDBUT
	A=C    B
	GOSBVL =POLL
	CON(2) =pGRAPH
	GOC    setupe
	?XM=0		Le graphique a-t-il été reconnu ?
	GOYES  STUP10	  Oui
	LC(4)  (=graid)~(=eMODMS) Non: "Module missing"
 setupe GOVLNG =BSERR
 STUP10 C=D    A	C(A) := adresse du driver
	D0=(5) =DRIVER
	DAT0=C A	(DRIVER) := adresse du driver
	RTN

************************************************************
* GRAPHx
*
* But: exécuter un ordre HPGL via le driver approprié
* Entree:
*   - C(B) = identificateur de l'ordre (nXX)
*   - DRIVER = adresse du driver
* Sortie:
*   dépend de l'ordre HPGL
* Abime: A(B), C(A)
* Appelle: driver HPGL approprié
* Niveaux: 1
* Historique:
*   86/08/19: PD conception et codage
************************************************************

=GRAPHx A=C    B	Numéro HPGL dans A(B)
	D0=(5) =DRIVER
	C=DAT0 A	C(A) := adresse du driver
	RSTK=C
	RTN

************************************************************
* ENDGL
*
* But: achever l'envoi d'une séquence d'ordres HPGL.
* Entree:
*   - (BUFFER) = adresse du buffer
* Sortie: -
* Abime: 
* Appelle: POLL
* Niveaux: 
* Historique:
*   86/08/27: PD conception & codage
************************************************************

=ENDGL	D1=(5) =MBUF
	C=DAT1 A
	D1=C
	C=DAT1 B
	D=C    B
	LC(2)  =prFIN
	A=C    B
	GOSBVL =POLL
	CON(2) =pGRAPH
	RTN		Le retour du poll n'est pas testé
* Il faudrait que quelqu'un le réécrive !

************************************************************
* MBUFC
*
* But: calculer l'adresse du champ C(B) dans le buffer.
* Entree:
*   - C(B) = champ à chercher
*   - (BUFFER) = ^ bMAIN
* Sortie:
*   - D1 = C = ^ champ demandé dans le buffer
*   - D(A) = C(B) en entrée
*   - Cy = 0
* Abime: C(A), D(A), D1
* Niveaux: 0
* Historique:
*   87/02/24: PD pompage dans le module "raster"
************************************************************

=MBUFC	D1=(5) =MBUF
	D=0    A	} D(A) := C(B)
	D=C    B	}
	C=DAT1 A	C(A) := ^ bDRIVR
	C=C+D  A	C(A) := ^ bDRIVR.champ
	D1=C		D1 := ^ bDRIVR.champ
	RTN

	END
