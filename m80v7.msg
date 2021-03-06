Bruce Tanner of Cerritos College has contributed a new release of MAC80, his
8080 cross assember for the DECsystem-10 and DECSYSTEM-20, to the KERMIT
distribution.  For those of you who may have an earlier copy, here are the
differences:

Changes between MAC80 6A and 7:

	<filename>.SYM is created whenever a list file is requested.
	This can be used by SID and ZSID.

	MACLIB <filename> will read in <filename>.LIB (in your default path)
	as a library of macros and symbol definitions.

	PAGE will force a page eject.
	PAGE n will set the default page size to n.

	NUL FOO will return TRUE if FOO is a null argument to a macro.
	NUL actually checks for an undefined symbol generated for the macro,
	so passing an undefined symbol as an argument to a macro will be
	tested as a null argument.

	REPT <expr> ... ENDM  repeats the code inside the macro <expr> times.
	Local symbols may be used in REPT.

	EXITM may be used to abort a macro or REPT.

	One layer of fuzzy thinking removed from upper/lower case handling.

	One known bug: OPT SMAC and nested macros generate junk in the
	listing. The generated code is OK.


Changes between MAC80 6 and 6A:

	Relational operators in expressions (=,<>,<,<=,>,>=,eq,ne,lt,le,gt,ge),
	returns FF if true 0 if false.

	@ and ? are allowed in symbols.

	$ are considered non-significant in symbols.

	local symbols are now ??n instead of L$$n.

Changes between MAC80 5B and 6:

	Symbols may now be up to 12 characters long

	Symbols (including numbers) may include dollar signs

	The listing file output reflects the actual case of the input file

	The value generated by dollar signs (assembler PC) in EQU statements
	are now correct

	Binary numbers are now legal

	Macros may now be nested

	Local symbols in macros

You can get the new MAC80 via anonymous FTP from COLUMBIA-20 (ARPAnet) or
anonymous NFT from CUCS20 (CCnet), specifying files KER:M*8*.* and
KER:TORTUR.* (the latter being a "torture test" that illustrates all the
features of the assembler.

Bruce's utility HEXIFY, which converts a CP/M .COM file to a .HEX file on the
DEC-10 or -20, remains available as before.  In addition, he has contributed a
complementary program, HEXCOM, to convert a .HEX file to a .COM file.  These
programs can be obtained by specifying KER:HEX*.* to FTP or NFT.

- Frank
   