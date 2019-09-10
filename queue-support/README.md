# Queue Support

Formerly known as `myq.sh`.

This directory hosts wrapper to the queue interfaces,
to show information on running, queueing, and completed jobs.

Directories:

- [bsub](./bsub): 
  * `myq_bsub.sh` reformats the output of the `bjobs`
    utility on the RWTH bull cluster for better readability.
    This cluster will be (read: is/was) decommissioned in April 2019,
    so the content is only of historic value.

- [slurm](./slurm): 
  * `myq_slurm.sh` is an interface to the slurm utility `squeue`,
    the queueing system available on the CLAIX16 and CLAIX18 cluster.
    It shows running and pending jobs.  
  * `myjobinfo_slurm.sh` is an interface to the accounting tool `sacct`.  
  * `mymail_slurm.sh` is a mail-writing script footing on the above.
    In theory this could be used as a replacement of the 
    [seff/smail](https://github.com/SchedMD/slurm/tree/master/contribs/seff)
    combination shipped with SLURM (https://github.com/SchedMD/slurm),
    and used via the setting `MailProg=/path/to/smail`.
    This is still somewhat experiemental, because I can only test it so far;
    i.e. as part of the job, not as mail program substitute. 
  * `init_gotojobdir.bash` is an initialisation script that implements a function `gotojobdir`,
    which retrieves the working directory via the `sacct` command, 
    and then changes to this directory.
    Because of this, it has to be sourced in the main shell,
    as a subshell (which it will run in if executed as a script) 
    cannot effect the main process.  
    Installing this script means placing it with other initialisation scripts 
    (which are automatically sourced), or explicitly specifying it to be sourced within `.bashrc`.
    If you use the [`dotfiles`](/dotfiles/) of this repository,
    you can simply copy it to the recommended `~/local/bash_profile.d/` directory,
    from which it will be sourced automatically.
  * `myslurm.rc` is an example configuration file.

## Installation

Copy or link the executable script(s) to a directory found on your `PATH` variable.
In most cases, no set-up is required.
If you want persistent options set, you can use the example rc file 
and copy it to (one of) these locations, which will all be sourced if they exist:

1. '/etc/myslurm.rc'          (loaded first)
2. '$HOME/.myslurmrc' 
3. '$HOME/.config/myslurm.rc' (loaded last, i.e. superior)

The scripts should work with bash and the queueing system as its only dependencies.
 
Additionally `mymail_slurm.sh`, uses `mail`, which can be configured to use a substitute program.
It needs `myjobinfo_slurm.sh` to be executeable and found in `PATH`, 
but it can also be configured to use absolute paths.

Scripts with the prefix `init_` are meant to be sourced by `.bashrc`. 
If they are executed, they will only print a warning and exit.
These scripts should be placed with other initialisation scripts.
See [`dotfiles`](/dotfiles/) for more information.

There is another script in this directory `myq_switcher.sh`, which tries to guess the
command and execute the correct script.
(If you copy all three `myq_` scripts to the `~/bin` directory, 
it should work without configuration/edit on the new CLAIX18 and the old BULL clusters.
Note that the latter is decommissioned in April 2019.)

## License (GNU General Public License v3.0)

rwth-tools - a collection of scripts for CLAIX18  
Copyright (C) 2019 Martin C Schwarzer

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See [LICENSE](LICENSE) to see the full text.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

___version___: 2019-09-10-1500
