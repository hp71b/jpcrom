#!/bin/sh

sed '	s/[ 	][ 	]*$//
	s/^\\//g
	s/\^*{1\(.*\)}/\\chapter {\1}/g
	s/\^*{2\(.*\)}/\\section {\1}/g
	s/\^*{3\(.*\)}/\\subsection {\1}/g
	s/\^*{4\(.*\)}/\\subsubsection {\1}/g
	s/\^*{5\(.*\)}/\\paragraph {\1}/g
	s/{g/{\\bf /g
	s/{i/{\\em /g
	s/{p/{\\small /g
	s/{[cl]/{\\tt /g
	s/{n/{\\rm /g
	s/{h/{\\Large\\sf /g
	s/{m/{MATHMATH /g
	s/{_/{UNDERSCORE /g
	s/{^/{EXPOSANT /g
	s/{v/{INDICE /g
	s/{-/{NORMAL /g
	s/« */``/
	s/ *»/'"''"'/' $* |

    awk 'BEGIN	{
		    etat = 0
		    last = ""
		}
	/\\$/	{
		    if (etat != 0)
			print last

		    last = substr ($0, 1, length ($0) - 1)
		    etat = 1
		    next
		}
	/^$/	{
		    if (etat != 0)
		    {
			print last
			etat = 0
		    }
		    print $0
		    next
		}
		{
		    if (etat != 0)
		    {
			print last " \\par"
			etat = 0
		    }
		    print $0
		}
	  END	{
		    if (etat != 0)
		    {
			print last
			etat = 0
		    }
		}'
