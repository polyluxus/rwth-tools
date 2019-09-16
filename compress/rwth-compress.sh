#!/bin/env bash

###
#
# rwth-compress.sh -- 
#   a script to submit a archiving job to the slurm queuing system
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

usage ()
{
  local scriptname="${0##*/}"
  {
    echo "USAGE:      $scriptname [opt] <target_(base)_filename> <source_directory>"
    echo "INFO:       $scriptname will write a bash script to be submitted to a scheduler."
    echo "MODUS:      The script tries to guess from the extension which action to use;"
    echo "            where it will default to first create a tar archive and use zstd to compress it."
    echo "            (Currently supported: .tgz, .tar.gz, .tar.gzip, .tar.zstd [default]; WIP: .zip, .7z)"
    echo "            (Experimental: .tar, .gz, .gzip, .z, .zstd )"
    echo "            The batch file is written in a way, that it will exit on error to give you "
    echo "            the opportunity to check the logfiles."
    echo "OPTIONS:"
    echo "  -u        Strip user level from source directory."
    echo "            Try to change to user level directory before archive creation."
    echo "  -q <ARG>  Use <ARG> as queueing system."
    echo "            (Currently supported: slurm [default], busb)"
    echo "  -A <ARG>  Account to use."
    echo "  -j <ARG>  Wait for JobID <ARG>."
    echo "            Can be specified multiple times. Only available for SLURM."
    echo "  -k        Keep submission script."
    echo "  -n        Do not submit (dry run)."
    echo "  -D        Debug mode with (much) more information."
    echo "LICENSE:    rwth-compress.sh  Copyright (C) 2019  Martin C Schwarzer"
    echo "            This program comes with ABSOLUTELY NO WARRANTY; this is free software,"
    echo "            and you are welcome to redistribute it under certain conditions;"
    echo "            please see the license file distributed alongside this repository,"
    echo "            which is available when you type '${0##*/} license',"
    echo "            or at <https://github.com/polyluxus/rwth-tools>."
    echo "INFO:       [ ___version___: 2019-09-16-1708 ]"
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
strip_user_level="false"
account="default"
submit="true"

while getopts :uq:A:j:knDh options ; do
  case $options in
    u)
      strip_user_level="true"
      ;;
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
(( $# < 2 )) && usage

# Set default mode
execution_mode=default

case $1 in
  *.[Tt][Gg][Zz] )
    target_base_filename="${1%.*}" 
    target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
    execution_mode=tgz
    debug "Will run in $execution_mode mode."
    ;;
  *.[Gg][Zz][Ii][Pp] | *.[Gg][Zz] | *.[Zz] )
    target_base_filename="${1%.*}"
    if [[ $target_base_filename =~ [Tt][Aa][Rr]$ ]] ; then
      target_tar_filename=$(is_readable_file "$target_base_filename") && fatal "File exists ($target_tar_filename)."
      target_base_filename="${target_tar_filename%.*}"
      execution_mode=targzip
    else
      target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
      execution_mode=gzip
    fi
    debug "Will run in $execution_mode mode."
    ;;
  *.[Zz][Ii][Pp] )
    fatal "Not yet implemented."
    target_base_filename="${1%.*}"
    execution_mode=zip
    debug "Will run in $execution_mode mode."
    ;;
  *.[Zz][Ss][Tt][Dd]? )
    target_base_filename="${1%.*}"
    if [[ $target_base_filename =~ [Tt][Aa][Rr]$ ]] ; then
      target_tar_filename=$(is_readable_file "$target_base_filename") && fatal "File exists ($target_tar_filename)."
      target_base_filename="${target_tar_filename%.*}"
    else
      target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
      execution_mode=zstd
    fi
    debug "Will run in $execution_mode mode."
    ;;
  *.7[Zz] )
    fatal "Not yet implemented."
    target_base_filename="${1%.*}"
    execution_mode=seven
    debug "Will run in $execution_mode mode."
    ;;
  *.[Tt][Aa][Rr].[Zz][Ss][Tt][Dd]? )
    target_base_filename="${1%.*.*}"
    target_tar_filename=$(is_readable_file "${1%.*}") && fatal "File exists ($target_tar_filename)."
    target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
    execution_mode=zstd
    debug "Will run in $execution_mode mode."
    ;;
  *.[Tt][Aa][Rr].[Gg][Zz] | *.[Tt][Aa][Rr].[Gg][Zz][Ii][Pp] )
    target_base_filename="${1%.*.*}"
    target_tar_filename=$(is_readable_file "${1%.*}") && fatal "File exists ($target_tar_filename)."
    target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
    execution_mode=tgz
    debug "Will run in $execution_mode mode."
    ;;
  *.[Tt][Aa][Rr] )
    target_base_filename="${1%.*}"
    target_tar_filename=$(is_readable_file "$1") && fatal "File exists ($target_tar_filename)."
    execution_mode=tar
    debug "Will run in $execution_mode mode."
    ;;
  *)
    target_base_filename="$1"
    execution_mode=zstd
    debug "Will run in $execution_mode mode."
esac

# Check the files

if source_directory=$(is_readable_directory "$2") ; then
  debug "Found readable directory ($source_directory)."
elif source_tar_filename=$(is_readable_file "$2") ; then
  debug "Found readable file, skipping tar."
  unset source_directory
  debug "source_directory='$source_directory'; source_tar_filename='$source_tar_filename'"
  if [[ "$execution_mode" == tgz ]] || [[ "$execution_mode" == targzip ]] ; then 
    execution_mode=gzip
    debug "Resetting to $execution_mode mode."
    [[ -n $target_zip_filename ]] && target_zip_filename="${target_zip_filename%.*}.gz"
    debug "Target file name: '$target_zip_filename'."
  fi
else
  fatal "Directory or file does not exist ($2)."
fi
usename="${source_directory//\//%}"

# Checks for commands

case "$execution_mode" in
  default | tar )
    tar_cmd=$(command -v tar) || fatal "Comand not found (tar)."
    # Additional checks for filenames
    if [[ -z $target_tar_filename ]] ; then
      target_tar_filename=$(is_readable_file "${target_base_filename}.tar") && fatal "File exists ($target_tar_filename)."
    fi
    ;;&
  default | zstd )
    zstd_cmd=$(command -v zstd) || fatal "Comand not found (zstd)."
    if [[ -z $target_zip_filename ]] ; then
      target_zip_filename=$(is_readable_file "${target_tar_filename:-$source_tar_filename}.zst") && fatal "File exists ($target_zip_filename)."
    fi
    ;;
  tgz | targzip )
    tar_cmd=$(command -v tar) || fatal "Comand not found (tar)."
    # Will not be performed with separate steps.
    # gzip_cmd=$(command -v gzip) || fatal "Comand not found (gzip)."
    if [[ -z $target_zip_filename ]] ; then
      target_zip_filename=$(is_readable_file "${target_base_filename}.tgz") && fatal "File exists ($target_zip_filename)."
    fi
    ;;
  gzip )
    # not fully implemented
    gzip_cmd=$(command -v gzip) || fatal "Comand not found (gzip)."
    if [[ -z $target_zip_filename ]] ; then
      target_zip_filename=$(is_readable_file "${target_tar_filename:-$source_tar_filename}.zst") && fatal "File exists ($target_zip_filename)."
    fi
    debug '----------------------'
    ;;
  seven )
    # not fully implemented
    seven_cmd=$(command -v 7z) || fatal "Comand not found (7z)."
    if [[ -z $target_zip_filename ]] ; then
      target_zip_filename=$(is_readable_file "${target_tar_filename:-$source_tar_filename}.zst") && fatal "File exists ($target_zip_filename)."
    fi
    ;;
  zip )
    # not fully implemented
    zip_cmd=$(command -v zip) || fatal "Comand not found (zip)."
    if [[ -z $target_zip_filename ]] ; then
      target_zip_filename=$(is_readable_file "${target_tar_filename:-$source_tar_filename}.zst") && fatal "File exists ($target_zip_filename)."
    fi
    ;;
  default | tar | zstd | tgz | targzip | gzip | seven | zip )
    # Fallthrough catch (for tar)
    debug "Will run in $execution_mode mode."
    ;;
  *)
    fatal "Unrecognised execution mode"
    ;;
esac

if [[ "$strip_user_level" == "true" ]] ; then
  strip_user_directory_base="${source_directory%%/${USER}*}"
  if [[ "$strip_user_directory_base" == "$source_directory" ]] ; then
    message "Atempt to strip user directory (of $USER) failed;"
    message "pattern not found in '$source_directory'."
    unset strip_user_directory
    strip_user_level=false
  else
    strip_user_directory="${strip_user_directory_base}/$USER"
    cleaned_source_directory="${source_directory##$strip_user_directory/}"
    debug "Stripping '$strip_user_level'."
    debug "Source is now: $cleaned_source_directory"
  fi
else
  debug "Not stripping user level directory."
fi

# debug "$tar_cmd -cf '$target_tar_filename' '$source_directory'"
# debug "$zstd_cmd -v -9 '$target_tar_filename' -o '$target_zip_filename'"

# Make a temporary submission script
submitfile=$(mktemp compress.XXXX.sh)
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
	#BSUB -J compress.${usename}
	#BSUB -o ${logdir}/compress.${usename}.o%J
	#BSUB -e ${logdir}/compress.${usename}.e%J
	END-of-header
  for check_hpc in "$source_directory" "$target_tar_filename" "$target_zip_filename" ; do
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
	#SBATCH --job-name="compress.${usename}"
	#SBATCH --output='${logdir}/compress.${usename}.o%J'
	#SBATCH --error='${logdir}/compress.${usename}.e%J'
	END-of-header
  if [[ -n "$dependency" ]] ; then
    # Dependency is stored in the form ':jobid:jobid:jobid'
    # which should be recognised by SLURM 
    echo "#SBATCH --depend=afterok$dependency" >&9
  fi
  # It is necessary to implement the constraints for the CLAIX18 because of the sometimes failing hpcwork
  for check_hpc in "$source_directory" "$target_tar_filename" "$target_zip_filename" ; do
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

if [[ "$execution_mode" == "tgz" ]] ; then
  if [[ "$strip_user_level" == "true" ]] ; then
    echo "'$tar_cmd' -v -czf '$target_zip_filename' -C '$strip_user_directory' '$cleaned_source_directory' || exit 65"  >> "$submitfile"
  else
    echo "'$tar_cmd' -v -czf '$target_zip_filename' '$source_directory' || exit 66"  >> "$submitfile"
  fi
else
  if [[ "$strip_user_level" == "true" ]] ; then
    [[ -n $tar_cmd ]] && echo "'$tar_cmd'  -v -cf  '$target_tar_filename' -C '$strip_user_directory' '$cleaned_source_directory' || exit 62"  >> "$submitfile"
  else
    [[ -n $tar_cmd ]] && echo "'$tar_cmd'  -v -cf  '$target_tar_filename'    '$source_directory'     || exit 63"  >> "$submitfile"
  fi
  target_tar_filename="${target_tar_filename:-$source_tar_filename}"
  [[ -n $zstd_cmd ]]  && echo "'$zstd_cmd' -v -9   '$target_tar_filename' -o '$target_zip_filename'  || exit 127" >> "$submitfile"
  [[ -n $gzip_cmd ]]  && echo "'$gzip_cmd' -v -9 < '$target_tar_filename' >  '$target_zip_filename'  || exit 127" >> "$submitfile"
  [[ -n $seven_cmd ]] && echo "'$seven_cmd' a -bb3 '$target_zip_filename'    '$target_tar_filename'  || exit 127" >> "$submitfile"
  [[ -n $zip_cmd ]]   && echo "'$zip_cmd'     -9   '$target_zip_filename'    '$target_tar_filename'  || exit 127" >> "$submitfile"
fi

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

