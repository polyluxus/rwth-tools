#!/bin/bash
# ___version___: 2019-09-10-1348

###
#
# init_gotojobdir.bash -- 
#   an initialisation script to make the 'gotojobdir' command available
#   it retrieves the working diretory of a batch job based on the job ID
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

if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : # Script is suorced, everything is fine
else
  echo "This script is only meant to be sourced."
  exit 0
fi

if command -v sacct &> /dev/null ; then
  :
else
  echo "The function to be defined is a wrapper to 'sacct', but the command was not found."
  return 1
fi

gotojobdir ()
{
  local sacct_format="WorkDir"
  local print_only=false
  local OPTIND=1
  while getopts :ph options ; do
    case $options in
      #         -p           Print only, do not change to the directory.
      p)
        print_only=true
        ;;
      #         -h           Show this help file and exit.  
      h)
        echo "The command 'gotojobdir' is an interface to 'sacct' to retrieve the work directory and change to it."
        echo "Usage: gotojobdir [option(s)] jobid"
        echo "Options: -p (print only), -h (this help)"
        return 0
        ;;
      \?)
        echo "Invalid option: -$OPTARG"
        return 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument."
        return 1
        ;;
    esac
  done
  
  shift $(( OPTIND - 1 ))
  [[ -n $1 ]] || { echo "Job ID necessary." ; return 1; }
  local show_jobid="$1"
  [[ "$show_jobid" =~ ^[[:digit:]]+$ ]] || { echo "Job ID must be an integer value." ; return 1 ; }
  shift
  while [[ -n $1 ]] ; do
    echo "Ignoring: $1" >&2
    shift
  done
  local job_workdir
  job_workdir=$( sacct --noheader --format="$sacct_format" --parsable --jobs="$show_jobid" 2> /dev/null )
  job_workdir="${job_workdir%%|*}"
  [[ -z "$job_workdir" ]] && { echo "Cannot obtain work directory." ; return 1 ; }
  [[ "$print_only" == "true" ]] && { echo "$job_workdir" ; return 0 ; }
  cd "$job_workdir" || { echo "Change to directory failed." ; return 1 ; }
  pwd
}
echo "Available command: gotojobdir [-h]"
