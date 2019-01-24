#! /bin/bash

if [[ "$1" == -h ]] ; then
  echo "This script starts JabRef, being able to update first."
  echo "Usage: ${0##*/} [debug] [update]"
  exit 0
fi

debug ()
{
  echo "$*" >&3
}

testcommand ()
{
  if command -v "$1" &> /dev/null ; then
    debug "Found '$1'"
  else
    echo "This updater needs '$1' to work."
    exit 1
  fi
}

get_absolute_location ()
{
    # Resolves the absolute location of parameter and returns it
    # Taken from https://stackoverflow.com/a/246128/3180795
    # Originally written for https://github.com/polyluxus/tools-for-g16.bash
    local resolve_file="$1" description="$2" 
    local link_target directory_name filename resolve_dir_name 
    debug "Getting directory for '$resolve_file'."
    #  resolve $resolve_file until it is no longer a symlink
    while [[ -h "$resolve_file" ]]; do 
      link_target="$(readlink "$resolve_file")"
      if [[ $link_target == /* ]]; then
        debug "File '$resolve_file' is an absolute symlink to '$link_target'"
        resolve_file="$link_target"
      else
        directory_name="$(dirname "$resolve_file")" 
        debug "File '$resolve_file' is a relative symlink to '$link_target' (relative to '$directory_name')"
        #  If $resolve_file was a relative symlink, we need to resolve 
        #+ it relative to the path where the symlink file was located
        resolve_file="$directory_name/$link_target"
      fi
    done
    debug "File is '$resolve_file'" 
    filename="$(basename "$resolve_file")"
    debug "File name is '$filename'"
    resolve_dir_name="$(dirname "$resolve_file")"
    directory_name="$(cd -P "$(dirname "$resolve_file")" && pwd)"
    if [[ "$directory_name" != "$resolve_dir_name" ]]; then
      debug "$description '$directory_name' resolves to '$directory_name'."
    fi
    debug "$description is '$directory_name'"
    if [[ -z $directory_name ]] ; then
      directory_name="."
    fi
    echo "$directory_name/$filename"
}

get_absolute_filename ()
{
    # Returns only the filename
    local resolve_file="$1" description="$2" return_filename
    return_filename=$(get_absolute_location "$resolve_file" "$description")
    return_filename=${return_filename##*/}
    echo "$return_filename"
}

get_absolute_dirname ()
{
    # Returns only the directory
    local resolve_file="$1" description="$2" return_dirname
    return_dirname=$(get_absolute_location "$resolve_file" "$description")
    return_dirname=${return_dirname%/*}
    echo "$return_dirname"
}

update_jabref ()
{
  testcommand curl
  testcommand grep
  testcommand cut
  testcommand wget
 
  local update_url update_target_name update_target_dir update_target 
  debug "Trying to get the download URL of the lates release from GitHub."
  update_url=$(curl -s "https://api.github.com/repos/JabRef/jabref/releases/latest" | grep "browser_download_url.*jar" | cut -d '"' -f 4)
  debug "Found: $update_url"
  update_target_name="${update_url##*/}"
  debug "Target name: $update_target_name"
  update_target_dir="$1"
  debug "Target directory: $update_target_dir"
  update_target="${update_target_dir}/${update_target_name}"
  
  if [[ -e "$update_target" ]] ; then
    debug "File exists already: $update_target" 
  else
    debug "Downloading latest release."
    debug "$(wget --no-verbose "$update_url")"
  fi
  debug "Updated: $update_target"
  echo "$update_target"
}

get_jabref_jar ()
{
  debug "Finding Jabref file."
  local testset_jabref_jar=( "$1"/*.jar )
  if [[ "${testset_jabref_jar[0]}" =~ [\*]+ ]] ; then
    echo "No java (*.jar) files found, try downloading the latest release:" >&2
    echo "  ${0##*/} [debug] update" >&2
    echo "Aborting for now." >&2
    exit 1
  fi
  debug "Testset: ${testset_jabref_jar[*]}"
  local return_jabref_jar="${testset_jabref_jar[0]}"
  local test_jabref_jar 
  for test_jabref_jar in "${testset_jabref_jar[@]}" ; do
    [[ $test_jabref_jar -nt $return_jabref_jar ]] && return_jabref_jar="$test_jabref_jar"
  done
  debug "Newest: $return_jabref_jar"
  echo "$return_jabref_jar"
}

run_jabref ()
{
  local jabref_logfile_dir
  if [[ -z $LOGFILES ]] ; then
    if [[ -d "$HOME/logfiles" ]] ; then
      jabref_logfile_dir="$HOME/logfiles"
    else
      jabref_logfile_dir="${TMPDIR}"
    fi
  else
    jabref_logfile_dir="$LOGFILES"
  fi
  jabref_logfile="${jabref_logfile_dir}/jabref_session_$(date +%y%m%d%H%M).log"
  testcommand java
  debug "Starting: $jabref_jar"
  debug "Logfile: $jabref_logfile"
  java -jar "$jabref_jar" "$@" &> "$jabref_logfile"
}

# 
# Start of main script
#

if [[ "$1" == "debug" ]] ; then
  exec 3>&1
  debug "Starting debug mode."
  shift
else
  exec 3> /dev/null
fi

jabref_install_dir=$(get_absolute_dirname "$0" "JabRef installation directory")

if [[ "$1" == "update" ]] ; then
  debug "Starting Update mode."
  jabref_jar=$( update_jabref "$jabref_install_dir" )
  shift
fi

if [[ -z $jabref_jar ]] ; then 
  debug "No Jabref java file selected yet."
  jabref_jar="$(get_jabref_jar "$jabref_install_dir")" || exit 1
fi

run_jabref "$@"

exec 3>&-


