#!/bin/bash
#___version___: 2019-02-18-1908

if (( ${#BASH_SOURCE[*]} == 1 )) ; then
  echo "This script is only meant to be sourced."
  exit 0
fi

# Add some exception when not to load this configuration file
# When on the RWTH cluster, SHLVL=1 corresponds to the default zsh,
# in all other cases the default shell may be bash and we can skip the set-up
# as modules are probably already loaded
if (( SHLVL > 1 )) ; then
  [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] || return
fi
# On the RWTH cluster, assuming we have already set-up bash, (and with it modules)
# meaning it is already SHLVL=2, we can skip sourcing this file for later instances
if [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] && (( SHLVL > 2 )) ; then
  return
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
  if [[ -r "$HOME/.rwth-modulesrc" ]] ; then
    echo "Loading modules according to '$HOME/.rwth-modulesrc'."
    while read -r line || [[ -n "$line" ]] ; do
      pattern='^[[:space:]]*#'
      [[ "$line" =~ $pattern ]] && continue
      [[ -z $line ]] && continue
      module load "$line"
    done < "$HOME/.rwth-modulesrc"
  fi
else
  # If not on the RWTH RZ cluster, there should be a different init script.
  # (I have non available currently.)
  :
fi






