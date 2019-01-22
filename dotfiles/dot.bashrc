#!/bin/bash
# shellcheck disable=SC1090
#
# ~/.bashrc: executed by bash(1) for non-login shells.
# ___version___: 2019-00-00-0000

# If not running interactively, don't do anything
#
[ -z "$PS1" ] && return

# Short message to know what we're loading and where.
#
echo "Entering bash on $HOSTNAME."

# Temporarily disable and debug
#
# env | less
# echo "Will not load bashrc."
# return
#
###

# Source global definitions, except when operating on RWTH cluster
#
if [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] ; then
  echo "Skipping global definitions (/etc/bashrc) on $HOSTNAME."
  printf 'Loading specific scripts: ' 
  tmp_script="/etc/profile.d/bash_completion.sh"
  [ -e "$tmp_script" ] && { printf '%s ' "$tmp_script" ; source "$tmp_script" ; }
  tmp_script="/usr/share/Modules/init/bash_completion"
  [ -e "$tmp_script" ] && { printf '%s ' "$tmp_script" ; source "$tmp_script" ; }
  printf '\n'
  unset tmp_script
  # Set the SHELL to an actually reasonable value, it inherits values from zsh
  SHELL=$(command -v bash)
else
  if [ -f /etc/bashrc ]; then
	  source /etc/bashrc
  fi
fi

# Add user's bin to PATH (look there first!)
if [ -e "$HOME/bin" ]; then
  PATH="$HOME/bin/:$PATH"
fi

# Expand directories and make variables changable
shopt -s direxpand
shopt -s cdable_vars

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"
[ -f "$HOME/.alias" ] && source "$HOME/.alias"

# If there are user-defined functions available, source them
[ -f "$HOME/.bash_functions" ] && source "$HOME/.bash_functions"

# General option that control handling of history settings
# Append to the history file, don't overwrite it:
shopt -s histappend

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# alternative HISTCONTROL=ignoreboth:erasedups

# Setting history length (see man bash)
# HISTSIZE (lines or commands stored in memory while session is ongoing)
# HISTFILESIZE (lines or commands in the history file at start/end of session)
HISTSIZE=10000
HISTFILESIZE=20000
# Set HISTSIZE=-1 and HISTFILESIZE=-1 for unlimited lines

# Enable extended globbing for bash
shopt -s extglob

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# Make less more friendly for non-text input files:
# requires lesspipe to be installed: https://github.com/wofr06/lesspipe
# I couldn't get the above to work properly, 
# so I'm using falling back to the system default if installed

if lesspipe_cmd=$(command -v lesspipe || command -v lesspipe.sh) ; then
  LESSOPEN="|${lesspipe_cmd} %s"
  export LESSOPEN
fi
unset lesspipe_cmd

# Specify a directory as a shortcut for log files
if [ -d "$HOME/logfiles" ] ; then
  LOGFILES="$HOME/logfiles"
elif [ -d "$HOME/logs" ] ; then
  LOGFILES="$HOME"
fi
[[ -n $LOGFILES ]] && export LOGFILES

### Set and modify prompt
# Set a quite simple prompt to start (note the qoutes)
PS1='\u@\h:\w\$ '

# See what out terminal is capable of
case "$TERM" in
  *color) 
    color_prompt=yes
    ;;
  xterm*)
    if command -v tput &> /dev/null && tput setaf 1 &> /dev/null ; then
      # Assume we have color support compliant with Ecma-48 (ISO/IEC-6429).
      # (Lack of such support is extremely rare, and such
      # a case would tend to support setf rather than setaf.)
      color_prompt=yes
    fi
    ;;
esac

if [[ "$color_prompt" == yes ]] ; then
  # Set a colorful promt then (note the quotes)
  PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
unset color_prompt 

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    # Since we are extending the prompt (note the quotes), 
    # we explicitly escape backslash.
    PS1="\\[\\e]0;\\u@\\h:\\w\\a\\]$PS1"
    ;;
esac

# Add shell level to prompt
if [[ $HOSTNAME =~ [Rr][Ww][Tt][Hh] ]] ; then
  # Aachen RZ Cluster only allows zsh as login shell.
  # SHLVL == 1 can therefore only be the zsh
  if (( SHLVL == 2 )); then
    PS1="(bash) $PS1"
  else 
    PS1="(bash $((SHLVL -1))) $PS1" 
  fi
else
  # In all other cases we directly use the variable
  PS1="($SHLVL) $PS1"
fi

# Add helper script to execute befor prompt is displayed, 
# or add the time _in_ the prompt
if command -v ii2l.bash > /dev/null ; then
  PROMPT_COMMAND="ii2l.bash"
else
  PS1="\\D{%H:%M} $PS1"
fi
[[ -n $PROMPT_COMMAND ]] && export PROMPT_COMMAND

# Find initialisation scripts in a local directory
# Customise location of these scripts:
local_etc_profile_dir="$HOME/local/bash_profile.d"
if [[ -d $local_etc_profile_dir ]] ; then
  for script in "$local_etc_profile_dir"/*.bash ; do
    [[ -r $script ]] && . "$script"
  done
  unset script
fi
unset local_etc_profile_dir

echo "Loading bashrc complete."
