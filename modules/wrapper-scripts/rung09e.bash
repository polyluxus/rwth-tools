#!/bin/bash
#___version___: 2019-01-28-1824

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
module load gaussian/09.e01_bin 

# Log the set variables
declare -p | grep GAUSS >&2

# Execute any commands
"$@"
