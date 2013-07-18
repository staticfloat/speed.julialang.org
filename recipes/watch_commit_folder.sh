#!/bin/bash

# This script watches $COMMITS_DIR for new files, and invokes cook_recipes whenever a new file is added
RECIPE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $RECIPE_DIR
source common.sh


if [[ "$(uname)" == "Darwin" ]]; then
    if [[ -z "$(which fswait)" ]]; then
        echo "ERROR: must install fswait!" 1>&2
        exit -1
    fi
    WAIT_CMD="fswait"
fi

if [[ "$(uname)" == "Linux" ]]; then
    if [[ -z "$(which inotifywait)" ]]; then
        echo "ERROR: must install inotifywait!" 1>&2
        exit -1
    fi
    WAIT_CMD="inotifywait -e CREATE"
fi

mkdir -p $COMMITS_DIR
chmod 777 $COMMITS_DIR

echo "Watching $COMMITS_DIR..."
while [ yes ]; do
    while [[ ! -z "$(ls $COMMITS_DIR)" ]]; do
        for COMMIT in $(ls $COMMITS_DIR); do
            BRANCH=$(cat $COMMITS_DIR/$COMMIT)
            ./cook_recipes.sh $BRANCH $COMMIT
            rm $COMMITS_DIR/$COMMIT
        done
    done
    $WAIT_CMD $COMMITS_DIR
done
