#!/bin/zsh
#
# This script is intended to switch to a different shell on the 
# RWTH RZ cluster, which only allows zsh as login shell.
# ___version___: 2019-02-28-1243
#
# Uncomment to show environment variables before doing anything
# env | less
#
# Uncomment to temporarily disable setting up anything
# return
#
# At login the shell level is 1, starting bash will set it to 2;
# if it is greater than that, we explicitly called it from somewhere,
# therefore we're not doing anything else.
#
if [[ $SHLVL -ge 2 ]]; then return ; fi
#
# Start Martin's favourite shell:
#
if [[ -o login ]]; then
  # Do not start a login shell (per request of the servicedesk)
  bash 
  exit
else
  exec bash
fi
#
# This is the end of the file.
