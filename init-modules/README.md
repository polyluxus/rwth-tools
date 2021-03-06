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

See [LICENSE](../LICENSE) to see the full text.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

___version___: 2019-09-17-1200
