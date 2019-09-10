#!/bin/bash

while getopts :htfV: options ; do
  case $options in
    h)
      echo "This script fetches remote repository, checks local changes, and updates the version in those files."
      echo "Options: -h (show this help); -t (test run); -f (force on all files)"
      echo "___version___: 2019-09-10-1348"
      exit 0
      ;;
    t)
      echo "Will perform a testrun, and not update any files."
      testrun=true
      ;;
    f)
      echo "Forcing update of all version numbers." 
      force_update=true
      ;;
    V)
      [[ $OPTARG =~ ^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{4}$ ]] || { echo "Unrecognised version format." ; exit 1 ; }
      echo "Forcing version number '$OPTARG'."
      insert_version="$OPTARG"
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
  esac
done

shift $(( OPTIND -1 ))

while [[ -n $1 ]] ; do
  echo "Additional input ignored: $1"
  shift
done

# Default text settings:
unchanged_text="Unchanged"
update_text="Updating"
fatal_text="ERROR"
warning_text="WARNING"

# Testrun specific settings
if [[ "$testrun" == "true" ]] ; then
  update_text="Update necessary:"
  [[ "$force_update" == "true" ]] && unchanged_text="Update forced"
else
  update_text="Updating"
  if [[ "$force_update" == "true" ]] ; then
    echo 'Do you want to continue? (NO/yes)'
    read -r user_input
    [[ "$user_input" =~ ^[Yy][Ee][Ss]$ ]] || exit 2
    unset user_input
    unchanged_text="Update forced:"
  fi
fi

fatal ()
{
  echo "${fatal_text}: $*"
  exit 1
}

warning ()
{
  echo "${warning_text}: $*"
  return 1
}

if command -v tput > /dev/null && tput setaf 1 &> /dev/null ; then 
  color_green=$(tput setaf 2)
  color_yellow=$(tput setaf 3)
  color_red=$(tput setaf 1)
  color_magenta=$(tput setaf 5)
  color_default=$(tput sgr0)
  update_text="${color_green}${update_text}${color_default}"
  unchanged_text="${color_yellow}${unchanged_text}${color_default}"
  fatal_text="${color_red}${fatal_text}${color_default}"
  warning_text="${color_magenta}${warning_text}${color_default}"
else
  warning 'No color available.'
fi

update_file ()
{
  [[ "$1" =~ [\*]+ ]] && return
  local display_git_root
  display_git_root="${PWD/$git_root/<GIT_ROOT>}"
  printf '%s "%s" ... ' "$update_text" "$display_git_root/$1"
  if [[ "$testrun" == "true" ]] ; then
    printf '\n  Setting: %s \n' \
      "$(sed -n "s/___version___:\\([[:space:]]\\+\\)[[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{4\\}/___version___:\\1$insert_version/p" "$1")"
  else
    sed -i "s/___version___: [[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{4\\}/___version___: $insert_version/" "$1"
    printf 'done.\n'
  fi
}

update_directory ()
{
  local directory="$1"
  local file subdirectory
  [[ -d "$directory" ]] || return 1
  does_differ=$( git diff "origin/$git_branch" -- "$directory" )
  if [[ -z $does_differ ]] ; then
    printf '%s: %s\n' "$unchanged_text" "${PWD/$git_root/<GIT_ROOT>}/$directory"
    [[ "$force_update" == "true" ]] || return 0
  fi
  pushd "$directory" &> /dev/null || fatal "ERROR changing directory"
  for file in *.sh *.bash *.md *.markdown dot.* *.tex config .gitignore ; do
    [[ -r "$file" ]] || continue 
    [[ -d "$file" ]] && continue
    update_file "$file"
  done
  for subdirectory in */ ; do
    [[ "$subdirectory" =~ [\*]+ ]] && continue
    [[ -d "$subdirectory" ]] || continue
    update_directory "$subdirectory"
  done
  popd &> /dev/null || fatal "ERROR changing directory" 
}

git fetch
git_root=$( git rev-parse --show-toplevel )
git_branch=$( git rev-parse --abbrev-ref HEAD )
insert_version=${insert_version:-$( date '+%Y-%m-%d-%H%M' )}

update_directory "$git_root"

[[ "$testrun" == "true" ]] && { echo "Testrun complete." ; exit 0 ; }

cat <<EOF
To apply these changes:
  # Add eerything to the repository
  git add "$git_root"

  # Commit the changes
  git commit # to enter message interactively
  # OR
  git commit -m "Bump version to $insert_version" # Standard message

  # Add a tag (lightweight tag, forced) used in development phase
  git tag -f "$insert_version"
  # OR an annotated tag to release (should only be done if the update was forced)
  git tag -a "$insert_version"

  # Publish everything
  git push
  git push --tags # for releases
EOF

