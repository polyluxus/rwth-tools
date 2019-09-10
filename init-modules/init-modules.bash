#!/bin/env bash

###
#
# init-modules.bash -- 
#   initialises the autoload feature for the module environment
# Copyright (C) 2019 Martin C Schwarzer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
###

# If this script is not sourced, return before executing anything
if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : #Everything is fine
else
  echo "This script needs to be sourced to redefine the module command."
  exit 0
fi

# Make function 'module' available, emulating the autoload feature; 
# which is available for ksh and zsh, but not for bash!
module () {
  # If root, do nothing, see https://askubuntu.com/a/836092/220129
  if ! (( ${EUID:-0} || "$(id -u)"  )) ; then 
    echo "module: not available for root" >&2 
    return 1 
  fi

  # Redefine 'module'.
  # Edit the location of the initialisation scripts.
  # The following are for CLAIX18:
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

