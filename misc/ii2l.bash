#!/bin/bash
# It is important to turn on extended globbing
if shopt -p extglob > /dev/null ; then
  :
else
  shopt -s extglob > /dev/null
fi

fatal ()
{
  echo "ERROR: $*"
  [[ -n $testmode ]] && return 1
  exit 1
}

isittoolate ()
{
  local current color uncolor text 
  current="$1"
  uncolor="$(tput sgr0)"
  local use_silent use_oklate use_almost2late use_itis2late use_early use_morning use_lunch use_default
  use_silent="@($__silent)"
  use_oklate="@($__oklate)"
  use_almost2late="@($__almost2late)"
  use_itis2late="@($__itis2late)"
  use_early="@($__early)"
  use_morning="@($__morning)"
  use_lunch="@($__lunch)"
  use_default="@($__default)"
  exec 3>&1
  case "$current" in
    $use_silent)
      exec 3> /dev/null
      ;;&
    $use_oklate)
      color="$(tput setf 6)"
      text="It is late: $current."
      ;;
    $use_almost2late)
      color="$(tput setf 5)"
      text="It is getting too late: $current."
      ;;
    $use_itis2late)
      color="$(tput setf 4)"
      text="It is too late: $current."
      ;;
    $use_early)
      color="$(tput setf 3)"
      text="It is quite early: $current."
      ;;
    $use_morning)
      color="$(tput setf 2)"
      text="Good morning! ($current)"
      ;;
    $use_lunch)
      color="$(tput setf 5)"
      text="It is almost lunch ($current)!"
      ;;
    $use_default)
      color="$(tput setf 3)"
      text="Current time: $current."
      ;;
    *)
      fatal "No rule could be applied." || { exec 3>&- ; return 1 ; }
      ;;
  esac
  printf '%s%s%s\n' "${color}" "${text}" "${uncolor}" >&3
  exec 3>&-
}

testfunction()
{
  local testtime
  testmode="true"
  for testtime in {00..23}:{0..5}0 ; do
    printf '%s  ' "$testtime"
    isittoolate "$testtime"
  done
  exit 0
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
    write_to_file  "# This skript ($0) uses globbing like patterns."
    write_to_file  "# The general format is 'HH:MM'."
    write_to_file  "# The '*' matches any character, brackets '[]' may be used to group values,"
    write_to_file  "# a pipe '|' may be used to separate values."
    write_to_file  "# Example: The pattern '1[123]:*' matches the times 11:00 to 13:59."
    write_to_file  "# Example: The pattern '0[78]:*|09:[012]*' matches the times 7:00 to 9:29."
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
testmode=''

# Allow for configuration file
[[ -r "$HOME/.ii2lrc" ]] && . "$HOME/.ii2lrc"

# Options
if [[ "$1" == "-h" ]] ; then
  echo "Checks if it is too late, or too early, or time for lunch." 
  echo "___version___: 2019-01-16-1808"
  exit 0
elif [[ "$1" == "-c" ]] ; then
  configure
elif [[ "$1" == "test" ]] ; then
  testfunction
fi

# Checks
if command -v tput > /dev/null ; then
  :
else
  fatal "Command not found: tput" 
fi

# Execution
isittoolate "$(date +%H:%M)" 

