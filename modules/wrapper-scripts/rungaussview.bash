#!/bin/bash
#___version___: 2019-02-12-2239

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
module load gaussian/16.b01_bin 
module load gaussview/60

# Log the set variables
declare -p | grep GAUSS >&2

# Find the executable
if gaussview_loc="$(command -v gview)" ; then
  echo "gview is $gaussview_loc."
elif [[ -n $GV_DIR ]] ; then
  # Try a standard location
  gaussview_loc="$GV_DIR/gview"
else
  echo "Something went wrong loading the modules. Abort."
  exit 1
fi

if [[ ! -e "$gaussview_loc" || ! -x "$gaussview_loc" ]] ; then
  echo "GaussView not found or not executable."
  exit 1
else
  export LANG=en_US.utf8 
  export LC_ALL=en_US.utf8 
  "$gaussview_loc" "$@"
fi
