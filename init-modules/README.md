# init-modules.sh

This is a small, more secure version of the initialisation script for the module command. 
It can be used on CLAIX18 as a replacement script for the recommended one mentioned in
`/usr/local_host/etc/bashrc`
([see the cluster documentation for details](https://doc.itc.rwth-aachen.de/display/CC/modules+system):
```
# Make module available:
. /usr/local_host/etc/init_modules.sh
```

When I mentioned to the IT service desk the security risks the current recommended usage poses,
I was told that they were working on a new implementation of the module system.
I recently noticed that the script still has not changed, so I can only again recommend switching.

___version___: 2019-06-24-1724
