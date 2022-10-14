	TITLE  KEYWAIT <keywait.as>

=LEX4

*
* JPC:B03
*   87/12/10: PD/JT Intégration dans JPC Rom
*

	CON(2) =iKEYWT
	CON(2) =tKEYWT	Min Token
	CON(2) =tKEYWT	Max Token
	REL(5) =LEX5	"Next Lex" chain (gmmain.as)

	NIBHEX F	No speed table
	REL(4) 1+TxTbSt
	CON(4) 0	No message table
	CON(5) 0	No poll handler
*
* Main table
*
	CON(3) (TxEn01)-(TxTbSt)
	REL(5) =KEYWAITe
	CON(1) #F
*
* Text Table
*
 TxTbSt
 TxEn01 CON(1) 15
	NIBASC 'KEYWAIT$'
	CON(2) =tKEYWT

	NIBHEX 1FF
	
	NIBHEX 00
=KEYWAITe
	CD0EX
	R0=C
	CD1EX
	R1=C
 KW10	GOSBVL =SLEEP
	GOC    KW20
	C=R1
	D1=C
	C=R0
	D0=C
	GOVLNG =KEY$
 KW20	GOSBVL =CKSREQ
	GOTO   KW10

	END
