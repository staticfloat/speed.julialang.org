#!/bin/bash

# Finds all recipes, creates (or updates) a checkout of Julia for each in REPOS_DIR
# Needs the commit and branch to be passed in from the command line:
#
# cook_recipes.sh <branch> <commit>
#

REPOS_DIR=/tmp/julia_recipe_build_area/
BRANCH=$1
COMMIT=$2
RECIPE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $RECIPE_DIR

# Gotta do this so that when we're run by www-data we install packages into the proper place
export JULIA_PKGDIR=/tmp/julia_recipe_build_area/pkgdir/
mkdir -p $JULIA_PKGDIR

for recipe in $(ls build_*.sh); do
    flavor=${recipe:6:-3}

    # create git repo if not already created
    if [[ ! -d $REPOS_DIR/julia-$flavor ]]; then
        git clone https://github.com/staticfloat/julia.git $REPOS_DIR/julia-$flavor
    fi

    pushd $REPOS_DIR/julia-$flavor

    # set to branch and commit as requested from outside
    git fetch
    git checkout $BRANCH/$COMMIT
    make cleanall

    # Run recipe to build this julia commit
    $RECIPE_DIR/build_$flavor.sh 2>&1 | tee ../julia-${flavor}_build.log

    popd >/dev/null

    # Run this julia build on all the tests by invoking taste_flavor.jl
    $REPOS_DIR/julia-$flavor/julia $RECIPE_DIR/taste_flavor.jl $flavor $BRANCH $COMMIT
done