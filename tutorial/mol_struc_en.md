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

   It needs a bit training to click together a reasonable guess, 
   Chemcraft has a reasonably large fragments database, 
   Molden has a few standards, but is (technically) able to read in fragments, too.
   For simple molecules you can sometimes find structures online, maybe even crystal structures.
   Another easy way is to search for it on [ChemSpider](http://www.chemspider.com/), 
   [PubChem](https://pubchem.ncbi.nlm.nih.gov/search/), or 
   draw it with Chemdraw (etc.) and generate a 
   [SMILES](https://en.wikipedia.org/wiki/Simplified_molecular-input_line-entry_system) code.
   You can use [Open Babel](http://openbabel.org) to create a guessed structure.
   For example for ethanol:
   
   ```
   ~/comp_chem/ $ obabel -:'CCO' -oxyz --gen3d -Oopt.start.xyz
   ```
   That sometimes even works for more complex molecules; 
   unfortunately not for organometallics (and similar), 
   because it doesn't describe ionic interactions (see [footnotes](#footnotes)).

   Assume we did this, and we will call it `bp86svp.start.xyz`.

2. Create an input file. That can be done by hand, using a text editor and the handbook 
   at [Gaussian](http://gaussian.com/) or with one of the tools.
   A very simple optimisation would probably use BP86/def2-SVP, or similar, 
   so you can just run the prepare script:
   ```
   ~/comp_chem/ $ g16.prepare -R'#P BP86/def2-SVP/W06' -r'OPT(MaxCycle=100)' -j'bp86svp.opt' bp86svp.start.xyz
   ```
   This will create the file `bp86svp.opt.com`.

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

Calculate the the Gibs free energies for the above reaction,

H<sub>3</sub>O<sup>+</sup> + NH<sub>3</sub> &lrarr; H<sub>2</sub>O + NH<sub>4</sub><sup>+</sup>, 

with the functionals BP86, PBE0, TPSS, with the basis sets STO-3G, 6-31+G(d,p), def2-SVP, def2-TZVPP.

Table 1: Total electronic energies *E*<sub>el</sub>(X) / a.u. of the optimised species X
with Gaussian 16 Rev. B.01 and default convergence criteria.

| Method            | H<sub>2</sub>O | H<sub>3</sub>O<sup>+</sup> | NH<sub>3</sub> | NH<sub>4</sub><sup>+</sup> |
| ----------------- | -------------- | -------------------------- | -------------- | -------------------------- |
| BP86/STO-3G       | -75.3242201397 |             -75.6882536544 | -55.7927087482 |             -56.2060362911 |
| BP86/6-31+g(d,p)  | -76.4339483487 |             -76.7080449545 | -56.5650751658 |             -56.9042384383 |
| BP86/def2-SVP     | -76.3592176929 |             -76.6448024687 | -56.5089170326 |             -56.8551260469 |
| BP86/def2-TZVPP   | -76.4666406313 |             -76.7420357920 | -56.5868570660 |             -56.9251577651 |
|                   |                |                            |                |                            |
| PBE0/STO-3G       | -75.2542779470 |             -75.6187676146 | -55.7318377218 |             -56.1468497146 |
| PBE0/6-31+g(d,p)  | -76.3491179704 |             -76.6256495403 | -56.4951204862 |             -56.8368333289 |
| PBE0/def2-SVP     | -76.2763273959 |             -76.5623317543 | -56.4407385104 |             -56.7886295206 |
| PBE0/def2-TZVPP   | -76.3808105823 |             -76.6585542787 | -56.5157421862 |             -56.8567830696 |
|                   |                |                            |                |                            |
| TPSS/STO-3G       | -75.3401313853 |             -75.7019737431 | -55.8076946072 |             -56.2181456687 |
| TPSS/6-31+g(d,p)  | -76.4343339532 |             -76.7107889691 | -56.5675183608 |             -56.9101136017 |
| TPSS/def2-SVP     | -76.3605685213 |             -76.6478600722 | -56.5126844104 |             -56.8616627803 |
| TPSS/def2-TZVPP   | -76.4669889202 |             -76.7448758484 | -56.5888887155 |             -56.9307985669 |
|                   |                |                            |                |                            |


Table 2: Reaction energies for 
H<sub>3</sub>O<sup>+</sup> + NH<sub>3</sub> &lrarr; H<sub>2</sub>O + NH<sub>4</sub><sup>+</sup>,
at *T* = 298.15 K and *p* = 1 atm, calculated with Gaussian 16 Rev. B.01 and default settings.

| Method            | Δ *E*<sub>el</sub> | Δ *E*<sub>o</sub> | Δ *H*       | Δ *G*       |
| ----------------- | ------------------ | ----------------- | ----------- | ----------- |
| BP86/STO-3G       |             -129.4 |            -126.9 |      -127.0 |      -126.4 |
| BP86/6-31+g(d,p)  |             -170.8 |            -165.3 |      -165.5 |      -162.9 |
| BP86/def2-SVP     |             -159.2 |            -153.8 |      -154.0 |      -153.1 |
| BP86/def2-TZVPP   |             -165.2 |            -159.7 |      -159.9 |      -159.0 |
|                   |                    |                   |             |             |
| PBE0/STO-3G       |             -132.6 |            -130.4 |      -130.5 |      -128.2 |
| PBE0/6-31+g(d,p)  |             -171.1 |            -165.4 |      -165.7 |      -163.0 |
| PBE0/def2-SVP     |             -162.5 |            -157.0 |      -157.3 |      -156.3 |
| PBE0/def2-TZVPP   |             -166.2 |            -160.6 |      -160.8 |      -159.9 |
|                   |                    |                   |             |             |
| TPSS/STO-3G       |             -127.6 |            -125.7 |      -125.7 |      -125.2 |
| TPSS/6-31+g(d,p)  |             -173.7 |            -167.8 |      -168.1 |      -167.2 |
| TPSS/def2-SVP     |             -162.0 |            -156.4 |      -156.6 |      -155.7 |
| TPSS/def2-TZVPP   |             -168.1 |            -162.5 |      -162.7 |      -161.8 |
|                   |                    |                   |             |             |

---
### Footnotes

1. Some may work okay-ish, e.g. sodium ethanolate (`CC[O-].[Na+]`), others not.
   You can try building the structure for the cation of 
   [tris(ethylenediamine)cobalt(III) chloride](https://pubchem.ncbi.nlm.nih.gov/compound/407049):
   `C(C[NH-])[NH-].C(C[NH-])[NH-].C(C[NH-])[NH-].[Co].[Cl-].[Cl-].[Cl-]`.
  



___version___: 2019-02-11-1932
