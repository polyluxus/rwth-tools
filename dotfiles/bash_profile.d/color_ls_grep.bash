#!/bin/bash
#___version___: 2019-04-16-1544

if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : #Everything is fine
else
  echo "This script is only meant to be sourced."
  exit 0
fi

# Enable color support of ls and grep
if command -v dircolors &> /dev/null ; then
  if [[ -r ~/.dircolors ]] ; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi
  alias ls    &> /dev/null || alias ls='ls --color=auto'
# alias dir   &> /dev/null || alias dir='dir --color=auto'
# alias vdir  &> /dev/null || alias vdir='vdir --color=auto'

  alias grep  &> /dev/null || alias grep='grep --color=auto'
  alias fgrep &> /dev/null || alias fgrep='fgrep --color=auto'
  alias egrep &> /dev/null || alias egrep='egrep --color=auto'
fi

