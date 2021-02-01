IF NOT lasm
.printx * CPXMZZ.ASM *
ENDIF	;NOT lasm
;	KERMIT - (Celtic for "FREE")
;
;	This is the CP/M-80 implementation of the Columbia University
;	KERMIT file transfer protocol.
;
;	Version 4.0
;
;	This file contains the system-dependent code and data for KERMIT
;	specific to a custom system using INS8251 UARTs with INS8253 baud
;	generator.
;
; revision history:
;
; edit 01 31st Jan 2021 by D R Miller <durgadas311@gmail.com>
;	Cloned from CPXHEA.ASM.
;	
; Keep module name, edit number, and last revision date in memory.
;sysedt:	db	'CPXMZZ.ASM (1) 31-Jan-21 $'
;
;
;
; Assembly time message to let me know I'm building the right version.
; LASM generates an 'S' error along with the message, which is messy, but
; better than trying to put everything inside a IF m80 OR mac80 conditional,
; because LASM doesn't like nested IF's, either.

.printx * Assembling KERMIT-80 for an INS8251/INS8253 system *
;

;

mnport	EQU	03ah		;Modem data port
bgport	EQU	0c8h		; For both 8251, cnt1 for modem

;	Definitions for the 8251 ACE

acerbr	EQU	0		; ACE Receiver Buffer Register offset (R/O) (DLAB = 0)
acethr	EQU	0		; ACE Transmitter Holding Register offset (W/O)
acecmd	EQU	1		; ACE command/mode register
acests	EQU	1		; ACE status register

brgct0	EQU	0
brgct1	EQU	1
brgct2	EQU	2
brgctl	EQU	3

ace8bw	EQU	01001110b	; Mode ctl: 1 stop, no party, 8 bit, 16x
aceena	EQU	00000101b	; Cmd bit: rx/tx enable
acerst	EQU	01000000b	; Cmd bit: reset the 8251
acesb	EQU	00001000b	; Cmd bit: set break
acedtr	EQU	00000010b	; Cmd bit: data terminal ready
acerts	EQU	00100000b	; Cmd bit: req to send
aceerr	EQU	00010000b	; Cmd bit: error reset

acedr	EQU	00000010b	; Sts bit: rx data ready
acethe	EQU	00000001b	; Sts bit: tx ready for data

defesc	EQU	'\'-100O	;The default is Control \ -- it's easier B.E.

;
;	Family is the string used in VERSION to say which of several 
;	smaller overlay files are used. These are (will be) derived from 
;	the juge CPXSYS.ASM file, in which case we will never get here.
;	Just a Dollar, but put a sting in for a family of machines.
;
family:	db	'CPXMZZ.ASM (1)  31-Jan-2021$'		; Used for family versions....

;
sysxin:		; continuation of initialisation code
;
;	System dependent startup
;
	; TODO: need algorithm to reset the 8251 and set mode byte
	; Assume one of two states: RESET (mode) or initialized.

	lda	acectl
	ori	aceerr		; do error reset
	out	mnport+acecmd

; right now, no speed support
IF 0
	call    mdmofl		; keep the line safe from garbage

;	First, tell Kermit the modem port's current speed
	in      mnport+acelcr
	ori     acedla
	out     mnport+acelcr	; access the ACE's divisor latch
	in      mnport+acedll	; get the low byte
	sta     speed
	in      mnport+acedlh	; and the high byte
	sta     speed+1

;	Now set up the port for Kermit
	mvi     a,ace8bw	; 8 data bits, 1 stop bit, no parity
	out     mnport+acelcr
	in      mnport+acemcr
	ori     acedtr		; raise DTR (just in case)
	out     mnport+acemcr
	call    mdmonl		; and put the ACE back on line
ENDIF
	ret

acectl:	db	aceena+acedtr+acerts	; should be how it's initialized

;	Take the ACE off line before modifying its state
mdmofl:
	lda	acectl
	ani	not aceena	; disable Tx/Rx
	sta	acectl
	out	mnport+acecmd
	ret

;	Put the ACE back on line
mdmonl:
	lda	acectl
	ori	aceena		; enable Tx/Rx
	sta	acectl
	out	mnport+acecmd	; needs error reset also?
	in	mnport+acerbr	; flush left-over garbage in the receive buffer
	mvi	a,7		; wait about 2 300-baud character times
	call	delay
	in	mnport+acerbr	; and flush more garbage
	ret

;
;
;	system-dependent termination processing
;	If we've changed anything, this is our last chance to put it back.
sysexit:
	ret

;
;	system-dependent processing for start of CONNECT command
;
syscon:
	ret

conmsg:		; Messages printed when entering transparent (CONNECT) mode:
;
;
;	syscls - system-dependent close routine
;	called when exiting transparent session.
;
syscls:
	ret
;
;
;	sysinh - help for system-dependent special functions.
;	called in response to <escape>?, after listing all the
;	system-independent escape sequences.
;
sysinh:
	lxi	d,inhlps	; we got options...
	call	prtstr		; print them.
	ret


;additional, system-dependent help for transparent mode
; (two-character escape sequences)
inhlps:
	db	cr,lf,'B  Transmit a BREAK'
	db	cr,lf,'D  Drop the line'
	db	'$'		;[hh] table terminator

;
;	sysint - system dependent special functions
;	called when transparent escape character has been typed;
;	the second character of the sequence is in A (and in B).
;	returns:
;	non-skip: sequence has been processed
;	skip:   sequence was not recognized
sysint:	ani	137O		; convert lower case to upper, for testing...

	cpi	'D'		; drop line?
	jnz	intc00		; no:  try next function character

; NOTE: DTR not connected
mdmdrp:		; (we also get here from sysbye) drop DTR
	lda	acectl
	ani	not acedtr	; drop DTR
	out	mnport+acecmd	; yes: drop DTR
	mvi	a,50		;	for half a second
	call	delay
	lda	acectl
	out	mnport+acecmd	;	and then restore it
	ret
intc00:
	cpi	'B'		; send break?
	jz	sendbr		; yes, go do it.  return nonskip when through.
	jmp	rskp		; take skip return - command not recognized.

;
;
;	Send BREAK on INS8251
;
sendbr:
	lda	acectl
	ori	acesb		; send BREAK command
	out	mnport+acecmd	; set ACE break condition
	mvi	a,30
	call	delay		; wait 300 milliseconds
	lda	acectl		; no BREAK set
	out	mnport+acecmd	; and clear ACE break condition
	ret

;
;
;	sysflt - system-dependent filter
;	called with character in E.
;	if this character should not be printed, return with A = zero.
;	preserves bc, de, hl.
;	note: <xon>,<xoff>,<del>, and <nul> are always discarded.
sysflt:
	mov	a,e		; get character for testing
	ret

;	mdmflt - modem filter [30]
;	called with character to be sent to printer in E
;	with parity set as appropriate.
;	return with accumulator = 0 do do nothing,
;	<> 0 to send char in E.
mdmflt:
	mov	a,e		;[30] get character to test
	ret



;	prtflt - printer filter [30]
;	called with character to be sent to printer in E
;	returns with a = 0 to do nothing
;	a <> 0 to print it.
;
;	this routine for those printer that automatically insert
;	a lf on cr, or cr for lf.  Should this be shifted to 
;	the system indep. stuff, in say 4.06?
prtflt:
	mov	a,e		; [30] get character to test
	ret


;
;
; system-dependent processing for BYE command.
;  for apmmdm, heath, scntpr, and lobo, hang up the phone.
sysbye:
	call	mdmdrp		;  Sleazy but effective
	ret
;
;	This is the system-dependent command to change the baud rate.
;	DE contains the two-byte value from the baud rate table; this
;	value is also stored in 'speed'.
sysspd:
	call	mdmofl		; keep the line safe from garbage
	mvi	a,01110110b	; counter 1, LSB+MSB, mode 3, binary
	out	bgport+brgctl
	mov	a,e		; LSB
	out	bgport+brgct1
	mov	a,d		; MSB
	out	bgport+brgct1
	call	mdmonl		; online, does delay and flush
	ret

;
;
;	Speed tables
; (Note that speed tables MUST be in alphabetical order for later
; lookup procedures, and must begin with a value showing the total
; number of entries.  The speed help tables are just for us poor
; humans.
;
;	db	string length,string,divisor (2 identical bytes or 1 word)
; [Toad Hall]

;
;	Speed selection table for 614.4KHz INS8253
;

spdtbl: db	7	; num entries
	db	4,'1200$'
	dw	512
	db	5,'19200$'
	dw	32
	db	4,'2400$'
	dw	256
	db	5,'38400$'
	dw	16
	db	4,'4800$'
	dw	128
	db	3,'600$'
	dw	1024
	db	4,'9600$'
	dw	64

sphtbl: db	cr,lf
	db	'   600  1200  2400  4800  9600 19200 38400$'
;
;
;	This is the system-dependent SET PORT command.
;	HL contains the argument from the command table.
sysprt:
	ret
;
prttbl	equ	0		; SET PORT is not supported
prhtbl	equ	0
;
;
;
;	selmdm - select modem port
;	selcon - select console port
;	selmdm is called before using inpmdm or outmdm;
;	selcon is called before using inpcon or outcon.
;	For iobyt systems, diddle the I/O byte to select console or comm port;
;	For Decision I, switches Multi I/O board to console or modem serial
;	port.  [Toad Hall]
;	For the rest, does nothing.
;	preserves bc, de, hl.
selmdm:
	ret

selcon:
	ret

;	Get character from console, or return zero.
;	result is returned in A.  destroys bc, de, hl.
;
inpcon:
	mvi	c,dconio	;Direct console I/O BDOS call.
	mvi	e,0FFH		;Input.
	call	BDOS
	ret
;
;
;	Output character in E to the console.
;	destroys bc, de, hl
;
outcon:
	mvi	c,dconio	;Console output bdos call.
	call	bdos		;Output the char to the console.
	ret
;
;
;	outmdm - output a char from E to the modem.
;	the parity bit has been set as necessary.
;	returns nonskip; bc, de, hl preserved.
outmdm:
	in	mnport+acests	;Get the output done flag.
	ani	acethe		;Is it set?
	jz	outmdm		;If not, loop until it is.
	mov	a,e
	out	mnport+acethr	;Output it.
	ret

;
;
;	get character from modem; return zero if none available.
;	for IOBYT systems, the modem port has already been selected.
;	destroys bc, de, hl.
inpmdm:
	in	mnport+acests	; input status port
	ani	acedr		; anything t read in?
	rz			; nope
	in	mnport+acerbr	; else read in the data
	ret			; return with character in A

;
;	flsmdm - flush comm line.
;	Modem is selected.
;	Currently, just gets characters until none are available.

flsmdm: call	inpmdm		; Try to get a character
	ora	a		; Got one?
	jnz	flsmdm		; If so, try for another
	ret			; Receiver is drained.  Return.
;
;
;	lptstat - get the printer status. Return a=0ffh if ok, or 0 if not.
lptstat:
	call	bprtst		; assume it is ok.. this may not be necessary
	ret

;
;	outlpt - output character in E to printer
;	console is selected.
;	preserves de.
outlpt:
	push	d		; save DE in either case
	call	prtflt		; go through printer filter [30]
	ana	a		; if A = 0 do nothing,
	jz	outlp1		; [30] if a=0 do nothing
	mvi	c,lstout
	call	bdos		;Char to printer
outlp1: pop	d		; restore saved register pair
	ret

; Not sure why these need to be here, vs. CPXVDU or ...

; erase the character at the current cursor position
clrspc: mvi	e,' '
	call	outcon
	mvi	e,bs		;get a backspace
	jmp	outcon

clrlin:	ret
clrtop:	ret
delchr:
	mvi	e,bs		;get a backspace
	jmp	outcon

sysver: db	'Mike_Z$'

; This is not the end... CPXVDU follows...
