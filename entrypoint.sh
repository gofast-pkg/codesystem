#!/bin/bash
# Script codesystem checker to verify the files in the project are up to date
# You can add CODESYSTEM_IGNORED_FILES environment variable to ignore some files or folders
# Example: CODESYSTEM_IGNORED_FILES="folder1 folder2 file1 file2"

# Type of project: app or lib
TYPE=$1
# Context of project to find the files
CONTEXT=$2

# MAIN_FOLDER describe the folder location to extract the assets files
MAIN_FOLDER=verified_files
# URL describe the url to download the assets files
URL=https://github.com/gofast-pkg/codesystem/releases/latest/download
# APP_ZIP describe the name of the zip file for app project
APP_ZIP=app-codesystem.zip
# LIB_ZIP describe the name of the zip file for lib project
LIB_ZIP=lib-codesystem.zip

# init the folder to extract the assets files
# download the assets files and install them
init()
{
	local loc_zipname=$1
	if [ -d "$MAIN_FOLDER" ]; then
		rm -rf $MAIN_FOLDER
	fi
	mkdir $MAIN_FILES
	# download the zip file and extract it
	curl -LO $URL/$loc_zipname
	unzip -q -d $MAIN_FOLDER $loc_zipname
	shopt -s dotglob
	folder_browser $MAIN_FOLDER
	echo "files are verified"
}

# is_ignored check if the target is in the ignored files list
is_ignored()
{
	for value in $CODESYSTEM_IGNORED_FILES; do
		if [ "$value" = "$target" ]; then
			return 0
		fi
	done

	return 1
}

get_folderpath()
{
	FOLDERPATH=$(echo $1 | sed 's/'$MAIN_FOLDER'//g')
	# remove the first / character if exist
	if [[ ${FOLDERPATH:0:1} == "/" ]]; then
		FOLDERPATH=$(echo $FOLDERPATH | sed 's/\///')
	fi
}

get_filepath()
{
	local loc_folderpath=$1
	local loc_filepath=$2
	local loc_filename=$(basename $loc_filepath)

	# test if loc_folderpath is empty
	if [ -z $loc_folderpath ]; then
		FILEPATH=$loc_filename
	else
		FILEPATH=$loc_folderpath/$loc_filename
	fi
}

folder_browser()
{
	# save the input in the local variable
	local loc_folder=$1
	# get the folder path withtout the main folder
	get_folderpath $loc_folder
	local loc_folderpath=$FOLDERPATH
	if is_ignored $loc_folderpath; then
		echo "skip $loc_folderpath"
		return
	fi
	for file in $loc_folder/*; do
		if [ -d $file ]; then
			folder_browser $file
			continue
		fi

		# normalize the file path to remove the useless / character
		get_filepath "$loc_folderpath" "$file"
		local loc_filepath=$FILEPATH

		if is_ignored $loc_filepath; then
			echo "skip $loc_filepath"
			continue
		fi
		# check if file exist
		if [ ! -f $CONTEXT/$loc_filepath ]; then
			echo "File $loc_filepath not found in the context $CONTEXT/$loc_filepath"
			exit 1
		fi
		# check if files are different
		sha_remote=$(shasum $MAIN_FOLDER/$loc_filepath | grep -o -E -e "[0-9a-f]{40}")
		sha_locate=$(shasum $CONTEXT/$loc_filepath | grep -o -E -e "[0-9a-f]{40}")
		if [ ! $sha_remote == $sha_locate ]; then
			echo "File $loc_filepath is different. Replacing..."
			exit 1
		else
			echo "File $loc_filepath is up to date"
		fi
	done
}

if [ "$TYPE" = "app" ]; then
	init $APP_ZIP
elif [ "$TYPE" = "lib" ]; then
	init $LIB_ZIP
else
	echo "Invalid type. Please use 'app' or 'lib'."
	exit 1
fi
