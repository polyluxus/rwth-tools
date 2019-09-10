# Installing pandoc

You can obtain the latest release from [GitHub/jgm/pandoc](https://github.com/jgm/pandoc),
or directly go to the download page of the [latest release](https://github.com/jgm/pandoc/releases/latest).

Detailed installation instructions are available in [the pandoc repository](https://github.com/jgm/pandoc/blob/master/INSTALL.md).

The module files in this directory assume that they are installed in the following path,
where `<USER>` should be substituted by your username, 
and `<version>` needs to be replaced with the actual version number (currently 2.7):
```
/home/<USER>/local/pandoc/pandoc-<version>
```

This directory contains a script `install_pandoc.bash`, which installs everything according to the instructions below.

## Instructions

If the installation directory does not yet exist, create it:
```
mkdir -v -- "$HOME/local/pandoc"
```

Change to the installation directory:
```
cd "$HOME/local/pandoc"
```

You can obtain the latest tarball archive with the following commands:
```
TGZ_SRC=$(curl -s "https://api.github.com/repos/jgm/pandoc/releases/latest" | grep "browser_download_url.*tar.gz" | cut -d '"' -f 4)
wget "$TGZ_SRC"
```

To install it to the standard location, you can use the following commands:
```
TGZ="${TGZ_SRC##*/}"
DEST="${TGZ%-*}"
mkdir -v -- "$DEST"
tar xvzf "$TGZ" --strip-components 1 -C "$DEST"
```

Assuming your local module files are installed in the following directories
```
/home/<USER>/local/modules/modulefiles/LOCAL
/home/<USER>/local/modules/modulefiles/source
```

and further assuming `rwth-tools` is installed in the directory
```
/home/<USER>/local/rwth-tools
```

you can copy the module files directly from *here* to *there*:
```
cp -vr -- "$HOME/local/rwth-tools/modules/modulefiles/LOCAL/pandoc" "$HOME/local/modules/modulefiles/LOCAL"
cp -vr -- "$HOME/local/rwth-tools/modules/modulefiles/source/pandoc" "$HOME/local/modules/modulefiles/source"
```

Check with `module avail` if the new module file is recognised.
You should now be able to load it with `module load pandoc`.

___version___: 2019-09-10-1500


