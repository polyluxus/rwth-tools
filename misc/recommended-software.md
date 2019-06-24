# Recommended software and resources

This is a list of software and other resources that I recommend for usage 
when doing quantum chemistry.
It is quite unsorted, so please look them up yourself 
in order to decide whether or not to use them.

## Software

- [**JabRef**](http://www.jabref.org/)
is a citation manager that interfaces well to [`biblatex`](https://ctan.org/pkg/biblatex).
There is a script that allows you to run it from the linux command line in this directory.
- [**Notepad++**](https://notepad-plus-plus.org/)
is a multipurpose textfile editor which I recommend when editing files on a Windows platform.
- [**Vim**](https://www.vim.org/)
is one of the most common editors in linux.
It is highly configurable and supports a lot of file formats.
It is preinstalled alongside many distributions, but you can also build it from source,
which is available on [GitHub](https://github.com/vim/vim).
I have included a startup script for Vim, which ensures that you are using the 'huge' version.
More about that on the [respective readme page](../dotfiles/bash_profile.d/README.md) of this repository.
- [**MobaXterm**](https://mobaxterm.mobatek.net/)
is a terminal emulator for Windows, which has an X11 server, tabbed SSH-CLI, SCP-browser, 
and more network tools. 
It is in my opinion the most capable interface (on Windows platforms) to compute clusters.
- [**ChemCraft**](https://www.chemcraftprog.com/index.html)
is a graphical user interface to many quantum chemistry packages.
It is my choice of molecular editor. Unfortunately it is not free.
However, you can download and test it for 150 days without limitations.
(And it only took me half a year to buy it at the RWTH Aachen University.)
- [**Molden**](http://cheminf.cmbi.ru.nl/molden/)
is a pre- and postprocessing program of molecular and electronic structure.
It interfaces to a lot of quantum chemical programs, or quantum chemical programs interface to it.
This is one of the most common programs and it is free for academic use.
It is lightweight and a very quick interface on any kind of remote host.
- [**VMD - Visual Molecular Dynamics**](https://www.ks.uiuc.edu/Research/vmd/)
is another molecular visualisation program, but it has a bit of a learning curve.
It makes excellent graphics and is available on the RWTH cluster.
It is also free for academic use.
- [**Avogadro**](https://avogadro.cc/)
is also a molecular editor. It is free, open source, and cross-platform.
It is probably a neat alternative to the above recommendations.
I have little experience with it.
- For completeness: [**GaussView 6**](http://gaussian.com/gaussview6/)
is the graphical interface to Gaussian 16. 
GaussView 5 is the predecessor, which interfaces predominantly to Gaussian 09.
They are compatible to a degree, but newer features will not be available, and vice versa.
I personally do not recommend using it, I found it a quite painful experience.
Please note that it is only half as capable of anything if Gaussian is not installed.
- [**Multiwfn**](http://sobereva.com/multiwfn/)
is a multifunctional wavefunction analyser. 
It is a versatile tool to post-process quantum chemical calculations.
- [**xtb**](https://www.chemie.uni-bonn.de/pctc/mulliken-center/software/xtb/xtb)
is an extended tight-binding semi-empirical program package.
I like using it for conformational searches, pre-optimisations, quick calculations, etc.
It is quite fast and very reliable.  
Bannwarth, Christoph; Ehlert, Sebastian; Grimme, Stefan (2018): 
GFN2-xTB - an Accurate and Broadly Parametrized Self-Consistent Tight-Binding Quantum Chemical Method 
with Multipole Electrostatics and Density-Dependent Dispersion Contributions. ChemRxiv. Preprint. 
DOI: [10.26434/chemrxiv.7246238.v2](https://doi.org/10.26434/chemrxiv.7246238.v2)
- [**tree**](http://mama.indstate.edu/users/ice/tree/)
is a neet command line utility that allows you the recursive listing of a directory.
It is more capable than the `ls` command and offers an nicely formatted output.
- [**Open Babel**](http://openbabel.org)
is a chemical toolbox that allows to interconvert many chemistry file formats into each other.
- [**Gaussian 16**](http://gaussian.com/)
is the workhorse for many quantum chemists around the world. 
The online manual, [list of keywords](http://gaussian.com/keywords/), is a well organised 
documentation of how to use the program. Always consult it first.

- If you need more information on specific commands you can always try to consult the man pages with `man <command>`.
These are often cluttered with technical details, and you spent a lot of time before finding what you need.
A curated list of examples is available through the program **tldr**, which you can find on [GitHub](https://github.com/tldr-pages/tldr).
I have tried the shell client `tldr`, which is also available on [GitHub](https://github.com/raylee/tldr),
and the installation is quite simple.
The interface allows you to use `tldr <command>` to show you most common usages and examples of the command you want to learn about.

## Articles & Documentation

- The article by Andrew Watson on the dev.to platform
["*101 Bash Commands and Tips for Beginners to Experts*"](https://dev.to/awwsmm/101-bash-commands-and-tips-for-beginners-to-experts-30je) 
offers a great overview of many functions of the bash shell. 
- Machtelt Garrels 
["*Bash Guide for Beginners*"](http://tldp.org/LDP/Bash-Beginners-Guide/html/Bash-Beginners-Guide.html) 
(copy on the [wayback machine](https://web.archive.org/web/20180929153032/http://tldp.org/LDP/Bash-Beginners-Guide/html/Bash-Beginners-Guide.html))
is also a fine resource for learning the bash.
- Joe Brockmeier's
["*Vim 101: A Beginner's Guide to Vim*"](https://www.linux.com/learn/vim-101-beginners-guide-vim)
offers a nice overview into my (and soon to be your) favourite editor.
- I have written an overview for some of the density functionals that you may encounter:
["*DFT Functional Selection Criteria*"](https://chemistry.stackexchange.com/q/27302/4945)
- On the same Platform (Chemistry Stack Exchange) there is an overview for books 
["*Resources for learning Chemistry*"](https://chemistry.stackexchange.com/a/37304/4945)
My personal recommendation for an easy start is:
Jensen, F. Introduction to Computational Chemistry, 3rd ed.; Wiley:
Chichester, U.K., 2017.
- Again on the same platform there are guides on how to make neat orbital pictures:
["*Generating neat orbitals/surfaces from molden/wfn-files*"](https://chemistry.stackexchange.com/q/33932/4945)


## Shemeless self-promotion

I have written a couple of scripts that interface to some of the most common computational chemistry packages.
They have been developed mainly for the use with the RWTH RZ cluster, 
but may be used on other systems, too.

- [`tools-for.g16.bash`](https://github.com/polyluxus/tools-for-g16.bash) 
contains pre- and post-processing scripts thatb interface to Gaussian 16.
- [`runMultiwfn.bash`](https://github.com/polyluxus/runMultiwfn.bash)
is a wrapper script to Multiwfn (see above), making post-processing easier.
- [`runxtb.bash`](https://github.com/polyluxus/runxtb.bash) 
is a wrapper script to the xtb program by the Grimme group (see above).
- [`tools-for-tm.bash`](https://github.com/polyluxus/tools-for-tm.bash)
is a (growing [or maybe not]) collection of scripts that interface to Turbomole.
It currently only contains a submit script.
- [`tools-for-orca.bash`](https://github.com/polyluxus/tools-for-orca.bash)
is a (growing [or maybe not]) collection of scripts that interface to ORCA.
It currently only contains a submit script (in the `devel`branch).


___version___: 2019-06-24-1724


