^{hMAIN DIFFERENCES

^{hBETWEEN VERSION C AND VERSION D}



\The differences between version C and version D (see
{cVER$} in {iOther JPC Rom features})
result from some bug fixes, modifications and improvements.
The main differences are listed below :\


{gBug fixes}


\The extended character set {iRoman} disappeared at power
on.\

\The {iAssembler Tabs} mode was regularly enabled (during
power on, for example).\

\The {cPOSI} function returned an incorrect value (1) when
used as {cPOSI("",{ix{c)}, with {ix}<6. This bug was
mentioned by Joe Horn in the United States.\

\The new {cDBLIST} version did not recognize the following
syntax : {cDBLIST 1000 INDENT 4}.\

\The {cFIND} keyword did not work properly.
Notified by Henri Kudelski from Switzerland and
Claudio Benski from France.\

\Date calculation functions (such as {cDOW} for example) did
not accept February 29 of leap years, when the last
year digit was not a multiple of 4. Notified with details by
Laurent Istria from France.\

\From {ibrowse mode} in {cKA}, the keystroke
{l[f][EDIT]}, then {l[ENDLINE]} entered {iedit mode}, then
exited it. Notified by Henri Kudelski from Switzerland.\


{gNew keywords and features}

\The {cDDIR} and {cPDIR} keywords have been added.\


{gModifications and improvements}

\Disassembling with {cOPCODE$} and {cSYSEDIT} swapped
{lRSI} and {lPC=(A)} mnemonics. This appeared when we
disassembled the HP-28C Rom.\


{gNote}

\All these improvements and corrections have been realized
preserving program compatibility with previous versions of
JPC Rom. So your programs written with previous versions are
totally compatible with the new JPC Rom.\
