#!/bin/bash
# ___version___: 2019-04-00-0000

if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : #Everything is fine
else
  echo "This script is only meant to be sourced."
  exit 0
fi

if command -v sacct &> /dev/null ; then
  :
else
  echo "This script is a wrapper to 'sacct', but the command was not found."
  return 1
fi

go2jobdir ()
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
        echo "The command is an interface to 'sacct' to retrieve the work directory and change to it."
        echo "${0##*/} [option(s)] jobid"
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
echo "Available command: go2jobdir [-h]"
