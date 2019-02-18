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

___version___: 2019-02-18-1908
