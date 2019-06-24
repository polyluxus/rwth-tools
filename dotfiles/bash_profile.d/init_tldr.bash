#!/bin/bash
#___version___: 2019-06-24-1724

if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : #Everything is fine
else
  echo "This script is only meant to be sourced."
  exit 0
fi

# Check if tldr is installed
# add it to bash completition
if command -v tldr &> /dev/null ; then
  complete -W "$(tldr 2>/dev/null --list)" tldr
fi
#

