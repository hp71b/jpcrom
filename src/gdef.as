	TITLE	Graphique, définitions globales <gdef.as>

************************************************************
* GRAPHIQUE
*
* Version 0 : (85/09/00 -> 87/02/26)
*   id	     #D0
*   pGRAPH   #D0
*   bMAIN    #D00
*   bDRIVR   #D01
*   GRAPH    #E228 / #E229
* Version A : (87/03/26 -> 87/03/26)
*   Reception des nouvelles allocations de ressources
*   id	     #68
*   pGRAPH   #48
*   bMAIN    #83B
*   bDRIVR   #83C
*   GRAPH    #E222 / #E223
*   Debogage de TICLEN (gbas.as & r1.as)
*   VER$ = "GRPH:A RSTR:B"
* Intégration dans JPC Rom (89/06/18)
************************************************************

=graid	   EQU	  #68

=pGRAPH EQU    #48	Poll Graphique

=prINIT EQU    0	Debut d'une session graphique
=prEND	EQU    1	Fin de session graphique
=prDBUT EQU    2	Debut d'envoi d'ordres HPGL
=prFIN	EQU    3	Fin d'envoi d'ordres HPGL

=nOP	EQU    01	Output P1 & P2
=nOA	EQU    02	Output Actual position
=nOE	EQU    03	Output Error
=nIW	EQU    04	Input Window
=nIP	EQU    05	Input P1 & P2
=nSP	EQU    06	Select Pen
=nDF	EQU    07	DeFault
=nTL	EQU    08	Tick Len
=nPA	EQU    09	Plot Absolute
=nPD	EQU    10	Pen Down
=nPU	EQU    11	Pen Up
=nDI	EQU    12	set absolute DIrection
=nSI	EQU    13	character SIze
=nSL	EQU    14	character SLant
=nLB	EQU    15	LaBel
=nCP	EQU    16	Character Plot
=nXT	EQU    17	X Tick
=nYT	EQU    18	Y Tick
=nLT	EQU    19	Line Type
=nDU	EQU    20	DUmp

=fGRAPH EQU    #E222	Type de la memoire graphique

=bMAIN	EQU    #83B	Buffer du module maitre
=bDRIVR EQU    #83C	Buffer autorise pour les drivers

	END
