# Kermit-80 building...
export CPMDrive_D = $(PWD)
export CPMDefault = d:

COM_SRC = cpsdef.asm cpxlnk.asm

GEN_SRC = cpvgen.asm \
	cpxcom.asm \
	cpxswt.asm \
	cpxsys.asm \
	cpxsy2.asm \
	cpxvdu.asm

all:

%.asm: ../%.asm
	unix2dos -n $< $@

# TODO: test this...
cpsker.com: cpsker.asm # ...others...
	vcpm m80 cpsker=cpsker.asm
	vcpm l80 /p:100,cpsker,cpsker/n/e

cpvgen.asm: cpxtyp.asm
	sed	-e 's/^m80	EQU	FALSE/m80	EQU	TRUE/' \
		-e 's/^lasm	EQU	TRUE/lasm	EQU	FALSE/' \
		-e 's/^gener	EQU	FALSE/gener	EQU	TRUE/' \
		-e 's/^crt	EQU	FALSE/crt	EQU	TRUE/' \
		$? >$@

# TODO: extract ORG address from code...
cpvgen.hex: $(GEN_SRC) $(COM_SRC)
	vcpm m80 cpvgen=cpvgen.asm/l
	vcpm l80 /p:7000,cpvgen,cpvgen/n/x/e
