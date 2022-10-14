MBASE   EQU    0
=eHEAD  EQU    (MBASE)+0    JPC 
=eDRIVE EQU    (MBASE)+1    Driver Lex File
=eNFND  EQU    (MBASE)+2    Not Found
=eSTRUC EQU    (MBASE)+3    Structure Mismatch
=eIPRMP EQU    (MBASE)+4    Invalid Prompt
=eIFMT  EQU    (MBASE)+5    Invalid Format
=eIDIM  EQU    (MBASE)+6    #Dims
=eINOVR EQU    (MBASE)+7    Var Not Found
=eSUN   EQU    (MBASE)+8    Sunday
=eMON   EQU    (MBASE)+9    Monday
=eTUE   EQU    (MBASE)+10   Tuesday
=eWED   EQU    (MBASE)+11   Wednesday
=eTHU   EQU    (MBASE)+12   Thursday
=eFRI   EQU    (MBASE)+13   Friday
=eSAT   EQU    (MBASE)+14   Saturday
=eFNINT EQU    (MBASE)+15   Function Interrupted
=eOBSOL EQU    (MBASE)+16   Removed Keyword
=eXMEM  EQU    (MBASE)+17   Insufficient Memory
=teICMD EQU    (MBASE)+18   Invalid Cmd
=teIPAT EQU    (MBASE)+19   Invalid Pattern
=teICMP EQU    (MBASE)+20   No Room for Pattern
=tePLIN EQU    (MBASE)+21   Line ^, Cmd:
=tePEOF EQU    (MBASE)+22   Eof, Cmd:
=teEOF  EQU    (MBASE)+23   [Eof]
=teDELE EQU    (MBASE)+24   Ok to Delete? Y/N:
=teCONF EQU    (MBASE)+25   Yes/No/Quit ?
=teKEYS EQU    (MBASE)+26   YNQ
=teVCMD EQU    (MBASE)+27   CDEHIJLMPQRSTX
=teHL00 EQU    (MBASE)+28   Copy: [b[e]] C [<file>]
=teHL01 EQU    (MBASE)+29   Delete: [b[e]] D [<file>[+]]
=teHL02 EQU    (MBASE)+30   Exit: E
=teHL03 EQU    (MBASE)+31   Help: H [<cmd>]
=teHL04 EQU    (MBASE)+32   Insert: [l] I
=teHL05 EQU    (MBASE)+33   Join: [b[e]] [?] J [n]
=teHL06 EQU    (MBASE)+34   List: [b[e]] L [n][N]
=teHL07 EQU    (MBASE)+35   Move: [b[e]] M [<file>]
=teHL08 EQU    (MBASE)+36   Print: [b[e]] P [n][N]
=teHL09 EQU    (MBASE)+37   Quit: Q
=teHL10 EQU    (MBASE)+38   Replace: [b[e]] [?] R/str1/str2[/]
=teHL11 EQU    (MBASE)+39   Search: [b[e]] [?] S/str[/]
=teHL12 EQU    (MBASE)+40   Text: [l] T
=teHL13 EQU    (MBASE)+41   Exchange File: X <file>
=eCPYRG EQU    (MBASE)+42   (c) 1986, 1987, 1988, 1989 PPC-Paris

BB43    EQU    43           JPC 
BB44    EQU    44           Driver Lex File
BB45    EQU    45           Not Found
BB46    EQU    46           Structure Mismatch
BB47    EQU    47           Invalid Prompt

=MSGTBL
        CON(2) (MBASE)+0    Lowest message #
        CON(2) (MBASE)+42   Highest message #

* #Dims
        CON(2) 16
        CON(2) =eIDIM   Message # 6
        CON(1) 4
        NIBASC '#Dims'
        CON(1) 12

* JPC 
        CON(2) 14
        CON(2) =eHEAD   Message # 0
        CON(1) 3
        NIBASC 'JPC '
        CON(1) 12

* Driver Lex File
        CON(2) 37
        CON(2) =eDRIVE  Message # 1
        CON(1) 11
        CON(1) 14
        NIBASC 'Driver L'
        NIBASC 'ex File'
        CON(1) 12

* Not Found
        CON(2) 24
        CON(2) =eNFND   Message # 2
        CON(1) 8
        NIBASC 'Not Foun'
        NIBASC 'd'
        CON(1) 12

* Structure Mismatch
        CON(2) 44
        CON(2) =eSTRUC  Message # 3
        CON(1) 11
        CON(1) 15
        NIBASC 'Structur'
        NIBASC 'e Mismat'
        CON(1) 1
        NIBASC 'ch'
        CON(1) 12

* Invalid Prompt
        CON(2) 21
        CON(2) =eIPRMP  Message # 4
        CON(1) 14
        CON(2) 236
        CON(1) 5
        NIBASC 'Prompt'
        CON(1) 12

* Invalid Format
        CON(2) 21
        CON(2) =eIFMT   Message # 5
        CON(1) 14
        CON(2) 236
        CON(1) 5
        NIBASC 'Format'
        CON(1) 12

* Var Not Found
        CON(2) 15
        CON(2) =eINOVR  Message # 7
        CON(1) 2
        NIBASC 'Var'
        CON(1) 14
        CON(2) 232
        CON(1) 12

* Sunday
        CON(2) 15
        CON(2) =eSUN    Message # 8
        CON(1) 2
        NIBASC 'Sun'
        CON(1) 13
        CON(2) BB43
        CON(1) 12

* Monday
        CON(2) 15
        CON(2) =eMON    Message # 9
        CON(1) 2
        NIBASC 'Mon'
        CON(1) 13
        CON(2) BB43
        CON(1) 12

* Tuesday
        CON(2) 17
        CON(2) =eTUE    Message # 10
        CON(1) 3
        NIBASC 'Tues'
        CON(1) 13
        CON(2) BB43
        CON(1) 12

* Wednesday
        CON(2) 21
        CON(2) =eWED    Message # 11
        CON(1) 5
        NIBASC 'Wednes'
        CON(1) 13
        CON(2) BB43
        CON(1) 12

* Thursday
        CON(2) 19
        CON(2) =eTHU    Message # 12
        CON(1) 4
        NIBASC 'Thurs'
        CON(1) 13
        CON(2) BB43
        CON(1) 12

* Friday
        CON(2) 15
        CON(2) =eFRI    Message # 13
        CON(1) 2
        NIBASC 'Fri'
        CON(1) 13
        CON(2) BB43
        CON(1) 12

* Saturday
        CON(2) 19
        CON(2) =eSAT    Message # 14
        CON(1) 4
        NIBASC 'Satur'
        CON(1) 13
        CON(2) BB43
        CON(1) 12

* Function Interrupted
        CON(2) 48
        CON(2) =eFNINT  Message # 15
        CON(1) 11
        CON(1) 15
        NIBASC 'Function'
        NIBASC ' Interru'
        CON(1) 3
        NIBASC 'pted'
        CON(1) 12

* Removed Keyword
        CON(2) 37
        CON(2) =eOBSOL  Message # 16
        CON(1) 11
        CON(1) 14
        NIBASC 'Removed '
        NIBASC 'Keyword'
        CON(1) 12

* Insufficient Memory
        CON(2) 46
        CON(2) =eXMEM   Message # 17
        CON(1) 11
        CON(1) 15
        NIBASC 'Insuffic'
        NIBASC 'ient Mem'
        CON(1) 2
        NIBASC 'ory'
        CON(1) 12

* Invalid Cmd
        CON(2) 15
        CON(2) =teICMD  Message # 18
        CON(1) 14
        CON(2) 236
        CON(1) 2
        NIBASC 'Cmd'
        CON(1) 12

* Invalid Pattern
        CON(2) 11
        CON(2) =teIPAT  Message # 19
        CON(1) 14
        CON(2) 236
        CON(1) 13
        CON(2) BB44
        CON(1) 12

* No Room for Pattern
        CON(2) 34
        CON(2) =teICMP  Message # 20
        CON(1) 11
        CON(1) 11
        NIBASC 'No Room '
        NIBASC 'for '
        CON(1) 13
        CON(2) BB44
        CON(1) 12

* Line ^, Cmd:
        CON(2) 31
        CON(2) =tePLIN  Message # 21
        CON(1) 4
        NIBASC 'Line '
        NIBHEX f2
        CON(1) 5
        NIBASC ', Cmd:'
        CON(1) 12

* Eof, Cmd:
        CON(2) 24
        CON(2) =tePEOF  Message # 22
        CON(1) 8
        NIBASC 'Eof, Cmd'
        NIBASC ':'
        CON(1) 12

* [Eof]
        CON(2) 16
        CON(2) =teEOF   Message # 23
        CON(1) 4
        NIBASC '[Eof]'
        CON(1) 12

* Ok to Delete? Y/N:
        CON(2) 44
        CON(2) =teDELE  Message # 24
        CON(1) 11
        CON(1) 15
        NIBASC 'Ok to De'
        NIBASC 'lete? Y/'
        CON(1) 1
        NIBASC 'N:'
        CON(1) 12

* Yes/No/Quit ?
        CON(2) 33
        CON(2) =teCONF  Message # 25
        CON(1) 11
        CON(1) 12
        NIBASC 'Yes/No/Q'
        NIBASC 'uit ?'
        CON(1) 12

* YNQ
        CON(2) 12
        CON(2) =teKEYS  Message # 26
        CON(1) 2
        NIBASC 'YNQ'
        CON(1) 12

* CDEHIJLMPQRSTX
        CON(2) 35
        CON(2) =teVCMD  Message # 27
        CON(1) 11
        CON(1) 13
        NIBASC 'CDEHIJLM'
        NIBASC 'PQRSTX'
        CON(1) 12

* Copy: [b[e]] C [<file>]
        CON(2) 34
        CON(2) =teHL00  Message # 28
        CON(1) 5
        NIBASC 'Copy: '
        CON(1) 13
        CON(2) BB45
        CON(1) 2
        NIBASC 'C ['
        CON(1) 13
        CON(2) BB46
        CON(1) 0
        NIBASC ']'
        CON(1) 12

* Delete: [b[e]] D [<file>[+]]
        CON(2) 44
        CON(2) =teHL01  Message # 29
        CON(1) 7
        NIBASC 'Delete: '
        CON(1) 13
        CON(2) BB45
        CON(1) 2
        NIBASC 'D ['
        CON(1) 13
        CON(2) BB46
        CON(1) 3
        NIBASC '[+]]'
        CON(1) 12

* Exit: E
        CON(2) 20
        CON(2) =teHL02  Message # 30
        CON(1) 6
        NIBASC 'Exit: E'
        CON(1) 12

* Help: H [<cmd>]
        CON(2) 37
        CON(2) =teHL03  Message # 31
        CON(1) 11
        CON(1) 14
        NIBASC 'Help: H '
        NIBASC '[<cmd>]'
        CON(1) 12

* Insert: [l] I
        CON(2) 33
        CON(2) =teHL04  Message # 32
        CON(1) 11
        CON(1) 12
        NIBASC 'Insert: '
        NIBASC '[l] I'
        CON(1) 12

* Join: [b[e]] [?] J [n]
        CON(2) 40
        CON(2) =teHL05  Message # 33
        CON(1) 5
        NIBASC 'Join: '
        CON(1) 13
        CON(2) BB45
        CON(1) 8
        NIBASC '[?] J [n'
        NIBASC ']'
        CON(1) 12

* List: [b[e]] L [n][N]
        CON(2) 27
        CON(2) =teHL06  Message # 34
        CON(1) 5
        NIBASC 'List: '
        CON(1) 13
        CON(2) BB45
        CON(1) 0
        NIBASC 'L'
        CON(1) 13
        CON(2) BB47
        CON(1) 12

* Move: [b[e]] M [<file>]
        CON(2) 34
        CON(2) =teHL07  Message # 35
        CON(1) 5
        NIBASC 'Move: '
        CON(1) 13
        CON(2) BB45
        CON(1) 2
        NIBASC 'M ['
        CON(1) 13
        CON(2) BB46
        CON(1) 0
        NIBASC ']'
        CON(1) 12

* Print: [b[e]] P [n][N]
        CON(2) 29
        CON(2) =teHL08  Message # 36
        CON(1) 6
        NIBASC 'Print: '
        CON(1) 13
        CON(2) BB45
        CON(1) 0
        NIBASC 'P'
        CON(1) 13
        CON(2) BB47
        CON(1) 12

* Quit: Q
        CON(2) 20
        CON(2) =teHL09  Message # 37
        CON(1) 6
        NIBASC 'Quit: Q'
        CON(1) 12

* Replace: [b[e]] [?] R/str1/str2[/]
        CON(2) 66
        CON(2) =teHL10  Message # 38
        CON(1) 8
        NIBASC 'Replace:'
        NIBASC ' '
        CON(1) 13
        CON(2) BB45
        CON(1) 11
        CON(1) 15
        NIBASC '[?] R/st'
        NIBASC 'r1/str2['
        CON(1) 1
        NIBASC '/]'
        CON(1) 12

* Search: [b[e]] [?] S/str[/]
        CON(2) 51
        CON(2) =teHL11  Message # 39
        CON(1) 7
        NIBASC 'Search: '
        CON(1) 13
        CON(2) BB45
        CON(1) 11
        CON(1) 11
        NIBASC '[?] S/st'
        NIBASC 'r[/]'
        CON(1) 12

* Text: [l] T
        CON(2) 28
        CON(2) =teHL12  Message # 40
        CON(1) 10
        NIBASC 'Text: [l'
        NIBASC '] T'
        CON(1) 12

* Exchange File: X <file>
        CON(2) 45
        CON(2) =teHL13  Message # 41
        CON(1) 11
        CON(1) 15
        NIBASC 'Exchange'
        NIBASC ' File: X'
        CON(1) 0
        NIBASC ' '
        CON(1) 13
        CON(2) BB46
        CON(1) 12

* (c) 1986, 1987, 1988, 1989 PPC-Paris
        CON(2) 82
        CON(2) =eCPYRG  Message # 42
        CON(1) 11
        CON(1) 15
        NIBASC '(c) 1986'
        NIBASC ', 1987, '
        CON(1) 11
        CON(1) 15
        NIBASC '1988, 19'
        NIBASC '89 PPC-P'
        CON(1) 3
        NIBASC 'aris'
        CON(1) 12

* day
        CON(2) 12
        CON(2) BB43     Message # 43
        CON(1) 2
        NIBASC 'day'
        CON(1) 12

* Pattern
        CON(2) 20
        CON(2) BB44     Message # 44
        CON(1) 6
        NIBASC 'Pattern'
        CON(1) 12

* [b[e]] 
        CON(2) 20
        CON(2) BB45     Message # 45
        CON(1) 6
        NIBASC '[b[e]] '
        CON(1) 12

* <file>
        CON(2) 18
        CON(2) BB46     Message # 46
        CON(1) 5
        NIBASC '<file>'
        CON(1) 12

*  [n][N]
        CON(2) 20
        CON(2) BB47     Message # 47
        CON(1) 6
        NIBASC ' [n][N]'
        CON(1) 12

        NIBHEX FF       Table terminator
