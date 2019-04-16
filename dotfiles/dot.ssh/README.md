# `dot.ssh`

This directory contains a configuration file for the dialog systems
of the RWTH cluster (BULL and CLAIX-2018).
It should be placed as `~/.ssh` on your local and remote systems. 
See the notes on `config` below.  
Paste your **public** ssh-key to the file `authorised_keys` for
easier switching of the dialog systems. 
The file `known_hosts` is a blank and will be generated 
by the system automatically when you login. 
There is no actual need to have it in the first place,
this is just a reminder that the file will exist at some point.

## Notes on `config`

The configuration file conatins entries of the following kind:
```
Host claix18
    User <username>
    Hostname login18-1.hpc.itc.rwth-aachen.de
```
In those cases `<username>` has to be replaced with your login name.
You can do this by hand, or with sed:
```
[...]/dot.ssh$ sed "/[[:space:]]*User/ s/<username>/$USER/" config >> "$HOME/.ssh/config"
```
This will __append__ to the existing configuration file, 
make sure to check whether the result is acceptable.

### Content of the directory
```
.
├── authorized_keys
├── config
├── known_hosts
└── README.md
```

___version___: 2019-04-16-1544

