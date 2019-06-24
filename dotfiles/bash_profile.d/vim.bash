#!/bin/bash
#___version___: 2019-06-24-1724
#
# No bash, no alias
[[ -z $BASH ]] && return 0
if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : #Everything is fine
else
  echo "This script is only meant to be sourced."
  exit 0
fi

#
# Alias vi to vim (if it does not exist)
if command -v vim &> /dev/null ; then
  alias vi &> /dev/null || alias vi='vim'
fi
#

