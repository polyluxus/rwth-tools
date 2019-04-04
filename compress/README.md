# rwth-compress.sh

This is a small script which submits a job to the queueing system 
to compress a directory into an archive file.

## Usage
 
```
rwth-compress.sh [opt] <target_(base)_filename> <source_directory>
```

The script tries to guess from the extension which action to use;
where it will default to first create a tar archive and use zstd to compress it.
(Currently supported: .tgz, .tar.gz, .tar.gzip, .tar.zstd [default]; WIP: .zip, .7z)

I therefore recommend installing [zstd](https://github.com/facebook/zstd) before
using this script.

## Options

| Switch     | Function |
|:-----------|:---------|
| `-q <ARG>` | select a queueing system; supported: slurm [default], bsub |
| `-k`       | keep the submission script |
| `-h`       | print a help message |

## Miscellanious

If `LOGFILES` is set and a directory, the script will use it to store the logfiles.
If `~/logfiles` exists (and `LOGFILES` is unset, it will use this destination.
If neither applies, `HOME` will be the destination for logfiles. 
(TODO: Choose location.)

___version___: 2019-04-04-1847
