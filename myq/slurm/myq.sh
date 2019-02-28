#!/bin/bash

if command -v squeue &> /dev/null ; then
  :
else
  echo "This script is a wrapper to 'squeue', but the command was not found."
  exit 1
fi

declare -- show_full_path="false"

#hlp The script is an interface to the squeue command to reformat the output.
#hlp It will only show running and pending jobs.
#hlp 
#hlp Usage:
#hlp   ${0##*/} [option(s)]
#hlp   
OPTIND=1

while getopts :fFl:u:h options ; do
  #hlp Options:
  case $options in
    #hlp      -f           Show the full path (may result in two lines per entry)
    #hlp                   (WORK IN PROGRESS)
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
    #hlp                   May be specified multiple times and will also print the normal summary.
    #hlp                   (WORK IN PROGRESS)
    #hlp
    l)
      squeue --jobs="$OPTARG" --format="%all"
      ;;

    #hlp      -u <USER>    Show for <USER>
    u)
      show_user="$OPTARG"
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
#hlp  ___version___: 2019-02-28-1035

# Reimplement later (maybe)
# declare -a gathered_projects=( "$@" )

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
  # If remaining width is smaller display of dir is turned off
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
  echo ""
}

queue_output_common=""
queue_output_common+="%${width_user}u "
queue_output_common+="%${width_project}a "
queue_output_common+="%.${width_stat}t "
queue_output_common+="%.${width_queue}P "
queue_output_common+="%.${width_slots}C "
queue_output_common+="%.${width_id}i "
queue_output_common+="%.${width_name}j "

# Reimplement later (maybe)
# for project in "${gathered_projects[@]}" ; do
#   queue_output_time="submit_time:$width_time "
#   echo "Project: $project"
#   call_queue -u all -P "$project" -o "$queue_output_time$queue_output_common"
#   unset queue_output_time
# done
# 
# (( ${#gathered_projects[@]} > 0 )) && exit 0

if (( width_remain < 20 )) ; then
  echo "Warning: Terminal is a bit too small to fit the directories."
  unset queue_output_exedir 
elif [[ "$show_full_path" == "none" ]] ; then
  unset queue_output_exedir
else
  queue_output_exedir="| %Z"
fi

printf 'It is %s.\n\n' "$(date +"%F %T (%Z)")"

queue_output_time="%${width_time}S "
call_queue --user="$show_user" --states=R --format="$queue_output_time$queue_output_common$queue_output_exedir"
queue_output_time="%${width_time}V "
call_queue --user="$show_user" --states=PD --format="$queue_output_time$queue_output_common$queue_output_exedir"
exit

