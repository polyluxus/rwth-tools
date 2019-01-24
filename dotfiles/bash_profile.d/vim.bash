#!/bin/bash
#___version___: 2019-01-24-1428
#
# No bash, no alias
[[ -z $BASH ]] && return 0
if (( ${#BASH_SOURCE[*]} == 1 )) ; then
  echo "This script is only meant to be sourced."
  exit 0
fi
#
# Alias vi to vim (if it does not exist)
if command -v vim &> /dev/null ; then
  alias vi &> /dev/null || alias vi='vim'
fi
#

