CFLAGS = -g -Wall -Wextra -Werror

L = fr
DIR = D

all:	jpcpf man.pdf

man.pdf: jpcpf man.tex $(DIR)/a.tex
	xelatex man
	xelatex man
	xelatex man

$(DIR)/a.tex: ../$(L)/a.pf jpcpf dir.awk
	rm -rf $(DIR)
	mkdir $(DIR)
	sh format-jpc.sh ../$(L)

clean:
	rm -rf $(DIR)
	rm -f jpcpf
	rm -f *.log *.aux *.toc *.out
	rm -f *.pdf
