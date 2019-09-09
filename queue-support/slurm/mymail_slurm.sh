#!/bin/bash

#hlp This script interfaces to a job info script (e.g. the myjobinfo_slurm.sh of this repository)
#hlp and sends an email with this content via the specified emailer.
#hlp 
#hlp Usage:
#hlp   ${0##*/} [option(s)] 
#hlp

#hlp Configuration files:
#hlp   '/etc/myslurm.rc'          (loaded first)
#hlp   '$HOME/.myslurmrc' 
#hlp   '$HOME/.config/myslurm.rc' (loaded last, i.e. superior)
#hlp

# Source a global configuration
#shellcheck source=myslurm.rc
[[ -r "/etc/myslurm.rc" ]] && . "/etc/myslurm.rc"
#shellcheck source=myslurm.rc
[[ -r "$HOME/.myslurmrc" ]] && . "$HOME/.myslurmrc"
#shellcheck source=myslurm.rc
[[ -r "$HOME/.config/myslurm.rc" ]] && . "$HOME/.config/myslurm.rc"

# Configure:
mail_cmd="${mail_cmd:-mail}"
declare -a mail_cmd_opts
myjobinfo="${myjobinfo:-myjobinfo_slurm.sh}"
declare -a myjobinfo_opts
from_within="${from_within:-false}"

####
# The following information is taken from 
# https://github.com/SchedMD/slurm/blob/master/contribs/seff/smail
# and applies to the cases where it is used as 'MailProg' by slurm.
#
# Input should look like this for an end record:
# $1: '-s' (the subject argument keyword)
# $2: The subject itself
# $3: The To: email address.
#
# The subject should look like this for an start record:
# SLURM Job_id=323 Name=ddt_clone Began, Queued time 00:00:01
#
# The subject should look like this for an end record:
# SLURM Job_id=327 Name=ddt_clone Ended, Run time 00:05:01, COMPLETED, ExitCode 0
# SLURM Job_id=328 Name=ddt_clone Failed, Run time 00:05:01, FAILED, ExitCode 127
# SLURM Job_id=342 Name=ddt_clone Ended, Run time 00:00:33, CANCELLED, ExitCode 0
# Not sure what to do about PENDING state resulting from a requeue request.
# Doing a seff on it for now:
# SLURM Job_id=326 Name=ddt_clone Failed, Run time 00:00:41, PENDING, ExitCode 0
#
# These end records are the only types of messages to process. They have 4 (rather
# than 2) comma-delimited arguments, of which ending status is the 3rd.
# Just pass through notifications without an ending status.
####

# Implement some options:
OPTIND=1

while getopts :s:u:j:Ih options ; do
  #hlp Options:
  case $options in
    #hlp      -s <ARG>     Subject
    #hlp
    s)
      subject="$OPTARG"
      ;;

    #hlp      -u <ARG>     User/ Recipient (default $USER)
    #hlp
    u)
      recipient="$OPTARG"
      ;;

    #hlp      -j <ARG>     Job ID (specify directly, no need to parse the subject)
    #hlp
    j)
      jobid="$OPTARG"
      ;;

    #hlp      -I           Run from within the job script.
    #hlp                   Do not use it as interface 'MailProg' for the queueing system.
    #hlp
    I)
      from_within="true"
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
#hlp  ___version___: 2019-09-09-1805

shift $(( OPTIND - 1 ))

# Check if the commands are actually available
command -v "$mail_cmd" &> /dev/null || { echo "Command not found: $mail_cmd. Please reconfigure." >&2 ; exit 1 ; }
command -v "$myjobinfo" &> /dev/null || { echo "Command not found: $myjobinfo. Please reconfigure." >&2 ; exit 1 ; }

# Get the ClusterName
ClusterName=${SLURM_CLUSTER_NAME}
# This only works if the script is called from within SLURM itself, 
# otherwise the environment variable will not be set.
# Ammend the subject with the cluster name
# (which actually only makes sense, if multiple clusters are in use by the same user)
subject="$ClusterName ${subject:-$jobid}"
# Specify the recipient; use current user if unset (to avoid errors)
# We have shifted enough so that $1 should now hold this
recipient="${recipient:-$1}"
# It is optional, so set to the current user now
recipient="${recipient:-$USER}"

# In cases where we would like to re-sort the subject line, read it into an array.
# This is 'implemented' for the cases of further developement.
# IFS="," read -r -a subject_array <<< "$subject"
# As this is not necessary, if we only want to extract the Job ID, 
# we can use the subject variable directly (safer),
# instead of relying on a specific ordering.

if [[ -z $jobid ]] ; then
  # Specify the pattern for the Job ID, which could be a mixed spelling, with underscore or without
  pattern="[Jj][Oo][Bb]_?[Ii][Dd]=([[:digit:]]+)"
  # Probably more robust would be to not rely on the equals sign, 
  # therefore something like the following should work alright, too:
  # pattern="[Jj][Oo][Bb]_?[Ii][Dd][^[:digit:]]*([[:digit:]]+)"
  
  if [[ "$subject" =~ $pattern ]] ; then
    jobid="${BASH_REMATCH[1]}"
  fi
fi

if [[ -z $jobid ]] ; then
  # If there is no Job ID (or it isn't recognised) pretend to just send an email.
  # Issue a control statement.
  echo "Interactive mail '$subject' to '$recipient'."
  $mail_cmd -s "$subject" "$recipient"
  exit
fi

if [[ "$from_within" == "true" ]] ; then
  # For the use as part of the job:
  # Get the information about the job and pipe to mail program
  $myjobinfo "${myjobinfo_opts[@]}" -- "$jobid" | $mail_cmd "${mail_cmd_opts[@]}" -s "$subject" "$recipient"
  # Send control statement
  echo "Sent email '$subject' to '$recipient'."
  exit 0
fi

# For the use as mail sender by SLURM (as setting MailProg='')
# Spawn a new process, send to the back, let database update
{ # Spawn a sub-process to SLURM, this implements a delay to let the database update
  # send it into the background to complete the job.
  # (smail uses 60 seconds, but 30 should be way sufficient, too)
  sleep 30
  # Get the information about the job and pipe to mail program (like above)
  $myjobinfo "${myjobinfo_opts[@]}" -- "$jobid" | $mail_cmd "${mail_cmd_opts[@]}" -s "$subject" "$recipient"
} &


