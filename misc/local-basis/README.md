# Local basis

This directory contains scripts which are somewhat hastily hacked together.

***WARNING*** 
Only use these scripts if you know what you are doing,
or do not care about the consequences. 
***WARNING***

They provide access to the [EMSL Basis Set Exchange Library](https://bse.pnl.gov/bse/portal)
via a couple of bash scripts.
These is not much dynamic about it, some sections are hardcoded after analysing the source code 
of the website.
It might break easily, so use it carefully, to not break everything.
Dependencies: `wget`, `grep`, `sed`, `dos2unix`, `mktemp`, and probably some others I cannot remember.
Read the source, if you need to know more.

All scripts can be invoked with `debug`, to make them tell you what they are currently doing.

1. Create the database with `make-db.bash -c`, the file is created in `${PWD}/bse.db`
2. Search the database with (for example) `search-db.bash def2-svp`, which should give
   you an index number and the name. In this case probably `64: Def2-SVP`.
   The script uses `grep`, so any expression that is valid for it should be valid here.
3. Download the (complete) basis set to `${PWD}/download-basis/<basisset name>/` with `download-bs.bash`; 
   in this example it would be `${PWD}/download-basis/Def2-SVP/` with `download-bs.bash 64`


```
.
├── download-bs.bash
├── make-db.bash
├── README.md
└── search-db.bash
```

___version___: 2019-04-04-1847


