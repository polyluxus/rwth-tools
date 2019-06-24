#!/bin/bash
# 
# Will be sourced by ~/.bashrc of this package
# ___version___: 2019-06-24-1724

# Get settings for sciebo and define some functions to use it,
# otherwise skip it
if [[ -r "$HOME/.scieborc" ]] ; then 
  source "$HOME/.scieborc"

  # The following function synchronises a directory with the sciebo cloud

  echo "Available command: sync_sciebo [-h]"
  sync_sciebo ()
  {
    if [[ "$1" == "-h" ]] ; then
      echo "sync_sciebo is a function that synchronises a predefined (~/.scieborc) directory with the sciebo cloud."
      return 0
    fi
    if ! command -v owncloudcmd &> /dev/null ; then
      echo "ERROR: Command 'owncloudcmd' not found."
    fi
    local date_current time_current log err 
    local sciebo_passwd
    local OLDIFS="$IFS"
    date_current=$(date +%Y%m%d)
    log="$LOGFILES/sync.sciebo.$date_current.log"
    err="$LOGFILES/sync.sciebo.$date_current.err"
    if [[ -e "$log" || -e "$err" ]] ; then
      time_current=$(date +%H%M%S)
      log="${log/log/}$time_current.log"
      err="${err/err/}$time_current.err"
    fi
    printf 'Password for %s: ' "$SCIEBOUSER"
    IFS="" read -r -s sciebo_passwd
    IFS="$OLDIFS"
    printf '\n'
    printf 'Synchronising "%s" to "%s" ...' "$SCIEBOSOURCE" "$SCIEBOTARGET"
    owncloudcmd -u "$SCIEBOUSER" -p "$sciebo_passwd" "$SCIEBOSOURCE" "$SCIEBOTARGET" > "$log" 2> "$err"
    printf ' Done.\n'
  }
fi

echo "Available command: mylocate [ -h | -d <db> | -u ]"
mylocate ()
{

  local OPTIND=1
  local mylocate_database
  local mylocate_update="FALSE"
  local mylocate_sources="$HOME"

  if [[ -e "$HOME/.mylocate.rc" ]] ; then
    # shellcheck source=/dev/null
    source "$HOME/.mylocate.rc"
  fi

  while getopts d:uh options ; do
    case $options in
      h) 
        echo "This is a local implementation of locate for the HOME directory."
        type mylocate
        return 0
        ;;
      d)
        mylocate_database="$OPTARG"
        ;;
      u)
        mylocate_update="TRUE"
        ;;
      \?)
        echo "Invalid option: -$OPTARG."
        return 1
        ;;
      :)
        echo "Option -$OPTARG requires an argument."
        return 1
        ;;
    esac
  done

  shift $(( OPTIND -1 ))

  if [[ -z $mylocate_database ]] ; then
    mylocate_database="$HOME/.mylocate.db"
  fi

  echo "Using: $mylocate_database"
  declare -p mylocate_database > "$HOME/.mylocate.rc"

  if [[ "$mylocate_update" == "TRUE" ]] ; then
    local mylocate_logfile
    if [[ -z $LOGFILES ]] ; then
      mylocate_logfile="${mylocate_database}.log.$(date +%H%M%S)"
    else
      mylocate_logfile="$LOGFILES/mylocate.db.log.$(date +%H%M%S)"
    fi
    echo "Logfile: $mylocate_logfile"
    updatedb -v --require-visibility 0 -o "$mylocate_database" -U "$mylocate_sources" &> "$mylocate_logfile"
    return 0
  fi

  locate --database="$mylocate_database" "$@"

}

echo "Available command: rsync_log [-h]"
rsync_log ()
{
  [[ "$1" == "-h" || -z $1 ]] && { echo "Usage: rsync_log <base_directory> <target_directory>" ; return ; }
  if ! command -v rsync &> /dev/null ; then
    echo "ERROR: Command 'rsync' not found."
  fi
  [[ -z $LOGFILES ]] && LOGFILES="$HOME"
  local date_current time_current in_dir out_dir log err 
  date_current=$(date +%Y%m%d)
  in_dir="$1"
  out_dir="$2"
  [[ -d "$in_dir" ]]  || { echo "ERROR: Not a directory ($in_dir)."  ; return 1 ; }
  [[ -d "$out_dir" ]] || { echo "ERROR: Not a directory ($out_dir)." ; return 1 ; }
  log="$LOGFILES/rsync.${in_dir//\//%}_to_${out_dir//\//%}.$date_current.log"
  err="$LOGFILES/rsync.${in_dir//\//%}_to_${out_dir//\//%}.$date_current.err"
  printf 'Synchronising "%s" to "%s" ...' "$in_dir" "$out_dir"
  if [[ -e "$log" || -e "$err" ]] ; then
    time_current=$(date +%H%M%S)
    log="${log%.log}.$time_current.log"
    err="${err%.err}.$time_current.err"
  fi
  rsync -av "$in_dir" "$out_dir" > "$log" 2> "$err"
  printf ' Done.\n'
}

