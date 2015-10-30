#!/bin/bash
#
# Setup script to start development on OpSech.io
# website. Currently only supports Fedora (DNF)
#
# Author: Michael Goodwin

# dnf package install array
DNF_INSTALL=(
	python{,-virtualenv{,wrapper},-devel}
	libjpeg-turbo-devel 
	zlib-devel	
)

# pip package install array
PIP_INSTALL=( 
	markdown
	pillow 
	beautifulsoup4
	typogrify
)	

# Install based pre-virtualenv requirements 
# libjpeg and zlib devel are for python compiling the Pillow library (see below)
sudo dnf install "${DNF_INSTALL[@]}"

# Setup python virtual environment for working with pelican 
(
virtualenv ~/virtualenvs/pelican
source ~/virtualenvs/pelican/bin/activate
pip install "${PIP_INSTALL[@]}"
)

# We need to pull in the long tree of plugins recursively
# Since the pelican-plugins git project also links to some 
# plugins as submodules. 
git submodule update --init --recursive

# The project tends to point to certain commits, but
# We probably don't want that, so let's update everything to master
git submodule foreach --recursive 'git checkout master; git pull'

