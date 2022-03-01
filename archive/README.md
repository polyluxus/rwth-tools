# rwth-archive.sh

This is a small script which submits a job to the queueing system 
to archive a directory, e.g. convert binary gaussian checkpoint to
formatted checkpoint files. Successful converted binary files are
deleted in the process.

## Usage
 
```
rwth-archive.sh [opt] <target_directory>
```

## Options

| Switch     | Function |
|:-----------|:---------|
| `-q <ARG>` | Select a queueing system; supported: slurm [default], bsub. |
| `-A <ARG>` | Account (bsub: project) to use. |
| `-k`       | Keep the submission script. |
| `-n`       | Do not submit (dry run). |
| `-h`       | Print a help message. |
| `-D`       | Debug mode with (much) more information. |

## Miscellanious

If `LOGFILES` is set and a directory, the script will use it to store the logfiles.
If `~/logfiles` exists (and `LOGFILES` is unset, it will use this destination.
If neither applies, `HOME` will be the destination for logfiles. 
(TODO: Choose location.)

## License (GNU General Public License v3.0)

rwth-tools - a collection of scripts for CLAIX18  
Copyright (C) 2022 Ole Osterthun
Copyright (C) 2019 Martin C Schwarzer

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See [LICENSE](LICENSE) to see the full text.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

___version___: 2022-03-01-1600
