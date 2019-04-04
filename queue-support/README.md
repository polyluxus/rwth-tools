# Queue Support

Formerly known as `myq.sh`.

This directory hosts wrapper to the queue interfaces,
to show information on running, queueing, and completed jobs.

Directories:

- [bsub](./bsub): 
  * `myqi_bsub.sh` reformats the output of the `bjobs`
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

## Installation

Copy or link the script(s) to a directory found in your path.
In most cases, no set-up is required.
The scripts should work with bash and the queueing system as dependencies.
 
Additionally `mymail_slurm.sh`, uses `mail`, which can be configured to use a substitute.
It needs `myjobinfo_slurm.sh` to be executeable and found in `PATH`, 
but it can be configured to use absolute paths.

There is another script in this directory `myq_switcher.sh`, which tries to guess the
command and execute the correct script.
(If you copy all three `myq` scripts to the `~/bin` directory, 
it should work without configuration/edit on the new CLAIX18 and the old BULL clusters.)

___version___: 2019-04-04-1847
