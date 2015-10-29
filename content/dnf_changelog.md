Title: How to view latest changelog entries for dnf updates
Date: Wed Oct 28 10:09:28 EDT 2015
Modified: Wed Oct 28 13:10:42 EDT 2015
Category: scripts
Tags: linux, fedora, dnf
Slug: dnf-updates-changelog
Summary: A simple script for reading the latest changelog entries for dnf (and therefore rpm) packages.

DNF seems to be missing a proper [yum-changelog](http://linux.die.net/man/1/yum-changelog) plugin, 
so I wrote this tiny script to help me understand what had changed and why (only works after installed).

It outputs a header for each updated package based on `dnf history info '*'` and highlights CVE updates in red (on the console) for higher visibility.

<br />

Usage `bash dnf_changelog.sh [<history id>]` 

<br />

```
#!/bin/bash
# Read in latest updated packages (post install) and show just most recent
# changelog entries for those packages
#set -ux 
LAST_UPDATE=$( sudo dnf history | awk -F'|' '$4 ~ /([ ]+U|Update)/{print $1; exit}' ) 

sudo dnf history info ${1:-${LAST_UPDATE}} \
	| awk '/Upgraded[ ]+/{ gsub("[-][0-9]*[-]?[0-9]+[.:].*","",$2); pkg = $2 } /Upgrade[ ]+/{ OFS=""; print pkg,"-",$2 }' \
	| while read -r a; do
		count=0
		echo -e "\e[1;32m###### CHANGELOG FOR: ${a^^} ######\e[0m\n"
		rpm -q --changelog "$a" \
			| while read -r b; do
				
				if [[ $b =~ ^\* ]]; then
					((count++))
				fi
				
				[[ $count == 2 ]] && break
				CVE_REGEX="CVE-[0-9]{4}-[0-9]{4}"
				if [[ $b =~ .*${CVE_REGEX}.* ]]; then
					C_R=$'\033[1;31m'
					C_N=$'\033[0m'
					echo "$b" | sed -r 's|('"$CVE_REGEX"')|'"$C_R"'\1'"$C_N"'|'
				else 
					echo "$b"
				fi

			  done
	  done \
	| less -r  
```

<br />

![dnf_changelog.sh](/images/dnf_changelog.png)
