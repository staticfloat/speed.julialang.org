#!/bin/bash

REPOS_DIR=/tmp/julia_recipe_build_area/
COMMITS_DIR=$REPOS_DIR/incoming
RECIPE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export JULIA_PKGDIR=$REPOS_DIR/pkgdir
