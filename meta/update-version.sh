#!/bin/bash

update_file ()
{
  [[ "$1" =~ [\*]+ ]] && return
  printf 'Updating "%s" ... ' "$1"
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
    pushd "$directory" || { echo "ERROR changing directory" ; exit 1 ; }
    for file in *.sh *.bash *.md *.markdown ; do
      [[ "$file" =~ [\*]+ ]] && continue 
      update_file "$file"
    done
    popd &> /dev/null || { echo "ERROR changing directory" ; exit 1 ; }
  else
    printf 'Unchanged: %s.\n' "$directory"
  fi
done

cat <<EOF
To apply these changes:
  git add "$git_root"
  git commit
  git tag -f "$insert_version"
  git push
EOF

