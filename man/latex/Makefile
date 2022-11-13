CFLAGS = -g -Wall -Wextra -Werror

.SUFFIXES:	.pdf .tex

.tex.pdf:
	xelatex $*
	xelatex $*
	xelatex $*

all:	jpcpf man-fr.pdf man-en.pdf

man-fr.pdf: jpcpf D-fr/a.tex
man-en.pdf: jpcpf D-en/a.tex

D-fr/a.tex: ../fr/a.jpc jpcpf dir.awk
	rm -rf D-fr
	mkdir D-fr
	sh format-jpc.sh ../fr D-fr

D-en/a.tex: ../en/a.jpc jpcpf dir.awk
	rm -rf D-en
	mkdir D-en
	sh format-jpc.sh ../en D-en

clean:
	rm -rf D-fr D-en
	rm -f jpcpf
	rm -f *.log *.aux *.toc *.out
	rm -f *.pdf
