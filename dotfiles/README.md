# Dotfiles

This directory contains scripts, which are mainly intended to be 
set up scripts for the command line interpreter.
They are designed in the way that they install bash as the default shell,
with a non-standard, but still default behaviour.
They can probably be used on other systems as they have special cases implemented 
based on the hostname.

The subdirectory contains specific startup script that are sourced (if found)
from the bashrc.
For this to work it is necessary to either edit the location of the directory
into the file, or store it in a firectory called `~/local` as it is specified there.

## Installation

Import the files to their default location, e.g.
replace or append to `~/.bashrc` the file `dot.bashrc`.
Edit the rest to your needs.

Create a directory `~/local` (I use it to store any software I install personally)
and copy `bash_profile.d` into it.
For more description see the [README](./bash_profile.d/README.md) there.

## Contents-tree

```
.
├── bash_profile.d
│   ├── color_ls_grep.bash
│   ├── init_modules.bash
│   ├── README.md
│   ├── set_lesspipe.bash
│   └── vim.bash
├── dot.alias
├── dot.bash_functions
├── dot.bashrc
├── dot.inputrc
├── dot.scieborc
├── dot.ssh
│   ├── authorized_keys
│   ├── config
│   ├── known_hosts
│   └── README.md
├── dot.zshrc
└── README.md
```

___version___: 2019-02-28-1243
