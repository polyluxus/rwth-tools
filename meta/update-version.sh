#!/bin/bash

update_file ()
{
  printf 'Updating "%s" ... ' "$1"
  sed -i "s/___version___: [[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{4\\}/___version___: $insert_version/" "$1"
  printf 'done.\n'
}

git_root=$(git rev-parse --show-toplevel)
insert_version=$( date '+%Y-%m-%d-%H%M' )

for directory in "$git_root" "${git_root}/*" ; do
  pushd "$directory" || { echo "ERROR changing directory" ; exit 1 ; }
  for file in *.sh *.bash *.md *.markdown ; do
    update_file "$file"
  done
  popd || { echo "ERROR changing directory" ; exit 1 ; }
done

