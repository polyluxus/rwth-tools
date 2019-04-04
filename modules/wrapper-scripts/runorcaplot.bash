#!/bin/bash
# Needs an installation of orca and a modulefile from this repository
#___version___: 2019-04-04-1847

#hlp +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#hlp +++                Wrapper      to      call      orca_plot                 +++
#hlp +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#hlp
OPTIND=1

while getopts :f:i:h options ; do
  #hlp +   Options:
  case $options in
    #hlp +     -f <gbw-file>    Run 'non-interactive' FOD visualisation
    f)
      input_gbw="$OPTARG"
      execmode="fod"
      ;;
    #hlp +     -i <gbw-file>    Run 'interactive' on <gbw-file>
    i)
      input_gbw="$OPTARG"
      execmode="interactive"
      ;;
    #hlp +     -h               Show this!  
    h)
      pattern="^[[:space:]]*#hlp(.*)?$"
      while read -r line || [[ -n "$line" ]] ; do
        [[ "$line" =~ $pattern ]] && printf 'HELP: %s\n' "${BASH_REMATCH[1]}"
      done < <( grep '#hlp' "$0" )
      exit 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

#hlp
#hlp +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

if [[ -z $input_gbw && -z ${1} ]] ; then
  echo "This wrapper needs a gbw file as input."
  echo "Try '$0 -h' for more information."
  exit 0
elif [[ -z $input_gbw ]] ; then
  input_gbw="$1"
  execmode="interactive"
  shift
fi

while [[ ! -z ${1} ]] ; do
  printf 'Ignored: %s\n' "$1"
  shift
done

[[ -r "$input_gbw" ]] || { echo "Not readable: $input_gbw" ; exit 1 ; }

module load orca 2>&1
ORCAPLOT_BIN="$( command -v "orca_plot" )" || { echo "No executable found!" ; exit 1 ; }

case $execmode in
  fod)
    # Initialise fod input
    declare -a fod_input
    # Choose 'Enter type of plot' (1)
    fod_input+=( "1" )
    # Choose 'electron density' (2)
    fod_input+=( "2" )
    # Default filename? (no)
    fod_input+=( "n" )
    # Enter name of the FOD file (assume from input gbw)
    fod_input+=( "${input_gbw/.gbw/}.scfp_fod" )
    # Choose 'Enter number of grid intervals' (4)
    fod_input+=( "4" )
    # Enter 'NGRID' (120 = high quality)
    fod_input+=( "120" )
    # Choose 'Select output file format' (5)
    fod_input+=( "5" )
    # Choose 'Gaussian cube' (7)
    fod_input+=( "7" )
    # Choose 'Generate the plot' (10)
    fod_input+=( "10" )
    # Choose 'Exit the program' (11)
    fod_input+=( "11" )
    # One linebreak extra
    fod_input+=( "" )

    "${ORCAPLOT_BIN}" "$input_gbw" -i < <( printf '%s\n' "${fod_input[@]}" )
    ;;
  interactive)
    "${ORCAPLOT_BIN}" "$input_gbw" -i 
    ;;
  *)
    echo "Unknown execution mode."
    ;;
esac

