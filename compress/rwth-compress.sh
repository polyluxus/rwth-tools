#!/bin/env bash

usage ()
{
  local scriptname="${0##*/}"
  {
    echo "USAGE: $scriptname [opt] <target_(base)_filename> <source_directory>"
    echo "INFO:  $scriptname will write a bash script to be submitted to a scheduler."
    echo "MODUS: The script tries to guess from the extension which action to use;"
    echo "       where it will default to first create a tar archive and use zstd to compress it."
    echo "       (Currently supported: .tgz, .tar.gz, .tar.gzip, .tar.zstd [default]; WIP: .zip, .7z)"
    echo "OPTION:"
    echo "  -q <ARG>    Use <ARG> as queueing system."
    echo "              (Currently supported: slurm [default], busb)"
    echo "  -k          Keep submission script."
    echo "       [ ___version___: 2019-02-18-1908 ]"
  } >&2
  exit 0
}

fatal ()
{
  echo "ERROR: $*" >&2
  exit 1
}

debug ()
{ 
  local line
  while read -r line || [[ -n $line ]] ; do
    echo "INFO:  $line" >&2
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

OPTIND=1
queue="slurm"
clean_script="delete"

while getopts :q:kh options ; do
  case $options in
    q)
      queue="$OPTARG"
      debug "Selected queue: $queue"
      if [[ ! "$queue" =~ ([Bb][Ss][Uu][Bb]|[Ss][Ll][Uu][Rr][Mm]) ]] ; then
        fatal "Invalid argument for option -q: $queue"
      fi
      ;;
    k)
      clean_script="keep"
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
    ;;
  *.[Gg][Zz][Ii][Pp] | *.[Gg][Zz] | *.[Zz] )
    target_base_filename="${1%.*}"
    if [[ $target_base_filename =~ [Tt][Aa][Rr]$ ]] ; then
      target_tar_filename=$(is_readable_file "$target_base_filename") && fatal "File exists ($target_tar_filename)."
      target_base_filename="${target_tar_filename%.*}"
      execution_mode=tgz
    fi
    target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
    execution_mode=gzip
    ;;
  *.[Zz][Ii][Pp] )
    fatal "Not yet implemented."
    target_base_filename="${1%.*}"
    execution_mode=zip
    ;;
  *.[Zz][Ss][Tt][Dd] )
    target_base_filename="${1%.*}"
    if [[ $target_base_filename =~ [Tt][Aa][Rr]$ ]] ; then
      target_tar_filename=$(is_readable_file "$target_base_filename") && fatal "File exists ($target_tar_filename)."
      target_base_filename="${target_tar_filename%.*}"
    fi
    target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
    execution_mode=zstd
    ;;
  *.7[Zz] )
    fatal "Not yet implemented."
    target_base_filename="${1%.*}"
    execution_mode=seven
    ;;
  *.[Tt][Aa][Rr].[Zz][Ss][Tt][Dd] )
    target_base_filename="${1%.*.*}"
    target_tar_filename=$(is_readable_file "${1%.*}") && fatal "File exists ($target_tar_filename)."
    target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
    execution_mode=zstd
    ;;
  *.[Tt][Aa][Rr].[Gg][Zz] | *.[Tt][Aa][Rr].[Gg][Zz][Ii][Pp] )
    target_base_filename="${1%.*.*}"
    target_tar_filename=$(is_readable_file "${1%.*}") && fatal "File exists ($target_tar_filename)."
    target_zip_filename=$(is_readable_file "$1") && fatal "File exists ($target_zip_filename)."
    execution_mode=tgz
    ;;
  *.[Tt][Aa][Rr] )
    target_base_filename="${1%.*}"
    target_tar_filename=$(is_readable_file "$1") && fatal "File exists ($target_tar_filename)."
    execution_mode=zstd
    ;;
  *)
    target_base_filename="$1"
    execution_mode=zstd
esac

# Checks for commands

case "$execution_mode" in
  default | zstd )
    tar_cmd=$(command -v tar) || fatal "Comand not found (tar)."
    # Additional checks for filenames
    if [[ -z $target_tar_filename ]] ; then
      target_tar_filename=$(is_readable_file "$target_base_filename.tar") && fatal "File exists ($target_tar_filename)."
    fi
    zstd_cmd=$(command -v zstd) || fatal "Comand not found (zstd)."
    if [[ -z $target_zip_filename ]] ; then
      target_zip_filename=$(is_readable_file "$target_tar_filename.zstd") && fatal "File exists ($target_zip_filename)."
    fi
    ;;
  tgz)
    tar_cmd=$(command -v tar) || fatal "Comand not found (tar)."
    # Will not be performed with separate steps.
    # gzip_cmd=$(command -v gzip) || fatal "Comand not found (gzip)."
    if [[ -z $target_zip_filename ]] ; then
      target_zip_filename=$(is_readable_file "$target_base_filename.tgz") && fatal "File exists ($target_zip_filename)."
    fi
    ;;
  gzip)
    # not fully implemented
    gzip_cmd=$(command -v gzip) || fatal "Comand not found (gzip)."
    ;;
  seven)
    # not fully implemented
    seven_cmd=$(command -v 7z) || fatal "Comand not found (7z)."
    ;;
  zip)
    # not fully implemented
    zip_cmd=$(command -v zip) || fatal "Comand not found (zip)."
    ;;
  *)
    fatal "Unrecognised execution mode"
    ;;
esac

source_directory=$(is_readable_directory "$2") || fatal "Directory does not exist ($2)."
usename="${source_directory//\//%}"

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
  # It is necessary to implement the constraints for the CLAIX18 because of the sometimes failing hpcwork
  for check_hpc in "$source_directory" "$target_tar_filename" "$target_zip_filename" ; do
    [[ ${check_hpc%%/*/} =~ hpc ]] || continue
    debug "Detected usage of HPCWORK."
    echo "#SBATCH --constraint=hpcwork" >> "$submitfile"
    echo '' >> "$submitfile"
    break
  done
  queue_cmd=$(command -v sbatch) || fatal "Comand not found (sbatch)."
else
  fatal "Invalid queue: $queue"
fi

if [[ "$execution_mode" == "tgz" ]] ; then
  echo "'$tar_cmd'  -v -czf '$target_zip_filename' '$source_directory'    2>&1 || exit 65"  >> "$submitfile"
else
  [[ -n $tar_cmd ]]   && echo "'$tar_cmd'  -v -cf  '$target_tar_filename'    '$source_directory'    2>&1 || exit 63"  >> "$submitfile"
  [[ -n $zstd_cmd ]]  && echo "'$zstd_cmd' -v -9   '$target_tar_filename' -o '$target_zip_filename' 2>&1 || exit 127" >> "$submitfile"
  [[ -n $gzip_cmd ]]  && echo "'$gzip_cmd' -v -9 < '$target_tar_filename' >  '$target_zip_filename' 2>&1 || exit 127" >> "$submitfile"
  [[ -n $seven_cmd ]] && echo "'$seven_cmd' a -bb3 '$target_zip_filename'    '$target_tar_filename' 2>&1 || exit 127" >> "$submitfile"
  [[ -n $zip_cmd ]]   && echo "'$zip_cmd'     -9   '$target_zip_filename'    '$target_tar_filename' 2>&1 || exit 127" >> "$submitfile"
fi

debug "Content:"
debug "$(cat "$submitfile")"
echo 

case "${queue_cmd##*/}" in
  sbatch)
    debug "$( "$queue_cmd" "$submitfile" )"
    ;;
  bsub)
    debug "$( "$queue_cmd" < "$submitfile" )"
    ;; 
  *)
    fatal "Not recognised command: ${queue_cmd##*/}."
    ;;
esac

if [[ $clean_script == "delete" ]] ; then
  debug "$(rm -v "$submitfile")"
elif [[ $clean_script == "keep" ]] ; then
  debug "Submission script '$submitfile' kept."
else
  warning "Unknown cleanup mode."
fi

