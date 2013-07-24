#!/bin/bash

# Finds all recipes, creates (or updates) a checkout of Julia for each in REPOS_DIR
# Needs the commit and branch to be passed in from the command line:
#
# cook_recipes.sh <branch> <commit>
#

source common.sh
BRANCH=$1
COMMIT=$2

mkdir -p $JULIA_PKGDIR

for recipe in $(ls build_*.sh); do
    flavor=$(echo $recipe | sed -E 's/build_(.*)\.sh/\1/g')

    # create git repo if not already created
    if [[ ! -d $REPOS_DIR/julia-$flavor ]]; then
        git clone https://github.com/JuliaLang/julia.git $REPOS_DIR/julia-$flavor
    fi

    pushd $REPOS_DIR/julia-$flavor

    # set to branch and commit as requested from outside
    git fetch
    git reset --hard origin/$BRANCH
    git checkout $COMMIT
    make cleanall

    # Run recipe to build this julia commit
    $RECIPE_DIR/build_$flavor.sh 2>&1 | tee ../julia-${flavor}_build.log

    # Grab some metadata about this build real quick
    export JULIA_FLAVOR=$flavor
    if [[ "$(uname)" == "Darwin" ]]; then
        export JULIA_COMMIT_DATE=$(date -jr $(git log -1 --pretty=format:%ct) -u '+%Y-%m-%d %H:%M:%S %Z')
    else
        export JULIA_COMMIT_DATE=$(date --date=@$(git log -1 --pretty=format:%ct) -u '+%Y-%m-%d %H:%M:%S %Z')
    fi
    export JULIA_BRANCH=$BRANCH

    # Run our new performance testsuite!
    cd test/perf
    make codespeed

    popd >/dev/null

    echo "Done with $flavor - $BRANCH $COMMIT"
    echo
done
