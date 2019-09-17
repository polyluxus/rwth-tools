# Natural Bond Orbitals (version 6.0)

The Natural Bond Orbital (NBO) program NBO 6.0 is an analysis tool for wavefunctions. 
NBO 6.0 is the previous version, NBO 7.0 was released in November 2018,
and it contains a broad set of algorithms to analyse the wavefunction, 
and express it in chemically intuitive language of Lewis-like bonding patterns 
and associated resonance-type 'donor-acceptor' interactions.

For more information vist the [NBO Homepage](http://nbo6.chem.wisc.edu/).

## Installation of the modules

Follow the instructions of the distribution you have obtained to install the program itself.

Depending on what you have bought, you will have the executables `nbo6.i8.exe` or `nbo6.i4.exe`,
and `gennbo6.i8.exe` or `gennbo6.i4.exe` (or both versions).
Additionally you will have the generic `tcsh` shell script, which needs a `*.47` file
and produces the `*.nbo` files.

If you are using the program in conjunction with Gaussian, 
you also need the `tcsh` shell script `gaunbo6`.

Unfortunately NBO does not use subversioning for its software,
so in order to know vhich revision you have, you will have to check the `REVISIONS`,
which is hopefully included in your distribution.

The module files in this directory assume that the software is installed in the following path,
where `<USER>` should be substituted by your username, 
and `<version>` refers to a version you set yourself, 
I have chosen `2018` as this was the last etry in the above mentioned file:
```
/home/<USER>/local/nbo6/nbo6-<version>
```
You could also use `<version>` to distinguish between `i4`/`i8` builds, 
or fine tuned towards a specific Gaussian version, i.e. `g09` or `g16`,
or if you are building it for a completely different ESS.

The earlier mentioned executable files should all be located then in:
```
/home/<USER>/local/nbo6/nbo6-<version>/bin
```

The installation manual mentiones to edit the `tcsh` scripts with the corresponding paths.
I have tested setting the `NBOBIN` in the `gennbo` script with a more dynamic approach:
```
setenv NBOBIN `readlink -f $0`
setenv NBOBIN `dirname $NBOBIN`
```
This is to replace the hardcoded paths to the binaries.

Similarily, I have used this approach for the `gaunbo6` script 
(Note the difference in the variable names):
```
setenv BINDIR `readlink -f $0`
setenv BINDIR `dirname $BINDIR`
```

With this you should be set up alright.
In order to access the program, the directory has to be found in `PATH`.
This is where the modules files come in handy.

Assuming your local module files are installed in the following directories
```
/home/<USER>/local/modules/modulefiles/LOCAL
/home/<USER>/local/modules/modulefiles/source
```
and further assuming `rwth-tools` is installed in the directory
```
/home/<USER>/local/rwth-tools
```
you can copy the module files directly from *here* to *there*:
```
cp -vr -- "$HOME/local/rwth-tools/modules/modulefiles/LOCAL/nbo6" "$HOME/local/modules/modulefiles/LOCAL"
cp -vr -- "$HOME/local/rwth-tools/modules/modulefiles/source/nbo6" "$HOME/local/modules/modulefiles/source"
```

You may have to edit the versioning files depending on what you have set up earlier;
if you do, don't forget the hidden `[...]/modulefiles/source/nbo6/.version`.

Check with `module avail` if the new module file is recognised.
You should now be able to load it with `module load nbo6`.

___version___: 2019-09-17-1200

