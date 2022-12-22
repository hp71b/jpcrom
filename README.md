JPC Rom
=======

[[French version/Version française](README-fr.md)]

This repository contains all the source files for **JPC Rom** as well as
the original files used to build the extensive documentation of more
than 200 pages for the E version of the ROM, as they existed in
october 1989.


What is JPC Rom?
----------------

**JPC Rom** is a module conceived around the end of the 80s for
the [''pocket computer HP-71B''](https://en.wikipedia.org/wiki/HP-71B)
by contributors, members of the PPC Paris club. This club gathered
Hewlett-Packard calculators owners, including the HP-71B.  Entirely
written in assembly language (about 50 000 source code lines) for
the (processor HP Saturn)[https://en.wikipedia.org/wiki/HP_Saturn], **JPC Rom**
extends the functionalities of the HP-71B in various areas as shown in
the documentation.


Why this repository?
--------------------

After years of sleeping, the original files which constitute **JPC Rom**
have been found in our archives. We think that these elements could be
useful to future historians or simply to enthusiasts of HP calculators
and more precisely the HP-71B or the Saturn processor.

The aim is not to revive **JPC Rom** but to document the final version
that we produced at the time. No changes are planned.


Building the LEX from the source files
--------------------------------------

Complete source files for the version E are available in the `src/`
directory.

The assembler/link editor used to build the LEX from the source files
is available here 
[https://github.com/hp71b/areuh](https://github.com/hp71b/areuh).
Under Unix, with `aas`, `amg` and `ald` in the PATH, you just type
`make` in the `src/` directory to rebuild the LEX file.


Building the documentation
--------------------------

Source code for the dedicated formatter used to produce the
manual has been lost. A tool was designed in 2022 by Pierre
David to translate the formatting instructions to LaTeX in
order to rebuild the documentation, and produce PDF files for
the [English](https://hp71b.github.io/jpcrom/man-en.pdf) and
[French](https://hp71b.github.io/jpcrom/man-fr.pdf) manuals.

Under Unix, to generate the documentation go to the `man/latex/`
directory and type `make`. Prerequisites: you need a C compiler,
`awk`, and the texlive distribution (in particular `xetex`).

The English manual was not updated for the E version and so it documents
the D version (missing from the documentation are the graphic functions
and the text editor).

Both [English PDF manual]((https://hp71b.github.io/jpcrom/man-en.pdf)
and [French PDF manual](https://hp71b.github.io/jpcrom/man-en.pdf)
should be printed double-sided.


Warning: character encoding
---------------------------

All these files were originally encoded with the
[HP-Roman8](https://en.wikipedia.org/wiki/HP_Roman#Roman-8) character set,
the native character set on HP-71B.

  - Source files for the module (in the `src/` directory) has been
    converted to UTF-8 for easy reading
  - Files used to generate documentation (in the `man/fr` and `man/en`
    directories were left in HP-Roman8 so as not to disturb during
    treatment phases (such as building the documentation).


JPC Rom contributors
--------------------

Begining with the release of the HP-71 and the FORTH Assembler module,
many PPC Paris members have produced LEX files to improve the
existing functionnalities or create new ones. All these works have
been published in the JPC Journal as can be seen in the [archives
published by Jean-François
Garnier](http://www.jeffcalc.hp41.eu/divers/index.html#jpc).

When Corvallis Micro Technology introduced EPROM modules compatibles
with the HP-71B ports, it was possible to go a step further and merge
all these files to produce a real ROM. The various ressources used,
begining with the LEX ID, have been booked with Hewlett-Packard.

All the source files we have not developped ourselves have been
published in JPC and are available in the
[archive](http://www.jeffcalc.hp41.eu/divers/index.html#jpc).
So we think nothing prevents their diffusion in this repository. If an
author doesn't wish his source files be republished, he just need to ask
us for their withdrawal.


Additional informations
-----------------------

[Jean-François Garnier's site](http://www.jeffcalc.hp41.eu/emu71/jpcrom.html)
contains further information on **JPC Rom** and the
developpments beyond the E version, in wich we have played no part.


Creators of this repository
---------------------------

Pierre David and Janick Taillandier (December 22nd, 2022)


License
-------

Apart from a few files produced by the creators of this repository,
all works for **JPC Rom** have been published at this time in the [JPC
journal](http://www.jeffcalc.hp41.eu/divers/index.html#jpc) which have
been scanned and published by Jean-François Garnier. These texts were
only covered by French copyright law.

Source files not published in the JPC journal, as well as
the documentation, were created by Pierre David and Janick
Taillandier. We place these files under the [Creative-Commons BY-NC-SA
license](https://creativecommons.org/licenses/by-nc-sa/4.0/).
