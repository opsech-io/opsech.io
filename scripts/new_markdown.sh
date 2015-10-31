#!/bin/bash
#
# A script to start a new markdown post for pelican
#
# Author: Michael Goodwin
set -eux
PELICAN_DIR=".."
CONTENT_DIR="$( awk -F"[ =\'\"]" '$1 == "PATH" {print $5}' < "${PELICAN_DIR}/pelicanconf.py" )"
ARTICLES_DIR="articles"
YEAR="$(date +'%Y')"
CONTENT_LOC="${PELICAN_DIR}/${CONTENT_DIR}/${ARTICLES_DIR}/${YEAR}" 

# Header varibles to get from the user
IN_VARS=(
	TITLE
	CATEGORY
	TAGS
	SLUG
	SUMMARY
)

# Print an array, each element on a new line  
# This use case allows for two linebreaks after output
# because we want a space between header and article body.
print_array_newline() {
	eval printf \"%s\\n\" \"\$\{"${1}"[@]\}\"
	echo -en "\n\n" 
}

# Iterates through each IN_VARS element, and asks the user via stdin 
# to input information for each. Some of the confusing logic here 
# Is because I am using IN_VARS elements for the prompt text as well
# but am reformatting it to look like it will in the header.
# Could have probably avoided that by requring normal case IN_VARS elements
# (i.e. "Title" instead of "TITLE"), but this way negates the need to worry 
# about case altogether. 
for i in "${!IN_VARS[@]}"; do
	declare -a output input
	PROMPT_VAR="${IN_VARS[i],,}"    	   # To lowercase 
	PROMPT_VAR="${PROMPT_VAR^}"     	   # To first char upper case
	read -rp "${PROMPT_VAR}: " "input[$i]" 
	[[ ${input[i]} ]] &&    		   # Skip appending to the array if null
	output[$i]="${PROMPT_VAR}: ${input[i]}"    # Save the entier header line
done

# Get today's date for the post 
output+=( "Date: $(date)" )

# We need the title in order to output a file name 
# Since the above loop is agnostic on what we're inputting 
# I found it necessary to use awk to find it. 
TITLE=$( awk -F': ' '$1 == "Title" { gsub(" ","_",$2); print $2 }' < <( print_array_newline output ) )
FILE="${CONTENT_LOC}/${TITLE,,}.md"

if [[ -f ${FILE} ]]; then 
	read -rp "File \"${FILE}\" exists, overwrite? [y/N]" -N1 overwrite_choice 
	case "$overwrite_choice" in
		[Yy])
			print_array_newline output > "${FILE}"
		;;
		[Nn?])
			echo "Ok. Keeping old file. Current will be saved as ${FILE}-saved"
			print_array_newline output >> "${FILE}-saved" 
		;;
	esac 
else
	print_array_newline output >> "${FILE}" 
fi

vim +$ +start "${FILE}"
