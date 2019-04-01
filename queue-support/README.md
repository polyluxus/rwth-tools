# Queue Support

Formerly known as `myq.sh`.

This directory hosts wrapper to the queue interfaces,
to show information on running, queueing, and completed jobs.

Directories:

- [bsub](./bsub): `myqi_bsub.sh` reformats the output of the `bjobs`
  utility on the RWTH bull cluster for better readability.
  This cluster will be (read: is/was) decommissioned in April 2019,
  so the content is only of historic value.

- [slurm](./slurm): `myq_slurm.sh` is an interface to the slurm utility `squeue`,
  the queueing system available on the CLAIX16 and CLAIX18 cluster.
  It shows running and pending jobs.  
  `myjobinfo_slurm.sh` is an interface to the accounting tool `sacct`.  
  `mymail_slurm.sh` is a mail-writing script footing on the above.
  (This is still quite experimental.)

## Installation

Copy or link the script(s) to a directory found in your path.
No set-up required. 
(Except for `mymail_slurm.sh`, but that will be explained, when it works as expected.)

There is another script in this directory `myq_switcher.sh`, which tries to guess the
command and execute the correct script.
(If you copy all three `myq` scripts to the `~/bin` directory, 
it should work without configuration/edit on the new CLAIX18 and the old BULL clusters.)

___version___: 2019-04-01-2152
