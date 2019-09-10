#!/bin/bash

###
#
# myq_slurm.sh --
#   a wrapper to the squeue command of the slurm queueing system
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

if ! command -v squeue &> /dev/null ; then
  echo "This script is a wrapper to 'squeue', but the command was not found."
  exit 1
fi

#hlp The script is an interface to the squeue command to reformat the output.
#hlp It will only show running and pending jobs.
#hlp 
#hlp Usage:
#hlp   ${0##*/} [option(s)]
#hlp   

#hlp Configuration files:
#hlp   '/etc/myslurm.rc'          (loaded first)
#hlp   '$HOME/.myslurmrc' 
#hlp   '$HOME/.config/myslurm.rc' (loaded last, i.e. superior)
#hlp
#hlp License: 
#hlp   myq_slurm.sh  Copyright (C) 2019  Martin C Schwarzer
#hlp   This program comes with ABSOLUTELY NO WARRANTY; this is free software,
#hlp   and you are welcome to redistribute it under certain conditions;
#hlp   please see the license file distributed alongside this repository,
#hlp   which is available when you type '${0##*/} license',
#hlp   or at <https://github.com/polyluxus/rwth-tools>.
#hlp

if [[ "$1" =~ ^[Ll][Ii][Cc][Ee][Nn][Ss][Ee]$ ]] ; then
  command -v curl &> /dev/null || fatal "Command 'curl' not found, but it is necessary to obtain the license."
  if command -v less &> /dev/null ; then
    curl --silent https://raw.githubusercontent.com/polyluxus/rwth-tools/master/LICENSE | less
  else
    curl --silent https://raw.githubusercontent.com/polyluxus/rwth-tools/master/LICENSE
  fi
  echo "Displayed license and will exit."
  exit 0
fi

# Source a global configuration
#shellcheck source=myslurm.rc
[[ -r "/etc/myslurm.rc" ]] && . "/etc/myslurm.rc"
#shellcheck source=myslurm.rc
[[ -r "$HOME/.myslurmrc" ]] && . "$HOME/.myslurmrc"
#shellcheck source=myslurm.rc
[[ -r "$HOME/.config/myslurm.rc" ]] && . "$HOME/.config/myslurm.rc"

show_full_path="${show_full_path:-false}"

OPTIND=1

while getopts :fFl:u:A:h options ; do
  #hlp Options:
  case $options in
    #hlp      -f           Show the full path (may result in two lines per entry)
    #hlp
    f)
      show_full_path="true"
      ;;

    #hlp      -F           Suppress path.
    #hlp
    F)
      show_full_path="none"
      ;;

    #hlp      -l <JOBID>   Print the long format of the information of the job with <JOBID>
    #hlp                   May be specified multiple times, will suppress the normal summary.
    #hlp                   <JOBID> can also contain multiple comma-separated (no spaces) IDs.
    #hlp
    l)
      long_format_jobids="$long_format_jobids,$OPTARG"
      ;;

    #hlp      -u <USER>    Show for specific user <USER> (default: $USER)
    #hlp                   This may be specified by a comma-separated list without spaces.
    #hlp                   If <USER>=all, then no specific user will be specified, 
    #hlp                   which will result in all users shown. [Not recommended]
    #hlp
    u)
      show_user="$OPTARG"
      ;;

    #hlp      -A <ACCOUNT> Show for <ACCOUNT> (or project) and all users within
    #hlp                   This will turn off the output for a specific user.
    #hlp                   This may be specified by a comma-separated list without spaces.
    #hlp                   
    A)
      show_account="$OPTARG"
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

shift $(( OPTIND - 1 ))

#hlp
#hlp  ___version___: 2019-09-10-1500

if [[ -n $long_format_jobids ]] ; then
  number_jobs=0
  while read -r line || [[ -n $line ]] ; do
    [[ $read_header != "off" ]] && { IFS='|' read -r -a header <<< "$line" ; read_header=off ; continue ; }
    IFS='|' read -r -a current_body <<< "$line"
    body+=( "${current_body[@]}" )
    unset current_body
    (( number_jobs++ ))
  done < <( squeue --jobs="${long_format_jobids#,}" --format="%all" )
  printed_jobs=0
  while (( printed_jobs < number_jobs )) ; do
    for index in "${!header[@]}" ; do
      body_index=$(( index + printed_jobs * ${#header[@]} ))
      printf '%-20s: %s\n' "${header[index]}" "${body[body_index]}"
    done
    printf '\n===================================\n\n'
    (( printed_jobs++ ))
  done
  exit 0
fi

declare -i width_total
width_total=$(tput cols)
declare -i width_time=20
declare -i width_user=9
declare -i width_project=8
declare -i width_stat=3
declare -i width_queue=8
declare -i width_slots=6
declare -i width_id=10
declare -i width_name=25
declare -i width_remain
width_remain=$(( width_total - width_time - width_user - width_project - width_stat - width_queue - width_slots - width_id - width_name -10 ))

declare -- queue_cmd="squeue"
declare -- queue_output_common queue_output_time queue_output_exedir 

declare -- show_user="${show_user:-$USER}"

call_queue ()
{
  local queue_opts=( "$@" )
  local count_jobs=0
  # If remaining width is smaller display of dir is turned off
  if (( width_remain > 19 )) ; then
    local truncator=" […] "
    local truncated_width=$(( (width_remain - 5) / 2 ))
    (( truncated_width-- ))
  fi
  while read -r line || [[ -n "$line" ]] ; do
    (( count_jobs++ ))
    if (( ${#line} < width_total )) ; then
      echo "$line"
      continue
    elif [[ -z $truncated_width ]] ; then
      echo "$line"
      continue
    fi
    if [[ "$line" =~ ^([^|]+|)(.*)$ ]] ; then
      local front="${BASH_REMATCH[1]}"
      local end="${BASH_REMATCH[2]}"
      if [[ "$show_full_path" == "true" ]] ; then
        printf '%s (++)\n(++) dir: %s\n' "$front" "$end"
      else
        echo "${front}${end:0:$truncated_width}${truncator}${end:(-$truncated_width)}"
      fi
    fi
  done < <($queue_cmd "${queue_opts[@]}")
  printf 'Total number of jobs: %4d\n\n' "$(( count_jobs - 1 ))"
}

queue_output_common=""
queue_output_common+="%${width_user}u "
queue_output_common+="%${width_project}a "
queue_output_common+="%.${width_stat}t "
queue_output_common+="%.${width_queue}P "
queue_output_common+="%.${width_slots}C "
queue_output_common+="%.${width_id}i "
queue_output_common+="%.${width_name}j "

if (( width_remain < 20 )) ; then
  echo "Warning: Terminal is a bit too small to fit the directories."
  unset queue_output_exedir 
elif [[ "$show_full_path" == "none" ]] ; then
  unset queue_output_exedir
else
  queue_output_exedir="| %Z"
fi

printf 'It is %s.\n\n' "$(date +"%F %T (%Z)")"

# Show account queue instead of user queue
if [[ -n $show_account ]] ; then
  queue_output_time="%${width_time}S "
  call_queue --account="$show_account" --states=R --format="$queue_output_time$queue_output_common$queue_output_exedir"
  queue_output_time="%${width_time}V "
  call_queue --account="$show_account" --states=PD --format="$queue_output_time$queue_output_common$queue_output_exedir"
elif [[ "$show_user" =~ ^[Aa][Ll][Ll]$ ]] ; then
  queue_output_time="%${width_time}S "
  call_queue --states=R --format="$queue_output_time$queue_output_common$queue_output_exedir"
  queue_output_time="%${width_time}V "
  call_queue --states=PD --format="$queue_output_time$queue_output_common$queue_output_exedir"
else
  queue_output_time="%${width_time}S "
  call_queue --user="$show_user" --states=R --format="$queue_output_time$queue_output_common$queue_output_exedir"
  queue_output_time="%${width_time}V "
  call_queue --user="$show_user" --states=PD --format="$queue_output_time$queue_output_common$queue_output_exedir"
fi

