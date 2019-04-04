# Exercise 'Protonation'

## Exercise

Calculate the the Gibs free energies for the above reaction,

H<sub>3</sub>O<sup>+</sup> + NH<sub>3</sub> &lrarr; H<sub>2</sub>O + NH<sub>4</sub><sup>+</sup>, 

with the functionals BP86, PBE0, TPSS, with the basis sets STO-3G, 6-31+G(d,p), def2-SVP, def2-TZVPP.

## Notes and tips

To create a nice little tree use some extglob magic (in bash with `shopt -s extglob`): 
```
mkdir {ammonia,ammonium,hydronium,water}
mkdir {ammonia,ammonium,hydronium,water}/g16-{bp86,pbe0,tpss}-{sto3g,631+gdp,def2svp,def2tzvpp}
```

Create start files:

 - ammonia:   `obabel -:'N' --gen3d -oxyz -Ostart.xyz`
 - ammonium:  `obabel -:'[NH4+]' --gen3d -oxyz -Ostart.xyz`
 - water:     `obabel -:'O' --gen3d -oxyz -Ostart.xyz`
 - hydronium: `obabel -:'[OH3+]' --gen3d -oxyz -Ostart.xyz`

Create input file, submit, etc.

 1. `g16.prepare -R "#P {methodkey}/{basiskey} OPT(MaxCycle=100)" -j "{method}-{basis}" -c "charge" "{dir}/start.xyz"`
 2. `g16.submit -p1 -m1000 -w"00:30:00" -P0 -M0 "{method}-{basis}.com"`
 3. `g16.freqinput "{method}-{basis}.com"`
 4. `g16.submit -p1 -m1000 -w"00:30:00" -P0 -M0 "{method}-{basis}.freq.com"`
 5. `g16.getfreq -V3 -f "{method}-{basis}.freq.summary.txt" "{method}-{basis}.freq.log"`
 6. `g16.chk2xyz -a`
 7. (`rm -v "{method}-{basis}.chk" "{method}-{basis}.freq.chk"`)
 8. Make tables.

## Results for comparison

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


Table 2: Reaction energies in kJ/mol for 
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


___version___: 2019-04-04-1847
