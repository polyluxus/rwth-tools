#!/bin/bash

scriptname="${0##*/}"

usage ()
{
  local line
  local pattern="^[[:space:]]*#hlp[[:space:]]?(.*)?$"
  while read -r line; do
    [[ "$line" =~ $pattern ]] && eval "echo \"${BASH_REMATCH[1]}\"" >&2
  done < <(grep "#hlp" "$0")
  exit 0
  #hlp USAGE:       $scriptname [options] <pysisyphus-yaml>
  #hlp INFO:        $scriptname will write a bash script to be submitted to a scheduler for remote execution of 'pysis'.
  #hlp              [ ___version___: 2019-05-16-1633 ]
  #hlp 
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
  [[ "$debug_mode" == "true" ]] || return 0
  local line
  while read -r line || [[ -n $line ]] ; do
    echo "DEBUG:  $line" >&2
  done <<< "$*"
}

#
# MAIN
#

if [[ ! "$HOSTNAME" =~ [Rr][Ww][Tt][Hh] ]] ; then
  : # We're not on a RWTH server, issue a warning.
  message "This script is designed for the RWTH cluster environment."
  message "It might not work on $HOSTNAME."
fi

# Defaults
OPTIND=1
queue="slurm"
submit="true"
requested_CPU=8
requested_memory=2000
requested_walltime=24
local_python_environment=""
use_modules=()

#shellcheck source=.pysis.subrc
[[ -e "$HOME/.pysis.subrc" ]] && . "$HOME/.pysis.subrc"
#shellcheck source=pysis.sub.rc
[[ -e "$HOME/.config/pysis.sub.rc" ]] && . "$HOME/.config/pysis.sub.rc"

while getopts :p:m:w:E:M:kA:Dh options ; do
  #hlp OPTIONS:
  case $options in
    p)
      #hlp   -p <ARG>   Processors
      requested_CPU="$OPTARG"
      ;;
    m)
      #hlp   -m <ARG>   Memory (MB) per processor
      requested_memory="$OPTARG"
      ;;
    w)
      #hlp   -w <ARG>   Walltime (hours)
      requested_walltime="$OPTARG"
      ;;
    E)
      #hlp   -E <ARG>   local python environment activation file 
      local_python_environment="$OPTARG"
      ;;
    M)
      #hlp   -M <ARG>   Modules to be loaded 
      use_modules+=( "OPTARG" )
      ;;
    k)
      #hlp   -k         Keep submission script, do not submit.
      submit="false"
      ;;
    A)
      #hlp   -A <ARG>   Specify account
      qsys_account="$OPTARG"
      ;;
    D)
      #hlp   -D         Debug mode.
      debug_mode=true
      ;;
    h)
      #hlp   -h         This help file.
      usage
      ;;
    :)
      fatal "Option -$OPTARG requires an argument."
      ;;
    \?)
      fatal "Invalid option: -$OPTARG."
  esac
  #hlp 
  #hlp SETTINGS:
  #hlp   queue="$queue"
  #hlp   submit="$submit"
  #hlp   requested_CPU=$requested_CPU
  #hlp   requested_memory=$requested_memory
  #hlp   requested_walltime=$requested_walltime
  #hlp   local_python_environment="$local_python_environment"
  #hlp   use_modules=( ${use_modules[*]} )
  #hlp   qsys_account="$qsys_account"
  #hlp 
done

shift $(( OPTIND - 1 ))

# Check wehther there is something to do or not.
(( $# < 1 )) && usage

input_yaml="$1"
shift
while [[ -n $1 ]] ; do
  message "Ignoring '$1'."
  shift
done
jobname="${input_yaml%.yaml}"
output_log="$jobname.log"
submitfile="$jobname.$queue.bash"
debug "create '$submitfile'"

cat > "$submitfile" <<-END-of-header
#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=$requested_CPU
#SBATCH --mem-per-cpu=$requested_memory
#SBATCH --time=$requested_walltime:00:00
#SBATCH --mail-type=END,FAIL
#SBATCH --job-name="$jobname"
#SBATCH --output='$PWD/${submitfile}.oe%J'

END-of-header
# It is necessary to implement the constraints for the CLAIX18 because of the sometimes failing hpcwork
if [[ ${PWD} =~ [Hh][Pp][Cc][Ww][Oo][Rr][Kk] ]] ; then
  debug "Detected usage of HPCWORK."
  echo "#SBATCH --constraint=hpcwork" >> "$submitfile"
  echo '' >> "$submitfile"
fi

if [[ "$qsys_account" =~ ^(|0|[Dd][Ee][Ff][Aa]?[Uu]?[Ll]?[Tt]?)$ ]] ; then
  message "No account selected."
else
  echo "#SBATCH --account='$qsys_account'" >> "$submitfile"
fi

# Create a temporary working directory,
# write cleanup routine and trap it (in case of killed calculation),
# then copy the existing content to this directory,
# and change to it.
cat >> "$submitfile" <<-END-of-dirs
# Create temporary working diretory
pysis_tmpdir="\$( mktemp --directory --tmpdir )"
# Emergency cleanup (only relevant if the script does not run through)
emergency_cleanup ()
{
  echo "Job was killed, copying back everything."
  mv -v -r -- "\$pysis_tmpdir" "${jobname}.slurm.scratch.\$SLURM_JOB_ID"
  exit 1 
}
trap emergency_cleanup SIGINT

# Copy all files to working directory
cp -v -- "$PWD"/* "\$pysis_tmpdir/" || exit 1
# Enter work directory
cd -- "\$pysis_tmpdir" || exit 1
pwd

END-of-dirs

if (( ${#use_modules[@]} > 0 )) ; then
  # Load modules
  # Export current module path to be sure
  echo "MODULEPATH='$MODULEPATH'" >> "$submitfile"
  for module in "${use_modules[@]}" ; do
    echo "module load '$module'" >> "$submitfile"
  done
else
  debug "No modules in use."
fi

if [[ -n $local_python_environment ]] ; then
  # Activate python environment
  # . ~/local/python/local_env/pysisiphus/bin/activate
  echo ". '$local_python_environment'" >> "$submitfile"
else
  debug "No local python environment set."
fi


# Then run pysisyphus.
# Then create an archive with all data.
# Then run the cleanup mode of pysisyphus.
cat >> "$submitfile" <<-END-of-body
# Run pysisyphus
echo "${wrapper:-srun} pysis '$input_yaml' > '$output_log'"
${wrapper:-srun} pysis '$input_yaml' > '$output_log'
exit_status=\$?

echo "Directory Contents:"
ls -lAh
echo ""

echo "Creating archive:"
# Create zipfile
if command -v tar ; then
  tar -vczf "$PWD/${jobname}.data.tgz" .
  cycle_files=( cycle*.trj )
  cp -v -- "\${cycle_files[-1]}" "$PWD"
  echo "Runing pysis --fclean"
  pysis --fclean
fi

# Move back everything relevant (no clobber to prevent overwriting original data)
echo "Moving remaining files (no clobbering)."
mv -nv -- * "$PWD/"
for file in * ; do 
  if cmp -s -- "\$file" "$PWD/\$file" ; then
    rm -v -- "\$file"
  else
    mv -v -- "\$file" "\$( mktemp --tmpdir="$PWD" "\${file}.back.XXXX" )"
  fi
done

echo "Done: \$(date)"
exit \$exit_status
END-of-body

message "Written '$submitfile'."
debug "$( cat "$submitfile" )"

if [[ "$submit" == "true" ]] ; then 
  queue_cmd=$(command -v sbatch) || fatal "Comand not found (sbatch)."
  message "$( "$queue_cmd" "$submitfile" )"
else
  message "Use 'sbatch $submitfile' to submit to $queue."
fi

message "$scriptname done."
