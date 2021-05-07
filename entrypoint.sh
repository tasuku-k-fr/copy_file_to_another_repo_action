#!/bin/sh

set -e
set -x

if [ -z $INPUT_SOURCE_FILE ]
then
  echo "Source file must be defined"
  return -1
fi

if [ -z "$INPUT_DESTINATION_BRANCH" ]
then
  INPUT_DESTINATION_BRANCH=main
fi
OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH"

CLONE_DIR=$(mktemp -d)

echo "Cloning destination git repository"
git config --global user.email "$INPUT_USER_EMAIL"
git config --global user.name "$INPUT_USER_NAME"
git clone --single-branch --branch $INPUT_DESTINATION_BRANCH "https://x-access-token:$API_TOKEN_GITHUB@github.com/$INPUT_DESTINATION_REPO.git" "$CLONE_DIR"
# this line is remove command of gastbyjs build hash files.
APP_ROOT_DIR=$CLONE_DIR/$INPUT_DESTINATION_FOLDER$INPUT_TARGET_DIR_NAME
REMOVE_FILES="$APP_ROOT_DIR/*.map $APP_ROOT_DIR/*.js $APP_ROOT_DIR/*.LICENSE.txt $APP_ROOT_DIR/*.css"
rm -f $REMOVE_FILES

echo "Copying contents to git repo all file escep"
mkdir -p $CLONE_DIR/$INPUT_DESTINATION_FOLDER
if [ "$INPUT_TARGET_DIR_NAME" ]
then 
  mv $INPUT_SOURCE_FILE/ $INPUT_TARGET_DIR_NAME/
  cp -R $INPUT_TARGET_DIR_NAME "$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
  mv $INPUT_TARGET_DIR_NAME/ $INPUT_SOURCE_FILE/
else
  cp -R $INPUT_SOURCE_FILE "$CLONE_DIR/$INPUT_DESTINATION_FOLDER"
fi
cd "$CLONE_DIR"

if [ ! -z "$INPUT_DESTINATION_BRANCH_CREATE" ]
then
  git checkout -b "$INPUT_DESTINATION_BRANCH_CREATE"
  OUTPUT_BRANCH="$INPUT_DESTINATION_BRANCH_CREATE"
fi

if [ -z "$INPUT_COMMIT_MESSAGE" ]
then
  INPUT_COMMIT_MESSAGE="Update from https://github.com/${GITHUB_REPOSITORY}/commit/${GITHUB_SHA}"
fi

echo "Adding git commit"
git add .
if git status | grep -q "Changes to be committed"
then
  git commit --message "$INPUT_COMMIT_MESSAGE"
  echo "Pushing git commit"
  git push -u origin HEAD:$OUTPUT_BRANCH
else
  echo "No changes detected"
fi
