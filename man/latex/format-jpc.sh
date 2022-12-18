#!/bin/sh

set -e
set -u

DIRECTAWK=./dir.awk

jpcdir ()
{
    # process JPCRom directives (such as .keyword, .example, etc.)
    # and writes latex code on stdout, with special characters : \ { }
    # substituted as:
    #	chr 001 = \
    #	chr 002 = {
    #	chr 003 = }
    awk -f $DIRECTAWK
}

specialchar ()
{
    # process special characters to restore their normal meanings
    # (i.e. convert back chr 001 to "\", etc.)
    awk '{
	    gsub ("\001", "\\")
	    gsub ("\002", "{")
	    gsub ("\003", "}")
	    print
	}' -
}

if [ $# != 2 ]
then
    echo "usage: $0 <sourcedir> <destdir>" >&2
    exit 1
fi
INDIR="$1"
OUTDIR="$2"

for f in $(ls "$INDIR/"*.jpc)
do
    base=$(basename $f .jpc)
    jpcpf < $f | jpcdir | specialchar > $OUTDIR/$base.tex
done

for f in $(ls "$INDIR/"*.pf)
do
    base=$(basename $f .pf)
    jpcpf -d < $f > $OUTDIR/$base.tex
done
