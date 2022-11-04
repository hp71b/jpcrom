BEGIN { etat = 0 }

# detection du .purpose
# passage en etat 1
/^\.purpose/	{   etat = 1
		    pteur = 0
		    next
		}

# detection du .syntaxe
# passage en etat 3
/^\.syntaxe/	{   etat = 3
		    next
		}

# sortie des etats 1 ou 3
# si etat = 3 : affichage du .purpose
/^ *$|^\./	{   if (etat==3)
		    {
			ligne [0] = sprintf ("\\{n%s", ligne [0])
			ligne [pteur-1] = sprintf ("%s\\", ligne [pteur-1])
			for (i=0 ; i<pteur; i++)
			    printf "%s\n", ligne [i]
		        pteur = 0
			printf "\n"
		    }
		    etat=0
		}

# toute ligne :
# si etat 1 : memoriser
# si etat 3 : imprimer
		{   if (etat == 1)
		    {
			ligne [pteur] = $0
			pteur++
		    }
		    else if (etat == 3)
		    {
			printf "{c%s\n", $0
		    }
		}
