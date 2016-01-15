#!/usr/bin/env bash
#
# A script to start a new markdown post for pelican
#
# Author: Michael Goodwin
set -eu
PELICAN_DIR="$(dirname $0)/.."
CONTENT_DIR="$( awk -F"[ ='\"]" '$1 == "PATH" {print $5}' < "${PELICAN_DIR}/pelicanconf.py" )"
echo "Creating new article: "
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

# We'll take something like "Title: Foo bar" from the array
# and turn it into "foo_bar.md"
to_filename() {
	awk -F': ' '$1 == "'"$1"'" { gsub("[- ]","_",$2); tolower($2); print $2".md" }' < <( print_array_newline output )
	return $?
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
	
	if [[ ${input[i]} ]]; then		   # Skip appending to the array if null
		output[$i]="${PROMPT_VAR}: ${input[i]}"    # Save the entier header line
	elif [[ $PROMPT_VAR == "Title" && -z ${input[i]} ]]; then
		{ echo "Error: At minimum, \"Title:\" is required."; exit 1; } >&2
	fi
done
# Get today's date for the post
output+=( "Date: $(date)" )

# We need the title in order to output a file name
# Since the above loop is agnostic on what we're inputting
# If user input a Slug:, use that, else Title:
if ( print_array_newline output | grep -q "Slug: " ); then
	FILE="${CONTENT_LOC}/$(to_filename Slug)"
else
	FILE="${CONTENT_LOC}/$(to_filename Title)"
fi

# Logic to handle existing articles, ask the user if they
# want to overwrite first, then either truncate the old file
# or save the new input somewhere else as what the name would be + -saved
# If the file doesn't exist at all, just output it
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
	if [[ ! -d ${CONTENT_LOC} ]]; then
		echo "Dir \"${CONTENT_LOC}\", doesn't exist! Creating.." 
		mkdir -p "${CONTENT_LOC}" 
	fi
	print_array_newline output >> "${FILE}"
fi

set +u
for i in "$VISUAL" "$EDITOR"; do
	if [[ $i =~ /vim ]]; then
		"$i" +$ +start "${FILE}"
		break
	elif [[ $i =~ /kate ]]; then
		"$i" -l $(wc -l "${FILE}")
		break
	elif [[ -n $i ]]; then
		"$i" "${FILE}"
		break
	fi
done
set -u
