# kermit-80
## An off-shoot of kermit-80 from Columbia University

### Building

The subdirectory 'm80' contains a Makefile for
build using M80/L80 and a CP/M emulator "vcpm".
See https://github.com/durgadas311/cpnet-z80
for more information on obtaining and setting up
"vcpm".

Currently, the only build targets are:

* cpvgen.hex	Generic CP/M (iobyte)
* cpvkpr.hex	Kaypro
* cpvh89.hex	Heath/Zenith 89

The plan is to add more, including the system-independent
kermit module.

This build environment aims to avoid the need to
manually edit cpxtyp.asm for each build performed.
The consequences of that are 'sed' scripts to
modify the variables in cpxtyp.asm for each target.

This "vcpm" setup requires that M80.COM and L80.COM
be present on the A: drive (directory). Those should be
easily obtained from various sources on the internet.

To build targets, "cd" to the 'm80' subdirectory and
run "make *target*". Because the building is done using
CP/M commands, errors cannot be detected automatically.
You will need to examine the output to ensure all went well.

Bugfixes are also being applied as they are found.
