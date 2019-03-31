#!/bin/bash 

# You can obtain the latest release from https://github.com/jgm/pandoc,
# or directly go to the download page of the https://github.com/jgm/pandoc/releases/latest.

# Detailed installation instructions are available in https://github.com/jgm/pandoc/blob/master/INSTALL.md.

# The module files in this directory assume that they are installed along the following path:
pandoc_base="$HOME/local/pandoc"

echo "Obtaining pandoc. This may take a while."
echo "Install target: $pandoc_base"

# If the installation directory does not yet exist, create it:
[[ -d "$pandoc_base" ]] || mkdir -v -- "$pandoc_base"

# You can obtain the latest tarball archive with the following commands:
pandoc_tgz_src=$(curl -s "https://api.github.com/repos/jgm/pandoc/releases/latest" | grep "browser_download_url.*tar.gz" | cut -d '"' -f 4)
wget --no-verbose --directory-prefix="$pandoc_base" "$pandoc_tgz_src"
pandoc_tgz="${pandoc_tgz_src##*/}"
pandoc_dest="${pandoc_tgz%-*}"
[[ -d "$pandoc_base/$pandoc_dest" ]] && { echo "Directory '$pandoc_base/$pandoc_dest' alredy exists. Abort." ; exit 1 ; }
mkdir -v -- "$pandoc_base/$pandoc_dest"
pushd "$pandoc_base" || { echo "Cannot change to install directory '$pandoc_base'. Abort." ; exit 1 ; }
tar xvzf "$pandoc_tgz" --strip-components 1 -C "$pandoc_dest"

# Assuming your local module files are installed in the following directories
module_LOCAL="$HOME/local/modules/modulefiles/LOCAL"
module_source="$HOME/local/modules/modulefiles/source"
[[ -d "$module_LOCAL" ]] || { echo "Directory '$module_LOCAL' does not exist. Abort." ; exit 1 ; }
[[ -d "$module_source" ]] || { echo "Directory '$module_source' does not exist. Abort." ; exit 1 ; }

# and further assuming `rwth-tools` is installed in the directory
rwth_tools_src="$HOME/local/rwth-tools"
[[ -d "$rtwh_tools_src" ]] || { echo "Directory '$rwth_tools_src' does not exist. Abort." ; exit 1 ; }

# copy the module files directly from *here* to *there*:
cp --no-clobber -vr -- "$rwth_tools_src/modules/modulefiles/LOCAL/pandoc" "$module_LOCAL"
cp --no-clobber -vr -- "$rwth_tools_src/modules/modulefiles/source/pandoc" "$module_source"

#Check with `module avail` if the new module file is recognised.
#You should now be able to load it with `module load pandoc`.

echo "This install script is ___version___: 2019-03-31-1608"

