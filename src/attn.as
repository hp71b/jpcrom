	 TITLE	ATTNLEX <attn.as>
*
* JPC:A05
*   87/02/02: PD gain de beaucoup d'octets !
*

************************************************************
* ATTN
************************************************************

	REL(5) =ATTNd	  Décompilation.
	REL(5) =ATTNp	  Parse

=ATTNe
	D1=(5) =ATNDIS
	A=DAT0 B	 A(B) := token suivant ATTN
*
* tON = E0
* tOFF = E1
*   ATTN ON <==> (ATNDIS) := 0	  (0)
*   ATTN OFF <==> (ATNDIS) := #0  (1)
*
	DAT1=A 1	ATNDIS := 0 ou 1
	GOVLNG =NXTSTM	Et on revient a BASIC.

	END
