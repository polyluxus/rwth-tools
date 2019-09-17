# Submit script for pysisyphus 

This directory contains a submit script for 
[pysisyphus](https://github.com/eljost/pysisyphus).

## Prerequisites

This installation needs pysisiphus and slurm and all dependencies thereof.

It is highly recommended (but not necessary) to have a virtual environment
and load modules for the used quantum chemistry packages.

## Installation

1. Link/ copy the executable script `pysis.sub.sh` to a directory on your `PATH`.
2. Place and edit the `.pysis.subrc` in your `HOME` **or**  
   place and edit the `pysis.sub.rc` in your `HOME/.config`

## Setting up pysisyphus on CLAIX18

Thanks to the IT department, you can on CLAIX18 use a modern version of python right out of the box.
At the time of writing, this was [Python 3.7.3](https://www.python.org/downloads/release/python-373/).
You can check the available verions with
```
modules avail
```

The python modules are located within the `DEVELOP` submodule, so be sure to have that loaded;
which it should be at startup.
Now you can load the python module:
```
module load python/3.7.3
```
Check that you are actually using the correct version, 
as the principle binary may still point to another version:
```
python --version
```
If you get something like `Python 2.7.5`, then try explicitly:
```
python3 --version
```
In this example it should now say `Python 3.7.3`.

I recommend creating local (or virtual) environments for the use with pysisyphus.
Therefore I have made a directory where to store these.
I'll be using my setup as the example for this guide.
Create the directory, if you have not already, and change to it:
```
mkdir ~/local/python/local_env/
cd ~/local/python/local_env/
```
Now you can create the virtual environment `pysisiphus-p3.7.3-claix` with the following command:
```
python3 -m venv pysisiphus-p3.7.3-claix
```
This will create a new directory of the same name in the current location.
In order to activate this environment, you have to source the activation script:
```
. ~/local/python/local_env/pysisiphus-p3.7.3-claix/bin/activate
```
The path to this script should also be set as `local_python_environment`
in the `pysis.sub.rc` (see above).
Your prompt should have changed now, at the very begining there is the name
of the virtual environment in parenthesis.

Now change to the directory where you store your own software,
it is `~/local` in my case and clone pysisyphus into it.
```
cd ~/local
git clone https://github.com/eljost/pysisyphus.git 
```
This should create the repository `~/local/pysisyphus`, change to it:
```
cd ~/local/pysisyphus
```
To access the newest features, you can change to the development branch,
but you can also use the current master snapshot.
Please keep in mind that pysisyphus is in active development and currently
not recommended for production work.
Make sure to support the repository by reporting bugs,
and check the manual and read-me/GitHub pages for the latest changes.
Check out the development branch:
```
git checkout dev
```
Now you can set up pysisyphus with the following command,
which should install all necessary packages in the virtual environment.
```
python3 setup.py develop
```
After that, check whether it installed properly:
```
pysis --help
```
Now tell pysisyphus about some of the commands it needs. 
Create the file `~/.pysisyphusrc` with the following contents (see manual for more):
```
[xtb]
cmd=xtb
[gaussian16]
cmd=g16
formchk_cmd=formchk
unfchk_cmd=unfchk
```
This requires to load the Gaussian and xtb modules (on CLAIX18 within `CHEMISTRY`) 
before using pysisyphus.
In `pysis.sub.rc` (see above), this can be achieved by adding (editing) the following:
```
use_modules=( "CHEMISTRY" "xtb" "gaussian/16.b01_bin" )
```

This should complete the set-up, and once you have updated the `pysis.sub.rc` (see above),
you should be ready to use the software.

## Testing the NEB with pysisyphus

At the time of writing the following worked:

1. Make a testing directory and change to it.
   ```
   mkdir ~/tmp/pysis
   cd ~/tmp/pysis
   ```

2. Create two Xmol files, one for hydrogen cyanide and one for hydrogen isocyanide with open babel:
   ```
   obabel -:'CC(C)=O' --gen3d -oxyz -Oacetone.xyz
   obabel -:'CC(O)=C' --gen3d -oxyz -Opropenol.xyz
   ```
   Make sure the atom sequence is identical in both files, which they will not be.
   You can try the automated approach, but that will probably not always work.
   ```
   pysistrj --match acetone.xyz propenol.xyz
   ```
   The created structure might have the proton on the wrong side of the oxygen 
   in the structure of prop-1-en-2-ol `propenol.xyz`, 
   you might want to turn this around manually.
  
   Optionally you can optimise the individual molecules with xtb first.

3. Create a yaml file with the pysisyphus set-up. 
   I have called it `pysisyphus_neb.yaml` and it contains the following:
   ```
   cos:
    type: neb
    climb: True
   opt:
    type: qm
    max_cycles: 10
    align: True
    climb: True
   interpol:
    type: lst
    between: 10
   calc:
    type: xtb
    charge: 0
    mult: 1
    pal: 4
   xyz: [ acetone.xyz, propenol.xyz ]
   ```
   Now you can run pysisyphus (interactive, i.e. you have to activate your virtual environment):
   ```
   pysis pysisyphus_neb.yaml
   ```
   This will run 10 cycles and most likely not converge.
   You can have a look at the NEB paths that were created in the `cycle_???.trj` files.
   A (often) reasonable guess to the transition state is called `splined_hei.xyz`.  
   Try running the following to see the convergence plotted:
   ```
   pysisplot --energies
   ```
   
   Note that the above has done interactively. 
   You can of course also submit it to the queue:
   ```
   pysis.sub pysisyphus_neb.yaml
   ```

4. Post-process the directory.
   This will essentially be handled already if you submit it with the script. 
   Then you can just go ahead and use your method of choice to find the transition state 
   and preform IRC calculations.
 
 ___version___: 2019-09-17-1200
 
