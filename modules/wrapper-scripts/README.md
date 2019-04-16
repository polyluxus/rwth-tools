# Wrapper scripts

These scripts wrap around an executable to set environment variables.

This is helpful, because it avoids loading everithing into the shell 
manually, or have it in the shell by default.
It also makes switching between versions more convenient.

These scripts are intended to be used on the RWTH RZ cluster,
as the module names are hardcoded.
If anything changes there, they would have to be edited, too.
If `HOSTNAME` does not match the pattern `/[Rr][Ww][Tt][Hh]/`,
they will not do anything.

## Installation

Link or copy the scripts to a directory found in PATH;
if you use the setup provided with this repository, 
`~/bin` is a reasonable choice.

## Example

Assume you have calculated a molecule with Gaussian 09, 
obtaining the checkpoint file `testcalc.g09d.chk`. 
You can use the wrapper command
```
wrapper.g09d.bash formchk testcalc.g09d.chk testcalc.g09d.fchk
```
to produce a formatted checkpoint file.
You can convert it to a Gaussian 16 checkpoint file to read in orbitals (etc.)
with the wrapper command
```
wrapper.g16b.bash unfchk testcalc.g09d.fchk testcalc.conv.chk
```
which can now be accessed wit the link0 directive `%OldChk=testcalc.conv.chk`.

___version___: 2019-04-16-1544
