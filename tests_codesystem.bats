#!/usr/bin/env bats

# load script to test.
load './entrypoint.sh'

# Setup.
setup() {
  TMP_DIR=$(mktemp -d)
  CONTEXT=$TMP_DIR
}

teardown() {
  rm -rf "$TMP_DIR"
}

# ---- Tests is_ignored ----

@test "is_ignored returns 0 for ignored file" {
  CODESYSTEM_IGNORED_FILES="ignored.txt other.txt"
  run is_ignored "ignored.txt"
  [ "$status" -eq 0 ]
}

@test "is_ignored returns 1 for non-ignored file" {
  CODESYSTEM_IGNORED_FILES="ignored.txt other.txt"
  run is_ignored "file.txt"
  [ "$status" -eq 1 ]
}

# ---- Tests get_folderpath ----

@test "get_folderpath removes main folder prefix" {
  MAIN_FOLDER="verified_files"
  get_folderpath "verified_files/sub/folder"
  [ "$FOLDERPATH" = "sub/folder" ]
}

@test "get_folderpath removes trailing /" {
  MAIN_FOLDER="verified_files"
  get_folderpath "verified_files/sub/folder/"
  echo "$FOLDERPATH"
  [ "$FOLDERPATH" = "sub/folder" ]
}

# ---- Tests get_filepath ----

@test "get_filepath combines folder path and filename" {
  get_filepath "sub/folder" "/tmp/file.txt"
  [ "$FILEPATH" = "sub/folder/file.txt" ]
}

@test "get_filepath returns filename if folderpath is empty" {
  get_filepath "" "/tmp/file.txt"
  [ "$FILEPATH" = "file.txt" ]
}

# ---- Tests folder_browser ----

@test "folder_browser skips ignored folders" {
  MAIN_FOLDER="${TMP_DIR}"
  CODESYSTEM_IGNORED_FILES="skipfolder"
  mkdir -p "$TMP_DIR/skipfolder"
  run folder_browser "$TMP_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"skip skipfolder"* ]]
}

@test "folder_browser detects missing file" {
  REPLACE=true

  mkdir -p "$TMP_DIR/main_folder"
  echo "remote content" > "$TMP_DIR/main_folder/file.txt"
  MAIN_FOLDER="${TMP_DIR}/main_folder"

  mkdir -p "$TMP_DIR/context"
  CONTEXT="${TMP_DIR}/context/"

  run folder_browser "$TMP_DIR/main_folder"
  [ "$status" -eq 0 ]
  [[ "$output" == *"File file.txt added"* ]]
}

@test "folder_browser detects out of sync file" {
  REPLACE=true

  mkdir -p "$TMP_DIR/main_folder"
  echo "remote content" > "$TMP_DIR/main_folder/file.txt"
  MAIN_FOLDER="${TMP_DIR}/main_folder"

  mkdir -p "$TMP_DIR/context"
  echo "remote content out of sync" > "$TMP_DIR/context/file.txt"
  CONTEXT="${TMP_DIR}/context/"

  run folder_browser "$TMP_DIR/main_folder/"
  [ "$status" -eq 0 ]
  [[ "$output" == *"File file.txt replaced"* ]]
}

@test "folder_browser no detection change" {
  REPLACE=true

  mkdir -p "$TMP_DIR/main_folder"
  echo "remote content" > "$TMP_DIR/main_folder/file.txt"
  MAIN_FOLDER="${TMP_DIR}/main_folder"

  mkdir -p "$TMP_DIR/context"
  echo "remote content" > "$TMP_DIR/context/file.txt"
  CONTEXT="${TMP_DIR}/context/"

  run folder_browser "$TMP_DIR/main_folder/"
  [ "$status" -eq 0 ]
  [[ "$output" == *"File file.txt is up to date"* ]]
}

@test "folder_browser detects missing file --no-replace" {
  REPLACE=false

  mkdir -p "$TMP_DIR/main_folder"
  echo "remote content" > "$TMP_DIR/main_folder/file.txt"
  MAIN_FOLDER="${TMP_DIR}/main_folder"

  mkdir -p "$TMP_DIR/context"
  CONTEXT="${TMP_DIR}/context/"

  run folder_browser "$TMP_DIR/main_folder"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File file.txt not found"* ]]
}

@test "folder_browser detects out of sync file --no-replace" {
  REPLACE=false

  mkdir -p "$TMP_DIR/main_folder"
  echo "remote content" > "$TMP_DIR/main_folder/file.txt"
  MAIN_FOLDER="${TMP_DIR}/main_folder"

  mkdir -p "$TMP_DIR/context"
  echo "remote content out of sync" > "$TMP_DIR/context/file.txt"
  CONTEXT="${TMP_DIR}/context/"

  run folder_browser "$TMP_DIR/main_folder/"
  [ "$status" -eq 1 ]
  [[ "$output" == *"File file.txt differs"* ]]
}
