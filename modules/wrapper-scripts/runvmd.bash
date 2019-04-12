#!/bin/bash
# This is a simple wrapper to start VMD
#___version___: 2019-04-12-1335

if [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] ; then
  echo "Running on $HOSTNAME." >&2
else
  echo "Script is designed for use on RWTH RZ Cluster."
  echo "Found $HOSTNAME. Please make adjustments to the script."
  exit 1
fi

# If TMP does not exist, make one 
[[ -z $TMP ]] || TMP="$(mktemp --directory --tmpdir gaussian.XXXXX)" && export TMP

# Load the modules (output goes to stderr)
module load CHEMISTRY 
module load vmd

# Log the set variables
declare -p | grep 'VMD_HOME' >&2

# Execute any commands

vmd "$@"

