#!/bin/sh
#
#  updatecheck.sh: Check for updates to Epichrome
#  
#  Copyright (C) 2020  David Marmor
#
#  https://github.com/dmarmor/epichrome
#
#  Full license at: http://www.gnu.org/licenses/ (V3,6/29/2007)
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 


# ABORT -- exit cleanly on error

function abort {
    [[ -d "$appTmp" ]] && rmtemp "$appTmp" 'temporary app bundle'
    
    [[ "$1" ]] && echo "$1" 1>&2
    
    local result="$2" ; [ "$result" ] || result=1
    exit "$result"
}


# HANDLE KILL SIGNALS

trap "abort 'Unexpected termination.' 2" SIGHUP SIGINT SIGTERM


# BOOTSTRAP RUNTIME SCRIPT

source "${0%/*}/../Runtime/Resources/Scripts/runtime.sh"
[[ "$?" != 0 ]] && abort 'Unable to load runtime script.'


# GET INFO ON MY INSTANCE OF EPICHROME

epichromeinfo "$myPath"


# COMPARE VERSIONS

if [[ "$ok" ]] ; then
    if [[ "$2" ]] ; then
	
	# compare two versions & echo the latest
	
	if vcmp "$1" '<' "$2" ; then
	    echo "$2"
	else
	    echo "$1"
	fi
    else

	# compare the supplied version against the latest on GitHub
	
	checkepichromeversion "$myPath/Contents/Resources/Runtime" "$1"
    fi
fi

[[ "$ok" ]] || abort "$errmsg" 1
