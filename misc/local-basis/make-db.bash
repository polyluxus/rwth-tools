#!/bin/bash
#
# This is a very, very, very simple CLI to the EMSL Basis Set Exchange
# Only use it, if you know what you are doing, or like to live dangerously.
#
# This script tries to download parts of the BSE portal, and reformat
# the content to a bash like format.
#
# ___version___: 2019-01-31-1936

base_url="https://bse.pnl.gov/bse/portal"
database_loc="$PWD/bse.db"
[[ -z $1 ]] && { echo "$database_loc" ; exit 0 ; }

debug ()
{
  echo "DEBUG: $*" >&3
}

exec 3> /dev/null
[[ "$1" == "debug" ]] && { exec 3>&2 ; shift ; }
[[ -r "$1" ]] && database_loc="$1"
[[ "$1" == -c ]] || { echo "Get the info from EMSL BSE with -c" ; exit 0 ; }

url_get_content ()
{
  local portal_tmp_file
  portal_tmp_file="$(mktemp portal.XXXXXX)"
  debug "portal file: $portal_tmp_file"
  #wget --quiet --output-document="$portal_tmp_file" "$base_url"
  debug "$(wget --no-verbose --output-document="$portal_tmp_file" "$base_url" 2>&1 )"
  debug "$(dos2unix "$portal_tmp_file" 2>&1)"
  local content_url
  content_url_grepped="$( grep --color=never 'src=.*\/Main\/.*\/content' "$portal_tmp_file" )"
  # | sed 's/[[:space:]]*src=//' ) #| sed 's/"//g' )
  local pattern
  pattern='^[^"]+"([^"]+)".*$'
  [[ "$content_url_grepped" =~ $pattern ]] && content_url="${BASH_REMATCH[1]}"
  debug "Content-URL: ${content_url}"
  echo "$content_url"
  debug "$(rm -v  "$portal_tmp_file" )"
}

create_basisset_entry()
{
  local parseline="$1"
  local bs_count="$2"
  debug "line is: $parseline"
  local parseline_mod
  [[ "$parseline" =~ ^[^\(]+\((.*)\)\;[[:space:]]*$ ]] && parseline_mod="${BASH_REMATCH[1]}"
  debug "modified: $parseline_mod"
  pattern='^[[:space:]]*"([^"]+)",(.*)$'
  local -a bs_array
  while [[ "$parseline_mod" =~ $pattern ]] ; do
    bs_array+=("${BASH_REMATCH[1]}")
    parseline_mod="${BASH_REMATCH[2]}"
  done
  local mod_elements="${bs_array[3]}"
  mod_elements="${mod_elements#*[}"
  mod_elements="${mod_elements%]*}"

  cat <<-EOF
	#Basis Set ${bs_count}:
  bs_index[${bs_count}]="${bs_count}"
  url[${bs_count}]="${bs_array[0]}"
  name[${bs_count}]="${bs_array[1]}"
  type[${bs_count}]="${bs_array[2]}"
  elements[${bs_count}]="${mod_elements}"
  status[${bs_count}]="${bs_array[4]}"
  has_ecp[${bs_count}]="${bs_array[5]}"
  has_spin[${bs_count}]="${bs_array[6]}"
  last_modification[${bs_count}]="${bs_array[7]}"
  contribution_pi[${bs_count}]="${bs_array[8]}"
  contributor_name[${bs_count}]="${bs_array[9]}"
  abstract[${bs_count}]="${parseline_mod//\"}"
	#end ${bs_count}
	EOF
}

create_database ()
{
  local content_tmp_file content_tmp_file_reduced content_url
  content_tmp_file=$(mktemp content.XXXXXX)
  debug "Content file: $content_tmp_file"
  content_tmp_file_reduced=$(mktemp content.red.XXXXXX)
  debug "Content file reduced: $content_tmp_file_reduced"
  content_url=$(url_get_content)
  debug "Content URL: $content_url"
  debug "$(wget --no-verbose --output-document="$content_tmp_file" "${content_url}" 2>&1 )"
  debug "$(dos2unix "$content_tmp_file" 2>&1 )"
  grep 'basisSets\[[[:digit:]]\+\]' "$content_tmp_file" > "$content_tmp_file_reduced"
  local portlets_bsaction_path_grepped portlets_bsaction_path
  portlets_bsaction_path_grepped="$( grep --color=never 'path=.*\/action\/.*' "$content_tmp_file" | uniq | head -n 1 )"
  local pattern
  pattern='^[^"]+"([^"]+)".*$'
  [[ "$portlets_bsaction_path_grepped" =~ $pattern ]] && portlets_bsaction_path="${BASH_REMATCH[1]}"
  debug "bsaction path: ${portlets_bsaction_path}"
  debug "$( rm -v "$content_tmp_file" )"
  cat <<-EOF
	#!/bin/bash
	#shellcheck disable=SC2034
	# Header $(date)
  base_url="${base_url}"
  content_url="${content_url}"
  portlets_bsaction_path="${portlets_bsaction_path}"
	# end header
	EOF
  local line counter=0
  while read -r line || [[ -n "$line" ]] ; do
    debug "Line: $line"
    create_basisset_entry "$line" "$counter"
    (( counter++ ))
    debug "sleeping"
    # sleep 3
  done < "$content_tmp_file_reduced"
  debug "$( rm -v "$content_tmp_file_reduced" )"
  echo '# End of database'
}

[[ -e $database_loc ]] && debug "$(mv -v "$database_loc" "${database_loc}.$(date +%s).bak")"
debug "Writing to: $database_loc"
create_database > "$database_loc"


