#!/bin/bash

if [[ $1 == -h ]] ; then
  echo "This script fetches remote repository, checks local changes, and updates the version in those files."
  echo "___version___: 2019-01-24-1930"
  exit 0
elif [[ $1 == -t ]] ; then
  echo "Will perform a testrun, and not update any files."
  testrun=true
fi


if [[ "$testrun" == "true" ]] ; then
  update_text="Update necessary:"
else
  update_text="Updating"
fi
unchanged_text="Unchanged"
fatal_text="ERROR"
warning_text="WARNING"

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
      "$(sed -n "s/___version___: [[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{4\\}/___version___: $insert_version/p" "$1")"
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
    return 0
  fi
  pushd "$directory" &> /dev/null || fatal "ERROR changing directory"
  for file in *.sh *.bash *.md *.markdown ; do
    [[ "$file" =~ [\*]+ ]] && continue 
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
insert_version=$( date '+%Y-%m-%d-%H%M' )

update_directory "$git_root"
   ###   #for directory in "$git_root" "${git_root}"/* ; do
   ###   for directory in "$git_root" ; do
   ###     [[ -d $directory ]] || continue
   ###     does_differ=$( git diff "origin/$git_branch" -- "$directory" )
   ###     if [[ -n $does_differ ]] ; then
   ###       update_directory "$directory"
   ###     else
   ###       printf '%s: %s.\n' "$unchanged_text" "$directory"
   ###     fi
   ###   done

[[ "$testrun" == "true" ]] && { echo "Testrun complete." ; exit 0 ; }

cat <<EOF
To apply these changes:
  git add "$git_root"
  git commit # to enter message interactively
  # OR
  git commit -m "Bump version to $insert_version"
  git tag -f "$insert_version"
  git push
EOF

