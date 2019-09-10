#!/bin/bash
#___version___: 2019-08-27-1732

if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : #Everything is fine
else
  echo "This script is only meant to be sourced."
  exit 0
fi

# Add some exception when not to load this configuration file.
# Only load this for bash:
[[ "$SHELL" =~ [Bb][Aa][Ss][Hh] ]] || return

# On CLAIX18, SHLVL=1 corresponds to the default zsh for login (switching not possible).
# The recommended way is to start the bash via the .zshrc, making this SHLVL=2.
# For any other system we can assume that modules have been initialised at SHLVL=1,
# (which might has to be implemented below at 'No redefinition found'.)
# so we do not need to repeat the process (it's inherited).
if (( SHLVL > 1 )) ; then
  [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] || return
fi
# Let's assume we initialise modules on CLAIX18 at SHLVL=2, 
# we can skip sourcing this file for child processes for the same reasons as above.
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
unset local_modulepath

if [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] ; then
  echo "Redefined: module (Don't forget to load your local modules.)"
  # Make function 'module' available, emulating the autoload feature; 
  # which is available for ksh and zsh, but not for bash!
  module () {
    # If we detect the super user (root), do nothing, see https://askubuntu.com/a/836092/220129
    # Do not rely on that it is called root!
    if ! (( ${EUID:-0} || "$(id -u)"  )) ; then 
      echo "module: not available for root" >&2 
      return 1 
    fi
  
    # Redefine 'module'.
    # These are data from CLAIX18 at the time of writing.
    local module_cmd="modulecmd.tcl"
    local module_dir="/usr/local_rwth/modules/src"
  
    # BugFix: The statements cannot be combined, because local -r exits with 0,
    #         even if it assigns nothing to the variable, and the subshell exits > 0.
    local -r source_autoinit=$( tclsh "$module_dir/$module_cmd" sh autoinit 2> /dev/null )
    # BugFix: Check if there is something to execute instead.
    if [[ -n $source_autoinit ]] ; then
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
  echo "ERROR: No redefinition for 'module' found."
fi

