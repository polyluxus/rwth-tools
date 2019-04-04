#!/bin/bash

if command -v sacct &> /dev/null ; then
  :
else
  echo "This script is a wrapper to 'sacct', but the command was not found."
  exit 1
fi

sacct_format_default="JobID,JobName,WorkDir,Cluster,User,Group,Account,Partition,State,ExitCode,"
sacct_format_default+="AllocCPU,AllocNodes,CPUTime,CPUTimeRAW,Elapsed,ElapsedRaw,"
sacct_format_default+="Submit,Start,End"
declare -- only_two

#hlp The script is an interface to the sacct command to reformat the output.
#hlp 
#hlp Usage:
#hlp   ${0##*/} [option(s)] jobid
#hlp   
OPTIND=1

while getopts :f:Fmh options ; do
  #hlp Options:
  case $options in
    #hlp      -f           Show different fields than coded within this script.
    #hlp                   (default: $sacct_format_default)
    #hlp
    f)
      sacct_format="$OPTARG"
      ;;

    #hlp      -F           Show all available fields, essentially 'sacct --helpformat', and exit
    #hlp
    F)
      sacct --helpformat
      exit 0
      ;;

    #hlp      -m           Show only one line (presumably the main line) for the job
    #hlp
    m)
      only_two=true
      ;;

    #hlp      -h           Show this help file and exit.  
    #hlp
    h)
      pattern="^[[:space:]]*#hlp(.*)?$"
      while read -r line || [[ -n "$line" ]] ; do
        [[ "$line" =~ $pattern ]] && eval "printf 'HELP: %s\\n' \"${BASH_REMATCH[1]}\""
      done < <( grep '#hlp' "$0" )
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done
#hlp
#hlp  ___version___: 2019-04-04-1847


shift $(( OPTIND - 1 ))
[[ -n $1 ]] || { echo "Job ID necessary." ; exit 1; }
show_jobid="$1"
shift
while [[ -n $1 ]] ; do
  echo "Ignoring: $1" >&2
  shift
done

sacct_format="${sacct_format:-$sacct_format_default}"
while read -r line || [[ -n $line ]] ; do
#  echo "Read: $line"
  if [[ $read_header != "off" ]] ; then
    IFS='|' read -r -a header <<< "$line" 
    read_header=off
    printf '=== MAIN =========================================\n'
    continue 
  fi
  IFS='|' read -r -a body <<< "$line"
  for index in "${!header[@]}" ; do
    printf '%-20s: %s\n' "${header[index]}" "${body[index]}"
  done
  printf '==================================================\n\n'
  [[ -n $only_two ]] && break # breakout
done < <( sacct --jobs="$show_jobid" --parsable --format="$sacct_format" )

