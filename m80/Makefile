# Kermit-80 building...
export CPMDrive_D = $(PWD)
export CPMDefault = d:

# TODO: extract overlay ORG address from code...
OVL_ADR = 7000

COM_SRC = cpsdef.asm cpxlnk.asm

GEN_SRC = cpvgen.asm \
	cpxcom.asm \
	cpxswt.asm \
	cpxsys.asm \
	cpxsy2.asm \
	cpxvdu.asm

KPR_SRC = cpvkpr.asm \
	cpxbbi.asm \
	cpxcom.asm \
	cpxswt.asm

H89_SRC = cpvh89.asm \
	cpxhea.asm \
	cpxcom.asm \
	cpxswt.asm

all:

%.asm: ../%.asm
	unix2dos -n $< $@

# TODO: test this...
cpsker.com: cpsker.asm # ...others...
	vcpm m80 cpsker=cpsker.asm
	vcpm l80 /p:100,cpsker,cpsker/n/e

# Generic CP/M kermit-80
cpvgen.asm: cpxtyp.asm
	sed	-e 's/^m80	EQU	FALSE/m80	EQU	TRUE/' \
		-e 's/^lasm	EQU	TRUE/lasm	EQU	FALSE/' \
		-e 's/^gener	EQU	FALSE/gener	EQU	TRUE/' \
		-e 's/^crt	EQU	FALSE/crt	EQU	TRUE/' \
		$? >$@

cpvgen.hex: $(GEN_SRC) $(COM_SRC)
	vcpm m80 cpvgen=cpvgen.asm/l
	vcpm l80 /p:$(OVL_ADR),cpvgen,cpvgen/n/x/e

# Kaypro II (2X...) kermit-80
cpvkpr.asm: cpxtyp.asm
	sed	-e 's/^m80	EQU	FALSE/m80	EQU	TRUE/' \
		-e 's/^lasm	EQU	TRUE/lasm	EQU	FALSE/' \
		-e 's/^kpII	EQU	FALSE/kpII	EQU	TRUE/' \
		$? >$@

cpvkpr.hex: $(KPR_SRC) $(COM_SRC)
	vcpm m80 cpvkpr=cpvkpr.asm/l
	vcpm l80 /p:$(OVL_ADR),cpvkpr,cpvkpr/n/x/e

# Heath/Zenith 89 (and H8) kermit-80
cpvh89.asm: cpxtyp.asm
	sed	-e 's/^m80	EQU	FALSE/m80	EQU	TRUE/' \
		-e 's/^lasm	EQU	TRUE/lasm	EQU	FALSE/' \
		-e 's/^heath	EQU	FALSE/heath	EQU	TRUE/' \
		$? >$@

cpvh89.hex: $(H89_SRC) $(COM_SRC)
	vcpm m80 cpvh89=cpvh89.asm/l
	vcpm l80 /p:$(OVL_ADR),cpvh89,cpvh89/n/x/e
