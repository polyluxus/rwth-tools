# JabRef

This directory contains ia script which is a wrapper to
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
runJabRef.bash [debug] update <JabRef arguments>
```
to get the latest release.
The debug switch gives some statements, if something does not go according to plan.
Without any wrapper switches, it will simply call the most recent java file.

```
runJabRef.bash <JabRef arguments>
```


___version___: 2019-00-00-0000

