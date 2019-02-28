[Switch to German.](mol_struc_de.md)

---

## Preliminaries

I personally use the approach to have one directory per set of optimisation (calculation).
That usually translates to one directory per molecule and method, 
and within that, all related calculations.

For example, if I wanted to describe the reaction of transferring one proton
from a hydronium to an ammonia moelcule, 

H<sub>3</sub>O<sup>+</sup> + NH<sub>3</sub> &lrarr; H<sub>2</sub>O + NH<sub>4</sub><sup>+</sup>, 

then a directory tree would probably look something like that:

```
.
├── README
├── ammonia
│   ├── g16-b3lyp
│   │   ├── b3lypsvp.opt.com
│   │   ├── < ... >
│   │   └── b3lypsvp.start.xyz
│   ├── g16-bp86
│   │   ├── bp86svp.opt.com
│   │   ├── < ... >
│   │   └── bp86svp.start.xyz
│   └── g16-pbe0
│       ├── pbe0svp.opt.com
│       ├── < ... >
│       └── pbe0svp.start.xyz
├── ammonium
│   ├── g16-b3lyp
│   │   ├── b3lypsvp.opt.com
│   │   ├── < ... >
│   │   └── b3lypsvp.start.xyz
│   ├── g16-bp86
│   │   ├── bp86svp.opt.com
│   │   ├── < ... >
│   │   └── bp86svp.start.xyz
│   └── g16-pbe0
│       ├── pbe0svp.opt.com
│       ├── < ... >
│       └── pbe0svp.start.xyz
├── hydronium
│   ├── g16-b3lyp
│   │   ├── b3lypsvp.opt.com
│   │   ├── < ... >
│   │   └── b3lypsvp.start.xyz
│   ├── g16-bp86
│   │   ├── bp86svp.opt.com
│   │   ├── < ... >
│   │   └── bp86svp.start.xyz
│   └── g16-pbe0
│       ├── pbe0svp.opt.com
│       ├── < ... >
│       └── pbe0svp.start.xyz
└── water
    ├── g16-b3lyp
    │   ├── b3lypsvp.opt.com
    │   ├── < ... >
    │   └── b3lypsvp.start.xyz
    ├── g16-bp86
    │   ├── bp86svp.opt.com
    │   ├── < ... >
    │   └── bp86svp.start.xyz
    └── g16-pbe0
        ├── pbe0svp.opt.com
        ├── < ... >
        └── pbe0svp.start.xyz
```

A structure like that will ensure that files that belong together are grouped,
which minimises search times, and gives you a better context.

If you are trying to develop a reaction mechanism (or cycle) it is advisable
to propose a preliminary path, with preliminary numbering to which you can 
relate during the development phase. 

For something line in 
"[Why does cyclopropane react with bromine?](https://chemistry.stackexchange.com/q/10653/4945)",
I'd would choose something like the following:

```
.
├── README
├── prelim_0010_react_cycprop
│   └── g16-opt-bp86
├── prelim_0020_react_dibrom
│   └── g16-opt-bp86
├── prelim_0030_ts_adduct
│   └── g16-opt-bp86
├── prelim_0040_ts_bromonium
│   └── g16-opt-bp86
├── prelim_0050_prod_chain
│   └── g16-opt-bp86
├── prelim_0060_etc___
│   └── g16-opt-bp86
└── prelim_0070
    └── g16-opt-bp86
```

Always add a file (like `README`) explaining what you did.

Later you can use the preliminary numbers to find your calculations, 
even if you were to rename everything (using soft links `ln -s`), like

```
.
├── README
├── fin_01_cycloprop -> prelim_0010_react_cycprop/
├── fin_02_br2 -> prelim_0020_react_dibrom/
├── fin_03_ts -> prelim_0040_ts_bromonium/
├── fin_04_dibrom-1-3-propane -> prelim_0050_prod_chain/
├── prelim_0010_react_cycprop
├── prelim_0020_react_dibrom
├── prelim_0030_ts_adduct
├── prelim_0040_ts_bromonium
├── prelim_0050_prod_chain
├── prelim_0060_etc___
└── prelim_0070
```

Using steps of 10 in the preliminary calculations would allow you to insert 
more calculations.

# Basic molecular structure optimisations

The molecular structure is often also referred to as *geometry*, 
and hence the optimisation of the molecular structure is often referred to as
*geometry optimisation*.

Here is a short checklist, flowchart, or list how to get from an 
initial (guessed) structure to a final structure.

1. Create a molecular structure file in cartesian coordinates (`*.xyz`) 
   with your preferred molecular editor, command line tool, or even text editor.
   If you (intend to) use Gaussview, please see some more [notes on Gaussview](notes_gv_en.md).

   It needs a bit training to click together a reasonable guess, 
   Chemcraft has a reasonably large fragments database, 
   Molden has a few standards, but is (technically) able to read in fragments, too.
   For simple molecules you can sometimes find structures online, maybe even crystal structures.
   Another easy way is to search for it on [ChemSpider](http://www.chemspider.com/), 
   [PubChem](https://pubchem.ncbi.nlm.nih.gov/search/), or 
   draw it with Chemdraw (etc.) and generate a 
   [SMILES](https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system) code.
   You can use [Open Babel](http://openbabel.org) to create a guessed structure.
   For example, the SMILES for ethanol is `CCO`, 
   see [PubChem CID 702](https://pubchem.ncbi.nlm.nih.gov/compound/ethanol#section=Canonical-SMILES),
   then the command for Open Babel is:
   
   ```
   ~/comp_chem/ $ obabel -:'CCO' -oxyz --gen3d -Oopt.start.xyz
   ```
   The option `-:` takes a SMILES as an input, 
   the `-o` selects the output format (here chosen as Xmol, Cartesian coordinates),
   `--gen3d` tells the program to generate 3D coordinates (duh!),
   and `-O` selects the output file to write on; 
   see also the [Open Babel Wiki](http://openbabel.org/wiki/Main_Page).

   That sometimes even works for more complex molecules; 
   unfortunately not for organometallics (and similar), 
   because it doesn't describe ionic interactions (see [footnotes *1*](#footnotes)).

   Assume we did this, and we will call it `bp86svp.start.xyz`.

2. Create an input file. That can be done by hand, using a text editor and the handbook 
   at [Gaussian](http://gaussian.com/) or with one of the tools.
   A *very simple* optimisation would probably use BP86/def2-SVP with mostly default parameters, 
   or similar (see [footnotes *2*](#footnotes)), so you can just run the prepare script:
   ```
   ~/comp_chem/ $ g16.prepare -R'#P BP86/def2SVP/W06' -r'OPT(MaxCycles=100)' -j'bp86svp.opt' bp86svp.start.xyz
   ```
   This will create the file `bp86svp.opt.com`.

   You can find a [pdf file](https://github.com/polyluxus/tools-for-g16.bash/blob/master/docs/)
   with the options for all of these scripts in the 
   [tools-for-g16](https://github.com/polyluxus/tools-for-g16.bash) repository.

3. Submit the input file to the queue.
   You can again write your own submission script or simply let mine handle it:
   ```
   ~/comp_chem/ $ g16.submit -p12 -m4000  bp86svp.opt.com
   ```
   This will create a modified inputfile `bp86svp.opt.gjf`, with the correct settings for Gaussian
   according to what you requested in the submit routine.
   It will also create (assuming it is set to `bsub-rwth`) a script for the queueing system,
   `bp86svp.opt.bsub.bash`, which will be executed remotely.

   What sensible parameter (processors, memory, walltime) are comes a bit with experience.
   Obviously don't ask for more than you have 
   (p12, m4000 is reasonable for medium sized molecule optimisations).

4. Once the calculation is done (you'll probably get an email), you will have a few output files.
   - `bp86svp.opt.log`: the main output
   - `bp86svp.opt.chk`: the checkpoint file (useful for later)
   - `bp86svp.opt.bsub.bash.e<number>`: the error file from the queueing system
   - `bp86svp.opt.bsub.bash.o<number>`: the standard output file from the queueing system

   Check the main output file for errors. Everything should be fine when you find *Normal termination* at the end.
   ```
   ~/comp_chem/ $ tail bp86svp.opt.log
   ```
   You can (and should) also check for *stationary point found*:
   ```
   ~/comp_chem/ $ grep 'Stationary point found' -B7 -A3  bp86svp.opt.log

   ```
   Don't forget to open it with a molecular viewer to make sure the structure is actually sensible.

5. Create a frequency calculation **in the same** directory.
   ```
   ~/comp_chem/ $ g16.freqinput bp86svp.opt.gjf
   ```
   This creates `bp86svp.opt.freq.com` which you can submit:
   ```
   ~/comp_chem/ $ g16.submit -p12 -m24000  bp86svp.opt.freq.com
   ```
   Frequency calculations are memory demanding, they will slow down if they do not have enough,
   about 2 GB per core should be okay.

6. You'll get similar outputfiles like above. 
   Open the `*.log` file with a molecular viewer, and look at the frequencies (or modes).
   If there are no imaginary modes, you have found a *local* minimum, 
   if there is exactly one mode, you found a transition state.
   Repeat the above steps as necessary.

7. Look for the energy values and put them in tables to calculate barriers and stuff.
   You can use the post-processing script for that, or look through the manual by yourself:
   ```
   ~/comp_chem/ $ g16.getfreq -V3  bp86svp.opt.freq.log
   ```

8. Finalise the calculation with creating a formatted checkpoint file and a coordinate file.
   The Gaussian checkpoint files are binary files and they are machine dependent.
   That usually doesn't pose any problem, but it is good practice to create a pure text file anyway.
   The formatted checkpointfile can be used as an input for further analysis by many programs,
   therefore it is good to have in any case.
   Writing an `xyz` file with the optimised structure helps cutting down loading times;
   it also gives you an indicator that the calculation is done.

   You can do these two steps together with the following command:
   ```
   ~/comp_chem/ $ g16k2xyz  bp86svp.opt.freq.chk
   ```
   The above command produces the formatted checkpoint file `bp86svp.opt.freq.fchk` and
   the coordinate file `bp86svp.opt.freq.xyz`.
   Alternatively you can use the script with the `-a` switch to do that for every `*.chk`
   file in the current directory.

Once you have done all the steps you can move on to interpreting the results,
which is where often the real work lies.

## Exercise

### Protonation

Calculate the the Gibbs free energies for the above reaction,

H<sub>3</sub>O<sup>+</sup> + NH<sub>3</sub> &lrarr; H<sub>2</sub>O + NH<sub>4</sub><sup>+</sup>, 

with the functionals BP86, PBE0, TPSS, with the basis sets STO-3G, 6-31+G(d,p), def2-SVP, def2-TZVPP.

The [results](exercises/protonation.md) are available for comparison, along with some notes and tips.


---
### Footnotes

1. Some may work okay-ish, e.g. sodium ethanolate (`CC[O-].[Na+]`), others not.
   You can try building the structure for the cation of 
   [tris(ethylenediamine)cobalt(III) chloride](https://pubchem.ncbi.nlm.nih.gov/compound/407049):
   `C(C[NH-])[NH-].C(C[NH-])[NH-].C(C[NH-])[NH-].[Co].[Cl-].[Cl-].[Cl-]`.
  
2. Choosing an appropriate level of theory is not often trivial, one has to consider a couple of things,
   like accuracy, performance, and speed. 
   I have previously written quite a long article about that: 
   [DFT Functional Selection Criteria](https://chemistry.stackexchange.com/a/27418/4945).

   The example command uses the DF-BP86/def2-SVP level of theory, but with something extra. Remember:
   ```
   ~/comp_chem/ $ g16.prepare -R'#P BP86/def2SVP/W06' -r'OPT(MaxCycles=100)' -j'bp86svp.opt' bp86svp.start.xyz
   ```
   The `-R` switch to g16.prepare sets the basic route section to `#P BP86/def2SVP/W06`, the different parts mean the following:

   - The `#P` selects verbose printing ([G16 manual](http://gaussian.com/route/?tabid=1)),
   other options are `#N` (normal) and `#T` (terse).
   - The method is selected as `BP86`, which selects the exchange functional `B` and the correlation functional `P86`.
   There are plenty of [Functionals implemented](http://gaussian.com/dft/).
   - For the example I have chosen the def2-SVP basis set; please note that the keyword is without the dash.
   There are again many available in [Gaussian](http://gaussian.com/basissets/), and additional ones can be defined;
   that is something for more advanced users (and a topic for another day).
   - Additionally, this route section requests density fitting 
   (sometimes also referred to as *resolution-of-the-identity*, or short RI, approximation)
   with the auxiliar basis set `W06` (see the [Manual](http://gaussian.com/basissets/?tabid=2) for more),
   which should speed up the calculation.
   This is also available via the [`DensityFit`/`DenFit`](http://gaussian.com/densityfit/) keyword, 
   and therefore commonly abbreviated with DF in the level of theory.
   
   The `-r` switch to the script adds more keywords to the route section. 
   In this specific case we'll request an optimisation ([`OPT`](http://gaussian.com/opt/)) with 100 cycles at the most.

   The `-j` switch selects a jobname for the calculation, and it will further be used to derive filenames for it.

   The last argument is the molecular structure file, here in the Xmol format. 
   There are some other formats recognised, but that is also something for another day.


___version___: 2019-02-28-1243
