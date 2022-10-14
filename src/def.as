	TITLE  Ressources utilisées par les modules <def.as>
 
*
* JPC:B03
*   87/12/06: PD/JT Création du fichier à partir de KA
*   87/12/06: PD/JT Ajout de RESJPC
*   87/12/06: PD/JT Ajout des définitions de FINPUT
*   87/12/06: PD/JT Ajout des définitions de MARGIN
*   87/12/10: PD/JT Ajout de KEYWAIT$
*   87/12/10: PD/JT Ajout de CHPMAX, CHPCOU pour poll FINPUT
* JPC:C03
*   88/04/16: PD/JT INENDL pour remplacer "indic" dans pol
* JPC:D02
*   89/06/18: PD/JT INEDIT pour indiquer qu'on est ds XEDIT
*

=fADRS	EQU    #E224	Type de fichier ADRS
=RESJPC EQU    #2F991	Ram réservée de JPC ROM

=tSINPUT EQU   93	Token de FINPUT
=INSINP EQU    =RESJPC
=INSMSK EQU    %0001	Bit utilisé par FINPUT

=ASFMSK EQU    %0010	Bit utilisé par ASSFIELD

=MARGEr EQU    =RESJPC
=MARGEm EQU    %0100	Bit utilisé par MARGIN
=bMARGE EQU    #83D	Buffer utilisé par MARGIN

=fDLEX	EQU    #00FF

=tKEYWT EQU    #1
=iKEYWT EQU    #52	User's Library Lex
=bCHARs EQU    (=bCHARS)&(#7FF) Avant configuration

=CHPCOU EQU    =LDCSPC	Champ courant dans le poll de FINPUT
	 *		((1..CHPMAX))
=CHPMAX EQU    =n	Defini dans fbas.as...
=INENDL	EQU    1+=STSAVE nb d'appuis successifs sur [ENDLN]
	 *		dans FINPUT ou KA

=INEDIT	EQU    %1000	bit de T/XEDIT

	END
