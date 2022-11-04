^{1DIFFERENCES PRINCIPALES

^{1ENTRE LA VERSION B ET LA VERSION C}



\Le passage de la version B00 » la fonction C (voir la fonction 
{cVER$} dans {iles caract≈ristiques additionnelles de JPC†Rom})
r≈sulte d'un certain nombre de corrections,
modifications et am≈liorations. Les principales sont
r≈sum≈es ci-dessous :\


{2Corrections}

\Les mots-clefs de programmation structur≈e ne
fonctionnaient pas lorsqu'une remarque suivait
directement le d≈but de la boucle, comme par exemple :{c\
      10 WHILE 1 !
      20 END WHILE
\}Idem pour {cSELECT}, {cCASE}, etc. Signal≈ par Henri
Kudelski en Suisse et G≈rard Kossman en France.\

\Les fonctions {cSTARTUP$} et {cENDUP$} ne retournaient
pas convenablement leur
r≈sultat, ce qui avait pour effet de provoquer une erreur
{cData†type} lorsque le programme suivant ≈tait ex≈cut≈
:{c\
      10 DESTROY ALL
      20 DIM S$
      30 DIM S$[LEN(STARTUP$)]
\}Idem pour {cENDUP$}. Signal≈ par Tapani Tarvainen en
Finlande.\

\La touche {l[f][BACK]} retrouve sa signification normale dans
la pile de commande en mode CALC, ce qui permet d'≈diter
librement les expressions dans les lignes de commandes.
Signal≈ par Michael Markov aux Etats-Unis et Tapani
Tarvainen en Finlande.\

\Apr…s une configuration (par exemple, {cCOPY} d'un fichier
Lex en m≈moire, {cLEX†ON/OFF}), les tabulations assembleur
≈taient activ≈es lorsqu'on utilisait {cEDTEXT}.\

\Le mot-clef {cSTACK} a ≈t≈ remplac≈ par celui de Henri
Kudelski en Suisse qui fait moins de mis…res au lancement du
programme {cML}.\


{2Nouveaux mots-clefs et nouvelles caract≈ristiques}

\Le mot-clef {cSYSEDIT} a ≈t≈ ajout≈, ainsi que {cOPCODE$}
et {cNEXTOP$}. {cOPCODE$} et {cNEXTOP$} ont ≈t≈ ≈crits par
Jean-Jacques Dh≈nin. {cSYSEDIT} a ≈t≈ ≈crit par Pierre David
et Janick Taillandier.\

\La fonction {cFILESIZE} de Henri Kudelski a ≈t≈ ajout≈e.\

\Le gestionnaire de carnet d'adresses {cKA} et ses fonctions
d'acc…s programmables ({cADCREATE}, {cADDELETE},
{cADFIND}, {cADGET}, {cADPUT} et {cADSIZE}) ont ≈t≈
ajout≈es. Ces mots-clefs ont ≈t≈ ≈crits par Pierre
David.\

\La fonction {cKEYWAIT$} (de Hewlett-Packard) a ≈t≈ ajout≈e.
Ses num≈ros d'Id et de token n'ont pas ≈t≈ modifi≈s par
rapport » ceux de la User's Library.\

\Le mot-clef {cROMAN} a ≈t≈ ajout≈ pour permettre l'acc…s au
jeu de caract…res {iRoman}. Ce mot-clef a ≈t≈ ≈crit par
Pierre David et Janick Taillandier.\

\JPC Rom reconna—t maintenant les types de fichiers non
standard lors d'un {cCAT}, tels ceux du HP-41 ou du HP-75, mais en plus les
fichiers non standard produits par le HP-71. Ce Lex a ≈t≈
≈crit par Jan Buitenhuis des Pays Bas et Janick Taillandier
de France.\


{2Modifications et am≈liorations}

\{iJPC Rom} s'appelait avant {iJPCLEX}.\

\{cBLIST} a ≈t≈ renomm≈ en {cDBLIST}, » cause de
l'homonymie avec le mot-clef du Lex BREAK de la User's
Library.\

\{cSWAP} a ≈t≈ renomm≈ en {cVARSWAP}.\

\La fonction {cINV$} a ≈t≈ supprim≈e, et ses fonctionnalit≈s
report≈es sur {cINVERSE}.\

\La syntaxe de {cINVERSE} et de {cPAINT} ont ≈t≈ ≈tendues
pour offrir plus de souplesse.\

\La syntaxe de {cSPACE$} a ≈t≈ ≈tendue pour la g≈n≈raliser
et l'≈tendre » la r≈p≈tition de cha—nes quelconques.\

\{cENABLE} et {cDISABLE} ont ≈t≈ renomm≈s en {cLEX†ON/OFF} »
cause du conflit avec {cENABLE} dans le module HP-IL.\

\Les fonctions {cREPLACE$} et {cRPLC$} sont d≈sormais une
seule fonction {cREPLACE$}. Si il n'y a que trois
param…tres, ou si le quatri…me est num≈rique, les
fonctionnalit≈s sont celles de l'ancienne {cRPLC$}. Si le
quatri…me param…tre est alphanum≈rique, c'est le {ijoker}
utilis≈ dans l'ancienne fonction {cREPLACE$}.\

\{cDBLIST} et {cPBLIST} ont ≈t≈ r≈≈crits pour autoriser
l'indentation des structures et la redirection dans un
fichier.\

\Les fonctions supprim≈es sont rep≈r≈es par {cobsolete}
quand elles apparaissent dans un programme. Lorsque ces
programmes sont ex≈cut≈s, ils g≈n…rent l'erreur
{cJPC†ERR:Removed†Keyword} (message num≈ro 16).\


{2Note}

\Toutes ces am≈liorations ou corrections ont ≈t≈ faites
en conservant la compatibilit≈ des programmes ≈crits avec
l'ancienne version de JPC Rom. Ainsi, vos programmes ≈crits
avec l'ancien JPC Rom sont-ils totalement compatibles avec
le nouveau JPC Rom.\
