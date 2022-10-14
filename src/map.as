	TITLE  MAP <map.as>
*
* Premiere version :
*   Tapani Tarvainen
* JPC:A06
*   87/04/20: PD/JT Intégration dans JPC Rom
*

*
* Tapani Tarvainen 86/09/07, 87/02/24
*
* Function MAP$ maps given set of characters onto another
* in a string; statement MAP does the same for
* all or part of a TEXT (LIF1) file.
*
* Syntax: MAP$(<str0>,<str1>,<str2>)
*	  MAP <file>,<str1>,<str2>[,<num1>[,<num2>]]
*	  MAP #<chnl>,<str1>,<str2>[,<num1>[,<num2>]]
* where <str0>, <str1> and <str2> are string expressions,
* <num1> and <num2> are numeric expressions,
* <file> is a file specifier (literal or string expr),
* <chnl> is channel number (numeric expression).
* <num1> and <num2> specify beginning and end record;
* defaults are beginning and end of file, respectively.
*
* The file must reside in RAM and it mustn't be secured;
* the strings <str1> and <str2> must be of equal length.
* If some char occurs several times in <str1>,
* it's the first one that counts.
*
* For example, MAP$("calculator","ac","xz") returns
* "zxlzulxtor", and
* MAP F$, "abcdefg...xyz", "ABCDEFG...XYZ"
* will convert entire file F$ to upper case.
*
************************************************
*
* Errors:
* "Chnl# Not Found",
* "Invalid Filespec", "File Not Found" as appropriate;
* "Invalid File Type" if non-TEXT file;
* "Illegal Access" if not in RAM;
* "Protected" if the file is SECUREd;
* "Invalid Arg" if LEN(<str1>)#LEN(<str2>), or
*   <num1> or <num2> negative or >2^20-1
* "Insufficient Memory" results if there isn't enough
*   room for the conversion table (256 bytes, see below);
* "End of File" means the file is bad (record length points
*   beyond end of file).
*
************************************************
*
* Algorithm: Create a 256-byte table, where Nth byte
* is the new value for char N, and replace every char
* in the file with corresponding element in the table.
*
************************************************
*
* It is rather unusual to allow both channel # and filespec
* to be used.  Channel is faster, once the file is opened,
* and so to be preferred if it is likely that the operation
* is done among other file processing, but if it is of
* "global" nature, i.e., if it is likely that a separate
* ASSIGN is needed each time, filespec is clearly better.
* MAP statement was originally conceived as TRANSFORM-like
* total operation, for sending files to different computers
* and printers with different charater sets, so filespec was
* obvious choice; later different applications emerged, with
* need for record limits and situations where the file was
* likely to have been opened, suggesting the use of channel.
* An additional consideration is the need to ensure FIB info
* remains correct, even if the file is referred to by name:
* fortunately, the MAP operation requires no changes to the
* FIB.
* So why not let the user choose?
* The only cost (besides longer code) is an extra byte for
* the # token (it needn't be tokenized if it were mandatory)
* Even that could be avoided, at the cost of still more
* code (lots): if there is a numeric expression it must
* be channel#, else filespec (even that one comma now
* tokenized isn't really necessary, but omitting it
* would cost a ridiculous amount of code (or ingenuity)).
*
************************************************
 
* local symbols
 sMAP$	EQU 3	      flag to distinguish MAP$ and MAP
 
************************************************
* MAP$ function start
 
	 NIBHEX 44433	 3 string params
=MAP$e	 ST=1	sMAP$	 indicates were in MAP$, not MAP
	 CD0EX		 save D0 (program counter)
	 R0=C		 in R0
	 GOTO	bldtbl	 go build conversion table
 
************************************************
* MAP statement run-time code start
 
	REL(5) =MAPd	offset to decompile routine
	REL(5) =MAPp	offset to parse routine
=MAPe	A=DAT0 B	read 1st token to determine
	LCASC  '#'	whether we have channel# or filespec
	?A#C   B	# present?
	GOYES  xfsp	no, go check filespec
 
************************************************
* we have channel#
* find file address, type &c from FIB
	D0=D0+ 2	skip # token
	GOSBVL =GETCH#	channel# to A(B)
	GOSBVL =FIBADR	find FIB entry, save in STMTD1
* locating FIB entry before EXPEXC below means
* trouble with UDFs monkeying with channel #,
* but anybody doing that deserves what he gets
	D0=D0+ 2	step over comma
	GOSBVL =EXPEX-	other arguments to mathstack
	CD1EX
	D0=C
	D1=(5) =STMTD1	recover FIB addr
	C=DAT1 A
	D1=C
	D1=D1+ 5
	C=0    A
	C=DAT1 4	file type
	D1=D1+ 4
	A=DAT1 S	protection
	D1=D1+ 3
	C=DAT1 S	device code
	D=C    S
	D1=D1+ 9
	A=DAT1 A	data start addr
	D1=A
	D1=D1- 5	link field addr
	GONC   chktyp
 
************************************************
* we have filespec
* get type &c from header
 xfsp	GOSBVL =FILXQ^	execute filespec
	GOC    fspOK	filespec OK
	LC(2)  =eFSPEC	"Invalid Filespec"
	GONC   mferr	B.E.T.
* We save FILXQ^ result (file name & port info) in
* statement scratch during EXPEXC. Note that we can't
* call FINDF first, as EXPEXC might change the file
* address, or SECURE or PURGE it (or CREATE!)
 fspOK	D1=(5) =STMTR0	save FILXQ^ result (A & D)
	DAT1=A W	file name
	D1=(2) =STMTR1	port info
* STMTR0 and STMTR1 have same 3 high order digits
	C=D    W
	DAT1=C W
	D0=D0+ 2	step over comma
	GOSBVL =EXPEX-	strings to mathstack
	CD1EX		FINDF+ &c use D1 but not D0,
	D0=C		so we save stack pt in D0
	D1=(5) =STMTR0	recover FILXQ^ result
	A=DAT1 W
	D1=(2) =STMTR1
	C=DAT1 W
	D=C    W
	GOSBVL =FINDF+	find the file
	GOC    mferr	not found, error
	D1=D1+ 16
	C=0    A
	C=DAT1 4	file type
	D1=D1+ 4
	A=DAT1 S	protection
	D1=D1+ 12	at link field
 
************************************************
* the file has been found, either by filespec or channel#
* C(A)=file type, A(S)=protection nib, D(S)=device code
* D1=link field addr, D0=math stack pt
 chktyp C=C-1  A	test type:
	?C=0   A	text?
	GOYES  textf
	LC(2)  =eFTYPE	"Invalid File Type"
 mferr	GOVLNG =MFERR
 textf	GOSBVL =RAMROM	in RAM?
	LC(2)  =eFACCS	"Illegal Access"
	GONC   mferr
	GOSBVL =?PRFI+ check protection
	GOC    mferr  secure, complain
 
* Now we know it's unprotected text file in RAM
	CD0EX		mathstack pt
	CD1EX		back to D1,
	R0=C		link field addr to R0
	ST=0   sMAP$	indicates were in MAP, not MAP$
* clearing sMAP$ earlier isn't a good idea:
* some sub we call (EXPEXC!) might change it
 
************************************************
* now see if record limits were given:
* are there numbers in the mathstack?
	C=0    A	default start record=0
	R1=C
	C=C-1  A	default record count=inf
	R2=C		(or 2^20-1)
	D=0    S	flag 1st time through
* peel numbers (up to 2) from top of mathstack
 num?	LCHEX  9	P=0
	A=DAT1 W	read stack entry
	?A>C   P	real number?
	GOYES  bldtbl	no, go process strings
	D1=D1+ 16	pop it off
	GOSBVL =FLTDH	convert to hex integer
	GONC   argerr	error if negative or too big
	AR1EX		substitute for start record
	D=D-1  S	did we already have a number?
	GOC    num?	no, look for another
	C=R1		yes, it was end record
	A=A-C  A	<end record>-<start record>
	GONC   b<=e	was start record>end record?
	A=0    A	yes, convert start record only
 b<=e	R2=A		number of records to convert -1
 
************************************************
* MAP$ function and MAP statement join here
 
* the strings are in mathstack: get addresses
 bldtbl GOSBVL =POP1S	pop str2
	CD1EX
	D0=C		str2 addr to D0
	B=A    A	str2 length
	A=A+C  A	skip past str2
	D1=A		point at str1 header
	GOSBVL =POP1S	pop str1
	?A=B   A	equal lengths?
	GOYES  strsOK
 argerr GOVLNG =ARGERR	no, Invalid Arg
 strsOK ACEX   A	str2 addr to A (for CHKmem)
	D=0    M	we'd only need to clear nib 5
	D=C    A	length in nibs
	DSRB		in bytes (used as counter)
	CD1EX
	B=C    A	str1 addr to B(A)
 
* The conversion table will be located at AVMEMS
* First we check there is room for it (256 bytes)
	LC(5)  512	# of nibs needed
	GOSBVL =CHKmem	memory check
	GOC    mfer1	Insufficient Memory
	D1=A		available memory start
* Initialize the table to map each char to itself
	C=0    B	start with CHR$(0)
 init	DAT1=C B	write char to table
	D1=D1+ 2	next table element
	C=C+1  B	next char
	GONC   init
 
* Initialization could be done faster as follows:
*	LCHEX  0101010101010101	 assumes P=0
*	A=C    W
*	LCHEX  0706050403020100
* init	DAT1=C W
*	D1=D1+ 16
*	C=C+A  W
*	GONC   init
*
* This would cost 37 nibs and save ca 7000 cycles
 
* Then we change the table so that if Ith char in
* str1 is N, Nth entry is set to Ith char of str2
	ABEX   A	table start to B(A)
	AD1EX		str1 addr to D1
* ready to set up the conversion table:
* D1=str1 addr, D0=str2 addr, B(A)=table addr, D(A)=str len
	D=D-1  A	adjust counter
	GOC    nop	in case str1 & str2 null strings
 setup	A=0    A
	A=DAT1 B	str1 char
	A=A+A  X	double to get nibble offset
	A=A+B  A	add table start
	AD1EX
	C=DAT0 B	corresp. str2 char
	DAT1=C B	put in table
	AD1EX		str1 adr back to D1
	D1=D1+ 2	next char
	D0=D0+ 2	in both strings
	D=D-1  A	decrement counter
	GONC   setup
* table is ready, its addr in B(A)
 
 nop	?ST=0  sMAP$	in MAP statement?
	GOYES  stmt
 
************************************************
* set things up for converting str0 (in mathstack)
	CD1EX		str0 header addr; it is where
	D1=C		D1 (stack pt) must be on exit
	RSTK=C		we save it in RSTK
	A=0    M	need to clear nib 5
	D1=D1+ 2	skip type tag (0F or 8F)
	A=DAT1 A	str0 length (nibs)
	ASRB		convert to bytes
	D1=D1+ 14	skip rest of str0 header
	GOTO   iconv	join MAP
 
************************************************
* End of File -error (corrupted file)
 Eof	LC(2)  =eEOFIL
 mfer1	GOTO   mferr
 
************************************************
* Initialize conversion of file
 stmt	A=R0		recover file addr
	D1=A		link field addr
	A=DAT1 A	link field contents
	D1=D1+ 5	beginning of data
* we need the end-of-file address to check
* if a line length header points beyond it
* (which means the file is corrupted, but
* even that should't cause total disaster)
	CD1EX
	D1=C
	C=A+C  A	end of file
	D=C    A	save in D(A)
	D=0    S	indicates initial skipping phase
************************************************
* File conversion loop
* D1 = next record length field addr
* B(A) = conversion table addr
* D(A) = end-of-file addr (used as a safeguard)
* D(S) = 0 when skipping records before starting
* R1(A) = # of records left to skip/convert
* R(2) = (max) # of records to convert
* P=0
 nxtrec C=R1		records left
	C=C-1  A
	GONC   cont
	?D=0   S	were we skipping initial recs?
	GOYES  action	yes, start the real work
 nxtstm GOVLNG =NXTSTM	all done
 action D=D+1  S	so we know we've been here
	C=R2		record count
 cont	R1=C
* read record header (length field)
	A=0    XS
	A=DAT1 B	1st byte of rec length
	D1=D1+ 2
	ASL    A	move left
	ASL    A
	A=DAT1 B	2nd byte - now in proper order
	D1=D1+ 2
* last 7 lines could be replaced by the following:
*      A=0    A
*      A=DAT1 4
*      D1=D1+ 4
*      GOSBVL =SWPBYT	equ #17A24
* this would save 1 nib and cost 38 cycles / record
	P=     3	so we can test carry below
	A=A+1  WP	must add 1 if odd
	P=     0	if that carried, it's #FFFF
	GOC    nxtstm	i.e., eof, and we're done
	LCHEX  E	P=0
	A=A&C  P	clear lsb
* we'll convert the pad byte too, but who cares
	CD1EX		next check for corrupt file
	D1=C
	C=C+A  A	add rec len twice (it's bytes!)
	C=C+A  A
	?C>D   A	past eof?
	GOYES  Eof	yes, error
	?D#0   S	initial skipping phase?
	GOYES  iconv	no, convert the record
	D1=C		next rec addr
	GONC   nxtrec
 
************************************************
* Here MAP and MAP$ join again
* D1 points to first char of record/str0
* A(A)= # of chars to convert (str/rec length)
* B(A)= conversion table addr
 iconv	A=A-1  A	adjust counter
	GOC    nullst  null string or zero-length record
* innermost loop: this is where the time is spent
 conv	C=0    A
	C=DAT1 B	read char
	C=C+C  X	double to get nibble offset
	C=C+B  A	add table start
	D0=C
* it might be possible to set things up so
* that D0=CS could be used above, and all
* A fields replaced with WP (with P=3) or X,
* but I don't think it's worth the trouble
	C=DAT0 B	read corresp. char in table
	DAT1=C B	write back
	D1=D1+ 2	skip to next char
	A=A-1  A
	GONC   conv
 nullst ?ST=0  sMAP$	MAP statement?
	GOYES  nxtrec	yes, next record
 
************************************************
 
* MAP$ done: restore pointers & return to EXPR
	C=RSTK		recover D1 (mathstack pt)
	D1=C
	C=R0		and D0 (program counter)
	D0=C
	GOVLNG =EXPR	return
*
	END
