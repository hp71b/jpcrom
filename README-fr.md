JPC Rom
=======

[[Version anglais/English version](README.md)]

Ce dépôt contient l'ensemble des fichiers sources de **JPC Rom** ainsi que 
les fichiers originaux qui ont permis de générer la documentation de plus
de 200 pages de cette ROM, dans sa version E, tels qu'ils étaient
en octobre 1989.


Qu'est-ce que JPC Rom ?
-----------------------

**JPC Rom** est un module conçu à la fin des années 1980 pour «
l'ordinateur de poche » [HP-71B](https://en.wikipedia.org/wiki/HP-71B)
par des contributeurs membres du club PPC Paris. Ce club regroupait
des possesseurs de calculatrices Hewlett-Packard, dont ce HP-71B.
Entièrement programmé en assembleur (environ 50 000 lignes) pour le
(processeur HP Saturn)[https://en.wikipedia.org/wiki/HP_Saturn], **JPC
Rom** étend les fonctionnalités du HP-71B dans de nombreux domaines
comme le montre sa documentation.


Pourquoi ce dépôt ?
-------------------

Après des années de sommeil, les fichiers originaux constituant
**JPC Rom** ont été retrouvés dans nos archives. Il nous a semblé
que ces éléments pourraient être utiles aux historiens futurs
ou tout simplement à des passionnés des calculatrices HP et plus
précisément du HP-71B ou du processeur Saturn.

Le but n'est pas de faire revivre **JPC Rom** mais de documenter la
version finale que nous avions produite à l'époque. Aucune évolution
n'est prévue.


Reconstruction du LEX à partir des sources
------------------------------------------

L'intégralité des sources de la version E sont disponibles dans le
répertoire `src/`.

L'assembleur/éditeur de liens utilisé pour construire le
LEX à partir de ces fichiers sources est accessible via
[https://github.com/hp71b/areuh](https://github.com/hp71b/areuh).
Sur Unix, avec ces programmes (`aas`, `amg` et `ald`) dans le PATH,
il suffit d'utiliser `make` dans le répertoire `src/` pour reconstruire
le fichier LEX.


Reconstruction de la documentation
----------------------------------

Les fichiers sources du formateur spécialisé pour produire le
manuel ayant été perdus, un outil de transcodage vers LaTeX
a été créé par Pierre David en 2022 afin de reconstruire
la documentation et produire un fichier PDF des [manuels en
français](https://hp71b.github.io/jpcrom/man-fr.pdf) et en
[anglais](https://hp71b.github.io/jpcrom/man-en.pdf).

Pour générer cette documentation sur Unix, il suffit d'aller dans
le répertoire `man/latex/` et de taper `make`. Prérequis : il faut
disposer d'un compilateur C, de `awk` et de la distribution texlive
(et en particulier de `xetex`).

Le manuel en anglais n'avait pas été mis à jour pour la version E et 
correspond donc à la version D (manquent en particulier 
les fonctions graphiques et l'éditeur de textes).

Les fichiers PDF [français](https://hp71b.github.io/jpcrom/man-fr.pdf)
et [anglais](https://hp71b.github.io/jpcrom/man-en.pdf) sont prévus
pour être imprimés recto-verso.


Avertissement : codage des caractères
-------------------------------------

L'ensemble de ces fichiers était originellement encodé dans le jeu de
caractères [HP-Roman8](https://en.wikipedia.org/wiki/HP_Roman#Roman-8),
le jeu de caractères natif du HP-71B.

  - Les fichiers sources du module (dans le répertoire `src/`) ont été
    convertis en UTF-8 pour en faciliter la lecture.
  - Les fichiers servant pour la génération de la documentation (dans
    les répertoires `man/fr` et `man/en` ont été laissés en HP-Roman8
    pour ne pas perturber lors des phases de traitement (comme la
    reconstruction de la documentation).


Contributeurs de JPC ROM
------------------------

Beaucoup de membres de PPC Paris se sont impliqués dès la sortie du
HP-71B et du module FORTH Assembler dans la réalisation de LEX
permettant d'améliorer le fonctionnement de la machine ou de créer de
nouvelles fonctionnalités. Ces travaux ont été publiés au fur et à
mesure dans le journal JPC (voir les
[archives collectées par Jean-François
Garnier](http://www.jeffcalc.hp41.eu/divers/index.html#jpc])).

La création par la société Corvallis Micro Technology de modules EPROM
compatibles avec les ports du HP-71B a permis d'aller plus loin en
fusionnant ces réalisations et en créant
une véritable ROM.  Les différentes ressources  utilisées,
à commencer par l'ID de LEX, avaient fait l'objet d'une réservation
auprès de Hewlett-Packard.

Toutes les sources n'ayant pas été développées par nous ont fait
l'objet de publication dans JPC et sont donc disponibles dans les
[archives](http://www.jeffcalc.hp41.eu/divers/index.html#jpc) : à ce
titre nous pensons qu'il n'y a pas d'obstacle à leur diffusion ici. Si
un auteur souhaite que ses sources ne soit pas diffusées, il suffit
simplement de nous en demander le retrait.


Informations complémentaires
----------------------------

Le [site de Jean-François
Garnier](http://www.jeffcalc.hp41.eu/emu71/jpcrom.html) contient beaucoup
d'informations sur **JPC Rom** et les développements qui ont suivi cette
version E, développements auxquels nous n'avons pas participé.


Auteurs de ce dépôt
-------------------

Pierre David et Janick Taillandier (22 décembre 2022)


Licence
-------

Hormis quelques fichiers produits par les créateurs de ce dépôt,
tous les sources de **JPC Rom** ont été publiés à l'époque dans le
[journal JPC](http://www.jeffcalc.hp41.eu/divers/index.html#jpc) dont
les archives ont été scannées et publiées par Jean-François Garnier.
Les informations n'étaient couvertes que par le droit d'auteur français.

Les fichiers sources non publiés dans le journal JPC, ainsi que la
documentation, ont été créés par Pierre David et Janick Taillandier.
Nous plaçons ces fichiers sous [licence Creative-Commons BY-NC-SA
4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).
