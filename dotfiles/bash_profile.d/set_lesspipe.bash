#!/bin/bash
# ___version___: 2019-04-16-1544

if (return 0 2>/dev/null) ; then
  # [How to detect if a script is being sourced](https://stackoverflow.com/a/28776166/3180795)
  : #Everything is fine
else
  echo "This script is only meant to be sourced."
  exit 0
fi

# Make less more friendly for non-text input files:
# requires lesspipe to be installed: https://github.com/wofr06/lesspipe
# I couldn't get the above to work properly, 
# so I'm falling back to the system default if installed.

# If the environment variable is already provided, don't overwrite it.
[[ -n $LESSOPEN ]] && return

if lesspipe_cmd=$(command -v lesspipe || command -v lesspipe.sh) ; then
  LESSOPEN="|${lesspipe_cmd} %s"
  export LESSOPEN
fi
unset lesspipe_cmd

