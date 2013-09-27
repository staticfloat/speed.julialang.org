speed.julialang.org
===================

This repository contains all configuration and code needed to run a [codespeed](https://github.com/tobami/codespeed/) server for the [Julia project](http://julialang.org).  The imaginary url notwithstanding, an example installation can be seen at http://128.52.160.154/

The `etc/` directory contains configuration files for an ubuntu-based system to run an nginx server connected to a uwsgi process and django installation to listen to travis hooks and serve codespeed pages, respectively

The `www/` directory contains the web code.
`www/codespeed` is a git checkout of the codespeed install, and contains all the files needed to run the codespeed frontend on nginx.  There's nothing special in here, except a copy of the `sample_project` folder called `julia_codespeed`.  Inside this folder is where the database holding all codespeed results is stored.
`www/julia_codespeed` is the site specifically setup for the Julia codespeed installation.
`www/posthook.py` is a python uwsgi application that is invoked by nginx to kick off compilation and testing of a new julia commit.  It does this by writing a file into a directory to notify a listening process (using inotifywait on linux, or fswait on osx) that a new build is ready to go.  Note that this code can be placed on multiple computers, and if they are properly configured with regards to the location of the codespeed server, they can all report independently.

The `recipes/` directory contains the recipes detailing how to build different julia executables.
Note that each recipe must start with the `build_` prefix, and the suffix must be a valid directory name.  So far, two examples exist: `build_vanilla.sh` and `build_libblas.sh`.  Both are targeted toward Ubuntu, building an OpenBLAS-backed Julia and a system-provided BLAS-backed Julia respectively.


Notes
=====
Codespeed apparently does not pick up on parameters such as `units` in JSON submissions yet.  These must be set manually via the admin interface.

The timeline view may not function correctly yet, as it requires multiple commits before it can display data.
