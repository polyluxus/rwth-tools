#!/bin/bash
#shellcheck disable=SC2059

# ___version___: 2019-09-17-1200

if [[ "$1" == "-h" ]] ; then
  echo "This script tests whether a set of modules can be loaded."
  echo "Usage: ${0##*/} [file.list], "
  echo "       where 'file.list' contains one module per line."
  shift
fi

# Prerequisite on RWTH RZ Cluster
module load CHEMISTRY

declare -a testing
if [[ -z "$1" ]] || [[ ! -r "$1" ]] ; then
  echo "Testing for a standard set of Gaussian modules."
  echo "These are not all available on the RWTH RZ cluster."
  testing+=('gaussian')
  testing+=('gaussian/03')
  testing+=('gaussian/09')
  testing+=('gaussian/16')
  testing+=('gaussview')
else
  mapfile -t testing < "$1"
fi

logfile="module.testload.$(date +%s).log"
tmpfile=$(mktemp "${logfile%.log}.XXXXXXXX.tmplog")

exec 3> "$logfile"
exec 4> "$tmpfile"

format="%10s | %s\\n"
printf "$format" "LOAD" "MODULE" >&4
for i in "${testing[@]}" ; do
  # load in subshell (no need tu unload)
  # sed command trims color codes: 
  # https://www.commandlinefu.com/commands/view/12043/remove-color-special-escape-ansi-codes-from-text-with-sed
  load_output=$(module load "$i" 2>&1 | sed 's,\x1B\[[0-9;]*[a-zA-Z],,g')
  printf '=== %-20s ===\n' "$i" >&3
  printf '%s\n' "$load_output" >&3
  if [[ $load_output =~ [Oo][Kk] ]] ; then
    printf "$format" "OK" "$i" >&4
  else
    printf "$format" "FAIL" "$i" >&4
  fi
done
exec 4>&-

printf '\n\n=== %-20s ===\n\n' "Summary" >&3
cat "$tmpfile" >&3 
exec 3>&-
cat "$tmpfile"
[[ -e "$tmpfile" ]] && rm "$tmpfile" 

