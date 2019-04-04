#!/bin/bash
#___version___: 2019-04-04-1847

if (( ${#BASH_SOURCE[*]} == 1 )) ; then
  echo "This script is only meant to be sourced."
  exit 0
fi

# Check if tldr is installed
# add it to bash completition
if command -v tldr &> /dev/null ; then
  complete -W "$(tldr 2>/dev/null --list)" tldr
fi
#

