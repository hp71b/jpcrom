^{hDIFFERENCES PRINCIPALES

^{hENTRE LA VERSION C ET LA VERSION D}



\Le passage de la version C » la version D (voir la fonction
{cVER$} dans {iles caract≈ristiques additionnelles de
JPC†Rom}) r≈sulte d'un certain nombre de corrections,
modifications et am≈liorations. Les principales sont
r≈sum≈es ci-dessous :\


{gCorrections}

\Le jeu de caract…res ≈tendu {cRoman} disparaissait » chaque
mise sous tension.\

\Le mode {iTabulations assembleur} ≈tait r≈activ≈
r≈guli…rement, comme par exemple » chaque mise sous
tension.\

\La fonction {cPOSI} renvoyait une valeur incorrecte (1) lorsqu'on
utilisait {cPOSI("",{ix}) avec {ix}<6. Signal≈ par Joe Horn
aux Etats-Unis.\

\La nouvelle version de {cDBLIST} n'acceptait pas la syntaxe
suivante : {cDBLIST†1000†INDENT†4}.\

\Le mot-clef {cFIND} ne trouvait parfois pas l'occurrence d'une
lettre dans une ligne. Signal≈ par Henri Kudelski en Suisse
et Claudio Benski en France.\

\Les fonctions de calcul de dates (telle que {cDOW} par
exemple) n'acceptaient pas le 29 f≈vrier des ann≈es
bissextiles lorsque le dernier chiffre de l'ann≈e n'≈tait
pas multiple de 4. Signal≈ avec beaucoup de pr≈cision par
Laurent Istria en France.\

\En mode {iconsultation de fiche}, avec {cKA}, la s≈quence
de touche suivante {l[f][EDIT]}, puis {l[ENDLINE]}
provoquait parfois l'entr≈e et la sortie imm≈diate du mode
{i≈dition de fiches}. Signal≈ par Henri Kudelski en Suisse.\


{gNouveaux mots-clefs et nouvelles caract≈ristiques}

\Les mots-clefs {cDDIR} et {cPDIR} ont ≈t≈ ajout≈s.\


{gModifications et am≈liorations}

\Le d≈sassemblage par {cOPCODE$} ou {cSYSEDIT} inversait les
mn≈moniques {cRSI} et {cPC=(A)}, comme cela a ≈t≈ r≈v≈l≈ par
le d≈sassemblage de la Rom du HP-28C.\


{gNote}

\Toutes ces am≈liorations ou corrections ont ≈t≈ faites en
conservant la compatibilit≈ des programmes ≈crits avec
l'ancienne version de JPC†Rom. Ainsi, vos programmes ≈crits
avec l'ancien JPC†Rom sont-ils totalement compatibles avec
le nouveau JPC†Rom.\
