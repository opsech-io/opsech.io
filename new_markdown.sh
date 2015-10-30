#!/bin/bash
#
# A script to start a new markdown post for pelican
#
# Author: Michael Goodwin
set -eux

# Get content location, assumes: ./<content_path>/articles/<year>
CONTENT_LOC="$( awk -F"[ ='\"]" '$1 == "PATH" {print $5}' < pelicanconf.py )/articles/$(date +'%Y')" 

# Header varibles to get from the user
IN_VARS=(
	TITLE
	CATEGORY
	TAGS
	SLUG
	SUMMARY
)

print_array_newline() {
	eval printf \"%s\\n\" \"\${$1[@]}\"
	echo -en "\n\n" 
} 

for i in ${!IN_VARS[@]}; do
	declare -a output input
	PROMPT_VAR="${IN_VARS[i],,}"
	PROMPT_VAR="${PROMPT_VAR^}" 
	read -p "${PROMPT_VAR}: " "input[$i]"
	output[$i]="${PROMPT_VAR}: ${input[i]}" 
done

output+=( "Date: $(date)" )
TITLE=$( awk -F': ' '$1 == "Title" { gsub(" ","_",$2); print $2 }' < <( print_array_newline output ) )
FILE="${CONTENT_LOC}/${TITLE,,}.md"

if [[ -f ${FILE} ]]; then 
	read -p "File \"${FILE}\" exists, overwrite? [y/N]" -N1 overwrite_choice 
	case "$overwrite_choice" in
		[Yy])
			print_array_newline output >> "${FILE}"
		;;
		[Nn?])
			echo "Ok. Keeping old file. Current will be saved as ${FILE}-saved"
			print_array_newline output >> "${FILE}-saved" 
		;;
	esac 
else
	print_array_newline output >> "${FILE}" 
fi
