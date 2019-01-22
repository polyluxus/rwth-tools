# `bash_profile.d`

This directory contains more scripts, which are intended to 
set up the environment for the command line utilities.
They all use bash as the  shell interpreter,
and they should be sourced from `~/.bashrc` or related set-up files.

## Installation

Create a directory `~/local` (I use it to store any software I install personally)
and copy this directory (`bash_profile.d`) into it, or specify the location of it 
in the set-up file.

## Resources

### `color_ls_grep.bash`

This script enables colour support for the `ls` and `grep` utilities.

### `init_modules.bash`

This script is a replacement for the module load funtion the RZ provides.
It also adds a local directory (if found) to the module path.
This is currently set to `$HOME/local/modules/modulefiles/LOCAL`,
which I recommend, because a future version of this repository will
also contain some module files compatible with this set-up.

### `vim.bash`

This script only provides an alias `vi` to `vim` if one does not yet exist.
The background for this is simple: 
Usually the `vi` command point to a minimal (*small*) version of VIM.
This can be tested with the following command:
```
bash --norc -c "vi --version"
```
On the other hand, `vim` usually points to the *huge* version, 
which I prefer for many reasions and since it is installed, it does no harm using it.
The behaviour can of course similarly be tested:
```
bash --norc -c "vim --version"
```

___version___: 2019-00-00-0000
