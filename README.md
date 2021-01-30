# kermit-80
## An off-shoot of kermit-80 from Columbia University

### Building

The subdirectory 'm80' contains a Makefile for
build using M80/L80 and a CP/M emulator "vcpm".
See https://github.com/durgadas311/cpnet-z80
for more information on obtaining and setting up
"vcpm".

Currently, the only build target is "cpvgen.hex".
The plan is to add more, including the system-independent
kermit module.

This build environment aims to avoid the need to
manually edit cpxtyp.asm for each build performed.
The consequences of that are 'sed' scripts to
modify the variables in cpxtyp.asm for the target.

Bugfixes are also being applied as they are found.
