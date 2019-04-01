#! /bin/bash

# Configure:
mail_cmd="mail"
myjobinfo="./myjobinfo_slurm.sh"

####
# The following information is taken from 
# https://github.com/SchedMD/slurm/blob/master/contribs/seff/smail
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

command -v "$mail_cmd" &> /dev/null || { echo "Command not found: $mail_cmd. Please reconfigure." ; exit 1 ; }
command -v "$myjobinfo" &> /dev/null || { echo "Command not found: $myjobinfo. Please reconfigure." ; exit 1 ; }

IFS="," read -r -a array <<< "$2"

# Get the ClusterName
ClusterName=${SLURM_CLUSTER_NAME}
subject="$ClusterName $2"
recipient="${3:-$USER}"

pattern="[Jj][Oo][Bb]_?[Ii][Dd]=([[:digit:]]+)"

if [[ "${array[0]}" =~ $pattern ]] ; then
  { # Send to the back
    $myjobinfo "${BASH_REMATCH[1]}" | $mail_cmd -s "$subject" "$recipient"
  } &
else
  echo "Interactive mail '$subject' to '$recipient'."
  $mail_cmd -s "$subject" "$recipient"
fi

# rwth-tools
# ___version___: 2019-04-01-2152

