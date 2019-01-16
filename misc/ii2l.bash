#!/bin/bash

fatal ()
{
  echo "ERROR: $*"
  exit 1
}

isittoolate ()
{
  local current color uncolor text
  current=$(date +%H:%M)
  uncolor="$(tput sgr0)"
  exec 3>&1
  case $current in
    $__silent)
      exec 3> /dev/null
      ;;
    $__oklate)
      color="$(tput setf 6)"
      text="It is late: $current."
      ;;
    $__almost2late)
      color="$(tput setf 5)"
      text="It is getting too late: $current."
      ;;
    $__itis2late)
      color="$(tput setf 4)"
      text="It is too late: $current."
      ;;
    $__early)
      color="$(tput setf 3)"
      text="It is quite early: $current."
      ;;
    $__morning)
      color="$(tput setf 2)"
      text="Good morning! ($current)"
      ;;
    $__lunch)
      color="$(tput setf 5)"
      text="It is almost lunch ($current)!"
      ;;
    $__default)
      color="$(tput setf 3)"
      text="Current time: $current."
      ;;
    *)
      fatal "No rule could be applied."
      ;;
  esac
  printf '%s%s%s\n' "${color}" "${text}" "${uncolor}" >&3
  exec >&-
}

write_to_file ()
{
  echo "$*" >&4
}

configure ()
{
  echo "This feature is not yet fully implemented."
  sleep 1
  if command -v vi > /dev/null ; then
    local rcfile="$HOME/.ii2lrc"
    exec 4> "$rcfile"
    write_to_file  "# This uses globbing like in the case statement."
    write_to_file  "__silent='$__silent'"
    write_to_file  "__oklate='$__oklate'"
    write_to_file  "__almost2late='$__almost2late'"
    write_to_file  "__itis2late='$__itis2late'"
    write_to_file  "__early='$__early'"
    write_to_file  "__morning='$__morning'"
    write_to_file  "__lunch='$__lunch'"
    write_to_file  "__default='$__default'"
    exec 4>&-
    vi "$rcfile"
    exit 0
  else
    fatal "Command not found: vi"
  fi
}

#MAIN

# Variables
__silent=""
__oklate="19:*|20:*"
__almost2late="21:*|22:*"
__itis2late="23:*|0[012345]:*"
__early="0[678]:*"
__morning="09:*|10:*"
__lunch="11:*"
__default="1[2345678]:*"

# Allow for configuration file
[[ -r "$HOME/.ii2lrc" ]] && . "$HOME/.ii2lrc"

# Options
if [[ "$1" == "-h" ]] ; then
  echo "Checks if it is too late, or too early, or time for lunch." 
  echo "___version___: 2019-01-16-1808"
  exit 0
elif [[ "$1" == "-c" ]] ; then
  configure
fi

# Checks
if command -v tput > /dev/null ; then
  :
else
  fatal "Command not found: tput"
fi

# Execution
isittoolate 

