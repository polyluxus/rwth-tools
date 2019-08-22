#!/bin/bash
#
# This is a very, very, very simple CLI to the EMSL Basis Set Exchange
# Only use it, if you know what you are doing, or like to live dangerously.
#
# This script is basically a frontend (to grep) to the database 
# that was created with make-db.bash (probably in ./bse.db)
#
# ___version___: 2019-08-22-1746

database_loc="$(bash make-db.bash)"
[[ -z $1 ]] && { echo "$database_loc" ; exit 0 ; }

get_bs_index ()
{
  local parseline="$1"
  local index
  local pattern
  pattern='^[^\[]+\[([[:digit:]]+)\].*$'
  [[ "$parseline" =~ $pattern ]] && index="${BASH_REMATCH[1]}"
  echo "$index"

}

get_bs_index_list_all ()
{
  local line
  while read -r line || [[ -n $line ]] ; do
    get_bs_index "$line"
  done < <(grep --ignore-case "$1" "$database_loc")
}

get_bs_index_list_unique ()
{ 
  get_bs_index_list_all "$1" | uniq
}

[[ -e "$database_loc" ]] || { echo "No DB!" ; exit 1 ; }
. "$database_loc"
while read -r line || [[ -n $line ]] ; do
  printf '%10s: %s\n' "$line" "${name[$line]}"
done < <(get_bs_index_list_unique "$@")

