MBASE   EQU    0
=eGRAPH EQU    (MBASE)+0    GRPH 
=eIVGRT EQU    (MBASE)+1    Invalid Graph type
=eGNTIN EQU    (MBASE)+2    Graph not initialized
=eNOLOP EQU    (MBASE)+3    No Loop
=eMODMS EQU    (MBASE)+4    Module missing
=eSVRER EQU    (MBASE)+5    Severe error
=ePLTRC EQU    (MBASE)+6    Plotter not reachable
=eGHILE EQU    (MBASE)+7    GRAPHILE Not found

BB8     EQU    8            GRPH 
BB9     EQU    9            Invalid Graph type

=GRAMSG
        CON(2) (MBASE)+0    Lowest message #
        CON(2) (MBASE)+7    Highest message #

* GRPH 
        CON(2) 16
        CON(2) =eGRAPH  Message # 0
        CON(1) 4
        NIBASC 'GRPH '
        CON(1) 12

* Invalid Graph type
        CON(2) 20
        CON(2) =eIVGRT  Message # 1
        CON(1) 14
        CON(2) 236
        CON(1) 13
        CON(2) BB8
        CON(1) 3
        NIBASC 'type'
        CON(1) 12

* Graph not initialized
        CON(2) 40
        CON(2) =eGNTIN  Message # 2
        CON(1) 13
        CON(2) BB8
        CON(1) 11
        CON(1) 14
        NIBASC 'not init'
        NIBASC 'ialized'
        CON(1) 12

* No Loop
        CON(2) 20
        CON(2) =eNOLOP  Message # 3
        CON(1) 6
        NIBASC 'No Loop'
        CON(1) 12

* Module missing
        CON(2) 35
        CON(2) =eMODMS  Message # 4
        CON(1) 11
        CON(1) 13
        NIBASC 'Module m'
        NIBASC 'issing'
        CON(1) 12

* Severe error
        CON(2) 31
        CON(2) =eSVRER  Message # 5
        CON(1) 11
        CON(1) 11
        NIBASC 'Severe e'
        NIBASC 'rror'
        CON(1) 12

* Plotter not reachable
        CON(2) 50
        CON(2) =ePLTRC  Message # 6
        CON(1) 11
        CON(1) 15
        NIBASC 'Plotter '
        NIBASC 'not reac'
        CON(1) 4
        NIBASC 'hable'
        CON(1) 12

* GRAPHILE Not found
        CON(2) 25
        CON(2) =eGHILE  Message # 7
        CON(1) 7
        NIBASC 'GRAPHILE'
        CON(1) 13
        CON(2) BB9
        CON(1) 12

* Graph 
        CON(2) 18
        CON(2) BB8      Message # 8
        CON(1) 5
        NIBASC 'Graph '
        CON(1) 12

*  Not found
        CON(2) 26
        CON(2) BB9      Message # 9
        CON(1) 9
        NIBASC ' Not fou'
        NIBASC 'nd'
        CON(1) 12

        NIBHEX FF       Table terminator
