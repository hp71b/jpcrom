	TITLE	Graphique, module maître <gmmain.as>

=DRIVER EQU    (=TRFMBF)+00
=MBUF	EQU    (=TRFMBF)+05
=LOCAL	EQU    (=TRFMBF)+10  debut des variables locales

=LEX5
	CON(2) =graid	  id
	CON(2) 1	  lowest token
	CON(2) 21	  highest token
	CON(5) 0	  next lex chain
	NIBHEX F	  no speed table
	REL(4) (TxTbSt)+1
	REL(4) =GRAMSG	  message table
	REL(5) =GRAPOL	  poll handler (grmain.as)

	CON(3) (TxEn01)-(TxTbSt)
	REL(5) =BOXe
	CON(1) #D
	CON(3) (TxEn02)-(TxTbSt)
	REL(5) =CSIZEe
	CON(1) #D
	CON(3) (TxEn03)-(TxTbSt)
	REL(5) =DRAWe
	CON(1) #D
	CON(3) (TxEn04)-(TxTbSt)
	REL(5) =FRAMEe
	CON(1) #D
	CON(3) (TxEn05)-(TxTbSt)
	REL(5) =GDUMPe
	CON(1) #D
	CON(3) (TxEn06)-(TxTbSt)
	REL(5) =GENDe
	CON(1) #D
	CON(3) (TxEn07)-(TxTbSt)
	REL(5) =GINITe
	CON(1) #D
	CON(3) (TxEn08)-(TxTbSt)
	REL(5) =IDRAWe
	CON(1) #D
	CON(3) (TxEn09)-(TxTbSt)
	REL(5) =IMOVEe
	CON(1) #D
	CON(3) (TxEn10)-(TxTbSt)
	REL(5) =LABELe
	CON(1) #D
	CON(3) (TxEn11)-(TxTbSt)
	REL(5) =LDIRe
	CON(1) #D
	CON(3) (TxEn12)-(TxTbSt)
	REL(5) =LINETYPEe
	CON(1) #D
	CON(3) (TxEn13)-(TxTbSt)
	REL(5) =LORGe
	CON(1) #D
	CON(3) (TxEn14)-(TxTbSt)
	REL(5) =MOVEe
	CON(1) #D
	CON(3) (TxEn15)-(TxTbSt)
	REL(5) =PENDOWNe
	CON(1) #D
	CON(3) (TxEn16)-(TxTbSt)
	REL(5) =PENUPe
	CON(1) #D
	CON(3) (TxEn17)-(TxTbSt)
	REL(5) =PENe
	CON(1) #D
	CON(3) (TxEn18)-(TxTbSt)
	REL(5) =PLOTTERe
	CON(1) #D
	CON(3) (TxEn19)-(TxTbSt)
	REL(5) =TICLENe
	CON(1) #D
	CON(3) (TxEn20)-(TxTbSt)
	REL(5) =XAXISe
	CON(1) #D
	CON(3) (TxEn21)-(TxTbSt)
	REL(5) =YAXISe
	CON(1) #D

 TxTbSt
 TxEn01 CON(1) 5
	NIBASC 'BOX'	BOX x1,x2,y1,y2
	CON(2) 1
 TxEn02 CON(1) 9
	NIBASC 'CSIZE'	CSIZE haut [,rapport [,pente] ]
	CON(2) 2
 TxEn03 CON(1) 7
	NIBASC 'DRAW'	DRAW x,y
	CON(2) 3
 TxEn04 CON(1) 9
	NIBASC 'FRAME'	FRAME
	CON(2) 4
 TxEn05 CON(1) 9
	NIBASC 'GDUMP'	GDUMP
	CON(2) 5
 TxEn06 CON(1) 7
	NIBASC 'GEND'	GEND
	CON(2) 6
 TxEn07 CON(1) 9
	NIBASC 'GINIT'	GINIT "type" [, n]
	CON(2) 7
 TxEn08 CON(1) 9
	NIBASC 'IDRAW'	IDRAW x, y
	CON(2) 8
 TxEn09 CON(1) 9
	NIBASC 'IMOVE'	IMOVE x, y
	CON(2) 9
 TxEn10 CON(1) 9
	NIBASC 'LABEL'	LABEL "label" [;]
	CON(2) 10
 TxEn11 CON(1) 7
	NIBASC 'LDIR'	LDIR theta
	CON(2) 11
 TxEn12 CON(1) 15
	NIBASC 'LINETYPE' LINETYPE n [ , lg ]
	CON(2) 12
 TxEn13 CON(1) 7
	NIBASC 'LORG'	LORG n
	CON(2) 13
 TxEn14 CON(1) 7
	NIBASC 'MOVE'	MOVE x,y
	CON(2) 14
 TxEn15 CON(1) 13
	NIBASC 'PENDOWN' PENDOWN
	CON(2) 15
 TxEn16 CON(1) 9
	NIBASC 'PENUP'	PENUP
	CON(2) 16
 TxEn17 CON(1) 5
	NIBASC 'PEN'	PEN [ n ]
	CON(2) 17
 TxEn18 CON(1) 13
	NIBASC 'PLOTTER' PLOTTER IS :<device specifier>
	CON(2) 18
 TxEn19 CON(1) 11
	NIBASC 'TICLEN' TICLEN n
	CON(2) 19
 TxEn20 CON(1) 9
	NIBASC 'XAXIS'	XAXIS y [,space [,xmin,xmax] ]
	CON(2) 20
 TxEn21 CON(1) 9
	NIBASC 'YAXIS'	YAXIS x [,space [,ymin,ymax] ]
	CON(2) 21
	NIBHEX 1FF

	END
