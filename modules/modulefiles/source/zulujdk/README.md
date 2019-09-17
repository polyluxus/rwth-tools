# Local Java 

Since Oracle decided to change their licenses, 
the corresponding OracleJDK software packages were removed on CLAIX18.
The HPC team recommended switching to the OpenJDK packages, 
which are installed (form the distribution source) in various reasons.
Crucially these lack OpenJFX support which would be necessary to run JabRef.

As an alternative one can use ZuluFX™ from [Azul Systems](https://www.azul.com/).

## Installation of ZuluJDK

You can obtain the latest JDK release from the download page:
[Azul.com/downloads/zulu/zulufx/](https://www.azul.com/downloads/zulu/zulufx/).
At the time of writing, the current package was
[Java 8, OpenJDK 8u212 (64bit, tar.gz)](https://cdn.azul.com/zulu/bin/zulu8.38.0.13-ca-fx-jdk8.0.212-linux_x64.tar.gz).

After that it is a matter of unpacking and setting the correct paths.
The following question on stack overflow might be of help:
[How to install java locally - no root - on linux, if possible?](https://stackoverflow.com/q/27003920/3180795)

The module files in this directory assume that they are installed in the following path,
where `<USER>` should be substituted by your username, 
and `<version>` needs to be replaced with the actual version number (currently `8u212`):
```
/home/<USER>/local/java/zulujdk-<version>
```

If the installation directory does not yet exist, create it:
```
mkdir -v -- "$HOME/local/java"
```
I have chosen java as a header directory, to make it easier to determine what it is,
and to possibly mess around with other Java bundles.

Change to the installation directory:
```
cd "$HOME/local/java"
```

Obtain the latest tarball archive from the above source ([zulufx](https://www.azul.com/downloads/zulu/zulufx/)), 
please check whether a newer version has been provided. 
For the purpose of this guide, we'll assume the following
```
TGZ_SRC="https://cdn.azul.com/zulu/bin/zulu8.38.0.13-ca-fx-jdk8.0.212-linux_x64.tar.gz"
wget "$TGZ_SRC"
```

To install it to the standard location, simply unpack it, or use the following commands:
```
TGZ="${TGZ_SRC##*/}"
tar -xvzf "$TGZ"
```
This will (probably) create the directory `zulu8.38.0.13-ca-fx-jdk8.0.212-linux_x64`.

You can now delete the tarball archive (`rm -v -- "$TGZ"`).  
To properly use the included module files, 
you should also create a symbolic link with a shorter name:
```
ln -s zulu8.38.0.13-ca-fx-jdk8.0.212-linux_x64 zulujdk-8u212
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
cp -vr -- "$HOME/local/rwth-tools/modules/modulefiles/LOCAL/zulujdk" "$HOME/local/modules/modulefiles/LOCAL"
cp -vr -- "$HOME/local/rwth-tools/modules/modulefiles/source/zulujdk" "$HOME/local/modules/modulefiles/source"
```

Check with `module avail` if the new module file is recognised.
You should now be able to load it with `module load zulujdk`.

___version___: 2019-09-17-1200

