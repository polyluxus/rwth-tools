# Notes on Gaussview

Gaussview is unfortunately unable to write Xmol files, for whatever reason,
this is not supported.
Instead it can write a standard Gaussian input file, 
which you could set up ready-for-submission-complete with Gaussview.
A lot of people do that, it is the GUI to Gaussian after all,
the downside of this approach is that you tend to forget what you are doing.

Not everything in those input files is necessary, and some of it is a terrible choice.
For example, it usually includes the absolute paths to checkpoint files.
If you decide to change anything (and this is quite likely) and then rerun a calculation,
it will very likely fail, or overwrite existing things.
If you are using Gaussview locally, but submit a calculation to the cluster,
it is also likely, that the specified location does not exist.

There are easy and not quite as easy workarounds: 

- Use a different program.
- Edit the files on the cluster by hand, remove everything superflous with a text editor.
- Convert them with, e.g. Molden. (Unfortunately Open Babel cannot do that.)
- Use my prepare script. It will search the inputfile for lines of the pattern
  ```
  XX  +000.0000  -000.0000  +000.0000
  ```
  (Two letters followed by three real numbers.)
- Alternatively, you can use a different program. (Seriously, it is worth mentioning it twice.)
- You can use the [`newzmat`](http://gaussian.com/newzmat/) utility to convert it.


___version___: 2019-09-17-1200
