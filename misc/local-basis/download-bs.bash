#!/bin/bash
#
# This is a very, very, very simple CLI to the EMSL Basis Set Exchange
# Only use it, if you know what you are doing, or like to live dangerously.
#
# This script downloads and reformats the actual basis set files.
#
# ___version___: 2019-02-28-1243

debug ()
{
  echo "DEBUG: $*" >&3
}

exec 3> /dev/null
[[ "$1" == "debug" ]] && { exec 3>&2 ; shift ; }

database_loc="$(bash make-db.bash)"
[[ -z $1 ]] && { echo "$database_loc" ; exit 0 ; }

url_generator ()
{
  local basisSets_url="$1"
  local basisSets_name="$2"
  local eltlist="$3"
  local outputcode_value="$4"
  local contraction_checked=checked
  [[ -z "$portlets_bsaction_path" ]] && { echo "Rebuild database." ; exit 0 ; }
  local path="$portlets_bsaction_path"
  #hardcoded from source code of emsl bse
  path+="/eventSubmit_doDownload/true"
  path+="?bsurl=$basisSets_url"
  path+="&bsname=$basisSets_name"
  path+="&elts=$eltlist"
  path+="&format=$outputcode_value"
  path+="&minimize=$contraction_checked"
  
  echo "$path"
}

basisSet_format=Gaussian94
download_target="${PWD}/basis-download"

[[ -e "$database_loc" ]] || { echo "No DB!" ; exit 1 ; }
#shellcheck source=bse.db
. "$database_loc"

until [[ -z $1 ]] ; do
  down_bs_name="${name[$1]}"
  down_bs_url="${url[$1]}"
  down_bs_elements_string="${elements[$1]}"
  down_bs_elements_string="${down_bs_elements_string//[[:space:]]/}"
  printf '%5s: %-15s (%s)\n       %s\n\n' "$1" "$down_bs_name" "$down_bs_url" "$down_bs_elements_string"
  IFS=, read -ra down_bs_elements_array <<< "$down_bs_elements_string"
  [[ -d "$download_target/$down_bs_name" ]] || debug "$(mkdir -vp "$download_target/$down_bs_name" || exit 1)"
  for down_element in "${down_bs_elements_array[@]}" ; do
    wget_download_url="$(url_generator "$down_bs_url" "$down_bs_name" "$down_element" "$basisSet_format")"
    basisset_file_raw="$download_target/$down_bs_name/${down_element}.gbs.raw"
    basisset_file="${basisset_file_raw%.raw}"
    [[ -e "$basisset_file_raw" ]] && debug "$(rm -v "$basisset_file_raw" )"
    debug "$(wget --output-document="$basisset_file_raw" "$wget_download_url" 2>&1 )"
    sed -n '/<pre/,/<\/pre/p' "$basisset_file_raw" | sed '/pre/d' | sed '/^[[:space:]]*$/d' | sed '0,/\*\*\*\*/{//d;}' > "${basisset_file}"
    [[ -e "$basisset_file_raw" ]] && debug "$(rm -v "$basisset_file_raw" )"
    if [[ "${has_ecp[$1]}" =~ [Tt][Rr][Uu][Ee] ]] ; then
      sed -- '1,/\*\*\*\*/d' "${basisset_file}" > "${basisset_file%.gbs}-ECP.gbs"
      sed -n -i '1,/\*\*\*\*/p' "${basisset_file}" 
      grep '^!' "${basisset_file%.gbs}-ECP.gbs" >> "${basisset_file}"
    fi
  done
  shift
done

