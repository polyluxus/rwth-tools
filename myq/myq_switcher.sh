#!/bin/bash
if command -v bjobs &> /dev/null ; then
  if command -v myq_bjobs &> /dev/null ; then
    myq_bjobs "$@"
    exit 0
  elif command -v myq_bjobs.sh &> /dev/null ; then
    myq_bjobs.sh "$@"
    exit 0
  fi
elif command -v squeue &> /dev/null ; then
  if command -v myq_slurm &> /dev/null ; then
    myq_slurm "$@"
    exit 0
  elif command -v myq_slurm.sh &> /dev/null ; then
    myq_slurm.sh "$@"
    exit 0
  fi
else
  echo "No appropriate tool found."
  exit 1
fi
