#!/bin/bash
#___version___: 2019-01-24-1428

if (( ${#BASH_SOURCE[*]} == 1 )) ; then
  echo "This script is only meant to be sourced."
  exit 0
fi

# Where are the local modules stored?
local_modulepath="$HOME/local/modules/modulefiles/LOCAL"

if [[ -z $MODULEPATH ]] ; then
  MODULEPATH="$local_modulepath"
else
  MODULEPATH="$local_modulepath:$MODULEPATH"
fi
export MODULEPATH

if [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] ; then
  echo "Redefined: module (Don't forget to load your local modules.)"
  # Make function 'module' available, emulating the autoload feature; 
  # which is available for ksh and zsh, but not for bash!
  module () {
    # If root, do nothing, see https://askubuntu.com/a/836092/220129
    if ! (( ${EUID:-0} || "$(id -u)"  )) ; then 
      echo "module: not available for root" >&2 
      return 1 
    fi
  
    # Redefine 'module'.
    local module_cmd="modulecmd.tcl"
    local module_dir="/usr/local_rwth/modules/src"
  
    if local -r source_autoinit=$( tclsh "$module_dir/$module_cmd" sh autoinit 2> /dev/null ) ; then
      $source_autoinit
      module "$@"
    else
      echo "ERROR: no modules available" >&2 
      return
    fi
  
  }
else
  # If not on the RWTH RZ cluster, there should be a dirrerent init script.
  # (I have non available currently.)
  :
fi






