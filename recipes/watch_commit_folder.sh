#!/bin/bash

# This script watches $COMMITS_DIR for new files, and invokes cook_recipes whenever a new file is added
RECIPE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $RECIPE_DIR
source common.sh


if [[ -z "$(which inotifywait)" ]]; then
    echo "ERROR: must install inotifywait!" 1>&2
    exit -1
fi

mkdir -p $COMMITS_DIR
chmod 777 $COMMITS_DIR

while [ yes ]; do
    while [[ ! -z "$(ls $COMMITS_DIR)" ]]; do
        for COMMIT in $(ls $COMMITS_DIR); do
            BRANCH=$(cat $COMMITS_DIR/$COMMIT)
            rm $COMMITS_DIR/$COMMIT
            ./cook_recipes.sh $BRANCH $COMMIT
        done
    done
    inotifywait -e CREATE $COMMITS_DIR
done
