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

## License (GNU General Public License v3.0)

rwth-tools - a collection of scripts for CLAIX18  
Copyright (C) 2019 Martin C Schwarzer

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See [LICENSE](../LICENSE) to see the full text.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

___version___: 2019-09-17-1200
