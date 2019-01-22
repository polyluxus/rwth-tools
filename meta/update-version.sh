#!/bin/bash

if [[ $1 == -h ]] ; then
  echo "This script fetches remote repository, checks local changes, and updates the version in those files."
  echo "___version___: 2019-01-22-2159"
  exit 0
fi


update_text="Updating"
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
  printf '%s "%s" ... ' "$update_text" "$1"
  sed -i "s/___version___: [[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{4\\}/___version___: $insert_version/" "$1"
  printf 'done.\n'
}

git fetch
git_root=$( git rev-parse --show-toplevel )
git_branch=$( git rev-parse --abbrev-ref HEAD )
insert_version=$( date '+%Y-%m-%d-%H%M' )

for directory in "$git_root" "${git_root}"/* ; do
  [[ -d $directory ]] || continue
  does_differ=$( git diff "origin/$git_branch" -- "$directory" )
  if [[ -n $does_differ ]] ; then
    pushd "$directory" &> /dev/null || fatal "ERROR changing directory"
    for file in *.sh *.bash *.md *.markdown ; do
      [[ "$file" =~ [\*]+ ]] && continue 
      update_file "$file"
    done
    popd &> /dev/null || fatal "ERROR changing directory" 
  else
    printf '%s: %s.\n' "$unchanged_text" "$directory"
  fi
done

cat <<EOF
To apply these changes:
  git add "$git_root"
  git commit # to enter message interactively
  # OR
  git commit -m "Bump version to $insert_version"
  git tag -f "$insert_version"
  git push
EOF

