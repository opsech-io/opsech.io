#!/usr/bin/env bash
#
# Setup script to start development on OpSech.io
# website. Currently only supports Fedora (DNF)
#
# Author: Michael Goodwin
set -eu
PELICAN_DIR="$(dirname $0)/.."

# dnf package install array
DNF_INSTALL=(
	python{,-virtualenv{,wrapper},-devel}
	libjpeg-turbo-devel
	zlib-devel
	s3cmd	
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
set +u
mkdir -p ~/virtualenvs
virtualenv ~/virtualenvs/pelican
source ~/virtualenvs/pelican/bin/activate
pip install "${PIP_INSTALL[@]}"
)

# We need to pull in the long tree of plugins recursively
# Since the pelican-plugins git project also links to some
# plugins as submodules.
(
cd "${PELICAN_DIR}"
git submodule update --init --recursive

# The project tends to point to certain commits, but
# We probably don't want that, so let's update everything to master
git submodule foreach --recursive 'git checkout master; git pull'
)
# Setup s3cmd
# Go get ACCESS_KEY and SECRET_ACCESS_KEY that
# Can R/W to the proper site bucket!
# _MUST_ be the same name as the domain if you intend
# to serve your content with S3 as the static server!
if [[ ! -e ~/.s3cfg ]]; then
	s3cmd --configure
fi
