#!/bin/bash
# CodeSystem Checker: verify project files are up to date
# Use CODESYSTEM_IGNORED_FILES environment variable to ignore files/folders
# Example: CODESYSTEM_IGNORED_FILES="folder1 folder2 file1 file2"

# -----------------------------
# Configuration
# -----------------------------
TYPE=$1                 # Project type: "app" or "lib"
CONTEXT=$2              # Project folder to check
AUTO_REPLACE=$3         # "--auto-replace" to replace differing/missing files

MAIN_FOLDER="verified_files"
URL="https://github.com/gofast-pkg/codesystem/releases/latest/download"
APP_ZIP="app-codesystem.zip"
LIB_ZIP="lib-codesystem.zip"
REPLACE=false

# -----------------------------
# Functions
# -----------------------------

# Initialize local folder and download assets
init() {
	local zip_name="$1"

	[ -d "$MAIN_FOLDER" ] && rm -rf "$MAIN_FOLDER"
	mkdir -p "$MAIN_FOLDER"

	curl -LO "$URL/$zip_name"
	unzip -q -d "$MAIN_FOLDER" "$zip_name"

	shopt -s dotglob
	folder_browser "$MAIN_FOLDER"

	echo "All files are verified."
	exit 0
}

# Check if target file/folder is ignored
is_ignored() {
	local target="$1"

	for value in $CODESYSTEM_IGNORED_FILES; do
		[ "$value" = "$target" ] && return 0
	done
	return 1
}

# Get folder path relative to MAIN_FOLDER
get_folderpath() {
	local input="$1"

	FOLDERPATH="${input#$MAIN_FOLDER}"   # Remove MAIN_FOLDER prefix
	FOLDERPATH="${FOLDERPATH#/}"         # Remove leading slash if present
	FOLDERPATH="${FOLDERPATH%/}"         # Remove trailing slash if present
}

# Get normalized file path
get_filepath() {
	local folderpath="$1"
	local filepath="$2"
	local filename
	filename=$(basename "$filepath")

	if [ -z "$folderpath" ]; then
		FILEPATH="$filename"
	else
		FILEPATH="$folderpath/$filename"
	fi
}

# Recursively check folder contents
folder_browser() {
	local folder="$1"

	get_folderpath "$folder"
	local folderpath="$FOLDERPATH"

	if is_ignored "$folderpath"; then
		echo "skip $folderpath"
		return
	fi

	for file in "$folder"/*; do
		[ -d "$file" ] && folder_browser "$file" && continue

		get_filepath "$folderpath" "$file"
		local filepath="$FILEPATH"

		if is_ignored "$filepath"; then
			echo "skip $filepath"
			continue
		fi

		# Check if file exists in context
		if [ ! -f "$CONTEXT/$filepath" ]; then
			echo "File $filepath not found in $CONTEXT/$filepath"
			if [ "$REPLACE" = true ]; then
				cp "$MAIN_FOLDER/$filepath" "$CONTEXT/$filepath"
				echo "File $filepath added."
			else
				exit 1
			fi
		fi

		# Check if file contents differ
		sha_remote=$(shasum "$MAIN_FOLDER/$filepath" | awk '{print $1}')
		sha_local=$(shasum "$CONTEXT/$filepath" | awk '{print $1}')

		if [ "$sha_remote" != "$sha_local" ]; then
			echo "File $filepath differs."
			if [ "$REPLACE" = true ]; then
				cp "$MAIN_FOLDER/$filepath" "$CONTEXT/$filepath"
				echo "File $filepath replaced."
			else
				exit 1
			fi
		else
			echo "File $filepath is up to date."
		fi
	done
}

# -----------------------------
# Main execution
# -----------------------------
main() {
	if [ -z "$CONTEXT" ]; then
		echo "Context cannot be empty. Usage: ./script.sh 'app|lib' 'context-path' [--auto-replace]"
		exit 1
	fi

	if [ "$AUTO_REPLACE" = "--auto-replace" ]; then
		REPLACE=true
	elif [ -n "$AUTO_REPLACE" ]; then
		echo "Unknown option: $AUTO_REPLACE. Only --auto-replace is allowed."
		exit 1
	fi

	echo "files ignored by codesystem: $CODESYSTEM_IGNORED_FILES"

	if [ "$TYPE" = "app" ]; then
		init "$APP_ZIP"
	elif [ "$TYPE" = "lib" ]; then
		init "$LIB_ZIP"
	else
		echo "Invalid type. Please use 'app' or 'lib'."
		exit 1
	fi
}

# Execute main only if script is called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main "$@"
fi