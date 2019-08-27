#!/bin/env bash
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

  local -r source_autoinit=$( tclsh "$module_dir/$module_cmd" sh autoinit 2> /dev/null )
  if [[ -n $source_autoinit ]] ; then
    $source_autoinit
    module "$@"
  else
    echo "ERROR: no modules available" >&2 
    return
  fi

}

