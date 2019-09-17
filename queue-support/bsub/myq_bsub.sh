#!/bin/bash

if command -v bjobs &> /dev/null ; then
  :
else
  echo "Is bjobs installed?"
  exit 1
fi

declare -- show_full_path="false"

#hlp The script is an interface to the bjobs command to reformat the output.
#hlp The default behaviour is to print the currently running, pending, and finished/exited jobs.
#hlp If the path doesn't fit the width of the window, it will be truncated or skipped.
#hlp 
#hlp Usage:
#hlp   ${0##*/} [project(s)]
#hlp   
#hlp If one or more project names are given as arguments, the script will show a summary
#hlp of the currentlöy running jobs in those projects instead.
#hlp
OPTIND=1

while getopts :fl:h options ; do
  #hlp Options:
  case $options in
    #hlp      -f           Show the full path (may result in two lines per entry)
    #hlp
    f)
      show_full_path="true"
      ;;

    #hlp      -l <JOBID>   Print the long format of the information of the job with <JOBID>
    #hlp                   May be specified multiple times and will also print the normal summary.
    #hlp
    l)
      bjobs -all "$OPTARG"
      ;;

    #hlp      -h           Show this help file and exit.  
    #hlp
    h)
      pattern="^[[:space:]]*#hlp(.*)?$"
      while read -r line || [[ -n "$line" ]] ; do
        [[ "$line" =~ $pattern ]] && eval "printf 'HELP: %s\n' \"${BASH_REMATCH[1]}\""
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
#hlp  ___version___: 2019-09-17-1200

declare -a gathered_projects=( "$@" )

declare -i width_total
width_total=$(tput cols)
declare -i width_time=16
declare -i width_user=8
declare -i width_project=8
declare -i width_stat=4
declare -i width_queue=5
declare -i width_slots=5
declare -i width_id=10
declare -i width_name=25
declare -i width_remain
width_remain=$(( width_total - width_time - width_user - width_project - width_stat - width_queue - width_slots - width_id - width_name -10 ))

declare -- queue_cmd="bjobs"
declare -- queue_output_common queue_output_time queue_output_exedir queue_output_subdir

call_queue ()
{
  local queue_opts=( "$@" )
  if (( width_remain > 19 )) ; then
    local truncator=" […] "
    local truncated_width=$(( (width_remain - 5) / 2 ))
    (( truncated_width-- ))
  fi
  while read -r line || [[ -n "$line" ]] ; do
    if (( ${#line} < width_total )) ; then
      echo "$line"
      continue
    elif [[ -z $truncated_width ]] ; then
      echo "$line"
      continue
    fi
    if [[ "$line" =~ ^([^/]+)(.*)$ ]] ; then
      local front="${BASH_REMATCH[1]}"
      local end="${BASH_REMATCH[2]}"
      if [[ "$show_full_path" == "true" ]] ; then
        printf '%s (++)\n(++) dir: %s\n' "$front" "$end"
      else
        echo "${front}${end:0:$truncated_width}${truncator}${end:(-$truncated_width)}"
      fi
    fi
  done < <($queue_cmd "${queue_opts[@]}")
  echo ""
}

queue_output_common=" "
queue_output_common+="user:$width_user "
queue_output_common+="project:$width_project "
queue_output_common+="stat:-$width_stat "
queue_output_common+="queue:-$width_queue "
queue_output_common+="slots:-$width_slots "
queue_output_common+="id:-$width_id "
queue_output_common+="name:-$width_name "

for project in "${gathered_projects[@]}" ; do
  queue_output_time="submit_time:$width_time "
  echo "Project: $project"
  call_queue -u all -P "$project" -o "$queue_output_time$queue_output_common"
  unset queue_output_time
done

(( ${#gathered_projects[@]} > 0 )) && exit 0


if (( width_remain < 20 )) ; then
  echo "Warning: Terminal is a bit too small to fit the directories."
  unset queue_output_exedir queue_output_subdir
else
  queue_output_exedir="exec_cwd"
  queue_output_subdir="sub_cwd"
fi

printf "It is %s\n\n" "$(date +"%F %T (%Z)")"

queue_output_time="start_time:$width_time "
call_queue -r -o "$queue_output_time$queue_output_common$queue_output_exedir"
queue_output_time="submit_time:$width_time "
call_queue -p -o "$queue_output_time$queue_output_common$queue_output_subdir"
queue_output_time="finish_time:$width_time "
call_queue -d -o "$queue_output_time$queue_output_common$queue_output_exedir"
exit

