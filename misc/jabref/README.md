# JabRef

This directory contains a script which is a wrapper to
the JabRef java file. 
It will find the most recent `JabRef-*.jar` in the install directory
(where the run script is located), 
or update it via [GitHub](https://github.com/JabRef/jabref).

From their [website jabref.org/](http://www.jabref.org/):

> JabRef is an open source bibliography reference manager. 
> The native file format used by JabRef is BibTeX, 
> the standard LaTeX bibliography format. 
> JabRef is a desktop application and runs on the Java VM (version 8), 
> and works equally well on Windows, Linux, and Mac OS X.

## Installation & Usage

Copy this script to a location where you would like to also store
the downloaded java files.
I suggest `~/local/jabref/`.
For nicer access, create a softlink in a directory which is on 
your `PATH` to the script.
I suggest `~/bin`.
The execute it with 
```
runJabRef.bash [debug] update 
```
to get the latest release.
The debug switch gives some statements, if something does not go according to plan.
Without any wrapper switches, it will simply call the most recent java file.

```
runJabRef.bash [debug] <JabRef arguments>
```
A very brief description is given with the `-h` switch.

JabRef requires Java 8.
JavaFX is not included in every runtime or development kit, 
therefore they recommend Oracle Java 8. 
However, since the recent license change, the Oracle packages have been removed from CLAIX18.
The installed OpenJDK packages that shall replace them do not include JavaFX.
As an alternative you can install ZuluFX, further instructions on how to do that can be found
in the modules tree of this repository: [ZuluJDK](../../modules/modulefiles/source/zulujdk/README.md).


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

See [LICENSE](../../LICENSE) to see the full text.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

___version___: 2019-08-22-1746
