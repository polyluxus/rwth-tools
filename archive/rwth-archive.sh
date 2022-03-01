#!/bin/env bash

###
#
# rwth-archive.sh -- 
#   a script to submit a archiving job to the slurm queuing system
# Copyright (C) 2022 Ole Osterthun 
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

usage ()
{
  local scriptname="${0##*/}"
  {
    echo "USAGE:      $scriptname [opt] <target_directory>"
    echo "INFO:       $scriptname will write a bash script to be submitted to a scheduler."
    echo "MODUS:      The script will traverse through <target_directory> and convert *.chk files"
    echo "            to formatted checkpoint files (*.fchk). It will then delete the original."
    echo "OPTIONS:"
    #echo "  -u        Strip user level from source directory."
    #echo "            Try to change to user level directory before archive creation."
    echo "  -q <ARG>  Use <ARG> as queueing system."
    echo "            (Currently supported: slurm [default], busb)"
    echo "  -A <ARG>  Account to use."
    echo "  -j <ARG>  Wait for JobID <ARG>."
    echo "            Can be specified multiple times. Only available for SLURM."
    echo "  -k        Keep submission script."
    echo "  -n        Do not submit (dry run)."
    echo "  -D        Debug mode with (much) more information."
    echo "LICENSE:    rwth-archive.sh  Copyright (C) 2022 Ole Osterthun"
    echo "            This program comes with ABSOLUTELY NO WARRANTY; this is free software,"
    echo "            and you are welcome to redistribute it under certain conditions;"
    echo "            please see the license file distributed alongside this repository,"
    echo "            which is available when you type '${0##*/} license',"
    echo "            or at <https://github.com/O2-AC/rwth-tools>."
    echo "INFO:       [ ___version___: 2022-02-24-1200 ]"
  } >&2
  exit 0
}

fatal ()
{
  echo "ERROR: $*" >&2
  exit 1
}

message ()
{
  local line
  while read -r line || [[ -n $line ]] ; do
    echo "INFO:  $line" >&2
  done <<< "$*"
}

debug ()
{ 
  [[ "$debug_mode" == "true" ]] || return
  local line
  while read -r line || [[ -n $line ]] ; do
    echo "DEBUG:  $line" >&2
  done <<< "$*"
}

is_file ()
{
    [[ -f $1 ]]
}

is_directory ()
{
    [[ -d $1 ]]
}

is_readable ()
{
    [[ -r $1 ]]
}

is_readable_file ()
{
  local status=0
  is_file "$1"     || status=1
  is_readable "$1" || status=1
  echo "$(cd "$(dirname "$1")" || return 2; pwd)/$(basename "$1")" 
  return $status
}

is_readable_directory ()
{
  local status=0
  is_directory "$1" || status=1
  is_readable "$1"  || status=1
  echo "$(cd "$(dirname "$1")" || return 2; pwd)/$(basename "$1")" 
  return $status
}

if [[ ! "$HOSTNAME" =~ [Rr][Ww][Tt][Hh] ]] ; then
  : # We're not on a RWTH server, issue a warning.
  debug "This script is designed for the RWTH cluster environment."
  debug "It might not work on $HOSTNAME."
fi

if [[ "$1" =~ ^[Ll][Ii][Cc][Ee][Nn][Ss][Ee]$ ]] ; then
  command -v curl &> /dev/null || fatal "Command 'curl' not found, but it is necessary to obtain the license."
  if command -v less &> /dev/null ; then
    curl --silent https://raw.githubusercontent.com/polyluxus/rwth-tools/master/LICENSE | less
  else
    curl --silent https://raw.githubusercontent.com/polyluxus/rwth-tools/master/LICENSE
  fi
  message "Displayed license and will exit."
  exit 0
fi

OPTIND=1
queue="slurm"
debug_mode="false"
clean_script="delete"
account="default"
submit="true"

while getopts :uq:A:j:knDh options ; do
  case $options in
    q)
      queue="$OPTARG"
      debug "Selected queue: $queue"
      if [[ ! "$queue" =~ ([Bb][Ss][Uu][Bb]|[Ss][Ll][Uu][Rr][Mm]) ]] ; then
        fatal "Invalid argument for option -q: $queue"
      fi
      ;;
    A)
      account="$OPTARG"
      ;;
    j)
      dependency+=":$OPTARG"
      ;;
    k)
      clean_script="keep"
      ;;
    D)
      debug_mode="true"
      ;;
    n)
      submit="false"
      ;;
    h)
      usage
      ;;
    :)
      fatal "Option -$OPTARG requires an argument."
      ;;
    \?)
      fatal "Invalid option: -$OPTARG."
  esac
done

shift $(( OPTIND - 1 ))

# Check wehther there is something to do or not.
(( $# < 1 )) && usage

# Set default mode
execution_mode=default

# Check the files

if target_directory=$(is_readable_directory "$1") ; then
  debug "Found readable directory ($target_directory)."
else
  fatal "Directory or file does not exist ($1)."
fi
usename="${target_directory//\//%}"

# Checks for commands

module load CHEMISTRY
module load gaussian/16.b01_bin

formchk_cmd=$(command -v formchk) || fatal "Comand not found (formchk)."

module unload gaussian/16.b01_bin

# Make a temporary submission script
submitfile=$(mktemp archive.XXXX.sh)
debug "create '$submitfile'"

# Check where to write log files
logdir="$LOGFILES"
[[ -z $logdir && -d "$HOME/logfiles" ]] && logdir="$HOME/logfiles" 
[[ -z $HOME ]] && fatal "No home directory set. abort."
[[ -z $logdir ]] && logdir="$HOME"
debug "Logfile will be written to '$logdir'."

# Write the script
if [[ $queue =~ ([Bb][Ss][Uu][Bb]) ]] ; then
	cat > "$submitfile" <<-END-of-header
	#!/usr/bin/env bash
	#BSUB -n 1
	#BSUB -a openmp
	#BSUB -M 2000
	#BSUB -W 6:00
	#BSUB -N 
	#BSUB -J archive.${usename}
	#BSUB -o ${logdir}/archive.${usename}.o%J
	#BSUB -e ${logdir}/archive.${usename}.e%J
	END-of-header
  for check_hpc in "$target_directory" ; do
    [[ ${check_hpc%%/*/} =~ hpc ]] || continue
    debug "Detected usage of HPCWORK."
    echo "#BSUB -R select[hpcwork]" >> "$submitfile"
    echo '' >> "$submitfile"
    break
  done
  if [[ "$account" =~ ^[Dd][Ee][Ff][Aa][Uu][Ll][Tt]$ ]] ; then
    debug "No account selected."
  else
    echo "#BSUB -P $account" >> "$submitfile"
  fi
  echo "" >> "$submitfile"
  queue_cmd=$(command -v bsub) || fatal "Comand not found (bsub)."
elif [[ $queue =~ ([Ss][Ll][Uu][Rr][Mm]) ]] ; then
	cat > "$submitfile" <<-END-of-header
	#!/usr/bin/env bash
	#SBATCH --nodes=1
	#SBATCH --ntasks=1
	#SBATCH --cpus-per-task=1
	#SBATCH --mem-per-cpu=2000
	#SBATCH --time="6:00:00"
	#SBATCH --mail-type=END,FAIL
	#SBATCH --job-name="archive.${usename}"
	#SBATCH --output='${logdir}/archive.${usename}.o%J'
	#SBATCH --error='${logdir}/archive.${usename}.e%J'
	END-of-header
  if [[ -n "$dependency" ]] ; then
    # Dependency is stored in the form ':jobid:jobid:jobid'
    # which should be recognised by SLURM 
    echo "#SBATCH --depend=afterok$dependency" >&9
  fi
  # It is necessary to implement the constraints for the CLAIX18 because of the sometimes failing hpcwork
  for check_hpc in "$target_directory" ; do
    [[ ${check_hpc%%/*/} =~ hpc ]] || continue
    debug "Detected usage of HPCWORK."
    echo "#SBATCH --constraint=hpcwork" >> "$submitfile"
    echo '' >> "$submitfile"
    break
  done
  if [[ "$account" =~ ^[Dd][Ee][Ff][Aa][Uu][Ll][Tt]$ ]] ; then
    debug "No account selected."
  else
    echo "#SBATCH --account=$account" >> "$submitfile"
  fi
  echo "" >> "$submitfile"
  queue_cmd=$(command -v sbatch) || fatal "Comand not found (sbatch)."
else
  fatal "Invalid queue: $queue"
fi

echo "module load CHEMISTRY gaussian/16.b01_bin 2>&1" >> "$submitfile"
echo "find '$target_directory' -name *.chk -type f -execdir echo "Found {}" \; -execdir '$formchk_cmd' {} \; -execdir rm {} \; || exit 1"  >> "$submitfile"

debug "Content:"
debug "$(cat "$submitfile")"
debug "" 

if [[ $submit == "false" ]] ; then
  message "Job not submitted per user request."
else
  case "${queue_cmd##*/}" in
    sbatch)
      message "$( "$queue_cmd" "$submitfile" )"
      ;;
    bsub)
      message "$( "$queue_cmd" < "$submitfile" )"
      ;; 
    *)
      fatal "Not recognised command: ${queue_cmd##*/}."
      ;;
  esac
fi

if [[ $clean_script == "delete" ]] ; then
  debug "$(rm -v "$submitfile")"
elif [[ $clean_script == "keep" ]] ; then
  message "Submission script '$submitfile' kept."
else
  warning "Unknown cleanup mode."
fi

