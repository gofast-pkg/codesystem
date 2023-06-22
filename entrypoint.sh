#!/bin/bash

TYPE=$1
CONTEXT=$2

FOLDER_FILES=verified_files
URL=https://github.com/gofast-pkg/codesystem/releases/latest/download
APP_ZIP=app-codesystem.zip
LIB_ZIP=lib-codesystem.zip

file_checker()
{
	ZIP_NAME=$1
	mkdir $FOLDER_FILES
	echo "Downloading files..."
	curl -LO $URL/$ZIP_NAME
	echo "Unzipping $ZIP_NAME ..."
	unzip -q -d $FOLDER_FILES $ZIP_NAME
	shopt -s dotglob
	for file in $FOLDER_FILES/*; do
		filename=$(basename "$file")
		echo "check $filename"
		if [ ! -f $CONTEXT/$filename ]; then
			echo "File $filename not found in the context $CONTEXT/$filename"
			exit 1
		fi
		sha_remote=$(shasum $FOLDER_FILES/$filename | grep -o -E -e "[0-9a-f]{40}")
		sha_locate=$(shasum $CONTEXT/$filename | grep -o -E -e "[0-9a-f]{40}")
		if [ ! $sha_remote == $sha_locate ]; then
			echo "File $filename is different. Replacing..."
			exit 1
		fi
	done

	echo "files are verified"
}

if [ -d "$FOLDER_FILES" ]; then
	rm -rf $FOLDER_FILES
fi
if [ "$TYPE" = "app" ]; then
	file_checker $APP_ZIP
elif [ "$TYPE" = "lib" ]; then
	file_checker $LIB_ZIP
else
	echo "Invalid type. Please use 'app' or 'lib'."
	exit 1
fi
