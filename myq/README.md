# myq.sh

This directory hosts wrapper to the queue interfaces,
to show information on running, queueing, and completed jobs.

Directories:

- [bsub](./bsub): `myq.sh` reformats the output of the `bjobs`
  utility on the RWTH bull cluster for better readability.
  This cluster will be decommissioned in April 2019,
  so the content is only of historic value.

- [slurm](./slurm): *in preparation* `myq.sh` is an interface to slurm,
  the queueing system available on the CLAIX16 and CLAIX18 cluster.

## Installation

Copy or link the script(s) to a directory found in your path.
No set-up required.

There is another script in this directory, which tries to guess the
command and execute the correct script.
(If you copy all three scripts to the directory, it should also work on the old BULL cluster.)

___version___: 2019-02-28-1035
