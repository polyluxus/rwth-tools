#!/bin/bash

update_file ()
{
  [[ "$1" =~ \* ]] && return
  printf 'Updating "%s" ... ' "$1"
  sed -i "s/___version___: [[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{4\\}/___version___: $insert_version/" "$1"
  printf 'done.\n'
}

git_root=$(git rev-parse --show-toplevel)
insert_version=$( date '+%Y-%m-%d-%H%M' )

for directory in "$git_root" "${git_root}"/* ; do
  [[ -d $directory ]] || continue
  pushd "$directory" || { echo "ERROR changing directory" ; exit 1 ; }
  for file in *.sh *.bash *.md *.markdown ; do
    update_file "$file"
  done
  popd &> /dev/null || { echo "ERROR changing directory" ; exit 1 ; }
done

