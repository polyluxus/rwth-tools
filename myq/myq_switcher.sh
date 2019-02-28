#!/bin/bash
if command -v bjobs &> /dev/null ; then
  if command -v myq_bjobs ; then
    myq_bjobs "$@"
    exit 0
  elif command -v myq_bjobs.sh ; then
    myq_bjobs.sh "$@"
    exit 0
  fi
elif command -v squeue &> /dev/null ; then
  if command -v myq_slurm ; then
    myq_slurm "$@"
    exit 0
  elif command -v myq_slurm.sh ; then
    myq_slurm.sh "$@"
    exit 0
  fi
else
  echo "No appropriate tool found."
  exit 1
fi
