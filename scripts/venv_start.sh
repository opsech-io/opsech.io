#!/usr/bin/env bash
#
# If you want to use this on the commandline
# You need to use `source` or `.` just like below!
#
# Start the python virtualenv, or source it in scripts:
#

venvwrap_path=$( command -v virtualenvwrapper.sh )

if [[ "$venvwrap_path" ]]; then
	source "$venvwrap_path"
	workon pelican
elif [[ -x ~/.virtualenvs/pelican/bin/activate ]]; then
	source ~/.virtualenvs/pelican/bin/activate
elif [[ -x ~/virtualenvs/pelican/bin/activate ]]; then
	source ~/virtualenvs/pelican/bin/activate
fi
